CLASS ltcl_test_action_front DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    DATA mo_cut    TYPE REF TO z2ui5_cl_core_action_front.
    DATA mo_action TYPE REF TO z2ui5_cl_core_action.

    METHODS setup.

    METHODS test_toast_plain          FOR TESTING RAISING cx_static_check.
    METHODS test_toast_options        FOR TESTING RAISING cx_static_check.
    METHODS test_toast_duration_junk  FOR TESTING RAISING cx_static_check.
    METHODS test_toast_opt_out        FOR TESTING RAISING cx_static_check.
    METHODS test_box_default_type     FOR TESTING RAISING cx_static_check.
    METHODS test_box_explicit_type    FOR TESTING RAISING cx_static_check.
    METHODS test_box_unknown_type     FOR TESTING RAISING cx_static_check.
    METHODS test_box_icon_none        FOR TESTING RAISING cx_static_check.
    METHODS test_box_actions          FOR TESTING RAISING cx_static_check.
    METHODS test_box_msg_table_empty  FOR TESTING RAISING cx_static_check.

    METHODS queued
      RETURNING
        VALUE(result) TYPE string
      RAISING
        z2ui5_cx_ajson_error.
ENDCLASS.


CLASS ltcl_test_action_front IMPLEMENTATION.

  METHOD setup.

    DATA lo_http TYPE REF TO z2ui5_cl_core_handler.
    lo_http = NEW #( val = `` ).
    mo_action = NEW #( val = lo_http ).
    mo_cut = NEW #( mo_action ).

  ENDMETHOD.

  METHOD queued.

    " the APP-phase action the call queued - there is exactly one per test,
    " built as its JSON array and stringified here only to assert on it
    DATA(ls_action) = VALUE #( mo_action->ms_next-s_action-t_custom[ 1 ] OPTIONAL ).
    IF ls_action-o_json IS BOUND.
      result = ls_action-o_json->stringify( ).
    ENDIF.

  ENDMETHOD.

  METHOD test_toast_plain.

    " nothing but the text: the options object stays empty, so UI5 applies
    " every one of its own defaults
    mo_cut->msg_toast( `Saved` ).

    cl_abap_unit_assert=>assert_equals( exp = `["CONTROL_GLOBAL","MESSAGE_TOAST","show","Saved"]`
                                        act = queued( ) ).

  ENDMETHOD.

  METHOD test_toast_options.

    " class is no MessageToast option - it rides along and the frontend puts
    " it on the toast's DOM node
    mo_cut->msg_toast( text                           = `Saved`
                                             duration = `250`
                                             my       = `center center`
                                             class    = `myCls` ).

    cl_abap_unit_assert=>assert_equals( exp = `["CONTROL_GLOBAL","MESSAGE_TOAST","show","Saved",{"class":"myCls","duration":250,"my":"center center"}]`
                                        act = queued( ) ).

  ENDMETHOD.

  METHOD test_toast_duration_junk.

    " a non-numeric duration is dropped rather than converted, so it can
    " never reach MessageToast as NaN
    mo_cut->msg_toast( text                           = `Saved`
                                             duration = `abc` ).

    cl_abap_unit_assert=>assert_equals( exp = `["CONTROL_GLOBAL","MESSAGE_TOAST","show","Saved"]`
                                        act = queued( ) ).

  ENDMETHOD.

  METHOD test_toast_opt_out.

    " abap_true is UI5's own default for both, so only the opt-out travels
    mo_cut->msg_toast( text                            = `Saved`
                                             autoclose = abap_false ).

    cl_abap_unit_assert=>assert_equals( exp = `["CONTROL_GLOBAL","MESSAGE_TOAST","show","Saved",{"autoClose":false}]`
                                        act = queued( ) ).

  ENDMETHOD.

  METHOD test_box_default_type.

    " the default type `information` is no MessageBox display method - it maps
    " to show( ) with the Information title
    mo_cut->msg_box( `Hello` ).

    cl_abap_unit_assert=>assert_equals( exp = `["CONTROL_GLOBAL","MESSAGE_BOX","show","Hello",{"title":"Information"}]`
                                        act = queued( ) ).

  ENDMETHOD.

  METHOD test_box_explicit_type.

    mo_cut->msg_box( text                          = `Delete?`
                                           type    = `Confirm`
                                           onclose = `ANSWERED` ).

    cl_abap_unit_assert=>assert_equals( exp = `["CONTROL_GLOBAL","MESSAGE_BOX","confirm","Delete?",{"onClose":"ANSWERED"}]`
                                        act = queued( ) ).

  ENDMETHOD.

  METHOD test_box_unknown_type.

    " a type that is no display method would be rejected by the whitelist on
    " the frontend, so a requested box falls back to show( ) instead of
    " disappearing
    mo_cut->msg_box( text                       = `Boom`
                                           type = `garbage` ).

    cl_abap_unit_assert=>assert_equals( exp = `["CONTROL_GLOBAL","MESSAGE_BOX","show","Boom"]`
                                        act = queued( ) ).

  ENDMETHOD.

  METHOD test_box_icon_none.

    " MessageBox.Icon.NONE would defeat the icon the chosen method sets for
    " itself, so it is dropped like an unset icon
    mo_cut->msg_box( text                       = `Boom`
                                           type = `error`
                                           icon = `NONE` ).

    cl_abap_unit_assert=>assert_equals( exp = `["CONTROL_GLOBAL","MESSAGE_BOX","error","Boom"]`
                                        act = queued( ) ).

  ENDMETHOD.

  METHOD test_box_actions.

    mo_cut->msg_box( text                          = `Delete?`
                                           type    = `confirm`
                                           actions = VALUE #( ( `OK` ) ( `CANCEL` ) ) ).

    cl_abap_unit_assert=>assert_equals( exp = `["CONTROL_GLOBAL","MESSAGE_BOX","confirm","Delete?",{"actions":["OK","CANCEL"]}]`
                                        act = queued( ) ).

  ENDMETHOD.

  METHOD test_box_msg_table_empty.

    " an empty message table has nothing worth showing - the EMPTY result is
    " what tells the caller not to queue anything at all
    TYPES: BEGIN OF ty_s_row,
             type    TYPE string,
             message TYPE string,
           END OF ty_s_row.
    DATA lt_msg TYPE STANDARD TABLE OF ty_s_row WITH EMPTY KEY.

    mo_cut->msg_box( lt_msg ).

    cl_abap_unit_assert=>assert_initial(
        mo_action->ms_next-s_action-t_custom ).

  ENDMETHOD.

ENDCLASS.
