" A filter for the adopt tests. It declares if_serializable_object for the
" same reason the framework's own filters do (see lcl_empty_filter_keep_rows
" in z2ui5_cl_ui5_client.clas.locals_imp): z2ui5_if_ajson_filter does not
" compose it, and check_serializable( ) refuses a filter that cannot be
" written into the draft.
CLASS ltcl_test_filter DEFINITION FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES z2ui5_if_ajson_filter.
    INTERFACES if_serializable_object.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS ltcl_test_filter IMPLEMENTATION.

  METHOD z2ui5_if_ajson_filter~keep_node.

    rv_keep = abap_true.

  ENDMETHOD.

ENDCLASS.


CLASS ltcl_bnd_helper DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PUBLIC SECTION.
    INTERFACES if_serializable_object.

    TYPES:
      BEGIN OF ty_s_row,
        name TYPE string,
        job  TYPE string,
      END OF ty_s_row.
    TYPES ty_t_row TYPE STANDARD TABLE OF ty_s_row WITH DEFAULT KEY.

    TYPES:
      BEGIN OF ty_s_struc,
        input TYPE string,
      END OF ty_s_struc.

    DATA mv_value TYPE string.
    DATA ms_struc TYPE ty_s_struc.
    DATA mt_tab   TYPE ty_t_row.
ENDCLASS.

CLASS ltcl_bnd_helper IMPLEMENTATION.
ENDCLASS.


CLASS ltcl_bnd_app DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_s_deep,
        input TYPE string,
        BEGIN OF s_02,
          input TYPE string,
          BEGIN OF s_03,
            input TYPE string,
            BEGIN OF s_04,
              input TYPE string,
            END OF s_04,
          END OF s_03,
        END OF s_02,
      END OF ty_s_deep.

    " B01 a root value, B02 one named like the old reserved node
    DATA mv_value TYPE string.
    DATA xx       TYPE string.
    " B03 four structure levels
    DATA ms_deep  TYPE ty_s_deep.
    " B04 a table of structures, B05 one of strings
    DATA mt_tab     TYPE ltcl_bnd_helper=>ty_t_row.
    DATA mt_strings TYPE string_table.
    " B06 typed and generic references, B07 a runtime-built table
    DATA mr_value TYPE REF TO string.
    DATA mr_any   TYPE REF TO data.
    DATA mr_tab   TYPE REF TO data.
    " B08 a helper instance with values, a structure and a table of its own
    DATA mo_obj   TYPE REF TO ltcl_bnd_helper.
    " a value that looks like a cell and is none
    DATA mv_other TYPE string.

    METHODS fill.
ENDCLASS.


CLASS ltcl_bnd_app IMPLEMENTATION.

  METHOD fill.

    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
    DATA temp1 TYPE ltcl_bnd_helper=>ty_t_row.
    DATA temp2 LIKE LINE OF temp1.
    DATA temp3 TYPE string_table.
    DATA temp5 TYPE REF TO cl_abap_tabledescr.
    DATA lo_tab LIKE temp5.
    FIELD-SYMBOLS <temp6> LIKE LINE OF mt_tab.
    DATA temp7 LIKE sy-tabix.

    mv_value = `value`.
    xx       = `xx`.
    ms_deep-input                = `l1`.
    ms_deep-s_02-input           = `l2`.
    ms_deep-s_02-s_03-input      = `l3`.
    ms_deep-s_02-s_03-s_04-input = `l4`.

    CLEAR temp1.

    temp2-name = `Michael Adams`.
    temp2-job = `Scrum Master`.
    INSERT temp2 INTO TABLE temp1.
    temp2-name = `John Miller`.
    temp2-job = `Product Owner`.
    INSERT temp2 INTO TABLE temp1.
    mt_tab = temp1.

    CLEAR temp3.
    INSERT `one` INTO TABLE temp3.
    INSERT `two` INTO TABLE temp3.
    mt_strings = temp3.

    CREATE DATA mr_value.
    mr_value->* = `typed-ref`.
    CREATE DATA mr_any TYPE string.

    temp5 ?= cl_abap_typedescr=>describe_by_data( mt_tab ).

    lo_tab = temp5.
    CREATE DATA mr_tab TYPE HANDLE lo_tab.
    ASSIGN mr_tab->* TO <tab>.
    <tab> = mt_tab.

    CREATE OBJECT mo_obj.
    mo_obj->mv_value       = `helper`.
    mo_obj->ms_struc-input = `helper-struc`.
    mo_obj->mt_tab         = mt_tab.



    temp7 = sy-tabix.
    READ TABLE mt_tab INDEX 1 ASSIGNING <temp6>.
    sy-tabix = temp7.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    mv_other = <temp6>-name.

  ENDMETHOD.

ENDCLASS.


" a filter WITHOUT if_serializable_object - the one thing a bind refuses
CLASS ltcl_bnd_filter_dead DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_ajson_filter.
ENDCLASS.

CLASS ltcl_bnd_filter_dead IMPLEMENTATION.

  METHOD z2ui5_if_ajson_filter~keep_node.
    rv_keep = abap_true.
  ENDMETHOD.

ENDCLASS.


CLASS ltcl_00_base DEFINITION DEFERRED.
CLASS ltcl_01_path DEFINITION DEFERRED.
CLASS ltcl_02_cell DEFINITION DEFERRED.
CLASS ltcl_03_options DEFINITION DEFERRED.
CLASS z2ui5_cl_ui5_srv_bind DEFINITION LOCAL FRIENDS ltcl_00_base ltcl_01_path ltcl_02_cell ltcl_03_options.


