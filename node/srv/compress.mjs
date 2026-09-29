/*
 * compress.mjs - gzip for the framework's responses in a Node host: what the
 * ICF does for them on an SAP system.
 *
 * z2ui5_cl_ui5_http_handler asks the ICF to compress every response
 * (set_response, the dynamic SET_COMPRESSION call), and on an SAP system the
 * GET page - ~360 KB, the whole UI5 frontend embedded - travels as ~85 KB,
 * the roundtrip JSON cut as much. open-abap's express shim has no such
 * method, so a Node host sent everything uncompressed. compress() is the
 * missing half: an express-style middleware, (req, res, next), over
 * node:zlib and nothing else. createApp() puts it in front of the handler;
 * a host that mounts createHandler() on an express app of its own adds it
 * the same way.
 *
 * GZIP ONLY. The GET page carries an ETag, and the framework answers a
 * conditional GET itself (_check_etag_match): an exact tag, a weak W/"tag",
 * or Apache mod_deflate's "tag-gzip" - the suffix INSIDE the quotes. A
 * compressed page is another representation and needs another strong tag,
 * so it goes out as "tag-gzip", and the browser's If-None-Match: "tag-gzip"
 * on the next load is one the framework already accepts and answers with a
 * 304. There is no such suffix for brotli: a br page would carry a tag the
 * framework does not recognise, and every reload would be a full transfer.
 *
 * WHEN. The request accepts gzip (an Accept-Encoding entry for gzip, or *,
 * with q > 0 - q=0 refuses), it is not a HEAD (the session-terminate ping),
 * the status is not 204 or 304, nothing set a Content-Encoding, the type is
 * text, JSON, JavaScript or XML, no Cache-Control: no-transform, and the
 * body is at least `threshold` bytes. Every response that would be
 * compressed for a client that asks carries Vary: Accept-Encoding, also the
 * plain one for a client that does not. A 304 carries what the 200 would
 * have: the Vary, and for a client that accepts gzip the tag "tag-gzip".
 *
 * HOW. res.write/res.end are wrapped for the one response - the framework
 * sends each body in one piece (res.status(code).send(buffer) in the shim) -
 * the body is collected, and compressed on the thread pool (zlib.gzip, not
 * the Sync variant: no request waits on another's compression). A response
 * whose headers went out already (an explicit writeHead) passes untouched.
 * The GET page is compressed once per ETag: a strong tag names one
 * representation, so the compressed page is cached under it (bounded,
 * oldest out first) and a reload that does not revalidate costs no gzip.
 *
 * TWICE IS ONCE. A host may mount compress() in front of createApp(), which
 * has one of its own (abap2UI5/mcp-server's npm host does, for releases that
 * export it). The first instance a response passes marks it and does the
 * work, every later one passes it through untouched - through a mark under
 * Symbol.for, so two copies of this module agree as well. A tag never gets
 * the -gzip suffix twice either.
 */
import zlib from "node:zlib";

/** On a response a compress() instance has taken: the others let it pass. */
const TAKEN = Symbol.for("@abap2ui5/node-runtime/compress");

const COMPRESSIBLE = /^(?:text\/|application\/(?:json|javascript|ecmascript|xml|[\w.+-]*\+(?:json|xml))\b)/i;

/**
 * Whether the Accept-Encoding header allows gzip. No header: no - a client
 * that says nothing gets what it did not ask to decode.
 * @param {string | string[] | undefined} header
 */
export function acceptsGzip(header) {
  if (header === undefined) return false;
  let gzip;
  let any;
  for (const entry of String(header).split(",")) {
    const [coding, ...params] = entry.split(";");
    const name = coding.trim().toLowerCase();
    if (name === "") continue;
    let q = 1;
    for (const param of params) {
      const [key, value] = param.split("=");
      if (key.trim().toLowerCase() === "q") q = Number(value?.trim());
    }
    if (!(q >= 0 && q <= 1)) continue;     // a malformed q-value counts as absent
    if (name === "gzip" || name === "x-gzip") gzip = Math.max(gzip ?? 0, q);
    else if (name === "*") any = q;
  }
  return (gzip ?? any ?? 0) > 0;
}

