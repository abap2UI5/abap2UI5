"! Generic UI5 XML view builder - translate a UI5 XML view 1:1 by method
"! chaining. Every letter of the API is the initial of the term it stands for:
"!   new - factory   a new empty builder root
"!   ele - element   add a child element and DESCEND into it (returns the child)
"!   tag - tag       add a child element and STAY here (returns the same node)
"!   att - attribute set an attribute on the element you are standing on
"!   end - end       ascend to the parent element (returns the parent)
"!   stringify      render the whole view, always from the root
"! Element = n (name), namespace prefix = ns (e.g. `f`, `core`, `l`).
"! There is exactly one rule: att( ) always applies to the CURRENT element, the
"! one the last ele( ) descended into. tag( ) does not move, so its attributes
"! travel with it in t_att - after a tag( ) the chain still stands on the
"! parent, and an att( ) there would attach to the parent. Reach for tag( ) on
"! a leaf whose attributes are literals, and for ele( )/end( ) everywhere else.
"! Every ele( ) may be closed by an end( );
"! a trailing end( ) at the end of the chain can be omitted, because stringify( )
"! renders from the root no matter where the chain stopped.
"! The root mvc:View element and its xmlns declarations are written by hand,
"! exactly like a real UI5 view:
"!   DATA(view) = z2ui5_cl_ui5_view_builder=>new( ).
"!   view->ele( n = `View` ns = `mvc`
"!       )->att( n = `xmlns`     v = `sap.m`
"!       )->att( n = `xmlns:mvc` v = `sap.ui.core.mvc` ) ...
"! `v` may be any string expression (literal, a client bind/event, || template).
"! For a boolean from an ABAP variable pass b instead of v.
CLASS z2ui5_cl_ui5_view_builder DEFINITION PUBLIC CREATE PRIVATE.

  PUBLIC SECTION.

    "! attribute list for tag( ) - one `key=value` string per attribute, e.g.
    "! t_att = VALUE #( ( `text=Hello` ) ( `width=100%` ) ). Split on the FIRST
    "! `=`, so the value may contain further ones.
    TYPES ty_t_attr TYPE STANDARD TABLE OF string WITH EMPTY KEY.

    "! returns an empty builder root; open the mvc:View element and declare the
    "! xmlns namespaces yourself, exactly like any other control
    CLASS-METHODS new
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_ui5_view_builder.

    "! add a child element and descend into it - the returned reference is the
    "! new element, so a following att( ) lands on it
    METHODS ele
      IMPORTING
        n             TYPE string
        ns            TYPE string OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_ui5_view_builder.

    "! add a child element and STAY on the current one, so the next tag( ) or
    "! ele( ) becomes its sibling and no end( ) is needed. Its attributes must
    "! travel with it in t_att - a following att( ) would land on the element
    "! the chain is standing on, which is the PARENT, not the tag just added.
    "! Use ele( )/end( ) whenever an attribute needs a computed value.
    METHODS tag
      IMPORTING
        n             TYPE string
        ns            TYPE string OPTIONAL
        t_att         TYPE ty_t_attr OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_ui5_view_builder.

    "! set an attribute on the current element. Pass either v (any string
    "! expression) or b (an ABAP boolean, rendered as `true` / `false`) -
    "! exactly one of the two, never both and never neither.
    METHODS att
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

  PROTECTED SECTION.
    TYPES ty_t_node TYPE STANDARD TABLE OF REF TO z2ui5_cl_ui5_view_builder WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_s_pair,
        n TYPE string,
        v TYPE string,
      END OF ty_s_pair.
    TYPES ty_t_pair TYPE STANDARD TABLE OF ty_s_pair WITH EMPTY KEY.

    DATA name    TYPE string.
    DATA prefix  TYPE string.
    DATA t_pair  TYPE ty_t_pair.
    DATA t_child TYPE ty_t_node.
    DATA parent  TYPE REF TO z2ui5_cl_ui5_view_builder.
    DATA root    TYPE REF TO z2ui5_cl_ui5_view_builder.

    "! split one `key=value` attribute string on its first `=`
    METHODS parse_attr
      IMPORTING
        kv            TYPE string
      RETURNING
        VALUE(result) TYPE ty_s_pair.

    METHODS render
      RETURNING
        VALUE(result) TYPE string.

    METHODS xml_escape
      IMPORTING
        val           TYPE string
      RETURNING
        VALUE(result) TYPE string.

  PRIVATE SECTION.