CLASS ltcl_00_base DEFINITION ABSTRACT
  FOR TESTING RISK LEVEL HARMLESS DURATION MEDIUM.

  PROTECTED SECTION.
    DATA mo_app  TYPE REF TO ltcl_bnd_app.
    DATA mo_cont TYPE REF TO z2ui5_cl_ui5_app_cont.
    DATA mo_bind TYPE REF TO z2ui5_cl_ui5_srv_bind.

    " main( ) on the same service - what one render's _bind( ) calls do
    METHODS bind
      IMPORTING
        ir_val        TYPE REF TO data
        is_config     TYPE z2ui5_if_ui5_types=>ty_s_bind_config OPTIONAL
      RETURNING
        VALUE(result) TYPE string.

    " the cell of one row of mo_app->mt_tab, as a reference INTO the table
    " (not the way bind_tab_cell( ) builds its own, so the reference match
    " is exercised rather than satisfied by construction)
    METHODS cell_name
      IMPORTING
        iv_index      TYPE i
      RETURNING
        VALUE(result) TYPE REF TO data.

    METHODS expect_bind_error
      IMPORTING
        ir_val    TYPE REF TO data
        is_config TYPE z2ui5_if_ui5_types=>ty_s_bind_config
        iv_text   TYPE string.

  PRIVATE SECTION.
    METHODS setup.
ENDCLASS.


CLASS ltcl_00_base IMPLEMENTATION.

  METHOD setup.

    CREATE OBJECT mo_app.
    mo_app->fill( ).
    CREATE OBJECT mo_cont.
    mo_cont->mo_app = mo_app.
    CREATE OBJECT mo_bind EXPORTING APP = mo_cont.

  ENDMETHOD.

  METHOD bind.

    result = mo_bind->main( val    = ir_val
                            config = is_config ).

  ENDMETHOD.

  METHOD cell_name.

    FIELD-SYMBOLS <row> TYPE ltcl_bnd_helper=>ty_s_row.

    FIELD-SYMBOLS <temp8> TYPE ltcl_bnd_helper=>ty_s_row.
DATA lr_row LIKE REF TO <temp8>.
    READ TABLE mo_app->mt_tab INDEX iv_index ASSIGNING <temp8>.
IF sy-subrc <> 0.
  ASSERT 1 = 0.
ENDIF.

GET REFERENCE OF <temp8> INTO lr_row.
    ASSIGN lr_row->* TO <row>.
    GET REFERENCE OF <row>-name INTO result.

  ENDMETHOD.

  METHOD expect_bind_error.
        DATA lx TYPE REF TO z2ui5_cx_ui5_util_error.
        DATA temp1 TYPE xsdboolean.

    TRY.
        bind( ir_val    = ir_val
              is_config = is_config ).
        cl_abap_unit_assert=>fail( |expected a binding error with '{ iv_text }'| ).

      CATCH z2ui5_cx_ui5_util_error INTO lx.

        temp1 = boolc( lx->get_text( ) CS iv_text ).
        cl_abap_unit_assert=>assert_true( act = temp1
                                          msg = |wrong error: { lx->get_text( ) }| ).
    ENDTRY.

  ENDMETHOD.

ENDCLASS.


" ---------------------------------------------------------------------------
" 01 - the path: for every form, main( ) answers the client path of the
" attribute the value lives in, braces around it
" ---------------------------------------------------------------------------
CLASS ltcl_01_path DEFINITION FINAL INHERITING FROM ltcl_00_base
  FOR TESTING RISK LEVEL HARMLESS DURATION MEDIUM.

  PRIVATE SECTION.
    " B01/B02 root values - XX binds like any other name
    METHODS root_value             FOR TESTING RAISING cx_static_check.
    " B03 one path per structure level, the segments as in ABAP
    METHODS structure_levels       FOR TESTING RAISING cx_static_check.
    " B04/B05 a table as a whole, whatever its line
    METHODS whole_table            FOR TESTING RAISING cx_static_check.
    " B06/B07 a dereferenced reference: the deref segment is `*`
    METHODS reference_deref        FOR TESTING RAISING cx_static_check.
    " B08 values inside a helper instance
    METHODS helper_attribute       FOR TESTING RAISING cx_static_check.
    " the same value bound twice gets the same path, and stays bound once
    METHODS bind_idempotent        FOR TESTING RAISING cx_static_check.
    " path_only and switch_default_model decorate the same path
    METHODS path_decorations       FOR TESTING RAISING cx_static_check.
    " a value that is no attribute of the app - the model's error
    METHODS foreign_value_refused  FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_01_path IMPLEMENTATION.

  METHOD root_value.

    DATA temp9 LIKE REF TO mo_app->mv_value.
    DATA temp10 LIKE REF TO mo_app->xx.
    GET REFERENCE OF mo_app->mv_value INTO temp9.
cl_abap_unit_assert=>assert_equals( exp = `{/MV_VALUE}`
                                        act = bind( temp9 ) ).

    GET REFERENCE OF mo_app->xx INTO temp10.
cl_abap_unit_assert=>assert_equals( exp = `{/XX}`
                                        act = bind( temp10 ) ).

  ENDMETHOD.

  METHOD structure_levels.

    DATA temp11 LIKE REF TO mo_app->ms_deep.
    DATA temp12 LIKE REF TO mo_app->ms_deep-input.
    DATA temp13 LIKE REF TO mo_app->ms_deep-s_02-input.
    DATA temp14 LIKE REF TO mo_app->ms_deep-s_02-s_03-input.
    DATA temp15 LIKE REF TO mo_app->ms_deep-s_02-s_03-s_04-input.
    GET REFERENCE OF mo_app->ms_deep INTO temp11.
cl_abap_unit_assert=>assert_equals( exp = `{/MS_DEEP}`
                                        act = bind( temp11 ) ).

    GET REFERENCE OF mo_app->ms_deep-input INTO temp12.
cl_abap_unit_assert=>assert_equals( exp = `{/MS_DEEP/INPUT}`
                                        act = bind( temp12 ) ).

    GET REFERENCE OF mo_app->ms_deep-s_02-input INTO temp13.
cl_abap_unit_assert=>assert_equals( exp = `{/MS_DEEP/S_02/INPUT}`
                                        act = bind( temp13 ) ).

    GET REFERENCE OF mo_app->ms_deep-s_02-s_03-input INTO temp14.
cl_abap_unit_assert=>assert_equals( exp = `{/MS_DEEP/S_02/S_03/INPUT}`
                                        act = bind( temp14 ) ).

    GET REFERENCE OF mo_app->ms_deep-s_02-s_03-s_04-input INTO temp15.
