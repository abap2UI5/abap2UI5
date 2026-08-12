"! Generic UI5 XML view builder - translate a UI5 XML view 1:1 by method
"! chaining. Navigate the tree with:
"!   open  - add a child control/aggregation and DESCEND into it (returns child)
"!   leaf  - add a childless control but STAY on the current node (returns same)
"!   shut  - ASCEND to the parent (returns parent)
"!   a     - add one attribute to the control just opened/leaf'd (returns same)
"! Element = n (name), namespace prefix = ns (e.g. `f`, `core`, `l`).
"! Attributes are added with a( n = `key` v = `value` ) chained right after
"! the control's open/leaf - a always targets that control (the last child,
"! or the node itself). `v` may be any string expression (literal, a client
"! bind/event, || template). Alternatively pass attributes up front to open/leaf
"! via a = a flat table of `key=value` strings (split on the first `=`).
"! The root mvc:View element and its xmlns declarations are written by hand, exactly
"! like a real UI5 view. For a boolean from an ABAP variable, use as_bool( ).
CLASS z2ui5_cl_ai_xml DEFINITION PUBLIC CREATE PRIVATE.

  PUBLIC SECTION.

    "! attribute list - one `key=value` string per attribute, e.g.
    "! a = VALUE #( ( `text=Hello` ) ( `width=100%` ) ). Split on the first `=`.
    TYPES ty_t_attr TYPE STANDARD TABLE OF string WITH EMPTY KEY.

    "! render an ABAP boolean as the UI5 attribute value `true` / `false`,
    "! e.g. a = VALUE #( |visible={ z2ui5_cl_ai_xml=>as_bool( flag ) }| )
    CLASS-METHODS as_bool
      IMPORTING
        val           TYPE abap_bool
      RETURNING
        VALUE(result) TYPE string.

    "! returns an empty builder root; open the mvc:View element and declare the xmlns
    "! namespaces yourself, exactly like any other control:
    "!   DATA(view) = z2ui5_cl_ai_xml=>factory( ).
    "!   view->open( n = `View` ns = `mvc`
    "!       )->a( n = `xmlns`     v = `sap.m`
    "!       )->a( n = `xmlns:mvc` v = `sap.ui.core.mvc` ) ...
    CLASS-METHODS factory
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_ai_xml.

    METHODS open
      IMPORTING
        n             TYPE string
        ns            TYPE string OPTIONAL
        a             TYPE ty_t_attr OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_ai_xml.

    METHODS leaf
      IMPORTING
        n             TYPE string
        ns            TYPE string OPTIONAL
        a             TYPE ty_t_attr OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_ai_xml.

    METHODS a
      IMPORTING
        n             TYPE string
        v             TYPE string
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_ai_xml.

    METHODS shut
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_ai_xml.

    METHODS stringify
      RETURNING
        VALUE(result) TYPE string.

  PROTECTED SECTION.
    TYPES ty_t_node TYPE STANDARD TABLE OF REF TO z2ui5_cl_ai_xml WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_s_pair,
        n TYPE string,
        v TYPE string,
      END OF ty_s_pair.
    TYPES ty_t_pair TYPE STANDARD TABLE OF ty_s_pair WITH EMPTY KEY.

    DATA name   TYPE string.
    DATA prefix TYPE string.
    DATA t_pair TYPE ty_t_pair.
    DATA t_child TYPE ty_t_node.
    DATA parent TYPE REF TO z2ui5_cl_ai_xml.
    DATA root   TYPE REF TO z2ui5_cl_ai_xml.

    METHODS elem
      IMPORTING
        n             TYPE string
        ns            TYPE string
        a             TYPE ty_t_attr
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_ai_xml.

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


CLASS z2ui5_cl_ai_xml IMPLEMENTATION.

  METHOD as_bool.

    result = COND #( WHEN val = abap_true THEN `true` ELSE `false` ).

  ENDMETHOD.


  METHOD factory.

    result = NEW #( ).
    result->root = result.

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


  METHOD elem.

    result = NEW #( ).
    result->root = root.
    result->parent = me.
    result->name = n.
    result->prefix = ns.
    LOOP AT a INTO DATA(kv).
      DATA(pair) = parse_attr( kv ).
      ASSERT NOT line_exists( result->t_pair[ n = pair-n ] ).
      APPEND pair TO result->t_pair.
    ENDLOOP.
    APPEND result TO t_child.

  ENDMETHOD.


  METHOD open.

    result = elem( n  = n
                   ns = ns
                   a  = a ).

  ENDMETHOD.


  METHOD leaf.

    elem( n  = n
          ns = ns
          a  = a ).
    result = me.

  ENDMETHOD.


  METHOD a.

    " set the attribute on the element the chain is currently pointing at:
    " the just-added child (after open/leaf) or - if none yet - this node
    " itself (so attributes can be attached right after open/leaf/shut).
    " fail fast instead of dropping silently: on the empty factory root there
    " is no element to attach to, and a duplicate name renders invalid XML
    ASSERT name IS NOT INITIAL OR t_child IS NOT INITIAL.
    IF t_child IS INITIAL.
      ASSERT NOT line_exists( t_pair[ n = n ] ).
      APPEND VALUE #( n = n v = v ) TO t_pair.
    ELSE.
      DATA(target) = t_child[ lines( t_child ) ].
      ASSERT NOT line_exists( target->t_pair[ n = n ] ).
      APPEND VALUE #( n = n v = v ) TO target->t_pair.
    ENDIF.
    result = me.

  ENDMETHOD.


  METHOD shut.

    " fail fast: a shut( ) past the mvc:View root would hand back a null
    " reference that only crashes at the next chained call, far from the bug
    ASSERT parent IS BOUND.
    result = parent.

  ENDMETHOD.


  METHOD render.

    " collect the children in a table and concatenate once - the string
    " template accumulator would re-copy everything rendered so far on every
    " sibling, which grows quadratic on wide views
    DATA lt_inner TYPE string_table.
    LOOP AT t_child INTO DATA(child).
      INSERT child->render( ) INTO TABLE lt_inner.
    ENDLOOP.
    DATA(inner) = concat_lines_of( lt_inner ).

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

    " `&` must be replaced first so the entities added afterwards are not
    " escaped again. The three whitespace characters become character
    " references because XML attribute-value normalization would otherwise
    " turn a literal LF/CR/TAB into a plain space and silently drop the line
    " breaks of e.g. a two-line noDataText. The char constants come from the
    " context class - the one place allowed to reference cl_abap_char_utilities
    " (see "Utilities" in AGENTS.md). Chained replaces, no per-call escape
    " table: this method runs once per attribute of every rendered view
    " (same implementation as z2ui5_cl_ui5_view_builder=>xml_escape).
    result = replace( val  = val
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
