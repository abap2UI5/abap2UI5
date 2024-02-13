CLASS ltcl_test_app DEFINITION FINAL FOR TESTING
  DURATION MEDIUM
  RISK LEVEL HARMLESS.

  PUBLIC SECTION.

    DATA mv_value TYPE string ##NEEDED.

    DATA xx TYPE string ##NEEDED.
    METHODS constructor.
ENDCLASS.

CLASS ltcl_test_app IMPLEMENTATION.

  METHOD constructor.

  ENDMETHOD.

ENDCLASS.

CLASS ltcl_test_attri DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    METHODS first_test FOR TESTING RAISING cx_static_check.
    METHODS second_test FOR TESTING RAISING cx_static_check.
    METHODS third_test FOR TESTING RAISING cx_static_check.

ENDCLASS.

CLASS z2ui5_cl_core_app DEFINITION LOCAL FRIENDS ltcl_test_attri.

CLASS ltcl_test_attri IMPLEMENTATION.

  METHOD first_test.

    DATA(lo_app_client) = NEW ltcl_test_app( ).
    DATA lr_value TYPE REF TO data.
    GET REFERENCE OF lo_app_client->mv_value INTO lr_value.

    DATA(lt_attri) = VALUE z2ui5_if_core_types=>ty_t_attri( ( r_ref = lr_value ) ).

    DATA(lo_model) = NEW z2ui5_cl_core_model_srv(
      attri = REF #( lt_attri )
      app   = lo_app_client ).

    DATA(lr_attri) = lo_model->search_attribute( REF #( lo_app_client->mv_value ) ).

    IF lr_attri->r_ref <> lr_value.
      cl_abap_unit_assert=>abort( ).
    ENDIF.

  ENDMETHOD.

  METHOD second_test.

    DATA(lo_app_client) = NEW ltcl_test_app( ).
    DATA lr_value TYPE REF TO data.
    GET REFERENCE OF lo_app_client->mv_value INTO lr_value.

    DATA(lt_attri) = VALUE z2ui5_if_core_types=>ty_t_attri( ( r_ref = REF #( lo_app_client->mv_value ) ) ).

    DATA(lo_model) = NEW z2ui5_cl_core_model_srv(
      attri = REF #( lt_attri )
      app   = lo_app_client ).

    DATA(lr_attri) = lo_model->search_attribute( REF #( lo_app_client->mv_value ) ).

    IF lr_attri->r_ref <> lr_value.
      cl_abap_unit_assert=>abort( ).
    ENDIF.

  ENDMETHOD.

  METHOD third_test.


  ENDMETHOD.

ENDCLASS.
