
CLASS ltcl_test_bind DEFINITION DEFERRED.
CLASS z2ui5_cl_ui5_srv_bind DEFINITION LOCAL FRIENDS ltcl_test_bind.

CLASS ltcl_test_app DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION MEDIUM.

  PUBLIC SECTION.

    TYPES:
      BEGIN OF s_01,
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
      END OF s_01.

    DATA ms_struc TYPE s_01 ##NEEDED.
    DATA mv_value TYPE string ##NEEDED.
    DATA mr_value TYPE REF TO data ##NEEDED.
    DATA mr_struc TYPE REF TO s_01 ##NEEDED.
    DATA mo_app   TYPE REF TO ltcl_test_bind ##NEEDED.

    DATA xx       TYPE string ##NEEDED.
ENDCLASS.


" the transpiler only emits a class that has an implementation part,
" so keep the empty block even though the class declares no methods
CLASS ltcl_test_app IMPLEMENTATION.
ENDCLASS.


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


CLASS ltcl_test_bind DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION MEDIUM.

  PUBLIC SECTION.

  PROTECTED SECTION.

  PRIVATE SECTION.
    METHODS test_bind_path         FOR TESTING RAISING cx_static_check.
    METHODS test_attri_named_xx    FOR TESTING RAISING cx_static_check.
    METHODS test_bind_idempotent   FOR TESTING RAISING cx_static_check.
    METHODS test_bind_adopt_filter FOR TESTING RAISING cx_static_check.
    METHODS test_bind_adopt_json   FOR TESTING RAISING cx_static_check.
    METHODS test_bind_keeps_json   FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_test_bind IMPLEMENTATION.
  METHOD test_attri_named_xx.

    " XX used to be a reserved model-node name; now that the bound data
    " lives directly on the root, an attribute named XX binds like any other
    DATA lo_app_client TYPE REF TO ltcl_test_app.
    DATA lo_app TYPE REF TO z2ui5_cl_ui5_app_cont.
    DATA lo_bind TYPE REF TO z2ui5_cl_ui5_srv_bind.
    DATA temp1 LIKE REF TO lo_app_client->xx.
DATA lv_bind TYPE string.
    CREATE OBJECT lo_app_client TYPE ltcl_test_app.

    CREATE OBJECT lo_app TYPE z2ui5_cl_ui5_app_cont.
    lo_app->mo_app = lo_app_client.


    CREATE OBJECT lo_bind TYPE z2ui5_cl_ui5_srv_bind EXPORTING APP = lo_app.


    GET REFERENCE OF lo_app_client->xx INTO temp1.

lv_bind = lo_bind->main( temp1 ).

    cl_abap_unit_assert=>assert_equals( exp = `{/XX}`
                                        act = lv_bind ).

  ENDMETHOD.

  METHOD test_bind_path.

    DATA lo_app_client TYPE REF TO ltcl_test_app.
    DATA lo_app TYPE REF TO z2ui5_cl_ui5_app_cont.
    DATA lo_bind TYPE REF TO z2ui5_cl_ui5_srv_bind.
    DATA temp2 LIKE REF TO lo_app_client->mv_value.
DATA lv_bind TYPE string.
    CREATE OBJECT lo_app_client TYPE ltcl_test_app.

    CREATE OBJECT lo_app TYPE z2ui5_cl_ui5_app_cont.
    lo_app->mo_app = lo_app_client.


    CREATE OBJECT lo_bind TYPE z2ui5_cl_ui5_srv_bind EXPORTING APP = lo_app.


    GET REFERENCE OF lo_app_client->mv_value INTO temp2.

lv_bind = lo_bind->main( temp2 ).

    cl_abap_unit_assert=>assert_equals( exp = `{/MV_VALUE}`
                                        act = lv_bind ).

  ENDMETHOD.

  METHOD test_bind_idempotent.

    DATA lo_app_client TYPE REF TO ltcl_test_app.
    DATA lo_app TYPE REF TO z2ui5_cl_ui5_app_cont.
    DATA lo_bind TYPE REF TO z2ui5_cl_ui5_srv_bind.
    DATA temp3 LIKE REF TO lo_app_client->mv_value.
DATA lv_bind TYPE string.
    DATA temp4 LIKE REF TO lo_app_client->mv_value.
DATA lv_bind2 TYPE string.
    CREATE OBJECT lo_app_client TYPE ltcl_test_app.

    CREATE OBJECT lo_app TYPE z2ui5_cl_ui5_app_cont.
    lo_app->mo_app = lo_app_client.


    CREATE OBJECT lo_bind TYPE z2ui5_cl_ui5_srv_bind EXPORTING APP = lo_app.


    GET REFERENCE OF lo_app_client->mv_value INTO temp3.

