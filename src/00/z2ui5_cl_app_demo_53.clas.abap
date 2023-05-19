CLASS z2ui5_cl_app_demo_53 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    TYPES:
      BEGIN OF ty_s_token,
        key     TYPE string,
        text    TYPE string,
        visible TYPE abap_bool,
        selkz   TYPE abap_bool,
      END OF ty_S_token.

    DATA mt_token            TYPE STANDARD TABLE OF ty_S_token WITH EMPTY KEY.
*    DATA mt_token_sugg       TYPE STANDARD TABLE OF ty_S_token WITH EMPTY KEY.

    DATA mt_table TYPE STANDARD TABLE OF z2ui5_t_draft.
    DATA ms_detail TYPE z2ui5_t_draft.
    DATA mv_check_columns TYPE abap_bool.
    DATA mv_check_sort TYPE abap_bool.
    DATA mv_check_table TYPE abap_bool.

    DATA mv_contentheight TYPE string VALUE `70%`.
    DATA mv_contentwidth TYPE string VALUE `70%`.

    DATA mv_check_download_csv TYPE abap_bool.

    TYPES:
      BEGIN OF ty_S_out,
        selkz               TYPE abap_bool,
        uuid                TYPE string,
        uuid_prev           TYPE string,
        uuid_prev_app       TYPE string,
        uuid_prev_app_stack TYPE string,
        timestampl          TYPE string,
        uname               TYPE string,
      END OF ty_s_out.

    DATA:
      BEGIN OF ms_view,
        headerpinned   TYPE abap_bool,
        headerexpanded TYPE abap_bool,
        search_val     TYPE string,
        title          TYPE string,
        t_tab          TYPE STANDARD TABLE OF ty_S_out WITH EMPTY KEY,
      END OF ms_view.

    TYPES:
      BEGIN OF ty_S_cols,
        visible  TYPE abap_bool,
        name     TYPE string,
        length   TYPE string,
        title    TYPE string,
        editable TYPE abap_bool,
      END OF ty_S_cols.

    TYPES:
      BEGIN OF ty_S_filter_show,
        selkz TYPE abap_bool,
        name  TYPE string,
        value TYPE string,
        " t_value TYPE STANDARD TABLE OF ty_S_token WITH EMPTY KEY,
      END OF ty_S_filter_show.

    TYPES:
      BEGIN OF ty_S_filter,
        uuid      TYPE string,
        uuid_prev TYPE string,
        "STANDARD TABLE OF ty_s_token WITH EMPTY KEY,
      END OF ty_S_filter.

    TYPES:
      BEGIN OF ty_S_sort,
        "  selkz      TYPE abap_bool,
        name TYPE string,
        type TYPE string,
        " descr      TYPE string,
        "  check_descending TYPE string,
      END OF ty_S_sort.

    DATA:
      BEGIN OF ms_layout,
        check_zebra   TYPE abap_bool,
        title         TYPE string,
        sticky_header TYPE string,
        selmode       TYPE string,
        t_filter_show TYPE STANDARD TABLE OF ty_S_filter_show,
        s_filter      TYPE ty_s_filter,
        t_cols        TYPE STANDARD TABLE OF ty_S_cols,
        t_sort        TYPE STANDARD TABLE OF ty_S_sort,
      END OF ms_layout.

    TYPES:
      BEGIN OF s_combobox,
        key  TYPE string,
        text TYPE string,
      END OF s_combobox.

    TYPES ty_t_combo TYPE STANDARD TABLE OF s_combobox WITH EMPTY KEY.

    CLASS-METHODS encode_base64
      IMPORTING
        val           TYPE string
      RETURNING
        VALUE(result) TYPE string.

    TYPES:
      BEGIN OF ty_S_db_layout,
        selkz   TYPE ABap_bool,
        name    TYPE string,
        user    TYPE string,
        default TYPE abap_bool,
        data    TYPE string,
      END OF ty_S_db_layout.
    DATA mt_db_layout TYPE STANDARD TABLE OF ty_S_db_layout.

    DATA mv_layout_name TYPE string.

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
    METHODS init_table_output.
    METHODS z2ui5_on_render_main.
    METHODS z2ui5_on_render_detail.
    METHODS z2ui5_on_render_pop_setup.
    METHODS z2ui5_on_render_pop_filter.
    METHODS z2ui5_on_render_pop_detail.
    METHODS z2ui5_on_render_pop_layout.
    METHODS z2ui5_set_download_csv
      IMPORTING
        i_view TYPE REF TO z2ui5_cl_xml_view.
    METHODS z2ui5_set_search.
    METHODS z2ui5_set_detail.
    METHODS z2ui5_set_sort.
    METHODS z2ui5_set_filter
      IMPORTING
        io_box TYPE REF TO z2ui5_cl_xml_view.
    METHODS z2ui5_set_data.

