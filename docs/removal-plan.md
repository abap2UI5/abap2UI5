# Removal plan — what is obsolete and what has to happen first

Working checklist for the day the compatibility layer gets cut. Every entry says
what it is, what replaces it, what breaks, and what has to be true before it can
go. Nothing here is urgent; the point is that none of it gets forgotten.

Counts are as of **2026-08-15**, and re-measuring is one command:

```
npm run blockers -- ../samples ../samples-controls ../samples-stack ../app-template
```

`.github/scripts/removal-blockers.mjs` counts the files naming each deprecated
symbol under every checkout you point it at. It is not a CI gate — the sibling
repositories are not checked out here, and making this repository's checks
depend on four others would be worse than a stale number. It exists because the
numbers below were measured by hand, and a hand-measured count is right on the
day it is written: the previous revision of this file said *"samples: 336 of
343 classes use `z2ui5_cl_xml_view`, 0 use the successor"* while `samples` had
already been migrated in full and the true number was 0. A maintainer reading
that would have concluded the migration had not started.

**As of 2026-08-15 every blocker in sections 1 and 2 is at zero** across
`samples`, `samples-controls`, `samples-stack` and `app-template` — 614 classes
use `z2ui5_cl_ui5_view_builder` and none use its predecessor. What is left is
**`docs`**, which is a separate repository and is not scanned here.

**Rule of thumb for the order:** documentation, then samples, then the code. A
removal whose replacement is still undocumented turns every upgrader into a
support case.

---

## 0. Already done (do not re-litigate)

- [x] `ty_s_get-viewname` removed — never filled by the framework. API snapshot
      regenerated, recorded as BREAKING in `changelog.txt`
- [x] `_bind_edit( )` migrated out of the framework apps and the samples
      (236 calls, 90 files); one deliberate holdout, see below
- [x] `nest_view_model_update( )` / `nest2_view_model_update( )` delegate to
      `view_model_update( )`; `check_update_model` dropped from `ty_s_view_nest`
- [x] Removed earlier: `cs_bind_type`, the `XX/` view-model node, view-based
      model filtering, `json_bind_local`, `t_startup_params`, `z2ui5_if_action`
- [x] `cs_event-nav_to_route` removed — a frontend-side second way into a
      navigation the backend owns; `nav_app_call( )` is the navigation and,
      with `set_nav_routing` on, pushes the same route entry. Frontend handler
      and `Router.navToApp( )` deleted with it. Zero usages in the ecosystem
- [x] `cs_event-history_back` removed — a wrapper around `history.back( )`
      predating raw-JS `follow_up_action( )`. Replacement:
      `follow_up_action( |history.back()| )`, or `nav_app_leave( )` for
      navigation inside the app. Frontend handler deleted with it; the only
      caller, samples app 322, moved to the raw-JS form in the same change
- [x] `z2ui5_if_types` retired to `src/99` — every type it held now sits on the
      object that uses it (`ty_s_get` / `ty_s_event_control` / `ty_s_name_value`
      / `ty_t_name_value` / `cs_device` on `z2ui5_if_client`, the three HTTP
      config types on `z2ui5_if_ui5_exit`, `ty_s_draft` on
      `z2ui5_cl_ui5_srv_draft`, `ty_s_config` written out inside `ty_s_get`).
      A rule-5 break on paper — 10 `REMOVED`, 4 `CHANGED`, snapshot 80 to 75 —
      but nothing is deleted and nothing is reshaped: the interface ships
      unchanged from the frozen package, so `z2ui5_if_types=>…` still compiles
      downstream, and every moved type is identical field for field. The
      `- BREAKING:` line is written, under `unreleased` in `changelog.txt`,
      and the release cut carries it under the version heading. The
      ecosystem is already off it: `samples` and `samples-controls` named it
      in 6 classes and name it in none now — `cs_device` moved to
      `z2ui5_if_client`, which the pinned release already carries, and the
      three `ty_t_name_value` uses became a type the sample declares itself,
      which needs no release at all. What still resolves into
      `z2ui5_if_types` is `src/99` itself: `z2ui5_cl_xml_view` (and its test
      class) and `z2ui5_cl_pop_get_range`, frozen code reaching for a frozen
      interface, which is where both of them belong

