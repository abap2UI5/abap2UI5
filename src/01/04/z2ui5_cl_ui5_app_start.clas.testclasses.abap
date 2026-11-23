CLASS ltcl_app_startup_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_factory_state FOR TESTING RAISING cx_static_check.
    METHODS test_on_init_proposal FOR TESTING RAISING cx_static_check.
    METHODS test_reset_clears_outcome FOR TESTING RAISING cx_static_check.
    METHODS test_link_enabled FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_app_startup_test IMPLEMENTATION.

  METHOD test_factory_state.

    " A fresh instance is the one a first request renders, so its model has to
    " be the Check state already - the view binds these fields before any
    " event has run. This replaced a test that called factory( ) into a
    " ##NEEDED variable and asserted nothing: it passed for as long as the
    " constructor did not dump, which is not what its name claimed.
    DATA(lo_app) = z2ui5_cl_ui5_app_start=>factory( ).

    cl_abap_unit_assert=>assert_bound( lo_app ).
    cl_abap_unit_assert=>assert_equals( act = lo_app->ms_home-class_editable
                                        exp = abap_true
                                        msg = `a fresh app offers an editable class name` ).
    cl_abap_unit_assert=>assert_equals( act = lo_app->ms_home-link_enabled
                                        exp = abap_false
                                        msg = `nothing has been checked yet - the app link stays dead` ).

  ENDMETHOD.

  METHOD test_on_init_proposal.

    " The proposal in the input is the hello-world app, resolved by RTTI
    " rather than written as a literal: the name is the one thing here that a
    " rename would silently break, and the input would then propose a class
    " that no longer exists.
    DATA(lo_app) = z2ui5_cl_ui5_app_start=>factory( ).
    lo_app->on_init( ).

    cl_abap_unit_assert=>assert_equals(
        act = to_upper( lo_app->ms_home-classname )
        exp = `Z2UI5_CL_UI5_APP_HI_WORLD`
        msg = `on_init proposes the hello-world app as the class to check` ).
    cl_abap_unit_assert=>assert_equals(
        act = lo_app->ms_home-btn_event_id
        exp = z2ui5_cl_ui5_app_start=>cs_event-button_check
        msg = `on_init leaves the button on Check` ).

  ENDMETHOD.

  METHOD test_reset_clears_outcome.

    " Going back to Edit has to drop the PREVIOUS check's outcome, or the
    " re-opened input still shows the old value state and a stale step-5 link.
    " class_value_state is bound to a UI5 ValueState, so it is set to `None`
    " and NOT cleared - an empty string there is not a valid ValueState.
    DATA(lo_app) = z2ui5_cl_ui5_app_start=>factory( ).

    lo_app->ms_home-url                    = `https://example.org/?app_start=ZCL_X`.
    lo_app->ms_home-class_value_state      = `Success`.
    lo_app->ms_home-class_value_state_text = `all good`.

    lo_app->reset_button_state( ).

    cl_abap_unit_assert=>assert_initial( act = lo_app->ms_home-url
                                         msg = `reset drops the link of the previous check` ).
    cl_abap_unit_assert=>assert_initial( act = lo_app->ms_home-class_value_state_text
                                         msg = `reset drops the previous check's message` ).
    cl_abap_unit_assert=>assert_equals( act = lo_app->ms_home-class_value_state
                                        exp = `None`
                                        msg = `ValueState is set to None, never cleared` ).

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
