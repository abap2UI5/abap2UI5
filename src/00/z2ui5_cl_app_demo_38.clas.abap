CLASS z2ui5_cl_app_demo_38 DEFINITION PUBLIC.

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

    TYPES:
      BEGIN OF ty_msg,
        type        TYPE string,
        title       TYPE string,
        subtitle    TYPE string,
        description TYPE string,
        group       TYPE string,
      END OF ty_msg.

    DATA t_tab TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.
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



CLASS z2ui5_cl_app_demo_38 IMPLEMENTATION.


  METHOD z2ui5_if_app~controller.


    me->client     = client.
    "we collect all app infos in the structure app
    app-get        = client->get( ).
    app-view_popup = ``. "we display popups only once so clear it after every roundtrip


    IF check_initialized = abap_false.
      check_initialized = abap_true.

        t_msg = value #(
            ( description = 'descr' subtitle = 'subtitle' title = 'title' type = 'Error'     group = 'group 01' )
            ( description = 'descr' subtitle = 'subtitle' title = 'title' type = 'Information' group = 'group 01' )
            ( description = 'descr' subtitle = 'subtitle' title = 'title' type = 'Information' group = 'group 02' )
            ( description = 'descr' subtitle = 'subtitle' title = 'title' type = 'Success' group = 'group 03' )

        ).

      t_tab = VALUE #(
        ( title = 'Peter'  info = 'completed'   descr = 'this is a description' icon = 'sap-icon://account' )
        ( title = 'Peter'  info = 'incompleted' descr = 'this is a description' icon = 'sap-icon://account' )
        ( title = 'Peter'  info = 'working'     descr = 'this is a description' icon = 'sap-icon://account' )
        ( title = 'Peter'  info = 'working'     descr = 'this is a description' icon = 'sap-icon://account' )
        ( title = 'Peter'  info = 'completed'   descr = 'this is a description' icon = 'sap-icon://account' )
        ( title = 'Peter'  info = 'completed'   descr = 'this is a description' icon = 'sap-icon://account' )
      ).

    ENDIF.

    CASE client->get( )-event.
      WHEN 'MESSAGES'.

      WHEN 'BACK'.
        client->nav_app_leave( client->get_app( client->get( )-id_prev_app_stack ) ).
    ENDCASE.

    DATA(page) = z2ui5_cl_xml_view_helper=>factory( )->shell(
        )->page(
            title          = 'abap2UI5 - List'
            navbuttonpress = client->_event( 'BACK' )
              shownavbutton = abap_true
            )->header_content(
                )->link(
                    text = 'Source_Code'  target = '_blank'
                    href = z2ui5_cl_xml_view_helper=>hlp_get_source_code_url( app = me get = client->get( ) )
            )->get_parent( ).
    page->button( text = 'Messages' press = client->_event( 'MESSAGES' ) ).
    page->message_view(
        items = client->_bind( t_msg )
        groupitems = abap_true
        )->message_item(
            type        = `{TYPE}`
            title       = `{TITLE}`
            subtitle    = `{SUBTITLE}`
            description = `{DESCRIPTION}`
            groupname   = `{GROUP}`
    ).
    page->list(
       headertext = 'List Ouput'
       items      = client->_bind_one( t_tab )
       )->standard_list_item(
           title       = '{TITLE}'
           description = '{DESCR}'
           icon        = '{ICON}'
           info        = '{INFO}' ).

    app-next-xml_main = page->get_root(  )->xml_get( ).


   " data(popup) = z2ui5_cl_xml_view_helper=>factory_popup( )->


    "set the data for the frontend
    client->set_next( app-next ).

    "the app will be serialized and persisted, we delete all data which is not needed in the future before
    CLEAR app-get.
    CLEAR app-next.
  ENDMETHOD.
ENDCLASS.
