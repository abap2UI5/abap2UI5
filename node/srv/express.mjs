import express from 'express';
import {initializeABAP} from "../output/init.mjs";
import {cl_express_icf_shim} from "../output/cl_express_icf_shim.clas.mjs";
await initializeABAP();

const PORT = process.env.PORT || 3000;
// HOST unset binds every interface - what the e2e runner and a container
// need to reach the server; HOST=127.0.0.1 binds loopback only. The log
// below says which: it used to say localhost whatever the socket was bound to
const HOST = process.env.HOST;

const app = express();
app.disable('x-powered-by');
app.set('etag', false);
app.use(express.raw({type: "*/*", limit: "10mb"}));

// ------------------

app.all("/{*path}", async function (req, res) {
  if (!req.body) { req.body = Buffer.alloc(0); }
  await cl_express_icf_shim.run({req, res, class: "ZCL_SICF"});
});

const server = app.listen(PORT, HOST, () => {
  console.log(HOST
    ? `Listening on http://${HOST}:${PORT}`
    : `Listening on port ${PORT} on all interfaces (set HOST=127.0.0.1 to bind loopback only)`);
});
server.on("error", (err) => {
  console.error("Failed to start server:", err.message);
  process.exit(1);
});
