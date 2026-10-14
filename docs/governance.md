# abap2UI5 for IT governance

For the people who approve a tool rather than write apps with it: IT
management, SAP Basis, architecture boards, internal audit. Each section
answers one question such a review asks and links the page that carries the
detail. [When to use abap2UI5](when-to-use.md) is the companion page: where it is
the right tool and where RAP and Fiori Elements are.

## The short version

- **An app is code.** One ABAP class per app. No designer, no generated
  artefacts, no configuration tables that describe a screen.
- **Everything runs inside the SAP system.** No middleware, no extra server,
  no BTP subscription, no separate frontend deployment.
- **Nothing new to govern.** Apps go through the change process you already
  run for ABAP: development system, code review, transport, release. Users
  and authorizations are SAP's.
- **No licence cost, no vendor.** MIT licence, unlimited users. The source is
  in your system, and a build in your own namespace is one workflow run.

## Code first: an app is a class

This is the decision everything below follows from. An abap2UI5 app is one
ABAP class that implements the interface `z2ui5_if_app`. The class builds its
view, holds its state and handles its events. There is no second place where
the app lives:

| | abap2UI5 | A tool that stores apps as configuration |
|---|---|---|
| What an app is | An ABAP class | Entries in the tool's tables, read by its runtime |
| Where a change is made | In the development system, in ADT or SE80 | Wherever the tool's designer is open — possibly production |
| How a change travels | A transport, like any class | The tool's own export, or a customizing transport |
| How a change is reviewed | As a code diff, in abapGit, a pull request or the transport | In the tool's designer, if it shows a history at all |
| What a debugger shows | Your code | The tool's runtime interpreting your configuration |
| What happens if the tool goes away | The classes stay; they are plain ABAP | The apps go with it |

The consequence for governance is that abap2UI5 needs no rule of its own. A
system closed for repository changes is closed for abap2UI5 apps. Every rule
that already applies to ABAP — naming conventions, code review, ATC, the
four-eyes principle on transports — applies to an app without any change.

The price is that someone has to write ABAP. abap2UI5 has no click-together
designer for business users, on purpose: a designer would put a second kind
of app definition next to the code, and that second kind is exactly what the
table above has to govern separately. What makes writing the class fast
instead is a [sample catalogue](https://abap2ui5.github.io/playground/samples/)
of several hundred apps to copy from, a linter that checks a view without an
SAP system, and AI assistants that write the first draft
([Build with AI](../README.md#build-with-ai)).

## Where things run

```
Browser                         SAP system (the only server)
──────────────────────────      ─────────────────────────────────────────────
generic UI5 shell, loaded  ───▶ ICF node → abap2UI5 handler → your app class
once; no app code of its        SAP logon, authorization objects, sy-uname
own                             app state in table Z2UI5_T_01, per user
```

- The browser runs a generic UI5 shell, the same for every app. App code
  never leaves the system; the browser receives the view and the data the
  app chose to bind.
- There is one HTTP endpoint, an ICF node. Nothing else listens.
- UI5 itself is loaded from the public CDN by default; a productive
  installation points it at a UI5 served by the system or by a host it
  controls ([security model](security.md#what-the-operator-has-to-do)).
- Apps run as tiles in the Fiori launchpad, next to RAP and Fiori Elements
  apps, and through BTP where that is the entry point.

## Authorization and audit

- **Authentication is SAP's.** No user store, no token, no session concept of
  its own; a request that reaches an app has passed SAP logon, and
  `sy-uname` is the user.
- **Authorization is two gates.** The outer one is the authorization object
  on the ICF node, as for any service. The inner one is the app: it performs
  its authority checks in its own code, the same way a transaction or a
  report does. The framework adds no central check on purpose; the
  [security model](security.md#what-the-app-has-to-do) has the reasoning.
- **State belongs to its user.** The serialized app state is stored per user
  and refused to anyone else, checked on every read.
- **Every roundtrip can be logged.** The roundtrip monitor
  (`z2ui5_if_ui5_monitor`) receives, for each request, the user, the app,
  the event, the timings and any error. It is off until an installation
  switches it on in the user exit; the
  [admin-cockpit](https://github.com/abap2UI5-addons/admin-cockpit) addon is
  one implementation.
- **Data changes are your code's.** An app posts a document by calling the
  same BAPIs, function modules or RAP actions any other ABAP program calls,
  so change documents, application logs and authority checks behind them
  apply unchanged.

## Change management and upgrades

- **Installation is an abapGit pull** into a package, then transported like
  any other development. There is no app to deploy to a frontend server.
- **An upgrade is a new version of that package**, transported through the
  landscape. Releases are tagged, and the changelog says what changed in
  each one ([changelog.txt](../changelog.txt)).
- **The public API is held stable by a gate.** The interfaces apps use are
  snapshotted; a change to them fails the framework's own pull request.
  Deprecations are announced and tracked until removal
  ([removal plan](removal-plan.md)).
- **Each merge is tested** against Standard ABAP and ABAP Cloud, downported
  and linted against NW 7.02, and run in the browser on the oldest and the
  current supported UI5 release ([verified on](verified-on.md)).

## Operations

What Basis does, all of it:

1. Pull the package with abapGit and activate it.
2. Create the ICF node and put an authorization object on it.
3. Change the four production defaults in the user exit (`z2ui5_if_ui5_exit`):
   UI5 source, error details, the Content Security Policy header, the node
   authorization ([security model](security.md#what-the-operator-has-to-do)).
4. Optionally, switch on the roundtrip monitor.

There is no job to schedule: the app state table cleans itself up on app
start, and its rows live for hours, not years. There is no schema to migrate
on upgrade.

## Clean core

abap2UI5 passes the ABAP Cloud checks and runs in ABAP Cloud, on S/4HANA and
on BTP ABAP, from the same source that runs on NW 7.02. It modifies nothing
in the SAP standard, and every merge is linted against the ABAP Cloud rule
set: released APIs only, no classic statements. It is not SAP's programming
model, though: an organisation whose clean-core
guideline names RAP as the extensibility model has a decision to make, and a
review board will point that out ([when to use](when-to-use.md)).

## Vendor risk

- **Licence:** MIT. No fees per user, per system or per app, now or later.
- **Source:** in your system, in full. Nothing is called at runtime that is
  not in your system, apart from the UI5 library, which you can host
  yourself.
- **Namespace:** a build renamed into your own customer prefix or registered
  namespace is one run of the
  [build-rename](../.github/workflows/build-rename.yaml) workflow.
- **Support:** community support on Slack and GitHub; commercial providers
  are listed in [SUPPORT.md](../SUPPORT.md). Security reports are
  acknowledged within three business days ([SECURITY.md](../SECURITY.md)).
- **Exit:** if the project stopped tomorrow, the installed version keeps
  running, the source stays readable and changeable, and the apps stay
  ordinary classes.

## What it does not do

- **No offline mode.** Every interaction is a roundtrip to the system. Camera,
  barcode scanning and location are available; an offline store is not.
- **No reusable service.** An app is a UI, not an OData service other
  consumers can call.
- **No designer for business users.** See [code first](#code-first-an-app-is-a-class)
  for why.

## How to evaluate it

Take one real screen your team has to build, build it with abap2UI5 in a
development system, and review it the way your organisation reviews ABAP:
read the class, transport it, run ATC on it, check the authorizations it
asks for. Then hold this page against [the security model](security.md) and
[the verified-on page](verified-on.md) with the scepticism you would apply to
any vendor's slide.
