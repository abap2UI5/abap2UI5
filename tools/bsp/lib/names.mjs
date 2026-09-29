// names.mjs - the name of the BSP, and the object names derived from it.

import { createHash } from "node:crypto";

// An ICF service and a BSP application name have at most 15 characters.
export const MAX_NAME_LENGTH = 15;

/**
 * The BSP name, upper-cased and checked. A name in a registered /NS/
 * namespace is refused: its ICF nodes sit below the namespace instead of
 * `sap`, and the namespace node has to be created with them -
 * tools/bsp_rename does that for abap2UI5's own BSP, this package does not
 * yet.
 */
export function bspName(raw) {
  const name = String(raw ?? "").trim().toUpperCase();
  if (!name) {
    throw new Error("a BSP name is needed, e.g. --name ZMYAPP");
  }
  if (name.includes("/") || name.includes("#")) {
    throw new Error(`${name}: names in a /NS/ namespace are not supported - use a Z or Y name`);
  }
  if (!/^[A-Z][A-Z0-9_]*$/.test(name)) {
    throw new Error(`${name}: a BSP name starts with a letter and has only letters, digits and _`);
  }
  if (name.length > MAX_NAME_LENGTH) {
    throw new Error(`${name}: ${name.length} characters - a BSP name has at most ${MAX_NAME_LENGTH}`);
  }
  return name;
}

/** True for a name outside the customer namespace (Z*, Y*). */
export function isSapName(name) {
  return !/^[ZY]/.test(name);
}

/**
 * abapGit's file name for an ICF node: the node name left-justified in a
 * 15-character field, then the first 25 hex characters of the SHA-1 of the
 * node's full URL. A URL that changes changes the file name - with a stale
 * one, abapGit serializes the node under another name after the pull.
 */
export function sicfFileName(nodeName, url) {
  const hash = createHash("sha1").update(url).digest("hex").slice(0, 25);
  return `${nodeName.toLowerCase().padEnd(MAX_NAME_LENGTH)}${hash}.sicf.xml`;
}
