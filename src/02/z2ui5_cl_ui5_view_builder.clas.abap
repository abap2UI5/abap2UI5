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

  PROTECTED SECTION.
    TYPES ty_t_node TYPE STANDARD TABLE OF REF TO z2ui5_cl_ui5_view_builder WITH DEFAULT KEY.
    TYPES:
      BEGIN OF ty_s_name_value,
        n TYPE string,
        v TYPE string,
      END OF ty_s_name_value.
    TYPES ty_t_name_value TYPE STANDARD TABLE OF ty_s_name_value WITH DEFAULT KEY.

    DATA name    TYPE string.
    DATA prefix  TYPE string.
    DATA t_pair  TYPE ty_t_name_value.
    DATA t_child TYPE ty_t_node.
    DATA parent  TYPE REF TO z2ui5_cl_ui5_view_builder.
    DATA root    TYPE REF TO z2ui5_cl_ui5_view_builder.

    METHODS render
      RETURNING
        VALUE(result) TYPE string.

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
ENDCLASS.


CLASS z2ui5_cl_ui5_view_builder IMPLEMENTATION.

  METHOD factory.

    CREATE OBJECT result.
    result->root = result.

  ENDMETHOD.


  METHOD ele.

    CREATE OBJECT result.
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
    DATA val LIKE v.
      DATA temp1 TYPE string.
      DATA temp2 LIKE sy-subrc.
      DATA temp3 TYPE z2ui5_cl_ui5_view_builder=>ty_s_name_value.
      DATA target LIKE LINE OF t_child.
      FIELD-SYMBOLS <temp1> LIKE LINE OF t_child.
      DATA temp6 LIKE sy-tabix.
      DATA temp4 LIKE sy-subrc.
      DATA temp5 TYPE z2ui5_cl_ui5_view_builder=>ty_s_name_value.

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

    val = v.
    IF b IS SUPPLIED.
      ASSERT v IS INITIAL.

      IF b = abap_true.
        temp1 = `true`.
      ELSE.
        temp1 = `false`.
      ENDIF.
      val = temp1.
    ENDIF.

    IF t_child IS INITIAL.

      READ TABLE t_pair WITH KEY n = n TRANSPORTING NO FIELDS.
      temp2 = sy-subrc.
      ASSERT NOT temp2 = 0. "#EC CI_SORTSEQ

      CLEAR temp3.
      temp3-n = n.
      temp3-v = val.
      APPEND temp3 TO t_pair.
    ELSE.



      temp6 = sy-tabix.
      READ TABLE t_child INDEX lines( t_child ) ASSIGNING <temp1>.
      sy-tabix = temp6.
      IF sy-subrc <> 0.
        ASSERT 1 = 0.
      ENDIF.
      target = <temp1>.

      READ TABLE target->t_pair WITH KEY n = n TRANSPORTING NO FIELDS.
      temp4 = sy-subrc.
      ASSERT NOT temp4 = 0. "#EC CI_SORTSEQ

      CLEAR temp5.
      temp5-n = n.
      temp5-v = val.
      APPEND temp5 TO target->t_pair.
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

    " collect the children in a table and concatenate once - the string
    " template accumulator would re-copy everything rendered so far on every
    " sibling, which grows quadratic on wide views
    DATA lt_inner TYPE string_table.
    DATA child LIKE LINE OF t_child.
    DATA inner TYPE string.
    DATA temp6 TYPE string.
    DATA qname LIKE temp6.
    DATA lt_attr TYPE string_table.
    DATA pair LIKE LINE OF t_pair.
      DATA temp7 LIKE LINE OF lt_attr.
    DATA attrs TYPE string.
    LOOP AT t_child INTO child.
      INSERT child->render( ) INTO TABLE lt_inner.
    ENDLOOP.

    inner = concat_lines_of( lt_inner ).

    " empty builder root - render only the children
    IF name IS INITIAL.
      result = inner.
      RETURN.
    ENDIF.


    IF prefix IS INITIAL.
      temp6 = name.
    ELSE.
      temp6 = |{ prefix }:{ name }|.
    ENDIF.

    qname = temp6.
    " same table-then-concat form as the children above, same reason: the
    " template accumulator re-copied every attribute rendered so far on
    " each further one, quadratic on attribute-heavy elements


    LOOP AT t_pair INTO pair.

      temp7 = | { pair-n }="{ xml_escape( pair-v ) }"|.
      INSERT temp7 INTO TABLE lt_attr.
    ENDLOOP.

    attrs = concat_lines_of( lt_attr ).

    IF t_child IS INITIAL.
      result = |<{ qname }{ attrs }/>|.
    ELSE.
      result = |<{ qname }{ attrs }>{ inner }</{ qname }>|.
    ENDIF.

  ENDMETHOD.


  METHOD xml_escape.

    " one CA scan up front: replace( occ = 0 ) copies the whole string on
    " every call even when nothing matches, and a value without any special
    " character is the COMMON case - that made every attribute value pay for
    " seven full copies. A value that does carry one still runs all seven
    " replaces below, unchanged
    IF gv_escape_specials IS INITIAL.
      gv_escape_specials = `&<>"`
          && z2ui5_cl_ui5_util_context=>cv_char_util_newline
          && z2ui5_cl_ui5_util_context=>cv_char_util_cr_lf(1)
          && z2ui5_cl_ui5_util_context=>cv_char_util_horizontal_tab.
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

  ENDMETHOD.


  METHOD stringify.

    result = root->render( ).

  ENDMETHOD.

ENDCLASS.
