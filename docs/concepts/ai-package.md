# From description to class

## What exists

The pieces are there, in five places:

- **The guide** - `docs/agents/building-apps.md`, shipped into the system as
  `z2ui5_cl_ui5_llm=>guide( )` in the version installed, and as the
  `build-an-app` skill.
- **The checks** - abaplint with the framework's rule set, and the abap2UI5
  linter (1.71 names, the house layout, the lifecycle, `missing-accessibility`).
- **Where a model writes** - the playground's AI Studio, the Claude Code and
  Copilot plugins (`plugin/`, `plugin-copilot/`) with the
  [MCP server](https://github.com/abap2UI5/mcp-server), and the language
  model seam `z2ui5_if_ui5_llm` for an app that calls a model itself.
- **Where a model operates** - the four agent tools (`app_list`,
  `app_start`, `app_describe`, `app_act`) in the MCP server and, in the
  system, in the [agent add-on](https://github.com/abap2UI5-addons/abap-agent-runtime).
- **Where it runs before a system** - the playground, which transpiles and
  runs the class in the browser, with the checks in its panel.

What is missing is the one path a team can follow and a review board can
read: a description goes in, a class comes out that has been checked, run
and tested, with a record of each step.

## The first cut

A slash command of the plugin, `/abap2ui5:new-app` grown into the whole
path, and the same steps as a page in the documentation:

1. **Describe** - the screen, the data (a table or CDS view by name, or its
   fields), the events.
2. **Write** - the model writes the class from the guide of the installed
   version (`guide( )` through the MCP server when a system is connected,
   the repository's guide otherwise).
3. **Check** - abaplint and the linter on the class; a finding goes back to
   the model, until there is none or a limit is reached and the finding is
   shown.
4. **Run** - in the playground (`?src=` with the class, the table as a
   playground table) or headless against the system through the agent
   tools: start the app, fire each event once, report what came back.
5. **Test** - an ABAP unit test class for the logic the app has (the
   lifecycle arms, not the view), written and run the same way.
6. **Hand over** - the class, its test class and a short record: the
   description, the checks that ran, what the run showed. The developer
   reads it like a pull request from a colleague; nothing is imported into a
   system without them.

## What it must not become

- **A system the model writes into on its own.** Every step that changes a
  system - activation, a transport - is the developer's. The path ends at a
  class on disk and a record.
- **A second kind of app.** What comes out is the class a developer would
  have written: the same guide, the same checks, nothing that only a model
  can maintain.
- **A claim the checks do not back.** "Checked" means the checks above ran
  and found nothing; it does not mean correct, and the record says which
  checks ran.

## Open questions

- Where does step 4 run for a team without the MCP server connected to a
  system - is the playground enough, or does a headless run of the
  transpiled class belong in the plugin?
- ATC on the generated class: worth a step when a system is connected, or
  left to the transport as for any class?