cl_abap_unit_assert=>assert_equals( exp = `{/MS_DEEP/S_02/S_03/S_04/INPUT}`
                                        act = bind( temp15 ) ).

  ENDMETHOD.

  METHOD whole_table.

    DATA temp16 LIKE REF TO mo_app->mt_tab.
    DATA temp17 LIKE REF TO mo_app->mt_strings.
    GET REFERENCE OF mo_app->mt_tab INTO temp16.
cl_abap_unit_assert=>assert_equals( exp = `{/MT_TAB}`
                                        act = bind( temp16 ) ).

    GET REFERENCE OF mo_app->mt_strings INTO temp17.
cl_abap_unit_assert=>assert_equals( exp = `{/MT_STRINGS}`
                                        act = bind( temp17 ) ).

  ENDMETHOD.

  METHOD reference_deref.

    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
    DATA temp18 LIKE REF TO <tab>.

    " the app hands over the dereferenced data - _bind( <fs> ), not the
    " reference; the row is `MR_VALUE->*`, `>` dropped and `-` a slash
    cl_abap_unit_assert=>assert_equals( exp = `{/MR_VALUE/*}`
                                        act = bind( mo_app->mr_value ) ).
    cl_abap_unit_assert=>assert_equals( exp = `{/MR_ANY/*}`
                                        act = bind( mo_app->mr_any ) ).
    ASSIGN mo_app->mr_tab->* TO <tab>.

    GET REFERENCE OF <tab> INTO temp18.
cl_abap_unit_assert=>assert_equals( exp = `{/MR_TAB/*}`
                                        act = bind( temp18 ) ).

  ENDMETHOD.

  METHOD helper_attribute.

    DATA temp19 LIKE REF TO mo_app->mo_obj->mv_value.
    DATA temp20 LIKE REF TO mo_app->mo_obj->ms_struc-input.
    DATA temp21 LIKE REF TO mo_app->mo_obj->mt_tab.
    GET REFERENCE OF mo_app->mo_obj->mv_value INTO temp19.
cl_abap_unit_assert=>assert_equals( exp = `{/MO_OBJ/MV_VALUE}`
                                        act = bind( temp19 ) ).

    GET REFERENCE OF mo_app->mo_obj->ms_struc-input INTO temp20.
cl_abap_unit_assert=>assert_equals( exp = `{/MO_OBJ/MS_STRUC/INPUT}`
                                        act = bind( temp20 ) ).

    GET REFERENCE OF mo_app->mo_obj->mt_tab INTO temp21.
cl_abap_unit_assert=>assert_equals( exp = `{/MO_OBJ/MT_TAB}`
                                        act = bind( temp21 ) ).

  ENDMETHOD.

  METHOD bind_idempotent.

    DATA temp22 LIKE REF TO mo_app->mv_value.
DATA lv_first TYPE string.
    DATA temp23 LIKE REF TO mo_app->mv_value.
DATA lv_second TYPE string.
    DATA lv_count TYPE i.
    GET REFERENCE OF mo_app->mv_value INTO temp22.

lv_first  = bind( temp22 ).

    GET REFERENCE OF mo_app->mv_value INTO temp23.

lv_second = bind( temp23 ).

    cl_abap_unit_assert=>assert_equals( exp = lv_first
                                        act = lv_second ).
    cl_abap_unit_assert=>assert_not_initial( lv_first ).
    " one row, bound once

    lv_count = 0.
    LOOP AT mo_cont->mt_attri->* TRANSPORTING NO FIELDS WHERE name = `MV_VALUE` AND bind = abap_true. "#EC CI_SORTSEQ
      lv_count = lv_count + 1.
    ENDLOOP.
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lv_count ).

  ENDMETHOD.

  METHOD path_decorations.

    DATA temp24 LIKE REF TO mo_app->ms_deep-input.
DATA temp1 TYPE z2ui5_if_ui5_types=>ty_s_bind_config.
    DATA temp25 LIKE REF TO mo_app->mv_value.
DATA temp2 TYPE z2ui5_if_ui5_types=>ty_s_bind_config.
    DATA temp26 LIKE REF TO mo_app->mv_value.
DATA temp3 TYPE z2ui5_if_ui5_types=>ty_s_bind_config.
    GET REFERENCE OF mo_app->ms_deep-input INTO temp24.

CLEAR temp1.
temp1-path_only = abap_true.
cl_abap_unit_assert=>assert_equals( exp = `/MS_DEEP/INPUT`
                                        act = bind( ir_val    = temp24
                                                    is_config = temp1 ) ).

    GET REFERENCE OF mo_app->mv_value INTO temp25.

CLEAR temp2.
temp2-switch_default_model = abap_true.
cl_abap_unit_assert=>assert_equals( exp = `{http>/MV_VALUE}`
                                        act = bind( ir_val    = temp25
                                                    is_config = temp2 ) ).

    GET REFERENCE OF mo_app->mv_value INTO temp26.

CLEAR temp3.
temp3-switch_default_model = abap_true.
temp3-path_only = abap_true.
cl_abap_unit_assert=>assert_equals( exp = `http>/MV_VALUE`
                                        act = bind( ir_val    = temp26
                                                    is_config = temp3 ) ).

  ENDMETHOD.

  METHOD foreign_value_refused.

    DATA lv_local TYPE string VALUE `not an attribute`.

    DATA temp27 LIKE REF TO lv_local.
DATA temp4 TYPE z2ui5_if_ui5_types=>ty_s_bind_config.
    GET REFERENCE OF lv_local INTO temp27.

CLEAR temp4.
expect_bind_error( ir_val    = temp27
                       is_config = temp4
                       iv_text   = `BINDING_ERROR` ).

  ENDMETHOD.

ENDCLASS.


