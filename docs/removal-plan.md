# Removal plan — what is obsolete and what has to happen first

Working checklist for the day the compatibility layer gets cut. Every entry says
what it is, what replaces it, what breaks, and what has to be true before it can
go. Nothing here is urgent; the point is that none of it gets forgotten.

Counts are as of 2026-08-04 and worth re-measuring before acting.

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

---

## 1. Public API — `src/02/`

Every entry here is a **rule-5 break**: it needs `node .github/scripts/api-snapshot.mjs --write`,
a `- BREAKING:` line in `changelog.txt`, and a note in the docs
[Deprecations](https://abap2ui5.github.io/docs/resources/deprecations) page.

- [ ] **`_bind_edit( )`** — `z2ui5_if_client.intf.abap:354`. Alias of `_bind`,
      both two-way. AGENTS.md puts removal at ~1 year out (from 2026-07).
      - Former blocker resolved: per-direction mapping was dropped —
        `custom_mapper_back` / `custom_filter_back` are still accepted for
        source compatibility but no longer evaluated.
      - Last caller in the ecosystem: `samples z2ui5_cl_demo_app_153` — check
        it still makes sense without the asymmetric mapper before removal.
- [ ] **`view` parameter of `_bind( )` and `_bind_edit( )`** —
      `z2ui5_if_client.intf.abap:339` and `:359`. Inert, not passed on
      internally. Removing it is a signature change, so it rides along with the
      `_bind_edit` removal rather than going separately.
- [ ] **`nest_view_model_update( )` / `nest2_view_model_update( )`** —
      `z2ui5_if_client.intf.abap:172`, `:184`. No-ops now (the model push is
      automatic).
      - Callers in samples: `z2ui5_cl_demo_app_069` (1), `z2ui5_cl_demo_app_085` (6).
        Delete the calls there first - migrating them to another no-op is
        pointless.
- [ ] **`cs_event-nav_container_to`** and the `nest_` / `nest2_` / `popup_` /
      `popover_` variants — `z2ui5_if_client.intf.abap:97-101`.
      - Removing them also deletes the remap block in
        `z2ui5_cl_ui5_srv_event=>map_client_event` (~20 lines) that rewrites
        them onto `control_by_id` + method `to`.
      - Zero usages in samples and samples-controls (checked, incl. raw literals).
- [ ] **`cs_event-image_editor_popup_close`** — `z2ui5_if_client.intf.abap:96`.
      Belongs to `z2ui5_cl_pop_image_editor`; goes when `src/99/02` goes.

> **Not obsolete, do not remove:** `cs_event-z2ui5` is the supported entry point
> for app-registered JavaScript (`js_loader`) and currently sits in the
> "legacy event names" block. Move it up to the active actions instead.

---

## 2. `src/99/` — the frozen package (~30,800 ABAP lines)

The single biggest item. All of it is public and shipped, so removal is a
breaking change for any downstream app that still references it.

- [ ] **`z2ui5_cl_xml_view` (15,882 lines) + `z2ui5_cl_xml_view_cc`**
      → `z2ui5_cl_ai_xml` (`src/02/`)
      - **Blocker A:** samples — 336 of 343 classes use it, 0 use the successor.
      - **Blocker B:** docs — 51 pages teach it.
      - This is a project, not a task. Until it is done, nothing else in
        `src/99` can go either, because the package ships as a unit.
- [ ] **`src/99/01/` — 9 utility classes (11,925 lines) + `z2ui5_cx_util_error`
      + table `Z2UI5_T_91`**
      - **Blocker:** there is no successor API for *app* code. The internal
        replacement (`z2ui5_cl_ui5_context`) is framework-only. Decide first
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

**Falls out automatically when `src/99` goes:**

- [ ] 23 `FROZEN-ONLY` methods in `z2ui5_cl_ui5_context` (`src/00/03/`) — they
      exist solely because the shipped `src/99` still calls them. Grep the
      marker, delete the marked block.
- [ ] `npm run check:frozen` + the `check_frozen_paths` workflow
- [ ] the three `src/99` test skips in `node/setup/abap_transpile.json`
      and the `src/99` testclass/sidecar exemptions in `check:frozen` +
      `check_frozen_paths.yaml`
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
      `destroyNestView2` / `destroyView`** — `View1.controller.js:170-186`.
      Thin wrappers around `ViewSlots.destroy()`, kept because apps may call
      them from custom JS.
- [ ] **Legacy app-state hash handling in `core/Router.js`** (`:131`, `:330`,
      `:350`) — only removable if the pre-routing app-state hash is dropped
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

- [ ] **`follow_up_action( _event( ) )` snippet parsing** —
      `z2ui5_cl_ui5_action.clas.abap:256-262`. A `SPLIT` on `.eB(['` that
      reverse-engineers the next event out of a legacy JS string.
- [x] **The dynamic slot loops** — `reset_view_update_flags` 20 → 10 lines,
      `check_view_update_needed` 43 → 22. Plain `CLEAR` / `IF` on the statically
      known slots; `cs_view_slot_list` and `cs_model_slot_list` are gone, and
      with them four `ASSIGN COMPONENT` runtime guards that the syntax check
      now covers instead.

---

## 5. Documentation debt to clear alongside

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
