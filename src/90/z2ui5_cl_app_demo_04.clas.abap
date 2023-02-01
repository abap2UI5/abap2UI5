CLASS z2ui5_cl_app_demo_04 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.
    CLASS-METHODS create
      IMPORTING
        url      TYPE string
        editable TYPE abap_bool
      RETURNING
        value(r_result) TYPE REF TO z2ui5_cl_app_demo_04.

    DATA url_input TYPE string.
    DATA check_initialized TYPE abap_bool.
    data editable type abap_bool.

ENDCLASS.

CLASS z2ui5_cl_app_demo_04 IMPLEMENTATION.

  METHOD create.

    r_result = NEW #( ).

    r_result->url_input = url.
    r_result->editable = editable.

  ENDMETHOD.

  METHOD z2ui5_if_app~on_event.

    IF check_initialized = abap_false.
      check_initialized = abap_true.
      url_input = cond #( when url_input = '' then _=>get_server_info(  )-origin else url_input ).
    ENDIF.

    CASE client->event( )->get_id( ).

      WHEN 'BTN_BACK'.
        client->controller( )->nav_to_app_called( ).

      WHEN 'BUTTON_POST'.
        "roundtrip

    ENDCASE.

  ENDMETHOD.

  METHOD z2ui5_if_app~set_view.

    view->factory_selscreen_page( event_nav_back_id = 'BTN_BACK' title = 'ABAP2UI5 Demo - Browser'
         ")->begin_of_block( 'Selection Screen'
          "  )->begin_of_group( 'Browser'
          "      )->label( 'URL'
          "      )->input( value = url_input editable = editable
          "      )->button( text = 'go' on_press_id = 'BUTTON_POST'
          " )->end_of_group(
         "  )->end_of_block(
         )->begin_of_block( 'Browser'
            )->html( `<iframe height="900" width="100%" src="` && url_input && `"></iframe>`
       ).

  ENDMETHOD.

ENDCLASS.