" ---------------------------------------------------------------------------
" 02 - the cell: a value addressed as one row of a table (config-tab and
" tab_index). ABAP counts rows from 1, the client path from 0; the cell is
" identified by REFERENCE, and the two refusals of bind_tab_cell( ) are the
" only places a wrong call is caught at all
" ---------------------------------------------------------------------------
CLASS ltcl_02_cell DEFINITION FINAL INHERITING FROM ltcl_00_base
  FOR TESTING RISK LEVEL HARMLESS DURATION MEDIUM.

  PRIVATE SECTION.
    " row 1 and row 2 - the index resolved and shifted, not assumed
    METHODS row_index_shifted       FOR TESTING RAISING cx_static_check.
    " the second component of the same row
    METHODS other_column            FOR TESTING RAISING cx_static_check.
    " the decorations apply to a cell path too
    METHODS cell_decorations        FOR TESTING RAISING cx_static_check.
    " a cell of the helper's table and of the runtime-built table
    METHODS cell_in_helper_table    FOR TESTING RAISING cx_static_check.
    METHODS cell_in_runtime_table   FOR TESTING RAISING cx_static_check.
    " an index past the last row
    METHODS index_out_of_range      FOR TESTING RAISING cx_static_check.
    " a value that is not a component of that row, however equal it looks
    METHODS foreign_value_refused   FOR TESTING RAISING cx_static_check.
    " a table of strings has no component to bind a cell of
    METHODS elementary_row_refused  FOR TESTING RAISING cx_static_check.
    " one render, one service: cells of two tables in turn, and a cell of
    " the runtime-built table after main( ) created that table again
    METHODS cells_of_two_tables     FOR TESTING RAISING cx_static_check.
    METHODS cell_after_recreate     FOR TESTING RAISING cx_static_check.
    " the mapper and the filter of a cell bind land on the TABLE, and a
    " second cell with a different mapper is refused like a second _bind( )
    " of the table would be
    METHODS cell_carries_options    FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_02_cell IMPLEMENTATION.

  METHOD cell_carries_options.

    DATA lo_filter TYPE REF TO ltcl_test_filter.
    DATA lo_mapper TYPE REF TO z2ui5_if_ajson_mapping.
    DATA temp28 LIKE REF TO mo_app->mt_tab.
DATA temp5 TYPE z2ui5_if_ui5_types=>ty_s_bind_config.
    DATA temp29 LIKE REF TO mo_app->mt_tab.
DATA lr_tab TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.
    DATA temp30 LIKE REF TO mo_app->mt_tab.
DATA temp6 TYPE z2ui5_if_ui5_types=>ty_s_bind_config.
    DATA temp31 LIKE REF TO mo_app->mt_tab.
DATA temp7 TYPE z2ui5_if_ui5_types=>ty_s_bind_config.
    CREATE OBJECT lo_filter TYPE ltcl_test_filter.

    lo_mapper = z2ui5_cl_ajson_mapping=>create_upper_case( ).


    GET REFERENCE OF mo_app->mt_tab INTO temp28.

CLEAR temp5.
temp5-tab = temp28.
temp5-tab_index = 1.
temp5-custom_filter = lo_filter.
temp5-custom_mapper = lo_mapper.
bind( ir_val    = cell_name( 1 )
          is_config = temp5 ).

    " stored on the table's row - the one the serializer applies them to

    GET REFERENCE OF mo_app->mt_tab INTO temp29.

lr_tab = mo_bind->get_model( )->main_attri_search( temp29 ).
    cl_abap_unit_assert=>assert_equals( exp = lo_filter
                                        act = lr_tab->custom_filter ).
    cl_abap_unit_assert=>assert_equals( exp = lo_mapper
                                        act = lr_tab->custom_mapper ).

    " the same options again, for another cell: no conflict

    GET REFERENCE OF mo_app->mt_tab INTO temp30.

CLEAR temp6.
temp6-tab = temp30.
temp6-tab_index = 2.
temp6-custom_filter = lo_filter.
temp6-custom_mapper = lo_mapper.
bind( ir_val    = cell_name( 2 )
          is_config = temp6 ).

    " a different mapper for a cell of the same table: refused, as the
    " table's own second bind would be - it used to be dropped silently

    GET REFERENCE OF mo_app->mt_tab INTO temp31.

CLEAR temp7.
temp7-tab = temp31.
temp7-tab_index = 1.
temp7-custom_mapper = z2ui5_cl_ajson_mapping=>create_lower_case( ).
expect_bind_error( ir_val    = cell_name( 1 )
                       is_config = temp7
                       iv_text   = `Two different mappers` ).

  ENDMETHOD.

  METHOD row_index_shifted.

    DATA temp32 LIKE REF TO mo_app->mt_tab.
DATA temp8 TYPE z2ui5_if_ui5_types=>ty_s_bind_config.
    DATA temp33 LIKE REF TO mo_app->mt_tab.
DATA temp9 TYPE z2ui5_if_ui5_types=>ty_s_bind_config.
    GET REFERENCE OF mo_app->mt_tab INTO temp32.

CLEAR temp8.
temp8-tab = temp32.
temp8-tab_index = 1.
cl_abap_unit_assert=>assert_equals( exp = `{/MT_TAB/0/NAME}`
                                        act = bind( ir_val    = cell_name( 1 )
                                                    is_config = temp8 ) ).

    GET REFERENCE OF mo_app->mt_tab INTO temp33.

CLEAR temp9.
temp9-tab = temp33.
temp9-tab_index = 2.
cl_abap_unit_assert=>assert_equals( exp = `{/MT_TAB/1/NAME}`
                                        act = bind( ir_val    = cell_name( 2 )
                                                    is_config = temp9 ) ).

  ENDMETHOD.

  METHOD other_column.

    FIELD-SYMBOLS <row> TYPE ltcl_bnd_helper=>ty_s_row.

    FIELD-SYMBOLS <temp34> TYPE ltcl_bnd_helper=>ty_s_row.
DATA lr_row LIKE REF TO <temp34>.
    DATA temp35 LIKE REF TO mo_app->mt_tab.
DATA temp10 LIKE REF TO <row>-job.
DATA temp1 TYPE z2ui5_if_ui5_types=>ty_s_bind_config.
    READ TABLE mo_app->mt_tab INDEX 2 ASSIGNING <temp34>.
IF sy-subrc <> 0.
  ASSERT 1 = 0.
ENDIF.

GET REFERENCE OF <temp34> INTO lr_row.
    ASSIGN lr_row->* TO <row>.


    GET REFERENCE OF mo_app->mt_tab INTO temp35.

GET REFERENCE OF <row>-job INTO temp10.

