
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

ENDCLASS.


CLASS ltcl_test_bind IMPLEMENTATION.
  METHOD test_one_way_w_x_error.

    DATA lo_app_client TYPE REF TO ltcl_test_app.
    DATA lo_app TYPE REF TO z2ui5_cl_core_app.
    DATA lo_bind TYPE REF TO z2ui5_cl_core_srv_bind.
        DATA temp1 LIKE REF TO lo_app_client->xx.
    CREATE OBJECT lo_app_client TYPE ltcl_test_app.
    
    CREATE OBJECT lo_app TYPE z2ui5_cl_core_app.
    lo_app->mo_app = lo_app_client.

    
    CREATE OBJECT lo_bind TYPE z2ui5_cl_core_srv_bind EXPORTING APP = lo_app.

    TRY.
        
        GET REFERENCE OF lo_app_client->xx INTO temp1.
lo_bind->main( val  = temp1
                       type = z2ui5_if_core_types=>cs_bind_type-one_way ).

        cl_abap_unit_assert=>abort( ).

      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

  ENDMETHOD.

  METHOD test_one_way.
    DATA lo_app_client TYPE REF TO ltcl_test_app.
    DATA lo_app TYPE REF TO z2ui5_cl_core_app.
    DATA lo_bind TYPE REF TO z2ui5_cl_core_srv_bind.
    DATA temp2 LIKE REF TO lo_app_client->mv_value.
DATA lv_bind TYPE string.

    IF sy-sysid = `ABC`.
      RETURN.
    ENDIF.

    
    CREATE OBJECT lo_app_client TYPE ltcl_test_app.
    
    CREATE OBJECT lo_app TYPE z2ui5_cl_core_app.
    lo_app->mo_app = lo_app_client.

    
    CREATE OBJECT lo_bind TYPE z2ui5_cl_core_srv_bind EXPORTING APP = lo_app.

    
    GET REFERENCE OF lo_app_client->mv_value INTO temp2.

lv_bind = lo_bind->main( val  = temp2
                                   type = z2ui5_if_core_types=>cs_bind_type-one_way ).

    cl_abap_unit_assert=>assert_equals( exp = `{/MV_VALUE}`
                                        act = lv_bind ).

  ENDMETHOD.

  METHOD test_error_diff.
    DATA lo_app_client TYPE REF TO ltcl_test_app.
    DATA lo_app TYPE REF TO z2ui5_cl_core_app.
    DATA lo_bind TYPE REF TO z2ui5_cl_core_srv_bind.
    DATA temp3 LIKE REF TO lo_app_client->mv_value.
        DATA temp4 LIKE REF TO lo_app_client->mv_value.

    IF sy-sysid = `ABC`.
      RETURN.
    ENDIF.


    
    CREATE OBJECT lo_app_client TYPE ltcl_test_app.
    
    CREATE OBJECT lo_app TYPE z2ui5_cl_core_app.
    lo_app->mo_app = lo_app_client.

    
    CREATE OBJECT lo_bind TYPE z2ui5_cl_core_srv_bind EXPORTING APP = lo_app.

    
    GET REFERENCE OF lo_app_client->mv_value INTO temp3.
lo_bind->main( val  = temp3
                   type = z2ui5_if_core_types=>cs_bind_type-one_way ).

    TRY.
        
        GET REFERENCE OF lo_app_client->mv_value INTO temp4.
lo_bind->main( val  = temp4
                       type = z2ui5_if_core_types=>cs_bind_type-two_way ).

        cl_abap_unit_assert=>abort( ).

      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

  ENDMETHOD.

  METHOD test_two_way.
    DATA lo_app_client TYPE REF TO ltcl_test_app.
    DATA lo_app TYPE REF TO z2ui5_cl_core_app.
    DATA lo_bind TYPE REF TO z2ui5_cl_core_srv_bind.
    DATA temp5 LIKE REF TO lo_app_client->mv_value.
DATA lv_bind TYPE string.
    DATA temp6 LIKE REF TO lo_app_client->mv_value.
