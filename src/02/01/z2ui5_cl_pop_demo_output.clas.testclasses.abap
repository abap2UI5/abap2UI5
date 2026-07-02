
CLASS ltcl_output_stub DEFINITION FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS get
      RETURNING
        VALUE(result) TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS ltcl_output_stub IMPLEMENTATION.

  METHOD get.

    result = `<p><span class="heading1">Hello cl_demo_output</span></p>`.

  ENDMETHOD.

ENDCLASS.


CLASS ltcl_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    METHODS test_factory          FOR TESTING RAISING cx_static_check.
    METHODS test_factory_custom   FOR TESTING RAISING cx_static_check.
    METHODS test_factory_as_page  FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_test IMPLEMENTATION.

  METHOD test_factory.

    DATA lo_pop TYPE REF TO z2ui5_cl_pop_demo_output.
    DATA temp1 TYPE REF TO ltcl_output_stub.
    CREATE OBJECT temp1 TYPE ltcl_output_stub.
    lo_pop = z2ui5_cl_pop_demo_output=>factory( temp1 ).
    cl_abap_unit_assert=>assert_bound( lo_pop ).

  ENDMETHOD.

  METHOD test_factory_custom.

    DATA lo_pop TYPE REF TO z2ui5_cl_pop_demo_output.
    DATA temp2 TYPE REF TO ltcl_output_stub.
    CREATE OBJECT temp2 TYPE ltcl_output_stub.
    lo_pop = z2ui5_cl_pop_demo_output=>factory(
      i_output      = temp2
      i_title       = `My Output`
      i_icon        = `sap-icon://hint`
      i_button_text = `Close`
      i_stretch     = abap_true ).

    cl_abap_unit_assert=>assert_bound( lo_pop ).

  ENDMETHOD.

  METHOD test_factory_as_page.

    DATA lo_pop TYPE REF TO z2ui5_cl_pop_demo_output.
    DATA temp3 TYPE REF TO ltcl_output_stub.
    CREATE OBJECT temp3 TYPE ltcl_output_stub.
    lo_pop = z2ui5_cl_pop_demo_output=>factory(
      i_output  = temp3
      i_as_page = abap_true ).

    cl_abap_unit_assert=>assert_bound( lo_pop ).

  ENDMETHOD.

ENDCLASS.
