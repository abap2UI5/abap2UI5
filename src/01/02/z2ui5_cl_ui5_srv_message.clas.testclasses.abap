" a plain object whose public attributes carry a message - what
" message_box_display( lo_result ) sees in an object that is neither an
" exception nor a log
CLASS ltcl_msg_carrier DEFINITION FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    " read by name through RTTI (msg_get_by_oref_attri), never statically
    DATA message TYPE string VALUE `Order 4711 saved` ##NEEDED.
    DATA type    TYPE c LENGTH 1 VALUE `S` ##NEEDED.
ENDCLASS.

CLASS ltcl_msg_carrier IMPLEMENTATION.
ENDCLASS.


CLASS ltcl_box_format DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_box_empty_skips        FOR TESTING RAISING cx_static_check.
    METHODS test_box_single             FOR TESTING RAISING cx_static_check.
    METHODS test_box_multiple           FOR TESTING RAISING cx_static_check.
    METHODS test_box_multiple_escaped   FOR TESTING RAISING cx_static_check.
    METHODS test_box_unbound_oref_skips FOR TESTING RAISING cx_static_check.
    METHODS test_box_exception_object   FOR TESTING RAISING cx_static_check.
    METHODS test_box_plain_object       FOR TESTING RAISING cx_static_check.
    METHODS test_box_no_msg_skips       FOR TESTING RAISING cx_static_check.
    METHODS test_msg_item_plain_field   FOR TESTING RAISING cx_static_check.
    METHODS test_msg_id_key_column      FOR TESTING RAISING cx_static_check.
    METHODS test_type_column_stays_data FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_box_format IMPLEMENTATION.

  METHOD test_box_empty_skips.

    " no messages means no popup at all, signalled by `skip`
    DATA lt_msg TYPE z2ui5_cl_ui5_util_context=>ty_t_msg.

    DATA ls_box TYPE z2ui5_cl_ui5_util_context=>ty_s_msg_box.
    ls_box = z2ui5_cl_ui5_srv_message=>box_format_msg( lt_msg ).

    cl_abap_unit_assert=>assert_equals( exp = abap_true act = ls_box-skip ).

  ENDMETHOD.

  METHOD test_box_single.

    " a single message renders as plain text without a details list
    DATA lt_msg TYPE z2ui5_cl_ui5_util_context=>ty_t_msg.

    DATA temp1 TYPE z2ui5_cl_ui5_util_context=>ty_t_msg.
    DATA temp2 LIKE LINE OF temp1.
    DATA ls_box TYPE z2ui5_cl_ui5_util_context=>ty_s_msg_box.
    CLEAR temp1.

    temp2-text = `boom`.
    temp2-type = `E`.
    INSERT temp2 INTO TABLE temp1.
    lt_msg = temp1.


    ls_box = z2ui5_cl_ui5_srv_message=>box_format_msg( lt_msg ).

    cl_abap_unit_assert=>assert_equals( exp = abap_false act = ls_box-skip ).
    cl_abap_unit_assert=>assert_equals( exp = `boom`
                                        act = ls_box-text ).
    cl_abap_unit_assert=>assert_equals( exp = `Error`
                                        act = ls_box-title ).
    cl_abap_unit_assert=>assert_equals( exp = `error`
                                        act = ls_box-type ).
    cl_abap_unit_assert=>assert_initial( ls_box-details ).

  ENDMETHOD.

  METHOD test_box_multiple.

    " several messages collapse into a count plus an HTML list, and the box
    " takes its severity from the most severe message, not the first
    DATA lt_msg TYPE z2ui5_cl_ui5_util_context=>ty_t_msg.

    DATA temp3 TYPE z2ui5_cl_ui5_util_context=>ty_t_msg.
    DATA temp4 LIKE LINE OF temp3.
    DATA ls_box TYPE z2ui5_cl_ui5_util_context=>ty_s_msg_box.
    DATA temp5 TYPE z2ui5_cl_ui5_util_context=>ty_t_msg.
    DATA temp6 LIKE LINE OF temp5.
    CLEAR temp3.

    temp4-text = `first`.
    temp4-type = `W`.
    INSERT temp4 INTO TABLE temp3.
    temp4-text = `second`.
    temp4-type = `E`.
    INSERT temp4 INTO TABLE temp3.
    lt_msg = temp3.


    ls_box = z2ui5_cl_ui5_srv_message=>box_format_msg( lt_msg ).

    cl_abap_unit_assert=>assert_equals( exp = abap_false act = ls_box-skip ).
    cl_abap_unit_assert=>assert_equals( exp = `Error`
                                        act = ls_box-title ).
    cl_abap_unit_assert=>assert_equals( exp = `error`
                                        act = ls_box-type ).
    cl_abap_unit_assert=>assert_equals( exp = `2 Messages found:`
                                        act = ls_box-text ).

    " a warning outranks success and information wherever it stands, and
    " between those two the first one decides

    CLEAR temp5.

    temp6-text = `a`.
    temp6-type = `S`.
    INSERT temp6 INTO TABLE temp5.
    temp6-text = `b`.
    temp6-type = `I`.
    INSERT temp6 INTO TABLE temp5.
    temp6-text = `c`.
    temp6-type = `W`.
    INSERT temp6 INTO TABLE temp5.
    lt_msg = temp5.
    cl_abap_unit_assert=>assert_equals( exp = `warning`
                                        act = z2ui5_cl_ui5_srv_message=>box_format_msg( lt_msg )-type ).
    DELETE lt_msg INDEX 3.
    cl_abap_unit_assert=>assert_equals( exp = `success`
                                        act = z2ui5_cl_ui5_srv_message=>box_format_msg( lt_msg )-type ).
    cl_abap_unit_assert=>assert_equals(
        exp = `<ul><li>first</li><li>second</li></ul>`
        act = ls_box-details ).

  ENDMETHOD.

  METHOD test_box_multiple_escaped.

    " the texts are DATA inside the HTML list: a token in angle brackets is
    " shown as written instead of being dropped by the frontend sanitizer
    " as an unknown element - every sibling renderer escapes, this did not
    DATA lt_msg TYPE z2ui5_cl_ui5_util_context=>ty_t_msg.

    DATA temp7 TYPE z2ui5_cl_ui5_util_context=>ty_t_msg.
    DATA temp8 LIKE LINE OF temp7.
    DATA ls_box TYPE z2ui5_cl_ui5_util_context=>ty_s_msg_box.
    CLEAR temp7.

    temp8-text = `Enter a value for <MATNR>`.
    temp8-type = `E`.
    INSERT temp8 INTO TABLE temp7.
    temp8-text = `a & b`.
    temp8-type = `E`.
    INSERT temp8 INTO TABLE temp7.
    lt_msg = temp7.


    ls_box = z2ui5_cl_ui5_srv_message=>box_format_msg( lt_msg ).

    cl_abap_unit_assert=>assert_equals(
        exp = `<ul><li>Enter a value for &lt;MATNR&gt;</li><li>a &amp; b</li></ul>`
        act = ls_box-details ).

  ENDMETHOD.

  METHOD test_box_unbound_oref_skips.

    " an unbound object reference carries no message: `skip`, like a
    " business table - it used to fall through msg_get_by_oref's handlers
    " into a describe on the null reference and end in a 500
    DATA lo_unbound TYPE REF TO object.

    DATA ls_box TYPE z2ui5_cl_ui5_util_context=>ty_s_msg_box.
    ls_box = z2ui5_cl_ui5_srv_message=>box_format_msg( lo_unbound ).

    cl_abap_unit_assert=>assert_equals( exp = abap_true act = ls_box-skip ).

  ENDMETHOD.

  METHOD test_box_exception_object.

    " an exception is its text, an error by default
    DATA lx TYPE REF TO z2ui5_cx_ui5_util_error.
    DATA ls_box TYPE z2ui5_cl_ui5_util_context=>ty_s_msg_box.
    DATA temp1 TYPE xsdboolean.
    TRY.
        RAISE EXCEPTION TYPE z2ui5_cx_ui5_util_error
          EXPORTING
            val = `Posting failed`.
      CATCH z2ui5_cx_ui5_util_error INTO lx ##NO_HANDLER.
    ENDTRY.


    ls_box = z2ui5_cl_ui5_srv_message=>box_format_msg( lx ).

    cl_abap_unit_assert=>assert_equals( exp = abap_false act = ls_box-skip ).
    cl_abap_unit_assert=>assert_equals( exp = `Error`
                                        act = ls_box-title ).

    temp1 = boolc( ls_box-text CS `Posting failed` ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp1 ).

  ENDMETHOD.

  METHOD test_box_plain_object.

    " neither exception nor log: the public attributes that carry a message
    " part are mapped - the fourth shape of msg_get_by_oref
    DATA lo_carrier TYPE REF TO ltcl_msg_carrier.
    DATA ls_box TYPE z2ui5_cl_ui5_util_context=>ty_s_msg_box.
    CREATE OBJECT lo_carrier TYPE ltcl_msg_carrier.


    ls_box = z2ui5_cl_ui5_srv_message=>box_format_msg( lo_carrier ).

    cl_abap_unit_assert=>assert_equals( exp = abap_false act = ls_box-skip ).
    cl_abap_unit_assert=>assert_equals( exp = `Order 4711 saved`
                                        act = ls_box-text ).
    cl_abap_unit_assert=>assert_equals( exp = `Success`
                                        act = ls_box-title ).

  ENDMETHOD.

  METHOD test_box_no_msg_skips.

    " a business table has none of the message components, so the message
    " formatter answers `skip` - it used to answer with one blank message
    " per row, which is what put an empty popup on the screen. `skip` is
    " what hands the data to ui5_data_box_format( )
    TYPES:
      BEGIN OF ty_s_row,
        carrid TYPE string,
        seats  TYPE i,
      END OF ty_s_row.
    TYPES temp1 TYPE STANDARD TABLE OF ty_s_row WITH DEFAULT KEY.