DATA lv_bind2 TYPE string.

    IF sy-sysid = `ABC`.
      RETURN.
    ENDIF.

    
    CREATE OBJECT lo_app_client TYPE ltcl_test_app.
    
    CREATE OBJECT lo_app TYPE z2ui5_cl_core_app.
    lo_app->mo_app = lo_app_client.

    
    CREATE OBJECT lo_bind TYPE z2ui5_cl_core_srv_bind EXPORTING APP = lo_app.

    
    GET REFERENCE OF lo_app_client->mv_value INTO temp5.

lv_bind = lo_bind->main( val  = temp5
                                   type = z2ui5_if_core_types=>cs_bind_type-two_way ).

    
    GET REFERENCE OF lo_app_client->mv_value INTO temp6.

lv_bind2 = lo_bind->main( val  = temp6
                                    type = z2ui5_if_core_types=>cs_bind_type-two_way ).

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
    DATA temp7 LIKE REF TO lo_test_app->ms_struc-input.
DATA lv_result TYPE string.
    DATA temp8 LIKE REF TO lo_test_app->ms_struc-input.
DATA temp1 TYPE z2ui5_if_core_types=>ty_s_bind_config.

    IF sy-sysid = `ABC`.
      RETURN.
    ENDIF.


    
    CREATE OBJECT lo_test_app TYPE ltcl_test_main_structure.
    
    CREATE OBJECT lo_app TYPE z2ui5_cl_core_app.
    lo_app->mo_app = lo_test_app.

    
    CREATE OBJECT lo_bind TYPE z2ui5_cl_core_srv_bind EXPORTING APP = lo_app.
    
    GET REFERENCE OF lo_test_app->ms_struc-input INTO temp7.

lv_result = lo_bind->main( val  = temp7
                                     type = z2ui5_if_core_types=>cs_bind_type-one_way ).

    cl_abap_unit_assert=>assert_equals( exp = `{/MS_STRUC/INPUT}`
                                        act = lv_result ).

    
    GET REFERENCE OF lo_test_app->ms_struc-input INTO temp8.

CLEAR temp1.
temp1-path_only = abap_true.
lv_result = lo_bind->main( val    = temp8
                               config = temp1
                               type   = z2ui5_if_core_types=>cs_bind_type-one_way ).

    cl_abap_unit_assert=>assert_equals( exp = `/MS_STRUC/INPUT`
                                        act = lv_result ).

  ENDMETHOD.

  METHOD test_one_way_lev2.
    DATA lo_test_app TYPE REF TO ltcl_test_main_structure.
    DATA lo_app TYPE REF TO z2ui5_cl_core_app.
    DATA lo_bind TYPE REF TO z2ui5_cl_core_srv_bind.
    DATA temp9 LIKE REF TO lo_test_app->ms_struc-s_02-input.
DATA lv_result TYPE string.

    IF sy-sysid = `ABC`.
      RETURN.
    ENDIF.


    
    CREATE OBJECT lo_test_app TYPE ltcl_test_main_structure.
    
    CREATE OBJECT lo_app TYPE z2ui5_cl_core_app.
    lo_app->mo_app = lo_test_app.

    
    CREATE OBJECT lo_bind TYPE z2ui5_cl_core_srv_bind EXPORTING APP = lo_app.
    
    GET REFERENCE OF lo_test_app->ms_struc-s_02-input INTO temp9.

lv_result = lo_bind->main( val  = temp9
                                     type = z2ui5_if_core_types=>cs_bind_type-one_way ).

    cl_abap_unit_assert=>assert_equals( exp = `{/MS_STRUC/S_02/INPUT}`
                                        act = lv_result ).

  ENDMETHOD.

  METHOD test_one_way_lev3.
    DATA lo_test_app TYPE REF TO ltcl_test_main_structure.
    DATA lo_app TYPE REF TO z2ui5_cl_core_app.
    DATA lo_bind TYPE REF TO z2ui5_cl_core_srv_bind.
    DATA temp10 LIKE REF TO lo_test_app->ms_struc-s_02-s_03-input.
