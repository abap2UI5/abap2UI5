# When to use abap2UI5, and when not

abap2UI5 is one way to put a UI5 interface on ABAP. RAP with Fiori Elements
is another, freestyle UI5 with OData a third, and all three run side by side
in the same launchpad; the commercial low-code platforms are a fourth, compared
further down. This page is the honest version of the decision:
where abap2UI5 is the shorter path, where it is the wrong tool, and what it
costs either way. It is written so that a team can disagree with a specific
line rather than with a feeling.

## The one-sentence difference

With RAP and Fiori Elements you describe a data model and a service, and the
UI is derived from annotations. With abap2UI5 you write the UI in ABAP — one
class, a view built in code, state that simply survives between requests —
and there is no service, no frontend project and no deployment. The first
scales with how standard your app is. The second scales with how much of the
UI is yours.

With abap2UI5 the app is code, not configuration: a class that is reviewed,
transported and debugged like every other one.
[abap2UI5 for IT governance](governance.md) is the same decision written for
the people who approve a tool rather than build with it.

## Use abap2UI5 when

- **The team is ABAP.** No JavaScript, no UI5 tooling, no Business
  Application Studio set up. An app is one class in the system, written,
  debugged, transported and unit-tested like every other class.
- **The system is older than RAP.** NW 7.02 to 7.4x have no RAP, no CDS
  worth the name, and a Fiori stack that is expensive to add. abap2UI5 runs
  there from the same source it runs on ABAP Cloud, which also means the app
  written on 7.31 today moves to S/4HANA unchanged.
- **The screen is yours, not SAP's.** Tools, cockpits, monitors, admin
  consoles, selection screens with a result list, anything that used to be a
  report with an ALV or a module pool. Fiori Elements covers the standard
  floorplans; the moment a screen is a dashboard with a map and a chart and
  a custom form, the template becomes the thing you fight.
- **There is no deployment pipeline, and you do not want one.** No BSP
  upload, no approuter, no MTA. The frontend is served by the ABAP system
  itself; an abapGit pull is the installation.
