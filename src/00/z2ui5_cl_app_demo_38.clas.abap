CLASS z2ui5_cl_app_demo_38 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    TYPES:
      BEGIN OF ty_msg,
        type        TYPE string,
        title       TYPE string,
        subtitle    TYPE string,
        description TYPE string,
        group       TYPE string,
      END OF ty_msg.

    DATA t_msg TYPE STANDARD TABLE OF ty_msg WITH EMPTY KEY.
    DATA check_initialized TYPE abap_bool.

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

  PRIVATE SECTION.
ENDCLASS.



CLASS Z2UI5_CL_APP_DEMO_38 IMPLEMENTATION.


  METHOD z2ui5_if_app~main.

    me->client     = client.
    app-get        = client->get( ).
    app-view_popup = ``.

    IF check_initialized = abap_false.
      check_initialized = abap_true.

      t_msg = VALUE #(
          ( description = 'descr' subtitle = 'subtitle' title = 'title' type = 'Error'     group = 'group 01' )
          ( description = 'descr' subtitle = 'subtitle' title = 'title' type = 'Information' group = 'group 01' )
          ( description = 'descr' subtitle = 'subtitle' title = 'title' type = 'Information' group = 'group 02' )
          ( description = 'descr' subtitle = 'subtitle' title = 'title' type = 'Success' group = 'group 03' ) ).

    ENDIF.

    CASE client->get( )-event.
      WHEN 'POPUP'.
        app-view_popup = 'POPUP'.
      WHEN 'POPOVER'.
        app-view_popup = 'POPOVER'.
        app-next-popup_open_by_id = 'test'.
      WHEN 'BACK'.
        client->nav_app_leave( client->get_app( client->get( )-id_prev_app_stack ) ).
    ENDCASE.

    DATA(page) = z2ui5_cl_xml_view=>factory( )->shell(
        )->page(
            title          = 'abap2UI5 - List'
            navbuttonpress = client->_event( 'BACK' )
              shownavbutton = abap_true
            )->header_content(
                )->link(
                    text = 'Demo'  target = '_blank'
                    href = `https://twitter.com/OblomovDev/status/1647246029828268032`
                )->link(
                    text = 'Source_Code'  target = '_blank'
                    href = z2ui5_cl_xml_view=>hlp_get_source_code_url( app = me get = client->get( ) )
            )->get_parent( ).
    page->button( text = 'Messages' press = client->_event( 'POPUP' )  ).
    page->message_view(
        items = client->_bind( t_msg )
        groupitems = abap_true
        )->message_item(
            type        = `{TYPE}`
            title       = `{TITLE}`
            subtitle    = `{SUBTITLE}`
            description = `{DESCRIPTION}`
            groupname   = `{GROUP}` ).

    page->footer( )->overflow_toolbar(
         )->button(
             id = 'test'
             text  = 'Messages (6)'
             press = client->_event( 'POPOVER' )
             type  = 'Emphasized'
         )->toolbar_spacer(
         )->button(
             text  = 'Send to Server'
             press = client->_event( 'BUTTON_SEND' )
             type  = 'Success' ).

    app-next-xml_main = page->get_root(  )->xml_get( ).

    DATA(popup) = z2ui5_cl_xml_view=>factory_popup( ).
    CASE app-view_popup.

      WHEN 'POPOVER'.

        popup = popup->popover(
            placement = `Top`
            title = `Messages`
            contentheight = '50%'
            contentwidth = '50%' ).

        popup->message_view(
                items      = client->_bind( t_msg )
                groupitems = abap_true
            )->message_item(
                type        = `{TYPE}`
                title       = `{TITLE}`
                subtitle    = `{SUBTITLE}`
                description = `{DESCRIPTION}`
                groupname   = `{GROUP}` ).

      WHEN 'POPUP'.

        popup = popup->dialog(
        title = `Messages`
        contentheight = '50%'
        contentwidth = '50%' ).

        popup->message_view(
                items = client->_bind( t_msg )
                groupitems = abap_true
            )->message_item(
                type        = `{TYPE}`
                title       = `{TITLE}`
                subtitle    = `{SUBTITLE}`
                description = `{DESCRIPTION}`
                groupname   = `{GROUP}` ).

        popup->footer( )->overflow_toolbar(
          )->toolbar_spacer(
          )->button(
              text  = 'close'
              press = client->_event_close_popup( ) ).

    ENDCASE.

    app-next-xml_popup = popup->get_root(  )->xml_get( ).

    client->set_next( app-next ).
    CLEAR app-get.
    CLEAR app-next.

  ENDMETHOD.
ENDCLASS.
