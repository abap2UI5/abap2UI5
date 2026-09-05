"! Generic UI5 XML view builder - translate a UI5 XML view 1:1 by method
"! chaining. The navigating methods are abbreviations of the term they stand
"! for, and the attribute verb is the single `a`:
"!   factory         a new empty builder root
"!   ele - element   add a child element and DESCEND into it (returns the child)
"!   tag - tag       add a child element and STAY here (returns the same node)
"!   a   - attribute set an attribute on the element it follows
"!   end - end       ascend to the parent element (returns the parent)
"!   stringify       render the whole view, always from the root
"! Element = n (name), namespace prefix = ns (e.g. `f`, `core`, `l`).
"! There is exactly one rule: a( ) applies to the element the chain is
"! POINTING AT - the child just added by ele( )/tag( ), or the node itself
"! while it has no children yet. So an a( ) always follows the control it
"! belongs to, no matter whether that control was opened with ele( ) or added
"! with tag( ), and every attribute is set by its own a( ).
"! Reach for tag( ) on a leaf and for ele( )/end( ) on a container. The flip
"! side of the rule: once an element has a child, a( ) can no longer reach
"! it - give an element its attributes before its first child.
"! Every ele( ) may be closed by an end( );
"! a trailing end( ) at the end of the chain can be omitted, because stringify( )
"! renders from the root no matter where the chain stopped.
"! The root mvc:View element and its xmlns declarations are written by hand,
"! exactly like a real UI5 view:
"!   DATA(view) = z2ui5_cl_ui5_view_builder=>factory( ).
"!   view->ele( n = `View` ns = `mvc`
"!       )->a( n = `xmlns`     v = `sap.m`
"!       )->a( n = `xmlns:mvc` v = `sap.ui.core.mvc` ) ...
"! `v` may be any string expression (literal, a client bind/event, || template).
"! For a boolean pass b instead of v - it renders `true` / `false`, so an ABAP
"! flag reaches the view without a conversion of its own:
"!   )->a( n = `editable` b = mv_edit_mode
"!   )->a( n = `visible`  b = xsdbool( lines( mt_item ) > 0 ) )
CLASS z2ui5_cl_ui5_view_builder DEFINITION PUBLIC CREATE PRIVATE.

  PUBLIC SECTION.

    "! returns an empty builder root; open the mvc:View element and declare the
    "! xmlns namespaces yourself, exactly like any other control
    CLASS-METHODS factory
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_ui5_view_builder.

    "! add a child element and descend into it - the returned reference is the
    "! new element, so a following a( ) lands on it
    METHODS ele
      IMPORTING
        n             TYPE string
        ns            TYPE string OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_ui5_view_builder.

    "! add a child element and STAY on the current one, so the next tag( ) or
    "! ele( ) becomes its sibling and no end( ) is needed. A following a( )
    "! still lands on the tag, because it is now this node's last child - the
    "! form for a leaf, whatever its attributes are.
    METHODS tag
      IMPORTING
        n             TYPE string
        ns            TYPE string OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_ui5_view_builder.

    "! set an attribute on the element the chain is pointing at - the child
    "! just added by ele( )/tag( ), or this node itself while it has none.
    "! Pass either v (any string expression) or b (an ABAP boolean, rendered
    "! as `true` / `false`) - exactly one of the two, never both and never
    "! neither.
    METHODS a
      IMPORTING
        n             TYPE string
        v             TYPE string    OPTIONAL
        b             TYPE abap_bool OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_ui5_view_builder.

    "! ascend to the parent element
    METHODS end
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_ui5_view_builder.

    "! render the complete view as XML - always from the root, no matter which
    "! element this reference currently points at
    METHODS stringify
      RETURNING
        VALUE(result) TYPE string.

    "! Escape a value that must render as LITERAL text in an attribute: the
    "! page bootstraps with complex binding syntax, so a curly brace in the
    "! value - think a user-supplied search string - is otherwise parsed
    "! by UI5 as a binding path (or an expression) instead of shown as text,
    "! and can read arbitrary paths out of the view model. Backslash-escaping
    "! the braces is UI5's own convention for literal text.
    "! Deliberately NOT applied by a( ) itself: a deliberate binding in v -
    "! client-&gt;_bind( ), an event, a template - is the builder's bread and
    "! butter, and only the app knows which values are literals. Use it on
    "! any user- or external-supplied string an app renders via a( v = ... ):
    "!   )-&gt;a( n = `text` v = z2ui5_cl_ui5_view_builder=&gt;escape_literal( lv_input ) )
    "! XML escaping is a separate concern and always applied on render.
    CLASS-METHODS escape_literal
      IMPORTING
        val           TYPE string
      RETURNING
        VALUE(result) TYPE string.

  PROTECTED SECTION.
    TYPES ty_t_node TYPE STANDARD TABLE OF REF TO z2ui5_cl_ui5_view_builder WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_s_name_value,
        n TYPE string,
        v TYPE string,
      END OF ty_s_name_value.
    TYPES ty_t_name_value TYPE STANDARD TABLE OF ty_s_name_value WITH EMPTY KEY.

    DATA name    TYPE string.
    DATA prefix  TYPE string.
    DATA t_pair  TYPE ty_t_name_value.
    DATA t_child TYPE ty_t_node.
    DATA parent  TYPE REF TO z2ui5_cl_ui5_view_builder.
    DATA root    TYPE REF TO z2ui5_cl_ui5_view_builder.

    " Append this node's markup to ct_out - the open tag, the children (by
    " the same call), the close tag. One accumulator for the whole tree,
    " concatenated once by stringify( ): a render that returned a string
    " per node copied every subtree once per ancestor (view size times
    " nesting depth on every render); appending moves each character once
    METHODS render_into
      CHANGING
        ct_out TYPE string_table.

    METHODS xml_escape
      IMPORTING
        val           TYPE string
      RETURNING
        VALUE(result) TYPE string.

  PRIVATE SECTION.
    " the character set xml_escape guards against, concatenated once per
    " roll area instead of once per attribute (three CLASS-DATA reads and a
    " template per call otherwise). Lazily filled on first use - a public
    " class_constructor is the alternative and abap-check names it a trap
    CLASS-DATA gv_escape_specials TYPE string.
    CLASS-DATA gv_escape_controls TYPE string.
