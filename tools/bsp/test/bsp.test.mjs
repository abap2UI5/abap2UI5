// The tests of @abap2ui5/bsp - `npm run test:bsp`, node's own runner.
//
// The real case is abap2UI5's own webapp: app2bsp -> check -> bsp2app has to
// give back every file, and app2bsp over that result the BSP it started
// from, byte for byte. The rest pins the page format and every refusal.

import { test } from "node:test";
import assert from "node:assert/strict";
import { execFileSync, spawnSync } from "node:child_process";
import { mkdirSync, mkdtempSync, readdirSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import {
  app2bsp,
  bsp2app,
  bspName,
  checkBspFolder,
  pathMapping,
  sicfFileName,
  toFile,
  toPage,
} from "../index.mjs";

const here = dirname(fileURLToPath(import.meta.url));
const repo = join(here, "..", "..", "..");
const cli = join(here, "..", "cli.mjs");

const scratch = () => mkdtempSync(join(tmpdir(), "abap2ui5-bsp-"));

function filesIn(dir, base = dir) {
  return readdirSync(dir, { withFileTypes: true }).flatMap((entry) =>
    entry.isDirectory()
      ? filesIn(join(dir, entry.name), base)
      : [join(dir, entry.name).slice(base.length + 1).split("\\").join("/")],
  );
}

function app(files) {
  const dir = scratch();
  for (const [file, content] of Object.entries(files)) {
    mkdirSync(dirname(join(dir, file)), { recursive: true });
    writeFileSync(join(dir, file), content);
  }
  return dir;
}

// what the system keeps of a text file: no spaces at line ends, one newline
const normalized = (text) => {
  const lines = text.split(/\r\n|\r|\n/).map((line) => line.replace(/ +$/, ""));
  if (lines.length > 1 && lines[lines.length - 1] === "") lines.pop();
  return lines.join("\n") + "\n";
};

test("a page is 255-character lines, no newline after the last", () => {
  const page = toPage("a\r\nbb\n");
  assert.equal(page, "a".padEnd(255) + "\n" + "bb".padEnd(255));
  assert.equal(toFile(page), "a\nbb\n");
  const long = "x".repeat(300);
  assert.deepEqual(
    toPage(long).split("\n").map((line) => line.length),
    [255, 255],
  );
});

test("the path mapping is the format the UI5 repository writes", () => {
  // the checked-in page abap2UI5 has delivered for years, for the files it lists
  const shipped = readFileSync(join(repo, "tools/app2bsp/static_files/z2ui5.wapa.ui5repositorypathmapping.xml"), "utf8");
  const files = [...shipped.matchAll(/internal_rep_path = "([^"]+)"/g)].map((m) => m[1]);
  assert.equal(toPage(pathMapping(files)), shipped);
});

test("the ICF node file names are abapGit's", () => {
  const shipped = [
    ...readdirSync(join(repo, "tools/app2bsp/static_files")),
    ...readdirSync(join(repo, "frontend/abap/standard/01")),
  ].filter((file) => file.endsWith(".sicf.xml"));
  for (const url of ["/sap/bc/ui5_ui5/sap/z2ui5/", "/sap/bc/bsp/sap/z2ui5/", "/sap/bc/z2ui5/"]) {
    assert.ok(shipped.includes(sicfFileName("Z2UI5", url)), url);
  }
});

test("abap2UI5's webapp: app2bsp, check, bsp2app and back, byte for byte", () => {
  const webapp = join(repo, "app/webapp");
  const work = scratch();
  try {
    const first = join(work, "first");
    app2bsp({ webapp, target: first, name: "ZTEST", packageText: "test" });
    assert.deepEqual(checkBspFolder(first).problems, []);

    const back = join(work, "back");
    const result = bsp2app({ source: first, target: back });
    assert.deepEqual(result.unregistered, []);
    const files = filesIn(webapp).sort();
    assert.deepEqual(filesIn(back).sort(), files);
    for (const file of files) {
      assert.equal(readFileSync(join(back, file), "utf8"), normalized(readFileSync(join(webapp, file), "utf8")), file);
    }

    const second = join(work, "second");
    app2bsp({ webapp: back, target: second, name: "ZTEST", packageText: "test" });
    assert.deepEqual(filesIn(second).sort(), filesIn(first).sort());
    for (const file of filesIn(first)) {
      assert.equal(readFileSync(join(second, file), "utf8"), readFileSync(join(first, file), "utf8"), file);
    }
  } finally {
    rmSync(work, { recursive: true, force: true });
  }
});

test("app2bsp refuses what the system cannot take, naming every case", () => {
  const webapp = app({
    "Component-preload.js": "x",
    "a.js": "y".repeat(256),
    "img/logo.png": Buffer.from([0x89, 0x50, 0x4e, 0x47, 0, 1]),
    "Dup.js": "1",
    "dup.js": "2",
  });
  try {
    assert.throws(
      () => app2bsp({ webapp, target: join(webapp, "..", "never"), name: "ZX" }),
      (error) => {
        assert.equal(error.problems.length, 4);
        assert.match(error.problems.join("\n"), /Component-preload\.js: a BSP page name/);
        assert.match(error.problems.join("\n"), /a\.js:1: 256 characters/);
        assert.match(error.problems.join("\n"), /img\/logo\.png: not a UTF-8 text file/);
        assert.match(error.problems.join("\n"), /same page file/);
        return true;
      },
    );
  } finally {
    rmSync(webapp, { recursive: true, force: true });
  }
});

test("app2bsp writes only into an empty folder", () => {
  const webapp = app({ "index.html": "<html/>" });
  try {
    assert.throws(() => app2bsp({ webapp, target: webapp, name: "ZX" }), /is not empty/);
  } finally {
    rmSync(webapp, { recursive: true, force: true });
  }
});

test("BSP names: Z/Y names up to 15 characters, no /NS/ namespace", () => {
  assert.equal(bspName("zmyapp"), "ZMYAPP");
  assert.throws(() => bspName("/ABAPGIT/UI5"), /namespace/);
  assert.throws(() => bspName("Z234567890123456"), /at most 15/);
  assert.throws(() => bspName("Z-APP"), /letters, digits/);
  assert.throws(() => bspName(""), /name is needed/);
});

test("bsp2app: a missing page file and a page name outside the folder are errors", () => {
  const webapp = app({ "index.html": "<html/>", "view/Main.view.xml": "<mvc:View/>" });
  const work = scratch();
  try {
    const bsp = join(work, "bsp");
    app2bsp({ webapp, target: bsp, name: "ZX" });
    rmSync(join(bsp, "zx.wapa.view_-main.view.xml"));
    assert.throws(() => bsp2app({ source: bsp, target: join(work, "a") }), /view\/Main\.view\.xml: registered, but/);

    const xml = join(bsp, "zx.wapa.xml");
    writeFileSync(xml, readFileSync(xml, "utf8").replace("<PAGENAME>view/Main.view.xml<", "<PAGENAME>../evil.js<"));
    assert.throws(() => bsp2app({ source: bsp, target: join(work, "b") }), /\.\.\/evil\.js: not a page name/);
  } finally {
    rmSync(webapp, { recursive: true, force: true });
    rmSync(work, { recursive: true, force: true });
  }
});

test("check: an unregistered page file, a long line, broken JavaScript", () => {
  const webapp = app({ "index.html": "<html/>", "a.js": "var a = 1;" });
  const work = scratch();
  try {
    const bsp = join(work, "bsp");
    app2bsp({ webapp, target: bsp, name: "ZX" });
    writeFileSync(join(bsp, "zx.wapa.stray.js"), "x");
    writeFileSync(join(bsp, "zx.wapa.a.js"), "var a = ;".padEnd(256));
    const { problems } = checkBspFolder(bsp);
    assert.equal(problems.length, 3, problems.join("\n"));
  } finally {
    rmSync(webapp, { recursive: true, force: true });
    rmSync(work, { recursive: true, force: true });
  }
});

test("the CLI: app2bsp again replaces its own output, and nothing else", () => {
  const webapp = app({ "index.html": "<html/>", "Component.js": "sap.ui.define([], () => {});" });
  const work = scratch();
  const run = (...args) => spawnSync(process.execPath, [cli, ...args], { cwd: work, encoding: "utf8" });
  try {
    const out = join(work, "bsp");
    assert.equal(run("app2bsp", webapp, "--name", "zx", "--out", out).status, 0);
    rmSync(join(webapp, "Component.js"));
    assert.equal(run("app2bsp", webapp, "--name", "zx", "--out", out).status, 0);
    assert.ok(!readdirSync(join(out, "src")).includes("zx.wapa.component.js"), "a removed file stays removed");
    assert.ok(readdirSync(out).includes(".abapgit.xml"));

    writeFileSync(join(out, "src", "notes.txt"), "mine");
    const refused = run("app2bsp", webapp, "--name", "zx", "--out", out);
    assert.equal(refused.status, 1);
    assert.match(refused.stderr, /did not write \(notes\.txt\)/);

    // check looks at the files of the BSP (zx.wapa.*) only
    assert.equal(run("check", out).status, 0);
  } finally {
    rmSync(webapp, { recursive: true, force: true });
    rmSync(work, { recursive: true, force: true });
  }
});

test("the CLI: bsp2app and check", () => {
  const webapp = app({ "index.html": "<html/>\n", "view/Main.view.xml": "<mvc:View/>\n" });
  const work = scratch();
  try {
    execFileSync(process.execPath, [cli, "app2bsp", webapp, "--name", "ZX", "--out", join(work, "bsp")]);
    execFileSync(process.execPath, [cli, "check", join(work, "bsp")]);
    execFileSync(process.execPath, [cli, "bsp2app", join(work, "bsp", "src"), "--out", join(work, "app")]);
    assert.equal(readFileSync(join(work, "app", "view", "Main.view.xml"), "utf8"), "<mvc:View/>\n");
    const again = spawnSync(process.execPath, [cli, "bsp2app", join(work, "bsp", "src"), "--out", join(work, "app")], {
      encoding: "utf8",
    });
    assert.equal(again.status, 1);
    assert.match(again.stderr, /is not empty/);
  } finally {
    rmSync(webapp, { recursive: true, force: true });
    rmSync(work, { recursive: true, force: true });
  }
});
