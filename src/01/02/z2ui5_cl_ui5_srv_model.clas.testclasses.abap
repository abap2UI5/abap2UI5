"------------------------------------------------------------------------
" Helper: app with a tree-like table (rows carry a sub-table and a struct)
"------------------------------------------------------------------------
CLASS ltcl_app_tree DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    TYPES:
      BEGIN OF ty_s_node,
        user      TYPE string,
        validated TYPE abap_bool,
      END OF ty_s_node.
    TYPES ty_t_nodes TYPE STANDARD TABLE OF ty_s_node WITH DEFAULT KEY.

    TYPES:
      BEGIN OF ty_s_adr,
        city TYPE string,
        zip  TYPE string,
      END OF ty_s_adr.

    TYPES:
      BEGIN OF ty_s_root,
        user    TYPE string,
        enabled TYPE abap_bool,
        s_adr   TYPE ty_s_adr,
        nodes   TYPE ty_t_nodes,
      END OF ty_s_root.
    TYPES ty_t_tree TYPE STANDARD TABLE OF ty_s_root WITH DEFAULT KEY.

    DATA mt_tree TYPE ty_t_tree.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS ltcl_app_tree IMPLEMENTATION.
  METHOD z2ui5_if_app~main ##NEEDED.
  ENDMETHOD.
ENDCLASS.


CLASS ltcl_app_typed DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    TYPES:
      BEGIN OF ty_s_pos,
        qty TYPE i,
      END OF ty_s_pos.
    TYPES ty_t_pos TYPE STANDARD TABLE OF ty_s_pos WITH DEFAULT KEY.
    " the nested shape a row delta cannot be applied to
    TYPES ty_t_pos_sorted TYPE SORTED TABLE OF ty_s_pos WITH UNIQUE KEY qty.

    " a table whose cells are NOT all strings - the only shape in which a
    " delta cell can fail to convert at all
    TYPES:
      BEGIN OF ty_s_row,
        name     TYPE string,
        price    TYPE p LENGTH 9 DECIMALS 2,
        t_pos    TYPE ty_t_pos,
        t_sorted TYPE ty_t_pos_sorted,
        " the three kinds whose wire form is ISO text, not their ABAP form
        dt       TYPE d,
        tm       TYPE t,
        ts       TYPE timestamp,
      END OF ty_s_row.
    TYPES ty_t_tab TYPE STANDARD TABLE OF ty_s_row WITH DEFAULT KEY.
    " the one table shape a row delta cannot be applied to
    TYPES ty_t_sorted TYPE SORTED TABLE OF ty_s_row WITH UNIQUE KEY name.

    DATA mt_tab TYPE ty_t_tab.
    DATA mt_sorted TYPE ty_t_sorted.
ENDCLASS.


CLASS ltcl_app_typed IMPLEMENTATION.
  METHOD z2ui5_if_app~main ##NEEDED.
  ENDMETHOD.
ENDCLASS.


" the numeric and character kinds a delta cell converts into beyond the
" packed price above: what the wire's text has to land as, exactly
CLASS ltcl_app_conv DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    TYPES:
      BEGIN OF ty_s_row,
        dec   TYPE decfloat34,
        numc  TYPE n LENGTH 5,
        " p, not int8: 7.02 has no int8 - 31 digits still hold 2^53 + 1
        big   TYPE p LENGTH 16 DECIMALS 0,
        price TYPE p LENGTH 9 DECIMALS 2,
        qty   TYPE i,
        flag  TYPE abap_bool,
        text  TYPE string,
      END OF ty_s_row.
    TYPES ty_t_row TYPE STANDARD TABLE OF ty_s_row WITH DEFAULT KEY.

    DATA mt_row TYPE ty_t_row.
ENDCLASS.


CLASS ltcl_app_conv IMPLEMENTATION.
  METHOD z2ui5_if_app~main ##NEEDED.
  ENDMETHOD.
ENDCLASS.


" the edges of a binding: a structure written as one value (its dates, its
" references), a table of references to rows, and numbers with more digits
" than a double keeps - on every road the model goes out by
CLASS ltcl_app_edge DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    TYPES:
      BEGIN OF ty_s_form,
        name TYPE string,
        dt   TYPE d,
        tm   TYPE t,
      END OF ty_s_form.
    TYPES ty_t_form TYPE STANDARD TABLE OF ty_s_form WITH DEFAULT KEY.
    TYPES:
      BEGIN OF ty_s_line,
        id     TYPE i,
        s_form TYPE ty_s_form,
      END OF ty_s_line.
    TYPES ty_t_line TYPE STANDARD TABLE OF ty_s_line WITH DEFAULT KEY.
    TYPES:
      BEGIN OF ty_s_withref,
        name TYPE string,
        r    TYPE REF TO data,
        o    TYPE REF TO object,
      END OF ty_s_withref.
    TYPES:
      BEGIN OF ty_s_row,
        name TYPE string,
        qty  TYPE i,
      END OF ty_s_row.
    TYPES ty_t_refs TYPE STANDARD TABLE OF REF TO ty_s_row WITH DEFAULT KEY.
    " the shape of a TZNTSTMPL, DEC 21,7 - more digits than a double keeps
    TYPES ty_stamp TYPE p LENGTH 11 DECIMALS 7.
    TYPES:
      BEGIN OF ty_s_wide,
        name       TYPE string,
        changed_at TYPE ty_stamp,
        big        TYPE decfloat34,
        price      TYPE p LENGTH 8 DECIMALS 2,
        ratio      TYPE f,
      END OF ty_s_wide.
    TYPES ty_t_wide TYPE STANDARD TABLE OF ty_s_wide WITH DEFAULT KEY.
    TYPES:
      BEGIN OF ty_s_deep,
        s_wide TYPE ty_s_wide,
        t_wide TYPE ty_t_wide,
      END OF ty_s_deep.

    DATA ms_form    TYPE ty_s_form.
    DATA mt_form    TYPE ty_t_form.
    DATA mt_line    TYPE ty_t_line.
    DATA ms_withref TYPE ty_s_withref.
    DATA mt_refs    TYPE ty_t_refs.
    " bound component by component - the general road's scalars
    DATA ms_wide    TYPE ty_s_wide.
    " bound whole - the fast road
    DATA ms_flat    TYPE ty_s_wide.
    DATA mt_wide    TYPE ty_t_wide.
    " a deep value - the general road, walked
    DATA ms_deep    TYPE ty_s_deep.
    DATA mv_big     TYPE decfloat34.
ENDCLASS.


CLASS ltcl_app_edge IMPLEMENTATION.
  METHOD z2ui5_if_app~main ##NEEDED.
  ENDMETHOD.
ENDCLASS.


" three levels of tables - a delta that walks two nested __delta nodes
CLASS ltcl_app_deep3 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    TYPES:
      BEGIN OF ty_s_leaf,
        qty TYPE i,
        txt TYPE string,
      END OF ty_s_leaf.
    TYPES ty_t_leaf TYPE STANDARD TABLE OF ty_s_leaf WITH DEFAULT KEY.
    TYPES:
      BEGIN OF ty_s_mid,
        name   TYPE string,
        t_leaf TYPE ty_t_leaf,
      END OF ty_s_mid.
    TYPES ty_t_mid TYPE STANDARD TABLE OF ty_s_mid WITH DEFAULT KEY.
    TYPES:
      BEGIN OF ty_s_top,
        id    TYPE string,
        t_mid TYPE ty_t_mid,
      END OF ty_s_top.
    TYPES ty_t_top TYPE STANDARD TABLE OF ty_s_top WITH DEFAULT KEY.

    DATA mt_top TYPE ty_t_top.
    DATA ms_head TYPE ty_s_leaf.
ENDCLASS.


CLASS ltcl_app_deep3 IMPLEMENTATION.
  METHOD z2ui5_if_app~main ##NEEDED.
  ENDMETHOD.
ENDCLASS.


" ---------------------------------------------------------------------------
" The shape catalogue: one attribute per FORM an app attribute can take, and
" the same invariants run over every row of mt_attri after every lifecycle
" step. A new form is one more attribute here - every test below picks it
" up. The forms and the numbering follow the test plan (S01-S30).
" ---------------------------------------------------------------------------

" a class that does NOT implement if_serializable_object: the view builder,
" the client, any helper an app keeps in an attribute. It must come back
" initial from the draft - and it must not fail the draft (S15)
CLASS ltcl_shp_dead DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PUBLIC SECTION.
    DATA mv_text TYPE string.
ENDCLASS.

CLASS ltcl_shp_dead IMPLEMENTATION.
ENDCLASS.


" a serializable helper instance with data of its own, a dref that points at
" the OUTER app's anonymous table (sample 339: mo_layout->mr_data) and a
" chain to another instance of itself (S12, S14, S18)
CLASS ltcl_shp_inner DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PUBLIC SECTION.
    INTERFACES if_serializable_object.

    TYPES:
      BEGIN OF ty_s_row,
        col1 TYPE string,
        col2 TYPE i,
      END OF ty_s_row.
    TYPES ty_t_row TYPE STANDARD TABLE OF ty_s_row WITH DEFAULT KEY.

    DATA mv_inner  TYPE string.
    DATA mt_own    TYPE ty_t_row.
    DATA mr_shared TYPE REF TO data.
    DATA mo_deeper TYPE REF TO ltcl_shp_inner.
ENDCLASS.

CLASS ltcl_shp_inner IMPLEMENTATION.
ENDCLASS.


CLASS ltcl_app_shapes DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    TYPES:
      BEGIN OF ty_s_row,
        col1 TYPE string,
        col2 TYPE i,
      END OF ty_s_row.
    TYPES ty_t_row    TYPE STANDARD TABLE OF ty_s_row WITH DEFAULT KEY.
    TYPES ty_t_sorted TYPE SORTED TABLE OF ty_s_row WITH UNIQUE KEY col1.
    " the shape of the runtime-built line: a known row plus SELKZ
    TYPES:
      BEGIN OF ty_s_row_sel,
        col1  TYPE string,
        col2  TYPE i,
        selkz TYPE abap_bool,
      END OF ty_s_row_sel.

    TYPES:
      BEGIN OF ty_s_deep,
        v1 TYPE string,
        BEGIN OF l1,
          v2 TYPE string,
          BEGIN OF l2,
            v3 TYPE string,
            BEGIN OF l3,
              v4 TYPE abap_bool,
            END OF l3,
          END OF l2,
        END OF l1,
      END OF ty_s_deep.

    TYPES:
      BEGIN OF ty_s_nested,
        id      TYPE string,
        t_items TYPE ty_t_row,
      END OF ty_s_nested.
    TYPES ty_t_nested TYPE STANDARD TABLE OF ty_s_nested WITH DEFAULT KEY.

    TYPES:
      BEGIN OF ty_s_with_oref,
        text  TYPE string,
        o_obj TYPE REF TO ltcl_shp_inner,
      END OF ty_s_with_oref.

    TYPES:
      BEGIN OF ty_s_with_dref,
        text  TYPE string,
        r_tab TYPE REF TO data,
      END OF ty_s_with_dref.

    TYPES:
      BEGIN OF ty_s_row_ref,
        id     TYPE string,
        r_elem TYPE REF TO string,
        o_obj  TYPE REF TO ltcl_shp_inner,
      END OF ty_s_row_ref.
    TYPES ty_t_row_ref TYPE STANDARD TABLE OF ty_s_row_ref WITH DEFAULT KEY.

    " S01 elementary
    DATA mv_string TYPE string.
    DATA mv_int    TYPE i.
    DATA mv_packed TYPE p LENGTH 8 DECIMALS 2.
    DATA mv_date   TYPE d.
    DATA mv_time   TYPE t.
    DATA mv_bool   TYPE abap_bool.
    DATA mv_xstr   TYPE xstring.
    " S02 flat structure, S03 four levels deep
    DATA ms_flat   TYPE ty_s_row.
    DATA ms_deep   TYPE ty_s_deep.
    " S04 standard, S05 sorted, S06 elementary line, S07 nested table
    DATA mt_std     TYPE ty_t_row.
    DATA mt_sorted  TYPE ty_t_sorted.
    DATA mt_strings TYPE string_table.
    DATA mt_nested  TYPE ty_t_nested.
    " S08 statically typed drefs
    DATA mr_typed_tab   TYPE REF TO ty_t_row.
    DATA mr_typed_struc TYPE REF TO ty_s_row.
    DATA mr_typed_elem  TYPE REF TO string.
    " S09 generic drefs created TYPE HANDLE (anonymous line type)
    DATA mr_handle_tab   TYPE REF TO data.
    DATA mr_handle_struc TYPE REF TO data.
    " S10 generic dref, elementary target
    DATA mr_elem TYPE REF TO data.
    " S11 drefs INTO other attributes
    DATA mr_alias_struc TYPE REF TO data.
    DATA mr_alias_tab   TYPE REF TO data.
    " S12 three drefs on ONE anonymous table - the third sits in mo_inner
    DATA mr_shared_a TYPE REF TO data.
    DATA mr_shared_b TYPE REF TO data.
    " S13 a dref whose target is a dref
    DATA mr_ref_ref TYPE REF TO data.
    " S14 serializable instance (with a chain inside), S15 a dead one
    DATA mo_inner TYPE REF TO ltcl_shp_inner.
    DATA mo_dead  TYPE REF TO ltcl_shp_dead.
    " S19 object as component, S20 dref as component - and both as cells
    DATA ms_with_oref TYPE ty_s_with_oref.
    DATA ms_with_dref TYPE ty_s_with_dref.
    DATA mt_rows_ref  TYPE ty_t_row_ref.
    " S25 a table whose rows hold RTTI descriptors - abap_component_tab, the
    " attribute every runtime-typed sample keeps (184, 190, 194, 199, 212)
    DATA mt_comp TYPE abap_component_tab.
    " S26 an anonymous STRUCTURE whose components are tables (194 ms_fixval)
    DATA mr_handle_nested TYPE REF TO data.
    " S27 a second helper over the same data as the first, and pointing at
    " a TYPED table attribute of the app (334: two objects, one target;
    " 347: the bound table aliased from inside a helper)
    DATA mo_inner_2 TYPE REF TO ltcl_shp_inner.
    " S28 an interface-typed reference (what a host keeps its sub-app in
    " when it is not REF TO object), S29 a table of object references
    DATA mi_app  TYPE REF TO z2ui5_if_app.
    TYPES temp1_29d92c7aed TYPE STANDARD TABLE OF REF TO ltcl_shp_inner WITH DEFAULT KEY.
DATA mt_apps TYPE temp1_29d92c7aed.
    " S30 a string with markup, quotes and a line break - what has to pass
    " the JSON writer, the asXML of the draft and the way back unchanged
    DATA mv_markup TYPE string.

    METHODS fill.
    METHODS get_protected
      RETURNING
        VALUE(result) TYPE string.
    " the address of a protected attribute - what a search for it gets
    METHODS get_protected_ref
      RETURNING
        VALUE(result) TYPE REF TO data.

  PROTECTED SECTION.
    " S23 - serialized with the rest, never dissolved, never bindable
    DATA mv_protected TYPE string.
    DATA mo_hidden    TYPE REF TO ltcl_shp_dead.
ENDCLASS.


CLASS ltcl_app_shapes IMPLEMENTATION.

  METHOD z2ui5_if_app~main ##NEEDED.
  ENDMETHOD.

  METHOD get_protected.
    result = mv_protected.
  ENDMETHOD.

  METHOD get_protected_ref.
    GET REFERENCE OF mv_protected INTO result.
  ENDMETHOD.

  METHOD fill.

    FIELD-SYMBOLS <tab>   TYPE STANDARD TABLE.
    FIELD-SYMBOLS <row>   TYPE any.
    FIELD-SYMBOLS <elem>  TYPE any.
    DATA ls_sel TYPE ty_s_row_sel.
    DATA temp1 TYPE ltcl_app_shapes=>ty_t_row.
    DATA temp2 LIKE LINE OF temp1.
    DATA temp3 TYPE ltcl_app_shapes=>ty_t_sorted.
    DATA temp4 LIKE LINE OF temp3.
    DATA temp5 TYPE string_table.
    DATA temp7 TYPE ltcl_app_shapes=>ty_t_nested.
    DATA temp8 LIKE LINE OF temp7.
    DATA temp6 TYPE ltcl_app_shapes=>ty_t_row.
    DATA temp18 LIKE LINE OF temp6.
    DATA temp20 TYPE ltcl_app_shapes=>ty_t_row.
    DATA temp21 LIKE LINE OF temp20.
    DATA temp9 TYPE ltcl_app_shapes=>ty_t_row.
    DATA temp10 LIKE LINE OF temp9.
    DATA temp11 TYPE REF TO cl_abap_structdescr.
    DATA lo_line LIKE temp11.
    DATA lt_comp TYPE abap_component_tab.
    DATA lv_flag TYPE c LENGTH 1.
    DATA temp12 TYPE abap_componentdescr.
    DATA temp22 TYPE REF TO cl_abap_datadescr.
    DATA lo_struc TYPE REF TO cl_abap_structdescr.
    DATA lo_tab TYPE REF TO cl_abap_tabledescr.
    DATA temp13 TYPE ltcl_shp_inner=>ty_t_row.
    DATA temp14 LIKE LINE OF temp13.
    DATA lt_nested_comp TYPE abap_component_tab.
    DATA temp15 TYPE abap_componentdescr.
    DATA temp23 TYPE REF TO cl_abap_datadescr.
    DATA temp16 TYPE abap_componentdescr.
    DATA temp24 TYPE REF TO cl_abap_datadescr.
    DATA lo_nested TYPE REF TO cl_abap_structdescr.
    FIELD-SYMBOLS <row_ref> TYPE ltcl_app_shapes=>ty_s_row_ref.
    DATA temp17 TYPE REF TO ltcl_shp_inner.
    FIELD-SYMBOLS <temp18> LIKE LINE OF mt_apps.
    DATA temp19 LIKE sy-tabix.

    mv_string = `text`.
    mv_int    = 42.
    mv_packed = '1234.56'.
    mv_date   = '20240115'.
    mv_time   = '123045'.
    mv_bool   = abap_true.
    mv_xstr   = 'DEADBEEF'.

    CLEAR ms_flat.
    ms_flat-col1 = `flat`.
    ms_flat-col2 = 1.
    ms_deep-v1          = `v1`.
    ms_deep-l1-v2       = `v2`.
    ms_deep-l1-l2-v3    = `v3`.
    ms_deep-l1-l2-l3-v4 = abap_true.


    CLEAR temp1.

    temp2-col1 = `a`.
    temp2-col2 = 1.
    INSERT temp2 INTO TABLE temp1.
    temp2-col1 = `b`.
    temp2-col2 = 2.
    INSERT temp2 INTO TABLE temp1.
    mt_std     = temp1.

    CLEAR temp3.

    temp4-col1 = `x`.
    temp4-col2 = 9.
    INSERT temp4 INTO TABLE temp3.
    temp4-col1 = `y`.
    temp4-col2 = 8.
    INSERT temp4 INTO TABLE temp3.
    mt_sorted  = temp3.

    CLEAR temp5.
    INSERT `one` INTO TABLE temp5.
    INSERT `two` INTO TABLE temp5.
    mt_strings = temp5.

    CLEAR temp7.

    temp8-id = `n1`.

    CLEAR temp6.

    temp18-col1 = `n1a`.
    temp18-col2 = 1.
    INSERT temp18 INTO TABLE temp6.
    temp8-t_items = temp6.
    INSERT temp8 INTO TABLE temp7.
    temp8-id = `n2`.

    CLEAR temp20.

    temp21-col1 = `n2a`.
    temp21-col2 = 2.
    INSERT temp21 INTO TABLE temp20.
    temp21-col1 = `n2b`.
    temp21-col2 = 3.
    INSERT temp21 INTO TABLE temp20.
    temp8-t_items = temp20.
    INSERT temp8 INTO TABLE temp7.
    mt_nested  = temp7.

    CREATE DATA mr_typed_tab.

    CLEAR temp9.

    temp10-col1 = `typed`.
    temp10-col2 = 7.
    INSERT temp10 INTO TABLE temp9.
    mr_typed_tab->* = temp9.
    CREATE DATA mr_typed_struc.
    CLEAR mr_typed_struc->*.
    mr_typed_struc->*-col1 = `typed-struc`.
    mr_typed_struc->*-col2 = 8.
    CREATE DATA mr_typed_elem.
    mr_typed_elem->* = `typed-elem`.

    " the anonymous line type of a runtime-built table: the components of a
    " known structure plus a field that exists in NO dictionary (SELKZ in
    " the samples)

    temp11 ?= cl_abap_typedescr=>describe_by_data( ms_flat ).

    lo_line = temp11.

    lt_comp = lo_line->get_components( ).
    " c LENGTH 1, not abap_bool: a type-pool type carries a full absolute
    " name (\TYPE-POOL=ABAP\TYPE=ABAP_BOOL) that S-RTTI resolves by name -
    " fine on a system, unknown to the NodeJS runtime, which only answers
    " for the built-in types by their anonymous names


    CLEAR temp12.
    temp12-name = `SELKZ`.

    temp22 ?= cl_abap_datadescr=>describe_by_data( lv_flag ).
    temp12-type = temp22.
    INSERT temp12 INTO TABLE lt_comp.

    lo_struc = cl_abap_structdescr=>create( lt_comp ).

    lo_tab   = cl_abap_tabledescr=>create( p_line_type  = lo_struc
                                                 p_table_kind = cl_abap_tabledescr=>tablekind_std ).

    CREATE DATA mr_handle_tab TYPE HANDLE lo_tab.
    ASSIGN mr_handle_tab->* TO <tab>.
    CLEAR ls_sel.
    ls_sel-col1 = `handle-row-1`.
    ls_sel-selkz = abap_true.
    INSERT INITIAL LINE INTO TABLE <tab> ASSIGNING <row>.
    MOVE-CORRESPONDING ls_sel TO <row>.
    CLEAR ls_sel.
    ls_sel-col1 = `handle-row-2`.
    INSERT INITIAL LINE INTO TABLE <tab> ASSIGNING <row>.
    MOVE-CORRESPONDING ls_sel TO <row>.

    CREATE DATA mr_handle_struc TYPE HANDLE lo_struc.
    ASSIGN mr_handle_struc->* TO <row>.
    CLEAR ls_sel.
    ls_sel-col1 = `handle-struc`.
    MOVE-CORRESPONDING ls_sel TO <row>.

    CREATE DATA mr_elem TYPE string.
    ASSIGN mr_elem->* TO <elem>.
    <elem> = `elem`.

    GET REFERENCE OF ms_flat INTO mr_alias_struc.
    GET REFERENCE OF mt_std INTO mr_alias_tab.

    " one data object, three references - two here, one in the helper
    CREATE DATA mr_shared_a TYPE HANDLE lo_tab.
    ASSIGN mr_shared_a->* TO <tab>.
    CLEAR ls_sel.
    ls_sel-col1 = `shared`.
    INSERT INITIAL LINE INTO TABLE <tab> ASSIGNING <row>.
    MOVE-CORRESPONDING ls_sel TO <row>.
    mr_shared_b = mr_shared_a.

    CREATE OBJECT mo_inner.
    mo_inner->mv_inner  = `inner`.

    CLEAR temp13.

    temp14-col1 = `own`.
    temp14-col2 = 5.
    INSERT temp14 INTO TABLE temp13.
    mo_inner->mt_own    = temp13.
    mo_inner->mr_shared = mr_shared_a.
    CREATE OBJECT mo_inner->mo_deeper.
    mo_inner->mo_deeper->mv_inner = `deeper`.

    CREATE OBJECT mo_inner_2.
    mo_inner_2->mv_inner  = `inner-2`.
    GET REFERENCE OF mt_std INTO mo_inner_2->mr_shared.

    CREATE OBJECT mo_dead.
    mo_dead->mv_text = `dead`.

    mt_comp = lt_comp.

    " a structure that exists at runtime only, with a table inside


    CLEAR temp15.
    temp15-name = `ID`.

    temp23 ?= cl_abap_datadescr=>describe_by_data( mv_string ).
    temp15-type = temp23.
    INSERT temp15 INTO TABLE lt_nested_comp.

    CLEAR temp16.
    temp16-name = `T_ITEMS`.

    temp24 ?= cl_abap_datadescr=>describe_by_data( mt_std ).
    temp16-type = temp24.
    INSERT temp16 INTO TABLE lt_nested_comp.
    " a variable as the handle: a method call in this position is a syntax
    " error on a system ("No method can be specified in the current
    " position"), which neither abaplint nor the transpiler model

    lo_nested = cl_abap_structdescr=>create( lt_nested_comp ).
    CREATE DATA mr_handle_nested TYPE HANDLE lo_nested.
    ASSIGN mr_handle_nested->* TO <row>.
    ASSIGN COMPONENT `T_ITEMS` OF STRUCTURE <row> TO <tab>.
    IF sy-subrc = 0.
      <tab> = mt_std.
    ENDIF.

    ms_with_oref-text  = `with-oref`.
    CREATE OBJECT ms_with_oref-o_obj.
    ms_with_oref-o_obj->mv_inner = `in-struc`.

    ms_with_dref-text = `with-dref`.
    CREATE DATA ms_with_dref-r_tab TYPE HANDLE lo_tab.
    ASSIGN ms_with_dref-r_tab->* TO <tab>.
    CLEAR ls_sel.
    ls_sel-col1 = `in-struc-tab`.
    INSERT INITIAL LINE INTO TABLE <tab> ASSIGNING <row>.
    MOVE-CORRESPONDING ls_sel TO <row>.


    INSERT INITIAL LINE INTO TABLE mt_rows_ref ASSIGNING <row_ref>.
    <row_ref>-id = `r1`.
    CREATE DATA <row_ref>-r_elem.
    <row_ref>-r_elem->* = `cell-ref`.
    CREATE OBJECT <row_ref>-o_obj.
    <row_ref>-o_obj->mv_inner = `cell-obj`.

    mv_protected = `protected`.
    CREATE OBJECT mo_hidden.


    CREATE OBJECT temp17 TYPE ltcl_shp_inner.
    INSERT temp17 INTO TABLE mt_apps.


    temp19 = sy-tabix.
    READ TABLE mt_apps INDEX 1 ASSIGNING <temp18>.
    sy-tabix = temp19.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    <temp18>->mv_inner = `in-table`.

    mv_markup = |<b>tag</b> & "quoted" 'single' \\ backslash{ z2ui5_cl_ui5_util_context=>cv_char_util_newline }second line|.

  ENDMETHOD.

ENDCLASS.


" ---------------------------------------------------------------------------
" Sample 338: a host holds its sub-app in a REF TO object and swaps it for an
" instance of ANOTHER class between two roundtrips - the rows of the old
" class stay in mt_attri with nothing to resolve to.
" ---------------------------------------------------------------------------

CLASS ltcl_shp_sub_a DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.
    DATA mt_table  TYPE REF TO data.
    DATA mo_layout TYPE REF TO ltcl_shp_inner.
    METHODS fill.
ENDCLASS.

CLASS ltcl_shp_sub_a IMPLEMENTATION.

  METHOD z2ui5_if_app~main ##NEEDED.
  ENDMETHOD.

  METHOD fill.
    FIELD-SYMBOLS <tab>  TYPE STANDARD TABLE.
    FIELD-SYMBOLS <row>  TYPE any.
    DATA lv_selkz TYPE c LENGTH 1.
    DATA ls_line  TYPE ltcl_shp_inner=>ty_s_row.
    " a runtime-built line type, like the samples: known components plus
    " a field no dictionary has
    DATA temp20 TYPE REF TO cl_abap_structdescr.
    DATA lo_line LIKE temp20.
    DATA lt_comp TYPE abap_component_tab.
    DATA temp21 TYPE abap_componentdescr.
    DATA temp25 TYPE REF TO cl_abap_datadescr.
    DATA lo_tab TYPE REF TO cl_abap_tabledescr.
    temp20 ?= cl_abap_typedescr=>describe_by_data( ls_line ).

    lo_line = temp20.

    lt_comp = lo_line->get_components( ).

    CLEAR temp21.
    temp21-name = `SELKZ`.

    temp25 ?= cl_abap_datadescr=>describe_by_data( lv_selkz ).
    temp21-type = temp25.
    INSERT temp21 INTO TABLE lt_comp.

    lo_tab = cl_abap_tabledescr=>create( p_line_type  = cl_abap_structdescr=>create( lt_comp )
                                               p_table_kind = cl_abap_tabledescr=>tablekind_std ).
    CREATE DATA mt_table TYPE HANDLE lo_tab.
    ASSIGN mt_table->* TO <tab>.
    ls_line-col1 = `a`.
    INSERT INITIAL LINE INTO TABLE <tab> ASSIGNING <row>.
    MOVE-CORRESPONDING ls_line TO <row>.
    mo_layout->mr_shared = mt_table.
  ENDMETHOD.

ENDCLASS.


CLASS ltcl_shp_sub_b DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.
    DATA mt_data TYPE REF TO data.
    DATA mo_lay  TYPE REF TO ltcl_shp_inner.
    METHODS fill.
ENDCLASS.

CLASS ltcl_shp_sub_b IMPLEMENTATION.

  METHOD z2ui5_if_app~main ##NEEDED.
  ENDMETHOD.

  METHOD fill.
    FIELD-SYMBOLS <tab>  TYPE STANDARD TABLE.
    FIELD-SYMBOLS <row>  TYPE any.
    DATA lv_selkz TYPE c LENGTH 1.
    DATA ls_line  TYPE ltcl_shp_inner=>ty_s_row.
    " a runtime-built line type, like the samples: known components plus
    " a field no dictionary has
    DATA temp22 TYPE REF TO cl_abap_structdescr.
    DATA lo_line LIKE temp22.
    DATA lt_comp TYPE abap_component_tab.
    DATA temp23 TYPE abap_componentdescr.
    DATA temp26 TYPE REF TO cl_abap_datadescr.
    DATA lo_tab TYPE REF TO cl_abap_tabledescr.
    temp22 ?= cl_abap_typedescr=>describe_by_data( ls_line ).

    lo_line = temp22.

    lt_comp = lo_line->get_components( ).

    CLEAR temp23.
    temp23-name = `SELKZ`.

    temp26 ?= cl_abap_datadescr=>describe_by_data( lv_selkz ).
    temp23-type = temp26.
    INSERT temp23 INTO TABLE lt_comp.

    lo_tab = cl_abap_tabledescr=>create( p_line_type  = cl_abap_structdescr=>create( lt_comp )
                                               p_table_kind = cl_abap_tabledescr=>tablekind_std ).
    CREATE DATA mt_data TYPE HANDLE lo_tab.
    ASSIGN mt_data->* TO <tab>.
    ls_line-col1 = `b`.
    INSERT INITIAL LINE INTO TABLE <tab> ASSIGNING <row>.
    MOVE-CORRESPONDING ls_line TO <row>.
    mo_lay->mr_shared = mt_data.
  ENDMETHOD.

ENDCLASS.


CLASS ltcl_app_host DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.
    DATA mv_selectedkey TYPE string.
    DATA mo_app         TYPE REF TO object.
ENDCLASS.

CLASS ltcl_app_host IMPLEMENTATION.
  METHOD z2ui5_if_app~main ##NEEDED.
  ENDMETHOD.
ENDCLASS.


" ---------------------------------------------------------------------------
" Sample 339 with the sort order turned around: the canonical row of a shared
" table is whichever of its rows sorts LAST in mt_attri. In 339 that is an
" outer attribute (MT_TABLE_TMP->*); here the helper's reference sorts last
" (MZ_INNER->MR_SHARED->*), so the payload lives on the NESTED object and
" the outer references are re-pointed from there.
" ---------------------------------------------------------------------------

CLASS ltcl_app_shared_last DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.
    DATA mr_table     TYPE REF TO data.
    DATA mr_table_tmp TYPE REF TO data.
    DATA mz_inner     TYPE REF TO ltcl_shp_inner.
ENDCLASS.

CLASS ltcl_app_shared_last IMPLEMENTATION.
  METHOD z2ui5_if_app~main ##NEEDED.
  ENDMETHOD.
ENDCLASS.


" ---------------------------------------------------------------------------
" Three of the small test samples as unit tests: 343 (binding a REF TO data
" itself is refused), 138 (a leaf six levels down a structure whose
" components all carry the same name) and 118 (date and time fields the
" model has to ship as they are, initial or not)
" ---------------------------------------------------------------------------

CLASS ltcl_app_samples DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    TYPES:
      BEGIN OF ty_s_row,
        id    TYPE i,
        descr TYPE string,
        adate TYPE d,
        atime TYPE t,
      END OF ty_s_row.
    TYPES ty_t_row TYPE STANDARD TABLE OF ty_s_row WITH DEFAULT KEY.

    DATA mt_rows TYPE ty_t_row.
    " a reference INTO the nested structure below - what a leaf reached
    " through it has to bind as
    DATA mr_alias TYPE REF TO data.

    DATA:
      BEGIN OF ms_data,
        BEGIN OF ms_data2,
          val TYPE string,
          BEGIN OF ms_data2,
            val TYPE string,
            BEGIN OF ms_data2,
              val TYPE string,
              BEGIN OF ms_data2,
                val TYPE string,
                BEGIN OF ms_data2,
                  val TYPE string,
                  BEGIN OF ms_data2,
                    val TYPE string,
                  END OF ms_data2,
                END OF ms_data2,
              END OF ms_data2,
            END OF ms_data2,
          END OF ms_data2,
        END OF ms_data2,
        val2 TYPE string,
      END OF ms_data.
ENDCLASS.

CLASS ltcl_app_samples IMPLEMENTATION.
  METHOD z2ui5_if_app~main ##NEEDED.
  ENDMETHOD.
ENDCLASS.


" a serializable filter - what an app's own filter class has to be to
" survive the draft (z2ui5_cl_ui5_srv_bind refuses one that is not)
CLASS ltcl_shp_filter DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PUBLIC SECTION.
    INTERFACES if_serializable_object.
    INTERFACES z2ui5_if_ui5_ajs_filter.
ENDCLASS.

CLASS ltcl_shp_filter IMPLEMENTATION.

  METHOD z2ui5_if_ui5_ajs_filter~keep_node.
    " drop an initial string leaf, keep everything else
    DATA temp1 TYPE xsdboolean.
    temp1 = boolc( is_node-type <> z2ui5_if_ui5_ajs_types=>node_type-string OR is_node-value IS NOT INITIAL ).
    rv_keep = temp1.
  ENDMETHOD.

ENDCLASS.


CLASS ltcl_00_base DEFINITION DEFERRED.
CLASS ltcl_01_dissolve DEFINITION DEFERRED.
CLASS ltcl_02_search DEFINITION DEFERRED.
CLASS ltcl_03_model_out DEFINITION DEFERRED.
CLASS ltcl_04_model_in DEFINITION DEFERRED.
CLASS ltcl_05_draft DEFINITION DEFERRED.
CLASS ltcl_06_fast_json DEFINITION DEFERRED.
CLASS ltcl_07_intf_attr DEFINITION DEFERRED.
CLASS z2ui5_cl_ui5_srv_model DEFINITION LOCAL FRIENDS ltcl_00_base ltcl_01_dissolve ltcl_02_search
                                                     ltcl_03_model_out ltcl_04_model_in ltcl_05_draft
                                                     ltcl_06_fast_json ltcl_07_intf_attr.


CLASS ltcl_00_base DEFINITION ABSTRACT
  FOR TESTING RISK LEVEL HARMLESS DURATION MEDIUM.

  PROTECTED SECTION.
    DATA mo_app   TYPE REF TO ltcl_app_shapes.
    DATA mo_model TYPE REF TO z2ui5_cl_ui5_srv_model.
    DATA mr_attri TYPE REF TO z2ui5_if_ui5_types=>ty_t_attri.
    " the names every bound row must keep across the lifecycle
    DATA mt_bound TYPE string_table.

    " a fresh model over the same fixture and attribute table
    METHODS model_renew.

    " bind one value the way _bind( ) does - through the search - and record
    " the row it landed on
    METHODS bind
      IMPORTING
        ir_val        TYPE REF TO data
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.

    " bind one value of every bindable form
    METHODS bind_all.

    " the draft roundtrip as the container runs it: srtti save, asXML of the
    " app AND of the attribute table, parse into fresh instances, load.
    " io_replace_app, when given, is put in as the app BEFORE the load - the
    " state of a restore against a live instance that changed meanwhile
    " iv_legacy strips the TYPE_NAME elements from the attribute table's
    " asXML - the draft a version before that component wrote
    METHODS roundtrip
      IMPORTING
        io_replace_app TYPE REF TO ltcl_app_shapes OPTIONAL
        iv_legacy      TYPE abap_bool OPTIONAL.

    " the asXML without every <iv_tag>...</iv_tag> element
    METHODS xml_without_tag
      IMPORTING
        iv_xml        TYPE string
        iv_tag        TYPE string
      RETURNING
        VALUE(result) TYPE string.

    " one row of mt_attri, by value - and by reference for a write
    METHODS row
      IMPORTING
        iv_name       TYPE string
      RETURNING
        VALUE(result) TYPE z2ui5_if_ui5_types=>ty_s_attri.
    METHODS row_ref
      IMPORTING
        iv_name       TYPE string
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.

    METHODS row_exists
      IMPORTING
        iv_name       TYPE string
      RETURNING
        VALUE(result) TYPE abap_bool.

    " the invariants - I1 types known, I3 reachable, I4 identity, I5 search,
    " I2/I6 model unchanged, I8 payload cleared (numbering of the test plan)
    METHODS inv_types_known.
    METHODS inv_rows_reachable.
    METHODS inv_identity_shared.
    METHODS inv_search_finds_bound.
    METHODS inv_json_unchanged
      IMPORTING
        iv_before TYPE string.
    METHODS inv_srtti_cleared.
    METHODS inv_all
      IMPORTING
        iv_before TYPE string.

  PRIVATE SECTION.
    " private, as ABAP Unit wants it - and inherited by every section
    METHODS setup.
ENDCLASS.


CLASS ltcl_00_base IMPLEMENTATION.

  METHOD setup.

    CREATE OBJECT mo_app.
    mo_app->fill( ).
    CREATE DATA mr_attri.
    model_renew( ).

  ENDMETHOD.

  METHOD model_renew.

    CREATE OBJECT mo_model EXPORTING attri = mr_attri app = mo_app.

  ENDMETHOD.

  METHOD bind.
    DATA lv_path LIKE result->name.
    DATA temp24 LIKE sy-subrc.

    result = mo_model->main_attri_search( ir_val ).
    result->bind = abap_true.
    " a path the ajson writer accepts: no `-` and no `->` inside a segment

    lv_path = result->name.
    lv_path = replace( val  = lv_path
                       sub  = `->*`
                       with = `_D`
                       occ  = 0 ).
    lv_path = replace( val  = lv_path
                       sub  = `->`
                       with = `_`
                       occ  = 0 ).
    lv_path = replace( val  = lv_path
                       sub  = `-`
                       with = `_`
                       occ  = 0 ).
    result->name_client = |/{ lv_path }|.

    READ TABLE mt_bound WITH KEY table_line = result->name TRANSPORTING NO FIELDS.
    temp24 = sy-subrc.
    IF NOT temp24 = 0.
      INSERT result->name INTO TABLE mt_bound.
    ENDIF.

  ENDMETHOD.

  METHOD bind_all.

    DATA lr_tab TYPE REF TO data.
    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
    DATA temp25 LIKE REF TO mo_app->mv_string.
    DATA temp26 LIKE REF TO mo_app->mv_int.
    DATA temp27 LIKE REF TO mo_app->mv_packed.
    DATA temp28 LIKE REF TO mo_app->mv_date.
    DATA temp29 LIKE REF TO mo_app->mv_time.
    DATA temp30 LIKE REF TO mo_app->mv_bool.
    DATA temp31 LIKE REF TO mo_app->mv_markup.
    DATA temp32 LIKE REF TO mo_app->ms_flat.
    DATA temp33 LIKE REF TO mo_app->ms_deep-l1-l2-l3-v4.
    DATA temp34 LIKE REF TO mo_app->mt_std.
    DATA temp35 LIKE REF TO mo_app->mt_sorted.
    DATA temp36 LIKE REF TO mo_app->mt_strings.
    DATA temp37 LIKE REF TO mo_app->mt_nested.
    DATA temp38 LIKE REF TO mo_app->mr_typed_struc->col1.
    DATA temp39 LIKE REF TO mo_app->mo_inner->mv_inner.
    DATA temp40 LIKE REF TO mo_app->mo_inner->mt_own.
    DATA temp41 LIKE REF TO mo_app->mo_inner->mo_deeper->mv_inner.
    DATA temp42 LIKE REF TO mo_app->mo_inner_2->mv_inner.
    DATA temp43 LIKE REF TO mo_app->ms_with_oref-o_obj->mv_inner.

    CLEAR mt_bound.

    " S01

    GET REFERENCE OF mo_app->mv_string INTO temp25.
bind( temp25 ).

    GET REFERENCE OF mo_app->mv_int INTO temp26.
bind( temp26 ).

    GET REFERENCE OF mo_app->mv_packed INTO temp27.
bind( temp27 ).

    GET REFERENCE OF mo_app->mv_date INTO temp28.
bind( temp28 ).

    GET REFERENCE OF mo_app->mv_time INTO temp29.
bind( temp29 ).

    GET REFERENCE OF mo_app->mv_bool INTO temp30.
bind( temp30 ).

    GET REFERENCE OF mo_app->mv_markup INTO temp31.
bind( temp31 ).
    " S02/S03 - the structure and a leaf four levels down

    GET REFERENCE OF mo_app->ms_flat INTO temp32.
bind( temp32 ).

    GET REFERENCE OF mo_app->ms_deep-l1-l2-l3-v4 INTO temp33.
bind( temp33 ).
    " S04-S07

    GET REFERENCE OF mo_app->mt_std INTO temp34.
bind( temp34 ).

    GET REFERENCE OF mo_app->mt_sorted INTO temp35.
bind( temp35 ).

    GET REFERENCE OF mo_app->mt_strings INTO temp36.
bind( temp36 ).

    GET REFERENCE OF mo_app->mt_nested INTO temp37.
bind( temp37 ).
    " S08 - the dereferenced data, exactly what _bind( <fs> ) hands over
    bind( mo_app->mr_typed_tab ).

    GET REFERENCE OF mo_app->mr_typed_struc->col1 INTO temp38.
bind( temp38 ).
    bind( mo_app->mr_typed_elem ).
    " S09/S10
    bind( mo_app->mr_handle_tab ).
    bind( mo_model->attri_get_val_ref( `MR_HANDLE_STRUC->COL1` ) ).
    bind( mo_app->mr_elem ).
    " S12 - the shared table through the helper's reference
    bind( mo_app->mo_inner->mr_shared ).
    " S14 - data inside the helper and its chain

    GET REFERENCE OF mo_app->mo_inner->mv_inner INTO temp39.
bind( temp39 ).

    GET REFERENCE OF mo_app->mo_inner->mt_own INTO temp40.
bind( temp40 ).

    GET REFERENCE OF mo_app->mo_inner->mo_deeper->mv_inner INTO temp41.
bind( temp41 ).
    " S26 - the table inside the anonymous structure
    bind( mo_model->attri_get_val_ref( `MR_HANDLE_NESTED->T_ITEMS` ) ).
    " S27 - the typed table, reached through the second helper's reference

    GET REFERENCE OF mo_app->mo_inner_2->mv_inner INTO temp42.
bind( temp42 ).
    " S19/S20 - through the component

    GET REFERENCE OF mo_app->ms_with_oref-o_obj->mv_inner INTO temp43.
bind( temp43 ).
    ASSIGN mo_app->ms_with_dref-r_tab->* TO <tab>.
    " into a typed variable first - the 7.02 downport declares its temporary
    " LIKE REF TO the operand, which a generic <tab> cannot give it
    GET REFERENCE OF <tab> INTO lr_tab.
    bind( lr_tab ).

  ENDMETHOD.

  METHOD roundtrip.
    DATA lv_app_xml TYPE string.
    DATA lv_attri_xml TYPE string.

    mo_model->main_attri_db_save_srtti( ).

    " the container serializes itself with the app AND mt_attri inside -
    " o_typedescr is a REF TO cl_abap_typedescr and does not survive this,
    " which is the state every restore starts from

    lv_app_xml   = z2ui5_cl_ui5_util_context=>xml_stringify( mo_app ).

    lv_attri_xml = z2ui5_cl_ui5_util_context=>xml_stringify( mr_attri->* ).
    IF iv_legacy = abap_true.
      lv_attri_xml = xml_without_tag( iv_xml = lv_attri_xml
                                      iv_tag = `TYPE_NAME` ).
    ENDIF.

    CLEAR mo_app.
    z2ui5_cl_ui5_util_context=>xml_parse( EXPORTING xml = lv_app_xml
                                          IMPORTING any = mo_app ).
    CREATE DATA mr_attri.
    z2ui5_cl_ui5_util_context=>xml_parse( EXPORTING xml = lv_attri_xml
                                          IMPORTING any = mr_attri->* ).
    IF io_replace_app IS BOUND.
      mo_app = io_replace_app.
    ENDIF.

    model_renew( ).
    mo_model->main_attri_db_load( ).

  ENDMETHOD.

  METHOD xml_without_tag.
    DATA lv_open TYPE string.
    DATA lv_close TYPE string.
      DATA lv_from TYPE i.
      DATA lv_to TYPE i.
      DATA lv_end TYPE i.

    " both spellings of the element: with a value, and the empty one
    result = iv_xml.

    lv_open  = |<{ iv_tag }>|.

    lv_close = |</{ iv_tag }>|.
    DO.

      lv_from = find( val = result
                            sub = lv_open ).
      IF lv_from < 0.
        EXIT.
      ENDIF.

      lv_to = find( val = result
                          sub = lv_close ).
      IF lv_to < 0 OR lv_to < lv_from.
        EXIT.
      ENDIF.

      lv_end = lv_to + strlen( lv_close ).
      result = result(lv_from) && result+lv_end.
    ENDDO.
    result = replace( val  = result
                      sub  = |<{ iv_tag }/>|
                      with = ``
                      occ  = 0 ).

  ENDMETHOD.

  METHOD row.

    " no chained dereference of a functional method call - 7.50 rejects
    " `row_ref( ... )->*`, the reference needs its own variable first
    DATA lr_row TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.
    lr_row = row_ref( iv_name ).
    result = lr_row->*.

  ENDMETHOD.

  METHOD row_ref.

    FIELD-SYMBOLS <attri> TYPE z2ui5_if_ui5_types=>ty_s_attri.
    READ TABLE mr_attri->* WITH KEY name = iv_name ASSIGNING <attri>.
    IF <attri> IS NOT ASSIGNED.
      cl_abap_unit_assert=>fail( |no row { iv_name }| ).
      RETURN.
    ENDIF.
    GET REFERENCE OF <attri> INTO result.

  ENDMETHOD.

  METHOD row_exists.

    DATA temp44 LIKE sy-subrc.
    DATA temp2 TYPE xsdboolean.
    READ TABLE mr_attri->* WITH KEY name = iv_name TRANSPORTING NO FIELDS.
    temp44 = sy-subrc.

    temp2 = boolc( temp44 = 0 ).
    result = temp2.

  ENDMETHOD.

  METHOD inv_types_known.

    " I1 - every row knows its type across the draft: the absolute name
    " travels as a string on the row (the search prefilters by it), while
    " the descriptor object is rebuilt only where the restore parses a
    " payload. A row without a name is a draft written before the name
    " existed - not a state a roundtrip of THIS version may produce
    DATA temp45 LIKE LINE OF mr_attri->*.
    DATA lr_attri LIKE REF TO temp45.
    DATA lv_name LIKE LINE OF mt_bound.
      DATA ls_row TYPE z2ui5_if_ui5_types=>ty_s_attri.
      DATA ls_parent TYPE z2ui5_if_ui5_types=>ty_s_attri.
    LOOP AT mr_attri->* REFERENCE INTO lr_attri.
      cl_abap_unit_assert=>assert_not_initial( act = lr_attri->type_name
                                               msg = |I1: no type name on { lr_attri->name }| ).
      cl_abap_unit_assert=>assert_not_initial( act = lr_attri->type_kind
                                               msg = |I1: no type kind on { lr_attri->name }| ).
    ENDLOOP.
    " ...and the payload rows carry their descriptor again

    LOOP AT mt_bound INTO lv_name.

      ls_row = row( lv_name ).
      IF ls_row-name_parent IS INITIAL OR ls_row-name_ref IS NOT INITIAL.
        CONTINUE.
      ENDIF.

      ls_parent = row( ls_row-name_parent ).
      IF ls_parent-type_kind <> z2ui5_cl_ui5_util_context=>cv_typedescr_typekind_dref.
        CONTINUE.
      ENDIF.
      cl_abap_unit_assert=>assert_bound( act = ls_parent-o_typedescr
                                         msg = |I1: no descriptor on the restored { ls_parent-name }| ).
    ENDLOOP.

  ENDMETHOD.

  METHOD inv_rows_reachable.

    " I3 - every row names data that exists on the instance
    DATA temp46 LIKE LINE OF mr_attri->*.
    DATA lr_attri LIKE REF TO temp46.
          DATA lr_ref TYPE REF TO data.
    LOOP AT mr_attri->* REFERENCE INTO lr_attri.
      IF lr_attri->name CP `MO_DEAD->*`.
        CONTINUE.
      ENDIF.
      TRY.

          lr_ref = mo_model->attri_get_val_ref( lr_attri->name ).
          cl_abap_unit_assert=>assert_bound( act = lr_ref
                                             msg = |I3: { lr_attri->name } not reachable| ).
        CATCH cx_root.
          cl_abap_unit_assert=>fail( |I3: { lr_attri->name } not reachable| ).
      ENDTRY.
    ENDLOOP.

  ENDMETHOD.

  METHOD inv_identity_shared.
    DATA temp3 TYPE xsdboolean.
    DATA temp4 TYPE xsdboolean.
    DATA temp5 TYPE xsdboolean.
    DATA lr_flat LIKE REF TO mo_app->ms_flat.
    DATA lr_std LIKE REF TO mo_app->mt_std.
    DATA temp6 TYPE xsdboolean.
    DATA temp7 TYPE xsdboolean.
    DATA temp8 TYPE xsdboolean.

    " I4 - references that shared a data object share ONE again (identity,
    " not content: the sample toasts compare content and would miss a copy)
    cl_abap_unit_assert=>assert_bound( act = mo_app->mr_shared_a
                                       msg = `I4: mr_shared_a lost` ).

    temp3 = boolc( mo_app->mr_shared_a = mo_app->mr_shared_b ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp3
                                      msg = `I4: mr_shared_a and mr_shared_b are two objects now` ).

    temp4 = boolc( mo_app->mr_shared_a = mo_app->mo_inner->mr_shared ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp4
                                      msg = `I4: the helper's mr_shared is a copy` ).
    " ...two helpers stay two objects (334)...

    temp5 = boolc( mo_app->mo_inner <> mo_app->mo_inner_2 ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp5
                                      msg = `I4: the two helpers collapsed into one object` ).
    " ...and the aliases point INTO their owner again, the one inside the
    " second helper included (347)

    GET REFERENCE OF mo_app->ms_flat INTO lr_flat.

    GET REFERENCE OF mo_app->mt_std INTO lr_std.

    temp6 = boolc( mo_app->mr_alias_struc = lr_flat ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp6
                                      msg = `I4: mr_alias_struc detached from ms_flat` ).

    temp7 = boolc( mo_app->mr_alias_tab = lr_std ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp7
                                      msg = `I4: mr_alias_tab detached from mt_std` ).

    temp8 = boolc( mo_app->mo_inner_2->mr_shared = lr_std ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp8
                                      msg = `I4: the helper's alias of mt_std is a copy` ).

  ENDMETHOD.

  METHOD inv_search_finds_bound.

    " I5 - the binding search answers with the same row for every bound
    " attribute, on the instance as it is NOW
    DATA lv_name LIKE LINE OF mt_bound.
      DATA lr_ref TYPE REF TO data.
      DATA lr_attri TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.
    LOOP AT mt_bound INTO lv_name.

      lr_ref = mo_model->attri_get_val_ref( lv_name ).

      lr_attri = mo_model->main_attri_search( lr_ref ).
      cl_abap_unit_assert=>assert_equals( act = lr_attri->name
                                          exp = lv_name
                                          msg = |I5: { lv_name } found as { lr_attri->name }| ).
    ENDLOOP.

  ENDMETHOD.

  METHOD inv_json_unchanged.

    " I2/I6 - the model the next render ships is the model before the save
    DATA lv_after TYPE string.
    DATA lv_name LIKE LINE OF mt_bound.
      DATA lv_key TYPE string.
      DATA temp9 TYPE xsdboolean.
    lv_after = mo_model->main_json_stringify( ).
    cl_abap_unit_assert=>assert_equals( act = lv_after
                                        exp = iv_before
                                        msg = `I2: the model changed across the draft` ).

    LOOP AT mt_bound INTO lv_name.

      lv_key = substring( val = row( lv_name )-name_client
                                off = 1 ).

      temp9 = boolc( lv_after CS |"{ lv_key }"| ).
      cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp9
                                        msg = |I6: { lv_name } missing from the model| ).
    ENDLOOP.

  ENDMETHOD.

  METHOD inv_srtti_cleared.

    " I8 - a successful restore leaves no payload behind
    DATA temp47 LIKE LINE OF mr_attri->*.
    DATA lr_attri LIKE REF TO temp47.
    LOOP AT mr_attri->* REFERENCE INTO lr_attri "#EC CI_SORTSEQ
         WHERE srtti_data IS NOT INITIAL.
      cl_abap_unit_assert=>fail( |I8: { lr_attri->name } still carries srtti_data| ).
    ENDLOOP.

  ENDMETHOD.

  METHOD inv_all.

    inv_types_known( ).
    inv_rows_reachable( ).
    inv_identity_shared( ).
    inv_search_finds_bound( ).
    inv_json_unchanged( iv_before ).
    inv_srtti_cleared( ).

  ENDMETHOD.

ENDCLASS.


" ---------------------------------------------------------------------------
" 01 DISSOLVE - the attributes of the app become the rows of mt_attri
" ---------------------------------------------------------------------------
CLASS ltcl_01_dissolve DEFINITION INHERITING FROM ltcl_00_base FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION MEDIUM.

  PRIVATE SECTION.
    " every form gets its rows, protected attributes get none
    METHODS rows_per_form            FOR TESTING RAISING cx_static_check.
    " a row knows what it is
    METHODS row_kinds                FOR TESTING RAISING cx_static_check.
    " a reference INTO another attribute knows its owner (name_ref), and so
    " do the children it fans out into
    METHODS aliases_know_owner       FOR TESTING RAISING cx_static_check.
    " of several references to one data object exactly one row is canonical
    METHODS shared_one_canonical     FOR TESTING RAISING cx_static_check.
    " a structure is followed to its last level, however deep
    METHODS deep_struct_every_level  FOR TESTING RAISING cx_static_check.
    " an object graph that points back at itself ends at the hop limit
    METHODS cycle_self_ends          FOR TESTING RAISING cx_static_check.
    METHODS cycle_two_objects_ends   FOR TESTING RAISING cx_static_check.
    " a table of objects is a leaf - its rows are not attributes
    METHODS table_of_objects_is_leaf FOR TESTING RAISING cx_static_check.
    " an interface-typed reference is followed like a class-typed one
    METHODS interface_ref_followed   FOR TESTING RAISING cx_static_check.
    " a refresh rebuilds the rows and keeps what a bind wrote on them
    METHODS refresh_keeps_bindings   FOR TESTING RAISING cx_static_check.
    " ... and the window of a window_bind_tab( ) table with its total and event
    METHODS refresh_keeps_window     FOR TESTING RAISING cx_static_check.
    " a refresh finds an object that was initial at the first dissolve
    METHODS refresh_finds_late_obj   FOR TESTING RAISING cx_static_check.
    " a refresh drops the rows of an object that is gone
    METHODS refresh_drops_orphans    FOR TESTING RAISING cx_static_check.
    " dissolving twice changes nothing
    METHODS dissolve_idempotent      FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_01_dissolve IMPLEMENTATION.

  METHOD rows_per_form.
    DATA temp48 TYPE string_table.
    DATA lt_expected LIKE temp48.
    DATA lv_name LIKE LINE OF lt_expected.
    DATA temp10 TYPE xsdboolean.
    DATA temp1 LIKE sy-subrc.

    mo_model->main_attri_refresh( ).


    CLEAR temp48.
    INSERT `MV_STRING` INTO TABLE temp48.
    INSERT `MV_PACKED` INTO TABLE temp48.
    INSERT `MV_XSTR` INTO TABLE temp48.
    INSERT `MV_MARKUP` INTO TABLE temp48.
    INSERT `MS_FLAT` INTO TABLE temp48.
    INSERT `MS_FLAT-COL1` INTO TABLE temp48.
    INSERT `MS_DEEP` INTO TABLE temp48.
    INSERT `MS_DEEP-L1` INTO TABLE temp48.
    INSERT `MS_DEEP-L1-L2` INTO TABLE temp48.
    INSERT `MS_DEEP-L1-L2-L3` INTO TABLE temp48.
    INSERT `MS_DEEP-L1-L2-L3-V4` INTO TABLE temp48.
    INSERT `MT_STD` INTO TABLE temp48.
    INSERT `MT_SORTED` INTO TABLE temp48.
    INSERT `MT_STRINGS` INTO TABLE temp48.
    INSERT `MT_NESTED` INTO TABLE temp48.
    INSERT `MR_TYPED_TAB` INTO TABLE temp48.
    INSERT `MR_TYPED_TAB->*` INTO TABLE temp48.
    INSERT `MR_TYPED_STRUC` INTO TABLE temp48.
    INSERT `MR_TYPED_STRUC->COL1` INTO TABLE temp48.
    INSERT `MR_TYPED_ELEM` INTO TABLE temp48.
    INSERT `MR_TYPED_ELEM->*` INTO TABLE temp48.
    INSERT `MR_HANDLE_TAB` INTO TABLE temp48.
    INSERT `MR_HANDLE_TAB->*` INTO TABLE temp48.
    INSERT `MR_HANDLE_STRUC` INTO TABLE temp48.
    INSERT `MR_HANDLE_STRUC->SELKZ` INTO TABLE temp48.
    INSERT `MR_ELEM` INTO TABLE temp48.
    INSERT `MR_ELEM->*` INTO TABLE temp48.
    INSERT `MR_ALIAS_STRUC` INTO TABLE temp48.
    INSERT `MR_ALIAS_STRUC->COL1` INTO TABLE temp48.
    INSERT `MR_ALIAS_TAB` INTO TABLE temp48.
    INSERT `MR_ALIAS_TAB->*` INTO TABLE temp48.
    INSERT `MR_SHARED_A` INTO TABLE temp48.
    INSERT `MR_SHARED_A->*` INTO TABLE temp48.
    INSERT `MR_SHARED_B->*` INTO TABLE temp48.
    INSERT `MR_REF_REF` INTO TABLE temp48.
    INSERT `MO_INNER` INTO TABLE temp48.
    INSERT `MO_INNER->MV_INNER` INTO TABLE temp48.
    INSERT `MO_INNER->MT_OWN` INTO TABLE temp48.
    INSERT `MO_INNER->MR_SHARED` INTO TABLE temp48.
    INSERT `MO_INNER->MR_SHARED->*` INTO TABLE temp48.
    INSERT `MO_INNER->MO_DEEPER` INTO TABLE temp48.
    INSERT `MO_INNER->MO_DEEPER->MV_INNER` INTO TABLE temp48.
    INSERT `MO_DEAD` INTO TABLE temp48.
    INSERT `MO_DEAD->MV_TEXT` INTO TABLE temp48.
    INSERT `MS_WITH_OREF-O_OBJ` INTO TABLE temp48.
    INSERT `MS_WITH_OREF-O_OBJ->MV_INNER` INTO TABLE temp48.
    INSERT `MS_WITH_DREF-R_TAB` INTO TABLE temp48.
    INSERT `MS_WITH_DREF-R_TAB->*` INTO TABLE temp48.
    INSERT `MT_ROWS_REF` INTO TABLE temp48.
    INSERT `MT_COMP` INTO TABLE temp48.
    INSERT `MT_APPS` INTO TABLE temp48.
    INSERT `MI_APP` INTO TABLE temp48.
    INSERT `MR_HANDLE_NESTED` INTO TABLE temp48.
    INSERT `MR_HANDLE_NESTED->ID` INTO TABLE temp48.
    INSERT `MR_HANDLE_NESTED->T_ITEMS` INTO TABLE temp48.
    INSERT `MO_INNER_2` INTO TABLE temp48.
    INSERT `MO_INNER_2->MR_SHARED` INTO TABLE temp48.

    lt_expected = temp48.


    LOOP AT lt_expected INTO lv_name.
      cl_abap_unit_assert=>assert_equals( exp = abap_true act = row_exists( lv_name )
                                        msg = |no row for { lv_name }| ).
    ENDLOOP.

    " protected attributes are not dissolved - nothing can bind them
    cl_abap_unit_assert=>assert_equals( exp = abap_false act = row_exists( `MV_PROTECTED` ) ).
    cl_abap_unit_assert=>assert_equals( exp = abap_false act = row_exists( `MO_HIDDEN` ) ).

    " every row is done - nothing pending after a full refresh


    READ TABLE mr_attri->* WITH KEY check_dissolved = abap_false TRANSPORTING NO FIELDS.
    temp1 = sy-subrc.
    temp10 = boolc( temp1 = 0 ).
    cl_abap_unit_assert=>assert_equals( exp = abap_false act = temp10 ). "#EC CI_SORTSEQ

  ENDMETHOD.

  METHOD row_kinds.

    mo_model->main_attri_refresh( ).

    cl_abap_unit_assert=>assert_equals( exp = cl_abap_datadescr=>typekind_string
                                        act = row( `MV_STRING` )-type_kind ).
    cl_abap_unit_assert=>assert_equals( exp = cl_abap_typedescr=>kind_elem
                                        act = row( `MV_INT` )-kind ).
    cl_abap_unit_assert=>assert_equals( exp = cl_abap_datadescr=>typekind_table
                                        act = row( `MT_STD` )-type_kind ).
    cl_abap_unit_assert=>assert_equals( exp = cl_abap_datadescr=>typekind_oref
                                        act = row( `MO_INNER` )-type_kind ).
    cl_abap_unit_assert=>assert_equals( exp = cl_abap_datadescr=>typekind_dref
                                        act = row( `MR_HANDLE_TAB` )-type_kind ).
    cl_abap_unit_assert=>assert_equals( exp = cl_abap_datadescr=>typekind_table
                                        act = row( `MR_HANDLE_TAB->*` )-type_kind ).
    cl_abap_unit_assert=>assert_equals( exp = `MR_HANDLE_TAB`
                                        act = row( `MR_HANDLE_TAB->*` )-name_parent ).
    cl_abap_unit_assert=>assert_equals( exp = `MO_INNER`
                                        act = row( `MO_INNER->MV_INNER` )-name_parent ).

  ENDMETHOD.

  METHOD aliases_know_owner.

    mo_model->main_attri_refresh( ).

    " the reference to a structure attribute, and its children
    cl_abap_unit_assert=>assert_equals( exp = `MS_FLAT`
                                        act = row( `MR_ALIAS_STRUC` )-name_ref ).
    cl_abap_unit_assert=>assert_equals( exp = `MS_FLAT-COL1`
                                        act = row( `MR_ALIAS_STRUC->COL1` )-name_ref ).
    " the reference to a table attribute
    cl_abap_unit_assert=>assert_equals( exp = `MT_STD`
                                        act = row( `MR_ALIAS_TAB->*` )-name_ref ).
    " the same from inside a helper object (347)
    cl_abap_unit_assert=>assert_equals( exp = `MT_STD`
                                        act = row( `MO_INNER_2->MR_SHARED->*` )-name_ref ).
    " a reference to its OWN data object owns it
    cl_abap_unit_assert=>assert_initial( row( `MR_HANDLE_TAB->*` )-name_ref ).

  ENDMETHOD.

  METHOD shared_one_canonical.
    DATA lv_canonical TYPE i.

    mo_model->main_attri_refresh( ).


    lv_canonical = 0.
    LOOP AT mr_attri->* TRANSPORTING NO FIELDS "#EC CI_SORTSEQ
         WHERE ( name = `MR_SHARED_A->*` OR name = `MR_SHARED_B->*` OR name = `MO_INNER->MR_SHARED->*` )
           AND name_ref IS INITIAL.
      lv_canonical = lv_canonical + 1.
    ENDLOOP.
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lv_canonical
                                        msg = `the shared table needs exactly one canonical row` ).
    " and it is the one that sorts last - the contract the draft relies on
    " (the payload is stored on the canonical row's parent)
    cl_abap_unit_assert=>assert_initial( row( `MR_SHARED_B->*` )-name_ref ).
    cl_abap_unit_assert=>assert_equals( exp = `MR_SHARED_B->*`
                                        act = row( `MR_SHARED_A->*` )-name_ref ).
    cl_abap_unit_assert=>assert_equals( exp = `MR_SHARED_B->*`
                                        act = row( `MO_INNER->MR_SHARED->*` )-name_ref ).

  ENDMETHOD.

  METHOD deep_struct_every_level.

    " sample 138: a leaf seven components down, every level of the same name
    DATA lo_app TYPE REF TO ltcl_app_samples.
    DATA lt_attri TYPE z2ui5_if_ui5_types=>ty_t_attri.
    DATA temp50 LIKE REF TO lt_attri.
DATA lo_model TYPE REF TO z2ui5_cl_ui5_srv_model.
    DATA temp11 TYPE xsdboolean.
    DATA temp2 LIKE sy-subrc.
    DATA temp12 TYPE xsdboolean.
    DATA temp3 LIKE sy-subrc.
    CREATE OBJECT lo_app TYPE ltcl_app_samples.


    GET REFERENCE OF lt_attri INTO temp50.

CREATE OBJECT lo_model TYPE z2ui5_cl_ui5_srv_model EXPORTING attri = temp50 app = lo_app.
    lo_model->main_attri_refresh( ).



    READ TABLE lt_attri WITH KEY name = `MS_DATA-MS_DATA2-MS_DATA2-MS_DATA2-MS_DATA2-MS_DATA2-MS_DATA2-VAL` TRANSPORTING NO FIELDS.
    temp2 = sy-subrc.
    temp11 = boolc( temp2 = 0 ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp11 ).


    READ TABLE lt_attri WITH KEY check_dissolved = abap_false TRANSPORTING NO FIELDS.
    temp3 = sy-subrc.
    temp12 = boolc( temp3 = 0 ).
    cl_abap_unit_assert=>assert_equals( exp = abap_false act = temp12 ). "#EC CI_SORTSEQ

  ENDMETHOD.

  METHOD cycle_self_ends.
    DATA lv_deepest TYPE i.
    DATA temp51 LIKE LINE OF mr_attri->*.
    DATA lr_attri LIKE REF TO temp51.
      DATA lv_hops TYPE i.
    DATA temp13 TYPE xsdboolean.
    DATA temp14 TYPE xsdboolean.
    DATA temp4 LIKE sy-subrc.

    mo_app->mo_inner->mo_deeper = mo_app->mo_inner.
    mo_model->main_attri_refresh( ).

    cl_abap_unit_assert=>assert_equals( exp = abap_true act = row_exists( `MO_INNER->MO_DEEPER->MO_DEEPER->MV_INNER` ) ).

    lv_deepest = 0.


    LOOP AT mr_attri->* REFERENCE INTO lr_attri.

      lv_hops = count( val = lr_attri->name
                             sub = `->` ).
      IF lv_hops > lv_deepest.
        lv_deepest = lv_hops.
      ENDIF.
    ENDLOOP.

    temp13 = boolc( lv_deepest <= 5 ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp13
                                      msg = |the cycle ran { lv_deepest } hops deep| ).


    READ TABLE mr_attri->* WITH KEY check_dissolved = abap_false TRANSPORTING NO FIELDS.
    temp4 = sy-subrc.
    temp14 = boolc( temp4 = 0 ).
    cl_abap_unit_assert=>assert_equals( exp = abap_false act = temp14 ). "#EC CI_SORTSEQ

  ENDMETHOD.

  METHOD cycle_two_objects_ends.
    DATA lv_deepest TYPE i.
    DATA temp52 LIKE LINE OF mr_attri->*.
    DATA lr_attri LIKE REF TO temp52.
      DATA lv_hops TYPE i.
    DATA temp15 TYPE xsdboolean.
    DATA temp16 TYPE xsdboolean.
    DATA temp5 LIKE sy-subrc.

    " A holds B, B holds A - the hop count is the only thing that ends it
    mo_app->mo_inner->mo_deeper   = mo_app->mo_inner_2.
    mo_app->mo_inner_2->mo_deeper = mo_app->mo_inner.
    mo_model->main_attri_refresh( ).

    cl_abap_unit_assert=>assert_equals( exp = abap_true act = row_exists( `MO_INNER->MO_DEEPER->MO_DEEPER->MV_INNER` ) ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = row_exists( `MO_INNER_2->MO_DEEPER->MO_DEEPER->MV_INNER` ) ).

    lv_deepest = 0.


    LOOP AT mr_attri->* REFERENCE INTO lr_attri.

      lv_hops = count( val = lr_attri->name
                             sub = `->` ).
      IF lv_hops > lv_deepest.
        lv_deepest = lv_hops.
      ENDIF.
    ENDLOOP.

    temp15 = boolc( lv_deepest <= 5 ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp15 ).


    READ TABLE mr_attri->* WITH KEY check_dissolved = abap_false TRANSPORTING NO FIELDS.
    temp5 = sy-subrc.
    temp16 = boolc( temp5 = 0 ).
    cl_abap_unit_assert=>assert_equals( exp = abap_false act = temp16 ). "#EC CI_SORTSEQ

  ENDMETHOD.

  METHOD table_of_objects_is_leaf.

    mo_model->main_attri_refresh( ).

    cl_abap_unit_assert=>assert_equals( exp = abap_true act = row_exists( `MT_APPS` ) ).
    cl_abap_unit_assert=>assert_equals( exp = cl_abap_datadescr=>typekind_table
                                        act = row( `MT_APPS` )-type_kind ).
    LOOP AT mr_attri->* TRANSPORTING NO FIELDS "#EC CI_SORTSEQ
         WHERE name CP `MT_APPS-*` OR name CP `MT_APPS->*`.
      cl_abap_unit_assert=>fail( `the rows of a table of objects are not attributes` ).
    ENDLOOP.

  ENDMETHOD.

  METHOD interface_ref_followed.

    " S28 - a REF TO z2ui5_if_app holding another instance of the app class
    DATA lo_other TYPE REF TO ltcl_app_shapes.
    DATA temp53 LIKE REF TO lo_other->mv_string.
DATA lr_attri TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.
    CREATE OBJECT lo_other TYPE ltcl_app_shapes.
    lo_other->mv_string = `other`.
    mo_app->mi_app = lo_other.
    mo_model->main_attri_refresh( ).

    cl_abap_unit_assert=>assert_equals( exp = abap_true act = row_exists( `MI_APP->MV_STRING` ) ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = row_exists( `MI_APP->MT_STD` ) ).

    GET REFERENCE OF lo_other->mv_string INTO temp53.

lr_attri = mo_model->main_attri_search( temp53 ).
    cl_abap_unit_assert=>assert_equals( exp = `MI_APP->MV_STRING`
                                        act = lr_attri->name ).

  ENDMETHOD.

  METHOD refresh_keeps_bindings.

    DATA temp54 LIKE REF TO mo_app->ms_flat.
DATA lr_attri TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.
    DATA temp55 LIKE REF TO mo_app->mv_string.
DATA lr_json TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.
    DATA lr_after TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.
    GET REFERENCE OF mo_app->ms_flat INTO temp54.

lr_attri = bind( temp54 ).
    CREATE OBJECT lr_attri->custom_filter TYPE ltcl_shp_filter.
    lr_attri->check_json    = abap_false.

    GET REFERENCE OF mo_app->mv_string INTO temp55.

lr_json = bind( temp55 ).
    lr_json->check_json = abap_true.

    mo_model->main_attri_refresh( ).


    lr_after = row_ref( `MS_FLAT` ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = lr_after->bind ).
    cl_abap_unit_assert=>assert_equals( exp = `/MS_FLAT`
                                        act = lr_after->name_client ).
    cl_abap_unit_assert=>assert_bound( lr_after->custom_filter ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = row( `MV_STRING` )-check_json ).

  ENDMETHOD.

  METHOD refresh_keeps_window.

    DATA temp56 LIKE REF TO mo_app->mt_std.
DATA lr_attri TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.
    DATA lr_after TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.
    GET REFERENCE OF mo_app->mt_std INTO temp56.

lr_attri = bind( temp56 ).
    lr_attri->window_size  = 100.
    lr_attri->window_total = 5000.
    lr_attri->window_event = `ROWS`.

    mo_model->main_attri_refresh( ).


    lr_after = row_ref( `MT_STD` ).
    cl_abap_unit_assert=>assert_equals( exp = 100
                                        act = lr_after->window_size ).
    cl_abap_unit_assert=>assert_equals( exp = 5000
                                        act = lr_after->window_total ).
    cl_abap_unit_assert=>assert_equals( exp = `ROWS`
                                        act = lr_after->window_event ).

  ENDMETHOD.

  METHOD refresh_finds_late_obj.
    DATA temp57 LIKE REF TO mo_app->mv_string.

    " the app creates its helper AFTER the first bind (sample 117: mo_app is
    " created in render_sub_app, the host's own view was bound before)
    CLEAR mo_app->mi_app.

    GET REFERENCE OF mo_app->mv_string INTO temp57.
bind( temp57 ).
    cl_abap_unit_assert=>assert_equals( exp = abap_false act = row_exists( `MI_APP->MV_STRING` ) ).

    CREATE OBJECT mo_app->mi_app TYPE ltcl_app_shapes.
    mo_model->main_attri_refresh( ).

    cl_abap_unit_assert=>assert_equals( exp = abap_true act = row_exists( `MI_APP->MV_STRING` ) ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = row( `MV_STRING` )-bind ).

  ENDMETHOD.

  METHOD refresh_drops_orphans.

    mo_model->main_attri_refresh( ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = row_exists( `MO_DEAD->MV_TEXT` ) ).

    CLEAR mo_app->mo_dead.
    mo_model->main_attri_refresh( ).

    cl_abap_unit_assert=>assert_equals( exp = abap_true act = row_exists( `MO_DEAD` ) ).
    cl_abap_unit_assert=>assert_equals( exp = abap_false act = row_exists( `MO_DEAD->MV_TEXT` ) ).

  ENDMETHOD.

  METHOD dissolve_idempotent.
    DATA lv_rows TYPE i.

    mo_model->main_attri_refresh( ).

    lv_rows = lines( mr_attri->* ).
    mo_model->dissolve( ).
    mo_model->dissolve( ).
    cl_abap_unit_assert=>assert_equals( exp = lv_rows
                                        act = lines( mr_attri->* ) ).

  ENDMETHOD.

ENDCLASS.


" ---------------------------------------------------------------------------
" 02 SEARCH - a value handed to _bind( ) is found as the row it belongs to
" ---------------------------------------------------------------------------
CLASS ltcl_02_search DEFINITION INHERITING FROM ltcl_00_base FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION MEDIUM.

  PRIVATE SECTION.
    " every bindable form is found as its own row
    METHODS every_form_found          FOR TESTING RAISING cx_static_check.
    " a value reached by name - the addresses the search compares against
    METHODS address_per_form          FOR TESTING RAISING cx_static_check.
    " an alias binds as its OWNER - the model writes the owner's path
    METHODS alias_binds_as_owner      FOR TESTING RAISING cx_static_check.
    " three references to one table bind to the one canonical row
    METHODS shared_binds_canonical    FOR TESTING RAISING cx_static_check.
    " a reference itself is refused (sample 343)
    METHODS reference_itself_refused  FOR TESTING RAISING cx_static_check.
    " a leaf deeper than one dissolve pass reaches (sample 138)
    METHODS deep_leaf_found           FOR TESTING RAISING cx_static_check.
    " a leaf two levels below a reference INTO a structure binds as the
    " owner's leaf - the rows under a struct alias know their owner at
    " every depth, not only at the first
    METHODS alias_grandchild_as_owner FOR TESTING RAISING cx_static_check.
    " a row without a descriptor is passed over, not dumped on
    METHODS unreachable_row_skipped   FOR TESTING RAISING cx_static_check.
    " a value that is not there yet: the search dissolves, then refreshes
    METHODS search_refreshes_late_obj FOR TESTING RAISING cx_static_check.
    " a value that belongs to no public attribute is a named error
    METHODS unknown_value_is_error    FOR TESTING RAISING cx_static_check.
    " a value re-created in main( ) - a new object under the same name - is
    " found as that name; the object it replaced belongs to nobody
    METHODS recreated_value_found     FOR TESTING RAISING cx_static_check.
    " an elementary row the scan resolved is in the index afterwards - the
    " next search compares references instead of re-resolving it
    METHODS elementary_rows_indexed   FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_02_search IMPLEMENTATION.

  METHOD elementary_rows_indexed.

    " dissolve indexes tables, references and structures; an elementary
    " row reaches the index through the scan of the binding search alone.
    " Every row the scan resolved on the way stays indexed, so a form of k
    " attributes bound in name order pays k dynamic ASSIGNs per roundtrip,
    " not k*k/2 - and the hit is still confirmed by a fresh ASSIGN
    DATA temp58 LIKE REF TO mo_app->mv_string.
DATA lr_row TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.
    FIELD-SYMBOLS <idx> TYPE z2ui5_cl_ui5_srv_model=>ty_s_ref_idx.
    DATA temp17 TYPE xsdboolean.
    DATA lr_val LIKE REF TO mo_app->mv_string.
    DATA temp18 TYPE xsdboolean.
    DATA temp59 LIKE REF TO mo_app->mv_string.
DATA lr_again TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.
    DATA temp19 TYPE xsdboolean.
    GET REFERENCE OF mo_app->mv_string INTO temp58.

lr_row = bind( temp58 ).


    READ TABLE mo_model->mt_ref_idx WITH KEY name = `MV_STRING` ASSIGNING <idx>.

    temp17 = boolc( <idx> IS ASSIGNED ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp17
                                      msg = `the resolved row was not indexed` ).

    GET REFERENCE OF mo_app->mv_string INTO lr_val.

    temp18 = boolc( <idx>-ref = lr_val ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp18 ).

    " the second search lands on the same row

    GET REFERENCE OF mo_app->mv_string INTO temp59.

lr_again = mo_model->main_attri_search( temp59 ).

    temp19 = boolc( lr_again = lr_row ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp19 ).

  ENDMETHOD.

  METHOD every_form_found.
    DATA lv_name LIKE LINE OF mt_bound.

    bind_all( ).

    " every form landed on a row of its own, and each is found again
    cl_abap_unit_assert=>assert_equals( exp = 27
                                        act = lines( mt_bound ) ).

    LOOP AT mt_bound INTO lv_name.
      cl_abap_unit_assert=>assert_equals( exp = abap_true
                                          act = row( lv_name )-bind
                                          msg = |{ lv_name } is not bound| ).
    ENDLOOP.
    inv_search_finds_bound( ).

  ENDMETHOD.

  METHOD address_per_form.
    DATA temp60 LIKE REF TO mo_app->mv_string.
DATA temp20 TYPE xsdboolean.
    DATA temp21 TYPE xsdboolean.
    DATA temp61 LIKE REF TO mo_app->mo_inner->mv_inner.
DATA temp22 TYPE xsdboolean.
    DATA temp23 TYPE xsdboolean.
    DATA temp62 LIKE REF TO mo_app->ms_deep-l1-l2-l3-v4.
DATA temp24 TYPE xsdboolean.
    DATA temp63 LIKE REF TO mo_app->mr_typed_struc->col1.
DATA temp25 TYPE xsdboolean.

    mo_model->main_attri_refresh( ).


    GET REFERENCE OF mo_app->mv_string INTO temp60.

temp20 = boolc( mo_model->attri_get_val_ref( `MV_STRING` ) = temp60 ).
cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp20 ).

    temp21 = boolc( mo_model->attri_get_val_ref( `MR_ELEM->*` ) = mo_app->mr_elem ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp21 ).

    GET REFERENCE OF mo_app->mo_inner->mv_inner INTO temp61.

temp22 = boolc( mo_model->attri_get_val_ref( `MO_INNER->MV_INNER` ) = temp61 ).
cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp22 ).

    temp23 = boolc( mo_model->attri_get_val_ref( `MO_INNER->MR_SHARED->*` ) = mo_app->mo_inner->mr_shared ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp23 ).

    GET REFERENCE OF mo_app->ms_deep-l1-l2-l3-v4 INTO temp62.

temp24 = boolc( mo_model->attri_get_val_ref( `MS_DEEP-L1-L2-L3-V4` ) = temp62 ).
cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp24 ).

    GET REFERENCE OF mo_app->mr_typed_struc->col1 INTO temp63.

temp25 = boolc( mo_model->attri_get_val_ref( `MR_TYPED_STRUC->COL1` ) = temp63 ).
cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp25 ).

    TRY.
        mo_model->attri_get_val_ref( `NOT_AN_ATTRIBUTE` ).
        cl_abap_unit_assert=>fail( `an unknown name must raise` ).
      CATCH z2ui5_cx_ui5_util_error ##NO_HANDLER.
    ENDTRY.

  ENDMETHOD.

  METHOD alias_binds_as_owner.

    DATA lr_attri TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.
    lr_attri = mo_model->main_attri_search( mo_app->mr_alias_struc ).
    cl_abap_unit_assert=>assert_equals( exp = `MS_FLAT`
                                        act = lr_attri->name ).
    lr_attri = mo_model->main_attri_search( mo_app->mr_alias_tab ).
    cl_abap_unit_assert=>assert_equals( exp = `MT_STD`
                                        act = lr_attri->name ).
    lr_attri = mo_model->main_attri_search( mo_app->mo_inner_2->mr_shared ).
    cl_abap_unit_assert=>assert_equals( exp = `MT_STD`
                                        act = lr_attri->name ).

  ENDMETHOD.

  METHOD shared_binds_canonical.

    DATA lr_a TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.
    DATA lr_b TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.
    DATA lr_i TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.
    lr_a = mo_model->main_attri_search( mo_app->mr_shared_a ).

    lr_b = mo_model->main_attri_search( mo_app->mr_shared_b ).

    lr_i = mo_model->main_attri_search( mo_app->mo_inner->mr_shared ).
    cl_abap_unit_assert=>assert_equals( exp = `MR_SHARED_B->*`
                                        act = lr_a->name ).
    cl_abap_unit_assert=>assert_equals( exp = lr_a->name
                                        act = lr_b->name ).
    cl_abap_unit_assert=>assert_equals( exp = lr_a->name
                                        act = lr_i->name ).

  ENDMETHOD.

  METHOD reference_itself_refused.
        DATA temp64 LIKE REF TO mo_app->mr_handle_tab.
        DATA lx TYPE REF TO z2ui5_cx_ui5_util_error.
        DATA temp26 TYPE xsdboolean.

    " _bind( mr_handle_tab ) hands the REFERENCE over, not the table behind
    " it - refused with a message that says what to do instead
    TRY.

        GET REFERENCE OF mo_app->mr_handle_tab INTO temp64.
mo_model->main_attri_search( temp64 ).
        cl_abap_unit_assert=>fail( `a reference itself must not be bindable` ).

      CATCH z2ui5_cx_ui5_util_error INTO lx.

        temp26 = boolc( lx->get_text( ) CS `NO DATA REFERENCES` ).
        cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp26 ).
    ENDTRY.

  ENDMETHOD.

  METHOD alias_grandchild_as_owner.

    DATA lo_app TYPE REF TO ltcl_app_samples.
    DATA lt_attri TYPE z2ui5_if_ui5_types=>ty_t_attri.
    DATA temp65 LIKE REF TO lt_attri.
DATA lo_model TYPE REF TO z2ui5_cl_ui5_srv_model.
    DATA lr_leaf TYPE REF TO data.
    DATA lr_attri TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.
    FIELD-SYMBOLS <temp66> LIKE LINE OF lt_attri.
    DATA temp67 LIKE sy-tabix.
    FIELD-SYMBOLS <temp68> LIKE LINE OF lt_attri.
    DATA temp69 LIKE sy-tabix.
    FIELD-SYMBOLS <temp70> LIKE LINE OF lt_attri.
    DATA temp71 LIKE sy-tabix.
    CREATE OBJECT lo_app TYPE ltcl_app_samples.
    GET REFERENCE OF lo_app->ms_data INTO lo_app->mr_alias.
    lo_app->ms_data-ms_data2-val = `two`.


    GET REFERENCE OF lt_attri INTO temp65.

CREATE OBJECT lo_model TYPE z2ui5_cl_ui5_srv_model EXPORTING attri = temp65 app = lo_app.

    " the leaf reached THROUGH the reference is the owner's leaf

    lr_leaf = lo_model->attri_get_val_ref( `MR_ALIAS->MS_DATA2-VAL` ).

    lr_attri = lo_model->main_attri_search( lr_leaf ).
    cl_abap_unit_assert=>assert_equals( exp = `MS_DATA-MS_DATA2-VAL`
                                        act = lr_attri->name ).
    " ...because every row under the alias names the owner's path


    temp67 = sy-tabix.
    READ TABLE lt_attri WITH KEY name = `MR_ALIAS->MS_DATA2` ASSIGNING <temp66>.
    sy-tabix = temp67.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `MS_DATA-MS_DATA2`
                                        act = <temp66>-name_ref ).


    temp69 = sy-tabix.
    READ TABLE lt_attri WITH KEY name = `MR_ALIAS->MS_DATA2-VAL` ASSIGNING <temp68>.
    sy-tabix = temp69.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `MS_DATA-MS_DATA2-VAL`
                                        act = <temp68>-name_ref ).


    temp71 = sy-tabix.
    READ TABLE lt_attri WITH KEY name = `MR_ALIAS->MS_DATA2-MS_DATA2-VAL` ASSIGNING <temp70>.
    sy-tabix = temp71.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `MS_DATA-MS_DATA2-MS_DATA2-VAL`
                                        act = <temp70>-name_ref ).

  ENDMETHOD.

  METHOD deep_leaf_found.

    DATA lo_app TYPE REF TO ltcl_app_samples.
    DATA lt_attri TYPE z2ui5_if_ui5_types=>ty_t_attri.
    DATA temp72 LIKE REF TO lt_attri.
DATA lo_model TYPE REF TO z2ui5_cl_ui5_srv_model.
    DATA temp73 LIKE REF TO lo_app->ms_data-ms_data2-ms_data2-ms_data2-ms_data2-ms_data2-ms_data2-val.
DATA lr_attri TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.
    DATA temp74 LIKE REF TO lo_app->ms_data-ms_data2-val.
DATA lr_upper TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.
    CREATE OBJECT lo_app TYPE ltcl_app_samples.
    lo_app->ms_data-ms_data2-ms_data2-ms_data2-ms_data2-ms_data2-ms_data2-val = `deep`.


    GET REFERENCE OF lt_attri INTO temp72.

CREATE OBJECT lo_model TYPE z2ui5_cl_ui5_srv_model EXPORTING attri = temp72 app = lo_app.

    GET REFERENCE OF lo_app->ms_data-ms_data2-ms_data2-ms_data2-ms_data2-ms_data2-ms_data2-val INTO temp73.

lr_attri = lo_model->main_attri_search(
        temp73 ).
    cl_abap_unit_assert=>assert_equals( exp = `MS_DATA-MS_DATA2-MS_DATA2-MS_DATA2-MS_DATA2-MS_DATA2-MS_DATA2-VAL`
                                        act = lr_attri->name ).

    GET REFERENCE OF lo_app->ms_data-ms_data2-val INTO temp74.

lr_upper = lo_model->main_attri_search( temp74 ).
    cl_abap_unit_assert=>assert_equals( exp = `MS_DATA-MS_DATA2-VAL`
                                        act = lr_upper->name ).

  ENDMETHOD.

  METHOD unreachable_row_skipped.

    " a row whose o_typedescr the restore could not re-resolve - the same
    " type_kind and kind as the searched value, so the prefilter visits it
    " first, and no descriptor. It used to dump CX_SY_REF_IS_INITIAL
    DATA temp75 LIKE REF TO mo_app->mv_string.
DATA lo_descr TYPE REF TO cl_abap_typedescr.
    DATA temp76 TYPE z2ui5_if_ui5_types=>ty_s_attri.
    DATA temp77 LIKE REF TO mo_app->mv_string.
DATA lr_attri TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.
    GET REFERENCE OF mo_app->mv_string INTO temp75.

lo_descr = z2ui5_cl_ui5_util_context=>rtti_get_typedescr_by_data_ref( temp75 ).

    CLEAR temp76.
    temp76-name = `AA_GONE`.
    temp76-check_dissolved = abap_true.
    temp76-type_kind = lo_descr->type_kind.
    temp76-kind = lo_descr->kind.
    INSERT temp76 INTO TABLE mr_attri->*.


    GET REFERENCE OF mo_app->mv_string INTO temp77.

lr_attri = mo_model->main_attri_search( temp77 ).
    cl_abap_unit_assert=>assert_equals( exp = `MV_STRING`
                                        act = lr_attri->name ).

  ENDMETHOD.

  METHOD search_refreshes_late_obj.
    DATA temp78 LIKE REF TO mo_app->mv_string.
    DATA lo_other TYPE REF TO ltcl_app_shapes.
    DATA temp79 LIKE REF TO lo_other->mv_int.
DATA lr_attri TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.

    CLEAR mo_app->mi_app.

    GET REFERENCE OF mo_app->mv_string INTO temp78.
bind( temp78 ).
    CREATE OBJECT mo_app->mi_app TYPE ltcl_app_shapes.

    lo_other ?= mo_app->mi_app.

    " not in mt_attri yet - the search dissolves, finds nothing, refreshes

    GET REFERENCE OF lo_other->mv_int INTO temp79.

lr_attri = mo_model->main_attri_search( temp79 ).
    cl_abap_unit_assert=>assert_equals( exp = `MI_APP->MV_INT`
                                        act = lr_attri->name ).
    " and the earlier bind survived the refresh
    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = row( `MV_STRING` )-bind ).

  ENDMETHOD.

  METHOD unknown_value_is_error.

    DATA lv_local TYPE string.
        DATA temp80 LIKE REF TO lv_local.
        DATA lx TYPE REF TO z2ui5_cx_ui5_util_error.
        DATA temp27 TYPE xsdboolean.
    TRY.

        GET REFERENCE OF lv_local INTO temp80.
mo_model->main_attri_search( temp80 ).
        cl_abap_unit_assert=>fail( `a value outside the app must raise` ).

      CATCH z2ui5_cx_ui5_util_error INTO lx.

        temp27 = boolc( lx->get_text( ) CS `BINDING_ERROR` ).
        cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp27 ).
    ENDTRY.
    " a protected attribute is outside as well
    TRY.
        mo_model->main_attri_search( mo_app->get_protected_ref( ) ).
        cl_abap_unit_assert=>fail( `a protected attribute must not be bindable` ).
      CATCH z2ui5_cx_ui5_util_error ##NO_HANDLER.
    ENDTRY.

  ENDMETHOD.


  METHOD recreated_value_found.

    FIELD-SYMBOLS <elem> TYPE any.
    DATA temp81 LIKE REF TO mo_app->mo_inner->mv_inner.
    DATA lr_old_elem LIKE mo_app->mr_elem.
    DATA lo_old_inner LIKE mo_app->mo_inner.
    DATA lr_attri TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.
    DATA temp82 LIKE REF TO mo_app->mo_inner->mv_inner.
    DATA lv_model TYPE string.
    DATA temp28 TYPE xsdboolean.
    DATA temp29 TYPE xsdboolean.
        DATA lx TYPE REF TO z2ui5_cx_ui5_util_error.
        DATA temp30 TYPE xsdboolean.
        DATA temp83 LIKE REF TO lo_old_inner->mv_inner.
        DATA temp31 TYPE xsdboolean.

    " the first render binds the target of the generic reference and the
    " helper's value
    bind( mo_app->mr_elem ).

    GET REFERENCE OF mo_app->mo_inner->mv_inner INTO temp81.
bind( temp81 ).

    lr_old_elem = mo_app->mr_elem.

    lo_old_inner = mo_app->mo_inner.

    " main( ) of the next roundtrip: CREATE DATA and CREATE OBJECT again -
    " new objects under the same names, the old ones still alive in a local
    CREATE DATA mo_app->mr_elem TYPE string.
    ASSIGN mo_app->mr_elem->* TO <elem>.
    <elem> = `elem-new`.
    CREATE OBJECT mo_app->mo_inner.
    mo_app->mo_inner->mv_inner = `inner-new`.

    " the search answers with the rows, resolved against the NEW objects,
    " and the binding they carried stays

    lr_attri = mo_model->main_attri_search( mo_app->mr_elem ).
    cl_abap_unit_assert=>assert_equals( exp = `MR_ELEM->*`
                                        act = lr_attri->name ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = lr_attri->bind ).

    GET REFERENCE OF mo_app->mo_inner->mv_inner INTO temp82.
lr_attri = mo_model->main_attri_search( temp82 ).
    cl_abap_unit_assert=>assert_equals( exp = `MO_INNER->MV_INNER`
                                        act = lr_attri->name ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = lr_attri->bind ).

    " the model reads the new objects

    lv_model = mo_model->main_json_stringify( ).

    temp28 = boolc( lv_model CS `"elem-new"` ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp28 ).

    temp29 = boolc( lv_model CS `"inner-new"` ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp29 ).

    " the objects the render replaced are nobody's attribute any more: a
    " named error, never the stale row
    TRY.
        mo_model->main_attri_search( lr_old_elem ).
        cl_abap_unit_assert=>fail( `the replaced data object must not bind` ).

      CATCH z2ui5_cx_ui5_util_error INTO lx.

        temp30 = boolc( lx->get_text( ) CS `BINDING_ERROR` ).
        cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp30 ).
    ENDTRY.
    TRY.

        GET REFERENCE OF lo_old_inner->mv_inner INTO temp83.
mo_model->main_attri_search( temp83 ).
        cl_abap_unit_assert=>fail( `the replaced helper must not bind` ).
      CATCH z2ui5_cx_ui5_util_error INTO lx.

        temp31 = boolc( lx->get_text( ) CS `BINDING_ERROR` ).
        cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp31 ).
    ENDTRY.

    " ...and the refresh those misses ran left the bindings in place
    inv_search_finds_bound( ).

  ENDMETHOD.
ENDCLASS.


" ---------------------------------------------------------------------------
" 03 MODEL OUT - what the client receives
" ---------------------------------------------------------------------------
CLASS ltcl_03_model_out DEFINITION INHERITING FROM ltcl_00_base FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION MEDIUM.

  PRIVATE SECTION.
    " every bound row is a key of the model, and nothing else is
    METHODS every_bound_row          FOR TESTING RAISING cx_static_check.
    METHODS nothing_bound_is_empty   FOR TESTING RAISING cx_static_check.
    " the values, per form
    METHODS values_per_form          FOR TESTING RAISING cx_static_check.
    " date and time fields, filled or not (sample 118)
    METHODS dates_initial_or_broken  FOR TESTING RAISING cx_static_check.
    " markup and quotes in a value arrive as a value
    METHODS markup_escaped           FOR TESTING RAISING cx_static_check.
    " _bind( json = abap_true ): the string IS JSON and becomes a node
    METHODS json_bind_spliced        FOR TESTING RAISING cx_static_check.
    METHODS json_bind_invalid_raises FOR TESTING RAISING cx_static_check.
    " ... and one that holds no JSON yet is null, not a failed roundtrip
    METHODS json_bind_initial_null   FOR TESTING RAISING cx_static_check.
    " a filter drops what it says (omit_initial)
    METHODS filter_applied           FOR TESTING RAISING cx_static_check.
    " the snapshot before main( ): unchanged values are no change - also
    " when a bound row cannot be reached (its reference was cleared), which
    " the snapshot leaves out and used to count as bound anew, pushing the
    " whole model on every roundtrip
    METHODS snapshot_unchanged       FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_03_model_out IMPLEMENTATION.

  METHOD snapshot_unchanged.
    DATA lt_snapshot TYPE z2ui5_cl_ui5_srv_model=>ty_t_snapshot.

    bind_all( ).

    lt_snapshot = mo_model->main_snapshot( ).
    cl_abap_unit_assert=>assert_equals( exp = abap_false act = mo_model->main_snapshot_changed( lt_snapshot ) ).

    mo_app->mv_string = `changed`.
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = mo_model->main_snapshot_changed( lt_snapshot ) ).

    " a bound row whose reference is gone: in no snapshot, and no change
    CLEAR mo_app->mr_elem.
    lt_snapshot = mo_model->main_snapshot( ).
    cl_abap_unit_assert=>assert_equals( exp = abap_false act = mo_model->main_snapshot_changed( lt_snapshot ) ).

  ENDMETHOD.

  METHOD every_bound_row.
    DATA lv_json TYPE string.
    DATA lv_name LIKE LINE OF mt_bound.
      DATA lv_key TYPE string.
      DATA temp32 TYPE xsdboolean.
    DATA temp33 TYPE xsdboolean.
    DATA temp34 TYPE xsdboolean.

    bind_all( ).

    lv_json = mo_model->main_json_stringify( ).


    LOOP AT mt_bound INTO lv_name.

      lv_key = substring( val = row( lv_name )-name_client
                                off = 1 ).

      temp32 = boolc( lv_json CS |"{ lv_key }"| ).
      cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp32
                                        msg = |{ lv_name } missing from the model| ).
    ENDLOOP.
    " a reference row itself never travels - only the data behind it

    temp33 = boolc( lv_json CS `"MR_HANDLE_TAB":` OR lv_json CS `"MO_INNER":` ).
    cl_abap_unit_assert=>assert_equals( exp = abap_false act = temp33 ).
    " and an unbound attribute does not either

    temp34 = boolc( lv_json CS `"MV_XSTR"` ).
    cl_abap_unit_assert=>assert_equals( exp = abap_false act = temp34 ).

  ENDMETHOD.

  METHOD nothing_bound_is_empty.

    mo_model->main_attri_refresh( ).
    cl_abap_unit_assert=>assert_equals( exp = `{}`
                                        act = mo_model->main_json_stringify( ) ).

  ENDMETHOD.

  METHOD values_per_form.
    DATA temp84 TYPE REF TO z2ui5_if_ui5_ajs.
    DATA lo_json LIKE temp84.

    bind_all( ).

    temp84 ?= z2ui5_cl_ui5_ajs=>parse( mo_model->main_json_stringify( ) ).

    lo_json = temp84.

    cl_abap_unit_assert=>assert_equals( exp = `text`
                                        act = lo_json->get_string( `/MV_STRING` ) ).
    cl_abap_unit_assert=>assert_equals( exp = 42
                                        act = lo_json->get_integer( `/MV_INT` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `2024-01-15`
                                        act = lo_json->get_string( `/MV_DATE` ) ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = lo_json->get_boolean( `/MV_BOOL` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `flat`
                                        act = lo_json->get_string( `/MS_FLAT/COL1` ) ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = lo_json->get_boolean( `/MS_DEEP_L1_L2_L3_V4` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `b`
                                        act = lo_json->get_string( `/MT_STD/2/COL1` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `n2b`
                                        act = lo_json->get_string( `/MT_NESTED/2/T_ITEMS/2/COL1` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `handle-row-1`
                                        act = lo_json->get_string( `/MR_HANDLE_TAB_D/1/COL1` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `shared`
                                        act = lo_json->get_string( `/MR_SHARED_B_D/1/COL1` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `elem`
                                        act = lo_json->get_string( `/MR_ELEM_D` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `deeper`
                                        act = lo_json->get_string( `/MO_INNER_MO_DEEPER_MV_INNER` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `in-struc-tab`
                                        act = lo_json->get_string( `/MS_WITH_DREF_R_TAB_D/1/COL1` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `a`
                                        act = lo_json->get_string( `/MR_HANDLE_NESTED_T_ITEMS/1/COL1` ) ).

  ENDMETHOD.

  METHOD dates_initial_or_broken.

    " the empty string of row 4 comes from a variable: written as a literal
    " the extended check reports it on every run ("" is not an admissible
    " value for type "D" / "T"), and what the row is about - an app moving
    " an empty string into a date - is a value the compiler never sees
    DATA lv_empty TYPE string.

    DATA lo_app TYPE REF TO ltcl_app_samples.
    DATA temp85 TYPE ltcl_app_samples=>ty_t_row.
    DATA temp86 LIKE LINE OF temp85.
    DATA lt_attri TYPE z2ui5_if_ui5_types=>ty_t_attri.
    DATA temp87 LIKE REF TO lt_attri.
DATA lo_model TYPE REF TO z2ui5_cl_ui5_srv_model.
    DATA temp88 LIKE REF TO lo_app->mt_rows.
DATA lr_attri TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.
    DATA lv_json TYPE string.
    DATA temp35 TYPE xsdboolean.
    DATA temp36 TYPE xsdboolean.
    CREATE OBJECT lo_app TYPE ltcl_app_samples.

    CLEAR temp85.

    CLEAR temp86.
    temp86-id = 1.
    temp86-descr = `initial`.
    INSERT temp86 INTO TABLE temp85.
    CLEAR temp86.
    temp86-id = 2.
    temp86-descr = `zeros`.
    temp86-adate = '00000000'.
    temp86-atime = '000000'.
    INSERT temp86 INTO TABLE temp85.
    CLEAR temp86.
    temp86-id = 3.
    temp86-descr = `valid`.
    temp86-adate = '20240115'.
    temp86-atime = '123045'.
    INSERT temp86 INTO TABLE temp85.
    CLEAR temp86.
    temp86-id = 4.
    temp86-descr = `empty string moved in`.
    temp86-adate = lv_empty.
    temp86-atime = lv_empty.
    INSERT temp86 INTO TABLE temp85.
    lo_app->mt_rows = temp85.



    GET REFERENCE OF lt_attri INTO temp87.

CREATE OBJECT lo_model TYPE z2ui5_cl_ui5_srv_model EXPORTING attri = temp87 app = lo_app.

    GET REFERENCE OF lo_app->mt_rows INTO temp88.

lr_attri = lo_model->main_attri_search( temp88 ).
    lr_attri->bind        = abap_true.
    lr_attri->name_client = `/MT_ROWS`.


    lv_json = lo_model->main_json_stringify( ).

    temp35 = boolc( lv_json CS `"empty string moved in"` ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp35 ).

    temp36 = boolc( lv_json CS `2024-01-15` ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp36 ).

  ENDMETHOD.

  METHOD markup_escaped.

    DATA temp89 LIKE REF TO mo_app->mv_markup.
    DATA lv_json TYPE string.
    DATA temp90 TYPE REF TO z2ui5_if_ui5_ajs.
    DATA lo_json LIKE temp90.
    GET REFERENCE OF mo_app->mv_markup INTO temp89.
bind( temp89 ).

    lv_json = mo_model->main_json_stringify( ).
    " parsed back, the value is what the attribute holds - quotes, angle
    " brackets, ampersand and the line break included

    temp90 ?= z2ui5_cl_ui5_ajs=>parse( lv_json ).

    lo_json = temp90.
    cl_abap_unit_assert=>assert_equals( exp = mo_app->mv_markup
                                        act = lo_json->get_string( `/MV_MARKUP` ) ).

  ENDMETHOD.

  METHOD json_bind_spliced.
    DATA temp91 LIKE REF TO mo_app->mv_string.
DATA lr_attri TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.
    DATA temp92 TYPE REF TO z2ui5_if_ui5_ajs.
    DATA lo_result LIKE temp92.

    mo_app->mv_string = `{"_version":"1.0","sap.app":{"type":"card"},"sap.card":{"type":"List"}}`.

    GET REFERENCE OF mo_app->mv_string INTO temp91.

lr_attri = bind( temp91 ).
    lr_attri->check_json = abap_true.


    temp92 ?= z2ui5_cl_ui5_ajs=>parse( mo_model->main_json_stringify( ) ).

    lo_result = temp92.
    cl_abap_unit_assert=>assert_equals( exp = z2ui5_if_ui5_ajs_types=>node_type-object
                                        act = lo_result->get_node_type( `/MV_STRING` )
                                        msg = `the raw JSON must become a node, not a quoted string` ).
    cl_abap_unit_assert=>assert_equals( exp = `card`
                                        act = lo_result->get_string( `/MV_STRING/sap.app/type` ) ).

  ENDMETHOD.

  METHOD json_bind_invalid_raises.
    DATA temp93 LIKE REF TO mo_app->mv_string.
DATA lr_attri TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.

    mo_app->mv_string = `not json at all`.

    GET REFERENCE OF mo_app->mv_string INTO temp93.

lr_attri = bind( temp93 ).
    lr_attri->check_json = abap_true.
    TRY.
        mo_model->main_json_stringify( ).
        cl_abap_unit_assert=>fail( `an unparseable json bind must raise` ).
      CATCH z2ui5_cx_ui5_util_error ##NO_HANDLER.
    ENDTRY.

  ENDMETHOD.

  METHOD json_bind_initial_null.
    DATA temp94 LIKE REF TO mo_app->mv_string.
DATA lr_attri TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.
    DATA lv_json TYPE string.
    DATA temp95 TYPE REF TO z2ui5_if_ui5_ajs.
    DATA lo_result LIKE temp95.

    CLEAR mo_app->mv_string.

    GET REFERENCE OF mo_app->mv_string INTO temp94.

lr_attri = bind( temp94 ).
    lr_attri->check_json = abap_true.


    lv_json = mo_model->main_json_stringify( ).

    temp95 ?= z2ui5_cl_ui5_ajs=>parse( lv_json ).

    lo_result = temp95.
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = lo_result->exists( lr_attri->name_client )
                                      msg = lv_json ).
    cl_abap_unit_assert=>assert_equals( exp = `null`
                                        act = lo_result->get_node_type( lr_attri->name_client ) ).

  ENDMETHOD.

  METHOD filter_applied.
    DATA temp96 LIKE REF TO mo_app->ms_flat.
DATA lr_attri TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.
    DATA temp97 TYPE REF TO z2ui5_if_ui5_ajs.
    DATA lo_result LIKE temp97.

    " the behaviour behind _bind( omit_initial ): an INITIAL field stays
    " absent, so the control keeps its own default instead of receiving ``
    CLEAR mo_app->ms_flat-col1.
    mo_app->ms_flat-col2 = 7.

    GET REFERENCE OF mo_app->ms_flat INTO temp96.

lr_attri = bind( temp96 ).
    CREATE OBJECT lr_attri->custom_filter TYPE ltcl_shp_filter.


    temp97 ?= z2ui5_cl_ui5_ajs=>parse( mo_model->main_json_stringify( ) ).

    lo_result = temp97.
    cl_abap_unit_assert=>assert_equals( exp = 7
                                        act = lo_result->get_integer( `/MS_FLAT/COL2` ) ).
    cl_abap_unit_assert=>assert_equals( exp = abap_false
                                        act = lo_result->exists( `/MS_FLAT/COL1` )
                                        msg = `an initial field must stay ABSENT, not serialize as an empty string` ).

  ENDMETHOD.

ENDCLASS.


" ---------------------------------------------------------------------------
" 04 MODEL IN - what the client sends back: whole values and row deltas
" ---------------------------------------------------------------------------
CLASS ltcl_04_model_in DEFINITION INHERITING FROM ltcl_00_base FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION MEDIUM.

  PRIVATE SECTION.
    " a whole value, per form, written through every level
    METHODS whole_value_per_form     FOR TESTING RAISING cx_static_check.
    " what the client is not allowed to write
    METHODS unbound_not_written      FOR TESTING RAISING cx_static_check.
    METHODS json_bind_not_read_back  FOR TESTING RAISING cx_static_check.
    METHODS alias_written_once       FOR TESTING RAISING cx_static_check.
    " a scalar the type refuses keeps its value and is traced
    METHODS scalar_refused_traced    FOR TESTING RAISING cx_static_check.
    " a scalar whole value is read in place, with the row delta's typed
    " conversions: ISO and plain dates, a time, a boolean, a number, a null
    METHODS whole_scalar_typed       FOR TESTING RAISING cx_static_check.
    " a scalar sent for a structure attribute is refused and traced, never
    " assigned - the assignment would be a runtime error, not an exception
    METHODS whole_scalar_into_struc  FOR TESTING RAISING cx_static_check.
    " markup and quotes come back as they went out
    METHODS markup_round_trips       FOR TESTING RAISING cx_static_check.
    " the whole model out and in again - the count the backend holds (199)
    METHODS whole_table_round_trips  FOR TESTING RAISING cx_static_check.
    " row deltas: which row, which cell, out of range
    METHODS delta_rows               FOR TESTING RAISING cx_static_check.
    " row deltas into the tables behind references and inside the helper
    METHODS delta_into_dref_table    FOR TESTING RAISING cx_static_check.
    METHODS delta_into_helper_table  FOR TESTING RAISING cx_static_check.
    " nested rows, structure cells, a replaced sub-table
    METHODS delta_nested             FOR TESTING RAISING cx_static_check.
    " typed cells: accepted, ISO dates, plain date, refused
    METHODS delta_typed_cells        FOR TESTING RAISING cx_static_check.
    " what the trace of a refused cell says
    METHODS delta_trace              FOR TESTING RAISING cx_static_check.
    " a table kind that takes no row delta
    METHODS delta_sorted_refused     FOR TESTING RAISING cx_static_check.
    " a row index past the table's end, top level and nested
    METHODS delta_row_past_end       FOR TESTING RAISING cx_static_check.
    " a structure cell is written as a whole value - a replace, not a merge
    METHODS delta_struct_cell_whole  FOR TESTING RAISING cx_static_check.
    " a column kind that takes no value of the shape the wire carries
    METHODS delta_kind_refused       FOR TESTING RAISING cx_static_check.
    " a delta over many rows with a refused cell and a refused nested table
    " in the middle: every good cell lands, the refused ones keep their
    " values and are traced, nothing else is touched
    METHODS delta_mass_edit          FOR TESTING RAISING cx_static_check.
    " a __delta node that is not the shape the client is supposed to send
    METHODS delta_malformed_survives FOR TESTING RAISING cx_static_check.
    " a whole table out and back in with initial and filled dates, times
    " and timestamps: what went out comes back, initial stays initial
    METHODS whole_dates_round_trip   FOR TESTING RAISING cx_static_check.
    " text that needs JSON escaping - quotes, backslashes, control
    " characters, non-ASCII - out and back in, whole and as a row delta
    METHODS special_chars_round_trip FOR TESTING RAISING cx_static_check.
    " a JSON null in a delta cell clears it - what a null as a whole value
    " does (whole_scalar_typed), for every elementary kind of the row
    METHODS delta_null_clears        FOR TESTING RAISING cx_static_check.
    " decfloat, NUMC, a big integer, rounding into a packed cell, a JSON number
    " node next to a JSON string, a boolean into a number column
    METHODS delta_number_kinds       FOR TESTING RAISING cx_static_check.
    " a delta two __delta levels down: the cell lands, a refused one is
    " traced under the full table path with its immediate parent row
    METHODS delta_three_levels       FOR TESTING RAISING cx_static_check.
    " a row added or removed on the client sends the whole array: it
    " replaces the rows, nested tables included
    METHODS whole_rows_replaced      FOR TESTING RAISING cx_static_check.
    " a __delta for an attribute that is no table is traced, never applied
    METHODS delta_on_structure       FOR TESTING RAISING cx_static_check.
    " a date or time in a spelling that is neither ISO nor plain digits is
    " refused and traced - it used to be cut to its first characters
    METHODS date_time_text_refused   FOR TESTING RAISING cx_static_check.
    " a structure, a structure cell and a table written as one value read
    " an emptied date or time as initial and plain digits like the ISO form
    METHODS whole_value_dates        FOR TESTING RAISING cx_static_check.
    " the reference components of a structure written as one value take
    " nothing from the wire and keep what they held - the edit of a sibling
    " field lands
    METHODS whole_value_refs_kept    FOR TESTING RAISING cx_static_check.
    " a row delta into a table of references goes into the rows they point
    " to; a reference that points nowhere is traced
    METHODS delta_ref_rows           FOR TESTING RAISING cx_static_check.
    " a number with more digits than a double keeps goes out as text on
    " every road, and comes back unchanged with the edit of a sibling
    METHODS wide_numbers_quoted      FOR TESTING RAISING cx_static_check.
    " a numeric text takes digits only, and no more than it has places
    METHODS delta_numc_refused       FOR TESTING RAISING cx_static_check.

    METHODS edge_model
      IMPORTING
        io_app        TYPE REF TO ltcl_app_edge
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_ui5_srv_model.
    " the wide row of wide_numbers_quoted, every field set from its text
    METHODS wide_fill
      CHANGING
        cs_wide TYPE ltcl_app_edge=>ty_s_wide.
    METHODS edge_bind
      IMPORTING
        io_model TYPE REF TO z2ui5_cl_ui5_srv_model
        ir_val   TYPE REF TO data
        iv_name  TYPE string.

    METHODS typed_app
      RETURNING
        VALUE(result) TYPE REF TO ltcl_app_typed.
    METHODS typed_model
      IMPORTING
        io_app        TYPE REF TO ltcl_app_typed
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_ui5_srv_model.
    METHODS tree_app
      RETURNING
        VALUE(result) TYPE REF TO ltcl_app_tree.
    METHODS delta
      IMPORTING
        iv_json       TYPE string
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_if_ui5_ajs
      RAISING
        z2ui5_cx_ui5_ajs_error.
ENDCLASS.


CLASS ltcl_04_model_in IMPLEMENTATION.

  METHOD typed_app.
    DATA temp98 TYPE ltcl_app_typed=>ty_t_tab.
    DATA temp99 LIKE LINE OF temp98.
    DATA temp27 TYPE ltcl_app_typed=>ty_t_pos.
    DATA temp28 LIKE LINE OF temp27.
    DATA temp29 TYPE ltcl_app_typed=>ty_t_pos.
    DATA temp30 LIKE LINE OF temp29.

    CREATE OBJECT result.

    CLEAR temp98.

    temp99-name = `Notebook`.
    temp99-price = '1249.00'.

    CLEAR temp27.

    temp28-qty = 1.
    INSERT temp28 INTO TABLE temp27.
    temp99-t_pos = temp27.
    INSERT temp99 INTO TABLE temp98.
    temp99-name = `Monitor`.
    temp99-price = '299.00'.

    CLEAR temp29.

    temp30-qty = 2.
    INSERT temp30 INTO TABLE temp29.
    temp99-t_pos = temp29.
    INSERT temp99 INTO TABLE temp98.
    result->mt_tab = temp98.

  ENDMETHOD.

  METHOD typed_model.

    DATA lr_attri TYPE REF TO z2ui5_if_ui5_types=>ty_t_attri.
    CREATE DATA lr_attri.
    CREATE OBJECT result EXPORTING attri = lr_attri app = io_app.

  ENDMETHOD.

  METHOD tree_app.
    DATA temp100 TYPE ltcl_app_tree=>ty_t_tree.
    DATA temp101 LIKE LINE OF temp100.
    DATA temp31 TYPE ltcl_app_tree=>ty_t_nodes.
    DATA temp32 LIKE LINE OF temp31.

    CREATE OBJECT result.

    CLEAR temp100.

    temp101-user = `Manager`.
    temp101-enabled = abap_false.
    CLEAR temp101-s_adr.
    temp101-s_adr-city = `Old Town`.
    temp101-s_adr-zip = `00000`.

    CLEAR temp31.

    temp32-user = `E1`.
    temp32-validated = abap_false.
    INSERT temp32 INTO TABLE temp31.
    temp32-user = `E2`.
    temp32-validated = abap_false.
    INSERT temp32 INTO TABLE temp31.
    temp101-nodes = temp31.
    INSERT temp101 INTO TABLE temp100.
    result->mt_tree = temp100.

  ENDMETHOD.

  METHOD delta.

    result = z2ui5_cl_ui5_ajs=>parse( iv_json ).

  ENDMETHOD.

  METHOD whole_value_per_form.
    DATA temp102 TYPE REF TO z2ui5_if_ui5_ajs.
    DATA lo_front LIKE temp102.
    FIELD-SYMBOLS <elem> TYPE any.

    bind_all( ).

    temp102 ?= z2ui5_cl_ui5_ajs=>create_empty( ).

    lo_front = temp102.
    lo_front->set( iv_path = `/MV_STRING`
                   iv_val  = `updated` ).
    lo_front->set( iv_path = `/MV_INT`
                   iv_val  = 7 ).
    " a false is an EMPTY value to set( ) - it would be ignored
    lo_front->set_boolean( iv_path = `/MV_BOOL`
                           iv_val  = abap_false ).
    lo_front->set_boolean( iv_path = `/MS_DEEP_L1_L2_L3_V4`
                           iv_val  = abap_false ).
    lo_front->set( iv_path = `/MS_FLAT/COL1`
                   iv_val  = `written` ).
    lo_front->set( iv_path = `/MO_INNER_MO_DEEPER_MV_INNER`
                   iv_val  = `deeper-written` ).
    lo_front->set( iv_path = `/MR_ELEM_D`
                   iv_val  = `elem-written` ).
    lo_front->set( iv_path = `/MR_TYPED_STRUC_COL1`
                   iv_val  = `typed-written` ).
    lo_front->set( iv_path = `/MO_INNER_2_MV_INNER`
                   iv_val  = `inner-2-written` ).

    mo_model->main_json_to_attri( lo_front ).


    cl_abap_unit_assert=>assert_equals( exp = `updated`
                                        act = mo_app->mv_string ).
    cl_abap_unit_assert=>assert_equals( exp = 7
                                        act = mo_app->mv_int ).
    cl_abap_unit_assert=>assert_equals( exp = abap_false
                                        act = mo_app->mv_bool ).
    cl_abap_unit_assert=>assert_equals( exp = abap_false
                                        act = mo_app->ms_deep-l1-l2-l3-v4 ).
    cl_abap_unit_assert=>assert_equals( exp = `written`
                                        act = mo_app->ms_flat-col1 ).
    cl_abap_unit_assert=>assert_equals( exp = `deeper-written`
                                        act = mo_app->mo_inner->mo_deeper->mv_inner ).
    ASSIGN mo_app->mr_elem->* TO <elem>.
    cl_abap_unit_assert=>assert_equals( exp = `elem-written`
                                        act = <elem> ).
    cl_abap_unit_assert=>assert_equals( exp = `typed-written`
                                        act = mo_app->mr_typed_struc->col1 ).
    cl_abap_unit_assert=>assert_equals( exp = `inner-2-written`
                                        act = mo_app->mo_inner_2->mv_inner ).
    cl_abap_unit_assert=>assert_initial( mo_model->mt_skipped ).

  ENDMETHOD.

  METHOD unbound_not_written.
    DATA lr_attri TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.
    DATA temp103 TYPE REF TO z2ui5_if_ui5_ajs.
    DATA lo_front LIKE temp103.

    mo_model->main_attri_refresh( ).

    lr_attri = row_ref( `MV_STRING` ).
    lr_attri->bind        = abap_false.
    lr_attri->name_client = `/MV_STRING`.

    temp103 ?= z2ui5_cl_ui5_ajs=>create_empty( ).

    lo_front = temp103.
    lo_front->set( iv_path = `/MV_STRING`
                   iv_val  = `should_not_update` ).

    mo_model->main_json_to_attri( lo_front ).

    cl_abap_unit_assert=>assert_equals( exp = `text`
                                        act = mo_app->mv_string ).

  ENDMETHOD.

  METHOD json_bind_not_read_back.
    DATA temp104 LIKE REF TO mo_app->mv_string.
DATA lr_attri TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.
    DATA temp105 TYPE REF TO z2ui5_if_ui5_ajs.
    DATA lo_front LIKE temp105.

    mo_app->mv_string = `{"sap.app":{"type":"card"}}`.

    GET REFERENCE OF mo_app->mv_string INTO temp104.

lr_attri = bind( temp104 ).
    lr_attri->check_json = abap_true.

    temp105 ?= z2ui5_cl_ui5_ajs=>create_empty( ).

    lo_front = temp105.
    lo_front->set( iv_path = `/MV_STRING`
                   iv_val  = `overwritten` ).

    mo_model->main_json_to_attri( lo_front ).

    cl_abap_unit_assert=>assert_equals( exp = `{"sap.app":{"type":"card"}}`
                                        act = mo_app->mv_string
                                        msg = `a json bind must not be read back from the client model` ).

  ENDMETHOD.

  METHOD alias_written_once.

    " the same variable under two client paths: only the path the client
    " carries is written, the other entry is passed over
    DATA temp106 LIKE REF TO mo_app->mv_string.
DATA lr_attri TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.
    DATA ls_extra TYPE z2ui5_if_ui5_types=>ty_s_attri.
    DATA temp107 TYPE REF TO z2ui5_if_ui5_ajs.
    DATA lo_front LIKE temp107.
    GET REFERENCE OF mo_app->mv_string INTO temp106.

lr_attri = bind( temp106 ).

    ls_extra = lr_attri->*.
    ls_extra-name        = `MV_STRING_ALIAS`.
    ls_extra-name_client = `/ALIAS`.
    INSERT ls_extra INTO TABLE mr_attri->*.

    temp107 ?= z2ui5_cl_ui5_ajs=>create_empty( ).

    lo_front = temp107.
    lo_front->set( iv_path = `/MV_STRING`
                   iv_val  = `once` ).

    mo_model->main_json_to_attri( lo_front ).

    cl_abap_unit_assert=>assert_equals( exp = `once`
                                        act = mo_app->mv_string ).

  ENDMETHOD.

  METHOD scalar_refused_traced.

    " `1,250.00` typed into an Input bound to a packed SCALAR: traced with
    " the attribute name, row 0 and the raw value, the old value kept
    DATA temp108 LIKE REF TO mo_app->mv_packed.
    DATA temp109 TYPE REF TO z2ui5_if_ui5_ajs.
    DATA lo_front LIKE temp109.
    DATA temp110 TYPE decfloat34.
    DATA temp33 TYPE decfloat34.
    FIELD-SYMBOLS <temp111> LIKE LINE OF mo_model->mt_skipped.
    DATA temp112 LIKE sy-tabix.
    FIELD-SYMBOLS <temp113> LIKE LINE OF mo_model->mt_skipped.
    DATA temp114 LIKE sy-tabix.
    FIELD-SYMBOLS <temp115> LIKE LINE OF mo_model->mt_skipped.
    DATA temp116 LIKE sy-tabix.
    GET REFERENCE OF mo_app->mv_packed INTO temp108.
bind( temp108 ).

    temp109 ?= z2ui5_cl_ui5_ajs=>create_empty( ).

    lo_front = temp109.
    lo_front->set( iv_path = `/MV_PACKED`
                   iv_val  = `1,250.00` ).

    mo_model->main_json_to_attri( lo_front ).


    temp110 = '1234.56'.

    temp33 = mo_app->mv_packed.
    cl_abap_unit_assert=>assert_equals( exp = temp110
                                        act = temp33 ).
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( mo_model->mt_skipped ) ).


    temp112 = sy-tabix.
    READ TABLE mo_model->mt_skipped INDEX 1 ASSIGNING <temp111>.
    sy-tabix = temp112.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `MV_PACKED`
                                        act = <temp111>-name ).


    temp114 = sy-tabix.
    READ TABLE mo_model->mt_skipped INDEX 1 ASSIGNING <temp113>.
    sy-tabix = temp114.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = 0
                                        act = <temp113>-row ).


    temp116 = sy-tabix.
    READ TABLE mo_model->mt_skipped INDEX 1 ASSIGNING <temp115>.
    sy-tabix = temp116.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `1,250.00`
                                        act = <temp115>-value ).

  ENDMETHOD.

  METHOD whole_scalar_typed.

    DATA temp117 LIKE REF TO mo_app->mv_date.
    DATA temp118 LIKE REF TO mo_app->mv_time.
    DATA temp119 LIKE REF TO mo_app->mv_bool.
    DATA temp120 LIKE REF TO mo_app->mv_int.
    DATA temp121 LIKE REF TO mo_app->mv_string.
    DATA temp122 TYPE REF TO z2ui5_if_ui5_ajs.
    DATA lo_front LIKE temp122.
    DATA temp123 TYPE string.
    DATA temp124 TYPE string.
    DATA temp125 TYPE REF TO z2ui5_if_ui5_ajs.
    DATA temp126 TYPE string.
    GET REFERENCE OF mo_app->mv_date INTO temp117.
bind( temp117 ).

    GET REFERENCE OF mo_app->mv_time INTO temp118.
bind( temp118 ).

    GET REFERENCE OF mo_app->mv_bool INTO temp119.
bind( temp119 ).

    GET REFERENCE OF mo_app->mv_int INTO temp120.
bind( temp120 ).

    GET REFERENCE OF mo_app->mv_string INTO temp121.
bind( temp121 ).

    " the spellings ajson writes outbound - unpacked like a delta cell

    temp122 ?= z2ui5_cl_ui5_ajs=>create_empty( ).

    lo_front = temp122.
    lo_front->set( iv_path = `/MV_DATE`
                   iv_val  = `2024-01-15` ).
    lo_front->set( iv_path = `/MV_TIME`
                   iv_val  = `12:30:45` ).
    lo_front->set_boolean( iv_path = `/MV_BOOL`
                           iv_val  = abap_true ).
    lo_front->set( iv_path = `/MV_INT`
                   iv_val  = 42 ).
    lo_front->set_null( `/MV_STRING` ).

    mo_model->main_json_to_attri( lo_front ).


    temp123 = mo_app->mv_date.
    cl_abap_unit_assert=>assert_equals( exp = `20240115`
                                        act = temp123 ).

    temp124 = mo_app->mv_time.
    cl_abap_unit_assert=>assert_equals( exp = `123045`
                                        act = temp124 ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = mo_app->mv_bool ).
    cl_abap_unit_assert=>assert_equals( exp = 42
                                        act = mo_app->mv_int ).
    " a null is the cleared target - what to_abap( ) left behind for it
    cl_abap_unit_assert=>assert_initial( mo_app->mv_string ).
    cl_abap_unit_assert=>assert_initial( mo_model->mt_skipped ).

    " a plain date keeps the direct assignment, like a delta cell does

    temp125 ?= z2ui5_cl_ui5_ajs=>create_empty( ).
    lo_front = temp125.
    lo_front->set( iv_path = `/MV_DATE`
                   iv_val  = `20240116` ).

    mo_model->main_json_to_attri( lo_front ).


    temp126 = mo_app->mv_date.
    cl_abap_unit_assert=>assert_equals( exp = `20240116`
                                        act = temp126 ).
    cl_abap_unit_assert=>assert_initial( mo_model->mt_skipped ).

  ENDMETHOD.

  METHOD whole_scalar_into_struc.

    DATA temp127 LIKE REF TO mo_app->ms_flat.
    DATA ls_before LIKE mo_app->ms_flat.
    DATA temp128 TYPE REF TO z2ui5_if_ui5_ajs.
    DATA lo_front LIKE temp128.
    FIELD-SYMBOLS <temp129> LIKE LINE OF mo_model->mt_skipped.
    DATA temp130 LIKE sy-tabix.
    FIELD-SYMBOLS <temp131> LIKE LINE OF mo_model->mt_skipped.
    DATA temp132 LIKE sy-tabix.
    GET REFERENCE OF mo_app->ms_flat INTO temp127.
bind( temp127 ).

    ls_before = mo_app->ms_flat.

    temp128 ?= z2ui5_cl_ui5_ajs=>create_empty( ).

    lo_front = temp128.
    lo_front->set( iv_path = `/MS_FLAT`
                   iv_val  = `not a structure` ).

    mo_model->main_json_to_attri( lo_front ).

    cl_abap_unit_assert=>assert_equals( exp = ls_before
                                        act = mo_app->ms_flat ).
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( mo_model->mt_skipped ) ).


    temp130 = sy-tabix.
    READ TABLE mo_model->mt_skipped INDEX 1 ASSIGNING <temp129>.
    sy-tabix = temp130.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `MS_FLAT`
                                        act = <temp129>-name ).


    temp132 = sy-tabix.
    READ TABLE mo_model->mt_skipped INDEX 1 ASSIGNING <temp131>.
    sy-tabix = temp132.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `not a structure`
                                        act = <temp131>-value ).

  ENDMETHOD.

  METHOD markup_round_trips.

    DATA temp133 LIKE REF TO mo_app->mv_markup.
    DATA lv_out TYPE string.
    DATA lv_before LIKE mo_app->mv_markup.
    DATA temp134 TYPE REF TO z2ui5_if_ui5_ajs.
    GET REFERENCE OF mo_app->mv_markup INTO temp133.
bind( temp133 ).

    lv_out = mo_model->main_json_stringify( ).

    lv_before = mo_app->mv_markup.
    CLEAR mo_app->mv_markup.


    temp134 ?= z2ui5_cl_ui5_ajs=>parse( lv_out ).
    mo_model->main_json_to_attri( temp134 ).

    cl_abap_unit_assert=>assert_equals( exp = lv_before
                                        act = mo_app->mv_markup ).

  ENDMETHOD.

  METHOD whole_table_round_trips.

    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
    DATA temp135 TYPE ltcl_app_shapes=>ty_s_row.
    DATA temp136 TYPE ltcl_app_shapes=>ty_s_row.
    DATA lv_json TYPE string.
    DATA temp37 TYPE xsdboolean.
    DATA temp137 TYPE REF TO z2ui5_if_ui5_ajs.
    FIELD-SYMBOLS <temp138> LIKE LINE OF mo_app->mr_typed_tab->*.
    DATA temp139 LIKE sy-tabix.

    bind( mo_app->mr_typed_tab ).
    " the backend appends two rows and ships the table...

    CLEAR temp135.
    temp135-col1 = `second`.
    INSERT temp135 INTO TABLE mo_app->mr_typed_tab->*.

    CLEAR temp136.
    temp136-col1 = `third`.
    INSERT temp136 INTO TABLE mo_app->mr_typed_tab->*.

    lv_json = mo_model->main_json_stringify( ).

    temp37 = boolc( lv_json CS `"third"` ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp37 ).

    " ...the client sends the whole table back with its next event, and the
    " backend holds exactly what it shipped
    CLEAR mo_app->mr_typed_tab->*.

    temp137 ?= z2ui5_cl_ui5_ajs=>parse( lv_json ).
    mo_model->main_json_to_attri( temp137 ).
    ASSIGN mo_app->mr_typed_tab->* TO <tab>.
    cl_abap_unit_assert=>assert_equals( exp = 3
                                        act = lines( <tab> ) ).


    temp139 = sy-tabix.
    READ TABLE mo_app->mr_typed_tab->* INDEX 3 ASSIGNING <temp138>.
    sy-tabix = temp139.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `third`
                                        act = <temp138>-col1 ).

  ENDMETHOD.

  METHOD delta_rows.

    DATA temp140 LIKE REF TO mo_app->mt_std.
    FIELD-SYMBOLS <temp141> LIKE LINE OF mo_app->mt_std.
    DATA temp142 LIKE sy-tabix.
    FIELD-SYMBOLS <temp143> LIKE LINE OF mo_app->mt_std.
    DATA temp144 LIKE sy-tabix.
    FIELD-SYMBOLS <temp145> LIKE LINE OF mo_app->mt_std.
    DATA temp146 LIKE sy-tabix.
    FIELD-SYMBOLS <temp147> LIKE LINE OF mo_app->mt_std.
    DATA temp148 LIKE sy-tabix.
    FIELD-SYMBOLS <temp149> LIKE LINE OF mo_app->mt_std.
    DATA temp150 LIKE sy-tabix.
    FIELD-SYMBOLS <temp151> LIKE LINE OF mo_app->mt_std.
    DATA temp152 LIKE sy-tabix.
    FIELD-SYMBOLS <temp153> LIKE LINE OF mo_app->mt_std.
    DATA temp154 LIKE sy-tabix.
    FIELD-SYMBOLS <temp155> LIKE LINE OF mo_app->mt_std.
    DATA temp156 LIKE sy-tabix.
    GET REFERENCE OF mo_app->mt_std INTO temp140.
bind( temp140 ).

    mo_model->main_json_to_attri( delta( `{"MT_STD":{"__delta":{"0":{"COL1":"X"}}}}` ) ).


    temp142 = sy-tabix.
    READ TABLE mo_app->mt_std INDEX 1 ASSIGNING <temp141>.
    sy-tabix = temp142.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `X`
                                        act = <temp141>-col1 ).


    temp144 = sy-tabix.
    READ TABLE mo_app->mt_std INDEX 1 ASSIGNING <temp143>.
    sy-tabix = temp144.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = <temp143>-col2 ).


    temp146 = sy-tabix.
    READ TABLE mo_app->mt_std INDEX 2 ASSIGNING <temp145>.
    sy-tabix = temp146.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `b`
                                        act = <temp145>-col1 ).

    mo_model->main_json_to_attri( delta( `{"MT_STD":{"__delta":{"1":{"COL2":9}}}}` ) ).


    temp148 = sy-tabix.
    READ TABLE mo_app->mt_std INDEX 2 ASSIGNING <temp147>.
    sy-tabix = temp148.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = 9
                                        act = <temp147>-col2 ).


    temp150 = sy-tabix.
    READ TABLE mo_app->mt_std INDEX 2 ASSIGNING <temp149>.
    sy-tabix = temp150.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `b`
                                        act = <temp149>-col1 ).

    " out of range, garbled and negative indexes: no crash, table unchanged
    mo_model->main_json_to_attri( delta( `{"MT_STD":{"__delta":{"5":{"COL1":"Z"},"x":{"COL1":"Z"},"-1":{"COL1":"Z"}}}}` ) ).
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( mo_app->mt_std ) ).


    temp152 = sy-tabix.
    READ TABLE mo_app->mt_std INDEX 1 ASSIGNING <temp151>.
    sy-tabix = temp152.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `X`
                                        act = <temp151>-col1 ).

    " a key that CONVERTS but is no row index: `1.5` rounds to 2, `+1`
    " converts to 1 - each used to land the cell in a row the client
    " never named. Digits only, so neither writes (a blank-padded and the
    " empty key are in delta_malformed_survives)
    mo_model->main_json_to_attri( delta( `{"MT_STD":{"__delta":{"1.5":{"COL1":"Z"},"+1":{"COL1":"Z"}}}}` ) ).


    temp154 = sy-tabix.
    READ TABLE mo_app->mt_std INDEX 1 ASSIGNING <temp153>.
    sy-tabix = temp154.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `X`
                                        act = <temp153>-col1 ).


    temp156 = sy-tabix.
    READ TABLE mo_app->mt_std INDEX 2 ASSIGNING <temp155>.
    sy-tabix = temp156.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `b`
                                        act = <temp155>-col1 ).
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( mo_app->mt_std ) ).

  ENDMETHOD.

  METHOD delta_malformed_survives.

    " The request body is whatever reached the handler. A __delta that is
    " not an object of row-index -> cell-object is not something the
    " framework's own client writes, but it is still a request that has to
    " be ANSWERED: the single top-level catch in
    " z2ui5_cl_ui5_http_handler=>_main turns an exception into an error
    " page, while a RUNTIME ERROR ends the roundtrip with no body, no
    " status code and no security headers. So every shape below has to come
    " back with the bound table untouched.
    "
    " The empty-keyed member `{"":{...}}` was left out of the list while
    " open-abap's cl_sxml_string_reader could not tell it from an element
    " of an array: it emitted no `name` attribute, and the JSON parser's
    " own ASSERT fired before the model ever saw the body. That is fixed
    " upstream (open-abap/open-abap-core#1248) and the pin carries it, so
    " the shape is in the list below like any other.
    DATA temp157 LIKE REF TO mo_app->mt_std.
    DATA temp158 TYPE string_table.
    DATA lt_hostile LIKE temp158.
    DATA lv_json LIKE LINE OF lt_hostile.
      FIELD-SYMBOLS <temp160> LIKE LINE OF mo_app->mt_std.
      DATA temp161 LIKE sy-tabix.
      FIELD-SYMBOLS <temp162> LIKE LINE OF mo_app->mt_std.
      DATA temp163 LIKE sy-tabix.
    FIELD-SYMBOLS <temp164> LIKE LINE OF mo_app->mt_std.
    DATA temp165 LIKE sy-tabix.
    FIELD-SYMBOLS <temp166> LIKE LINE OF mo_app->mt_std.
    DATA temp167 LIKE sy-tabix.
    GET REFERENCE OF mo_app->mt_std INTO temp157.
bind( temp157 ).


    CLEAR temp158.
    INSERT `{"MT_STD":{"__delta":"boom"}}` INTO TABLE temp158.
    INSERT `{"MT_STD":{"__delta":42}}` INTO TABLE temp158.
    INSERT `{"MT_STD":{"__delta":null}}` INTO TABLE temp158.
    INSERT `{"MT_STD":{"__delta":["a","b"]}}` INTO TABLE temp158.
    INSERT `{"MT_STD":{"__delta":{"0":"boom"}}}` INTO TABLE temp158.
    INSERT `{"MT_STD":{"__delta":{"0":[1,2]}}}` INTO TABLE temp158.
    INSERT `{"MT_STD":{"__delta":{"0":null}}}` INTO TABLE temp158.
    INSERT `{"MT_STD":{"__delta":{"999999999999":{"COL1":"Z"}}}}` INTO TABLE temp158.
    INSERT `{"MT_STD":{"__delta":{"1e3":{"COL1":"Z"}}}}` INTO TABLE temp158.
    INSERT `{"MT_STD":{"":"boom"}}` INTO TABLE temp158.
    INSERT `{"MT_STD":{"__delta":{"":{"COL1":"Z"}}}}` INTO TABLE temp158.
    INSERT `{"MT_STD":{"__delta":{"0":{"":"Z"}}}}` INTO TABLE temp158.
    INSERT `{"MT_STD":{"__delta":{"0":{"NOPE":"Z"}}}}` INTO TABLE temp158.
    INSERT `{"MT_STD":{"__delta":{"0":{"__DELTA":"Z"}}}}` INTO TABLE temp158.
    INSERT `{"MT_STD":{"__delta":{"0":{"COL1":{"__delta":{"0":{"X":1}}}}}}}` INTO TABLE temp158.
    INSERT `{"MT_STD":{"__delta":{"0":{"COL2":{"__delta":{"0":{"X":1}}}}}}}` INTO TABLE temp158.
    INSERT `{"MT_STD":"boom"}` INTO TABLE temp158.
    INSERT `{"MT_STD":42}` INTO TABLE temp158.

    lt_hostile = temp158.


    LOOP AT lt_hostile INTO lv_json.
      TRY.
          mo_model->main_json_to_attri( delta( lv_json ) ).
        CATCH z2ui5_cx_ui5_util_error ##NO_HANDLER.
          " an exception IS a legitimate answer - the handler renders it
        CATCH z2ui5_cx_ui5_ajs_error ##NO_HANDLER.
          " so is the parser's own: an empty-keyed member never reaches the
          " model, and the single top-level CATCH cx_root renders this one
          " the same way. What must NOT happen is a runtime error, and that
          " is what the assertions below hold
      ENDTRY.
      cl_abap_unit_assert=>assert_equals( exp = 2
                                          act = lines( mo_app->mt_std )
                                          msg = |rows changed by { lv_json }| ).


      temp161 = sy-tabix.
      READ TABLE mo_app->mt_std INDEX 1 ASSIGNING <temp160>.
      sy-tabix = temp161.
      IF sy-subrc <> 0.
        ASSERT 1 = 0.
      ENDIF.
      cl_abap_unit_assert=>assert_equals( exp = `a`
                                          act = <temp160>-col1
                                          msg = |row 1 changed by { lv_json }| ).


      temp163 = sy-tabix.
      READ TABLE mo_app->mt_std INDEX 2 ASSIGNING <temp162>.
      sy-tabix = temp163.
      IF sy-subrc <> 0.
        ASSERT 1 = 0.
      ENDIF.
      cl_abap_unit_assert=>assert_equals( exp = `b`
                                          act = <temp162>-col1
                                          msg = |row 2 changed by { lv_json }| ).
    ENDLOOP.

    " A PADDED index is not one of those: `" 1 "` converts like any other
    " ABAP numeric text and addresses the row it names. Stated because it
    " looks like the shapes above and is not one - it stays inside the
    " table, which is all this test is about
    mo_model->main_json_to_attri( delta( `{"MT_STD":{"__delta":{" 1 ":{"COL1":"Z"}}}}` ) ).
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( mo_app->mt_std ) ).


    temp165 = sy-tabix.
    READ TABLE mo_app->mt_std INDEX 1 ASSIGNING <temp164>.
    sy-tabix = temp165.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `a`
                                        act = <temp164>-col1 ).


    temp167 = sy-tabix.
    READ TABLE mo_app->mt_std INDEX 2 ASSIGNING <temp166>.
    sy-tabix = temp167.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `Z`
                                        act = <temp166>-col1 ).

  ENDMETHOD.

  METHOD delta_into_dref_table.

    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <row> TYPE any.
    FIELD-SYMBOLS <col> TYPE any.

    " the runtime-built table behind a generic reference (samples 339, 344)
    DATA lr_attri TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.
    DATA lv_key TYPE string.
    DATA temp38 TYPE xsdboolean.
    lr_attri = bind( mo_app->mr_handle_tab ).

    lv_key = substring( val = lr_attri->name_client
                              off = 1 ).
    mo_model->main_json_to_attri( delta( |\{"{ lv_key }":\{"__delta":\{"1":\{"COL1":"edited"\}\}\}\}| ) ).

    ASSIGN mo_app->mr_handle_tab->* TO <tab>.
    READ TABLE <tab> INDEX 2 ASSIGNING <row>.

    temp38 = boolc( <row> IS ASSIGNED ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp38 ).
    ASSIGN COMPONENT `COL1` OF STRUCTURE <row> TO <col>.
    cl_abap_unit_assert=>assert_subrc( ).
    cl_abap_unit_assert=>assert_equals( exp = `edited`
                                        act = <col> ).
    cl_abap_unit_assert=>assert_initial( mo_model->mt_skipped ).

  ENDMETHOD.

  METHOD delta_into_helper_table.

    " the table inside the helper object (the layout rows of sample 332)
    DATA temp168 LIKE REF TO mo_app->mo_inner->mt_own.
    FIELD-SYMBOLS <temp169> LIKE LINE OF mo_app->mo_inner->mt_own.
    DATA temp170 LIKE sy-tabix.
    FIELD-SYMBOLS <temp171> LIKE LINE OF mo_app->mo_inner->mt_own.
    DATA temp172 LIKE sy-tabix.
    GET REFERENCE OF mo_app->mo_inner->mt_own INTO temp168.
bind( temp168 ).
    mo_model->main_json_to_attri( delta( `{"MO_INNER_MT_OWN":{"__delta":{"0":{"COL1":"own-edited","COL2":6}}}}` ) ).



    temp170 = sy-tabix.
    READ TABLE mo_app->mo_inner->mt_own INDEX 1 ASSIGNING <temp169>.
    sy-tabix = temp170.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `own-edited`
                                        act = <temp169>-col1 ).


    temp172 = sy-tabix.
    READ TABLE mo_app->mo_inner->mt_own INDEX 1 ASSIGNING <temp171>.
    sy-tabix = temp172.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = 6
                                        act = <temp171>-col2 ).
    cl_abap_unit_assert=>assert_initial( mo_model->mt_skipped ).

  ENDMETHOD.

  METHOD delta_nested.

    DATA lo_app TYPE REF TO ltcl_app_tree.
    DATA lr_attri TYPE REF TO z2ui5_if_ui5_types=>ty_t_attri.
    DATA lo_model TYPE REF TO z2ui5_cl_ui5_srv_model.
    FIELD-SYMBOLS <temp173> LIKE LINE OF lo_app->mt_tree.
    DATA temp174 LIKE sy-tabix.
    FIELD-SYMBOLS <temp175> LIKE LINE OF lo_app->mt_tree.
    DATA temp176 LIKE sy-tabix.
    FIELD-SYMBOLS <temp34> LIKE LINE OF <temp175>-nodes.
    DATA temp35 LIKE sy-tabix.
    FIELD-SYMBOLS <temp177> LIKE LINE OF lo_app->mt_tree.
    DATA temp178 LIKE sy-tabix.
    FIELD-SYMBOLS <temp36> LIKE LINE OF <temp177>-nodes.
    DATA temp37 LIKE sy-tabix.
    FIELD-SYMBOLS <temp179> LIKE LINE OF lo_app->mt_tree.
    DATA temp180 LIKE sy-tabix.
    FIELD-SYMBOLS <temp181> LIKE LINE OF lo_app->mt_tree.
    DATA temp182 LIKE sy-tabix.
    FIELD-SYMBOLS <temp183> LIKE LINE OF lo_app->mt_tree.
    DATA temp184 LIKE sy-tabix.
    FIELD-SYMBOLS <temp185> LIKE LINE OF lo_app->mt_tree.
    DATA temp186 LIKE sy-tabix.
    FIELD-SYMBOLS <temp38> LIKE LINE OF <temp185>-nodes.
    DATA temp39 LIKE sy-tabix.
    lo_app = tree_app( ).

    CREATE DATA lr_attri.

    CREATE OBJECT lo_model TYPE z2ui5_cl_ui5_srv_model EXPORTING attri = lr_attri app = lo_app.

    " a cell inside the nested table, a root cell next to it
    lo_model->delta_apply_to_table( io_val_front = delta( `{"__delta":{"0":{"ENABLED":true,"NODES":{"__delta":{"1":{"VALIDATED":true}}}}}}` )
                                    iv_name      = `MT_TREE` ).


    temp174 = sy-tabix.
    READ TABLE lo_app->mt_tree INDEX 1 ASSIGNING <temp173>.
    sy-tabix = temp174.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = <temp173>-enabled ).


    temp176 = sy-tabix.
    READ TABLE lo_app->mt_tree INDEX 1 ASSIGNING <temp175>.
    sy-tabix = temp176.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.


    temp35 = sy-tabix.
    READ TABLE <temp175>-nodes INDEX 2 ASSIGNING <temp34>.
    sy-tabix = temp35.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = <temp34>-validated ).


    temp178 = sy-tabix.
    READ TABLE lo_app->mt_tree INDEX 1 ASSIGNING <temp177>.
    sy-tabix = temp178.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.


    temp37 = sy-tabix.
    READ TABLE <temp177>-nodes INDEX 1 ASSIGNING <temp36>.
    sy-tabix = temp37.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = abap_false
                                        act = <temp36>-validated ).


    temp180 = sy-tabix.
    READ TABLE lo_app->mt_tree INDEX 1 ASSIGNING <temp179>.
    sy-tabix = temp180.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `Manager`
                                        act = <temp179>-user ).

    " a structure cell ships whole
    lo_model->delta_apply_to_table( io_val_front = delta( `{"__delta":{"0":{"S_ADR":{"CITY":"Berlin","ZIP":"10115"}}}}` )
                                    iv_name      = `MT_TREE` ).


    temp182 = sy-tabix.
    READ TABLE lo_app->mt_tree INDEX 1 ASSIGNING <temp181>.
    sy-tabix = temp182.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `Berlin`
                                        act = <temp181>-s_adr-city ).

    " a whole sub-table value replaces the nested table
    lo_model->delta_apply_to_table( io_val_front = delta( `{"__delta":{"0":{"NODES":[{"USER":"NEW","VALIDATED":true}]}}}` )
                                    iv_name      = `MT_TREE` ).


    temp184 = sy-tabix.
    READ TABLE lo_app->mt_tree INDEX 1 ASSIGNING <temp183>.
    sy-tabix = temp184.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( <temp183>-nodes ) ).


    temp186 = sy-tabix.
    READ TABLE lo_app->mt_tree INDEX 1 ASSIGNING <temp185>.
    sy-tabix = temp186.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.


    temp39 = sy-tabix.
    READ TABLE <temp185>-nodes INDEX 1 ASSIGNING <temp38>.
    sy-tabix = temp39.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `NEW`
                                        act = <temp38>-user ).

  ENDMETHOD.

  METHOD delta_typed_cells.

    DATA lo_app TYPE REF TO ltcl_app_typed.
    DATA lo_model TYPE REF TO z2ui5_cl_ui5_srv_model.
    DATA temp187 TYPE decfloat34.
    DATA temp40 TYPE decfloat34.
    FIELD-SYMBOLS <temp1> LIKE LINE OF lo_app->mt_tab.
    DATA temp2 LIKE sy-tabix.
    DATA lv_date TYPE d VALUE '20240115'.
    DATA lv_time TYPE t VALUE '123045'.
    DATA lv_ts TYPE timestamp VALUE '20240115123045'.
    FIELD-SYMBOLS <temp188> LIKE LINE OF lo_app->mt_tab.
    DATA temp189 LIKE sy-tabix.
    FIELD-SYMBOLS <temp190> LIKE LINE OF lo_app->mt_tab.
    DATA temp191 LIKE sy-tabix.
    FIELD-SYMBOLS <temp192> LIKE LINE OF lo_app->mt_tab.
    DATA temp193 LIKE sy-tabix.
    FIELD-SYMBOLS <temp194> LIKE LINE OF lo_app->mt_tab.
    DATA temp195 LIKE sy-tabix.
    FIELD-SYMBOLS <temp196> LIKE LINE OF lo_app->mt_tab.
    DATA temp197 LIKE sy-tabix.
    DATA lv_date_init TYPE d.
    DATA lv_time_init TYPE t.
    FIELD-SYMBOLS <temp198> LIKE LINE OF lo_app->mt_tab.
    DATA temp199 LIKE sy-tabix.
    FIELD-SYMBOLS <temp200> LIKE LINE OF lo_app->mt_tab.
    DATA temp201 LIKE sy-tabix.
    FIELD-SYMBOLS <temp202> LIKE LINE OF lo_app->mt_tab.
    DATA temp203 LIKE sy-tabix.
    DATA temp39 TYPE xsdboolean.
    FIELD-SYMBOLS <temp204> LIKE LINE OF lo_app->mt_tab.
    DATA temp205 LIKE sy-tabix.
    FIELD-SYMBOLS <temp206> LIKE LINE OF lo_app->mt_tab.
    DATA temp207 LIKE sy-tabix.
    DATA lv_ts_cut TYPE timestamp VALUE '20240115123059'.
    FIELD-SYMBOLS <temp208> LIKE LINE OF lo_app->mt_tab.
    DATA temp209 LIKE sy-tabix.
    DATA temp210 TYPE decfloat34.
    DATA temp41 TYPE decfloat34.
    FIELD-SYMBOLS <temp3> LIKE LINE OF lo_app->mt_tab.
    DATA temp4 LIKE sy-tabix.
    FIELD-SYMBOLS <temp211> LIKE LINE OF lo_app->mt_tab.
    DATA temp212 LIKE sy-tabix.
    DATA temp213 TYPE decfloat34.
    DATA temp42 TYPE decfloat34.
    FIELD-SYMBOLS <temp5> LIKE LINE OF lo_app->mt_tab.
    DATA temp6 LIKE sy-tabix.
    lo_app = typed_app( ).

    lo_model = typed_model( lo_app ).

    " accepted
    lo_model->delta_apply_to_table( io_val_front = delta( `{"__delta":{"0":{"PRICE":"1250.00"}}}` )
                                    iv_name      = `MT_TAB` ).

    temp187 = '1250.00'.



    temp2 = sy-tabix.
    READ TABLE lo_app->mt_tab INDEX 1 ASSIGNING <temp1>.
    sy-tabix = temp2.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    temp40 = <temp1>-price.
    cl_abap_unit_assert=>assert_equals( exp = temp187
                                        act = temp40 ).
    cl_abap_unit_assert=>assert_initial( lo_model->mt_skipped ).

    " the ISO spelling ajson wrote, and a plain date
    lo_model->delta_apply_to_table( io_val_front = delta( `{"__delta":{"0":{"DT":"2024-01-15","TM":"12:30:45","TS":"2024-01-15T12:30:45Z"},"1":{"DT":"20240115","TM":""}}}` )
                                    iv_name      = `MT_TAB` ).





    temp189 = sy-tabix.
    READ TABLE lo_app->mt_tab INDEX 1 ASSIGNING <temp188>.
    sy-tabix = temp189.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = lv_date
                                        act = <temp188>-dt ).


    temp191 = sy-tabix.
    READ TABLE lo_app->mt_tab INDEX 1 ASSIGNING <temp190>.
    sy-tabix = temp191.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = lv_time
                                        act = <temp190>-tm ).


    temp193 = sy-tabix.
    READ TABLE lo_app->mt_tab INDEX 1 ASSIGNING <temp192>.
    sy-tabix = temp193.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = lv_ts
                                        act = <temp192>-ts ).


    temp195 = sy-tabix.
    READ TABLE lo_app->mt_tab INDEX 2 ASSIGNING <temp194>.
    sy-tabix = temp195.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = lv_date
                                        act = <temp194>-dt ).


    temp197 = sy-tabix.
    READ TABLE lo_app->mt_tab INDEX 2 ASSIGNING <temp196>.
    sy-tabix = temp197.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_initial( <temp196>-tm ).
    cl_abap_unit_assert=>assert_initial( lo_model->mt_skipped ).

    " a cleared picker sends "" - the initial date/time, not eight blanks
    " (which is not IS INITIAL and which ajson shipped back as `    -  -  `)


    lo_model->delta_apply_to_table( io_val_front = delta( `{"__delta":{"0":{"DT":"","TM":""}}}` )
                                    iv_name      = `MT_TAB` ).


    temp199 = sy-tabix.
    READ TABLE lo_app->mt_tab INDEX 1 ASSIGNING <temp198>.
    sy-tabix = temp199.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = lv_date_init
                                        act = <temp198>-dt ).


    temp201 = sy-tabix.
    READ TABLE lo_app->mt_tab INDEX 1 ASSIGNING <temp200>.
    sy-tabix = temp201.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = lv_time_init
                                        act = <temp200>-tm ).


    temp203 = sy-tabix.
    READ TABLE lo_app->mt_tab INDEX 1 ASSIGNING <temp202>.
    sy-tabix = temp203.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.

    temp39 = boolc( <temp202>-dt IS INITIAL ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp39 ).
    cl_abap_unit_assert=>assert_initial( lo_model->mt_skipped ).

    " an instant with a NEGATIVE offset is one ajson cannot read - it used
    " to answer an initial timestamp that was assigned without a word; now
    " it is a refusal: the old value stands and the cell is traced
    lo_model->delta_apply_to_table( io_val_front = delta( `{"__delta":{"0":{"TS":"2024-01-15T12:30:45Z"}}}` )
                                    iv_name      = `MT_TAB` ).
    lo_model->delta_apply_to_table( io_val_front = delta( `{"__delta":{"0":{"TS":"2024-01-15T12:30:45-05:00"}}}` )
                                    iv_name      = `MT_TAB` ).


    temp205 = sy-tabix.
    READ TABLE lo_app->mt_tab INDEX 1 ASSIGNING <temp204>.
    sy-tabix = temp205.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = lv_ts
                                        act = <temp204>-ts ).
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( lo_model->mt_skipped ) ).
    CLEAR lo_model->mt_skipped.

    " the initial timestamp as ajson writes it is the initial value, not a
    " refusal - it comes back untouched with every sibling edit
    lo_model->delta_apply_to_table( io_val_front = delta( `{"__delta":{"0":{"TS":"0000-00-00T00:00:00Z"}}}` )
                                    iv_name      = `MT_TAB` ).


    temp207 = sy-tabix.
    READ TABLE lo_app->mt_tab INDEX 1 ASSIGNING <temp206>.
    sy-tabix = temp207.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_initial( <temp206>-ts ).
    cl_abap_unit_assert=>assert_initial( lo_model->mt_skipped ).

    " a fraction a short TIMESTAMP cannot carry is cut off, not rounded:
    " rounded, .6 made second 60 - 20240115123060 is no timestamp at all
    lo_model->delta_apply_to_table( io_val_front = delta( `{"__delta":{"0":{"TS":"2024-01-15T12:30:59.6Z"}}}` )
                                    iv_name      = `MT_TAB` ).



    temp209 = sy-tabix.
    READ TABLE lo_app->mt_tab INDEX 1 ASSIGNING <temp208>.
    sy-tabix = temp209.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = lv_ts_cut
                                        act = <temp208>-ts ).
    cl_abap_unit_assert=>assert_initial( lo_model->mt_skipped ).

    " refused: the grouped thousands separator, text into a number - the
    " old value stands (on a system the failed conversion clears the target
    " first; the copy in delta_apply_field puts it back), the good cell in
    " the same delta lands, a field that is not in the delta is no finding
    lo_model->delta_apply_to_table( io_val_front = delta( `{"__delta":{"0":{"PRICE":"abc","NAME":"Laptop","NOT_A_COMPONENT":"x"},"1":{"PRICE":"1,250.00"}}}` )
                                    iv_name      = `MT_TAB` ).

    temp210 = '1250.00'.



    temp4 = sy-tabix.
    READ TABLE lo_app->mt_tab INDEX 1 ASSIGNING <temp3>.
    sy-tabix = temp4.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    temp41 = <temp3>-price.
    cl_abap_unit_assert=>assert_equals( exp = temp210
                                        act = temp41 ).


    temp212 = sy-tabix.
    READ TABLE lo_app->mt_tab INDEX 1 ASSIGNING <temp211>.
    sy-tabix = temp212.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `Laptop`
                                        act = <temp211>-name ).

    temp213 = '299.00'.



    temp6 = sy-tabix.
    READ TABLE lo_app->mt_tab INDEX 2 ASSIGNING <temp5>.
    sy-tabix = temp6.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    temp42 = <temp5>-price.
    cl_abap_unit_assert=>assert_equals( exp = temp213
                                        act = temp42 ).
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( lo_model->mt_skipped ) ).

  ENDMETHOD.

  METHOD delta_trace.

    DATA lo_app TYPE REF TO ltcl_app_typed.
    DATA lo_model TYPE REF TO z2ui5_cl_ui5_srv_model.
    DATA ls_skip TYPE z2ui5_if_client=>ty_s_model_skip.
    FIELD-SYMBOLS <temp43> LIKE LINE OF lo_model->mt_skipped.
    DATA temp44 LIKE sy-tabix.
    FIELD-SYMBOLS <temp214> LIKE LINE OF lo_app->mt_tab.
    DATA temp215 LIKE sy-tabix.
    FIELD-SYMBOLS <temp45> LIKE LINE OF <temp214>-t_pos.
    DATA temp46 LIKE sy-tabix.
    FIELD-SYMBOLS <temp216> LIKE LINE OF lo_model->mt_skipped.
    DATA temp217 LIKE sy-tabix.
    lo_app = typed_app( ).

    lo_model = typed_model( lo_app ).

    " a top-level cell: name, row, field, the raw value, no parent
    lo_model->delta_apply_to_table( io_val_front = delta( `{"__delta":{"1":{"PRICE":"1,250.00"}}}` )
                                    iv_name      = `MT_TAB` ).
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( lo_model->mt_skipped ) ).



    temp44 = sy-tabix.
    READ TABLE lo_model->mt_skipped INDEX 1 ASSIGNING <temp43>.
    sy-tabix = temp44.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    ls_skip = <temp43>.
    cl_abap_unit_assert=>assert_equals( exp = `MT_TAB`
                                        act = ls_skip-name ).
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = ls_skip-row ).
    cl_abap_unit_assert=>assert_equals( exp = `PRICE`
                                        act = ls_skip-field ).
    cl_abap_unit_assert=>assert_equals( exp = `1,250.00`
                                        act = ls_skip-value ).
    cl_abap_unit_assert=>assert_equals( exp = 0
                                        act = ls_skip-row_parent ).

    " a nested cell under the SECOND outer row: the path parent first, the
    " row inside the inner table, the outer record as row_parent
    CLEAR lo_model->mt_skipped.
    lo_model->delta_apply_to_table( io_val_front = delta( `{"__delta":{"1":{"T_POS":{"__delta":{"0":{"QTY":"many"}}}}}}` )
                                    iv_name      = `MT_TAB` ).


    temp215 = sy-tabix.
    READ TABLE lo_app->mt_tab INDEX 2 ASSIGNING <temp214>.
    sy-tabix = temp215.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.


    temp46 = sy-tabix.
    READ TABLE <temp214>-t_pos INDEX 1 ASSIGNING <temp45>.
    sy-tabix = temp46.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = <temp45>-qty ).


    temp217 = sy-tabix.
    READ TABLE lo_model->mt_skipped INDEX 1 ASSIGNING <temp216>.
    sy-tabix = temp217.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    ls_skip = <temp216>.
    cl_abap_unit_assert=>assert_equals( exp = `MT_TAB-T_POS`
                                        act = ls_skip-name ).
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = ls_skip-row ).
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = ls_skip-row_parent ).
    cl_abap_unit_assert=>assert_equals( exp = `many`
                                        act = ls_skip-value ).

  ENDMETHOD.

  METHOD delta_sorted_refused.

    DATA lo_app TYPE REF TO ltcl_app_typed.
    DATA temp218 TYPE ltcl_app_typed=>ty_s_row.
    DATA lo_model TYPE REF TO z2ui5_cl_ui5_srv_model.
    DATA temp219 TYPE decfloat34.
    DATA temp47 TYPE decfloat34.
    FIELD-SYMBOLS <temp7> LIKE LINE OF lo_app->mt_sorted.
    DATA temp8 LIKE sy-tabix.
    FIELD-SYMBOLS <temp220> LIKE LINE OF lo_model->mt_skipped.
    DATA temp221 LIKE sy-tabix.
    DATA temp40 TYPE xsdboolean.
    DATA temp6 LIKE sy-subrc.
    DATA temp7 LIKE sy-subrc.
    DATA temp9 LIKE sy-tabix.
    DATA temp222 LIKE REF TO mo_app->mt_sorted.
    FIELD-SYMBOLS <temp223> LIKE LINE OF mo_app->mt_sorted.
    DATA temp224 LIKE sy-tabix.
    lo_app = typed_app( ).

    CLEAR temp218.
    temp218-name = `Monitor`.
    temp218-price = '299.00'.
    INSERT temp218 INTO TABLE lo_app->mt_sorted.

    lo_model = typed_model( lo_app ).

    " a sorted table takes no row delta - every cell of it is traced, the
    " table untouched (decided by RTTI: the ASSIGN to a standard-table field
    " symbol is a runtime error on a system)
    lo_model->delta_apply_to_table( io_val_front = delta( `{"__delta":{"0":{"PRICE":"1250.00","NAME":"Screen"}}}` )
                                    iv_name      = `MT_SORTED` ).

    temp219 = '299.00'.



    temp8 = sy-tabix.
    READ TABLE lo_app->mt_sorted INDEX 1 ASSIGNING <temp7>.
    sy-tabix = temp8.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    temp47 = <temp7>-price.
    cl_abap_unit_assert=>assert_equals( exp = temp219
                                        act = temp47 ).
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( lo_model->mt_skipped ) ).


    temp221 = sy-tabix.
    READ TABLE lo_model->mt_skipped INDEX 1 ASSIGNING <temp220>.
    sy-tabix = temp221.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `MT_SORTED`
                                        act = <temp220>-name ).




    temp7 = sy-subrc.
    temp9 = sy-tabix.
    READ TABLE lo_model->mt_skipped WITH KEY field = `PRICE` value = `1250.00` TRANSPORTING NO FIELDS.
    temp6 = sy-subrc.
    sy-subrc = temp7.
    sy-tabix = temp9.
    temp40 = boolc( temp6 = 0 ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp40 ). "#EC CI_SORTSEQ

    " the same for the fixture's sorted table, through the model path

    GET REFERENCE OF mo_app->mt_sorted INTO temp222.
bind( temp222 ).
    mo_model->main_json_to_attri( delta( `{"MT_SORTED":{"__delta":{"0":{"COL2":1}}}}` ) ).


    temp224 = sy-tabix.
    READ TABLE mo_app->mt_sorted INDEX 1 ASSIGNING <temp223>.
    sy-tabix = temp224.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = 9
                                        act = <temp223>-col2 ).
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( mo_model->mt_skipped ) ).

  ENDMETHOD.

  METHOD delta_row_past_end.

    DATA lo_app TYPE REF TO ltcl_app_typed.
    DATA lo_model TYPE REF TO z2ui5_cl_ui5_srv_model.
    DATA ls_skip TYPE z2ui5_if_client=>ty_s_model_skip.
    FIELD-SYMBOLS <temp48> LIKE LINE OF lo_model->mt_skipped.
    DATA temp49 LIKE sy-tabix.
    FIELD-SYMBOLS <temp225> LIKE LINE OF lo_app->mt_tab.
    DATA temp226 LIKE sy-tabix.
    FIELD-SYMBOLS <temp227> LIKE LINE OF lo_app->mt_tab.
    DATA temp228 LIKE sy-tabix.
    FIELD-SYMBOLS <temp50> LIKE LINE OF <temp227>-t_pos.
    DATA temp51 LIKE sy-tabix.
    FIELD-SYMBOLS <temp229> LIKE LINE OF lo_model->mt_skipped.
    DATA temp230 LIKE sy-tabix.
    lo_app = typed_app( ).

    lo_model = typed_model( lo_app ).

    " row index 5 of a two-row table: no row is appended, and every cell of
    " the row is traced like a sorted-table row - it used to vanish without
    " an entry while the browser kept showing the edit
    lo_model->delta_apply_to_table( io_val_front = delta( `{"__delta":{"4":{"PRICE":"1.00","NAME":"Ghost"}}}` )
                                    iv_name      = `MT_TAB` ).
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( lo_app->mt_tab ) ).
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( lo_model->mt_skipped ) ).



    temp49 = sy-tabix.
    READ TABLE lo_model->mt_skipped WITH KEY field = `NAME` ASSIGNING <temp48>.
    sy-tabix = temp49.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    ls_skip = <temp48>. "#EC CI_SORTSEQ
    cl_abap_unit_assert=>assert_equals( exp = `MT_TAB`
                                        act = ls_skip-name ).
    cl_abap_unit_assert=>assert_equals( exp = 5
                                        act = ls_skip-row ).
    cl_abap_unit_assert=>assert_equals( exp = `Ghost`
                                        act = ls_skip-value ).
    cl_abap_unit_assert=>assert_equals( exp = 0
                                        act = ls_skip-row_parent ).

    " the same for a nested table: the inner index, the outer record as
    " row_parent, and the existing inner row untouched
    CLEAR lo_model->mt_skipped.
    lo_model->delta_apply_to_table( io_val_front = delta( `{"__delta":{"1":{"T_POS":{"__delta":{"3":{"QTY":"7"}}}}}}` )
                                    iv_name      = `MT_TAB` ).


    temp226 = sy-tabix.
    READ TABLE lo_app->mt_tab INDEX 2 ASSIGNING <temp225>.
    sy-tabix = temp226.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( <temp225>-t_pos ) ).


    temp228 = sy-tabix.
    READ TABLE lo_app->mt_tab INDEX 2 ASSIGNING <temp227>.
    sy-tabix = temp228.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.


    temp51 = sy-tabix.
    READ TABLE <temp227>-t_pos INDEX 1 ASSIGNING <temp50>.
    sy-tabix = temp51.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = <temp50>-qty ).
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( lo_model->mt_skipped ) ).


    temp230 = sy-tabix.
    READ TABLE lo_model->mt_skipped INDEX 1 ASSIGNING <temp229>.
    sy-tabix = temp230.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    ls_skip = <temp229>.
    cl_abap_unit_assert=>assert_equals( exp = `MT_TAB-T_POS`
                                        act = ls_skip-name ).
    cl_abap_unit_assert=>assert_equals( exp = 4
                                        act = ls_skip-row ).
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = ls_skip-row_parent ).
    cl_abap_unit_assert=>assert_equals( exp = `7`
                                        act = ls_skip-value ).

  ENDMETHOD.

  METHOD delta_struct_cell_whole.

    DATA lo_app TYPE REF TO ltcl_app_tree.
    DATA lr_attri TYPE REF TO z2ui5_if_ui5_types=>ty_t_attri.
    DATA lo_model TYPE REF TO z2ui5_cl_ui5_srv_model.
    FIELD-SYMBOLS <temp231> LIKE LINE OF lo_app->mt_tree.
    DATA temp232 LIKE sy-tabix.
    FIELD-SYMBOLS <temp233> LIKE LINE OF lo_app->mt_tree.
    DATA temp234 LIKE sy-tabix.
    FIELD-SYMBOLS <temp235> LIKE LINE OF lo_app->mt_tree.
    DATA temp236 LIKE sy-tabix.
    FIELD-SYMBOLS <temp237> LIKE LINE OF lo_app->mt_tree.
    DATA temp238 LIKE sy-tabix.
    FIELD-SYMBOLS <temp239> LIKE LINE OF lo_app->mt_tree.
    DATA temp240 LIKE sy-tabix.
    FIELD-SYMBOLS <temp241> LIKE LINE OF lo_app->mt_tree.
    DATA temp242 LIKE sy-tabix.
    lo_app = tree_app( ).

    CREATE DATA lr_attri.

    CREATE OBJECT lo_model TYPE z2ui5_cl_ui5_srv_model EXPORTING attri = lr_attri app = lo_app.

    " what the client sends for an edit of /MT_TREE/0/S_ADR/CITY: the whole
    " structure, read from its current model - every component lands
    lo_model->delta_apply_to_table( io_val_front = delta( `{"__delta":{"0":{"S_ADR":{"CITY":"New Town","ZIP":"00000"}}}}` )
                                    iv_name      = `MT_TREE` ).


    temp232 = sy-tabix.
    READ TABLE lo_app->mt_tree INDEX 1 ASSIGNING <temp231>.
    sy-tabix = temp232.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `New Town`
                                        act = <temp231>-s_adr-city ).


    temp234 = sy-tabix.
    READ TABLE lo_app->mt_tree INDEX 1 ASSIGNING <temp233>.
    sy-tabix = temp234.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `00000`
                                        act = <temp233>-s_adr-zip ).
    cl_abap_unit_assert=>assert_initial( lo_model->mt_skipped ).

    " a component the object leaves out is cleared, not kept: the cell is a
    " replace (see delta_apply_field). The client leaves out only what it
    " never received - an initial value under omit_initial - so for its own
    " requests the two readings agree; this pins which one the model takes
    lo_model->delta_apply_to_table( io_val_front = delta( `{"__delta":{"0":{"S_ADR":{"CITY":"Other Town"}}}}` )
                                    iv_name      = `MT_TREE` ).


    temp236 = sy-tabix.
    READ TABLE lo_app->mt_tree INDEX 1 ASSIGNING <temp235>.
    sy-tabix = temp236.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `Other Town`
                                        act = <temp235>-s_adr-city ).


    temp238 = sy-tabix.
    READ TABLE lo_app->mt_tree INDEX 1 ASSIGNING <temp237>.
    sy-tabix = temp238.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_initial( <temp237>-s_adr-zip ).
    " the sibling cells of the row are no part of the structure


    temp240 = sy-tabix.
    READ TABLE lo_app->mt_tree INDEX 1 ASSIGNING <temp239>.
    sy-tabix = temp240.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `Manager`
                                        act = <temp239>-user ).


    temp242 = sy-tabix.
    READ TABLE lo_app->mt_tree INDEX 1 ASSIGNING <temp241>.
    sy-tabix = temp242.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( <temp241>-nodes ) ).

  ENDMETHOD.

  METHOD delta_kind_refused.

    " a cell whose column takes no value of the shape the wire carries is
    " traced and left alone, never assigned: a string into a REF TO data or
    " a scalar into a nested table is no class-based exception on a system
    " but a runtime error, so the skip has to be decided up front. The
    " reference cell needs no crafted request - ajson ships it as its plain
    " value, and an Input bound to it sends a string back
    DATA temp243 LIKE REF TO mo_app->mt_rows_ref.
    DATA lr_before TYPE REF TO string.
    FIELD-SYMBOLS <temp52> LIKE LINE OF mo_app->mt_rows_ref.
    DATA temp53 LIKE sy-tabix.
    FIELD-SYMBOLS <temp244> LIKE LINE OF mo_model->mt_skipped.
    DATA temp245 LIKE sy-tabix.
    FIELD-SYMBOLS <temp246> LIKE LINE OF mo_model->mt_skipped.
    DATA temp247 LIKE sy-tabix.
    FIELD-SYMBOLS <temp248> LIKE LINE OF mo_app->mt_rows_ref.
    DATA temp249 LIKE sy-tabix.
    DATA temp41 TYPE xsdboolean.
    FIELD-SYMBOLS <temp250> LIKE LINE OF mo_app->mt_rows_ref.
    DATA temp251 LIKE sy-tabix.
    DATA temp252 LIKE REF TO mo_app->mt_nested.
    FIELD-SYMBOLS <temp253> LIKE LINE OF mo_model->mt_skipped.
    DATA temp254 LIKE sy-tabix.
    FIELD-SYMBOLS <temp255> LIKE LINE OF mo_app->mt_nested.
    DATA temp256 LIKE sy-tabix.
    FIELD-SYMBOLS <temp257> LIKE LINE OF mo_app->mt_nested.
    DATA temp258 LIKE sy-tabix.
    GET REFERENCE OF mo_app->mt_rows_ref INTO temp243.
bind( temp243 ).



    temp53 = sy-tabix.
    READ TABLE mo_app->mt_rows_ref INDEX 1 ASSIGNING <temp52>.
    sy-tabix = temp53.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    lr_before = <temp52>-r_elem.
    mo_model->main_json_to_attri( delta( `{"MT_ROWS_REF":{"__delta":{"0":{"R_ELEM":"x"}}}}` ) ).
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( mo_model->mt_skipped ) ).


    temp245 = sy-tabix.
    READ TABLE mo_model->mt_skipped INDEX 1 ASSIGNING <temp244>.
    sy-tabix = temp245.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `R_ELEM`
                                        act = <temp244>-field ).


    temp247 = sy-tabix.
    READ TABLE mo_model->mt_skipped INDEX 1 ASSIGNING <temp246>.
    sy-tabix = temp247.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `x`
                                        act = <temp246>-value ).


    temp249 = sy-tabix.
    READ TABLE mo_app->mt_rows_ref INDEX 1 ASSIGNING <temp248>.
    sy-tabix = temp249.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.

    temp41 = boolc( <temp248>-r_elem = lr_before ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp41 ).


    temp251 = sy-tabix.
    READ TABLE mo_app->mt_rows_ref INDEX 1 ASSIGNING <temp250>.
    sy-tabix = temp251.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `cell-ref`
                                        act = <temp250>-r_elem->* ).

    " a scalar into a nested table column, next to a digit-only key that
    " would address a component by position: the first is traced, the
    " second skipped, the row is untouched
    CLEAR mo_model->mt_skipped.

    GET REFERENCE OF mo_app->mt_nested INTO temp252.
bind( temp252 ).
    mo_model->main_json_to_attri( delta( `{"MT_NESTED":{"__delta":{"0":{"T_ITEMS":"x","0":"y"}}}}` ) ).
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( mo_model->mt_skipped ) ).


    temp254 = sy-tabix.
    READ TABLE mo_model->mt_skipped INDEX 1 ASSIGNING <temp253>.
    sy-tabix = temp254.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `T_ITEMS`
                                        act = <temp253>-field ).


    temp256 = sy-tabix.
    READ TABLE mo_app->mt_nested INDEX 1 ASSIGNING <temp255>.
    sy-tabix = temp256.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( <temp255>-t_items ) ).


    temp258 = sy-tabix.
    READ TABLE mo_app->mt_nested INDEX 1 ASSIGNING <temp257>.
    sy-tabix = temp258.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `n1`
                                        act = <temp257>-id ).

  ENDMETHOD.

  METHOD delta_mass_edit.

    DATA lo_app TYPE REF TO ltcl_app_typed.
      DATA temp259 TYPE ltcl_app_typed=>ty_s_row.
      DATA temp54 TYPE ltcl_app_typed=>ty_t_pos.
      DATA temp55 LIKE LINE OF temp54.
      DATA temp56 TYPE ltcl_app_typed=>ty_t_pos_sorted.
      DATA temp57 LIKE LINE OF temp56.
    DATA lo_model TYPE REF TO z2ui5_cl_ui5_srv_model.
    DATA lv_json TYPE string.
      FIELD-SYMBOLS <temp260> LIKE LINE OF lo_app->mt_tab.
      DATA temp261 LIKE sy-tabix.
    DATA temp262 TYPE decfloat34.
    DATA temp58 TYPE decfloat34.
    FIELD-SYMBOLS <temp9> LIKE LINE OF lo_app->mt_tab.
    DATA temp10 LIKE sy-tabix.
    DATA temp263 TYPE decfloat34.
    DATA temp59 TYPE decfloat34.
    FIELD-SYMBOLS <temp11> LIKE LINE OF lo_app->mt_tab.
    DATA temp12 LIKE sy-tabix.
    DATA temp264 TYPE decfloat34.
    DATA temp60 TYPE decfloat34.
    FIELD-SYMBOLS <temp13> LIKE LINE OF lo_app->mt_tab.
    DATA temp14 LIKE sy-tabix.
    FIELD-SYMBOLS <temp265> LIKE LINE OF lo_app->mt_tab.
    DATA temp266 LIKE sy-tabix.
    FIELD-SYMBOLS <temp61> LIKE LINE OF <temp265>-t_pos.
    DATA temp62 LIKE sy-tabix.
    FIELD-SYMBOLS <temp267> LIKE LINE OF lo_app->mt_tab.
    DATA temp268 LIKE sy-tabix.
    FIELD-SYMBOLS <temp63> LIKE LINE OF <temp267>-t_sorted.
    DATA temp64 LIKE sy-tabix.
    FIELD-SYMBOLS <temp269> LIKE LINE OF lo_app->mt_tab.
    DATA temp270 LIKE sy-tabix.
    FIELD-SYMBOLS <temp65> LIKE LINE OF <temp269>-t_pos.
    DATA temp66 LIKE sy-tabix.
    DATA temp42 TYPE xsdboolean.
    DATA temp11 LIKE sy-subrc.
    DATA temp43 TYPE xsdboolean.
    DATA temp13 LIKE sy-subrc.
    CREATE OBJECT lo_app TYPE ltcl_app_typed.
    DO 6 TIMES.

      CLEAR temp259.
      temp259-name = |row-{ sy-index }|.
      temp259-price = sy-index * 100.

      CLEAR temp54.

      temp55-qty = sy-index.
      INSERT temp55 INTO TABLE temp54.
      temp259-t_pos = temp54.

      CLEAR temp56.

      temp57-qty = 1.
      INSERT temp57 INTO TABLE temp56.
      temp259-t_sorted = temp56.
      INSERT temp259 INTO TABLE lo_app->mt_tab.
    ENDDO.

    lo_model = typed_model( lo_app ).

    " the select-all shape: one cell in every row - plus a price that does
    " not convert in the third, a nested standard-table cell under the
    " fourth and a nested SORTED table under the fifth

    lv_json = `{"__delta":{`.
    DO 6 TIMES.
      IF sy-index > 1.
        lv_json = lv_json && `,`.
      ENDIF.
      lv_json = lv_json && |"{ sy-index - 1 }":\{"NAME":"edited-{ sy-index }"|.
      CASE sy-index.
        WHEN 3.
          lv_json = lv_json && `,"PRICE":"1,250.00"`.
        WHEN 4.
          lv_json = lv_json && `,"T_POS":{"__delta":{"0":{"QTY":"9"}}}`.
        WHEN 5.
          lv_json = lv_json && `,"T_SORTED":{"__delta":{"0":{"QTY":"5"}}}`.
        WHEN OTHERS.
          lv_json = lv_json && |,"PRICE":"{ sy-index * 10 }.50"|.
      ENDCASE.
      lv_json = lv_json && `}`.
    ENDDO.
    lv_json = lv_json && `}}`.

    lo_model->delta_apply_to_table( io_val_front = delta( lv_json )
                                    iv_name      = `MT_TAB` ).

    " every name landed, the good prices too
    DO 6 TIMES.


      temp261 = sy-tabix.
      READ TABLE lo_app->mt_tab INDEX sy-index ASSIGNING <temp260>.
      sy-tabix = temp261.
      IF sy-subrc <> 0.
        ASSERT 1 = 0.
      ENDIF.
      cl_abap_unit_assert=>assert_equals( exp = |edited-{ sy-index }|
                                          act = <temp260>-name ).
    ENDDO.

    temp262 = '10.50'.



    temp10 = sy-tabix.
    READ TABLE lo_app->mt_tab INDEX 1 ASSIGNING <temp9>.
    sy-tabix = temp10.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    temp58 = <temp9>-price.
    cl_abap_unit_assert=>assert_equals( exp = temp262
                                        act = temp58 ).

    temp263 = '60.50'.



    temp12 = sy-tabix.
    READ TABLE lo_app->mt_tab INDEX 6 ASSIGNING <temp11>.
    sy-tabix = temp12.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    temp59 = <temp11>-price.
    cl_abap_unit_assert=>assert_equals( exp = temp263
                                        act = temp59 ).
    " the refused price keeps its value - the good name in the SAME row was
    " written

    temp264 = '300'.



    temp14 = sy-tabix.
    READ TABLE lo_app->mt_tab INDEX 3 ASSIGNING <temp13>.
    sy-tabix = temp14.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    temp60 = <temp13>-price.
    cl_abap_unit_assert=>assert_equals( exp = temp264
                                        act = temp60 ).
    " the nested standard table took its cell, the nested sorted one did not


    temp266 = sy-tabix.
    READ TABLE lo_app->mt_tab INDEX 4 ASSIGNING <temp265>.
    sy-tabix = temp266.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.


    temp62 = sy-tabix.
    READ TABLE <temp265>-t_pos INDEX 1 ASSIGNING <temp61>.
    sy-tabix = temp62.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = 9
                                        act = <temp61>-qty ).


    temp268 = sy-tabix.
    READ TABLE lo_app->mt_tab INDEX 5 ASSIGNING <temp267>.
    sy-tabix = temp268.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.


    temp64 = sy-tabix.
    READ TABLE <temp267>-t_sorted INDEX 1 ASSIGNING <temp63>.
    sy-tabix = temp64.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = <temp63>-qty ).
    " a cell the delta did not name is untouched, and no row came or went


    temp270 = sy-tabix.
    READ TABLE lo_app->mt_tab INDEX 2 ASSIGNING <temp269>.
    sy-tabix = temp270.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.


    temp66 = sy-tabix.
    READ TABLE <temp269>-t_pos INDEX 1 ASSIGNING <temp65>.
    sy-tabix = temp66.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = <temp65>-qty ).
    cl_abap_unit_assert=>assert_equals( exp = 6
                                        act = lines( lo_app->mt_tab ) ).

    " exactly the two refusals are traced, each naming its cell
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( lo_model->mt_skipped ) ).


    READ TABLE lo_model->mt_skipped WITH KEY name = `MT_TAB` row = 3 field = `PRICE` value = `1,250.00` TRANSPORTING NO FIELDS.
    temp11 = sy-subrc.
    temp42 = boolc( temp11 = 0 ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp42 ). "#EC CI_SORTSEQ


    READ TABLE lo_model->mt_skipped WITH KEY name = `MT_TAB-T_SORTED` row = 1 row_parent = 5 field = `QTY` value = `5` TRANSPORTING NO FIELDS.
    temp13 = sy-subrc.
    temp43 = boolc( temp13 = 0 ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp43 ). "#EC CI_SORTSEQ

  ENDMETHOD.

  METHOD whole_dates_round_trip.

    DATA lv_date TYPE d VALUE '20240229'.
    DATA lv_time TYPE t VALUE '235959'.
    " a whole hour on purpose: the transpiled runtime copies one packed
    " field into another through a JS double, so ajson's TIMESTAMPL for
    " 23:59:59 came back as 23:59:58.9986304 and its to_timestamp refused
    " the fraction - a gap of the JS runtime (a system copies exactly), not
    " of this class; abap-check section 4, backlog runtime-packed-copy-precision
    DATA lv_ts   TYPE timestamp VALUE '20240229120000'.

    DATA lo_app TYPE REF TO ltcl_app_typed.
    FIELD-SYMBOLS <temp271> LIKE LINE OF lo_app->mt_tab.
    DATA temp272 LIKE sy-tabix.
    FIELD-SYMBOLS <temp273> LIKE LINE OF lo_app->mt_tab.
    DATA temp274 LIKE sy-tabix.
    FIELD-SYMBOLS <temp275> LIKE LINE OF lo_app->mt_tab.
    DATA temp276 LIKE sy-tabix.
    DATA lo_model TYPE REF TO z2ui5_cl_ui5_srv_model.
    DATA temp277 LIKE REF TO lo_app->mt_tab.
DATA lr_attri TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.
    DATA lv_out TYPE string.
    DATA temp278 TYPE REF TO z2ui5_if_ui5_ajs.
    FIELD-SYMBOLS <temp279> LIKE LINE OF lo_app->mt_tab.
    DATA temp280 LIKE sy-tabix.
    FIELD-SYMBOLS <temp67> LIKE LINE OF lo_app->mt_tab.
    DATA temp68 LIKE sy-tabix.
    DATA temp44 TYPE xsdboolean.
    FIELD-SYMBOLS <temp281> LIKE LINE OF lo_app->mt_tab.
    DATA temp282 LIKE sy-tabix.
    FIELD-SYMBOLS <temp69> LIKE LINE OF lo_app->mt_tab.
    DATA temp70 LIKE sy-tabix.
    DATA temp45 TYPE xsdboolean.
    FIELD-SYMBOLS <temp283> LIKE LINE OF lo_app->mt_tab.
    DATA temp284 LIKE sy-tabix.
    FIELD-SYMBOLS <temp285> LIKE LINE OF lo_app->mt_tab.
    DATA temp286 LIKE sy-tabix.
    FIELD-SYMBOLS <temp287> LIKE LINE OF lo_app->mt_tab.
    DATA temp288 LIKE sy-tabix.
    FIELD-SYMBOLS <temp289> LIKE LINE OF lo_app->mt_tab.
    DATA temp290 LIKE sy-tabix.
    lo_app = typed_app( ).
    " row 1 leaves all three initial, row 2 fills them


    temp272 = sy-tabix.
    READ TABLE lo_app->mt_tab INDEX 2 ASSIGNING <temp271>.
    sy-tabix = temp272.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    <temp271>-dt = lv_date.


    temp274 = sy-tabix.
    READ TABLE lo_app->mt_tab INDEX 2 ASSIGNING <temp273>.
    sy-tabix = temp274.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    <temp273>-tm = lv_time.


    temp276 = sy-tabix.
    READ TABLE lo_app->mt_tab INDEX 2 ASSIGNING <temp275>.
    sy-tabix = temp276.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    <temp275>-ts = lv_ts.

    lo_model = typed_model( lo_app ).

    GET REFERENCE OF lo_app->mt_tab INTO temp277.

lr_attri = lo_model->main_attri_search( temp277 ).
    lr_attri->bind        = abap_true.
    lr_attri->name_client = `/MT_TAB`.

    lv_out = lo_model->main_json_stringify( ).

    " the client sends the table back whole (a row added or removed on the
    " client replaces the delta with the array)
    CLEAR lo_app->mt_tab.

    temp278 ?= z2ui5_cl_ui5_ajs=>parse( lv_out ).
    lo_model->main_json_to_attri( temp278 ).

    cl_abap_unit_assert=>assert_initial( lo_model->mt_skipped ).
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( lo_app->mt_tab ) ).


    temp280 = sy-tabix.
    READ TABLE lo_app->mt_tab INDEX 1 ASSIGNING <temp279>.
    sy-tabix = temp280.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.


    temp68 = sy-tabix.
    READ TABLE lo_app->mt_tab INDEX 1 ASSIGNING <temp67>.
    sy-tabix = temp68.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.

    temp44 = boolc( <temp279>-dt IS INITIAL ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp44
                                      msg = |an initial date came back as '{ <temp67>-dt }'| ).


    temp282 = sy-tabix.
    READ TABLE lo_app->mt_tab INDEX 1 ASSIGNING <temp281>.
    sy-tabix = temp282.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.


    temp70 = sy-tabix.
    READ TABLE lo_app->mt_tab INDEX 1 ASSIGNING <temp69>.
    sy-tabix = temp70.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.

    temp45 = boolc( <temp281>-tm IS INITIAL ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp45
                                      msg = |an initial time came back as '{ <temp69>-tm }'| ).


    temp284 = sy-tabix.
    READ TABLE lo_app->mt_tab INDEX 1 ASSIGNING <temp283>.
    sy-tabix = temp284.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_initial( <temp283>-ts ).


    temp286 = sy-tabix.
    READ TABLE lo_app->mt_tab INDEX 2 ASSIGNING <temp285>.
    sy-tabix = temp286.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = lv_date
                                        act = <temp285>-dt ).


    temp288 = sy-tabix.
    READ TABLE lo_app->mt_tab INDEX 2 ASSIGNING <temp287>.
    sy-tabix = temp288.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = lv_time
                                        act = <temp287>-tm ).


    temp290 = sy-tabix.
    READ TABLE lo_app->mt_tab INDEX 2 ASSIGNING <temp289>.
    sy-tabix = temp290.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = lv_ts
                                        act = <temp289>-ts ).
    " and the next render ships exactly what the first one did
    cl_abap_unit_assert=>assert_equals( exp = lv_out
                                        act = lo_model->main_json_stringify( ) ).

  ENDMETHOD.

  METHOD delta_null_clears.

    DATA lo_app TYPE REF TO ltcl_app_typed.
    FIELD-SYMBOLS <temp291> LIKE LINE OF lo_app->mt_tab.
    DATA temp292 LIKE sy-tabix.
    FIELD-SYMBOLS <temp293> LIKE LINE OF lo_app->mt_tab.
    DATA temp294 LIKE sy-tabix.
    FIELD-SYMBOLS <temp295> LIKE LINE OF lo_app->mt_tab.
    DATA temp296 LIKE sy-tabix.
    DATA lo_model TYPE REF TO z2ui5_cl_ui5_srv_model.
    FIELD-SYMBOLS <temp297> LIKE LINE OF lo_app->mt_tab.
    DATA temp298 LIKE sy-tabix.
    FIELD-SYMBOLS <temp299> LIKE LINE OF lo_app->mt_tab.
    DATA temp300 LIKE sy-tabix.
    FIELD-SYMBOLS <temp301> LIKE LINE OF lo_app->mt_tab.
    DATA temp302 LIKE sy-tabix.
    FIELD-SYMBOLS <temp71> LIKE LINE OF lo_app->mt_tab.
    DATA temp72 LIKE sy-tabix.
    DATA temp46 TYPE xsdboolean.
    FIELD-SYMBOLS <temp303> LIKE LINE OF lo_app->mt_tab.
    DATA temp304 LIKE sy-tabix.
    FIELD-SYMBOLS <temp73> LIKE LINE OF lo_app->mt_tab.
    DATA temp74 LIKE sy-tabix.
    DATA temp47 TYPE xsdboolean.
    FIELD-SYMBOLS <temp305> LIKE LINE OF lo_app->mt_tab.
    DATA temp306 LIKE sy-tabix.
    FIELD-SYMBOLS <temp307> LIKE LINE OF lo_app->mt_tab.
    DATA temp308 LIKE sy-tabix.
    FIELD-SYMBOLS <temp309> LIKE LINE OF lo_app->mt_tab.
    DATA temp310 LIKE sy-tabix.
    lo_app = typed_app( ).


    temp292 = sy-tabix.
    READ TABLE lo_app->mt_tab INDEX 1 ASSIGNING <temp291>.
    sy-tabix = temp292.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    <temp291>-dt = '20240115'.


    temp294 = sy-tabix.
    READ TABLE lo_app->mt_tab INDEX 1 ASSIGNING <temp293>.
    sy-tabix = temp294.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    <temp293>-tm = '123045'.


    temp296 = sy-tabix.
    READ TABLE lo_app->mt_tab INDEX 1 ASSIGNING <temp295>.
    sy-tabix = temp296.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    <temp295>-ts = '20240115123045'.

    lo_model = typed_model( lo_app ).

    lo_model->delta_apply_to_table(
        io_val_front = delta( `{"__delta":{"0":{"NAME":null,"PRICE":null,"DT":null,"TM":null,"TS":null}}}` )
        iv_name      = `MT_TAB` ).



    temp298 = sy-tabix.
    READ TABLE lo_app->mt_tab INDEX 1 ASSIGNING <temp297>.
    sy-tabix = temp298.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_initial( <temp297>-name ).


    temp300 = sy-tabix.
    READ TABLE lo_app->mt_tab INDEX 1 ASSIGNING <temp299>.
    sy-tabix = temp300.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_initial( <temp299>-price ).


    temp302 = sy-tabix.
    READ TABLE lo_app->mt_tab INDEX 1 ASSIGNING <temp301>.
    sy-tabix = temp302.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.


    temp72 = sy-tabix.
    READ TABLE lo_app->mt_tab INDEX 1 ASSIGNING <temp71>.
    sy-tabix = temp72.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.

    temp46 = boolc( <temp301>-dt IS INITIAL ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp46
                                      msg = |a null date became '{ <temp71>-dt }'| ).


    temp304 = sy-tabix.
    READ TABLE lo_app->mt_tab INDEX 1 ASSIGNING <temp303>.
    sy-tabix = temp304.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.


    temp74 = sy-tabix.
    READ TABLE lo_app->mt_tab INDEX 1 ASSIGNING <temp73>.
    sy-tabix = temp74.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.

    temp47 = boolc( <temp303>-tm IS INITIAL ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp47
                                      msg = |a null time became '{ <temp73>-tm }'| ).


    temp306 = sy-tabix.
    READ TABLE lo_app->mt_tab INDEX 1 ASSIGNING <temp305>.
    sy-tabix = temp306.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_initial( <temp305>-ts ).
    " the other row and the nested table are not part of the delta


    temp308 = sy-tabix.
    READ TABLE lo_app->mt_tab INDEX 2 ASSIGNING <temp307>.
    sy-tabix = temp308.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `Monitor`
                                        act = <temp307>-name ).


    temp310 = sy-tabix.
    READ TABLE lo_app->mt_tab INDEX 1 ASSIGNING <temp309>.
    sy-tabix = temp310.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( <temp309>-t_pos ) ).
    cl_abap_unit_assert=>assert_initial( lo_model->mt_skipped ).

  ENDMETHOD.

  METHOD delta_number_kinds.

    DATA lr_attri TYPE REF TO z2ui5_if_ui5_types=>ty_t_attri.
    DATA lo_app TYPE REF TO ltcl_app_conv.
    DATA temp311 TYPE ltcl_app_conv=>ty_t_row.
    DATA temp312 LIKE LINE OF temp311.
    DATA lo_model TYPE REF TO z2ui5_cl_ui5_srv_model.
    DATA temp313 TYPE decfloat34.
    FIELD-SYMBOLS <temp75> LIKE LINE OF lo_app->mt_row.
    DATA temp76 LIKE sy-tabix.
    DATA temp314 TYPE string.
    FIELD-SYMBOLS <temp77> LIKE LINE OF lo_app->mt_row.
    DATA temp78 LIKE sy-tabix.
    DATA lv_big TYPE p LENGTH 16 DECIMALS 0.
    FIELD-SYMBOLS <temp315> LIKE LINE OF lo_app->mt_row.
    DATA temp316 LIKE sy-tabix.
    DATA temp317 TYPE decfloat34.
    DATA temp79 TYPE decfloat34.
    FIELD-SYMBOLS <temp15> LIKE LINE OF lo_app->mt_row.
    DATA temp16 LIKE sy-tabix.
    DATA temp318 TYPE decfloat34.
    DATA temp80 TYPE decfloat34.
    FIELD-SYMBOLS <temp17> LIKE LINE OF lo_app->mt_row.
    DATA temp18 LIKE sy-tabix.
    DATA temp319 TYPE decfloat34.
    DATA temp81 TYPE decfloat34.
    FIELD-SYMBOLS <temp19> LIKE LINE OF lo_app->mt_row.
    DATA temp20 LIKE sy-tabix.
    FIELD-SYMBOLS <temp320> LIKE LINE OF lo_app->mt_row.
    DATA temp321 LIKE sy-tabix.
    FIELD-SYMBOLS <temp322> LIKE LINE OF lo_app->mt_row.
    DATA temp323 LIKE sy-tabix.
    DATA temp324 TYPE string.
    FIELD-SYMBOLS <temp82> LIKE LINE OF lo_app->mt_row.
    DATA temp83 LIKE sy-tabix.
    FIELD-SYMBOLS <temp325> LIKE LINE OF lo_model->mt_skipped.
    DATA temp326 LIKE sy-tabix.
    CREATE OBJECT lo_app TYPE ltcl_app_conv.

    CLEAR temp311.

    temp312-qty = 7.
    temp312-text = `seven`.
    INSERT temp312 INTO TABLE temp311.
    lo_app->mt_row = temp311.
    CREATE DATA lr_attri.

    CREATE OBJECT lo_model TYPE z2ui5_cl_ui5_srv_model EXPORTING attri = lr_attri app = lo_app.

    " a JSON number and a JSON string carry the same text to the cell: the
    " raw text converts, no binary float sits in between (0.1 stays 0.1)
    lo_model->delta_apply_to_table(
        io_val_front = delta( `{"__delta":{"0":{"DEC":0.1,"NUMC":"42","BIG":"9007199254740993","PRICE":-12.5}}}` )
        iv_name      = `MT_ROW` ).

    temp313 = '0.1'.


    temp76 = sy-tabix.
    READ TABLE lo_app->mt_row INDEX 1 ASSIGNING <temp75>.
    sy-tabix = temp76.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = temp313
                                        act = <temp75>-dec ).



    temp78 = sy-tabix.
    READ TABLE lo_app->mt_row INDEX 1 ASSIGNING <temp77>.
    sy-tabix = temp78.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    temp314 = <temp77>-numc.
    cl_abap_unit_assert=>assert_equals( exp = `00042`
                                        act = temp314 ).

    lv_big = 9007199254740992.
    lv_big = lv_big + 1.


    temp316 = sy-tabix.
    READ TABLE lo_app->mt_row INDEX 1 ASSIGNING <temp315>.
    sy-tabix = temp316.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = lv_big
                                        act = <temp315>-big ).

    temp317 = '-12.5'.



    temp16 = sy-tabix.
    READ TABLE lo_app->mt_row INDEX 1 ASSIGNING <temp15>.
    sy-tabix = temp16.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    temp79 = <temp15>-price.
    cl_abap_unit_assert=>assert_equals( exp = temp317
                                        act = temp79 ).
    cl_abap_unit_assert=>assert_initial( lo_model->mt_skipped ).

    " more decimals than the packed cell has: rounded half away from zero,
    " as the text-to-packed conversion does it - not cut off, not refused
    lo_model->delta_apply_to_table(
        io_val_front = delta( `{"__delta":{"0":{"PRICE":"1.235"}}}` )
        iv_name      = `MT_ROW` ).

    temp318 = '1.24'.



    temp18 = sy-tabix.
    READ TABLE lo_app->mt_row INDEX 1 ASSIGNING <temp17>.
    sy-tabix = temp18.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    temp80 = <temp17>-price.
    cl_abap_unit_assert=>assert_equals( exp = temp318
                                        act = temp80 ).
    lo_model->delta_apply_to_table(
        io_val_front = delta( `{"__delta":{"0":{"PRICE":"-1.235"}}}` )
        iv_name      = `MT_ROW` ).

    temp319 = '-1.24'.



    temp20 = sy-tabix.
    READ TABLE lo_app->mt_row INDEX 1 ASSIGNING <temp19>.
    sy-tabix = temp20.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    temp81 = <temp19>-price.
    cl_abap_unit_assert=>assert_equals( exp = temp319
                                        act = temp81 ).
    cl_abap_unit_assert=>assert_initial( lo_model->mt_skipped ).

    " a boolean into a number column is a refusal, traced, the old value
    " kept; into a boolean column it is the flag; into a text column the
    " text of the flag
    lo_model->delta_apply_to_table(
        io_val_front = delta( `{"__delta":{"0":{"QTY":true,"FLAG":true,"TEXT":true}}}` )
        iv_name      = `MT_ROW` ).


    temp321 = sy-tabix.
    READ TABLE lo_app->mt_row INDEX 1 ASSIGNING <temp320>.
    sy-tabix = temp321.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = 7
                                        act = <temp320>-qty ).


    temp323 = sy-tabix.
    READ TABLE lo_app->mt_row INDEX 1 ASSIGNING <temp322>.
    sy-tabix = temp323.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = <temp322>-flag ).

    temp324 = abap_true.


    temp83 = sy-tabix.
    READ TABLE lo_app->mt_row INDEX 1 ASSIGNING <temp82>.
    sy-tabix = temp83.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = temp324
                                        act = <temp82>-text ).
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( lo_model->mt_skipped ) ).


    temp326 = sy-tabix.
    READ TABLE lo_model->mt_skipped INDEX 1 ASSIGNING <temp325>.
    sy-tabix = temp326.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `QTY`
                                        act = <temp325>-field ).

  ENDMETHOD.

  METHOD delta_three_levels.

    DATA lr_attri TYPE REF TO z2ui5_if_ui5_types=>ty_t_attri.
    DATA lo_app TYPE REF TO ltcl_app_deep3.
    DATA temp327 TYPE ltcl_app_deep3=>ty_t_top.
    DATA temp328 LIKE LINE OF temp327.
    DATA temp84 TYPE ltcl_app_deep3=>ty_t_mid.
    DATA temp85 LIKE LINE OF temp84.
    DATA temp21 TYPE ltcl_app_deep3=>ty_t_leaf.
    DATA temp22 LIKE LINE OF temp21.
    DATA temp23 TYPE ltcl_app_deep3=>ty_t_leaf.
    DATA temp24 LIKE LINE OF temp23.
    DATA lo_model TYPE REF TO z2ui5_cl_ui5_srv_model.
    FIELD-SYMBOLS <temp329> LIKE LINE OF lo_app->mt_top.
    DATA temp330 LIKE sy-tabix.
    FIELD-SYMBOLS <temp86> LIKE LINE OF <temp329>-t_mid.
    DATA temp87 LIKE sy-tabix.
    FIELD-SYMBOLS <temp25> LIKE LINE OF <temp86>-t_leaf.
    DATA temp26 LIKE sy-tabix.
    FIELD-SYMBOLS <temp331> LIKE LINE OF lo_app->mt_top.
    DATA temp332 LIKE sy-tabix.
    FIELD-SYMBOLS <temp88> LIKE LINE OF <temp331>-t_mid.
    DATA temp89 LIKE sy-tabix.
    FIELD-SYMBOLS <temp27> LIKE LINE OF <temp88>-t_leaf.
    DATA temp28 LIKE sy-tabix.
    FIELD-SYMBOLS <temp333> LIKE LINE OF lo_app->mt_top.
    DATA temp334 LIKE sy-tabix.
    FIELD-SYMBOLS <temp90> LIKE LINE OF <temp333>-t_mid.
    DATA temp91 LIKE sy-tabix.
    FIELD-SYMBOLS <temp29> LIKE LINE OF <temp90>-t_leaf.
    DATA temp30 LIKE sy-tabix.
    FIELD-SYMBOLS <temp335> LIKE LINE OF lo_app->mt_top.
    DATA temp336 LIKE sy-tabix.
    FIELD-SYMBOLS <temp92> LIKE LINE OF <temp335>-t_mid.
    DATA temp93 LIKE sy-tabix.
    FIELD-SYMBOLS <temp31> LIKE LINE OF <temp92>-t_leaf.
    DATA temp32 LIKE sy-tabix.
    FIELD-SYMBOLS <temp337> LIKE LINE OF lo_app->mt_top.
    DATA temp338 LIKE sy-tabix.
    FIELD-SYMBOLS <temp94> LIKE LINE OF <temp337>-t_mid.
    DATA temp95 LIKE sy-tabix.
    DATA ls_skip TYPE z2ui5_if_client=>ty_s_model_skip.
    FIELD-SYMBOLS <temp96> LIKE LINE OF lo_model->mt_skipped.
    DATA temp97 LIKE sy-tabix.
    CREATE OBJECT lo_app TYPE ltcl_app_deep3.

    CLEAR temp327.

    temp328-id = `T1`.

    CLEAR temp84.

    temp85-name = `M1`.

    CLEAR temp21.

    temp22-qty = 1.
    temp22-txt = `L1`.
    INSERT temp22 INTO TABLE temp21.
    temp85-t_leaf = temp21.
    INSERT temp85 INTO TABLE temp84.
    temp85-name = `M2`.

    CLEAR temp23.

    temp24-qty = 2.
    temp24-txt = `L2`.
    INSERT temp24 INTO TABLE temp23.
    temp24-qty = 3.
    temp24-txt = `L3`.
    INSERT temp24 INTO TABLE temp23.
    temp85-t_leaf = temp23.
    INSERT temp85 INTO TABLE temp84.
    temp328-t_mid = temp84.
    INSERT temp328 INTO TABLE temp327.
    lo_app->mt_top = temp327.
    CREATE DATA lr_attri.

    CREATE OBJECT lo_model TYPE z2ui5_cl_ui5_srv_model EXPORTING attri = lr_attri app = lo_app.

    " row 1 / mid row 2 / leaf row 2: one cell lands, one is refused
    lo_model->delta_apply_to_table(
        io_val_front = delta( `{"__delta":{"0":{"T_MID":{"__delta":{"1":{"T_LEAF":{"__delta":{"1":{"TXT":"edited","QTY":"lots"}}}}}}}}}` )
        iv_name      = `MT_TOP` ).



    temp330 = sy-tabix.
    READ TABLE lo_app->mt_top INDEX 1 ASSIGNING <temp329>.
    sy-tabix = temp330.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.


    temp87 = sy-tabix.
    READ TABLE <temp329>-t_mid INDEX 2 ASSIGNING <temp86>.
    sy-tabix = temp87.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.


    temp26 = sy-tabix.
    READ TABLE <temp86>-t_leaf INDEX 2 ASSIGNING <temp25>.
    sy-tabix = temp26.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `edited`
                                        act = <temp25>-txt ).


    temp332 = sy-tabix.
    READ TABLE lo_app->mt_top INDEX 1 ASSIGNING <temp331>.
    sy-tabix = temp332.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.


    temp89 = sy-tabix.
    READ TABLE <temp331>-t_mid INDEX 2 ASSIGNING <temp88>.
    sy-tabix = temp89.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.


    temp28 = sy-tabix.
    READ TABLE <temp88>-t_leaf INDEX 2 ASSIGNING <temp27>.
    sy-tabix = temp28.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = 3
                                        act = <temp27>-qty ).
    " nothing else moved


    temp334 = sy-tabix.
    READ TABLE lo_app->mt_top INDEX 1 ASSIGNING <temp333>.
    sy-tabix = temp334.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.


    temp91 = sy-tabix.
    READ TABLE <temp333>-t_mid INDEX 2 ASSIGNING <temp90>.
    sy-tabix = temp91.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.


    temp30 = sy-tabix.
    READ TABLE <temp90>-t_leaf INDEX 1 ASSIGNING <temp29>.
    sy-tabix = temp30.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `L2`
                                        act = <temp29>-txt ).


    temp336 = sy-tabix.
    READ TABLE lo_app->mt_top INDEX 1 ASSIGNING <temp335>.
    sy-tabix = temp336.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.


    temp93 = sy-tabix.
    READ TABLE <temp335>-t_mid INDEX 1 ASSIGNING <temp92>.
    sy-tabix = temp93.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.


    temp32 = sy-tabix.
    READ TABLE <temp92>-t_leaf INDEX 1 ASSIGNING <temp31>.
    sy-tabix = temp32.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `L1`
                                        act = <temp31>-txt ).


    temp338 = sy-tabix.
    READ TABLE lo_app->mt_top INDEX 1 ASSIGNING <temp337>.
    sy-tabix = temp338.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.


    temp95 = sy-tabix.
    READ TABLE <temp337>-t_mid INDEX 2 ASSIGNING <temp94>.
    sy-tabix = temp95.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( <temp94>-t_leaf ) ).

    " the trace names the innermost table by its full path, its row, and
    " the row of the table it sits in (the immediate parent, not the top)
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( lo_model->mt_skipped ) ).



    temp97 = sy-tabix.
    READ TABLE lo_model->mt_skipped INDEX 1 ASSIGNING <temp96>.
    sy-tabix = temp97.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    ls_skip = <temp96>.
    cl_abap_unit_assert=>assert_equals( exp = `MT_TOP-T_MID-T_LEAF`
                                        act = ls_skip-name ).
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = ls_skip-row ).
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = ls_skip-row_parent ).
    cl_abap_unit_assert=>assert_equals( exp = `QTY`
                                        act = ls_skip-field ).
    cl_abap_unit_assert=>assert_equals( exp = `lots`
                                        act = ls_skip-value ).

  ENDMETHOD.

  METHOD whole_rows_replaced.

    DATA lo_app TYPE REF TO ltcl_app_typed.
    DATA lo_model TYPE REF TO z2ui5_cl_ui5_srv_model.
    DATA temp339 LIKE REF TO lo_app->mt_tab.
DATA lr_attri TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.
    FIELD-SYMBOLS <temp340> LIKE LINE OF lo_app->mt_tab.
    DATA temp341 LIKE sy-tabix.
    FIELD-SYMBOLS <temp342> LIKE LINE OF lo_app->mt_tab.
    DATA temp343 LIKE sy-tabix.
    FIELD-SYMBOLS <temp98> LIKE LINE OF <temp342>-t_pos.
    DATA temp99 LIKE sy-tabix.
    FIELD-SYMBOLS <temp344> LIKE LINE OF lo_app->mt_tab.
    DATA temp345 LIKE sy-tabix.
    FIELD-SYMBOLS <temp346> LIKE LINE OF lo_app->mt_tab.
    DATA temp347 LIKE sy-tabix.
    FIELD-SYMBOLS <temp348> LIKE LINE OF lo_app->mt_tab.
    DATA temp349 LIKE sy-tabix.
    FIELD-SYMBOLS <temp350> LIKE LINE OF lo_app->mt_tab.
    DATA temp351 LIKE sy-tabix.
    lo_app = typed_app( ).

    lo_model = typed_model( lo_app ).

    GET REFERENCE OF lo_app->mt_tab INTO temp339.

lr_attri = lo_model->main_attri_search( temp339 ).
    lr_attri->bind        = abap_true.
    lr_attri->name_client = `/MT_TAB`.

    " the client removed the first row: the array is the table now
    lo_model->main_json_to_attri( delta( `{"MT_TAB":[{"NAME":"Monitor","PRICE":"299.00","T_POS":[{"QTY":2}]}]}` ) ).
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( lo_app->mt_tab ) ).


    temp341 = sy-tabix.
    READ TABLE lo_app->mt_tab INDEX 1 ASSIGNING <temp340>.
    sy-tabix = temp341.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `Monitor`
                                        act = <temp340>-name ).


    temp343 = sy-tabix.
    READ TABLE lo_app->mt_tab INDEX 1 ASSIGNING <temp342>.
    sy-tabix = temp343.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.


    temp99 = sy-tabix.
    READ TABLE <temp342>-t_pos INDEX 1 ASSIGNING <temp98>.
    sy-tabix = temp99.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = <temp98>-qty ).

    " the client added two rows, one with a nested table of its own
    lo_model->main_json_to_attri( delta( `{"MT_TAB":[{"NAME":"Monitor"},{"NAME":"Mouse","T_POS":[{"QTY":4},{"QTY":5}]},{"NAME":"Pad"}]}` ) ).
    cl_abap_unit_assert=>assert_equals( exp = 3
                                        act = lines( lo_app->mt_tab ) ).


    temp345 = sy-tabix.
    READ TABLE lo_app->mt_tab INDEX 2 ASSIGNING <temp344>.
    sy-tabix = temp345.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( <temp344>-t_pos ) ).


    temp347 = sy-tabix.
    READ TABLE lo_app->mt_tab INDEX 3 ASSIGNING <temp346>.
    sy-tabix = temp347.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `Pad`
                                        act = <temp346>-name ).
    " a whole value is the whole row: what the array leaves out is initial


    temp349 = sy-tabix.
    READ TABLE lo_app->mt_tab INDEX 1 ASSIGNING <temp348>.
    sy-tabix = temp349.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_initial( <temp348>-price ).


    temp351 = sy-tabix.
    READ TABLE lo_app->mt_tab INDEX 1 ASSIGNING <temp350>.
    sy-tabix = temp351.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_initial( <temp350>-t_pos ).
    cl_abap_unit_assert=>assert_initial( lo_model->mt_skipped ).

    " and the empty array empties it
    lo_model->main_json_to_attri( delta( `{"MT_TAB":[]}` ) ).
    cl_abap_unit_assert=>assert_initial( lo_app->mt_tab ).
    cl_abap_unit_assert=>assert_initial( lo_model->mt_skipped ).

  ENDMETHOD.

  METHOD date_time_text_refused.

    DATA lv_date TYPE d VALUE '20240115'.
    DATA lv_time TYPE t VALUE '123045'.

    DATA lo_app TYPE REF TO ltcl_app_typed.
    FIELD-SYMBOLS <temp352> LIKE LINE OF lo_app->mt_tab.
    DATA temp353 LIKE sy-tabix.
    FIELD-SYMBOLS <temp354> LIKE LINE OF lo_app->mt_tab.
    DATA temp355 LIKE sy-tabix.
    FIELD-SYMBOLS <temp356> LIKE LINE OF lo_app->mt_tab.
    DATA temp357 LIKE sy-tabix.
    DATA lo_model TYPE REF TO z2ui5_cl_ui5_srv_model.
    FIELD-SYMBOLS <temp358> LIKE LINE OF lo_app->mt_tab.
    DATA temp359 LIKE sy-tabix.
    FIELD-SYMBOLS <temp360> LIKE LINE OF lo_app->mt_tab.
    DATA temp361 LIKE sy-tabix.
    FIELD-SYMBOLS <temp362> LIKE LINE OF lo_app->mt_tab.
    DATA temp363 LIKE sy-tabix.
    FIELD-SYMBOLS <temp364> LIKE LINE OF lo_app->mt_tab.
    DATA temp365 LIKE sy-tabix.
    DATA temp48 TYPE xsdboolean.
    DATA temp14 LIKE sy-subrc.
    DATA temp15 LIKE sy-subrc.
    DATA temp16 LIKE sy-tabix.
    DATA temp49 TYPE xsdboolean.
    DATA temp17 LIKE sy-subrc.
    DATA temp18 LIKE sy-subrc.
    DATA temp19 LIKE sy-tabix.
    DATA temp366 TYPE string.
    FIELD-SYMBOLS <temp100> LIKE LINE OF lo_app->mt_tab.
    DATA temp101 LIKE sy-tabix.
    DATA temp367 TYPE string.
    FIELD-SYMBOLS <temp102> LIKE LINE OF lo_app->mt_tab.
    DATA temp103 LIKE sy-tabix.
    DATA temp368 LIKE REF TO mo_app->mv_date.
    FIELD-SYMBOLS <temp369> LIKE LINE OF mo_model->mt_skipped.
    DATA temp370 LIKE sy-tabix.
    lo_app = typed_app( ).


    temp353 = sy-tabix.
    READ TABLE lo_app->mt_tab INDEX 1 ASSIGNING <temp352>.
    sy-tabix = temp353.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    <temp352>-dt = lv_date.


    temp355 = sy-tabix.
    READ TABLE lo_app->mt_tab INDEX 1 ASSIGNING <temp354>.
    sy-tabix = temp355.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    <temp354>-tm = lv_time.


    temp357 = sy-tabix.
    READ TABLE lo_app->mt_tab INDEX 2 ASSIGNING <temp356>.
    sy-tabix = temp357.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    <temp356>-dt = lv_date.

    lo_model = typed_model( lo_app ).

    " what a DatePicker / TimePicker without valueFormat writes: its display
    " format. Assigned as text, `15.01.2024` became the date `15.01.20`
    lo_model->delta_apply_to_table(
        io_val_front = delta( `{"__delta":{"0":{"DT":"15.01.2024","TM":"12.30"},"1":{"DT":"Jan 15, 2024","NAME":"kept"}}}` )
        iv_name      = `MT_TAB` ).



    temp359 = sy-tabix.
    READ TABLE lo_app->mt_tab INDEX 1 ASSIGNING <temp358>.
    sy-tabix = temp359.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = lv_date
                                        act = <temp358>-dt ).


    temp361 = sy-tabix.
    READ TABLE lo_app->mt_tab INDEX 1 ASSIGNING <temp360>.
    sy-tabix = temp361.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = lv_time
                                        act = <temp360>-tm ).


    temp363 = sy-tabix.
    READ TABLE lo_app->mt_tab INDEX 2 ASSIGNING <temp362>.
    sy-tabix = temp363.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = lv_date
                                        act = <temp362>-dt ).
    " the good cell of the same row still lands


    temp365 = sy-tabix.
    READ TABLE lo_app->mt_tab INDEX 2 ASSIGNING <temp364>.
    sy-tabix = temp365.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `kept`
                                        act = <temp364>-name ).
    cl_abap_unit_assert=>assert_equals( exp = 3
                                        act = lines( lo_model->mt_skipped ) ).




    temp15 = sy-subrc.
    temp16 = sy-tabix.
    READ TABLE lo_model->mt_skipped WITH KEY row = 1 field = `DT` value = `15.01.2024` TRANSPORTING NO FIELDS.
    temp14 = sy-subrc.
    sy-subrc = temp15.
    sy-tabix = temp16.
    temp48 = boolc( temp14 = 0 ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp48 ). "#EC CI_SORTSEQ




    temp18 = sy-subrc.
    temp19 = sy-tabix.
    READ TABLE lo_model->mt_skipped WITH KEY row = 1 field = `TM` value = `12.30` TRANSPORTING NO FIELDS.
    temp17 = sy-subrc.
    sy-subrc = temp18.
    sy-tabix = temp19.
    temp49 = boolc( temp17 = 0 ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp49 ). "#EC CI_SORTSEQ

    " the two spellings that ARE read keep working: ISO and plain digits
    CLEAR lo_model->mt_skipped.
    lo_model->delta_apply_to_table(
        io_val_front = delta( `{"__delta":{"0":{"DT":"2024-02-29","TM":"235959"}}}` )
        iv_name      = `MT_TAB` ).



    temp101 = sy-tabix.
    READ TABLE lo_app->mt_tab INDEX 1 ASSIGNING <temp100>.
    sy-tabix = temp101.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    temp366 = <temp100>-dt.
    cl_abap_unit_assert=>assert_equals( exp = `20240229`
                                        act = temp366 ).



    temp103 = sy-tabix.
    READ TABLE lo_app->mt_tab INDEX 1 ASSIGNING <temp102>.
    sy-tabix = temp103.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    temp367 = <temp102>-tm.
    cl_abap_unit_assert=>assert_equals( exp = `235959`
                                        act = temp367 ).
    cl_abap_unit_assert=>assert_initial( lo_model->mt_skipped ).

    " the same rule for a bound scalar - the whole-value path shares it
    mo_app->mv_date = lv_date.

    GET REFERENCE OF mo_app->mv_date INTO temp368.
bind( temp368 ).
    mo_model->main_json_to_attri( delta( `{"MV_DATE":"15.01.2024"}` ) ).
    cl_abap_unit_assert=>assert_equals( exp = lv_date
                                        act = mo_app->mv_date ).
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( mo_model->mt_skipped ) ).


    temp370 = sy-tabix.
    READ TABLE mo_model->mt_skipped INDEX 1 ASSIGNING <temp369>.
    sy-tabix = temp370.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `MV_DATE`
                                        act = <temp369>-name ).

  ENDMETHOD.

  METHOD delta_on_structure.

    DATA lr_attri TYPE REF TO z2ui5_if_ui5_types=>ty_t_attri.
    DATA lo_app TYPE REF TO ltcl_app_deep3.
    DATA lo_model TYPE REF TO z2ui5_cl_ui5_srv_model.
    FIELD-SYMBOLS <temp371> LIKE LINE OF lo_model->mt_skipped.
    DATA temp372 LIKE sy-tabix.
    FIELD-SYMBOLS <temp373> LIKE LINE OF lo_model->mt_skipped.
    DATA temp374 LIKE sy-tabix.
    CREATE OBJECT lo_app TYPE ltcl_app_deep3.
    CLEAR lo_app->ms_head.
    lo_app->ms_head-qty = 1.
    lo_app->ms_head-txt = `head`.
    CREATE DATA lr_attri.

    CREATE OBJECT lo_model TYPE z2ui5_cl_ui5_srv_model EXPORTING attri = lr_attri app = lo_app.

    lo_model->delta_apply_to_table( io_val_front = delta( `{"__delta":{"0":{"TXT":"edited"}}}` )
                                    iv_name      = `MS_HEAD` ).

    cl_abap_unit_assert=>assert_equals( exp = `head`
                                        act = lo_app->ms_head-txt ).
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( lo_model->mt_skipped ) ).


    temp372 = sy-tabix.
    READ TABLE lo_model->mt_skipped INDEX 1 ASSIGNING <temp371>.
    sy-tabix = temp372.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `MS_HEAD`
                                        act = <temp371>-name ).


    temp374 = sy-tabix.
    READ TABLE lo_model->mt_skipped INDEX 1 ASSIGNING <temp373>.
    sy-tabix = temp374.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `edited`
                                        act = <temp373>-value ).

  ENDMETHOD.

  METHOD special_chars_round_trip.

    " non-ASCII built at run time - the source stays 7-bit: a-umlaut, the
    " euro sign and an emoji outside the BMP (a surrogate pair in JSON)
    DATA lv_unicode TYPE string.
    DATA lv_text TYPE string.
    DATA lo_app TYPE REF TO ltcl_app_typed.
    FIELD-SYMBOLS <temp375> LIKE LINE OF lo_app->mt_tab.
    DATA temp376 LIKE sy-tabix.
    DATA lo_model TYPE REF TO z2ui5_cl_ui5_srv_model.
    DATA temp377 LIKE REF TO lo_app->mt_tab.
DATA lr_attri TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.
    DATA lv_out TYPE string.
    DATA temp378 TYPE REF TO z2ui5_if_ui5_ajs.
    FIELD-SYMBOLS <temp379> LIKE LINE OF lo_app->mt_tab.
    DATA temp380 LIKE sy-tabix.
    DATA lv_exp TYPE string.
    FIELD-SYMBOLS <temp381> LIKE LINE OF lo_app->mt_tab.
    DATA temp382 LIKE sy-tabix.
    lv_unicode = z2ui5_cl_ui5_util_context=>conv_get_string_by_xstring( `C3A4E282ACF09F9880` ).

    lv_text = `"double" 'single' \\ back\slash / slash { brace } </script>`
                 && z2ui5_cl_ui5_util_context=>cv_char_util_horizontal_tab
                 && z2ui5_cl_ui5_util_context=>cv_char_util_cr_lf
                 && lv_unicode
                 && ` trailing backslash \`.


    lo_app = typed_app( ).


    temp376 = sy-tabix.
    READ TABLE lo_app->mt_tab INDEX 1 ASSIGNING <temp375>.
    sy-tabix = temp376.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    <temp375>-name = lv_text.

    lo_model = typed_model( lo_app ).

    GET REFERENCE OF lo_app->mt_tab INTO temp377.

lr_attri = lo_model->main_attri_search( temp377 ).
    lr_attri->bind        = abap_true.
    lr_attri->name_client = `/MT_TAB`.

    lv_out = lo_model->main_json_stringify( ).

    " whole: out and in again, unchanged
    CLEAR lo_app->mt_tab.

    temp378 ?= z2ui5_cl_ui5_ajs=>parse( lv_out ).
    lo_model->main_json_to_attri( temp378 ).


    temp380 = sy-tabix.
    READ TABLE lo_app->mt_tab INDEX 1 ASSIGNING <temp379>.
    sy-tabix = temp380.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = lv_text
                                        act = <temp379>-name ).

    " a row delta carries the same characters in the JSON escapes a browser
    " writes - \" \\ \/ \t \r\n, and \u00e4 for the a-umlaut
    lo_model->main_json_to_attri( delta( `{"MT_TAB":{"__delta":{"1":{"NAME":"q\"b\\s\/t\tn\r\nu\u00e4"}}}}` ) ).

    lv_exp = `q"b\s/t` && z2ui5_cl_ui5_util_context=>cv_char_util_horizontal_tab
                && `n` && z2ui5_cl_ui5_util_context=>cv_char_util_cr_lf
                && `u` && z2ui5_cl_ui5_util_context=>conv_get_string_by_xstring( `C3A4` ).


    temp382 = sy-tabix.
    READ TABLE lo_app->mt_tab INDEX 2 ASSIGNING <temp381>.
    sy-tabix = temp382.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = lv_exp
                                        act = <temp381>-name ).
    cl_abap_unit_assert=>assert_initial( lo_model->mt_skipped ).

  ENDMETHOD.

  METHOD edge_model.

    DATA lr_attri TYPE REF TO z2ui5_if_ui5_types=>ty_t_attri.
    CREATE DATA lr_attri.
    CREATE OBJECT result EXPORTING attri = lr_attri app = io_app.

  ENDMETHOD.

  METHOD edge_bind.

    DATA lr_attri TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.
    lr_attri = io_model->main_attri_search( ir_val ).
    lr_attri->bind        = abap_true.
    lr_attri->name_client = iv_name.

  ENDMETHOD.

  METHOD wide_fill.

    cs_wide-name       = `a`.
    cs_wide-changed_at = '20240115123045.1234567'.
    cs_wide-big        = '1234567890.123456789'.
    cs_wide-price      = '12.50'.
    " a float with every digit a double has: it IS one, and stays a number
    cs_wide-ratio      = 1 / 3.

  ENDMETHOD.

  METHOD whole_value_dates.

    DATA lo_app TYPE REF TO ltcl_app_edge.
    DATA temp383 TYPE ltcl_app_edge=>ty_t_line.
    DATA temp384 LIKE LINE OF temp383.
    DATA temp385 TYPE ltcl_app_edge=>ty_t_form.
    DATA temp386 LIKE LINE OF temp385.
    DATA lo_model TYPE REF TO z2ui5_cl_ui5_srv_model.
    DATA temp387 LIKE REF TO lo_app->ms_form.
    DATA temp388 LIKE REF TO lo_app->mt_line.
    DATA temp389 LIKE REF TO lo_app->mt_form.
    DATA temp390 TYPE string.
    DATA temp391 TYPE string.
    DATA temp392 TYPE string.
    FIELD-SYMBOLS <temp393> LIKE LINE OF lo_app->mt_line.
    DATA temp394 LIKE sy-tabix.
    DATA temp395 TYPE string.
    FIELD-SYMBOLS <temp104> LIKE LINE OF lo_app->mt_line.
    DATA temp105 LIKE sy-tabix.
    FIELD-SYMBOLS <temp396> LIKE LINE OF lo_app->mt_line.
    DATA temp397 LIKE sy-tabix.
    FIELD-SYMBOLS <temp398> LIKE LINE OF lo_app->mt_form.
    DATA temp399 LIKE sy-tabix.
    DATA temp400 TYPE string.
    FIELD-SYMBOLS <temp106> LIKE LINE OF lo_app->mt_form.
    DATA temp107 LIKE sy-tabix.
    FIELD-SYMBOLS <temp401> LIKE LINE OF lo_app->mt_form.
    DATA temp402 LIKE sy-tabix.
    CREATE OBJECT lo_app TYPE ltcl_app_edge.
    CLEAR lo_app->ms_form.
    lo_app->ms_form-name = `a`.
    lo_app->ms_form-dt = '20240115'.
    lo_app->ms_form-tm = '123000'.

    CLEAR temp383.

    temp384-id = 1.
    CLEAR temp384-s_form.
    temp384-s_form-name = `l1`.
    temp384-s_form-dt = '20240115'.
    temp384-s_form-tm = '123000'.
    INSERT temp384 INTO TABLE temp383.
    lo_app->mt_line = temp383.

    CLEAR temp385.

    temp386-name = `r1`.
    temp386-dt = '20240115'.
    INSERT temp386 INTO TABLE temp385.
    lo_app->mt_form = temp385.

    lo_model = edge_model( lo_app ).

    GET REFERENCE OF lo_app->ms_form INTO temp387.
edge_bind( io_model = lo_model
               ir_val   = temp387
               iv_name  = `/MS_FORM` ).

    GET REFERENCE OF lo_app->mt_line INTO temp388.
edge_bind( io_model = lo_model
               ir_val   = temp388
               iv_name  = `/MT_LINE` ).

    GET REFERENCE OF lo_app->mt_form INTO temp389.
edge_bind( io_model = lo_model
               ir_val   = temp389
               iv_name  = `/MT_FORM` ).

    " an emptied date and time are initial: ajson ships an initial one as
    " "", and assigned as it came that was a date of blanks on a system
    lo_model->main_json_to_attri( delta( `{"MS_FORM":{"NAME":"b","DT":"","TM":""}}` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `b`
                                        act = lo_app->ms_form-name ).
    cl_abap_unit_assert=>assert_initial( lo_app->ms_form-dt ).
    cl_abap_unit_assert=>assert_initial( lo_app->ms_form-tm ).
    cl_abap_unit_assert=>assert_initial( lo_model->mt_skipped ).

    " the blanks such a date went out as come back initial - they used to
    " refuse the structure, and every later edit of it with them
    lo_model->main_json_to_attri( delta( `{"MS_FORM":{"NAME":"c","DT":"    -  -  ","TM":"  :  :  "}}` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `c`
                                        act = lo_app->ms_form-name ).
    cl_abap_unit_assert=>assert_initial( lo_app->ms_form-dt ).
    cl_abap_unit_assert=>assert_initial( lo_app->ms_form-tm ).
    cl_abap_unit_assert=>assert_initial( lo_model->mt_skipped ).

    " plain digits (valueFormat yyyyMMdd / HHmmss) read like the ISO form,
    " as a cell reads them
    lo_model->main_json_to_attri( delta( `{"MS_FORM":{"NAME":"d","DT":"20240301","TM":"123000"}}` ) ).

    temp390 = lo_app->ms_form-dt.
    cl_abap_unit_assert=>assert_equals( exp = `20240301`
                                        act = temp390 ).

    temp391 = lo_app->ms_form-tm.
    cl_abap_unit_assert=>assert_equals( exp = `123000`
                                        act = temp391 ).
    cl_abap_unit_assert=>assert_initial( lo_model->mt_skipped ).

    " a date that is none still refuses the value - traced, the old one kept
    lo_model->main_json_to_attri( delta( `{"MS_FORM":{"NAME":"e","DT":"Jan 15, 2024"}}` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `d`
                                        act = lo_app->ms_form-name ).

    temp392 = lo_app->ms_form-dt.
    cl_abap_unit_assert=>assert_equals( exp = `20240301`
                                        act = temp392 ).
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( lo_model->mt_skipped ) ).
    CLEAR lo_model->mt_skipped.

    " the same for a structure cell of a row ...
    lo_model->main_json_to_attri(
        delta( `{"MT_LINE":{"__delta":{"0":{"S_FORM":{"NAME":"l2","DT":"20240302","TM":""}}}}}` ) ).


    temp394 = sy-tabix.
    READ TABLE lo_app->mt_line INDEX 1 ASSIGNING <temp393>.
    sy-tabix = temp394.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `l2`
                                        act = <temp393>-s_form-name ).



    temp105 = sy-tabix.
    READ TABLE lo_app->mt_line INDEX 1 ASSIGNING <temp104>.
    sy-tabix = temp105.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    temp395 = <temp104>-s_form-dt.
    cl_abap_unit_assert=>assert_equals( exp = `20240302`
                                        act = temp395 ).


    temp397 = sy-tabix.
    READ TABLE lo_app->mt_line INDEX 1 ASSIGNING <temp396>.
    sy-tabix = temp397.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_initial( <temp396>-s_form-tm ).
    cl_abap_unit_assert=>assert_initial( lo_model->mt_skipped ).

    " ... and for a whole table
    lo_model->main_json_to_attri(
        delta( `{"MT_FORM":[{"NAME":"r1","DT":""},{"NAME":"r2","DT":"20240102","TM":"  :  :  "}]}` ) ).
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( lo_app->mt_form ) ).


    temp399 = sy-tabix.
    READ TABLE lo_app->mt_form INDEX 1 ASSIGNING <temp398>.
    sy-tabix = temp399.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_initial( <temp398>-dt ).



    temp107 = sy-tabix.
    READ TABLE lo_app->mt_form INDEX 2 ASSIGNING <temp106>.
    sy-tabix = temp107.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    temp400 = <temp106>-dt.
    cl_abap_unit_assert=>assert_equals( exp = `20240102`
                                        act = temp400 ).


    temp402 = sy-tabix.
    READ TABLE lo_app->mt_form INDEX 2 ASSIGNING <temp401>.
    sy-tabix = temp402.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_initial( <temp401>-tm ).
    cl_abap_unit_assert=>assert_initial( lo_model->mt_skipped ).

  ENDMETHOD.

  METHOD whole_value_refs_kept.

    FIELD-SYMBOLS <inner> TYPE any.
    DATA lr_inner TYPE REF TO string.
    DATA lo_app TYPE REF TO ltcl_app_edge.
    DATA lo_model TYPE REF TO z2ui5_cl_ui5_srv_model.
    DATA temp403 LIKE REF TO lo_app->ms_withref.
    DATA temp50 TYPE xsdboolean.

    " CREATE DATA, not NEW: the downport turns a NEW of data into a CREATE
    " OBJECT (abap-check, section 4)
    CREATE DATA lr_inner.
    lr_inner->* = `inner`.

    CREATE OBJECT lo_app TYPE ltcl_app_edge.
    lo_app->ms_withref-name = `x`.
    lo_app->ms_withref-r = lr_inner.

    lo_model = edge_model( lo_app ).

    GET REFERENCE OF lo_app->ms_withref INTO temp403.
edge_bind( io_model = lo_model
               ir_val   = temp403
               iv_name  = `/MS_WITHREF` ).

    " what the client sends back when NAME is edited: the whole structure,
    " the data reference as ajson wrote it - its target's value, under a
    " lower-case name - and the object reference as null
    lo_model->main_json_to_attri( delta( `{"MS_WITHREF":{"NAME":"edited","r":"typed","O":null}}` ) ).
    cl_abap_unit_assert=>assert_initial( lo_model->mt_skipped ).
    cl_abap_unit_assert=>assert_equals( exp = `edited`
                                        act = lo_app->ms_withref-name ).
    cl_abap_unit_assert=>assert_bound( lo_app->ms_withref-r ).
    ASSIGN lo_app->ms_withref-r->* TO <inner>.
    cl_abap_unit_assert=>assert_equals( exp = `inner`
                                        act = <inner> ).
    cl_abap_unit_assert=>assert_not_bound( lo_app->ms_withref-o ).

    " a bound object reference stays what it was as well
    lo_app->ms_withref-o = lo_app.
    lo_model->main_json_to_attri( delta( `{"MS_WITHREF":{"NAME":"again","O":null}}` ) ).
    cl_abap_unit_assert=>assert_initial( lo_model->mt_skipped ).
    cl_abap_unit_assert=>assert_equals( exp = `again`
                                        act = lo_app->ms_withref-name ).

    temp50 = boolc( lo_app->ms_withref-o = lo_app ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp50 ).
    cl_abap_unit_assert=>assert_bound( lo_app->ms_withref-r ).

  ENDMETHOD.

  METHOD delta_ref_rows.

    DATA lr_row  TYPE REF TO ltcl_app_edge=>ty_s_row.
    DATA lr_none TYPE REF TO ltcl_app_edge=>ty_s_row.
    DATA lo_app TYPE REF TO ltcl_app_edge.
    DATA lo_model TYPE REF TO z2ui5_cl_ui5_srv_model.
    DATA temp404 LIKE REF TO lo_app->mt_refs.
    DATA temp51 TYPE xsdboolean.
    DATA temp20 LIKE sy-subrc.
    DATA temp52 TYPE xsdboolean.
    DATA temp21 LIKE sy-subrc.

    CREATE DATA lr_row.
    lr_row->name = `r1`.
    lr_row->qty  = 1.

    CREATE OBJECT lo_app TYPE ltcl_app_edge.
    INSERT lr_row INTO TABLE lo_app->mt_refs.
    INSERT lr_none INTO TABLE lo_app->mt_refs.

    lo_model = edge_model( lo_app ).

    GET REFERENCE OF lo_app->mt_refs INTO temp404.
edge_bind( io_model = lo_model
               ir_val   = temp404
               iv_name  = `/MT_REFS` ).

    " ajson writes the row a reference points to - that is what the client
    " edits, and where the cells go
    lo_model->main_json_to_attri( delta( `{"MT_REFS":{"__delta":{"0":{"NAME":"edited","QTY":7}}}}` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `edited`
                                        act = lr_row->name ).
    cl_abap_unit_assert=>assert_equals( exp = 7
                                        act = lr_row->qty ).
    cl_abap_unit_assert=>assert_initial( lo_model->mt_skipped ).

    " a refused cell keeps its old value and is traced, and so is every
    " cell of a row whose reference points nowhere
    lo_model->main_json_to_attri( delta( `{"MT_REFS":{"__delta":{"0":{"QTY":"seven"},"1":{"NAME":"lost"}}}}` ) ).
    cl_abap_unit_assert=>assert_equals( exp = 7
                                        act = lr_row->qty ).
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( lo_model->mt_skipped ) ).


    READ TABLE lo_model->mt_skipped WITH KEY row = 1 field = `QTY` TRANSPORTING NO FIELDS.
    temp20 = sy-subrc.
    temp51 = boolc( temp20 = 0 ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp51 ). "#EC CI_SORTSEQ


    READ TABLE lo_model->mt_skipped WITH KEY row = 2 field = `NAME` TRANSPORTING NO FIELDS.
    temp21 = sy-subrc.
    temp52 = boolc( temp21 = 0 ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp52 ). "#EC CI_SORTSEQ

  ENDMETHOD.

  METHOD wide_numbers_quoted.

    DATA lv_path TYPE string.

    " every wide value set from its text, never copied from another
    " field: the transpiled runtime copies a packed through a double
    " (abap-check, section 4), a system does not
    DATA lo_app TYPE REF TO ltcl_app_edge.
    FIELD-SYMBOLS <row> TYPE ltcl_app_edge=>ty_s_wide.
    DATA lo_model TYPE REF TO z2ui5_cl_ui5_srv_model.
    DATA temp405 LIKE REF TO lo_app->ms_wide-name.
    DATA temp406 LIKE REF TO lo_app->ms_wide-changed_at.
    DATA temp407 LIKE REF TO lo_app->ms_flat.
    DATA temp408 LIKE REF TO lo_app->mt_wide.
    DATA temp409 LIKE REF TO lo_app->ms_deep.
    DATA temp410 LIKE REF TO lo_app->mv_big.
    DATA lo_out TYPE REF TO z2ui5_if_ui5_ajs.
    DATA temp411 TYPE string_table.
    DATA lt_quoted LIKE temp411.
    DATA temp413 TYPE string_table.
    DATA lt_number LIKE temp413.
    CREATE OBJECT lo_app TYPE ltcl_app_edge.
    wide_fill( CHANGING cs_wide = lo_app->ms_wide ).
    wide_fill( CHANGING cs_wide = lo_app->ms_flat ).
    wide_fill( CHANGING cs_wide = lo_app->ms_deep-s_wide ).

    INSERT INITIAL LINE INTO TABLE lo_app->mt_wide ASSIGNING <row>.
    wide_fill( CHANGING cs_wide = <row> ).
    INSERT INITIAL LINE INTO TABLE lo_app->ms_deep-t_wide ASSIGNING <row>.
    wide_fill( CHANGING cs_wide = <row> ).
    lo_app->mv_big = '12.5'.

    lo_model = edge_model( lo_app ).

    GET REFERENCE OF lo_app->ms_wide-name INTO temp405.
edge_bind( io_model = lo_model
               ir_val   = temp405
               iv_name  = `/MS_WIDE/NAME` ).

    GET REFERENCE OF lo_app->ms_wide-changed_at INTO temp406.
edge_bind( io_model = lo_model
               ir_val   = temp406
               iv_name  = `/MS_WIDE/CHANGED_AT` ).

    GET REFERENCE OF lo_app->ms_flat INTO temp407.
edge_bind( io_model = lo_model
               ir_val   = temp407
               iv_name  = `/MS_FLAT` ).

    GET REFERENCE OF lo_app->mt_wide INTO temp408.
edge_bind( io_model = lo_model
               ir_val   = temp408
               iv_name  = `/MT_WIDE` ).

    GET REFERENCE OF lo_app->ms_deep INTO temp409.
edge_bind( io_model = lo_model
               ir_val   = temp409
               iv_name  = `/MS_DEEP` ).

    GET REFERENCE OF lo_app->mv_big INTO temp410.
edge_bind( io_model = lo_model
               ir_val   = temp410
               iv_name  = `/MV_BIG` ).


    lo_out = delta( lo_model->main_json_stringify( ) ).

    " a number a double rounds goes out as text - a component bound on its
    " own, a flat structure and the rows of a table (the fast road), a deep
    " value (the general road)

    CLEAR temp411.
    INSERT `/MS_WIDE/CHANGED_AT` INTO TABLE temp411.
    INSERT `/MS_FLAT/CHANGED_AT` INTO TABLE temp411.
    INSERT `/MT_WIDE/1/CHANGED_AT` INTO TABLE temp411.
    INSERT `/MS_DEEP/S_WIDE/CHANGED_AT` INTO TABLE temp411.
    INSERT `/MS_DEEP/T_WIDE/1/CHANGED_AT` INTO TABLE temp411.

    lt_quoted = temp411.
    LOOP AT lt_quoted INTO lv_path.
      cl_abap_unit_assert=>assert_equals( exp = z2ui5_if_ui5_ajs_types=>node_type-string
                                          act = lo_out->get_node_type( lv_path )
                                          msg = lv_path ).
      cl_abap_unit_assert=>assert_equals( exp = `20240115123045.1234567`
                                          act = lo_out->get_string( lv_path )
                                          msg = lv_path ).
    ENDLOOP.
    cl_abap_unit_assert=>assert_equals( exp = z2ui5_if_ui5_ajs_types=>node_type-string
                                        act = lo_out->get_node_type( `/MS_FLAT/BIG` ) ).
    cl_abap_unit_assert=>assert_equals( exp = z2ui5_if_ui5_ajs_types=>node_type-string
                                        act = lo_out->get_node_type( `/MS_DEEP/S_WIDE/BIG` ) ).

    " what a double holds stays a number: a price of 8 bytes, a short
    " decfloat, a float

    CLEAR temp413.
    INSERT `/MS_FLAT/PRICE` INTO TABLE temp413.
    INSERT `/MS_FLAT/RATIO` INTO TABLE temp413.
    INSERT `/MT_WIDE/1/PRICE` INTO TABLE temp413.
    INSERT `/MS_DEEP/S_WIDE/PRICE` INTO TABLE temp413.
    INSERT `/MS_DEEP/S_WIDE/RATIO` INTO TABLE temp413.
    INSERT `/MV_BIG` INTO TABLE temp413.

    lt_number = temp413.
    LOOP AT lt_number INTO lv_path.
      cl_abap_unit_assert=>assert_equals( exp = z2ui5_if_ui5_ajs_types=>node_type-number
                                          act = lo_out->get_node_type( lv_path )
                                          msg = lv_path ).
    ENDLOOP.

    " the edit of a sibling sends the text back as it came: nothing moves
    lo_model->main_json_to_attri( delta( `{"MS_WIDE":{"NAME":"b","CHANGED_AT":"20240115123045.1234567"},` &&
                                         `"MS_FLAT":{"NAME":"b","CHANGED_AT":"20240115123045.1234567",` &&
                                         `"PRICE":12.5,"RATIO":0.5}}` ) ).
    cl_abap_unit_assert=>assert_initial( lo_model->mt_skipped ).
    cl_abap_unit_assert=>assert_equals( exp = `b`
                                        act = lo_app->ms_wide-name ).
    cl_abap_unit_assert=>assert_equals( exp = `20240115123045.1234567`
                                        act = |{ lo_app->ms_wide-changed_at }| ).
    cl_abap_unit_assert=>assert_equals( exp = `20240115123045.1234567`
                                        act = |{ lo_app->ms_flat-changed_at }| ).

  ENDMETHOD.

  METHOD delta_numc_refused.

    DATA lo_app TYPE REF TO ltcl_app_conv.
    DATA temp415 TYPE ltcl_app_conv=>ty_t_row.
    DATA temp416 LIKE LINE OF temp415.
    DATA lr_attri TYPE REF TO z2ui5_if_ui5_types=>ty_t_attri.
    DATA lo_model TYPE REF TO z2ui5_cl_ui5_srv_model.
    DATA temp417 TYPE string_table.
    DATA lt_refused LIKE temp417.
    DATA lv_value LIKE LINE OF lt_refused.
      DATA temp419 TYPE string.
      FIELD-SYMBOLS <temp108> LIKE LINE OF lo_app->mt_row.
      DATA temp109 LIKE sy-tabix.
      FIELD-SYMBOLS <temp420> LIKE LINE OF lo_model->mt_skipped.
      DATA temp421 LIKE sy-tabix.
    DATA temp422 TYPE string.
    FIELD-SYMBOLS <temp110> LIKE LINE OF lo_app->mt_row.
    DATA temp111 LIKE sy-tabix.
    DATA temp423 TYPE string.
    FIELD-SYMBOLS <temp112> LIKE LINE OF lo_app->mt_row.
    DATA temp113 LIKE sy-tabix.
    CREATE OBJECT lo_app TYPE ltcl_app_conv.

    CLEAR temp415.

    temp416-numc = '00042'.
    INSERT temp416 INTO TABLE temp415.
    lo_app->mt_row = temp415.

    CREATE DATA lr_attri.

    CREATE OBJECT lo_model TYPE z2ui5_cl_ui5_srv_model EXPORTING attri = lr_attri app = lo_app.

    " a letter, a sign, a digit more than the field has places: assigned,
    " the first lost the letter, the second kept the sign on the transpiled
    " runtime, the third lost its first digit - refused now, the old value
    " kept

    CLEAR temp417.
    INSERT `12a3` INTO TABLE temp417.
    INSERT `-5` INTO TABLE temp417.
    INSERT `123456` INTO TABLE temp417.

    lt_refused = temp417.

    LOOP AT lt_refused INTO lv_value.
      CLEAR lo_model->mt_skipped.
      lo_model->delta_apply_to_table(
          io_val_front = delta( |\{"__delta":\{"0":\{"NUMC":"{ lv_value }"\}\}\}| )
          iv_name      = `MT_ROW` ).



      temp109 = sy-tabix.
      READ TABLE lo_app->mt_row INDEX 1 ASSIGNING <temp108>.
      sy-tabix = temp109.
      IF sy-subrc <> 0.
        ASSERT 1 = 0.
      ENDIF.
      temp419 = <temp108>-numc.
      cl_abap_unit_assert=>assert_equals( exp = `00042`
                                          act = temp419
                                          msg = lv_value ).


      temp421 = sy-tabix.
      READ TABLE lo_model->mt_skipped INDEX 1 ASSIGNING <temp420>.
      sy-tabix = temp421.
      IF sy-subrc <> 0.
        ASSERT 1 = 0.
      ENDIF.
      cl_abap_unit_assert=>assert_equals( exp = lv_value
                                          act = <temp420>-value ).
    ENDLOOP.

    " leading zeros are no digits of the value, and the emptied field is 0
    CLEAR lo_model->mt_skipped.
    lo_model->delta_apply_to_table( io_val_front = delta( `{"__delta":{"0":{"NUMC":"0000007"}}}` )
                                    iv_name      = `MT_ROW` ).



    temp111 = sy-tabix.
    READ TABLE lo_app->mt_row INDEX 1 ASSIGNING <temp110>.
    sy-tabix = temp111.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    temp422 = <temp110>-numc.
    cl_abap_unit_assert=>assert_equals( exp = `00007`
                                        act = temp422 ).
    lo_model->delta_apply_to_table( io_val_front = delta( `{"__delta":{"0":{"NUMC":""}}}` )
                                    iv_name      = `MT_ROW` ).



    temp113 = sy-tabix.
    READ TABLE lo_app->mt_row INDEX 1 ASSIGNING <temp112>.
    sy-tabix = temp113.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    temp423 = <temp112>-numc.
    cl_abap_unit_assert=>assert_equals( exp = `00000`
                                        act = temp423 ).
    cl_abap_unit_assert=>assert_initial( lo_model->mt_skipped ).

  ENDMETHOD.
ENDCLASS.


" ---------------------------------------------------------------------------
" 05 DRAFT - the state across the draft: save, restore, the next render
" ---------------------------------------------------------------------------
CLASS ltcl_05_draft DEFINITION INHERITING FROM ltcl_00_base FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION MEDIUM.

  PRIVATE SECTION.
    " the save detaches the generic references, the restore in place brings
    " them back - the roundtrip that is in flight goes on rendering
    METHODS save_restore_in_place    FOR TESTING RAISING cx_static_check.
    " the draft read into a NEW instance, and the render after that
    METHODS roundtrip_new_instance   FOR TESTING RAISING cx_static_check.
    METHODS second_roundtrip_clean   FOR TESTING RAISING cx_static_check.
    " the payload lives on the canonical row - also when that row is in the
    " nested object (sample 339 with the sort order turned around)
    METHODS payload_on_canonical_row FOR TESTING RAISING cx_static_check.
    " the payload travels as two documents, type and data - and a row
    " written before (one combined document) is still restored
    METHODS payload_two_documents    FOR TESTING RAISING cx_static_check.
    METHODS payload_one_document_old FOR TESTING RAISING cx_static_check.
    " what does NOT survive, quietly
    METHODS dead_objects_stay_quiet  FOR TESTING RAISING cx_static_check.
    " what has to survive, loudly if it cannot
    METHODS broken_payload_bound_loud  FOR TESTING RAISING cx_static_check.
    METHODS broken_payload_unbound_ok  FOR TESTING RAISING cx_static_check.
    " the draft outlives the class
    METHODS attribute_gone_skipped   FOR TESTING RAISING cx_static_check.
    METHODS attribute_new_found      FOR TESTING RAISING cx_static_check.
    " the host swapped its sub-app's class (sample 338), before and after
    METHODS class_swap_before_load   FOR TESTING RAISING cx_static_check.
    METHODS class_swap_after_load    FOR TESTING RAISING cx_static_check.
    " what a bind carries survives: filter, json flag
    METHODS bind_options_survive     FOR TESTING RAISING cx_static_check.
    " values with markup survive both serializations
    METHODS markup_survives          FOR TESTING RAISING cx_static_check.
    " a cell binding on the restored instance (sample 332)
    METHODS cell_bind_after_restore  FOR TESTING RAISING cx_static_check.
    " the forms the samples never had: interface ref, table of objects
    METHODS interface_and_obj_table  FOR TESTING RAISING cx_static_check.
    " S13 - skipped in Node (CREATE DATA ... TYPE REF TO data)
    METHODS dref_chain_survives      FOR TESTING RAISING cx_static_check.
    " a draft written before the rows carried their type name loads, binds
    " and saves like one of this version
    METHODS legacy_draft_no_type_name FOR TESTING RAISING cx_static_check.
    " the LIVE instance across two roundtrips, no draft read in between (a
    " sticky session): main( ) creates its references again - the same type,
    " and another one - and the next render, model and draft follow
    METHODS live_recreated_same_type   FOR TESTING RAISING cx_static_check.
    METHODS live_recreated_other_type  FOR TESTING RAISING cx_static_check.
    " a save that no main( ) preceded changes neither the rows nor the data
    METHODS save_without_main_is_noop  FOR TESTING RAISING cx_static_check.
    " a helper created late, holding a reference INTO the app: bound after
    " the fact it binds as the owner, and the save keeps it that way
    METHODS late_alias_survives_save   FOR TESTING RAISING cx_static_check.
    " a reference pointed at ANOTHER attribute between two roundtrips, and
    " one of three shared references pointed at a table of its own: the
    " draft follows the new targets, not the owners of the first pass
    METHODS alias_repointed_survives   FOR TESTING RAISING cx_static_check.
    " a reference the app CLEARed stays cleared across the draft - the
    " restore used to point it back at the owner its `->*` row still named
    METHODS alias_cleared_stays_cleared FOR TESTING RAISING cx_static_check.
    " a generic reference still INITIAL when the rows were dissolved, given
    " a table of its own later and never bound: its row has no `->*` child,
    " and the save used to store no payload for it - the detach then left
    " the draft without the table
    METHODS late_table_survives_draft FOR TESTING RAISING cx_static_check.

    " the payload shape every draft before 2026-09 carried: the S-RTTI
    " descriptor graph and the data in ONE asXML document. The framework
    " only reads it now (z2ui5_cl_ui5_util_context=>xml_srtti_parse); the
    " writer lives here, with the one test that restores such a draft
    METHODS legacy_document
      IMPORTING
        data          TYPE any
      RETURNING
        VALUE(result) TYPE string.
ENDCLASS.


CLASS ltcl_05_draft IMPLEMENTATION.

  METHOD save_restore_in_place.
    DATA lv_before TYPE string.

    bind_all( ).

    lv_before = mo_model->main_json_stringify( ).

    mo_model->main_attri_db_save_srtti( ).
    cl_abap_unit_assert=>assert_not_bound( act = mo_app->mr_handle_tab
                                           msg = `the save must detach the generic reference` ).
    cl_abap_unit_assert=>assert_not_bound( mo_app->mr_elem ).
    cl_abap_unit_assert=>assert_not_bound( mo_app->mo_inner->mr_shared ).
    " EVERY data reference is detached, the typed ones too - S-RTTI carries
    " them all; typed attributes are not touched, asXML carries them
    cl_abap_unit_assert=>assert_not_bound( mo_app->mr_typed_tab ).
    cl_abap_unit_assert=>assert_not_bound( mo_app->mr_alias_tab ).
    cl_abap_unit_assert=>assert_equals( exp = `text`
                                        act = mo_app->mv_string ).
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( mo_app->mt_std ) ).

    mo_model->main_attri_db_load( ).
    inv_all( lv_before ).

  ENDMETHOD.

  METHOD roundtrip_new_instance.

    FIELD-SYMBOLS <tab>    TYPE STANDARD TABLE.
    FIELD-SYMBOLS <nested> TYPE any.
    DATA lv_before TYPE string.
    FIELD-SYMBOLS <temp424> LIKE LINE OF mo_app->mt_rows_ref.
    DATA temp425 LIKE sy-tabix.
    FIELD-SYMBOLS <temp426> LIKE LINE OF mo_app->mt_rows_ref.
    DATA temp427 LIKE sy-tabix.
    FIELD-SYMBOLS <temp428> LIKE LINE OF mo_app->mt_comp.
    DATA temp429 LIKE sy-tabix.

    bind_all( ).

    lv_before = mo_model->main_json_stringify( ).

    roundtrip( ).
    inv_all( lv_before ).

    " the data behind the rows, not only the rows
    ASSIGN mo_app->mr_handle_tab->* TO <tab>.
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( <tab> ) ).
    ASSIGN mo_app->ms_with_dref-r_tab->* TO <tab>.
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( <tab> ) ).
    cl_abap_unit_assert=>assert_equals( exp = `typed-elem`
                                        act = mo_app->mr_typed_elem->* ).
    cl_abap_unit_assert=>assert_equals( exp = `deeper`
                                        act = mo_app->mo_inner->mo_deeper->mv_inner ).
    cl_abap_unit_assert=>assert_equals( exp = `in-struc`
                                        act = mo_app->ms_with_oref-o_obj->mv_inner ).


    temp425 = sy-tabix.
    READ TABLE mo_app->mt_rows_ref INDEX 1 ASSIGNING <temp424>.
    sy-tabix = temp425.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `cell-ref`
                                        act = <temp424>-r_elem->* ).


    temp427 = sy-tabix.
    READ TABLE mo_app->mt_rows_ref INDEX 1 ASSIGNING <temp426>.
    sy-tabix = temp427.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `cell-obj`
                                        act = <temp426>-o_obj->mv_inner ).
    cl_abap_unit_assert=>assert_equals( exp = `protected`
                                        act = mo_app->get_protected( ) ).
    " the rows of the descriptor table survive, the descriptors they held do
    " not (an RTTI descriptor is not serializable), and neither is an error
    cl_abap_unit_assert=>assert_equals( exp = 3
                                        act = lines( mo_app->mt_comp ) ).


    temp429 = sy-tabix.
    READ TABLE mo_app->mt_comp INDEX 1 ASSIGNING <temp428>.
    sy-tabix = temp429.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_not_bound( <temp428>-type ).
    ASSIGN mo_app->mr_handle_nested->* TO <nested>.
    ASSIGN COMPONENT `T_ITEMS` OF STRUCTURE <nested> TO <tab>.
    cl_abap_unit_assert=>assert_subrc( ).
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( <tab> ) ).

  ENDMETHOD.

  METHOD second_roundtrip_clean.
    DATA lv_second TYPE string.
    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <row> TYPE any.
    DATA ls_sel TYPE ltcl_app_shapes=>ty_s_row_sel.
    DATA lv_changed TYPE string.
    DATA temp53 TYPE xsdboolean.

    bind_all( ).
    roundtrip( ).

    lv_second = mo_model->main_json_stringify( ).

    " the restored instance changes its data through the helper's reference
    " (sample 335) before the next draft; the change reaches the model of
    " the roundtrip after that, and the references stay one



    ASSIGN mo_app->mo_inner->mr_shared->* TO <tab>.
    ls_sel-col1 = `appended after the restore`.
    INSERT INITIAL LINE INTO TABLE <tab> ASSIGNING <row>.
    MOVE-CORRESPONDING ls_sel TO <row>.

    lv_changed = mo_model->main_json_stringify( ).
    cl_abap_unit_assert=>assert_differs( exp = lv_second
                                         act = lv_changed ).

    temp53 = boolc( lv_changed CS `"appended after the restore"` ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp53 ).

    roundtrip( ).
    inv_all( lv_changed ).
    ASSIGN mo_app->mr_shared_a->* TO <tab>.
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( <tab> ) ).

  ENDMETHOD.

  METHOD payload_two_documents.

    bind( mo_app->mr_shared_a ).
    mo_model->main_attri_db_save_srtti( ).

    " type and data on the canonical row, each a document of its own
    cl_abap_unit_assert=>assert_not_initial( row( `MR_SHARED_B` )-srtti_type ).
    cl_abap_unit_assert=>assert_not_initial( row( `MR_SHARED_B` )-srtti_data ).
    cl_abap_unit_assert=>assert_initial( row( `MR_SHARED_A` )-srtti_type ).

    mo_model->main_attri_db_load( ).
    inv_identity_shared( ).
    cl_abap_unit_assert=>assert_initial( row( `MR_SHARED_B` )-srtti_type ).

  ENDMETHOD.

  METHOD payload_one_document_old.

    FIELD-SYMBOLS <val> TYPE any.
    DATA lr_row TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.
    DATA lr_val TYPE REF TO data.

    bind( mo_app->mr_shared_a ).
    mo_model->main_attri_db_save_srtti( ).

    " rewrite the row the way every draft before 2026-09 carried it: one
    " combined document and no type of its own

    lr_row = row_ref( `MR_SHARED_B` ).

    lr_val = z2ui5_cl_ui5_util_context=>xml_srtti_parse_pair( iv_type = lr_row->srtti_type
                                                                    iv_data = lr_row->srtti_data ).
    ASSIGN lr_val->* TO <val>.
    lr_row->srtti_data = legacy_document( <val> ).
    CLEAR lr_row->srtti_type.

    mo_model->main_attri_db_load( ).
    cl_abap_unit_assert=>assert_bound( act = mo_app->mr_shared_a
                                       msg = `the one-document payload was not restored` ).
    cl_abap_unit_assert=>assert_initial( row( `MR_SHARED_B` )-srtti_data ).
    inv_identity_shared( ).

  ENDMETHOD.

  METHOD legacy_document.

    DATA lo_srtti TYPE REF TO object.
    lo_srtti = z2ui5_cl_ui5_util_context=>xml_srtti_descr( data ).
    CALL TRANSFORMATION id SOURCE srtti = lo_srtti dobj = data RESULT XML result.

  ENDMETHOD.

  METHOD payload_on_canonical_row.

    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
    DATA ls_row TYPE ltcl_shp_inner=>ty_s_row.
    DATA lo_app TYPE REF TO ltcl_app_shared_last.
    DATA temp430 TYPE REF TO cl_abap_tabledescr.
    DATA lo_tab LIKE temp430.
    DATA lr_attri TYPE REF TO z2ui5_if_ui5_types=>ty_t_attri.
    DATA lo_model TYPE REF TO z2ui5_cl_ui5_srv_model.
    DATA ls_bind TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.
    DATA lv_before TYPE string.
    FIELD-SYMBOLS <temp431> LIKE LINE OF lr_attri->*.
    DATA temp432 LIKE sy-tabix.
    FIELD-SYMBOLS <temp433> LIKE LINE OF lr_attri->*.
    DATA temp434 LIKE sy-tabix.
    DATA lv_app_xml TYPE string.
    DATA lv_attri_xml TYPE string.
    DATA temp54 TYPE xsdboolean.
    DATA temp55 TYPE xsdboolean.

    " the fixture's own shared table: the canonical row is MR_SHARED_B->*
    bind( mo_app->mr_shared_a ).
    mo_model->main_attri_db_save_srtti( ).
    cl_abap_unit_assert=>assert_not_initial( row( `MR_SHARED_B` )-srtti_data ).
    cl_abap_unit_assert=>assert_initial( row( `MR_SHARED_A` )-srtti_data ).
    cl_abap_unit_assert=>assert_initial( row( `MO_INNER->MR_SHARED` )-srtti_data ).
    mo_model->main_attri_db_load( ).
    inv_identity_shared( ).

    " and the app where the nested reference sorts LAST: the payload lives
    " on the nested object's row and the outer references are re-pointed
    " from there

    CREATE OBJECT lo_app TYPE ltcl_app_shared_last.
    CREATE OBJECT lo_app->mz_inner.

    temp430 ?= cl_abap_typedescr=>describe_by_data( lo_app->mz_inner->mt_own ).

    lo_tab = temp430.
    CREATE DATA lo_app->mr_table TYPE HANDLE lo_tab.
    ASSIGN lo_app->mr_table->* TO <tab>.
    ls_row-col1 = `shared`.
    INSERT ls_row INTO TABLE <tab>.
    lo_app->mr_table_tmp = lo_app->mr_table.
    lo_app->mz_inner->mr_shared = lo_app->mr_table.


    CREATE DATA lr_attri.

    CREATE OBJECT lo_model TYPE z2ui5_cl_ui5_srv_model EXPORTING attri = lr_attri app = lo_app.

    ls_bind = lo_model->main_attri_search( lo_app->mr_table ).
    ls_bind->bind = abap_true.
    ls_bind->name_client = `/MR_TABLE`.
    cl_abap_unit_assert=>assert_equals( exp = `MZ_INNER->MR_SHARED->*`
                                        act = ls_bind->name ).

    lv_before = lo_model->main_json_stringify( ).

    lo_model->main_attri_db_save_srtti( ).


    temp432 = sy-tabix.
    READ TABLE lr_attri->* WITH KEY name = `MZ_INNER->MR_SHARED` ASSIGNING <temp431>.
    sy-tabix = temp432.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_not_initial( <temp431>-srtti_data ).


    temp434 = sy-tabix.
    READ TABLE lr_attri->* WITH KEY name = `MR_TABLE` ASSIGNING <temp433>.
    sy-tabix = temp434.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_initial( <temp433>-srtti_data ).


    lv_app_xml   = z2ui5_cl_ui5_util_context=>xml_stringify( lo_app ).

    lv_attri_xml = z2ui5_cl_ui5_util_context=>xml_stringify( lr_attri->* ).
    CLEAR lo_app.
    z2ui5_cl_ui5_util_context=>xml_parse( EXPORTING xml = lv_app_xml
                                          IMPORTING any = lo_app ).
    CREATE DATA lr_attri.
    z2ui5_cl_ui5_util_context=>xml_parse( EXPORTING xml = lv_attri_xml
                                          IMPORTING any = lr_attri->* ).
    CREATE OBJECT lo_model EXPORTING attri = lr_attri app = lo_app.
    lo_model->main_attri_db_load( ).


    temp54 = boolc( lo_app->mr_table = lo_app->mr_table_tmp ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp54 ).

    temp55 = boolc( lo_app->mr_table = lo_app->mz_inner->mr_shared ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp55 ).
    cl_abap_unit_assert=>assert_equals( exp = lv_before
                                        act = lo_model->main_json_stringify( ) ).

  ENDMETHOD.

  METHOD dead_objects_stay_quiet.
    DATA temp435 LIKE REF TO mo_app->mv_string.
DATA lr_attri TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.

    bind_all( ).
    roundtrip( ).

    " S15 - not serializable, so gone; and nothing raised on the way
    cl_abap_unit_assert=>assert_not_bound( mo_app->mo_dead ).
    " the row it left behind carries no descriptor and is skipped by the
    " search instead of dumping it
    cl_abap_unit_assert=>assert_not_bound( row( `MO_DEAD->MV_TEXT` )-o_typedescr ).

    GET REFERENCE OF mo_app->mv_string INTO temp435.

lr_attri = mo_model->main_attri_search( temp435 ).
    cl_abap_unit_assert=>assert_equals( exp = `MV_STRING`
                                        act = lr_attri->name ).
    " a refresh drops the orphan rows for good
    mo_model->main_attri_refresh( ).
    cl_abap_unit_assert=>assert_equals( exp = abap_false act = row_exists( `MO_DEAD->MV_TEXT` ) ).

  ENDMETHOD.

  METHOD broken_payload_bound_loud.
    DATA lr_payload TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.
        DATA lx TYPE REF TO z2ui5_cx_ui5_util_error.
        DATA temp56 TYPE xsdboolean.
        DATA temp57 TYPE xsdboolean.

    " the payload of a BOUND table is not what S-RTTI wrote (a system
    " upgrade, a type change): the load says so - the alternative was an
    " app running on a cleared reference and a view that comes back empty
    bind( mo_app->mr_handle_tab ).
    mo_model->main_attri_db_save_srtti( ).

    lr_payload = row_ref( `MR_HANDLE_TAB` ).
    lr_payload->srtti_data = `this is not the serialized type`.

    TRY.
        mo_model->main_attri_db_load( ).
        cl_abap_unit_assert=>fail( `a failed restore of BOUND data must not pass silently` ).

      CATCH z2ui5_cx_ui5_util_error INTO lx.

        temp56 = boolc( lx->get_text( ) CS `APP_STATE_RESTORE_ERROR` ).
        cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp56 ).

        temp57 = boolc( lx->get_text( ) CS `MR_HANDLE_TAB` ).
        cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp57 ).
    ENDTRY.

  ENDMETHOD.

  METHOD broken_payload_unbound_ok.

    " nothing reads it, so it keeps the lenient treatment - the payload
    " stays on the row (only a SUCCESSFUL restore clears it), the reference
    " the save cleared stays unbound, everything else is restored
    DATA temp436 LIKE REF TO mo_app->mv_string.
    DATA lr_broken TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.
    GET REFERENCE OF mo_app->mv_string INTO temp436.
bind( temp436 ).
    mo_model->main_attri_db_save_srtti( ).

    lr_broken = row_ref( `MR_ELEM` ).
    lr_broken->srtti_data = `this is not the serialized type`.

    mo_model->main_attri_db_load( ).

    cl_abap_unit_assert=>assert_not_initial( row( `MR_ELEM` )-srtti_data ).
    cl_abap_unit_assert=>assert_not_bound( mo_app->mr_elem ).
    cl_abap_unit_assert=>assert_bound( mo_app->mr_handle_tab ).

  ENDMETHOD.

  METHOD attribute_gone_skipped.
    DATA lv_before TYPE string.
    DATA lv_app_xml TYPE string.
    DATA lv_attri_xml TYPE string.
    DATA temp437 TYPE z2ui5_if_ui5_types=>ty_s_attri.
    DATA temp438 TYPE z2ui5_if_ui5_types=>ty_s_attri.
    DATA temp439 TYPE z2ui5_if_ui5_types=>ty_s_attri.

    " the class lost an attribute since the draft was written: its rows are
    " skipped by every restore step, the rest comes back, and a bind on
    " what is left works
    bind_all( ).

    lv_before = mo_model->main_json_stringify( ).
    mo_model->main_attri_db_save_srtti( ).

    lv_app_xml   = z2ui5_cl_ui5_util_context=>xml_stringify( mo_app ).

    lv_attri_xml = z2ui5_cl_ui5_util_context=>xml_stringify( mr_attri->* ).
    CLEAR mo_app.
    z2ui5_cl_ui5_util_context=>xml_parse( EXPORTING xml = lv_app_xml
                                          IMPORTING any = mo_app ).
    CREATE DATA mr_attri.
    z2ui5_cl_ui5_util_context=>xml_parse( EXPORTING xml = lv_attri_xml
                                          IMPORTING any = mr_attri->* ).
    " the rows of the attribute that is gone: a plain one, and a dref with
    " a payload nobody can put anywhere

    CLEAR temp437.
    temp437-name = `MV_GONE`.
    temp437-check_dissolved = abap_true.
    temp437-type_kind = row( `MV_STRING` )-type_kind.
    temp437-kind = row( `MV_STRING` )-kind.
    temp437-bind = abap_true.
    temp437-name_client = `/MV_GONE`.
    INSERT temp437 INTO TABLE mr_attri->*.

    CLEAR temp438.
    temp438-name = `MR_GONE`.
    temp438-check_dissolved = abap_true.
    temp438-type_kind = z2ui5_cl_ui5_util_context=>cv_typedescr_typekind_dref.
    temp438-srtti_data = `payload of a reference nobody has`.
    INSERT temp438 INTO TABLE mr_attri->*.

    CLEAR temp439.
    temp439-name = `MR_GONE->*`.
    temp439-name_parent = `MR_GONE`.
    temp439-check_dissolved = abap_true.
    temp439-type_kind = z2ui5_cl_ui5_util_context=>cv_typedescr_typekind_table.
    temp439-name_ref = `MR_SHARED_B->*`.
    INSERT temp439 INTO TABLE mr_attri->*.

    model_renew( ).
    mo_model->main_attri_db_load( ).

    inv_identity_shared( ).
    inv_search_finds_bound( ).
    " the model is the old one - MV_GONE has no value to ship
    cl_abap_unit_assert=>assert_equals( exp = lv_before
                                        act = mo_model->main_json_stringify( ) ).

  ENDMETHOD.

  METHOD attribute_new_found.
    DATA lv_app_xml TYPE string.
    DATA lv_attri_xml TYPE string.
    DATA temp440 LIKE REF TO mo_app->mv_xstr.
DATA lr_attri TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.

    " the class gained an attribute since the draft was written: it has no
    " row yet, and the first bind on it finds it through a refresh - with
    " every earlier bind kept
    bind_all( ).
    mo_model->main_attri_db_save_srtti( ).

    lv_app_xml   = z2ui5_cl_ui5_util_context=>xml_stringify( mo_app ).

    lv_attri_xml = z2ui5_cl_ui5_util_context=>xml_stringify( mr_attri->* ).
    CLEAR mo_app.
    z2ui5_cl_ui5_util_context=>xml_parse( EXPORTING xml = lv_app_xml
                                          IMPORTING any = mo_app ).
    CREATE DATA mr_attri.
    z2ui5_cl_ui5_util_context=>xml_parse( EXPORTING xml = lv_attri_xml
                                          IMPORTING any = mr_attri->* ).
    DELETE mr_attri->* WHERE name = `MV_XSTR`.
    model_renew( ).
    mo_model->main_attri_db_load( ).


    GET REFERENCE OF mo_app->mv_xstr INTO temp440.

lr_attri = mo_model->main_attri_search( temp440 ).
    cl_abap_unit_assert=>assert_equals( exp = `MV_XSTR`
                                        act = lr_attri->name ).
    inv_search_finds_bound( ).

  ENDMETHOD.

  METHOD class_swap_before_load.

    " roundtrip 1: the host renders sub-app A and binds A's table
    DATA lo_host TYPE REF TO ltcl_app_host.
    DATA lo_a TYPE REF TO ltcl_shp_sub_a.
    DATA lr_attri TYPE REF TO z2ui5_if_ui5_types=>ty_t_attri.
    DATA lo_model TYPE REF TO z2ui5_cl_ui5_srv_model.
    DATA temp441 LIKE REF TO lo_host->mv_selectedkey.
DATA ls_bind TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.
    DATA lv_app_xml TYPE string.
    DATA lv_attri_xml TYPE string.
    DATA lo_b TYPE REF TO ltcl_shp_sub_b.
    FIELD-SYMBOLS <temp442> LIKE LINE OF lr_attri->*.
    DATA temp443 LIKE sy-tabix.
    DATA temp444 LIKE REF TO lo_host->mv_selectedkey.
    DATA temp58 TYPE xsdboolean.
    DATA temp22 LIKE sy-subrc.
    CREATE OBJECT lo_host TYPE ltcl_app_host.

    CREATE OBJECT lo_a TYPE ltcl_shp_sub_a.
    CREATE OBJECT lo_a->mo_layout.
    lo_a->fill( ).
    lo_host->mo_app = lo_a.
    lo_host->mv_selectedkey = `1`.


    CREATE DATA lr_attri.

    CREATE OBJECT lo_model TYPE z2ui5_cl_ui5_srv_model EXPORTING attri = lr_attri app = lo_host.

    GET REFERENCE OF lo_host->mv_selectedkey INTO temp441.

ls_bind = lo_model->main_attri_search( temp441 ).
    ls_bind->bind = abap_true.
    ls_bind->name_client = `/MV_SELECTEDKEY`.
    ls_bind = lo_model->main_attri_search( lo_a->mt_table ).
    cl_abap_unit_assert=>assert_equals( exp = `MO_APP->MT_TABLE->*`
                                        act = ls_bind->name ).
    ls_bind->bind = abap_true.
    ls_bind->name_client = `/MO_APP_MT_TABLE`.

    " roundtrip 2: the host holds sub-app B, whose attributes have OTHER
    " names, when the draft is restored. The rows of A resolve to nothing
    " and keep no descriptor - the restore must not raise over them
    lo_model->main_attri_db_save_srtti( ).

    lv_app_xml   = z2ui5_cl_ui5_util_context=>xml_stringify( lo_host ).

    lv_attri_xml = z2ui5_cl_ui5_util_context=>xml_stringify( lr_attri->* ).
    CLEAR lo_host.
    z2ui5_cl_ui5_util_context=>xml_parse( EXPORTING xml = lv_app_xml
                                          IMPORTING any = lo_host ).
    CREATE DATA lr_attri.
    z2ui5_cl_ui5_util_context=>xml_parse( EXPORTING xml = lv_attri_xml
                                          IMPORTING any = lr_attri->* ).

    CREATE OBJECT lo_b TYPE ltcl_shp_sub_b.
    CREATE OBJECT lo_b->mo_lay.
    lo_b->fill( ).
    lo_host->mo_app = lo_b.
    CREATE OBJECT lo_model EXPORTING attri = lr_attri app = lo_host.
    lo_model->main_attri_db_load( ).


    temp443 = sy-tabix.
    READ TABLE lr_attri->* WITH KEY name = `MO_APP->MO_LAYOUT->MV_INNER` ASSIGNING <temp442>.
    sy-tabix = temp443.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_not_bound( <temp442>-o_typedescr ).

    " the host's own bind first - it walks the A rows of its own kind and
    " used to dump on the first one without a descriptor

    GET REFERENCE OF lo_host->mv_selectedkey INTO temp444.
ls_bind = lo_model->main_attri_search( temp444 ).
    cl_abap_unit_assert=>assert_equals( exp = `MV_SELECTEDKEY`
                                        act = ls_bind->name ).
    " then B's table: not in mt_attri, so the search refreshes and finds it
    ls_bind = lo_model->main_attri_search( lo_b->mt_data ).
    cl_abap_unit_assert=>assert_equals( exp = `MO_APP->MT_DATA->*`
                                        act = ls_bind->name ).
    " the refresh dropped A's rows - nothing of the old class lingers


    READ TABLE lr_attri->* WITH KEY name = `MO_APP->MT_TABLE->*` TRANSPORTING NO FIELDS.
    temp22 = sy-subrc.
    temp58 = boolc( temp22 = 0 ).
    cl_abap_unit_assert=>assert_equals( exp = abap_false act = temp58 ).

  ENDMETHOD.

  METHOD class_swap_after_load.

    " the same switch AFTER the restore (the sample's own order: restore,
    " then the tab event creates B), and the draft roundtrip that follows
    DATA lo_host TYPE REF TO ltcl_app_host.
    DATA lo_a TYPE REF TO ltcl_shp_sub_a.
    DATA lr_attri TYPE REF TO z2ui5_if_ui5_types=>ty_t_attri.
    DATA lo_model TYPE REF TO z2ui5_cl_ui5_srv_model.
    DATA ls_bind TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.
    DATA lv_app_xml TYPE string.
    DATA lv_attri_xml TYPE string.
    DATA lo_b TYPE REF TO ltcl_shp_sub_b.
    DATA lv_before TYPE string.
    DATA temp59 TYPE xsdboolean.
    DATA lo_b_restored TYPE REF TO ltcl_shp_sub_b.
    DATA temp60 TYPE xsdboolean.
    CREATE OBJECT lo_host TYPE ltcl_app_host.

    CREATE OBJECT lo_a TYPE ltcl_shp_sub_a.
    CREATE OBJECT lo_a->mo_layout.
    lo_a->fill( ).
    lo_host->mo_app = lo_a.


    CREATE DATA lr_attri.

    CREATE OBJECT lo_model TYPE z2ui5_cl_ui5_srv_model EXPORTING attri = lr_attri app = lo_host.

    ls_bind = lo_model->main_attri_search( lo_a->mt_table ).
    ls_bind->bind = abap_true.
    ls_bind->name_client = `/MO_APP_MT_TABLE`.

    lo_model->main_attri_db_save_srtti( ).

    lv_app_xml   = z2ui5_cl_ui5_util_context=>xml_stringify( lo_host ).

    lv_attri_xml = z2ui5_cl_ui5_util_context=>xml_stringify( lr_attri->* ).
    CLEAR lo_host.
    z2ui5_cl_ui5_util_context=>xml_parse( EXPORTING xml = lv_app_xml
                                          IMPORTING any = lo_host ).
    CREATE DATA lr_attri.
    z2ui5_cl_ui5_util_context=>xml_parse( EXPORTING xml = lv_attri_xml
                                          IMPORTING any = lr_attri->* ).
    CREATE OBJECT lo_model EXPORTING attri = lr_attri app = lo_host.
    lo_model->main_attri_db_load( ).


    CREATE OBJECT lo_b TYPE ltcl_shp_sub_b.
    CREATE OBJECT lo_b->mo_lay.
    lo_b->fill( ).
    lo_host->mo_app = lo_b.
    ls_bind = lo_model->main_attri_search( lo_b->mt_data ).
    ls_bind->bind = abap_true.
    ls_bind->name_client = `/MO_APP_MT_DATA`.

    lv_before = lo_model->main_json_stringify( ).

    temp59 = boolc( lv_before CS `"MO_APP_MT_DATA"` ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp59 ).

    lo_model->main_attri_db_save_srtti( ).
    lv_app_xml   = z2ui5_cl_ui5_util_context=>xml_stringify( lo_host ).
    lv_attri_xml = z2ui5_cl_ui5_util_context=>xml_stringify( lr_attri->* ).
    CLEAR lo_host.
    z2ui5_cl_ui5_util_context=>xml_parse( EXPORTING xml = lv_app_xml
                                          IMPORTING any = lo_host ).
    CREATE DATA lr_attri.
    z2ui5_cl_ui5_util_context=>xml_parse( EXPORTING xml = lv_attri_xml
                                          IMPORTING any = lr_attri->* ).
    CREATE OBJECT lo_model EXPORTING attri = lr_attri app = lo_host.
    lo_model->main_attri_db_load( ).

    cl_abap_unit_assert=>assert_equals( exp = lv_before
                                        act = lo_model->main_json_stringify( ) ).

    lo_b_restored ?= lo_host->mo_app.
    cl_abap_unit_assert=>assert_bound( lo_b_restored->mt_data ).

    temp60 = boolc( lo_b_restored->mt_data = lo_b_restored->mo_lay->mr_shared ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp60 ).
    ls_bind = lo_model->main_attri_search( lo_b_restored->mt_data ).
    cl_abap_unit_assert=>assert_equals( exp = `MO_APP->MT_DATA->*`
                                        act = ls_bind->name ).

  ENDMETHOD.

  METHOD bind_options_survive.
    DATA temp445 LIKE REF TO mo_app->ms_flat.
DATA lr_flat TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.
    DATA temp446 LIKE REF TO mo_app->mv_string.
DATA lr_json TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.
    DATA lv_before TYPE string.
    DATA temp61 TYPE xsdboolean.
    DATA temp62 TYPE xsdboolean.

    " the filter and the json flag travel in mt_attri - a filter class that
    " is not serializable is refused at bind time (srv_bind)
    CLEAR mo_app->ms_flat-col1.

    GET REFERENCE OF mo_app->ms_flat INTO temp445.

lr_flat = bind( temp445 ).
    CREATE OBJECT lr_flat->custom_filter TYPE ltcl_shp_filter.
    mo_app->mv_string = `{"sap.app":{"type":"card"}}`.

    GET REFERENCE OF mo_app->mv_string INTO temp446.

lr_json = bind( temp446 ).
    lr_json->check_json = abap_true.

    lv_before = mo_model->main_json_stringify( ).

    temp61 = boolc( lv_before CS `"COL2"` ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp61 ).

    temp62 = boolc( lv_before CS `"COL1"` ).
    cl_abap_unit_assert=>assert_equals( exp = abap_false act = temp62 ).

    roundtrip( ).

    cl_abap_unit_assert=>assert_bound( row( `MS_FLAT` )-custom_filter ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = row( `MV_STRING` )-check_json ).
    cl_abap_unit_assert=>assert_equals( exp = lv_before
                                        act = mo_model->main_json_stringify( ) ).

  ENDMETHOD.

  METHOD markup_survives.

    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <row> TYPE any.
    DATA ls_sel TYPE ltcl_app_shapes=>ty_s_row_sel.
    DATA temp447 LIKE REF TO mo_app->mv_markup.
    DATA lv_before TYPE string.
    DATA lv_markup LIKE mo_app->mv_markup.

    " markup in a typed attribute (asXML) and in a cell of the runtime-built
    " table (S-RTTI inside asXML) - both serializations escape and unescape
    ASSIGN mo_app->mr_handle_tab->* TO <tab>.
    ls_sel-col1 = mo_app->mv_markup.
    INSERT INITIAL LINE INTO TABLE <tab> ASSIGNING <row>.
    MOVE-CORRESPONDING ls_sel TO <row>.

    GET REFERENCE OF mo_app->mv_markup INTO temp447.
bind( temp447 ).
    bind( mo_app->mr_handle_tab ).

    lv_before = mo_model->main_json_stringify( ).

    lv_markup = mo_app->mv_markup.

    roundtrip( ).

    cl_abap_unit_assert=>assert_equals( exp = lv_markup
                                        act = mo_app->mv_markup ).
    inv_json_unchanged( lv_before ).

  ENDMETHOD.

  METHOD cell_bind_after_restore.
    DATA lo_cont TYPE REF TO z2ui5_cl_ui5_app_cont.
    DATA lo_bind TYPE REF TO z2ui5_cl_ui5_srv_bind.
    FIELD-SYMBOLS <temp448> TYPE ltcl_shp_inner=>ty_s_row.
DATA lr_row LIKE REF TO <temp448>.
    DATA temp449 LIKE REF TO mo_app->mo_inner->mt_own.
DATA temp114 LIKE REF TO lr_row->col1.
DATA temp33 TYPE z2ui5_if_ui5_types=>ty_s_bind_config.
DATA lv_path TYPE string.
    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <row> TYPE any.
    DATA temp63 TYPE xsdboolean.
    FIELD-SYMBOLS <cell> TYPE any.
    DATA temp450 TYPE REF TO data.
DATA temp115 TYPE z2ui5_if_ui5_types=>ty_s_bind_config.
    DATA temp64 TYPE xsdboolean.

    bind_all( ).
    roundtrip( ).

    " the binder works on the container: the restored app and the restored
    " attribute table, exactly what the next render's _bind( ) sees

    CREATE OBJECT lo_cont TYPE z2ui5_cl_ui5_app_cont.
    lo_cont->mo_app   = mo_app.
    lo_cont->mt_attri = mr_attri.

    CREATE OBJECT lo_bind TYPE z2ui5_cl_ui5_srv_bind EXPORTING APP = lo_cont.

    " row 1 of the helper's own table, the layout row of sample 332

    READ TABLE mo_app->mo_inner->mt_own INDEX 1 ASSIGNING <temp448>.
IF sy-subrc <> 0.
  ASSERT 1 = 0.
ENDIF.

GET REFERENCE OF <temp448> INTO lr_row.

    GET REFERENCE OF mo_app->mo_inner->mt_own INTO temp449.

GET REFERENCE OF lr_row->col1 INTO temp114.

CLEAR temp33.
temp33-tab = temp449.
temp33-tab_index = 1.

lv_path = lo_bind->main( val    = temp114
                                   config = temp33 ).
    cl_abap_unit_assert=>assert_equals( exp = `{/MO_INNER_MT_OWN/0/COL1}`
                                        act = lv_path ).

    " ...and a cell of the runtime-built table behind the generic reference


    ASSIGN mo_app->mr_handle_tab->* TO <tab>.
    READ TABLE <tab> INDEX 2 ASSIGNING <row>.

    temp63 = boolc( <row> IS ASSIGNED ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp63 ).

    ASSIGN COMPONENT `COL1` OF STRUCTURE <row> TO <cell>.
    cl_abap_unit_assert=>assert_subrc( ).

GET REFERENCE OF <cell> INTO temp450.

CLEAR temp115.
temp115-tab = mo_app->mr_handle_tab.
temp115-tab_index = 2.
lv_path = lo_bind->main( val    = temp450
                             config = temp115 ).

    temp64 = boolc( lv_path CP `{/*/1/COL1}` ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp64
                                      msg = |cell path after restore: { lv_path }| ).

  ENDMETHOD.

  METHOD interface_and_obj_table.

    DATA lo_other TYPE REF TO ltcl_app_shapes.
    DATA temp451 LIKE REF TO lo_other->mv_string.
    DATA temp452 LIKE REF TO mo_app->mv_string.
    DATA lv_before TYPE string.
    DATA lo_restored TYPE REF TO ltcl_app_shapes.
    FIELD-SYMBOLS <temp453> LIKE LINE OF mo_app->mt_apps.
    DATA temp454 LIKE sy-tabix.
    CREATE OBJECT lo_other TYPE ltcl_app_shapes.
    lo_other->mv_string = `other`.
    mo_app->mi_app = lo_other.

    GET REFERENCE OF lo_other->mv_string INTO temp451.
bind( temp451 ).

    GET REFERENCE OF mo_app->mv_string INTO temp452.
bind( temp452 ).

    lv_before = mo_model->main_json_stringify( ).

    roundtrip( ).

    " S28 - the interface-typed reference and the instance behind it

    lo_restored ?= mo_app->mi_app.
    cl_abap_unit_assert=>assert_equals( exp = `other`
                                        act = lo_restored->mv_string ).
    " S29 - the table of objects, row by row
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( mo_app->mt_apps ) ).


    temp454 = sy-tabix.
    READ TABLE mo_app->mt_apps INDEX 1 ASSIGNING <temp453>.
    sy-tabix = temp454.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `in-table`
                                        act = <temp453>->mv_inner ).
    inv_json_unchanged( lv_before ).
    inv_search_finds_bound( ).

  ENDMETHOD.

  METHOD dref_chain_survives.

    FIELD-SYMBOLS <inner> TYPE REF TO data.
    FIELD-SYMBOLS <elem>  TYPE any.

    " S13 - the value behind mr_ref_ref->*->* is data like any other; the
    " dref save cleared the outer reference and never restored it
    CREATE DATA mo_app->mr_ref_ref TYPE REF TO data.
    ASSIGN mo_app->mr_ref_ref->* TO <inner>.
    CREATE DATA <inner> TYPE string.
    ASSIGN <inner>->* TO <elem>.
    <elem> = `ref-ref`.

    bind( <inner> ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = row_exists( `MR_REF_REF->*->*` ) ).
    roundtrip( ).

    cl_abap_unit_assert=>assert_bound( act = mo_app->mr_ref_ref
                                       msg = `S13: the outer reference was lost` ).
    ASSIGN mo_app->mr_ref_ref->* TO <inner>.
    cl_abap_unit_assert=>assert_bound( act = <inner>
                                       msg = `S13: the inner reference was lost` ).
    ASSIGN <inner>->* TO <elem>.
    cl_abap_unit_assert=>assert_equals( exp = `ref-ref`
                                        act = <elem> ).
    inv_search_finds_bound( ).

  ENDMETHOD.


  METHOD alias_cleared_stays_cleared.

    " roundtrip 1: the alias into mt_std, as the fixture has it
    bind_all( ).
    mo_model->main_attri_db_save_srtti( ).
    mo_model->main_attri_reattach( ).
    cl_abap_unit_assert=>assert_equals( exp = `MT_STD`
                                        act = row( `MR_ALIAS_TAB->*` )-name_ref ).

    " main( ) of roundtrip 2: the app lets go of the alias
    CLEAR mo_app->mr_alias_tab.

    " the save drops the alias the child row carried - nothing to re-point
    mo_model->main_attri_db_save_srtti( ).
    cl_abap_unit_assert=>assert_initial( row( `MR_ALIAS_TAB->*` )-name_ref ).
    mo_model->main_attri_reattach( ).
    cl_abap_unit_assert=>assert_not_bound( mo_app->mr_alias_tab ).

    " ...and the draft read into a new instance keeps it cleared
    roundtrip( ).
    cl_abap_unit_assert=>assert_not_bound( act = mo_app->mr_alias_tab
                                           msg = `the restore pointed the cleared alias at its old owner again` ).

  ENDMETHOD.

  METHOD late_table_survives_draft.

    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
    DATA ls_row TYPE ltcl_app_shapes=>ty_s_row.
    DATA lt_exp TYPE ltcl_app_shapes=>ty_t_row.
    DATA temp455 TYPE ltcl_app_shapes=>ty_t_row.
    DATA temp456 LIKE LINE OF temp455.

    " roundtrip 1: the reference is INITIAL when the rows are dissolved
    CLEAR mo_app->mr_alias_tab.
    bind_all( ).
    mo_model->main_attri_db_save_srtti( ).
    mo_model->main_attri_reattach( ).
    cl_abap_unit_assert=>assert_equals( exp = abap_false act = row_exists( `MR_ALIAS_TAB->*` ) ).

    " main( ) of roundtrip 2: a table of its own, which nothing binds - so
    " nothing dissolves the reference again
    CREATE DATA mo_app->mr_alias_tab LIKE mo_app->mt_std.
    ASSIGN mo_app->mr_alias_tab->* TO <tab>.
    ls_row-col1 = `late`.
    ls_row-col2 = 7.
    INSERT ls_row INTO TABLE <tab>.

    " the draft read into a new instance carries the table
    roundtrip( ).
    cl_abap_unit_assert=>assert_bound( act = mo_app->mr_alias_tab
                                       msg = `the table was lost from the draft` ).
    ASSIGN mo_app->mr_alias_tab->* TO <tab>.

    CLEAR temp455.

    temp456-col1 = `late`.
    temp456-col2 = 7.
    INSERT temp456 INTO TABLE temp455.
    lt_exp = temp455.
    cl_abap_unit_assert=>assert_equals( exp = lt_exp
                                        act = <tab> ).

  ENDMETHOD.

  METHOD alias_repointed_survives.

    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <row> TYPE any.
    DATA ls_sel TYPE ltcl_app_shapes=>ty_s_row_sel.
    DATA lr_own TYPE REF TO data.
    DATA temp457 TYPE REF TO cl_abap_tabledescr.
    DATA lo_tab LIKE temp457.
    DATA lr_alias TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.
    DATA lr_own_row TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.
    DATA lv_changed TYPE string.
    DATA temp65 TYPE xsdboolean.
    DATA lr_own_tab LIKE REF TO mo_app->mo_inner->mt_own.
    DATA temp66 TYPE xsdboolean.
    DATA temp67 TYPE xsdboolean.
    DATA temp68 TYPE xsdboolean.

    " roundtrip 1: the alias into mt_std, the shared trio, as the fixture
    " has them
    bind_all( ).
    mo_model->main_attri_db_save_srtti( ).
    mo_model->main_attri_reattach( ).
    cl_abap_unit_assert=>assert_equals( exp = `MT_STD`
                                        act = row( `MR_ALIAS_TAB->*` )-name_ref ).

    " main( ) of roundtrip 2: the alias points INTO the helper's table now,
    " the first of the shared references at a table of its own
    GET REFERENCE OF mo_app->mo_inner->mt_own INTO mo_app->mr_alias_tab.

    temp457 ?= z2ui5_cl_ui5_util_context=>rtti_get_typedescr_by_data_ref( mo_app->mr_shared_b ).

    lo_tab = temp457.
    CREATE DATA lr_own TYPE HANDLE lo_tab.
    ASSIGN lr_own->* TO <tab>.
    ls_sel-col1 = `own`.
    INSERT INITIAL LINE INTO TABLE <tab> ASSIGNING <row>.
    MOVE-CORRESPONDING ls_sel TO <row>.
    mo_app->mr_shared_a = lr_own.

    " the render: the alias binds as its NEW owner, the parted reference
    " as a row of its own

    lr_alias = bind( mo_app->mr_alias_tab ).
    cl_abap_unit_assert=>assert_equals( exp = `MO_INNER->MT_OWN`
                                        act = lr_alias->name ).

    lr_own_row = bind( mo_app->mr_shared_a ).
    cl_abap_unit_assert=>assert_equals( exp = `MR_SHARED_A->*`
                                        act = lr_own_row->name ).

    lv_changed = mo_model->main_json_stringify( ).

    temp65 = boolc( lv_changed CS `"own"` ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp65 ).

    " the save: the rows say what the references say now - the typed table
    " stays the owner, the reference the alias; the parted one carries a
    " payload of its own
    mo_model->main_attri_db_save_srtti( ).
    cl_abap_unit_assert=>assert_equals( exp = `MO_INNER->MT_OWN`
                                        act = row( `MR_ALIAS_TAB->*` )-name_ref ).
    cl_abap_unit_assert=>assert_initial( row( `MO_INNER->MT_OWN` )-name_ref ).
    cl_abap_unit_assert=>assert_initial( row( `MR_SHARED_A->*` )-name_ref ).
    cl_abap_unit_assert=>assert_not_initial( row( `MR_SHARED_A` )-srtti_data ).
    cl_abap_unit_assert=>assert_not_initial( row( `MR_SHARED_B` )-srtti_data ).
    mo_model->main_attri_reattach( ).

    " ...and the draft read into a new instance follows the new targets
    roundtrip( ).

    GET REFERENCE OF mo_app->mo_inner->mt_own INTO lr_own_tab.

    temp66 = boolc( mo_app->mr_alias_tab = lr_own_tab ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp66
                                      msg = `the restore pointed the alias at its old owner` ).
    cl_abap_unit_assert=>assert_bound( mo_app->mr_shared_a ).
    ASSIGN mo_app->mr_shared_a->* TO <tab>.
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( <tab> ) ).

    temp67 = boolc( mo_app->mr_shared_a = mo_app->mr_shared_b ).
    cl_abap_unit_assert=>assert_equals( exp = abap_false act = temp67 ).

    temp68 = boolc( mo_app->mr_shared_b = mo_app->mo_inner->mr_shared ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp68 ).
    inv_search_finds_bound( ).
    inv_json_unchanged( lv_changed ).
    inv_srtti_cleared( ).

  ENDMETHOD.

  METHOD legacy_draft_no_type_name.
    DATA lv_before TYPE string.

    bind_all( ).

    lv_before = mo_model->main_json_stringify( ).

    " the asXML of the attribute table without its TYPE_NAME elements: what
    " a draft in the table looks like across the upgrade
    roundtrip( iv_legacy = abap_true ).
    cl_abap_unit_assert=>assert_initial( act = row( `MV_STRING` )-type_name
                                         msg = `the fixture still carries type names - nothing is proven` ).
    cl_abap_unit_assert=>assert_initial( row( `MR_HANDLE_TAB->*` )-type_name ).
    " the one kind of row the load resolves anyway - a payload row - gets
    " its name on the way
    cl_abap_unit_assert=>assert_not_initial( row( `MR_HANDLE_TAB` )-type_name ).

    " everything but the type invariant holds: the data is back, the search
    " finds every bound row without the prefilter, the model is the same
    inv_rows_reachable( ).
    inv_identity_shared( ).
    inv_search_finds_bound( ).
    inv_json_unchanged( lv_before ).
    inv_srtti_cleared( ).

    " the next draft of that instance: the same, the names still missing
    " on the rows nothing re-created - a refresh is what writes them
    roundtrip( ).
    inv_rows_reachable( ).
    inv_identity_shared( ).
    inv_search_finds_bound( ).
    inv_json_unchanged( lv_before ).
    inv_srtti_cleared( ).
    cl_abap_unit_assert=>assert_initial( row( `MV_STRING` )-type_name ).
    mo_model->main_attri_refresh( ).
    inv_all( lv_before ).

  ENDMETHOD.

  METHOD live_recreated_same_type.

    FIELD-SYMBOLS <tab>  TYPE STANDARD TABLE.
    FIELD-SYMBOLS <row>  TYPE any.
    FIELD-SYMBOLS <elem> TYPE any.
    DATA ls_sel TYPE ltcl_app_shapes=>ty_s_row_sel.
    DATA lr_new TYPE REF TO data.
    DATA temp458 TYPE REF TO cl_abap_tabledescr.
    DATA lo_tab LIKE temp458.
    DATA lr_shared TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.
    DATA lr_elem TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.
    DATA lv_changed TYPE string.
    DATA temp69 TYPE xsdboolean.
    DATA temp70 TYPE xsdboolean.
    DATA temp71 TYPE xsdboolean.
    DATA lr_elem_2 LIKE mo_app->mr_elem.
    DATA temp72 TYPE xsdboolean.
    DATA temp73 TYPE xsdboolean.

    " roundtrip 1 on the live instance
    bind_all( ).
    mo_model->main_attri_db_save_srtti( ).
    mo_model->main_attri_db_load( ).

    " main( ) of roundtrip 2: the three references to the shared table are
    " pointed at a NEW table of the same line type, the elementary
    " reference is created again - no draft was read, the rows stay

    temp458 ?= z2ui5_cl_ui5_util_context=>rtti_get_typedescr_by_data_ref( mo_app->mr_shared_a ).

    lo_tab = temp458.
    CREATE DATA lr_new TYPE HANDLE lo_tab.
    ASSIGN lr_new->* TO <tab>.
    ls_sel-col1 = `re-created`.
    INSERT INITIAL LINE INTO TABLE <tab> ASSIGNING <row>.
    MOVE-CORRESPONDING ls_sel TO <row>.
    mo_app->mr_shared_a = lr_new.
    mo_app->mr_shared_b = lr_new.
    mo_app->mo_inner->mr_shared = lr_new.
    CREATE DATA mo_app->mr_elem TYPE string.
    ASSIGN mo_app->mr_elem->* TO <elem>.
    <elem> = `elem-2`.

    " the render binds them again: the canonical row and the deref row as
    " before, resolved against the new objects

    lr_shared = bind( mo_app->mo_inner->mr_shared ).
    cl_abap_unit_assert=>assert_equals( exp = `MR_SHARED_B->*`
                                        act = lr_shared->name ).

    lr_elem = bind( mo_app->mr_elem ).
    cl_abap_unit_assert=>assert_equals( exp = `MR_ELEM->*`
                                        act = lr_elem->name ).

    lv_changed = mo_model->main_json_stringify( ).

    temp69 = boolc( lv_changed CS `"re-created"` ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp69 ).

    temp70 = boolc( lv_changed CS `"elem-2"` ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp70 ).

    temp71 = boolc( lv_changed CS `"shared"` ).
    cl_abap_unit_assert=>assert_equals( exp = abap_false act = temp71 ).

    " the draft of roundtrip 2, restored in place: the new data, the three
    " references one object again - and, with the save handing the same
    " objects back, the very object main( ) created

    lr_elem_2 = mo_app->mr_elem.
    mo_model->main_attri_db_save_srtti( ).
    mo_model->main_attri_reattach( ).
    inv_all( lv_changed ).

    temp72 = boolc( mo_app->mr_shared_a = lr_new ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp72 ).

    temp73 = boolc( mo_app->mr_elem = lr_elem_2 ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp73 ).
    ASSIGN mo_app->mr_shared_a->* TO <tab>.
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( <tab> ) ).
    ASSIGN mo_app->mr_elem->* TO <elem>.
    cl_abap_unit_assert=>assert_equals( exp = `elem-2`
                                        act = <elem> ).

    " ...and read into a new instance
    roundtrip( ).
    inv_all( lv_changed ).
    ASSIGN mo_app->mr_shared_a->* TO <tab>.
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( <tab> ) ).

  ENDMETHOD.

  METHOD live_recreated_other_type.

    FIELD-SYMBOLS <elem> TYPE any.
    DATA lr_attri TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.
    DATA lv_changed TYPE string.
    DATA temp74 TYPE xsdboolean.

    bind_all( ).
    mo_model->main_attri_db_save_srtti( ).
    mo_model->main_attri_db_load( ).

    " main( ) of roundtrip 2: the elementary reference is created again
    " with ANOTHER type - the row MR_ELEM->* still describes a string
    CREATE DATA mo_app->mr_elem TYPE i.
    ASSIGN mo_app->mr_elem->* TO <elem>.
    <elem> = 7.

    " the render binds it: the row, not a dump on the stale description,
    " described as what it is now, the binding it carried kept

    lr_attri = bind( mo_app->mr_elem ).
    cl_abap_unit_assert=>assert_equals( exp = `MR_ELEM->*`
                                        act = lr_attri->name ).
    cl_abap_unit_assert=>assert_equals( exp = cl_abap_typedescr=>typekind_int
                                        act = lr_attri->type_kind ).

    lv_changed = mo_model->main_json_stringify( ).

    temp74 = boolc( lv_changed CS `"MR_ELEM_D":7` ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp74 ).

    " the draft of that roundtrip brings the integer back, as an integer
    mo_model->main_attri_db_save_srtti( ).
    mo_model->main_attri_db_load( ).
    inv_all( lv_changed ).
    ASSIGN mo_app->mr_elem->* TO <elem>.
    cl_abap_unit_assert=>assert_equals( exp = 7
                                        act = <elem> ).
    cl_abap_unit_assert=>assert_equals( exp = cl_abap_typedescr=>typekind_int
                                        act = z2ui5_cl_ui5_util_context=>rtti_get_type_kind( <elem> ) ).

    roundtrip( ).
    inv_all( lv_changed ).
    ASSIGN mo_app->mr_elem->* TO <elem>.
    cl_abap_unit_assert=>assert_equals( exp = 7
                                        act = <elem> ).

  ENDMETHOD.

  METHOD save_without_main_is_noop.
    DATA lv_before TYPE string.
    DATA lv_payloads_1 TYPE i.
    DATA lt_rows TYPE z2ui5_if_ui5_types=>ty_t_attri.
    DATA lv_payloads_2 TYPE i.
    DATA temp75 TYPE xsdboolean.
    DATA temp459 LIKE LINE OF lt_rows.
    DATA lr_old LIKE REF TO temp459.
      DATA lr_now TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.

    bind_all( ).

    lv_before = mo_model->main_json_stringify( ).

    mo_model->main_attri_db_save_srtti( ).

    lv_payloads_1 = 0.
    LOOP AT mr_attri->* TRANSPORTING NO FIELDS WHERE srtti_data IS NOT INITIAL. "#EC CI_SORTSEQ
      lv_payloads_1 = lv_payloads_1 + 1.
    ENDLOOP.
    mo_model->main_attri_db_load( ).

    lt_rows = mr_attri->*.

    " a second save right away - nothing ran on the app in between
    mo_model->main_attri_db_save_srtti( ).

    lv_payloads_2 = 0.
    LOOP AT mr_attri->* TRANSPORTING NO FIELDS WHERE srtti_data IS NOT INITIAL. "#EC CI_SORTSEQ
      lv_payloads_2 = lv_payloads_2 + 1.
    ENDLOOP.
    mo_model->main_attri_db_load( ).

    " the same payloads, the same rows: names, owners, bindings, client
    " names, kinds - and the same model and data behind them

    temp75 = boolc( lv_payloads_1 > 0 ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp75 ).
    cl_abap_unit_assert=>assert_equals( exp = lv_payloads_1
                                        act = lv_payloads_2 ).
    cl_abap_unit_assert=>assert_equals( exp = lines( lt_rows )
                                        act = lines( mr_attri->* ) ).


    LOOP AT lt_rows REFERENCE INTO lr_old.

      lr_now = row_ref( lr_old->name ).
      cl_abap_unit_assert=>assert_equals( exp = lr_old->name_ref
                                          act = lr_now->name_ref
                                          msg = |name_ref of { lr_old->name } changed| ).
      cl_abap_unit_assert=>assert_equals( exp = lr_old->name_parent
                                          act = lr_now->name_parent ).
      cl_abap_unit_assert=>assert_equals( exp = lr_old->bind
                                          act = lr_now->bind ).
      cl_abap_unit_assert=>assert_equals( exp = lr_old->name_client
                                          act = lr_now->name_client ).
      cl_abap_unit_assert=>assert_equals( exp = lr_old->type_kind
                                          act = lr_now->type_kind ).
    ENDLOOP.
    inv_all( lv_before ).

  ENDMETHOD.

  METHOD late_alias_survives_save.
    DATA lo_late TYPE REF TO ltcl_shp_inner.
    DATA temp460 LIKE REF TO lo_late->mv_inner.
DATA lr_value TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.
    DATA lr_table TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.
    DATA lv_changed TYPE string.
    DATA temp76 TYPE xsdboolean.
    DATA lr_std LIKE REF TO mo_app->mt_std.
    DATA temp77 TYPE xsdboolean.
    DATA temp78 TYPE xsdboolean.

    bind_all( ).
    mo_model->main_attri_db_save_srtti( ).
    mo_model->main_attri_db_load( ).

    " main( ): the chain grows by one helper that points INTO the app -
    " created after the rows were dissolved, so no row knows it yet

    CREATE OBJECT lo_late TYPE ltcl_shp_inner.
    lo_late->mv_inner  = `late`.
    GET REFERENCE OF mo_app->mt_std INTO lo_late->mr_shared.
    mo_app->mo_inner->mo_deeper->mo_deeper = lo_late.

    " the render binds the helper's value and the table through its
    " reference: the value as its own row, the table as the OWNER's

    GET REFERENCE OF lo_late->mv_inner INTO temp460.

lr_value = bind( temp460 ).
    cl_abap_unit_assert=>assert_equals( exp = `MO_INNER->MO_DEEPER->MO_DEEPER->MV_INNER`
                                        act = lr_value->name ).

    lr_table = mo_model->main_attri_search( lo_late->mr_shared ).
    cl_abap_unit_assert=>assert_equals( exp = `MT_STD`
                                        act = lr_table->name ).
    cl_abap_unit_assert=>assert_equals( exp = `MT_STD`
                                        act = row( `MO_INNER->MO_DEEPER->MO_DEEPER->MR_SHARED->*` )-name_ref ).

    lv_changed = mo_model->main_json_stringify( ).

    temp76 = boolc( lv_changed CS `"late"` ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp76 ).

    " the save keeps the alias an alias: restored in place and from a new
    " instance it points INTO mt_std again, not at a copy
    mo_model->main_attri_db_save_srtti( ).
    mo_model->main_attri_db_load( ).
    inv_all( lv_changed ).

    GET REFERENCE OF mo_app->mt_std INTO lr_std.

    temp77 = boolc( mo_app->mo_inner->mo_deeper->mo_deeper->mr_shared = lr_std ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp77 ).

    roundtrip( ).
    inv_all( lv_changed ).
    GET REFERENCE OF mo_app->mt_std INTO lr_std.

    temp78 = boolc( mo_app->mo_inner->mo_deeper->mo_deeper->mr_shared = lr_std ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp78 ).
    cl_abap_unit_assert=>assert_equals( exp = `late`
                                        act = mo_app->mo_inner->mo_deeper->mo_deeper->mv_inner ).

  ENDMETHOD.
ENDCLASS.


" ---------------------------------------------------------------------------
" 06 - a generic reference at a structure that carries a table component. On
" its own fixture: the shared one above has struct aliases of flat structures
" only, and this shape is about what the restore does with the rows BELOW the
" alias - `<alias>->t_items` carries `<owner>-t_items` as name_ref for the
" binding search, and the restore used to follow it and re-point the alias at
" the table component of its own target (2026-09-05)
" ---------------------------------------------------------------------------
CLASS ltcl_app_struct_alias DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    TYPES:
      BEGIN OF ty_s_row,
        col1 TYPE string,
        col2 TYPE i,
      END OF ty_s_row.
    TYPES ty_t_row TYPE STANDARD TABLE OF ty_s_row WITH DEFAULT KEY.
    TYPES:
      BEGIN OF ty_s_nested,
        id      TYPE string,
        t_items TYPE ty_t_row,
      END OF ty_s_nested.

    DATA ms_nested TYPE ty_s_nested.
    DATA mr_alias  TYPE REF TO data.

    METHODS fill.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS ltcl_app_struct_alias IMPLEMENTATION.

  METHOD z2ui5_if_app~main ##NEEDED.
  ENDMETHOD.

  METHOD fill.
    DATA temp461 TYPE ltcl_app_struct_alias=>ty_t_row.
    DATA temp462 LIKE LINE OF temp461.
    ms_nested-id      = `n1`.

    CLEAR temp461.

    temp462-col1 = `a`.
    temp462-col2 = 1.
    INSERT temp462 INTO TABLE temp461.
    ms_nested-t_items = temp461.
    GET REFERENCE OF ms_nested INTO mr_alias.
  ENDMETHOD.

ENDCLASS.


CLASS ltcl_06_struct_alias DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION MEDIUM.

  PRIVATE SECTION.
    METHODS alias_stays_on_struct FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_06_struct_alias IMPLEMENTATION.

  METHOD alias_stays_on_struct.

    FIELD-SYMBOLS <struc> TYPE any.
    FIELD-SYMBOLS <tab>   TYPE any.
    DATA lo_app   TYPE REF TO ltcl_app_struct_alias.
    DATA lr_attri TYPE REF TO z2ui5_if_ui5_types=>ty_t_attri.
    DATA lo_model TYPE REF TO z2ui5_cl_ui5_srv_model.
    DATA temp463 TYPE REF TO data.
DATA lr_row TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.
    DATA lv_app_xml TYPE string.
    DATA lv_attri_xml TYPE string.
    DATA lo_descr TYPE REF TO cl_abap_typedescr.
    DATA lr_struc LIKE REF TO lo_app->ms_nested.
    DATA temp79 TYPE xsdboolean.

    CREATE OBJECT lo_app.
    lo_app->fill( ).
    CREATE DATA lr_attri.

    CREATE OBJECT lo_model TYPE z2ui5_cl_ui5_srv_model EXPORTING attri = lr_attri app = lo_app.

    " the table bound through the alias, as _bind( mr_alias->t_items ) does
    ASSIGN lo_app->mr_alias->* TO <struc>.
    ASSIGN COMPONENT `T_ITEMS` OF STRUCTURE <struc> TO <tab>.
    cl_abap_unit_assert=>assert_subrc( ).

GET REFERENCE OF <tab> INTO temp463.

lr_row = lo_model->main_attri_search( temp463 ).
    lr_row->bind        = abap_true.
    lr_row->name_client = `/T_ITEMS`.

    " the draft roundtrip as the container runs it
    lo_model->main_attri_db_save_srtti( ).

    lv_app_xml   = z2ui5_cl_ui5_util_context=>xml_stringify( lo_app ).

    lv_attri_xml = z2ui5_cl_ui5_util_context=>xml_stringify( lr_attri->* ).
    CLEAR lo_app.
    z2ui5_cl_ui5_util_context=>xml_parse( EXPORTING xml = lv_app_xml
                                          IMPORTING any = lo_app ).
    CREATE DATA lr_attri.
    z2ui5_cl_ui5_util_context=>xml_parse( EXPORTING xml = lv_attri_xml
                                          IMPORTING any = lr_attri->* ).
    CREATE OBJECT lo_model EXPORTING attri = lr_attri app = lo_app.
    lo_model->main_attri_db_load( ).

    " the alias points at the STRUCTURE again, not at its table component
    cl_abap_unit_assert=>assert_bound( act = lo_app->mr_alias
                                       msg = `alias lost across the draft` ).

    lo_descr = z2ui5_cl_ui5_util_context=>rtti_get_typedescr_by_data_ref( lo_app->mr_alias ).
    cl_abap_unit_assert=>assert_equals( exp = cl_abap_typedescr=>kind_struct
                                        act = lo_descr->kind
                                        msg = |alias re-pointed - it derefs to kind { lo_descr->kind } ({ lo_descr->absolute_name })| ).

    GET REFERENCE OF lo_app->ms_nested INTO lr_struc.

    temp79 = boolc( lo_app->mr_alias = lr_struc ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp79
                                      msg = `alias no longer points at ms_nested` ).
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( lo_app->ms_nested-t_items ) ).

  ENDMETHOD.

ENDCLASS.


" a REFERENCE component below a struct alias: mr_alias points at ms_nested,
" which holds r_val. The row `MR_ALIAS->R_VAL` inherits `MS_NESTED-R_VAL` as
" name_ref for the binding search, and the restore followed it like an alias
" of its own - once mr_alias was re-pointed at ms_nested, both paths named
" the same variable and r_val came back pointing at itself (2026-10-07)
" ---------------------------------------------------------------------------
CLASS ltcl_app_alias_dref DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    TYPES:
      BEGIN OF ty_s_nested,
        id    TYPE string,
        r_val TYPE REF TO data,
      END OF ty_s_nested.

    DATA ms_nested TYPE ty_s_nested.
    DATA mr_alias  TYPE REF TO data.

    METHODS fill.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS ltcl_app_alias_dref IMPLEMENTATION.

  METHOD z2ui5_if_app~main ##NEEDED.
  ENDMETHOD.

  METHOD fill.
    FIELD-SYMBOLS <lv_val> TYPE string.
    ms_nested-id = `n1`.
    CREATE DATA ms_nested-r_val TYPE string.
    ASSIGN ms_nested-r_val->* TO <lv_val>.
    <lv_val> = `payload`.
    GET REFERENCE OF ms_nested INTO mr_alias.
  ENDMETHOD.

ENDCLASS.


CLASS ltcl_07_alias_dref DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS dref_below_alias_kept FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_07_alias_dref IMPLEMENTATION.

  METHOD dref_below_alias_kept.

    FIELD-SYMBOLS <lv_val> TYPE string.
    DATA lo_app   TYPE REF TO ltcl_app_alias_dref.
    DATA lr_attri TYPE REF TO z2ui5_if_ui5_types=>ty_t_attri.
    DATA lo_model TYPE REF TO z2ui5_cl_ui5_srv_model.
    DATA lv_app_xml TYPE string.
    DATA lv_attri_xml TYPE string.
    DATA lr_self LIKE REF TO lo_app->ms_nested-r_val.
    DATA temp80 TYPE xsdboolean.
    DATA lr_struc LIKE REF TO lo_app->ms_nested.
    DATA temp81 TYPE xsdboolean.

    CREATE OBJECT lo_app.
    lo_app->fill( ).
    CREATE DATA lr_attri.

    CREATE OBJECT lo_model TYPE z2ui5_cl_ui5_srv_model EXPORTING attri = lr_attri app = lo_app.

    " the first save of an app that bound nothing yet - the save's own
    " dissolve creates the rows, so the inherited name_ref is still there
    lo_model->main_attri_db_save_srtti( ).

    lv_app_xml   = z2ui5_cl_ui5_util_context=>xml_stringify( lo_app ).

    lv_attri_xml = z2ui5_cl_ui5_util_context=>xml_stringify( lr_attri->* ).
    CLEAR lo_app.
    z2ui5_cl_ui5_util_context=>xml_parse( EXPORTING xml = lv_app_xml
                                          IMPORTING any = lo_app ).
    CREATE DATA lr_attri.
    z2ui5_cl_ui5_util_context=>xml_parse( EXPORTING xml = lv_attri_xml
                                          IMPORTING any = lr_attri->* ).
    CREATE OBJECT lo_model EXPORTING attri = lr_attri app = lo_app.
    lo_model->main_attri_db_load( ).


    GET REFERENCE OF lo_app->ms_nested-r_val INTO lr_self.
    cl_abap_unit_assert=>assert_bound( act = lo_app->ms_nested-r_val
                                       msg = `r_val lost across the draft` ).

    temp80 = boolc( lo_app->ms_nested-r_val = lr_self ).
    cl_abap_unit_assert=>assert_equals( exp = abap_false act = temp80
                                       msg = `r_val points at itself` ).
    ASSIGN lo_app->ms_nested-r_val->* TO <lv_val>.
    cl_abap_unit_assert=>assert_subrc( ).
    cl_abap_unit_assert=>assert_equals( exp = `payload`
                                        act = <lv_val> ).

    GET REFERENCE OF lo_app->ms_nested INTO lr_struc.

    temp81 = boolc( lo_app->mr_alias = lr_struc ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp81
                                      msg = `alias no longer points at ms_nested` ).

  ENDMETHOD.

ENDCLASS.


" the two-hop alias chain: two generic references at ONE typed table whose
" name sorts BEFORE them (ma_tab < mr_a < mr_b). The pairing used to name the
" last candidate, so MR_A->* aliased MR_B->* instead of the table, and the
" fresh-instance load resolved MR_A while MR_B was still initial (2026-09-05)
" ---------------------------------------------------------------------------
CLASS ltcl_app_two_refs DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    TYPES:
      BEGIN OF ty_s_row,
        col1 TYPE string,
      END OF ty_s_row.
    TYPES ty_t_row TYPE STANDARD TABLE OF ty_s_row WITH DEFAULT KEY.

    DATA ma_tab TYPE ty_t_row.
    DATA mr_a   TYPE REF TO data.
    DATA mr_b   TYPE REF TO data.

    METHODS fill.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS ltcl_app_two_refs IMPLEMENTATION.

  METHOD z2ui5_if_app~main ##NEEDED.
  ENDMETHOD.

  METHOD fill.
    DATA temp464 TYPE ltcl_app_two_refs=>ty_t_row.
    DATA temp465 LIKE LINE OF temp464.
    CLEAR temp464.

    temp465-col1 = `a`.
    INSERT temp465 INTO TABLE temp464.
    ma_tab = temp464.
    GET REFERENCE OF ma_tab INTO mr_a.
    GET REFERENCE OF ma_tab INTO mr_b.
  ENDMETHOD.

ENDCLASS.


CLASS ltcl_06_two_refs DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION MEDIUM.

  PRIVATE SECTION.
    METHODS both_refs_back_on_table FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_06_two_refs IMPLEMENTATION.

  METHOD both_refs_back_on_table.

    FIELD-SYMBOLS <tab> TYPE any.
    DATA lo_app   TYPE REF TO ltcl_app_two_refs.
    DATA lr_attri TYPE REF TO z2ui5_if_ui5_types=>ty_t_attri.
    DATA lo_model TYPE REF TO z2ui5_cl_ui5_srv_model.
    DATA temp466 TYPE REF TO data.
DATA lr_row TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.
    DATA temp467 LIKE LINE OF lr_attri->*.
    DATA lr_alias LIKE REF TO temp467.
    DATA lv_app_xml TYPE string.
    DATA lv_attri_xml TYPE string.
    DATA lr_tab LIKE REF TO lo_app->ma_tab.
    DATA temp82 TYPE xsdboolean.
    DATA temp83 TYPE xsdboolean.

    CREATE OBJECT lo_app.
    lo_app->fill( ).
    CREATE DATA lr_attri.

    CREATE OBJECT lo_model TYPE z2ui5_cl_ui5_srv_model EXPORTING attri = lr_attri app = lo_app.

    " the table bound through the FIRST reference, as _bind( mr_a->* ) does
    ASSIGN lo_app->mr_a->* TO <tab>.

GET REFERENCE OF <tab> INTO temp466.

lr_row = lo_model->main_attri_search( temp466 ).
    lr_row->bind        = abap_true.
    lr_row->name_client = `/MA_TAB`.

    " every alias names the typed owner, none names the other reference
    lo_model->main_attri_db_save_srtti( ).


    LOOP AT lr_attri->* REFERENCE INTO lr_alias "#EC CI_SORTSEQ
         WHERE name_ref IS NOT INITIAL.
      cl_abap_unit_assert=>assert_equals( exp = `MA_TAB`
                                          act = lr_alias->name_ref
                                          msg = |{ lr_alias->name } names { lr_alias->name_ref }| ).
    ENDLOOP.

    " the draft roundtrip as the container runs it

    lv_app_xml   = z2ui5_cl_ui5_util_context=>xml_stringify( lo_app ).

    lv_attri_xml = z2ui5_cl_ui5_util_context=>xml_stringify( lr_attri->* ).
    CLEAR lo_app.
    z2ui5_cl_ui5_util_context=>xml_parse( EXPORTING xml = lv_app_xml
                                          IMPORTING any = lo_app ).
    CREATE DATA lr_attri.
    z2ui5_cl_ui5_util_context=>xml_parse( EXPORTING xml = lv_attri_xml
                                          IMPORTING any = lr_attri->* ).
    CREATE OBJECT lo_model EXPORTING attri = lr_attri app = lo_app.
    lo_model->main_attri_db_load( ).


    GET REFERENCE OF lo_app->ma_tab INTO lr_tab.
    cl_abap_unit_assert=>assert_bound( act = lo_app->mr_a
                                       msg = `mr_a lost across the draft` ).

    temp82 = boolc( lo_app->mr_a = lr_tab ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp82
                                      msg = `mr_a no longer points at ma_tab` ).
    cl_abap_unit_assert=>assert_bound( act = lo_app->mr_b
                                       msg = `mr_b lost across the draft` ).

    temp83 = boolc( lo_app->mr_b = lr_tab ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp83
                                      msg = `mr_b no longer points at ma_tab` ).

  ENDMETHOD.

ENDCLASS.


" ---------------------------------------------------------------------------
" Sample 500a: the host app that renders ANOTHER app INTO ITS OWN VIEW. It
" builds a page, keeps the builder node in an attribute, creates the sub-app
" by NAME (CREATE OBJECT mo_app TYPE (class)) into a REF TO object, writes the
" page into the sub-app's MO_PARENT_PAGE by dynamic ASSIGN and calls the
" sub-app's main( ) with ITS OWN client. So the sub-app binds through the
" host's model, the host's draft is what gets saved, and two things the host
" holds are framework objects rather than data.
"
" It was the last of the "main app calling subapps" scaffolds in samples
" (src/00/98, cleared 2026-09-22) and the only one left in src/01; what it
" asserted by hand in a browser is asserted here.
"
" The shape nothing else in this file has: a LIVE z2ui5_cl_ui5_view_builder in
" a PUBLIC attribute of an app. diss_oref skips exactly one class by name -
" z2ui5_cl_ui5_client, after the start page put 300 rows of the roundtrip
" graph into its own draft - and the builder is not that class. What keeps it
" harmless is that the builder's own state is PROTECTED, so the public-only
" walk finds nothing behind it. That is a property of the builder, not of the
" walk, which is why it is pinned here: a public attribute added to the
" builder would put the whole view tree into every host app's model, and no
" test of the builder would notice.
" ---------------------------------------------------------------------------

CLASS ltcl_app_sub_view DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    TYPES:
      BEGIN OF ty_s_row,
        carrid TYPE string,
      END OF ty_s_row.
    TYPES ty_t_row TYPE STANDARD TABLE OF ty_s_row WITH DEFAULT KEY.

    " the page the host hands over - a live framework object in a PUBLIC
    " attribute of an app, which is the shape under test
    DATA mo_parent_page TYPE REF TO z2ui5_cl_ui5_view_builder.
    DATA mt_table       TYPE ty_t_row.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS ltcl_app_sub_view IMPLEMENTATION.

  METHOD z2ui5_if_app~main ##NEEDED.
  ENDMETHOD.

ENDCLASS.


CLASS ltcl_app_view_host DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    DATA mv_selectedkey TYPE string.
    " the node of the host's own view tree, kept between the two halves of
    " the roundtrip - the attribute 500a calls MO_MAIN_PAGE
    DATA mo_main_page   TYPE REF TO z2ui5_cl_ui5_view_builder.
    " the sub-app, created by name: REF TO object, not REF TO its class
    DATA mo_app         TYPE REF TO object.

    METHODS render.
    METHODS create_sub_app.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS ltcl_app_view_host IMPLEMENTATION.

  METHOD z2ui5_if_app~main ##NEEDED.
  ENDMETHOD.

  METHOD render.

    mo_main_page = z2ui5_cl_ui5_view_builder=>factory(
        )->ele( n  = `View`
                ns = `mvc`
            )->a( n = `xmlns`
                  v = `sap.m`
            )->a( n = `xmlns:mvc`
                  v = `sap.ui.core.mvc`

            )->ele( `Page`
                )->a( n = `title`
                      v = `Main App calling Subapps` ).

  ENDMETHOD.

  METHOD create_sub_app.

    " what render_sub_app( ) does on every tab switch, and it does it AFTER
    " the host has already bound its own attribute
    DATA lo_sub TYPE REF TO ltcl_app_sub_view.
    DATA temp468 TYPE ltcl_app_sub_view=>ty_t_row.
    DATA temp469 LIKE LINE OF temp468.
    CREATE OBJECT lo_sub TYPE ltcl_app_sub_view.

    CLEAR temp468.

    temp469-carrid = `LH`.
    INSERT temp469 INTO TABLE temp468.
    temp469-carrid = `UA`.
    INSERT temp469 INTO TABLE temp468.
    lo_sub->mt_table       = temp468.
    lo_sub->mo_parent_page = mo_main_page.
    mo_app                 = lo_sub.

  ENDMETHOD.

ENDCLASS.


CLASS ltcl_07_view_host DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION MEDIUM.

  PRIVATE SECTION.
    DATA mo_host  TYPE REF TO ltcl_app_view_host.
    DATA mr_attri TYPE REF TO z2ui5_if_ui5_types=>ty_t_attri.
    DATA mo_model TYPE REF TO z2ui5_cl_ui5_srv_model.

    METHODS setup.

    "! the sub-app behind a REF TO object - a second app class - binds its own
    "! table through the HOST's model, under the host's attribute
    METHODS subapp_binds_under_host   FOR TESTING RAISING cx_static_check.
    "! the sub-app is created during the render, after the host bound its own
    "! attribute: a refresh has to find it (500a's render_sub_app order)
    METHODS subapp_created_late_found FOR TESTING RAISING cx_static_check.
    "! the live view builder the host holds PUBLIC contributes no bindable row
    METHODS builder_carries_no_rows   FOR TESTING RAISING cx_static_check.
    "! ...and does not reach the model either, however deep its tree is
    METHODS builder_tree_not_walked   FOR TESTING RAISING cx_static_check.
    "! the draft: the builder is gone, the sub-app and its data are back
    METHODS host_survives_roundtrip   FOR TESTING RAISING cx_static_check.

    "! the rows the walk produced, by name
    METHODS row_exists
      IMPORTING iv_name       TYPE string
      RETURNING VALUE(result) TYPE abap_bool.
    "! how many rows start with the given prefix
    METHODS rows_under
      IMPORTING iv_prefix     TYPE string
      RETURNING VALUE(result) TYPE i.
ENDCLASS.


CLASS ltcl_07_view_host IMPLEMENTATION.

  METHOD setup.

    CREATE OBJECT mo_host.
    mo_host->mv_selectedkey = `1`.
    mo_host->render( ).
    CREATE DATA mr_attri.
    CREATE OBJECT mo_model EXPORTING attri = mr_attri app = mo_host.

  ENDMETHOD.

  METHOD row_exists.

    DATA temp470 LIKE sy-subrc.
    DATA temp84 TYPE xsdboolean.
    READ TABLE mr_attri->* WITH KEY name = iv_name TRANSPORTING NO FIELDS.
    temp470 = sy-subrc.

    temp84 = boolc( temp470 = 0 ).
    result = temp84.

  ENDMETHOD.

  METHOD rows_under.

    LOOP AT mr_attri->* TRANSPORTING NO FIELDS "#EC CI_SORTSEQ
         WHERE name CP |{ iv_prefix }*|.
      result = result + 1.
    ENDLOOP.

  ENDMETHOD.

  METHOD subapp_binds_under_host.
    DATA temp471 TYPE REF TO ltcl_app_sub_view.
    DATA lo_sub LIKE temp471.
    DATA temp472 LIKE REF TO lo_sub->mt_table.
DATA lr_row TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.
    DATA lv_json TYPE string.
    DATA temp85 TYPE xsdboolean.
    DATA temp473 TYPE REF TO z2ui5_if_ui5_ajs.
    DATA lo_front LIKE temp473.
    FIELD-SYMBOLS <temp474> LIKE LINE OF lo_sub->mt_table.
    DATA temp475 LIKE sy-tabix.

    mo_host->create_sub_app( ).
    mo_model->main_attri_refresh( ).

    " the row is the HOST's - the sub-app is reached through MO_APP, so that
    " is the name the draft saves and the model writes back into

    temp471 ?= mo_host->mo_app.

    lo_sub = temp471.

    GET REFERENCE OF lo_sub->mt_table INTO temp472.

lr_row = mo_model->main_attri_search( temp472 ).
    cl_abap_unit_assert=>assert_equals( exp = `MO_APP->MT_TABLE`
                                        act = lr_row->name ).

    lr_row->bind        = abap_true.
    lr_row->name_client = `/MT_TABLE`.

    lv_json = mo_model->main_json_stringify( ).

    temp85 = boolc( lv_json CS `"LH"` ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp85
                                      msg = `the sub-app's rows never reached the host's model` ).

    " ...and the way back lands in the sub-app instance, not in a copy

    temp473 ?= z2ui5_cl_ui5_ajs=>parse( lv_json ).

    lo_front = temp473.
    lo_front->set( iv_path = `/MT_TABLE/1/CARRID`
                   iv_val  = `AA` ).
    mo_model->main_json_to_attri( lo_front ).


    temp475 = sy-tabix.
    READ TABLE lo_sub->mt_table INDEX 1 ASSIGNING <temp474>.
    sy-tabix = temp475.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `AA`
                                        act = <temp474>-carrid ).

  ENDMETHOD.

  METHOD subapp_created_late_found.

    " roundtrip 1: the host renders and binds its own attribute; no sub-app
    " exists yet, so nothing of it can be in the rows
    DATA temp476 LIKE REF TO mo_host->mv_selectedkey.
DATA lr_key TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.
    FIELD-SYMBOLS <temp477> LIKE LINE OF mr_attri->*.
    DATA temp478 LIKE sy-tabix.
    GET REFERENCE OF mo_host->mv_selectedkey INTO temp476.

lr_key = mo_model->main_attri_search( temp476 ).
    lr_key->bind        = abap_true.
    lr_key->name_client = `/MV_SELECTEDKEY`.
    cl_abap_unit_assert=>assert_equals( exp = abap_false act = row_exists( `MO_APP->MT_TABLE` ) ).

    " the tab switch creates it, inside the same request
    mo_host->create_sub_app( ).
    mo_model->main_attri_refresh( ).

    cl_abap_unit_assert=>assert_equals( exp = abap_true act = row_exists( `MO_APP->MT_TABLE` ) ).
    " the host's own binding is untouched by the refresh


    temp478 = sy-tabix.
    READ TABLE mr_attri->* WITH KEY name = `MV_SELECTEDKEY` ASSIGNING <temp477>.
    sy-tabix = temp478.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = <temp477>-bind ).

  ENDMETHOD.

  METHOD builder_carries_no_rows.

    mo_model->main_attri_refresh( ).

    " the reference itself is a row - it is a public attribute of the app
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = row_exists( `MO_MAIN_PAGE` )
                                      msg = `the attribute itself is not in the rows` ).
    " and it is the ONLY one: everything the builder holds is protected, so
    " the public-only walk of diss_oref finds nothing to descend into
    cl_abap_unit_assert=>assert_equals(
        exp = 0
        act = rows_under( `MO_MAIN_PAGE->` )
        msg = `the view builder exposed state to the dissolve walk - every host app's draft now carries its view tree` ).

  ENDMETHOD.

  METHOD builder_tree_not_walked.

    " a DEEP tree, so a walk that descended would be unmistakable in the count
    DATA lo_node LIKE mo_host->mo_main_page.
    lo_node = mo_host->mo_main_page.
    DO 20 TIMES.
      lo_node = lo_node->ele( `VBox`
          )->a( n = `class`
                v = `sapUiSmallMargin` ).
    ENDDO.
    mo_host->create_sub_app( ).
    mo_model->main_attri_refresh( ).

    cl_abap_unit_assert=>assert_equals( exp = 0
                                        act = rows_under( `MO_MAIN_PAGE->` ) ).
    " the sub-app's OWN page reference is the same object and stays as quiet
    cl_abap_unit_assert=>assert_equals( exp = 0
                                        act = rows_under( `MO_APP->MO_PARENT_PAGE->` ) ).
    " what is behind the sub-app is still found - the builder is skipped, the
    " sub-app is not
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = row_exists( `MO_APP->MT_TABLE` ) ).

  ENDMETHOD.

  METHOD host_survives_roundtrip.
    DATA temp479 TYPE REF TO ltcl_app_sub_view.
    DATA lo_live LIKE temp479.
    DATA temp480 LIKE REF TO lo_live->mt_table.
DATA lr_row TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.
    DATA lv_before TYPE string.
    DATA lv_app_xml TYPE string.
    DATA lv_attri_xml TYPE string.
    DATA temp481 TYPE REF TO ltcl_app_sub_view.
    DATA lo_back LIKE temp481.

    mo_host->create_sub_app( ).

    temp479 ?= mo_host->mo_app.

    lo_live = temp479.

    GET REFERENCE OF lo_live->mt_table INTO temp480.

lr_row = mo_model->main_attri_search( temp480 ).
    lr_row->bind        = abap_true.
    lr_row->name_client = `/MT_TABLE`.

    lv_before = mo_model->main_json_stringify( ).

    " the draft as the container writes and reads it
    mo_model->main_attri_db_save_srtti( ).

    lv_app_xml   = z2ui5_cl_ui5_util_context=>xml_stringify( mo_host ).

    lv_attri_xml = z2ui5_cl_ui5_util_context=>xml_stringify( mr_attri->* ).
    CLEAR mo_host.
    z2ui5_cl_ui5_util_context=>xml_parse( EXPORTING xml = lv_app_xml
                                          IMPORTING any = mo_host ).
    CREATE DATA mr_attri.
    z2ui5_cl_ui5_util_context=>xml_parse( EXPORTING xml = lv_attri_xml
                                          IMPORTING any = mr_attri->* ).
    CREATE OBJECT mo_model EXPORTING attri = mr_attri app = mo_host.
    mo_model->main_attri_db_load( ).

    " the builder is not serializable and does not come back - and its
    " absence took nothing with it
    cl_abap_unit_assert=>assert_not_bound( act = mo_host->mo_main_page
                                           msg = `a view builder came back from a draft` ).
    " the sub-app did come back, as its own class, with its data
    cl_abap_unit_assert=>assert_bound( act = mo_host->mo_app
                                       msg = `the sub-app was lost across the draft` ).

    temp481 ?= mo_host->mo_app.

    lo_back = temp481.
    cl_abap_unit_assert=>assert_not_bound( act = lo_back->mo_parent_page
                                           msg = `the sub-app's page reference came back` ).
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( lo_back->mt_table ) ).
    cl_abap_unit_assert=>assert_equals( exp = lv_before
                                        act = mo_model->main_json_stringify( ) ).

  ENDMETHOD.

ENDCLASS.


" ---------------------------------------------------------------------------
" 06 FAST JSON - a bound table of flat rows written directly, byte for byte
" what ajson writes (attri_json_fast, json_fast_set, json_fast_splice)
" ---------------------------------------------------------------------------
CLASS ltcl_app_fast DEFINITION FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.
    TYPES:
      BEGIN OF ty_s_row,
        id    TYPE i,
        name  TYPE string,
        price TYPE p LENGTH 9 DECIMALS 2,
        ok    TYPE abap_bool,
        day   TYPE d,
      END OF ty_s_row.
    TYPES ty_t_row TYPE STANDARD TABLE OF ty_s_row WITH DEFAULT KEY.
    " a row type as a DDIC table or a reuse structure gives it: an include
    " with a suffix, and the two time stamp kinds
    TYPES BEGIN OF ty_s_log.
    TYPES id TYPE i.
    INCLUDE TYPE ty_s_row AS s_row RENAMING WITH SUFFIX _r.
    TYPES created_at TYPE timestamp.
    TYPES changed_at TYPE timestampl.
    TYPES END OF ty_s_log.
    TYPES ty_t_log TYPE STANDARD TABLE OF ty_s_log WITH DEFAULT KEY.
    DATA mt_rows  TYPE ty_t_row.
    DATA ms_head  TYPE ty_s_row.
    DATA mv_title TYPE string.
    DATA mt_log   TYPE ty_t_log.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS ltcl_app_fast IMPLEMENTATION.
  METHOD z2ui5_if_app~main.
  ENDMETHOD.
ENDCLASS.


" the edit popup of abap2UI5-addons/table-maintenance (z2ui5_cl_tm_pop), as
" it binds a row of an arbitrary DDIC table: the row and the fixed values
" per field are structures built at runtime behind REF TO data, one
" component per field - named like the field, so a table with fields of an
" industry solution or a customer namespace (MARA: /CWM/XCWMAT,
" /VSO/R_TILT_IND, ...) carries components that start with a slash - and
" every fixed-value component a table of flat rows, the fast path's form
CLASS ltcl_app_tm_pop DEFINITION FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.
    TYPES:
      BEGIN OF ty_s_fix_val,
        low   TYPE string,
        high  TYPE string,
        descr TYPE string,
      END OF ty_s_fix_val.
    TYPES ty_t_fix_val TYPE STANDARD TABLE OF ty_s_fix_val WITH DEFAULT KEY.
    DATA ms_data_row TYPE REF TO data.
    DATA ms_fixval   TYPE REF TO data.
    " the fields of the "DDIC table"
    DATA mt_field    TYPE string_table.
    METHODS build.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS ltcl_app_tm_pop IMPLEMENTATION.

  METHOD z2ui5_if_app~main.
  ENDMETHOD.

  METHOD build.

    DATA lt_comp_row TYPE cl_abap_structdescr=>component_table.
    DATA lt_comp_fix TYPE cl_abap_structdescr=>component_table.
    DATA lt_fixval   TYPE ty_t_fix_val.
    DATA lv_text     TYPE string.
    FIELD-SYMBOLS <row>    TYPE any.
    FIELD-SYMBOLS <fixval> TYPE any.
    FIELD-SYMBOLS <val>    TYPE any.
    FIELD-SYMBOLS <tab>    TYPE ty_t_fix_val.

    DATA lv_field LIKE LINE OF mt_field.
      DATA temp482 TYPE abap_componentdescr.
      DATA temp116 TYPE REF TO cl_abap_datadescr.
      DATA temp483 TYPE abap_componentdescr.
      DATA temp117 TYPE REF TO cl_abap_datadescr.
    DATA lo_row TYPE REF TO cl_abap_structdescr.
    DATA lo_fix TYPE REF TO cl_abap_structdescr.
      DATA temp484 TYPE ltcl_app_tm_pop=>ty_t_fix_val.
      DATA temp485 LIKE LINE OF temp484.
    LOOP AT mt_field INTO lv_field.

      CLEAR temp482.
      temp482-name = lv_field.

      temp116 ?= cl_abap_typedescr=>describe_by_data( lv_text ).
      temp482-type = temp116.
      INSERT temp482 INTO TABLE lt_comp_row.

      CLEAR temp483.
      temp483-name = lv_field.

      temp117 ?= cl_abap_typedescr=>describe_by_data( lt_fixval ).
      temp483-type = temp117.
      INSERT temp483 INTO TABLE lt_comp_fix.
    ENDLOOP.

    lo_row = cl_abap_structdescr=>create( lt_comp_row ).

    lo_fix = cl_abap_structdescr=>create( lt_comp_fix ).
    CREATE DATA ms_data_row TYPE HANDLE lo_row.
    CREATE DATA ms_fixval TYPE HANDLE lo_fix.

    ASSIGN ms_data_row->* TO <row>.
    ASSIGN ms_fixval->* TO <fixval>.
    LOOP AT mt_field INTO lv_field.
      ASSIGN COMPONENT lv_field OF STRUCTURE <row> TO <val>.
      cl_abap_unit_assert=>assert_subrc( ).
      <val> = |v-{ lv_field }|.
      ASSIGN COMPONENT lv_field OF STRUCTURE <fixval> TO <tab>.
      cl_abap_unit_assert=>assert_subrc( ).

      CLEAR temp484.

      temp485-low = `A`.
      temp485-descr = |a of { lv_field }|.
      INSERT temp485 INTO TABLE temp484.
      temp485-low = `B`.
      temp485-descr = `b`.
      INSERT temp485 INTO TABLE temp484.
      <tab> = temp484.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.


CLASS ltcl_app_ns DEFINITION FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.
    " a table of flat rows with namespaced columns (the fast path), the
    " same row as one structure, and a table whose rows carry a table of
    " such rows as well (the general road) - built at run time, the only
    " way a component gets a name with a namespace in a unit test
    DATA mr_tab  TYPE REF TO data.
    DATA mr_row  TYPE REF TO data.
    DATA mr_deep TYPE REF TO data.
    METHODS build.
    " one cell of a row, by component name
    CLASS-METHODS cell
      IMPORTING
        is_row        TYPE any
        iv_name       TYPE string
      RETURNING
        VALUE(result) TYPE string.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS ltcl_app_ns IMPLEMENTATION.

  METHOD z2ui5_if_app~main.
  ENDMETHOD.

  METHOD build.

    DATA lt_comp TYPE cl_abap_structdescr=>component_table.
    DATA lv_text TYPE string.
    DATA lv_int  TYPE i.
    FIELD-SYMBOLS <tab>  TYPE STANDARD TABLE.
    FIELD-SYMBOLS <row>  TYPE any.
    FIELD-SYMBOLS <cell> TYPE any.

    " MATNR sorts between the namespace CWM and the plain ZZ_LAST - the
    " namespace object takes its place by its own name
    DATA temp486 TYPE abap_component_tab.
    DATA temp487 LIKE LINE OF temp486.
    DATA temp118 TYPE REF TO cl_abap_datadescr.
    DATA temp119 TYPE REF TO cl_abap_datadescr.
    DATA temp120 TYPE REF TO cl_abap_datadescr.
    DATA temp121 TYPE REF TO cl_abap_datadescr.
    DATA temp122 TYPE REF TO cl_abap_datadescr.
    DATA lo_row TYPE REF TO cl_abap_structdescr.
    DATA lo_tab TYPE REF TO cl_abap_tabledescr.
    FIELD-SYMBOLS <first> TYPE any.
    DATA temp488 TYPE abap_component_tab.
    DATA temp489 LIKE LINE OF temp488.
    DATA temp123 TYPE REF TO cl_abap_datadescr.
    DATA temp124 TYPE REF TO cl_abap_datadescr.
    DATA lo_deep_row TYPE REF TO cl_abap_structdescr.
    DATA lo_deep TYPE REF TO cl_abap_tabledescr.
    FIELD-SYMBOLS <deep> TYPE STANDARD TABLE.
    CLEAR temp486.

    temp487-name = `MATNR`.

    temp118 ?= cl_abap_typedescr=>describe_by_data( lv_text ).
    temp487-type = temp118.
    INSERT temp487 INTO TABLE temp486.
    temp487-name = `/CWM/XCWMAT`.

    temp119 ?= cl_abap_typedescr=>describe_by_data( lv_text ).
    temp487-type = temp119.
    INSERT temp487 INTO TABLE temp486.
    temp487-name = `/CWM/VALUM`.

    temp120 ?= cl_abap_typedescr=>describe_by_data( lv_int ).
    temp487-type = temp120.
    INSERT temp487 INTO TABLE temp486.
    temp487-name = `/VSO/R_TILT`.

    temp121 ?= cl_abap_typedescr=>describe_by_data( lv_text ).
    temp487-type = temp121.
    INSERT temp487 INTO TABLE temp486.
    temp487-name = `AA_FIRST`.

    temp122 ?= cl_abap_typedescr=>describe_by_data( lv_text ).
    temp487-type = temp122.
    INSERT temp487 INTO TABLE temp486.
    lt_comp = temp486.

    lo_row = cl_abap_structdescr=>create( lt_comp ).

    lo_tab = cl_abap_tabledescr=>create( lo_row ).
    CREATE DATA mr_row TYPE HANDLE lo_row.
    CREATE DATA mr_tab TYPE HANDLE lo_tab.

    ASSIGN mr_tab->* TO <tab>.
    DO 2 TIMES.
      INSERT INITIAL LINE INTO TABLE <tab> ASSIGNING <row>.
      ASSIGN COMPONENT `MATNR` OF STRUCTURE <row> TO <cell>.
      cl_abap_unit_assert=>assert_subrc( ).
      <cell> = |M{ sy-index }|.
      ASSIGN COMPONENT `/CWM/XCWMAT` OF STRUCTURE <row> TO <cell>.
      cl_abap_unit_assert=>assert_subrc( ).
      <cell> = |X{ sy-index }|.
      ASSIGN COMPONENT `/CWM/VALUM` OF STRUCTURE <row> TO <cell>.
      cl_abap_unit_assert=>assert_subrc( ).
      <cell> = sy-index * 10.
      ASSIGN COMPONENT `/VSO/R_TILT` OF STRUCTURE <row> TO <cell>.
      cl_abap_unit_assert=>assert_subrc( ).
      <cell> = |T{ sy-index }|.
      ASSIGN COMPONENT `AA_FIRST` OF STRUCTURE <row> TO <cell>.
      cl_abap_unit_assert=>assert_subrc( ).
      <cell> = |A{ sy-index }|.
    ENDDO.
    ASSIGN mr_row->* TO <cell>.

    READ TABLE <tab> INDEX 1 ASSIGNING <first>.
    <cell> = <first>.

    " the deep rows: a key, a namespaced column and a namespaced table of
    " the flat rows above

    CLEAR temp488.

    temp489-name = `ID`.

    temp123 ?= cl_abap_typedescr=>describe_by_data( lv_int ).
    temp489-type = temp123.
    INSERT temp489 INTO TABLE temp488.
    temp489-name = `/ABC/NOTE`.

    temp124 ?= cl_abap_typedescr=>describe_by_data( lv_text ).
    temp489-type = temp124.
    INSERT temp489 INTO TABLE temp488.
    temp489-name = `/ABC/ITEMS`.
    temp489-type = lo_tab.
    INSERT temp489 INTO TABLE temp488.
    lt_comp = temp488.

    lo_deep_row = cl_abap_structdescr=>create( lt_comp ).

    lo_deep = cl_abap_tabledescr=>create( lo_deep_row ).
    CREATE DATA mr_deep TYPE HANDLE lo_deep.

    ASSIGN mr_deep->* TO <deep>.
    INSERT INITIAL LINE INTO TABLE <deep> ASSIGNING <row>.
    ASSIGN COMPONENT `ID` OF STRUCTURE <row> TO <cell>.
    cl_abap_unit_assert=>assert_subrc( ).
    <cell> = 1.
    ASSIGN COMPONENT `/ABC/NOTE` OF STRUCTURE <row> TO <cell>.
    cl_abap_unit_assert=>assert_subrc( ).
    <cell> = `note`.
    ASSIGN COMPONENT `/ABC/ITEMS` OF STRUCTURE <row> TO <cell>.
    cl_abap_unit_assert=>assert_subrc( ).
    <cell> = <tab>.

  ENDMETHOD.

  METHOD cell.

    FIELD-SYMBOLS <cell> TYPE any.
    ASSIGN COMPONENT iv_name OF STRUCTURE is_row TO <cell>.
    cl_abap_unit_assert=>assert_subrc( ).
    result = <cell>.

  ENDMETHOD.

ENDCLASS.


CLASS ltcl_06_fast_json DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION MEDIUM.

  PRIVATE SECTION.
    " every elementary kind the fast path takes, in one row type (no
    " decfloat16 and no int8: the transpiled runtime has no type for the
    " first, 7.02 none for the second - both render through |{ }| like
    " decfloat34 and i do)
    TYPES:
      BEGIN OF ty_s_kinds,
        v_i      TYPE i,
        v_int1   TYPE int1,
        v_int2   TYPE int2,
        v_p      TYPE p LENGTH 9 DECIMALS 2,
        v_p0     TYPE p LENGTH 5 DECIMALS 0,
        v_f      TYPE f,
        v_dec34  TYPE decfloat34,
        v_c      TYPE c LENGTH 10,
        v_n      TYPE n LENGTH 5,
        v_string TYPE string,
        v_x      TYPE x LENGTH 2,
        v_xstr   TYPE xstring,
        v_d      TYPE d,
        v_t      TYPE t,
        v_bool   TYPE abap_bool,
        v_xsd    TYPE xsdboolean,
        za_last  TYPE string,
        a_first  TYPE string,
      END OF ty_s_kinds.
    TYPES ty_t_kinds TYPE STANDARD TABLE OF ty_s_kinds WITH DEFAULT KEY.
    TYPES ty_t_kinds_sorted TYPE SORTED TABLE OF ty_s_kinds WITH UNIQUE KEY v_i.

    TYPES:
      BEGIN OF ty_s_nested,
        id   TYPE i,
        s_in TYPE ltcl_app_fast=>ty_s_row,
      END OF ty_s_nested.
    TYPES ty_t_nested TYPE STANDARD TABLE OF ty_s_nested WITH DEFAULT KEY.
    TYPES:
      BEGIN OF ty_s_stamp,
        id  TYPE i,
        ts  TYPE timestamp,
        tsl TYPE timestampl,
      END OF ty_s_stamp.
    TYPES ty_t_stamp TYPE STANDARD TABLE OF ty_s_stamp WITH DEFAULT KEY.

    " row types with includes: plain, an include of an include, the same
    " structure twice under two suffixes, and one whose include is not flat
    TYPES:
      BEGIN OF ty_s_inc_base,
        b_id   TYPE i,
        b_text TYPE string,
        b_day  TYPE d,
        b_ok   TYPE abap_bool,
      END OF ty_s_inc_base.
    TYPES BEGIN OF ty_s_inc_plain.
    TYPES z_own TYPE string.
    INCLUDE TYPE ty_s_inc_base.
    TYPES a_own TYPE i.
    TYPES END OF ty_s_inc_plain.
    TYPES ty_t_inc_plain TYPE STANDARD TABLE OF ty_s_inc_plain WITH DEFAULT KEY.
    TYPES BEGIN OF ty_s_inc_nested.
    INCLUDE TYPE ty_s_inc_plain.
    TYPES m_own TYPE t.
    TYPES END OF ty_s_inc_nested.
    TYPES ty_t_inc_nested TYPE STANDARD TABLE OF ty_s_inc_nested WITH DEFAULT KEY.
    TYPES BEGIN OF ty_s_inc_suffix.
    TYPES key TYPE i.
    INCLUDE TYPE ty_s_inc_base AS s_old RENAMING WITH SUFFIX _old.
    INCLUDE TYPE ty_s_inc_base AS s_new RENAMING WITH SUFFIX _new.
    TYPES END OF ty_s_inc_suffix.
    TYPES ty_t_inc_suffix TYPE STANDARD TABLE OF ty_s_inc_suffix WITH DEFAULT KEY.
    TYPES BEGIN OF ty_s_inc_deep.
    TYPES key TYPE i.
    INCLUDE TYPE ty_s_nested AS s_deep RENAMING WITH SUFFIX _d.
    TYPES END OF ty_s_inc_deep.
    TYPES ty_t_inc_deep TYPE STANDARD TABLE OF ty_s_inc_deep WITH DEFAULT KEY.

    DATA mo_model TYPE REF TO z2ui5_cl_ui5_srv_model.

    METHODS setup.

    " the representative rows - specials, negatives, decimals, initial
    METHODS rows
      RETURNING
        VALUE(result) TYPE ty_t_kinds.

    " the general road: ajson under the upper-case mapping, a wide number
    " quoted when its digits need it (json_quote_lossy) as on the fast road
    METHODS ajson_text
      IMPORTING
        iv_val        TYPE any
      RETURNING
        VALUE(result) TYPE string
      RAISING
        z2ui5_cx_ui5_ajs_error.

    METHODS every_kind_identical     FOR TESTING RAISING cx_static_check.
    METHODS empty_table_identical    FOR TESTING RAISING cx_static_check.
    METHODS flat_struct_identical    FOR TESTING RAISING cx_static_check.
    METHODS keys_in_ajson_order      FOR TESTING RAISING cx_static_check.
    METHODS escape_as_ajson          FOR TESTING RAISING cx_static_check.
    METHODS not_taken_falls_back     FOR TESTING RAISING cx_static_check.
    METHODS include_plain_identical  FOR TESTING RAISING cx_static_check.
    METHODS include_nested_identical FOR TESTING RAISING cx_static_check.
    METHODS include_suffix_identical FOR TESTING RAISING cx_static_check.
    METHODS include_deep_falls_back  FOR TESTING RAISING cx_static_check.
    METHODS timestamp_identical      FOR TESTING RAISING cx_static_check.
    METHODS timestamp_struct_identical FOR TESTING RAISING cx_static_check.
    METHODS model_log_identical      FOR TESTING RAISING cx_static_check.
    METHODS model_identical          FOR TESTING RAISING cx_static_check.
    METHODS model_dollar_and_token   FOR TESTING RAISING cx_static_check.
    METHODS splice_any_order         FOR TESTING RAISING cx_static_check.
    METHODS splice_no_token          FOR TESTING RAISING cx_static_check.
    METHODS splice_token_lost        FOR TESTING RAISING cx_static_check.
    " the edit popup of table-maintenance over a table with namespaced
    " fields - MODEL_FAST_PATH_TOKEN_LOST on initial rendering (1.150.0)
    METHODS tm_pop_namespaced_fields FOR TESTING RAISING cx_static_check.
    " a draft written before the fix keeps its client names with `//`
    METHODS tm_pop_legacy_double_slash FOR TESTING RAISING cx_static_check.
    " a token overwritten by a later attribute at the same path
    METHODS tm_pop_token_overwritten FOR TESTING RAISING cx_static_check.
    METHODS splice_lost_token_skipped FOR TESTING RAISING cx_static_check.
    " a namespaced column of a bound table is a level of its row
    " (`"CWM":{"XCWMAT":...}`), so a row template can bind it relatively -
    " the fast path and the general road alike, and every other row as
    " before, byte for byte
    METHODS ns_fast_path_grouped     FOR TESTING RAISING cx_static_check.
    METHODS ns_struct_grouped        FOR TESTING RAISING cx_static_check.
    METHODS ns_general_road_grouped  FOR TESTING RAISING cx_static_check.
    METHODS ns_text_plain_identical  FOR TESTING RAISING cx_static_check.
    METHODS ns_omit_initial_grouped  FOR TESTING RAISING cx_static_check.
    " and an edit comes back onto the component
    METHODS ns_delta_applied         FOR TESTING RAISING cx_static_check.
    METHODS ns_whole_value_applied   FOR TESTING RAISING cx_static_check.
    METHODS ns_deep_whole_applied    FOR TESTING RAISING cx_static_check.
    METHODS ns_cell_bind_path        FOR TESTING RAISING cx_static_check.

    " the app of the ns_* tests with its three values bound
    METHODS ns_setup
      EXPORTING
        eo_app  TYPE REF TO ltcl_app_ns
        eo_cont TYPE REF TO z2ui5_cl_ui5_app_cont
        et_path TYPE string_table.

    " the popup's render: every field bound as value and as fixed values,
    " through the real bind service - the bind paths, field by field
    METHODS tm_pop_bind
      IMPORTING
        io_app        TYPE REF TO ltcl_app_tm_pop
        io_cont       TYPE REF TO z2ui5_cl_ui5_app_cont
      RETURNING
        VALUE(result) TYPE string_table
      RAISING
        cx_static_check.

    " the document the general road writes: every bound attribute set into
    " ajson at its client name, in the order of the attribute table
    METHODS tm_pop_ajson_text
      IMPORTING
        io_cont       TYPE REF TO z2ui5_cl_ui5_app_cont
      RETURNING
        VALUE(result) TYPE string
      RAISING
        cx_static_check.

ENDCLASS.


CLASS ltcl_06_fast_json IMPLEMENTATION.

  METHOD setup.

    DATA lr_attri TYPE REF TO z2ui5_if_ui5_types=>ty_t_attri.
    DATA temp125 TYPE REF TO ltcl_app_fast.
    CREATE DATA lr_attri.

    CREATE OBJECT temp125 TYPE ltcl_app_fast.
    CREATE OBJECT mo_model EXPORTING attri = lr_attri app = temp125.

  ENDMETHOD.

  METHOD rows.

    DATA ls_row TYPE ty_s_kinds.
    " row 1: filled, with the characters the escaper handles and a few
    " more a bound value may carry
    ls_row-v_i      = 42.
    ls_row-v_int1   = 255.
    ls_row-v_int2   = -32768.
    ls_row-v_p      = '1234567.89'.
    ls_row-v_p0     = 12.
    ls_row-v_f      = '12.5'.
    ls_row-v_dec34  = '-1234.5678'.
    ls_row-v_c      = 'ab c'.
    ls_row-v_n      = '42'.
    ls_row-v_string = `say "hi" \ tab` && z2ui5_cl_ui5_util_context=>cv_char_util_horizontal_tab
                      && `nl` && z2ui5_cl_ui5_util_context=>cv_char_util_newline && `cr` && z2ui5_cl_ui5_util_context=>cv_char_util_cr_lf
                      && ` { } [ ] / $& $1 <b>&amp;</b> ` && `\u00e9`.
    ls_row-v_x      = 'A0FF'.
    ls_row-v_xstr   = '0102'.
    ls_row-v_d      = '20240229'.
    ls_row-v_t      = '235959'.
    ls_row-v_bool   = abap_true.
    ls_row-v_xsd    = abap_true.
    ls_row-za_last  = `z`.
    ls_row-a_first  = `a`.
    INSERT ls_row INTO TABLE result.
    " row 2: negatives and decimals
    CLEAR ls_row.
    ls_row-v_i     = -7.
    ls_row-v_p     = '-0.01'.
    ls_row-v_p0    = -99999.
    ls_row-v_f     = '-0.000001'.
    ls_row-v_dec34 = '123456789012345678901234567890'.
    ls_row-v_c     = `"`.
    ls_row-v_n     = '00007'.
    ls_row-v_string = `\`.
    INSERT ls_row INTO TABLE result.
    " row 3: everything initial
    CLEAR ls_row.
    INSERT ls_row INTO TABLE result.

  ENDMETHOD.

  METHOD ajson_text.

    DATA lr_val TYPE REF TO data.
    DATA li_json TYPE REF TO z2ui5_if_ui5_ajs.
    li_json = z2ui5_cl_ui5_ajs=>create_empty( ii_custom_mapping = z2ui5_cl_ui5_util_json_fl=>mapper_upper( )
                      )->set( iv_ignore_empty = abap_false
                              iv_path         = `/`
                              iv_val          = iv_val ).
    GET REFERENCE OF iv_val INTO lr_val.
    mo_model->json_quote_lossy( io_json = li_json
                                iv_path = ``
                                ir_ref  = lr_val ).
    result = li_json->stringify( ).

  ENDMETHOD.

  METHOD every_kind_identical.

    DATA lt_rows TYPE ltcl_06_fast_json=>ty_t_kinds.
    DATA lr_rows LIKE REF TO lt_rows.
    DATA lv_act TYPE string.
    DATA temp86 TYPE xsdboolean.
    DATA temp87 TYPE xsdboolean.
    DATA temp88 TYPE xsdboolean.
    DATA temp89 TYPE xsdboolean.
    DATA temp90 TYPE xsdboolean.
    DATA temp91 TYPE xsdboolean.
    DATA temp92 TYPE xsdboolean.
    DATA temp93 TYPE xsdboolean.
    DATA temp94 TYPE xsdboolean.
    DATA temp95 TYPE xsdboolean.
    DATA temp96 TYPE xsdboolean.
    DATA temp97 TYPE xsdboolean.
    DATA temp98 TYPE xsdboolean.
    DATA temp99 TYPE xsdboolean.
    DATA temp100 TYPE xsdboolean.
    lt_rows = rows( ).

    GET REFERENCE OF lt_rows INTO lr_rows.


    lv_act = mo_model->attri_json_fast( lr_rows ).

    cl_abap_unit_assert=>assert_not_initial( lv_act ).
    cl_abap_unit_assert=>assert_equals( exp = ajson_text( lt_rows )
                                        act = lv_act ).
    " and a few of the renderings, pinned - the compare above would also
    " pass if both sides changed together

    temp86 = boolc( lv_act CS `"V_P":1234567.89` ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp86 ).

    temp87 = boolc( lv_act CS `"V_P":-0.01` ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp87 ).

    temp88 = boolc( lv_act CS `"V_P":0.00` ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp88 ).

    temp89 = boolc( lv_act CS `"V_BOOL":true` ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp89 ).

    temp90 = boolc( lv_act CS `"V_BOOL":false` ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp90 ).

    temp91 = boolc( lv_act CS `"V_D":"2024-02-29"` ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp91 ).

    temp92 = boolc( lv_act CS `"V_T":"23:59:59"` ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp92 ).

    temp93 = boolc( lv_act CS `"V_D":""` ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp93 ).

    temp94 = boolc( lv_act CS `"V_T":""` ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp94 ).

    temp95 = boolc( lv_act CS `"V_N":"00007"` ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp95 ).

    temp96 = boolc( lv_act CS `"V_X":"A0FF"` ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp96 ).

    temp97 = boolc( lv_act CS `"V_C":"ab c"` ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp97 ).

    temp98 = boolc( lv_act CS `"V_INT2":-32768` ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp98 ).
    " more digits than a double keeps - quoted; fewer stay a number

    temp99 = boolc( lv_act CS `"V_DEC34":"123456789012345678901234567890"` ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp99 ).

    temp100 = boolc( lv_act CS `"V_DEC34":-1234.5678` ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp100 ).

  ENDMETHOD.

  METHOD empty_table_identical.

    DATA lt_rows TYPE ty_t_kinds.
    DATA lr_rows LIKE REF TO lt_rows.
    GET REFERENCE OF lt_rows INTO lr_rows.

    cl_abap_unit_assert=>assert_equals( exp = `[]`
                                        act = mo_model->attri_json_fast( lr_rows ) ).
    cl_abap_unit_assert=>assert_equals( exp = ajson_text( lt_rows )
                                        act = mo_model->attri_json_fast( lr_rows ) ).

  ENDMETHOD.

  METHOD flat_struct_identical.

    DATA lt_rows TYPE ltcl_06_fast_json=>ty_t_kinds.
    DATA temp490 LIKE LINE OF lt_rows.
    DATA lr_row LIKE REF TO temp490.
    lt_rows = rows( ).


    LOOP AT lt_rows REFERENCE INTO lr_row.
      cl_abap_unit_assert=>assert_equals( exp = ajson_text( lr_row->* )
                                          act = mo_model->attri_json_fast( lr_row ) ).
    ENDLOOP.

  ENDMETHOD.

  METHOD keys_in_ajson_order.

    " ajson writes the members of an object by name, not in component
    " order - A_FIRST is the last component and the first key
    DATA lt_rows TYPE ltcl_06_fast_json=>ty_t_kinds.
    DATA temp491 LIKE REF TO lt_rows.
DATA lv_act TYPE string.
    DATA temp101 TYPE xsdboolean.
    DATA temp102 TYPE xsdboolean.
    DATA temp103 TYPE xsdboolean.
    lt_rows = rows( ).

    GET REFERENCE OF lt_rows INTO temp491.

lv_act = mo_model->attri_json_fast( temp491 ).


    temp101 = boolc( lv_act CP `[{"A_FIRST":"a",*` ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp101 ).

    temp102 = boolc( lv_act CS `"ZA_LAST":"z"}` ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp102 ).

    temp103 = boolc( find( val = lv_act sub = `"V_I":` ) < find( val = lv_act sub = `"V_INT1":` ) ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp103 ).

  ENDMETHOD.

  METHOD escape_as_ajson.

    " the string escaper against ajson's, character by character, for the
    " characters it handles and the ones it leaves alone
    DATA lv_raw TYPE string.
    DATA lv_exp TYPE string.
    lv_raw = `a"b\c` && z2ui5_cl_ui5_util_context=>cv_char_util_horizontal_tab && z2ui5_cl_ui5_util_context=>cv_char_util_newline
                   && z2ui5_cl_ui5_util_context=>cv_char_util_cr_lf && `/ $& \u0041 ` && `{}`.

    lv_exp = z2ui5_cl_ui5_ajs=>create_empty( )->set( iv_path = `/V`
                                                        iv_val     = lv_raw )->stringify( ).
    cl_abap_unit_assert=>assert_equals( exp = lv_exp
                                        act = |\{"V":"{ z2ui5_cl_ui5_util_context=>c_escape_json( lv_raw ) }"\}| ).
    " nothing to escape: the text itself
    cl_abap_unit_assert=>assert_equals( exp = `plain`
                                        act = z2ui5_cl_ui5_util_context=>c_escape_json( `plain` ) ).

  ENDMETHOD.

  METHOD not_taken_falls_back.

    " a nested structure in the row, a sorted table, a table of scalars, a
    " scalar: none of them is written here - the general road through
    " ajson stays the reference for them
    DATA lt_nested TYPE ty_t_nested.
    DATA lt_sorted TYPE ty_t_kinds_sorted.
    DATA lt_scalar TYPE string_table.
    DATA lv_scalar TYPE string.
    DATA temp492 TYPE ltcl_06_fast_json=>ty_s_nested.
    DATA temp493 TYPE ltcl_06_fast_json=>ty_s_kinds.
    DATA temp494 LIKE REF TO lt_nested.
    DATA temp495 LIKE REF TO lt_sorted.
    DATA temp496 LIKE REF TO lt_scalar.
    DATA temp497 LIKE REF TO lv_scalar.
    CLEAR temp492.
    temp492-id = 1.
    INSERT temp492 INTO TABLE lt_nested.

    CLEAR temp493.
    temp493-v_i = 1.
    INSERT temp493 INTO TABLE lt_sorted.
    INSERT `x` INTO TABLE lt_scalar.


    GET REFERENCE OF lt_nested INTO temp494.
cl_abap_unit_assert=>assert_initial( mo_model->attri_json_fast( temp494 ) ).

    GET REFERENCE OF lt_sorted INTO temp495.
cl_abap_unit_assert=>assert_initial( mo_model->attri_json_fast( temp495 ) ).

    GET REFERENCE OF lt_scalar INTO temp496.
cl_abap_unit_assert=>assert_initial( mo_model->attri_json_fast( temp496 ) ).

    GET REFERENCE OF lv_scalar INTO temp497.
cl_abap_unit_assert=>assert_initial( mo_model->attri_json_fast( temp497 ) ).

  ENDMETHOD.

  METHOD include_plain_identical.

    " the fields of an include are members of the row like its own - in
    " ajson's order (by name), whatever the order of the components
    DATA lt_rows TYPE ty_t_inc_plain.
    DATA temp498 TYPE ltcl_06_fast_json=>ty_s_inc_plain.
    DATA temp499 LIKE REF TO lt_rows.
DATA lv_act TYPE string.
    DATA temp104 TYPE xsdboolean.
    FIELD-SYMBOLS <temp126> TYPE ltcl_06_fast_json=>ty_s_inc_plain.
DATA temp500 LIKE REF TO <temp126>.
FIELD-SYMBOLS <temp127> LIKE LINE OF lt_rows.
DATA temp128 LIKE sy-tabix.
    CLEAR temp498.
    temp498-z_own = `z`.
    temp498-b_id = 1.
    temp498-b_text = `in "clu" de`.
    temp498-b_day = '20240229'.
    temp498-b_ok = abap_true.
    temp498-a_own = 7.
    INSERT temp498 INTO TABLE lt_rows.
    INSERT INITIAL LINE INTO TABLE lt_rows.


    GET REFERENCE OF lt_rows INTO temp499.

lv_act = mo_model->attri_json_fast( temp499 ).

    cl_abap_unit_assert=>assert_not_initial( lv_act ).
    cl_abap_unit_assert=>assert_equals( exp = ajson_text( lt_rows )
                                        act = lv_act ).

    temp104 = boolc( lv_act CS `{"A_OWN":7,"B_DAY":"2024-02-29","B_ID":1,"B_OK":true,"B_TEXT":"in \"clu\" de","Z_OWN":"z"}` ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp104 ).
    " and the structure itself

    READ TABLE lt_rows INDEX 1 ASSIGNING <temp126>.
IF sy-subrc <> 0.
  ASSERT 1 = 0.
ENDIF.

GET REFERENCE OF <temp126> INTO temp500.


temp128 = sy-tabix.
READ TABLE lt_rows INDEX 1 ASSIGNING <temp127>.
sy-tabix = temp128.
IF sy-subrc <> 0.
  ASSERT 1 = 0.
ENDIF.
cl_abap_unit_assert=>assert_equals( exp = ajson_text( <temp127> )
                                        act = mo_model->attri_json_fast( temp500 ) ).

  ENDMETHOD.

  METHOD include_nested_identical.

    " an include whose structure has an include of its own
    DATA lt_rows TYPE ty_t_inc_nested.
    DATA temp501 TYPE ltcl_06_fast_json=>ty_s_inc_nested.
    DATA temp502 LIKE REF TO lt_rows.
DATA lv_act TYPE string.
    DATA temp105 TYPE xsdboolean.
    CLEAR temp501.
    temp501-z_own = `z`.
    temp501-b_id = 1.
    temp501-b_text = `deep`.
    temp501-b_ok = abap_true.
    temp501-a_own = 7.
    temp501-m_own = '120000'.
    INSERT temp501 INTO TABLE lt_rows.
    INSERT INITIAL LINE INTO TABLE lt_rows.


    GET REFERENCE OF lt_rows INTO temp502.

lv_act = mo_model->attri_json_fast( temp502 ).

    cl_abap_unit_assert=>assert_not_initial( lv_act ).
    cl_abap_unit_assert=>assert_equals( exp = ajson_text( lt_rows )
                                        act = lv_act ).

    temp105 = boolc( lv_act CS `"B_TEXT":"deep","M_OWN":"12:00:00","Z_OWN":"z"}` ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp105 ).

  ENDMETHOD.

  METHOD include_suffix_identical.

    " the same structure twice, told apart by RENAMING WITH SUFFIX: the
    " members carry the suffixed names, and the name of the include itself
    " (AS s_old) is no member
    DATA lt_rows TYPE ty_t_inc_suffix.
    DATA temp503 TYPE ltcl_06_fast_json=>ty_s_inc_suffix.
    DATA temp504 LIKE REF TO lt_rows.
DATA lv_act TYPE string.
    DATA temp106 TYPE xsdboolean.
    DATA temp107 TYPE xsdboolean.
    DATA temp108 TYPE xsdboolean.
    CLEAR temp503.
    temp503-key = 1.
    temp503-b_id_old = 10.
    temp503-b_text_old = `before`.
    temp503-b_id_new = 11.
    temp503-b_text_new = `after`.
    temp503-b_ok_new = abap_true.
    INSERT temp503
           INTO TABLE lt_rows.
    INSERT INITIAL LINE INTO TABLE lt_rows.


    GET REFERENCE OF lt_rows INTO temp504.

lv_act = mo_model->attri_json_fast( temp504 ).

    cl_abap_unit_assert=>assert_not_initial( lv_act ).
    cl_abap_unit_assert=>assert_equals( exp = ajson_text( lt_rows )
                                        act = lv_act ).

    temp106 = boolc( lv_act CS `"B_ID_NEW":11,"B_ID_OLD":10,` ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp106 ).

    temp107 = boolc( lv_act CS `"B_TEXT_NEW":"after","B_TEXT_OLD":"before","KEY":1}` ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp107 ).

    temp108 = boolc( lv_act CS `S_OLD` ).
    cl_abap_unit_assert=>assert_equals( exp = abap_false act = temp108 ).

  ENDMETHOD.

  METHOD include_deep_falls_back.

    " an include that brings a nested structure along: not flat, so the
    " general road - which writes the same document as before
    DATA lt_rows TYPE ty_t_inc_deep.
    DATA temp505 TYPE ltcl_06_fast_json=>ty_s_inc_deep.
    DATA temp506 LIKE REF TO lt_rows.
    CLEAR temp505.
    temp505-key = 1.
    temp505-id_d = 2.
    INSERT temp505 INTO TABLE lt_rows.


    GET REFERENCE OF lt_rows INTO temp506.
cl_abap_unit_assert=>assert_initial( mo_model->attri_json_fast( temp506 ) ).

  ENDMETHOD.

  METHOD timestamp_identical.

    " the two time stamp kinds as ajson writes them - an ISO instant in
    " UTC, never empty. Row 1 initial, row 2 a typical one, row 3 a long
    " one with a fraction. The fraction is a half and the time a whole
    " hour on purpose: the transpiled runtime copies a packed field
    " through a double (backlog/items/runtime-packed-copy-precision.md),
    " which holds exactly these and shifts most others by some hundred
    " nanoseconds - a system holds them all. Row 4 carries such a
    " fraction and is only compared, not pinned
    DATA lt_rows TYPE ty_t_stamp.
    DATA temp507 TYPE ltcl_06_fast_json=>ty_s_stamp.
    DATA temp508 TYPE ltcl_06_fast_json=>ty_s_stamp.
    DATA temp509 TYPE ltcl_06_fast_json=>ty_s_stamp.
    DATA temp510 TYPE ltcl_06_fast_json=>ty_s_stamp.
    DATA temp511 LIKE REF TO lt_rows.
DATA lv_act TYPE string.
    DATA temp109 TYPE xsdboolean.
    DATA temp110 TYPE xsdboolean.
    DATA temp111 TYPE xsdboolean.
    CLEAR temp507.
    temp507-id = 1.
    INSERT temp507 INTO TABLE lt_rows.

    CLEAR temp508.
    temp508-id = 2.
    temp508-ts = '20240229230000'.
    temp508-tsl = '20240229230000'.
    INSERT temp508 INTO TABLE lt_rows.

    CLEAR temp509.
    temp509-id = 3.
    temp509-ts = '19991231120000'.
    temp509-tsl = '20240229230000.5'.
    INSERT temp509 INTO TABLE lt_rows.

    CLEAR temp510.
    temp510-id = 4.
    temp510-ts = '20240229235959'.
    temp510-tsl = '20240229235959.1234567'.
    INSERT temp510 INTO TABLE lt_rows.


    GET REFERENCE OF lt_rows INTO temp511.

lv_act = mo_model->attri_json_fast( temp511 ).

    cl_abap_unit_assert=>assert_not_initial( lv_act ).
    cl_abap_unit_assert=>assert_equals( exp = ajson_text( lt_rows )
                                        act = lv_act ).

    temp109 = boolc( lv_act CS `{"ID":1,"TS":"0000-00-00T00:00:00Z","TSL":"0000-00-00T00:00:00.0Z"}` ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp109 ).

    temp110 = boolc( lv_act CS `{"ID":2,"TS":"2024-02-29T23:00:00Z","TSL":"2024-02-29T23:00:00.0Z"}` ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp110 ).

    temp111 = boolc( lv_act CS `{"ID":3,"TS":"1999-12-31T12:00:00Z","TSL":"2024-02-29T23:00:00.5Z"}` ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp111 ).

  ENDMETHOD.

  METHOD timestamp_struct_identical.

    " a flat structure with time stamps, row by row
    DATA lt_rows TYPE ty_t_stamp.
    DATA temp512 TYPE ltcl_06_fast_json=>ty_s_stamp.
    DATA temp513 TYPE ltcl_06_fast_json=>ty_s_stamp.
    DATA temp514 LIKE LINE OF lt_rows.
    DATA lr_row LIKE REF TO temp514.
    CLEAR temp512.
    temp512-id = 1.
    INSERT temp512 INTO TABLE lt_rows.

    CLEAR temp513.
    temp513-id = 2.
    temp513-ts = '20240229230000'.
    temp513-tsl = '20240229230000.5'.
    INSERT temp513 INTO TABLE lt_rows.



    LOOP AT lt_rows REFERENCE INTO lr_row.
      cl_abap_unit_assert=>assert_not_initial( mo_model->attri_json_fast( lr_row ) ).
      cl_abap_unit_assert=>assert_equals( exp = ajson_text( lr_row->* )
                                          act = mo_model->attri_json_fast( lr_row ) ).
    ENDLOOP.

  ENDMETHOD.

  METHOD model_log_identical.

    " the whole model with a table whose row type has an include and both
    " time stamp kinds: the document the tree alone writes
    DATA temp515 TYPE REF TO ltcl_app_fast.
    DATA lo_app LIKE temp515.
    DATA temp516 TYPE ltcl_app_fast=>ty_t_log.
    DATA temp517 LIKE LINE OF temp516.
    DATA temp518 LIKE LINE OF mo_model->mt_attri->*.
    DATA lr_attri LIKE REF TO temp518.
    DATA li_exp TYPE REF TO z2ui5_cl_ui5_ajs.
    DATA lv_act TYPE string.
    DATA temp112 TYPE xsdboolean.
    DATA temp519 LIKE REF TO lo_app->mt_log.
    temp515 ?= mo_model->mo_app.

    lo_app = temp515.

    CLEAR temp516.

    CLEAR temp517.
    temp517-id = 1.
    temp517-id_r = 10.
    temp517-name_r = `one`.
    temp517-price_r = '1.50'.
    temp517-ok_r = abap_true.
    temp517-day_r = '20240101'.
    temp517-created_at = '20240229230000'.
    temp517-changed_at = '20240229230000.5'.
    INSERT temp517 INTO TABLE temp516.
    CLEAR temp517.
    INSERT temp517 INTO TABLE temp516.
    lo_app->mt_log = temp516.
    mo_model->main_attri_refresh( ).


    LOOP AT mo_model->mt_attri->* REFERENCE INTO lr_attri "#EC CI_SORTSEQ
         WHERE name = `MT_LOG`.
      lr_attri->bind        = abap_true.
      lr_attri->name_client = |/{ lr_attri->name }|.
    ENDLOOP.


    li_exp = z2ui5_cl_ui5_ajs=>create_empty( ii_custom_mapping = z2ui5_cl_ui5_util_json_fl=>mapper_upper( ) ).
    li_exp->set( iv_ignore_empty = abap_false
                 iv_path         = `/MT_LOG`
                 iv_val          = lo_app->mt_log ).


    lv_act = mo_model->main_json_stringify( ).

    cl_abap_unit_assert=>assert_equals( exp = li_exp->stringify( )
                                        act = lv_act ).

    temp112 = boolc( lv_act CS `{"MT_LOG":[{"CHANGED_AT":"2024-02-29T23:00:00.5Z","CREATED_AT":"2024-02-29T23:00:00Z","DAY_R":"2024-01-01",` ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp112 ).
    " through the fast path, not the tree: the row type is taken

    GET REFERENCE OF lo_app->mt_log INTO temp519.
cl_abap_unit_assert=>assert_not_initial( mo_model->attri_json_fast( temp519 ) ).

  ENDMETHOD.

  METHOD model_identical.

    " the whole model: a bound table and a bound structure through the fast
    " path, a bound scalar through the tree - the document is what the
    " tree alone wrote before (a string node per bound attribute)
    DATA temp520 TYPE REF TO ltcl_app_fast.
    DATA lo_app LIKE temp520.
    DATA temp521 TYPE ltcl_app_fast=>ty_t_row.
    DATA temp522 LIKE LINE OF temp521.
    DATA temp523 LIKE LINE OF mo_model->mt_attri->*.
    DATA lr_attri LIKE REF TO temp523.
    DATA li_exp TYPE REF TO z2ui5_cl_ui5_ajs.
    DATA lv_act TYPE string.
    DATA temp113 TYPE xsdboolean.
    DATA temp114 TYPE xsdboolean.
    temp520 ?= mo_model->mo_app.

    lo_app = temp520.

    CLEAR temp521.

    CLEAR temp522.
    temp522-id = 1.
    temp522-name = `one`.
    temp522-price = '1.50'.
    temp522-ok = abap_true.
    temp522-day = '20240101'.
    INSERT temp522 INTO TABLE temp521.
    CLEAR temp522.
    temp522-id = 2.
    temp522-name = `t"wo`.
    INSERT temp522 INTO TABLE temp521.
    CLEAR temp522.
    INSERT temp522 INTO TABLE temp521.
    lo_app->mt_rows = temp521.
    CLEAR lo_app->ms_head.
    lo_app->ms_head-id = 9.
    lo_app->ms_head-name = `head`.
    lo_app->mv_title = `title`.
    mo_model->main_attri_refresh( ).


    LOOP AT mo_model->mt_attri->* REFERENCE INTO lr_attri "#EC CI_SORTSEQ
         WHERE name = `MT_ROWS` OR name = `MS_HEAD` OR name = `MV_TITLE`.
      lr_attri->bind        = abap_true.
      lr_attri->name_client = |/{ lr_attri->name }|.
    ENDLOOP.


    li_exp = z2ui5_cl_ui5_ajs=>create_empty( ii_custom_mapping = z2ui5_cl_ui5_util_json_fl=>mapper_upper( ) ).
    li_exp->set( iv_ignore_empty = abap_false
                 iv_path         = `/MT_ROWS`
                 iv_val          = lo_app->mt_rows ).
    li_exp->set( iv_ignore_empty = abap_false
                 iv_path         = `/MS_HEAD`
                 iv_val          = lo_app->ms_head ).
    li_exp->set( iv_ignore_empty = abap_false
                 iv_path         = `/MV_TITLE`
                 iv_val          = lo_app->mv_title ).


    lv_act = mo_model->main_json_stringify( ).

    cl_abap_unit_assert=>assert_equals( exp = li_exp->stringify( )
                                        act = lv_act ).

    temp113 = boolc( lv_act CS `"MT_ROWS":[{"DAY":"2024-01-01","ID":1,"NAME":"one","OK":true,"PRICE":1.50},` ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp113 ).

    temp114 = boolc( lv_act CS `z2ui5-fast-` ).
    cl_abap_unit_assert=>assert_equals( exp = abap_false act = temp114 ).

  ENDMETHOD.

  METHOD model_dollar_and_token.

    " values a splice must not read as anything: a `$&` and `$1` (what the
    " transpiled runtime's replace( ) reads as a pattern), a value that
    " looks like a token of this very path, in a cell and in the scalar
    " the tree writes before the table
    DATA temp524 TYPE REF TO ltcl_app_fast.
    DATA lo_app LIKE temp524.
    DATA temp525 TYPE ltcl_app_fast=>ty_t_row.
    DATA temp526 LIKE LINE OF temp525.
    DATA temp527 LIKE LINE OF mo_model->mt_attri->*.
    DATA lr_attri LIKE REF TO temp527.
    DATA li_exp TYPE REF TO z2ui5_cl_ui5_ajs.
    temp524 ?= mo_model->mo_app.

    lo_app = temp524.

    CLEAR temp525.

    temp526-id = 1.
    temp526-name = `$& $1 $$ z2ui5-fast-x-1`.
    INSERT temp526 INTO TABLE temp525.
    lo_app->mt_rows  = temp525.
    lo_app->mv_title = `"z2ui5-fast-` && `00000000000000000000000000000000-1"`.
    mo_model->main_attri_refresh( ).


    LOOP AT mo_model->mt_attri->* REFERENCE INTO lr_attri "#EC CI_SORTSEQ
         WHERE name = `MT_ROWS` OR name = `MV_TITLE`.
      lr_attri->bind        = abap_true.
      lr_attri->name_client = |/{ lr_attri->name }|.
    ENDLOOP.


    li_exp = z2ui5_cl_ui5_ajs=>create_empty( ii_custom_mapping = z2ui5_cl_ui5_util_json_fl=>mapper_upper( ) ).
    li_exp->set( iv_ignore_empty = abap_false
                 iv_path         = `/MT_ROWS`
                 iv_val          = lo_app->mt_rows ).
    li_exp->set( iv_ignore_empty = abap_false
                 iv_path         = `/MV_TITLE`
                 iv_val          = lo_app->mv_title ).

    cl_abap_unit_assert=>assert_equals( exp = li_exp->stringify( )
                                        act = mo_model->main_json_stringify( ) ).

  ENDMETHOD.

  METHOD splice_any_order.

    " one pass, whatever order the document holds the tokens in: the third
    " token first, a scalar between two tokens, the JSON of one carrying
    " what a replace( ) would read as a pattern and what looks like the
    " token that follows it - spliced text is not searched again
    DATA ls_fast TYPE z2ui5_cl_ui5_srv_model=>ty_s_fast_state.
    DATA temp528 TYPE z2ui5_cl_ui5_srv_model=>ty_s_fast.
    DATA temp529 TYPE z2ui5_cl_ui5_srv_model=>ty_s_fast.
    DATA temp530 TYPE z2ui5_cl_ui5_srv_model=>ty_s_fast.
    DATA lv_json TYPE string.
    ls_fast-uuid = `U1`.

    CLEAR temp528.
    temp528-token = `z2ui5-fast-U1-1`.
    temp528-json = `[{"A":"$& $1 \"z2ui5-fast-U1-2\""}]`.
    INSERT temp528 INTO TABLE ls_fast-t_token.

    CLEAR temp529.
    temp529-token = `z2ui5-fast-U1-2`.
    temp529-json = `[]`.
    INSERT temp529 INTO TABLE ls_fast-t_token.

    CLEAR temp530.
    temp530-token = `z2ui5-fast-U1-3`.
    temp530-json = `{"B":1}`.
    INSERT temp530 INTO TABLE ls_fast-t_token.

    lv_json = `{"C":"z2ui5-fast-U1-3","D":"z2ui5-fast-U1-1","E":"x","F":"z2ui5-fast-U1-2"}`.

    z2ui5_cl_ui5_srv_model=>json_fast_splice( EXPORTING is_fast = ls_fast
                                              CHANGING  cv_json = lv_json ).

    cl_abap_unit_assert=>assert_equals(
        exp = `{"C":{"B":1},"D":[{"A":"$& $1 \"z2ui5-fast-U1-2\""}],"E":"x","F":[]}`
        act = lv_json ).

  ENDMETHOD.

  METHOD splice_no_token.

    " nothing took the fast path: the document is not touched
    DATA ls_fast TYPE z2ui5_cl_ui5_srv_model=>ty_s_fast_state.
    DATA lv_json TYPE string.
    lv_json = `{"A":"z2ui5-fast--1"}`.

    z2ui5_cl_ui5_srv_model=>json_fast_splice( EXPORTING is_fast = ls_fast
                                              CHANGING  cv_json = lv_json ).

    cl_abap_unit_assert=>assert_equals( exp = `{"A":"z2ui5-fast--1"}`
                                        act = lv_json ).

  ENDMETHOD.

  METHOD splice_token_lost.

    " a token the document does not hold, and one it holds twice: both are
    " a table missing from the model, and both are refused
    DATA ls_fast TYPE z2ui5_cl_ui5_srv_model=>ty_s_fast_state.
    DATA temp531 TYPE z2ui5_cl_ui5_srv_model=>ty_s_fast.
    DATA temp532 TYPE z2ui5_cl_ui5_srv_model=>ty_s_fast.
    DATA lv_json TYPE string.
        DATA lx_lost TYPE REF TO z2ui5_cx_ui5_util_error.
        DATA temp115 TYPE xsdboolean.
        DATA lx_twice TYPE REF TO z2ui5_cx_ui5_util_error.
        DATA temp116 TYPE xsdboolean.
    ls_fast-uuid = `U1`.

    CLEAR temp531.
    temp531-token = `z2ui5-fast-U1-1`.
    temp531-json = `[]`.
    INSERT temp531 INTO TABLE ls_fast-t_token.

    CLEAR temp532.
    temp532-token = `z2ui5-fast-U1-2`.
    temp532-json = `[]`.
    INSERT temp532 INTO TABLE ls_fast-t_token.


    lv_json = `{"A":"z2ui5-fast-U1-2"}`.
    TRY.
        z2ui5_cl_ui5_srv_model=>json_fast_splice( EXPORTING is_fast = ls_fast
                                                  CHANGING  cv_json = lv_json ).
        cl_abap_unit_assert=>fail( `a lost token must be refused` ).

      CATCH z2ui5_cx_ui5_util_error INTO lx_lost.

        temp115 = boolc( lx_lost->get_text( ) CS `MODEL_FAST_PATH_TOKEN_LOST` ).
        cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp115 ).
    ENDTRY.

    lv_json = `{"A":"z2ui5-fast-U1-1","B":"z2ui5-fast-U1-1"}`.
    TRY.
        z2ui5_cl_ui5_srv_model=>json_fast_splice( EXPORTING is_fast = ls_fast
                                                  CHANGING  cv_json = lv_json ).
        cl_abap_unit_assert=>fail( `a token written twice must be refused` ).

      CATCH z2ui5_cx_ui5_util_error INTO lx_twice.

        temp116 = boolc( lx_twice->get_text( ) CS `MODEL_FAST_PATH_TOKEN_LOST` ).
        cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp116 ).
    ENDTRY.

  ENDMETHOD.

  METHOD splice_lost_token_skipped.

    " a token the tree cannot write (main_json_stringify marked it lost)
    " is not expected in the document - every other one still is
    DATA ls_fast TYPE z2ui5_cl_ui5_srv_model=>ty_s_fast_state.
    DATA temp533 TYPE z2ui5_cl_ui5_srv_model=>ty_s_fast.
    DATA temp534 TYPE z2ui5_cl_ui5_srv_model=>ty_s_fast.
    DATA lv_json TYPE string.
        DATA lx TYPE REF TO z2ui5_cx_ui5_util_error.
        DATA temp117 TYPE xsdboolean.
    ls_fast-uuid = `U1`.

    CLEAR temp533.
    temp533-token = `z2ui5-fast-U1-1`.
    temp533-json = `[1]`.
    temp533-lost = abap_true.
    INSERT temp533 INTO TABLE ls_fast-t_token.

    CLEAR temp534.
    temp534-token = `z2ui5-fast-U1-2`.
    temp534-json = `[2]`.
    INSERT temp534 INTO TABLE ls_fast-t_token.

    lv_json = `{"A":"z2ui5-fast-U1-2"}`.

    z2ui5_cl_ui5_srv_model=>json_fast_splice( EXPORTING is_fast = ls_fast
                                              CHANGING  cv_json = lv_json ).

    cl_abap_unit_assert=>assert_equals( exp = `{"A":[2]}`
                                        act = lv_json ).

    " but a token marked lost that the document holds after all is the
    " inconsistency the error is for
    lv_json = `{"A":"z2ui5-fast-U1-1","B":"z2ui5-fast-U1-2"}`.
    TRY.
        z2ui5_cl_ui5_srv_model=>json_fast_splice( EXPORTING is_fast = ls_fast
                                                  CHANGING  cv_json = lv_json ).
        cl_abap_unit_assert=>fail( `a lost token in the document must be refused` ).

      CATCH z2ui5_cx_ui5_util_error INTO lx.

        temp117 = boolc( lx->get_text( ) CS `MODEL_FAST_PATH_TOKEN_LOST` ).
        cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp117 ).
    ENDTRY.

  ENDMETHOD.

  METHOD tm_pop_bind.

    DATA lr_val TYPE REF TO data.
    FIELD-SYMBOLS <row>    TYPE any.
    FIELD-SYMBOLS <fixval> TYPE any.
    FIELD-SYMBOLS <val>    TYPE any.
    FIELD-SYMBOLS <struc>  TYPE any.

    DATA lo_bind TYPE REF TO z2ui5_cl_ui5_srv_bind.
    DATA lv_field LIKE LINE OF io_app->mt_field.
      DATA temp535 TYPE z2ui5_if_ui5_types=>ty_s_bind_config.
      DATA temp536 TYPE z2ui5_if_ui5_types=>ty_s_bind_config.
    CREATE OBJECT lo_bind TYPE z2ui5_cl_ui5_srv_bind EXPORTING APP = io_cont.
    ASSIGN io_app->ms_data_row->* TO <row>.
    ASSIGN io_app->ms_fixval->* TO <fixval>.

    LOOP AT io_app->mt_field INTO lv_field.
      ASSIGN COMPONENT lv_field OF STRUCTURE <row> TO <val>.
      cl_abap_unit_assert=>assert_subrc( ).
      GET REFERENCE OF <val> INTO lr_val.

      CLEAR temp535.
      temp535-path_only = abap_true.
      INSERT lo_bind->main( val    = lr_val
                            config = temp535 ) INTO TABLE result.
      ASSIGN COMPONENT lv_field OF STRUCTURE <fixval> TO <struc>.
      cl_abap_unit_assert=>assert_subrc( ).
      GET REFERENCE OF <struc> INTO lr_val.

      CLEAR temp536.
      temp536-path_only = abap_true.
      INSERT lo_bind->main( val    = lr_val
                            config = temp536 ) INTO TABLE result.
    ENDLOOP.

  ENDMETHOD.

  METHOD tm_pop_ajson_text.

    DATA li_exp TYPE REF TO z2ui5_cl_ui5_ajs.
    DATA lo_model TYPE REF TO z2ui5_cl_ui5_srv_model.
    DATA temp537 LIKE LINE OF io_cont->mt_attri->*.
    DATA lr_attri LIKE REF TO temp537.
      DATA lr_ref TYPE REF TO data.
      FIELD-SYMBOLS <val> TYPE data.
    li_exp = z2ui5_cl_ui5_ajs=>create_empty( ii_custom_mapping = z2ui5_cl_ui5_util_json_fl=>mapper_upper( ) ).

    CREATE OBJECT lo_model TYPE z2ui5_cl_ui5_srv_model EXPORTING attri = io_cont->mt_attri app = io_cont->mo_app.


    LOOP AT io_cont->mt_attri->* REFERENCE INTO lr_attri "#EC CI_SORTSEQ
         WHERE bind = abap_true.

      lr_ref = lo_model->attri_get_val_ref( lr_attri->name ).

      ASSIGN lr_ref->* TO <val>.
      li_exp->set( iv_ignore_empty = abap_false
                   iv_path         = lr_attri->name_client
                   iv_val          = <val> ).
    ENDLOOP.
    result = li_exp->stringify( ).

  ENDMETHOD.

  METHOD tm_pop_namespaced_fields.

    " a "large" DDIC table: its own fields, a long one, and the fields an
    " industry solution or a customer namespace appended - the shape that
    " raised MODEL_FAST_PATH_TOKEN_LOST on the first rendering of the popup
    DATA lo_app TYPE REF TO ltcl_app_tm_pop.
    DATA temp538 TYPE string_table.
      DATA temp540 LIKE LINE OF lo_app->mt_field.
    DATA lo_cont TYPE REF TO z2ui5_cl_ui5_app_cont.
    DATA lt_path TYPE string_table.
    DATA lo_model TYPE REF TO z2ui5_cl_ui5_srv_model.
    DATA lv_act TYPE string.
    DATA temp118 TYPE xsdboolean.
    DATA li_doc TYPE REF TO z2ui5_cl_ui5_ajs.
    DATA lv_field LIKE LINE OF lo_app->mt_field.
      DATA lv_val_path LIKE LINE OF lt_path.
      FIELD-SYMBOLS <temp129> LIKE LINE OF lt_path.
      DATA temp130 LIKE sy-tabix.
      DATA lv_fix_path LIKE LINE OF lt_path.
      FIELD-SYMBOLS <temp131> LIKE LINE OF lt_path.
      DATA temp132 LIKE sy-tabix.
      DATA temp119 TYPE xsdboolean.
    FIELD-SYMBOLS <temp541> LIKE LINE OF lt_path.
    DATA temp542 LIKE sy-tabix.
    CREATE OBJECT lo_app TYPE ltcl_app_tm_pop.

    CLEAR temp538.
    INSERT `MANDT` INTO TABLE temp538.
    INSERT `MATNR` INTO TABLE temp538.
    INSERT `ERSDA` INTO TABLE temp538.
    INSERT `ZZ_A_RATHER_LONG_FIELD_NAME_XX` INTO TABLE temp538.
    INSERT `/CWM/XCWMAT` INTO TABLE temp538.
    INSERT `/CWM/VALUM` INTO TABLE temp538.
    INSERT `/VSO/R_TILT_IND` INTO TABLE temp538.
    INSERT `/SAPMP/KADU` INTO TABLE temp538.
    lo_app->mt_field = temp538.
    DO 30 TIMES.

      temp540 = |F{ sy-index }|.
      INSERT temp540 INTO TABLE lo_app->mt_field.
    ENDDO.
    lo_app->build( ).

    CREATE OBJECT lo_cont TYPE z2ui5_cl_ui5_app_cont.
    lo_cont->mo_app = lo_app.


    lt_path = tm_pop_bind( io_app  = lo_app
                                 io_cont = lo_cont ).


    CREATE OBJECT lo_model TYPE z2ui5_cl_ui5_srv_model EXPORTING attri = lo_cont->mt_attri app = lo_app.

    lv_act = lo_model->main_json_stringify( ).

    " the document the general road writes, and no token left in it
    cl_abap_unit_assert=>assert_equals( exp = tm_pop_ajson_text( lo_cont )
                                        act = lv_act ).

    temp118 = boolc( lv_act CS `z2ui5-fast-` ).
    cl_abap_unit_assert=>assert_equals( exp = abap_false act = temp118 ).

    " every binding path is one UI5 resolves - no empty segment, at which
    " sap.ui.model.json.JSONModel stops walking - and finds the field's
    " value and its fixed values in the document

    li_doc = z2ui5_cl_ui5_ajs=>parse( lv_act ).

    LOOP AT lo_app->mt_field INTO lv_field.



      temp130 = sy-tabix.
      READ TABLE lt_path INDEX 2 * sy-tabix - 1 ASSIGNING <temp129>.
      sy-tabix = temp130.
      IF sy-subrc <> 0.
        ASSERT 1 = 0.
      ENDIF.
      lv_val_path = <temp129>.



      temp132 = sy-tabix.
      READ TABLE lt_path INDEX 2 * sy-tabix ASSIGNING <temp131>.
      sy-tabix = temp132.
      IF sy-subrc <> 0.
        ASSERT 1 = 0.
      ENDIF.
      lv_fix_path = <temp131>.

      temp119 = boolc( lv_val_path CS `//` OR lv_fix_path CS `//` ).
      cl_abap_unit_assert=>assert_equals( exp = abap_false act = temp119
                                         msg = |empty path segment for { lv_field }| ).
      cl_abap_unit_assert=>assert_equals( exp = |v-{ lv_field }|
                                          act = li_doc->get_string( lv_val_path )
                                          msg = |value of { lv_field }| ).
      cl_abap_unit_assert=>assert_equals( exp = |a of { lv_field }|
                                          act = li_doc->get_string( |{ lv_fix_path }/1/DESCR| )
                                          msg = |fixed values of { lv_field }| ).
    ENDLOOP.


    temp542 = sy-tabix.
    READ TABLE lt_path INDEX 10 ASSIGNING <temp541>.
    sy-tabix = temp542.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `/MS_FIXVAL/CWM/XCWMAT`
                                        act = <temp541> ).

  ENDMETHOD.

  METHOD tm_pop_legacy_double_slash.

    " a session started before the fix: its draft keeps the client names
    " the bind wrote then (main_attri_db_load takes name_client over), with
    " the empty segment ajson files under a path no parent walks. Not a
    " fast path case - the general road, which writes what it always wrote
    DATA lo_app TYPE REF TO ltcl_app_tm_pop.
    DATA temp543 TYPE string_table.
    DATA lo_cont TYPE REF TO z2ui5_cl_ui5_app_cont.
    DATA temp545 LIKE LINE OF lo_cont->mt_attri->*.
    DATA lr_attri LIKE REF TO temp545.
    DATA lo_model TYPE REF TO z2ui5_cl_ui5_srv_model.
    DATA lv_act TYPE string.
    DATA temp120 TYPE xsdboolean.
    DATA temp121 TYPE xsdboolean.
    CREATE OBJECT lo_app TYPE ltcl_app_tm_pop.

    CLEAR temp543.
    INSERT `MATNR` INTO TABLE temp543.
    INSERT `/CWM/XCWMAT` INTO TABLE temp543.
    lo_app->mt_field = temp543.
    lo_app->build( ).

    CREATE OBJECT lo_cont TYPE z2ui5_cl_ui5_app_cont.
    lo_cont->mo_app = lo_app.
    tm_pop_bind( io_app  = lo_app
                 io_cont = lo_cont ).


    LOOP AT lo_cont->mt_attri->* REFERENCE INTO lr_attri "#EC CI_SORTSEQ
         WHERE bind = abap_true.
      lr_attri->name_client = replace( val  = lr_attri->name_client
                                       sub  = `/CWM/`
                                       with = `//CWM/` ).
    ENDLOOP.


    CREATE OBJECT lo_model TYPE z2ui5_cl_ui5_srv_model EXPORTING attri = lo_cont->mt_attri app = lo_app.

    lv_act = lo_model->main_json_stringify( ).

    cl_abap_unit_assert=>assert_equals( exp = tm_pop_ajson_text( lo_cont )
                                        act = lv_act ).

    temp120 = boolc( lv_act CS `z2ui5-fast-` ).
    cl_abap_unit_assert=>assert_equals( exp = abap_false act = temp120 ).

    temp121 = boolc( lv_act CS `"MATNR":[{"DESCR":"a of MATNR"` ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp121 ).

  ENDMETHOD.

  METHOD tm_pop_token_overwritten.

    " a field named like the namespace of another: /CWM/XCWMAT sorts before
    " CWM and sits below it in the document, so the later set of CWM
    " replaces the node holding the first token. The general road loses
    " that value the same way - the document is the same, not an error
    DATA lo_app TYPE REF TO ltcl_app_tm_pop.
    DATA temp546 TYPE string_table.
    DATA lo_cont TYPE REF TO z2ui5_cl_ui5_app_cont.
    DATA lo_model TYPE REF TO z2ui5_cl_ui5_srv_model.
    DATA lv_act TYPE string.
    DATA temp122 TYPE xsdboolean.
    DATA temp123 TYPE xsdboolean.
    CREATE OBJECT lo_app TYPE ltcl_app_tm_pop.

    CLEAR temp546.
    INSERT `/CWM/XCWMAT` INTO TABLE temp546.
    INSERT `CWM` INTO TABLE temp546.
    INSERT `MATNR` INTO TABLE temp546.
    lo_app->mt_field = temp546.
    lo_app->build( ).

    CREATE OBJECT lo_cont TYPE z2ui5_cl_ui5_app_cont.
    lo_cont->mo_app = lo_app.
    tm_pop_bind( io_app  = lo_app
                 io_cont = lo_cont ).


    CREATE OBJECT lo_model TYPE z2ui5_cl_ui5_srv_model EXPORTING attri = lo_cont->mt_attri app = lo_app.

    lv_act = lo_model->main_json_stringify( ).

    cl_abap_unit_assert=>assert_equals( exp = tm_pop_ajson_text( lo_cont )
                                        act = lv_act ).

    temp122 = boolc( lv_act CS `z2ui5-fast-` ).
    cl_abap_unit_assert=>assert_equals( exp = abap_false act = temp122 ).

    temp123 = boolc( lv_act CS `"CWM":[{"DESCR":"a of CWM"` ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp123 ).

  ENDMETHOD.

  METHOD ns_setup.
    DATA lo_bind TYPE REF TO z2ui5_cl_ui5_srv_bind.
    DATA temp548 TYPE z2ui5_if_ui5_types=>ty_s_bind_config.
    DATA temp549 TYPE z2ui5_if_ui5_types=>ty_s_bind_config.

    CREATE OBJECT eo_app.
    eo_app->build( ).
    CREATE OBJECT eo_cont.
    eo_cont->mo_app = eo_app.

    CREATE OBJECT lo_bind TYPE z2ui5_cl_ui5_srv_bind EXPORTING APP = eo_cont.

    CLEAR temp548.
    temp548-path_only = abap_true.
    INSERT lo_bind->main( val    = eo_app->mr_tab
                          config = temp548 ) INTO TABLE et_path.

    CLEAR temp549.
    temp549-path_only = abap_true.
    INSERT lo_bind->main( val    = eo_app->mr_deep
                          config = temp549 ) INTO TABLE et_path.

  ENDMETHOD.

  METHOD ns_fast_path_grouped.

    DATA lo_app TYPE REF TO ltcl_app_ns.
    DATA lo_cont TYPE REF TO z2ui5_cl_ui5_app_cont.
    DATA lt_path TYPE string_table.
    DATA lo_model TYPE REF TO z2ui5_cl_ui5_srv_model.
    DATA lv_exp TYPE string.
    DATA li_tree TYPE REF TO z2ui5_cl_ui5_ajs.
    FIELD-SYMBOLS <tab> TYPE any.
    DATA li_doc TYPE REF TO z2ui5_cl_ui5_ajs.
    FIELD-SYMBOLS <temp550> LIKE LINE OF lt_path.
    DATA temp551 LIKE sy-tabix.
    ns_setup( IMPORTING eo_app  = lo_app
                        eo_cont = lo_cont
                        et_path = lt_path ).

    CREATE OBJECT lo_model TYPE z2ui5_cl_ui5_srv_model EXPORTING attri = lo_cont->mt_attri app = lo_app.


    lv_exp = `[{"AA_FIRST":"A1","CWM":{"VALUM":10,"XCWMAT":"X1"},"MATNR":"M1","VSO":{"R_TILT":"T1"}},` &&
                   `{"AA_FIRST":"A2","CWM":{"VALUM":20,"XCWMAT":"X2"},"MATNR":"M2","VSO":{"R_TILT":"T2"}}]`.
    cl_abap_unit_assert=>assert_equals( exp = lv_exp
                                        act = lo_model->attri_json_fast( lo_app->mr_tab ) ).

    " the general road writes the same text for the same table

    li_tree = z2ui5_cl_ui5_ajs=>create_empty( ii_custom_mapping = z2ui5_cl_ui5_util_json_fl=>mapper_upper( ) ).

    ASSIGN lo_app->mr_tab->* TO <tab>.
    li_tree->set( iv_ignore_empty = abap_false
                  iv_path         = `/`
                  iv_val          = <tab> ).
    cl_abap_unit_assert=>assert_equals( exp = lv_exp
                                        act = z2ui5_cl_ui5_srv_model=>json_ns_text( li_tree->mt_json_tree ) ).

    " and the model carries it, a relative row path resolves in it

    li_doc = z2ui5_cl_ui5_ajs=>parse( lo_model->main_json_stringify( ) ).


    temp551 = sy-tabix.
    READ TABLE lt_path INDEX 1 ASSIGNING <temp550>.
    sy-tabix = temp551.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `X2`
                                        act = li_doc->get_string( |{ <temp550> }/2/CWM/XCWMAT| ) ).
    cl_abap_unit_assert=>assert_equals( exp = `CWM/XCWMAT`
                                        act = z2ui5_cl_ui5_view_builder=>component_path( `/CWM/XCWMAT` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `MATNR`
                                        act = z2ui5_cl_ui5_view_builder=>component_path( `MATNR` ) ).

  ENDMETHOD.

  METHOD ns_struct_grouped.

    DATA lo_app TYPE REF TO ltcl_app_ns.
    CREATE OBJECT lo_app TYPE ltcl_app_ns.
    lo_app->build( ).
    cl_abap_unit_assert=>assert_equals(
        exp = `{"AA_FIRST":"A1","CWM":{"VALUM":10,"XCWMAT":"X1"},"MATNR":"M1","VSO":{"R_TILT":"T1"}}`
        act = mo_model->attri_json_fast( lo_app->mr_row ) ).

  ENDMETHOD.

  METHOD ns_general_road_grouped.

    DATA lo_app TYPE REF TO ltcl_app_ns.
    DATA lo_cont TYPE REF TO z2ui5_cl_ui5_app_cont.
    DATA lt_path TYPE string_table.
    DATA lo_model TYPE REF TO z2ui5_cl_ui5_srv_model.
    DATA lv_act TYPE string.
    DATA temp124 TYPE xsdboolean.
    DATA temp125 TYPE xsdboolean.
    DATA temp126 TYPE xsdboolean.
    DATA temp127 TYPE xsdboolean.
    DATA li_doc TYPE REF TO z2ui5_cl_ui5_ajs.
    FIELD-SYMBOLS <temp552> LIKE LINE OF lt_path.
    DATA temp553 LIKE sy-tabix.
    ns_setup( IMPORTING eo_app  = lo_app
                        eo_cont = lo_cont
                        et_path = lt_path ).

    CREATE OBJECT lo_model TYPE z2ui5_cl_ui5_srv_model EXPORTING attri = lo_cont->mt_attri app = lo_app.
    " a deep row is no fast path case
    cl_abap_unit_assert=>assert_initial( lo_model->attri_json_fast( lo_app->mr_deep ) ).


    lv_act = lo_model->main_json_stringify( ).

    temp124 = boolc( lv_act CS `z2ui5-fast-` ).
    cl_abap_unit_assert=>assert_equals( exp = abap_false act = temp124 ).

    temp125 = boolc( lv_act CS `"/` ).
    cl_abap_unit_assert=>assert_equals( exp = abap_false act = temp125 ).

    temp126 = boolc( lv_act CS `[{"ABC":{"ITEMS":[{"AA_FIRST":"A1","CWM":{"VALUM":10,"XCWMAT":"X1"},"MATNR":"M1","VSO":{"R_TILT":"T1"}},` ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp126 ).

    temp127 = boolc( lv_act CS `],"NOTE":"note"},"ID":1}]` ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp127 ).

    li_doc = z2ui5_cl_ui5_ajs=>parse( lv_act ).


    temp553 = sy-tabix.
    READ TABLE lt_path INDEX 2 ASSIGNING <temp552>.
    sy-tabix = temp553.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `X2`
                                        act = li_doc->get_string( |{ <temp552> }/1/ABC/ITEMS/2/CWM/XCWMAT| ) ).

  ENDMETHOD.

  METHOD ns_text_plain_identical.

    " the renderer of the general road writes what ajson writes for a value
    " without a namespace - the shapes the identity tests above hold
    DATA lt_rows TYPE ltcl_06_fast_json=>ty_t_kinds.
    DATA li_tree TYPE REF TO z2ui5_cl_ui5_ajs.
    DATA lt_nested TYPE ty_t_nested.
    DATA temp554 TYPE ltcl_06_fast_json=>ty_t_nested.
    DATA temp555 LIKE LINE OF temp554.
    DATA temp556 LIKE REF TO lt_rows.
    lt_rows = rows( ).

    li_tree = z2ui5_cl_ui5_ajs=>create_empty( ii_custom_mapping = z2ui5_cl_ui5_util_json_fl=>mapper_upper( ) ).
    li_tree->set( iv_ignore_empty = abap_false
                  iv_path         = `/`
                  iv_val          = lt_rows ).
    cl_abap_unit_assert=>assert_equals( exp = li_tree->stringify( )
                                        act = z2ui5_cl_ui5_srv_model=>json_ns_text( li_tree->mt_json_tree ) ).



    CLEAR temp554.

    temp555-id = 1.
    INSERT temp555 INTO TABLE temp554.
    temp555-id = 2.
    INSERT temp555 INTO TABLE temp554.
    lt_nested = temp554.
    li_tree = z2ui5_cl_ui5_ajs=>create_empty( ii_custom_mapping = z2ui5_cl_ui5_util_json_fl=>mapper_upper( ) ).
    li_tree->set( iv_ignore_empty = abap_false
                  iv_path         = `/`
                  iv_val          = lt_nested ).
    cl_abap_unit_assert=>assert_equals( exp = li_tree->stringify( )
                                        act = z2ui5_cl_ui5_srv_model=>json_ns_text( li_tree->mt_json_tree ) ).

    " and the plain table on the fast path is the text it always was

    GET REFERENCE OF lt_rows INTO temp556.
cl_abap_unit_assert=>assert_equals( exp = ajson_text( lt_rows )
                                        act = mo_model->attri_json_fast( temp556 ) ).

  ENDMETHOD.

  METHOD ns_omit_initial_grouped.

    " omit_initial is a filter on the compatibility branch - the namespace
    " is grouped there too, the initial cells left out (the test filter
    " drops an initial string; a namespace left without a member is gone)
    DATA lo_app TYPE REF TO ltcl_app_ns.
    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <row> TYPE any.
    DATA temp128 TYPE xsdboolean.
    FIELD-SYMBOLS <cell> TYPE any.
    DATA lo_cont TYPE REF TO z2ui5_cl_ui5_app_cont.
    DATA lo_client TYPE REF TO z2ui5_cl_ui5_srv_bind.
    DATA temp557 TYPE z2ui5_if_ui5_types=>ty_s_bind_config.
    DATA lo_model TYPE REF TO z2ui5_cl_ui5_srv_model.
    DATA lv_act TYPE string.
    DATA temp129 TYPE xsdboolean.
    CREATE OBJECT lo_app TYPE ltcl_app_ns.
    lo_app->build( ).

    ASSIGN lo_app->mr_tab->* TO <tab>.
    DELETE <tab> FROM 2.
    " the row first: the transpiled runtime assigns the ROW for a component
    " of a table expression (ASSIGN COMPONENT ... OF STRUCTURE <tab>[ 1 ])

    READ TABLE <tab> INDEX 1 ASSIGNING <row>.

    temp128 = boolc( <row> IS ASSIGNED ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp128 ).

    ASSIGN COMPONENT `/CWM/XCWMAT` OF STRUCTURE <row> TO <cell>.
    cl_abap_unit_assert=>assert_subrc( ).
    CLEAR <cell>.
    ASSIGN COMPONENT `/VSO/R_TILT` OF STRUCTURE <row> TO <cell>.
    cl_abap_unit_assert=>assert_subrc( ).
    CLEAR <cell>.

    CREATE OBJECT lo_cont TYPE z2ui5_cl_ui5_app_cont.
    lo_cont->mo_app = lo_app.

    CREATE OBJECT lo_client TYPE z2ui5_cl_ui5_srv_bind EXPORTING APP = lo_cont.

    CLEAR temp557.
    temp557-path_only = abap_true.
    CREATE OBJECT temp557-custom_filter TYPE ltcl_shp_filter.
    lo_client->main( val    = lo_app->mr_tab
                     config = temp557 ).

    CREATE OBJECT lo_model TYPE z2ui5_cl_ui5_srv_model EXPORTING attri = lo_cont->mt_attri app = lo_app.

    lv_act = lo_model->main_json_stringify( ).

    temp129 = boolc( lv_act CS `[{"AA_FIRST":"A1","CWM":{"VALUM":10},"MATNR":"M1"}]` ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true
        act = temp129
        msg = lv_act ).

  ENDMETHOD.

  METHOD ns_delta_applied.

    DATA lo_app TYPE REF TO ltcl_app_ns.
    DATA lo_cont TYPE REF TO z2ui5_cl_ui5_app_cont.
    DATA lt_path TYPE string_table.
    DATA lo_model TYPE REF TO z2ui5_cl_ui5_srv_model.
    DATA temp558 TYPE REF TO z2ui5_if_ui5_ajs.
    DATA li_front LIKE temp558.
    FIELD-SYMBOLS <temp559> LIKE LINE OF lt_path.
    DATA temp560 LIKE sy-tabix.
    FIELD-SYMBOLS <temp561> LIKE LINE OF lt_path.
    DATA temp562 LIKE sy-tabix.
    FIELD-SYMBOLS <temp563> LIKE LINE OF lt_path.
    DATA temp564 LIKE sy-tabix.
    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <row_1> TYPE any.
    FIELD-SYMBOLS <row_2> TYPE any.
    FIELD-SYMBOLS <temp565> LIKE LINE OF lo_model->mt_skipped.
    DATA temp566 LIKE sy-tabix.
    FIELD-SYMBOLS <temp567> LIKE LINE OF lo_model->mt_skipped.
    DATA temp568 LIKE sy-tabix.
    ns_setup( IMPORTING eo_app  = lo_app
                        eo_cont = lo_cont
                        et_path = lt_path ).

    CREATE OBJECT lo_model TYPE z2ui5_cl_ui5_srv_model EXPORTING attri = lo_cont->mt_attri app = lo_app.
    " what Lib.buildDeltaFromPaths sends for an edit at /<table>/1/CWM/XCWMAT:
    " the row's member CWM whole, read from the client's model

    temp558 ?= z2ui5_cl_ui5_ajs=>create_empty( ).

    li_front = temp558.


    temp560 = sy-tabix.
    READ TABLE lt_path INDEX 1 ASSIGNING <temp559>.
    sy-tabix = temp560.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    li_front->set( iv_path = |{ <temp559> }/__delta/1/CWM/XCWMAT|
                   iv_val  = `edited` ).


    temp562 = sy-tabix.
    READ TABLE lt_path INDEX 1 ASSIGNING <temp561>.
    sy-tabix = temp562.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    li_front->set( iv_path = |{ <temp561> }/__delta/1/CWM/VALUM|
                   iv_val  = `abc` ).


    temp564 = sy-tabix.
    READ TABLE lt_path INDEX 1 ASSIGNING <temp563>.
    sy-tabix = temp564.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    li_front->set( iv_path = |{ <temp563> }/__delta/1/MATNR|
                   iv_val  = `M-edited` ).
    lo_model->main_json_to_attri( li_front ).


    ASSIGN lo_app->mr_tab->* TO <tab>.

    READ TABLE <tab> INDEX 1 ASSIGNING <row_1>.

    READ TABLE <tab> INDEX 2 ASSIGNING <row_2>.
    cl_abap_unit_assert=>assert_equals( exp = `edited`
                                        act = ltcl_app_ns=>cell( is_row  = <row_2>
                                                                 iv_name = `/CWM/XCWMAT` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `M-edited`
                                        act = ltcl_app_ns=>cell( is_row  = <row_2>
                                                                 iv_name = `MATNR` ) ).
    " row 1 untouched
    cl_abap_unit_assert=>assert_equals( exp = `X1`
                                        act = ltcl_app_ns=>cell( is_row  = <row_1>
                                                                 iv_name = `/CWM/XCWMAT` ) ).
    " a refused cell is traced under the component's own name, its old
    " value kept
    cl_abap_unit_assert=>assert_equals( exp = `20`
                                        act = condense( ltcl_app_ns=>cell( is_row  = <row_2>
                                                                           iv_name = `/CWM/VALUM` ) ) ).
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( lo_model->mt_skipped ) ).


    temp566 = sy-tabix.
    READ TABLE lo_model->mt_skipped INDEX 1 ASSIGNING <temp565>.
    sy-tabix = temp566.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `/CWM/VALUM`
                                        act = <temp565>-field ).


    temp568 = sy-tabix.
    READ TABLE lo_model->mt_skipped INDEX 1 ASSIGNING <temp567>.
    sy-tabix = temp568.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = <temp567>-row ).

  ENDMETHOD.

  METHOD ns_whole_value_applied.

    " the table sent whole - what the client ships for an edit it cannot
    " express as a row delta (Lib.buildDeltaFromPaths): the array as the
    " model holds it, the namespaces as levels of the rows
    DATA lo_app TYPE REF TO ltcl_app_ns.
    DATA lo_cont TYPE REF TO z2ui5_cl_ui5_app_cont.
    DATA lt_path TYPE string_table.
    DATA lo_model TYPE REF TO z2ui5_cl_ui5_srv_model.
    DATA li_out TYPE REF TO z2ui5_cl_ui5_ajs.
    DATA temp569 TYPE REF TO z2ui5_if_ui5_ajs.
    DATA li_front LIKE temp569.
    FIELD-SYMBOLS <temp570> LIKE LINE OF lt_path.
    DATA temp571 LIKE sy-tabix.
    FIELD-SYMBOLS <temp133> LIKE LINE OF lt_path.
    DATA temp134 LIKE sy-tabix.
    FIELD-SYMBOLS <temp572> LIKE LINE OF lt_path.
    DATA temp573 LIKE sy-tabix.
    FIELD-SYMBOLS <temp574> LIKE LINE OF lt_path.
    DATA temp575 LIKE sy-tabix.
    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <row_1> TYPE any.
    FIELD-SYMBOLS <row_2> TYPE any.
    ns_setup( IMPORTING eo_app  = lo_app
                        eo_cont = lo_cont
                        et_path = lt_path ).

    CREATE OBJECT lo_model TYPE z2ui5_cl_ui5_srv_model EXPORTING attri = lo_cont->mt_attri app = lo_app.

    li_out = z2ui5_cl_ui5_ajs=>parse( lo_model->main_json_stringify( ) ).

    temp569 ?= z2ui5_cl_ui5_ajs=>create_empty( ).

    li_front = temp569.


    temp571 = sy-tabix.
    READ TABLE lt_path INDEX 1 ASSIGNING <temp570>.
    sy-tabix = temp571.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.


    temp134 = sy-tabix.
    READ TABLE lt_path INDEX 1 ASSIGNING <temp133>.
    sy-tabix = temp134.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    li_front->set( iv_path = <temp570>
                   iv_val  = li_out->slice( <temp133> ) ).


    temp573 = sy-tabix.
    READ TABLE lt_path INDEX 1 ASSIGNING <temp572>.
    sy-tabix = temp573.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    li_front->set( iv_path = |{ <temp572> }/1/CWM/XCWMAT|
                   iv_val  = `whole` ).


    temp575 = sy-tabix.
    READ TABLE lt_path INDEX 1 ASSIGNING <temp574>.
    sy-tabix = temp575.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    li_front->set( iv_path = |{ <temp574> }/2/VSO/R_TILT|
                   iv_val  = `tilt` ).
    lo_model->main_json_to_attri( li_front ).


    ASSIGN lo_app->mr_tab->* TO <tab>.

    READ TABLE <tab> INDEX 1 ASSIGNING <row_1>.

    READ TABLE <tab> INDEX 2 ASSIGNING <row_2>.
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( <tab> ) ).
    cl_abap_unit_assert=>assert_equals( exp = `whole`
                                        act = ltcl_app_ns=>cell( is_row  = <row_1>
                                                                 iv_name = `/CWM/XCWMAT` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `tilt`
                                        act = ltcl_app_ns=>cell( is_row  = <row_2>
                                                                 iv_name = `/VSO/R_TILT` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `T1`
                                        act = ltcl_app_ns=>cell( is_row  = <row_1>
                                                                 iv_name = `/VSO/R_TILT` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `20`
                                        act = condense( ltcl_app_ns=>cell( is_row  = <row_2>
                                                                           iv_name = `/CWM/VALUM` ) ) ).
    cl_abap_unit_assert=>assert_equals( exp = `M2`
                                        act = ltcl_app_ns=>cell( is_row  = <row_2>
                                                                 iv_name = `MATNR` ) ).
    cl_abap_unit_assert=>assert_initial( lo_model->mt_skipped ).

  ENDMETHOD.

  METHOD ns_deep_whole_applied.

    " a nested table edited (the cell sits below a namespaced table of the
    " row - the client ships the row's member ABC whole) comes back down
    " to the namespaced cell of the inner row
    DATA lo_app TYPE REF TO ltcl_app_ns.
    DATA lo_cont TYPE REF TO z2ui5_cl_ui5_app_cont.
    DATA lt_path TYPE string_table.
    DATA lo_model TYPE REF TO z2ui5_cl_ui5_srv_model.
    DATA li_out TYPE REF TO z2ui5_cl_ui5_ajs.
    DATA temp576 TYPE REF TO z2ui5_if_ui5_ajs.
    DATA li_front LIKE temp576.
    FIELD-SYMBOLS <temp577> LIKE LINE OF lt_path.
    DATA temp578 LIKE sy-tabix.
    FIELD-SYMBOLS <temp135> LIKE LINE OF lt_path.
    DATA temp136 LIKE sy-tabix.
    FIELD-SYMBOLS <temp579> LIKE LINE OF lt_path.
    DATA temp580 LIKE sy-tabix.
    FIELD-SYMBOLS <temp581> LIKE LINE OF lt_path.
    DATA temp582 LIKE sy-tabix.
    FIELD-SYMBOLS <deep> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <items> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <deep_row> TYPE any.
    DATA temp130 TYPE xsdboolean.
    FIELD-SYMBOLS <item_1> TYPE any.
    FIELD-SYMBOLS <item_2> TYPE any.
    ns_setup( IMPORTING eo_app  = lo_app
                        eo_cont = lo_cont
                        et_path = lt_path ).

    CREATE OBJECT lo_model TYPE z2ui5_cl_ui5_srv_model EXPORTING attri = lo_cont->mt_attri app = lo_app.

    li_out = z2ui5_cl_ui5_ajs=>parse( lo_model->main_json_stringify( ) ).

    temp576 ?= z2ui5_cl_ui5_ajs=>create_empty( ).

    li_front = temp576.


    temp578 = sy-tabix.
    READ TABLE lt_path INDEX 2 ASSIGNING <temp577>.
    sy-tabix = temp578.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.


    temp136 = sy-tabix.
    READ TABLE lt_path INDEX 2 ASSIGNING <temp135>.
    sy-tabix = temp136.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    li_front->set( iv_path = |{ <temp577> }/__delta/0/ABC|
                   iv_val  = li_out->slice( |{ <temp135> }/1/ABC| ) ).


    temp580 = sy-tabix.
    READ TABLE lt_path INDEX 2 ASSIGNING <temp579>.
    sy-tabix = temp580.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    li_front->set( iv_path = |{ <temp579> }/__delta/0/ABC/ITEMS/2/CWM/XCWMAT|
                   iv_val  = `deep` ).


    temp582 = sy-tabix.
    READ TABLE lt_path INDEX 2 ASSIGNING <temp581>.
    sy-tabix = temp582.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    li_front->set( iv_path = |{ <temp581> }/__delta/0/ABC/NOTE|
                   iv_val  = `note2` ).
    lo_model->main_json_to_attri( li_front ).



    ASSIGN lo_app->mr_deep->* TO <deep>.

    READ TABLE <deep> INDEX 1 ASSIGNING <deep_row>.

    temp130 = boolc( <deep_row> IS ASSIGNED ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp130 ).
    cl_abap_unit_assert=>assert_equals( exp = `note2`
                                        act = ltcl_app_ns=>cell( is_row  = <deep_row>
                                                                 iv_name = `/ABC/NOTE` ) ).
    ASSIGN COMPONENT `/ABC/ITEMS` OF STRUCTURE <deep_row> TO <items>.
    cl_abap_unit_assert=>assert_subrc( ).
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( <items> ) ).

    READ TABLE <items> INDEX 1 ASSIGNING <item_1>.

    READ TABLE <items> INDEX 2 ASSIGNING <item_2>.
    cl_abap_unit_assert=>assert_equals( exp = `deep`
                                        act = ltcl_app_ns=>cell( is_row  = <item_2>
                                                                 iv_name = `/CWM/XCWMAT` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `X1`
                                        act = ltcl_app_ns=>cell( is_row  = <item_1>
                                                                 iv_name = `/CWM/XCWMAT` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `T1`
                                        act = ltcl_app_ns=>cell( is_row  = <item_1>
                                                                 iv_name = `/VSO/R_TILT` ) ).
    cl_abap_unit_assert=>assert_initial( lo_model->mt_skipped ).

  ENDMETHOD.

  METHOD ns_cell_bind_path.

    " _bind( val = <row>-/cwm/xcwmat tab = ... tab_index = 2 ): the cell
    " path carries the namespace as a level, as the model does
    DATA lo_app TYPE REF TO ltcl_app_ns.
    DATA lo_cont TYPE REF TO z2ui5_cl_ui5_app_cont.
    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <row> TYPE any.
    DATA temp131 TYPE xsdboolean.
    FIELD-SYMBOLS <cell> TYPE any.
    DATA lo_bind TYPE REF TO z2ui5_cl_ui5_srv_bind.
    DATA temp583 TYPE REF TO data.
DATA temp137 TYPE z2ui5_if_ui5_types=>ty_s_bind_config.
DATA lv_path TYPE string.
    DATA temp584 TYPE z2ui5_if_ui5_types=>ty_s_bind_config.
    DATA lv_tab TYPE string.
    DATA lo_model TYPE REF TO z2ui5_cl_ui5_srv_model.
    DATA li_doc TYPE REF TO z2ui5_cl_ui5_ajs.
    CREATE OBJECT lo_app TYPE ltcl_app_ns.
    lo_app->build( ).

    CREATE OBJECT lo_cont TYPE z2ui5_cl_ui5_app_cont.
    lo_cont->mo_app = lo_app.

    ASSIGN lo_app->mr_tab->* TO <tab>.

    READ TABLE <tab> INDEX 2 ASSIGNING <row>.

    temp131 = boolc( <row> IS ASSIGNED ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp131 ).

    ASSIGN COMPONENT `/CWM/XCWMAT` OF STRUCTURE <row> TO <cell>.
    cl_abap_unit_assert=>assert_subrc( ).

    CREATE OBJECT lo_bind TYPE z2ui5_cl_ui5_srv_bind EXPORTING APP = lo_cont.

GET REFERENCE OF <cell> INTO temp583.

CLEAR temp137.
temp137-tab = lo_app->mr_tab.
temp137-tab_index = 2.
temp137-path_only = abap_true.

lv_path = lo_bind->main( val    = temp583
                                   config = temp137 ).

    CLEAR temp584.
    temp584-path_only = abap_true.

    lv_tab = lo_bind->main( val    = lo_app->mr_tab
                                  config = temp584 ).
    " UI5 counts the rows from 0
    cl_abap_unit_assert=>assert_equals( exp = |{ lv_tab }/1/CWM/XCWMAT|
                                        act = lv_path ).

    " and the model holds the cell there - ajson counts from 1

    CREATE OBJECT lo_model TYPE z2ui5_cl_ui5_srv_model EXPORTING attri = lo_cont->mt_attri app = lo_app.

    li_doc = z2ui5_cl_ui5_ajs=>parse( lo_model->main_json_stringify( ) ).
    cl_abap_unit_assert=>assert_equals( exp = `X2`
                                        act = li_doc->get_string( |{ lv_tab }/2/CWM/XCWMAT| ) ).

  ENDMETHOD.


ENDCLASS.


INTERFACE lif_intf_attr.
  TYPES:
    BEGIN OF ty_s_row,
      name TYPE string,
      qty  TYPE i,
    END OF ty_s_row.
  TYPES ty_t_row TYPE STANDARD TABLE OF ty_s_row WITH DEFAULT KEY.
  CONSTANTS c_const TYPE string VALUE `C` ##NEEDED.
  DATA mv_intf TYPE string.
  DATA ms_intf TYPE ty_s_row.
  DATA mt_intf TYPE ty_t_row.
  DATA mr_intf TYPE REF TO data.
ENDINTERFACE.

INTERFACE lif_intf_alias.
  DATA mv_shared TYPE string.
ENDINTERFACE.

CLASS ltcl_intf_impl DEFINITION FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES lif_intf_attr.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS ltcl_intf_impl IMPLEMENTATION.
ENDCLASS.

CLASS ltcl_app_intf DEFINITION FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.
    INTERFACES lif_intf_attr.
    INTERFACES lif_intf_alias.
    ALIASES mv_shared FOR lif_intf_alias~mv_shared.
    DATA mv_own   TYPE string.
    DATA mi_state TYPE REF TO lif_intf_attr.
    DATA mo_state TYPE REF TO ltcl_intf_impl.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS ltcl_app_intf IMPLEMENTATION.

  METHOD z2ui5_if_app~main.
  ENDMETHOD.

ENDCLASS.


" An attribute an INTERFACE declares binds (decided 2026-11-24, it raised
" BINDING_ERROR before): the app's own `LIF~ATTR`, one reached through an
" interface reference without ALIASES (`mi_state->attr`) or through an
" object (`mo_state->lif~attr`). The client path keeps the `~` - no class
" attribute can carry it, so the name cannot meet one; a namespaced
" interface becomes a level like every namespace (`/NS/IF~ATTR`). The
" interface rows are dissolved only once a binding misses every class
" row (main_attri_search): an app that never binds one keeps the draft and
" the model it had
CLASS ltcl_07_intf_attr DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    DATA mo_app  TYPE REF TO ltcl_app_intf.
    DATA mo_cont TYPE REF TO z2ui5_cl_ui5_app_cont.
    DATA mo_bind TYPE REF TO z2ui5_cl_ui5_srv_bind.

    METHODS setup.
    METHODS bind
      IMPORTING
        ir_val        TYPE REF TO data
      RETURNING
        VALUE(result) TYPE string.
    METHODS model
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_ui5_srv_model.
    METHODS intf_rows
      RETURNING
        VALUE(result) TYPE i.

    METHODS intf_attribute_bound FOR TESTING RAISING cx_static_check.
    METHODS class_attribute_stays_lean FOR TESTING RAISING cx_static_check.
    METHODS intf_reference_bound FOR TESTING RAISING cx_static_check.
    METHODS intf_struct_and_table FOR TESTING RAISING cx_static_check.
    METHODS intf_model_out_and_back FOR TESTING RAISING cx_static_check.
    METHODS intf_namespaced_level FOR TESTING RAISING cx_static_check.
    METHODS alias_and_intf_one_row FOR TESTING RAISING cx_static_check.
    " the alias spelling of MV_SHARED, in a method of its own: a method that
    " names one component both ways draws the extended check's "accessed in
    " the current context under a different name"
    METHODS alias_ref
      RETURNING
        VALUE(result) TYPE REF TO string.
    METHODS alias_dedupe_by_reference FOR TESTING RAISING cx_static_check.
    METHODS intf_survives_refresh FOR TESTING RAISING cx_static_check.
    METHODS intf_dref_save_load FOR TESTING RAISING cx_static_check.
    METHODS no_attribute_still_refused FOR TESTING RAISING cx_static_check.
ENDCLASS.

CLASS ltcl_07_intf_attr IMPLEMENTATION.

  METHOD setup.

    CREATE OBJECT mo_app.
    CREATE OBJECT mo_app->mo_state.
    CREATE OBJECT mo_app->mi_state TYPE ltcl_intf_impl.
    CREATE OBJECT mo_cont.
    mo_cont->mo_app = mo_app.
    CREATE OBJECT mo_bind EXPORTING APP = mo_cont.

  ENDMETHOD.

  METHOD bind.

    DATA temp585 TYPE z2ui5_if_ui5_types=>ty_s_bind_config.
    CLEAR temp585.
    temp585-path_only = abap_true.
    result = mo_bind->main( val    = ir_val
                            config = temp585 ).

  ENDMETHOD.

  METHOD model.

    CREATE OBJECT result TYPE z2ui5_cl_ui5_srv_model EXPORTING attri = mo_cont->mt_attri app = mo_app.

  ENDMETHOD.

  METHOD intf_rows.

    LOOP AT mo_cont->mt_attri->* TRANSPORTING NO FIELDS WHERE name CA `~`. "#EC CI_SORTSEQ
      result = result + 1.
    ENDLOOP.

  ENDMETHOD.

  METHOD intf_attribute_bound.

    DATA temp586 LIKE REF TO mo_app->mv_own.
    DATA temp587 LIKE REF TO mo_app->lif_intf_attr~mv_intf.
    DATA temp588 LIKE REF TO mo_app->lif_intf_attr~mv_intf.
    DATA temp589 LIKE REF TO mo_app->mv_own.
    GET REFERENCE OF mo_app->mv_own INTO temp586.
cl_abap_unit_assert=>assert_equals( exp = `/MV_OWN`
                                        act = bind( temp586 ) ).

    GET REFERENCE OF mo_app->lif_intf_attr~mv_intf INTO temp587.
cl_abap_unit_assert=>assert_equals( exp = `/LIF_INTF_ATTR~MV_INTF`
                                        act = bind( temp587 ) ).
    " a second bind finds the row the first one created

    GET REFERENCE OF mo_app->lif_intf_attr~mv_intf INTO temp588.
cl_abap_unit_assert=>assert_equals( exp = `/LIF_INTF_ATTR~MV_INTF`
                                        act = bind( temp588 ) ).
    " and the class attribute keeps its path

    GET REFERENCE OF mo_app->mv_own INTO temp589.
cl_abap_unit_assert=>assert_equals( exp = `/MV_OWN`
                                        act = bind( temp589 ) ).

  ENDMETHOD.

  METHOD class_attribute_stays_lean.

    " the app implements three interfaces - none of their attributes is
    " dissolved while nothing binds one
    DATA temp590 LIKE REF TO mo_app->mv_own.
    GET REFERENCE OF mo_app->mv_own INTO temp590.
bind( temp590 ).
    cl_abap_unit_assert=>assert_equals( exp = 0
                                        act = intf_rows( ) ).

  ENDMETHOD.

  METHOD intf_reference_bound.

    " a reference typed with the interface, no alias: the class of the
    " object behind it declares nothing of its own
    DATA temp591 LIKE REF TO mo_app->mi_state->mv_intf.
    DATA temp592 LIKE REF TO mo_app->mo_state->lif_intf_attr~mv_intf.
    GET REFERENCE OF mo_app->mi_state->mv_intf INTO temp591.
cl_abap_unit_assert=>assert_equals( exp = `/MI_STATE/LIF_INTF_ATTR~MV_INTF`
                                        act = bind( temp591 ) ).
    " an object reference, its interface attribute spelled out

    GET REFERENCE OF mo_app->mo_state->lif_intf_attr~mv_intf INTO temp592.
cl_abap_unit_assert=>assert_equals( exp = `/MO_STATE/LIF_INTF_ATTR~MV_INTF`
                                        act = bind( temp592 ) ).

  ENDMETHOD.

  METHOD intf_struct_and_table.

    DATA temp593 LIKE REF TO mo_app->lif_intf_attr~ms_intf-name.
    DATA temp594 LIKE REF TO mo_app->lif_intf_attr~mt_intf.
    DATA temp132 TYPE xsdboolean.
    DATA temp23 LIKE sy-subrc.
    GET REFERENCE OF mo_app->lif_intf_attr~ms_intf-name INTO temp593.
cl_abap_unit_assert=>assert_equals( exp = `/LIF_INTF_ATTR~MS_INTF/NAME`
                                        act = bind( temp593 ) ).

    GET REFERENCE OF mo_app->lif_intf_attr~mt_intf INTO temp594.
cl_abap_unit_assert=>assert_equals( exp = `/LIF_INTF_ATTR~MT_INTF`
                                        act = bind( temp594 ) ).
    " a constant of the interface is no row


    READ TABLE mo_cont->mt_attri->* WITH KEY name = `LIF_INTF_ATTR~C_CONST` TRANSPORTING NO FIELDS.
    temp23 = sy-subrc.
    temp132 = boolc( temp23 = 0 ).
    cl_abap_unit_assert=>assert_equals( exp = abap_false act = temp132 ).

  ENDMETHOD.

  METHOD intf_model_out_and_back.
    DATA temp595 TYPE lif_intf_attr=>ty_t_row.
    DATA temp596 LIKE LINE OF temp595.
    DATA temp597 LIKE REF TO mo_app->lif_intf_attr~mv_intf.
    DATA temp598 LIKE REF TO mo_app->lif_intf_attr~mt_intf.
    DATA temp599 LIKE REF TO mo_app->mi_state->mv_intf.
    DATA li_doc TYPE REF TO z2ui5_cl_ui5_ajs.
    FIELD-SYMBOLS <temp600> LIKE LINE OF mo_app->lif_intf_attr~mt_intf.
    DATA temp601 LIKE sy-tabix.
    FIELD-SYMBOLS <temp602> LIKE LINE OF mo_app->lif_intf_attr~mt_intf.
    DATA temp603 LIKE sy-tabix.

    mo_app->lif_intf_attr~mv_intf = `out`.

    CLEAR temp595.

    temp596-name = `A`.
    temp596-qty = 1.
    INSERT temp596 INTO TABLE temp595.
    temp596-name = `B`.
    temp596-qty = 2.
    INSERT temp596 INTO TABLE temp595.
    mo_app->lif_intf_attr~mt_intf = temp595.
    mo_app->mi_state->mv_intf = `ref-out`.

    GET REFERENCE OF mo_app->lif_intf_attr~mv_intf INTO temp597.
bind( temp597 ).

    GET REFERENCE OF mo_app->lif_intf_attr~mt_intf INTO temp598.
bind( temp598 ).

    GET REFERENCE OF mo_app->mi_state->mv_intf INTO temp599.
bind( temp599 ).


    li_doc = z2ui5_cl_ui5_ajs=>parse( model( )->main_json_stringify( ) ).
    cl_abap_unit_assert=>assert_equals( exp = `out`
                                        act = li_doc->get_string( `/LIF_INTF_ATTR~MV_INTF` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `B`
                                        act = li_doc->get_string( `/LIF_INTF_ATTR~MT_INTF/2/NAME` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `ref-out`
                                        act = li_doc->get_string( `/MI_STATE/LIF_INTF_ATTR~MV_INTF` ) ).

    " back in: a whole value, a row delta and a value behind the reference
    model( )->main_json_to_attri( z2ui5_cl_ui5_ajs=>parse(
        `{"LIF_INTF_ATTR~MV_INTF":"in","LIF_INTF_ATTR~MT_INTF":{"__delta":{"1":{"QTY":7}}},` &&
        `"MI_STATE":{"LIF_INTF_ATTR~MV_INTF":"ref-in"}}` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `in`
                                        act = mo_app->lif_intf_attr~mv_intf ).


    temp601 = sy-tabix.
    READ TABLE mo_app->lif_intf_attr~mt_intf INDEX 2 ASSIGNING <temp600>.
    sy-tabix = temp601.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = 7
                                        act = <temp600>-qty ).


    temp603 = sy-tabix.
    READ TABLE mo_app->lif_intf_attr~mt_intf INDEX 1 ASSIGNING <temp602>.
    sy-tabix = temp603.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = <temp602>-qty ).
    cl_abap_unit_assert=>assert_equals( exp = `ref-in`
                                        act = mo_app->mi_state->mv_intf ).

  ENDMETHOD.

  METHOD intf_namespaced_level.
    DATA temp604 LIKE REF TO mo_app->lif_intf_attr~mv_intf.
    FIELD-SYMBOLS <temp605> LIKE LINE OF mo_cont->mt_attri->*.
    DATA temp606 LIKE sy-tabix.

    " a namespaced interface - `/NS/IF~ATTR`, no local interface can be
    " named so - becomes a level of the model like every namespace
    " (z2ui5_cl_ui5_srv_bind=>get_client_name, ltcl_01_path): the row is
    " given that client name, and the value travels out and back under it
    mo_app->lif_intf_attr~mv_intf = `out`.

    GET REFERENCE OF mo_app->lif_intf_attr~mv_intf INTO temp604.
bind( temp604 ).


    temp606 = sy-tabix.
    READ TABLE mo_cont->mt_attri->* WITH KEY name = `LIF_INTF_ATTR~MV_INTF` ASSIGNING <temp605>.
    sy-tabix = temp606.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    <temp605>-name_client = `/NS/LIF_INTF_ATTR~MV_INTF`.

    cl_abap_unit_assert=>assert_equals( exp = `{"NS":{"LIF_INTF_ATTR~MV_INTF":"out"}}`
                                        act = model( )->main_json_stringify( ) ).

    model( )->main_json_to_attri( z2ui5_cl_ui5_ajs=>parse( `{"NS":{"LIF_INTF_ATTR~MV_INTF":"in"}}` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `in`
                                        act = mo_app->lif_intf_attr~mv_intf ).

  ENDMETHOD.

  METHOD alias_and_intf_one_row.

    " the alias and the interface spelling are one data object: either
    " name answers the same path, and one row carries it. Which row is a
    " question of the runtime: a system lists the alias among the class's
    " attributes (`MV_SHARED`) and the interface spelling is left out
    " (diss_oref_intf, alias_dedupe_by_reference below); the transpiled
    " runtime lists no ALIASES at all, so there it is the interface row
    DATA temp607 LIKE REF TO mo_app->lif_intf_alias~mv_shared.
DATA lv_path TYPE string.
    DATA temp608 LIKE REF TO mo_app->lif_intf_attr~mv_intf.
    DATA temp609 LIKE REF TO mo_app->lif_intf_alias~mv_shared.
    DATA lv_alias_row TYPE abap_bool.
    DATA temp138 LIKE sy-subrc.
    DATA temp133 TYPE xsdboolean.
    DATA lv_intf_row TYPE abap_bool.
    DATA temp139 LIKE sy-subrc.
    DATA temp134 TYPE xsdboolean.
    DATA lr_alias TYPE REF TO string.
    DATA lv_member TYPE string.
    DATA li_doc TYPE REF TO z2ui5_cl_ui5_ajs.
    GET REFERENCE OF mo_app->lif_intf_alias~mv_shared INTO temp607.

lv_path = bind( temp607 ).
    cl_abap_unit_assert=>assert_equals( exp = lv_path
                                        act = bind( alias_ref( ) ) ).
    " with the interface rows on (another interface attribute was looked
    " for), still the same row

    GET REFERENCE OF mo_app->lif_intf_attr~mv_intf INTO temp608.
bind( temp608 ).

    GET REFERENCE OF mo_app->lif_intf_alias~mv_shared INTO temp609.
cl_abap_unit_assert=>assert_equals( exp = lv_path
                                        act = bind( temp609 ) ).
    cl_abap_unit_assert=>assert_equals( exp = lv_path
                                        act = bind( alias_ref( ) ) ).


    READ TABLE mo_cont->mt_attri->* WITH KEY name = `MV_SHARED` TRANSPORTING NO FIELDS.
    temp138 = sy-subrc.

    temp133 = boolc( temp138 = 0 ).
    lv_alias_row = temp133.


    READ TABLE mo_cont->mt_attri->* WITH KEY name = `LIF_INTF_ALIAS~MV_SHARED` TRANSPORTING NO FIELDS.
    temp139 = sy-subrc.

    temp134 = boolc( temp139 = 0 ).
    lv_intf_row = temp134.
    cl_abap_unit_assert=>assert_differs( exp = lv_alias_row
                                         act = lv_intf_row ).

    " written once, out and back

    lr_alias = alias_ref( ).
    lr_alias->* = `out`.

    lv_member = substring( val = lv_path
                                 off = 1 ).

    li_doc = z2ui5_cl_ui5_ajs=>parse( model( )->main_json_stringify( ) ).
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( li_doc->members( `/` ) ) ).
    cl_abap_unit_assert=>assert_equals( exp = `out`
                                        act = li_doc->get_string( lv_path ) ).
    model( )->main_json_to_attri( z2ui5_cl_ui5_ajs=>parse( |\{"{ lv_member }":"in"\}| ) ).
    cl_abap_unit_assert=>assert_equals( exp = `in`
                                        act = mo_app->lif_intf_alias~mv_shared ).

  ENDMETHOD.

  METHOD alias_ref.
    GET REFERENCE OF mo_app->mv_shared INTO result.
  ENDMETHOD.

  METHOD alias_dedupe_by_reference.

    " the class pass wrote the alias's row - the interface spelling of the
    " same data object is not added next to it, another one is
    DATA lt_result TYPE z2ui5_if_ui5_types=>ty_t_attri.
    DATA temp610 TYPE z2ui5_if_ui5_types=>ty_s_attri.
    DATA temp611 TYPE abap_attrdescr_tab.
    DATA temp612 LIKE LINE OF temp611.
    DATA lt_descr LIKE temp611.
    DATA temp1 TYPE REF TO z2ui5_cl_ui5_srv_model.
    DATA temp135 TYPE xsdboolean.
    DATA temp24 LIKE sy-subrc.
    DATA temp136 TYPE xsdboolean.
    DATA temp25 LIKE sy-subrc.
    CLEAR temp610.
    temp610-name = `MV_SHARED`.
    INSERT temp610 INTO TABLE lt_result.

    CLEAR temp611.

    temp612-name = `LIF_INTF_ALIAS~MV_SHARED`.
    temp612-visibility = z2ui5_cl_ui5_util_context=>cv_objectdescr_public.
    temp612-is_interface = abap_true.
    INSERT temp612 INTO TABLE temp611.
    temp612-name = `LIF_INTF_ATTR~MV_INTF`.
    temp612-visibility = z2ui5_cl_ui5_util_context=>cv_objectdescr_public.
    temp612-is_interface = abap_true.
    INSERT temp612 INTO TABLE temp611.

    lt_descr = temp611.


    temp1 = model( ).
    temp1->diss_oref_intf( EXPORTING it_attri  = lt_descr
                                        iv_prefix = ``
                                        iv_parent = ``
                              CHANGING  ct_result = lt_result ).

    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( lt_result ) ).


    READ TABLE lt_result WITH KEY name = `LIF_INTF_ALIAS~MV_SHARED` TRANSPORTING NO FIELDS.
    temp24 = sy-subrc.
    temp135 = boolc( temp24 = 0 ).
    cl_abap_unit_assert=>assert_equals( exp = abap_false act = temp135 ).


    READ TABLE lt_result WITH KEY name = `LIF_INTF_ATTR~MV_INTF` TRANSPORTING NO FIELDS.
    temp25 = sy-subrc.
    temp136 = boolc( temp25 = 0 ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp136 ).

  ENDMETHOD.

  METHOD intf_survives_refresh.

    DATA temp613 LIKE REF TO mo_app->lif_intf_attr~mv_intf.
    DATA lo_model TYPE REF TO z2ui5_cl_ui5_srv_model.
    FIELD-SYMBOLS <temp614> LIKE LINE OF mo_cont->mt_attri->*.
    DATA temp615 LIKE sy-tabix.
    DATA temp616 LIKE REF TO mo_app->lif_intf_attr~mv_intf.
DATA lr_row TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.
    GET REFERENCE OF mo_app->lif_intf_attr~mv_intf INTO temp613.
bind( temp613 ).

    " the next roundtrip: a fresh model instance over the draft's rows,
    " rebuilt - the bound interface row is found again, bound

    lo_model = model( ).
    lo_model->main_attri_refresh( ).


    temp615 = sy-tabix.
    READ TABLE mo_cont->mt_attri->* WITH KEY name = `LIF_INTF_ATTR~MV_INTF` ASSIGNING <temp614>.
    sy-tabix = temp615.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals(
        exp = abap_true
        act = <temp614>-bind ).

    GET REFERENCE OF mo_app->lif_intf_attr~mv_intf INTO temp616.

lr_row = lo_model->main_attri_search( temp616 ).
    cl_abap_unit_assert=>assert_equals( exp = `LIF_INTF_ATTR~MV_INTF`
                                        act = lr_row->name ).

  ENDMETHOD.

  METHOD intf_dref_save_load.

    FIELD-SYMBOLS <tab> TYPE lif_intf_attr=>ty_t_row.
    DATA temp617 TYPE lif_intf_attr=>ty_s_row.
    DATA temp618 LIKE REF TO <tab>.
    DATA lo_model TYPE REF TO z2ui5_cl_ui5_srv_model.
    DATA lv_before TYPE string.

    " CREATE DATA ... LIKE, not NEW: the downport writes the NEW of a type
    " of a local interface as CREATE OBJECT ... TYPE lif_intf_attr, and the
    " transpiled runtime refuses CREATE DATA ... TYPE lif_intf_attr=>ty_t_row
    CREATE DATA mo_app->lif_intf_attr~mr_intf LIKE mo_app->lif_intf_attr~mt_intf.
    ASSIGN mo_app->lif_intf_attr~mr_intf->* TO <tab>.

    CLEAR temp617.
    temp617-name = `R`.
    temp617-qty = 3.
    INSERT temp617 INTO TABLE <tab>.

    GET REFERENCE OF <tab> INTO temp618.
cl_abap_unit_assert=>assert_equals( exp = `/LIF_INTF_ATTR~MR_INTF/*`
                                        act = bind( temp618 ) ).

    " the draft: the data reference is detached and its payload written,
    " the load puts it back - by the row's name, `~` and all

    lo_model = model( ).

    lv_before = lo_model->main_json_stringify( ).
    lo_model->main_attri_db_save_srtti( ).
    cl_abap_unit_assert=>assert_not_bound( mo_app->lif_intf_attr~mr_intf ).
    lo_model->main_attri_db_load( ).
    cl_abap_unit_assert=>assert_bound( mo_app->lif_intf_attr~mr_intf ).
    cl_abap_unit_assert=>assert_equals( exp = lv_before
                                        act = model( )->main_json_stringify( ) ).

  ENDMETHOD.

  METHOD no_attribute_still_refused.

    DATA lv_local TYPE string.
        DATA temp619 LIKE REF TO lv_local.
        DATA lx TYPE REF TO z2ui5_cx_ui5_util_error.
        DATA temp137 TYPE xsdboolean.

    TRY.

        GET REFERENCE OF lv_local INTO temp619.
bind( temp619 ).
        cl_abap_unit_assert=>fail( `a local variable is no attribute` ).

      CATCH z2ui5_cx_ui5_util_error INTO lx.

        temp137 = boolc( lx->get_text( ) CS `BINDING_ERROR` ).
        cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp137
                                          msg = lx->get_text( ) ).
    ENDTRY.

  ENDMETHOD.

ENDCLASS.
