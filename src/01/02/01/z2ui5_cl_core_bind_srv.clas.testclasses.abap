
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