DATA lv_result TYPE string.

    IF sy-sysid = `ABC`.
      RETURN.
    ENDIF.

    
    CREATE OBJECT lo_test_app TYPE ltcl_test_main_structure.
    
    CREATE OBJECT lo_app TYPE z2ui5_cl_core_app.
    lo_app->mo_app = lo_test_app.

    
    CREATE OBJECT lo_bind TYPE z2ui5_cl_core_srv_bind EXPORTING APP = lo_app.
    
    GET REFERENCE OF lo_test_app->ms_struc-s_02-s_03-input INTO temp10.

lv_result = lo_bind->main( val  = temp10
                                     type = z2ui5_if_core_types=>cs_bind_type-one_way ).

    cl_abap_unit_assert=>assert_equals( exp = `{/MS_STRUC/S_02/S_03/INPUT}`
                                        act = lv_result ).

  ENDMETHOD.

  METHOD test_one_way_lev4_long_name.
    DATA lo_test_app TYPE REF TO ltcl_test_main_structure.
    DATA lo_app TYPE REF TO z2ui5_cl_core_app.
    DATA lo_bind TYPE REF TO z2ui5_cl_core_srv_bind.
    DATA temp11 LIKE REF TO lo_test_app->ms_struc-s_02-s_03-s_04-input.
DATA lv_result TYPE string.

    IF sy-sysid = `ABC`.
      RETURN.
    ENDIF.

    
    CREATE OBJECT lo_test_app TYPE ltcl_test_main_structure.
    
    CREATE OBJECT lo_app TYPE z2ui5_cl_core_app.
    lo_app->mo_app = lo_test_app.

    
    CREATE OBJECT lo_bind TYPE z2ui5_cl_core_srv_bind EXPORTING APP = lo_app.
    
    GET REFERENCE OF lo_test_app->ms_struc-s_02-s_03-s_04-input INTO temp11.

lv_result = lo_bind->main( val  = temp11
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
    DATA temp12 LIKE REF TO lo_test_app->mo_obj->mv_value.
DATA lv_result TYPE string.

    IF sy-sysid = `ABC`.
      RETURN.
    ENDIF.


    
    CREATE OBJECT lo_test_app TYPE ltcl_test_main_object.
    CREATE OBJECT lo_test_app->mo_obj.
    lo_test_app->mo_obj->mv_value = `test`.
    
    CREATE OBJECT lo_app TYPE z2ui5_cl_core_app.
    lo_app->mo_app = lo_test_app.

    
    CREATE OBJECT lo_bind TYPE z2ui5_cl_core_srv_bind EXPORTING APP = lo_app.
    
    GET REFERENCE OF lo_test_app->mo_obj->mv_value INTO temp12.

lv_result = lo_bind->main( val  = temp12
                                     type = z2ui5_if_core_types=>cs_bind_type-one_way ).

    cl_abap_unit_assert=>assert_equals( exp = `{/MO_OBJ/MV_VALUE}`
                                        act = lv_result ).

  ENDMETHOD.

  METHOD test_one_way_struc.
    DATA lo_test_app TYPE REF TO ltcl_test_main_object.
    DATA lo_app TYPE REF TO z2ui5_cl_core_app.
    DATA lo_bind TYPE REF TO z2ui5_cl_core_srv_bind.
    DATA temp13 LIKE REF TO lo_test_app->mo_obj->ms_struc-input.
DATA lv_result TYPE string.

    IF sy-sysid = `ABC`.
      RETURN.
    ENDIF.

    
    CREATE OBJECT lo_test_app TYPE ltcl_test_main_object.
    CREATE OBJECT lo_test_app->mo_obj.
    
    CREATE OBJECT lo_app TYPE z2ui5_cl_core_app.
    lo_app->mo_app = lo_test_app.

    
    CREATE OBJECT lo_bind TYPE z2ui5_cl_core_srv_bind EXPORTING APP = lo_app.
    
    GET REFERENCE OF lo_test_app->mo_obj->ms_struc-input INTO temp13.

lv_result = lo_bind->main( val  = temp13
                                     type = z2ui5_if_core_types=>cs_bind_type-one_way ).

    cl_abap_unit_assert=>assert_equals( exp = `{/MO_OBJ/MS_STRUC/INPUT}`
                                        act = lv_result ).

  ENDMETHOD.
ENDCLASS.