CLEAR temp1.
temp1-tab = temp35.
temp1-tab_index = 2.
cl_abap_unit_assert=>assert_equals( exp = `{/MT_TAB/1/JOB}`
                                        act = bind( ir_val    = temp10
                                                    is_config = temp1 ) ).

  ENDMETHOD.

  METHOD cell_decorations.

    DATA temp36 LIKE REF TO mo_app->mt_tab.
DATA temp11 TYPE z2ui5_if_ui5_types=>ty_s_bind_config.
    DATA temp37 LIKE REF TO mo_app->mt_tab.
DATA temp12 TYPE z2ui5_if_ui5_types=>ty_s_bind_config.
    GET REFERENCE OF mo_app->mt_tab INTO temp36.

CLEAR temp11.
temp11-tab = temp36.
temp11-tab_index = 1.
temp11-path_only = abap_true.
cl_abap_unit_assert=>assert_equals( exp = `/MT_TAB/0/NAME`
                                        act = bind( ir_val    = cell_name( 1 )
                                                    is_config = temp11 ) ).

    GET REFERENCE OF mo_app->mt_tab INTO temp37.

CLEAR temp12.
temp12-tab = temp37.
temp12-tab_index = 1.
temp12-switch_default_model = abap_true.
cl_abap_unit_assert=>assert_equals( exp = `{http>/MT_TAB/0/NAME}`
                                        act = bind( ir_val    = cell_name( 1 )
                                                    is_config = temp12 ) ).

  ENDMETHOD.

  METHOD cell_in_helper_table.

    FIELD-SYMBOLS <row> TYPE ltcl_bnd_helper=>ty_s_row.

    FIELD-SYMBOLS <temp38> TYPE ltcl_bnd_helper=>ty_s_row.
DATA lr_row LIKE REF TO <temp38>.
    DATA temp39 LIKE REF TO mo_app->mo_obj->mt_tab.
DATA temp13 LIKE REF TO <row>-name.
DATA temp2 TYPE z2ui5_if_ui5_types=>ty_s_bind_config.
    READ TABLE mo_app->mo_obj->mt_tab INDEX 1 ASSIGNING <temp38>.
IF sy-subrc <> 0.
  ASSERT 1 = 0.
ENDIF.

GET REFERENCE OF <temp38> INTO lr_row.
    ASSIGN lr_row->* TO <row>.


    GET REFERENCE OF mo_app->mo_obj->mt_tab INTO temp39.

GET REFERENCE OF <row>-name INTO temp13.

CLEAR temp2.
temp2-tab = temp39.
temp2-tab_index = 1.
cl_abap_unit_assert=>assert_equals( exp = `{/MO_OBJ/MT_TAB/0/NAME}`
                                        act = bind( ir_val    = temp13
                                                    is_config = temp2 ) ).

  ENDMETHOD.

  METHOD cell_in_runtime_table.

    FIELD-SYMBOLS <tab>  TYPE STANDARD TABLE.
    FIELD-SYMBOLS <row>  TYPE any.
    FIELD-SYMBOLS <name> TYPE any.
    DATA temp40 TYPE REF TO data.
DATA temp14 TYPE z2ui5_if_ui5_types=>ty_s_bind_config.

    ASSIGN mo_app->mr_tab->* TO <tab>.
    READ TABLE <tab> INDEX 2 ASSIGNING <row>.
    ASSIGN COMPONENT `NAME` OF STRUCTURE <row> TO <name>.
    cl_abap_unit_assert=>assert_subrc( ).

    " the table behind a generic reference: the cell path carries the
    " deref segment of the table's own path

GET REFERENCE OF <name> INTO temp40.

CLEAR temp14.
temp14-tab = mo_app->mr_tab.
temp14-tab_index = 2.
cl_abap_unit_assert=>assert_equals( exp = `{/MR_TAB/*/1/NAME}`
                                        act = bind( ir_val    = temp40
                                                    is_config = temp14 ) ).

  ENDMETHOD.

  METHOD index_out_of_range.

    DATA temp41 LIKE REF TO mo_app->mt_tab.
DATA temp15 TYPE z2ui5_if_ui5_types=>ty_s_bind_config.
    GET REFERENCE OF mo_app->mt_tab INTO temp41.

CLEAR temp15.
temp15-tab = temp41.
temp15-tab_index = 3.
expect_bind_error( ir_val    = cell_name( 1 )
                       is_config = temp15
                       iv_text   = `BINDING_ERROR_TAB_CELL_LEVEL` ).

  ENDMETHOD.

  METHOD foreign_value_refused.

    " mv_other holds the same text as the cell - a value, not the cell
    DATA temp42 LIKE REF TO mo_app->mt_tab.
DATA temp16 LIKE REF TO mo_app->mv_other.
DATA temp3 TYPE z2ui5_if_ui5_types=>ty_s_bind_config.
    GET REFERENCE OF mo_app->mt_tab INTO temp42.

GET REFERENCE OF mo_app->mv_other INTO temp16.

CLEAR temp3.
temp3-tab = temp42.
temp3-tab_index = 1.
expect_bind_error( ir_val    = temp16
                       is_config = temp3
                       iv_text   = `BINDING_ERROR_TAB_CELL_LEVEL` ).

  ENDMETHOD.

  METHOD elementary_row_refused.

    DATA temp43 LIKE REF TO mo_app->mt_strings.
FIELD-SYMBOLS <temp4> TYPE string.
DATA temp17 LIKE REF TO <temp4>.
DATA temp5 TYPE z2ui5_if_ui5_types=>ty_s_bind_config.
    GET REFERENCE OF mo_app->mt_strings INTO temp43.

READ TABLE mo_app->mt_strings INDEX 1 ASSIGNING <temp4>.
IF sy-subrc <> 0.
  ASSERT 1 = 0.
ENDIF.

GET REFERENCE OF <temp4> INTO temp17.

CLEAR temp5.
temp5-tab = temp43.
temp5-tab_index = 1.
expect_bind_error( ir_val    = temp17
                       is_config = temp5
                       iv_text   = `not a structure` ).

  ENDMETHOD.


  METHOD cells_of_two_tables.

    FIELD-SYMBOLS <row> TYPE ltcl_bnd_helper=>ty_s_row.

    FIELD-SYMBOLS <temp44> TYPE ltcl_bnd_helper=>ty_s_row.
