
CLASS ltcl_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    METHODS test_factory          FOR TESTING RAISING cx_static_check.
    METHODS test_factory_custom   FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_test IMPLEMENTATION.

  METHOD test_factory.

    DATA(lo_pop) = z2ui5_cl_pop_html=>factory( `<p>Hello</p>` ).
    cl_abap_unit_assert=>assert_bound( lo_pop ).

  ENDMETHOD.

  METHOD test_factory_custom.

    DATA(lo_pop) = z2ui5_cl_pop_html=>factory(
      i_html        = `<h1>Title</h1>`
      i_title       = `My HTML`
      i_icon        = `sap-icon://hint`
      i_button_text = `Done` ).

    cl_abap_unit_assert=>assert_bound( lo_pop ).

  ENDMETHOD.

ENDCLASS.
