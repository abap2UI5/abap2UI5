// Value formatting for the developer tools - JSON and XML to display text.
//
// Split out of devtools/DeveloperTools.js so the tab registry
// (devtools/Tabs.js) can produce finished text without depending on the
// dialog control. That is what lets ONE table drive the tab strip, the
// cross-tab search and the export: every consumer needs a string, and
// none of them should have to know whether the value behind a tab
// started life as an object or as an XML document.
//
// Both functions are total: they never throw and never return undefined.
// A developer tool that dies on a value the app was happy to hold is
// worse than useless, so a failure degrades to the plain string form.
sap.ui.define([], () => {
  "use strict";

  // toJson() pretty-prints with this many spaces per nesting level.
  const INDENT_UNIT = 3;

  // Pretty-print any value (object, array, primitive) as indented JSON.
  // `null` is used as a fallback so undefined values still produce output.
  // A replacer drops circular references (the z2ui5 global can hold them,
  // e.g. via ComponentData) so the output stays useful JSON instead of
  // throwing and degrading to a bare "[object Object]".
  function toJson(val) {
    const safe = val === undefined ? null : val;
    // Track the ANCESTOR chain, not every object ever visited: a plain
    // WeakSet of all seen objects would mislabel a value referenced twice in
    // sibling branches (common in the live z2ui5 global) as "[Circular]".
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

  // XSL stylesheet used by prettifyXml to reindent any XML string.
  const PRETTIFY_XSL = `<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
        <xsl:strip-space elements="*" />
        <xsl:template match="para[content-style][not(text())]">
          <xsl:value-of select="normalize-space(.)" />
        </xsl:template>
        <xsl:template match="node()|@*">
          <xsl:copy>
            <xsl:apply-templates select="node()|@*" />
          </xsl:copy>
        </xsl:template>
        <xsl:output indent="yes" />
      </xsl:stylesheet>`;

  // The XSLT processor and (de)serializers are expensive to construct, so
  // we keep them as module-level singletons - built on FIRST USE, not at
  // module load: this module is in every page's preload, and the text
  // helpers below are used without ever prettifying an XML.
  let _xmlSerializer = null;
  let _domParser = null;
  let _xsltProcessor = null;

  function getDomParser() {
    if (!_domParser) _domParser = new DOMParser();
    return _domParser;
  }

  function getXmlSerializer() {
    if (!_xmlSerializer) _xmlSerializer = new XMLSerializer();
    return _xmlSerializer;
  }

  function getXsltProcessor() {
    if (_xsltProcessor) return _xsltProcessor;
    const xsltDoc = getDomParser().parseFromString(
      PRETTIFY_XSL,
      "application/xml",
    );
    _xsltProcessor = new XSLTProcessor();
    _xsltProcessor.importStylesheet(xsltDoc);
    return _xsltProcessor;
  }

  // Reformat an XML string with indentation. If anything goes wrong the
  // original input is returned unchanged - the developer tools must never
  // crash the host app.
  function prettifyXml(sourceXml) {
    if (!sourceXml) return "";
    try {
      const xmlDoc = getDomParser().parseFromString(
        sourceXml,
        "application/xml",
      );
      const resultDoc = getXsltProcessor().transformToDocument(xmlDoc);
      if (!resultDoc) return sourceXml;
      const resultXml = getXmlSerializer().serializeToString(resultDoc);
      // The serializer escapes > as &gt; in text nodes AND attribute values;
      // a raw > is legal in both, so it is put back for readability. &lt; is
      // NOT touched: a raw < is never legal there, and the view builder
      // escapes every < an attribute carries (htmlText, core:HTML content,
      // a text with a comparison) - unescaping it showed malformed XML and
      // made "Apply to App" fail on a view the developer had not edited.
      return resultXml.replace(/&gt;/g, ">");
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

  // A framework event wire in a handler's source or a view attribute:
  // eB / eBP / eF, then the quoted event name (single, double or the
  // XML-escaped apostrophe of a view attribute) - either right after the
  // parenthesis or as the first entry of the argument array, which for eBP
  // sits behind the $event and the veto expression:
  // `.eBP($event,true,['ITEM_PRESS'])`. Match 1 is the method, match 2 the
  // event name. No `g` flag, so exec( ) on it is stateless; a scan over a
  // whole view compiles its own global copy from `.source`.
  const FRAMEWORK_CALL =
    /\b(eB|eBP|eF)\s*\((?:[^[]*\[)?\s*(?:&apos;|&quot;|['"])([A-Za-z0-9_.-]+)/;

  return { toJson, prettifyXml, truncate, formatBytes, FRAMEWORK_CALL };
});
