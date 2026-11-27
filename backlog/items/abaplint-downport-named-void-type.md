---
target: abaplint
title: 'The 702 downport refuses an inline declaration or # whose type is a named void type'
summary: 'DATA(ls_item) = item( ... ) with a RETURNING parameter of a type abaplint does not know stops with "Cannot downport, type of ls_item is void", although the name written after TYPE in the signature is what the declaration needs'
priority: low
state: open
first_seen: 2026-11-27
upstream: abaplint/abaplint
evidence:
  - 'abap-util/business-api 66dca94, 2026-11 ("the sources the downport could not handle: inline declarations and VALUE #( ) of void BAPI types are now typed explicitly"): six methods of one class rewritten by hand - DATA(ls_item) = item( ... ) with RETURNING ... TYPE bapi2017_gm_item_create, and COND #( ... ) for a formal TYPE lgort_d'
  - 'probed 2026-11-27 against abaplint main after 2.120.122, syntax v702: "Cannot downport, type of ls_item is void" and "Cannot downport, inferred type is void"; VALUE #( ( ls_item ) ) for a formal typed with a class-local table type is downported'
  - 'rules/downport.ts notDownported refuses when the void type has no qualified name, while getVoided( ) holds the name written after TYPE; the refusal message is recent and deliberate, so this needs the maintainer to agree first'
---

# The 702 downport: a void type that has a name

```abap
" METHODS item ... RETURNING VALUE(rs) TYPE bapi2017_gm_item_create.
DATA(ls_item) = item( iv_bwart = '311' ).
```

`bapi2017_gm_item_create` is not in the repository or its dependencies, so
the type is void and the downport stops: "Cannot downport, type of ls_item
is void". The declaration it would have to write only needs the name:

```abap
DATA ls_item TYPE bapi2017_gm_item_create.
```

## Proposal

When the void comes from a plain `TYPE <name>` of a known signature, use
that name - for the inline declaration and for `#`
(`COND lgort_d( ... )`).

## Must keep refusing

A void without a usable name: the result of a method of a void class,
`LIKE LINE OF` a void table, a component of a void structure - there the
voided text is not the type of the value.

## Workaround

Declare the variable with its type, write the type instead of `#`.
