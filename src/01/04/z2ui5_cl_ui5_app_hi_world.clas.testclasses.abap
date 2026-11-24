
CLASS ltcl_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    METHODS test_create          FOR TESTING RAISING cx_static_check.
    METHODS test_post_names_input FOR TESTING RAISING cx_static_check.
    METHODS test_name_attribute  FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_test IMPLEMENTATION.

  METHOD test_create.

    DATA(lo_app) = NEW z2ui5_cl_ui5_app_hi_world( ).
    cl_abap_unit_assert=>assert_bound( lo_app ).

  ENDMETHOD.

  METHOD test_post_names_input.

    " the one thing the app does: BUTTON_POST answers with a message box
    " that names what was typed - driven like the browser drives it, through
    " the public test harness: the first start renders the form, the user
    " types into the bound input, the press sends the edit with the event
    DATA(lo_test) = z2ui5_cl_ui5_test=>start( NEW z2ui5_cl_ui5_app_hi_world( ) ).

    cl_abap_unit_assert=>assert_true( act = xsdbool( lo_test->view_xml( ) CS `abap2UI5 - Hello World` )
                                      msg = lo_test->view_xml( ) ).
    cl_abap_unit_assert=>assert_equals( exp = ``
                                        act = lo_test->model( `/NAME` ) ).

    lo_test->set_model( path = `/NAME`
                        val  = `Ada` )->event( `BUTTON_POST` ).

    DATA(lt_message) = lo_test->messages( ).
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( lt_message ) ).
    cl_abap_unit_assert=>assert_equals( exp = `Your name is Ada`
                                        act = lt_message[ 1 ]-text ).
    " the edit reached the attribute of the instance the draft restored
    cl_abap_unit_assert=>assert_equals( exp = `Ada`
                                        act = CAST z2ui5_cl_ui5_app_hi_world( lo_test->app( ) )->name ).
    " an event does not rebuild the view - the form stays on screen
    cl_abap_unit_assert=>assert_true( xsdbool( lo_test->view_xml( ) CS `BUTTON_POST` ) ).

  ENDMETHOD.

  METHOD test_name_attribute.

    DATA(lo_app) = NEW z2ui5_cl_ui5_app_hi_world( ).
    lo_app->name = `Test Name`.
    cl_abap_unit_assert=>assert_equals( exp = `Test Name`
                                        act = lo_app->name ).

  ENDMETHOD.

ENDCLASS.
