# Architecture seams — the draft store, the serializer, the roundtrip monitor, the codepage fallback

> Extracted from `AGENTS.md`, which points here. The sections below are
> the places where the framework deliberately lets something be swapped,
> watched or degraded: the draft store and the serializer are interfaces a
> host that is not an SAP system implements, the roundtrip monitor is the
> one an installation implements to log what its apps do, and the codepage
> fallback is the one utility failure a view render survives. AGENTS.md keeps the one-paragraph statement
> of each seam and the pointer; the contracts themselves live on the
> interfaces (`z2ui5_if_ui5_draft_store`, `z2ui5_if_ui5_serializer`) and the
> degradation at its two code sites. Every fact below was in AGENTS.md
> unchanged.

## Session persistence — the store is swappable

**The store is swappable (`z2ui5_if_ui5_draft_store`).** The draft service's seven
methods are an interface, `z2ui5_cl_ui5_srv_draft` is its shipped implementation, and
every caller goes through `z2ui5_cl_ui5_srv_draft=>get_instance( )`. On a system
nothing changes: without `set_instance( )` that call answers a fresh
`NEW z2ui5_cl_ui5_srv_draft( )` per call, which is literally what each call site
did before, so `Z2UI5_T_01` and all nine of its SQL statements are still what
runs.

The seam exists for the runtimes that are not an SAP system. `node/srv/express.mjs`
already serves this framework through the transpiler over open-abap, and
`node/setup/setup.mjs` only gets away with it by recreating the draft table in
SQLite. A host with persistence of its own — a CAP service with a CDS entity, a
Node process with a document store — previously had to fork the class to use it;
now it implements the interface and calls `set_instance( )` at startup. Tests can
do the same.

What an implementation must keep is written on the interface, because it was
never written down anywhere before: a draft belongs to the user that created it,
and `read_draft( )`, `read_info( )` and `check_exists( )` answer "not found" for
anybody else **identically**, so a caller cannot tell a foreign draft from a
missing one. `count_entries( )` is owner-scoped for the same reason;
`count_entries_total( )` deliberately is not, because it reports the size of the
store itself.

Note there are no `ALIASES` on the class — `no_aliases` is an error here, and
none are needed: an interface reference takes the plain method names. A caller
holding a concrete `z2ui5_cl_ui5_srv_draft` would have to qualify, which is the
second reason everything goes through `get_instance( )`.

## App state serialization (`z2ui5_if_ui5_serializer`)

The state that goes into the draft is the whole `z2ui5_cl_ui5_app_cont` — the
app instance, `mt_attri`, the draft ids — turned into a string by
`all_xml_stringify( )` and rebuilt by `all_xml_parse( )`. Both now delegate to
`z2ui5_cl_ui5_app_cont=>get_serializer( )`.

The shipped implementation, `z2ui5_cl_ui5_serializer`, is the mechanism
that has always run here and is unchanged statement for statement:
`main_attri_db_save_srtti( )` detaches the data references, `CALL TRANSFORMATION
id` writes the asXML, `main_attri_reattach( )` gives the live instance its
references back, and the one retry rebuilds the rows from the instance as it is
now before giving up with `APP_SERIALIZATION_ERROR`. Without `set_serializer( )`
`get_serializer( )` answers a fresh one per call, so a system behaves
identically.