DATA lt_row TYPE temp1.

    DATA temp9 LIKE lt_row.
    DATA temp10 LIKE LINE OF temp9.
    DATA ls_box TYPE z2ui5_cl_ui5_util_context=>ty_s_msg_box.
    CLEAR temp9.

    temp10-carrid = `LH`.
    temp10-seats = 12.
    INSERT temp10 INTO TABLE temp9.
    lt_row = temp9.


    ls_box = z2ui5_cl_ui5_srv_message=>box_format_msg( lt_row ).

    cl_abap_unit_assert=>assert_equals( exp = abap_true act = ls_box-skip ).

  ENDMETHOD.

  METHOD test_msg_item_plain_field.

    " an ITEM that is a plain field (a position number) is no envelope:
    " it used to become the whole message, text `0010`, and the structure
    " was never handed to the data renderer
    TYPES:
      BEGIN OF ty_s_row,
        name TYPE string,
        item TYPE c LENGTH 4,
      END OF ty_s_row.

    DATA temp11 TYPE ty_s_row.
    DATA ls_row LIKE temp11.
    DATA ls_box TYPE z2ui5_cl_ui5_util_context=>ty_s_msg_box.
    CLEAR temp11.
    temp11-name = `Ada`.
    temp11-item = `0010`.

    ls_row = temp11.


    ls_box = z2ui5_cl_ui5_srv_message=>box_format_msg( ls_row ).

    cl_abap_unit_assert=>assert_equals( exp = abap_true act = ls_box-skip ).

  ENDMETHOD.

  METHOD test_msg_id_key_column.

    " an ID column without a message NUMBER is a key, not a T100 message:
    " a table of business rows is data, and the box falls back to the data
    " renderer - it showed `2 Messages found` with I:0001: and I:0002:
    TYPES:
      BEGIN OF ty_s_row,
        id   TYPE c LENGTH 4,
        name TYPE string,
      END OF ty_s_row.
    TYPES ty_t_row TYPE STANDARD TABLE OF ty_s_row WITH DEFAULT KEY.

    DATA temp12 TYPE ty_t_row.
    DATA temp13 LIKE LINE OF temp12.
    DATA lt_rows LIKE temp12.
    CLEAR temp12.

    temp13-id = `0001`.
    temp13-name = `Ada`.
    INSERT temp13 INTO TABLE temp12.
    temp13-id = `0002`.
    temp13-name = `Alan`.
    INSERT temp13 INTO TABLE temp12.

    lt_rows = temp12.

    cl_abap_unit_assert=>assert_equals( exp = abap_true act = z2ui5_cl_ui5_srv_message=>box_format_msg( lt_rows )-skip ).

  ENDMETHOD.

  METHOD test_type_column_stays_data.

    " a business row with a column called TYPE that holds `E` looks like an
    " error without a text - and is data. It names no message (no T100 key,
    " no RAP row), so it gets no standard text and the caller renders it
    TYPES:
      BEGIN OF ty_s_row,
        type TYPE c LENGTH 1,
        name TYPE string,
      END OF ty_s_row.
    TYPES temp2 TYPE STANDARD TABLE OF ty_s_row WITH DEFAULT KEY.
