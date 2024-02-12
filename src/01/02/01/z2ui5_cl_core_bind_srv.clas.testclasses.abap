
CLASS ltcl_test_bind DEFINITION DEFERRED.
CLASS z2ui5_cl_core_bind_srv DEFINITION LOCAL FRIENDS ltcl_test_bind.

CLASS ltcl_test_app DEFINITION FINAL FOR TESTING
  DURATION MEDIUM
  RISK LEVEL HARMLESS.

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
    DATA mv_value TYPE string.
    DATA mr_value TYPE REF TO data.
    DATA mr_struc TYPE REF TO s_01.
    DATA mo_app TYPE REF TO ltcl_test_bind.

    DATA x TYPE string.
ENDCLASS.

CLASS ltcl_test_bind DEFINITION FINAL FOR TESTING
  DURATION MEDIUM
  RISK LEVEL HARMLESS.

  PUBLIC SECTION.
  PROTECTED SECTION.
  PRIVATE SECTION.
    METHODS test_one_way      FOR TESTING RAISING cx_static_check.
    METHODS test_one_way_w_x_error  FOR TESTING RAISING cx_static_check.
    METHODS test_error_diff   FOR TESTING RAISING cx_static_check.
    METHODS test_two_way      FOR TESTING RAISING cx_static_check.

ENDCLASS.

CLASS ltcl_test_bind IMPLEMENTATION.

  METHOD test_one_way_w_x_error.

    DATA(lo_app_client) = NEW ltcl_test_app( ).
    DATA(lo_app) = NEW z2ui5_cl_core_app( ).
    lo_app->mo_app = lo_app_client.

    DATA(lo_bind)  = NEW z2ui5_cl_core_bind_srv( lo_app ).

    TRY.
        DATA(lv_bind) = lo_bind->main(
            val    = REF #( lo_app_client->x )
            type   = z2ui5_if_core_types=>cs_bind_type-one_way  ).

        cl_abap_unit_assert=>abort( ).

      CATCH cx_root.
    ENDTRY.

  ENDMETHOD.

  METHOD test_one_way.

    DATA(lo_app_client) = NEW ltcl_test_app( ).
    DATA(lo_app) = NEW z2ui5_cl_core_app( ).
    lo_app->mo_app = lo_app_client.

    DATA(lo_bind)  = NEW z2ui5_cl_core_bind_srv( lo_app ).

    DATA(lv_bind) = lo_bind->main(
        val    = REF #( lo_app_client->mv_value )
        type   = z2ui5_if_core_types=>cs_bind_type-one_way  ).

    DATA(lv_bind2) = lo_bind->main(
         val    = REF #( lo_app_client->mv_value )
         type   = z2ui5_if_core_types=>cs_bind_type-one_way  ).

    cl_abap_unit_assert=>assert_equals(
       act = lv_bind
       exp = lv_bind2 ).

    cl_abap_unit_assert=>assert_not_initial( lv_bind ).

  ENDMETHOD.

  METHOD test_error_diff.

    DATA(lo_app_client) = NEW ltcl_test_app( ).
    DATA(lo_app) = NEW z2ui5_cl_core_app( ).
    lo_app->mo_app = lo_app_client.

    DATA(lo_bind)  = NEW z2ui5_cl_core_bind_srv( lo_app ).

    DATA(lv_bind) = lo_bind->main(
        val    = REF #( lo_app_client->mv_value )
        type   = z2ui5_if_core_types=>cs_bind_type-one_way  ).

    TRY.
        DATA(lv_bind2) = lo_bind->main(
             val    = REF #( lo_app_client->mv_value )
             type   = z2ui5_if_core_types=>cs_bind_type-two_way ).

        cl_abap_unit_assert=>abort( ).

      CATCH cx_root.
    ENDTRY.

  ENDMETHOD.


  METHOD test_two_way.

    DATA(lo_app_client) = NEW ltcl_test_app( ).
    DATA(lo_app) = NEW z2ui5_cl_core_app( ).
    lo_app->mo_app = lo_app_client.

    DATA(lo_bind)  = NEW z2ui5_cl_core_bind_srv( lo_app ).

    DATA(lv_bind) = lo_bind->main(
        val    = REF #( lo_app_client->mv_value )
        type   = z2ui5_if_core_types=>cs_bind_type-two_way  ).

    DATA(lv_bind2) = lo_bind->main(
         val    = REF #( lo_app_client->mv_value )
         type   = z2ui5_if_core_types=>cs_bind_type-two_way  ).

    cl_abap_unit_assert=>assert_equals(
       act = lv_bind
       exp = lv_bind2 ).

    cl_abap_unit_assert=>assert_not_initial( lv_bind ).

  ENDMETHOD.
