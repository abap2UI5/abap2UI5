/*
 * app-guide-deviations — the sentences abap2UI5/app-template's AGENTS.md is
 * expected to say differently, declared once and executed by two programs.
 *
 * `docs/agents/building-apps.md` in abap2UI5 is the app-building guide, and
 * app-template carries everything from "1. The model in one paragraph" down
 * inside its own AGENTS.md, so a new project can brief an agent without a
 * framework checkout. It cannot be a byte copy: a handful of sentences name
 * commands and files that exist in the framework repository and not in a
 * project made from the template. Those sentences are below, as
 * `[what the framework says, what the template says]`.
 *
 * Two programs read this file, and they are in different repositories:
 *
 *   abap2UI5's `.github/scripts/shared-file-gate.mjs` applies the list to the
 *   guide and compares the result with app-template's AGENTS.md — the source
 *   noticing that a copy stopped matching.
 *
 *   app-template's `scripts/generate-agents.mjs` applies the SAME list to the
 *   SAME guide and writes the result into AGENTS.md — the copy being produced
 *   rather than maintained by hand.
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
