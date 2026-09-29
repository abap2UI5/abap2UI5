// @ts-check
const { test, expect } = require("@playwright/test");
const fs = require("fs");
const http = require("http");
const path = require("path");
const zlib = require("zlib");
const { execFileSync } = require("child_process");
const { pathToFileURL } = require("url");

// ---------------------------------------------------------------------
// node/srv/compress.mjs - gzip for the framework's responses, which the
// framework asks the ICF for and a Node host could not give it.
//
// Two halves. The middleware on its own, in front of a stub handler: when it
// compresses and when it must not, the headers it owes (Vary, the -gzip tag,
// the Content-Length), the per-ETag page cache. And the middleware in front
// of the REAL framework (helpers/compressFramework.mjs, in a child process):
// the conditional GET only closes its circle with the framework's own
// _check_etag_match, which accepts the "tag-gzip" the middleware sends - that
// half needs the transpiled tree and skips without it, like
// efWireRoundtrip.spec.js; test.yaml's test_node job runs it on one.
// ---------------------------------------------------------------------

const MODULE = path.join(__dirname, "..", "srv", "compress.mjs");
const OUTPUT = path.join(__dirname, "..", "output", "init.mjs");
const FRAMEWORK = path.join(__dirname, "helpers", "compressFramework.mjs");

const PAGE = "<!doctype html>" + "<p>abap2UI5</p>".repeat(400);

/** @type {any} */
let mod;
const load = async () => (mod ??= await import(pathToFileURL(MODULE).href));

/** A server with compress() in front of `handler`, one request, the raw answer. */
async function roundtrip(handler, { method = "GET", headers = {}, options = {} } = {}) {
  const { compress } = await load();
  const middleware = compress(options);
  const server = http.createServer((req, res) => middleware(req, res, () => handler(req, res)));
  await new Promise((resolve) => server.listen(0, "127.0.0.1", () => resolve(undefined)));
  try {
    const address = /** @type {import("net").AddressInfo} */ (server.address());
    return await new Promise((resolve, reject) => {
      const req = http.request({ host: "127.0.0.1", port: address.port, path: "/", method, headers }, (res) => {
        const chunks = [];
        res.on("data", (c) => chunks.push(c));
        res.on("end", () => {
          const raw = Buffer.concat(chunks);
          resolve({
            status: res.statusCode,
            headers: res.headers,
            raw,
            body: res.headers["content-encoding"] === "gzip" ? zlib.gunzipSync(raw).toString("utf8") : raw.toString("utf8"),
          });
        });
      });
      req.on("error", reject);
      req.end();
    });
  } finally {
    server.close();
  }
}

/** The shape the framework answers in: headers, then res.end with the body. */
const page = (status = 200, headers = { "content-type": "text/html; charset=UTF-8", etag: "\"v1-abc\"" }, body = PAGE) =>
  (req, res) => {
    res.statusCode = status;
    for (const [name, value] of Object.entries(headers)) res.setHeader(name, value);
    res.setHeader("Content-Length", Buffer.byteLength(body));
    res.end(Buffer.from(body));
  };