ENDCLASS.


CLASS ltcl_test_main_structure DEFINITION FINAL FOR TESTING
  DURATION MEDIUM
  RISK LEVEL HARMLESS.

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

    METHODS test_one_way_lev1 FOR TESTING RAISING cx_static_check.
    METHODS test_one_way_lev2 FOR TESTING RAISING cx_static_check.
    METHODS test_one_way_lev3 FOR TESTING RAISING cx_static_check.
    METHODS test_one_way_lev4_long_name FOR TESTING RAISING cx_static_check.


ENDCLASS.

CLASS ltcl_test_main_structure IMPLEMENTATION.

  METHOD test_one_way_lev1.

*    DATA(lo_app) = NEW ltcl_test_main_structure( ).
*    lo_app->ms_struc-input = `my value`.
*
*    DATA(lt_attri) = VALUE z2ui5_cl_fw_binding=>ty_t_attri( ).
*
*    DATA(lo_bind) = z2ui5_cl_fw_binding=>factory(
*        app   = lo_app
*        attri = lt_attri
*        type  = z2ui5_cl_fw_binding=>cs_bind_type-one_way
*        data  = lo_app->ms_struc-input ).
*
*    DATA(lv_result) = lo_bind->main( ).
*
*    cl_abap_unit_assert=>assert_equals(
*        act = lv_result
*        exp = `/MS_STRUC/INPUT` ).

  ENDMETHOD.

  METHOD test_one_way_lev2.

*    DATA(lo_app) = NEW ltcl_test_main_structure( ).
*    lo_app->ms_struc-s_02-input = `my value`.
*
*    DATA(lt_attri) = VALUE z2ui5_cl_fw_binding=>ty_t_attri( ).
*
*    DATA(lo_bind) = z2ui5_cl_fw_binding=>factory(
*        app   = lo_app
*        attri = lt_attri
*        type  = z2ui5_cl_fw_binding=>cs_bind_type-one_way
*        data  = lo_app->ms_struc-s_02-input ).
*
*    DATA(lv_result) = lo_bind->main( ).
*
*    cl_abap_unit_assert=>assert_equals(
*        act = lv_result
*        exp = `/MS_STRUC/S_02-INPUT` ).

  ENDMETHOD.

  METHOD test_one_way_lev3.

*    DATA(lo_app) = NEW ltcl_test_main_structure( ).
*    lo_app->ms_struc-s_02-s_03-input = `my value`.
*
*    DATA(lt_attri) = VALUE z2ui5_cl_fw_binding=>ty_t_attri( ).
*
*    DATA(lo_bind) = z2ui5_cl_fw_binding=>factory(
*        app   = lo_app
*        attri = lt_attri
*        type  = z2ui5_cl_fw_binding=>cs_bind_type-one_way
*        data  = lo_app->ms_struc-s_02-s_03-input ).
*
*    DATA(lv_result) = lo_bind->main( ).
*
*    cl_abap_unit_assert=>assert_equals(
*        act = lv_result
*        exp = `/MS_STRUC/S_02-S_03-INPUT` ).

  ENDMETHOD.

  METHOD test_one_way_lev4_long_name.

