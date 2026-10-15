# abap2UI5 agent skills

The four skills for building apps **with** abap2UI5, in the open
[Agent Skills](https://agentskills.io/specification) format - the layout the
[`skills` CLI](https://github.com/vercel-labs/skills), SAP's
[ai-skills-library](https://github.com/SAP/ai-skills-library) and every agent
that reads `SKILL.md` expect. Install them into whatever agent you use:

```
npx skills add abap2UI5/abap2UI5
```

(`--list` shows them, `--skill build-an-app` takes one, `-g` installs for the
user rather than the project). Claude Code and GitHub Copilot users take the
[plugin](../plugin/README.md) or the [Copilot plugin](../plugin-copilot/README.md)
instead - same skills, plus the commands, the reviewer agent and the MCP server.

| Skill | What it is |
|---|---|
| `build-an-app` | The checklist for writing an app class - template, lifecycle, view builder, binding, events, popups, navigation, validation. The full guide is its `references/building-apps.md` |
| `view-chain-layout` | The layout rules for a `z2ui5_cl_ui5_view_builder` chain |
| `abap-check` | The ABAP problems a green lint does not catch - abapGit round trip, activation, extended check, downport, runtime |
| `ui5-check` | The UI5 problems a green lint does not catch - names missing from UI5 1.71, version-sensitive layout, views that fail to load, CSP traps |

The skills point at the [MCP server](https://github.com/abap2UI5/mcp-server)
where a tool helps; without a plugin, register it in your agent yourself:
`npx --yes -p @abap2ui5/mcp-server abap2ui5-mcp` over stdio.

## For maintainers - everything but this file is generated

The skill folders are written by `npm run plugin`
(`.github/scripts/generate-plugin.mjs`) from `.claude/skills/` and
`docs/agents/building-apps.md`, and `npm run check:plugin` fails a pull
request whose copy is stale. Edit the source, never the copy. The copies add
`license` and `metadata` to the frontmatter and carry the guide as a
`references/` file, as the specification recommends;
`npm run check:plugin-formats` checks that every frontmatter parses and
follows the specification's name and description rules. "This repository" in
the text means the framework's, abap2UI5/abap2UI5.