test.describe("the middleware", () => {
  test("gzips for a client that accepts it, and says so in Vary, Content-Length and the tag", async () => {
    const res = await roundtrip(page(), { headers: { "accept-encoding": "gzip, deflate, br" } });
    expect(res.status).toBe(200);
    expect(res.headers["content-encoding"]).toBe("gzip");
    expect(res.headers.vary).toBe("Accept-Encoding");
    expect(Number(res.headers["content-length"])).toBe(res.raw.length);
    expect(res.raw.length).toBeLessThan(Buffer.byteLength(PAGE) / 5);
    expect(res.body).toBe(PAGE);
    // mod_deflate's form, the one _check_etag_match accepts back
    expect(res.headers.etag).toBe("\"v1-abc-gzip\"");
  });

  test("sends the body as it is to a client that does not ask - but still with Vary", async () => {
    const res = await roundtrip(page());
    expect(res.headers["content-encoding"]).toBeUndefined();
    expect(res.headers.etag).toBe("\"v1-abc\"");
    expect(res.headers.vary).toBe("Accept-Encoding");
    expect(res.body).toBe(PAGE);
  });

  test("reads Accept-Encoding with its q-values", async () => {
    const { acceptsGzip } = await load();
    for (const yes of ["gzip", "GZIP", "x-gzip", "gzip;q=0.5", "br, gzip;q=0.001", "*", "*;q=0.1", "identity, *", "deflate, gzip ; q=1"]) {
      expect(acceptsGzip(yes), yes).toBe(true);
    }
    for (const no of [undefined, "", "identity", "br", "deflate, br", "gzip;q=0", "gzip;q=0.000, *", "*;q=0", "gzip;q=2", "gzip;q=x"]) {
      expect(acceptsGzip(no), String(no)).toBe(false);
    }
    const res = await roundtrip(page(), { headers: { "accept-encoding": "gzip;q=0, identity" } });
    expect(res.headers["content-encoding"]).toBeUndefined();
  });

  test("leaves HEAD, 204, small, already encoded, binary and no-transform responses alone", async () => {
    const cases = [
      [{ method: "HEAD" }, page()],
      [{}, page(204, {}, "")],
      [{}, page(200, { "content-type": "application/json" }, "{\"small\":true}")],
      [{}, page(200, { "content-type": "text/html", "content-encoding": "br" })],
      [{}, page(200, { "content-type": "image/png" })],
      [{}, page(200, { "content-type": "text/html", "cache-control": "private, no-transform" })],
    ];
    for (const [request, handler] of cases) {
      const res = await roundtrip(handler, { ...request, headers: { "accept-encoding": "gzip" } });
      expect(res.headers["content-encoding"] ?? null, JSON.stringify(res.headers)).not.toBe("gzip");
      expect(res.headers.vary).toBeUndefined();
    }
  });

  test("gives a 304 the tag and the Vary the 200 would have carried", async () => {
    const gzip = await roundtrip(page(304, { etag: "\"v1-abc\"" }, ""), { headers: { "accept-encoding": "gzip" } });
    expect(gzip.status).toBe(304);
    expect(gzip.headers.etag).toBe("\"v1-abc-gzip\"");
    expect(gzip.headers.vary).toBe("Accept-Encoding");
    const plain = await roundtrip(page(304, { etag: "\"v1-abc\"" }, ""));
    expect(plain.headers.etag).toBe("\"v1-abc\"");
    expect(plain.headers.vary).toBe("Accept-Encoding");
  });

  test("keeps a weak tag and an existing Vary as they are", async () => {
    const res = await roundtrip(page(200, { "content-type": "text/html", etag: "W/\"v1\"", vary: "Origin" }), { headers: { "accept-encoding": "gzip" } });
    expect(res.headers["content-encoding"]).toBe("gzip");
    expect(res.headers.etag).toBe("W/\"v1\"");
    expect(res.headers.vary).toBe("Origin, Accept-Encoding");
  });

  test("mounted twice - a host's in front of createApp()'s - compresses once, and tags once", async () => {
    const { compress } = await load();
    // roundtrip() puts one instance in front; the handler runs a second one
    const second = compress();
    for (const [status, headers, body] of [[200, undefined, PAGE], [304, { etag: "\"v1-abc\"" }, ""]]) {
      const res = await roundtrip((req, r) => second(req, r, () => page(status, headers, body)(req, r)), {
        headers: { "accept-encoding": "gzip" },
      });
      expect(res.status).toBe(status);
      expect(res.headers.etag).toBe("\"v1-abc-gzip\"");
      expect(res.headers.vary).toBe("Accept-Encoding");
      if (status === 200) {
        expect(res.headers["content-encoding"]).toBe("gzip");
        // one layer: a second gzip would not decode to the page
        expect(res.body).toBe(PAGE);
      }
    }
  });

  test("collects a body written in pieces", async () => {
    const res = await roundtrip((req, res) => {
      res.setHeader("content-type", "application/json");
      res.write("[");
      res.write(Buffer.from(Array.from({ length: 300 }, (_, i) => i).join(",")));
      res.end("]");
    }, { headers: { "accept-encoding": "gzip" } });
    expect(res.headers["content-encoding"]).toBe("gzip");
    expect(JSON.parse(res.body)).toHaveLength(300);
  });

  test("compresses a GET page once per strong ETag", async () => {
    const { compress } = await load();
    const middleware = compress();
    let body = PAGE;
    const server = http.createServer((req, res) => middleware(req, res, () => page(200, { "content-type": "text/html", etag: req.url === "/other" ? "\"v2\"" : "\"v1\"" }, body)(req, res)));
    await new Promise((resolve) => server.listen(0, "127.0.0.1", () => resolve(undefined)));
    const address = /** @type {import("net").AddressInfo} */ (server.address());
    const get = (pathname) => new Promise((resolve, reject) => {
      http.get({ host: "127.0.0.1", port: address.port, path: pathname, headers: { "accept-encoding": "gzip" } }, (res) => {
        const chunks = [];
        res.on("data", (c) => chunks.push(c));
        res.on("end", () => resolve(zlib.gunzipSync(Buffer.concat(chunks)).toString("utf8")));
      }).on("error", reject);
    });
    try {
      expect(await get("/")).toBe(PAGE);
      // a changed body under the SAME strong tag and length is, by the tag's
      // definition, the same representation: the cached compression answers
      body = PAGE.replace("abap2UI5", "ABAP2UI5");
      expect(await get("/")).toBe(PAGE);
      // another tag is another page
      expect(await get("/other")).toBe(body);
    } finally {
      server.close();
    }
  });
});

