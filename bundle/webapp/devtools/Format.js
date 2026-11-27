// Value formatting for the developer tools - JSON and XML to display text,
// and the one-line value previews and report helpers every inspector
// shares.
//
// Split out of devtools/DeveloperTools.js so the tab registry
// (devtools/Tabs.js) can produce finished text without depending on the
// dialog control. That is what lets ONE table drive the tab strip, the
// cross-tab search and the export: every consumer needs a string, and
// none of them should have to know whether the value behind a tab
// started life as an object or as an XML document.
//
// Every function here is total: it never throws and never returns
// undefined. A developer tool that dies on a value the app was happy to
// hold is worse than useless, so a failure degrades to the plain string
// form.
sap.ui.define([], () => {
  "use strict";

  // toJson() pretty-prints with this many spaces per nesting level.
  const INDENT_UNIT = 3;

  // Pretty-print any value (object, array, primitive) as indented JSON.
  // `null` is used as a fallback so undefined values still produce output.
  // A replacer drops circular references (the app state can hold them,
  // e.g. via ComponentData) so the output stays useful JSON instead of
  // throwing and degrading to a bare "[object Object]".
  function toJson(val) {
    const safe = val === undefined ? null : val;
    // Track the ANCESTOR chain, not every object ever visited: a plain
    // WeakSet of all seen objects would mislabel a value referenced twice in
    // sibling branches (common in the live app state) as "[Circular]".
    // `this` inside the replacer is the object the key belongs to, so we can
    // unwind the stack back to it before testing containment.
    const ancestors = [];
    try {
      return JSON.stringify(
        safe,
        function (key, value) {
          if (typeof value === "object" && value !== null) {
            while (
              ancestors.length > 0 &&
              ancestors[ancestors.length - 1] !== this
            ) {
              ancestors.pop();
            }
            if (ancestors.includes(value)) return "[Circular]";
            ancestors.push(value);
          }
          return value;
        },
        INDENT_UNIT,
      );
    } catch {
      // The developer tools must never crash the host app, so degrade to the
      // plain string form if serialization still fails.
      return String(safe);
    }
  }

  // prettifyXml() indents with this many spaces per nesting level.
  const XML_INDENT_UNIT = 2;

  // Node types (DOM Level 1 constants, spelled out so the walk does not
  // depend on a global `Node` - the unit specs hand in a plain tree).
  const ELEMENT_NODE = 1;
  const TEXT_NODE = 3;
  const CDATA_SECTION_NODE = 4;
  const PROCESSING_INSTRUCTION_NODE = 7;
  const COMMENT_NODE = 8;

  // The parser is cheap but reused all the same - built on FIRST USE, not
  // at module load: the text helpers below are used without ever
  // prettifying an XML.
  let _domParser = null;

  function getDomParser() {
    if (!_domParser) _domParser = new DOMParser();
    return _domParser;
  }

  // Escaping. A raw > is legal in text and in an attribute value, so it is
  // written as is for readability - except where it would close "]]>",
  // which is illegal in text. & and < are ALWAYS escaped: a raw < is never
  // legal there, and the view builder escapes every < an attribute carries
  // (htmlText, core:HTML content, a text with a comparison) - writing it
  // back raw showed malformed XML and made "Apply to App" fail on a view
  // the developer had not edited. An attribute additionally escapes its
  // quote and the whitespace a parser would otherwise normalize to a
  // space, so the value survives the next parse unchanged.
  function escapeText(text) {
    return text
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/]]>/g, "]]&gt;");
  }

  function escapeAttribute(value) {
    return value
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/"/g, "&quot;")
      .replace(/\t/g, "&#9;")
      .replace(/\n/g, "&#10;")
      .replace(/\r/g, "&#13;");
  }

  function isTextLike(node) {
    return node.nodeType === TEXT_NODE || node.nodeType === CDATA_SECTION_NODE;
  }

  function isBlank(node) {
    return isTextLike(node) && !/\S/.test(node.nodeValue);
  }

  function serializeNode(node, depth, indented) {
    const pad = indented ? " ".repeat(depth * XML_INDENT_UNIT) : "";
    switch (node.nodeType) {
      case ELEMENT_NODE:
        return pad + serializeElement(node, depth, indented);
      case TEXT_NODE:
        return pad + escapeText(node.nodeValue);
      case CDATA_SECTION_NODE:
        return `${pad}<![CDATA[${node.nodeValue}]]>`;
      case COMMENT_NODE:
        return `${pad}<!--${node.nodeValue}-->`;
      case PROCESSING_INSTRUCTION_NODE:
        return `${pad}<?${node.target} ${node.data}?>`;
      // A document type declaration is dropped (a UI5 view never has one).
      // It is not written back on purpose: this module rides in the preload
      // bundle, and test_main_get_bundle proves that bundle is not the HTML
      // page by the absence of that very markup.
      default:
        return "";
    }
  }

  // An element whose children are elements (and comments) puts each child
  // on a line of its own, one level deeper; whitespace-only text between
  // them is the old layout and is dropped. As soon as an element holds
  // real text (mixed content, or just a value) its children are written
  // inline and verbatim - indenting there would change the text.
  function serializeElement(el, depth, indented) {
    let open = `<${el.nodeName}`;
    const attrs = el.attributes || [];
    for (let i = 0; i < attrs.length; i++) {
      open += ` ${attrs[i].name}="${escapeAttribute(attrs[i].value)}"`;
    }
    const children = Array.prototype.slice.call(el.childNodes || []);
    if (children.length === 0) return `${open}/>`;
    const close = `</${el.nodeName}>`;

    const mixed = children.some((c) => isTextLike(c) && !isBlank(c));
    if (mixed || !indented) {
      return `${open}>${children
        .map((c) => serializeNode(c, 0, false))
        .join("")}${close}`;
    }
    const kept = children.filter((c) => !isBlank(c));
    if (kept.length === 0) return `${open}/>`;
    const pad = " ".repeat(depth * XML_INDENT_UNIT);
    return `${open}>\n${kept
      .map((c) => serializeNode(c, depth + 1, true))
      .join("\n")}\n${pad}${close}`;
  }

  // Reformat an XML string with indentation - a plain walk over the parsed
  // document. It replaced an XSLT identity transform, which every browser
  // has deprecated (chromestatus feature 4709671889534976): once the
  // processor is gone the developer tools would have shown every view as
  // one long line, silently. If anything goes wrong
  // the original input is returned unchanged - the developer tools must
  // never crash the host app. A parse error does not throw in a browser,
  // it returns a document holding a <parsererror>; that is a failure too.
  function prettifyXml(sourceXml) {
    if (!sourceXml) return "";
    try {
      const xmlDoc = getDomParser().parseFromString(
        sourceXml,
        "application/xml",
      );
      if (!xmlDoc || !xmlDoc.documentElement) return sourceXml;
      if (
        xmlDoc.documentElement.nodeName === "parsererror" ||
        xmlDoc.getElementsByTagName("parsererror").length > 0
      ) {
        return sourceXml;
      }
      return Array.prototype.slice
        .call(xmlDoc.childNodes)
        .filter((node) => !isBlank(node))
        .map((node) => serializeNode(node, 0, true))
        .join("\n");
    } catch {
      return sourceXml;
    }
  }

  // Cut a value for an inline preview and say how long it really was.
  // Shared by the inspectors and the recorder's diff renderer, which each
  // carried a copy.
  function truncate(text, max) {
    const str = String(text);
    if (str.length <= max) return str;
    return `${str.slice(0, max)}... (${str.length} chars)`;
  }

  // A byte count as B / KB / MB; a missing count renders as "-".
  function formatBytes(bytes) {
    if (bytes === null || bytes === undefined) return "-";
    if (bytes < 1024) return `${bytes} B`;
    if (bytes < 1024 * 1024) return `${Math.round(bytes / 1024)} KB`;
    return `${(bytes / (1024 * 1024)).toFixed(1)} MB`;
  }

  // A section heading of a text report: the title, underlined, after a
  // blank line. Every inspector renders its report this way.
  function section(title) {
    return `\n${title}\n${"-".repeat(title.length)}`;
  }

  // A value as ONE inline preview line: an object as its JSON, anything
  // else as its string form, cut at `max`. What the action list and the
  // model diff show for an argument or a changed value.
  function renderValue(value, max) {
    if (value === undefined) return "(absent)";
    if (value === null) return "null";
    let text;
    if (typeof value === "object") {
      try {
        text = JSON.stringify(value);
      } catch {
        text = String(value);
      }
    } else {
      text = String(value);
    }
    return truncate(text, max);
  }

  // A model value the way a developer scanning for "why is this field
  // empty" needs it: a table by its row count, a structure by its field
  // count, a scalar as a short preview. The Bindings tab and the picked
  // control both describe values this way and label the edge cases
  // differently, so those are the options: `absent` is the text for
  // undefined, `empty` for "", `typed` prefixes a scalar with its type
  // ("string  Miller AG") and `max` cuts the preview.
  function describeValue(
    value,
    { max = 60, typed = false, absent = "(absent)", empty = "(empty)" } = {},
  ) {
    if (value === null) return "null";
    if (value === undefined) return absent;
    if (Array.isArray(value)) return `table, ${value.length} row(s)`;
    if (typeof value === "object") {
      return `structure, ${Object.keys(value).length} field(s)`;
    }
    if (value === "") return typed ? `${typeof value} ${empty}` : empty;
    const preview = truncate(value, max);
    return typed ? `${typeof value}  ${preview}` : preview;
  }

  // What the developer tools never show verbatim: the value under a name
  // that says it holds a secret. The tools are made to be shared - the
  // bug report goes into a public GitHub issue, the history JSON and the
  // journey's ABAP Unit class into a repository - and a password bound
  // with _bind( ) travels in the model, the request delta and the event
  // arguments like any other value. A NAME is what the tools can judge
  // (they see the model as data, not the control that edits it), so the
  // test is on the name - anywhere in it: MV_PASSWORD, MS_LOGIN-PASSWORD,
  // the path /S_LOGIN/PASSWORD and a table column all match. The one
  // test every formatter and every export asks; Report.js and Journey.js
  // each carried their own copy of it, and the two had drifted.
  //
  // Only names that denote a CREDENTIAL. A bare TOKEN in the list hid
  // what is no secret at all and is exactly what a developer opens the
  // tools to look at: the token tables of a MultiInput (MT_TOKEN, T_TOKEN,
  // mt_tokens_added - KEY/TEXT rows of a filter) and counters such as
  // TOKEN_COUNT went out as ***, numbers included. A token that IS a
  // credential says so (ACCESS_TOKEN, AUTH_TOKEN, CSRF_TOKEN, ...) and is
  // a secret whatever it holds; any other name ending in _TOKEN only when
  // it holds a non-empty string (a bearer token, an S_TOKEN of a login) -
  // never a table, a structure or a number (WEAK_SECRET_NAME below).
  const SECRET_NAME =
    /(PASSW|PWD|SECRET|CREDENTIAL|API_?KEY|BEARER|(?:ACCESS|AUTH|SESSION|REFRESH|CSRF|XSRF)[_-]?TOKEN)/i;
  const WEAK_SECRET_NAME = /_TOKEN$/i;
  const MASK = "***";
  // isSecretName( name ) without a value judges the name alone - a weak
  // name counts there, the caller cannot say what it holds
  const UNKNOWN = {};

  function isSecretName(name, value = UNKNOWN) {
    if (typeof name !== "string") return false;
    if (SECRET_NAME.test(name)) return true;
    if (!WEAK_SECRET_NAME.test(name)) return false;
    return value === UNKNOWN || (typeof value === "string" && value !== "");
  }

  // A leaf worth hiding: a value that says something. An empty string, a
  // boolean or null is shown as it is - "the password field is empty" is
  // the very thing a developer opens the tools to find out.
  function isMaskable(value) {
    return (
      (typeof value === "string" && value !== "") || typeof value === "number"
    );
  }

  // A secret's value that is masked wherever else it appears, too (see
  // maskSecrets): only one distinctive enough not to be an ordinary value
  // as well. A PIN "1000" or a password "EQ" smeared *** over every
  // plant 1000 and every range option EQ of the whole record - the
  // export then hid the very data the bug report is about. Eight
  // characters and not only digits is what an ordinary key field, an
  // option, a flag or an amount rarely is.
  const MIN_SMEAR_LENGTH = 8;
  function isDistinctive(value) {
    return value.length >= MIN_SMEAR_LENGTH && !/^\d+$/.test(value);
  }

  // The positional event arguments of a request - where a secret value is
  // masked whatever its length, see maskSecrets
  const EVENT_ARGS = "T_EVENT_ARG";

  // Walk a value and call `leaf(value, secret, inArgs)` for every leaf,
  // with `secret` true below a key that names a secret and `inArgs` true
  // below T_EVENT_ARG. Ancestors only (a value referenced twice in sibling
  // branches is no cycle, see toJson).
  //
  // Below a secret key a structure is masked field by field, and so is a
  // table of scalars - but a table of ROWS is not masked wholesale: its
  // cells are judged by their own column names (a PASSWORD column still
  // is). Rows under a secret name are a list of records, and masking all
  // of them hid every token row of a filter.
  function mapSecrets(value, secret, leaf) {
    const ancestors = [];
    const visit = (val, under, inArgs) => {
      if (val === null || typeof val !== "object") {
        return leaf(val, under, inArgs);
      }
      if (ancestors.includes(val)) return "[Circular]";
      ancestors.push(val);
      let out;
      if (Array.isArray(val)) {
        out = val.map((item) =>
          visit(
            item,
            under && (item === null || typeof item !== "object"),
            inArgs,
          ),
        );
      } else {
        out = {};
        for (const key of Object.keys(val)) {
          out[key] = visit(
            val[key],
            under || isSecretName(key, val[key]),
            inArgs || key === EVENT_ARGS,
          );
        }
      }
      ancestors.pop();
      return out;
    };
    return visit(value, secret, false);
  }

  // The strings found below a secret-named key - what an event argument
  // is compared with: T_EVENT_ARG is positional and carries no name, so a
  // password handed to the event (`${/PASSWORD}` as an argument) is
  // recognised by being the value the same request bound under one. Every
  // such string, short ones included: an argument equal to one is masked
  // (Journey.maskedArgs, and T_EVENT_ARG in maskSecrets); anywhere else
  // only a distinctive one is (isDistinctive).
  function secretValues(value) {
    const found = new Set();
    try {
      mapSecrets(value, false, (val, under) => {
        if (under && typeof val === "string" && val !== "") found.add(val);
        return val;
      });
    } catch {
      // total, like everything here: nothing found is an empty set
    }
    return found;
  }

  // A COPY of `value` with every scalar below a secret-named key replaced
  // by "***" - and, given `values` (a Set, see secretValues), every string
  // equal to one of them: in the event arguments (T_EVENT_ARG) always,
  // anywhere else when it is distinctive (isDistinctive). `secret` marks
  // the value itself as one (the caller knows its name, e.g. a diff
  // path); `inArgs` marks it as event-argument content (Journey's parsed
  // object argument). The input is never touched: the recorder's payloads
  // are live references.
  function maskSecrets(
    value,
    { secret = false, values = null, inArgs = false } = {},
  ) {
    try {
      return mapSecrets(value, secret, (val, under, args) => {
        if (under && isMaskable(val)) return MASK;
        if (
          values &&
          typeof val === "string" &&
          values.has(val) &&
          (inArgs || args || isDistinctive(val))
        ) {
          return MASK;
        }
        return val;
      });
    } catch {
      return MASK;
    }
  }

  // A framework event wire in a handler's source or a view attribute:
  // eB / eBP / eF, then the quoted event name (single, double or the
  // XML-escaped apostrophe of a view attribute) - either right after the
  // parenthesis or as the first entry of the argument array, which for eBP
  // sits behind the $event and the veto expression:
  // `.eBP($event,true,['ITEM_PRESS'])`. Match 1 is the method, match 2 the
  // event name. No `g` flag, so exec( ) on it is stateless; a scan over a
  // whole view compiles its own global copy from `.source`.
  //
  // What may stand between the parenthesis and the array is only what an
  // eBP puts there ($event and the veto expression) - never a quote, a
  // closing parenthesis or an entity. Open to anything but `[`, the skip
  // ran past the end of an eF('CONTROL_BY_ID', ...) to the next `[` in the
  // view - the eF was listed under the event of a later eB, and that eB
  // was gone.
  const FRAMEWORK_CALL =
    /\b(eB|eBP|eF)\s*\((?:[^[)"'&]*\[)?\s*(?:&apos;|&quot;|['"])([A-Za-z0-9_.-]+)/;

  return {
    toJson,
    prettifyXml,
    truncate,
    formatBytes,
    section,
    renderValue,
    describeValue,
    FRAMEWORK_CALL,
    MASK,
    isSecretName,
    maskSecrets,
    secretValues,
  };
});
