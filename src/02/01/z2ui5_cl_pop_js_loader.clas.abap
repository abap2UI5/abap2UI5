CLASS z2ui5_cl_pop_js_loader DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    CLASS-METHODS factory
      IMPORTING
        i_js            TYPE string
        i_result        TYPE string DEFAULT `LOADED`
      RETURNING
        VALUE(r_result) TYPE REF TO z2ui5_cl_pop_js_loader.

    CLASS-METHODS factory_check_open_ui5
      RETURNING
        VALUE(r_result) TYPE REF TO z2ui5_cl_pop_js_loader.

    METHODS result
      RETURNING
        VALUE(result3) TYPE string.

    DATA mv_is_open_ui5 TYPE abap_bool.
    DATA ui5_gav        TYPE string.

  PROTECTED SECTION.
    DATA check_initialized TYPE abap_bool.
    DATA client            TYPE REF TO z2ui5_if_client.
    DATA js                TYPE string.
    DATA user_command      TYPE string.
    DATA check_open_ui5    TYPE abap_bool.

    METHODS view_display.

  PRIVATE SECTION.
ENDCLASS.


CLASS z2ui5_cl_pop_js_loader IMPLEMENTATION.
  METHOD factory.

    r_result = NEW #( ).
    r_result->js           = i_js.
    r_result->user_command = i_result.

  ENDMETHOD.

  METHOD factory_check_open_ui5.
    r_result = NEW #( ).
    r_result->check_open_ui5 = abap_true.
  ENDMETHOD.

  METHOD result.

    result3 = user_command.

  ENDMETHOD.

  METHOD view_display.

    DATA(popup) = z2ui5_cl_xml_view=>factory_popup( )->dialog( `Setup UI...`
        )->content( ).

    IF js IS NOT INITIAL.
      popup->_z2ui5( )->timer( client->_event( 'TIMER_FINISHED' )
      )->_generic( ns   = `html`
                   name = `script` )->_cc_plain_xml( js ).
    ENDIF.

    IF check_open_ui5 = abap_true.
      popup->_z2ui5( )->info_frontend( finished = client->_event( `INFO_FINISHED` )
                                       ui5_gav  = client->_bind_edit( ui5_gav ) ).
    ENDIF.

    client->popup_display( popup->stringify( ) ).

  ENDMETHOD.

  METHOD z2ui5_if_app~main.

    me->client = client.

    IF check_initialized = abap_false.
      check_initialized = abap_true.
      view_display( ).
      RETURN.
    ENDIF.

    CASE client->get( )-event.
      WHEN `INFO_FINISHED`.
        IF to_upper( ui5_gav ) CS `OPEN`.
          mv_is_open_ui5 = abap_true.
        ENDIF.
        client->popup_destroy( ).
        client->nav_app_leave( client->get_app( client->get( )-s_draft-id_prev_app_stack ) ).

      WHEN `TIMER_FINISHED`.
        client->popup_destroy( ).
        client->nav_app_leave( client->get_app( client->get( )-s_draft-id_prev_app_stack ) ).
      WHEN OTHERS.
    ENDCASE.

  ENDMETHOD.
ENDCLASS.