DATA lr_helper_row LIKE REF TO <temp44>.
    DATA temp45 LIKE REF TO mo_app->mt_tab.
DATA temp18 TYPE z2ui5_if_ui5_types=>ty_s_bind_config.
    DATA temp46 LIKE REF TO mo_app->mo_obj->mt_tab.
DATA temp19 LIKE REF TO <row>-name.
DATA temp6 TYPE z2ui5_if_ui5_types=>ty_s_bind_config.
    DATA temp47 LIKE REF TO mo_app->mt_tab.
DATA temp20 TYPE z2ui5_if_ui5_types=>ty_s_bind_config.
    DATA temp48 LIKE REF TO mo_app->mt_tab.
DATA temp21 LIKE REF TO <row>-name.
DATA temp7 TYPE z2ui5_if_ui5_types=>ty_s_bind_config.
    READ TABLE mo_app->mo_obj->mt_tab INDEX 1 ASSIGNING <temp44>.
IF sy-subrc <> 0.
  ASSERT 1 = 0.
ENDIF.

GET REFERENCE OF <temp44> INTO lr_helper_row.
    ASSIGN lr_helper_row->* TO <row>.

    " app table, helper table, app table again - each answer names ITS table

    GET REFERENCE OF mo_app->mt_tab INTO temp45.

CLEAR temp18.
temp18-tab = temp45.
temp18-tab_index = 1.
cl_abap_unit_assert=>assert_equals( exp = `{/MT_TAB/0/NAME}`
                                        act = bind( ir_val    = cell_name( 1 )
                                                    is_config = temp18 ) ).

    GET REFERENCE OF mo_app->mo_obj->mt_tab INTO temp46.

GET REFERENCE OF <row>-name INTO temp19.

CLEAR temp6.
temp6-tab = temp46.
temp6-tab_index = 1.
cl_abap_unit_assert=>assert_equals( exp = `{/MO_OBJ/MT_TAB/0/NAME}`
                                        act = bind( ir_val    = temp19
                                                    is_config = temp6 ) ).

    GET REFERENCE OF mo_app->mt_tab INTO temp47.

CLEAR temp20.
temp20-tab = temp47.
temp20-tab_index = 2.
cl_abap_unit_assert=>assert_equals( exp = `{/MT_TAB/1/NAME}`
                                        act = bind( ir_val    = cell_name( 2 )
                                                    is_config = temp20 ) ).
    " the two tables hold equal rows (fill copies the one into the other):
    " the helper's cell handed in with the APP's table is a foreign value,
    " not a match by content

    GET REFERENCE OF mo_app->mt_tab INTO temp48.

GET REFERENCE OF <row>-name INTO temp21.

CLEAR temp7.
temp7-tab = temp48.
temp7-tab_index = 1.
expect_bind_error( ir_val    = temp21
                       is_config = temp7
                       iv_text   = `BINDING_ERROR_TAB_CELL_LEVEL` ).

  ENDMETHOD.

  METHOD cell_after_recreate.

    FIELD-SYMBOLS <tab>  TYPE STANDARD TABLE.
    FIELD-SYMBOLS <row>  TYPE any.
    FIELD-SYMBOLS <name> TYPE any.
    DATA temp49 TYPE REF TO data.
DATA temp22 TYPE z2ui5_if_ui5_types=>ty_s_bind_config.
    DATA lr_old_cell TYPE REF TO data.
    DATA lr_old LIKE mo_app->mr_tab.
    DATA temp50 TYPE REF TO cl_abap_tabledescr.
    DATA lo_tab LIKE temp50.
    DATA temp51 TYPE REF TO data.
DATA temp23 TYPE z2ui5_if_ui5_types=>ty_s_bind_config.
    DATA temp52 TYPE z2ui5_if_ui5_types=>ty_s_bind_config.

    " a cell of the runtime-built table, as it is
    ASSIGN mo_app->mr_tab->* TO <tab>.
    READ TABLE <tab> INDEX 2 ASSIGNING <row>.
    ASSIGN COMPONENT `NAME` OF STRUCTURE <row> TO <name>.
    cl_abap_unit_assert=>assert_subrc( ).

GET REFERENCE OF <name> INTO temp49.

CLEAR temp22.
temp22-tab = mo_app->mr_tab.
temp22-tab_index = 2.
cl_abap_unit_assert=>assert_equals( exp = `{/MR_TAB/*/1/NAME}`
                                        act = bind( ir_val    = temp49
                                                    is_config = temp22 ) ).


    lr_old = mo_app->mr_tab.
    " a typed target for the REF of a generic field symbol - REF #( ) into
    " an inline declaration has no type to infer (see abap-check)
    GET REFERENCE OF <name> INTO lr_old_cell.

    " main( ) creates the table again - a new object under the same name,
    " one row - and binds a cell of it on the SAME service

    temp50 ?= cl_abap_typedescr=>describe_by_data( mo_app->mt_tab ).

    lo_tab = temp50.
    CREATE DATA mo_app->mr_tab TYPE HANDLE lo_tab.
    ASSIGN mo_app->mr_tab->* TO <tab>.
    APPEND INITIAL LINE TO <tab> ASSIGNING <row>.
    ASSIGN COMPONENT `NAME` OF STRUCTURE <row> TO <name>.
    cl_abap_unit_assert=>assert_subrc( ).
    <name> = `re-created`.


GET REFERENCE OF <name> INTO temp51.

CLEAR temp23.
temp23-tab = mo_app->mr_tab.
temp23-tab_index = 1.
cl_abap_unit_assert=>assert_equals( exp = `{/MR_TAB/*/0/NAME}`
                                        act = bind( ir_val    = temp51
                                                    is_config = temp23 ) ).
    " ...and a cell of the old table object is nobody's attribute

    CLEAR temp52.
    temp52-tab = lr_old.
    temp52-tab_index = 2.
    expect_bind_error( ir_val    = lr_old_cell
                       is_config = temp52
                       iv_text   = `BINDING_ERROR` ).

  ENDMETHOD.
ENDCLASS.