ENDCLASS.


CLASS z2ui5_cl_ui5_view_builder IMPLEMENTATION.

  METHOD factory.

    result = NEW #( ).
    result->root = result.

  ENDMETHOD.


  METHOD ele.

    result = NEW #( ).
    result->root = root.
    result->parent = me.
    result->name = n.
    result->prefix = ns.
    APPEND result TO t_child.

  ENDMETHOD.


  METHOD tag.

    ele( n  = n
         ns = ns ).
    " stay where we are - the tag is complete, its siblings follow directly
    result = me.

  ENDMETHOD.


  METHOD a.

    " one rule: the attribute lands on the element the chain is pointing at -
    " the child just added by ele( )/tag( ), or this node itself while it has
    " no children yet. That way a( ) follows the control it belongs to
    " whether that control was opened with ele( ) or added with tag( ).
    " fail fast instead of dropping silently: on the empty builder root there
    " is no element to attach to, and a duplicate name renders invalid XML
    ASSERT name IS NOT INITIAL OR t_child IS NOT INITIAL.
    " b and v are mutually exclusive - b is checked with IS SUPPLIED because
    " abap_false and "not passed" are the same character.
    " "never neither" is asserted with IS SUPPLIED rather than IS NOT INITIAL
    " so that a deliberately empty value ( a( n = `text` v = `` ) ) stays
    " legal: what this refuses is a( n = `visible` ) with no value at all,
    " which used to render visible="" - a working view that behaves wrongly,
    " and the one invariant of the three in the ABAP Doc above that nothing
    " checked
    ASSERT v IS SUPPLIED OR b IS SUPPLIED.
    DATA(val) = v.
    IF b IS SUPPLIED.
      ASSERT v IS INITIAL.
      val = COND #( WHEN b = abap_true THEN `true` ELSE `false` ).
    ENDIF.

    IF t_child IS INITIAL.
      ASSERT NOT line_exists( t_pair[ n = n ] ). "#EC CI_SORTSEQ
      APPEND VALUE #( n = n
                      v = val ) TO t_pair.
    ELSE.
      DATA(target) = t_child[ lines( t_child ) ].
      ASSERT NOT line_exists( target->t_pair[ n = n ] ). "#EC CI_SORTSEQ
      APPEND VALUE #( n = n
                      v = val ) TO target->t_pair.
    ENDIF.
    result = me.

  ENDMETHOD.


  METHOD end.

    " fail fast: an end( ) past the mvc:View root would hand back a null
    " reference that only crashes at the next chained call, far from the bug
    ASSERT parent IS BOUND.
    result = parent.

  ENDMETHOD.


  METHOD render_into.

    DATA child TYPE REF TO z2ui5_cl_ui5_view_builder.

    " empty builder root - render only the children
    IF name IS INITIAL.
      LOOP AT t_child INTO child.
        child->render_into( CHANGING ct_out = ct_out ).
      ENDLOOP.
      RETURN.
    ENDIF.

    DATA(qname) = COND string( WHEN prefix IS INITIAL THEN name ELSE |{ prefix }:{ name }| ).
    " table-then-concat for the attributes: a string template accumulator
    " re-copied every attribute rendered so far on each further one,
    " quadratic on attribute-heavy elements. REFERENCE INTO - the loop used
    " to copy a two-string structure per attribute
    DATA lt_attr TYPE string_table.
    LOOP AT t_pair REFERENCE INTO DATA(lr_pair).
      INSERT | { lr_pair->n }="{ xml_escape( lr_pair->v ) }"| INTO TABLE lt_attr.
    ENDLOOP.
    DATA(attrs) = concat_lines_of( lt_attr ).

    IF t_child IS INITIAL.
      APPEND |<{ qname }{ attrs }/>| TO ct_out.
      RETURN.
    ENDIF.

    APPEND |<{ qname }{ attrs }>| TO ct_out.
    LOOP AT t_child INTO child.
      child->render_into( CHANGING ct_out = ct_out ).
    ENDLOOP.
    APPEND |</{ qname }>| TO ct_out.

  ENDMETHOD.


  METHOD xml_escape.

    " one CA scan up front: replace( occ = 0 ) copies the whole string on
    " every call even when nothing matches, and a value without any special
    " character is the COMMON case - that made every attribute value pay for
    " seven full copies. A value that does carry one still runs all seven
    " replaces below, unchanged
    IF gv_escape_specials IS INITIAL.
      " the XML-illegal control characters as one string, so the CA scan
      " stays a single statement; built from their UTF-8 bytes through the
      " context class (the one door to the codepage API)
      gv_escape_controls = z2ui5_cl_ui5_util_context=>conv_get_string_by_xstring(
          CONV xstring( `0102030405060708` && `0B0C` && `0E0F101112131415161718191A1B1C1D1E1F` ) ).
      gv_escape_specials = `&<>"`
          && z2ui5_cl_ui5_util_context=>cv_char_util_newline
          && z2ui5_cl_ui5_util_context=>cv_char_util_cr_lf(1)
          && z2ui5_cl_ui5_util_context=>cv_char_util_horizontal_tab
          && gv_escape_controls.
    ENDIF.
    IF val NA gv_escape_specials.
      result = val.
      RETURN.
    ENDIF.

    result = val.
    result = replace( val  = result
                      sub  = `&`
                      with = `&amp;`
                      occ  = 0 ).
    result = replace( val  = result
                      sub  = `<`
                      with = `&lt;`
                      occ  = 0 ).
    result = replace( val  = result
                      sub  = `>`
                      with = `&gt;`
                      occ  = 0 ).
    result = replace( val  = result
                      sub  = `"`
                      with = `&quot;`
                      occ  = 0 ).
    " whitespace as character references - a literal LF/CR/TAB in an attribute
    " value is turned into a plain space by XML attribute-value normalization,
    " so line breaks (e.g. a two-line noDataText) would silently disappear.
    " char constants come from the context class - the one place allowed to
    " reference cl_abap_char_utilities (see "Utilities" in AGENTS.md)
    result = replace( val  = result
                      sub  = z2ui5_cl_ui5_util_context=>cv_char_util_newline
                      with = `&#xA;`
                      occ  = 0 ).
    result = replace( val  = result
                      sub  = z2ui5_cl_ui5_util_context=>cv_char_util_cr_lf(1)
                      with = `&#xD;`
                      occ  = 0 ).
    result = replace( val  = result
                      sub  = z2ui5_cl_ui5_util_context=>cv_char_util_horizontal_tab
                      with = `&#x9;`
                      occ  = 0 ).

    " what is left of the control range is illegal in XML 1.0 outright -
    " U+0000-U+0008, U+000B, U+000C, U+000E-U+001F cannot even be written
    " as character references, and UI5's XMLView parser rejects the whole
    " document over one such byte (a form feed or record separator out of a
    " legacy long text blanks the view). They carry no meaning in an
    " attribute value, so they are dropped. Only reached for a value that
    " passed the CA scan above - see gv_escape_specials
    IF result CA gv_escape_controls.
      " one replace per character, no regex: [[:cntrl:]] is not a class every
      " runtime this code runs on knows (the transpiled one left every byte
      " in place), and this branch is the rare one
      DATA(lv_off) = 0.
      DATA(lv_len) = strlen( gv_escape_controls ).
      WHILE lv_off < lv_len.
        result = replace( val  = result
                          sub  = gv_escape_controls+lv_off(1)
                          with = ``
                          occ  = 0 ).
        lv_off = lv_off + 1.
      ENDWHILE.
    ENDIF.

  ENDMETHOD.


  METHOD stringify.

    DATA lt_out TYPE string_table.
    root->render_into( CHANGING ct_out = lt_out ).
    result = concat_lines_of( lt_out ).

  ENDMETHOD.


  METHOD escape_literal.

    result = val.

    " nothing to escape: no brace, no backslash. Note that the shortcut is
    " NOT "no brace": UI5's XMLTemplateProcessor hands EVERY string property
    " to the binding parser with unescaping on, brace or not, and the
    " parser unescapes `\\`, `\{` and `\}` even when it finds no binding
    " (OpenUI5 1.71 BindingParser.complexParser, the bUnescaped tail). A
    " lone backslash is left alone, so `C:\temp\file` rendered fine either
    " way - but `\\server\share` lost one backslash per pair until the
    " backslash was escaped whenever present (2026-09-05)
    IF result NA `{}\`.
      RETURN.
    ENDIF.

    " the backslash first (UI5 unescapes `\\` back to one), then the braces,
    " which would otherwise start a binding
    result = replace( val  = result
                      sub  = `\`
                      with = `\\`
                      occ  = 0 ).
    result = replace( val  = result
                      sub  = `{`
                      with = `\{`
                      occ  = 0 ).
    result = replace( val  = result
                      sub  = `}`
                      with = `\}`
                      occ  = 0 ).

  ENDMETHOD.

ENDCLASS.
