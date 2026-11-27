/*
 * app-guide-deviations — the sentences abap2UI5/app-template's AGENTS.md is
 * expected to say differently, declared once and executed by two programs.
 *
 * `docs/agents/building-apps.md` in abap2UI5 is the app-building guide, and
 * app-template carries everything from "1. The model in one paragraph" down
 * as ONE file of its own (`TEMPLATE_GUIDE_FILE` below, a reference of its
 * build-an-app skill), so a new project can brief an agent without a
 * framework checkout. It cannot be a byte copy: a handful of sentences name
 * commands and files that exist in the framework repository and not in a
 * project made from the template. Those sentences are below, as
 * `[what the framework says, what the template says]`.
 *
 * The template's AGENTS.md does not carry the guide any more - 65 KB an agent
 * paid for before writing a line, whatever the task. It carries the
 * ESSENTIALS: the passages of the guide marked `<!-- essentials:<id> -->` ...
 * `<!-- /essentials:<id> -->` (comments, so a rendered page does not show
 * them), cut out and put in the order `renderEssentials` below gives them,
 * with a table of the guide's sections after them. Extracted, never retold:
 * a sentence there is a sentence of the guide.
 *
 * Two programs read this file, and they are in different repositories:
 *
 *   abap2UI5's `.github/scripts/shared-file-gate.mjs` applies the list to the
 *   guide and compares the result with app-template's guide file, and renders
 *   the essentials and compares them with the block in app-template's
 *   AGENTS.md — the source noticing that a copy stopped matching.
 *
 *   app-template's `scripts/generate-agents.mjs` applies the SAME list to the
 *   SAME guide and writes both — the copies being produced rather than
 *   maintained by hand.
 *
 * Which is why the file itself is shared, byte-equal, and gated (it is in
 * `shared-file-gate.mjs`'s SHARED list, like the guide it belongs to). Two
 * independent transcriptions of the same three substitutions would put the
 * drift back one level down, in the place that is hardest to see: a generator
 * and a gate that disagree produce a file that fails a check nobody can fix
 * from either side alone.
 *
 * Rules for editing:
 *
 *   A deviation is a DECISION about the guide, not a translation convenience.
 *   Keep them to whole sentences, so a reviewer can see what was traded, and
 *   keep the `from` text long enough to be unambiguous — both readers replace
 *   every occurrence.
 *
 *   A `from` that no longer appears in the guide is a FAILURE in both
 *   programs, not a silently skipped rewrite: it means somebody edited a
 *   sentence a consumer is known to reword, and the two have to be reconciled
 *   by hand.
 *
 *   If a deviation ever grows past a few lines, that is the signal to move the
 *   sentence out of the mirrored half of the guide instead of maintaining a
 *   translation of it.
 */
export const GUIDE_DEVIATIONS = [
  /* §3, "Formatting the chain": the same command, under the name the template
   * gives it. `npm run fmt:chains` there, `npm run fix` here — both are
   * `abap2ui5lint --fix`. */
  [
    '`npm run check:abap2ui5` reports and `npm run fmt:chains` applies.',
    '`npm run check:abap2ui5` reports and `npm run fix` applies.',
  ],
  /* §3, same paragraph: a file of the framework repository. A project made
   * from the template has no autofix config at all — abaplint's formatting
   * rules are simply not enabled in its `abaplint.jsonc` — so the sentence has
   * to say whose file it is talking about. */
  [
    "`.github/abaplint/auto_abaplint_fix.jsonc` excludes the shipped apps from",
    "the framework repository's `.github/abaplint/auto_abaplint_fix.jsonc`"
      + ' excludes its shipped apps from',
  ],
  /* §8, "Formatters": `check:formatter` is a gate over the framework's own
   * curated formatter module. It does not exist in a project, and a project
   * has nothing for it to check. */
  [
    'and `npm run check:formatter` enforces them.',
    "and the framework's own `check:formatter` gate enforces them there.",
  ],
  /* §8, "Rules that keep apps portable": the link is relative to the framework's `docs/agents/`
   * folder. In a project's AGENTS.md it would point outside the repository,
   * so the template carries the absolute address of the same section. */
  [
    '([security model](../security.md#what-the-app-has-to-do))',
    '([security model](https://github.com/abap2UI5/abap2UI5/blob/main/docs/security.md#what-the-app-has-to-do))',
  ],
];

