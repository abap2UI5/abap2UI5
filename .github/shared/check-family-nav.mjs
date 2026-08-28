/*
 * check-family-nav — the SOURCE of the body every sample repository's copy runs.
 *
 * `samples`, `samples-controls` and `samples-stack` each carry
 * `scripts/check-family-nav.mjs`, and that file says of itself: "The canonical
 * wording lives below and is identical in all three copies" and "Only these
 * three lines differ between the copies."
 *
 * Both sentences were true and neither was checked. The copies agreed because
 * nobody had edited one yet — the same standing that `chain-format` had before
 * it drifted between two repositories while a skill in a third still called
 * them byte-identical, which is the story this gate was written from.
 *
 * So the body is shared and the three lines are not. Everything from the first
 * `import` down is compared against each consumer; above it each repository
 * keeps its own SELF / PAGE_HTML / PAGE_CSS, which is exactly the split the
 * file already documents.
 *
 * A `section` entry rather than a whole-file one, so `--manifest` leaves it
 * alone: a consumer's copy is a file it owns the top of, and copying a source
 * over it would destroy those three lines.
 */

/* The three a consumer owns, declared here only so that this file is a valid
 * module on its own — ESLint lints `.github/shared/` and `no-undef` is right
 * to object to a body that reads names nothing declares.
 *
 * They are placeholders and this copy is not meant to run: every consumer
 * replaces this block with its own values, and `familyNavBody()` in
 * shared-file-gate.mjs slices from the `import` BELOW, so nothing above this
 * line is part of what the gate compares. Changing them here changes nothing
 * anywhere. */
const SELF = 'samples';
const PAGE_HTML = 'web/index.html';
const PAGE_CSS = 'web/overview.css';

import { readFileSync } from 'node:fs';

/* --------------------------------------------------------------- canon */

const BASE = 'https://abap2ui5.github.io';

const PAGES = [
  {
    key: 'samples',
    url: `${BASE}/samples/`,
    repo: 'abap2UI5/samples',
    verb: 'Learn',
    subtitle: 'start here, one idea at a time',
    question: 'Where do I start?',
  },
  {
    key: 'samples-controls',
    url: `${BASE}/samples-controls/`,
    repo: 'abap2UI5/samples-controls',
    verb: 'Controls',
    subtitle: 'every UI5 control, searchable',
    question: 'Which control does what?',
  },
  {
    key: 'samples-stack',
    url: `${BASE}/samples-stack/`,
    repo: 'abap2UI5/samples-stack',
    verb: 'Stack',
    subtitle: 'OData, RAP and your system',
    question: 'Will my system run it?',
  },
];

const TOOLS = [`${BASE}/playground/`, `${BASE}/docs/`];

/* Our own origin, with the trailing slash, for the "is this one of ours?"
 * filter below. The slash is not cosmetic: a host name may continue where a
 * prefix stops, so `startsWith(BASE)` also accepts
 * `https://abap2ui5.github.io.example.com/samples/` - a link to somebody
 * else entirely, counted as one of the three and compared against the wanted
 * list as if it were. With the slash the host is closed. */
const OURS = `${BASE}/`;

/* The catalogue moved to the root of its Pages site when the in-browser demo
 * was dropped, so this address is a 404 and stayed in one footer for a while.
 * Nothing may link to it again. */
const RETIRED = `${BASE}/samples-controls/search/`;

/* ------------------------------------------------------------- helpers */

const problems = [];
const fail = (msg) => problems.push(msg);

/** The text between two markers, or null. */
function between(text, name) {
  const start = text.indexOf(`${name}:start`);
  const end = text.indexOf(`${name}:end`);
  if (start < 0 || end < 0 || end < start) return null;
  return text.slice(start, end);
}

/** Every href in source order. */
const hrefs = (block) => [...block.matchAll(/href="([^"]+)"/g)].map((m) => m[1]);

