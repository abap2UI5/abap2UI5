# CLAUDE.md — AI Assistant Guide for abap2UI5

## Project Overview

abap2UI5 is a framework for building SAP UI5 applications purely in ABAP — no JavaScript, OData, or RAP required. It supports all ABAP releases from NW 7.02 to ABAP Cloud, running in both on-premise and cloud environments.

**Current version:** 1.142.0 (defined in `src/02/z2ui5_if_app.intf.abap`)
**License:** MIT
**Homepage:** https://abap2UI5.org

## Repository Structure

```
abap2UI5/
├── src/                           # ABAP source code (primary codebase)
│   ├── 00/                        # Layer 0: Utilities & Infrastructure
│   │   ├── 01/                    #   AJSON — JSON serialization/deserialization
│   │   ├── 02/                    #   S-RTTI — Runtime type information / reflection
│   │   └── 03/                    #   General utilities (HTTP, logging, messaging)
│   ├── 01/                        # Layer 1: Core Framework Engine
│   │   ├── 01/                    #   Draft service — session/state persistence
│   │   ├── 02/                    #   Core handler, client, action, binding, model services
│   │   └── 03/                    #   Embedded UI5 app resources (JS/XML as ABAP classes)
│   └── 02/                        # Layer 2: Public API
│       ├── z2ui5_if_app.intf.abap          # Main app interface (implement this)
│       ├── z2ui5_if_client.intf.abap       # Client methods for UI interaction
│       ├── z2ui5_if_types.intf.abap        # Shared type definitions
│       ├── z2ui5_if_exit.intf.abap         # Customization exit points
│       ├── z2ui5_cl_http_handler.clas.abap # HTTP entry point
│       ├── z2ui5_cl_xml_view.clas.abap     # Fluent XML view builder (largest file)
│       ├── z2ui5_cl_xml_view_cc.clas.abap  # Custom controls builder
│       ├── z2ui5_cl_app_startup.clas.abap  # Startup app with UI5 version selector
│       └── z2ui5_cl_app_hello_world.clas.abap # Reference example
├── app/                           # UI5 webapp (Fiori frontend)
│   └── webapp/
│       ├── controller/            # JS controllers (App, View1)
│       ├── view/                  # XML views
│       ├── cc/                    # Custom controls (DebugTool, Server.js)
│       ├── model/                 # UI5 data models
│       ├── Component.js           # UI5 component
│       └── manifest.json          # App metadata
├── node/                          # Node.js transpilation & test setup
│   ├── srv/                       # Express.js server + ABAP HTTP handler shim
│   ├── tests/                     # Playwright browser tests
│   ├── setup/                     # Build/transpilation config
│   └── playwright.config.js       # Browser test configuration
├── .github/
│   ├── workflows/                 # 16 CI/CD GitHub Actions workflows
│   ├── abaplint/                  # Additional linter configs per target
│   ├── app2abap/                  # Script to convert app files to ABAP classes
│   └── cleaner-profile.cfj        # ABAP Cleaner formatting profile
├── abaplint.jsonc                 # Main linter configuration (v750 syntax)
├── package.json                   # Node.js dependencies & npm scripts
└── .abapgit.xml                   # abapGit repository configuration
```

## Architecture

### Request/Response Flow

```
HTTP Request → z2ui5_cl_http_handler (factory) → z2ui5_cl_core_handler
  → Parse JSON → Load/Create App → app->main(client) → Build View/Handle Events
  → JSON Response → Browser (UI5 SPA)
```

### Layered Design

- **Layer 0 (`src/00/`)** — Self-contained utility libraries. AJSON handles all JSON work; S-RTTI provides runtime type reflection. These have no dependency on the framework itself. The `noIssues` flag in `abaplint.jsonc` suppresses lint warnings for this layer since it mirrors external projects.
- **Layer 1 (`src/01/`)** — Core engine. Handles HTTP processing, session drafts, event routing, data binding, and model management. Also contains embedded UI5 frontend resources as ABAP string constants.
- **Layer 2 (`src/02/`)** — Public API. The interfaces and classes that application developers use. This is the stable contract.

### Key Design Patterns

