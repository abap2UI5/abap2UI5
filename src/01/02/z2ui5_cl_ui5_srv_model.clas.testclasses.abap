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
    FIELD-SYMBOLS <row_ref> LIKE LINE OF mt_rows_ref.
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
    APPEND temp12 TO lt_comp.

    lo_struc = cl_abap_structdescr=>create( lt_comp ).

    lo_tab   = cl_abap_tabledescr=>create( p_line_type  = lo_struc
                                                 p_table_kind = cl_abap_tabledescr=>tablekind_std ).

    CREATE DATA mr_handle_tab TYPE HANDLE lo_tab.
    ASSIGN mr_handle_tab->* TO <tab>.
    CLEAR ls_sel.
    ls_sel-col1 = `handle-row-1`.
    ls_sel-selkz = abap_true.
    APPEND INITIAL LINE TO <tab> ASSIGNING <row>.
    MOVE-CORRESPONDING ls_sel TO <row>.
    CLEAR ls_sel.
    ls_sel-col1 = `handle-row-2`.
    APPEND INITIAL LINE TO <tab> ASSIGNING <row>.
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
    APPEND INITIAL LINE TO <tab> ASSIGNING <row>.
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
    APPEND temp15 TO lt_nested_comp.

    CLEAR temp16.
    temp16-name = `T_ITEMS`.

    temp24 ?= cl_abap_datadescr=>describe_by_data( mt_std ).
    temp16-type = temp24.
    APPEND temp16 TO lt_nested_comp.
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
    APPEND INITIAL LINE TO <tab> ASSIGNING <row>.
    MOVE-CORRESPONDING ls_sel TO <row>.


    APPEND INITIAL LINE TO mt_rows_ref ASSIGNING <row_ref>.
    <row_ref>-id = `r1`.
    CREATE DATA <row_ref>-r_elem.
    <row_ref>-r_elem->* = `cell-ref`.
    CREATE OBJECT <row_ref>-o_obj.
    <row_ref>-o_obj->mv_inner = `cell-obj`.

    mv_protected = `protected`.
    CREATE OBJECT mo_hidden.


    CREATE OBJECT temp17 TYPE ltcl_shp_inner.
    APPEND temp17 TO mt_apps.


    temp19 = sy-tabix.
    READ TABLE mt_apps INDEX 1 ASSIGNING <temp18>.
    sy-tabix = temp19.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    <temp18>->mv_inner = `in-table`.

    mv_markup = |<b>tag</b> & "quoted" 'single' \\ backslash{ cl_abap_char_utilities=>newline }second line|.

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
    APPEND temp21 TO lt_comp.

    lo_tab = cl_abap_tabledescr=>create( p_line_type  = cl_abap_structdescr=>create( lt_comp )
                                               p_table_kind = cl_abap_tabledescr=>tablekind_std ).
    CREATE DATA mt_table TYPE HANDLE lo_tab.
    ASSIGN mt_table->* TO <tab>.
    ls_line-col1 = `a`.
    APPEND INITIAL LINE TO <tab> ASSIGNING <row>.
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
    APPEND temp23 TO lt_comp.

    lo_tab = cl_abap_tabledescr=>create( p_line_type  = cl_abap_structdescr=>create( lt_comp )
                                               p_table_kind = cl_abap_tabledescr=>tablekind_std ).
    CREATE DATA mt_data TYPE HANDLE lo_tab.
    ASSIGN mt_data->* TO <tab>.
    ls_line-col1 = `b`.
    APPEND INITIAL LINE TO <tab> ASSIGNING <row>.
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
    INTERFACES z2ui5_if_ajson_filter.
ENDCLASS.

CLASS ltcl_shp_filter IMPLEMENTATION.

  METHOD z2ui5_if_ajson_filter~keep_node.
    " drop an initial string leaf, keep everything else
    DATA temp1 TYPE xsdboolean.
    temp1 = boolc( is_node-type <> z2ui5_if_ajson_types=>node_type-string OR is_node-value IS NOT INITIAL ).
    rv_keep = temp1.
  ENDMETHOD.

ENDCLASS.


CLASS ltcl_00_base DEFINITION DEFERRED.
CLASS ltcl_01_dissolve DEFINITION DEFERRED.
CLASS ltcl_02_search DEFINITION DEFERRED.
CLASS ltcl_03_model_out DEFINITION DEFERRED.
CLASS ltcl_04_model_in DEFINITION DEFERRED.
CLASS ltcl_05_draft DEFINITION DEFERRED.
CLASS z2ui5_cl_ui5_srv_model DEFINITION LOCAL FRIENDS ltcl_00_base ltcl_01_dissolve ltcl_02_search
                                                     ltcl_03_model_out ltcl_04_model_in ltcl_05_draft.


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
    REPLACE ALL OCCURRENCES OF `->*` IN lv_path WITH `_D`.
    REPLACE ALL OCCURRENCES OF `->` IN lv_path WITH `_`.
    REPLACE ALL OCCURRENCES OF `-` IN lv_path WITH `_`.
    result->name_client = |/{ lv_path }|.

    READ TABLE mt_bound WITH KEY table_line = result->name TRANSPORTING NO FIELDS.
    temp24 = sy-subrc.
    IF NOT temp24 = 0.
      APPEND result->name TO mt_bound.
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

      FIND FIRST OCCURRENCE OF lv_open IN result MATCH OFFSET lv_from.
      IF sy-subrc <> 0.
        EXIT.
      ENDIF.

      FIND FIRST OCCURRENCE OF lv_close IN result MATCH OFFSET lv_to.
      IF sy-subrc <> 0 OR lv_to < lv_from.
        EXIT.
      ENDIF.

      lv_end = lv_to + strlen( lv_close ).
      result = result(lv_from) && result+lv_end.
    ENDDO.
    REPLACE ALL OCCURRENCES OF |<{ iv_tag }/>| IN result WITH ``.

  ENDMETHOD.

  METHOD row.

    " no chained dereference of a functional method call - 7.50 rejects
    " `row_ref( ... )->*`, the reference needs its own variable first
    DATA lr_row TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.
    lr_row = row_ref( iv_name ).
    result = lr_row->*.

  ENDMETHOD.

  METHOD row_ref.

    READ TABLE mr_attri->* REFERENCE INTO result WITH TABLE KEY name = iv_name.
    IF sy-subrc <> 0.
      cl_abap_unit_assert=>fail( |no row { iv_name }| ).
    ENDIF.

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
    cl_abap_unit_assert=>assert_true( act = temp3
                                      msg = `I4: mr_shared_a and mr_shared_b are two objects now` ).

    temp4 = boolc( mo_app->mr_shared_a = mo_app->mo_inner->mr_shared ).
    cl_abap_unit_assert=>assert_true( act = temp4
                                      msg = `I4: the helper's mr_shared is a copy` ).
    " ...two helpers stay two objects (334)...

    temp5 = boolc( mo_app->mo_inner <> mo_app->mo_inner_2 ).
    cl_abap_unit_assert=>assert_true( act = temp5
                                      msg = `I4: the two helpers collapsed into one object` ).
    " ...and the aliases point INTO their owner again, the one inside the
    " second helper included (347)

    GET REFERENCE OF mo_app->ms_flat INTO lr_flat.

    GET REFERENCE OF mo_app->mt_std INTO lr_std.

    temp6 = boolc( mo_app->mr_alias_struc = lr_flat ).
    cl_abap_unit_assert=>assert_true( act = temp6
                                      msg = `I4: mr_alias_struc detached from ms_flat` ).

    temp7 = boolc( mo_app->mr_alias_tab = lr_std ).
    cl_abap_unit_assert=>assert_true( act = temp7
                                      msg = `I4: mr_alias_tab detached from mt_std` ).

    temp8 = boolc( mo_app->mo_inner_2->mr_shared = lr_std ).
    cl_abap_unit_assert=>assert_true( act = temp8
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
      cl_abap_unit_assert=>assert_true( act = temp9
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
      cl_abap_unit_assert=>assert_true( act = row_exists( lv_name )
                                        msg = |no row for { lv_name }| ).
    ENDLOOP.

    " protected attributes are not dissolved - nothing can bind them
    cl_abap_unit_assert=>assert_false( row_exists( `MV_PROTECTED` ) ).
    cl_abap_unit_assert=>assert_false( row_exists( `MO_HIDDEN` ) ).

    " every row is done - nothing pending after a full refresh


    READ TABLE mr_attri->* WITH KEY check_dissolved = abap_false TRANSPORTING NO FIELDS.
    temp1 = sy-subrc.
    temp10 = boolc( temp1 = 0 ).
    cl_abap_unit_assert=>assert_false( temp10 ). "#EC CI_SORTSEQ

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
    cl_abap_unit_assert=>assert_true( temp11 ).


    READ TABLE lt_attri WITH KEY check_dissolved = abap_false TRANSPORTING NO FIELDS.
    temp3 = sy-subrc.
    temp12 = boolc( temp3 = 0 ).
    cl_abap_unit_assert=>assert_false( temp12 ). "#EC CI_SORTSEQ

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

    cl_abap_unit_assert=>assert_true( row_exists( `MO_INNER->MO_DEEPER->MO_DEEPER->MV_INNER` ) ).

    lv_deepest = 0.


    LOOP AT mr_attri->* REFERENCE INTO lr_attri.

      lv_hops = count( val = lr_attri->name
                             sub = `->` ).
      IF lv_hops > lv_deepest.
        lv_deepest = lv_hops.
      ENDIF.
    ENDLOOP.

    temp13 = boolc( lv_deepest <= 5 ).
    cl_abap_unit_assert=>assert_true( act = temp13
                                      msg = |the cycle ran { lv_deepest } hops deep| ).


    READ TABLE mr_attri->* WITH KEY check_dissolved = abap_false TRANSPORTING NO FIELDS.
    temp4 = sy-subrc.
    temp14 = boolc( temp4 = 0 ).
    cl_abap_unit_assert=>assert_false( temp14 ). "#EC CI_SORTSEQ

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

    cl_abap_unit_assert=>assert_true( row_exists( `MO_INNER->MO_DEEPER->MO_DEEPER->MV_INNER` ) ).
    cl_abap_unit_assert=>assert_true( row_exists( `MO_INNER_2->MO_DEEPER->MO_DEEPER->MV_INNER` ) ).

    lv_deepest = 0.


    LOOP AT mr_attri->* REFERENCE INTO lr_attri.

      lv_hops = count( val = lr_attri->name
                             sub = `->` ).
      IF lv_hops > lv_deepest.
        lv_deepest = lv_hops.
      ENDIF.
    ENDLOOP.

    temp15 = boolc( lv_deepest <= 5 ).
    cl_abap_unit_assert=>assert_true( temp15 ).


    READ TABLE mr_attri->* WITH KEY check_dissolved = abap_false TRANSPORTING NO FIELDS.
    temp5 = sy-subrc.
    temp16 = boolc( temp5 = 0 ).
    cl_abap_unit_assert=>assert_false( temp16 ). "#EC CI_SORTSEQ

  ENDMETHOD.

  METHOD table_of_objects_is_leaf.

    mo_model->main_attri_refresh( ).

    cl_abap_unit_assert=>assert_true( row_exists( `MT_APPS` ) ).
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

    cl_abap_unit_assert=>assert_true( row_exists( `MI_APP->MV_STRING` ) ).
    cl_abap_unit_assert=>assert_true( row_exists( `MI_APP->MT_STD` ) ).

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
    lr_attri->custom_mapper = z2ui5_cl_ajson_mapping=>create_upper_case( ).
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
    cl_abap_unit_assert=>assert_bound( lr_after->custom_mapper ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = row( `MV_STRING` )-check_json ).

  ENDMETHOD.

  METHOD refresh_finds_late_obj.
    DATA temp56 LIKE REF TO mo_app->mv_string.

    " the app creates its helper AFTER the first bind (sample 117: mo_app is
    " created in render_sub_app, the host's own view was bound before)
    CLEAR mo_app->mi_app.

    GET REFERENCE OF mo_app->mv_string INTO temp56.
bind( temp56 ).
    cl_abap_unit_assert=>assert_false( row_exists( `MI_APP->MV_STRING` ) ).

    CREATE OBJECT mo_app->mi_app TYPE ltcl_app_shapes.
    mo_model->main_attri_refresh( ).

    cl_abap_unit_assert=>assert_true( row_exists( `MI_APP->MV_STRING` ) ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = row( `MV_STRING` )-bind ).

  ENDMETHOD.

  METHOD refresh_drops_orphans.

    mo_model->main_attri_refresh( ).
    cl_abap_unit_assert=>assert_true( row_exists( `MO_DEAD->MV_TEXT` ) ).

    CLEAR mo_app->mo_dead.
    mo_model->main_attri_refresh( ).

    cl_abap_unit_assert=>assert_true( row_exists( `MO_DEAD` ) ).
    cl_abap_unit_assert=>assert_false( row_exists( `MO_DEAD->MV_TEXT` ) ).

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
    DATA temp57 LIKE REF TO mo_app->mv_string.
DATA lr_row TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.
    DATA lr_idx TYPE REF TO z2ui5_cl_ui5_srv_model=>ty_s_ref_idx.
    DATA lr_val LIKE REF TO mo_app->mv_string.
    DATA temp17 TYPE xsdboolean.
    DATA temp58 LIKE REF TO mo_app->mv_string.
DATA lr_again TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.
    DATA temp18 TYPE xsdboolean.
    GET REFERENCE OF mo_app->mv_string INTO temp57.

lr_row = bind( temp57 ).


    READ TABLE mo_model->mt_ref_idx REFERENCE INTO lr_idx
         WITH TABLE KEY name = `MV_STRING`.
    cl_abap_unit_assert=>assert_subrc( msg = `the resolved row was not indexed` ).

    GET REFERENCE OF mo_app->mv_string INTO lr_val.

    temp17 = boolc( lr_idx->ref = lr_val ).
    cl_abap_unit_assert=>assert_true( temp17 ).

    " the second search lands on the same row

    GET REFERENCE OF mo_app->mv_string INTO temp58.

lr_again = mo_model->main_attri_search( temp58 ).

    temp18 = boolc( lr_again = lr_row ).
    cl_abap_unit_assert=>assert_true( temp18 ).

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
    DATA temp59 LIKE REF TO mo_app->mv_string.
DATA temp19 TYPE xsdboolean.
    DATA temp20 TYPE xsdboolean.
    DATA temp60 LIKE REF TO mo_app->mo_inner->mv_inner.
DATA temp21 TYPE xsdboolean.
    DATA temp22 TYPE xsdboolean.
    DATA temp61 LIKE REF TO mo_app->ms_deep-l1-l2-l3-v4.
DATA temp23 TYPE xsdboolean.
    DATA temp62 LIKE REF TO mo_app->mr_typed_struc->col1.
DATA temp24 TYPE xsdboolean.

    mo_model->main_attri_refresh( ).


    GET REFERENCE OF mo_app->mv_string INTO temp59.

temp19 = boolc( mo_model->attri_get_val_ref( `MV_STRING` ) = temp59 ).
cl_abap_unit_assert=>assert_true( temp19 ).

    temp20 = boolc( mo_model->attri_get_val_ref( `MR_ELEM->*` ) = mo_app->mr_elem ).
    cl_abap_unit_assert=>assert_true( temp20 ).

    GET REFERENCE OF mo_app->mo_inner->mv_inner INTO temp60.

temp21 = boolc( mo_model->attri_get_val_ref( `MO_INNER->MV_INNER` ) = temp60 ).
cl_abap_unit_assert=>assert_true( temp21 ).

    temp22 = boolc( mo_model->attri_get_val_ref( `MO_INNER->MR_SHARED->*` ) = mo_app->mo_inner->mr_shared ).
    cl_abap_unit_assert=>assert_true( temp22 ).

    GET REFERENCE OF mo_app->ms_deep-l1-l2-l3-v4 INTO temp61.

temp23 = boolc( mo_model->attri_get_val_ref( `MS_DEEP-L1-L2-L3-V4` ) = temp61 ).
cl_abap_unit_assert=>assert_true( temp23 ).

    GET REFERENCE OF mo_app->mr_typed_struc->col1 INTO temp62.

temp24 = boolc( mo_model->attri_get_val_ref( `MR_TYPED_STRUC->COL1` ) = temp62 ).
cl_abap_unit_assert=>assert_true( temp24 ).

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
        DATA temp63 LIKE REF TO mo_app->mr_handle_tab.
        DATA lx TYPE REF TO z2ui5_cx_ui5_util_error.
        DATA temp25 TYPE xsdboolean.

    " _bind( mr_handle_tab ) hands the REFERENCE over, not the table behind
    " it - refused with a message that says what to do instead
    TRY.

        GET REFERENCE OF mo_app->mr_handle_tab INTO temp63.
mo_model->main_attri_search( temp63 ).
        cl_abap_unit_assert=>fail( `a reference itself must not be bindable` ).

      CATCH z2ui5_cx_ui5_util_error INTO lx.

        temp25 = boolc( lx->get_text( ) CS `NO DATA REFERENCES` ).
        cl_abap_unit_assert=>assert_true( temp25 ).
    ENDTRY.

  ENDMETHOD.

  METHOD alias_grandchild_as_owner.

    DATA lo_app TYPE REF TO ltcl_app_samples.
    DATA lt_attri TYPE z2ui5_if_ui5_types=>ty_t_attri.
    DATA temp64 LIKE REF TO lt_attri.
DATA lo_model TYPE REF TO z2ui5_cl_ui5_srv_model.
    DATA lr_leaf TYPE REF TO data.
    DATA lr_attri TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.
    FIELD-SYMBOLS <temp65> LIKE LINE OF lt_attri.
    DATA temp66 LIKE sy-tabix.
    FIELD-SYMBOLS <temp67> LIKE LINE OF lt_attri.
    DATA temp68 LIKE sy-tabix.
    FIELD-SYMBOLS <temp69> LIKE LINE OF lt_attri.
    DATA temp70 LIKE sy-tabix.
    CREATE OBJECT lo_app TYPE ltcl_app_samples.
    GET REFERENCE OF lo_app->ms_data INTO lo_app->mr_alias.
    lo_app->ms_data-ms_data2-val = `two`.


    GET REFERENCE OF lt_attri INTO temp64.

CREATE OBJECT lo_model TYPE z2ui5_cl_ui5_srv_model EXPORTING attri = temp64 app = lo_app.

    " the leaf reached THROUGH the reference is the owner's leaf

    lr_leaf = lo_model->attri_get_val_ref( `MR_ALIAS->MS_DATA2-VAL` ).

    lr_attri = lo_model->main_attri_search( lr_leaf ).
    cl_abap_unit_assert=>assert_equals( exp = `MS_DATA-MS_DATA2-VAL`
                                        act = lr_attri->name ).
    " ...because every row under the alias names the owner's path


    temp66 = sy-tabix.
    READ TABLE lt_attri WITH KEY name = `MR_ALIAS->MS_DATA2` ASSIGNING <temp65>.
    sy-tabix = temp66.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `MS_DATA-MS_DATA2`
                                        act = <temp65>-name_ref ).


    temp68 = sy-tabix.
    READ TABLE lt_attri WITH KEY name = `MR_ALIAS->MS_DATA2-VAL` ASSIGNING <temp67>.
    sy-tabix = temp68.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `MS_DATA-MS_DATA2-VAL`
                                        act = <temp67>-name_ref ).


    temp70 = sy-tabix.
    READ TABLE lt_attri WITH KEY name = `MR_ALIAS->MS_DATA2-MS_DATA2-VAL` ASSIGNING <temp69>.
    sy-tabix = temp70.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `MS_DATA-MS_DATA2-MS_DATA2-VAL`
                                        act = <temp69>-name_ref ).

  ENDMETHOD.

  METHOD deep_leaf_found.

    DATA lo_app TYPE REF TO ltcl_app_samples.
    DATA lt_attri TYPE z2ui5_if_ui5_types=>ty_t_attri.
    DATA temp71 LIKE REF TO lt_attri.
