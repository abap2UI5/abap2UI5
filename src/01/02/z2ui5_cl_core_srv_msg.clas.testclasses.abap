CLASS ltcl_test_srv_msg DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO z2ui5_cl_core_srv_msg.

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

    METHODS joined
      IMPORTING
        val           TYPE string_table
      RETURNING
        VALUE(result) TYPE string.
ENDCLASS.


CLASS ltcl_test_srv_msg IMPLEMENTATION.

  METHOD setup.

    mo_cut = NEW #( ).

  ENDMETHOD.

  METHOD joined.

    result = concat_lines_of( table = val
                              sep   = `|` ).

  ENDMETHOD.

  METHOD test_toast_plain.

    " nothing but the text: the options object stays empty, so UI5 applies
    " every one of its own defaults
    cl_abap_unit_assert=>assert_equals(
        exp = `MESSAGE_TOAST|show|Saved`
        act = joined( mo_cut->get_toast_arg( `Saved` ) ) ).

  ENDMETHOD.

  METHOD test_toast_options.

    " class is no MessageToast option - it rides along and the frontend puts
    " it on the toast's DOM node
    cl_abap_unit_assert=>assert_equals(
        exp = `MESSAGE_TOAST|show|Saved|{"class":"myCls","duration":250,"my":"center center"}`
        act = joined( mo_cut->get_toast_arg( text     = `Saved`
                                             duration = `250`
                                             my       = `center center`
                                             class    = `myCls` ) ) ).

  ENDMETHOD.

  METHOD test_toast_duration_junk.

    " a non-numeric duration is dropped rather than converted, so it can
    " never reach MessageToast as NaN
    cl_abap_unit_assert=>assert_equals(
        exp = `MESSAGE_TOAST|show|Saved`
        act = joined( mo_cut->get_toast_arg( text     = `Saved`
                                             duration = `abc` ) ) ).

  ENDMETHOD.

  METHOD test_toast_opt_out.

    " abap_true is UI5's own default for both, so only the opt-out travels
    cl_abap_unit_assert=>assert_equals(
        exp = `MESSAGE_TOAST|show|Saved|{"autoClose":false}`
        act = joined( mo_cut->get_toast_arg( text      = `Saved`
                                             autoclose = abap_false ) ) ).

  ENDMETHOD.

  METHOD test_box_default_type.

    " the default type `information` is no MessageBox display method - it maps
    " to show( ) with the Information title
    cl_abap_unit_assert=>assert_equals(
        exp = `MESSAGE_BOX|show|Hello|{"title":"Information"}`
        act = joined( mo_cut->get_box_arg( `Hello` ) ) ).

  ENDMETHOD.

  METHOD test_box_explicit_type.

    cl_abap_unit_assert=>assert_equals(
        exp = `MESSAGE_BOX|confirm|Delete?|{"onClose":"ANSWERED"}`
        act = joined( mo_cut->get_box_arg( text    = `Delete?`
                                           type    = `Confirm`
                                           onclose = `ANSWERED` ) ) ).

  ENDMETHOD.

  METHOD test_box_unknown_type.

    " a type that is no display method would be rejected by the whitelist on
    " the frontend, so a requested box falls back to show( ) instead of
    " disappearing
    cl_abap_unit_assert=>assert_equals(
        exp = `MESSAGE_BOX|show|Boom`
        act = joined( mo_cut->get_box_arg( text = `Boom`
                                           type = `garbage` ) ) ).

  ENDMETHOD.

  METHOD test_box_icon_none.

    " MessageBox.Icon.NONE would defeat the icon the chosen method sets for
    " itself, so it is dropped like an unset icon
    cl_abap_unit_assert=>assert_equals(
        exp = `MESSAGE_BOX|error|Boom`
        act = joined( mo_cut->get_box_arg( text = `Boom`
                                           type = `error`
                                           icon = `NONE` ) ) ).

  ENDMETHOD.

  METHOD test_box_actions.

    cl_abap_unit_assert=>assert_equals(
        exp = `MESSAGE_BOX|confirm|Delete?|{"actions":["OK","CANCEL"]}`
        act = joined( mo_cut->get_box_arg( text    = `Delete?`
                                           type    = `confirm`
                                           actions = VALUE #( ( `OK` ) ( `CANCEL` ) ) ) ) ).

  ENDMETHOD.

  METHOD test_box_msg_table_empty.

    " an empty message table has nothing worth showing - the EMPTY result is
    " what tells the caller not to queue anything at all
    TYPES: BEGIN OF ty_s_row,
             type    TYPE string,
             message TYPE string,
           END OF ty_s_row.
    DATA lt_msg TYPE STANDARD TABLE OF ty_s_row WITH EMPTY KEY.

    cl_abap_unit_assert=>assert_initial( mo_cut->get_box_arg( lt_msg ) ).

  ENDMETHOD.

ENDCLASS.