function addVary(res) {
  const vary = res.getHeader("vary");
  const list = Array.isArray(vary) ? vary.join(",") : vary === undefined ? "" : String(vary);
  const names = list.split(",").map((v) => v.trim().toLowerCase());
  if (names.includes("*") || names.includes("accept-encoding")) return;
  res.setHeader("Vary", list.trim() === "" ? "Accept-Encoding" : `${list}, Accept-Encoding`);
}

/** "tag" -> "tag-gzip"; a weak, malformed or already -gzip tag stays as it is. */
function gzipTag(etag) {
  return typeof etag === "string" && /^"[^"]*"$/.test(etag) && !etag.endsWith("-gzip\"") ? `${etag.slice(0, -1)}-gzip"` : etag;
}

/**
 * The middleware.
 * @param {{ threshold?: number, level?: number, pages?: number }} [options]
 *   `threshold` the smallest body compressed, in bytes (default 1024);
 *   `level` the zlib level (default 6); `pages` how many compressed GET pages
 *   are kept, one per ETag (default 16)
 * @returns {(req: object, res: object, next: Function) => void}
 */
export function compress({ threshold = 1024, level = 6, pages = 16 } = {}) {
  const cache = new Map();   // `${etag} ${length}` -> Promise<Buffer>

  const gzip = (body) => new Promise((resolve, reject) => {
    zlib.gzip(body, { level }, (err, out) => (err ? reject(err) : resolve(out)));
  });

  function compressed(req, res, body) {
    const etag = res.getHeader("etag");
    if (req.method !== "GET" || res.statusCode !== 200 || typeof etag !== "string" || !etag.startsWith("\"")) {
      return gzip(body);
    }
    const key = `${etag} ${body.length}`;
    let out = cache.get(key);
    if (out === undefined) {
      out = gzip(body);
      out.catch(() => cache.delete(key));
      if (cache.size >= pages) cache.delete(cache.keys().next().value);
      cache.set(key, out);
    }
    return out;
  }

  return function compressResponse(req, res, next) {
    if (req.method === "HEAD" || res[TAKEN]) {
      next();
      return;
    }
    res[TAKEN] = true;
    const accepted = acceptsGzip(req.headers["accept-encoding"]);
    const { write, end } = res;
    const chunks = [];
    const collect = (chunk, encoding) => {
      if (chunk !== undefined && chunk !== null) {
        chunks.push(Buffer.isBuffer(chunk) ? chunk : Buffer.from(chunk, typeof encoding === "string" ? encoding : "utf8"));
      }
    };

    res.write = function writeCollected(chunk, encoding, callback) {
      collect(chunk, encoding);
      const done = typeof encoding === "function" ? encoding : callback;
      if (typeof done === "function") process.nextTick(done);
      return true;
    };

    res.end = function endCompressed(chunk, encoding, callback) {
      if (typeof chunk === "function") {
        callback = chunk;
        chunk = undefined;
      } else if (typeof encoding === "function") {
        callback = encoding;
      }
      collect(chunk, encoding);
      res.write = write;
      res.end = end;
      const body = Buffer.concat(chunks);
      const plain = () => end.call(res, body, callback);

      const status = res.statusCode;
      if (res.headersSent) return plain();
      if (status === 304) {
        // the headers the 200 would carry: its Vary, and its tag - which is
        // the gzip one for a client that accepts gzip (RFC 9110 15.4.5)
        if (res.getHeader("etag") !== undefined) {
          if (accepted) res.setHeader("ETag", gzipTag(res.getHeader("etag")));
          addVary(res);
        }
        return plain();
      }
      const type = res.getHeader("content-type");
      const cacheControl = String(res.getHeader("cache-control") ?? "");
      if (status < 200 || status === 204 || body.length < threshold
        || res.getHeader("content-encoding") !== undefined
        || !COMPRESSIBLE.test(String(type ?? ""))
        || /(?:^|,)\s*no-transform\s*(?:,|$)/i.test(cacheControl)) {
        return plain();
      }
      addVary(res);
      if (!accepted) return plain();

      compressed(req, res, body).then((out) => {
        res.setHeader("Content-Encoding", "gzip");
        res.setHeader("Content-Length", out.length);
        if (res.getHeader("etag") !== undefined) res.setHeader("ETag", gzipTag(res.getHeader("etag")));
        end.call(res, out, callback);
      }, () => {
        // zlib failed: the body goes out as it came
        plain();
      });
      return res;
    };

    next();
  };
}