" ---------------------------------------------------------------------------
" 03 - the options: mapper, filter and the json flag are stored on the
" attribute row and travel with the draft. A later bind adopts what the row
" does not carry yet, keeps what it has, and refuses a different
" implementation or one that cannot be serialized
" ---------------------------------------------------------------------------
CLASS ltcl_03_options DEFINITION FINAL INHERITING FROM ltcl_00_base
  FOR TESTING RISK LEVEL HARMLESS DURATION MEDIUM.

  PRIVATE SECTION.
    " the first bind stores all three
    METHODS options_stored          FOR TESTING RAISING cx_static_check.
    " a plain first bind invents nothing
    METHODS plain_bind_stores_none  FOR TESTING RAISING cx_static_check.
    " a later bind with a filter, a mapper or json adopts it
    METHODS later_bind_adopts       FOR TESTING RAISING cx_static_check.
    " a later plain bind keeps them - json only ever turns on
    METHODS later_plain_bind_keeps  FOR TESTING RAISING cx_static_check.
    " the same implementation again is no conflict
    METHODS same_impl_accepted      FOR TESTING RAISING cx_static_check.
    " a different mapper or filter for the same attribute is refused
    METHODS different_mapper_refused FOR TESTING RAISING cx_static_check.
    METHODS different_filter_refused FOR TESTING RAISING cx_static_check.
    " a filter that cannot be serialized is refused at bind time - on the
    " first bind and when a later bind would adopt it
    METHODS dead_filter_refused     FOR TESTING RAISING cx_static_check.
    " options are per attribute - a second attribute starts clean
    METHODS options_per_attribute   FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_03_options IMPLEMENTATION.

  METHOD options_stored.

    DATA lo_filter TYPE REF TO ltcl_test_filter.
    DATA lo_mapper TYPE REF TO z2ui5_if_ajson_mapping.
    DATA temp53 LIKE REF TO mo_app->mv_value.
DATA temp24 TYPE z2ui5_if_ui5_types=>ty_s_bind_config.
    DATA lr_attri LIKE mo_bind->mr_attri.
    CREATE OBJECT lo_filter TYPE ltcl_test_filter.

    lo_mapper = z2ui5_cl_ajson_mapping=>create_upper_case( ).


    GET REFERENCE OF mo_app->mv_value INTO temp53.

CLEAR temp24.
temp24-custom_filter = lo_filter.
temp24-custom_mapper = lo_mapper.
temp24-check_json = abap_true.
bind( ir_val    = temp53
          is_config = temp24 ).


    lr_attri = mo_bind->mr_attri.
    cl_abap_unit_assert=>assert_equals( exp = lo_filter
                                        act = lr_attri->custom_filter ).
    cl_abap_unit_assert=>assert_equals( exp = lo_mapper
                                        act = lr_attri->custom_mapper ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = lr_attri->check_json ).

  ENDMETHOD.

  METHOD plain_bind_stores_none.

    DATA temp54 LIKE REF TO mo_app->mv_value.
    DATA lr_attri LIKE mo_bind->mr_attri.
    GET REFERENCE OF mo_app->mv_value INTO temp54.
bind( temp54 ).


    lr_attri = mo_bind->mr_attri.
    cl_abap_unit_assert=>assert_not_bound( lr_attri->custom_filter ).
    cl_abap_unit_assert=>assert_not_bound( lr_attri->custom_mapper ).
    cl_abap_unit_assert=>assert_equals( exp = abap_false
                                        act = lr_attri->check_json ).

  ENDMETHOD.

  METHOD later_bind_adopts.

    " a filter handed to a LATER _bind( ) of an already-bound attribute used
    " to be dropped without a word - and because mt_attri is serialized into
    " the draft, the order of the two calls in the first render decided the
    " behaviour for the rest of the session
    DATA temp55 LIKE REF TO mo_app->mv_value.
    DATA lo_filter TYPE REF TO ltcl_test_filter.
    DATA temp56 LIKE REF TO mo_app->mv_value.
DATA temp25 TYPE z2ui5_if_ui5_types=>ty_s_bind_config.
    DATA temp57 LIKE REF TO mo_app->mv_value.
DATA temp26 TYPE z2ui5_if_ui5_types=>ty_s_bind_config.
    DATA temp58 LIKE REF TO mo_app->mv_value.
DATA temp27 TYPE z2ui5_if_ui5_types=>ty_s_bind_config.
    DATA lr_attri LIKE mo_bind->mr_attri.
    GET REFERENCE OF mo_app->mv_value INTO temp55.
bind( temp55 ).


    CREATE OBJECT lo_filter TYPE ltcl_test_filter.

    GET REFERENCE OF mo_app->mv_value INTO temp56.

CLEAR temp25.
temp25-custom_filter = lo_filter.
bind( ir_val    = temp56
          is_config = temp25 ).

    GET REFERENCE OF mo_app->mv_value INTO temp57.

CLEAR temp26.
temp26-custom_mapper = z2ui5_cl_ajson_mapping=>create_upper_case( ).
bind( ir_val    = temp57
          is_config = temp26 ).

    GET REFERENCE OF mo_app->mv_value INTO temp58.

CLEAR temp27.
temp27-check_json = abap_true.
bind( ir_val    = temp58
          is_config = temp27 ).


    lr_attri = mo_bind->mr_attri.
    cl_abap_unit_assert=>assert_equals( exp = lo_filter
                                        act = lr_attri->custom_filter ).
    cl_abap_unit_assert=>assert_bound( lr_attri->custom_mapper ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = lr_attri->check_json ).

  ENDMETHOD.

  METHOD later_plain_bind_keeps.

    DATA lo_filter TYPE REF TO ltcl_test_filter.
    DATA temp59 LIKE REF TO mo_app->mv_value.
DATA temp28 TYPE z2ui5_if_ui5_types=>ty_s_bind_config.
    DATA temp60 LIKE REF TO mo_app->mv_value.
    DATA lr_attri LIKE mo_bind->mr_attri.
    CREATE OBJECT lo_filter TYPE ltcl_test_filter.

    GET REFERENCE OF mo_app->mv_value INTO temp59.