/** Which of the three pages an <a ... aria-current="page"> points at. */
function currentPage(block) {
  const marked = [...block.matchAll(/<a\b[^>]*>/g)]
    .map((m) => m[0])
    .filter((tag) => tag.includes('aria-current="page"'));
  if (marked.length !== 1) return { count: marked.length, key: null };
  const href = /href="([^"]+)"/.exec(marked[0])?.[1];
  return { count: 1, key: PAGES.find((p) => p.url === href)?.key ?? href };
}

/* --------------------------------------------------------------- checks */

const html = readFileSync(PAGE_HTML, 'utf8');
const css = readFileSync(PAGE_CSS, 'utf8');

if (!between(css, 'family-nav')) {
  fail(`${PAGE_CSS}: the family-nav:start / family-nav:end styles are missing`);
}

const nav = between(html, 'family-nav');
const three = between(html, 'three-pages');

if (!nav) fail(`${PAGE_HTML}: no family-nav:start / family-nav:end block`);
if (!three) fail(`${PAGE_HTML}: no three-pages:start / three-pages:end block`);

if (nav) {
  const want = [...PAGES.map((p) => p.url), ...TOOLS];
  const got = hrefs(nav).filter((h) => h.startsWith(OURS));
  if (got.join(' ') !== want.join(' ')) {
    fail(`the bar links to\n    ${got.join('\n    ')}\n  but must link, in this order, to\n    ${want.join('\n    ')}`);
  }

  for (const page of PAGES) {
    if (!nav.includes(`<b>${page.verb}</b> <span>${page.subtitle}</span>`)) {
      fail(`the bar does not carry "${page.verb}" with its subtitle "${page.subtitle}" - reword it in all three repositories or in none`);
    }
    if (!nav.includes(`title="${page.repo}"`)) {
      fail(`the bar does not name the repository ${page.repo} in a title attribute`);
    }
  }

  const here = currentPage(nav);
  if (here.count !== 1) fail(`the bar carries ${here.count} aria-current="page" links; it must carry exactly one`);
  else if (here.key !== SELF) fail(`the bar marks "${here.key}" as the current page, but this repository is ${SELF}`);
}

if (three) {
  const want = PAGES.map((p) => p.url);
  const got = hrefs(three).filter((h) => h.startsWith(OURS));
  if (got.join(' ') !== want.join(' ')) {
    fail(`the three-pages strip links to\n    ${got.join('\n    ')}\n  but must link, in this order, to\n    ${want.join('\n    ')}`);
  }

  for (const page of PAGES) {
    for (const [what, text] of [['verb', page.verb], ['repository', page.repo], ['question', page.question]]) {
      if (!three.includes(text)) {
        fail(`the three-pages strip is missing the ${what} "${text}" - reword it in all three repositories or in none`);
      }
    }
  }

  const here = currentPage(three);
  if (here.count !== 1) fail(`the three-pages strip carries ${here.count} aria-current="page" cards; it must carry exactly one`);
  else if (here.key !== SELF) fail(`the three-pages strip marks "${here.key}" as the current page, but this repository is ${SELF}`);
}

/* The footer is not a shared block - each repository links its own catalogue -
 * but both siblings have to be reachable from it. */
const footer = html.slice(html.indexOf('<footer>'));
for (const page of PAGES.filter((p) => p.key !== SELF)) {
  if (!footer.includes(page.url)) fail(`the footer does not link ${page.url}`);
}

if (html.includes(RETIRED)) {
  fail(`${PAGE_HTML} links ${RETIRED}, which is a 404 - the catalogue is served from the root of that site`);
}

/* ---------------------------------------------------------------- report */

if (problems.length) {
  console.error(`check:family-nav - ${problems.length} problem${problems.length === 1 ? '' : 's'} in ${SELF}:\n`);
  for (const p of problems) console.error(`  * ${p}\n`);
  console.error('The bar and the strip are shared with abap2UI5/samples, /samples-controls');
  console.error('and /samples-stack. Change them in all three repositories or in none.');
  process.exit(1);
}

console.log(`check:family-nav - the shared blocks in ${SELF} are intact`);
