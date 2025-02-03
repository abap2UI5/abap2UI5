
CLASS ltcl_test_bind DEFINITION DEFERRED.
CLASS z2ui5_cl_core_srv_bind DEFINITION LOCAL FRIENDS ltcl_test_bind.

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

    METHODS constructor.
ENDCLASS.


CLASS ltcl_test_app IMPLEMENTATION.
  METHOD constructor.

  ENDMETHOD.
ENDCLASS.


CLASS ltcl_test_bind DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION MEDIUM.

  PUBLIC SECTION.

  PROTECTED SECTION.

  PRIVATE SECTION.
    METHODS test_one_way           FOR TESTING RAISING cx_static_check.
    METHODS test_one_way_w_x_error FOR TESTING RAISING cx_static_check.
    METHODS test_error_diff        FOR TESTING RAISING cx_static_check.
    METHODS test_two_way           FOR TESTING RAISING cx_static_check.
    METHODS test_local             FOR TESTING RAISING cx_static_check.
    METHODS test_local_one         FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_test_bind IMPLEMENTATION.
  METHOD test_one_way_w_x_error.

    DATA lo_app_client TYPE REF TO ltcl_test_app.
    DATA lo_app TYPE REF TO z2ui5_cl_core_app.
    DATA lo_bind TYPE REF TO z2ui5_cl_core_srv_bind.
        DATA temp18 LIKE REF TO lo_app_client->xx.
    CREATE OBJECT lo_app_client TYPE ltcl_test_app.
    
    CREATE OBJECT lo_app TYPE z2ui5_cl_core_app.
    lo_app->mo_app = lo_app_client.

    
    CREATE OBJECT lo_bind TYPE z2ui5_cl_core_srv_bind EXPORTING APP = lo_app.

    TRY.
        
        GET REFERENCE OF lo_app_client->xx INTO temp18.
lo_bind->main( val  = temp18
                       type = z2ui5_if_core_types=>cs_bind_type-one_way ).

        cl_abap_unit_assert=>abort( ).

      CATCH cx_root.
    ENDTRY.

  ENDMETHOD.

  METHOD test_one_way.

    DATA lo_app_client TYPE REF TO ltcl_test_app.
    DATA lo_app TYPE REF TO z2ui5_cl_core_app.
    DATA lo_bind TYPE REF TO z2ui5_cl_core_srv_bind.
    DATA temp19 LIKE REF TO lo_app_client->mv_value.
DATA lv_bind TYPE string.
    CREATE OBJECT lo_app_client TYPE ltcl_test_app.
    
    CREATE OBJECT lo_app TYPE z2ui5_cl_core_app.
    lo_app->mo_app = lo_app_client.

    
    CREATE OBJECT lo_bind TYPE z2ui5_cl_core_srv_bind EXPORTING APP = lo_app.

    
    GET REFERENCE OF lo_app_client->mv_value INTO temp19.

lv_bind = lo_bind->main( val  = temp19
                                   type = z2ui5_if_core_types=>cs_bind_type-one_way ).

    cl_abap_unit_assert=>assert_equals( exp = `{/MV_VALUE}`
                                        act = lv_bind ).

  ENDMETHOD.

  METHOD test_error_diff.

    DATA lo_app_client TYPE REF TO ltcl_test_app.
    DATA lo_app TYPE REF TO z2ui5_cl_core_app.
    DATA lo_bind TYPE REF TO z2ui5_cl_core_srv_bind.
    DATA temp20 LIKE REF TO lo_app_client->mv_value.
        DATA temp21 LIKE REF TO lo_app_client->mv_value.
    CREATE OBJECT lo_app_client TYPE ltcl_test_app.
    
    CREATE OBJECT lo_app TYPE z2ui5_cl_core_app.
    lo_app->mo_app = lo_app_client.

    
    CREATE OBJECT lo_bind TYPE z2ui5_cl_core_srv_bind EXPORTING APP = lo_app.

    
    GET REFERENCE OF lo_app_client->mv_value INTO temp20.
