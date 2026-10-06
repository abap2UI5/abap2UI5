// The framework half of hostGuard.spec.js: host.mjs's serve() - what
// `npm run express` runs - with its Host/Origin guard in front of the REAL
// transpiled framework.
//
// A separate process for the same reason as compressFramework.mjs: the
// transpiled tree and the runtime load natively here, and the spec reads
// plain JSON back.
//
// stdout: JSON { observations by name }
import http from "node:http";
import { serve } from "../../srv/host.mjs";

/** One GET / with exactly these headers - node:http, so Host is ours to set. */
function status(port, headers) {
  return new Promise((resolve, reject) => {
    const req = http.request({ host: "127.0.0.1", port, path: "/", method: "GET", headers }, (res) => {
      res.resume();
      res.on("end", () => resolve(res.statusCode));
    });
    req.on("error", reject);
    req.end();
  });
}

const out = {};

// the dev server's shape: HOST=127.0.0.1, no ALLOWED_HOSTS
const loopback = await serve({ port: 0, host: "127.0.0.1" });
try {
  const port = loopback.address().port;
  out.loopback = {
    ip: await status(port, { host: `127.0.0.1:${port}` }),
    localhost: await status(port, { host: `localhost:${port}` }),
    samePage: await status(port, { host: `localhost:${port}`, origin: `http://localhost:${port}` }),
    rebound: await status(port, { host: `rebind.attacker.example:${port}` }),
    crossPage: await status(port, { host: `127.0.0.1:${port}`, origin: "https://attacker.example" }),
    nullOrigin: await status(port, { host: `127.0.0.1:${port}`, origin: "null" }),
  };
} finally {
  loopback.close();
}

// a name added deliberately (ALLOWED_HOSTS=devbox.lan)
const named = await serve({ port: 0, host: "127.0.0.1", allowedHosts: "devbox.lan" });
try {
  const port = named.address().port;
  out.named = {
    added: await status(port, { host: `devbox.lan:${port}`, origin: `http://devbox.lan:${port}` }),
    other: await status(port, { host: `other.lan:${port}` }),
  };
} finally {
  named.close();
}

// the switch (ALLOWED_HOSTS=*): every request answered, as before
const open = await serve({ port: 0, host: "127.0.0.1", allowedHosts: "*" });
try {
  const port = open.address().port;
  out.open = {
    rebound: await status(port, { host: `rebind.attacker.example:${port}`, origin: "https://attacker.example" }),
  };
} finally {
  open.close();
}

process.stdout.write(JSON.stringify(out));
process.exit(0);
