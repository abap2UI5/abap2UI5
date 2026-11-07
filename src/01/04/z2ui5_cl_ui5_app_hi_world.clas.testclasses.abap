
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
    " that names what was typed - run through the real client, the way the
    " start page's tests do. This replaced a test that cast the app to
    " z2ui5_if_app and asserted the reference was bound, which the compiler
    " already guarantees for a class that implements the interface
    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    lo_handler = NEW #( val = `` ).
    lo_handler->mo_action->ms_actual-event = `BUTTON_POST`.
    DATA(lo_app) = NEW z2ui5_cl_ui5_app_hi_world( ).
    lo_app->name = `Ada`.

    lo_app->z2ui5_if_app~main( NEW z2ui5_cl_ui5_client( lo_handler->mo_action ) ).

    DATA lv_json TYPE string.
    LOOP AT lo_handler->mo_action->ms_next-s_action-t_custom INTO DATA(ls_action).
      lv_json = lv_json && ls_action-o_json->stringify( ).
    ENDLOOP.
    cl_abap_unit_assert=>assert_true( act = xsdbool( lv_json CS `Your name is Ada` )
                                      msg = lv_json ).

  ENDMETHOD.

  METHOD test_name_attribute.

    DATA(lo_app) = NEW z2ui5_cl_ui5_app_hi_world( ).
    lo_app->name = `Test Name`.
    cl_abap_unit_assert=>assert_equals( exp = `Test Name`
                                        act = lo_app->name ).

  ENDMETHOD.

ENDCLASS.