DATA lo_model TYPE REF TO z2ui5_cl_ui5_srv_model.
    DATA temp72 LIKE REF TO lo_app->ms_data-ms_data2-ms_data2-ms_data2-ms_data2-ms_data2-ms_data2-val.
DATA lr_attri TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.
    DATA temp73 LIKE REF TO lo_app->ms_data-ms_data2-val.
DATA lr_upper TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.
    CREATE OBJECT lo_app TYPE ltcl_app_samples.
    lo_app->ms_data-ms_data2-ms_data2-ms_data2-ms_data2-ms_data2-ms_data2-val = `deep`.


    GET REFERENCE OF lt_attri INTO temp71.

CREATE OBJECT lo_model TYPE z2ui5_cl_ui5_srv_model EXPORTING attri = temp71 app = lo_app.

    GET REFERENCE OF lo_app->ms_data-ms_data2-ms_data2-ms_data2-ms_data2-ms_data2-ms_data2-val INTO temp72.

lr_attri = lo_model->main_attri_search(
        temp72 ).
    cl_abap_unit_assert=>assert_equals( exp = `MS_DATA-MS_DATA2-MS_DATA2-MS_DATA2-MS_DATA2-MS_DATA2-MS_DATA2-VAL`
                                        act = lr_attri->name ).

    GET REFERENCE OF lo_app->ms_data-ms_data2-val INTO temp73.

lr_upper = lo_model->main_attri_search( temp73 ).
    cl_abap_unit_assert=>assert_equals( exp = `MS_DATA-MS_DATA2-VAL`
                                        act = lr_upper->name ).

  ENDMETHOD.

  METHOD unreachable_row_skipped.

    " a row whose o_typedescr the restore could not re-resolve - the same
    " type_kind and kind as the searched value, so the prefilter visits it
    " first, and no descriptor. It used to dump CX_SY_REF_IS_INITIAL
    DATA temp74 LIKE REF TO mo_app->mv_string.
DATA lo_descr TYPE REF TO cl_abap_typedescr.
    DATA temp75 TYPE z2ui5_if_ui5_types=>ty_s_attri.
    DATA temp76 LIKE REF TO mo_app->mv_string.
DATA lr_attri TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.
    GET REFERENCE OF mo_app->mv_string INTO temp74.

lo_descr = z2ui5_cl_ui5_util_context=>rtti_get_typedescr_by_data_ref( temp74 ).

    CLEAR temp75.
    temp75-name = `AA_GONE`.
    temp75-check_dissolved = abap_true.
    temp75-type_kind = lo_descr->type_kind.
    temp75-kind = lo_descr->kind.
    INSERT temp75 INTO TABLE mr_attri->*.


    GET REFERENCE OF mo_app->mv_string INTO temp76.

lr_attri = mo_model->main_attri_search( temp76 ).
    cl_abap_unit_assert=>assert_equals( exp = `MV_STRING`
                                        act = lr_attri->name ).

  ENDMETHOD.

  METHOD search_refreshes_late_obj.
    DATA temp77 LIKE REF TO mo_app->mv_string.
    DATA lo_other TYPE REF TO ltcl_app_shapes.
    DATA temp78 LIKE REF TO lo_other->mv_int.
DATA lr_attri TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.

    CLEAR mo_app->mi_app.

    GET REFERENCE OF mo_app->mv_string INTO temp77.
bind( temp77 ).
    CREATE OBJECT mo_app->mi_app TYPE ltcl_app_shapes.

    lo_other ?= mo_app->mi_app.

    " not in mt_attri yet - the search dissolves, finds nothing, refreshes

    GET REFERENCE OF lo_other->mv_int INTO temp78.

lr_attri = mo_model->main_attri_search( temp78 ).
    cl_abap_unit_assert=>assert_equals( exp = `MI_APP->MV_INT`
                                        act = lr_attri->name ).
    " and the earlier bind survived the refresh
    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = row( `MV_STRING` )-bind ).

  ENDMETHOD.

  METHOD unknown_value_is_error.

    DATA lv_local TYPE string.
        DATA temp79 LIKE REF TO lv_local.
        DATA lx TYPE REF TO z2ui5_cx_ui5_util_error.
        DATA temp26 TYPE xsdboolean.
    TRY.

        GET REFERENCE OF lv_local INTO temp79.
mo_model->main_attri_search( temp79 ).
        cl_abap_unit_assert=>fail( `a value outside the app must raise` ).

      CATCH z2ui5_cx_ui5_util_error INTO lx.

        temp26 = boolc( lx->get_text( ) CS `BINDING_ERROR` ).
        cl_abap_unit_assert=>assert_true( temp26 ).
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
    DATA temp80 LIKE REF TO mo_app->mo_inner->mv_inner.
    DATA lr_old_elem LIKE mo_app->mr_elem.
    DATA lo_old_inner LIKE mo_app->mo_inner.
    DATA lr_attri TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.
    DATA temp81 LIKE REF TO mo_app->mo_inner->mv_inner.
    DATA lv_model TYPE string.
    DATA temp27 TYPE xsdboolean.
    DATA temp28 TYPE xsdboolean.
        DATA lx TYPE REF TO z2ui5_cx_ui5_util_error.
        DATA temp29 TYPE xsdboolean.
        DATA temp82 LIKE REF TO lo_old_inner->mv_inner.
        DATA temp30 TYPE xsdboolean.

    " the first render binds the target of the generic reference and the
    " helper's value
    bind( mo_app->mr_elem ).

    GET REFERENCE OF mo_app->mo_inner->mv_inner INTO temp80.
bind( temp80 ).

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

    GET REFERENCE OF mo_app->mo_inner->mv_inner INTO temp81.
lr_attri = mo_model->main_attri_search( temp81 ).
    cl_abap_unit_assert=>assert_equals( exp = `MO_INNER->MV_INNER`
                                        act = lr_attri->name ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = lr_attri->bind ).

    " the model reads the new objects

    lv_model = mo_model->main_json_stringify( ).

    temp27 = boolc( lv_model CS `"elem-new"` ).
    cl_abap_unit_assert=>assert_true( temp27 ).

    temp28 = boolc( lv_model CS `"inner-new"` ).
    cl_abap_unit_assert=>assert_true( temp28 ).

    " the objects the render replaced are nobody's attribute any more: a
    " named error, never the stale row
    TRY.
        mo_model->main_attri_search( lr_old_elem ).
        cl_abap_unit_assert=>fail( `the replaced data object must not bind` ).

      CATCH z2ui5_cx_ui5_util_error INTO lx.

        temp29 = boolc( lx->get_text( ) CS `BINDING_ERROR` ).
        cl_abap_unit_assert=>assert_true( temp29 ).
    ENDTRY.
    TRY.

        GET REFERENCE OF lo_old_inner->mv_inner INTO temp82.
mo_model->main_attri_search( temp82 ).
        cl_abap_unit_assert=>fail( `the replaced helper must not bind` ).
      CATCH z2ui5_cx_ui5_util_error INTO lx.

        temp30 = boolc( lx->get_text( ) CS `BINDING_ERROR` ).
        cl_abap_unit_assert=>assert_true( temp30 ).
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
    " a filter drops what it says (omit_initial)
    METHODS filter_applied           FOR TESTING RAISING cx_static_check.
    " a mapper renames what it says
    METHODS mapper_applied           FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_03_model_out IMPLEMENTATION.

  METHOD every_bound_row.
    DATA lv_json TYPE string.
    DATA lv_name LIKE LINE OF mt_bound.
      DATA lv_key TYPE string.
      DATA temp31 TYPE xsdboolean.
    DATA temp32 TYPE xsdboolean.
    DATA temp33 TYPE xsdboolean.

    bind_all( ).

    lv_json = mo_model->main_json_stringify( ).


    LOOP AT mt_bound INTO lv_name.

      lv_key = substring( val = row( lv_name )-name_client
                                off = 1 ).

      temp31 = boolc( lv_json CS |"{ lv_key }"| ).
      cl_abap_unit_assert=>assert_true( act = temp31
                                        msg = |{ lv_name } missing from the model| ).
    ENDLOOP.
    " a reference row itself never travels - only the data behind it

    temp32 = boolc( lv_json CS `"MR_HANDLE_TAB":` OR lv_json CS `"MO_INNER":` ).
    cl_abap_unit_assert=>assert_false( temp32 ).
    " and an unbound attribute does not either

    temp33 = boolc( lv_json CS `"MV_XSTR"` ).
    cl_abap_unit_assert=>assert_false( temp33 ).

  ENDMETHOD.

  METHOD nothing_bound_is_empty.

    mo_model->main_attri_refresh( ).
    cl_abap_unit_assert=>assert_equals( exp = `{}`
                                        act = mo_model->main_json_stringify( ) ).

  ENDMETHOD.

  METHOD values_per_form.
    DATA temp83 TYPE REF TO z2ui5_if_ajson.
    DATA lo_json LIKE temp83.

    bind_all( ).

    temp83 ?= z2ui5_cl_ajson=>parse( mo_model->main_json_stringify( ) ).

    lo_json = temp83.

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

    DATA lo_app TYPE REF TO ltcl_app_samples.
    DATA temp84 TYPE ltcl_app_samples=>ty_t_row.
    DATA temp85 LIKE LINE OF temp84.
    DATA lt_attri TYPE z2ui5_if_ui5_types=>ty_t_attri.
    DATA temp86 LIKE REF TO lt_attri.
DATA lo_model TYPE REF TO z2ui5_cl_ui5_srv_model.
    DATA temp87 LIKE REF TO lo_app->mt_rows.
DATA lr_attri TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.
    DATA lv_json TYPE string.
    DATA temp34 TYPE xsdboolean.
    DATA temp35 TYPE xsdboolean.
    CREATE OBJECT lo_app TYPE ltcl_app_samples.

    CLEAR temp84.

    temp85-id = 1.
    temp85-descr = `initial`.
    INSERT temp85 INTO TABLE temp84.
    temp85-id = 2.
    temp85-descr = `zeros`.
    temp85-adate = '00000000'.
    temp85-atime = '000000'.
    INSERT temp85 INTO TABLE temp84.
    temp85-id = 3.
    temp85-descr = `valid`.
    temp85-adate = '20240115'.
    temp85-atime = '123045'.
    INSERT temp85 INTO TABLE temp84.
    temp85-id = 4.
    temp85-descr = `empty string moved in`.
    temp85-adate = ``.
    temp85-atime = ``.
    INSERT temp85 INTO TABLE temp84.
    lo_app->mt_rows = temp84.



    GET REFERENCE OF lt_attri INTO temp86.

CREATE OBJECT lo_model TYPE z2ui5_cl_ui5_srv_model EXPORTING attri = temp86 app = lo_app.

    GET REFERENCE OF lo_app->mt_rows INTO temp87.

lr_attri = lo_model->main_attri_search( temp87 ).
    lr_attri->bind        = abap_true.
    lr_attri->name_client = `/MT_ROWS`.


    lv_json = lo_model->main_json_stringify( ).

    temp34 = boolc( lv_json CS `"empty string moved in"` ).
    cl_abap_unit_assert=>assert_true( temp34 ).

    temp35 = boolc( lv_json CS `2024-01-15` ).
    cl_abap_unit_assert=>assert_true( temp35 ).

  ENDMETHOD.

  METHOD markup_escaped.

    DATA temp88 LIKE REF TO mo_app->mv_markup.
    DATA lv_json TYPE string.
    DATA temp89 TYPE REF TO z2ui5_if_ajson.
    DATA lo_json LIKE temp89.
    GET REFERENCE OF mo_app->mv_markup INTO temp88.