ENDCLASS.



CLASS z2ui5_cl_app_demo_53 IMPLEMENTATION.


  METHOD z2ui5_if_app~main.

    me->client     = client.
    app-get        = client->get( ).
    app-view_popup = ``.
    app-next-path = `/z2ui5_cl_app_demo_49`.
    app-next-title = `List Report`.


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

      WHEN 'SORT_ADD'.
        INSERT VALUE #( ) INTO TABLE ms_layout-t_sort.
        app-view_popup = 'POPUP_SETUP'.

      WHEN `SORT_DELETE`.
        DELETE ms_layout-t_sort WHERE name = app-get-event_data.
        app-view_popup = 'POPUP_SETUP'.

      WHEN 'BUTTON_DELETE'.
        DELETE ms_view-t_tab WHERE selkz = abap_true.

      WHEN 'BUTTON_CUSTOM'.
        client->popup_message_box( `custom action called` ).

      WHEN 'BUTTON_START'.
        z2ui5_set_data( ).

      WHEN 'BUTTON_DOWNLOAD'.
        mv_check_download_csv = abap_true.

      WHEN `POPUP_LAYOUT_LOAD`.
        DATA(ls_layout2) = mt_db_layout[ selkz = abap_true ].
        z2ui5_lcl_utility=>trans_xml_2_object(
          EXPORTING
            xml  = ls_layout2-data
          IMPORTING
             data = ms_layout
        ).
        ms_view-title = ls_layout2-name.

      WHEN `BUTTON_SAVE_LAYOUT`.
        DATA(ls_layout) = VALUE ty_s_db_layout(
          data = z2ui5_lcl_utility=>trans_data_2_xml( ms_layout )
          name = mv_layout_name
          ).
        INSERT ls_layout INTO TABLE mt_db_layout.

      WHEN 'BUTTON_SEARCH'.
        app-next-s_cursor-id = 'SEARCH'.
        app-next-s_cursor-cursorpos = '99'.
        app-next-s_cursor-selectionend = '99'.
        app-next-s_cursor-selectionstart = '99'.
        z2ui5_set_search( ).

      WHEN 'MAIN'.
        app-view_main = 'MAIN'.

      WHEN 'DETAIL'.
        z2ui5_set_detail( ).
        app-view_main = 'DETAIL'.

      WHEN 'POPUP_DETAIL'.
        app-next-popover_open_by_id = app-get-event_data.
        app-view_popup = 'POPUP_LAYOUT'.

      WHEN 'POPUP_LAYOUT'.
        app-next-popover_open_by_id = `btn_layout`.
        app-view_popup = 'POPUP_LAYOUT'.

      WHEN 'POPUP_FILTER'.
        app-view_popup = 'POPUP_FILTER'.

      WHEN 'BUTTON_SETUP'.
        app-view_popup = 'POPUP_SETUP'.

      WHEN 'POPUP_FILTER_CONTINUE'.
        " app-view_popup = 'POPUP_FILTER'.

      WHEN 'BUTTON_INIT'.
        init_table_output( ).

      WHEN 'BUTTON_CANCEL'.
        client->popup_message_toast( |cancel| ).
        app-view_popup = ''.

      WHEN 'BACK'.
        "  app-next-path = `test`.
        client->nav_app_leave( client->get_app( app-get-id_prev_app_stack ) ).

    ENDCASE.

  ENDMETHOD.


  METHOD z2ui5_on_init.


    init_table_output( ).

    ms_view-title = `Standart`.
    ms_layout-selmode = 'MultiSelect'.
    ms_layout-check_zebra = abap_true.
    ms_view-t_tab = CORRESPONDING #( mt_table ).
    ms_layout-sticky_header = `HeaderToolbar,InfoToolbar,ColumnHeaders`.
    ms_layout-title = `Drafts`.

    app-next-t_scroll = VALUE #( ( name = `page_main` ) ).

    mt_token = VALUE #(
                   ( key = 'VAL1' text = 'value_1' selkz = abap_true  visible = abap_true )
                   ( key = 'VAL3' text = 'value_3' selkz = abap_false visible = abap_true )
                   ( key = 'VAL4' text = 'value_4' selkz = abap_true )
                   ( key = '<500' text = '<500'    selkz = abap_true )
               ).



    " IF app-view_main IS INITIAL.
    DATA(lv_url) = z2ui5_cl_http_handler=>client-t_header[ name = `referer` ]-value.
    SPLIT lv_url AT `/z2ui5_cl_app_demo_49/` INTO DATA(lv_dummy1) DATA(lv_dummy2).
    SPLIT lv_dummy2 AT `(` INTO DATA(lv_view) DATA(lv_token).
    IF lv_view IS NOT INITIAL.
      app-view_main = lv_view.
      SPLIT lv_token AT `(` INTO DATA(lv_token2) lv_dummy1.
      SPLIT lv_token2 AT `)` INTO lv_token lv_dummy1.
      ms_detail-uuid = lv_token.
      IF ms_detail-uuid IS NOT INITIAL.
        z2ui5_set_data( ).

        ms_detail = mt_table[ uuid = ms_detail-uuid ].

        SELECT SINGLE FROM z2ui5_t_draft
          FIELDS *
          WHERE uuid = @ms_detail-uuid
        INTO CORRESPONDING FIELDS OF @ms_detail
        .

      ENDIF.
      "    ENDIF.
    ELSE.
      app-view_main  = 'MAIN'.
    ENDIF.


