// The dev server: abap2UI5 on http://localhost:3000, through the same entry
// point the npm package @abap2ui5/node-runtime exports (host.mjs) - so what
// `npm run express` runs is what a host installs.
import { serve } from "./host.mjs";

const PORT = process.env.PORT || 3000;
// HOST unset binds every interface - what the e2e runner and a container
// need to reach the server; HOST=127.0.0.1 binds loopback only. The log
// below says which: it used to say localhost whatever the socket was bound to
const HOST = process.env.HOST;
// Whichever the bind, the server answers only requests addressed to
// 127.0.0.1, localhost, [::1] or the HOST name, from a page there (DNS
// rebinding - srv/hostguard.mjs). ALLOWED_HOSTS adds names, comma-separated,
// for a container reached by its service name or a LAN address;
// ALLOWED_HOSTS=* answers any Host and any Origin
const ALLOWED_HOSTS = process.env.ALLOWED_HOSTS;

try {
  await serve({ port: PORT, host: HOST, allowedHosts: ALLOWED_HOSTS });
  console.log(HOST
    ? `Listening on http://${HOST}:${PORT}`
    : `Listening on port ${PORT} on all interfaces (set HOST=127.0.0.1 to bind loopback only)`);
} catch (err) {
  console.error("Failed to start server:", err.message);
  process.exit(1);
}
