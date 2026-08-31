CLASS ltcl_test_action_front DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    DATA mo_cut    TYPE REF TO z2ui5_cl_ui5_frontend.
    DATA mo_action TYPE REF TO z2ui5_cl_ui5_action.

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
    METHODS test_main_drops_teardowns FOR TESTING RAISING cx_static_check.
    METHODS test_main_keeps_displays  FOR TESTING RAISING cx_static_check.
    METHODS test_teardowns_no_main    FOR TESTING RAISING cx_static_check.

    METHODS queued
      RETURNING
        VALUE(result) TYPE string
      RAISING
        z2ui5_cx_ajson_error.

    "! the SYSTEM actions the serialization produced, pipe-joined
    METHODS serialized
      RETURNING
        VALUE(result) TYPE string
      RAISING
        z2ui5_cx_ajson_error.
ENDCLASS.


CLASS ltcl_test_action_front IMPLEMENTATION.

  METHOD setup.

    DATA lo_http TYPE REF TO z2ui5_cl_ui5_handler.
    CREATE OBJECT lo_http EXPORTING val = ``.
    CREATE OBJECT mo_action EXPORTING val = lo_http.
    CREATE OBJECT mo_cut EXPORTING ACTION = mo_action.

  ENDMETHOD.

  METHOD queued.

    " the APP-phase action the call queued - there is exactly one per test,
    " built as its JSON array and stringified here only to assert on it
    DATA temp1 TYPE z2ui5_if_ui5_types=>ty_s_queued_action.
    DATA temp2 TYPE z2ui5_if_ui5_types=>ty_s_queued_action.
    DATA ls_action LIKE temp1.
    CLEAR temp1.

    READ TABLE mo_action->ms_next-s_action-t_custom INTO temp2 INDEX 1.
    IF sy-subrc = 0.
      temp1 = temp2.
    ENDIF.

    ls_action = temp1.
    IF ls_action-o_json IS BOUND.
      result = ls_action-o_json->stringify( ).
    ENDIF.

  ENDMETHOD.

  METHOD test_toast_plain.

    " nothing but the text: the options object stays empty, so UI5 applies
    " every one of its own defaults
    mo_cut->msg_toast( `Saved` ).

    cl_abap_unit_assert=>assert_equals( exp = `["MESSAGE_TOAST","show","Saved"]`
                                        act = queued( ) ).

  ENDMETHOD.

  METHOD test_toast_options.

    " class is no MessageToast option - it rides along and the frontend puts
    " it on the toast's DOM node
    mo_cut->msg_toast( text                           = `Saved`
                                             duration = `250`
                                             my       = `center center`
                                             class    = `myCls` ).

    cl_abap_unit_assert=>assert_equals( exp = `["MESSAGE_TOAST","show","Saved",{"class":"myCls","duration":250,"my":"center center"}]`
                                        act = queued( ) ).

  ENDMETHOD.

  METHOD test_toast_duration_junk.

    " a non-numeric duration is dropped rather than converted, so it can
    " never reach MessageToast as NaN
    mo_cut->msg_toast( text                           = `Saved`
                                             duration = `abc` ).

    cl_abap_unit_assert=>assert_equals( exp = `["MESSAGE_TOAST","show","Saved"]`
                                        act = queued( ) ).

  ENDMETHOD.

  METHOD test_toast_opt_out.

    " abap_true is UI5's own default for both, so only the opt-out travels
    mo_cut->msg_toast( text                            = `Saved`
                                             autoclose = abap_false ).

    cl_abap_unit_assert=>assert_equals( exp = `["MESSAGE_TOAST","show","Saved",{"autoClose":false}]`
                                        act = queued( ) ).

  ENDMETHOD.

  METHOD test_box_default_type.

    " the default type `information` is no MessageBox display method - it maps
    " to show( ) with the Information title
    mo_cut->msg_box( `Hello` ).

    cl_abap_unit_assert=>assert_equals( exp = `["MESSAGE_BOX","show","Hello",{"title":"Information"}]`
                                        act = queued( ) ).

  ENDMETHOD.

  METHOD test_box_explicit_type.

    mo_cut->msg_box( text                          = `Delete?`
                                           type    = `Confirm`
                                           onclose = `ANSWERED` ).

    cl_abap_unit_assert=>assert_equals( exp = `["MESSAGE_BOX","confirm","Delete?",{"onClose":"ANSWERED"}]`
                                        act = queued( ) ).

  ENDMETHOD.

  METHOD test_box_unknown_type.

    " a type that is no display method would be rejected by the whitelist on
    " the frontend, so a requested box falls back to show( ) instead of
    " disappearing
    mo_cut->msg_box( text                       = `Boom`
                                           type = `garbage` ).

    cl_abap_unit_assert=>assert_equals( exp = `["MESSAGE_BOX","show","Boom"]`
                                        act = queued( ) ).

  ENDMETHOD.

  METHOD test_box_icon_none.

    " MessageBox.Icon.NONE would defeat the icon the chosen method sets for
    " itself, so it is dropped like an unset icon
    mo_cut->msg_box( text                       = `Boom`
                                           type = `error`
                                           icon = `NONE` ).

    cl_abap_unit_assert=>assert_equals( exp = `["MESSAGE_BOX","error","Boom"]`
                                        act = queued( ) ).

  ENDMETHOD.

  METHOD test_box_actions.

    DATA temp3 TYPE string_table.
    CLEAR temp3.
    INSERT `OK` INTO TABLE temp3.
    INSERT `CANCEL` INTO TABLE temp3.
    mo_cut->msg_box( text                          = `Delete?`
                                           type    = `confirm`
                                           actions = temp3 ).

    cl_abap_unit_assert=>assert_equals( exp = `["MESSAGE_BOX","confirm","Delete?",{"actions":["OK","CANCEL"]}]`
                                        act = queued( ) ).

  ENDMETHOD.

  METHOD test_box_msg_table_empty.

    " an empty message table has nothing worth showing - the EMPTY result is
    " what tells the caller not to queue anything at all
    TYPES: BEGIN OF ty_s_row,
             type    TYPE string,
             message TYPE string,
           END OF ty_s_row.
    DATA lt_msg TYPE STANDARD TABLE OF ty_s_row WITH DEFAULT KEY.

    mo_cut->msg_box( lt_msg ).

    cl_abap_unit_assert=>assert_initial(
        mo_action->ms_next-s_action-t_custom ).

  ENDMETHOD.

  METHOD serialized.
    DATA ls_action LIKE LINE OF mo_action->ms_next-s_action-t_system.

    mo_cut->slots_serialize( ).


    LOOP AT mo_action->ms_next-s_action-t_system INTO ls_action.
      IF result IS NOT INITIAL.
        result = result && `|`.
      ENDIF.
      result = result && ls_action-o_json->stringify( ).
    ENDLOOP.

  ENDMETHOD.

  METHOD test_main_drops_teardowns.

    " a new MAIN view takes the standalone slots down on the frontend
    " (actions/Slots), so their teardown is not sent next to it - whoever
    " queued it: the app itself here, prepare_app_stack on an app switch
    mo_cut->slot_destroy( z2ui5_if_client=>cs_view-popup ).
    mo_cut->slot_destroy( z2ui5_if_client=>cs_view-popover ).
    mo_cut->slot_display( slot = z2ui5_if_client=>cs_view-main
                          xml  = `<View/>` ).

    cl_abap_unit_assert=>assert_equals(
        exp = `["VIEW_SLOTS","display","MAIN","<View/>"]`
        act = serialized( ) ).

  ENDMETHOD.

  METHOD test_main_keeps_displays.

    " only the TEARDOWNS are derivable from the MAIN display - a popup this
    " roundtrip opens still travels, and behind MAIN, so it opens on the new
    " view instead of being torn down with the old one
    mo_cut->slot_display( slot = z2ui5_if_client=>cs_view-popup
                          xml  = `<Dialog/>` ).
    mo_cut->slot_display( slot = z2ui5_if_client=>cs_view-main
                          xml  = `<View/>` ).

    cl_abap_unit_assert=>assert_equals(
        exp = `["VIEW_SLOTS","display","MAIN","<View/>"]|["VIEW_SLOTS","display","POPUP","<Dialog/>"]`
        act = serialized( ) ).

  ENDMETHOD.

  METHOD test_teardowns_no_main.

    " without a MAIN display nothing tears the standalone slots down on the
    " frontend, so the teardown has to travel
    mo_cut->slot_destroy( z2ui5_if_client=>cs_view-popup ).
    mo_cut->slot_destroy( z2ui5_if_client=>cs_view-popover ).

    cl_abap_unit_assert=>assert_equals(
        exp = `["VIEW_SLOTS","destroy","POPUP"]|["VIEW_SLOTS","destroy","POPOVER"]`
        act = serialized( ) ).

  ENDMETHOD.

ENDCLASS.
