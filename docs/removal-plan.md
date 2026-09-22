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

- [x] `ty_s_event_control-check_allow_multi_req` removed. It sent the event
      while another roundtrip was still running and let the responses land in
      any order — but only the newest response may commit, so every earlier
      roundtrip was work whose answer was thrown away. The case it was reached
      for is the per-keystroke wire, and `check_queue_last` serves that one
      strictly better (one roundtrip at a time, order preserved, the backend
      ends on the control's current value). Ecosystem count at removal: **1**
      — samples app 059, the sample demonstrating the flag itself, converted
      to `check_queue_last` in the same change. Position [2] of the event
      array stays reserved and always false so nothing behind it shifts;
      `View1.eB` ignores a truthy value there. API snapshot regenerated,
      recorded as BREAKING in `changelog.txt`
- [x] `ty_s_get-viewname` removed — never filled by the framework. API snapshot
      regenerated, recorded as BREAKING in `changelog.txt`
- [x] `_bind_edit( )` migrated out of the framework apps and the samples
      (236 calls, 90 files); one deliberate holdout, see below
- [x] `nest_view_model_update( )` / `nest2_view_model_update( )` delegate to
      `view_model_update( )`; `check_update_model` dropped from `ty_s_view_nest`
- [x] `cs_event-image_editor_popup_close` removed, with
      `evImageEditorPopupClose` in `app/webapp/core/actions/ViewOps.js` and the
      regenerated `src/01/03/`. This item used to read *"goes when `src/99/02`
      goes"*, and that was the wrong reading: it did not wait on the frozen
      package, it waited on a **missing generic capability**. The handler
      bundled a read (`getImagePngDataURL( )` off the editor in the POPUP
      slot), a teardown and a backend event carrying that value, and only the
      teardown had an equivalent — `CONTROL_BY_ID` calls a method and discards
      its return value, and no `t_arg` expression could reach a control in
      another slot. `$controller.slotValue( )` supplies the read, so the
      button is an ordinary `_event( )` and the popup's own `SAVE` branch
      destroys the slot on the roundtrip, as its `CANCEL` branch always did.
      Ecosystem count at removal: **0**. API snapshot regenerated, recorded as
      BREAKING in `changelog.txt`.
- [x] The five `cs_event-*_nav_container_to` constants removed —
      `nav_container_to` and its `nest` / `nest2` / `popup` / `popover`
      variants. They never reached the frontend as events:
      `z2ui5_cl_ui5_srv_event=>map_client_event` rewrote each one into the
      generic `CONTROL_BY_ID` call with method `to` and the slot the
      constant's name picked, so the removal deletes a `SWITCH` in the
      backend and nothing else. An app writes the call itself and thereby
      reaches every other NavContainer method as well:
      `follow_up_action( val = cs_event-control_by_id t_arg = VALUE #( ( `navCont` ) ( `to` ) ( `page2` ) ) )`,
      with `view = cs_view-popup` / `nested` / `nested2` / `popover` for a
      container in another slot. **One behaviour difference to state when
      migrating the MAIN variant:** `cs_view-main` travels as the EMPTY slot
      where the constant injected the literal `MAIN`; an empty slot resolves
      across every open view (`ViewSlots.resolveById`), so it still finds a
      main-view container and is wider, never narrower. Ecosystem count at
      removal: **0** — no class of `samples` names any of the five, and
      neither `samples-stack` nor `samples-controls` carries one in its
      published `catalogue.json`; `samples` `z2ui5_cl_smp_app_088` already
      drives its NavContainer through `control_by_id` and is the migration
      example. The `srv_event` and `client` tests that pinned the remap pin
      the replacement now, one assertion per slot. API snapshot regenerated,
      recorded as BREAKING in `changelog.txt`
- [x] `cs_event-keyboard_set_mode` removed, with `evKeyboardSetMode` in
      `app/webapp/core/actions/Shortcuts.js` and the regenerated `src/01/03/`.
      It wrote the HTML `inputmode` attribute onto the input's DOM node — the
      wrong layer: UI5 discards that DOM on every re-render, so any later
      render of the field silently dropped the mode, and an app had no way to
      tell. `z2ui5.cc.InputExt` carries `inputmode` as a **bound property**
      instead, written on every rendering, so the mode cannot be lost and no
      action has to be ordered against a render. Ecosystem count at removal:
      **0** — `samples` `z2ui5_cl_smp_app_352`, the one caller, was deleted
      when its statement moved onto the control; `z2ui5_cl_smp_app_516` (the
      inputmode values) and `z2ui5_cl_smp_app_530` (a scan field) are the
      migration examples. API snapshot regenerated, recorded as BREAKING in
      `changelog.txt`. **`abap2UI5/docs` still documents the action** on
      `cookbook/browser_interaction/soft_keyboard` and lists the deleted 352
      in that page's `samples:` frontmatter — that page is the one piece of
      this removal still outstanding, in a repository this checkout does not
      carry
- [x] `cs_event-wizard_set_next_step` removed, with `evWizardSetNextStep` in
      `app/webapp/core/actions/ViewOps.js` and the regenerated `src/01/03/`.
      It bundled `discardProgress( oStep )` + `oStep.setNextStep( oNext )`
      into one fixed pair; both methods are on the `CONTROL_METHODS`
      whitelist, so the same flow is two ordinary `control_by_id` calls —
      which additionally reach `goToStep`, a step the bundled event could not
      express. Ecosystem count at removal: **0** — the Wizard sample
      (`samples` `z2ui5_cl_smp_app_202`) already drives the flow through
      `control_by_id` and is the migration example. API snapshot regenerated,
      recorded as BREAKING in `changelog.txt`
- [x] The obsolete spellings of the URL API removed: the methods
      `set_push_state( )` → `hash_set( )` and `set_app_state_active( )` →
      `app_state_set_active( )`, and the constants `cs_event-set_nav_routing`
      → `cs_event-hash_routing` and `cs_event-clipboard_app_state` →
      `app_state_get_href( )` + `cs_event-clipboard_copy`. The alias
      constants `cs_event-set_push_state` and `cs_event-set_app_state_active`
      went with their methods, so the obsolete run of the family is empty.
      All but the last shared their wire value with the surviving name, so
      nothing moved on the wire and the two delegating method bodies went
      rather than being reimplemented — which is why `hash_set` and
      `app_state_set_active` still carry `SET_PUSH_STATE` /
      `SET_APP_STATE_ACTIVE` as their values, and have to: a draft can hold a
      queued action, so a value is not renamable the way a constant is. The fourth was not a rename: it composed the share link
      in the BROWSER and could only put it on the clipboard, so its handler
      (`evClipboardAppState` in `app/webapp/core/actions/Browser.js`) went
      with it and `src/01/03/` was regenerated. Ecosystem count at removal:
      **0** in code — the samples-controls hits are prose naming the constant
      in an explanation of the bookmark URL. In-repo callers converted: the
      three `cs_event-set_nav_routing` client tests and the two e2e hub apps
      under `node/srv/`. API snapshot regenerated, recorded as BREAKING in
      `changelog.txt`
- [x] `view` parameter of `_bind( )` and `_bind_edit( )` removed. Marked
      obsolete at both declarations and inert for as long as it carried that
      mark — never passed on internally, a leftover from the time each view
      slot owned a model of its own. Ecosystem count at removal: **0** —
      `samples`, `samples-controls` and `samples-stack` never named it in
      their git history; the only in-repo caller was `_bind_edit( )` handing
      it to `_bind( )`. It did not wait for the `_bind_edit` removal it was
      once planned to ride along with: the two signatures are the whole
      change, and a call that names the parameter fails at compile time with
      "delete it" as the entire migration. `cs_view` stays — it is the view
      slot of `follow_up_action( )` and `_event_client( )`, where it selects
      one. API snapshot regenerated, recorded as BREAKING in `changelog.txt`
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
      caller, samples app 322, moved to the raw-JS form in the same change.
      **Superseded by `cs_event-hash_back`** (app-owned hash routing, the
      UI5 onNavBack pattern with an optional fallback hash): with
      `hash_attach_changed` registered, a consumed history step round-trips
      as the registered event, which raw JS could never wire — a REAL back,
      not a composed target, is what makes the router ports 1:1
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
- [x] **The `z2ui5` frontend global** removed (maintainer decision
      2026-09-22), with everything that existed only to reach it:
      - `window.z2ui5` itself — `core/AppState.js` keeps every field in its
        private `state` and no longer mirrors it onto the global through
        accessors. The backend GET page used to write `checkLocal`,
        `ccResourceRoot` and `cccResourceRoot` there; it now passes them as
        component data, which `Component.init` splits off before the rest
        travels to the backend. `requestTimeoutMs` and `search`, which only
        an app could set on the global, are no longer read
      - `cs_event-z2ui5` and its frontend handler (`Z2UI5` in
        `core/actions/ViewOps.js`), which called a function an app had put
        on the global. AGENTS.md rule 5, recorded exception 9
      - `z2ui5_cl_pop_js_loader` (`src/99/02`), the popup that loaded that
        function. A released object deleted outright, not relocated — the
        decision is recorded in AGENTS.md under "Layered Design"
      - `app/webapp/Util.js` and the `z2ui5.Util` / `z2ui5.Formatter`
        globals. The date helpers stay in `z2ui5/model/formatter`, reached
        via `core:require` (UI5 1.74 and later); a formatter string naming
        the global resolves to nothing now
      - the `developerTools` mirror on the global

      All of it `- BREAKING:` under `unreleased` in `changelog.txt`. There is
      no replacement for app-supplied JavaScript on purpose: a need the
      frontend cannot serve is a whitelist entry (AGENTS.md rule 19)

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
- [ ] **`nest_view_model_update( )` / `nest2_view_model_update( )`** of
      `z2ui5_if_client` — no-ops now (the model push is automatic), and so is
      `view_model_update( )` itself.
      - No callers left: zero across `samples`, `samples-controls` and
        `samples-stack` (re-checked 2026-08-21). The blocker this item used to
        carry is cleared.
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
      - **Blocker C: cleared 2026-09-22.** The last consumers anywhere were
        the 17 popup apps in `src/99/02`, frozen code reaching for frozen
        code. They are ported onto `z2ui5_cl_ui5_view_builder` (maintainer
        decision; the narrow `check:frozen` exemption that allowed it is in
        `.github/scripts/frozen-paths-gate.mjs` and goes away with it). A
        grep for `z2ui5_cl_xml_view` across `src/` now finds the class, its
        own test include, and **one prose comment** in
        `z2ui5_cl_ui5_util_context` — no code. **All three blockers are
        clear: this class can be deleted whenever the maintainer wants the
        breaking change.**
      - It is still a project rather than a task in one respect: `src/99`
        ships as a unit, so deleting `z2ui5_cl_xml_view` alone leaves the
        rest of the package behind. What has changed is that nothing
        *technical* holds it any more — only the decision to break
        downstream apps that still name it.
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
      | `cc/History.js` (34) | `hash_set( )` |
      | `cc/Title.js` (22) | `cs_event-set_title` |

- [x] **`app/webapp/Util.js` (21 lines) + the `z2ui5.Util` global** —
      removed with the `z2ui5` global, see §0.
- [ ] **`destroyPopup` / `destroyPopover` / `destroyNestView` /
      `destroyNestView2` / `destroyView`** — in `View1.controller.js`.
      Thin wrappers around `ViewSlots.destroy()`, kept because apps may call
      them from custom JS.
- [ ] **Legacy app-state hash handling in `core/Router.js`** (the note in
      `parse( )`, and the two branches in `sync( )`) — only removable if the pre-routing app-state hash is dropped
      entirely. The two names this entry used to say to check first are
      settled: `cs_event-clipboard_app_state` is gone and
      `set_app_state_active( )` is now only `app_state_set_active( )`. The
      hash itself stays — `app_state_set_active( )` writes it, and
      `app_state_get_href( )` composes the link that restores it.

> **Cannot go yet:** the `eF('…')` string parser in `core/actions/LegacyCustomJs.js`. It is
> the legacy path only for *framework* follow-up actions (those are JSON since
> #2501) — a WIRED action still emits the code form into view XML
> (`get_event_client( )`, reached through `follow_up_action( )`'s
> `IF result IS SUPPLIED` branch or through its obsolete second name
> `_event_client( )`), so the parser stays until that is JSON too.

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

- [x] **Parsing JSON.** An event argument arrives as a JSON string, and there
      is no released way to read it. `z2ui5_cl_ajson` is the mirrored library
      in `src/00/01` — synced from another project, and the same type this
      plan wants to stop handing app code through `custom_mapper` (§1).
      - Neither alternative is portable: `/ui2/cl_json` is not released for
        ABAP Cloud, `xco_cp_json` does not exist on 7.02.
      - `z2ui5_cl_ui5_json` in `src/02` was the answer for two weeks — a
        read-only veneer over the vendored ajson — and was **removed on
        2026-09-14**, before it had shipped in any release (it is in no tag
        up to `1.144.0`, so no installation ever had it and nothing had to be
        migrated). The api-snapshot's six entries went with it; that is the
        one removal from `src/02` rule 5 does not cover, because the contract
        it protects is what downstream installs compile against and this
        never reached one.
      - **Closed without an API instead.** Every app-side caller in the
        ecosystem reads what it needs by hand now and carries no directive and
        no `non-released-api` finding: `samples` `z2ui5_cl_smp_app_197` and
        `_327`; `samples-controls` `_103`, `_109`, `_203`, `_298` and `_307`
        (a flat array of projected controls, walked per object); and
        `samples-stack` `z2ui5_cl_smps_app_489`, which also WRITES its payload
        and therefore escapes on the way out and walks escapes on the way in.
        Outbound JSON is composed as a string in ABAP and bound with
        `json = abap_true`. building-apps.md documents both directions.
      - The one payload that could NOT be read this way was the Shopping Cart's
        (`samples-controls` `z2ui5_cl_smpc_demo_004`): it is nested, two arrays
        of six-field rows. It needs no reader either — the control's `value` is
        bound two-way, so `whole_value_apply` converts the whole object with
        `to_abap( iv_corresponding = abap_true )`. **Nested means bind it, not
        parse it**, and that is the general answer rather than this app's.
      - **Measured late, and that cost a red build.** The removal commit
        counted the two callers in `samples` and stopped there; five classes in
        `samples-controls`, one in `samples-stack` and the whole API written out
        in `app-template`'s `AGENTS.md` were not looked at, and
        `samples-controls` went red the same day (`abaplint`: *Class
        z2ui5_cl_ui5_json not found*) because its `abaplint.jsonc` resolves the
        framework against branch `main`. **Removing anything from `src/02` means
        running the count over every sibling first** — that is what
        `npm run blockers -- ../samples ../samples-controls ../samples-stack ../app-template`
        is for, and a class too young to be in the deprecated list is exactly
        the case a hand-count misses.
- [x] **A DDIC object to point a dynamic type at.** `src/02` releases no table
      or structure, so a sample demonstrating
      `CREATE DATA … TYPE STANDARD TABLE OF (name)` has to name the framework's
      own draft table `z2ui5_t_01`.
      - Caller: `samples` `z2ui5_cl_smp_app_061`.
      - Cheap to close: one released structure with two fields would do, and
        it costs nothing to keep compatible.
      - Closed by `z2ui5_t_02` in `src/02` — a released structure with two
        string fields (`name`, `value`), pinned by `ltcl_test_released_ddic`
        in `z2ui5_cl_ui5_http_handler`'s test include.
      - **Reopened and then withdrawn on 2026-09-22: the structure is gone.**
        Nothing ever named it. Not one sample in the three sample
        repositories, and app 061 — the caller this item was written for —
        went on naming `Z2UI5_T_01`, because what it demonstrates is a type
        computed at runtime and any name the system already has will do. The
        pin tested a structure whose only consumer was the pin.
        The item was a real gap read the wrong way round: a framework does
        not close it by shipping a dictionary object for apps to borrow. It
        is closed by saying whose name belongs there, which
        `docs/agents/building-apps.md` now does, and by the standing rule in
        `AGENTS.md` (*No new dictionary objects*) that keeps the next one from
        being added. The three tables that remain all carry their own reason:
        `z2ui5_t_01` persists drafts, `z2ui5_t_91` backs the frozen
        `z2ui5_cl_util_db`, and neither is an anchor for anybody's type.

## 6. Documentation debt to clear alongside

- [ ] Turn the two `"obsolete"` plain comments on the `view` parameter into
      `"! @parameter view | …` ABAP Doc — a `"` comment is invisible in ADT
- [ ] 26 frozen classes in `src/99` carry **no** obsolescence marker at all;
      `z2ui5_cl_xml_view`'s ABAP Doc header even reads as the current builder.
      Adding a header needs a one-time exception from `check:frozen`
- [ ] Migrate the 51 docs pages off `z2ui5_cl_xml_view` (after the samples)
- [ ] Keep the docs
      [Deprecations](https://abap2ui5.github.io/docs/resources/deprecations)
      page in step with every box ticked here
