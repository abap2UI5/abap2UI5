CLASS z2ui5_cl_pop_js_loader DEFINITION PUBLIC.

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
        VALUE(result) TYPE string.

    DATA mv_is_open_ui5 TYPE abap_bool.
    DATA ui5_gav        TYPE string.

  PROTECTED SECTION.
    DATA client         TYPE REF TO z2ui5_if_client.
    DATA js             TYPE string.
    DATA user_command   TYPE string.
    DATA check_open_ui5 TYPE abap_bool.

    METHODS view_display.

  PRIVATE SECTION.
ENDCLASS.


CLASS z2ui5_cl_pop_js_loader IMPLEMENTATION.

  METHOD factory.

    CREATE OBJECT r_result.
    r_result->js           = i_js.
    r_result->user_command = i_result.

  ENDMETHOD.

  METHOD factory_check_open_ui5.
    CREATE OBJECT r_result.
    r_result->check_open_ui5 = abap_true.
  ENDMETHOD.

  METHOD result.

    result = user_command.

  ENDMETHOD.

  METHOD view_display.

    DATA view TYPE REF TO z2ui5_cl_ui5_view_builder.
    DATA popup TYPE REF TO z2ui5_cl_ui5_view_builder.
    view = z2ui5_cl_ui5_view_builder=>factory(
        )->ele( n = `FragmentDefinition` ns = `core`
            )->a( n = `xmlns`       v = `sap.m`
            )->a( n = `xmlns:core`  v = `sap.ui.core`
            )->a( n = `xmlns:html`  v = `http://www.w3.org/1999/xhtml`
            )->a( n = `xmlns:z2ui5` v = `z2ui5.cc` ).


    popup = view->ele( `Dialog`
        )->a( n = `title` v = `Setup UI...`
        )->ele( `content` ).

    IF js IS NOT INITIAL.
      popup->tag( n = `Timer` ns = `z2ui5`
          )->a( n = `finished` v = client->_event( `TIMER_FINISHED` ) ).

      " ZZPLAIN is the marker the frontend replaces by the raw inner XML of
      " its VALUE - the only way to put a script body into a view
      popup->ele( n = `script` ns = `html`
          )->tag( n = `ZZPLAIN` ns = `html`
              )->a( n = `VALUE` v = js ).
    ENDIF.

    IF check_open_ui5 = abap_true.
      popup->tag( n = `Info` ns = `z2ui5`
          )->a( n = `finished` v = client->_event( `INFO_FINISHED` )
          )->a( n = `ui5_gav`  v = client->_bind( ui5_gav ) ).
    ENDIF.

    client->popup_display( popup->stringify( ) ).

  ENDMETHOD.

  METHOD z2ui5_if_app~main.
        DATA temp1 TYPE xsdboolean.

    me->client = client.

    IF client->check_on_init( ) IS NOT INITIAL.
      view_display( ).
      RETURN.
    ENDIF.

    CASE client->get( )-event.
      WHEN `INFO_FINISHED`.

        temp1 = boolc( ui5_gav CS `OPEN` ).
        mv_is_open_ui5 = temp1.
        client->popup_destroy( ).
        client->nav_app_leave( ).

      WHEN `TIMER_FINISHED`.
        client->popup_destroy( ).
        client->nav_app_leave( ).
    ENDCASE.

  ENDMETHOD.

ENDCLASS.