- **An AI assistant writes the first draft.** One file, one interface, 770
  samples to learn from and a linter that needs no SAP system — an app is
  the kind of thing a model gets right in one pass, and the
  [MCP server](https://github.com/abap2UI5/mcp-server) lets it validate,
  run and screenshot the result before anyone installs it.
- **You replace SAP GUI screens one at a time.** The
  [sapgui](https://github.com/abap2UI5-addons/sapgui) and
  [abap-cloud-gui](https://github.com/abap2UI5-addons/abap-cloud-gui) addons
  are the demonstration: selection screens, lists and transactions as
  browser apps, without rewriting the logic behind them.

## Use RAP and Fiori Elements when

- **The service is the product.** Other consumers — a mobile app, an
  integration, SAP's own apps — need the OData service anyway. RAP gives
  you the service and the UI from one model; abap2UI5 gives you a UI and no
  service.
- **The screen is a standard floorplan and should stay one.** List report,
  object page, worklist, with SAP's draft handling, side effects and
  flexible column layout as SAP ships and maintains them. Fiori Elements
  will track every UI5 release for you; a hand-built screen is yours to
  keep current.
- **The data is large and lives behind paging.** Fiori Elements pages,
  sorts and filters through OData on the server. In abap2UI5 the table a
  view binds travels in the model; tables of thousands of rows are routine,
  tables of millions are the app's job to page, and a
  [benchmark](../node/tests-examples/) exists for what one table of n rows
  costs a roundtrip.
- **Offline, or a native mobile SDK, is a requirement.** abap2UI5 is a
  stateful round trip to the ABAP system; it has a
  [mobile shell](https://github.com/abap2UI5/mobile-shell) for device
  features, not an offline store.
- **The organisation has standardised on it.** A clean-core guideline that
  names RAP as the extensibility model is a decision already taken. abap2UI5
  passes the cloud checks and runs in ABAP Cloud, but it is not SAP's
  programming model, and a review board will say so.

## What it costs either way

| | abap2UI5 | RAP + Fiori Elements |
|---|---|---|
| Skills | ABAP, and a reading knowledge of the UI5 control API | ABAP, CDS, RAP, annotations, and someone who can debug the Fiori Elements template when it does something the annotation did not say |
| First screen | One class, minutes | Data model, behaviour definition, service definition and binding, Fiori project, deploy — a day when everything is set up |
| Custom UI | Any UI5 control, 1:1, from ABAP | Extension points; past them, a freestyle UI5 project |
| Upgrade | The framework is a transport; the public API is snapshotted and deprecations are tracked ([removal plan](removal-plan.md)) | SAP's; the template follows the UI5 release |
| Where the logic runs | In the app class, every roundtrip | In the behaviour implementation, through the service |
| Reuse by other consumers | None — there is no service | The OData service, by anything |
| Runs on | NW 7.02 → ABAP Cloud, UI5 1.71 → 2.x | 7.5x+ for RAP, ABAP Cloud for the full model |
| Licence | MIT, no per-user cost | Part of the platform licence |

## Compared with the low-code platforms

Two commercial platforms also put a UI on SAP data without a frontend
project: [Neptune DXP](https://www.neptune-software.com) and
[Simplifier](https://www.simplifier.io). They are a different trade from RAP:
not SAP's programming model against a framework, but a platform — designer,
connectors, workflow, mobile, licence — against one class. Same honesty as
the table above: where each is the shorter path, and what it costs. The
facts are the vendors' own pages as of October 2026, summarised in the
[competitive review](competitive-review-2026-10.md); versions and prices
age, so re-read the source before quoting one.

| | abap2UI5 | Neptune DXP | Simplifier |
|---|---|---|---|
| What the app is | One ABAP class in abapGit; the view is code | A JSON app definition built in the App Designer, mapped to abapGit packages | A platform-internal app, exported as OpenUI5 / TypeScript |
| Where it runs | Inside the ABAP system, NW 7.02 → ABAP Cloud, UI5 1.71 → 2.x | SAP Edition: an ABAP add-on, SAP_BASIS 731 SP30 or later, on-premise. Open Edition: a Node server next to the system (Docker, BTP, cloud), the side-by-side path for Public Cloud | Its own Scala/JS server, on-premise or cloud; reaches SAP through RFC, OData and REST connectors |
| How the app reaches the system | abapGit pull — the frontend is served by the system itself | SAP Edition: installed with the add-on. Open Edition: deployed to the Neptune server | Exported and loaded into the ABAP repository through `/UI5/UI5_REPOSITORY_LOAD`, or served by the Simplifier server |
| Who builds it | An ABAP developer, in ADT or SE80 | A low-code developer in the drag-and-drop designer; ABAP for the server classes | A low-code developer in the Web App Editor and the visual binding editor; connectors configured, not coded |
| Change management | The ABAP transport and review process you have; diffs, unit tests, debugger | The designer's versioning; packages mapped to abapGit | The platform's versioning and export; the ABAP side holds a generated artefact |
| AI | MCP server and coding-agent plugins (Claude Code, Copilot, skills for other agents); validates, runs and screenshots without a system; your own model and key | Naia Build (prompt to components in the designer), Agent Studio, MCP server, AI Context Hub; several models, your own key | Agent Builder (one LLM per use case), an AI test agent that records a journey and writes OPA5 tests, a migration agent, an MCP server for the connectors |
| Mobile and offline | Browser, plus a [mobile shell](https://github.com/abap2UI5/mobile-shell) for device features; no offline store | Native mobile builds with offline synchronisation | Browser; mobile and offline not covered by the review |
| Workflow engine | None — out of scope by design | Built in | Part of the platform; not re-verified by the review |
| Beyond the UI | What the samples show: OData calls, launchpad, APC — the app's job | Launchpad with role administration, connector and API designer, marketplace, managed cloud | Connector layer (RFC, OData, REST) and the server that hosts it |
| Licence | MIT, no per-user cost | Per user, vendor list; a trial exists | Per user, vendor list |
| Exit path | The class stays an ABAP class; the framework is a transport you can read | The app definitions are the platform's; a different runtime means a rebuild | The exported OpenUI5 code runs without the platform; the connectors and the editor do not |

**Neptune DXP is the shorter path when** the team is not ABAP developers and
should build in a designer; when native mobile with offline is a requirement,
not a wish; when workflow, launchpad administration and API management should
come from one vendor with a support contract; and when the SAP Edition's floor
(7.31 SP30 on-premise) is met, or the Open Edition's extra server is
acceptable.

**Simplifier is the shorter path when** the UI spans several backends and the
connector layer is the point; when a central server outside the ABAP stack is
wanted or already there; when recorded UI tests (OPA5 from a journey) matter
to the team; and when the generated OpenUI5 code being the deliverable is a
feature rather than a cost.

**abap2UI5 is the shorter path when** the team is ABAP and the screen is a
tool, cockpit or replaced GUI transaction; when the system is older than the
platforms' floors or should carry no add-on and no second server; when an app
has to be a reviewable diff, a transport and a debuggable class; and when the
per-user licence of a platform is the cost that does not fit a handful of
internal tools.

What it costs either way: a platform buys the designer, the connectors and
the roadmap at the price of a per-user licence, a runtime of its own and app
definitions that live in that runtime; abap2UI5 buys one class and no licence
at the price of writing the UI as code, bringing your own workflow, offline
and administration, and a framework maintained by a community rather than a
vendor. The [governance page](governance.md) is the same comparison for the
people who sign the licence.

## Both, in one launchpad

The common answer is not either. Standard transactional screens as Fiori
Elements, the tools and cockpits around them as abap2UI5, both as tiles in
the same launchpad, with cross-app navigation between them — the
[samples-stack](https://github.com/abap2UI5/samples-stack) repository shows
the launchpad integration, the OData calls from an abap2UI5 app, and the
RAP artefacts displayed in one. The
[rap-ext](https://github.com/abap2UI5-addons/rap-ext) addon goes the other
way and renders RAP floorplans with abap2UI5 where a system has the RAP
model but not the Fiori stack.

## A fair test

Take one real screen your team has to build this quarter. Build it both
ways, with the people who will maintain it. Count the files, the systems and
tools involved, and the time until a user can click it. Then read the
[security model](security.md) and the [verified-on page](verified-on.md)
with the same scepticism you would apply to a vendor's slide, and decide
from the two screens. That is the comparison this page can only describe.
