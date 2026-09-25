#!/usr/bin/env node
/*
 * npm-publish — publish one packed tarball, with the bootstrap rule.
 *
 * Used by backend-prebuilt.yaml for both packages this repository publishes,
 * @abap2ui5/node-runtime and @abap2ui5/embed-control, so the rule below exists
 * once.
 *
 * Trusted publishing (OIDC) is the mechanism: the job holds `id-token: write`,
 * npm exchanges that token for a publish credential, and `--provenance`
 * records an attestation tying the tarball to the run and the commit. No
 * secret to leak or rotate. npm lets a package be pointed at a workflow only
 * once the package EXISTS, though, so the first version of each is published
 * by hand (RELEASING.md, "One-time setup - the npm packages"), and until then
 * a failed publish here is expected:
 *
 *   the package is not on the registry   -> a warning naming the bootstrap,
 *                                            exit 0 (the tarball is uploaded
 *                                            as a workflow artefact either way,
 *                                            and IS what the bootstrap
 *                                            publishes)
 *   the package is on the registry       -> the bootstrap is done, so a failed
 *                                            publish is an error, exit 1
 *   this version is already there        -> exit 0: a re-run of the workflow
 *                                            for a tag, e.g. to re-attach the
 *                                            backend, must not go red on the
 *                                            npm half
 *
 * A stored NPM_TOKEN still works and takes precedence - the fallback for an
 * organisation that has not moved to trusted publishing. The workflow hands
 * it over as NODE_AUTH_TOKEN, and this script points the user .npmrc at that
 * variable by NAME (`${NODE_AUTH_TOKEN}`, which npm expands when it reads the
 * file), so the secret itself is never written to disk. The shared setup
 * action configures no registry, so nothing else would.
 *
 *   node .github/scripts/npm-publish.mjs <tarball.tgz>
 */
import { execFileSync, spawnSync } from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";

const tarball = process.argv[2];
if (!tarball || !fs.existsSync(tarball)) {
  console.error(`npm-publish: no tarball at ${JSON.stringify(tarball)}`);
  console.error("  usage: node .github/scripts/npm-publish.mjs <tarball.tgz>");
  process.exit(2);
}

/* name and version from the tarball itself, not from a file in the checkout:
 * what is published is what is in there. */
const tmp = fs.mkdtempSync(path.join(os.tmpdir(), "npm-publish-"));
let name;
let version;
try {
  execFileSync("tar", ["-xzf", path.resolve(tarball), "-C", tmp, "package/package.json"]);
  ({ name, version } = JSON.parse(fs.readFileSync(path.join(tmp, "package", "package.json"), "utf8")));
} finally {
  fs.rmSync(tmp, { recursive: true, force: true });
}

const npm = (...argv) => spawnSync("npm", argv, { encoding: "utf8" });
const published = (spec) => npm("view", spec, "version").status === 0;

if (published(`${name}@${version}`)) {
  console.log(`npm-publish: ${name}@${version} is already on the registry - nothing to do`);
  process.exit(0);
}

if (process.env.NODE_AUTH_TOKEN) {
  fs.appendFileSync(path.join(os.homedir(), ".npmrc"), "\n//registry.npmjs.org/:_authToken=${NODE_AUTH_TOKEN}\n");
}
console.log(`npm-publish: ${name}@${version} ${process.env.NODE_AUTH_TOKEN ? "with NPM_TOKEN" : "via trusted publishing (OIDC)"}`);
const run = spawnSync("npm", ["publish", path.resolve(tarball), "--access", "public", "--provenance"], { stdio: "inherit" });
if (run.status === 0) {
  console.log(`npm-publish: published ${name}@${version}`);
  process.exit(0);
}

if (published(name)) {
  console.log(`::error::${name} is on the registry, but publishing ${version} failed - see the npm output above (the Trusted Publisher on npmjs.com not pointing at this repository and workflow file?)`);
  process.exit(1);
}
console.log(`::warning::${name}@${version} was packed and uploaded as a workflow artefact but NOT published: the package does not exist on the registry yet, and trusted publishing can only be configured for one that does. Publish that artefact once by hand - RELEASING.md, 'One-time setup - the npm packages' - and every release after it publishes here.`);