lv_bind = lo_bind->main( temp3 ).


    GET REFERENCE OF lo_app_client->mv_value INTO temp4.

lv_bind2 = lo_bind->main( temp4 ).

    cl_abap_unit_assert=>assert_equals( exp = lv_bind2
                                        act = lv_bind ).

    cl_abap_unit_assert=>assert_not_initial( lv_bind ).

  ENDMETHOD.

  METHOD test_bind_adopt_filter.

    " a filter handed to a LATER _bind( ) of an already-bound attribute used
    " to be dropped without a word: update_model_attri( ) runs on the new
    " binding only, and check_raise_existing( ) sees no conflict because the
    " stored attribute carries no filter to conflict with
    DATA lo_app_client TYPE REF TO ltcl_test_app.
    DATA lo_app TYPE REF TO z2ui5_cl_ui5_app_cont.
    DATA lo_bind TYPE REF TO z2ui5_cl_ui5_srv_bind.
    DATA temp5 LIKE REF TO lo_app_client->mv_value.
    DATA lo_filter TYPE REF TO ltcl_test_filter.
    DATA temp6 LIKE REF TO lo_app_client->mv_value.
DATA temp1 TYPE z2ui5_if_ui5_types=>ty_s_bind_config.
    CREATE OBJECT lo_app_client TYPE ltcl_test_app.

    CREATE OBJECT lo_app TYPE z2ui5_cl_ui5_app_cont.
    lo_app->mo_app = lo_app_client.


    CREATE OBJECT lo_bind TYPE z2ui5_cl_ui5_srv_bind EXPORTING APP = lo_app.


    GET REFERENCE OF lo_app_client->mv_value INTO temp5.
lo_bind->main( temp5 ).

    cl_abap_unit_assert=>assert_not_bound(
        act = lo_bind->mr_attri->custom_filter
        msg = `the plain first bind must not invent a filter` ).


    CREATE OBJECT lo_filter TYPE ltcl_test_filter.

    GET REFERENCE OF lo_app_client->mv_value INTO temp6.

CLEAR temp1.
temp1-custom_filter = lo_filter.
lo_bind->main( val    = temp6
                   config = temp1 ).

    cl_abap_unit_assert=>assert_bound(
        act = lo_bind->mr_attri->custom_filter
        msg = `the second bind's filter has to reach the attribute` ).

  ENDMETHOD.

  METHOD test_bind_adopt_json.

    DATA lo_app_client TYPE REF TO ltcl_test_app.
    DATA lo_app TYPE REF TO z2ui5_cl_ui5_app_cont.
    DATA lo_bind TYPE REF TO z2ui5_cl_ui5_srv_bind.
    DATA temp7 LIKE REF TO lo_app_client->mv_value.
    DATA temp8 LIKE REF TO lo_app_client->mv_value.
DATA temp2 TYPE z2ui5_if_ui5_types=>ty_s_bind_config.
    CREATE OBJECT lo_app_client TYPE ltcl_test_app.

    CREATE OBJECT lo_app TYPE z2ui5_cl_ui5_app_cont.
    lo_app->mo_app = lo_app_client.


    CREATE OBJECT lo_bind TYPE z2ui5_cl_ui5_srv_bind EXPORTING APP = lo_app.


    GET REFERENCE OF lo_app_client->mv_value INTO temp7.
lo_bind->main( temp7 ).

    GET REFERENCE OF lo_app_client->mv_value INTO temp8.

CLEAR temp2.
temp2-check_json = abap_true.
lo_bind->main( val    = temp8
                   config = temp2 ).

    cl_abap_unit_assert=>assert_equals(
        exp = abap_true
        act = lo_bind->mr_attri->check_json
        msg = `check_json asked for by the second bind has to stick` ).

  ENDMETHOD.

  METHOD test_bind_keeps_json.

    " the other direction: check_json only ever turns ON, so a later plain
    " _bind( ) of the same attribute must not switch it off again
    DATA lo_app_client TYPE REF TO ltcl_test_app.
    DATA lo_app TYPE REF TO z2ui5_cl_ui5_app_cont.
    DATA lo_bind TYPE REF TO z2ui5_cl_ui5_srv_bind.
    DATA temp9 LIKE REF TO lo_app_client->mv_value.