---

## 1. Public API — `src/02/`

Every entry here is a **rule-5 break**: it needs `node .github/scripts/api-snapshot.mjs --write`,
a `- BREAKING:` line in `changelog.txt`, and a note in the docs
[Deprecations](https://abap2ui5.github.io/docs/resources/deprecations) page.

- [ ] **`z2ui5_if_exit`** — the superseded name of `z2ui5_if_ui5_exit`, kept
      so that no existing exit breaks on the rename. It ships from `src/99` and
      `z2ui5_cl_ui5_user_exit` still looks it up, so a class implementing it is
      found and called exactly as before; its three types are references to the
      new interface's rather than copies, so there is one definition and it
      cannot drift. Before the old name can go: the new one has to be in a
      release, the documentation has to teach it — the examples on the Setup,
      Security, Style/CSS, Bootstrap-Attributes and Logon-Language pages still
      write `z2ui5_if_exit`, and they are compiled against the RELEASE, so they
      can only follow after one — and the deprecation has to have stood long
      enough to be seen. Deleting it is then four things: the second lookup in
      `get_user_exit_class( )`, `gi_user_exit_dep` and the two delegating
      methods in `z2ui5_cl_ui5_user_exit`, and the `/src/99/z2ui5_if_exit.intf.*`
      line that puts this one frozen object into `abaplint.jsonc`'s strict
      ruleset
- [ ] **`_bind_edit( )`** of `z2ui5_if_client` — alias of `_bind`, identical
      behaviour. AGENTS.md puts removal at ~1 year out (from 2026-07).
      - Former blocker resolved: per-direction mapping was dropped —
        `custom_mapper_back` / `custom_filter_back` are still accepted for
        source compatibility but no longer evaluated.
      - No callers left in the ecosystem: zero in `samples`,
        `samples-controls` and `samples-stack` (re-checked 2026-08-21). The
        only in-repo hits are the declaration, the delegating implementation
        and its test.
- [ ] **`view` parameter of `_bind( )` and `_bind_edit( )`** — marked
      obsolete at both declarations. Inert, not passed on internally. Removing it is a signature change, so it rides along with the
      `_bind_edit` removal rather than going separately.
- [ ] **`nest_view_model_update( )` / `nest2_view_model_update( )`** of
      `z2ui5_if_client` — no-ops now (the model push is automatic), and so is
      `view_model_update( )` itself.
      - No callers left: zero across `samples`, `samples-controls` and
        `samples-stack` (re-checked 2026-08-21). The blocker this item used to
        carry is cleared.
- [ ] **`cs_event-nav_container_to`** and the `nest_` / `nest2_` / `popup_` /
      `popover_` variants — in the "obsolet" block of `cs_event`.
      - Removing them also deletes the remap block in
        `z2ui5_cl_ui5_srv_event=>map_client_event` (~20 lines) that rewrites
        them onto `control_by_id` + method `to`.
      - Zero usages in samples and samples-controls (checked, incl. raw literals).
- [ ] **`cs_event-image_editor_popup_close`** — the same "obsolet" block.
      Belongs to `z2ui5_cl_pop_image_editor`; goes when `src/99/02` goes.
- [ ] **`cs_event-wizard_set_next_step`** — marked obsolete in the interface.
      Bundles `discardProgress( oStep )` + `oStep.setNextStep( oNext )` into
      one fixed pair; both methods are on the `CONTROL_METHODS` whitelist, so
      two `control_by_id` calls do the same and additionally reach `goToStep`.
      - Removing it also deletes `evWizardSetNextStep` in
        `app/webapp/core/actions/ViewOps.js` — regenerate `src/01/03/`.
      - Zero usages in samples: the Wizard sample (`samples`
        `z2ui5_cl_smp_app_202`) already drives the flow through `control_by_id`,
        which is the migration example.
- [ ] **`custom_mapper` / `custom_filter` of `_bind( )`** — marked obsolete at
      the declaration. Still evaluated. They hand app code a reference into the **mirrored**
      AJSON library (`src/00/01`, synced from an external project), so an app
      implementing `z2ui5_if_ajson_mapping` / `_filter` binds itself to a type
      this repo does not own.
      - Removing them is a signature change, so they ride along with the
        `_bind_edit` removal above rather than going separately (the same
        parameters exist on `_bind_edit`, plus the already-inert
        `custom_mapper_back` / `custom_filter_back`).
      - Zero usages across samples, samples-controls and samples-stack.
      - Blocker: `z2ui5_if_ajson_mapping` / `z2ui5_if_ajson_filter` reach app
        code only through these four parameters — check for downstream users
        before cutting, there is no declarative equivalent for a *custom*
        transformation (only `omit_initial` / `omit_initial_paths` / `json`).

- [x] `check_sticky` / `check_initialized` of `z2ui5_if_app` removed — the
      state had already moved to `z2ui5_cl_ui5_app_cont`'s `mv_check_sticky` /
      `mv_check_initialized`, and what was left were mirrors an
      `app_compat_mirror( )` kept in sync for readers. Interface, mirror method
      and the two assertions that tested the mirror all went; `id_draft` and
      `id_app` stayed, for the reason below.

> **Not obsolete, do not remove:** `id_draft` and `id_app` of `z2ui5_if_app`
> look like the two above and are not. `id_draft` is the handle
> `z2ui5_cl_ui5_app_cont=>db_load_by_app( )` resolves an app reference by
> (`read_draft( app->id_draft )`), and both are written at moments when no
> wrapper exists yet — an app handed to `nav_app_call( )`, a draft looked up
> before it is parsed. They are public only because an ABAP interface has no
> protected section. The reasoning sits at the declaration.

> **Not obsolete, do not remove:** `cs_event-z2ui5` is the supported entry point
> for app-registered JavaScript (`js_loader`) and currently sits in the
> "legacy event names" block. Move it up to the active actions instead.

---

## 2. `src/99/` — the frozen package (~30,800 ABAP lines)

The single biggest item. All of it is public and shipped, so removal is a
breaking change for any downstream app that still references it.

- [ ] **`z2ui5_cl_xml_view` (15,884 lines) + `z2ui5_cl_xml_view_cc` (742)**
      → `z2ui5_cl_ui5_view_builder` (`src/02/`)
      - **Blocker A: cleared 2026-08-15.** Zero callers across `samples` (150
        classes on the successor), `samples-controls` (431), `samples-stack`
        (32) and `app-template` (1). The last fourteen were
        `samples-controls` `src/03`, the SAPUI5-only collection, migrated in
        the same pass — they were also the only ABAP in that repository no
        view check could read, because nothing can reconstruct this builder.
      - **Blocker B: cleared 2026-08-21.** The 51 pages that taught it have
        been migrated: `abap2UI5/docs` names it on six pages and not one of
        them teaches it — the linter rule `frozen-view-builder`, the
        deprecations table, the changelog, the custom-control link into
        `z2ui5_cl_xml_view_cc`, and two sentences calling it the frozen
        predecessor. That side is also gated now: `check:examples` there
        refuses a `z2ui5_cl_xml_view=>` example unless the page carries the
        migration banner, so the count cannot climb back.
      - This is a project, not a task. Until it is done, nothing else in
        `src/99` can go either, because the package ships as a unit.
      - `factory_plain( )` (`:22`) is obsolete **inside** an already-obsolete
        class and needs no separate entry: it returns a builder with no root
        element at all, so the caller has to open one before anything renders
        — `factory( )` (shell + `sap.m` namespaces) and `factory_popup( )`
        (`FragmentDefinition`) are the two useful entry points, and the
        successor `z2ui5_cl_ui5_view_builder` exposes a single `factory( )`
        on purpose.
        Zero usages in samples, samples-controls and samples-stack. It is
        **not** marked obsolete in the source: `src/99` production code is
        frozen (`check:frozen` / `check_gates.yaml`), and a comment-only
        edit would fail that gate for no gain — the whole class is the entry.
- [ ] **`src/99/01/` — 9 utility classes (11,925 lines) + `z2ui5_cx_util_error`
      + table `Z2UI5_T_91`**
      - **Blocker:** there is no successor API for *app* code. The internal
        replacement (`z2ui5_cl_ui5_util_context`) is framework-only. Decide first
        whether apps get a public utility API, get pointed at
        [abap-util](https://github.com/abap-util/abap-util), or get nothing.
      - docs still uses them on 3 pages (logon language, lock, spreadsheet).
      - Dropping a **table** (`Z2UI5_T_91`) needs an explicit note — data loss.
- [ ] **`src/99/02/` — 18 `z2ui5_cl_pop_*` classes (2,326 lines)**
      → [popups addon](https://github.com/abap2UI5-addons/popups)
      - **Blocker:** verify the addon actually covers all 18. `z2ui5_cl_pop_bal`
        was already dropped in 1.142.0 without a replacement — do not repeat
        that silently.
      - docs uses them on 9 pages; samples in 4 classes.
- [ ] **`src/99/z2ui5_cl_http_handler` (11 lines)** → `z2ui5_cl_ui5_http_handler`
      - An empty subclass that exists so an ICF node pointing at the old
        handler name keeps resolving. AGENTS.md names it deprecated in two
        places; it had no box here, which made `src/99` look like three items
        when it is four.
      - **Blocker: it is the one object here a customer names rather than
        calls.** The class sits in an ICF service definition in a system, not
        in ABAP anybody wrote, so "zero callers in the sample repositories"
        says nothing about it. It goes when the handler rename is announced
        in the docs Deprecations page, not before.

**Falls out automatically when `src/99` goes:**

- [ ] the `FROZEN-ONLY` methods in `z2ui5_cl_ui5_util_context` (`src/00/03/`) — they
      exist solely because the shipped `src/99` still calls them. Grep the
      marker, delete the marked block. (No count here on purpose: this said 23
      while the file carried 25, because a marker is added by whoever needs one
      and nothing tells this page. `grep -c FROZEN-ONLY` is the answer, and it
      is the same command that does the work.)
- [ ] `npm run check:frozen` + the `check_gates` workflow
- [ ] the three `src/99` test skips in `node/setup/abap_transpile.json`
      and the `src/99` testclass/sidecar exemptions in `check:frozen` +
      `check_gates.yaml`
- [ ] the `src/99` exclusions in `abaplint.jsonc`

---

## 3. Frontend (`app/webapp/`)

Rule 7 of AGENTS.md makes the module IDs, properties and events of the custom
controls a public contract, so these break hand-written view XML. Regenerate
`src/01/03/` with `npm run app2abap` — never edit it by hand.

- [ ] **8 invisible custom controls (~613 lines)** — each already carries an
      `// OBSOLETE:` header:

      | File | Replacement |
      |---|---|
      | `cc/Timer.js` (65) | `cs_event-start_timer` |
      | `cc/Focus.js` (154) | `cs_event-set_focus` |
      | `cc/Scrolling.js` (125) | `cs_event-scroll_to` / `scroll_into_view` |
      | `cc/Info.js` (121) | `client->get( )-s_device` / `-s_ui5` |
      | `cc/LPTitle.js` (56) | `cs_event-set_title_launchpad` |
      | `cc/Favicon.js` (36) | `cs_event-set_favicon` |
      | `cc/History.js` (34) | `set_push_state( )` |
      | `cc/Title.js` (22) | `cs_event-set_title` |

- [ ] **`app/webapp/Util.js` (21 lines) + the `z2ui5.Util` global** — alias
      re-exporting `z2ui5/model/formatter`. Named in AGENTS.md rule 7 as a
      public contract, so it needs the same announcement as the controls.
- [ ] **`destroyPopup` / `destroyPopover` / `destroyNestView` /
      `destroyNestView2` / `destroyView`** — in `View1.controller.js`.
      Thin wrappers around `ViewSlots.destroy()`, kept because apps may call
      them from custom JS.
- [ ] **Legacy app-state hash handling in `core/Router.js`** (the note in
      `parse( )`, and the two branches in `sync( )`) — only removable if the pre-routing app-state hash is dropped
      entirely. Check `clipboard_app_state` and `set_app_state_active` first.

> **Cannot go yet:** the `eF('…')` string parser in `core/actions/LegacyCustomJs.js`. It is
> the legacy path only for *framework* follow-up actions (those are JSON since
> #2501) — a WIRED action still emits the code form into view XML
> (`get_event_client( )`, reached through `follow_up_action( )`'s
> `IF result IS SUPPLIED` branch or through its obsolete second name
> `_event_client( )`), so the parser stays until that is JSON too.
>
> **Cannot go yet:** the `z2ui5.*` global facade in `core/AppState.js`. It is a
> documented public contract for apps reaching internals via `js_loader`.

---

## 4. Internal cleanups — no announcement needed

Not part of any public contract; removable whenever.

- [ ] **`follow_up_action( _event( ) )` snippet parsing** — in
      `z2ui5_cl_ui5_action=>prepare_app_stack`. A `SPLIT` on `.eB(['` that
      reverse-engineers the next event out of a legacy JS string.
- [x] **The dynamic slot loops** — `reset_view_update_flags` 20 → 10 lines,
      `check_view_update_needed` 43 → 22. Plain `CLEAR` / `IF` on the statically
      known slots; `cs_view_slot_list` and `cs_model_slot_list` are gone, and
      with them four `ASSIGN COMPONENT` runtime guards that the syntax check
      now covers instead.

---

## 5. What app code still has to reach into internals for

The mirror image of a removal: every one of these is an app doing something
ordinary and finding nothing released to do it with, so it reaches into
`src/00` or `src/01` and the linter's `non-released-api` rule is right to say
so. Found by reading every `non-released-api` finding in `abap2UI5/samples`
rather than by guessing; each entry names the callers that exist today.

- [ ] **Parsing JSON.** An event argument arrives as a JSON string, and there
      is no released way to read it. `z2ui5_cl_ajson` is the mirrored library
      in `src/00/01` — synced from another project, and the same type this
      plan wants to stop handing app code through `custom_mapper` (§1).
      - Callers: `samples` `z2ui5_cl_smp_app_197`, `z2ui5_cl_smp_app_327`
        (both now carry a directive naming this gap).
      - Neither alternative is portable: `/ui2/cl_json` is not released for
        ABAP Cloud, `xco_cp_json` does not exist on 7.02.
- [ ] **A DDIC object to point a dynamic type at.** `src/02` releases no table
      or structure, so a sample demonstrating
      `CREATE DATA … TYPE STANDARD TABLE OF (name)` has to name the framework's
      own draft table `z2ui5_t_01`.
      - Caller: `samples` `z2ui5_cl_smp_app_061`.
      - Cheap to close: one released structure with two fields would do, and
        it costs nothing to keep compatible.

## 6. Documentation debt to clear alongside

- [ ] Move `cs_event-z2ui5` out of the "legacy event names" block (see §1)
- [ ] Turn the two `"obsolete"` plain comments on the `view` parameter into
      `"! @parameter view | …` ABAP Doc — a `"` comment is invisible in ADT
- [ ] 26 frozen classes in `src/99` carry **no** obsolescence marker at all;
      `z2ui5_cl_xml_view`'s ABAP Doc header even reads as the current builder.
      Adding a header needs a one-time exception from `check:frozen`
- [ ] Migrate the 51 docs pages off `z2ui5_cl_xml_view` (after the samples)
- [ ] Keep the docs
      [Deprecations](https://abap2ui5.github.io/docs/resources/deprecations)
      page in step with every box ticked here