- **Factory Pattern:** `z2ui5_cl_http_handler=>factory()` / `factory_cloud()` for on-premise vs. cloud
- **Fluent Builder:** `z2ui5_cl_xml_view=>factory()->shell()->page()->...->stringify()` builds XML views
- **Two-way Data Binding:** `client->_bind_edit(val)` binds ABAP variables to UI controls
- **Event Routing:** `client->_event('EVENT_ID')` registers events; `client->check_on_event('EVENT_ID')` checks them
- **Stateful Sessions:** Draft service persists app state between requests via `check_sticky`

### How Apps Work

Every abap2UI5 app implements `z2ui5_if_app` with a single `main()` method:

```abap
CLASS z2ui5_cl_my_app DEFINITION PUBLIC.
  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.
    DATA name TYPE string.
ENDCLASS.

CLASS z2ui5_cl_my_app IMPLEMENTATION.
  METHOD z2ui5_if_app~main.
    CASE abap_true.
      WHEN client->check_on_init( ).
        " Build and display the view
        client->view_display( z2ui5_cl_xml_view=>factory(
          )->shell( )->page( 'Title'
          )->input( client->_bind_edit( name )
          )->button( text = 'Send' press = client->_event( 'POST' )
          )->stringify( ) ).
      WHEN client->check_on_event( 'POST' ).
        " Handle the event
        client->message_box_display( |Hello { name }| ).
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
```

## Language & Naming Conventions

**Primary language:** ABAP (v750 syntax target, downported to v702 via CI)

### Naming Rules (enforced by abaplint)

| Object Type | Pattern | Example |
|---|---|---|
| Classes | `Z2UI5_CL_*` or `Z2UI5_CX_*` | `z2ui5_cl_core_handler` |
| Interfaces | `Z2UI5_IF_*` | `z2ui5_if_client` |
| Programs/Tables/etc. | `Z*` | — |

### ABAP Style Rules

