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
    TYPES ty_t_attr TYPE STANDARD TABLE OF string WITH DEFAULT KEY.

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
    TYPES ty_t_node TYPE STANDARD TABLE OF REF TO z2ui5_cl_ai_xml WITH DEFAULT KEY.
    TYPES:
      BEGIN OF ty_s_pair,
        n TYPE string,
        v TYPE string,
      END OF ty_s_pair.
    TYPES ty_t_pair TYPE STANDARD TABLE OF ty_s_pair WITH DEFAULT KEY.

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

    DATA temp3 TYPE string.
    IF val = abap_true.
      temp3 = `true`.
    ELSE.
      temp3 = `false`.
    ENDIF.
    result = temp3.

  ENDMETHOD.


  METHOD factory.

    CREATE OBJECT result.
    result->root = result.

  ENDMETHOD.


  METHOD parse_attr.

    DATA off TYPE i.
    off = find( val = kv
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
    DATA kv LIKE LINE OF a.
      DATA pair TYPE z2ui5_cl_ai_xml=>ty_s_pair.
      DATA temp4 LIKE sy-subrc.

    CREATE OBJECT result.
    result->root = root.
    result->parent = me.
    result->name = n.
    result->prefix = ns.

    LOOP AT a INTO kv.

      pair = parse_attr( kv ).

      READ TABLE result->t_pair WITH KEY n = pair-n TRANSPORTING NO FIELDS.
      temp4 = sy-subrc.
      ASSERT NOT temp4 = 0.
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
      DATA temp5 LIKE sy-subrc.
      DATA temp6 TYPE z2ui5_cl_ai_xml=>ty_s_pair.
      DATA target LIKE LINE OF t_child.
      DATA temp1 LIKE LINE OF t_child.
      DATA temp2 LIKE sy-tabix.
      DATA temp7 LIKE sy-subrc.
      DATA temp8 TYPE z2ui5_cl_ai_xml=>ty_s_pair.

    " set the attribute on the element the chain is currently pointing at:
    " the just-added child (after open/leaf) or - if none yet - this node
    " itself (so attributes can be attached right after open/leaf/shut).
    " fail fast instead of dropping silently: on the empty factory root there
    " is no element to attach to, and a duplicate name renders invalid XML
    ASSERT name IS NOT INITIAL OR t_child IS NOT INITIAL.
    IF t_child IS INITIAL.

      READ TABLE t_pair WITH KEY n = n TRANSPORTING NO FIELDS.
      temp5 = sy-subrc.
      ASSERT NOT temp5 = 0.

      CLEAR temp6.
      temp6-n = n.
      temp6-v = v.
      APPEND temp6 TO t_pair.
    ELSE.



      temp2 = sy-tabix.
      READ TABLE t_child INDEX lines( t_child ) INTO temp1.
      sy-tabix = temp2.
      IF sy-subrc <> 0.
        ASSERT 1 = 0.
      ENDIF.
      target = temp1.

      READ TABLE target->t_pair WITH KEY n = n TRANSPORTING NO FIELDS.
      temp7 = sy-subrc.
      ASSERT NOT temp7 = 0.

      CLEAR temp8.
      temp8-n = n.
      temp8-v = v.
      APPEND temp8 TO target->t_pair.
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

    DATA inner TYPE string.
    DATA child LIKE LINE OF t_child.
    DATA temp9 TYPE string.
    DATA qname LIKE temp9.
    DATA attrs TYPE string.
    DATA pair LIKE LINE OF t_pair.
    inner = ``.

    LOOP AT t_child INTO child.
      inner = |{ inner }{ child->render( ) }|.
    ENDLOOP.

    " empty builder root - render only the children
    IF name IS INITIAL.
      result = inner.
      RETURN.
    ENDIF.


    IF prefix IS INITIAL.
      temp9 = name.
    ELSE.
      temp9 = |{ prefix }:{ name }|.
    ENDIF.

    qname = temp9.

    attrs = ``.

    LOOP AT t_pair INTO pair.
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
    " (see "Utilities" in AGENTS.md).
    DATA temp10 TYPE ty_t_pair.
    DATA temp11 LIKE LINE OF temp10.
    DATA lt_escape LIKE temp10.
    DATA escape LIKE LINE OF lt_escape.
    CLEAR temp10.

    temp11-n = `&`.
    temp11-v = `&amp;`.
    INSERT temp11 INTO TABLE temp10.
    temp11-n = `<`.
    temp11-v = `&lt;`.
    INSERT temp11 INTO TABLE temp10.
    temp11-n = `>`.
    temp11-v = `&gt;`.
    INSERT temp11 INTO TABLE temp10.
    temp11-n = `"`.
    temp11-v = `&quot;`.
    INSERT temp11 INTO TABLE temp10.
    temp11-n = z2ui5_cl_a2ui5_context=>cv_char_util_newline.
    temp11-v = `&#xA;`.
    INSERT temp11 INTO TABLE temp10.
    temp11-n = z2ui5_cl_a2ui5_context=>cv_char_util_cr_lf(1).
    temp11-v = `&#xD;`.
    INSERT temp11 INTO TABLE temp10.
    temp11-n = z2ui5_cl_a2ui5_context=>cv_char_util_horizontal_tab.
    temp11-v = `&#x9;`.
    INSERT temp11 INTO TABLE temp10.

    lt_escape = temp10.

    result = val.

    LOOP AT lt_escape INTO escape.
      result = replace( val  = result
                        sub  = escape-n
                        with = escape-v
                        occ  = 0 ).
    ENDLOOP.

  ENDMETHOD.


  METHOD stringify.

    result = root->render( ).

  ENDMETHOD.

ENDCLASS.
