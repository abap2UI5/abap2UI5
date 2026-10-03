#!/usr/bin/env node
/*
 * generate-plugin — the Claude Code plugin under plugin/, written from the
 * skills and the app guide instead of by hand.
 *
 * This repository is also a Claude Code plugin marketplace
 * (`.claude-plugin/marketplace.json`), so an app developer gets the agent
 * skills and the MCP server with two commands:
 *
 *   /plugin marketplace add abap2UI5/abap2UI5
 *   /plugin install abap2ui5@abap2ui5
 *
 * WHY THE PLUGIN IS A FOLDER OF ITS OWN, and not the repository root with
 * `"skills": "./.claude/skills/"` in its manifest. That was the first shape,
 * and it installs: Claude Code copies a marketplace plugin into its cache and,
 * when the plugin root holds a package.json AND a lockfile, runs the package
 * install there - with no way to turn it off. The root of this repository has
 * both, so every user got the framework's whole devDependency tree (abaplint,
 * Playwright, the UI5 tooling): 166 MB in the cache for four Markdown files,
 * again for every version, and a plugin listed as half-installed whenever the
 * 60-second install budget ran out. A plugin may not reach outside its own
 * root either (a `..` path or a symlink out of it is refused), so the files
 * have to be IN plugin/ - which makes them copies, and a copy is the thing
 * CONVENTIONS §5 says is generated or gated. This is both.
 *
 * What it writes:
 *
 *   plugin/skills/<name>/SKILL.md      from .claude/skills/<name>/SKILL.md
 *   plugin/docs/agents/building-apps.md  from docs/agents/building-apps.md
 *
 * The guide travels with the skills because `build-an-app` is a pointer at it
 * ("the guide is the content"), and a pointer at a file the plugin user does
 * not have is a skill that sends the agent looking for nothing. The copy keeps
 * the path it has here, so the one sentence that names it only has to say
 * where the plugin is.
 *
 * Hand-written, and not touched here: `plugin/.claude-plugin/plugin.json`
 * (the manifest, with the MCP server inline - see the repository map for why
 * not a `.mcp.json`) and `plugin/README.md`.
 *
 * A HANDFUL OF SENTENCES DEVIATE, declared below as
 * `[what the source says, what the plugin copy says]`, the way
 * app-template's generate-skills.mjs declares its own. A deviation whose
 * sentence is no longer in the source FAILS rather than being skipped: it
 * means somebody edited a sentence this copy is known to reword, and the two
 * have to be reconciled by hand. Everything else is copied as it is, with one
 * provenance line after the frontmatter that says whose repository "this
 * repository" means - the catalogues name this repository's gates on nearly
 * every line, and those are facts about where a gate lives, not instructions
 * for the plugin user.
 *
 * Every skill under .claude/skills/ is either shipped (SKILLS) or left out
 * with a reason (NOT_SHIPPED) - a new skill cannot slip in or out of the
 * plugin unnoticed. A file under plugin/ that nothing here writes and that is
 * not one of the two hand-written ones fails as well, so a removed skill does
 * not linger in the plugin.
 *
 *   node .github/scripts/generate-plugin.mjs          rewrite plugin/  (npm run plugin)
 *   node .github/scripts/generate-plugin.mjs --check  fail if stale    (npm run check:plugin)
 */
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..', '..');
const PLUGIN = 'plugin';
const CHECK = process.argv.includes('--check');

const GUIDE = 'docs/agents/building-apps.md';

/* The skills the plugin ships, each with the sentences its copy rewords. */
const SKILLS = {
  'build-an-app': [
    /* The guide is in the plugin, not in the user's repository. */
    [
      '**Read `docs/agents/building-apps.md` in this repository — it is the complete\nself-contained guide**',
      '**Read `${CLAUDE_PLUGIN_ROOT}/docs/agents/building-apps.md` (the framework\'s\nguide, shipped with this plugin: `docs/agents/building-apps.md` two folders\nabove this skill\'s own) — it is the complete\nself-contained guide**',
    ],
    /* The interface is in the framework repository, which the plugin user
     * has not checked out. */
    [
      '- The API contract is `src/02/z2ui5_if_client.intf.abap` — when unsure about',
      '- The API contract is `src/02/z2ui5_if_client.intf.abap` in\n'
      + '  [abap2UI5/abap2UI5](https://github.com/abap2UI5/abap2UI5/blob/main/src/02/z2ui5_if_client.intf.abap)'
      + ' — when unsure about',
    ],
  ],
  'view-chain-layout': [],
  'abap-check': [],
  'ui5-check': [],
};

/* Skills under .claude/skills/ the plugin deliberately does not ship, each
 * with the reason. Empty today: all four are for app authors as much as for
 * framework contributors. */
const NOT_SHIPPED = new Map([]);

