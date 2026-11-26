
CLASS ltcl_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    METHODS test_create          FOR TESTING RAISING cx_static_check.
    METHODS test_post_names_input FOR TESTING RAISING cx_static_check.
    METHODS test_name_attribute  FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_test IMPLEMENTATION.

  METHOD test_create.

    DATA lo_app TYPE REF TO z2ui5_cl_ui5_app_hi_world.
    CREATE OBJECT lo_app TYPE z2ui5_cl_ui5_app_hi_world.
    cl_abap_unit_assert=>assert_bound( lo_app ).

  ENDMETHOD.

  METHOD test_post_names_input.

    " the one thing the app does: BUTTON_POST answers with a message box
    " that names what was typed - driven like the browser drives it, through
    " the public test harness: the first start renders the form, the user
    " types into the bound input, the press sends the edit with the event
    DATA lo_test TYPE REF TO z2ui5_cl_ui5_test.
    DATA temp1 TYPE REF TO z2ui5_cl_ui5_app_hi_world.
    DATA temp4 TYPE xsdboolean.
    DATA lt_message TYPE z2ui5_cl_ui5_test=>ty_t_message.
    FIELD-SYMBOLS <temp1> LIKE LINE OF lt_message.
    DATA temp2 LIKE sy-tabix.
    DATA temp3 TYPE REF TO z2ui5_cl_ui5_app_hi_world.
    DATA temp5 TYPE xsdboolean.
    CREATE OBJECT temp1 TYPE z2ui5_cl_ui5_app_hi_world.
    lo_test = z2ui5_cl_ui5_test=>start( temp1 ).


    temp4 = boolc( lo_test->view_xml( ) CS `abap2UI5 - Hello World` ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp4
                                      msg = lo_test->view_xml( ) ).
    cl_abap_unit_assert=>assert_equals( exp = ``
                                        act = lo_test->model( `/NAME` ) ).

    lo_test->set_model( path = `/NAME`
                        val  = `Ada` )->event( `BUTTON_POST` ).


    lt_message = lo_test->messages( ).
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( lt_message ) ).


    temp2 = sy-tabix.
    READ TABLE lt_message INDEX 1 ASSIGNING <temp1>.
    sy-tabix = temp2.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `Your name is Ada`
                                        act = <temp1>-text ).
    " the edit reached the attribute of the instance the draft restored

    temp3 ?= lo_test->app( ).
    cl_abap_unit_assert=>assert_equals( exp = `Ada`
                                        act = temp3->name ).
    " an event does not rebuild the view - the form stays on screen

    temp5 = boolc( lo_test->view_xml( ) CS `BUTTON_POST` ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp5 ).

  ENDMETHOD.

  METHOD test_name_attribute.

    DATA lo_app TYPE REF TO z2ui5_cl_ui5_app_hi_world.
    CREATE OBJECT lo_app TYPE z2ui5_cl_ui5_app_hi_world.
    lo_app->name = `Test Name`.
    cl_abap_unit_assert=>assert_equals( exp = `Test Name`
                                        act = lo_app->name ).

  ENDMETHOD.

ENDCLASS.
