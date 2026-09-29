// The framework half of compress.spec.js: compress() in front of the REAL
// transpiled framework, through host.mjs's serve() and createApp() - the
// conditional GET has to close its circle with the framework's own
// _check_etag_match, which only the framework can say.
//
// A separate process for the same reason as efWire.mjs: the transpiled tree
// and the runtime load natively here, and the spec reads plain JSON back.
//
// stdout: JSON { observations by name }
import http from "node:http";
import zlib from "node:zlib";
import express from "express";
import { serve, createApp, compress } from "../../srv/host.mjs";

/** One raw request - node:http, so nothing decodes or adds a header on its own. */
function request(base, pathname, { method = "GET", headers = {}, body } = {}) {
  return new Promise((resolve, reject) => {
    const req = http.request(new URL(pathname, base), { method, headers }, (res) => {
      const chunks = [];
      res.on("data", (c) => chunks.push(c));
      res.on("end", () => {
        const raw = Buffer.concat(chunks);
        const encoding = res.headers["content-encoding"];
        const decoded = encoding === "gzip" ? zlib.gunzipSync(raw) : raw;
        resolve({
          status: res.statusCode,
          encoding: encoding ?? null,
          etag: res.headers.etag ?? null,
          vary: res.headers.vary ?? null,
          length: Number(res.headers["content-length"] ?? raw.length),
          rawLength: raw.length,
          text: decoded.toString("utf8"),
        });
      });
    });
    req.on("error", reject);
    if (body) req.write(body);
    req.end();
  });
}

const post = (base, pathname, search, headers = {}) => request(base, pathname, {
  method: "POST",
  headers: { "content-type": "application/json", ...headers },
  body: JSON.stringify({ value: { S_FRONT: { ORIGIN: base, PATHNAME: pathname, SEARCH: search } } }),
});

async function observe(base, pathname) {
  const plain = await request(base, pathname);
  const gzip = await request(base, pathname, { headers: { "accept-encoding": "gzip, deflate, br" } });
  const gzipTag = gzip.etag;
  const plainTag = plain.etag;
  const revalidated = await request(base, pathname, { headers: { "accept-encoding": "gzip", "if-none-match": gzipTag } });
  const revalidatedPlain = await request(base, pathname, { headers: { "if-none-match": plainTag } });
  const refused = await request(base, pathname, { headers: { "accept-encoding": "gzip;q=0, identity" } });
  // the start app's first response carries its whole view - well over 1 KB
  const roundtrip = await post(base, pathname, "?app_start=z2ui5_cl_ui5_app_start", { "accept-encoding": "gzip" });
  const roundtripPlain = await post(base, pathname, "?app_start=z2ui5_cl_ui5_app_start");
  let app = null;
  try { app = JSON.parse(roundtrip.text).S_FRONT?.APP ?? null; } catch { /* not JSON - reported as null */ }
  return {
    plain: { ...plain, text: undefined, textLength: plain.text.length },
    gzip: { ...gzip, text: undefined, samePage: gzip.text === plain.text },
    revalidated: { ...revalidated, text: undefined, textLength: revalidated.text.length },
    revalidatedPlain: { ...revalidatedPlain, text: undefined, textLength: revalidatedPlain.text.length },
    refused: { ...refused, text: undefined },
    roundtrip: { ...roundtrip, text: undefined, app, plainLength: roundtripPlain.rawLength },
  };
}

const out = {};
const server = await serve({ port: 0, host: "127.0.0.1" });
try {
  out.serve = await observe(`http://127.0.0.1:${server.address().port}`, "/");
} finally {
  server.close();
}

const host = express();
host.use("/sap/bc/z2ui5", await createApp());
const mounted = await new Promise((resolve, reject) => {
  const s = host.listen(0, "127.0.0.1", () => resolve(s)).on("error", reject);
});
try {
  out.mounted = await observe(`http://127.0.0.1:${mounted.address().port}`, "/sap/bc/z2ui5/");
} finally {
  mounted.close();
}

// a host that mounts compress() in front of createApp(), which has its own
const twice = express();
twice.use(compress());
twice.use(await createApp());
const doubled = await new Promise((resolve, reject) => {
  const s = twice.listen(0, "127.0.0.1", () => resolve(s)).on("error", reject);
});
try {
  const base = `http://127.0.0.1:${doubled.address().port}`;
  const plain = await request(base, "/");
  const gzip = await request(base, "/", { headers: { "accept-encoding": "gzip" } });
  const revalidated = await request(base, "/", { headers: { "accept-encoding": "gzip", "if-none-match": gzip.etag } });
  out.doubled = {
    gzip: { ...gzip, text: undefined, samePage: gzip.text === plain.text },
    revalidated: { ...revalidated, text: undefined },
  };
} finally {
  doubled.close();
}

const bare = express();
bare.use(await createApp({ compression: false }));
const off = await new Promise((resolve, reject) => {
  const s = bare.listen(0, "127.0.0.1", () => resolve(s)).on("error", reject);
});
try {
  const res = await request(`http://127.0.0.1:${off.address().port}`, "/", { headers: { "accept-encoding": "gzip" } });
  out.off = { ...res, text: undefined };
} finally {
  off.close();
}

process.stdout.write(JSON.stringify(out));
process.exit(0);
