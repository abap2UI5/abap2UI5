# Architecture seams — the draft store, the serializer, the codepage fallback

> Extracted from `AGENTS.md`, which points here. The three sections below are
> the places where the framework deliberately lets something be swapped or
> degraded: the draft store and the serializer are interfaces a host that is
> not an SAP system implements, and the codepage fallback is the one utility
> failure a view render survives. AGENTS.md keeps the one-paragraph statement
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