DATA lt_row TYPE temp2.

    DATA temp14 LIKE lt_row.
    DATA temp15 LIKE LINE OF temp14.
    CLEAR temp14.

    temp15-type = `E`.
    temp15-name = `Ada`.
    INSERT temp15 INTO TABLE temp14.
    lt_row = temp14.

    cl_abap_unit_assert=>assert_equals( exp = abap_true act = z2ui5_cl_ui5_srv_message=>box_format_msg( lt_row )-skip ).

  ENDMETHOD.

ENDCLASS.


CLASS ltcl_text_default DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_t100_key       FOR TESTING RAISING cx_static_check.
    METHODS test_rap_row        FOR TESTING RAISING cx_static_check.
    METHODS test_type_alone     FOR TESTING RAISING cx_static_check.
    METHODS test_not_an_error   FOR TESTING RAISING cx_static_check.
    METHODS test_abort_and_exit FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_text_default IMPLEMENTATION.

  METHOD test_t100_key.

    " class and number name the message, so the standard text carries
    " them - whoever reads the box can look the message up
    DATA temp16 TYPE z2ui5_cl_ui5_util_context=>ty_s_msg.
    CLEAR temp16.
    temp16-type = `E`.
    temp16-id = `zfoo`.
    temp16-no = `042`.
    cl_abap_unit_assert=>assert_equals(
        exp = `Error ZFOO 042 (no message text available)`
        act = z2ui5_cl_ui5_srv_message=>text_default( temp16 ) ).

  ENDMETHOD.

  METHOD test_rap_row.

    " t_meta is what msg_get_rap_row fills - the entry comes from a RAP
    " response row, which is a message whatever else it lacks
    DATA temp17 TYPE z2ui5_cl_ui5_util_context=>ty_s_msg.
    DATA temp1 TYPE z2ui5_cl_ui5_util_context=>ty_t_name_value.
    DATA temp2 LIKE LINE OF temp1.
    CLEAR temp17.
    temp17-type = `E`.

    CLEAR temp1.

    temp2-n = `entity`.
    temp2-v = `TRAVEL`.
    INSERT temp2 INTO TABLE temp1.
    temp17-t_meta = temp1.
    cl_abap_unit_assert=>assert_equals(
        exp = z2ui5_cl_ui5_srv_message=>cs_text-error_no_text
        act = z2ui5_cl_ui5_srv_message=>text_default(
                  temp17 ) ).

  ENDMETHOD.

  METHOD test_type_alone.

    " a type and nothing else is not enough - see test_type_column_stays_data
    DATA temp18 TYPE z2ui5_cl_ui5_util_context=>ty_s_msg.
    CLEAR temp18.
    temp18-type = `E`.
    cl_abap_unit_assert=>assert_initial(
        z2ui5_cl_ui5_srv_message=>text_default( temp18 ) ).

  ENDMETHOD.

  METHOD test_not_an_error.

    " only an error gets a standard text: a warning, a success or an
    " information without one is dropped like every other empty entry
    DATA temp19 TYPE z2ui5_cl_ui5_util_context=>ty_s_msg.
    DATA temp20 TYPE z2ui5_cl_ui5_util_context=>ty_s_msg.
    DATA temp21 TYPE z2ui5_cl_ui5_util_context=>ty_s_msg.
    CLEAR temp19.
    temp19-type = `W`.
    temp19-id = `ZFOO`.
    temp19-no = `042`.
    cl_abap_unit_assert=>assert_initial(
        z2ui5_cl_ui5_srv_message=>text_default( temp19 ) ).

    CLEAR temp20.
    temp20-type = `S`.
    temp20-id = `ZFOO`.
    temp20-no = `042`.
    cl_abap_unit_assert=>assert_initial(
        z2ui5_cl_ui5_srv_message=>text_default( temp20 ) ).

    CLEAR temp21.
    temp21-id = `ZFOO`.
    temp21-no = `042`.
    cl_abap_unit_assert=>assert_initial(
        z2ui5_cl_ui5_srv_message=>text_default( temp21 ) ).

  ENDMETHOD.

  METHOD test_abort_and_exit.

    " A and X are errors too - ui5_get_msg_type decides, not a literal here
    DATA temp22 TYPE z2ui5_cl_ui5_util_context=>ty_s_msg.
    DATA temp23 TYPE z2ui5_cl_ui5_util_context=>ty_s_msg.
    CLEAR temp22.
    temp22-type = `A`.
    temp22-id = `ZFOO`.
    temp22-no = `001`.
    cl_abap_unit_assert=>assert_not_initial(
        z2ui5_cl_ui5_srv_message=>text_default( temp22 ) ).

    CLEAR temp23.
    temp23-type = `X`.
    temp23-id = `ZFOO`.
    temp23-no = `001`.
    cl_abap_unit_assert=>assert_not_initial(
        z2ui5_cl_ui5_srv_message=>text_default( temp23 ) ).

  ENDMETHOD.

