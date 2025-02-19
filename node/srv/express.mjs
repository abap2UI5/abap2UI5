import express from 'express';
import {initializeABAP} from "../src/init.mjs";
import {cl_express_icf_shim} from "../src/cl_express_icf_shim.clas.mjs";

console.log("test");
await initializeABAP();

const PORT = 3000;

const app = express();
app.disable('x-powered-by');
app.set('etag', false);
app.use(express.raw({type: "*/*"}));

// ------------------

app.all(["/", "/*"], async function (req, res) {
  await cl_express_icf_shim.run({req, res, class: "ZCL_SICF"});
});

app.listen(PORT);
console.log("Listening on port http://localhost:" + PORT);