CLASS z2ui5_cl_app_demo_08 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    DATA check_initialized TYPE abap_bool.
    DATA json TYPE string.
    DATA tabname TYPE string.
    DATA input TYPE string.
    DATA key_type TYPE string.

ENDCLASS.

CLASS z2ui5_cl_app_demo_08 IMPLEMENTATION.

  METHOD z2ui5_if_app~on_event.

    IF check_initialized = abap_false.
      check_initialized = abap_true.
      tabname = 'I_Language'.
      key_type = client->cs-code_editor-type-json.
    ENDIF.

    CASE client->event( )->get_id( ).

      WHEN 'BTN_BACK'.
        client->controller( )->nav_to_app_called( ).

      WHEN 'BUTTON_UPLOAD'.

        DATA lr_data_in TYPE REF TO data.
        CREATE DATA lr_data_in TYPE STANDARD TABLE OF (tabname).
        _=>trans_json_2_data(
          EXPORTING
            iv_json   = input
          IMPORTING
           ev_result = lr_data_in
        ).

        "save routine here, modify or bapi

      WHEN 'BUTTON_DOWNLOAD'.

        DATA lr_data TYPE REF TO data.
        CREATE DATA lr_data TYPE STANDARD TABLE OF (tabname).

        SELECT FROM (tabname)
         FIELDS *
         INTO CORRESPONDING FIELDS OF TABLE @lr_data->*
         UP TO 5 ROWS.

        input = _=>trans_data_2_json( lr_data->* ).
    ENDCASE.

    input = escape( format = cl_abap_format=>e_json_string val = input ).
  ENDMETHOD.

  METHOD z2ui5_if_app~set_view.

    view->factory_selscreen_page( event_nav_back_id = 'BTN_BACK' title = 'ABAP2UI5 Demo - Table Maintenance'
         )->begin_of_block( 'Selection-Screen'
            )->begin_of_group( 'Info'
                 )->label( 'tablename'
                 )->input( tabname
                 )->label('transfer'
                 )->button( text = 'Download' on_press_id = 'BUTTON_DOWNLOAD'
                 )->button( text = 'Upload' on_press_id = 'BUTTON_UPLOAD'
             )->end_of_group(
             )->end_of_block(
             )->begin_of_block( 'Table Edit:'
                )->code_editor( value = input type = key_type
    ).

  ENDMETHOD.

ENDCLASS.
