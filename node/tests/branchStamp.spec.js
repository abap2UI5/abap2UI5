// @ts-check
const { test, expect } = require("@playwright/test");
const path = require("path");
const { pathToFileURL } = require("url");

// tools/branch-stamp.mjs - the core commit a delivery branch names in its
// README banner and VERSION. frontend_deploy.yaml stamps a candidate with the
// commit the published VERSION names and compares; a sha that silently became
// HEAD there would stamp the wrong commit without a word. So a sha that is
// handed over must be one, and only a missing one falls back.

const MODULE = path.join(__dirname, "..", "..", "tools", "branch-stamp.mjs");

/** @type {any} */
let mod;
const load = async () => (mod ??= await import(pathToFileURL(MODULE).href));

const SHA = "0123456789abcdef0123456789abcdef01234567";

test("a full sha is taken as it is", async () => {
  const { coreSha } = await load();
  expect(coreSha(SHA)).toBe(SHA);
});

test("a malformed explicit sha is refused, not replaced by HEAD", async () => {
  const { coreSha } = await load();
  for (const bad of [SHA.slice(0, 12), SHA.toUpperCase(), "main", `${SHA}0`]) {
    expect(() => coreSha(bad)).toThrow(/no full 40-digit commit sha/);
  }
});

test("without a sha the environment or HEAD answers", async () => {
  const { coreSha } = await load();
  const saved = process.env.GITHUB_SHA;
  try {
    process.env.GITHUB_SHA = SHA;
    expect(coreSha()).toBe(SHA);
    expect(coreSha("")).toBe(SHA);
    delete process.env.GITHUB_SHA;
    const head = coreSha();
    expect(head === null || /^[0-9a-f]{40}$/.test(head)).toBe(true);
  } finally {
    if (saved === undefined) delete process.env.GITHUB_SHA;
    else process.env.GITHUB_SHA = saved;
  }
});
