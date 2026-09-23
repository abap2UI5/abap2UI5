// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");

// Tests the real implementation shipped in app/webapp/devtools/Format.js -
// the two value formatters the whole tab registry renders through.
//
// Both are total on purpose: a developer tool that dies on a value the app
// was happy to hold is worse than useless, so every failure path here has
// to degrade rather than throw. The circular-reference handling in
// particular had no coverage before it moved into a module of its own -
// and it is the subtle one, because the naive version (a WeakSet of every
// object ever seen) mislabels a value referenced twice in SIBLING branches
// as "[Circular]", which the live z2ui5 global does all the time.

function loadFormat({ xml } = {}) {
  const { module } = loadModule("devtools/Format.js", {
    sandbox: {
      XMLSerializer: class {
        serializeToString() {
          return xml?.serialized ?? "";
        }
      },
      DOMParser: class {
        parseFromString() {
          if (xml?.parseThrows) throw new Error("bad xml");
          return {};
        }
      },
      XSLTProcessor: class {
        importStylesheet() {}
        transformToDocument() {
          return xml?.transformed ?? null;
        }
      },
    },
  });
  return module;
}

test.describe("toJson", () => {
  test("pretty-prints with three spaces per level", () => {
    expect(loadFormat().toJson({ A: { B: 1 } })).toBe(
      '{\n   "A": {\n      "B": 1\n   }\n}',
    );
  });

  test("renders undefined as null rather than producing nothing", () => {
    expect(loadFormat().toJson(undefined)).toBe("null");
  });

  test("renders primitives", () => {
    const Format = loadFormat();
    expect(Format.toJson("x")).toBe('"x"');
    expect(Format.toJson(42)).toBe("42");
    expect(Format.toJson(null)).toBe("null");
  });

  test("drops a circular reference instead of throwing", () => {
    const node = { name: "root" };
    node.self = node;
    const out = loadFormat().toJson(node);
    expect(out).toContain('"name": "root"');
    expect(out).toContain("[Circular]");
  });

  test("drops a circular reference through a parent chain", () => {
    const parent = { name: "parent" };
    parent.child = { name: "child", parent };
    expect(loadFormat().toJson(parent)).toContain("[Circular]");
  });

  // The reason the replacer tracks the ANCESTOR chain rather than every
  // object it has seen: the same object under two sibling keys is not a
  // cycle, and calling it one would silently hide real data.
  test("keeps a value referenced twice in sibling branches", () => {
    const shared = { id: 7 };
    const out = loadFormat().toJson({ left: shared, right: shared });
    expect(out).not.toContain("[Circular]");
    expect(out.match(/"id": 7/g)?.length).toBe(2);
  });

  test("degrades to the plain string form when serialization still fails", () => {
    // a BigInt is not serializable and makes JSON.stringify throw
    expect(loadFormat().toJson(10n)).toBe("10");
  });
});

test.describe("prettifyXml", () => {
  test("empty input stays empty", () => {
    expect(loadFormat().prettifyXml("")).toBe("");
    expect(loadFormat().prettifyXml(undefined)).toBe("");
  });

  test("returns the input unchanged when the transform yields nothing", () => {
    // the documented fallback - the tools must never crash the host app
    expect(loadFormat().prettifyXml("<View/>")).toBe("<View/>");
  });

  test("returns the input unchanged when parsing throws", () => {
    const Format = loadFormat({ xml: { parseThrows: true } });
    expect(Format.prettifyXml("<not xml")).toBe("<not xml");
  });

  test("unescapes &gt; and keeps &lt; escaped", () => {
    // the serializer escapes > in text nodes and attribute values; a raw >
    // is legal there and reads better. A raw < never is, so &lt; stays -
    // otherwise the shown XML is malformed and Apply to App fails on it
    const Format = loadFormat({
      xml: {
        transformed: {},
        serialized: "&lt;Input value=&quot;x&quot;/&gt;",
      },
    });
    expect(Format.prettifyXml("<Input/>")).toBe("&lt;Input value=&quot;x&quot;/>");
  });

  test("an attribute carrying escaped markup stays well-formed", () => {
    // what the view builder ships for htmlText / core:HTML content
    const Format = loadFormat({
      xml: {
        transformed: {},
        serialized:
          '<FormattedText htmlText="&lt;strong&gt;x&lt;/strong&gt;"/>',
      },
    });
    expect(Format.prettifyXml("<FormattedText/>")).toBe(
      '<FormattedText htmlText="&lt;strong>x&lt;/strong>"/>',
    );
  });
});

test.describe("section", () => {
  test("underlines the title after a blank line", () => {
    expect(loadFormat().section("App")).toBe("\nApp\n---");
  });
});

// The inline preview the action list and the model diff render a value as.
test.describe("renderValue", () => {
  test("renders an object as its JSON and a scalar as its string", () => {
    const Format = loadFormat();
    expect(Format.renderValue({ A: 1 }, 100)).toBe('{"A":1}');
    expect(Format.renderValue(42, 100)).toBe("42");
    expect(Format.renderValue(null, 100)).toBe("null");
    expect(Format.renderValue(undefined, 100)).toBe("(absent)");
  });

  test("cuts at the given length and says how long it was", () => {
    expect(loadFormat().renderValue("x".repeat(500), 10)).toBe(
      `${"x".repeat(10)}... (500 chars)`,
    );
  });

  test("degrades to the string form when the JSON cannot be built", () => {
    expect(loadFormat().renderValue({ big: 10n }, 100)).toBe("[object Object]");
  });
});

// The shape description the Bindings tab and the picked control share.
test.describe("describeValue", () => {
  test("describes tables and structures by shape, not by dumping them", () => {
    const Format = loadFormat();
    expect(Format.describeValue([1, 2, 3])).toBe("table, 3 row(s)");
    expect(Format.describeValue({ A: 1 })).toBe("structure, 1 field(s)");
    expect(Format.describeValue(null)).toBe("null");
  });

  test("labels the edge cases the way the caller names them", () => {
    const Format = loadFormat();
    expect(Format.describeValue(undefined)).toBe("(absent)");
    expect(Format.describeValue("")).toBe("(empty)");
    expect(
      Format.describeValue(undefined, { absent: "(no value at this path)" }),
    ).toBe("(no value at this path)");
    expect(Format.describeValue("", { empty: "(empty string)" })).toBe(
      "(empty string)",
    );
  });

  test("prefixes a scalar with its type on request", () => {
    const Format = loadFormat();
    expect(Format.describeValue("Miller AG", { typed: true })).toBe(
      "string  Miller AG",
    );
    expect(Format.describeValue(7, { typed: true })).toBe("number  7");
    expect(Format.describeValue("", { typed: true })).toBe("string (empty)");
    expect(Format.describeValue("Miller AG")).toBe("Miller AG");
  });

  test("cuts a long scalar at the given length", () => {
    expect(loadFormat().describeValue("x".repeat(90), { max: 80 })).toBe(
      `${"x".repeat(80)}... (90 chars)`,
    );
  });
});
