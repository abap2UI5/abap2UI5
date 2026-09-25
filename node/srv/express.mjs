// The dev server: abap2UI5 on http://localhost:3000, through the same entry
// point the npm package @abap2ui5/node-runtime exports (host.mjs) - so what
// `npm run express` runs is what a host installs.
import { serve } from "./host.mjs";

const PORT = process.env.PORT || 3000;
// HOST unset binds every interface - what the e2e runner and a container
// need to reach the server; HOST=127.0.0.1 binds loopback only. The log
// below says which: it used to say localhost whatever the socket was bound to
const HOST = process.env.HOST;

try {
  await serve({ port: PORT, host: HOST });
  console.log(HOST
    ? `Listening on http://${HOST}:${PORT}`
    : `Listening on port ${PORT} on all interfaces (set HOST=127.0.0.1 to bind loopback only)`);
} catch (err) {
  console.error("Failed to start server:", err.message);
  process.exit(1);
}