bind( temp88 ).

    lv_json = mo_model->main_json_stringify( ).
    " parsed back, the value is what the attribute holds - quotes, angle
    " brackets, ampersand and the line break included

    temp89 ?= z2ui5_cl_ajson=>parse( lv_json ).

    lo_json = temp89.
    cl_abap_unit_assert=>assert_equals( exp = mo_app->mv_markup
                                        act = lo_json->get_string( `/MV_MARKUP` ) ).

  ENDMETHOD.

  METHOD json_bind_spliced.
    DATA temp90 LIKE REF TO mo_app->mv_string.
DATA lr_attri TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.
    DATA temp91 TYPE REF TO z2ui5_if_ajson.
    DATA lo_result LIKE temp91.

    mo_app->mv_string = `{"_version":"1.0","sap.app":{"type":"card"},"sap.card":{"type":"List"}}`.

    GET REFERENCE OF mo_app->mv_string INTO temp90.

lr_attri = bind( temp90 ).
    lr_attri->check_json = abap_true.


    temp91 ?= z2ui5_cl_ajson=>parse( mo_model->main_json_stringify( ) ).

    lo_result = temp91.
    cl_abap_unit_assert=>assert_equals( exp = z2ui5_if_ajson_types=>node_type-object
                                        act = lo_result->get_node_type( `/MV_STRING` )
                                        msg = `the raw JSON must become a node, not a quoted string` ).
    cl_abap_unit_assert=>assert_equals( exp = `card`
                                        act = lo_result->get_string( `/MV_STRING/sap.app/type` ) ).

  ENDMETHOD.

  METHOD json_bind_invalid_raises.
    DATA temp92 LIKE REF TO mo_app->mv_string.
DATA lr_attri TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.

    mo_app->mv_string = `not json at all`.

    GET REFERENCE OF mo_app->mv_string INTO temp92.

lr_attri = bind( temp92 ).
    lr_attri->check_json = abap_true.
    TRY.
        mo_model->main_json_stringify( ).
        cl_abap_unit_assert=>fail( `an unparseable json bind must raise` ).
      CATCH z2ui5_cx_ui5_util_error ##NO_HANDLER.
    ENDTRY.

  ENDMETHOD.

  METHOD filter_applied.
    DATA temp93 LIKE REF TO mo_app->ms_flat.
DATA lr_attri TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.
    DATA temp94 TYPE REF TO z2ui5_if_ajson.
    DATA lo_result LIKE temp94.

    " the behaviour behind _bind( omit_initial ): an INITIAL field stays
    " absent, so the control keeps its own default instead of receiving ``
    CLEAR mo_app->ms_flat-col1.
    mo_app->ms_flat-col2 = 7.

    GET REFERENCE OF mo_app->ms_flat INTO temp93.

lr_attri = bind( temp93 ).
    CREATE OBJECT lr_attri->custom_filter TYPE ltcl_shp_filter.


    temp94 ?= z2ui5_cl_ajson=>parse( mo_model->main_json_stringify( ) ).

    lo_result = temp94.
    cl_abap_unit_assert=>assert_equals( exp = 7
                                        act = lo_result->get_integer( `/MS_FLAT/COL2` ) ).
    cl_abap_unit_assert=>assert_equals( exp = abap_false
                                        act = lo_result->exists( `/MS_FLAT/COL1` )
                                        msg = `an initial field must stay ABSENT, not serialize as an empty string` ).

  ENDMETHOD.

  METHOD mapper_applied.

    DATA temp95 LIKE REF TO mo_app->ms_flat.
DATA lr_attri TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.
    DATA temp96 TYPE REF TO z2ui5_if_ajson.
    DATA lo_result LIKE temp96.
    GET REFERENCE OF mo_app->ms_flat INTO temp95.

lr_attri = bind( temp95 ).
    lr_attri->custom_mapper = z2ui5_cl_ajson_mapping=>create_lower_case( ).


    temp96 ?= z2ui5_cl_ajson=>parse( mo_model->main_json_stringify( ) ).

    lo_result = temp96.
    cl_abap_unit_assert=>assert_equals( exp = `flat`
                                        act = lo_result->get_string( `/MS_FLAT/col1` ) ).
    cl_abap_unit_assert=>assert_equals( exp = abap_false
                                        act = lo_result->exists( `/MS_FLAT/COL1` ) ).

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
    " a column kind that takes no value of the shape the wire carries
    METHODS delta_kind_refused       FOR TESTING RAISING cx_static_check.
    " a delta over many rows with a refused cell and a refused nested table
    " in the middle: every good cell lands, the refused ones keep their
    " values and are traced, nothing else is touched
    METHODS delta_mass_edit          FOR TESTING RAISING cx_static_check.
    " a __delta node that is not the shape the client is supposed to send
    METHODS delta_malformed_survives FOR TESTING RAISING cx_static_check.

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
        VALUE(result) TYPE REF TO z2ui5_if_ajson
      RAISING
        z2ui5_cx_ajson_error.
ENDCLASS.


CLASS ltcl_04_model_in IMPLEMENTATION.

  METHOD typed_app.
    DATA temp97 TYPE ltcl_app_typed=>ty_t_tab.
    DATA temp98 LIKE LINE OF temp97.
    DATA temp27 TYPE ltcl_app_typed=>ty_t_pos.
    DATA temp28 LIKE LINE OF temp27.
    DATA temp29 TYPE ltcl_app_typed=>ty_t_pos.
    DATA temp30 LIKE LINE OF temp29.

    CREATE OBJECT result.

    CLEAR temp97.

    temp98-name = `Notebook`.
    temp98-price = '1249.00'.

    CLEAR temp27.

    temp28-qty = 1.
    INSERT temp28 INTO TABLE temp27.
    temp98-t_pos = temp27.
    INSERT temp98 INTO TABLE temp97.
    temp98-name = `Monitor`.
    temp98-price = '299.00'.

    CLEAR temp29.

    temp30-qty = 2.
    INSERT temp30 INTO TABLE temp29.
    temp98-t_pos = temp29.
    INSERT temp98 INTO TABLE temp97.
    result->mt_tab = temp97.

  ENDMETHOD.

  METHOD typed_model.

    DATA lr_attri TYPE REF TO z2ui5_if_ui5_types=>ty_t_attri.
    CREATE DATA lr_attri.
    CREATE OBJECT result EXPORTING attri = lr_attri app = io_app.

  ENDMETHOD.

  METHOD tree_app.
    DATA temp99 TYPE ltcl_app_tree=>ty_t_tree.
    DATA temp100 LIKE LINE OF temp99.
    DATA temp31 TYPE ltcl_app_tree=>ty_t_nodes.
    DATA temp32 LIKE LINE OF temp31.

    CREATE OBJECT result.

    CLEAR temp99.

    temp100-user = `Manager`.
    temp100-enabled = abap_false.
    CLEAR temp100-s_adr.
    temp100-s_adr-city = `Old Town`.
    temp100-s_adr-zip = `00000`.

    CLEAR temp31.

    temp32-user = `E1`.
    temp32-validated = abap_false.
    INSERT temp32 INTO TABLE temp31.
    temp32-user = `E2`.
    temp32-validated = abap_false.
    INSERT temp32 INTO TABLE temp31.
    temp100-nodes = temp31.
    INSERT temp100 INTO TABLE temp99.
    result->mt_tree = temp99.

  ENDMETHOD.

  METHOD delta.

    result = z2ui5_cl_ajson=>parse( iv_json ).

  ENDMETHOD.

  METHOD whole_value_per_form.
    DATA temp101 TYPE REF TO z2ui5_if_ajson.
    DATA lo_front LIKE temp101.
    FIELD-SYMBOLS <elem> TYPE any.

    bind_all( ).

    temp101 ?= z2ui5_cl_ajson=>create_empty( ).

    lo_front = temp101.
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
    DATA temp102 TYPE REF TO z2ui5_if_ajson.
    DATA lo_front LIKE temp102.

    mo_model->main_attri_refresh( ).

    lr_attri = row_ref( `MV_STRING` ).
    lr_attri->bind        = abap_false.
    lr_attri->name_client = `/MV_STRING`.

    temp102 ?= z2ui5_cl_ajson=>create_empty( ).

    lo_front = temp102.
    lo_front->set( iv_path = `/MV_STRING`
                   iv_val  = `should_not_update` ).

    mo_model->main_json_to_attri( lo_front ).

    cl_abap_unit_assert=>assert_equals( exp = `text`
                                        act = mo_app->mv_string ).

  ENDMETHOD.

  METHOD json_bind_not_read_back.
    DATA temp103 LIKE REF TO mo_app->mv_string.
DATA lr_attri TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.
    DATA temp104 TYPE REF TO z2ui5_if_ajson.
    DATA lo_front LIKE temp104.

    mo_app->mv_string = `{"sap.app":{"type":"card"}}`.

    GET REFERENCE OF mo_app->mv_string INTO temp103.

lr_attri = bind( temp103 ).
    lr_attri->check_json = abap_true.

    temp104 ?= z2ui5_cl_ajson=>create_empty( ).

    lo_front = temp104.
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
    DATA temp105 LIKE REF TO mo_app->mv_string.
DATA lr_attri TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.
    DATA ls_extra TYPE z2ui5_if_ui5_types=>ty_s_attri.
    DATA temp106 TYPE REF TO z2ui5_if_ajson.
    DATA lo_front LIKE temp106.
    GET REFERENCE OF mo_app->mv_string INTO temp105.

lr_attri = bind( temp105 ).

    ls_extra = lr_attri->*.
    ls_extra-name        = `MV_STRING_ALIAS`.
    ls_extra-name_client = `/ALIAS`.
    INSERT ls_extra INTO TABLE mr_attri->*.

    temp106 ?= z2ui5_cl_ajson=>create_empty( ).

    lo_front = temp106.
    lo_front->set( iv_path = `/MV_STRING`
                   iv_val  = `once` ).

    mo_model->main_json_to_attri( lo_front ).

    cl_abap_unit_assert=>assert_equals( exp = `once`
                                        act = mo_app->mv_string ).

  ENDMETHOD.

  METHOD scalar_refused_traced.

    " `1,250.00` typed into an Input bound to a packed SCALAR: traced with
    " the attribute name, row 0 and the raw value, the old value kept
    DATA temp107 LIKE REF TO mo_app->mv_packed.
    DATA temp108 TYPE REF TO z2ui5_if_ajson.
    DATA lo_front LIKE temp108.
    DATA temp109 TYPE decfloat34.
    DATA temp33 TYPE decfloat34.
    FIELD-SYMBOLS <temp110> LIKE LINE OF mo_model->mt_skipped.
    DATA temp111 LIKE sy-tabix.
    FIELD-SYMBOLS <temp112> LIKE LINE OF mo_model->mt_skipped.
    DATA temp113 LIKE sy-tabix.
    FIELD-SYMBOLS <temp114> LIKE LINE OF mo_model->mt_skipped.
    DATA temp115 LIKE sy-tabix.
    GET REFERENCE OF mo_app->mv_packed INTO temp107.
bind( temp107 ).

    temp108 ?= z2ui5_cl_ajson=>create_empty( ).

    lo_front = temp108.
    lo_front->set( iv_path = `/MV_PACKED`
                   iv_val  = `1,250.00` ).

    mo_model->main_json_to_attri( lo_front ).


    temp109 = '1234.56'.

    temp33 = mo_app->mv_packed.
    cl_abap_unit_assert=>assert_equals( exp = temp109
                                        act = temp33 ).
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( mo_model->mt_skipped ) ).


    temp111 = sy-tabix.
    READ TABLE mo_model->mt_skipped INDEX 1 ASSIGNING <temp110>.
    sy-tabix = temp111.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `MV_PACKED`
                                        act = <temp110>-name ).


    temp113 = sy-tabix.
    READ TABLE mo_model->mt_skipped INDEX 1 ASSIGNING <temp112>.
    sy-tabix = temp113.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = 0
                                        act = <temp112>-row ).


    temp115 = sy-tabix.
    READ TABLE mo_model->mt_skipped INDEX 1 ASSIGNING <temp114>.
    sy-tabix = temp115.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `1,250.00`
                                        act = <temp114>-value ).

  ENDMETHOD.

  METHOD whole_scalar_typed.

    DATA temp116 LIKE REF TO mo_app->mv_date.
    DATA temp117 LIKE REF TO mo_app->mv_time.
    DATA temp118 LIKE REF TO mo_app->mv_bool.
    DATA temp119 LIKE REF TO mo_app->mv_int.
    DATA temp120 LIKE REF TO mo_app->mv_string.
    DATA temp121 TYPE REF TO z2ui5_if_ajson.
    DATA lo_front LIKE temp121.
    DATA temp122 TYPE string.
    DATA temp123 TYPE string.
    DATA temp124 TYPE REF TO z2ui5_if_ajson.
    DATA temp125 TYPE string.
    GET REFERENCE OF mo_app->mv_date INTO temp116.
bind( temp116 ).

    GET REFERENCE OF mo_app->mv_time INTO temp117.
bind( temp117 ).

    GET REFERENCE OF mo_app->mv_bool INTO temp118.
bind( temp118 ).

    GET REFERENCE OF mo_app->mv_int INTO temp119.
bind( temp119 ).

    GET REFERENCE OF mo_app->mv_string INTO temp120.
bind( temp120 ).

    " the spellings ajson writes outbound - unpacked like a delta cell

    temp121 ?= z2ui5_cl_ajson=>create_empty( ).

    lo_front = temp121.
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


    temp122 = mo_app->mv_date.
    cl_abap_unit_assert=>assert_equals( exp = `20240115`
                                        act = temp122 ).

    temp123 = mo_app->mv_time.
    cl_abap_unit_assert=>assert_equals( exp = `123045`
                                        act = temp123 ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = mo_app->mv_bool ).
    cl_abap_unit_assert=>assert_equals( exp = 42
                                        act = mo_app->mv_int ).
    " a null is the cleared target - what to_abap( ) left behind for it
    cl_abap_unit_assert=>assert_initial( mo_app->mv_string ).
    cl_abap_unit_assert=>assert_initial( mo_model->mt_skipped ).

    " a plain date keeps the direct assignment, like a delta cell does

    temp124 ?= z2ui5_cl_ajson=>create_empty( ).
    lo_front = temp124.
    lo_front->set( iv_path = `/MV_DATE`
                   iv_val  = `20240116` ).

    mo_model->main_json_to_attri( lo_front ).


    temp125 = mo_app->mv_date.
    cl_abap_unit_assert=>assert_equals( exp = `20240116`
                                        act = temp125 ).
    cl_abap_unit_assert=>assert_initial( mo_model->mt_skipped ).

  ENDMETHOD.

  METHOD whole_scalar_into_struc.

    DATA temp126 LIKE REF TO mo_app->ms_flat.
    DATA ls_before LIKE mo_app->ms_flat.
    DATA temp127 TYPE REF TO z2ui5_if_ajson.
    DATA lo_front LIKE temp127.
    FIELD-SYMBOLS <temp128> LIKE LINE OF mo_model->mt_skipped.
    DATA temp129 LIKE sy-tabix.
    FIELD-SYMBOLS <temp130> LIKE LINE OF mo_model->mt_skipped.
    DATA temp131 LIKE sy-tabix.
    GET REFERENCE OF mo_app->ms_flat INTO temp126.
