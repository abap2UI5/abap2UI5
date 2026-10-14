# Competitive review and plan — October 2026

A snapshot of what the other ways to put a UI5 interface on SAP data do
differently from abap2UI5, measured against the three things that shipped
recently here: the browser playground, the AI tooling (MCP server, Claude
Code plugin, AI Studio / AI Pilot, the agent runtime) and the layout editor.
It ends in a plan. Facts carry their source; anything the research could
not verify against a primary page is marked *(unverified)*. Prices and
version numbers are as of 2026-10-14 and will age.

The companion pages are [When to use abap2UI5](when-to-use.md), which is
the decision for one app, and [governance](governance.md), which is the
decision for an IT department. This page is the decision for the project:
where to spend the next quarters.

## 1. The field

| | What it is | Where the app lives | Runs on | AI | Visual design | Licence |
|---|---|---|---|---|---|---|
| **abap2UI5** 1.148 | UI5 apps as one ABAP class, no frontend artefact | ABAP class, abapGit | NW 7.02 → ABAP Cloud, UI5 1.71 → 2.x | MCP server + Claude Code plugin (sandbox without SAP), AI Studio / AI Pilot in the playground, agent runtime (unreleased) | layout-editor (design time, emits a class), layout-management addon (runtime variants for tables and forms) | MIT |
| **SAP RAP + Fiori elements** with Fiori tools 2607, Joule for Developers | SAP's programming model: CDS, behaviour, OData, annotation-driven UI | Several objects + a Node frontend project, deployed as BSP/MTA | RAP: 7.5x+; Joule / Project Accelerator: BTP ABAP, S/4 Public Cloud, S/4 Private Cloud ≥2021 (RISE). Not classic on-premise | Joule in ADT and BAS (RAP BO + FE app from a prompt, Project Accelerator), official ABAP MCP server in ADT, `@ui5/mcp-server`, `@sap-ux/fiori-mcp-server`, Claude Code + Copilot plugins (`UI5/plugins-coding-agents`), Smart Summarization at runtime in FE V4, `@ui5/webcomponents-ai` | Page Map / Page Editor (annotation and manifest, not freeform), key-user adaptation at runtime, Adaptation Editor in BAS | Platform licence; AI moves to consumption billing (AI Units) from Oct–Dec 2026 |
| **Neptune DXP** 24.15, DXP25 announced 2026-10-02 | Low-code platform; SAP Edition is an ABAP add-on, Open Edition a Node server | Proprietary JSON app definitions in the App Designer, abapGit mapping of packages | SAP Edition: SAP_BASIS 731 SP30+ on-prem; Open Edition: Docker/BTP/cloud, side-by-side for Public Cloud | Naia Build (prompt → components in the designer), Agent Studio, MCP server and "AI Context Hub" (governed AI access to custom SAP logic under the user's authorizations), multi-model BYOK | Drag-and-drop App Designer with XML import/export and versioning | Per user, ~€150/user/year entry *(unverified)*, 30-day trial |
| **Simplifier** 10, MAKERS CHOICE 26-04 | Low-code platform, Scala/JS server, apps exported as OpenUI5 / TypeScript | Platform-internal, exported to the ABAP repository via `/UI5/UI5_REPOSITORY_LOAD` | Own server, on-prem or cloud; SAP via RFC/OData connectors | Agent Builder (LLM per use case), AI test agent that records journeys and writes OPA5 tests, "Miri" migration agent, open-source MCP server for connectors | Web App Editor, visual binding editor | Per user (€7.90–15.90/user/month listed *(unverified)*) |
| **Community ABAP AI** (oisee/vibing-steampunk 499★, mcp-abap-adt ~200★, secondsky/sap-skills 464★, marianfoo/sap-ai-mcp-servers directory) | MCP servers and skills that drive ADT against a live system | ABAP objects in the system | Needs a connected SAP system | ADT CRUD, debugger, transports, abapGit import | none | mostly OSS |

No other maintained "UI5 purely in ABAP, no frontend deployment" project
exists; the only forks are personal. The implicit competitors are SAP's own
model and the two commercial low-code platforms.

A side note that matters for the 1.71 floor: SAP's Fiori newsletter #43
(October 2026) says SAPUI5 2.x delivery is on hold and recommends
legacy-free 1.x code. The old-release compatibility is not a fading asset.

## 2. Where abap2UI5 is ahead

- **Reach without BTP.** Every SAP-native generation path (Joule in ADT,
  Project Accelerator, the ABAP MCP server) needs BTP ABAP, Public Cloud or
  a RISE Private Edition ≥2021. Neptune's SAP Edition needs 7.31 SP30 and is
  side-by-side only on Public Cloud. abap2UI5 and its AI tooling run from
  7.02 to ABAP Cloud, and the MCP sandbox needs no system at all.
- **No system needed to write, run and screenshot an app.** The MCP server
  validates, deploys, builds, runs, unit-tests and screenshots on the
  transpiled Node runtime. Every community ABAP MCP server and SAP's ADT MCP
  server need a live system. Nobody else has this loop.
- **A playground that runs ABAP in the browser.** The SAPUI5 Demo Kit has a
  JavaScript live editor; UI5 Web Components has a hosted playground; there
  is no ABAP-in-the-browser editor anywhere else. Monaco + abaplint +
  the abap2UI5 linter + XML view round trip + share links + abapGit export
  is a stronger onboarding path than any competitor's trial.
- **The layout editor emits code, not metadata.** Neptune stores JSON app
  definitions in its designer; SAP's Page Editor edits annotations and
  manifests of Fiori elements floorplans only; no freeform WYSIWYG for UI5
  XML views exists from SAP. The layout editor's "one class out, no runtime
  of its own, no lock-in" is a category of its own.
- **Code, not configuration.** One class in abapGit, reviewed as a diff,
  transported, debugged, unit-tested with the headless-frontend simulator.
  Both low-code vendors are criticised for lock-in, platform versioning and
  collaboration conflicts in web editors (G2, Capterra).
- **Cost.** MIT, no per-user fee, AI cost is the user's own model. SAP AI
  Units start billing in Q4 2026; both vendors bill per user.
- **Depth of the corpus and the gates.** 700+ samples incl. the full demo
  kit port, a written protocol with conformance suites, a linter with a
  headless render, 49 CI gates, a public API snapshot and a removal plan.
  Neither vendor publishes anything comparable; SAP does, for a much larger
  surface.
- **Agents at runtime, under the user's authorizations.** Neptune's DXP25
  headline, the "AI Context Hub", is the same idea as abap-agent-runtime:
  governed AI access to custom logic, running as the SAP user, with audit.
  The idea is validated by a vendor's launch. Ours is not released.

## 3. Where abap2UI5 is behind

- **Nobody can find the new tooling.** The playground repo has 0 stars and
  the catalogue is the only part linked from the README; AI Studio and AI
  Pilot are unlinked; the layout-editor repo's description is "test" and it
  is linked from nowhere; the agent runtime, the agent snapshot and the VS
  Code system MCP are "development branches, not yet in a release". abap2UI5
  is absent from marianfoo/sap-ai-mcp-servers and secondsky/sap-skills, the
  two directories SAP developers use for AI tooling. The last SAP Community
  post is from January 2024. 385 stars is modest growth over two years.
- **Claude only.** AI Studio needs an Anthropic key; the plugin is Claude
  Code only; the agent runtime's default provider is Anthropic. SAP ships
  Claude Code and Copilot plugins; Neptune and Simplifier are multi-model
  BYOK. Most SAP shops have Copilot, not Claude.
- **No LLM seam in the framework.** `src/` has no AI class; the real-model
  provider interface lives in samples-stack (`z2ui5_if_smps_llm`), the
  `/abap2ui5:add-ai` command points at samples, and the agent runtime has a
  third seam (`z2ui5_if_agent_llm`). Three places for one concept.
- **No runtime key-user adaptation.** Fiori elements apps get "Adapt UI"
  (move, rename, hide fields; public views as defaults since January 2026)
  for free. The layout-management addon covers tables and simple forms as
  variants, 7.50+ only, no authorization checks.
- **What the platforms bundle and we do not.** Workflow engine, native
  mobile with offline sync, connector and API designer, launchpad with
  role administration, marketplace, managed cloud, vendor SLAs. Fiori
  elements adds draft handling, side effects, server-side paging,
  accessibility and Fiori compliance by construction. Most of this is out
  of scope by design and [when-to-use](when-to-use.md) says so; the plan
  below only picks up what fits "one class".
- **Testing from the UI.** Simplifier's AI test agent records a user
  journey and writes OPA5 tests. We have the headless-frontend simulator
  and Playwright in the MCP server, but no recorder that turns a journey
  into an ABAP Unit test.
- **Playground limits.** A few classes, no custom tables, state lost on
  reload, no "run this on my system" hand-off, no persistence beyond the
  URL fragment. The VS Code extension's F9 does the system part, but the
  two are not connected.
- **Layout editor limits.** 7.40+ output only (the framework runs on 7.02),
  OpenUI5 from a CDN, no way to open an existing class from a system or the
  playground, no AI inside the designer (Neptune's Naia Build generates
  sections in place), no Fiori-elements-style starters (list report, object
  page, worklist).
- **Proof on real systems.** The "reported from real systems" table in
  [verified-on](verified-on.md) is empty. A vendor's slide at least has
  logos.
- **The clean-core narrative.** SAP names RAP + Fiori elements as the
  extensibility model; a review board will say abap2UI5 is not SAP's. No
  feature closes this; only references and governance material soften it.

## 4. Plan

Ordered by return on effort. Each phase names what "done" looks like.

### Phase 1 — Ship and name what exists (weeks 1–6)

1. Release the layout editor: a real description, README, a version pinned
   to a framework release, linked from the playground, the docs landing
   page and the README. Decide the name pair now: *layout editor* (design
   time, emits a class) versus *personalization* (runtime variants; rename
   the layout-management addon's documentation accordingly) so the two stop
   sounding like one thing.
2. Link AI Studio and AI Pilot from the playground and the docs, with the
   "your key stays in memory" sentence up front.
3. Cut a release of abap-agent-runtime, the agent snapshot and the VS Code
   system MCP, or mark them experimental in the docs. "Development branch"
   is where ideas go unseen.
4. One "Tooling" page in the docs that lists the whole loop in order:
   playground → layout editor → plugin/MCP → VS Code F9 → linter in CI →
   agent runtime, each with its repo. Today it takes five repos to
   discover.

### Phase 2 — Be found (weeks 2–8, in parallel)

1. Pull requests to marianfoo/sap-ai-mcp-servers and secondsky/sap-skills
   listing the MCP server and the plugin; publish the server to the MCP
   registries that `claude mcp add` and Cursor search.
2. A new SAP Community series, one post per feature: the playground
   ("ABAP in your browser"), the MCP sandbox ("an agent that runs the app
   without a system"), the layout editor ("drag and drop that emits a
   class"), the agent runtime. Submit the same material to UI5con, DSAG
   and TechEd community sessions.
3. Fill the verified-on table: ask on Slack for three systems (one ECC,
   one S/4 on-prem, one Cloud) and record release, UI5 version, date.
4. Add a "compared with" section to [when-to-use](when-to-use.md): the
   same honesty as the RAP table, for Neptune and Simplifier, with the
   costs in both directions.

### Phase 3 — Provider-agnostic AI (weeks 4–12)

1. One LLM seam in the framework: `z2ui5_if_ui5_llm` (or the agent
   runtime's seam promoted into `src/`) with providers for Anthropic,
   OpenAI-compatible endpoints (covers Azure OpenAI, Ollama, SAP AI Core
   through the ABAP AI SDK) and a local rule-based one for 7.02. The
   samples-stack interface and the add-ai command point at it.
2. AI Studio and AI Pilot take an OpenAI-compatible base URL and key next
   to the Anthropic key.
3. A Copilot plugin next to the Claude Code one, the way UI5 ships both,
   and the skills published in the skills format SAP's ai-skills-library
   uses so they load in Cursor, Codex and Copilot unchanged.

### Phase 4 — Layout editor depth (weeks 8–20)

1. Open an existing class: from the playground (same tab), from a GitHub
   URL and, through the VS Code extension, from a system. Round trip is
   what makes a designer a tool rather than a starter.
2. AI in the designer: "describe this section" produces a builder chain
   fragment validated by the linter before it is applied, the Naia Build
   pattern, on the Phase 3 seam.
3. Starters shaped like the floorplans people ask for: list report with
   filter bar, object page with sections, worklist, master-detail. These
   are what Joule generates on the cloud stack; here they run on 7.02.
4. A 7.02 output option and a pinned, self-hosted UI5 for the canvas.
5. Hand-off: "Run in VS Code" and "Deploy to my system" buttons that use
   the extension and the MCP system mode.

### Phase 5 — Runtime: personalization and agents (weeks 12–24)

1. Key-user adaptation for abap2UI5 views: extend the personalization
   addon from tables and forms to any view the builder produced (hide,
   reorder, rename, per user or shared), with an authorization check, and
   7.02 support. This is the gap a Fiori elements user notices first.
2. Release the in-app copilot and generative UI of the agent runtime on
   the Phase 3 seam, and document how Joule Studio and Copilot Studio call
   the MCP endpoint as a tool. That is the abap2UI5 answer to Neptune's AI
   Context Hub, with the apps already in the customer's system.
3. Admin cockpit as the governance proof: usage, p95, agent call log, CSP
   traffic light, one page the review board can look at.

### Phase 6 — Testing and playground persistence (weeks 16–28)

1. A journey recorder: record clicks and inputs in the running app (the
   devtools Recorder already has the roundtrip history) and emit an ABAP
   Unit test on the headless-frontend simulator. Benchmark: Simplifier's
   AI test agent, but the output is a local test class in the same
   abapGit object.
2. Playground persistence (local storage plus gist or GitHub export) and
   a sample-level "open in VS Code" link.

### What not to do

Workflow engines, offline mobile sync, connector designers and a managed
cloud are the platforms' business and would turn one class into a
product. Server-side paging and draft handling stay the app's or RAP's
job. The rap-ext addon is the bridge for the latter.

## 5. Measures

| Signal | Today | Target by 2027-Q2 |
|---|---|---|
| Listed in sap-ai-mcp-servers and sap-skills | no | yes |
| Playground / layout-editor repos linked from README and docs | catalogue only | all |
| LLM providers in AI Studio, plugin and agent runtime | Anthropic | Anthropic, OpenAI-compatible, local |
| Coding-agent plugins | Claude Code | Claude Code, Copilot, skills loadable elsewhere |
| Verified-on reports from real systems | 0 | ≥3 |
| SAP Community posts in the last 12 months | 0 | ≥4 |
| Layout editor opens an existing class | no | yes |
| Runtime personalization scope | tables, simple forms, 7.50+ | any builder view, 7.02+ |

## Sources

Research of 2026-10-14 through search-engine excerpts and GitHub; SAP,
Neptune and Simplifier primary pages were not reachable from the research
environment, so each claim about them should be re-read on the source
before it is quoted externally. Key references:
Neptune DXP25 announcement (neptune-software.com/resources/neptune-dxp25-closing-the-execution-gap),
Neptune docs 24.15 (docs.neptune-software.com), Simplifier release notes
(community.simplifier.io/doc/release-notes), SAP Fiori tools 2607 and
newsletter #43 (community.sap.com), Joule for Developers pricing post
(ba-p/14490003), UI5/mcp-server, UI5/plugins-coding-agents,
SAP/open-ux-tools fiori-mcp-server, marianfoo/sap-ai-mcp-servers,
secondsky/sap-skills, and the abap2UI5, playground, mcp-server,
layout-editor and abap-agent-runtime repositories.
