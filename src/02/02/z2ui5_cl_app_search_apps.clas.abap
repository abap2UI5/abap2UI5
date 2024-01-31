CLASS z2ui5_cl_app_search_apps DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    TYPES:
      BEGIN OF ty_app,
        name    TYPE string,
        visible TYPE abap_bool,
*        check_fav TYPE abap_bool,
      END OF ty_app.
    DATA mt_apps TYPE STANDARD TABLE OF ty_app WITH EMPTY KEY.
    DATA mt_favs TYPE STANDARD TABLE OF ty_app WITH EMPTY KEY.

    DATA check_initialized TYPE abap_bool.
    DATA mv_search_value TYPE string.
    DATA mv_selected_key TYPE string.

    DATA:
      BEGIN OF ms_favrites,
        check_cloud_ready   TYPE abap_bool,
        check_premise_ready TYPE abap_bool,
        search_field        TYPE string,
      END OF ms_favrites.

  PROTECTED SECTION.
    METHODS search.
    METHODS view_display
      IMPORTING
        client TYPE REF TO z2ui5_if_client.
    METHODS view_nest_display
      IMPORTING
        client TYPE REF TO z2ui5_if_client.
    METHODS view_action_sheet
      IMPORTING
        val TYPE clike.

    DATA client TYPE REF TO z2ui5_if_client.
  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_app_search_apps IMPLEMENTATION.


  METHOD z2ui5_if_app~main.

    me->client = client.

    IF check_initialized = abap_false.
      check_initialized = abap_true.

      z2ui5_cl_util_func=>db_load_by_handle(
        EXPORTING
          uname  = sy-uname
          handle = 'z2ui5_cl_app_search_apps'
        IMPORTING
          result = mt_favs ).

      mt_apps = VALUE #( FOR row IN z2ui5_cl_util_func=>rtti_get_classes_impl_intf( `Z2UI5_IF_APP` )
        ( name  = row ) ).
      search( ).
      view_display( client ).
      RETURN.
    ENDIF.

    IF client->get( )-check_on_navigated = abap_true.
      view_display( client ).
    ENDIF.

    CASE client->get( )-event.

      WHEN `ON_PRESS`.

        DATA(lt_arg) = client->get( )-t_event_arg.
        DATA(lv_app) = lt_arg[ 1 ].



        INSERT VALUE #( name = lv_app ) INTO TABLE mt_favs.


        z2ui5_cl_util_func=>db_save(
            uname  = sy-uname
            handle = 'z2ui5_cl_app_search_apps'
            data   = mt_favs ).

        view_action_sheet( lv_app ).

        view_nest_display( client ).

      WHEN 'BACK'.
        client->nav_app_leave( client->get_app( client->get( )-s_draft-id_prev_app_stack ) ).

      WHEN 'ON_SEARCH'.
        search( ).
        client->view_model_update( ).
        client->message_toast_display( |backend search done| ).
    ENDCASE.

  ENDMETHOD.

  METHOD search.



    LOOP AT mt_apps REFERENCE INTO DATA(lr_app).
      lr_app->visible = abap_false.
      IF lr_app->name CS 'DEMO' OR lr_app->name CS `Z2UI5_CL_POPUP`.
        CONTINUE.
      ENDIF.
      IF lr_app->name CS mv_search_value.
        lr_app->visible = abap_true.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  METHOD view_display.


    DATA(page) = z2ui5_cl_xml_view=>factory(
          )->shell(
*          )->page(
*                title = 'abap2UI5 - Search Apps'
*                navbuttonpress = client->_event( 'BACK' )
*                shownavbutton = xsdbool( client->get( )-s_draft-id_prev_app_stack is not initial )
*           )->header_content(
*                )->search_field(
*          value  = client->_bind_edit( mv_search_value )
*          search = client->_event( 'ON_SEARCH' )
*          change = client->_event( 'ON_SEARCH' )
*          width  = `17.5rem`
*          id     = `SEARCH`
*           )->get_parent( ).
      )->tool_page(
                          )->header( `tnt`
                            )->tool_header(
                            )->title( `abap2UI5 - App Overview`
                            )->text( width = `10%`
                                  )->link( text = `Visit the abap2UI5 Project`
*                            )->button( text = `Bak` press = client->_event( 'BACK' )
                              )->get_parent(
                            )->get_parent( )->sub_header( `tnt`
                            )->tool_header( ).

    DATA(pages) = page->icon_tab_header( selectedkey    = client->_bind_edit( mv_selected_key )
*                                                  select = client->_event( `OnSelectIconTabBar` )
*                                                  select = client->_event_client( action = 'NAV_TO' t_arg  = value #( ( `NavCon` ) ( `${$parameters}` ) ) )
                                                 select = client->_event_client( val = client->cs_event-nav_container_to t_arg  = VALUE #( ( `NavCon` ) ( `${$parameters>/selectedKey}` ) ) )
                                                 mode   = `Inline`
                                 )->items(
                                   )->icon_tab_filter( key  = `page_favs`
                                                       text = `Favorites` )->get_parent(
                                   )->icon_tab_filter( key  = `page_all`
                                                       text = `Search...` )->get_parent(
                                   )->icon_tab_filter( key  = `page_online`
                                                       text = `More on GitHub...`
*                                      )->items(
*                                         )->icon_tab_filter( key = `page11` text = `User 1` )->get_parent(
*                                         )->icon_tab_filter( key = `page32` text = `User 2` )->get_parent(
*                                         )->icon_tab_filter( key = `page33` text = `User 3`
                                 )->get_parent( )->get_parent( )->get_parent( )->get_parent( )->get_parent(
                               )->main_contents(
*                                )->button( text = `page1` press = client->_event_client( action = 'NAV_TO' t_arg  = VALUE #( ( `NavCon` ) ( `page1` ) ) )
*                                )->button( text = `page2` press = client->_event_client( action = 'NAV_TO' t_arg  = VALUE #( ( `NavCon` ) ( `page2` ) ) )
*                                )->button( text = `page3` press = client->_event_client( action = 'NAV_TO' t_arg  = VALUE #( ( `NavCon` ) ( `page3` ) ) )
                                 )->nav_container( id                    = `NavCon`
                                                   initialpage           = `page_favs`
                                                   defaulttransitionname = `flip`
                                    )->pages( ).

    pages->page(
                           title = `12 Apps`
            id                   = `page_favs`
                )->header_content(
                )->button( text = `Edit`
      )->search_field(
      value  = client->_bind_edit( mv_search_value )
      search = client->_event( 'ON_SEARCH' )
      change = client->_event( 'ON_SEARCH' )
      width  = `17.5rem`
*id     = `SEARCH`
      )->get_parent( ).

    DATA(page_all) = pages->page(
      title     = `12 Apps on the System`
             id = `page_all`
                 )->header_content(
      )->search_field(
      value  = client->_bind_edit( mv_search_value )
      search = client->_event( 'ON_SEARCH' )
      change = client->_event( 'ON_SEARCH' )
      width  = `17.5rem`
      id     = `SEARCH`
      )->get_parent( ).


    LOOP AT mt_apps REFERENCE INTO DATA(lr_app).
      DATA(lv_tabix) = sy-tabix.
      page_all->generic_tile(
        id      = lr_app->name
        class   = 'sapUiTinyMarginBegin sapUiTinyMarginTop tileLayout'
        press   = client->_event( val = `ON_PRESS`   t_arg = VALUE #( ( `${$source>/header}` ) ( `${$source>/id}` ) ) )
        header  = client->_bind( val = lr_app->name    tab = mt_apps tab_index = lv_tabix )
        visible = client->_bind( val = lr_app->visible tab = mt_apps tab_index = lv_tabix ) ).
    ENDLOOP.


    view_nest_display( client ).




    DATA(page_online) = pages->page(
*            title = `Your app is not listed here? Fell free to send a PR and extend this page`
                   id = `page_online`
                    )->header_content(
                     )->toolbar_spacer(
                     )->checkbox( text     = `Cloud`
                                  selected = client->_bind_edit( ms_favrites-check_cloud_ready )
                     )->checkbox( text     = `On-Premise`
                                  selected = client->_bind_edit( ms_favrites-check_premise_ready )
                     )->button( text = `sort`
      )->search_field(
      value  = client->_bind_edit( mv_search_value )
      search = client->_event( 'ON_SEARCH' )
      change = client->_event( 'ON_SEARCH' )
      width  = `17.5rem`
      )->get_parent(
*           )->sub_header(
*            )->overflow_toolbar(
*             )->text( `Your open-source app is not listed here? Feel free to send a PR and extend this page`
*             )->link( target = `_blank` text = `HERE` href = `{AUTHOR_LINK}`
*            )->get_parent( )->get_parent(
            )->content( ).

    page_online->message_strip( type = `Warning`
                                text = `Your open-source app is not listed here? Feel free to send a PR and extend this page` ).

    DATA(lt_repos) = NEW lcl_github( )->get_repositories( ).




    DATA(item) = page_online->list(
             "   headertext = `Product`
                nodata         = `no conditions defined`
               items           = client->_bind_local( lt_repos )
               selectionchange = client->_event( 'SELCHANGE' )
                  )->custom_list_item( ).



    item = item->vbox( ).

*    grid->combobox(
*                 selectedkey = `{OPTION}`
*                 items       = client->_bind_local( value string_table( ( `OFFLINE` ) ( `ONLINE` ) ) )
*             )->item(
*                     key = '{}'
*                     text = '{}'
*             )->get_parent(
    item->text( ).
    DATA(row) = item->grid( ).
    row->title( `{NAME}` ).
    row->text( `{DESCR}` ).
    row->text( ).
    row->checkbox( text     = `Cloud Ready`
                   selected = client->_bind_edit( ms_favrites-check_cloud_ready ) ).

    row = item->grid( ).
*    row = item->hbox( ).
*    item->text( text = `{DESCR}`
    row->link( target = `_blank`
               text   = `{AUTHOR_NAME}`
               href   = `{AUTHOR_LINK}` ).

    row->link( target = `_blank`
               text   = `{LINK}`
               href   = `{LINK}` ).

    row->checkbox( text     = `Installed`
                   selected = client->_bind_edit( ms_favrites-check_cloud_ready ) ).
    row->checkbox( text     = `On-Premise since: 7.50`
                   selected = client->_bind_edit( ms_favrites-check_cloud_ready ) ).


*     page_online


    client->view_display( page->stringify( ) ).

  ENDMETHOD.

  METHOD view_action_sheet.

    DATA(action_sheet_view) = z2ui5_cl_xml_view=>factory_popup( ).

    action_sheet_view->_generic_property( VALUE #( n = `core:require` v = `{ MessageToast: 'sap/m/MessageToast' }` ) ).

    action_sheet_view->action_sheet( placement        = `Botton`
                                     showcancelbutton = abap_true
                                     title            = `Choose Your Action`
      )->button( text  = `Accept`
                 icon  = `sap-icon://accept`
                 press = `MessageToast.show('selected action is ' + ${$source>/text})`
      )->button( text  = `Reject`
                 icon  = `sap-icon://decline`
                 press = `MessageToast.show('selected action is ' + ${$source>/text})`
      )->button( text  = `Email`
                 icon  = `sap-icon://email`
                 press = `MessageToast.show('selected action is ' + ${$source>/text})`
      )->button( text  = `Forward`
                 icon  = `sap-icon://forward`
                 press = `MessageToast.show('selected action is ' + ${$source>/text})`
      )->button( text  = `Delete`
                 icon  = `sap-icon://delete`
                 press = `MessageToast.show('selected action is ' + ${$source>/text})`
      )->button( text  = `Other`
                 press = `MessageToast.show('selected action is ' + ${$source>/text})` ).

    client->popover_display( xml   = action_sheet_view->stringify( )
                             by_id = val ).

  ENDMETHOD.

  METHOD view_nest_display.




    DATA(lo_view_nested) = z2ui5_cl_xml_view=>factory( ).

    LOOP AT mt_favs REFERENCE INTO DATA(lr_app).
      " WHERE check_fav = abap_true.
      DATA(lv_tabix) = sy-tabix.
      lo_view_nested->generic_tile(
*      page_favs->generic_tile(
        class  = 'sapUiTinyMarginBegin sapUiTinyMarginTop tileLayout'
        press  = client->_event( val = `ON_PRESS` t_arg = VALUE #( ( `${$source>/header}` ) ) )
        header = client->_bind( val = lr_app->name    tab = mt_favs tab_index = lv_tabix )
*        visible = client->_bind( val = lr_app->check_fav tab = mt_apps tab_index = lv_tabix ) ).
    ENDLOOP.

    client->nest_view_display( val           = lo_view_nested->stringify( )
                               id            = `page_favs`
                               method_insert = 'addContent' ).

  ENDMETHOD.

ENDCLASS.