bind( temp126 ).

    ls_before = mo_app->ms_flat.

    temp127 ?= z2ui5_cl_ajson=>create_empty( ).

    lo_front = temp127.
    lo_front->set( iv_path = `/MS_FLAT`
                   iv_val  = `not a structure` ).

    mo_model->main_json_to_attri( lo_front ).

    cl_abap_unit_assert=>assert_equals( exp = ls_before
                                        act = mo_app->ms_flat ).
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( mo_model->mt_skipped ) ).


    temp129 = sy-tabix.
    READ TABLE mo_model->mt_skipped INDEX 1 ASSIGNING <temp128>.
    sy-tabix = temp129.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `MS_FLAT`
                                        act = <temp128>-name ).


    temp131 = sy-tabix.
    READ TABLE mo_model->mt_skipped INDEX 1 ASSIGNING <temp130>.
    sy-tabix = temp131.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `not a structure`
                                        act = <temp130>-value ).

  ENDMETHOD.

  METHOD markup_round_trips.

    DATA temp132 LIKE REF TO mo_app->mv_markup.
    DATA lv_out TYPE string.
    DATA lv_before LIKE mo_app->mv_markup.
    DATA temp133 TYPE REF TO z2ui5_if_ajson.
    GET REFERENCE OF mo_app->mv_markup INTO temp132.
bind( temp132 ).

    lv_out = mo_model->main_json_stringify( ).

    lv_before = mo_app->mv_markup.
    CLEAR mo_app->mv_markup.


    temp133 ?= z2ui5_cl_ajson=>parse( lv_out ).
    mo_model->main_json_to_attri( temp133 ).

    cl_abap_unit_assert=>assert_equals( exp = lv_before
                                        act = mo_app->mv_markup ).

  ENDMETHOD.

  METHOD whole_table_round_trips.

    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
    DATA temp134 TYPE ltcl_app_shapes=>ty_s_row.
    DATA temp135 TYPE ltcl_app_shapes=>ty_s_row.
    DATA lv_json TYPE string.
    DATA temp36 TYPE xsdboolean.
    DATA temp136 TYPE REF TO z2ui5_if_ajson.
    FIELD-SYMBOLS <temp137> LIKE LINE OF mo_app->mr_typed_tab->*.
    DATA temp138 LIKE sy-tabix.

    bind( mo_app->mr_typed_tab ).
    " the backend appends two rows and ships the table...

    CLEAR temp134.
    temp134-col1 = `second`.
    APPEND temp134 TO mo_app->mr_typed_tab->*.

    CLEAR temp135.
    temp135-col1 = `third`.
    APPEND temp135 TO mo_app->mr_typed_tab->*.

    lv_json = mo_model->main_json_stringify( ).

    temp36 = boolc( lv_json CS `"third"` ).
    cl_abap_unit_assert=>assert_true( temp36 ).

    " ...the client sends the whole table back with its next event, and the
    " backend holds exactly what it shipped
    CLEAR mo_app->mr_typed_tab->*.

    temp136 ?= z2ui5_cl_ajson=>parse( lv_json ).
    mo_model->main_json_to_attri( temp136 ).
    ASSIGN mo_app->mr_typed_tab->* TO <tab>.
    cl_abap_unit_assert=>assert_equals( exp = 3
                                        act = lines( <tab> ) ).


    temp138 = sy-tabix.
    READ TABLE mo_app->mr_typed_tab->* INDEX 3 ASSIGNING <temp137>.
    sy-tabix = temp138.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `third`
                                        act = <temp137>-col1 ).

  ENDMETHOD.

  METHOD delta_rows.

    DATA temp139 LIKE REF TO mo_app->mt_std.
    FIELD-SYMBOLS <temp140> LIKE LINE OF mo_app->mt_std.
    DATA temp141 LIKE sy-tabix.
    FIELD-SYMBOLS <temp142> LIKE LINE OF mo_app->mt_std.
    DATA temp143 LIKE sy-tabix.
    FIELD-SYMBOLS <temp144> LIKE LINE OF mo_app->mt_std.
    DATA temp145 LIKE sy-tabix.
    FIELD-SYMBOLS <temp146> LIKE LINE OF mo_app->mt_std.
    DATA temp147 LIKE sy-tabix.
    FIELD-SYMBOLS <temp148> LIKE LINE OF mo_app->mt_std.
    DATA temp149 LIKE sy-tabix.
    FIELD-SYMBOLS <temp150> LIKE LINE OF mo_app->mt_std.
    DATA temp151 LIKE sy-tabix.
    FIELD-SYMBOLS <temp152> LIKE LINE OF mo_app->mt_std.
    DATA temp153 LIKE sy-tabix.
    FIELD-SYMBOLS <temp154> LIKE LINE OF mo_app->mt_std.
    DATA temp155 LIKE sy-tabix.
    GET REFERENCE OF mo_app->mt_std INTO temp139.
bind( temp139 ).

    mo_model->main_json_to_attri( delta( `{"MT_STD":{"__delta":{"0":{"COL1":"X"}}}}` ) ).


    temp141 = sy-tabix.
    READ TABLE mo_app->mt_std INDEX 1 ASSIGNING <temp140>.
    sy-tabix = temp141.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `X`
                                        act = <temp140>-col1 ).


    temp143 = sy-tabix.
    READ TABLE mo_app->mt_std INDEX 1 ASSIGNING <temp142>.
    sy-tabix = temp143.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = <temp142>-col2 ).


    temp145 = sy-tabix.
    READ TABLE mo_app->mt_std INDEX 2 ASSIGNING <temp144>.
    sy-tabix = temp145.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `b`
                                        act = <temp144>-col1 ).

    mo_model->main_json_to_attri( delta( `{"MT_STD":{"__delta":{"1":{"COL2":9}}}}` ) ).


    temp147 = sy-tabix.
    READ TABLE mo_app->mt_std INDEX 2 ASSIGNING <temp146>.
    sy-tabix = temp147.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = 9
                                        act = <temp146>-col2 ).


    temp149 = sy-tabix.
    READ TABLE mo_app->mt_std INDEX 2 ASSIGNING <temp148>.
    sy-tabix = temp149.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `b`
                                        act = <temp148>-col1 ).

    " out of range, garbled and negative indexes: no crash, table unchanged
    mo_model->main_json_to_attri( delta( `{"MT_STD":{"__delta":{"5":{"COL1":"Z"},"x":{"COL1":"Z"},"-1":{"COL1":"Z"}}}}` ) ).
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( mo_app->mt_std ) ).


    temp151 = sy-tabix.
    READ TABLE mo_app->mt_std INDEX 1 ASSIGNING <temp150>.
    sy-tabix = temp151.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `X`
                                        act = <temp150>-col1 ).

    " a key that CONVERTS but is no row index: `1.5` rounds to 2, `+1`
    " converts to 1 - each used to land the cell in a row the client
    " never named. Digits only, so neither writes (a blank-padded and the
    " empty key are in delta_malformed_survives)
    mo_model->main_json_to_attri( delta( `{"MT_STD":{"__delta":{"1.5":{"COL1":"Z"},"+1":{"COL1":"Z"}}}}` ) ).


    temp153 = sy-tabix.
    READ TABLE mo_app->mt_std INDEX 1 ASSIGNING <temp152>.
    sy-tabix = temp153.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `X`
                                        act = <temp152>-col1 ).


    temp155 = sy-tabix.
    READ TABLE mo_app->mt_std INDEX 2 ASSIGNING <temp154>.
    sy-tabix = temp155.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `b`
                                        act = <temp154>-col1 ).
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
    DATA temp156 LIKE REF TO mo_app->mt_std.
    DATA temp157 TYPE string_table.
    DATA lt_hostile LIKE temp157.
    DATA lv_json LIKE LINE OF lt_hostile.
      FIELD-SYMBOLS <temp159> LIKE LINE OF mo_app->mt_std.
      DATA temp160 LIKE sy-tabix.
      FIELD-SYMBOLS <temp161> LIKE LINE OF mo_app->mt_std.
      DATA temp162 LIKE sy-tabix.
    FIELD-SYMBOLS <temp163> LIKE LINE OF mo_app->mt_std.
    DATA temp164 LIKE sy-tabix.
    FIELD-SYMBOLS <temp165> LIKE LINE OF mo_app->mt_std.
    DATA temp166 LIKE sy-tabix.
    GET REFERENCE OF mo_app->mt_std INTO temp156.
bind( temp156 ).


    CLEAR temp157.
    INSERT `{"MT_STD":{"__delta":"boom"}}` INTO TABLE temp157.
    INSERT `{"MT_STD":{"__delta":42}}` INTO TABLE temp157.
    INSERT `{"MT_STD":{"__delta":null}}` INTO TABLE temp157.
    INSERT `{"MT_STD":{"__delta":["a","b"]}}` INTO TABLE temp157.
    INSERT `{"MT_STD":{"__delta":{"0":"boom"}}}` INTO TABLE temp157.
    INSERT `{"MT_STD":{"__delta":{"0":[1,2]}}}` INTO TABLE temp157.
    INSERT `{"MT_STD":{"__delta":{"0":null}}}` INTO TABLE temp157.
    INSERT `{"MT_STD":{"__delta":{"999999999999":{"COL1":"Z"}}}}` INTO TABLE temp157.
    INSERT `{"MT_STD":{"__delta":{"1e3":{"COL1":"Z"}}}}` INTO TABLE temp157.
    INSERT `{"MT_STD":{"":"boom"}}` INTO TABLE temp157.
    INSERT `{"MT_STD":{"__delta":{"":{"COL1":"Z"}}}}` INTO TABLE temp157.
    INSERT `{"MT_STD":{"__delta":{"0":{"":"Z"}}}}` INTO TABLE temp157.
    INSERT `{"MT_STD":{"__delta":{"0":{"NOPE":"Z"}}}}` INTO TABLE temp157.
    INSERT `{"MT_STD":{"__delta":{"0":{"__DELTA":"Z"}}}}` INTO TABLE temp157.
    INSERT `{"MT_STD":{"__delta":{"0":{"COL1":{"__delta":{"0":{"X":1}}}}}}}` INTO TABLE temp157.
    INSERT `{"MT_STD":{"__delta":{"0":{"COL2":{"__delta":{"0":{"X":1}}}}}}}` INTO TABLE temp157.
    INSERT `{"MT_STD":"boom"}` INTO TABLE temp157.
    INSERT `{"MT_STD":42}` INTO TABLE temp157.

    lt_hostile = temp157.


    LOOP AT lt_hostile INTO lv_json.
      TRY.
          mo_model->main_json_to_attri( delta( lv_json ) ).
        CATCH z2ui5_cx_ui5_util_error ##NO_HANDLER.
          " an exception IS a legitimate answer - the handler renders it
        CATCH z2ui5_cx_ajson_error ##NO_HANDLER.
          " so is the parser's own: an empty-keyed member never reaches the
          " model, and the single top-level CATCH cx_root renders this one
          " the same way. What must NOT happen is a runtime error, and that
          " is what the assertions below hold
      ENDTRY.
      cl_abap_unit_assert=>assert_equals( exp = 2
                                          act = lines( mo_app->mt_std )
                                          msg = |rows changed by { lv_json }| ).


      temp160 = sy-tabix.
      READ TABLE mo_app->mt_std INDEX 1 ASSIGNING <temp159>.
      sy-tabix = temp160.
      IF sy-subrc <> 0.
        ASSERT 1 = 0.
      ENDIF.
      cl_abap_unit_assert=>assert_equals( exp = `a`
                                          act = <temp159>-col1
                                          msg = |row 1 changed by { lv_json }| ).


      temp162 = sy-tabix.
      READ TABLE mo_app->mt_std INDEX 2 ASSIGNING <temp161>.
      sy-tabix = temp162.
      IF sy-subrc <> 0.
        ASSERT 1 = 0.
      ENDIF.
      cl_abap_unit_assert=>assert_equals( exp = `b`
                                          act = <temp161>-col1
                                          msg = |row 2 changed by { lv_json }| ).
    ENDLOOP.

    " A PADDED index is not one of those: `" 1 "` converts like any other
    " ABAP numeric text and addresses the row it names. Stated because it
    " looks like the shapes above and is not one - it stays inside the
    " table, which is all this test is about
    mo_model->main_json_to_attri( delta( `{"MT_STD":{"__delta":{" 1 ":{"COL1":"Z"}}}}` ) ).
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( mo_app->mt_std ) ).


    temp164 = sy-tabix.
    READ TABLE mo_app->mt_std INDEX 1 ASSIGNING <temp163>.
    sy-tabix = temp164.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `a`
                                        act = <temp163>-col1 ).


    temp166 = sy-tabix.
    READ TABLE mo_app->mt_std INDEX 2 ASSIGNING <temp165>.
    sy-tabix = temp166.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `Z`
                                        act = <temp165>-col1 ).

  ENDMETHOD.

  METHOD delta_into_dref_table.

    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <row> TYPE any.
    FIELD-SYMBOLS <col> TYPE any.

    " the runtime-built table behind a generic reference (samples 339, 344)
    DATA lr_attri TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.
    DATA lv_key TYPE string.
    lr_attri = bind( mo_app->mr_handle_tab ).

    lv_key = substring( val = lr_attri->name_client
                              off = 1 ).
    mo_model->main_json_to_attri( delta( |\{"{ lv_key }":\{"__delta":\{"1":\{"COL1":"edited"\}\}\}\}| ) ).

    ASSIGN mo_app->mr_handle_tab->* TO <tab>.
    READ TABLE <tab> INDEX 2 ASSIGNING <row>.
    cl_abap_unit_assert=>assert_subrc( ).
    ASSIGN COMPONENT `COL1` OF STRUCTURE <row> TO <col>.
    cl_abap_unit_assert=>assert_subrc( ).
    cl_abap_unit_assert=>assert_equals( exp = `edited`
                                        act = <col> ).
    cl_abap_unit_assert=>assert_initial( mo_model->mt_skipped ).

  ENDMETHOD.

  METHOD delta_into_helper_table.

    " the table inside the helper object (the layout rows of sample 332)
    DATA temp167 LIKE REF TO mo_app->mo_inner->mt_own.
    FIELD-SYMBOLS <temp168> LIKE LINE OF mo_app->mo_inner->mt_own.
    DATA temp169 LIKE sy-tabix.
    FIELD-SYMBOLS <temp170> LIKE LINE OF mo_app->mo_inner->mt_own.
    DATA temp171 LIKE sy-tabix.
    GET REFERENCE OF mo_app->mo_inner->mt_own INTO temp167.
