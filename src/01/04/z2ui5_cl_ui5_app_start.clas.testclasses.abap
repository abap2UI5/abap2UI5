CLASS ltcl_app_startup_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_factory_state FOR TESTING RAISING cx_static_check.
    METHODS test_on_init_proposal FOR TESTING RAISING cx_static_check.
    METHODS test_reset_clears_outcome FOR TESTING RAISING cx_static_check.
    METHODS test_link_enabled FOR TESTING RAISING cx_static_check.
    METHODS test_link_href_literal FOR TESTING RAISING cx_static_check.
    METHODS test_check_success_clears_text FOR TESTING RAISING cx_static_check.
    METHODS test_check_empty_name FOR TESTING RAISING cx_static_check.
    METHODS test_check_precheck_hidden FOR TESTING RAISING cx_static_check.
    METHODS test_error_text_hidden FOR TESTING RAISING cx_static_check.
    METHODS test_popup_user_exit_row FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS z2ui5_cl_ui5_app_start DEFINITION LOCAL FRIENDS ltcl_app_startup_test.


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

  METHOD test_check_success_clears_text.

    " A failed check leaves its message in class_value_state_text and the
    " input editable, so the user corrects the name and checks again. The
    " successful check must drop that message, or the input carries the old
    " error text under a Success state.
    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    lo_handler = NEW #( val = `` ).
    DATA(lo_app) = z2ui5_cl_ui5_app_start=>factory( ).
    lo_app->client = NEW z2ui5_cl_ui5_client( lo_handler->mo_action ).

    lo_app->ms_home-classname              = `z2ui5_cl_ui5_app_hi_world`.
    lo_app->ms_home-class_value_state      = `Warning`.
    lo_app->ms_home-class_value_state_text = `Class ZZZ does not exist`.

    lo_app->on_event_check( ).

    cl_abap_unit_assert=>assert_equals( act = lo_app->ms_home-class_value_state
                                        exp = `Success`
                                        msg = `the check of a real app succeeds` ).
    cl_abap_unit_assert=>assert_initial( act = lo_app->ms_home-class_value_state_text
                                         msg = `a success drops the previous check's message` ).

  ENDMETHOD.

  METHOD test_check_empty_name.

    " Check pressed on an empty input: the message asks for a name instead of
    " reporting `Class  does not exist or does not implement ...` - a class
    " with no name, and a double blank where it should stand
    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    lo_handler = NEW #( val = `` ).
    DATA(lo_app) = z2ui5_cl_ui5_app_start=>factory( ).
    lo_app->client = NEW z2ui5_cl_ui5_client( lo_handler->mo_action ).

    lo_app->ms_home-classname = `   `.

    lo_app->on_event_check( ).

    cl_abap_unit_assert=>assert_equals( act = lo_app->ms_home-class_value_state_text
                                        exp = `Enter the name of your class first`
                                        msg = `an empty name asks for one` ).
    cl_abap_unit_assert=>assert_equals( act = lo_app->ms_home-class_value_state
                                        exp = `Warning`
                                        msg = `the input is marked like any failed check` ).
    cl_abap_unit_assert=>assert_equals( act = lo_app->ms_home-link_enabled
                                        exp = abap_false
                                        msg = `nothing was checked - the app link stays dead` ).

  ENDMETHOD.

  METHOD test_check_precheck_hidden.

    " An exit that hides error details hides SYSTEM text - the exception of a
    " CREATE OBJECT. The pre-check's sentence is the framework's own and
    " names only what the user typed; it used to be raised into the same
    " CATCH and replaced by the plain sentence of error_text_for_user
    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    lo_handler = NEW #( val = `` ).
    DATA(lo_app) = z2ui5_cl_ui5_app_start=>factory( ).
    lo_app->client = NEW z2ui5_cl_ui5_client( lo_handler->mo_action ).

    lo_app->ms_home-classname = `zz_no_such_class_4711`.

    lo_app->check_class( abap_true ).

    DATA(lv_text) = lo_app->ms_home-class_value_state_text.
    cl_abap_unit_assert=>assert_true( act = xsdbool( lv_text CS `ZZ_NO_SUCH_CLASS_4711 does not exist` )
                                      msg = lv_text ).
    cl_abap_unit_assert=>assert_equals( act = lo_app->ms_home-class_value_state
                                        exp = `Warning`
                                        msg = `the input is marked as failed` ).
    cl_abap_unit_assert=>assert_equals( act = lo_app->ms_home-link_enabled
                                        exp = abap_false
                                        msg = `a refused class leaves the app link dead` ).

  ENDMETHOD.

  METHOD test_error_text_hidden.

    " what the switch does hide: the text of an exception the system raised
    DATA(lo_app) = z2ui5_cl_ui5_app_start=>factory( ).
    DATA(lx) = NEW z2ui5_cx_ui5_util_error( val = `CX_SY_CREATE_OBJECT_ERROR detail` ).

    cl_abap_unit_assert=>assert_equals(
        act = lo_app->error_text_for_user( ix = lx hide_details = abap_false )
        exp = `CX_SY_CREATE_OBJECT_ERROR detail`
        msg = `details shown: the exception text` ).
    " ...and the sentence says where the details went. It used to send the
    " reader to "the system log", where nothing of this is ever written
    DATA(lv_hidden) = lo_app->error_text_for_user( ix           = lx
                                                   hide_details = abap_true ).
    cl_abap_unit_assert=>assert_equals(
        act = lv_hidden
        exp = `The class could not be instantiated - error details are hidden by this installation's user exit (check_hide_error_details)`
        msg = `details hidden: the plain sentence` ).
    cl_abap_unit_assert=>assert_false( act = xsdbool( lv_hidden CS `system log` )
                                       msg = `nothing is logged - the sentence must not point at a log` ).
    cl_abap_unit_assert=>assert_false( act = xsdbool( lv_hidden CS `CX_SY_CREATE_OBJECT_ERROR` )
                                       msg = `the hidden detail must not leak into the sentence` ).

  ENDMETHOD.

  METHOD test_popup_user_exit_row.

    " without an exit the row used to be an empty Text - read as a value that
    " failed to load. It says that the shipped defaults run instead
    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    lo_handler = NEW #( val = `` ).
    DATA(lo_app) = z2ui5_cl_ui5_app_start=>factory( ).
    lo_app->client = NEW z2ui5_cl_ui5_client( lo_handler->mo_action ).

    DATA(lv_exp) = z2ui5_cl_ui5_user_exit=>get_user_exit_class( ).
    IF lv_exp IS INITIAL.
      lv_exp = `none (shipped defaults)`.
    ENDIF.

    lo_app->render_system_popup( ).

    DATA lv_xml TYPE string.
    LOOP AT lo_handler->mo_action->ms_next-t_action_front INTO DATA(ls_action).
      lv_xml = lv_xml && ls_action-xml.
    ENDLOOP.
    cl_abap_unit_assert=>assert_true( act = xsdbool( lv_xml CS |text="User Exit"| )
                                      msg = lv_xml ).
    cl_abap_unit_assert=>assert_true( act = xsdbool( lv_xml CS |text="{ lv_exp }"| )
                                      msg = lv_xml ).

  ENDMETHOD.

  METHOD test_link_href_literal.

    " the sample links carry the page's own query and hash, and a browser
    " leaves { and } in them unencoded - written as a literal, not as a
    " binding UI5 would parse (and fail on) when it builds the start page
    DATA(lo_app) = z2ui5_cl_ui5_app_start=>factory( ).
    DATA(lo_form) = z2ui5_cl_ui5_view_builder=>factory( ).

    lo_app->render_icon_row( form = lo_form
                             icon = `sap-icon://product`
                             text = `samples`
                             href = `https://sys/z2ui5?x={/A}` ).

    DATA(lv_xml) = lo_form->stringify( ).
    cl_abap_unit_assert=>assert_true( act = xsdbool( lv_xml CS `\{/A\}` )
                                      msg = lv_xml ).

  ENDMETHOD.

  METHOD test_link_enabled.

    " link_enabled is the plain model value the step-5 link binds to. It must
    " stay the exact inverse of class_editable, so the link is only clickable
    " after a successful check.
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
