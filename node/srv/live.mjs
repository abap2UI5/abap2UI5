// The dev server for work on the FRONTEND: like `npm run express`, but the
// frontend comes straight from the working tree.
//
//   npm run express:live      http://localhost:3000
//
// The frontend is no app of its own any more - a page gets it as one script,
// GET <node>?z2ui5-bundle, which the backend answers from the classes
// `npm run app2abap` generated and the transpile built. So a change under
// bundle/webapp showed up only after both. This server answers that one
// request itself, with the bundle put together from the sources at that
// moment (tools/app2abap/trans2abap.js, buildTexts - the same code that
// writes the classes, without the comment strip): edit a file, reload the
// page. The same for the developer tools (?z2ui5-bundle=devtools).
//
// Everything else - the page, the roundtrips - is the built backend, as in
// `npm run express`. So the page's own app and the control
// (app_source/webapp) are NOT live: they sit in the page's inline script,
// whose text the page's Content-Security-Policy names by its hash. And a
// change that is live here still needs `npm run app2abap` before it is
// committed.
import http from "node:http";
import { createRequire } from "node:module";
import { createApp, hostGuard, initialize } from "./host.mjs";

const require = createRequire(import.meta.url);
const { buildTexts, NODE_PATH_TOKEN } = require("../../tools/app2abap/trans2abap.js");

const PORT = process.env.PORT || 3000;
const HOST = process.env.HOST;
const ALLOWED_HOSTS = process.env.ALLOWED_HOSTS;

// A string as the inside of a JavaScript string literal - what
// z2ui5_cl_ui5_util_context=>c_escape_js does to the path on the backend.
const escapeJs = (text) => JSON.stringify(text).slice(1, -1).replace(/</g, "\\x3c");

async function liveBundle(req, res) {
  const url = new URL(req.url, "http://localhost");
  if (req.method !== "GET" || !url.searchParams.has("z2ui5-bundle")) return false;
  try {
    const { bundleText, devtoolsText } = await buildTexts({ strip: false });
    const body = url.searchParams.get("z2ui5-bundle") === "devtools"
      ? devtoolsText
      : bundleText.replace(NODE_PATH_TOKEN, () => escapeJs(url.pathname));
    res.writeHead(200, {
      "content-type": "application/javascript; charset=UTF-8",
      // never kept: the next reload has to see the next edit - also under
      // the versioned URL the page asks with, which the backend lets a
      // browser keep
      "cache-control": "no-store",
      "x-content-type-options": "nosniff",
    });
    res.end(body);
  } catch (error) {
    // a source that does not build is said in the terminal and in the
    // browser's network tab, instead of a page that silently stays blank
    console.error(`live: the bundle does not build - ${error.message}`);
    res.writeHead(500, { "content-type": "text/plain; charset=UTF-8" });
    res.end(`the frontend bundle does not build: ${error.message}`);
  }
  return true;
}

try {
  const app = await createApp();
  const guard = hostGuard({ host: HOST, allowedHosts: ALLOWED_HOSTS });
  await initialize();
  const server = http.createServer((req, res) =>
    guard(req, res, () => {
      liveBundle(req, res).then((answered) => {
        if (!answered) app(req, res);
      });
    }),
  );
  await new Promise((resolve, reject) => {
    server.once("error", reject);
    server.listen(PORT, HOST, resolve);
  });
  console.log(`Listening on port ${PORT} - the frontend bundle is served live from bundle/webapp`);
} catch (err) {
  console.error("Failed to start server:", err.message);
  process.exit(1);
}
