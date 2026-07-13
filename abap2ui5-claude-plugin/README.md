# abap2UI5 App Builder — Claude Code plugin

A portable [Claude Code](https://claude.com/claude-code) plugin that helps you
build [abap2UI5](https://abap2ui5.org) applications in **pure ABAP** — UI5 apps
with no JavaScript, OData or RAP. It ships one skill, `abap2ui5-app`, backed by a
control catalog, recipe book and example index mined from the 350+ official
samples.

## What it does
When you ask Claude Code to "build an abap2UI5 app with a table", "add a popover",
"scaffold a UI5 form in ABAP", etc., the skill activates and walks the build:
1. Clarify the app (class name, package, on-prem vs cloud).
2. Find the closest worked example in the official samples and adapt it.
3. Pick the right structure (small app in `main( )` vs dispatcher + methods).
4. Write the `z2ui5_if_app` class with correct views, binding and events.
5. Wire the HTTP/ICF entry point (first app only) and run it.
6. Validate (abaplint if configured) and verify two-way bindings round-trip.

## Install

This repo is a plugin **marketplace**. In Claude Code:

```
/plugin marketplace add abap2UI5/abap2UI5     # or your fork / git URL
/plugin install abap2ui5-app@abap2ui5
```

Or load it for a single session without installing:

```
claude --plugin-dir /path/to/abap2ui5-claude-plugin
```

Once installed the skill is available as `/abap2ui5-app:abap2ui5-app` and is
auto-suggested when your request matches.

## Contents
```
.claude-plugin/
  plugin.json            # plugin manifest
  marketplace.json       # marketplace listing (this repo)
skills/abap2ui5-app/
  SKILL.md               # the workflow
  reference/
    setup.md             # install framework + ICF/HTTP wiring + run
    examples-index.md    # which official demo shows which feature
    controls.md          # ranked fluent control + client API catalog
    recipes.md           # patterns: tables, popups, nav, binding, events, files
    conventions.md       # abap2UI5 essentials + ABAP style flavors
  templates/
    app_simple.clas.abap     # small app, everything in main( )
    app_canonical.clas.abap  # larger app, dispatcher + methods
```

## License
MIT. abap2UI5 is an independent open-source project — see
<https://github.com/abap2UI5/abap2UI5>.