*    mt_token_sugg = VALUE #(
*        ( key = 'VAL1' text = 'value_1' )
*        ( key = 'VAL2' text = 'value_2' )
*        ( key = 'VAL3' text = 'value_3' )
*        ( key = 'VAL4' text = 'value_4' )
*    ).


  ENDMETHOD.


  METHOD z2ui5_on_render.

    CASE app-view_popup.
      WHEN `POPUP_FILTER`.
        z2ui5_on_render_pop_filter( ).
      WHEN `POPUP_SETUP`.
        z2ui5_on_render_pop_setup( ).
      WHEN `POPUP_LAYOUT`.
        z2ui5_on_render_pop_layout( ).
      WHEN `POPUP_DETAIL`.
        z2ui5_on_render_pop_detail( ).
    ENDCASE.

    app-next-path = app-next-path && `/` &&  app-view_main.

    CASE app-view_main.
      WHEN 'MAIN'.
        z2ui5_on_render_main( ).
      WHEN 'DETAIL'.
        z2ui5_on_render_detail( ).
    ENDCASE.



  ENDMETHOD.


  METHOD init_table_output.

    " CLEAR  ms_layout-s_table.
    " CLEAR mt_cols.
    "  CLEAR  ms_layout-t_cols.

    ms_view-headerexpanded = abap_true.
    ms_view-headerpinned   = abap_true.

    DATA(lt_cols)   = lcl_db=>get_fieldlist_by_table( mt_table ).
    LOOP AT lt_cols REFERENCE INTO DATA(lr_col) FROM 2.

      INSERT VALUE #(
        name = lr_col->*
      ) INTO TABLE  ms_layout-t_filter_show.

      INSERT VALUE #(
         visible = abap_true
         name = lr_col->*
       "  length = `10px`
         title = lr_col->*
       ) INTO TABLE ms_layout-t_cols.

*      INSERT VALUE #(
*       "  selkz = abap_true
*         name = lr_col->*
*      "   length = `10px`
*       ) INTO TABLE  ms_layout-t_cols.

    ENDLOOP.

  ENDMETHOD.


  METHOD z2ui5_on_render_main.

    z2ui5_set_sort( ).

    "   DATA(view) = z2ui5_cl_xml_view=>factory( )->shell( ).

    DATA(view) = z2ui5_cl_xml_view=>factory(
        )->page( id = `page_main`
                title          = 'abap2UI5 - Filter'
                navbuttonpress = client->_event( 'BACK' )
                shownavbutton  = abap_true
            )->header_content(
                )->link(
                    text = 'Demo' target = '_blank'
                    href = 'https://twitter.com/OblomovDev/status/1637163852264624139'
                )->link(
                    text = 'Source_Code' target = '_blank' href = z2ui5_cl_xml_view=>hlp_get_source_code_url( app = me get = client->get( ) )
           )->get_parent( ).

    IF mv_check_download_csv = abap_true.
      z2ui5_set_download_csv( view ).
    ENDIF.

    DATA(page) = view->dynamic_page(
            headerexpanded = client->_bind( ms_view-headerexpanded )
            headerpinned   = client->_bind(  ms_view-headerpinned  ) ).

    DATA(header_title) = page->title( ns = 'f'
            )->get( )->dynamic_page_title( ).

    header_title->heading( ns = 'f' )->hbox(
        )->title( ms_view-title
            )->get(
                )->link( text = `test` press =  client->_event( `POPUP_LAYOUT` )
            )->get_parent(
         )->button( id = `btn_layout` press = client->_event( `POPUP_LAYOUT` ) type = `Transparent` icon = `sap-icon://dropdown` ).

    header_title->expanded_content( 'f'
             )->label( text = 'Table Data' ).

    header_title->snapped_content( ns = 'f'
             )->label( text = 'Table Data' ).


    DATA(lo_box) = page->header( )->dynamic_page_header( pinnable = abap_true
         )->flex_box( alignitems = `Start` justifycontent = `SpaceBetween` )->flex_box( alignItems = `Start` ).

    z2ui5_set_filter( lo_box ).


    DATA(cont) = page->content( ns = 'f' ).


    DATA(tab) = cont->table(
        items = client->_bind( val = ms_view-t_tab )
        alternaterowcolors = ms_layout-check_zebra
        sticky = ms_layout-sticky_header
        autopopinmode = abap_true
        mode = ms_layout-selmode ).