lo_bind->main( val  = temp20
                   type = z2ui5_if_core_types=>cs_bind_type-one_way ).

    TRY.
        
        GET REFERENCE OF lo_app_client->mv_value INTO temp21.
lo_bind->main( val  = temp21
                       type = z2ui5_if_core_types=>cs_bind_type-two_way ).

        cl_abap_unit_assert=>abort( ).

      CATCH cx_root.
    ENDTRY.

  ENDMETHOD.

  METHOD test_two_way.

*    IF sy-sysid = 'ABC'.
*      RETURN.
*    ENDIF.

    DATA lo_app_client TYPE REF TO ltcl_test_app.
    DATA lo_app TYPE REF TO z2ui5_cl_core_app.
    DATA lo_bind TYPE REF TO z2ui5_cl_core_srv_bind.
    DATA temp22 LIKE REF TO lo_app_client->mv_value.
DATA lv_bind TYPE string.
    DATA temp23 LIKE REF TO lo_app_client->mv_value.
DATA lv_bind2 TYPE string.
    CREATE OBJECT lo_app_client TYPE ltcl_test_app.
    
    CREATE OBJECT lo_app TYPE z2ui5_cl_core_app.
    lo_app->mo_app = lo_app_client.

    
    CREATE OBJECT lo_bind TYPE z2ui5_cl_core_srv_bind EXPORTING APP = lo_app.

    
    GET REFERENCE OF lo_app_client->mv_value INTO temp22.

lv_bind = lo_bind->main( val  = temp22
                                   type = z2ui5_if_core_types=>cs_bind_type-two_way ).

    
    GET REFERENCE OF lo_app_client->mv_value INTO temp23.

lv_bind2 = lo_bind->main( val  = temp23
                                    type = z2ui5_if_core_types=>cs_bind_type-two_way ).

    cl_abap_unit_assert=>assert_equals( exp = lv_bind2
                                        act = lv_bind ).

    cl_abap_unit_assert=>assert_not_initial( lv_bind ).

  ENDMETHOD.

  METHOD test_local.

    DATA lo_app_client TYPE REF TO ltcl_test_app.
    DATA lo_app TYPE REF TO z2ui5_cl_core_app.
    DATA lo_bind TYPE REF TO z2ui5_cl_core_srv_bind.
    DATA lv_bind TYPE string.
    CREATE OBJECT lo_app_client TYPE ltcl_test_app.
    
    CREATE OBJECT lo_app TYPE z2ui5_cl_core_app.
    lo_app->mo_app = lo_app_client.

    
    CREATE OBJECT lo_bind TYPE z2ui5_cl_core_srv_bind EXPORTING APP = lo_app.

    
    lv_bind = lo_bind->main_local( lo_app_client->mv_value ).

    cl_abap_unit_assert=>assert_not_initial( lv_bind ).

  ENDMETHOD.

  METHOD test_local_one.

    DATA lo_app_client TYPE REF TO ltcl_test_app.
    DATA lo_app TYPE REF TO z2ui5_cl_core_app.
    DATA lo_bind TYPE REF TO z2ui5_cl_core_srv_bind.
    DATA lv_bind TYPE string.
    DATA temp24 LIKE REF TO lo_app_client->mv_value.
DATA lv_bind2 TYPE string.
    CREATE OBJECT lo_app_client TYPE ltcl_test_app.
    
    CREATE OBJECT lo_app TYPE z2ui5_cl_core_app.
    lo_app->mo_app = lo_app_client.

    
    CREATE OBJECT lo_bind TYPE z2ui5_cl_core_srv_bind EXPORTING APP = lo_app.

    
    lv_bind = lo_bind->main_local( lo_app_client->mv_value ).

    cl_abap_unit_assert=>assert_not_initial( lv_bind ).

    
    GET REFERENCE OF lo_app_client->mv_value INTO temp24.

