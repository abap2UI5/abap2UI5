# abap2UI5 plugin for GitHub Copilot

The [Claude Code plugin](../plugin/README.md), in the format GitHub Copilot
reads. One command in the Copilot CLI:

```
copilot plugin install abap2UI5/abap2UI5:plugin-copilot
```

(or `/plugin install abap2UI5/abap2UI5:plugin-copilot` inside a session).
It brings:

- **Four skills** - `build-an-app` (the checklist for writing an app class,
  with the full app guide next to it as `references/building-apps.md`),
  `view-chain-layout`, `abap-check` and `ui5-check` - the same four the
  Claude Code plugin ships, in the open
  [Agent Skills](https://agentskills.io/specification) format. Copilot loads
  them when they fit and on `/build-an-app` and so on.
- **Five commands** - `/abap2ui5-new-app`, `/abap2ui5-check`,
  `/abap2ui5-add-ai`, `/abap2ui5-find-sample` and `/abap2ui5-explain`, what
  `/abap2ui5:new-app` and the others do in Claude Code (the
  [plugin README](../plugin/README.md) describes each). `commands/` is the
  CLI's copy; `prompts/*.prompt.md` is the same five as VS Code prompt files
  - copy them into a repository's `.github/prompts/` to have them in
  Copilot Chat there.
- **A custom agent, `abap2ui5-reviewer`** - reviews an app class against the
  four skills with read-only tools and reports findings as `file:line`.
  Pick it under `/agent`, or ask for it by name. `agents/` is also what a
  repository's `.github/agents/` takes, for the Copilot coding agent on
  github.com.
- **The [MCP server](https://github.com/abap2UI5/mcp-server)** - sample
  search, view validation and fix, deploy, headless run and screenshot, no
  SAP system needed. `.mcp.json` registers it as `abap2ui5` over stdio
  (`npx --yes -p @abap2ui5/mcp-server abap2ui5-mcp`, so Node 22 and npm on
  the PATH; the first start downloads it). The commands and the agent name
  its tools as `abap2ui5/<tool>`. The same file, copied to a repository's
  `.github/mcp.json`, gives the server to everybody who works there.

Without the plugin, the skills alone: `npx skills add abap2UI5/abap2UI5`
(see [`skills/README.md`](../skills/README.md)), then the MCP server by
hand with `copilot mcp add abap2ui5 -- npx --yes -p @abap2ui5/mcp-server abap2ui5-mcp`.

No lint-on-edit hook: that one is Claude Code's PostToolUse contract. In an
app-template project `npm run check` runs the same linter.

The full setup, including the other assistants, is
[Developing with AI](https://abap2ui5.github.io/docs/get_started/ai.html).

## For maintainers - everything but this file is generated

Every other file in this folder is written by `npm run plugin`
(`.github/scripts/generate-plugin.mjs`) and gated by `npm run check:plugin`:
`skills/` from `.claude/skills/` and `docs/agents/building-apps.md`,
`plugin.json` and `.mcp.json` from `plugin/.claude-plugin/plugin.json`,
`agents/abap2ui5-reviewer.agent.md` from `plugin/agents/abap2ui5-reviewer.md`,
`commands/` and `prompts/` from `plugin/commands/`. Edit the source, never the
copy. The translation (Claude Code tool names to Copilot aliases, the MCP tool
names, `/abap2ui5:<cmd>` to `/abap2ui5-<cmd>`, `$ARGUMENTS`, the sentences
naming `${CLAUDE_PLUGIN_ROOT}`) is declared in the generator, and a Claude-only
token it cannot translate fails the run - so a new command is written once, in
`plugin/commands/`, and this folder follows. `npm run check:plugin-formats`
parses the result the way Copilot and the Agent Skills specification read it.
