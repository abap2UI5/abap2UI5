// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");

// Tests the real implementation shipped in bundle/webapp/devtools/Format.js -
// the two value formatters the whole tab registry renders through.
//
// Both are total on purpose: a developer tool that dies on a value the app
// was happy to hold is worse than useless, so every failure path here has
// to degrade rather than throw. The circular-reference handling in
// particular had no coverage before it moved into a module of its own -
// and it is the subtle one, because the naive version (a WeakSet of every
// object ever seen) mislabels a value referenced twice in SIBLING branches
// as "[Circular]", which the live z2ui5 global does all the time.

// A minimal, test-only stand-in for the browser's DOMParser: enough XML
// (elements, attributes, text, entities, comments, CDATA, processing
// instructions) to build the DOM-shaped tree prettifyXml walks - nodeType,
// nodeName, attributes, childNodes, nodeValue. Like Chrome it does not
// throw on malformed input but returns a document holding a <parsererror>.
// There is deliberately no XSLTProcessor and no XMLSerializer in the
// sandbox: the formatter must not need either (the XSLT API is deprecated
// in every browser and about to be removed).
function decodeEntities(text) {
  return text.replace(/&(#x[0-9a-f]+|#[0-9]+|lt|gt|amp|quot|apos);/gi, (m, e) => {
    if (e[0] === "#") {
      return String.fromCodePoint(
        e[1] === "x" || e[1] === "X" ? parseInt(e.slice(2), 16) : parseInt(e.slice(1), 10),
      );
    }
    return { lt: "<", gt: ">", amp: "&", quot: '"', apos: "'" }[e];
  });
}