DATA temp3 TYPE z2ui5_if_ui5_types=>ty_s_bind_config.
    DATA temp10 LIKE REF TO lo_app_client->mv_value.
    CREATE OBJECT lo_app_client TYPE ltcl_test_app.

    CREATE OBJECT lo_app TYPE z2ui5_cl_ui5_app_cont.
    lo_app->mo_app = lo_app_client.


    CREATE OBJECT lo_bind TYPE z2ui5_cl_ui5_srv_bind EXPORTING APP = lo_app.


    GET REFERENCE OF lo_app_client->mv_value INTO temp9.

CLEAR temp3.
temp3-check_json = abap_true.
lo_bind->main( val    = temp9
                   config = temp3 ).

    GET REFERENCE OF lo_app_client->mv_value INTO temp10.
lo_bind->main( temp10 ).

    cl_abap_unit_assert=>assert_equals(
        exp = abap_true
        act = lo_bind->mr_attri->check_json
        msg = `a plain rebind must not clear check_json` ).

  ENDMETHOD.

ENDCLASS.


CLASS ltcl_test_main_structure DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION MEDIUM.

  PUBLIC SECTION.

    TYPES:
      BEGIN OF s_01,
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
      END OF s_01.

    DATA ms_struc TYPE s_01.

  PRIVATE SECTION.

    METHODS test_bind_lev1           FOR TESTING RAISING cx_static_check.
    METHODS test_bind_lev2           FOR TESTING RAISING cx_static_check.
    METHODS test_bind_lev3           FOR TESTING RAISING cx_static_check.
    METHODS test_bind_lev4_long_name FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_test_main_structure IMPLEMENTATION.
  METHOD test_bind_lev1.

    DATA lo_test_app TYPE REF TO ltcl_test_main_structure.
    DATA lo_app TYPE REF TO z2ui5_cl_ui5_app_cont.
    DATA lo_bind TYPE REF TO z2ui5_cl_ui5_srv_bind.
    DATA temp11 LIKE REF TO lo_test_app->ms_struc-input.
DATA lv_result TYPE string.
    DATA temp12 LIKE REF TO lo_test_app->ms_struc-input.
DATA temp4 TYPE z2ui5_if_ui5_types=>ty_s_bind_config.
    CREATE OBJECT lo_test_app TYPE ltcl_test_main_structure.

    CREATE OBJECT lo_app TYPE z2ui5_cl_ui5_app_cont.
    lo_app->mo_app = lo_test_app.


    CREATE OBJECT lo_bind TYPE z2ui5_cl_ui5_srv_bind EXPORTING APP = lo_app.

    GET REFERENCE OF lo_test_app->ms_struc-input INTO temp11.

lv_result = lo_bind->main( temp11 ).

    cl_abap_unit_assert=>assert_equals( exp = `{/MS_STRUC/INPUT}`
                                        act = lv_result ).


    GET REFERENCE OF lo_test_app->ms_struc-input INTO temp12.

CLEAR temp4.
temp4-path_only = abap_true.
lv_result = lo_bind->main( val    = temp12
                               config = temp4 ).

    cl_abap_unit_assert=>assert_equals( exp = `/MS_STRUC/INPUT`
                                        act = lv_result ).

  ENDMETHOD.

  METHOD test_bind_lev2.

    DATA lo_test_app TYPE REF TO ltcl_test_main_structure.
    DATA lo_app TYPE REF TO z2ui5_cl_ui5_app_cont.
    DATA lo_bind TYPE REF TO z2ui5_cl_ui5_srv_bind.
    DATA temp13 LIKE REF TO lo_test_app->ms_struc-s_02-input.
DATA lv_result TYPE string.
    CREATE OBJECT lo_test_app TYPE ltcl_test_main_structure.

    CREATE OBJECT lo_app TYPE z2ui5_cl_ui5_app_cont.
    lo_app->mo_app = lo_test_app.


    CREATE OBJECT lo_bind TYPE z2ui5_cl_ui5_srv_bind EXPORTING APP = lo_app.

    GET REFERENCE OF lo_test_app->ms_struc-s_02-input INTO temp13.

lv_result = lo_bind->main( temp13 ).

    cl_abap_unit_assert=>assert_equals( exp = `{/MS_STRUC/S_02/INPUT}`
                                        act = lv_result ).

  ENDMETHOD.

  METHOD test_bind_lev3.

    DATA lo_test_app TYPE REF TO ltcl_test_main_structure.
    DATA lo_app TYPE REF TO z2ui5_cl_ui5_app_cont.
    DATA lo_bind TYPE REF TO z2ui5_cl_ui5_srv_bind.
    DATA temp14 LIKE REF TO lo_test_app->ms_struc-s_02-s_03-input.
