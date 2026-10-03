# abap2UI5 plugin for Claude Code

What an agent needs to build apps **with** abap2UI5, installable in two
commands:

```
/plugin marketplace add abap2UI5/abap2UI5
/plugin install abap2ui5@abap2ui5
```

It brings:

- **Four skills** - `build-an-app` (the checklist for writing an app class,
  with the full app guide next to it), `view-chain-layout` (the layout rules
  for a `z2ui5_cl_ui5_view_builder` chain), `abap-check` and `ui5-check` (the
  ABAP and UI5 problems a green lint does not catch). Claude Code lists them
  as `abap2ui5:build-an-app` and so on.
- **Five slash commands** -
  - `/abap2ui5:new-app <what it should do>` - checks the sample catalogues,
    writes one class implementing `z2ui5_if_app` plus its `.clas.xml`,
    validates it, looks at a screenshot of the view, iterates, and ends
    with the gates;
  - `/abap2ui5:check [path]` - abaplint and the abap2UI5 linter over the
    changed classes (`npm run check` in an app-template project), every
    finding explained, the mechanical ones fixed;
  - `/abap2ui5:add-ai [chat | summarize] <app class>` - adds a chat or a
    summarize-this-data panel to an existing app, the way the samples
    `Z2UI5_CL_SMP_APP_540` / `541` (local provider) and samples-stack
    package 10 (`Z2UI5_CL_SMPS_APP_014` / `015`, a real model) do it: a
    provider interface with a local stub first, so it runs on every system;
    the answer in a second roundtrip behind a busy state; the data sent
    capped and cleaned; then the switch to the samples-stack LLM classes,
    with endpoint and key in a destination or the settings table, never in
    the code;
  - `/abap2ui5:find-sample <topic>` - the best three matches across the
    three sample catalogues, with class, what it shows and a link;
  - `/abap2ui5:explain <class>` - lifecycle, events, bindings and the view
    tree of an app class, for a developer new to abap2UI5.

  Each works with the MCP server and without it (then through
  `npx @abap2ui5/linter` and the catalogue at
  <https://abap2ui5.github.io/playground/samples/apps.json>).
- **A subagent, `abap2ui5-reviewer`** - reviews an app class against the
  four skills (names missing from UI5 1.71, binding rules, roundtrip and
  state pitfalls, chain layout, abapGit sidecar format) with read-only
  tools and reports findings as `file:line`. Ask for it by name ("have the
  abap2ui5-reviewer look at zcl_my_app") or pick it under `/agents`.
- **A lint-on-edit hook** - after the agent edits or writes a `*.clas.abap`
  file, the abap2UI5 linter's static check (the property gate, no headless
  browser - well under a second) runs on that file, and its errors and
  warnings go straight back to the agent, rule id and `file:line`, so it
  fixes a typo'd control or a property UI5 1.71 does not have in the next
  step. The project's `abap2ui5lint.jsonc` applies. It only runs where the
  project already has the linter installed - `@abap2ui5/linter` in
  `node_modules` above the file, as in an app-template project - and is
  silent everywhere else: no download, no message, no delay. To switch it
  off, set `"env": { "ABAP2UI5_LINT_HOOK": "off" }` in `.claude/settings.json`
  (one project) or `~/.claude/settings.json` (everywhere); `"disableAllHooks":
  true` turns off every hook, `/plugin` disables the whole plugin.
- **The [MCP server](https://github.com/abap2UI5/mcp-server)** - search the
  sample catalogues, validate and fix a view, deploy, run headless and take a
  screenshot, no SAP system needed. It starts through
  `npx --yes -p @abap2ui5/mcp-server abap2ui5-mcp`, so it needs Node 22 and
  npm on the PATH; the first start downloads it. Claude Code names it
  `plugin:abap2ui5:abap2ui5`, so a copy registered earlier with
  `claude mcp add abap2ui5` does not clash - but the agent then sees every
  tool twice; `claude mcp remove abap2ui5` drops the old one. The same goes
  for a project's own `.mcp.json` that registers the server - app-template
  ships one, and `npm create abap2ui5-app -- --agent-setup` writes one: in
  such a project either keep the plugin's server and decline the project's
  when Claude Code asks, or use the project's and disable the plugin there.

The plugin carries no version number of its own, so every commit here is a
new version. To pick one up: `claude plugin marketplace update abap2ui5`,
then `claude plugin update abap2ui5@abap2ui5`. A marketplace outside
Anthropic's own does not update by itself unless you switch auto-update on
for it under `/plugin` - Marketplaces.

The full setup, including the other assistants, is
[Developing with AI](https://abap2ui5.github.io/docs/get_started/ai.html).

## For maintainers - most of this folder is generated

`skills/` and `docs/agents/building-apps.md` are **copies**, written by
`npm run plugin` (`.github/scripts/generate-plugin.mjs`) from
`.claude/skills/` and `docs/agents/building-apps.md`, and
`npm run check:plugin` fails a pull request whose copy is stale. Edit the
source, never the copy, and run `npm run plugin`. Written by hand:
`.claude-plugin/plugin.json`, this README, `commands/*.md`,
`agents/abap2ui5-reviewer.md` and `hooks/` (`hooks.json` and the Node
script it runs, no dependencies) - each one is named in the generator's
`HAND_WRITTEN` set, and any other file under `plugin/` fails the check, so a
new command, agent or hook script is added there too. The hook script is
tested with hook payloads by `.github/scripts/plugin-hook.test.mjs`
(`npm run check:plugin-hook`, part of `npm run gates` and `check_gates.yaml`). The commands reach the MCP tools as
`mcp__plugin_abap2ui5_abap2ui5__<tool>`, the name Claude Code gives a tool of
a plugin's own server; `claude plugin validate ./plugin` checks the lot.

The plugin is a folder of its own rather than the repository root because
Claude Code runs the package install of a plugin whose root has a
`package.json` and a lockfile, and the root of this repository would have
cost every user the framework's whole toolchain; the generator's header has
the measurement.
