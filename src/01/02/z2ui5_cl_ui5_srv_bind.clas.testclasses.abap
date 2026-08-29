
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


CLASS ltcl_test_bind DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION MEDIUM.

  PUBLIC SECTION.

  PROTECTED SECTION.

  PRIVATE SECTION.
    METHODS test_bind_path         FOR TESTING RAISING cx_static_check.
    METHODS test_attri_named_xx    FOR TESTING RAISING cx_static_check.
    METHODS test_bind_idempotent   FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_test_bind IMPLEMENTATION.
  METHOD test_attri_named_xx.

    " XX used to be a reserved model-node name; now that the bound data
    " lives directly on the root, an attribute named XX binds like any other
    DATA(lo_app_client) = NEW ltcl_test_app( ).
    DATA(lo_app) = NEW z2ui5_cl_ui5_app_cont( ).
    lo_app->mo_app = lo_app_client.

    DATA(lo_bind)  = NEW z2ui5_cl_ui5_srv_bind( lo_app ).

    DATA(lv_bind) = lo_bind->main( REF #( lo_app_client->xx ) ).

    cl_abap_unit_assert=>assert_equals( exp = `{/XX}`
                                        act = lv_bind ).

  ENDMETHOD.

  METHOD test_bind_path.

    DATA(lo_app_client) = NEW ltcl_test_app( ).
    DATA(lo_app) = NEW z2ui5_cl_ui5_app_cont( ).
    lo_app->mo_app = lo_app_client.

    DATA(lo_bind) = NEW z2ui5_cl_ui5_srv_bind( lo_app ).

    DATA(lv_bind) = lo_bind->main( REF #( lo_app_client->mv_value ) ).

    cl_abap_unit_assert=>assert_equals( exp = `{/MV_VALUE}`
                                        act = lv_bind ).

  ENDMETHOD.

  METHOD test_bind_idempotent.

    DATA(lo_app_client) = NEW ltcl_test_app( ).
    DATA(lo_app) = NEW z2ui5_cl_ui5_app_cont( ).
    lo_app->mo_app = lo_app_client.

    DATA(lo_bind)  = NEW z2ui5_cl_ui5_srv_bind( lo_app ).

    DATA(lv_bind) = lo_bind->main( REF #( lo_app_client->mv_value ) ).

    DATA(lv_bind2) = lo_bind->main( REF #( lo_app_client->mv_value ) ).

    cl_abap_unit_assert=>assert_equals( exp = lv_bind2
                                        act = lv_bind ).

    cl_abap_unit_assert=>assert_not_initial( lv_bind ).

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

    DATA(lo_test_app) = NEW ltcl_test_main_structure( ).
    DATA(lo_app) = NEW z2ui5_cl_ui5_app_cont( ).
    lo_app->mo_app = lo_test_app.

    DATA(lo_bind)  = NEW z2ui5_cl_ui5_srv_bind( lo_app ).
    DATA(lv_result) = lo_bind->main( REF #( lo_test_app->ms_struc-input ) ).

    cl_abap_unit_assert=>assert_equals( exp = `{/MS_STRUC/INPUT}`
                                        act = lv_result ).

    lv_result = lo_bind->main( val    = REF #( lo_test_app->ms_struc-input )
                               config = VALUE #( path_only = abap_true ) ).

    cl_abap_unit_assert=>assert_equals( exp = `/MS_STRUC/INPUT`
                                        act = lv_result ).

  ENDMETHOD.

  METHOD test_bind_lev2.

    DATA(lo_test_app) = NEW ltcl_test_main_structure( ).
    DATA(lo_app) = NEW z2ui5_cl_ui5_app_cont( ).
    lo_app->mo_app = lo_test_app.

    DATA(lo_bind)  = NEW z2ui5_cl_ui5_srv_bind( lo_app ).
    DATA(lv_result) = lo_bind->main( REF #( lo_test_app->ms_struc-s_02-input ) ).

    cl_abap_unit_assert=>assert_equals( exp = `{/MS_STRUC/S_02/INPUT}`
                                        act = lv_result ).

  ENDMETHOD.

  METHOD test_bind_lev3.

    DATA(lo_test_app) = NEW ltcl_test_main_structure( ).
    DATA(lo_app) = NEW z2ui5_cl_ui5_app_cont( ).
    lo_app->mo_app = lo_test_app.

    DATA(lo_bind)  = NEW z2ui5_cl_ui5_srv_bind( lo_app ).
    DATA(lv_result) = lo_bind->main( REF #( lo_test_app->ms_struc-s_02-s_03-input ) ).

    cl_abap_unit_assert=>assert_equals( exp = `{/MS_STRUC/S_02/S_03/INPUT}`
                                        act = lv_result ).

  ENDMETHOD.

  METHOD test_bind_lev4_long_name.

    DATA(lo_test_app) = NEW ltcl_test_main_structure( ).
    DATA(lo_app) = NEW z2ui5_cl_ui5_app_cont( ).
    lo_app->mo_app = lo_test_app.

    DATA(lo_bind)  = NEW z2ui5_cl_ui5_srv_bind( lo_app ).
    DATA(lv_result) = lo_bind->main( REF #( lo_test_app->ms_struc-s_02-s_03-s_04-input ) ).

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

    DATA(lo_test_app) = NEW ltcl_test_main_object( ).
    lo_test_app->mo_obj = NEW #( ).
    lo_test_app->mo_obj->mv_value = `test`.
    DATA(lo_app) = NEW z2ui5_cl_ui5_app_cont( ).
    lo_app->mo_app = lo_test_app.

    DATA(lo_bind)  = NEW z2ui5_cl_ui5_srv_bind( lo_app ).
    DATA(lv_result) = lo_bind->main( REF #( lo_test_app->mo_obj->mv_value ) ).

    cl_abap_unit_assert=>assert_equals( exp = `{/MO_OBJ/MV_VALUE}`
                                        act = lv_result ).

  ENDMETHOD.

  METHOD test_bind_struc.

    DATA(lo_test_app) = NEW ltcl_test_main_object( ).
    lo_test_app->mo_obj = NEW #( ).
    DATA(lo_app) = NEW z2ui5_cl_ui5_app_cont( ).
    lo_app->mo_app = lo_test_app.

    DATA(lo_bind)  = NEW z2ui5_cl_ui5_srv_bind( lo_app ).
    DATA(lv_result) = lo_bind->main( REF #( lo_test_app->mo_obj->ms_struc-input ) ).

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
" satisfied by construction. That REF #( tab[ n ] ) spelling is also the one
" that survives a downport, which is why it is the one the doc block on
" z2ui5_if_client~_bind recommends. The form an APP writes when it is not
" downported - the component itself as the val argument, mt_tab[ n ]-name -
" is proved one level up on z2ui5_if_client~_bind and skipped in the
" transpiled suite: see the skip note in node/setup/abap_transpile.json
CLASS ltcl_test_main_cell DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION MEDIUM.

  PUBLIC SECTION.

    TYPES:
      BEGIN OF ty_s_row,
        name TYPE string,
        job  TYPE string,
      END OF ty_s_row.

    DATA mt_tab   TYPE STANDARD TABLE OF ty_s_row WITH EMPTY KEY.
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

    CLEAR mt_tab.
    INSERT VALUE #( name = `Michael Adams`
                    job  = `Scrum Master` ) INTO TABLE mt_tab.
    INSERT VALUE #( name = `John Miller`
                    job  = `Product Owner` ) INTO TABLE mt_tab.

  ENDMETHOD.

  METHOD bind.

    DATA(lo_app) = NEW z2ui5_cl_ui5_app_cont( ).
    lo_app->mo_app = me.
    result = NEW z2ui5_cl_ui5_srv_bind( lo_app ).

  ENDMETHOD.

  METHOD cell_name.

    FIELD-SYMBOLS <row> TYPE ty_s_row.

    DATA(lr_row) = REF #( mt_tab[ iv_index ] ).
    ASSIGN lr_row->* TO <row>.
    result = REF #( <row>-name ).

  ENDMETHOD.

  METHOD test_cell_row1.

    DATA(lv_result) = bind( )->main( val    = cell_name( 1 )
                                     config = VALUE #( tab       = REF #( mt_tab )
                                                       tab_index = 1 ) ).

    cl_abap_unit_assert=>assert_equals( exp = `{/MT_TAB/0/NAME}`
                                        act = lv_result ).

  ENDMETHOD.

  METHOD test_cell_row2.

    " the SECOND row - a path that is only right when the row index is
    " actually resolved and shifted, not assumed to be the first
    DATA(lv_result) = bind( )->main( val    = cell_name( 2 )
                                     config = VALUE #( tab       = REF #( mt_tab )
                                                       tab_index = 2 ) ).

    cl_abap_unit_assert=>assert_equals( exp = `{/MT_TAB/1/NAME}`
                                        act = lv_result ).

  ENDMETHOD.

  METHOD test_cell_path_only.

    DATA(lv_result) = bind( )->main( val    = cell_name( 1 )
                                     config = VALUE #( tab       = REF #( mt_tab )
                                                       tab_index = 1
                                                       path_only = abap_true ) ).

    cl_abap_unit_assert=>assert_equals( exp = `/MT_TAB/0/NAME`
                                        act = lv_result ).

  ENDMETHOD.

  METHOD test_cell_bad_index.

    " a row that does not exist: the ASSIGN leaves the row unassigned, and
    " without the guard the next ASSIGN COMPONENT dumps GETWA_NOT_ASSIGNED
    " instead of reporting the binding error
    TRY.
        bind( )->main( val    = cell_name( 1 )
                       config = VALUE #( tab       = REF #( mt_tab )
                                         tab_index = 3 ) ).
        cl_abap_unit_assert=>fail( `a tab_index past the last row must raise the binding error` ).
      CATCH z2ui5_cx_ui5_util_error INTO DATA(lx_index).
        cl_abap_unit_assert=>assert_true( xsdbool( lx_index->get_text( ) CS `BINDING_ERROR_TAB_CELL_LEVEL` ) ).
    ENDTRY.

  ENDMETHOD.

  METHOD test_cell_foreign_val.

    " the cell is identified by REFERENCE - a value that is not a component
    " of that row cannot be addressed, however equal it looks
    mv_other = mt_tab[ 1 ]-name.

    TRY.
        bind( )->main( val    = REF #( mv_other )
                       config = VALUE #( tab       = REF #( mt_tab )
                                         tab_index = 1 ) ).
        cl_abap_unit_assert=>fail( `a val that is not a component of the addressed row must raise the binding error` ).
      CATCH z2ui5_cx_ui5_util_error INTO DATA(lx_val).
        cl_abap_unit_assert=>assert_true( xsdbool( lx_val->get_text( ) CS `BINDING_ERROR_TAB_CELL_LEVEL` ) ).
    ENDTRY.

  ENDMETHOD.

ENDCLASS.
