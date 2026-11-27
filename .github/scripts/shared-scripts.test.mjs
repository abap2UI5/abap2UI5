#!/usr/bin/env node
/*
 * shared-scripts.test — the helpers of the two build scripts this repository
 * is the source of for some thirty others: `.github/shared/rename.mjs` (the
 * namespace rename of every addon and corpus) and
 * `.github/shared/update-deps.mjs` (the monthly dependency update).
 *
 * `check:shared` proves every copy equals the source; it cannot prove the
 * source is right. Each case below is a bug the copies carried, found on
 * 2026-11-27 - a JSONC reader that looped forever on an unclosed comment,
 * global.exclude regexes turned into literal absolute paths that matched
 * nothing, an `--out .` that deleted the checkout, a transpiler pin read
 * from a field the runtime package does not write, ranges like `1.x` turned
 * into exact versions.
 *
 *   node .github/scripts/shared-scripts.test.mjs   (npm run check:shared-scripts)
 */
import { test } from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { objectOf, outRefusal, parseJsonc, prefixOf, renamedSource, runConfig } from "../shared/rename.mjs";
import { formatLike, nextSpec, pinActions, transpilerOf, withoutSecrets } from "../shared/update-deps.mjs";

test("JSONC: comments, trailing commas, // inside a string", () => {
  const text = '{\n  // a comment\n  "url": "https://github.com/x/y", /* block */\n  "a": [1, 2,],\n}\n';
  assert.deepEqual(parseJsonc(text), { url: "https://github.com/x/y", a: [1, 2] });
});

test("JSONC: an unclosed block comment is an error, not an endless loop", () => {
  assert.throws(() => parseJsonc('{ "a": 1 /* never closed\n', "x.jsonc"), /x\.jsonc: a \/\* comment is never closed/);
});

test("rename: global.exclude goes to every rule unchanged", () => {
  const exclude = ["/src/cloud/", "\\.testclasses\\.abap$"];
  const config = runConfig({ source: "src", prefix: "zmy_", own: { global: { exclude } }, output: ".github/abaplint/output" });
  for (const rule of Object.values(config.rules)) assert.deepEqual(rule, { exclude });
  // the run config sits at the root: its paths are root paths
  assert.deepEqual(config.global.files, ["/src/**/*.*"]);
  assert.equal(config.rename.output, ".github/abaplint/output");
});

test("rename: the clones, the skipped paths and the order of the other dependencies", () => {
  const config = runConfig({
    source: "conformance/apps/abap",
    deps: [["abap2ui5", "/src/0[0-2]/**/*.*"]],
    skipped: ["/repo/src/01/"],
    others: [{ url: "a", level: 0 }, { url: "b", level: 2 }],
    prefix: "/ns/",
    renameOwn: "^z((?:cl|if)_.*)$",
    output: "out",
  });
  assert.deepEqual(config.global.files, ["/conformance/apps/abap/**/*.*", "/.github/abaplint/rename-deps/abap2ui5/src/0[0-2]/**/*.*"]);
  assert.deepEqual(config.global.exclude, ["/repo/src/01/"]);
  assert.deepEqual(config.dependencies, [{ url: "b" }, { url: "a" }]);
  assert.deepEqual(config.rename.patterns.map((p) => p.newName), ["/ns/$1", "/ns/$1"]);
  assert.equal(config.rules.check_syntax, true);
});

test("rename: the renamed tree in both output layouts", () => {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), "rename-"));
  try {
    const root = path.join(dir, "repo");
    const output = path.join(root, ".github/abaplint/output");
    assert.equal(renamedSource(output, root, "src"), undefined);
    // a config outside the root, abaplint up to 2.120.121
    const absolute = path.join(output, root, "src");
    fs.mkdirSync(absolute, { recursive: true });
    assert.equal(renamedSource(output, root, "src"), absolute);
    // a config at the root, every version
    fs.mkdirSync(path.join(output, "src"), { recursive: true });
    assert.equal(renamedSource(output, root, "src"), path.join(output, "src"));
  } finally {
    fs.rmSync(dir, { recursive: true, force: true });
  }
});

test("rename: --out never deletes the repository, a folder above it or what the run reads", () => {
  const root = path.resolve("/work/repo");
  const keep = [path.join(root, "src"), path.join(root, ".github/abaplint"), path.join(root, ".git")];
  for (const out of [".", "..", "/", "src", "src/00", ".github", ".github/abaplint/output", ".git"]) {
    assert.ok(outRefusal(path.resolve(root, out), root, keep), out);
  }
  for (const out of [".github/out/rename_zmy", "out", "../elsewhere"]) {
    assert.equal(outRefusal(path.resolve(root, out), root, keep), undefined, out);
  }
});

