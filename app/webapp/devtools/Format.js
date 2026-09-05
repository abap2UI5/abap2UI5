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
  // we keep them as module-level singletons.
  const _xmlSerializer = new XMLSerializer();
  const _domParser = new DOMParser();
  let _xsltProcessor = null;

  function getXsltProcessor() {
    if (_xsltProcessor) return _xsltProcessor;
    const xsltDoc = _domParser.parseFromString(PRETTIFY_XSL, "application/xml");
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
      const xmlDoc = _domParser.parseFromString(sourceXml, "application/xml");
      const resultDoc = getXsltProcessor().transformToDocument(xmlDoc);
      if (!resultDoc) return sourceXml;
      const resultXml = _xmlSerializer.serializeToString(resultDoc);
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

  return { toJson, prettifyXml };
});
