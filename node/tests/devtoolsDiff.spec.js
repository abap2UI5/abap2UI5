// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");

// Tests the real implementation shipped in app/webapp/devtools/Diff.js -
// the two pure diff walks behind the Model Diff and View Diff tabs. The
// rendering around them, and the choice of the two inputs, is
// devtools/Recorder.js's (devtoolsRecorder.spec.js); what is pinned here
// is the walks themselves and the caps that keep a pathological pair from
// freezing a tab.

function loadDiff() {
  return loadModule("devtools/Diff.js").module;
}

test.describe("collectDiff", () => {
  test("reports changed, added and removed paths", () => {
    const out = loadDiff().collectDiff(
      { A: 1, B: "old", GONE: true },
      { A: 1, B: "new", NEW: [] },
    );
    expect(out).toEqual([
      { path: "/B", type: "changed", before: "old", after: "new" },
      { path: "/GONE", type: "removed", before: true, after: undefined },
      { path: "/NEW", type: "added", before: undefined, after: [] },
    ]);
  });

  test("walks into table rows by index", () => {
    const out = loadDiff().collectDiff(
      { T: [{ COL: "a" }, { COL: "b" }] },
      { T: [{ COL: "a" }, { COL: "c" }, { COL: "d" }] },
    );
    expect(out.map((entry) => entry.path)).toEqual(["/T/1/COL", "/T/2"]);
    expect(out[1].type).toBe("added");
  });

  test("an identical pair yields nothing, whatever its shape", () => {
    const Diff = loadDiff();
    expect(Diff.collectDiff({ A: [1, { B: 2 }] }, { A: [1, { B: 2 }] })).toEqual(
      [],
    );
    expect(Diff.collectDiff(undefined, undefined)).toEqual([]);
  });

  test("a scalar against a structure is one change at that path", () => {
    const out = loadDiff().collectDiff({ A: 1 }, { A: { B: 1 } });
    expect(out).toEqual([
      { path: "/A", type: "changed", before: 1, after: { B: 1 } },
    ]);
  });

  test("stops descending past the depth cap", () => {
    const Diff = loadDiff();
    const depth = Diff._internals.MAX_DIFF_DEPTH + 2;
    const nest = (leaf) => {
      let value = leaf;
      for (let i = 0; i < depth; i += 1) value = { N: value };
      return value;
    };
    const out = Diff.collectDiff(nest(1), nest(2));
    expect(out.length).toBe(1);
    expect(out[0].before).toBe("(too deep)");
  });

  test("stops after MAX_DIFF_ENTRIES differences", () => {
    const Diff = loadDiff();
    const max = Diff.MAX_DIFF_ENTRIES;
    const before = {};
    const after = {};
    for (let i = 0; i < max + 50; i += 1) {
      before[`K${i}`] = i;
      after[`K${i}`] = -i - 1;
    }
    expect(Diff.collectDiff(before, after).length).toBe(max);
  });
});

test.describe("diffLines", () => {
  test("reports an inserted line as an addition with its line number", () => {
    const out = loadDiff().diffLines("a\nb\nc", "a\nb\nX\nc");
    expect(out).toEqual([{ type: "+", line: "X", number: 3 }]);
  });

  test("reports a removed line as a removal", () => {
    const out = loadDiff().diffLines("a\nb\nc", "a\nc");
    expect(out).toEqual([{ type: "-", line: "b", number: 2 }]);
  });

  test("reports a changed line as a removal plus an addition", () => {
    const out = loadDiff().diffLines("a\nb\nc", "a\nB\nc");
    expect(out).toEqual([
      { type: "-", line: "b", number: 2 },
      { type: "+", line: "B", number: 2 },
    ]);
  });

  test("identical texts produce no change", () => {
    expect(loadDiff().diffLines("a\nb", "a\nb")).toEqual([]);
  });

  // The walk resyncs inside a bounded window: an edit further away than
  // the lookahead is reported line by line as a replacement, which is the
  // honest reading of a wholesale rebuild.
  test("resyncs on a line within the lookahead window", () => {
    const Diff = loadDiff();
    const inserted = Array.from(
      { length: Diff._internals.DIFF_LOOKAHEAD - 1 },
      (_, i) => `new${i}`,
    );
    const out = Diff.diffLines("a\nz", ["a", ...inserted, "z"].join("\n"));
    expect(out.every((change) => change.type === "+")).toBe(true);
    expect(out.length).toBe(inserted.length);
  });

  test("stops after MAX_DIFF_ENTRIES changes", () => {
    const Diff = loadDiff();
    const max = Diff.MAX_DIFF_ENTRIES;
    const before = Array.from({ length: max + 50 }, (_, i) => `a${i}`).join(
      "\n",
    );
    const after = Array.from({ length: max + 50 }, (_, i) => `b${i}`).join(
      "\n",
    );
    expect(Diff.diffLines(before, after).length).toBe(max);
  });
});
