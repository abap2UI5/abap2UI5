
CLASS ltcl_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    METHODS test_factory          FOR TESTING RAISING cx_static_check.
    METHODS test_factory_defaults FOR TESTING RAISING cx_static_check.
    METHODS test_factory_custom   FOR TESTING RAISING cx_static_check.
    METHODS test_result_initial   FOR TESTING RAISING cx_static_check.
    METHODS test_constants        FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_test IMPLEMENTATION.

  METHOD test_factory.

    DATA(lo_pop) = z2ui5_cl_pop_to_confirm=>factory( `Are you sure?` ).
    cl_abap_unit_assert=>assert_bound( lo_pop ).

  ENDMETHOD.

  METHOD test_factory_defaults.

    DATA(lo_pop) = z2ui5_cl_pop_to_confirm=>factory( `Delete?` ).
    cl_abap_unit_assert=>assert_false( lo_pop->result( ) ).

  ENDMETHOD.

  METHOD test_factory_custom.

    DATA(lo_pop) = z2ui5_cl_pop_to_confirm=>factory(
      i_question_text       = `Proceed?`
      i_title               = `Custom Title`
      i_icon                = `sap-icon://warning`
      i_button_text_confirm = `Yes`
      i_button_text_cancel  = `No` ).

    cl_abap_unit_assert=>assert_bound( lo_pop ).

  ENDMETHOD.

  METHOD test_result_initial.

    DATA(lo_pop) = z2ui5_cl_pop_to_confirm=>factory( `Test?` ).
    cl_abap_unit_assert=>assert_false( lo_pop->result( ) ).

  ENDMETHOD.

  METHOD test_constants.

    cl_abap_unit_assert=>assert_not_initial( z2ui5_cl_pop_to_confirm=>cs_event-confirmed ).
    cl_abap_unit_assert=>assert_not_initial( z2ui5_cl_pop_to_confirm=>cs_event-canceled ).

  ENDMETHOD.

ENDCLASS.