lv_bind2 = lo_bind->main( val  = temp24
                                    type = z2ui5_if_core_types=>cs_bind_type-two_way ).

    cl_abap_unit_assert=>assert_not_initial( lv_bind2 ).

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

    METHODS test_one_way_lev1           FOR TESTING RAISING cx_static_check.
    METHODS test_one_way_lev2           FOR TESTING RAISING cx_static_check.
    METHODS test_one_way_lev3           FOR TESTING RAISING cx_static_check.
    METHODS test_one_way_lev4_long_name FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_test_main_structure IMPLEMENTATION.
  METHOD test_one_way_lev1.

    DATA lo_test_app TYPE REF TO ltcl_test_main_structure.
    DATA lo_app TYPE REF TO z2ui5_cl_core_app.
    DATA lo_bind TYPE REF TO z2ui5_cl_core_srv_bind.
    DATA temp25 LIKE REF TO lo_test_app->ms_struc-input.
DATA lv_result TYPE string.
    DATA temp26 LIKE REF TO lo_test_app->ms_struc-input.
DATA temp1 TYPE z2ui5_if_core_types=>ty_s_bind_config.
    CREATE OBJECT lo_test_app TYPE ltcl_test_main_structure.
    
    CREATE OBJECT lo_app TYPE z2ui5_cl_core_app.
    lo_app->mo_app = lo_test_app.

    
    CREATE OBJECT lo_bind TYPE z2ui5_cl_core_srv_bind EXPORTING APP = lo_app.
    
    GET REFERENCE OF lo_test_app->ms_struc-input INTO temp25.

lv_result = lo_bind->main( val  = temp25
                                     type = z2ui5_if_core_types=>cs_bind_type-one_way ).

    cl_abap_unit_assert=>assert_equals( exp = `{/MS_STRUC/INPUT}`
                                        act = lv_result ).

    
    GET REFERENCE OF lo_test_app->ms_struc-input INTO temp26.

CLEAR temp1.
temp1-path_only = abap_true.
lv_result = lo_bind->main( val    = temp26
                               config = temp1
                               type   = z2ui5_if_core_types=>cs_bind_type-one_way ).

    cl_abap_unit_assert=>assert_equals( exp = `/MS_STRUC/INPUT`
                                        act = lv_result ).

  ENDMETHOD.

  METHOD test_one_way_lev2.

    DATA lo_test_app TYPE REF TO ltcl_test_main_structure.
    DATA lo_app TYPE REF TO z2ui5_cl_core_app.
    DATA lo_bind TYPE REF TO z2ui5_cl_core_srv_bind.
    DATA temp27 LIKE REF TO lo_test_app->ms_struc-s_02-input.
DATA lv_result TYPE string.
    CREATE OBJECT lo_test_app TYPE ltcl_test_main_structure.
    
    CREATE OBJECT lo_app TYPE z2ui5_cl_core_app.
    lo_app->mo_app = lo_test_app.

    
    CREATE OBJECT lo_bind TYPE z2ui5_cl_core_srv_bind EXPORTING APP = lo_app.
    
    GET REFERENCE OF lo_test_app->ms_struc-s_02-input INTO temp27.

lv_result = lo_bind->main( val  = temp27
                                     type = z2ui5_if_core_types=>cs_bind_type-one_way ).

    cl_abap_unit_assert=>assert_equals( exp = `{/MS_STRUC/S_02/INPUT}`
                                        act = lv_result ).

  ENDMETHOD.

  METHOD test_one_way_lev3.

    DATA lo_test_app TYPE REF TO ltcl_test_main_structure.
    DATA lo_app TYPE REF TO z2ui5_cl_core_app.
    DATA lo_bind TYPE REF TO z2ui5_cl_core_srv_bind.
    DATA temp28 LIKE REF TO lo_test_app->ms_struc-s_02-s_03-input.
DATA lv_result TYPE string.
    CREATE OBJECT lo_test_app TYPE ltcl_test_main_structure.
    
    CREATE OBJECT lo_app TYPE z2ui5_cl_core_app.
    lo_app->mo_app = lo_test_app.

    
    CREATE OBJECT lo_bind TYPE z2ui5_cl_core_srv_bind EXPORTING APP = lo_app.
    
    GET REFERENCE OF lo_test_app->ms_struc-s_02-s_03-input INTO temp28.