*    tab->header_toolbar(
*          )->toolbar(
*              )->title( text = ms_layout-title && ` (` && shift_right( CONV string( lines( ms_view-t_tab ) ) ) && `)` level = `H2`
*                  )->toolbar_spacer(
*              )->button(
*                  icon = 'sap-icon://refresh'
*                  press = client->_event( 'BUTTON_REFRESH' )
*              )->multi_input(
*                    tokens = client->_bind( mt_token )
*                    showclearicon   = abap_true
**                    showvaluehelp   = abap_true
**                    suggestionitems = client->_bind( mt_token_sugg )
*                )->item(
*                        key = `{KEY}`
*                        text = `{TEXT}`
*                )->tokens(
*                    )->token(
*                        key = `{KEY}`
*                        text = `{TEXT}`
*                        selected = `{SELKZ}`
**                        visible = `{VISIBLE}`
*               )->get_parent( )->get_parent(
*
*      )->toolbar_spacer(
**             )->button(
**                text = `Custom Action`
**                  press = client->_event( 'BUTTON_CUSTOM' )
*
*              )->button(
*                  text = `Anlegen`
*                  enabled = abap_false
*                  press = client->_event( 'BUTTON_CREATE' )
*                     )->button(
*                  text = `Löschen`
*                  press = client->_event( 'BUTTON_DELETE' )
*              )->button(
*                  icon = 'sap-icon://action-settings'
*                  press = client->_event( 'BUTTON_SETUP' )
*              )->button(
*                  icon = 'sap-icon://download'
*                  press = client->_event( 'BUTTON_DOWNLOAD' )
*              ).


    data(lv_width) = 10.
    DATA(lo_columns) = tab->columns( ).
    LOOP AT ms_layout-t_cols REFERENCE INTO DATA(lr_field)
          WHERE visible = abap_true.
      lo_columns->column(
            minscreenwidth = shift_right( conv string( lv_width ) ) && `px`
            demandpopin = abap_true width = lr_field->length )->text( text = CONV char10( lr_field->title )
        )->footer(
        )->object_number( number = `Summe` unit = 'ST' state = `Warning` ).
        lv_width = lv_width + 10.
    ENDLOOP.

    DATA(lo_cells) = tab->items( )->column_list_item(
        press = client->_event( val = 'DETAIL' data = `${UUID}` )
        selected = `{SELKZ}`
        type = `Navigation` )->cells( ).
    LOOP AT ms_layout-t_cols REFERENCE INTO lr_field
          WHERE visible = abap_true.
      IF lr_field->editable = abap_true.
        lo_cells->input( `{` && lr_field->name && `}` ).
      ELSE.
        " lo_cells->text(  `{` && lr_field->name && `}` ).
        lo_cells->link( text = `{` && lr_field->name && `}`
        "   press = client->_event( val = `POPUP_DETAIL` data = `${` && lr_field->name && `}` ) ).
           press = client->_event( val = `POPUP_DETAIL` data = `${$source>/id}` ) ).
          " press = client->_event( val = `POPUP_DETAIL` data = `$event` ) ).
      ENDIF.
    ENDLOOP.

    app-next-xml_main = page->get_root( )->xml_get( ).

  ENDMETHOD.


  METHOD z2ui5_on_render_detail.

    app-next-path = app-next-path && `(` && ms_detail-uuid && `)`.

    DATA(view) = z2ui5_cl_xml_view=>factory(
        )->page(
                title          = 'abap2UI5 - List Report'
                navbuttonpress = client->_event( 'MAIN' )
                shownavbutton  = abap_true
            )->header_content(
                )->link(
                    text = 'Demo' target = '_blank'
                    href = 'https://twitter.com/OblomovDev/status/1637163852264624139'
                )->link(
                    text = 'Source_Code' target = '_blank' href = z2ui5_cl_xml_view=>hlp_get_source_code_url( app = me get = client->get( ) )
           )->get_parent( ).

    DATA(page) = view->object_page_layout(
         showtitleinheadercontent = abap_true
         showeditheaderbutton     = abap_true
         editheaderbuttonpress    =  client->_event( 'EDIT_HEADER_PRESS' )
         uppercaseanchorbar       =  abap_false
     ).

    DATA(header_title) = page->header_title(  )->object_page_dyn_header_title( ).

    header_title->expanded_heading(
            )->hbox(
                )->title( text = 'Draft' wrapping = abap_true ).

    header_title->snapped_heading(
            )->flex_box( alignitems = `Center`
              )->avatar( src = `` class = 'sapUiTinyMarginEnd'
                )->title( text = 'Draft' wrapping = abap_true ).

    header_title->expanded_content( ns = `uxap` )->text( `Details` ).
    header_title->snapped_Content( ns = `uxap` )->text( `Details` ).
    header_title->snapped_Title_On_Mobile( )->title( `Details` ).

    DATA(header_content) = page->header_Content( ns = 'uxap' ).

    header_content->flex_box( wrap = 'Wrap'
       )->avatar( src = `` class = 'sapUiSmallMarginEnd' displaySize = 'layout'
        )->vertical_layout( class = 'sapUiSmallMarginBeginEnd'
            )->label(  text    = `UUID`
            )->label(  text    = ms_detail-uuid
        )->get_parent(
        )->horizontal_layout( class = 'sapUiSmallMarginBeginEnd'
         )->vertical_layout(
            )->label( text    = 'UUID PRevious'
            )->label( text    = ms_detail-uuid_prev
          )->get_parent(
        )->get_parent(
        )->vertical_layout( class = 'sapUiSmallMarginBeginEnd'
            )->label(  text    = 'Info'
            )->vbox(
                )->label( 'Timestampl'
                )->label( CONV #( ms_detail-timestampl )
        )->get_parent(  )->get_parent(
        )->vertical_layout( class = 'sapUiSmallMarginBeginEnd'
            )->label(  text    = 'User'
            )->label(  text    = ms_detail-uname
        )->get_parent(
    ).

    DATA(sections) = page->sections( ).

    sections->object_page_section( titleuppercase = abap_false id = 'goalsSectionSS1' title = '2014 Goals Plan'
        )->heading( ns = `uxap`
        )->get_parent(
        )->sub_sections(
            )->object_page_sub_section( id = 'goalssubSectionSS1' title = 'XML'
                )->blocks(
                    )->code_editor(
                        type  = `XML`
                     "   editable = mv_check_editable
                        value = client->_bind_one( ms_detail-data ) ).

    app-next-xml_main = view->get_root( )->xml_get( ).

  ENDMETHOD.


  METHOD z2ui5_on_render_pop_setup.

    DATA(ro_popup) = z2ui5_cl_xml_view=>factory_popup( ).

    ro_popup = ro_popup->dialog( title = 'View Setup'  resizable = abap_true
          contentheight = client->_bind( mv_contentheight ) contentwidth = client->_bind( mv_contentwidth ) ).

    ro_popup->custom_header(
          )->bar(
              )->content_right(
          )->button( text = `zurücksetzten` press = client->_event( 'BUTTON_INIT' ) ).


    DATA(lo_tab) = ro_popup->tab_container( ).

    lo_tab->tab( text = 'Table' selected = client->_bind( mv_check_table )
       )->simple_form( editable = abap_true
           )->content( 'form'
               )->label( 'zebra mode'
               )->checkbox( client->_bind( ms_layout-check_zebra )
               )->label( 'sticky header'
               )->input( client->_bind( ms_layout-sticky_header )
               )->label( text = `Title`
               )->Input( value = client->_bind( ms_layout-title )
               )->label( 'sel mode'
               )->combobox(
                   selectedkey = client->_bind( ms_layout-selmode )
                   items       = client->_bind_one( VALUE ty_t_combo(
                       ( key = 'None'  text = 'None' )
                       ( key = 'SingleSelect' text = 'SingleSelect' )
                       ( key = 'SingleSelectLeft' text = 'SingleSelectLeft' )
                       ( key = 'MultiSelect'  text = 'MultiSelect' ) ) )
                   )->item(
                       key = '{KEY}'
                       text = '{TEXT}' ).



    lo_tab->tab(
                text     = 'Columns'
                selected = client->_bind( mv_check_columns )
       )->table(
      "  mode = 'MultiSelect'
        items = client->_bind( ms_layout-t_cols )
        )->columns(
            )->column( )->text( 'Visible' )->get_parent(
            )->column( )->text( 'Name' )->get_parent(
            )->column( )->text( 'Title' )->get_parent(
            )->column( )->text( 'Editable' )->get_parent(
            )->column( )->text( 'Length' )->get_parent(
        )->get_parent(
        )->items( )->column_list_item(
            )->cells(
                )->checkbox( '{VISIBLE}'
                )->text( '{NAME}'
                )->Input( '{TITLE}'
                  )->checkbox( '{EDITABLE}'
                  )->Input( '{LENGTH}'
         "       )->text( '{DESCR}'
    )->get_parent( )->get_parent( )->get_parent( )->get_parent(  )->get_parent( ).

    DATA(lo_tab_sort) = lo_tab->tab(
                   text     = 'Sort'
                   selected = client->_bind( mv_check_sort ) ).

    lo_tab_sort->button( icon = `sap-icon://add` press = client->_event(  `SORT_ADD`  ) ).

    DATA(lo_hbox) = lo_tab_sort->list(
           items           = client->_bind( ms_layout-t_sort )
           selectionchange = client->_event( 'SELCHANGE' )
              )->custom_list_item(
                 )->hbox( ).

    lo_hbox->combobox(
                 selectedkey = `{NAME}`
                 items       = client->_bind( ms_layout-t_cols )
*                                    ( key = 'BLUE'  text = 'green' )
*                                    ( key = 'GREEN' text = 'blue' )
*                                    ( key = 'BLACK' text = 'red' )
*                                    ( key = 'GRAY'  text = 'gray' ) ) )
             )->item(
                     key = '{NAME}'
                     text = '{NAME}'
             )->get_parent(
              )->segmented_button( `{TYPE}`
)->items(
 )->segmented_button_item(
     key = 'DESCENDING'
     icon = 'sap-icon://sort-descending'
 )->segmented_button_item(
     key = 'ASCENDING'
     icon = 'sap-icon://sort-ascending'
)->get_parent( )->get_parent(
)->button( type = `Transparent` icon = 'sap-icon://decline' press = client->_event( val = `SORT_DELETE` data = `${NAME}` ) ).
*            )->get_parent( )->get_parent( )->get_parent(

*           )->button(
*                text  = 'counter descending'
*                icon = 'sap-icon://sort-descending'
*                press = client->_event( 'SORT_DESCENDING' )
*            )->button(
*                text  = 'counter ascending'
*                icon = 'sap-icon://sort-ascending'
*                press = client->_event( 'SORT_ASCENDING' )
*              )->get_parent( ).


