CLASS z2ui5_cl_core_app_search DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    TYPES:
      BEGIN OF ty_app,
        id      TYPE string,
        name    TYPE string,
        visible TYPE abap_bool,
      END OF ty_app.
    DATA mt_apps TYPE STANDARD TABLE OF ty_app WITH EMPTY KEY.
    DATA mt_favs TYPE STANDARD TABLE OF ty_app WITH EMPTY KEY.
    DATA ms_app_sel TYPE ty_app.

    DATA check_initialized TYPE abap_bool.
    DATA mv_selected_key TYPE string.

    DATA:
      BEGIN OF ms_search,
        check_hide_samples TYPE abap_bool,
        check_hide_system  TYPE abap_bool,
        search_field       TYPE string,
        number             TYPE string,
      END OF ms_search.

    DATA:
      BEGIN OF ms_favorites,
        check_cloud_ready   TYPE abap_bool,
        check_premise_ready TYPE abap_bool,
        search_field        TYPE string,
        number              TYPE string,
      END OF ms_favorites.

    TYPES:
      BEGIN OF ty_s_app,
        id         TYPE string,
        name       TYPE string,
        descr      TYPE string,
        classname  TYPE string,
        check_hide TYPE abap_bool,
      END OF ty_s_app.
    TYPES ty_t_app TYPE STANDARD TABLE OF ty_s_app WITH EMPTY KEY.

    TYPES:
      BEGIN OF ty_s_repo,
        name                 TYPE string,
        descr                TYPE string,
        author_link          TYPE string,
        author_name          TYPE string,
        check_abap_for_cloud TYPE abap_bool,
        check_standard_abap  TYPE abap_bool,
        link                 TYPE string,
        t_app                TYPE ty_t_app,
        number_of_app        TYPE i,
      END OF ty_s_repo.
    TYPES ty_t_repo TYPE STANDARD TABLE OF ty_s_repo WITH EMPTY KEY.

    DATA mt_git_repos TYPE ty_t_repo.
    DATA mt_git_addons TYPE ty_t_repo.

  PROTECTED SECTION.
    METHODS search.
    METHODS view_display
      IMPORTING
        client TYPE REF TO z2ui5_if_client.
    METHODS view_nest_display.
    METHODS view_action_sheet
      IMPORTING
        val TYPE clike.

    DATA client TYPE REF TO z2ui5_if_client.
  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_core_app_search IMPLEMENTATION.


  METHOD search.

    DATA lv_counter TYPE i.

    LOOP AT mt_apps REFERENCE INTO DATA(lr_app).
      lr_app->id = `ID` && sy-tabix.
      lr_app->visible = abap_false.

      IF ms_search-check_hide_samples = abap_true
      AND lr_app->name CS 'Z2UI5_CL_DEMO'.
        CONTINUE.
      ENDIF.
      IF ms_search-check_hide_system = abap_true
        AND lr_app->name CS `Z2UI5_CL_`
        AND lr_app->name NS `Z2UI5_CL_DEMO`.
        CONTINUE.
      ENDIF.

      IF lr_app->name CS ms_search-search_field.
        lr_app->visible = abap_true.
        lv_counter = lv_counter + 1.
      ENDIF.
    ENDLOOP.
    ms_search-number = `Result: ` && CONV string( lv_counter ).

  ENDMETHOD.


  METHOD view_action_sheet.

    DATA(action_sheet_view) = z2ui5_cl_xml_view=>factory_popup( ).

    action_sheet_view->_generic_property( VALUE #( n = `core:require` v = `{ MessageToast: 'sap/m/MessageToast' }` ) ).

    action_sheet_view->action_sheet( placement        = `Botton`
                                     showcancelbutton = abap_true
                                     title            = `Choose Your Action`
      )->button( text  = `Add to Favorite`
                 press = client->_event( `ADD_TO_FAVS` ) ).

    client->popover_display( xml = action_sheet_view->stringify( ) by_id = val ).

  ENDMETHOD.


  METHOD view_display.

    DATA(page) = z2ui5_cl_xml_view=>factory( )->shell( )->page( `abap2UI5 - App Finder`
       )->content( ).

    page->icon_tab_header( selectedkey    = client->_bind_edit( mv_selected_key )
                                                 select = client->_event_client(
                                                    val   = client->cs_event-nav_container_to
                                                    t_arg = VALUE #( ( `NavCon` ) ( `${$parameters>/selectedKey}` ) ) )
                                                 mode   = `Inline`
                                 )->items(
                                   )->icon_tab_filter( key  = `page_favs`
                                                       text = `Favorites` )->get_parent(
                                   )->icon_tab_filter( key  = `page_all`
                                                       text = `Local` )->get_parent(
                                   )->icon_tab_filter( key  = `page_online`
                                                       text = `Apps on GitHub` )->get_parent(
                                   )->icon_tab_filter( key  = `page_addon`
                                                       text = `Addons on GitHub`
                                ).
    DATA(pages) =   page->nav_container( id                    = `NavCon`
                                                 initialpage           = `page_favs`
                                                 defaulttransitionname = `flip`
                                  )->pages( ).

    pages->page(
                           title = `Result: ` && client->_bind( ms_favorites-number )
            id                   = `page_favs`
                )->header_content(
                )->button( text = `Clear` press = client->_event( `ON_FAVS_CLEAR` )
      )->get_parent( ).

    DATA(page_all) = pages->page(
      title     = client->_bind( ms_search-number  )
             id = `page_all`
                 )->header_content(
                             )->checkbox( text     = `Hide Samples`
                                  selected = client->_bind_edit( ms_search-check_hide_samples )
                                  select = client->_event( `ON_SEARCH_ALL` )
                              )->checkbox( text     = `Hide System`
                                  selected = client->_bind_edit( ms_search-check_hide_system )
                                   select = client->_event( `ON_SEARCH_ALL` )
      )->search_field(
      value  = client->_bind_edit( ms_search-search_field )
      search = client->_event( 'ON_SEARCH_ALL' )
      change = client->_event( 'ON_SEARCH_ALL' )
      width  = `17.5rem`
      id     = `SEARCH`
      )->get_parent( ).


    LOOP AT mt_apps REFERENCE INTO DATA(lr_app).
      DATA(lv_tabix) = sy-tabix.
      page_all->generic_tile(
        id      = lr_app->id
        class   = 'sapUiTinyMarginBegin sapUiTinyMarginTop tileLayout'
        press   = client->_event( val = `ON_PRESS`   t_arg = VALUE #( ( `${$source>/id}` ) ) )
        header  = client->_bind( val = lr_app->name    tab = mt_apps tab_index = lv_tabix )
        visible = client->_bind( val = lr_app->visible tab = mt_apps tab_index = lv_tabix ) ).
    ENDLOOP.

    view_nest_display( ).

    DATA(page_online) = pages->page( id = `page_online`
                    )->header_content(
                    )->text(
                    )->link( text = `Install with abapGit` href = `https://abapgit.org/` target = `blank`
                    )->toolbar_spacer(
                      )->link( text = `More Open Source on dotabap.org...` href = `https://dotabap.org/`  target = `blank`
                     )->toolbar_spacer(
                     )->text(
                     )->toolbar_spacer(
                     )->text(
                     )->get_parent(
            )->content( ).

    page_online->message_strip( type = `Warning`
                                text = `Your open-source app is not listed here? Feel free to send a PR and extend this page`
                                )->get( )->link(
                                     text = `here`
                                     target = `blank`
                                     href = `https://github.com/abap2UI5/abap2UI5/blob/main/src/02/02/z2ui5_cl_app_search_apps.clas.locals_imp.abap` ).

    mt_git_repos = NEW lcl_github( )->get_repositories( ).

    LOOP AT mt_git_repos REFERENCE INTO DATA(lr_repo).

      lr_repo->number_of_app = lines( lr_repo->t_app ).
      lr_repo->author_name = shift_left( val = lr_repo->author_link
                                         sub = `https://github.com/` ).
    ENDLOOP.

    DATA(item) = page_online->list(
             "   headertext = `Product`
                nodata         = `no conditions defined`
               items           = client->_bind( mt_git_repos )
               selectionchange = client->_event( 'SELCHANGE' )
                  )->custom_list_item( ).

    item = item->vbox( ).

    item->text( ).
    DATA(row) = item->grid( ).
    row->title( `{NAME}` ).
    row->text( `{DESCR}` ).
*    row->text( ).
    row->checkbox( text     = `ABAP for Cloud`
      enabled               = abap_false
                   selected = `{CHECK_ABAP_FOR_CLOUD}` ).

    row = item->grid( ).
    row->link( target = `_blank`
               text   = `{AUTHOR_NAME}`
               href   = `{AUTHOR_LINK}` ).

    row->link( target = `_blank`
               text   = `{LINK}`
               href   = `{LINK}` ).

    row->checkbox( text     = `Standard ABAP`
                   selected = `{CHECK_STANDARD_ABAP}`
                   enabled  = abap_false ).

    DATA(page_addon) = pages->page( id = `page_addon`
                       )->header_content(
                       )->text(
                       )->link( text = `Install with abapGit` href = `https://abapgit.org/` target = `blank`
                       )->toolbar_spacer(
                         )->link( text = `More Open Source on dotabap.org...` href = `https://dotabap.org/`  target = `blank`
                        )->toolbar_spacer(
                        )->text(
                        )->toolbar_spacer(
                        )->text(
                        )->get_parent(
               )->content( ).

    page_addon->message_strip( type = `Warning`
                                text = `Your open-source addon is not listed here? Feel free to send a PR and extend this page`
                                )->get( )->link(
                                     text = `here`
                                     target = `blank`
                                     href = `https://github.com/abap2UI5/abap2UI5/blob/main/src/02/02/z2ui5_cl_app_search_apps.clas.locals_imp.abap` ).

    mt_git_addons = NEW lcl_github( )->get_repositories_addons( ).

    LOOP AT mt_git_addons REFERENCE INTO lr_repo.

      lr_repo->number_of_app = lines( lr_repo->t_app ).
      lr_repo->author_name = shift_left( val = lr_repo->author_link
                                         sub = `https://github.com/` ).
    ENDLOOP.

    item = page_addon->list(
             "   headertext = `Product`
                nodata         = `no conditions defined`
               items           = client->_bind( mt_git_addons )
               selectionchange = client->_event( 'SELCHANGE' )
                  )->custom_list_item( ).

    item = item->vbox( ).

    item->text( ).
    row = item->grid( ).
    row->title( `{NAME}` ).
    row->text( `{DESCR}` ).
    row->text( ).

    row = item->grid( ).

    row->link( target = `_blank`
               text   = `{LINK}`
               href   = `{LINK}` ).

    client->view_display( page->stringify( ) ).

  ENDMETHOD.


  METHOD view_nest_display.

    DATA(lo_view_nested) = z2ui5_cl_xml_view=>factory( ).

    LOOP AT mt_favs REFERENCE INTO DATA(lr_app).
      DATA(lv_tabix) = sy-tabix.
      lo_view_nested->generic_tile(
        class  = 'sapUiTinyMarginBegin sapUiTinyMarginTop tileLayout'
        press  = client->_event( val = `ON_START`  t_arg = VALUE #( ( `${$source>/header}` ) ) )
*        header = `test`
        header = client->_bind( val = lr_app->name tab = mt_favs tab_index = lv_tabix )
        ).
    ENDLOOP.

    client->nest_view_display( val           = lo_view_nested->stringify( )
                               id            = `page_favs`
                               method_insert = 'addContent' ).

  ENDMETHOD.


  METHOD z2ui5_if_app~main.

    DATA li_app TYPE REF TO z2ui5_if_app.

    me->client = client.

    IF check_initialized = abap_false.
      check_initialized = abap_true.

      ms_search-check_hide_samples = abap_true.
      ms_search-check_hide_system  = abap_true.

      TRY.
          z2ui5_cl_util=>db_load_by_handle(
            EXPORTING
              uname  = sy-uname
              handle = z2ui5_cl_util=>rtti_get_classname_by_ref( me )
            IMPORTING
              result = mt_favs ).

        CATCH cx_root.
      ENDTRY.

      mt_apps = VALUE #( FOR row IN z2ui5_cl_util=>rtti_get_classes_impl_intf( z2ui5_cl_util=>rtti_get_intfname_by_ref( li_app ) )
        ( name  = row-classname ) ).
      search( ).
      view_display( client ).
      RETURN.
    ENDIF.

    IF client->get( )-check_on_navigated = abap_true.
      view_display( client ).
    ENDIF.

    CASE client->get( )-event.

      WHEN `ADD_TO_FAVS`.
        SPLIT ms_app_sel-name AT `--` INTO DATA(lv_dummy) ms_app_sel-name.
        ms_app_sel-name = mt_apps[ id = ms_app_sel-name ]-name.
        INSERT  ms_app_sel INTO TABLE mt_favs.
        z2ui5_cl_util=>db_save(
            uname  = sy-uname
            handle = 'z2ui5_cl_app_search_apps'
            data   = mt_favs ).

        view_nest_display( ).

      WHEN `ON_START`.

        TRY.

            DATA(lt_arg2) = client->get( )-t_event_arg.
            DATA(lv_app2) = lt_arg2[ 1 ].
            CREATE OBJECT li_app TYPE (lv_app2).
            client->nav_app_call( li_app ).
          CATCH cx_root INTO DATA(x).
            client->nav_app_call( z2ui5_cl_pop_to_inform=>factory( x->get_text( ) ) ).
        ENDTRY.

      WHEN `ON_PRESS`.
        DATA(lt_arg) = client->get( )-t_event_arg.
        DATA(lv_app) = lt_arg[ 1 ].

        ms_app_sel = VALUE #( name = lv_app ).

        view_action_sheet( lv_app ).

      WHEN 'BACK'.
        client->nav_app_leave( client->get_app( client->get( )-s_draft-id_prev_app_stack ) ).

      WHEN `ON_FAVS_CLEAR`.

        z2ui5_cl_util=>db_delete_by_handle(
               uname  = sy-uname
              handle = 'z2ui5_cl_app_search_apps'
            ).
        CLEAR mt_favs.

        client->message_box_display( `Favorites deleted.` ).
        view_nest_display( ).

      WHEN 'ON_SEARCH_ALL'.
        search( ).
        client->view_model_update( ).
        client->message_toast_display( |backend search done| ).

      WHEN 'ON_SEARCH_GIT'.
        search( ).
        client->view_model_update( ).
        client->message_toast_display( |backend search done| ).

    ENDCASE.

  ENDMETHOD.
ENDCLASS.