test.describe("in front of the framework", () => {
  // `npm run check:js` runs on a tree that was never transpiled (node/output
  // is built by `npm run downport && npm run auto_transpile`), so this half
  // skips there; test.yaml's test_node runs it on the transpiled tree
  test.skip(!fs.existsSync(OUTPUT), "needs the transpiled backend: npm run downport && npm run auto_transpile");

  /** @type {any} */
  let seen;
  const framework = () => (seen ??= JSON.parse(execFileSync(process.execPath, [FRAMEWORK], {
    encoding: "utf8", maxBuffer: 16 * 1024 * 1024, timeout: 120000,
  })));

  for (const where of ["serve", "mounted"]) {
    test(`${where}: the page goes out gzipped, and its -gzip tag revalidates to a 304`, () => {
      const run = framework()[where];
      expect(run.plain.status).toBe(200);
      expect(run.plain.encoding).toBeNull();
      expect(run.plain.vary).toBe("Accept-Encoding");
      expect(run.gzip.encoding).toBe("gzip");
      expect(run.gzip.samePage).toBe(true);
      expect(run.gzip.rawLength).toBeLessThan(run.plain.rawLength / 3);
      expect(run.gzip.etag).toBe(run.plain.etag.replace(/"$/, "-gzip\""));
      // the framework's _check_etag_match reads the -gzip tag back
      expect(run.revalidated.status).toBe(304);
      expect(run.revalidated.textLength).toBe(0);
      expect(run.revalidated.etag).toBe(run.gzip.etag);
      expect(run.revalidatedPlain.status).toBe(304);
      expect(run.revalidatedPlain.etag).toBe(run.plain.etag);
      expect(run.refused.encoding).toBeNull();
    });

    test(`${where}: a roundtrip's JSON goes out gzipped and decodes`, () => {
      const { roundtrip: rt } = framework()[where];
      expect(rt.status).toBe(200);
      expect(rt.encoding).toBe("gzip");
      expect(rt.app).toBe("Z2UI5_CL_UI5_APP_START");
      expect(rt.rawLength).toBeLessThan(rt.plainLength);
    });
  }

  test("compress() of a host in front of createApp() - which has one - is harmless", () => {
    const { doubled } = framework();
    expect(doubled.gzip.encoding).toBe("gzip");
    expect(doubled.gzip.samePage).toBe(true);
    expect(doubled.gzip.etag).toMatch(/[^-]-gzip"$/);
    expect(doubled.gzip.etag).not.toMatch(/-gzip-gzip"$/);
    expect(doubled.revalidated.status).toBe(304);
    expect(doubled.revalidated.etag).toBe(doubled.gzip.etag);
  });

  test("createApp({ compression: false }) leaves the responses as they are", () => {
    const { off } = framework();
    expect(off.status).toBe(200);
    expect(off.encoding).toBeNull();
    expect(off.vary).toBeNull();
  });
});