*        lo_tab->tab(
*                        text     = 'Group'
*                        selected = client->_bind( mv_check_group )
*                 )->get_parent( )->get_parent( ).

    ro_popup->footer( )->overflow_toolbar(
          )->toolbar_spacer(
          )->button(
              text  = 'continue'
              press = client->_event( 'POPUP_FILTER_CONTINUE' )
              type  = 'Emphasized' ).

    app-next-xml_popup = ro_popup->get_root( )->xml_get( ).

  ENDMETHOD.


  METHOD z2ui5_on_render_pop_filter.

    DATA(lo_popup) = z2ui5_cl_xml_view=>factory_popup( ).

    lo_popup->dialog( 'abap2UI5 - Popup to select entry'
        )->table(
            mode = 'MultiSelect'
            items = client->_bind( ms_layout-t_filter_show )
            )->columns(
                )->column( )->text( 'Title' )->get_parent(
                )->column( )->text( 'Color' )->get_parent(
                )->column( )->text( 'Info' )->get_parent(
                )->column( )->text( 'Description' )->get_parent(
            )->get_parent(
            )->items( )->column_list_item( selected = '{SELKZ}'
                )->cells(
             "       )->checkbox( '{SELKZ}'
                    )->text( '{NAME}'
                    )->text( '{VALUE}'
             "       )->text( '{DESCR}'
        )->get_parent( )->get_parent( )->get_parent( )->get_parent(
        )->footer( )->overflow_toolbar(
            )->toolbar_spacer(
            )->button(
                text  = 'continue'
                press = client->_event( 'POPUP_FILTER_CONTINUE' )
                type  = 'Emphasized' ).

    app-next-xml_popup = lo_popup->get_root( )->xml_get( ).

  ENDMETHOD.


  METHOD z2ui5_on_render_pop_detail.

    DATA(lo_popup) = z2ui5_cl_xml_view=>factory_popup( ).

    lo_popup->popover( placement = `Bottom` title = 'abap2UI5 - Layout'  contentwidth = `50%`
        )->input( description = `Name` value = client->_bind( mv_layout_name )
        )->button( text = `Save` press = client->_event( `BUTTON_SAVE_LAYOUT` )
        )->table(
            mode = 'SingleSelectLeft'
            items = client->_bind( mt_db_layout )
            )->columns(
                )->column( )->text( 'Name' )->get_parent(
                )->column( )->text( 'User' )->get_parent(
                )->column( )->text( 'Default' )->get_parent(
             "   )->column( )->text( 'Description' )->get_parent(
            )->get_parent(
            )->items( )->column_list_item( selected = '{SELKZ}'
                )->cells(
             "       )->checkbox( '{SELKZ}'
                    )->text( '{NAME}'
                    )->text( '{USER}'
                    )->text( '{DEFAULT}'
             "       )->text( '{DESCR}'
        )->get_parent( )->get_parent( )->get_parent( )->get_parent(
        )->footer( )->overflow_toolbar(
            )->toolbar_spacer(
             )->button(
                text  = 'load'
                press = client->_event( 'POPUP_LAYOUT_LOAD' )
                type  = 'Emphasized'
            )->button(
                text  = 'close'
                press = client->_event( 'POPUP_LAYOUT_CONTINUE' )
                type  = 'Emphasized' ).

    app-next-xml_popup = lo_popup->get_root( )->xml_get( ).

  ENDMETHOD.


  METHOD z2ui5_on_render_pop_layout.

    DATA(lo_popup) = z2ui5_cl_xml_view=>factory_popup( ).

    lo_popup->popover( placement = `Bottom` title = 'abap2UI5 - Layout'  contentwidth = `50%`
        )->input( description = `Name` value = client->_bind( mv_layout_name )
        )->button( text = `Save` press = client->_event( `BUTTON_SAVE_LAYOUT` )
        )->table(
            mode = 'SingleSelectLeft'
            items = client->_bind( mt_db_layout )
            )->columns(
                )->column( )->text( 'Name' )->get_parent(
                )->column( )->text( 'User' )->get_parent(
                )->column( )->text( 'Default' )->get_parent(
             "   )->column( )->text( 'Description' )->get_parent(
            )->get_parent(
            )->items( )->column_list_item( selected = '{SELKZ}'
                )->cells(
             "       )->checkbox( '{SELKZ}'
                    )->text( '{NAME}'
                    )->text( '{USER}'
                    )->text( '{DEFAULT}'
             "       )->text( '{DESCR}'
        )->get_parent( )->get_parent( )->get_parent( )->get_parent(
        )->footer( )->overflow_toolbar(
            )->toolbar_spacer(
             )->button(
                text  = 'load'
                press = client->_event( 'POPUP_LAYOUT_LOAD' )
                type  = 'Emphasized'
            )->button(
                text  = 'close'
                press = client->_event( 'POPUP_LAYOUT_CONTINUE' )
                type  = 'Emphasized' ).

    app-next-xml_popup = lo_popup->get_root( )->xml_get( ).

  ENDMETHOD.


  METHOD z2ui5_set_download_csv.

    DATA(lo_struc) = CAST cl_abap_structdescr( cl_abap_structdescr=>describe_by_data( ms_view-t_tab[ 1 ] ) ).
    DATA(lt_components) = lo_struc->get_components( ).

    DATA(lv_row) = ``.
    LOOP AT lt_components INTO DATA(lv_name) FROM 2.
      lv_row = lv_row && lv_name-name && `;`.
    ENDLOOP.
    lv_row = lv_row && cl_abap_char_utilities=>cr_lf.


    LOOP AT ms_view-t_tab REFERENCE INTO DATA(lr_row) FROM 2.

      DATA(lv_index) = 2.
      DO.
        ASSIGN COMPONENT lv_index OF STRUCTURE lr_row->* TO FIELD-SYMBOL(<field>).
        IF sy-subrc <> 0.
          EXIT.
        ENDIF.
        lv_row = lv_row && <field>.
        lv_index = lv_index + 1.
        lv_row = lv_row && `;`.
      ENDDO.

      lv_row = lv_row && cl_abap_char_utilities=>cr_lf.
    ENDLOOP.

    DATA lv_bas64enc TYPE string.

    lv_bas64enc = encode_base64( lv_row ).

    i_view->zz_plain( `<html:iframe src="data:text/csv;base64,` && lv_bas64enc && `" hidden="hidden" />`).

    mv_check_download_csv = abap_false.

  ENDMETHOD.


  METHOD encode_base64.

    TRY.
        CALL METHOD ('CL_WEB_HTTP_UTILITY')=>encode_base64
          EXPORTING
            unencoded = val
          RECEIVING
            encoded   = result.

      CATCH cx_sy_dyn_call_illegal_class.

        DATA(classname) = 'CL_HTTP_UTILITY'.
        CALL METHOD (classname)=>encode_base64
          EXPORTING
            unencoded = val
          RECEIVING
            encoded   = result.

    ENDTRY.

  ENDMETHOD.


  METHOD z2ui5_set_search.

    ms_view-t_tab = CORRESPONDING #( mt_table ).
    IF ms_view-search_val IS NOT INITIAL.
      LOOP AT ms_view-t_tab REFERENCE INTO DATA(lr_row).
        DATA(lv_row) = ``.
        DATA(lv_index) = 1.
        DO.
          ASSIGN COMPONENT lv_index OF STRUCTURE lr_row->* TO FIELD-SYMBOL(<field>).
          IF sy-subrc <> 0.
            EXIT.
          ENDIF.
          lv_row = lv_row && <field>.
          lv_index = lv_index + 1.
        ENDDO.

        IF lv_row NS ms_view-search_val.
          DELETE ms_view-t_tab.
        ENDIF.
      ENDLOOP.
    ENDIF.

  ENDMETHOD.


  METHOD z2ui5_set_detail.

    ms_detail = mt_table[ uuid = client->get( )-event_data ].

    SELECT SINGLE FROM z2ui5_t_draft
      FIELDS *
      WHERE uuid = @ms_detail-uuid
    INTO CORRESPONDING FIELDS OF @ms_detail
    .

  ENDMETHOD.


  METHOD z2ui5_set_sort.

    "quick and dirty - todo
    "only works for 2 conditions
    TRY.
        IF ms_layout-t_sort IS NOT INITIAL.
          DATA(ls_field1) = VALUE #( ms_layout-t_sort[ 1 ] OPTIONAL ).
          DATA(ls_field2) = VALUE #( ms_layout-t_sort[ 2 ] OPTIONAL ).

          SORT ms_view-t_tab BY
            (ls_field1-name) (ls_field1-type)
            (ls_field2-name) (ls_field2-type).

        ENDIF.
      CATCH cx_root.
    ENDTRY.

  ENDMETHOD.


  METHOD z2ui5_set_filter.

      io_box->search_field(
                    value = client->_bind( ms_view-search_val )
                    search = client->_event( 'BUTTON_SEARCH' )
                    change = client->_event( 'BUTTON_SEARCH' )
                    width = `17.5rem`
                    id    = `SEARCH`
              ).

    IF line_exists( ms_layout-t_filter_show[  name = `UUID` selkz = abap_true  ] ).
      io_box->input( value = client->_bind( ms_layout-s_filter-uuid ) description = `UUID` ).
    ENDIF.

    IF line_exists( ms_layout-t_filter_show[  name = `UUID_PREV` selkz = abap_true ] ).
      io_box->input( value = client->_bind( ms_layout-s_filter-uuid_prev ) description = `UUID_PREV` ).
    ENDIF.

    "todo other columns...

    DATA(rt_filter)  = ms_layout-t_filter_show.
    DELETE rt_filter WHERE selkz = abap_false.

    io_box->get_parent( )->hbox( justifycontent = `End`
        )->button( text = `Go` press = client->_event( `BUTTON_START` ) type = `Emphasized`
        )->button( text = `Adapt Filters (` && shift_right( CONV string( lines(  rt_filter ) ) ) && `)`  press = client->_event( `POPUP_FILTER` )
        ).

  ENDMETHOD.


  METHOD z2ui5_set_data.

    "dirty solution
    "todo: map filters to rangetab and make a nice select

    IF ms_layout-s_filter-uuid IS INITIAL.

      SELECT FROM z2ui5_t_draft
          FIELDS uuid, uuid_prev, timestampl, uname
        INTO CORRESPONDING FIELDS OF TABLE @mt_table
          UP TO 50 ROWS.

    ELSE.

      SELECT FROM z2ui5_t_draft
      FIELDS uuid, uuid_prev, timestampl, uname
      WHERE uuid = @ms_layout-s_filter-uuid
            INTO CORRESPONDING FIELDS OF TABLE @mt_table
                    UP TO 50 ROWS.

    ENDIF.

    ms_view-t_tab = CORRESPONDING #( mt_table ).

  ENDMETHOD.
ENDCLASS.
