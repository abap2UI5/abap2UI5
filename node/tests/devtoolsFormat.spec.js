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

  test("unescapes the angle brackets the serializer escaped", () => {
    // the serializer escapes < and > inside text nodes; the output has to
    // be browseable XML again
    const Format = loadFormat({
      xml: {
        transformed: {},
        serialized: "&lt;Input value=&quot;x&quot;/&gt;",
      },
    });
    expect(Format.prettifyXml("<Input/>")).toBe('<Input value=&quot;x&quot;/>');
  });
});
