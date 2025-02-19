/* eslint-disable curly */
import fs from "fs";
import path from "path";
import {fileURLToPath} from "url";
import {initializeABAP} from "./init.mjs";
import runtime from "@abaplint/runtime";

const __dirname = path.dirname(fileURLToPath(import.meta.url));

async function run() {
  await initializeABAP();
  const unit = new runtime.UnitTestResult();
  let clas;
  let locl;
  let meth;
  try {
// -------------------END-------------------
    fs.writeFileSync(__dirname + path.sep + "_output.xml", unit.xUnitXML());
  } catch (e) {
    if (meth) {
      meth.fail();
    }
    fs.writeFileSync(__dirname + path.sep + "_output.xml", unit.xUnitXML());
    throw e;
  }
}

run().then(() => {
  process.exit(0);
}).catch((err) => {
  console.log(err);
  process.exit(1);
});