ENDCLASS.


CLASS ltcl_box_resolve DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_s_ret,
        type    TYPE c LENGTH 1,
        message TYPE string,
      END OF ty_s_ret.
    TYPES ty_t_ret TYPE STANDARD TABLE OF ty_s_ret WITH DEFAULT KEY.

    METHODS test_empty_error_std_text  FOR TESTING RAISING cx_static_check.
    METHODS test_empty_error_any_case  FOR TESTING RAISING cx_static_check.
    METHODS test_empty_error_keeps_arg FOR TESTING RAISING cx_static_check.
    METHODS test_empty_other_type_skip FOR TESTING RAISING cx_static_check.
    METHODS test_unbound_ref_error     FOR TESTING RAISING cx_static_check.
    METHODS test_messages_win          FOR TESTING RAISING cx_static_check.
    METHODS test_text_as_written       FOR TESTING RAISING cx_static_check.
    METHODS test_unknown_type_shows    FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_box_resolve IMPLEMENTATION.

  METHOD test_empty_error_std_text.

    " the EML statement failed and REPORTED came back empty: the app asks
    " for an error box, and gets one that says so instead of no box at all
    DATA lt_ret TYPE ty_t_ret.

    DATA ls_box TYPE z2ui5_cl_ui5_util_context=>ty_s_msg_box.
    ls_box = z2ui5_cl_ui5_srv_message=>box_resolve( text    = lt_ret
                                                          type    = `error`
                                                          title   = ``
                                                          details = `` ).

    cl_abap_unit_assert=>assert_equals( exp = abap_false act = ls_box-skip ).
    cl_abap_unit_assert=>assert_equals( exp = z2ui5_cl_ui5_srv_message=>cs_text-failed
                                        act = ls_box-text ).
    cl_abap_unit_assert=>assert_equals( exp = `error`
                                        act = ls_box-type ).

  ENDMETHOD.

  METHOD test_empty_error_any_case.

    " the type arrives however the app spelled it
    DATA lt_ret TYPE ty_t_ret.

    DATA ls_box TYPE z2ui5_cl_ui5_util_context=>ty_s_msg_box.
    ls_box = z2ui5_cl_ui5_srv_message=>box_resolve( text    = lt_ret
                                                          type    = `Error`
                                                          title   = ``
                                                          details = `` ).

    cl_abap_unit_assert=>assert_equals( exp = z2ui5_cl_ui5_srv_message=>cs_text-failed
                                        act = ls_box-text ).
    cl_abap_unit_assert=>assert_equals( exp = `error`
                                        act = ls_box-type ).

  ENDMETHOD.

  METHOD test_empty_error_keeps_arg.

    " title and details are the app's, also on the standard text
    DATA lt_ret TYPE ty_t_ret.

    DATA ls_box TYPE z2ui5_cl_ui5_util_context=>ty_s_msg_box.
    ls_box = z2ui5_cl_ui5_srv_message=>box_resolve( text    = lt_ret
                                                          type    = `error`
                                                          title   = `Save`
                                                          details = `Travel 4711` ).

    cl_abap_unit_assert=>assert_equals( exp = `Save`
                                        act = ls_box-title ).
    cl_abap_unit_assert=>assert_equals( exp = `Travel 4711`
                                        act = ls_box-details ).

  ENDMETHOD.

  METHOD test_empty_other_type_skip.

    " every type but error stays silent over empty data: a BAPI return
    " table without messages is the normal case, not an event
    DATA lt_ret TYPE ty_t_ret.

    cl_abap_unit_assert=>assert_equals( exp = abap_true act =
        z2ui5_cl_ui5_srv_message=>box_resolve( text    = lt_ret
                                               type    = `information`
                                               title   = ``
                                               details = `` )-skip ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act =
        z2ui5_cl_ui5_srv_message=>box_resolve( text    = lt_ret
                                               type    = `warning`
                                               title   = ``
                                               details = `` )-skip ).

  ENDMETHOD.

  METHOD test_unbound_ref_error.

    " an exception reference that was never filled is nothing to show
    " either - and an error box all the same when the app asks for one
    DATA lx TYPE REF TO cx_root.

    DATA ls_box TYPE z2ui5_cl_ui5_util_context=>ty_s_msg_box.
    ls_box = z2ui5_cl_ui5_srv_message=>box_resolve( text    = lx
                                                          type    = `error`
                                                          title   = ``
                                                          details = `` ).

    cl_abap_unit_assert=>assert_equals( exp = z2ui5_cl_ui5_srv_message=>cs_text-failed
                                        act = ls_box-text ).

  ENDMETHOD.

  METHOD test_messages_win.

    " a message decides text, type and title itself - the type the app
    " passed is for a value that carries none
    DATA temp24 TYPE ty_t_ret.
    DATA temp25 LIKE LINE OF temp24.
    DATA lt_ret LIKE temp24.
    DATA ls_box TYPE z2ui5_cl_ui5_util_context=>ty_s_msg_box.
    CLEAR temp24.

    temp25-type = `W`.
    temp25-message = `Check the dates`.
    INSERT temp25 INTO TABLE temp24.

    lt_ret = temp24.


    ls_box = z2ui5_cl_ui5_srv_message=>box_resolve( text    = lt_ret
                                                          type    = `error`
                                                          title   = ``
                                                          details = `` ).

    cl_abap_unit_assert=>assert_equals( exp = `Check the dates`
                                        act = ls_box-text ).
    cl_abap_unit_assert=>assert_equals( exp = `warning`
                                        act = ls_box-type ).
    cl_abap_unit_assert=>assert_equals( exp = `Warning`
                                        act = ls_box-title ).

  ENDMETHOD.

  METHOD test_text_as_written.

    " a character value is its own text; information is a plain show( )
    " with the title the type used to bring
    DATA ls_box TYPE z2ui5_cl_ui5_util_context=>ty_s_msg_box.
    ls_box = z2ui5_cl_ui5_srv_message=>box_resolve( text    = `Hello`
                                                          type    = `Information`
                                                          title   = ``
                                                          details = `` ).

    cl_abap_unit_assert=>assert_equals( exp = `Hello`
                                        act = ls_box-text ).
    cl_abap_unit_assert=>assert_equals( exp = `show`
                                        act = ls_box-type ).
    cl_abap_unit_assert=>assert_equals( exp = `Information`
                                        act = ls_box-title ).

  ENDMETHOD.

  METHOD test_unknown_type_shows.

    " a type that is no MessageBox display method would be rejected by the
    " whitelisted call - the box falls back to show( ) instead of vanishing
    DATA ls_box TYPE z2ui5_cl_ui5_util_context=>ty_s_msg_box.
    ls_box = z2ui5_cl_ui5_srv_message=>box_resolve( text    = `Hello`
                                                          type    = `fancy`
                                                          title   = ``
                                                          details = `` ).

    cl_abap_unit_assert=>assert_equals( exp = `show`
                                        act = ls_box-type ).

  ENDMETHOD.

ENDCLASS.