Why the seam is here rather than anywhere else: this is the **one** part of the
framework that is ABAP's type system rather than ABAP code. `CALL TRANSFORMATION
id` walks type descriptors, and S-RTTI serializes a descriptor so
`CREATE DATA … TYPE HANDLE` can rebuild it on the other side. Neither has a
counterpart in a JavaScript runtime — a JS object carries no static type to
describe — so a host running this framework through the transpiler (which
`node/srv/express.mjs` already does) cannot reproduce it and has to persist its
own shape instead. Everything else in the engine transfers; this did not, and
it was wired straight into the container.

Both ends of the interface are `REF TO object`, not `REF TO
z2ui5_cl_ui5_app_cont`: an interface here may not reference a class
(`intf_referencing_clas`, an error) and naming it would close a cycle, since
the container is what calls the interface. `z2ui5_cl_ui5_serializer`
narrows once, in `narrow( )`. Note the typed local in its `parse( )` — the
transformation rebuilds the object from the class named in the asXML and needs
a concretely typed target, so a `REF TO object` there would give it nothing to
build into.

What an implementation has to keep is a round trip, not a format:
`parse( stringify( container ) )` must answer a container the framework can go
on with. The string in between is the implementation's business.

**The Node host installs one** (`node/srv/zcl_serializer_live.clas.abap`,
from `host.mjs`'s `initialize()`, packed into `@abap2ui5/node-runtime` next to
`zcl_sicf`). In a process the roll area never ends, so the string is an id
and the container stays live in a class-wide table behind it - no RTTI walk
of the object graph to save, none to load. The draft row in `Z2UI5_T_01`
carries the id, so a draft lives as long as the process, which the in-memory
SQLite of that host had already decided. What it changes: an id answers the
container **as it is**, not as it was when the id was written - every
roundtrip of an app saves the same object under a new id, so a Back/Forward
or a bookmark into an earlier roundtrip of the same app shows its latest
state, and a retry after a failed roundtrip runs on the state the failed one
left. That is the semantics of a stateful session
(`client->set_session_stateful( )`), which the framework already runs with
the live handler, for every app of that host; the id chain (`id_prev`,
`id_prev_app`) is kept as before. An id the table no longer holds - swept,
or written by an earlier process - answers
`NO_DRAFT_ENTRY_OF_PREVIOUS_REQUEST_FOUND`, the store's own error for a
missing row, so the handler treats both alike. The table is swept by
`zcl_serializer_live=>sweep( )` with the expiry the exit answers
(`draft_exp_time_in_hours`, the rule `cleanup( )` applies to `Z2UI5_T_01`),
which the host runs together with `cleanup( )` on a timer (`host.mjs`,
"DRAFT SWEEP") - the per-cold-start sweep stays what it is on a system
(`docs/agents/decisions.md`), and the timer is the host's, not the
framework's. On an SAP system nothing changes.

## The roundtrip monitor (`z2ui5_if_ui5_monitor`)

The one seam in the **released** API (`src/02`), because the party that
implements it is an installation or an addon (abap2UI5-addons/admin-cockpit),
not a host runtime. `z2ui5_cl_ui5_srv_monitor=>get_monitor( )` finds the
implementation exactly the way `z2ui5_cl_ui5_user_exit` finds the exit — the
classes implementing the interface, sorted by name, the first one wins, the
answer latched per roll area (so a stateless request pays one repository read
and a sticky session one in total) — and `set_monitor( )` installs one without
the lookup, for a host without a class repository and for tests.

`z2ui5_cl_ui5_handler=>main` asks for it first and calls it once at the very
end: on success after the response is built and the draft saved, on failure
inside its CATCH block with the exception it is about to raise — the same
object `z2ui5_cl_ui5_http_handler=>_main` renders into the 500 body, so the
error id `get_text_full` stamps on it is the one the user sees. Where each
field comes from:

| Field | Source |
|---|---|
| `app` | the class the response names (`ms_response-s_front-app`); on failure the class of the app that was running — empty before one was resolved |
| `event`, `draft_id_prev`, `check_start` | the request's `S_FRONT` (`EVENT`, `ID`, no `ID`), only once THIS body was parsed, capped like the error context |
| `draft_id` | the id the response carries; empty on failure |
| `uname`, `check_sticky` | `sy-uname`; the app container's `mv_check_sticky` |
| `timestampl`, `ms_*` | `GET TIME STAMP` at the start of `main( )`, after `main_begin( )` and around `main_end( )`; the phase a failure ends is closed at the failure, a phase never reached stays 0 |
| `bytes_*` | `strlen` of the request body, of the response JSON and of the model it carries (0 for no model and on failure — the 500 body is built later, above the engine) |
| `ms_client_prev` | `S_FRONT.MS_CLIENT_PREV`, the previous roundtrip as `core/Server.js` measured it (POST to parsed response); 0 when absent or unreadable |
| `check_error`, `error_text`, `error_class` | the exception: `z2ui5_cx_ui5_util_error=>get_text_full( )` and the class of the innermost `previous` |

Four decisions, each written at its code site as well:

- **It is off until the installation switches it on.** `get_monitor( )` asks
  the user exit first (`check_monitor_active` in `set_config_http_post`,
  nothing seeds it) and without the switch does not even look the class up;
  `set_monitor( )` is the host's own choice and is not asked. The reason is
  what fail-open cannot cover: a syntax error in the monitor or in any class it
  uses is the runtime error `SYNTAX_ERROR`, a short dump no `CATCH` stops. A
  half-activated pull of abap2UI5-addons/admin-cockpit (2026-10-06) answered
  every abap2UI5 request with *"Syntax error in program
  Z2UI5_CL_COCKPIT_SETUP"* while nothing had switched the cockpit on. Only
  code that is never called cannot break the framework. The switch is read on
  every call, so turning it off takes effect on the next roundtrip.
- **It fails open, where the exit fails closed.** The exit is a hardening
  control, and an exit class that cannot be built must not leave every request
  on the defaults unnoticed. A monitor only watches; failing closed would turn
  a broken log class into a broken app for every user. A lookup that raises, a
  class that cannot be instantiated and a call that raises are all ignored,
  and only an answer that came back is latched.
- **The clock is `GET TIME STAMP` plus arithmetic**
  (`z2ui5_cl_ui5_util_context=>time_diff_milliseconds`), not
  `cl_abap_tstmp=>subtract` and not `GET RUN TIME`: the first answers whole
  seconds in open-abap, the second counts from the previous call rather than
  the first there, so neither means the same in the transpiled runtime as on a
  system.
- **The LUW is clean when the monitor runs, unless the app is sticky.** On
  success the draft save has committed; on failure `monitor_notify` rolls back
  first — the rollback that follows the app's `main( )` in `main_process`
  never ran — so a monitor's `COMMIT WORK` commits only its own entry. It does
  so only while a monitor is installed (without one nothing changed) and never
  for a sticky app, whose LUW the framework does not touch on any path; the
  interface tells the implementation not to commit then.

Not monitored: the page request (GET), HEAD, and a POST the CSRF gate
rejects — none of them runs an app.

## A missing codepage class must not take down the view

`conv_get_string_by_xstring( )` / `conv_get_xstring_by_string( )` try
`CL_ABAP_CONV_CODEPAGE` and fall back to `CL_ABAP_CONV_IN_CE` / `_OUT_CE`,
both through dynamic `CALL METHOD` because neither is available on every
release. Since 2026-09 **the fallback has its own `TRY`**: it used to be the
body of the first `CATCH`, so when it failed too a raw
`CX_SY_DYN_CALL_ILLEGAL_CLASS` left a utility method under a name no caller
handles. Now both failures chain into `UNSUPPORTED_CODEPAGE_API`, a
`z2ui5_cx_ui5_util_error` like everything else here.

That matters because of who calls it. `z2ui5_cl_ui5_view_builder`'s
`xml_escape( )` builds its control-character set through this method, lazily,
on the first escape of the process — so on a release with neither class, or in
any runtime where a dynamic `CALL METHOD` resolves nothing, **every view render
died**. The builder now catches `z2ui5_cx_ui5_util_error` and degrades: the set
stays empty, the `CA` scan matches no control character, and `&`, `<`, `>`,
`"`, newline, CR and tab are escaped exactly as before. Dropping those 29 exotic
bytes repairs legacy long texts; it is not a correctness requirement of the
view, so losing it must not cost the render.

