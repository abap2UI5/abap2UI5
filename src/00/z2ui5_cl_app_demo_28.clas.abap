CLASS z2ui5_cl_app_demo_28 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    TYPES:
      BEGIN OF ty_row,
        title    TYPE string,
        value    TYPE string,
        descr    TYPE string,
        icon     TYPE string,
        info     TYPE string,
        checkbox TYPE abap_bool,
      END OF ty_row.
    DATA t_tab TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.
    DATA mv_Counter TYPE i.

  PROTECTED SECTION.

    DATA client TYPE REF TO z2ui5_if_client.
    DATA:
      BEGIN OF app,
        check_initialized TYPE abap_bool,
        view_main         TYPE string,
        view_popup        TYPE string,
        get               TYPE z2ui5_if_client=>ty_s_get,
        next              TYPE z2ui5_if_client=>ty_s_next,
      END OF app.

    METHODS z2ui5_on_init.
    METHODS z2ui5_on_event.
    METHODS z2ui5_on_render.

  PRIVATE SECTION.
ENDCLASS.



CLASS Z2UI5_CL_APP_DEMO_28 IMPLEMENTATION.


  METHOD z2ui5_if_app~main.

    me->client     = client.
    app-get        = client->get( ).
    app-view_popup = ``.

    IF app-check_initialized = abap_false.
      app-check_initialized = abap_true.
      z2ui5_on_init( ).
    ENDIF.

    IF app-get-event IS NOT INITIAL.
      z2ui5_on_event( ).
    ENDIF.

    z2ui5_on_render( ).

    client->set_next( app-next ).
    CLEAR app-get.
    CLEAR app-next.

  ENDMETHOD.


  METHOD z2ui5_on_event.

    CASE app-get-event.

      WHEN 'TIMER_FINISHED'.
        mv_counter = mv_counter + 1.
        INSERT VALUE #( title = 'entry' && mv_counter   info = 'completed'   descr = 'this is a description' icon = 'sap-icon://account'  )
            INTO TABLE t_tab.

        app-next-s_timer-interval_ms = '2000'.
        app-next-s_timer-event_finished = 'TIMER_FINISHED'.

      WHEN 'BACK'.
        client->nav_app_leave( client->get_app( app-get-id_prev_app_stack ) ).

    ENDCASE.

  ENDMETHOD.


  METHOD z2ui5_on_init.

    mv_counter = 1.

    t_tab = VALUE #(
            ( title = 'entry' && mv_counter  info = 'completed'   descr = 'this is a description' icon = 'sap-icon://account' ) ).

    app-next-s_timer-interval_ms = '2000'.
    app-next-s_timer-event_finished = 'TIMER_FINISHED'.

  ENDMETHOD.


  METHOD z2ui5_on_render.

    DATA(lo_view) = z2ui5_cl_xml_view=>factory( )->shell( )->page(
             title          = 'abap2UI5 - CL_GUI_TIMER - Monitor'
             navbuttonpress = client->_event( 'BACK' )
             shownavbutton  = abap_true
         )->header_content(
             )->link( text = 'Demo'    target = '_blank'    href = `https://twitter.com/OblomovDev/status/1645816100813152256`
             )->link(
                 text = 'Source_Code' target = '_blank'
                 href = z2ui5_cl_xml_view=>hlp_get_source_code_url( app = me get = client->get( ) )
         )->get_parent(
          ).

    lo_view->list(
         headertext = 'Data auto refresh (2 sec)'
         items      = client->_bind_one( t_tab )
         )->standard_list_item(
             title       = '{TITLE}'
             description = '{DESCR}'
             icon        = '{ICON}'
             info        = '{INFO}' ).

    app-next-xml_main = lo_view->get_root( )->xml_get( ).

  ENDMETHOD.
ENDCLASS.