bind( temp167 ).
    mo_model->main_json_to_attri( delta( `{"MO_INNER_MT_OWN":{"__delta":{"0":{"COL1":"own-edited","COL2":6}}}}` ) ).



    temp169 = sy-tabix.
    READ TABLE mo_app->mo_inner->mt_own INDEX 1 ASSIGNING <temp168>.
    sy-tabix = temp169.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `own-edited`
                                        act = <temp168>-col1 ).


    temp171 = sy-tabix.
    READ TABLE mo_app->mo_inner->mt_own INDEX 1 ASSIGNING <temp170>.
    sy-tabix = temp171.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = 6
                                        act = <temp170>-col2 ).
    cl_abap_unit_assert=>assert_initial( mo_model->mt_skipped ).

  ENDMETHOD.

  METHOD delta_nested.

    DATA lo_app TYPE REF TO ltcl_app_tree.
    DATA lr_attri TYPE REF TO z2ui5_if_ui5_types=>ty_t_attri.
    DATA lo_model TYPE REF TO z2ui5_cl_ui5_srv_model.
    FIELD-SYMBOLS <temp172> LIKE LINE OF lo_app->mt_tree.
    DATA temp173 LIKE sy-tabix.
    FIELD-SYMBOLS <temp174> LIKE LINE OF lo_app->mt_tree.
    DATA temp175 LIKE sy-tabix.
    FIELD-SYMBOLS <temp34> LIKE LINE OF <temp174>-nodes.
    DATA temp35 LIKE sy-tabix.
    FIELD-SYMBOLS <temp176> LIKE LINE OF lo_app->mt_tree.
    DATA temp177 LIKE sy-tabix.
    FIELD-SYMBOLS <temp36> LIKE LINE OF <temp176>-nodes.
    DATA temp37 LIKE sy-tabix.
    FIELD-SYMBOLS <temp178> LIKE LINE OF lo_app->mt_tree.
    DATA temp179 LIKE sy-tabix.
    FIELD-SYMBOLS <temp180> LIKE LINE OF lo_app->mt_tree.
    DATA temp181 LIKE sy-tabix.
    FIELD-SYMBOLS <temp182> LIKE LINE OF lo_app->mt_tree.
    DATA temp183 LIKE sy-tabix.
    FIELD-SYMBOLS <temp184> LIKE LINE OF lo_app->mt_tree.
    DATA temp185 LIKE sy-tabix.
    FIELD-SYMBOLS <temp38> LIKE LINE OF <temp184>-nodes.
    DATA temp39 LIKE sy-tabix.
    lo_app = tree_app( ).

    CREATE DATA lr_attri.

    CREATE OBJECT lo_model TYPE z2ui5_cl_ui5_srv_model EXPORTING attri = lr_attri app = lo_app.

    " a cell inside the nested table, a root cell next to it
    lo_model->delta_apply_to_table( io_val_front = delta( `{"__delta":{"0":{"ENABLED":true,"NODES":{"__delta":{"1":{"VALIDATED":true}}}}}}` )
                                    iv_name      = `MT_TREE` ).


    temp173 = sy-tabix.
    READ TABLE lo_app->mt_tree INDEX 1 ASSIGNING <temp172>.
    sy-tabix = temp173.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = <temp172>-enabled ).


    temp175 = sy-tabix.
    READ TABLE lo_app->mt_tree INDEX 1 ASSIGNING <temp174>.
    sy-tabix = temp175.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.


    temp35 = sy-tabix.
    READ TABLE <temp174>-nodes INDEX 2 ASSIGNING <temp34>.
    sy-tabix = temp35.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = <temp34>-validated ).


    temp177 = sy-tabix.
    READ TABLE lo_app->mt_tree INDEX 1 ASSIGNING <temp176>.
    sy-tabix = temp177.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.


    temp37 = sy-tabix.
    READ TABLE <temp176>-nodes INDEX 1 ASSIGNING <temp36>.
    sy-tabix = temp37.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = abap_false
                                        act = <temp36>-validated ).


    temp179 = sy-tabix.
    READ TABLE lo_app->mt_tree INDEX 1 ASSIGNING <temp178>.
    sy-tabix = temp179.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `Manager`
                                        act = <temp178>-user ).

    " a structure cell ships whole
    lo_model->delta_apply_to_table( io_val_front = delta( `{"__delta":{"0":{"S_ADR":{"CITY":"Berlin","ZIP":"10115"}}}}` )
                                    iv_name      = `MT_TREE` ).


    temp181 = sy-tabix.
    READ TABLE lo_app->mt_tree INDEX 1 ASSIGNING <temp180>.
    sy-tabix = temp181.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `Berlin`
                                        act = <temp180>-s_adr-city ).

    " a whole sub-table value replaces the nested table
    lo_model->delta_apply_to_table( io_val_front = delta( `{"__delta":{"0":{"NODES":[{"USER":"NEW","VALIDATED":true}]}}}` )
                                    iv_name      = `MT_TREE` ).


    temp183 = sy-tabix.
    READ TABLE lo_app->mt_tree INDEX 1 ASSIGNING <temp182>.
    sy-tabix = temp183.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( <temp182>-nodes ) ).


    temp185 = sy-tabix.
    READ TABLE lo_app->mt_tree INDEX 1 ASSIGNING <temp184>.
    sy-tabix = temp185.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.


    temp39 = sy-tabix.
    READ TABLE <temp184>-nodes INDEX 1 ASSIGNING <temp38>.
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
    DATA temp186 TYPE decfloat34.
    DATA temp40 TYPE decfloat34.
    FIELD-SYMBOLS <temp1> LIKE LINE OF lo_app->mt_tab.
    DATA temp2 LIKE sy-tabix.
    DATA lv_date TYPE d VALUE '20240115'.
    DATA lv_time TYPE t VALUE '123045'.
    DATA lv_ts TYPE timestamp VALUE '20240115123045'.
    FIELD-SYMBOLS <temp187> LIKE LINE OF lo_app->mt_tab.
    DATA temp188 LIKE sy-tabix.
    FIELD-SYMBOLS <temp189> LIKE LINE OF lo_app->mt_tab.
    DATA temp190 LIKE sy-tabix.
    FIELD-SYMBOLS <temp191> LIKE LINE OF lo_app->mt_tab.
    DATA temp192 LIKE sy-tabix.
    FIELD-SYMBOLS <temp193> LIKE LINE OF lo_app->mt_tab.
    DATA temp194 LIKE sy-tabix.
    FIELD-SYMBOLS <temp195> LIKE LINE OF lo_app->mt_tab.
    DATA temp196 LIKE sy-tabix.
    DATA lv_date_init TYPE d.
    DATA lv_time_init TYPE t.
    FIELD-SYMBOLS <temp197> LIKE LINE OF lo_app->mt_tab.
    DATA temp198 LIKE sy-tabix.
    FIELD-SYMBOLS <temp199> LIKE LINE OF lo_app->mt_tab.
    DATA temp200 LIKE sy-tabix.
    FIELD-SYMBOLS <temp201> LIKE LINE OF lo_app->mt_tab.
    DATA temp202 LIKE sy-tabix.
    DATA temp37 TYPE xsdboolean.
    FIELD-SYMBOLS <temp203> LIKE LINE OF lo_app->mt_tab.
    DATA temp204 LIKE sy-tabix.
    DATA temp205 TYPE decfloat34.
    DATA temp41 TYPE decfloat34.
    FIELD-SYMBOLS <temp3> LIKE LINE OF lo_app->mt_tab.
    DATA temp4 LIKE sy-tabix.
    FIELD-SYMBOLS <temp206> LIKE LINE OF lo_app->mt_tab.
    DATA temp207 LIKE sy-tabix.
    DATA temp208 TYPE decfloat34.
    DATA temp42 TYPE decfloat34.
    FIELD-SYMBOLS <temp5> LIKE LINE OF lo_app->mt_tab.
    DATA temp6 LIKE sy-tabix.
    lo_app = typed_app( ).

    lo_model = typed_model( lo_app ).

    " accepted
    lo_model->delta_apply_to_table( io_val_front = delta( `{"__delta":{"0":{"PRICE":"1250.00"}}}` )
                                    iv_name      = `MT_TAB` ).

    temp186 = '1250.00'.



    temp2 = sy-tabix.
    READ TABLE lo_app->mt_tab INDEX 1 ASSIGNING <temp1>.
    sy-tabix = temp2.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    temp40 = <temp1>-price.
    cl_abap_unit_assert=>assert_equals( exp = temp186
                                        act = temp40 ).
    cl_abap_unit_assert=>assert_initial( lo_model->mt_skipped ).

    " the ISO spelling ajson wrote, and a plain date
    lo_model->delta_apply_to_table( io_val_front = delta( `{"__delta":{"0":{"DT":"2024-01-15","TM":"12:30:45","TS":"2024-01-15T12:30:45Z"},"1":{"DT":"20240115","TM":""}}}` )
                                    iv_name      = `MT_TAB` ).





    temp188 = sy-tabix.
    READ TABLE lo_app->mt_tab INDEX 1 ASSIGNING <temp187>.
    sy-tabix = temp188.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = lv_date
                                        act = <temp187>-dt ).


    temp190 = sy-tabix.
    READ TABLE lo_app->mt_tab INDEX 1 ASSIGNING <temp189>.
    sy-tabix = temp190.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = lv_time
                                        act = <temp189>-tm ).


    temp192 = sy-tabix.
    READ TABLE lo_app->mt_tab INDEX 1 ASSIGNING <temp191>.
    sy-tabix = temp192.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = lv_ts
                                        act = <temp191>-ts ).


    temp194 = sy-tabix.
    READ TABLE lo_app->mt_tab INDEX 2 ASSIGNING <temp193>.
    sy-tabix = temp194.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = lv_date
                                        act = <temp193>-dt ).


    temp196 = sy-tabix.
    READ TABLE lo_app->mt_tab INDEX 2 ASSIGNING <temp195>.
    sy-tabix = temp196.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_initial( <temp195>-tm ).
    cl_abap_unit_assert=>assert_initial( lo_model->mt_skipped ).

    " a cleared picker sends "" - the initial date/time, not eight blanks
    " (which is not IS INITIAL and which ajson shipped back as `    -  -  `)


    lo_model->delta_apply_to_table( io_val_front = delta( `{"__delta":{"0":{"DT":"","TM":""}}}` )
                                    iv_name      = `MT_TAB` ).


    temp198 = sy-tabix.
    READ TABLE lo_app->mt_tab INDEX 1 ASSIGNING <temp197>.
    sy-tabix = temp198.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = lv_date_init
                                        act = <temp197>-dt ).


    temp200 = sy-tabix.
    READ TABLE lo_app->mt_tab INDEX 1 ASSIGNING <temp199>.
    sy-tabix = temp200.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = lv_time_init
                                        act = <temp199>-tm ).


    temp202 = sy-tabix.
    READ TABLE lo_app->mt_tab INDEX 1 ASSIGNING <temp201>.
    sy-tabix = temp202.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.

    temp37 = boolc( <temp201>-dt IS INITIAL ).
    cl_abap_unit_assert=>assert_true( temp37 ).
    cl_abap_unit_assert=>assert_initial( lo_model->mt_skipped ).

    " an instant with a NEGATIVE offset is one ajson cannot read - it used
    " to answer an initial timestamp that was assigned without a word; now
    " it is a refusal: the old value stands and the cell is traced
    lo_model->delta_apply_to_table( io_val_front = delta( `{"__delta":{"0":{"TS":"2024-01-15T12:30:45Z"}}}` )
                                    iv_name      = `MT_TAB` ).
    lo_model->delta_apply_to_table( io_val_front = delta( `{"__delta":{"0":{"TS":"2024-01-15T12:30:45-05:00"}}}` )
                                    iv_name      = `MT_TAB` ).


    temp204 = sy-tabix.
    READ TABLE lo_app->mt_tab INDEX 1 ASSIGNING <temp203>.
    sy-tabix = temp204.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = lv_ts
                                        act = <temp203>-ts ).
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( lo_model->mt_skipped ) ).
    CLEAR lo_model->mt_skipped.

    " refused: the grouped thousands separator, text into a number - the
    " old value stands (on a system the failed conversion clears the target
    " first; the copy in delta_apply_field puts it back), the good cell in
    " the same delta lands, a field that is not in the delta is no finding
    lo_model->delta_apply_to_table( io_val_front = delta( `{"__delta":{"0":{"PRICE":"abc","NAME":"Laptop","NOT_A_COMPONENT":"x"},"1":{"PRICE":"1,250.00"}}}` )
                                    iv_name      = `MT_TAB` ).

    temp205 = '1250.00'.



    temp4 = sy-tabix.
    READ TABLE lo_app->mt_tab INDEX 1 ASSIGNING <temp3>.
    sy-tabix = temp4.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    temp41 = <temp3>-price.
    cl_abap_unit_assert=>assert_equals( exp = temp205
                                        act = temp41 ).


    temp207 = sy-tabix.
    READ TABLE lo_app->mt_tab INDEX 1 ASSIGNING <temp206>.
    sy-tabix = temp207.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `Laptop`
                                        act = <temp206>-name ).

    temp208 = '299.00'.



    temp6 = sy-tabix.
    READ TABLE lo_app->mt_tab INDEX 2 ASSIGNING <temp5>.
    sy-tabix = temp6.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    temp42 = <temp5>-price.
    cl_abap_unit_assert=>assert_equals( exp = temp208
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
    FIELD-SYMBOLS <temp209> LIKE LINE OF lo_app->mt_tab.
    DATA temp210 LIKE sy-tabix.
    FIELD-SYMBOLS <temp45> LIKE LINE OF <temp209>-t_pos.
    DATA temp46 LIKE sy-tabix.
    FIELD-SYMBOLS <temp211> LIKE LINE OF lo_model->mt_skipped.
    DATA temp212 LIKE sy-tabix.
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


    temp210 = sy-tabix.
    READ TABLE lo_app->mt_tab INDEX 2 ASSIGNING <temp209>.
    sy-tabix = temp210.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.


    temp46 = sy-tabix.
    READ TABLE <temp209>-t_pos INDEX 1 ASSIGNING <temp45>.
    sy-tabix = temp46.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = <temp45>-qty ).


    temp212 = sy-tabix.
    READ TABLE lo_model->mt_skipped INDEX 1 ASSIGNING <temp211>.
    sy-tabix = temp212.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    ls_skip = <temp211>.
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
    DATA temp213 TYPE ltcl_app_typed=>ty_s_row.
    DATA lo_model TYPE REF TO z2ui5_cl_ui5_srv_model.
    DATA temp214 TYPE decfloat34.
    DATA temp47 TYPE decfloat34.
    FIELD-SYMBOLS <temp7> LIKE LINE OF lo_app->mt_sorted.
    DATA temp8 LIKE sy-tabix.
    FIELD-SYMBOLS <temp215> LIKE LINE OF lo_model->mt_skipped.
    DATA temp216 LIKE sy-tabix.
    DATA temp38 TYPE xsdboolean.
    DATA temp6 LIKE sy-subrc.
    DATA temp217 LIKE REF TO mo_app->mt_sorted.
    FIELD-SYMBOLS <temp218> LIKE LINE OF mo_app->mt_sorted.
    DATA temp219 LIKE sy-tabix.
    lo_app = typed_app( ).

    CLEAR temp213.
    temp213-name = `Monitor`.
    temp213-price = '299.00'.
    INSERT temp213 INTO TABLE lo_app->mt_sorted.

    lo_model = typed_model( lo_app ).

    " a sorted table takes no row delta - every cell of it is traced, the
    " table untouched (decided by RTTI: the ASSIGN to a standard-table field
    " symbol is a runtime error on a system)
    lo_model->delta_apply_to_table( io_val_front = delta( `{"__delta":{"0":{"PRICE":"1250.00","NAME":"Screen"}}}` )
                                    iv_name      = `MT_SORTED` ).

    temp214 = '299.00'.



    temp8 = sy-tabix.
    READ TABLE lo_app->mt_sorted INDEX 1 ASSIGNING <temp7>.
    sy-tabix = temp8.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    temp47 = <temp7>-price.
    cl_abap_unit_assert=>assert_equals( exp = temp214
                                        act = temp47 ).
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( lo_model->mt_skipped ) ).


    temp216 = sy-tabix.
    READ TABLE lo_model->mt_skipped INDEX 1 ASSIGNING <temp215>.
    sy-tabix = temp216.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `MT_SORTED`
                                        act = <temp215>-name ).


    READ TABLE lo_model->mt_skipped WITH KEY field = `PRICE` value = `1250.00` TRANSPORTING NO FIELDS.
    temp6 = sy-subrc.
    temp38 = boolc( temp6 = 0 ).
    cl_abap_unit_assert=>assert_true( temp38 ). "#EC CI_SORTSEQ

    " the same for the fixture's sorted table, through the model path

    GET REFERENCE OF mo_app->mt_sorted INTO temp217.
