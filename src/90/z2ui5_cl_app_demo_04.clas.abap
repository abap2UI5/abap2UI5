CLASS z2ui5_cl_app_demo_04 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    CLASS-METHODS create
      IMPORTING
        url      TYPE string
      RETURNING
        value(r_result) TYPE REF TO z2ui5_cl_app_demo_04.

    DATA url_input TYPE string.
    DATA check_initialized TYPE abap_bool.

ENDCLASS.

CLASS z2ui5_cl_app_demo_04 IMPLEMENTATION.

  METHOD create.

    r_result = NEW #( ).
    r_result->url_input = url.

  ENDMETHOD.

  METHOD z2ui5_if_app~on_event.

    IF check_initialized = abap_false.
      check_initialized = abap_true.
      url_input = cond #( when url_input = '' then _=>get_server_info(  )-origin else url_input ).
    ENDIF.

    CASE client->event( )->get_id( ).

      WHEN 'BTN_BACK'.
        client->controller( )->nav_to_app_called( ).

    ENDCASE.

  ENDMETHOD.

  METHOD z2ui5_if_app~set_view.

    view->factory_selscreen_page( event_nav_back_id = 'BTN_BACK' title = 'ABAP2UI5 - Demo Browser'
         )->begin_of_block( 'Browser'
            )->html( `<iframe height="900" width="100%" src="` && url_input && `"></iframe>`
       ).

  ENDMETHOD.

ENDCLASS.