DATA lv_result TYPE string.
    CREATE OBJECT lo_test_app TYPE ltcl_test_main_structure.

    CREATE OBJECT lo_app TYPE z2ui5_cl_ui5_app_cont.
    lo_app->mo_app = lo_test_app.


    CREATE OBJECT lo_bind TYPE z2ui5_cl_ui5_srv_bind EXPORTING APP = lo_app.

    GET REFERENCE OF lo_test_app->ms_struc-s_02-s_03-input INTO temp14.

lv_result = lo_bind->main( temp14 ).

    cl_abap_unit_assert=>assert_equals( exp = `{/MS_STRUC/S_02/S_03/INPUT}`
                                        act = lv_result ).

  ENDMETHOD.

  METHOD test_bind_lev4_long_name.

    DATA lo_test_app TYPE REF TO ltcl_test_main_structure.
    DATA lo_app TYPE REF TO z2ui5_cl_ui5_app_cont.
    DATA lo_bind TYPE REF TO z2ui5_cl_ui5_srv_bind.
    DATA temp15 LIKE REF TO lo_test_app->ms_struc-s_02-s_03-s_04-input.
DATA lv_result TYPE string.
    CREATE OBJECT lo_test_app TYPE ltcl_test_main_structure.

    CREATE OBJECT lo_app TYPE z2ui5_cl_ui5_app_cont.
    lo_app->mo_app = lo_test_app.


    CREATE OBJECT lo_bind TYPE z2ui5_cl_ui5_srv_bind EXPORTING APP = lo_app.

    GET REFERENCE OF lo_test_app->ms_struc-s_02-s_03-s_04-input INTO temp15.

lv_result = lo_bind->main( temp15 ).

    cl_abap_unit_assert=>assert_equals( exp = `{/MS_STRUC/S_02/S_03/S_04/INPUT}`
                                        act = lv_result ).

  ENDMETHOD.
ENDCLASS.


CLASS ltcl_test_main_object DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION MEDIUM.

  PUBLIC SECTION.

    DATA mo_obj   TYPE REF TO ltcl_test_main_object.
    DATA mv_value TYPE string.

    TYPES:
      BEGIN OF s_01,
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
      END OF s_01.

    DATA ms_struc TYPE s_01.

  PRIVATE SECTION.

    METHODS test_bind_value FOR TESTING RAISING cx_static_check.
    METHODS test_bind_struc FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_test_main_object IMPLEMENTATION.

  METHOD test_bind_value.

    DATA lo_test_app TYPE REF TO ltcl_test_main_object.
    DATA lo_app TYPE REF TO z2ui5_cl_ui5_app_cont.
    DATA lo_bind TYPE REF TO z2ui5_cl_ui5_srv_bind.
    DATA temp16 LIKE REF TO lo_test_app->mo_obj->mv_value.
DATA lv_result TYPE string.
    CREATE OBJECT lo_test_app TYPE ltcl_test_main_object.
    CREATE OBJECT lo_test_app->mo_obj.
    lo_test_app->mo_obj->mv_value = `test`.

    CREATE OBJECT lo_app TYPE z2ui5_cl_ui5_app_cont.
    lo_app->mo_app = lo_test_app.


    CREATE OBJECT lo_bind TYPE z2ui5_cl_ui5_srv_bind EXPORTING APP = lo_app.

    GET REFERENCE OF lo_test_app->mo_obj->mv_value INTO temp16.

lv_result = lo_bind->main( temp16 ).

    cl_abap_unit_assert=>assert_equals( exp = `{/MO_OBJ/MV_VALUE}`
                                        act = lv_result ).

  ENDMETHOD.

  METHOD test_bind_struc.

    DATA lo_test_app TYPE REF TO ltcl_test_main_object.
    DATA lo_app TYPE REF TO z2ui5_cl_ui5_app_cont.
    DATA lo_bind TYPE REF TO z2ui5_cl_ui5_srv_bind.
    DATA temp17 LIKE REF TO lo_test_app->mo_obj->ms_struc-input.
DATA lv_result TYPE string.
    CREATE OBJECT lo_test_app TYPE ltcl_test_main_object.
    CREATE OBJECT lo_test_app->mo_obj.

    CREATE OBJECT lo_app TYPE z2ui5_cl_ui5_app_cont.
    lo_app->mo_app = lo_test_app.


    CREATE OBJECT lo_bind TYPE z2ui5_cl_ui5_srv_bind EXPORTING APP = lo_app.

    GET REFERENCE OF lo_test_app->mo_obj->ms_struc-input INTO temp17.