bind( temp217 ).
    mo_model->main_json_to_attri( delta( `{"MT_SORTED":{"__delta":{"0":{"COL2":1}}}}` ) ).


    temp219 = sy-tabix.
    READ TABLE mo_app->mt_sorted INDEX 1 ASSIGNING <temp218>.
    sy-tabix = temp219.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = 9
                                        act = <temp218>-col2 ).
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( mo_model->mt_skipped ) ).

  ENDMETHOD.


  METHOD delta_kind_refused.

    " a cell whose column takes no value of the shape the wire carries is
    " traced and left alone, never assigned: a string into a REF TO data or
    " a scalar into a nested table is no class-based exception on a system
    " but a runtime error, so the skip has to be decided up front. The
    " reference cell needs no crafted request - ajson ships it as its plain
    " value, and an Input bound to it sends a string back
    DATA temp220 LIKE REF TO mo_app->mt_rows_ref.
    DATA lr_before TYPE REF TO string.
    FIELD-SYMBOLS <temp48> LIKE LINE OF mo_app->mt_rows_ref.
    DATA temp49 LIKE sy-tabix.
    FIELD-SYMBOLS <temp221> LIKE LINE OF mo_model->mt_skipped.
    DATA temp222 LIKE sy-tabix.
    FIELD-SYMBOLS <temp223> LIKE LINE OF mo_model->mt_skipped.
    DATA temp224 LIKE sy-tabix.
    FIELD-SYMBOLS <temp225> LIKE LINE OF mo_app->mt_rows_ref.
    DATA temp226 LIKE sy-tabix.
    DATA temp39 TYPE xsdboolean.
    FIELD-SYMBOLS <temp227> LIKE LINE OF mo_app->mt_rows_ref.
    DATA temp228 LIKE sy-tabix.
    DATA temp229 LIKE REF TO mo_app->mt_nested.
    FIELD-SYMBOLS <temp230> LIKE LINE OF mo_model->mt_skipped.
    DATA temp231 LIKE sy-tabix.
    FIELD-SYMBOLS <temp232> LIKE LINE OF mo_app->mt_nested.
    DATA temp233 LIKE sy-tabix.
    FIELD-SYMBOLS <temp234> LIKE LINE OF mo_app->mt_nested.
    DATA temp235 LIKE sy-tabix.
    GET REFERENCE OF mo_app->mt_rows_ref INTO temp220.
bind( temp220 ).



    temp49 = sy-tabix.
    READ TABLE mo_app->mt_rows_ref INDEX 1 ASSIGNING <temp48>.
    sy-tabix = temp49.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    lr_before = <temp48>-r_elem.
    mo_model->main_json_to_attri( delta( `{"MT_ROWS_REF":{"__delta":{"0":{"R_ELEM":"x"}}}}` ) ).
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( mo_model->mt_skipped ) ).


    temp222 = sy-tabix.
    READ TABLE mo_model->mt_skipped INDEX 1 ASSIGNING <temp221>.
    sy-tabix = temp222.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `R_ELEM`
                                        act = <temp221>-field ).


    temp224 = sy-tabix.
    READ TABLE mo_model->mt_skipped INDEX 1 ASSIGNING <temp223>.
    sy-tabix = temp224.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `x`
                                        act = <temp223>-value ).


    temp226 = sy-tabix.
    READ TABLE mo_app->mt_rows_ref INDEX 1 ASSIGNING <temp225>.
    sy-tabix = temp226.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.

    temp39 = boolc( <temp225>-r_elem = lr_before ).
    cl_abap_unit_assert=>assert_true( temp39 ).


    temp228 = sy-tabix.
    READ TABLE mo_app->mt_rows_ref INDEX 1 ASSIGNING <temp227>.
    sy-tabix = temp228.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `cell-ref`
                                        act = <temp227>-r_elem->* ).

    " a scalar into a nested table column, next to a digit-only key that
    " would address a component by position: the first is traced, the
    " second skipped, the row is untouched
    CLEAR mo_model->mt_skipped.

    GET REFERENCE OF mo_app->mt_nested INTO temp229.
bind( temp229 ).
    mo_model->main_json_to_attri( delta( `{"MT_NESTED":{"__delta":{"0":{"T_ITEMS":"x","0":"y"}}}}` ) ).
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( mo_model->mt_skipped ) ).


    temp231 = sy-tabix.
    READ TABLE mo_model->mt_skipped INDEX 1 ASSIGNING <temp230>.
    sy-tabix = temp231.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `T_ITEMS`
                                        act = <temp230>-field ).


    temp233 = sy-tabix.
    READ TABLE mo_app->mt_nested INDEX 1 ASSIGNING <temp232>.
    sy-tabix = temp233.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( <temp232>-t_items ) ).


    temp235 = sy-tabix.
    READ TABLE mo_app->mt_nested INDEX 1 ASSIGNING <temp234>.
    sy-tabix = temp235.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `n1`
                                        act = <temp234>-id ).

  ENDMETHOD.

  METHOD delta_mass_edit.

    DATA lo_app TYPE REF TO ltcl_app_typed.
      DATA temp236 TYPE ltcl_app_typed=>ty_s_row.
      DATA temp50 TYPE ltcl_app_typed=>ty_t_pos.
      DATA temp51 LIKE LINE OF temp50.
      DATA temp52 TYPE ltcl_app_typed=>ty_t_pos_sorted.
      DATA temp53 LIKE LINE OF temp52.
    DATA lo_model TYPE REF TO z2ui5_cl_ui5_srv_model.
    DATA lv_json TYPE string.
      FIELD-SYMBOLS <temp237> LIKE LINE OF lo_app->mt_tab.
      DATA temp238 LIKE sy-tabix.
    DATA temp239 TYPE decfloat34.
    DATA temp54 TYPE decfloat34.
    FIELD-SYMBOLS <temp9> LIKE LINE OF lo_app->mt_tab.
    DATA temp10 LIKE sy-tabix.
    DATA temp240 TYPE decfloat34.
    DATA temp55 TYPE decfloat34.
    FIELD-SYMBOLS <temp11> LIKE LINE OF lo_app->mt_tab.
    DATA temp12 LIKE sy-tabix.
    DATA temp241 TYPE decfloat34.
    DATA temp56 TYPE decfloat34.
    FIELD-SYMBOLS <temp13> LIKE LINE OF lo_app->mt_tab.
    DATA temp14 LIKE sy-tabix.
    FIELD-SYMBOLS <temp242> LIKE LINE OF lo_app->mt_tab.
    DATA temp243 LIKE sy-tabix.
    FIELD-SYMBOLS <temp57> LIKE LINE OF <temp242>-t_pos.
    DATA temp58 LIKE sy-tabix.
    FIELD-SYMBOLS <temp244> LIKE LINE OF lo_app->mt_tab.
    DATA temp245 LIKE sy-tabix.
    FIELD-SYMBOLS <temp59> LIKE LINE OF <temp244>-t_sorted.
    DATA temp60 LIKE sy-tabix.
    FIELD-SYMBOLS <temp246> LIKE LINE OF lo_app->mt_tab.
    DATA temp247 LIKE sy-tabix.
    FIELD-SYMBOLS <temp61> LIKE LINE OF <temp246>-t_pos.
    DATA temp62 LIKE sy-tabix.
    DATA temp40 TYPE xsdboolean.
    DATA temp7 LIKE sy-subrc.
    DATA temp41 TYPE xsdboolean.
    DATA temp8 LIKE sy-subrc.
    CREATE OBJECT lo_app TYPE ltcl_app_typed.
    DO 6 TIMES.

      CLEAR temp236.
      temp236-name = |row-{ sy-index }|.
      temp236-price = sy-index * 100.

      CLEAR temp50.

      temp51-qty = sy-index.
      INSERT temp51 INTO TABLE temp50.
      temp236-t_pos = temp50.

      CLEAR temp52.

      temp53-qty = 1.
      INSERT temp53 INTO TABLE temp52.
      temp236-t_sorted = temp52.
      APPEND temp236 TO lo_app->mt_tab.
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


      temp238 = sy-tabix.
      READ TABLE lo_app->mt_tab INDEX sy-index ASSIGNING <temp237>.
      sy-tabix = temp238.
      IF sy-subrc <> 0.
        ASSERT 1 = 0.
      ENDIF.
      cl_abap_unit_assert=>assert_equals( exp = |edited-{ sy-index }|
                                          act = <temp237>-name ).
    ENDDO.

    temp239 = '10.50'.



    temp10 = sy-tabix.
    READ TABLE lo_app->mt_tab INDEX 1 ASSIGNING <temp9>.
    sy-tabix = temp10.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    temp54 = <temp9>-price.
    cl_abap_unit_assert=>assert_equals( exp = temp239
                                        act = temp54 ).

    temp240 = '60.50'.



    temp12 = sy-tabix.
    READ TABLE lo_app->mt_tab INDEX 6 ASSIGNING <temp11>.
    sy-tabix = temp12.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    temp55 = <temp11>-price.
    cl_abap_unit_assert=>assert_equals( exp = temp240
                                        act = temp55 ).
    " the refused price keeps its value - the good name in the SAME row was
    " written

    temp241 = '300'.



    temp14 = sy-tabix.
    READ TABLE lo_app->mt_tab INDEX 3 ASSIGNING <temp13>.
    sy-tabix = temp14.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    temp56 = <temp13>-price.
    cl_abap_unit_assert=>assert_equals( exp = temp241
                                        act = temp56 ).
    " the nested standard table took its cell, the nested sorted one did not


    temp243 = sy-tabix.
    READ TABLE lo_app->mt_tab INDEX 4 ASSIGNING <temp242>.
    sy-tabix = temp243.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.


    temp58 = sy-tabix.
    READ TABLE <temp242>-t_pos INDEX 1 ASSIGNING <temp57>.
    sy-tabix = temp58.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = 9
                                        act = <temp57>-qty ).


    temp245 = sy-tabix.
    READ TABLE lo_app->mt_tab INDEX 5 ASSIGNING <temp244>.
    sy-tabix = temp245.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.


    temp60 = sy-tabix.
    READ TABLE <temp244>-t_sorted INDEX 1 ASSIGNING <temp59>.
    sy-tabix = temp60.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = <temp59>-qty ).
    " a cell the delta did not name is untouched, and no row came or went


    temp247 = sy-tabix.
    READ TABLE lo_app->mt_tab INDEX 2 ASSIGNING <temp246>.
    sy-tabix = temp247.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.


    temp62 = sy-tabix.
    READ TABLE <temp246>-t_pos INDEX 1 ASSIGNING <temp61>.
    sy-tabix = temp62.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = <temp61>-qty ).
    cl_abap_unit_assert=>assert_equals( exp = 6
                                        act = lines( lo_app->mt_tab ) ).

    " exactly the two refusals are traced, each naming its cell
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( lo_model->mt_skipped ) ).


    READ TABLE lo_model->mt_skipped WITH KEY name = `MT_TAB` row = 3 field = `PRICE` value = `1,250.00` TRANSPORTING NO FIELDS.
    temp7 = sy-subrc.
    temp40 = boolc( temp7 = 0 ).
    cl_abap_unit_assert=>assert_true( temp40 ). "#EC CI_SORTSEQ


    READ TABLE lo_model->mt_skipped WITH KEY name = `MT_TAB-T_SORTED` row = 1 row_parent = 5 field = `QTY` value = `5` TRANSPORTING NO FIELDS.
    temp8 = sy-subrc.
    temp41 = boolc( temp8 = 0 ).
    cl_abap_unit_assert=>assert_true( temp41 ). "#EC CI_SORTSEQ

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
    " what a bind carries survives: mapper, filter, json flag
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
    FIELD-SYMBOLS <temp248> LIKE LINE OF mo_app->mt_rows_ref.
    DATA temp249 LIKE sy-tabix.
    FIELD-SYMBOLS <temp250> LIKE LINE OF mo_app->mt_rows_ref.
    DATA temp251 LIKE sy-tabix.
    FIELD-SYMBOLS <temp252> LIKE LINE OF mo_app->mt_comp.
    DATA temp253 LIKE sy-tabix.

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


    temp249 = sy-tabix.
    READ TABLE mo_app->mt_rows_ref INDEX 1 ASSIGNING <temp248>.
    sy-tabix = temp249.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `cell-ref`
                                        act = <temp248>-r_elem->* ).


    temp251 = sy-tabix.
    READ TABLE mo_app->mt_rows_ref INDEX 1 ASSIGNING <temp250>.
    sy-tabix = temp251.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `cell-obj`
                                        act = <temp250>-o_obj->mv_inner ).
    cl_abap_unit_assert=>assert_equals( exp = `protected`
                                        act = mo_app->get_protected( ) ).
    " the rows of the descriptor table survive, the descriptors they held do
    " not (an RTTI descriptor is not serializable), and neither is an error
    cl_abap_unit_assert=>assert_equals( exp = 3
                                        act = lines( mo_app->mt_comp ) ).


    temp253 = sy-tabix.
    READ TABLE mo_app->mt_comp INDEX 1 ASSIGNING <temp252>.
    sy-tabix = temp253.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_not_bound( <temp252>-type ).
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
    DATA temp42 TYPE xsdboolean.

    bind_all( ).
    roundtrip( ).

    lv_second = mo_model->main_json_stringify( ).

    " the restored instance changes its data through the helper's reference
    " (sample 335) before the next draft; the change reaches the model of
    " the roundtrip after that, and the references stay one



    ASSIGN mo_app->mo_inner->mr_shared->* TO <tab>.
    ls_sel-col1 = `appended after the restore`.
    APPEND INITIAL LINE TO <tab> ASSIGNING <row>.
    MOVE-CORRESPONDING ls_sel TO <row>.

    lv_changed = mo_model->main_json_stringify( ).
    cl_abap_unit_assert=>assert_differs( exp = lv_second
                                         act = lv_changed ).

    temp42 = boolc( lv_changed CS `"appended after the restore"` ).
    cl_abap_unit_assert=>assert_true( temp42 ).

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
    DATA temp254 TYPE REF TO cl_abap_tabledescr.
    DATA lo_tab LIKE temp254.
    DATA lr_attri TYPE REF TO z2ui5_if_ui5_types=>ty_t_attri.
    DATA lo_model TYPE REF TO z2ui5_cl_ui5_srv_model.
    DATA ls_bind TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.
    DATA lv_before TYPE string.
    FIELD-SYMBOLS <temp255> LIKE LINE OF lr_attri->*.
    DATA temp256 LIKE sy-tabix.
    FIELD-SYMBOLS <temp257> LIKE LINE OF lr_attri->*.
    DATA temp258 LIKE sy-tabix.
    DATA lv_app_xml TYPE string.
    DATA lv_attri_xml TYPE string.
    DATA temp43 TYPE xsdboolean.
    DATA temp44 TYPE xsdboolean.

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

    temp254 ?= cl_abap_typedescr=>describe_by_data( lo_app->mz_inner->mt_own ).

    lo_tab = temp254.
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


    temp256 = sy-tabix.
    READ TABLE lr_attri->* WITH KEY name = `MZ_INNER->MR_SHARED` ASSIGNING <temp255>.
    sy-tabix = temp256.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_not_initial( <temp255>-srtti_data ).


    temp258 = sy-tabix.
    READ TABLE lr_attri->* WITH KEY name = `MR_TABLE` ASSIGNING <temp257>.
    sy-tabix = temp258.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_initial( <temp257>-srtti_data ).


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


    temp43 = boolc( lo_app->mr_table = lo_app->mr_table_tmp ).
    cl_abap_unit_assert=>assert_true( temp43 ).

    temp44 = boolc( lo_app->mr_table = lo_app->mz_inner->mr_shared ).
    cl_abap_unit_assert=>assert_true( temp44 ).
    cl_abap_unit_assert=>assert_equals( exp = lv_before
                                        act = lo_model->main_json_stringify( ) ).

  ENDMETHOD.

  METHOD dead_objects_stay_quiet.
    DATA temp259 LIKE REF TO mo_app->mv_string.
