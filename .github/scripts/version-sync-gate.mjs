// Gate: the version in package.json and the one in the ABAP interface agree.
//
// There are two, and only one of them ships. `z2ui5_if_app=>version` is what
// .abapgit.xml declares as VERSION_CONSTANT, so it is the number abapGit shows
// in a system and the number frontend_deploy stamps into the delivered
// frontend. package.json's is what the toolchain and the npm side read.
//
// Nothing kept them in step. They are edited by hand, in different files, at
// different moments of a release - and a mismatch is invisible until someone
// compares a system against a tag and finds the frontend stamped with a
// version the repository never released.

import { readFileSync } from "fs";
import { join } from "path";

const ROOT = new URL("../../", import.meta.url).pathname;

const INTERFACE = "src/02/z2ui5_if_app.intf.abap";

const pkg = JSON.parse(readFileSync(join(ROOT, "package.json"), "utf8")).version;

const abap = readFileSync(join(ROOT, INTERFACE), "utf8");
const match = abap.match(/CONSTANTS\s+version\s+TYPE\s+string\s+VALUE\s+`([^`]+)`/i);

if (!match) {
  console.log(`version-sync: no \`version\` constant found in ${INTERFACE}`);
  console.log("");
  console.log("That constant is what .abapgit.xml declares as VERSION_CONSTANT - if it was");
  console.log("renamed or moved, this gate has to learn the new place.");
  process.exit(1);
}

if (match[1] !== pkg) {
  console.log("The two version numbers disagree:");
  console.log("");
  console.log(`  package.json                 ${pkg}`);
  console.log(`  ${INTERFACE}   ${match[1]}`);
  console.log("");
  console.log("The ABAP constant is the one that ships: abapGit reads it as VERSION_CONSTANT");
  console.log("and frontend_deploy stamps it into the delivered frontend. Set both.");
  process.exit(1);
}

console.log(`version-sync: package.json and ${INTERFACE} both say ${pkg} - OK`);
