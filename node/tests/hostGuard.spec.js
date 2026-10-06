// @ts-check
const { test, expect } = require("@playwright/test");
const fs = require("fs");
const http = require("http");
const path = require("path");
const { execFileSync } = require("child_process");
const { pathToFileURL } = require("url");

// ---------------------------------------------------------------------
// node/srv/hostguard.mjs - which requests serve() (and `npm run express`)
// answers. It used to answer any Host and any Origin: a web page in the
// developer's browser could post to the dev server blind, and through DNS
// rebinding (a name of its own resolving to 127.0.0.1) read the answers.
//
// Two halves, like compress.spec.js. The guard on its own, in front of a
// stub handler: the names it allows, Host and Origin, the 403, the switch.
// And serve() in front of the REAL framework (helpers/hostGuardFramework.mjs,
// a child process) - that half needs the transpiled tree and skips without
// it; test.yaml's test_node job runs it on one.
// ---------------------------------------------------------------------

const MODULE = path.join(__dirname, "..", "srv", "hostguard.mjs");
const OUTPUT = path.join(__dirname, "..", "output", "init.mjs");
const FRAMEWORK = path.join(__dirname, "helpers", "hostGuardFramework.mjs");

/** @type {any} */
let mod;
const load = async () => (mod ??= await import(pathToFileURL(MODULE).href));

/** A server with hostGuard(options) in front of a stub, one GET, the status. */
async function status(options, headers) {
  const { hostGuard } = await load();
  const guard = hostGuard(options);
  const server = http.createServer((req, res) =>
    guard(req, res, () => {
      res.writeHead(200, { "content-type": "text/plain" });
      res.end("framework");
    }),
  );
  await new Promise((resolve) => server.listen(0, "127.0.0.1", () => resolve(undefined)));
  try {
    const address = /** @type {import("net").AddressInfo} */ (server.address());
    const hdrs = typeof headers === "function" ? headers(address.port) : headers;
    return await new Promise((resolve, reject) => {
      const req = http.request({ host: "127.0.0.1", port: address.port, path: "/", headers: hdrs }, (res) => {
        const chunks = [];
        res.on("data", (c) => chunks.push(c));
        res.on("end", () => resolve({ status: res.statusCode, body: Buffer.concat(chunks).toString("utf8") }));
      });
      req.on("error", reject);
      req.end();
    });
  } finally {
    server.close();
  }
}