DATA lr_attri TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.

    bind_all( ).
    roundtrip( ).

    " S15 - not serializable, so gone; and nothing raised on the way
    cl_abap_unit_assert=>assert_not_bound( mo_app->mo_dead ).
    " the row it left behind carries no descriptor and is skipped by the
    " search instead of dumping it
    cl_abap_unit_assert=>assert_not_bound( row( `MO_DEAD->MV_TEXT` )-o_typedescr ).

    GET REFERENCE OF mo_app->mv_string INTO temp259.

lr_attri = mo_model->main_attri_search( temp259 ).
    cl_abap_unit_assert=>assert_equals( exp = `MV_STRING`
                                        act = lr_attri->name ).
    " a refresh drops the orphan rows for good
    mo_model->main_attri_refresh( ).
    cl_abap_unit_assert=>assert_false( row_exists( `MO_DEAD->MV_TEXT` ) ).

  ENDMETHOD.

  METHOD broken_payload_bound_loud.
    DATA lr_payload TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.
        DATA lx TYPE REF TO z2ui5_cx_ui5_util_error.
        DATA temp45 TYPE xsdboolean.
        DATA temp46 TYPE xsdboolean.

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

        temp45 = boolc( lx->get_text( ) CS `APP_STATE_RESTORE_ERROR` ).
        cl_abap_unit_assert=>assert_true( temp45 ).

        temp46 = boolc( lx->get_text( ) CS `MR_HANDLE_TAB` ).
        cl_abap_unit_assert=>assert_true( temp46 ).
    ENDTRY.

  ENDMETHOD.

  METHOD broken_payload_unbound_ok.

    " nothing reads it, so it keeps the lenient treatment - the payload
    " stays on the row (only a SUCCESSFUL restore clears it), the reference
    " the save cleared stays unbound, everything else is restored
    DATA temp260 LIKE REF TO mo_app->mv_string.
    DATA lr_broken TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.
    GET REFERENCE OF mo_app->mv_string INTO temp260.
bind( temp260 ).
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
    DATA temp261 TYPE z2ui5_if_ui5_types=>ty_s_attri.
    DATA temp262 TYPE z2ui5_if_ui5_types=>ty_s_attri.
    DATA temp263 TYPE z2ui5_if_ui5_types=>ty_s_attri.

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

    CLEAR temp261.
    temp261-name = `MV_GONE`.
    temp261-check_dissolved = abap_true.
    temp261-type_kind = row( `MV_STRING` )-type_kind.
    temp261-kind = row( `MV_STRING` )-kind.
    temp261-bind = abap_true.
    temp261-name_client = `/MV_GONE`.
    INSERT temp261 INTO TABLE mr_attri->*.

    CLEAR temp262.
    temp262-name = `MR_GONE`.
    temp262-check_dissolved = abap_true.
    temp262-type_kind = z2ui5_cl_ui5_util_context=>cv_typedescr_typekind_dref.
    temp262-srtti_data = `payload of a reference nobody has`.
    INSERT temp262 INTO TABLE mr_attri->*.

    CLEAR temp263.
    temp263-name = `MR_GONE->*`.
    temp263-name_parent = `MR_GONE`.
    temp263-check_dissolved = abap_true.
    temp263-type_kind = z2ui5_cl_ui5_util_context=>cv_typedescr_typekind_table.
    temp263-name_ref = `MR_SHARED_B->*`.
    INSERT temp263 INTO TABLE mr_attri->*.

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
    DATA temp264 LIKE REF TO mo_app->mv_xstr.
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


    GET REFERENCE OF mo_app->mv_xstr INTO temp264.

lr_attri = mo_model->main_attri_search( temp264 ).
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
    DATA temp265 LIKE REF TO lo_host->mv_selectedkey.
DATA ls_bind TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.
    DATA lv_app_xml TYPE string.
    DATA lv_attri_xml TYPE string.
    DATA lo_b TYPE REF TO ltcl_shp_sub_b.
    FIELD-SYMBOLS <temp266> LIKE LINE OF lr_attri->*.
    DATA temp267 LIKE sy-tabix.
    DATA temp268 LIKE REF TO lo_host->mv_selectedkey.
    DATA temp47 TYPE xsdboolean.
    DATA temp9 LIKE sy-subrc.
    CREATE OBJECT lo_host TYPE ltcl_app_host.

    CREATE OBJECT lo_a TYPE ltcl_shp_sub_a.
    CREATE OBJECT lo_a->mo_layout.
    lo_a->fill( ).
    lo_host->mo_app = lo_a.
    lo_host->mv_selectedkey = `1`.


    CREATE DATA lr_attri.

    CREATE OBJECT lo_model TYPE z2ui5_cl_ui5_srv_model EXPORTING attri = lr_attri app = lo_host.

    GET REFERENCE OF lo_host->mv_selectedkey INTO temp265.

ls_bind = lo_model->main_attri_search( temp265 ).
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


    temp267 = sy-tabix.
    READ TABLE lr_attri->* WITH KEY name = `MO_APP->MO_LAYOUT->MV_INNER` ASSIGNING <temp266>.
    sy-tabix = temp267.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_not_bound( <temp266>-o_typedescr ).

    " the host's own bind first - it walks the A rows of its own kind and
    " used to dump on the first one without a descriptor

    GET REFERENCE OF lo_host->mv_selectedkey INTO temp268.
ls_bind = lo_model->main_attri_search( temp268 ).
    cl_abap_unit_assert=>assert_equals( exp = `MV_SELECTEDKEY`
                                        act = ls_bind->name ).
    " then B's table: not in mt_attri, so the search refreshes and finds it
    ls_bind = lo_model->main_attri_search( lo_b->mt_data ).
    cl_abap_unit_assert=>assert_equals( exp = `MO_APP->MT_DATA->*`
                                        act = ls_bind->name ).
    " the refresh dropped A's rows - nothing of the old class lingers


    READ TABLE lr_attri->* WITH KEY name = `MO_APP->MT_TABLE->*` TRANSPORTING NO FIELDS.
    temp9 = sy-subrc.
    temp47 = boolc( temp9 = 0 ).
    cl_abap_unit_assert=>assert_false( temp47 ).

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
    DATA temp48 TYPE xsdboolean.
    DATA lo_b_restored TYPE REF TO ltcl_shp_sub_b.
    DATA temp49 TYPE xsdboolean.
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

    temp48 = boolc( lv_before CS `"MO_APP_MT_DATA"` ).
    cl_abap_unit_assert=>assert_true( temp48 ).

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

    temp49 = boolc( lo_b_restored->mt_data = lo_b_restored->mo_lay->mr_shared ).
    cl_abap_unit_assert=>assert_true( temp49 ).
    ls_bind = lo_model->main_attri_search( lo_b_restored->mt_data ).
    cl_abap_unit_assert=>assert_equals( exp = `MO_APP->MT_DATA->*`
                                        act = ls_bind->name ).

  ENDMETHOD.

  METHOD bind_options_survive.
    DATA temp269 LIKE REF TO mo_app->ms_flat.
DATA lr_flat TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.
    DATA temp270 LIKE REF TO mo_app->mv_string.
DATA lr_json TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.
    DATA lv_before TYPE string.
    DATA temp50 TYPE xsdboolean.
    DATA temp51 TYPE xsdboolean.

    " mapper, filter and the json flag travel in mt_attri - a filter class
    " that is not serializable would be the app's fault (srv_bind refuses
    " it at bind time), a mapper always serializes
    CLEAR mo_app->ms_flat-col1.

    GET REFERENCE OF mo_app->ms_flat INTO temp269.

lr_flat = bind( temp269 ).
    CREATE OBJECT lr_flat->custom_filter TYPE ltcl_shp_filter.
    lr_flat->custom_mapper = z2ui5_cl_ajson_mapping=>create_lower_case( ).
    mo_app->mv_string = `{"sap.app":{"type":"card"}}`.

    GET REFERENCE OF mo_app->mv_string INTO temp270.

lr_json = bind( temp270 ).
    lr_json->check_json = abap_true.

    lv_before = mo_model->main_json_stringify( ).

    temp50 = boolc( lv_before CS `"col2"` ).
    cl_abap_unit_assert=>assert_true( temp50 ).

    temp51 = boolc( lv_before CS `"col1"` ).
    cl_abap_unit_assert=>assert_false( temp51 ).

    roundtrip( ).

    cl_abap_unit_assert=>assert_bound( row( `MS_FLAT` )-custom_filter ).
    cl_abap_unit_assert=>assert_bound( row( `MS_FLAT` )-custom_mapper ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = row( `MV_STRING` )-check_json ).
    cl_abap_unit_assert=>assert_equals( exp = lv_before
                                        act = mo_model->main_json_stringify( ) ).

  ENDMETHOD.

  METHOD markup_survives.

    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <row> TYPE any.
    DATA ls_sel TYPE ltcl_app_shapes=>ty_s_row_sel.
    DATA temp271 LIKE REF TO mo_app->mv_markup.
    DATA lv_before TYPE string.
    DATA lv_markup LIKE mo_app->mv_markup.

    " markup in a typed attribute (asXML) and in a cell of the runtime-built
    " table (S-RTTI inside asXML) - both serializations escape and unescape
    ASSIGN mo_app->mr_handle_tab->* TO <tab>.
    ls_sel-col1 = mo_app->mv_markup.
    APPEND INITIAL LINE TO <tab> ASSIGNING <row>.
    MOVE-CORRESPONDING ls_sel TO <row>.

    GET REFERENCE OF mo_app->mv_markup INTO temp271.
bind( temp271 ).
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
    FIELD-SYMBOLS <temp272> TYPE ltcl_shp_inner=>ty_s_row.
DATA lr_row LIKE REF TO <temp272>.
    DATA temp273 LIKE REF TO mo_app->mo_inner->mt_own.
DATA temp63 LIKE REF TO lr_row->col1.
DATA temp15 TYPE z2ui5_if_ui5_types=>ty_s_bind_config.
DATA lv_path TYPE string.
    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <row> TYPE any.
    FIELD-SYMBOLS <cell> TYPE any.
    DATA temp274 TYPE REF TO data.
DATA temp64 TYPE z2ui5_if_ui5_types=>ty_s_bind_config.
    DATA temp52 TYPE xsdboolean.

    bind_all( ).
    roundtrip( ).

    " the binder works on the container: the restored app and the restored
    " attribute table, exactly what the next render's _bind( ) sees

    CREATE OBJECT lo_cont TYPE z2ui5_cl_ui5_app_cont.
    lo_cont->mo_app   = mo_app.
    lo_cont->mt_attri = mr_attri.

    CREATE OBJECT lo_bind TYPE z2ui5_cl_ui5_srv_bind EXPORTING APP = lo_cont.

    " row 1 of the helper's own table, the layout row of sample 332

    READ TABLE mo_app->mo_inner->mt_own INDEX 1 ASSIGNING <temp272>.
IF sy-subrc <> 0.
  ASSERT 1 = 0.
ENDIF.

GET REFERENCE OF <temp272> INTO lr_row.

    GET REFERENCE OF mo_app->mo_inner->mt_own INTO temp273.

GET REFERENCE OF lr_row->col1 INTO temp63.

CLEAR temp15.
temp15-tab = temp273.
temp15-tab_index = 1.

lv_path = lo_bind->main( val    = temp63
                                   config = temp15 ).
    cl_abap_unit_assert=>assert_equals( exp = `{/MO_INNER_MT_OWN/0/COL1}`
                                        act = lv_path ).

    " ...and a cell of the runtime-built table behind the generic reference


    ASSIGN mo_app->mr_handle_tab->* TO <tab>.
    READ TABLE <tab> INDEX 2 ASSIGNING <row>.
    cl_abap_unit_assert=>assert_subrc( ).

    ASSIGN COMPONENT `COL1` OF STRUCTURE <row> TO <cell>.
    cl_abap_unit_assert=>assert_subrc( ).

GET REFERENCE OF <cell> INTO temp274.

CLEAR temp64.
temp64-tab = mo_app->mr_handle_tab.
temp64-tab_index = 2.
lv_path = lo_bind->main( val    = temp274
                             config = temp64 ).

    temp52 = boolc( lv_path CP `{/*/1/COL1}` ).
    cl_abap_unit_assert=>assert_true( act = temp52
                                      msg = |cell path after restore: { lv_path }| ).

  ENDMETHOD.

  METHOD interface_and_obj_table.

    DATA lo_other TYPE REF TO ltcl_app_shapes.
    DATA temp275 LIKE REF TO lo_other->mv_string.
    DATA temp276 LIKE REF TO mo_app->mv_string.
    DATA lv_before TYPE string.
    DATA lo_restored TYPE REF TO ltcl_app_shapes.
    FIELD-SYMBOLS <temp277> LIKE LINE OF mo_app->mt_apps.
    DATA temp278 LIKE sy-tabix.
    CREATE OBJECT lo_other TYPE ltcl_app_shapes.
    lo_other->mv_string = `other`.
    mo_app->mi_app = lo_other.

    GET REFERENCE OF lo_other->mv_string INTO temp275.
bind( temp275 ).

    GET REFERENCE OF mo_app->mv_string INTO temp276.