test("rename: the names distributions and build-rename take, and no other", () => {
  assert.equal(prefixOf("ZMYUI5"), "zmyui5_");
  assert.equal(prefixOf("/CA2UI5/"), "/ca2ui5/");
  assert.equal(prefixOf("z_my"), "z_my_");
  assert.throws(() => prefixOf("ZMYUI5_"), /ends in '_'/);
  assert.throws(() => prefixOf("z2ui5"), /original name/);
  assert.throws(() => prefixOf("1abc"), /invalid name/);
  assert.throws(() => prefixOf("/ca2ui5"), /invalid name/);
  assert.throws(() => prefixOf("zabcdefghij"), /11 characters, this repository allows at most 10/);
  assert.throws(() => prefixOf("zabcdefg", 6, "four classes over 25"), /at most 6 \(.*four classes over 25\)/);
});

test("rename: an ICF node's name, padded or exactly 15 characters long", () => {
  assert.deepEqual(objectOf("src/z2ui5_cci      001108d002800838e37bde4c3.sicf.xml").name, "z2ui5_cci");
  assert.equal(objectOf("src/zxxxxxxxx_agent8dc23e1f0a9b4c7d2e6f1a0b6.sicf.xml").name, "zxxxxxxxx_agent");
  assert.equal(objectOf("src/zcl_x_app.clas.xml").name, "zcl_x_app");
  assert.equal(objectOf("src/#abc#cl_x.clas.xml").name, "/abc/cl_x");
});

test("update-deps: the transpiler a runtime package records", () => {
  // @abap2ui5/node-runtime writes it under abap2ui5 (node/setup/pack-npm.mjs)
  assert.equal(transpilerOf({ abap2ui5: { transpiler: "2.13.1", commit: "abc" } }), "2.13.1");
  assert.equal(transpilerOf({ transpiler: "2.12.0" }), "2.12.0");
  assert.equal(transpilerOf({ name: "x" }), undefined);
});

test("update-deps: only a single version moves, in its own style", () => {
  assert.equal(nextSpec("^1.2.3", "1.4.0"), "^1.4.0");
  assert.equal(nextSpec("~1.2.3", "1.4.0"), "~1.4.0");
  assert.equal(nextSpec("1.2.3", "2.0.0"), "2.0.0");
  assert.equal(nextSpec("^1.0.0-beta.1", "1.0.0"), "^1.0.0");
  for (const spec of ["1.x", "^1 || ^2", ">=1.2.0", "latest", "1.2", "npm:@openui5/sap.m@1.71.81", "github:a/b"]) {
    assert.equal(nextSpec(spec, "9.9.9"), undefined, spec);
  }
});

test("update-deps: package.json keeps its indentation and line endings", () => {
  const value = { name: "x", dependencies: { a: "^1.0.0" } };
  assert.equal(formatLike('{\n  "name": "x"\n}\n', value), JSON.stringify(value, null, 2) + "\n");
  assert.equal(formatLike('{\n\t"name": "x"\n}\n', value), JSON.stringify(value, null, "\t") + "\n");
  assert.equal(formatLike('{\n    "name": "x"\n}', value), JSON.stringify(value, null, 4));
  const crlf = formatLike('{\r\n    "name": "x"\r\n}\r\n', value);
  assert.equal(crlf, JSON.stringify(value, null, 4).replace(/\n/g, "\r\n") + "\r\n");
  assert.ok(!/[^\r]\n/.test(crlf));
});

test("update-deps: action pins, and nothing across a line break", () => {
  const sha = "a".repeat(40);
  const next = "b".repeat(40);
  // every repository has a newer release - the second line must still stay:
  // its comment is on the next line and belongs to nothing
  const latestOf = () => ({ tag: "v7.0.2", sha: next });
  const yaml = `    - uses: actions/checkout@${sha} # v7.0.1\n    - uses: other/action@${sha}\n      # v1.0.0\n`;
  const { text, changed } = pinActions(yaml, latestOf);
  assert.equal(text, `    - uses: actions/checkout@${next} # v7.0.2\n    - uses: other/action@${sha}\n      # v1.0.0\n`);
  assert.deepEqual(changed, ["`actions/checkout` v7.0.1 → v7.0.2"]);
  // a repository whose release cannot be read is left as it is
  assert.equal(pinActions(`uses: x/y@${sha} # v1`, () => undefined).text, `uses: x/y@${sha} # v1`);
});

test("update-deps: npm never sees a credential", () => {
  const env = withoutSecrets({
    PATH: "/bin", HOME: "/h", GH_TOKEN: "x", DEPS_TOKEN: "x", GITHUB_TOKEN: "x",
    NPM_TOKEN: "x", NODE_AUTH_TOKEN: "x", ANTHROPIC_API_KEY: "x", MY_SECRET: "x", VSCE_PAT: "x",
  });
  assert.deepEqual(Object.keys(env).sort(), ["HOME", "PATH"]);
});