/* Applies the list to the framework's text, so what comes out is what the
 * template is expected to carry. Shared for the same reason the list is: the
 * gate and the generator have to fail on the same input and produce the same
 * output, and that is easier to guarantee than to check. */
export function applyGuideDeviations(text) {
  return GUIDE_DEVIATIONS.reduce((s, [from, to]) => {
    if (!s.includes(from)) {
      throw new Error(
        `declared deviation no longer matches the guide:\n      ${JSON.stringify(from)}\n`
        + '      the text it rewrites was edited or removed — update the deviation list',
      );
    }
    return s.split(from).join(to);
  }, text);
}

/* Everything from section 1 down: the part app-template mirrors. Above it each
 * repository says what IT is, which is not shared and must not be compared.
 *
 * Anchored to the start of a line, because app-template's provenance block
 * NAMES this heading when it explains how the mirror is produced — and an
 * unanchored search finds that sentence instead, then reports the whole guide
 * as different from line 1. A heading is a line, so the pattern says so. */
export const GUIDE_HEADING = '## 1. The model in one paragraph';

export function guideBody(text) {
  const at = text.search(/^## 1\. The model in one paragraph$/m);
  if (at === -1) throw new Error(`no "${GUIDE_HEADING}" heading on a line of its own`);
  return text.slice(at);
}

/* ------------------------------------------------------------------------
 * The essentials: what app-template's AGENTS.md carries of the guide.
 * ------------------------------------------------------------------------ */

/* Where the whole guide is in a project made from the template - the one
 * place, named by the essentials so a reader of AGENTS.md knows where a
 * section number leads. */
export const TEMPLATE_GUIDE_FILE = '.claude/skills/build-an-app/references/building-apps.md';

/* The generated block in the template's AGENTS.md sits between these two
 * lines. Everything outside them is the project's own. */
export const ESSENTIALS_BEGIN = '<!-- guide-essentials:begin - GENERATED from abap2UI5\'s docs/agents/building-apps.md by scripts/generate-agents.mjs in abap2UI5/app-template. Do not edit between this line and guide-essentials:end; put your own rules above. -->';
export const ESSENTIALS_END = '<!-- guide-essentials:end -->';

/* The marked passages of a guide text: Map of id -> the lines between
 * `<!-- essentials:<id> -->` and `<!-- /essentials:<id> -->`, each marker on a
 * line of its own (indented or not). A marker that is opened twice, never
 * closed or closed without being open is an error - a passage that silently
 * runs to the end of the file is the worst thing this could produce. */
export function guideEssentials(text) {
  const found = new Map();
  let open = null;
  let lines = [];
  for (const line of text.split('\n')) {
    const start = /^\s*<!-- essentials:([a-z0-9-]+) -->\s*$/.exec(line);
    const end = /^\s*<!-- \/essentials:([a-z0-9-]+) -->\s*$/.exec(line);
    if (start) {
      if (open) throw new Error(`essentials marker "${start[1]}" opens inside "${open}"`);
      if (found.has(start[1])) throw new Error(`essentials marker "${start[1]}" is in the guide twice`);
      open = start[1];
      lines = [];
    } else if (end) {
      if (open !== end[1]) throw new Error(`essentials marker "/${end[1]}" closes ${open ? `"${open}"` : 'nothing'}`);
      found.set(open, lines.join('\n').replace(/^\n+|\s+$/g, ''));
      open = null;
    } else if (open) {
      lines.push(line);
    }
  }
  if (open) throw new Error(`essentials marker "${open}" is never closed`);
  return found;
}

/* The guide's sections, read off its headings: `## 3. The view builder` with
 * the `###` headings under it. Lines inside a code fence are not headings. */
export function guideSections(text) {
  const sections = [];
  let fence = false;
  for (const line of text.split('\n')) {
    if (/^```/.test(line)) fence = !fence;
    if (fence) continue;
    const top = /^## (\d+)\. (.+)$/.exec(line);
    const sub = /^### (.+)$/.exec(line);
    if (top) sections.push({ n: Number(top[1]), title: top[2].trim(), parts: [] });
    else if (sub && sections.length) sections.at(-1).parts.push(sub[1].trim());
  }
  return sections;
}

/* In which order the marked passages appear, and under which heading. The
 * headings and the two sentences of glue are the only words here that are not
 * the guide's. An id the guide no longer marks FAILS, and so does a marked
 * passage this list does not place: either way somebody has to decide. */
const ESSENTIALS_LAYOUT = [
  ['### 1. The model in one paragraph', ['model']],
  ['### 2. The canonical app template', ['template', 'dispatcher']],
  ['### What you remember may be the old API (\u00a73)', ['names']],
  ['### Four rules that are cheap to break (\u00a73, \u00a74, \u00a78)', ['builder', 'binding', 'state']],
  ['### An addon class the lint gate does not find (\u00a76, \u00a79)', ['addons']],
];

/* The block for the template's AGENTS.md, from the guide text AFTER its
 * deviations were applied (`applyGuideDeviations(guideBody(guide))`), so a
 * reworded sentence is reworded here too. Without the two marker lines. */
export function renderEssentials(body) {
  const marked = guideEssentials(body);
  const placed = new Set(ESSENTIALS_LAYOUT.flatMap(([, ids]) => ids));
  for (const id of placed) {
    if (!marked.has(id)) throw new Error(`the guide no longer marks the passage "${id}" (<!-- essentials:${id} -->) - the essentials need it, or ESSENTIALS_LAYOUT has to drop it`);
  }
  for (const id of marked.keys()) {
    if (!placed.has(id)) throw new Error(`the guide marks a passage "${id}" that ESSENTIALS_LAYOUT does not place`);
  }
  const sections = guideSections(body);
  if (!sections.length) throw new Error('the guide has no "## <n>. <title>" heading - the section table would be empty');
  const out = [
    '## Building an app - the essentials',
    '',
    `What follows is cut out of the framework's app-building guide, word for word. The whole guide is ONE file, \`${TEMPLATE_GUIDE_FILE}\`; \u00a7N below is its section N. Read the section before you rely on a line here - and the whole of \u00a72 to \u00a75 before a first app.`,
  ];
  for (const [heading, ids] of ESSENTIALS_LAYOUT) {
    out.push('', heading, '', ids.map((id) => marked.get(id)).join(ids.every((id) => /^- /.test(marked.get(id))) ? '\n' : '\n\n'));
  }
  out.push('', '### Where to read on', '', `Sections of \`${TEMPLATE_GUIDE_FILE}\`:`, '', '| \u00a7 | Read it for |', '|---|---|');
  for (const s of sections) {
    out.push(`| ${s.n} | ${s.title.replace(/\|/g, '\\|')}${s.parts.length ? ` - ${s.parts.join('; ').replace(/\|/g, '\\|')}` : ''} |`);
  }
  return out.join('\n');
}

/* The generated block of an AGENTS.md, without its two marker lines. */
export function essentialsBlock(agents) {
  const begin = agents.indexOf(ESSENTIALS_BEGIN);
  const end = agents.indexOf(ESSENTIALS_END);
  if (begin === -1 || end === -1 || end < begin) throw new Error('no guide-essentials:begin ... guide-essentials:end block');
  return agents.slice(begin + ESSENTIALS_BEGIN.length, end).replace(/^\n+|\s+$/g, '');
}