ENDCLASS.


CLASS z2ui5_cl_ui5_view_builder IMPLEMENTATION.

  METHOD new.

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


  METHOD parse_attr.

    DATA(off) = find( val = kv
                      sub = `=` ).
    IF off < 0.
      result-n = condense( kv ).
    ELSE.
      result-n = condense( substring( val = kv
                                      len = off ) ).
      result-v = substring( val = kv
                            off = off + 1 ).
    ENDIF.

  ENDMETHOD.


  METHOD tag.

    DATA(child) = ele( n  = n
                       ns = ns ).
    LOOP AT t_att INTO DATA(kv).
      DATA(pair) = parse_attr( kv ).
      ASSERT NOT line_exists( child->t_pair[ n = pair-n ] ).
      APPEND pair TO child->t_pair.
    ENDLOOP.
    " stay where we are - the tag is complete, its siblings follow directly
    result = me.

  ENDMETHOD.


  METHOD att.

    " one rule: the attribute lands on the element the chain is standing on.
    " fail fast instead of dropping silently: on the empty builder root there
    " is no element to attach to, and a duplicate name renders invalid XML
    ASSERT name IS NOT INITIAL.
    ASSERT NOT line_exists( t_pair[ n = n ] ).
    " b and v are mutually exclusive - b is checked with IS SUPPLIED because
    " abap_false and "not passed" are the same character
    IF b IS SUPPLIED.
      ASSERT v IS INITIAL.
      APPEND VALUE #( n = n
                      v = COND #( WHEN b = abap_true THEN `true` ELSE `false` ) ) TO t_pair.
    ELSE.
      APPEND VALUE #( n = n
                      v = v ) TO t_pair.
    ENDIF.
    result = me.

  ENDMETHOD.


  METHOD end.

    " fail fast: an end( ) past the mvc:View root would hand back a null
    " reference that only crashes at the next chained call, far from the bug
    ASSERT parent IS BOUND.
    result = parent.

  ENDMETHOD.


  METHOD render.

    DATA(inner) = ``.
    LOOP AT t_child INTO DATA(child).
      inner = |{ inner }{ child->render( ) }|.
    ENDLOOP.

    " empty builder root - render only the children
    IF name IS INITIAL.
      result = inner.
      RETURN.
    ENDIF.

    DATA(qname) = COND string( WHEN prefix IS INITIAL THEN name ELSE |{ prefix }:{ name }| ).
    DATA(attrs) = ``.
    LOOP AT t_pair INTO DATA(pair).
      attrs = |{ attrs } { pair-n }="{ xml_escape( pair-v ) }"|.
    ENDLOOP.

    IF t_child IS INITIAL.
      result = |<{ qname }{ attrs }/>|.
    ELSE.
      result = |<{ qname }{ attrs }>{ inner }</{ qname }>|.
    ENDIF.

  ENDMETHOD.


  METHOD xml_escape.

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
                      sub  = z2ui5_cl_a2ui5_context=>cv_char_util_newline
                      with = `&#xA;`
                      occ  = 0 ).
    result = replace( val  = result
                      sub  = z2ui5_cl_a2ui5_context=>cv_char_util_cr_lf(1)
                      with = `&#xD;`
                      occ  = 0 ).
    result = replace( val  = result
                      sub  = z2ui5_cl_a2ui5_context=>cv_char_util_horizontal_tab
                      with = `&#x9;`
                      occ  = 0 ).

  ENDMETHOD.


  METHOD stringify.

    result = root->render( ).

  ENDMETHOD.

ENDCLASS.
