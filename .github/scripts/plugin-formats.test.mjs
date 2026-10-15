#!/usr/bin/env node
/*
 * plugin-formats.test — what generate-plugin.mjs writes, parsed the way its
 * consumers parse it.
 *
 * `npm run check:plugin` proves the copies under plugin/, plugin-copilot/
 * and skills/ match their sources; it does not prove a consumer can read
 * them. A description with an unquoted `: ` in it is valid Markdown, matches
 * its source byte for byte and is a YAML error that makes Claude Code,
 * Copilot or the `skills` CLI drop the skill without a word. So every
 * frontmatter block goes through a real YAML parser (js-yaml, which
 * @ui5/cli brings into node_modules), every JSON file through JSON.parse, and
 * the fields each format requires are checked against what its reference
 * says:
 *
 *   SKILL.md         the Agent Skills specification - `name` equal to the
 *                    folder, lower-case letters, digits and single hyphens,
 *                    at most 64 characters; `description` 1-1024; `license`
 *                    a string, `metadata` a map of strings
 *   *.prompt.md      VS Code prompt files - `description`, `agent`, `tools`
 *                    a list, no Claude `$ARGUMENTS` left
 *   commands/*.md    Copilot CLI commands - `description`, `allowed-tools`
 *                    a list, no shell pre-approved
 *   *.agent.md       Copilot custom agents - `description` required, `tools`
 *                    a list, a prompt of at most 30,000 characters
 *   plugin.json      the Copilot CLI's legacy manifest - a kebab-case name of
 *                    at most 64 characters, a description of at most 1024,
 *                    component paths that exist
 *   .mcp.json        one stdio server with `command`, `args` and `tools`,
 *                    the same command the Claude manifest registers
 *
 *   node .github/scripts/plugin-formats.test.mjs   (npm run check:plugin-formats)
 */
import { test } from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import yaml from 'js-yaml';

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..', '..');
const COPILOT = 'plugin-copilot';

const read = (rel) => fs.readFileSync(path.join(ROOT, rel), 'utf8');
const list = (rel, re) => (fs.existsSync(path.join(ROOT, rel))
  ? fs.readdirSync(path.join(ROOT, rel)).filter((f) => re.test(f)).map((f) => `${rel}/${f}`)
  : []);

/* The frontmatter as the consumers read it: the first thing in the file,
 * between two `---` lines, parsed as YAML into a plain object. */
function frontmatter(rel) {
  const text = read(rel);
  const m = /^---\n([\s\S]*?)\n---\n/.exec(text);
  assert.ok(m, `${rel}: no frontmatter at the very top of the file`);
  let data;
  try {
    data = yaml.load(m[1]);
  } catch (e) {
    assert.fail(`${rel}: frontmatter is not valid YAML - ${e.message}`);
  }
  assert.ok(data && typeof data === 'object' && !Array.isArray(data), `${rel}: frontmatter is not a map`);
  return { data, body: text.slice(m[0].length) };
}

const nonEmpty = (rel, data, key, max = Infinity) => {
  assert.equal(typeof data[key], 'string', `${rel}: \`${key}\` missing or not a string`);
  assert.ok(data[key].trim().length > 0, `${rel}: \`${key}\` is empty`);
  assert.ok(data[key].length <= max, `${rel}: \`${key}\` is ${data[key].length} characters, at most ${max} allowed`);
};

const stringList = (rel, data, key) => {
  assert.ok(Array.isArray(data[key]), `${rel}: \`${key}\` is not a list`);
  assert.ok(data[key].length > 0, `${rel}: \`${key}\` is empty`);
  for (const t of data[key]) assert.equal(typeof t, 'string', `${rel}: \`${key}\` holds a non-string`);
};

function parseJson(rel) {
  try {
    return JSON.parse(read(rel));
  } catch (e) {
    return assert.fail(`${rel}: not valid JSON - ${e.message}`);
  }
}

const SKILL_DIRS = ['skills', `${COPILOT}/skills`, 'plugin/skills'];
const SKILL_FIELDS = new Set(['name', 'description', 'license', 'compatibility', 'metadata', 'allowed-tools']);

test('every SKILL.md follows the Agent Skills specification', () => {
  let seen = 0;
  for (const dir of SKILL_DIRS) {
    for (const folder of list(dir, /^[^.]/).filter((d) => fs.statSync(path.join(ROOT, d)).isDirectory())) {
      const rel = `${folder}/SKILL.md`;
      assert.ok(fs.existsSync(path.join(ROOT, rel)), `${folder}: a skill folder without SKILL.md`);
      const { data, body } = frontmatter(rel);
      const name = path.basename(folder);
      assert.equal(data.name, name, `${rel}: \`name\` "${data.name}" is not the folder name "${name}"`);
      assert.match(data.name, /^[a-z0-9]+(-[a-z0-9]+)*$/, `${rel}: \`name\` is not lower-case letters, digits and single hyphens`);
      assert.ok(data.name.length <= 64, `${rel}: \`name\` over 64 characters`);
      nonEmpty(rel, data, 'description', 1024);
      if (dir !== 'plugin/skills') {
        for (const key of Object.keys(data)) assert.ok(SKILL_FIELDS.has(key), `${rel}: \`${key}\` is not a specification field`);
        nonEmpty(rel, data, 'license');
        assert.ok(data.metadata && typeof data.metadata === 'object', `${rel}: \`metadata\` is not a map`);
        for (const [k, v] of Object.entries(data.metadata)) assert.equal(typeof v, 'string', `${rel}: metadata.${k} is not a string`);
      }
      assert.ok(body.trim().length > 0, `${rel}: no instructions below the frontmatter`);
      seen += 1;
    }
  }
  assert.ok(seen >= 12, `expected the four skills in each of ${SKILL_DIRS.join(', ')}, found ${seen} SKILL.md`);
});

