---
description: Search the three abap2UI5 sample catalogues (samples, samples-controls, samples-stack) and show the best three matches with class, what it shows and a link.
argument-hint: <what you are looking for, e.g. "value help f4" or "sap.m.Wizard">
allowed-tools: Read, WebFetch, mcp__plugin_abap2ui5_abap2ui5__examples, mcp__plugin_abap2ui5_abap2ui5__read_example, mcp__plugin_abap2ui5_abap2ui5__capabilities
---

Find abap2UI5 samples for: **$ARGUMENTS**

If that is empty, ask what to look for and stop.

The three catalogues:

| Repository | Holds |
|---|---|
| `abap2UI5/samples` | curated apps, by pattern - value help, navigation, trees, tables, popups |
| `abap2UI5/samples-controls` | the UI5 demo kit rebuilt with abap2UI5, one port per control sample |
| `abap2UI5/samples-stack` | apps that need more than abap2UI5 - OData, RAP, APC/WebSockets, the launchpad |

## Search

- **MCP server available**: `examples { query: "..." }` - every word of a
  query has to match, so one or two words each - then again with synonyms
  or the UI5 control name; `repo: "samples-controls"` when the
  request names a control. If nothing fits a control question,
  `capabilities` says whether abap2UI5 can express it at all.
- **Without MCP**: fetch https://abap2ui5.github.io/playground/samples/apps.json
  (every sample of the three catalogues, with title, summary and keywords).
  If that host is unreachable, fetch `catalogue.json` from
  `https://raw.githubusercontent.com/abap2UI5/<repo>/main/catalogue.json`
  for each of the three repositories (`samples` and `samples-stack` list
  entries under `samples`, `samples-controls` under `ports`).

Match on title, summary, keywords and control name; prefer `samples` for a
pattern, `samples-controls` for a control (status `checked` over `reviewed`
over `generated`), and `samples-stack` only for a question about OData, RAP,
APC or the launchpad.

## Answer

The best three, each as:

- **`CLASS_NAME`** (repository) - what it shows, in one sentence; what it
  needs from the system when that is more than abap2UI5.
  Source: `https://github.com/abap2UI5/<repo>/blob/main/<file>`; running
  version: `https://abap2ui5.github.io/playground/samples/<class in lower case>/`
  only when you fetched `apps.json` and it lists the class - the MCP
  `examples` entries do not say, so leave the line out rather than writing
  that it is not listed.

Then one line on which to read first and why. Fewer than three good matches:
show what there is and say so - never pad with weak hits, never invent a
class name. `read_example { class }` (or the GitHub link) opens the source
when the user wants it.
