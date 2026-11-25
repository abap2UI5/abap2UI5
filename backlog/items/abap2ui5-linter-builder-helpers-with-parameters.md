---
target: abap2ui5-linter
title: 'Follow builder helpers of other classes that take parameters (views classes, layout builders)'
summary: 'the linter follows a static factory helper with a literal-only chain and a stringify helper of another class, one level deep; a helper that takes the client, a title or a data reference into its chain (xml_build_page, a layout table builder) leaves its part of the view unseen and the render skipped'
priority: low
state: filed
filed: https://github.com/abap2UI5/linter/pull/203
first_seen: 2026-11-25
checked_upstream: 2026-11-25
evidence:
  - 'abap2UI5/linter builder-helpers-across-classes (2026-11-25) on oblomov-dev/S5S_DEV: 13 documents, 363 controls, 151 bindings reconstructed from /kro/ui501_cl_app_view=>factory_view( ) / factory_popup( ) / stringify( ); still 43 of 57 app classes without a view - their screens come from xml_build_page( i_title client ), xml_build_table_v2( i_data … ), z2ui5_cl_layo_xml_builder=>xml_build_table( ) and the customizing-driven render_by_cust ( CALL METHOD lo_obj->(render_method) )'
  - 'the replay already enters a SAME-class void helper with its parameters bound per call (inHelperCall in lib/reconstruct.mjs); the cross-class helper index (builderHelpersOf) carries no body'
  - 'abap2UI5/linter open issues and PRs checked 2026-11-25 (#195, #196, #197): nothing on this'
---

# Follow builder helpers of other classes that take parameters

```abap
DATA(page) = zcl_views=>xml_build_page( client  = client
                                        i_title = `Stock` ).  " not followed
page->ele( `Table` )->a( n = `items` v = client->_bind( mt_stock ) ).
zcl_views=>xml_build_table( i_xml = page i_data = REF #( mt_stock ) ). " not followed
```

## Motivation

An app suite builds its screens through a views class. The linter follows
the two simplest shapes of such a class (a literal factory, a stringify);
everything else that class offers is a call the replay does not enter, and
the document is marked incomplete. The classes of the run are all there -
the bodies could be replayed the way a same-class helper is.

## Proposal

Carry the BODY of a static builder helper in the class index (bounded:
methods whose signature returns or takes `TYPE REF TO
z2ui5_cl_ui5_view_builder`), and replay it in the calling class like a
same-class helper: parameters bound per call where the argument resolves,
`client` mapped to the caller's client, a parameter that does not resolve
left unresolved (no guess). Keep the one-level depth limit and count what
is not entered as unplaced, as today.

## Must not change

- A helper whose body depends on runtime values (dynamic calls, `ASSIGN`,
  `CREATE OBJECT … TYPE (name)`) is not replayed.
- A class without the views class in the run keeps today's verdict.