test('the guide a portable skill points at is next to it', () => {
  for (const dir of ['skills', `${COPILOT}/skills`]) {
    const rel = `${dir}/build-an-app/SKILL.md`;
    assert.match(read(rel), /`references\/building-apps\.md`/, `${rel}: does not point at references/building-apps.md`);
    assert.ok(fs.existsSync(path.join(ROOT, dir, 'build-an-app', 'references', 'building-apps.md')),
      `${dir}/build-an-app/references/building-apps.md is missing`);
  }
});

test('every Copilot prompt file has description, agent and a tools list', () => {
  const files = list(`${COPILOT}/prompts`, /\.prompt\.md$/);
  assert.equal(files.length, 5, `expected five prompt files, found ${files.length}`);
  for (const rel of files) {
    const { data, body } = frontmatter(rel);
    nonEmpty(rel, data, 'description');
    assert.ok(['agent', 'ask', 'edit'].includes(data.agent), `${rel}: \`agent\` "${data.agent}" is not agent, ask or edit`);
    stringList(rel, data, 'tools');
    if ('argument-hint' in data) nonEmpty(rel, data, 'argument-hint');
    assert.ok(!body.includes('$ARGUMENTS'), `${rel}: Claude's $ARGUMENTS is left in the prompt`);
    assert.ok(body.includes('${input:arguments}'), `${rel}: the prompt never reads its input`);
  }
});

test('every Copilot CLI command has description and allowed-tools, and pre-approves no shell', () => {
  const files = list(`${COPILOT}/commands`, /\.md$/);
  assert.equal(files.length, 5, `expected five commands, found ${files.length}`);
  for (const rel of files) {
    const { data, body } = frontmatter(rel);
    nonEmpty(rel, data, 'description');
    stringList(rel, data, 'allowed-tools');
    for (const t of data['allowed-tools']) {
      assert.ok(!/^(execute|shell|bash|powershell)\b/i.test(t), `${rel}: \`allowed-tools\` pre-approves the shell ("${t}")`);
    }
    assert.ok(!/\$ARGUMENTS|\$\{input:/.test(body), `${rel}: an argument placeholder the CLI does not substitute`);
  }
});

test('the Claude Code commands parse too (they are the source of the Copilot ones)', () => {
  const files = list('plugin/commands', /\.md$/);
  assert.equal(files.length, 5, `expected five commands, found ${files.length}`);
  for (const rel of files) {
    const { data } = frontmatter(rel);
    nonEmpty(rel, data, 'description');
    nonEmpty(rel, data, 'allowed-tools');
  }
});

test('the Copilot custom agent and its Claude source parse', () => {
  const agents = list(`${COPILOT}/agents`, /\.agent\.md$/);
  assert.equal(agents.length, 1, `expected one custom agent, found ${agents.length}`);
  for (const rel of agents) {
    const { data, body } = frontmatter(rel);
    nonEmpty(rel, data, 'description');
    assert.equal(`${data.name}.agent.md`, path.basename(rel), `${rel}: \`name\` is not the file name`);
    stringList(rel, data, 'tools');
    assert.ok(body.length <= 30000, `${rel}: the prompt is ${body.length} characters, at most 30,000 allowed`);
  }
  const { data } = frontmatter('plugin/agents/abap2ui5-reviewer.md');
  nonEmpty('plugin/agents/abap2ui5-reviewer.md', data, 'name');
  nonEmpty('plugin/agents/abap2ui5-reviewer.md', data, 'description');
});

test('the Copilot manifest parses and its component paths exist', () => {
  const rel = `${COPILOT}/plugin.json`;
  const m = parseJson(rel);
  assert.match(m.name, /^[a-z0-9]+(-[a-z0-9]+)*$/, `${rel}: name is not kebab-case`);
  assert.ok(m.name.length <= 64, `${rel}: name over 64 characters`);
  assert.equal(typeof m.description, 'string', `${rel}: no description`);
  assert.ok(m.description.length <= 1024, `${rel}: description is ${m.description.length} characters, at most 1024`);
  for (const key of ['agents', 'skills', 'commands', 'mcpServers']) {
    assert.equal(typeof m[key], 'string', `${rel}: \`${key}\` is not a path`);
    assert.ok(fs.existsSync(path.join(ROOT, COPILOT, m[key])), `${rel}: \`${key}\` points at ${m[key]}, which does not exist`);
  }
});

test('the MCP config parses and registers the server the Claude plugin registers', () => {
  const rel = `${COPILOT}/.mcp.json`;
  const servers = Object.entries(parseJson(rel).mcpServers ?? {});
  assert.equal(servers.length, 1, `${rel}: expected exactly one server under mcpServers`);
  const [name, s] = servers[0];
  assert.ok(['stdio', 'local'].includes(s.type), `${rel}: ${name}.type "${s.type}" is not stdio or local`);
  assert.equal(typeof s.command, 'string', `${rel}: ${name}.command is not a string`);
  assert.ok(Array.isArray(s.args) && s.args.every((a) => typeof a === 'string'), `${rel}: ${name}.args is not a list of strings`);
  assert.ok(Array.isArray(s.tools) && s.tools.length > 0, `${rel}: ${name}.tools is required and not a list`);
  const claude = parseJson('plugin/.claude-plugin/plugin.json').mcpServers?.[name];
  assert.ok(claude, `plugin/.claude-plugin/plugin.json registers no server "${name}"`);
  assert.deepEqual([s.command, ...s.args], [claude.command, ...claude.args], `${rel}: not the command the Claude manifest runs`);
  parseJson('.claude-plugin/marketplace.json');
});