*    DATA(lo_app) = NEW ltcl_test_main_structure( ).
*    lo_app->ms_struc-s_02-s_03-s_04-input = `my value`.
*
*    DATA(lt_attri) = VALUE z2ui5_cl_fw_binding=>ty_t_attri( ).
*
*    DATA(lo_bind) = z2ui5_cl_fw_binding=>factory(
*        app   = lo_app
*        attri = lt_attri
*        type  = z2ui5_cl_fw_binding=>cs_bind_type-one_way
*        data  = lo_app->ms_struc-s_02-s_03-s_04-input ).
*
*    DATA(lv_result) = lo_bind->main( ).
*
*    cl_abap_unit_assert=>assert_equals(
*        act = lv_result
*        exp = `/MS_STRUC/S_02-S_03-S_04-INPUT` ).

  ENDMETHOD.

ENDCLASS.


CLASS ltcl_test_main_object DEFINITION FINAL FOR TESTING
  DURATION MEDIUM
  RISK LEVEL HARMLESS.

  PUBLIC SECTION.

    DATA mo_obj TYPE REF TO ltcl_test_main_object.

  PRIVATE SECTION.

    METHODS test_one_way_value FOR TESTING RAISING cx_static_check.
    METHODS test_one_way_struc FOR TESTING RAISING cx_static_check.


ENDCLASS.

CLASS ltcl_test_main_object IMPLEMENTATION.

  METHOD test_one_way_value.

*    DATA(lo_app) = NEW ltcl_test_main_object( ).
*    lo_app->mo_obj = NEW #( ).
*    lo_app->mo_obj->mv_value = `my value`.
*
*    DATA(lt_attri) = VALUE z2ui5_cl_fw_binding=>ty_t_attri( ).
*
*    DATA(lo_bind) = z2ui5_cl_fw_binding=>factory(
*        app   = lo_app
*        attri = lt_attri
*        type  = z2ui5_cl_fw_binding=>cs_bind_type-one_way
*        data  = lo_app->mo_obj->mv_value ).
*
*    DATA(lv_result) = lo_bind->main( ).
*
*    cl_abap_unit_assert=>assert_equals(
*        act = lv_result
*        exp = `/MO_OBJ/MV_VALUE` ).

  ENDMETHOD.

  METHOD test_one_way_struc.

*    DATA(lo_app) = NEW ltcl_test_main_object( ).
*    lo_app->mo_obj = NEW #( ).
*    lo_app->mo_obj->ms_struc-input = `my value`.
*
*    DATA(lt_attri) = VALUE z2ui5_cl_fw_binding=>ty_t_attri( ).
*
*    DATA(lo_bind) = z2ui5_cl_fw_binding=>factory(
*        app   = lo_app
*        attri = lt_attri
*        type  = z2ui5_cl_fw_binding=>cs_bind_type-one_way
*        data  = lo_app->mo_obj->ms_struc-input ).
*
*    DATA(lv_result) = lo_bind->main( ).
*
*    cl_abap_unit_assert=>assert_equals(
*        act = lv_result
*        exp = `/MO_OBJ/MS_STRUC-INPUT` ).

  ENDMETHOD.

ENDCLASS.

CLASS ltcl_test_bind2 DEFINITION FINAL FOR TESTING
  DURATION MEDIUM
  RISK LEVEL HARMLESS.

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
    DATA mv_value TYPE string.
    DATA mr_value TYPE REF TO data.
    DATA mr_struc TYPE REF TO s_01.
    DATA mo_app TYPE REF TO ltcl_test_bind.

  PRIVATE SECTION.
    METHODS test_value      FOR TESTING RAISING cx_static_check.
    METHODS test_struc      FOR TESTING RAISING cx_static_check.
    METHODS test_dref_val   FOR TESTING RAISING cx_static_check.
    METHODS test_dref_struc FOR TESTING RAISING cx_static_check.
    METHODS test_oref_val   FOR TESTING RAISING cx_static_check.
    METHODS test_oref_struc FOR TESTING RAISING cx_static_check.
    METHODS test_oref_dref_val FOR TESTING RAISING cx_static_check.
    METHODS test_local      FOR TESTING RAISING cx_static_check.

ENDCLASS.

