// @ts-check
const { test, expect } = require("@playwright/test");
const {
  normalizeForHash,
  computeFingerprint,
} = require("../../.github/app2abap/fingerprint");

// Tests the frontend build fingerprint (.github/app2abap/fingerprint.js).
//
// The fingerprint is compared across machines - the browser reports the one
// baked into its copy, the backend the one it embedded when app2abap last ran.
// So the property that matters is not "some hash" but: the same sources give
// the same answer everywhere, and different sources give a different one.
//
// The invariance tests below are regression tests. The first version hashed
// raw bytes, which made a checkout differing only in line endings produce a
// different fingerprint for byte-identical artefacts - check_app2abap failed
// on a tree that was in sync, and a real installation would have been told its
// correct frontend had drifted.

const FILES = [
  { relPath: "Component.js", content: "sap.ui.define([], () => {});\n" },
  { relPath: "core/Lib.js", content: "const a = 1;\nconst b = 2;\n" },
  { relPath: "css/style.css", content: ".a { color: red; }\n" },
];

const LENGTH = 12;
const fp = (entries) => computeFingerprint(entries, LENGTH);

test("the fingerprint has the requested length and is hex", () => {
  expect(fp(FILES)).toHaveLength(LENGTH);
  expect(fp(FILES)).toMatch(/^[0-9a-f]+$/);
});

test("the same sources always give the same fingerprint", () => {
  expect(fp(FILES)).toBe(fp(FILES));
});

// trans2abap strips trailing whitespace from every line, so these three trees
// generate byte-identical artefacts. They must therefore be one build.
test("line endings do not change the fingerprint", () => {
  const crlf = FILES.map((f) => ({
    ...f,
    content: f.content.replace(/\n/g, "\r\n"),
  }));

  expect(fp(crlf)).toBe(fp(FILES));
});

test("trailing whitespace does not change the fingerprint", () => {
  const padded = FILES.map((f) => ({
    ...f,
    content: f.content.replace(/\n/g, "   \n"),
  }));

  expect(fp(padded)).toBe(fp(FILES));
});

// readdir order is not part of the identity, and neither is the collation of
// whatever ICU build node was compiled with - hence the code-unit sort.
test("input order does not change the fingerprint", () => {
  expect(fp([...FILES].reverse())).toBe(fp(FILES));
});

// The other half: everything that DOES change what ships must move the hash.
test("a changed file changes the fingerprint", () => {
  const changed = FILES.map((f) =>
    f.relPath === "core/Lib.js" ? { ...f, content: "const a = 2;\n" } : f,
  );

  expect(fp(changed)).not.toBe(fp(FILES));
});

test("a renamed file changes the fingerprint", () => {
  const renamed = FILES.map((f) =>
    f.relPath === "core/Lib.js" ? { ...f, relPath: "core/Lib2.js" } : f,
  );

  expect(fp(renamed)).not.toBe(fp(FILES));
});

test("an added file changes the fingerprint", () => {
  expect(fp([...FILES, { relPath: "core/New.js", content: "" }])).not.toBe(
    fp(FILES),
  );
});

test("a removed file changes the fingerprint", () => {
  expect(fp(FILES.slice(1))).not.toBe(fp(FILES));
});

// Path and content are separated by the content length for exactly this case:
// without it, moving characters out of one file's tail into the next file's
// name would hash identically.
test("content cannot be shifted into a neighbouring path unnoticed", () => {
  const a = [
    { relPath: "a.js", content: "xy" },
    { relPath: "b.js", content: "" },
  ];
  const b = [
    { relPath: "a.js", content: "x" },
    { relPath: "yb.js", content: "" },
  ];

  expect(fp(a)).not.toBe(fp(b));
});

test("normalizeForHash strips trailing blanks and carriage returns only", () => {
  expect(normalizeForHash("a  \r\nb\t\n  c\n")).toBe("a\nb\n  c\n");
});