test.describe("the guard", () => {
  test("answers a request addressed to loopback by name, with or without the port", async () => {
    const { requestAllowed, allowedHostNames } = await load();
    const allowed = allowedHostNames({ host: "127.0.0.1" });
    for (const host of ["127.0.0.1:3000", "localhost:3000", "LOCALHOST", "[::1]:3000", "127.0.0.1"]) {
      expect(requestAllowed({ host }, allowed), host).toBe(true);
    }
  });

  test("refuses another Host - the DNS rebinding case - and a request without one", async () => {
    const { requestAllowed, allowedHostNames } = await load();
    const allowed = allowedHostNames({ host: "127.0.0.1" });
    expect(requestAllowed({ host: "rebind.attacker.example:3000" }, allowed)).toBe(false);
    expect(requestAllowed({ host: "127.0.0.1.attacker.example" }, allowed)).toBe(false);
    expect(requestAllowed({}, allowed)).toBe(false);
  });

  test("with an Origin, answers only a page on an allowed name - Origin: null is refused", async () => {
    const { requestAllowed, allowedHostNames } = await load();
    const allowed = allowedHostNames({});
    const host = "localhost:3000";
    expect(requestAllowed({ host, origin: "http://localhost:3000" }, allowed)).toBe(true);
    expect(requestAllowed({ host, origin: "http://127.0.0.1:8081" }, allowed)).toBe(true);
    expect(requestAllowed({ host, origin: "https://[::1]" }, allowed)).toBe(true);
    expect(requestAllowed({ host, origin: "https://attacker.example" }, allowed)).toBe(false);
    expect(requestAllowed({ host, origin: "null" }, allowed)).toBe(false);
    expect(requestAllowed({ host, origin: "file:///C:/page.html" }, allowed)).toBe(false);
  });

  test("allows the bound address when it is a name, never a wildcard bind", async () => {
    const { requestAllowed, allowedHostNames } = await load();
    expect(requestAllowed({ host: "192.168.1.5:3000" }, allowedHostNames({ host: "192.168.1.5" }))).toBe(true);
    expect(requestAllowed({ host: "devbox.lan:3000" }, allowedHostNames({ host: "DevBox.lan" }))).toBe(true);
    expect(requestAllowed({ host: "[fe80::1]:3000" }, allowedHostNames({ host: "fe80::1" }))).toBe(true);
    // 0.0.0.0 and :: name no host - every interface, loopback names only
    expect([...(allowedHostNames({ host: "0.0.0.0" }) ?? [])]).toEqual(["127.0.0.1", "localhost", "[::1]"]);
    expect([...(allowedHostNames({ host: "::" }) ?? [])]).toEqual(["127.0.0.1", "localhost", "[::1]"]);
    expect([...(allowedHostNames({}) ?? [])]).toEqual(["127.0.0.1", "localhost", "[::1]"]);
  });

  test("allowedHosts adds names - a list or comma-separated - and * switches the guard off", async () => {
    const { requestAllowed, allowedHostNames } = await load();
    const listed = allowedHostNames({ allowedHosts: "app.docker, devbox.lan" });
    expect(requestAllowed({ host: "app.docker:3000" }, listed)).toBe(true);
    expect(requestAllowed({ host: "devbox.lan", origin: "http://devbox.lan:3000" }, listed)).toBe(true);
    expect(requestAllowed({ host: "other.lan" }, listed)).toBe(false);
    expect(requestAllowed({ host: "app.docker" }, allowedHostNames({ allowedHosts: ["app.docker"] }))).toBe(true);
    expect(allowedHostNames({ allowedHosts: "*" })).toBeNull();
    expect(requestAllowed({ host: "anything", origin: "null" }, null)).toBe(true);
  });

  test("over HTTP: a refused request gets a 403 that names the switch, the handler never runs", async () => {
    const ok = await status({ host: "127.0.0.1" }, (port) => ({ host: `localhost:${port}` }));
    expect(ok).toEqual({ status: 200, body: "framework" });

    const refused = await status({ host: "127.0.0.1" }, (port) => ({
      host: `rebind.attacker.example:${port}`,
    }));
    expect(refused.status).toBe(403);
    expect(refused.body).not.toContain("framework");
    expect(refused.body).toContain("ALLOWED_HOSTS");

    const crossPage = await status({}, (port) => ({ host: `127.0.0.1:${port}`, origin: "https://attacker.example" }));
    expect(crossPage.status).toBe(403);
  });
});

test.describe("serve() in front of the framework", () => {
  // `npm run check:js` runs on a tree that was never transpiled, so this half
  // skips there; test.yaml's test_node runs it on the transpiled tree
  test.skip(!fs.existsSync(OUTPUT), "needs the transpiled backend: npm run downport && npm run auto_transpile");

  /** @type {any} */
  let seen;
  const framework = () =>
    (seen ??= JSON.parse(
      execFileSync(process.execPath, [FRAMEWORK], { encoding: "utf8", maxBuffer: 16 * 1024 * 1024, timeout: 120000 }),
    ));

  test("answers loopback by name and a page there, refuses a rebound Host, a foreign page and Origin: null", () => {
    const run = framework().loopback;
    expect(run.ip).toBe(200);
    expect(run.localhost).toBe(200);
    expect(run.samePage).toBe(200);
    expect(run.rebound).toBe(403);
    expect(run.crossPage).toBe(403);
    expect(run.nullOrigin).toBe(403);
  });

  test("allowedHosts answers the names it adds and no others; * answers any", () => {
    const run = framework();
    expect(run.named.added).toBe(200);
    expect(run.named.other).toBe(403);
    expect(run.open.rebound).toBe(200);
  });
});
