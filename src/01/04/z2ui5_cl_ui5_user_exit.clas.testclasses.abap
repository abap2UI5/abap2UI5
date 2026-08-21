CLASS ltcl_test_user_exit DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_defaults_http_get   FOR TESTING RAISING cx_static_check.
    METHODS test_defaults_http_post  FOR TESTING RAISING cx_static_check.
    METHODS test_expiry_clamped      FOR TESTING RAISING cx_static_check.
    METHODS test_superseded_intf     FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_test_user_exit IMPLEMENTATION.

  METHOD test_defaults_http_get.

    DATA ls_config TYPE z2ui5_if_ui5_exit=>ty_s_http_config.
    DATA temp1 TYPE xsdboolean.

    z2ui5_cl_ui5_user_exit=>get_instance( )->set_config_http_get( CHANGING cs_config = ls_config ).

    cl_abap_unit_assert=>assert_equals( exp = `sap_horizon`
                                        act = ls_config-theme ).

    cl_abap_unit_assert=>assert_not_initial( ls_config-src ).

    temp1 = xsdbool( ls_config-content_security_policy CS `Content-Security-Policy` ).
    cl_abap_unit_assert=>assert_true( temp1 ).

    cl_abap_unit_assert=>assert_not_initial( ls_config-t_security_header ).

  ENDMETHOD.

  METHOD test_defaults_http_post.

    DATA ls_config TYPE z2ui5_if_ui5_exit=>ty_s_http_config_post.

    z2ui5_cl_ui5_user_exit=>get_instance( )->set_config_http_post( CHANGING cs_config = ls_config ).

    " CSRF on unless an exit opts out, and a positive default expiry
    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = ls_config-check_csrf_active ).

    cl_abap_unit_assert=>assert_equals( exp = 4
                                        act = ls_config-draft_exp_time_in_hours ).

  ENDMETHOD.

  METHOD test_expiry_clamped.

    DATA ls_config TYPE z2ui5_if_ui5_exit=>ty_s_http_config_post.

    " an exit that hands back 0 (or a negative) would expire every draft
    " immediately - the shipped exit clamps it back to its default
    ls_config-draft_exp_time_in_hours = -1.

    z2ui5_cl_ui5_user_exit=>get_instance( )->set_config_http_post( CHANGING cs_config = ls_config ).

    cl_abap_unit_assert=>assert_equals( exp = 4
                                        act = ls_config-draft_exp_time_in_hours ).

  ENDMETHOD.

  METHOD test_superseded_intf.

    " The compatibility promise of the rename: z2ui5_if_exit is the superseded
    " name of z2ui5_if_ui5_exit, an exit written against it is still called,
    " and the shipped exit is still reachable through it. Asserted where it can
    " be asserted without a system - the class registry lookup that finds a
    " CUSTOMER exit needs SEOCLASS/XCO and has neither here.

    DATA li_exit   TYPE REF TO z2ui5_if_exit.
    DATA ls_config TYPE z2ui5_if_exit=>ty_s_http_config.

    li_exit ?= z2ui5_cl_ui5_user_exit=>get_instance( ).

    cl_abap_unit_assert=>assert_bound( li_exit ).

    li_exit->set_config_http_get( CHANGING cs_config = ls_config ).

    cl_abap_unit_assert=>assert_equals( exp = `sap_horizon`
                                        act = ls_config-theme ).

  ENDMETHOD.

ENDCLASS.
