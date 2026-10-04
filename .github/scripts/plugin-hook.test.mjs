#!/usr/bin/env node
/*
 * plugin-hook.test — the Claude Code plugin's PostToolUse hook
 * (plugin/hooks/lint-abap-class.mjs), driven the way Claude Code drives it:
 * a hook payload on stdin, the verdict in the exit code and on stderr.
 *
 * The hook is the one piece of the plugin that runs code on a user's machine
 * on every edit, so what it must NOT do is pinned as hard as what it must:
 * silent exit 0 for a file that is not an ABAP class, for a project without
 * the linter, for a payload it cannot read and when it is switched off - and
 * for a project that has the linter, exit 2 with the finding (rule id,
 * file:line, the pointer at /abap2ui5:check) for a typo'd control, nothing
 * for a clean class, and the project's abap2ui5lint.jsonc honoured.
 *
 * The projects are written into a temporary folder per run. "Has the linter"
 * is this repository's own devDependency @abap2ui5/linter, linked into the
 * fixture's node_modules - the same package an app-template project installs,
 * and no download.
 *
 *   node .github/scripts/plugin-hook.test.mjs     (npm run check:plugin-hook)
 */
import { test, before, after } from 'node:test';
import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..', '..');
const HOOK = path.join(ROOT, 'plugin', 'hooks', 'lint-abap-class.mjs');
const LINTER = path.join(ROOT, 'node_modules', '@abap2ui5', 'linter');

/* A minimal app class building a view with the builder; `control` is the
 * one place the defect goes in. */
const appClass = (name, control = 'Button') => `CLASS ${name} DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.
    DATA name TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS ${name} IMPLEMENTATION.

  METHOD z2ui5_if_app~main.

    IF client->check_on_init( ).
      name = \`World\`.
    ENDIF.

    DATA(view) = z2ui5_cl_ui5_view_builder=>factory(
        )->ele( n  = \`View\`
                ns = \`mvc\`
            )->a( n = \`xmlns\`     v = \`sap.m\`
            )->a( n = \`xmlns:mvc\` v = \`sap.ui.core.mvc\` ).

    view->ele( \`Page\`
        )->a( n = \`title\` v = \`Hello\`
        )->tag( \`Input\`
            )->a( n = \`value\` v = client->_bind( name )
        )->tag( \`${control}\`
            )->a( n = \`text\`  v = \`Send\`
            )->a( n = \`press\` v = client->_event( \`SEND\` ) ).

    client->view_display( view->stringify( ) ).

  ENDMETHOD.

ENDCLASS.
`;

let tmp;

function project(name, { linter = 'package', config = null } = {}) {
  const dir = path.join(tmp, name);
  fs.mkdirSync(path.join(dir, 'src'), { recursive: true });
  fs.writeFileSync(path.join(dir, 'package.json'), '{ "name": "fixture", "private": true }\n');
  if (linter === 'package') {
    fs.mkdirSync(path.join(dir, 'node_modules', '@abap2ui5'), { recursive: true });
    fs.symlinkSync(LINTER, path.join(dir, 'node_modules', '@abap2ui5', 'linter'), 'junction');
  } else if (linter === 'bin') {
    fs.mkdirSync(path.join(dir, 'node_modules', '.bin'), { recursive: true });
    fs.symlinkSync(path.join(LINTER, 'cli.mjs'), path.join(dir, 'node_modules', '.bin', 'abap2ui5lint'));
  }
  if (config) fs.writeFileSync(path.join(dir, 'abap2ui5lint.jsonc'), JSON.stringify(config, null, 2));
  return dir;
}

function write(dir, rel, text) {
  fs.mkdirSync(path.dirname(path.join(dir, rel)), { recursive: true });
  fs.writeFileSync(path.join(dir, rel), text);
}

function hook(payload, env = {}) {
  const input = typeof payload === 'string' ? payload : JSON.stringify(payload);
  const run = spawnSync(process.execPath, [HOOK], {
    input,
    encoding: 'utf8',
    timeout: 60000,
    env: { ...process.env, ABAP2UI5_LINT_HOOK: '', ...env },
  });
  return { code: run.status, stderr: run.stderr, stdout: run.stdout };
}

const edit = (cwd, file, tool = 'Edit') => ({
  session_id: 'test',
  hook_event_name: 'PostToolUse',
  cwd,
  tool_name: tool,
  tool_input: { file_path: file },
  tool_response: { success: true },
});

function assertSilent(r) {
  assert.equal(r.code, 0, `exit code 0 expected, got ${r.code}: ${r.stderr}`);
  assert.equal(r.stderr, '');
  assert.equal(r.stdout, '');
}

