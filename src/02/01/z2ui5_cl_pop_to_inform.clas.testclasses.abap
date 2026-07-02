CLASS ltcl_test DEFINITION DEFERRED.
CLASS z2ui5_cl_pop_to_inform DEFINITION LOCAL FRIENDS ltcl_test.

CLASS ltcl_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    METHODS test_factory          FOR TESTING RAISING cx_static_check.
    METHODS test_factory_defaults FOR TESTING RAISING cx_static_check.
    METHODS test_factory_custom   FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_test IMPLEMENTATION.

  METHOD test_factory.

    DATA(lo_pop) = z2ui5_cl_pop_to_inform=>factory( `Info message` ).
    cl_abap_unit_assert=>assert_bound( lo_pop ).

  ENDMETHOD.

  METHOD test_factory_defaults.

    DATA(lo_pop) = z2ui5_cl_pop_to_inform=>factory( `Hello` ).

    cl_abap_unit_assert=>assert_equals( exp = `Hello`
                                        act = lo_pop->question_text ).
    cl_abap_unit_assert=>assert_equals( exp = `Information`
                                        act = lo_pop->title ).
    cl_abap_unit_assert=>assert_equals( exp = `sap-icon://information`
                                        act = lo_pop->icon ).
    cl_abap_unit_assert=>assert_equals( exp = `OK`
                                        act = lo_pop->button_text_confirm ).

  ENDMETHOD.

  METHOD test_factory_custom.

    DATA(lo_pop) = z2ui5_cl_pop_to_inform=>factory(
      i_text        = `Custom Info`
      i_title       = `My Title`
      i_icon        = `sap-icon://hint`
      i_button_text = `Close` ).

    cl_abap_unit_assert=>assert_equals( exp = `Custom Info`
                                        act = lo_pop->question_text ).
    cl_abap_unit_assert=>assert_equals( exp = `My Title`
                                        act = lo_pop->title ).
    cl_abap_unit_assert=>assert_equals( exp = `sap-icon://hint`
                                        act = lo_pop->icon ).
    cl_abap_unit_assert=>assert_equals( exp = `Close`
                                        act = lo_pop->button_text_confirm ).

  ENDMETHOD.

ENDCLASS.