lv_result = lo_bind->main( temp17 ).

    cl_abap_unit_assert=>assert_equals( exp = `{/MO_OBJ/MS_STRUC/INPUT}`
                                        act = lv_result ).

  ENDMETHOD.
ENDCLASS.


" The cell level of main( ) - a bound value addressed as one row of an
" internal table (config-tab / config-tab_index) rather than as a whole
" attribute. What is proved here is the path arithmetic (ABAP counts rows
" from 1, the client path from 0) and the two refusals of bind_tab_cell( ),
" which are the only places a wrong call is caught at all.
"
" The row reference is taken as REF #( mt_tab[ n ] ) and dereferenced, NOT
" the way bind_tab_cell( ) builds its own (ASSIGN <tab>[ idx ] + ASSIGN
" COMPONENT), so the reference match is genuinely exercised rather than
" satisfied by construction. The form an APP writes - the component itself
" as the val argument, mt_tab[ n ]-name - is proved one level up on
" z2ui5_if_client~_bind, where it doubles as the canary for the downport
" patch that keeps it working (node/setup/patch-abaplint-downport.mjs)
CLASS ltcl_test_main_cell DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION MEDIUM.

  PUBLIC SECTION.

    TYPES:
      BEGIN OF ty_s_row,
        name TYPE string,
        job  TYPE string,
      END OF ty_s_row.

    TYPES temp1_fd1ca75c36 TYPE STANDARD TABLE OF ty_s_row WITH DEFAULT KEY.
DATA mt_tab   TYPE temp1_fd1ca75c36.
    DATA mv_other TYPE string.

  PROTECTED SECTION.

  PRIVATE SECTION.

    METHODS setup.
    METHODS test_cell_row1        FOR TESTING RAISING cx_static_check.
    METHODS test_cell_row2        FOR TESTING RAISING cx_static_check.
    METHODS test_cell_path_only   FOR TESTING RAISING cx_static_check.
    METHODS test_cell_bad_index   FOR TESTING RAISING cx_static_check.
    METHODS test_cell_foreign_val FOR TESTING RAISING cx_static_check.

    METHODS bind
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_ui5_srv_bind.

    "! The NAME component of one row, as a reference into the table itself
    METHODS cell_name
      IMPORTING
        iv_index      TYPE i
      RETURNING
        VALUE(result) TYPE REF TO data.

ENDCLASS.


CLASS ltcl_test_main_cell IMPLEMENTATION.

  METHOD setup.
    DATA temp18 TYPE ltcl_test_main_cell=>ty_s_row.
    DATA temp19 TYPE ltcl_test_main_cell=>ty_s_row.

    CLEAR mt_tab.

    CLEAR temp18.
    temp18-name = `Michael Adams`.
    temp18-job = `Scrum Master`.
    INSERT temp18 INTO TABLE mt_tab.

    CLEAR temp19.
    temp19-name = `John Miller`.
    temp19-job = `Product Owner`.
    INSERT temp19 INTO TABLE mt_tab.

  ENDMETHOD.

  METHOD bind.

    DATA lo_app TYPE REF TO z2ui5_cl_ui5_app_cont.
    CREATE OBJECT lo_app TYPE z2ui5_cl_ui5_app_cont.
    lo_app->mo_app = me.
    CREATE OBJECT result TYPE z2ui5_cl_ui5_srv_bind EXPORTING APP = lo_app.

  ENDMETHOD.

  METHOD cell_name.

    FIELD-SYMBOLS <row> TYPE ty_s_row.

    FIELD-SYMBOLS <temp20> TYPE ltcl_test_main_cell=>ty_s_row.
DATA lr_row LIKE REF TO <temp20>.
    READ TABLE mt_tab INDEX iv_index ASSIGNING <temp20>.
IF sy-subrc <> 0.
  ASSERT 1 = 0.
ENDIF.

GET REFERENCE OF <temp20> INTO lr_row.
    ASSIGN lr_row->* TO <row>.
    GET REFERENCE OF <row>-name INTO result.

  ENDMETHOD.

  METHOD test_cell_row1.

    DATA temp21 LIKE REF TO mt_tab.
DATA temp5 TYPE z2ui5_if_ui5_types=>ty_s_bind_config.
DATA lv_result TYPE string.
    GET REFERENCE OF mt_tab INTO temp21.

