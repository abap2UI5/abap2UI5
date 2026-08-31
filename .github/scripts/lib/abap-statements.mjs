/*
 * abap-statements — split ABAP source into statements.
 *
 * Two gates (extended-check-gate, exception-cause-gate) carried a
 * byte-identical splitter that knew backtick and single-quote literals but
 * not `|...|` string templates. That is not a cosmetic gap: a `"` inside a
 * template read as a comment, so the scan of that line stopped and the
 * statement swallowed everything up to the next period it happened to see —
 * the CATCH at z2ui5_cl_ui5_handler.clas.abap:504 was invisible to both
 * gates because the statement at :500 builds `|\{"S_FRONT":...\}|`. And a
 * `.` inside a template terminated the statement early
 * (z2ui5_cx_ui5_util_error.clas.abap:197, `|[...] chain truncated ...|`).
 *
 * So this scanner knows the four lexical shapes a gate has to get right:
 *   `...`      backtick literal (a doubled `` closes and reopens, which
 *              nets out to the correct end — same for '...')
 *   '...'      single-quote literal
 *   |...|      string template; `\` escapes the next character (\|, \{, \}),
 *              and `{ ... }` opens an embedded expression in which the
 *              normal rules apply again — literals, even a nested template
 *   "          comment to end of line, only in code at the top level
 *
 * Statements cannot span a literal across lines in ABAP, so the scan state
 * resets per line; only the "is a statement open" state carries over.
 *
 * Comment lines are handled the way both gates always did: a full-line `*`
 * comment is never part of a statement, and an indented `"` line BETWEEN
 * statements is a comment of its own. Trailing comments stay inside the
 * statement text on purpose — the pseudo-comments the extended-check gate
 * decides on ("#EC ...) live in exactly that trailing comment.
 */

/**
 * @param {string} source  ABAP source
 * @returns {{start: number, text: string}[]}  statements with their first
 *   source line (1-based); `text` keeps the raw lines, newlines included
 */
export function statements(source) {
  const out = [];
  let code = [];
  let start = 0;
  let line = 0;

  for (const raw of source.split("\n")) {
    line += 1;
    if (/^\*/.test(raw)) continue; // full-line comment: not part of any statement
    if (code.length === 0) {
      // Between statements, an indented `"` line is a comment of its own. Only
      // once a statement is open can such a line be a continuation of it.
      if (raw.trim() === "" || raw.trim().startsWith('"')) continue;
      start = line;
    }
    code.push(raw);

    if (terminatorAt(raw) >= 0) {
      out.push({ start, text: code.join("\n") });
      code = [];
    }
  }
  if (code.length > 0) out.push({ start, text: code.join("\n") });
  return out;
}

/* The statement terminator on one line: a period in code at the top level —
 * outside every literal, outside a template, outside a template's embedded
 * expression — and before any trailing comment. -1 when the line has none.
 *
 * `stack` is the lexical nesting: "code" at the bottom, a literal or template
 * pushed on entry and popped on its closing character, and an embedding
 * pushing "code" again so the normal rules apply inside `{ }`. */
function terminatorAt(raw) {
  const stack = ["code"];
  for (let i = 0; i < raw.length; i += 1) {
    const c = raw[i];
    const mode = stack[stack.length - 1];

    if (mode === "tick") {
      if (c === "`") stack.pop();
      continue;
    }
    if (mode === "quote") {
      if (c === "'") stack.pop();
      continue;
    }
    if (mode === "tmpl") {
      if (c === "\\") i += 1; // \| \{ \} \\ — escaped, not structural
      else if (c === "|") stack.pop();
      else if (c === "{") stack.push("code");
      continue;
    }

    // mode === "code"
    if (c === "`") stack.push("tick");
    else if (c === "'") stack.push("quote");
    else if (c === "|") stack.push("tmpl");
    else if (c === "}" && stack.length > 1) stack.pop(); // embedding closes
    else if (c === '"' && stack.length === 1) return -1; // rest is a comment
    else if (c === "." && stack.length === 1) return i;
  }
  return -1;
}