bind( temp276 ).

    lv_before = mo_model->main_json_stringify( ).

    roundtrip( ).

    " S28 - the interface-typed reference and the instance behind it

    lo_restored ?= mo_app->mi_app.
    cl_abap_unit_assert=>assert_equals( exp = `other`
                                        act = lo_restored->mv_string ).
    " S29 - the table of objects, row by row
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( mo_app->mt_apps ) ).


    temp278 = sy-tabix.
    READ TABLE mo_app->mt_apps INDEX 1 ASSIGNING <temp277>.
    sy-tabix = temp278.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `in-table`
                                        act = <temp277>->mv_inner ).
    inv_json_unchanged( lv_before ).
    inv_search_finds_bound( ).

  ENDMETHOD.

  METHOD dref_chain_survives.

    FIELD-SYMBOLS <inner> TYPE REF TO data.
    FIELD-SYMBOLS <elem>  TYPE any.

    " S13 - the value behind mr_ref_ref->*->* is data like any other; the
    " dref save cleared the outer reference and never restored it. Built
    " here and not in fill( ): the NodeJS runtime cannot CREATE DATA a
    " REF TO data object, so this one test is skipped there (see
    " node/setup/abap_transpile.json) while the catalogue stays runnable
    CREATE DATA mo_app->mr_ref_ref TYPE REF TO data.
    ASSIGN mo_app->mr_ref_ref->* TO <inner>.
    CREATE DATA <inner> TYPE string.
    ASSIGN <inner>->* TO <elem>.
    <elem> = `ref-ref`.

    bind( <inner> ).
    cl_abap_unit_assert=>assert_true( row_exists( `MR_REF_REF->*->*` ) ).
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

  METHOD alias_repointed_survives.

    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <row> TYPE any.
    DATA ls_sel TYPE ltcl_app_shapes=>ty_s_row_sel.
    DATA lr_own TYPE REF TO data.
    DATA temp279 TYPE REF TO cl_abap_tabledescr.
    DATA lo_tab LIKE temp279.
    DATA lr_alias TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.
    DATA lr_own_row TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.
    DATA lv_changed TYPE string.
    DATA temp53 TYPE xsdboolean.
    DATA lr_own_tab LIKE REF TO mo_app->mo_inner->mt_own.
    DATA temp54 TYPE xsdboolean.
    DATA temp55 TYPE xsdboolean.
    DATA temp56 TYPE xsdboolean.

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

    temp279 ?= z2ui5_cl_ui5_util_context=>rtti_get_typedescr_by_data_ref( mo_app->mr_shared_b ).

    lo_tab = temp279.
    CREATE DATA lr_own TYPE HANDLE lo_tab.
    ASSIGN lr_own->* TO <tab>.
    ls_sel-col1 = `own`.
    APPEND INITIAL LINE TO <tab> ASSIGNING <row>.
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

    temp53 = boolc( lv_changed CS `"own"` ).
    cl_abap_unit_assert=>assert_true( temp53 ).

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

    temp54 = boolc( mo_app->mr_alias_tab = lr_own_tab ).
    cl_abap_unit_assert=>assert_true( act = temp54
                                      msg = `the restore pointed the alias at its old owner` ).
    cl_abap_unit_assert=>assert_bound( mo_app->mr_shared_a ).
    ASSIGN mo_app->mr_shared_a->* TO <tab>.
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( <tab> ) ).

    temp55 = boolc( mo_app->mr_shared_a = mo_app->mr_shared_b ).
    cl_abap_unit_assert=>assert_false( temp55 ).

    temp56 = boolc( mo_app->mr_shared_b = mo_app->mo_inner->mr_shared ).
    cl_abap_unit_assert=>assert_true( temp56 ).
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
    DATA temp280 TYPE REF TO cl_abap_tabledescr.
    DATA lo_tab LIKE temp280.
    DATA lr_shared TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.
    DATA lr_elem TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.
    DATA lv_changed TYPE string.
    DATA temp57 TYPE xsdboolean.
    DATA temp58 TYPE xsdboolean.
    DATA temp59 TYPE xsdboolean.
    DATA lr_elem_2 LIKE mo_app->mr_elem.
    DATA temp60 TYPE xsdboolean.
    DATA temp61 TYPE xsdboolean.

    " roundtrip 1 on the live instance
    bind_all( ).
    mo_model->main_attri_db_save_srtti( ).
    mo_model->main_attri_db_load( ).

    " main( ) of roundtrip 2: the three references to the shared table are
    " pointed at a NEW table of the same line type, the elementary
    " reference is created again - no draft was read, the rows stay

    temp280 ?= z2ui5_cl_ui5_util_context=>rtti_get_typedescr_by_data_ref( mo_app->mr_shared_a ).

    lo_tab = temp280.
    CREATE DATA lr_new TYPE HANDLE lo_tab.
    ASSIGN lr_new->* TO <tab>.
    ls_sel-col1 = `re-created`.
    APPEND INITIAL LINE TO <tab> ASSIGNING <row>.
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

    temp57 = boolc( lv_changed CS `"re-created"` ).
    cl_abap_unit_assert=>assert_true( temp57 ).

    temp58 = boolc( lv_changed CS `"elem-2"` ).
    cl_abap_unit_assert=>assert_true( temp58 ).

    temp59 = boolc( lv_changed CS `"shared"` ).
    cl_abap_unit_assert=>assert_false( temp59 ).

    " the draft of roundtrip 2, restored in place: the new data, the three
    " references one object again - and, with the save handing the same
    " objects back, the very object main( ) created

    lr_elem_2 = mo_app->mr_elem.
    mo_model->main_attri_db_save_srtti( ).
    mo_model->main_attri_reattach( ).
    inv_all( lv_changed ).

    temp60 = boolc( mo_app->mr_shared_a = lr_new ).
    cl_abap_unit_assert=>assert_true( temp60 ).

    temp61 = boolc( mo_app->mr_elem = lr_elem_2 ).
    cl_abap_unit_assert=>assert_true( temp61 ).
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
    DATA temp62 TYPE xsdboolean.

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

    temp62 = boolc( lv_changed CS `"MR_ELEM_D":7` ).
    cl_abap_unit_assert=>assert_true( temp62 ).

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
    DATA temp63 TYPE xsdboolean.
    DATA temp281 LIKE LINE OF lt_rows.
    DATA lr_old LIKE REF TO temp281.
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

    temp63 = boolc( lv_payloads_1 > 0 ).
    cl_abap_unit_assert=>assert_true( temp63 ).
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
    DATA temp282 LIKE REF TO lo_late->mv_inner.
DATA lr_value TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.
    DATA lr_table TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.
    DATA lv_changed TYPE string.
    DATA temp64 TYPE xsdboolean.
    DATA lr_std LIKE REF TO mo_app->mt_std.
    DATA temp65 TYPE xsdboolean.
    DATA temp66 TYPE xsdboolean.

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

    GET REFERENCE OF lo_late->mv_inner INTO temp282.

lr_value = bind( temp282 ).
    cl_abap_unit_assert=>assert_equals( exp = `MO_INNER->MO_DEEPER->MO_DEEPER->MV_INNER`
                                        act = lr_value->name ).

    lr_table = mo_model->main_attri_search( lo_late->mr_shared ).
    cl_abap_unit_assert=>assert_equals( exp = `MT_STD`
                                        act = lr_table->name ).
    cl_abap_unit_assert=>assert_equals( exp = `MT_STD`
                                        act = row( `MO_INNER->MO_DEEPER->MO_DEEPER->MR_SHARED->*` )-name_ref ).

    lv_changed = mo_model->main_json_stringify( ).

    temp64 = boolc( lv_changed CS `"late"` ).
    cl_abap_unit_assert=>assert_true( temp64 ).

    " the save keeps the alias an alias: restored in place and from a new
    " instance it points INTO mt_std again, not at a copy
    mo_model->main_attri_db_save_srtti( ).
    mo_model->main_attri_db_load( ).
    inv_all( lv_changed ).

    GET REFERENCE OF mo_app->mt_std INTO lr_std.

    temp65 = boolc( mo_app->mo_inner->mo_deeper->mo_deeper->mr_shared = lr_std ).
    cl_abap_unit_assert=>assert_true( temp65 ).

    roundtrip( ).
    inv_all( lv_changed ).
    GET REFERENCE OF mo_app->mt_std INTO lr_std.

    temp66 = boolc( mo_app->mo_inner->mo_deeper->mo_deeper->mr_shared = lr_std ).
    cl_abap_unit_assert=>assert_true( temp66 ).
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
    DATA temp283 TYPE ltcl_app_struct_alias=>ty_t_row.
    DATA temp284 LIKE LINE OF temp283.
    ms_nested-id      = `n1`.

    CLEAR temp283.

    temp284-col1 = `a`.
    temp284-col2 = 1.
    INSERT temp284 INTO TABLE temp283.
    ms_nested-t_items = temp283.
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
    DATA temp285 TYPE REF TO data.
DATA lr_row TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.
    DATA lv_app_xml TYPE string.
    DATA lv_attri_xml TYPE string.
    DATA lo_descr TYPE REF TO cl_abap_typedescr.
    DATA lr_struc LIKE REF TO lo_app->ms_nested.
    DATA temp67 TYPE xsdboolean.

    CREATE OBJECT lo_app.
    lo_app->fill( ).
    CREATE DATA lr_attri.

    CREATE OBJECT lo_model TYPE z2ui5_cl_ui5_srv_model EXPORTING attri = lr_attri app = lo_app.

    " the table bound through the alias, as _bind( mr_alias->t_items ) does
    ASSIGN lo_app->mr_alias->* TO <struc>.
    ASSIGN COMPONENT `T_ITEMS` OF STRUCTURE <struc> TO <tab>.
    cl_abap_unit_assert=>assert_subrc( ).

GET REFERENCE OF <tab> INTO temp285.

lr_row = lo_model->main_attri_search( temp285 ).
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

    lo_descr = cl_abap_typedescr=>describe_by_data_ref( lo_app->mr_alias ).
    cl_abap_unit_assert=>assert_equals( exp = cl_abap_typedescr=>kind_struct
                                        act = lo_descr->kind
                                        msg = |alias re-pointed - it derefs to kind { lo_descr->kind } ({ lo_descr->absolute_name })| ).

    GET REFERENCE OF lo_app->ms_nested INTO lr_struc.

    temp67 = boolc( lo_app->mr_alias = lr_struc ).
    cl_abap_unit_assert=>assert_true( act = temp67
                                      msg = `alias no longer points at ms_nested` ).
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( lo_app->ms_nested-t_items ) ).

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
    DATA temp286 TYPE ltcl_app_two_refs=>ty_t_row.
    DATA temp287 LIKE LINE OF temp286.
    CLEAR temp286.

    temp287-col1 = `a`.
    INSERT temp287 INTO TABLE temp286.
    ma_tab = temp286.
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
    DATA temp288 TYPE REF TO data.
DATA lr_row TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.
    DATA temp289 LIKE LINE OF lr_attri->*.
    DATA lr_alias LIKE REF TO temp289.
    DATA lv_app_xml TYPE string.
    DATA lv_attri_xml TYPE string.
    DATA lr_tab LIKE REF TO lo_app->ma_tab.
    DATA temp68 TYPE xsdboolean.
    DATA temp69 TYPE xsdboolean.

    CREATE OBJECT lo_app.
    lo_app->fill( ).
    CREATE DATA lr_attri.

    CREATE OBJECT lo_model TYPE z2ui5_cl_ui5_srv_model EXPORTING attri = lr_attri app = lo_app.

    " the table bound through the FIRST reference, as _bind( mr_a->* ) does
    ASSIGN lo_app->mr_a->* TO <tab>.

GET REFERENCE OF <tab> INTO temp288.

lr_row = lo_model->main_attri_search( temp288 ).
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

    temp68 = boolc( lo_app->mr_a = lr_tab ).
    cl_abap_unit_assert=>assert_true( act = temp68
                                      msg = `mr_a no longer points at ma_tab` ).
    cl_abap_unit_assert=>assert_bound( act = lo_app->mr_b
                                       msg = `mr_b lost across the draft` ).

    temp69 = boolc( lo_app->mr_b = lr_tab ).
    cl_abap_unit_assert=>assert_true( act = temp69
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
    DATA temp290 TYPE ltcl_app_sub_view=>ty_t_row.
    DATA temp291 LIKE LINE OF temp290.
    CREATE OBJECT lo_sub TYPE ltcl_app_sub_view.

    CLEAR temp290.

    temp291-carrid = `LH`.
    INSERT temp291 INTO TABLE temp290.
    temp291-carrid = `UA`.
    INSERT temp291 INTO TABLE temp290.
    lo_sub->mt_table       = temp290.
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

    DATA temp292 LIKE sy-subrc.
    DATA temp70 TYPE xsdboolean.
    READ TABLE mr_attri->* WITH KEY name = iv_name TRANSPORTING NO FIELDS.
    temp292 = sy-subrc.

    temp70 = boolc( temp292 = 0 ).
    result = temp70.

  ENDMETHOD.

  METHOD rows_under.

    LOOP AT mr_attri->* TRANSPORTING NO FIELDS "#EC CI_SORTSEQ
         WHERE name CP |{ iv_prefix }*|.
      result = result + 1.
    ENDLOOP.

  ENDMETHOD.

  METHOD subapp_binds_under_host.
    DATA temp293 TYPE REF TO ltcl_app_sub_view.
    DATA lo_sub LIKE temp293.
    DATA temp294 LIKE REF TO lo_sub->mt_table.
DATA lr_row TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.
    DATA lv_json TYPE string.
    DATA temp71 TYPE xsdboolean.
    DATA temp295 TYPE REF TO z2ui5_if_ajson.
    DATA lo_front LIKE temp295.
    FIELD-SYMBOLS <temp296> LIKE LINE OF lo_sub->mt_table.
    DATA temp297 LIKE sy-tabix.

    mo_host->create_sub_app( ).
    mo_model->main_attri_refresh( ).

    " the row is the HOST's - the sub-app is reached through MO_APP, so that
    " is the name the draft saves and the model writes back into

    temp293 ?= mo_host->mo_app.

    lo_sub = temp293.

    GET REFERENCE OF lo_sub->mt_table INTO temp294.

lr_row = mo_model->main_attri_search( temp294 ).
    cl_abap_unit_assert=>assert_equals( exp = `MO_APP->MT_TABLE`
                                        act = lr_row->name ).

    lr_row->bind        = abap_true.
    lr_row->name_client = `/MT_TABLE`.

    lv_json = mo_model->main_json_stringify( ).

    temp71 = boolc( lv_json CS `"LH"` ).
    cl_abap_unit_assert=>assert_true( act = temp71
                                      msg = `the sub-app's rows never reached the host's model` ).

    " ...and the way back lands in the sub-app instance, not in a copy

    temp295 ?= z2ui5_cl_ajson=>parse( lv_json ).

    lo_front = temp295.
    lo_front->set( iv_path = `/MT_TABLE/1/CARRID`
                   iv_val  = `AA` ).
    mo_model->main_json_to_attri( lo_front ).


    temp297 = sy-tabix.
    READ TABLE lo_sub->mt_table INDEX 1 ASSIGNING <temp296>.
    sy-tabix = temp297.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `AA`
                                        act = <temp296>-carrid ).

  ENDMETHOD.

  METHOD subapp_created_late_found.

    " roundtrip 1: the host renders and binds its own attribute; no sub-app
    " exists yet, so nothing of it can be in the rows
    DATA temp298 LIKE REF TO mo_host->mv_selectedkey.
DATA lr_key TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.
    FIELD-SYMBOLS <temp299> LIKE LINE OF mr_attri->*.
    DATA temp300 LIKE sy-tabix.
    GET REFERENCE OF mo_host->mv_selectedkey INTO temp298.

lr_key = mo_model->main_attri_search( temp298 ).
    lr_key->bind        = abap_true.
    lr_key->name_client = `/MV_SELECTEDKEY`.
    cl_abap_unit_assert=>assert_false( row_exists( `MO_APP->MT_TABLE` ) ).

    " the tab switch creates it, inside the same request
    mo_host->create_sub_app( ).
    mo_model->main_attri_refresh( ).

    cl_abap_unit_assert=>assert_true( row_exists( `MO_APP->MT_TABLE` ) ).
    " the host's own binding is untouched by the refresh


    temp300 = sy-tabix.
    READ TABLE mr_attri->* WITH KEY name = `MV_SELECTEDKEY` ASSIGNING <temp299>.
    sy-tabix = temp300.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = <temp299>-bind ).

  ENDMETHOD.

  METHOD builder_carries_no_rows.

    mo_model->main_attri_refresh( ).

    " the reference itself is a row - it is a public attribute of the app
    cl_abap_unit_assert=>assert_true( act = row_exists( `MO_MAIN_PAGE` )
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
    cl_abap_unit_assert=>assert_true( row_exists( `MO_APP->MT_TABLE` ) ).

  ENDMETHOD.

  METHOD host_survives_roundtrip.
    DATA temp301 TYPE REF TO ltcl_app_sub_view.
    DATA lo_live LIKE temp301.
    DATA temp302 LIKE REF TO lo_live->mt_table.
DATA lr_row TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.
    DATA lv_before TYPE string.
    DATA lv_app_xml TYPE string.
    DATA lv_attri_xml TYPE string.
    DATA temp303 TYPE REF TO ltcl_app_sub_view.
    DATA lo_back LIKE temp303.

    mo_host->create_sub_app( ).

    temp301 ?= mo_host->mo_app.

    lo_live = temp301.

    GET REFERENCE OF lo_live->mt_table INTO temp302.

lr_row = mo_model->main_attri_search( temp302 ).
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

    temp303 ?= mo_host->mo_app.

    lo_back = temp303.
    cl_abap_unit_assert=>assert_not_bound( act = lo_back->mo_parent_page
                                           msg = `the sub-app's page reference came back` ).
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( lo_back->mt_table ) ).
    cl_abap_unit_assert=>assert_equals( exp = lv_before
                                        act = mo_model->main_json_stringify( ) ).

  ENDMETHOD.

ENDCLASS.