CLEAR temp28.
temp28-custom_filter = lo_filter.
temp28-custom_mapper = z2ui5_cl_ajson_mapping=>create_upper_case( ).
temp28-check_json = abap_true.
bind( ir_val    = temp59
          is_config = temp28 ).


    GET REFERENCE OF mo_app->mv_value INTO temp60.
bind( temp60 ).


    lr_attri = mo_bind->mr_attri.
    cl_abap_unit_assert=>assert_equals( exp = lo_filter
                                        act = lr_attri->custom_filter ).
    cl_abap_unit_assert=>assert_bound( lr_attri->custom_mapper ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = lr_attri->check_json ).

  ENDMETHOD.

  METHOD same_impl_accepted.

    " a second INSTANCE of the same class - what every render creates anew
    DATA temp61 LIKE REF TO mo_app->mv_value.
DATA temp29 TYPE z2ui5_if_ui5_types=>ty_s_bind_config.
    DATA temp62 LIKE REF TO mo_app->mv_value.
DATA temp30 TYPE z2ui5_if_ui5_types=>ty_s_bind_config.
DATA lv_path TYPE string.
    GET REFERENCE OF mo_app->mv_value INTO temp61.

CLEAR temp29.
CREATE OBJECT temp29-custom_filter TYPE ltcl_test_filter.
temp29-custom_mapper = z2ui5_cl_ajson_mapping=>create_upper_case( ).
bind( ir_val    = temp61
          is_config = temp29 ).

    GET REFERENCE OF mo_app->mv_value INTO temp62.

CLEAR temp30.
CREATE OBJECT temp30-custom_filter TYPE ltcl_test_filter.
temp30-custom_mapper = z2ui5_cl_ajson_mapping=>create_upper_case( ).

lv_path = bind( ir_val    = temp62
                          is_config = temp30 ).

    cl_abap_unit_assert=>assert_equals( exp = `{/MV_VALUE}`
                                        act = lv_path ).

  ENDMETHOD.

  METHOD different_mapper_refused.

    DATA temp63 LIKE REF TO mo_app->mv_value.
DATA temp31 TYPE z2ui5_if_ui5_types=>ty_s_bind_config.
    DATA temp64 LIKE REF TO mo_app->mv_value.
DATA temp32 TYPE z2ui5_if_ui5_types=>ty_s_bind_config.
    GET REFERENCE OF mo_app->mv_value INTO temp63.

CLEAR temp31.
temp31-custom_mapper = z2ui5_cl_ajson_mapping=>create_upper_case( ).
bind( ir_val    = temp63
          is_config = temp31 ).


    GET REFERENCE OF mo_app->mv_value INTO temp64.

CLEAR temp32.
temp32-custom_mapper = z2ui5_cl_ajson_mapping=>create_lower_case( ).
expect_bind_error( ir_val    = temp64
                       is_config = temp32
                       iv_text   = `Two different mappers` ).

  ENDMETHOD.

  METHOD different_filter_refused.

    DATA temp65 LIKE REF TO mo_app->mv_value.
DATA temp33 TYPE z2ui5_if_ui5_types=>ty_s_bind_config.
    DATA temp66 LIKE REF TO mo_app->mv_value.
DATA temp34 TYPE z2ui5_if_ui5_types=>ty_s_bind_config.
    GET REFERENCE OF mo_app->mv_value INTO temp65.

CLEAR temp33.
CREATE OBJECT temp33-custom_filter TYPE ltcl_test_filter.
bind( ir_val    = temp65
          is_config = temp33 ).

    " the framework's own row filter is another implementation

    GET REFERENCE OF mo_app->mv_value INTO temp66.

CLEAR temp34.
temp34-custom_filter = z2ui5_cl_ajson_filter_lib=>create_empty_filter( ).
expect_bind_error( ir_val    = temp66
                       is_config = temp34
                       iv_text   = `Two different filters` ).

  ENDMETHOD.

  METHOD dead_filter_refused.

    DATA temp67 LIKE REF TO mo_app->mv_value.
DATA temp35 TYPE z2ui5_if_ui5_types=>ty_s_bind_config.
    DATA temp68 LIKE REF TO mo_app->mv_value.
    DATA temp69 LIKE REF TO mo_app->mv_value.
DATA temp36 TYPE z2ui5_if_ui5_types=>ty_s_bind_config.
    GET REFERENCE OF mo_app->mv_value INTO temp67.

CLEAR temp35.
CREATE OBJECT temp35-custom_filter TYPE ltcl_bnd_filter_dead.
expect_bind_error( ir_val    = temp67
                       is_config = temp35
                       iv_text   = `not serializable` ).

    " ...and the row stays unbound after the refusal, so the next bind is
    " a first one again

    GET REFERENCE OF mo_app->mv_value INTO temp68.
bind( temp68 ).

    GET REFERENCE OF mo_app->mv_value INTO temp69.

CLEAR temp36.
CREATE OBJECT temp36-custom_filter TYPE ltcl_bnd_filter_dead.
expect_bind_error( ir_val    = temp69
                       is_config = temp36
                       iv_text   = `not serializable` ).

  ENDMETHOD.

  METHOD options_per_attribute.

    DATA temp70 LIKE REF TO mo_app->mv_value.
DATA temp37 TYPE z2ui5_if_ui5_types=>ty_s_bind_config.
    DATA temp71 LIKE REF TO mo_app->xx.
    DATA lr_attri LIKE mo_bind->mr_attri.
    GET REFERENCE OF mo_app->mv_value INTO temp70.

CLEAR temp37.
temp37-custom_mapper = z2ui5_cl_ajson_mapping=>create_upper_case( ).
temp37-check_json = abap_true.
bind( ir_val    = temp70
          is_config = temp37 ).

    GET REFERENCE OF mo_app->xx INTO temp71.
bind( temp71 ).


    lr_attri = mo_bind->mr_attri.
    cl_abap_unit_assert=>assert_equals( exp = `XX`
                                        act = lr_attri->name ).
    cl_abap_unit_assert=>assert_not_bound( lr_attri->custom_mapper ).
    cl_abap_unit_assert=>assert_equals( exp = abap_false
                                        act = lr_attri->check_json ).

  ENDMETHOD.

ENDCLASS.