CLEAR temp5.
temp5-tab = temp21.
temp5-tab_index = 1.

lv_result = bind( )->main( val    = cell_name( 1 )
                                     config = temp5 ).

    cl_abap_unit_assert=>assert_equals( exp = `{/MT_TAB/0/NAME}`
                                        act = lv_result ).

  ENDMETHOD.

  METHOD test_cell_row2.

    " the SECOND row - a path that is only right when the row index is
    " actually resolved and shifted, not assumed to be the first
    DATA temp22 LIKE REF TO mt_tab.
DATA temp6 TYPE z2ui5_if_ui5_types=>ty_s_bind_config.
DATA lv_result TYPE string.
    GET REFERENCE OF mt_tab INTO temp22.

CLEAR temp6.
temp6-tab = temp22.
temp6-tab_index = 2.

lv_result = bind( )->main( val    = cell_name( 2 )
                                     config = temp6 ).

    cl_abap_unit_assert=>assert_equals( exp = `{/MT_TAB/1/NAME}`
                                        act = lv_result ).

  ENDMETHOD.

  METHOD test_cell_path_only.

    DATA temp23 LIKE REF TO mt_tab.
DATA temp7 TYPE z2ui5_if_ui5_types=>ty_s_bind_config.
DATA lv_result TYPE string.
    GET REFERENCE OF mt_tab INTO temp23.

CLEAR temp7.
temp7-tab = temp23.
temp7-tab_index = 1.
temp7-path_only = abap_true.

lv_result = bind( )->main( val    = cell_name( 1 )
                                     config = temp7 ).

    cl_abap_unit_assert=>assert_equals( exp = `/MT_TAB/0/NAME`
                                        act = lv_result ).

  ENDMETHOD.

  METHOD test_cell_bad_index.
        DATA temp24 LIKE REF TO mt_tab.
DATA temp8 TYPE z2ui5_if_ui5_types=>ty_s_bind_config.
        DATA lx_index TYPE REF TO z2ui5_cx_ui5_util_error.
        DATA temp1 TYPE xsdboolean.

    " a row that does not exist: the ASSIGN leaves the row unassigned, and
    " without the guard the next ASSIGN COMPONENT dumps GETWA_NOT_ASSIGNED
    " instead of reporting the binding error
    TRY.

        GET REFERENCE OF mt_tab INTO temp24.

CLEAR temp8.
temp8-tab = temp24.
temp8-tab_index = 3.
bind( )->main( val    = cell_name( 1 )
                       config = temp8 ).
        cl_abap_unit_assert=>fail( `a tab_index past the last row must raise the binding error` ).

      CATCH z2ui5_cx_ui5_util_error INTO lx_index.

        temp1 = boolc( lx_index->get_text( ) CS `BINDING_ERROR_TAB_CELL_LEVEL` ).
        cl_abap_unit_assert=>assert_true( temp1 ).
    ENDTRY.

  ENDMETHOD.

  METHOD test_cell_foreign_val.

    " the cell is identified by REFERENCE - a value that is not a component
    " of that row cannot be addressed, however equal it looks
    FIELD-SYMBOLS <temp25> LIKE LINE OF mt_tab.
    DATA temp26 LIKE sy-tabix.
        DATA temp27 LIKE REF TO mt_tab.
DATA temp9 LIKE REF TO mv_other.
DATA temp1 TYPE z2ui5_if_ui5_types=>ty_s_bind_config.
        DATA lx_val TYPE REF TO z2ui5_cx_ui5_util_error.
        DATA temp2 TYPE xsdboolean.
    temp26 = sy-tabix.
    READ TABLE mt_tab INDEX 1 ASSIGNING <temp25>.
    sy-tabix = temp26.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    mv_other = <temp25>-name.

    TRY.

        GET REFERENCE OF mt_tab INTO temp27.

GET REFERENCE OF mv_other INTO temp9.

CLEAR temp1.
temp1-tab = temp27.
temp1-tab_index = 1.
bind( )->main( val    = temp9
                       config = temp1 ).
        cl_abap_unit_assert=>fail( `a val that is not a component of the addressed row must raise the binding error` ).

      CATCH z2ui5_cx_ui5_util_error INTO lx_val.

        temp2 = boolc( lx_val->get_text( ) CS `BINDING_ERROR_TAB_CELL_LEVEL` ).
        cl_abap_unit_assert=>assert_true( temp2 ).
    ENDTRY.

  ENDMETHOD.

ENDCLASS.