before(() => {
  assert.ok(fs.existsSync(path.join(LINTER, 'package.json')),
    '@abap2ui5/linter is not installed here - run npm ci first');
  tmp = fs.mkdtempSync(path.join(os.tmpdir(), 'abap2ui5-plugin-hook-'));
});

after(() => {
  if (tmp) fs.rmSync(tmp, { recursive: true, force: true });
});

test('a file that is not an ABAP class: silent exit 0', () => {
  const dir = project('not-abap');
  write(dir, 'README.md', '# hi\n');
  write(dir, 'src/zcl_app.clas.xml', '<?xml version="1.0"?>\n');
  write(dir, 'src/zcl_app.clas.testclasses.abap', appClass('ltcl_test', 'Buton'));
  assertSilent(hook(edit(dir, 'README.md', 'Write')));
  assertSilent(hook(edit(dir, 'src/zcl_app.clas.xml')));
  assertSilent(hook(edit(dir, 'src/zcl_app.clas.testclasses.abap')));
});

test('an ABAP class in a project without the linter: silent exit 0', () => {
  const dir = project('no-linter', { linter: null });
  write(dir, 'src/zcl_app.clas.abap', appClass('zcl_app', 'Buton'));
  assertSilent(hook(edit(dir, path.join(dir, 'src/zcl_app.clas.abap'))));
});

test('a payload it cannot read, or a file that is gone: silent exit 0', () => {
  const dir = project('garbage');
  assertSilent(hook('not json'));
  assertSilent(hook(''));
  assertSilent(hook({ tool_name: 'Edit', tool_input: {} }));
  assertSilent(hook(edit(dir, 'src/missing.clas.abap')));
});

test('a typo\'d control: exit 2, the finding on stderr with rule id, file:line and /abap2ui5:check', () => {
  const dir = project('defect');
  write(dir, 'src/zcl_app.clas.abap', appClass('zcl_app', 'Buton'));
  const r = hook(edit(dir, 'src/zcl_app.clas.abap', 'MultiEdit'));
  assert.equal(r.code, 2, r.stderr);
  assert.equal(r.stdout, '');
  assert.match(r.stderr, /unknown-control/);
  assert.match(r.stderr, /sap\.m\.Buton/);
  assert.match(r.stderr, /src\/zcl_app\.clas\.abap:\d+\s+error/);
  assert.match(r.stderr, /\/abap2ui5:check/);
  assert.ok(r.stderr.trim().split('\n').length <= 20, `at most 20 lines:\n${r.stderr}`);
});

test('a clean class: silent exit 0', () => {
  const dir = project('clean');
  write(dir, 'src/zcl_app.clas.abap', appClass('zcl_app'));
  assertSilent(hook(edit(dir, 'src/zcl_app.clas.abap', 'Write')));
});

test('the linter found through node_modules/.bin only, from a nested folder', () => {
  const dir = project('bin-only', { linter: 'bin' });
  write(dir, 'src/sub/zcl_app.clas.abap', appClass('zcl_app', 'Buton'));
  const r = hook(edit(path.join(dir, 'src'), 'sub/zcl_app.clas.abap'));
  assert.equal(r.code, 2, r.stderr);
  assert.match(r.stderr, /src\/sub\/zcl_app\.clas\.abap:\d+/);
});

test('the project\'s abap2ui5lint.jsonc decides: its severity is reported, a rule it switches off is not', () => {
  /* The severity first: only the config can turn this error into a warning,
   * so the switched-off case below cannot pass by the config being broken
   * (a config the linter refuses is a usage error, which the hook swallows). */
  const lowered = project('config-warning', { config: { rules: { 'unknown-control': 'warning' } } });
  write(lowered, 'src/zcl_app.clas.abap', appClass('zcl_app', 'Buton'));
  const r = hook(edit(lowered, 'src/zcl_app.clas.abap'));
  assert.equal(r.code, 2, r.stderr);
  assert.match(r.stderr, /0 error\(s\) and 1 warning\(s\)/);
  assert.match(r.stderr, /:\d+\s+warning\s+unknown-control/);

  const off = project('config-off', { config: { rules: { 'unknown-control': false } } });
  write(off, 'src/zcl_app.clas.abap', appClass('zcl_app', 'Buton'));
  assertSilent(hook(edit(off, 'src/zcl_app.clas.abap')));
});

test('switched off with ABAP2UI5_LINT_HOOK=off: silent exit 0 despite the defect', () => {
  const dir = project('off');
  write(dir, 'src/zcl_app.clas.abap', appClass('zcl_app', 'Buton'));
  assertSilent(hook(edit(dir, 'src/zcl_app.clas.abap'), { ABAP2UI5_LINT_HOOK: 'off' }));
});