- **Max method length:** 100 statements (test classes excluded)
- **Max cyclomatic complexity:** 20
- **Max nesting depth:** 5
- No aliases, no external form calls, no DEFINE macros
- No STATICS, no BREAK/BREAK-POINT
- Use class-based exceptions only
- Use `NEW #()` instead of `CREATE OBJECT`
- Use `xsdbool()` for boolean expressions
- Use `line_exists()` instead of READ TABLE checking sy-subrc
- Backtick string literals (`` ` ``) preferred over single quotes for string values
- No Yoda conditions
- Prefer `IS NOT` over `NOT ... IS`
- Prefer `RETURNING` over `EXPORTING` for single outputs
- SQL: use `@` host variable escaping, strict SQL mode

### Allowed Object Types

Only these ABAP object types are permitted: `CLAS`, `DEVC`, `INTF`, `TABL`.

## Build & Development Commands

All commands run from the repository root. Install dependencies first with `npm install`.

| Command | Purpose |
|---|---|
| `npx abaplint` | Run ABAP static analysis (main rules) |
| `npx abaplint .github/abaplint/auto_abaplint_fix.jsonc --fix` | Auto-fix formatting issues |
| `npm run auto_downport` | Downport code to ABAP 7.02 syntax |
| `npm run auto_transpile` | Transpile ABAP to JavaScript |
| `npm run unit` | Run unit tests (requires prior transpile) |
| `npm run express` | Start Express.js dev server on port 3000 |
| `npm run auto_abaplint` | Run abaplint auto-fix profile |
| `npm run auto_app2abap` | Convert `app/` frontend files into ABAP classes |

### Typical validation sequence

```bash
npx abaplint                          # Check for lint errors
npm run auto_downport                 # Downport for 7.02 compat
npm run auto_transpile                # Transpile ABAP → JS
npm run unit                          # Run unit tests
```

## CI/CD Workflows

### Testing Workflows
- **`test_unit.yaml`** — Transpiles ABAP to JS, runs unit tests
- **`test_node.yaml`** — Starts Express server, verifies it responds
- **`test_browser.yaml`** — Playwright end-to-end tests (Chromium, Firefox, WebKit)
- **`test_rename.yaml`** — Validates namespace renaming works

### Compatibility Workflows
- **`ABAP_702.yaml`** — Verifies compatibility with NW 7.02
- **`ABAP_STANDARD.yaml`** — Standard ABAP environment checks
- **`ABAP_CLOUD.yaml`** — ABAP Cloud environment checks
- **`UI5.yaml`** — UI5 framework integration tests

### Automation Workflows
- **`auto_downport.yaml`** — Automatic downporting to 7.02 syntax
- **`auto_transpile.yaml`** — Automatic ABAP-to-JS transpilation
- **`auto_abaplint_fix.yaml`** — Automatic code cleanup
- **`create_app2abap.yaml`** — Converts frontend files to ABAP classes
- **`create_frontend.yaml`** — Generates frontend artifacts

### Verification Workflows
- **`check_app.yaml`** — App integrity checks

### Mirror Workflows
- **`mirror_ajson.yaml`** / **`mirror_srtti.yaml`** — Sync upstream library changes

## Testing

### ABAP Unit Tests
Test classes are embedded alongside source files with the `.testclasses.abap` suffix (about 20 files). They run via the abaplint transpiler in Node.js.

### Browser Tests
Playwright tests live in `node/tests/`. They test the full UI5 app in Chromium, Firefox, and WebKit against the Express dev server at `http://localhost:3000`.

## Key Files to Know

| File | Why It Matters |
|---|---|
| `src/02/z2ui5_if_app.intf.abap` | Main app interface — version constant lives here |
| `src/02/z2ui5_if_client.intf.abap` | All client interaction methods (view, events, binding, navigation) |
| `src/02/z2ui5_cl_xml_view.clas.abap` | Fluent view builder — largest file (~511KB), maps to UI5 controls |
| `src/02/z2ui5_cl_http_handler.clas.abap` | HTTP entry point — factory methods for on-prem and cloud |
| `src/01/02/z2ui5_cl_core_handler.clas.abap` | Central request processor |
| `src/01/02/z2ui5_cl_core_client.clas.abap` | Implements z2ui5_if_client |
| `src/01/02/z2ui5_cl_core_action.clas.abap` | Event/action dispatcher |
| `src/01/02/z2ui5_cl_core_srv_bind.clas.abap` | Data binding engine |
| `src/00/01/z2ui5_cl_ajson.clas.abap` | JSON handling (mirrored from external project) |
| `abaplint.jsonc` | Linter rules — source of truth for code standards |

## Commit Message Style

The project uses a concise, lowercase style. Examples from recent history:

```
Fix endless LOOP (#2105)
fox token range mapping (#2097)
update changelog (#2091)
new release + simplify http handler + delete config method (#2090)
fix void types
update camerapicture with height/width (#2088)
Add SUBRC_OK check to DELETE statement (#2084)
refactoring+abap cleaner (#2076)
```

When following conventional commits: `feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`.

## Important Considerations for AI Assistants

1. **Do not modify `src/00/`** unless explicitly asked. Layer 0 (AJSON, S-RTTI) is mirrored from external projects and synced by automated workflows.

2. **The `z2ui5_cl_xml_view` class is very large** (~511KB). It contains a fluent method for nearly every UI5 control. Read only the sections you need.

3. **Multi-environment compatibility matters.** Code must work across NW 7.02, standard ABAP, and ABAP Cloud. The `downport` rule in abaplint enforces this. Avoid syntax that only exists in newer ABAP releases unless it can be downported.

4. **abaplint is the primary quality gate.** Always validate changes with `npx abaplint` before considering them complete.

5. **Frontend files in `app/` are converted to ABAP classes** in `src/01/03/` via the `auto_app2abap` script. If you modify frontend behavior, the canonical source is `app/webapp/`, not the generated ABAP classes.

6. **The public API is in `src/02/`.** The four interfaces (`z2ui5_if_app`, `z2ui5_if_client`, `z2ui5_if_types`, `z2ui5_if_exit`) form the stable contract. Changes here affect all downstream applications.

7. **String literals use backticks.** The project prefers `` `string` `` over `'string'` for ABAP string values.

8. **No database operations in loops.** The `db_operation_in_loop` rule is enforced.

9. **All ABAP objects use the `Z2UI5_` namespace prefix.** Follow the naming patterns defined in `abaplint.jsonc`.
