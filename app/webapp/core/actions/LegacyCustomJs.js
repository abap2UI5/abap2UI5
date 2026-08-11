sap.ui.define(["z2ui5/core/Lib"], (Lib) => {
  "use strict";

  // ------------------------------------------------------------------
  // The LEGACY follow-up-action wire formats, quarantined in one place.
  // Every framework-generated action is a JSON array today (format A,
  // handled in core/FrontendAction.js runCustom); what remains here is
  // only reached by apps that pass raw JavaScript strings to
  // follow_up_action:
  //   Format B: a structured eF( ) call string - its argument list is
  //             parsed manually (no eval / Function) so it runs under a
  //             strict Content-Security-Policy without unsafe-eval, while
  //             keeping object / array / string arguments intact.
  //   Format C: a raw expression such as alert(123) - needs a CSP that
  //             allows unsafe-eval, otherwise it is a no-op.
  // ------------------------------------------------------------------

  // The two quote characters the eF( ) argument parser below recognises.
  const CH_SQUOTE = "'";
  const CH_DQUOTE = '"';

  // Undo the escapes the backend applies to a single-quoted argument
  // (z2ui5_cl_core_srv_event=>escape_js_string): backslash, quote AND the
  // line breaks it rewrites to \n / \r - a raw newline would be a syntax
  // error inside a JS string literal, so a multi-line argument only ever
  // travels escaped. Decoding them in one pass keeps the order right: a
  // literal backslash-n ("\\n" on the wire) stays text instead of turning
  // into a line break.
  const EF_UNESCAPE = { n: "\n", r: "\r" };
  function unescapeEfString(body) {
    return body.replace(/\\(.)/g, (match, ch) => EF_UNESCAPE[ch] ?? ch);
  }

  // Convert a single JS-literal argument (as produced by the backend
  // get_t_arg) into a value WITHOUT eval: single- or double-quoted strings,
  // JSON objects / arrays, numbers, booleans and null.
  function parseEfValue(token) {
    if (token === "") return undefined;
    const first = token[0];
    if (first === CH_SQUOTE) {
      return unescapeEfString(token.slice(1, -1));
    }
    if (first === CH_DQUOTE || first === "{" || first === "[") {
      try {
        return JSON.parse(token);
      } catch {
        return token;
      }
    }
    if (token === "true") return true;
    if (token === "false") return false;
    if (token === "null") return null;
    if (token === "undefined") return undefined;
    const num = Number(token);
    return Number.isNaN(num) ? token : num;
  }

  // Split the argument list of an eF( ) call into its top-level arguments,
  // respecting nested (), {}, [] and quoted strings, and convert each one
  // to a value.
  function parseEfArgs(str) {
    const args = [];
    let depth = 0;
    let quote = null;
    let token = "";
    for (let i = 0; i < str.length; i++) {
      const ch = str[i];
      if (quote) {
        token += ch;
        if (ch === "\\" && i + 1 < str.length) token += str[++i];
        else if (ch === quote) quote = null;
        continue;
      }
      if (ch === CH_SQUOTE || ch === CH_DQUOTE) {
        quote = ch;
        token += ch;
      } else if (ch === "{" || ch === "[" || ch === "(") {
        depth++;
        token += ch;
      } else if (ch === "}" || ch === "]" || ch === ")") {
        depth--;
        token += ch;
      } else if (ch === "," && depth === 0) {
        args.push(parseEfValue(token.trim()));
        token = "";
      } else {
        token += ch;
      }
    }
    if (token.trim() !== "") args.push(parseEfValue(token.trim()));
    return args;
  }

  // Run one legacy snippet (formats B/C above). Never throws - a malformed
  // app snippet must not break the response processing it rides on.
  function run(item, oController) {
    try {
      const snippet = item.trim();
      const match = /^\.?eF\s*\(([\s\S]*)\)\s*;?$/.exec(snippet);
      if (match) {
        oController.eF(...parseEfArgs(match[1]));
        return;
      }
      // A raw JavaScript expression - only runs when the CSP allows
      // unsafe-eval.
      // eslint-disable-next-line no-new-func
      Function("return " + item)();
    } catch (e) {
      Lib.logError("customJs: execution failed", e);
    }
  }

  return { run };
});