/* Files under plugin/ that are written by hand. */
const HAND_WRITTEN = new Set([
  `${PLUGIN}/.claude-plugin/plugin.json`,
  `${PLUGIN}/README.md`,
]);

const provenance = (source) => `<!-- GENERATED by .github/scripts/generate-plugin.mjs from ${source}`
  + ' in abap2UI5/abap2UI5 - "this repository" in the text is the framework\'s.'
  + ' Do not edit; run npm run plugin. -->';

const read = (rel) => fs.readFileSync(path.join(ROOT, rel), 'utf8');

function rewrite(name, text, deviations) {
  return deviations.reduce((s, [from, to]) => {
    if (!s.includes(from)) {
      throw new Error(
        `${name}: a declared deviation no longer matches the source:\n      ${JSON.stringify(from)}\n`
        + '      the sentence it rewrites was edited or removed - update SKILLS in'
        + ' .github/scripts/generate-plugin.mjs',
      );
    }
    return s.split(from).join(to);
  }, text);
}

/* Frontmatter stays first (Claude Code reads `name` and `description` from
 * it), the provenance line goes right below. */
function renderSkill(name) {
  const source = `.claude/skills/${name}/SKILL.md`;
  const text = read(source);
  const m = /^---\n[\s\S]*?\n---\n/.exec(text);
  if (!m) throw new Error(`${source}: no frontmatter (--- name/description ---) at the top`);
  const body = rewrite(name, text.slice(m[0].length), SKILLS[name]);
  return `${m[0]}${provenance(source)}\n${body.replace(/\s*$/, '')}\n`;
}

function renderGuide() {
  return `${provenance(GUIDE)}\n\n${read(GUIDE).replace(/\s*$/, '')}\n`;
}

function listFiles(dir, out = []) {
  if (!fs.existsSync(path.join(ROOT, dir))) return out;
  for (const entry of fs.readdirSync(path.join(ROOT, dir), { withFileTypes: true })) {
    const rel = `${dir}/${entry.name}`;
    if (entry.isDirectory()) listFiles(rel, out);
    else out.push(rel);
  }
  return out;
}

const problems = [];

/* Every skill is shipped or excluded by name. */
const present = fs.readdirSync(path.join(ROOT, '.claude', 'skills'), { withFileTypes: true })
  .filter((e) => e.isDirectory()).map((e) => e.name).sort();
for (const name of present) {
  if (!(name in SKILLS) && !NOT_SHIPPED.has(name)) {
    problems.push(`.claude/skills/${name} is neither shipped nor excluded - add it to SKILLS in`
      + ' .github/scripts/generate-plugin.mjs, or to NOT_SHIPPED with the reason');
  }
}
for (const name of [...Object.keys(SKILLS), ...NOT_SHIPPED.keys()]) {
  if (!present.includes(name)) {
    problems.push(`generate-plugin.mjs names the skill ${name}, which .claude/skills/ no longer has`
      + ' - drop the entry');
  }
}

const expected = new Map();
try {
  for (const name of Object.keys(SKILLS).filter((n) => present.includes(n))) {
    expected.set(`${PLUGIN}/skills/${name}/SKILL.md`, renderSkill(name));
  }
  expected.set(`${PLUGIN}/${GUIDE}`, renderGuide());
} catch (e) {
  problems.push(e.message);
}

for (const rel of HAND_WRITTEN) {
  if (!fs.existsSync(path.join(ROOT, rel))) problems.push(`${rel} is missing - it is written by hand, not generated`);
}

const stale = [];
for (const [rel, text] of expected) {
  const file = path.join(ROOT, rel);
  const current = fs.existsSync(file) ? fs.readFileSync(file, 'utf8') : null;
  if (current === text) continue;
  if (CHECK) {
    stale.push(rel);
  } else {
    fs.mkdirSync(path.dirname(file), { recursive: true });
    fs.writeFileSync(file, text);
    console.log(`generate-plugin: wrote ${rel}`);
  }
}

const orphans = listFiles(PLUGIN).filter((rel) => !expected.has(rel) && !HAND_WRITTEN.has(rel));
for (const rel of orphans) {
  if (CHECK) {
    stale.push(`${rel} (nothing generates it)`);
  } else {
    fs.rmSync(path.join(ROOT, rel));
    console.log(`generate-plugin: removed ${rel}`);
  }
}

if (stale.length) {
  problems.push('plugin/ is stale - run `npm run plugin` and commit the result:\n'
    + stale.map((rel) => `      ${rel}`).join('\n'));
}

if (problems.length) {
  for (const p of problems) console.log(`ERROR ${p}`);
  console.log(`generate-plugin: ${problems.length} error(s).`);
  process.exit(1);
}
console.log(`generate-plugin: ${CHECK ? 'ok' : 'done'} (${expected.size} generated file(s),`
  + ` ${Object.keys(SKILLS).length} skill(s), ${HAND_WRITTEN.size} hand-written)`);