lv_result = lo_bind->main( val  = temp28
                                     type = z2ui5_if_core_types=>cs_bind_type-one_way ).

    cl_abap_unit_assert=>assert_equals( exp = `{/MS_STRUC/S_02/S_03/INPUT}`
                                        act = lv_result ).

  ENDMETHOD.

  METHOD test_one_way_lev4_long_name.

    DATA lo_test_app TYPE REF TO ltcl_test_main_structure.
    DATA lo_app TYPE REF TO z2ui5_cl_core_app.
    DATA lo_bind TYPE REF TO z2ui5_cl_core_srv_bind.
    DATA temp29 LIKE REF TO lo_test_app->ms_struc-s_02-s_03-s_04-input.
DATA lv_result TYPE string.
    CREATE OBJECT lo_test_app TYPE ltcl_test_main_structure.
    
    CREATE OBJECT lo_app TYPE z2ui5_cl_core_app.
    lo_app->mo_app = lo_test_app.

    
    CREATE OBJECT lo_bind TYPE z2ui5_cl_core_srv_bind EXPORTING APP = lo_app.
    
    GET REFERENCE OF lo_test_app->ms_struc-s_02-s_03-s_04-input INTO temp29.

lv_result = lo_bind->main( val  = temp29
                                     type = z2ui5_if_core_types=>cs_bind_type-one_way ).

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

    METHODS test_one_way_value FOR TESTING RAISING cx_static_check.
    METHODS test_one_way_struc FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_test_main_object IMPLEMENTATION.
  METHOD test_one_way_value.

    DATA lo_test_app TYPE REF TO ltcl_test_main_object.
    DATA lo_app TYPE REF TO z2ui5_cl_core_app.
    DATA lo_bind TYPE REF TO z2ui5_cl_core_srv_bind.
    DATA temp30 LIKE REF TO lo_test_app->mo_obj->mv_value.
DATA lv_result TYPE string.
    CREATE OBJECT lo_test_app TYPE ltcl_test_main_object.
    CREATE OBJECT lo_test_app->mo_obj.
    lo_test_app->mo_obj->mv_value = `test`.
    
    CREATE OBJECT lo_app TYPE z2ui5_cl_core_app.
    lo_app->mo_app = lo_test_app.

    
    CREATE OBJECT lo_bind TYPE z2ui5_cl_core_srv_bind EXPORTING APP = lo_app.
    
    GET REFERENCE OF lo_test_app->mo_obj->mv_value INTO temp30.

lv_result = lo_bind->main( val  = temp30
                                     type = z2ui5_if_core_types=>cs_bind_type-one_way ).

    cl_abap_unit_assert=>assert_equals( exp = `{/MO_OBJ/MV_VALUE}`
                                        act = lv_result ).

  ENDMETHOD.

  METHOD test_one_way_struc.

    DATA lo_test_app TYPE REF TO ltcl_test_main_object.
    DATA lo_app TYPE REF TO z2ui5_cl_core_app.
    DATA lo_bind TYPE REF TO z2ui5_cl_core_srv_bind.
    DATA temp31 LIKE REF TO lo_test_app->mo_obj->ms_struc-input.
DATA lv_result TYPE string.
    CREATE OBJECT lo_test_app TYPE ltcl_test_main_object.
    CREATE OBJECT lo_test_app->mo_obj.
    
    CREATE OBJECT lo_app TYPE z2ui5_cl_core_app.
    lo_app->mo_app = lo_test_app.

    
    CREATE OBJECT lo_bind TYPE z2ui5_cl_core_srv_bind EXPORTING APP = lo_app.
    
    GET REFERENCE OF lo_test_app->mo_obj->ms_struc-input INTO temp31.

lv_result = lo_bind->main( val  = temp31
                                     type = z2ui5_if_core_types=>cs_bind_type-one_way ).

    cl_abap_unit_assert=>assert_equals( exp = `{/MO_OBJ/MS_STRUC/INPUT}`
                                        act = lv_result ).

  ENDMETHOD.
ENDCLASS.
