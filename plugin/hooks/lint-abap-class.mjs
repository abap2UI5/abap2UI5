#!/usr/bin/env node
/*
 * lint-abap-class — the plugin's PostToolUse hook (hooks/hooks.json).
 *
 * After the agent edits or writes a `*.clas.abap` file, this runs the
 * abap2UI5 linter's STATIC check (the property gate, `--no-render`) on that
 * one file and hands the errors and warnings back to the agent, so it fixes
 * a typo'd control or a post-1.71 property in the very next step instead of
 * at the end with /abap2ui5:check.
 *
 * Two promises, both because a hook runs on EVERY edit of every project the
 * plugin is enabled in:
 *
 *   - It never blocks work and never installs anything. It runs only when the
 *     project already has the linter - `node_modules/@abap2ui5/linter` (or
 *     `node_modules/.bin/abap2ui5lint`) resolvable from the project root, the
 *     nearest folder above the file with a package.json. No project, no
 *     linter, an unreadable payload, a linter that crashes, times out or
 *     prints something this script cannot read: exit 0 without a word. No
 *     `npx`: a download inside a hook would cost every user of a project
 *     without the linter seconds per edit.
 *   - It is fast. The property gate alone takes well under a second for one
 *     class; the render gate (a headless browser) is left to /abap2ui5:check.
 *
 * The project's own `abap2ui5lint.jsonc` applies - the nearest one between
 * the file and the project root is passed with `--config` - so its UI5
 * floor, distribution, rule switches and baseline decide, exactly as in
 * `npm run check:abap2ui5`. The command line sets only what keeps the run
 * small and readable: `--no-render`, `--format json`, `--fail-on never`
 * (the verdict is taken from the findings, not the exit code). Nothing else:
 * an option the installed linter does not know is a fatal usage error, and
 * the projects pin different versions.
 *
 * Feedback goes the documented PostToolUse way: exit code 2 with the report
 * on stderr, which Claude Code shows to the model (the edit has already
 * happened - PostToolUse cannot undo it, only tell). Clean, or only hints:
 * exit 0 and nothing printed.
 *
 * Switched off for one project or machine with the environment variable
 * ABAP2UI5_LINT_HOOK=off (settings.json "env"); README.md says how else.
 *
 * Node 22, no dependencies. Tested by .github/scripts/plugin-hook.test.mjs
 * (npm run test:plugin).
 */
import { spawnSync } from 'node:child_process';
import fs from 'node:fs';
import path from 'node:path';

const MAX_FINDINGS = 15;
const MAX_LINE = 220;
const LINT_TIMEOUT_MS = 25000;

const quiet = () => process.exit(0);

function readStdin() {
  try {
    return fs.readFileSync(0, 'utf8');
  } catch {
    return '';
  }
}

function isFile(p) {
  try {
    return fs.statSync(p).isFile();
  } catch {
    return false;
  }
}

/* The nearest folder at or above `dir` that holds `name`, or null. */
function findUp(dir, name, stopAt = null) {
  let current = dir;
  for (;;) {
    if (isFile(path.join(current, name))) return current;
    if (current === stopAt) return null;
    const parent = path.dirname(current);
    if (parent === current) return null;
    current = parent;
  }
}

/* The linter's CLI script, resolved the way Node resolves a package from the
 * project root (each node_modules on the way up), or null. The script is run
 * with this Node rather than through the .bin shim: on Windows the shim is a
 * .cmd that cannot be spawned without a shell. */
function findLinter(root) {
  let current = root;
  for (;;) {
    const pkgDir = path.join(current, 'node_modules', '@abap2ui5', 'linter');
    try {
      const pkg = JSON.parse(fs.readFileSync(path.join(pkgDir, 'package.json'), 'utf8'));
      const bin = typeof pkg.bin === 'string' ? pkg.bin : pkg.bin?.abap2ui5lint;
      if (bin && isFile(path.join(pkgDir, bin))) return path.join(pkgDir, bin);
    } catch {
      // not here - try the .bin link, then the next folder up
    }
    try {
      const real = fs.realpathSync(path.join(current, 'node_modules', '.bin', 'abap2ui5lint'));
      if (/\.[cm]?js$/.test(real)) return real;
    } catch {
      // no link either
    }
    const parent = path.dirname(current);
    if (parent === current) return null;
    current = parent;
  }
}

function oneLine(text) {
  const line = String(text ?? '').split('\n')[0].trim();
  return line.length > MAX_LINE ? `${line.slice(0, MAX_LINE - 3)}...` : line;
}

function main() {
  if (/^(off|0|false|no)$/i.test(process.env.ABAP2UI5_LINT_HOOK ?? '')) quiet();

  let payload;
  try {
    payload = JSON.parse(readStdin());
  } catch {
    quiet();
  }
  const filePath = payload?.tool_input?.file_path;
  if (typeof filePath !== 'string' || !/\.clas\.abap$/i.test(filePath)) quiet();

  const base = typeof payload.cwd === 'string' ? payload.cwd : process.cwd();
  const file = path.resolve(base, filePath);
  if (!isFile(file)) quiet();

  const root = findUp(path.dirname(file), 'package.json');
  if (!root) quiet();
  const cli = findLinter(root);
  if (!cli) quiet();

  const args = [cli, file, '--no-render', '--format', 'json', '--fail-on', 'never'];
  const configDir = findUp(path.dirname(file), 'abap2ui5lint.jsonc', root);
  if (configDir) args.push('--config', path.join(configDir, 'abap2ui5lint.jsonc'));

  const run = spawnSync(process.execPath, args, {
    cwd: root,
    encoding: 'utf8',
    timeout: LINT_TIMEOUT_MS,
    maxBuffer: 16 * 1024 * 1024,
  });
  if (run.error || run.signal || !run.stdout) quiet();

  let report;
  try {
    report = JSON.parse(run.stdout);
  } catch {
    quiet();
  }

  const shown = path.relative(root, file).split(path.sep).join('/') || file;
  const findings = [];
  for (const result of report?.results ?? []) {
    if (path.resolve(root, String(result.file ?? '')) !== file) continue;
    for (const f of result.findings ?? []) {
      if (f.severity === 'error' || f.severity === 'warning') findings.push(f);
    }
  }
  if (!findings.length) quiet();

  findings.sort((a, b) => (a.severity === b.severity ? (a.line ?? 0) - (b.line ?? 0) : a.severity === 'error' ? -1 : 1));
  const errors = findings.filter((f) => f.severity === 'error').length;
  const warnings = findings.length - errors;

  const out = [
    `abap2UI5 linter (static check) found ${errors} error(s) and ${warnings} warning(s) in ${shown}:`,
  ];
  for (const f of findings.slice(0, MAX_FINDINGS)) {
    const where = f.line ? `${shown}:${f.line}` : shown;
    out.push(`  ${where}  ${f.severity}  ${f.type}  ${oneLine(f.message)}`);
  }
  if (findings.length > MAX_FINDINGS) out.push(`  ... and ${findings.length - MAX_FINDINGS} more`);
  out.push('Fix them now. `npx abap2ui5lint --explain <rule-id>` explains a rule;'
    + ' run /abap2ui5:check for the full gates (abaplint and the render gate).');

  process.stderr.write(`${out.join('\n')}\n`);
  process.exit(2);
}

main();
