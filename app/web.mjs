import {initializeABAP} from "../output/_init.mjs";
await initializeABAP();

async function redirectFetch(url, options) {
  console.dir("redirectFetch");
  let data = "";

  let res = {
    append: (d) => {
      console.dir("append2: " + d); },
    send: (d) => {
      console.dir("send2");
      data = Buffer.from(d).toString();
    },
    status: (status) => {
      console.dir("status2: " + status);
      return res; },
  }

  const method = options?.method || "GET";
  const body = options?.body || "";

  const req = {
    body: Buffer.from(body).toString("hex"),
    method: method,
    path: url,
    url: url,
  };
  console.dir(req);
  await abap.Classes["CL_EXPRESS_ICF_SHIM"].run({req: req, res, class: "ZCL_SICF"})
  console.log("redirectFetch RESPONSE,");
  console.dir(data);
  return {
    ok: true,
    json: async () => JSON.parse(data),
    text: async () => data,
  };
}

console.dir("entry, web.mjs");
globalThis.fetch = redirectFetch;

std();