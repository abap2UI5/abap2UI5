CLASS ltcl_test_user_exit DEFINITION DEFERRED.
" the double below is put where the class lookup would put it, which needs
" access to the protected reference - see test_superseded_intf
CLASS z2ui5_cl_ui5_user_exit DEFINITION LOCAL FRIENDS ltcl_test_user_exit.

" A customer exit written against the SUPERSEDED interface: what the rename
" promises to keep working.
CLASS ltcl_exit_dep DEFINITION FINAL.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_exit.

ENDCLASS.


CLASS ltcl_exit_dep IMPLEMENTATION.

  METHOD z2ui5_if_exit~set_config_http_get.

    cs_config-theme = `sap_belize`.

  ENDMETHOD.

  METHOD z2ui5_if_exit~set_config_http_post.

    cs_config-draft_exp_time_in_hours = 9.

  ENDMETHOD.

ENDCLASS.


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
    DATA temp2 TYPE xsdboolean.

    z2ui5_cl_ui5_user_exit=>get_instance( )->set_config_http_get( CHANGING cs_config = ls_config ).

    cl_abap_unit_assert=>assert_equals( exp = `sap_horizon`
                                        act = ls_config-theme ).

    cl_abap_unit_assert=>assert_not_initial( ls_config-src ).


    temp2 = boolc( ls_config-content_security_policy CS `Content-Security-Policy` ).
    temp1 = temp2.
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

    " The compatibility promise of the rename: an exit written against the
    " superseded z2ui5_if_exit is still called. What finds such a class is a
    " class-registry lookup that needs SEOCLASS or XCO and has neither here, so
    " the double is placed where that lookup would place it - which leaves the
    " dispatch under test, the part that decides whether the old interface is
    " honoured at all.

    DATA ls_config TYPE z2ui5_if_ui5_exit=>ty_s_http_config.
    DATA ls_post   TYPE z2ui5_if_ui5_exit=>ty_s_http_config_post.

    DATA li_exit TYPE REF TO z2ui5_if_ui5_exit.
    li_exit = z2ui5_cl_ui5_user_exit=>get_instance( ).

    CREATE OBJECT z2ui5_cl_ui5_user_exit=>gi_user_exit_dep TYPE ltcl_exit_dep.

    li_exit->set_config_http_get( CHANGING cs_config = ls_config ).
    li_exit->set_config_http_post( CHANGING cs_config = ls_post ).

    CLEAR z2ui5_cl_ui5_user_exit=>gi_user_exit_dep.

    " both seeded by the shipped exit first, then overwritten by the exit it
    " found - `sap_horizon` or 4 here would mean the old interface was skipped
    cl_abap_unit_assert=>assert_equals( exp = `sap_belize`
                                        act = ls_config-theme ).

    cl_abap_unit_assert=>assert_equals( exp = 9
                                        act = ls_post-draft_exp_time_in_hours ).

  ENDMETHOD.

ENDCLASS.
