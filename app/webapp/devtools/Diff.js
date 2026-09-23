// The two diff algorithms of the developer tools - a model tree diff and
// a line diff - as pure functions over plain data.
//
// Split out of devtools/Recorder.js, which renders their results as the
// Model Diff and View Diff tabs. Nothing here touches the DOM, UI5 or the
// recorded history: both walks take their two inputs and return a list of
// changes, capped so a pathological pair (a rebuilt 10,000-row table, a
// wholesale view rewrite) stops at a readable size instead of a frozen
// tab. Zero dependencies.
sap.ui.define([], () => {
  "use strict";

  // Changes reported before either walk gives up. The renderer marks a
  // list this long with "+" and says it stopped.
  const MAX_DIFF_ENTRIES = 200;

  // Nesting depth of the model walk. Deeper than this is reported as one
  // "(too deep)" change and not entered.
  const MAX_DIFF_DEPTH = 12;

  // Lines compared before the line diff gives up - a generated view can be
  // thousands of lines and this walk is deliberately cheap.
  const MAX_DIFF_LINES = 4000;

  // How far ahead the line walk looks for a line to resync on. A view
  // change is local (an inserted control, a changed attribute), so a small
  // window finds the anchor; a wholesale rebuild resyncs on nothing and is
  // reported as a full replacement, which is the honest answer for it.
  const DIFF_LOOKAHEAD = 25;

  function isPlainObject(value) {
    return value !== null && typeof value === "object" && !Array.isArray(value);
  }

  // Walk two model trees in parallel and collect the differing paths.
  // Arrays are compared by index - a table row inserted at the top does
  // report every following row as changed, which is the honest answer for
  // a model the backend rebuilds wholesale anyway.
  function walk(before, after, path, out, depth) {
    if (out.length >= MAX_DIFF_ENTRIES) return;
    if (before === after) return;
    if (depth > MAX_DIFF_DEPTH) {
      out.push({ path, type: "changed", before: "(too deep)", after: "" });
      return;
    }

    const bothObjects = isPlainObject(before) && isPlainObject(after);
    const bothArrays = Array.isArray(before) && Array.isArray(after);

    if (bothObjects) {
      const keys = new Set([...Object.keys(before), ...Object.keys(after)]);
      for (const key of keys) {
        walk(before[key], after[key], `${path}/${key}`, out, depth + 1);
      }
      return;
    }

    if (bothArrays) {
      const length = Math.max(before.length, after.length);
      for (let i = 0; i < length; i++) {
        walk(before[i], after[i], `${path}/${i}`, out, depth + 1);
      }
      return;
    }

    if (before === undefined) {
      out.push({ path, type: "added", before: undefined, after });
      return;
    }
    if (after === undefined) {
      out.push({ path, type: "removed", before, after: undefined });
      return;
    }
    out.push({ path, type: "changed", before, after });
  }

  // The differing paths between two model trees, in walk order. Each:
  // { path, type: "added" | "removed" | "changed", before, after }, with
  // the path as "/A/0/COL" and "" for the root itself.
  function collectDiff(before, after) {
    const out = [];
    walk(before, after, "", out, 0);
    return out;
  }

  // Line diff with a bounded resync window. Not an LCS: a full one is
  // quadratic, and for view XML - where edits are local - a lookahead
  // walk produces the same reading at a fraction of the cost. Each
  // change: { type: "+" | "-", line, number } with the 1-based line
  // number in the text the line comes from.
  function diffLines(beforeText, afterText) {
    const a = beforeText.split("\n").slice(0, MAX_DIFF_LINES);
    const b = afterText.split("\n").slice(0, MAX_DIFF_LINES);
    const out = [];
    let i = 0;
    let j = 0;
    while ((i < a.length || j < b.length) && out.length < MAX_DIFF_ENTRIES) {
      if (i < a.length && j < b.length && a[i] === b[j]) {
        i += 1;
        j += 1;
        continue;
      }
      let addedRun = -1;
      let removedRun = -1;
      for (let k = 1; k <= DIFF_LOOKAHEAD; k += 1) {
        if (
          addedRun < 0 &&
          i < a.length &&
          j + k < b.length &&
          a[i] === b[j + k]
        ) {
          addedRun = k;
        }
        if (
          removedRun < 0 &&
          j < b.length &&
          i + k < a.length &&
          b[j] === a[i + k]
        ) {
          removedRun = k;
        }
        if (addedRun >= 0 || removedRun >= 0) break;
      }
      if (addedRun >= 0 && (removedRun < 0 || addedRun <= removedRun)) {
        for (let k = 0; k < addedRun; k += 1) {
          out.push({ type: "+", line: b[j + k], number: j + k + 1 });
        }
        j += addedRun;
      } else if (removedRun >= 0) {
        for (let k = 0; k < removedRun; k += 1) {
          out.push({ type: "-", line: a[i + k], number: i + k + 1 });
        }
        i += removedRun;
      } else {
        // nothing to resync on - report the pair as a replacement
        if (i < a.length) {
          out.push({ type: "-", line: a[i], number: i + 1 });
          i += 1;
        }
        if (j < b.length) {
          out.push({ type: "+", line: b[j], number: j + 1 });
          j += 1;
        }
      }
    }
    return out;
  }

  return {
    collectDiff,
    diffLines,
    MAX_DIFF_ENTRIES,
    // exposed for the unit specs
    _internals: { MAX_DIFF_DEPTH, MAX_DIFF_LINES, DIFF_LOOKAHEAD },
  };
});