function parseXml(src) {
  const doc = { nodeType: 9, childNodes: [], documentElement: null };
  const stack = [doc];
  const top = () => stack[stack.length - 1];
  const add = (node) => top().childNodes.push(node);
  let i = 0;
  const fail = () => {
    const err = { nodeType: 1, nodeName: "parsererror", attributes: [], childNodes: [] };
    return {
      nodeType: 9,
      childNodes: [err],
      documentElement: err,
      getElementsByTagName: (n) => (n === "parsererror" ? [err] : []),
    };
  };
  while (i < src.length) {
    if (src.startsWith("<!--", i)) {
      const e = src.indexOf("-->", i);
      if (e < 0) return fail();
      add({ nodeType: 8, nodeValue: src.slice(i + 4, e) });
      i = e + 3;
    } else if (src.startsWith("<![CDATA[", i)) {
      const e = src.indexOf("]]>", i);
      if (e < 0 || stack.length === 1) return fail();
      add({ nodeType: 4, nodeValue: src.slice(i + 9, e) });
      i = e + 3;
    } else if (src.startsWith("<?", i)) {
      const e = src.indexOf("?>", i);
      if (e < 0) return fail();
      const [, target, data] = /^(\S+)\s*([\s\S]*)$/.exec(src.slice(i + 2, e));
      // the XML declaration is not a node
      if (target !== "xml") add({ nodeType: 7, target, data });
      i = e + 2;
    } else if (src.startsWith("</", i)) {
      const m = /^<\/([\w:.-]+)\s*>/.exec(src.slice(i));
      if (!m || stack.length === 1 || top().nodeName !== m[1]) return fail();
      stack.pop();
      i += m[0].length;
    } else if (src[i] === "<") {
      const m = /^<([\w:.-]+)((?:\s+[\w:.-]+\s*=\s*(?:"[^"<]*"|'[^'<]*'))*)\s*(\/?)>/.exec(
        src.slice(i),
      );
      if (!m || (stack.length === 1 && doc.documentElement)) return fail();
      const attributes = [];
      const re = /([\w:.-]+)\s*=\s*(?:"([^"]*)"|'([^']*)')/g;
      let a;
      while ((a = re.exec(m[2]))) {
        // attribute-value normalization: literal whitespace becomes a space,
        // a character reference keeps what it names
        const raw = (a[2] ?? a[3]).replace(/[\t\n\r]/g, " ");
        attributes.push({ name: a[1], value: decodeEntities(raw) });
      }
      const el = { nodeType: 1, nodeName: m[1], attributes, childNodes: [] };
      add(el);
      if (stack.length === 1) doc.documentElement = el;
      if (!m[3]) stack.push(el);
      i += m[0].length;
    } else {
      const e = src.indexOf("<", i) < 0 ? src.length : src.indexOf("<", i);
      const raw = src.slice(i, e);
      if (stack.length === 1 && /\S/.test(raw)) return fail();
      if (/&(?!(#x[0-9a-f]+|#[0-9]+|lt|gt|amp|quot|apos);)/i.test(raw)) return fail();
      add({ nodeType: 3, nodeValue: decodeEntities(raw) });
      i = e;
    }
  }
  if (stack.length !== 1 || !doc.documentElement) return fail();
  doc.getElementsByTagName = () => [];
  return doc;
}

function loadFormat({ parseThrows = false } = {}) {
  const { module, sandbox } = loadModule("devtools/Format.js", {
    sandbox: {
      DOMParser: class {
        parseFromString(src) {
          if (parseThrows) throw new Error("bad xml");
          return parseXml(src);
        }
      },
    },
  });
  if ("XSLTProcessor" in sandbox || "XMLSerializer" in sandbox) {
    throw new Error("the sandbox must not offer XSLTProcessor/XMLSerializer");
  }
  return module;
}

// The tree a document parses to, blank text dropped - what must survive a
// round trip through prettifyXml unchanged.
function shape(node) {
  if (node.nodeType === 3 || node.nodeType === 4) return { text: node.nodeValue };
  if (node.nodeType !== 1 && node.nodeType !== 9) return { other: node.nodeType, v: node.nodeValue };
  const kids = node.childNodes.filter((c) => !((c.nodeType === 3) && !/\S/.test(c.nodeValue)));
  return {
    name: node.nodeName,
    attrs: (node.attributes || []).map((a) => [a.name, a.value]),
    kids: kids.map(shape),
  };
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

  test("indents nested elements two spaces per level", () => {
    const src =
      '<mvc:View xmlns:mvc="sap.ui.core.mvc" xmlns="sap.m"><Page title="T"><content><VBox><Button text="Go"/></VBox><Input/></content></Page></mvc:View>';
    expect(loadFormat().prettifyXml(src)).toBe(
      [
        '<mvc:View xmlns:mvc="sap.ui.core.mvc" xmlns="sap.m">',
        '  <Page title="T">',
        "    <content>",
        "      <VBox>",
        '        <Button text="Go"/>',
        "      </VBox>",
        "      <Input/>",
        "    </content>",
        "  </Page>",
        "</mvc:View>",
      ].join("\n"),
    );
  });

  test("re-indents an already indented view instead of keeping its layout", () => {
    const src = "<A>\n\t\t<B>\n   <C/>\n</B>\n\n<D></D></A>";
    expect(loadFormat().prettifyXml(src)).toBe(
      "<A>\n  <B>\n    <C/>\n  </B>\n  <D/>\n</A>",
    );
  });

  test("keeps &lt; escaped in an attribute and writes > raw", () => {
    // what the view builder ships for htmlText / core:HTML content: a raw <
    // is never legal in an attribute, so &lt; stays - otherwise the shown
    // XML is malformed and Apply to App fails on it. A raw > is legal and
    // reads better.
    const src =
      '<FormattedText htmlText="&lt;strong&gt;x &amp; y&lt;/strong&gt;" tooltip="a &quot;b&quot; c"/>';
    const out = loadFormat().prettifyXml(src);
    expect(out).toBe(
      '<FormattedText htmlText="&lt;strong>x &amp; y&lt;/strong>" tooltip="a &quot;b&quot; c"/>',
    );
    expect(shape(parseXml(out))).toEqual(shape(parseXml(src)));
  });

  test("keeps a line break in an attribute value across the round trip", () => {
    const src = '<CodeEditor value="line1&#10;line2&#9;x"/>';
    const out = loadFormat().prettifyXml(src);
    expect(out).toBe('<CodeEditor value="line1&#10;line2&#9;x"/>');
    expect(parseXml(out).documentElement.attributes[0].value).toBe("line1\nline2\tx");
  });

  test("writes a text-only element on one line with its text verbatim", () => {
    const src = "<A><Text>  1 &lt; 2 &amp;&amp; 3 &gt; 2  </Text><B/></A>";
    expect(loadFormat().prettifyXml(src)).toBe(
      "<A>\n  <Text>  1 &lt; 2 &amp;&amp; 3 > 2  </Text>\n  <B/>\n</A>",
    );
  });

  test("does not indent inside mixed content", () => {
    const src = "<A><p>one <b>two</b> three</p></A>";
    expect(loadFormat().prettifyXml(src)).toBe(
      "<A>\n  <p>one <b>two</b> three</p>\n</A>",
    );
  });

  test("escapes the ]]> a text may not contain", () => {
    const out = loadFormat().prettifyXml("<A>x]]&gt;y</A>");
    expect(out).toBe("<A>x]]&gt;y</A>");
  });

  test("keeps comments, CDATA and processing instructions", () => {
    const src =
      '<?xml version="1.0"?><?pi data?><A><!-- note --><B><![CDATA[<raw>]]></B></A>';
    expect(loadFormat().prettifyXml(src)).toBe(
      "<?pi data?>\n<A>\n  <!-- note -->\n  <B><![CDATA[<raw>]]></B>\n</A>",
    );
  });

  test("the output parses back to the same document", () => {
    const src =
      '<core:FragmentDefinition xmlns="sap.m" xmlns:core="sap.ui.core"><Dialog title="a&lt;b"><buttons><Button text="OK" press="onOk"/></buttons><Text text="x"/><Label>Name: <core:Icon src="sap-icon://edit"/></Label></Dialog></core:FragmentDefinition>';
    const Format = loadFormat();
    const out = Format.prettifyXml(src);
    expect(shape(parseXml(out))).toEqual(shape(parseXml(src)));
    // and formatting is idempotent
    expect(Format.prettifyXml(out)).toBe(out);
  });

  test("returns a malformed input unchanged", () => {
    // the browser reports a parse error as a <parsererror> document, not
    // as an exception - showing that document would replace the view
    const Format = loadFormat();
    expect(Format.prettifyXml("<A><B></A>")).toBe("<A><B></A>");
    expect(Format.prettifyXml("<not xml")).toBe("<not xml");
    expect(Format.prettifyXml("plain text")).toBe("plain text");
  });

  test("returns the input unchanged when parsing throws", () => {
    const Format = loadFormat({ parseThrows: true });
    expect(Format.prettifyXml("<not xml")).toBe("<not xml");
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