## The exit interface during the rename (`z2ui5_if_ui5_exit` / `z2ui5_if_exit`)

**Exit Pattern:** `z2ui5_if_ui5_exit` (the public extension point) implemented by `z2ui5_cl_ui5_user_exit` for custom themes, CSP headers, etc. **A host installs the exit without the lookup:** `z2ui5_cl_ui5_user_exit=>set_instance( )` takes the shipped exit (the defaults, latched as "no exit installed") or any other implementation of `z2ui5_if_ui5_exit`, which is then called through the shipped exit exactly as a customer exit the lookup found - the defaults seeded first - and named by `get_user_exit_class( )`; an unbound reference restores the lookup. It exists because the lookup is a repository read that RAISES in a runtime without a class repository, and a raised lookup is deliberately not latched (a transient repository error on a system must not leave a sticky session on the shipped defaults for good) - so the transpiled runtime paid the RTTI walk and the dynamic call on every `get_instance( )`, three times per POST. `node/srv/host.mjs` calls it from `initialize()`; the no-latch contract for a system is untouched. **Two interfaces are honoured during the rename:** `z2ui5_if_exit` is the superseded name and carries the same two methods, its types being references to the ones on `z2ui5_if_ui5_exit` rather than copies. It lives in `src/99` and is the **one** object of that package `abaplint.jsonc` lists in the strict ruleset by name — a `src/01` class naming a type the strict parser cannot see is 37 unresolvable-type errors, so the line stays until the interface goes. `get_user_exit_class( )` looks the current interface up first and the superseded one only when that names nothing, so a class implementing both is found under the current name; `get_instance( )` casts to the current interface first, so such a class is called once, through `z2ui5_if_ui5_exit`. The shipped exit implements `z2ui5_if_ui5_exit` only — `gi_user_exit_dep`, the reference of the superseded type, holds nothing but a customer class written against that name. When `z2ui5_if_exit` goes, what goes with it is the second lookup, the second class-data reference and the two delegating methods — all in `z2ui5_cl_ui5_user_exit`.
