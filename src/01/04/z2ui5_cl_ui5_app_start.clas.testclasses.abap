CLASS ltcl_app_startup_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_first FOR TESTING RAISING cx_static_check.
    METHODS test_link_enabled FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_app_startup_test IMPLEMENTATION.
  METHOD test_first.

    DATA(lo_app) = z2ui5_cl_ui5_app_start=>factory( ) ##NEEDED.

  ENDMETHOD.

  METHOD test_link_enabled.

    " link_enabled is the plain model value the step-5 link binds to - it
    " replaced a UI5 expression binding, which would be eval-compiled and
    " therefore break under a strict CSP. It must stay the exact inverse of
    " class_editable, so the link is only clickable after a successful check.
    DATA(lo_app) = z2ui5_cl_ui5_app_start=>factory( ).

    lo_app->ms_home-link_enabled = abap_true.
    lo_app->reset_button_state( ).

    cl_abap_unit_assert=>assert_equals( act = lo_app->ms_home-link_enabled
                                        exp = abap_false
                                        msg = `reset must disable the app link again` ).
    cl_abap_unit_assert=>assert_equals( act = lo_app->ms_home-class_editable
                                        exp = abap_true
                                        msg = `reset must make the class name editable again` ).

  ENDMETHOD.
ENDCLASS.