CLASS ltcl_test_bind2 IMPLEMENTATION.

  METHOD test_value.


*    DATA(lo_app) = NEW z2ui5_cl_core_app( ).
*
*    DATA(lo_bind)  = NEW z2ui5_cl_core_bind_srv( lo_app ).
*    DATA(lo_app_client) = NEW ltcl_test_app( ).
*
*    DATA(lv_bind) = lo_bind->main(
*        val    = REF #( lo_app_client->mv_value )
*        type   = z2ui5_if_core_types=>cs_bind_type-one_way  ).
*
*    DATA(lv_bind2) = lo_bind->main(
*         val    = REF #( lo_app_client->mv_value )
*         type   = z2ui5_if_core_types=>cs_bind_type-one_way  ).
*
*    cl_abap_unit_assert=>assert_equals(
*       act = lv_bind
*       exp = lv_bind2 ).

*   lo_bind->
*    lo_bind->
*    DATA(lo_bind) = NEW z2ui5_cl_core_bind_srv( app).
*
*    lo_bind->mo_app = lo_app.
*    lo_bind->mr_data = REF #( lo_app->mv_value ).
*    lo_bind->mv_type = z2ui5_cl_fw_binding=>cs_bind_type-one_way.
*
*    DATA(ls_attri) = VALUE z2ui5_cl_fw_binding=>ty_s_attri( name = `MV_VALUE` ).
*    DATA(lv_result) = lo_bind->bind( REF #( ls_attri ) ).
*
*    cl_abap_unit_assert=>assert_equals(
*      act = lv_result
*      exp = `/MV_VALUE` ).

  ENDMETHOD.


  METHOD test_struc.

*    DATA(lo_app)    = NEW ltcl_test_bind( ).
*    DATA(lo_bind) = NEW z2ui5_cl_fw_binding( ).
*
*    lo_bind->mo_app = lo_app.
*    lo_bind->mr_data = REF #( lo_app->ms_struc-s_02-s_03-s_04-input ).
*    lo_bind->mv_type = z2ui5_cl_fw_binding=>cs_bind_type-one_way.
*
*    DATA(ls_attri) = VALUE z2ui5_cl_fw_binding=>ty_s_attri( name = `MS_STRUC-S_02-S_03-S_04-INPUT` ).
*    DATA(lv_result) = lo_bind->bind( REF #( ls_attri ) ).
*
*    cl_abap_unit_assert=>assert_equals(
*      act = lv_result
*      exp = `/MS_STRUC/S_02-S_03-S_04-INPUT` ).

  ENDMETHOD.


  METHOD test_dref_val.

*    DATA(lo_app)  = NEW ltcl_test_bind( ).
*    DATA(lo_bind) = NEW z2ui5_cl_fw_binding( ).
*
*    FIELD-SYMBOLS <any> TYPE any.
*    CREATE DATA lo_app->mr_value TYPE string.
*    ASSIGN lo_app->mr_value->* TO <any>.
*
*    lo_bind->mo_app = lo_app.
*    lo_bind->mr_data = REF #( <any> ).
*    lo_bind->mv_type = z2ui5_cl_fw_binding=>cs_bind_type-one_way.
*
*    DATA(ls_attri) = VALUE z2ui5_cl_fw_binding=>ty_s_attri( name = `MR_VALUE->*` ).
*    DATA(lv_result) = lo_bind->bind( REF #( ls_attri ) ).
*
*    cl_abap_unit_assert=>assert_equals(
*      act = lv_result
*      exp = `/MR_VALUE/*` ).

  ENDMETHOD.

  METHOD test_dref_struc.

*    DATA(lo_app)  = NEW ltcl_test_bind( ).
*    DATA(lo_bind) = NEW z2ui5_cl_fw_binding( ).
*
*    FIELD-SYMBOLS <any> TYPE any.
*    CREATE DATA lo_app->mr_struc.
*    ASSIGN lo_app->mr_struc->input TO <any>.
*
*    lo_bind->mo_app = lo_app.
*    lo_bind->mr_data = REF #( <any> ).
*    lo_bind->mv_type = z2ui5_cl_fw_binding=>cs_bind_type-one_way.
*
*    DATA(ls_attri) = VALUE z2ui5_cl_fw_binding=>ty_s_attri( name = `MR_STRUC->INPUT` ).
*    DATA(lv_result) = lo_bind->bind( REF #( ls_attri ) ).
*
*    cl_abap_unit_assert=>assert_equals(
*      act = lv_result
*      exp = `/MR_STRUC/INPUT` ).

  ENDMETHOD.

  METHOD test_oref_val.

*    DATA(lo_app)  = NEW ltcl_test_bind( ).
*    lo_app->mo_app = NEW #( ).
*    DATA(lo_bind) = NEW z2ui5_cl_fw_binding( ).
*
*    lo_bind->mo_app = lo_app.
*    lo_bind->mr_data = REF #( lo_app->mo_app->mv_value ).
*    lo_bind->mv_type = z2ui5_cl_fw_binding=>cs_bind_type-one_way.
*
*    DATA(ls_attri) = VALUE z2ui5_cl_fw_binding=>ty_s_attri( name = `MO_APP->MV_VALUE` ).
*    DATA(lv_result) = lo_bind->bind( REF #( ls_attri ) ).
*
*    cl_abap_unit_assert=>assert_equals(
*      act = lv_result
*      exp = `/MO_APP/MV_VALUE` ).

  ENDMETHOD.

  METHOD test_oref_struc.

*    DATA(lo_app)  = NEW ltcl_test_bind( ).
*    lo_app->mo_app = NEW #( ).
*    DATA(lo_bind) = NEW z2ui5_cl_fw_binding( ).
*
*    lo_bind->mo_app = lo_app.
*    lo_bind->mr_data = REF #( lo_app->mo_app->ms_struc-input ).
*    lo_bind->mv_type = z2ui5_cl_fw_binding=>cs_bind_type-one_way.
*
*    DATA(ls_attri) = VALUE z2ui5_cl_fw_binding=>ty_s_attri( name = `MO_APP->MS_STRUC-INPUT` ).
*    DATA(lv_result) = lo_bind->bind( REF #( ls_attri ) ).
*
*    cl_abap_unit_assert=>assert_equals(
*      act = lv_result
*      exp = `/MO_APP/MS_STRUC-INPUT` ).

  ENDMETHOD.

  METHOD test_oref_dref_val.

*    DATA(lo_app)   = NEW ltcl_test_bind( ).
*    FIELD-SYMBOLS <any> TYPE any.
*    lo_app->mo_app = NEW #( ).
*    DATA(lo_bind)  = NEW z2ui5_cl_fw_binding( ).
*
*    CREATE DATA lo_app->mo_app->mr_value TYPE string.
*    ASSIGN lo_app->mo_app->mr_value->* TO <any>.
*
*    lo_bind->mo_app = lo_app.
*    lo_bind->mr_data = REF #( <any> ).
*    lo_bind->mv_type = z2ui5_cl_fw_binding=>cs_bind_type-one_way.
*
*    DATA(ls_attri) = VALUE z2ui5_cl_fw_binding=>ty_s_attri( name = `MO_APP->MR_VALUE->*` ).
*    DATA(lv_result) = lo_bind->bind( REF #( ls_attri ) ).
*
*    cl_abap_unit_assert=>assert_equals(
*      act = lv_result
*      exp = `/MO_APP/MR_VALUE->*` ).

  ENDMETHOD.

  METHOD test_local.

*    DATA(lo_bind)  = NEW z2ui5_cl_fw_binding( ).
*    DATA(lv_value) = `test`.
*    lo_bind->mr_data = REF #( lv_value ).
*    lo_bind->mv_type = z2ui5_cl_fw_binding=>cs_bind_type-one_time.
*
*    DATA(lv_result) = lo_bind->bind_local( ).
*
*    IF lv_result IS INITIAL.
*      cl_abap_unit_assert=>fail( ).
*    ENDIF.

  ENDMETHOD.

ENDCLASS.
