/*
 * Detector for `transpiler-reserved-js-identifiers`.
 *
 * Reports an ABAP declaration whose name is a reserved JavaScript word. The
 * seven abap2UI5 already configures are the negatives: each one is a name that
 * only compiles because somebody hit it and added it to a list, which is the
 * argument the item makes.
 */
import { lines, isComment, abapFiles } from '../../.github/scripts/lib/abap-scan.mjs';

export const describe =
  'an ABAP declaration named after a reserved JavaScript word, with the seven abap2UI5 already configures as the negatives';

/* ECMAScript reserved words plus the strict-mode additions and the future
 * reserved ones — all of them ordinary, likely ABAP identifiers. */
const RESERVED = new Set([
  'await', 'break', 'case', 'catch', 'class', 'const', 'continue', 'debugger',
  'default', 'delete', 'do', 'else', 'enum', 'export', 'extends', 'false',
  'finally', 'for', 'function', 'if', 'implements', 'import', 'in',
  'instanceof', 'interface', 'let', 'new', 'null', 'package', 'private',
  'protected', 'public', 'return', 'static', 'super', 'switch', 'this',
  'throw', 'true', 'try', 'typeof', 'var', 'void', 'while', 'with', 'yield',
]);

// already renamed by node/setup/abap_transpile.json's `keywords`
const CONFIGURED = new Set(['return', 'in', 'class', 'for', 'delete', 'var', 'with']);

const DECL =
  /^\s*(?:class-)?(?:data|constants|types|methods|class-methods|class-data|events|field-symbols)?\s*:?\s*(?:importing|exporting|changing|returning\s+value\()?\s*([a-z_][a-z_0-9]*)\s*\)?\s*(?:type|like)\s/i;

/* Which chain a declaration sits in decides whether the name becomes a JS
 * BINDING or an object key, and only a binding can collide.
 *
 * The first cut of this detector ignored that and reported six words — `enum`,
 * `false`, `null`, `default`, `new`, `interface`. Four were structure
 * components and constants, which the transpiler emits as object KEYS where a
 * reserved word is perfectly legal — and the corpus proves it, since it
 * transpiles green today with all four in place. That is the kind of number a
 * maintainer disproves in ten minutes, so it is narrowed here rather than
 * explained away in a note. */
const CHAIN = /^\s*(?:(class-data|class-methods|field-symbols|data|constants|types|methods|events))\b/i;
const BINDS = new Set(['data', 'class-data', 'field-symbols', 'methods', 'class-methods']);
const BEGIN_OF = /^\s*begin\s+of\b/i;
const END_OF = /^\s*end\s+of\b/i;

export function run(roots) {
  const sites = [];
  const negatives = [];
  const seen = new Set();
  for (const root of roots) {
    for (const file of abapFiles(root)) {
      let chain = 'data';
      let depth = 0;
      lines(file).forEach((line, i) => {
        if (isComment(line)) return;
        const c = CHAIN.exec(line);
        if (c) chain = c[1].toLowerCase();
        if (BEGIN_OF.test(line)) depth += 1;
        else if (END_OF.test(line)) depth = Math.max(0, depth - 1);

        const m = DECL.exec(line);
        if (!m) return;
        const name = m[1].toLowerCase();
        if (!RESERVED.has(name)) return;
        // a structure component and a constant become object KEYS, where a
        // reserved word is legal JavaScript
        if (depth > 0 || !BINDS.has(chain)) return;
        // one row per name per repository — the question is which words this
        // code base uses, and every occurrence of one shares its fate
        const key = `${file.repo}|${name}`;
        if (seen.has(key)) return;
        seen.add(key);
        const where = { repo: file.repo, file: file.rel, line: i + 1, text: `\`${name}\` — ${line.trim().slice(0, 50)}` };
        (CONFIGURED.has(name) ? negatives : sites).push(where);
      });
    }
  }
  return {
    sites,
    negatives,
    notes: [
      'One row per reserved word per repository, not per occurrence: the '
      + 'question is which words this code base uses, and every occurrence of '
      + 'one shares its fate.',
      'Only local data, field symbols and method parameters are counted. A '
      + 'constant or a structure component becomes an object KEY, where a '
      + 'reserved word is legal JavaScript — the corpus transpiles green today '
      + 'with `enum`, `false`, `null` and `default` as component names, which '
      + 'is why counting them would have inflated this by a factor of three.',
      'Only declarations with an explicit `TYPE`/`LIKE` on one line are '
      + 'matched. Inline `DATA(x)` and parameters split across lines are '
      + 'missed, so this is a floor.',
      'The negatives are the words already listed in '
      + '`node/setup/abap_transpile.json` — code that compiles only because '
      + 'somebody was bitten first. They are the argument, not an exception.',
    ],
  };
}
