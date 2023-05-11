CLASS z2ui5_cl_app_demo_49 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

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
        data                TYPE string,
      END OF ty_s_out.

    DATA:
      BEGIN OF ms_view,
        headerpinned   TYPE abap_bool,
        headerexpanded TYPE abap_bool,
        search_val     TYPE string,
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

    DATA mt_cols TYPE STANDARD TABLE OF ty_S_cols.

    TYPES:
      BEGIN OF ty_S_filter,
        selkz TYPE abap_bool,
        name  TYPE string,
        value TYPE string,
      END OF ty_S_filter.

*    DATA mt_filter TYPE STANDARD TABLE OF ty_S_filter.


*    DATA:
*      BEGIN OF ms_table,
*        check_zebra   TYPE abap_bool,
*        title         TYPE string,
*        sticky_header TYPE string,
*        selmode       TYPE string,
*      END OF ms_table.

    TYPES:
      BEGIN OF ty_S_sort,
        "  selkz      TYPE abap_bool,
        name TYPE string,
        type TYPE string,
        " descr      TYPE string,
        "  check_descending TYPE string,
      END OF ty_S_sort.

    DATA mt_sort TYPE STANDARD TABLE OF ty_S_sort.

data:
  begin of ms_layout,
       BEGIN OF s_table,
        check_zebra   TYPE abap_bool,
        title         TYPE string,
        sticky_header TYPE string,
        selmode       TYPE string,
      END OF s_table,
       t_filter TYPE STANDARD TABLE OF ty_S_filter,
  end of ms_layout.

    TYPES:
      BEGIN OF s_combobox,
        key  TYPE string,
        text TYPE string,
      END OF s_combobox.

    TYPES ty_t_combo TYPE STANDARD TABLE OF s_combobox WITH EMPTY KEY.

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
    METHODS z2ui5_download_csv
      IMPORTING
        i_view TYPE REF TO z2ui5_cl_xml_view.

ENDCLASS.



CLASS z2ui5_cl_app_demo_49 IMPLEMENTATION.


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

      WHEN 'BUTTON_DELETE'.
        DELETE ms_view-t_tab WHERE selkz = abap_true.

      WHEN 'BUTTON_CUSTOM'.
        client->popup_message_box( `custom action called` ).

     when  'BUTTON_START'.

    SELECT FROM z2ui5_t_draft
        FIELDS uuid, uuid_prev, timestampl, uname
      INTO CORRESPONDING FIELDS OF TABLE @mt_table
        UP TO 50 ROWS.
ms_view-t_tab = CORRESPONDING #( mt_table ).

      WHEN 'BUTTON_DOWNLOAD'.
        mv_check_download_csv = abap_true.

      WHEN 'BUTTON_SEARCH'.
        app-next-s_cursor_pos-id = 'SEARCH'.
        app-next-s_cursor_pos-cursorpos = '99'.
        app-next-s_cursor_pos-selectionend = '99'.
        app-next-s_cursor_pos-selectionstart = '99'.
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

      WHEN 'MAIN'.
        app-view_main = 'MAIN'.

      WHEN 'DETAIL'.

        ms_detail = mt_table[ uuid = client->get( )-event_data ].

        SELECT SINGLE FROM z2ui5_t_draft
          FIELDS *
          WHERE uuid = @ms_detail-uuid
        INTO CORRESPONDING FIELDS OF @ms_detail
        .

        app-view_main = 'DETAIL'.

      WHEN 'BUTTON_POST'.

        SELECT FROM z2ui5_t_draft
            FIELDS *
          INTO CORRESPONDING FIELDS OF TABLE @mt_table
            UP TO 100 ROWS.


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
        client->nav_app_leave( client->get_app( app-get-id_prev_app_stack ) ).

    ENDCASE.

  ENDMETHOD.


  METHOD z2ui5_on_init.

    app-view_main  = 'MAIN'.
    init_table_output( ).

    ms_layout-s_table-selmode = 'MultiSelect'.
     ms_layout-s_table-check_zebra = abap_true.
    ms_view-t_tab = CORRESPONDING #( mt_table ).
     ms_layout-s_table-sticky_header = `HeaderToolbar,InfoToolbar,ColumnHeaders`.
     ms_layout-s_table-title = `Drafts`.

  ENDMETHOD.


  METHOD z2ui5_on_render.

    CASE app-view_popup.
      WHEN `POPUP_FILTER`.
        z2ui5_on_render_pop_filter( ).
      WHEN `POPUP_SETUP`.
        z2ui5_on_render_pop_setup( ).
    ENDCASE.

    CASE app-view_main.
      WHEN 'MAIN'.
        z2ui5_on_render_main( ).
      WHEN 'DETAIL'.
        z2ui5_on_render_detail( ).
    ENDCASE.

  ENDMETHOD.

  METHOD init_table_output.

   " CLEAR  ms_layout-s_table.
    CLEAR mt_cols.
    CLEAR mt_sort.

    ms_view-headerexpanded = abap_true.
    ms_view-headerpinned   = abap_true.

    DATA(lt_cols)   = lcl_db=>get_fieldlist_by_table( mt_table ).
    LOOP AT lt_cols REFERENCE INTO DATA(lr_col) FROM 2.

      INSERT VALUE #(
        name = lr_col->*
      ) INTO TABLE  ms_layout-t_filter.

      INSERT VALUE #(
         visible = abap_true
         name = lr_col->*
       "  length = `10px`
         title = lr_col->*
       ) INTO TABLE mt_cols.

      INSERT VALUE #(
       "  selkz = abap_true
         name = lr_col->*
      "   length = `10px`
       ) INTO TABLE mt_sort.

    ENDLOOP.

  ENDMETHOD.


  METHOD z2ui5_on_render_main.

    "   DATA(view) = z2ui5_cl_xml_view=>factory( )->shell( ).

    DATA(view) = z2ui5_cl_xml_view=>factory(
        )->page(
                title          = 'abap2UI5 - List Report'
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
      z2ui5_download_csv( view ).
    ENDIF.

    DATA(page) = view->dynamic_page(
            headerexpanded = client->_bind( ms_view-headerexpanded )
            headerpinned   = client->_bind(  ms_view-headerpinned  ) ).

    DATA(header_title) = page->title( ns = 'f'
            )->get( )->dynamic_page_title( ).

    header_title->heading( ns = 'f' )->title( 'Standart' ).

    header_title->expanded_content( 'f'
             )->label( text = 'Drafts of abap2UI5' ).

    header_title->snapped_content( ns = 'f'
             )->label( text = 'Drafts of abap2UI5' ).

  header_title->actions( ns = 'f' )->overflow_toolbar(
      )->button( text = `Layout` type = `Emphasized`
      )->button( text = `Start` press = client->_event( `BUTTON_START` ) type = `Emphasized`
      ).

  data(lo_box) = page->header( )->dynamic_page_header( pinnable = abap_true
       )->flex_box( alignItems = `Start` justifyContent = `SpaceBetween` ).


    data(lt_filter) = ms_layout-t_filter.
    DELETE lt_filter where selkz = abap_false.

       loop at lt_filter REFERENCE INTO data(lr_filter)
        where selkz = abap_true.
        lo_box->input( description = lr_filter->name ).
       endloop.


    lo_box->button( text = `Change Filter (` && shift_right( conv string( lines( lt_filter ) ) ) && `)`  press = client->_event( `POPUP_FILTER` )  ).



    DATA(cont) = page->content( ns = 'f' ).

    DATA(tab) = cont->table(
        items = client->_bind( val = ms_view-t_tab )
        alternaterowcolors = ms_layout-s_table-check_zebra
        sticky = ms_layout-s_table-sticky_header
        mode = ms_layout-s_table-selmode ).

    tab->header_toolbar(
          )->toolbar(
              )->title( text = ms_layout-s_table-title && ` (` && shift_right( CONV string( lines( ms_view-t_tab ) ) ) && `)` level = `H2`
                  )->toolbar_spacer(
              )->button(
                  icon = 'sap-icon://refresh'
                  press = client->_event( 'BUTTON_REFRESH' )
              )->search_field(
                    value = client->_bind( ms_view-search_val )
                    search = client->_event( 'BUTTON_SEARCH' )
                    change = client->_event( 'BUTTON_SEARCH' )
*                    liveChange = client->_event( 'BUTTON_SEARCH' )
                    width = `17.5rem`
                    id    = `SEARCH`

      )->toolbar_spacer(
             )->button(
                text = `Custom Action`
                  press = client->_event( 'BUTTON_CUSTOM' )

              )->button(
                  text = `Anlegen`
                  enabled = abap_false
                  press = client->_event( 'BUTTON_CREATE' )
                     )->button(
                  text = `Löschen`
                  press = client->_event( 'BUTTON_DELETE' )
              )->button(
                  icon = 'sap-icon://action-settings'
                  press = client->_event( 'BUTTON_SETUP' )
              )->button(
                  icon = 'sap-icon://download'
                  press = client->_event( 'BUTTON_DOWNLOAD' )
              ).


    DATA(lo_columns) = tab->columns( ).
    LOOP AT mt_cols REFERENCE INTO DATA(lr_field)
          WHERE visible = abap_true.
      lo_columns->column( width = lr_field->length )->text(  text = CONV char10( lr_field->title )
        )->footer(
        )->object_number( number = `10` unit = 'ST' state = `Warning` ).
    ENDLOOP.

    DATA(lo_cells) = tab->items( )->column_list_item(
        press = client->_event( val = 'DETAIL' data = `${UUID}` )
        selected = `{SELKZ}`
        type = `Navigation` )->cells( ).
    LOOP AT mt_cols REFERENCE INTO lr_field
          WHERE visible = abap_true.
      IF lr_field->editable = abap_true.
        lo_cells->input( `{` && lr_field->name && `}` ).
      ELSE.
        lo_cells->text(  `{` && lr_field->name && `}` ).
      ENDIF.
    ENDLOOP.

    app-next-xml_main = page->get_root( )->xml_get( ).

  ENDMETHOD.


  METHOD z2ui5_on_render_detail.

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
               )->checkbox( client->_bind( ms_layout-s_table-check_zebra )
               )->label( 'sticky header'
               )->input( client->_bind( ms_layout-s_table-sticky_header )
               )->label( text = `Title`
               )->Input( value = client->_bind( ms_layout-s_table-title )
               )->label( 'sel mode'
               )->combobox(
                   selectedkey = client->_bind( ms_layout-s_table-selmode )
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
        items = client->_bind( mt_cols )
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

    DATA(lo_hbox) = lo_tab->tab(
                  text     = 'Sort'
                  selected = client->_bind( mv_check_sort )

          )->list(
           items           = client->_bind( mt_sort )
           selectionchange = client->_event( 'SELCHANGE' )
              )->custom_list_item(
                 )->hbox( ).

    lo_hbox->combobox(
                 selectedkey = `{NAME}`
                 items       = client->_bind( mt_cols )
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
)->text( text = `{TYPE}`
)->button( text = 'close' ).
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
            items = client->_bind( ms_layout-t_filter )
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


  METHOD z2ui5_download_csv.

    DATA lv_bas64enc TYPE string VALUE 'Teststring'.

    DATA(lo_struc) = CAST cl_abap_structdescr( cl_abap_structdescr=>describe_by_data( ms_view-t_tab[ 1 ] ) ).
    DATA(lt_components) = lo_struc->get_components( ).

    DATA(lv_row) = ``.
    LOOP AT lt_components INTO DATA(lv_name).
      lv_row = lv_row && lv_name-name && `;`.
    ENDLOOP.
    lv_row = lv_row && cl_abap_char_utilities=>cr_lf.


    LOOP AT ms_view-t_tab REFERENCE INTO DATA(lr_row).

      DATA(lv_index) = 1.
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

    lv_bas64enc = cl_web_http_utility=>encode_base64( lv_row ).

    i_view->zz_plain( `<html:iframe src="data:text/csv;base64,` && lv_bas64enc && `" hidden="hidden" />`).

    mv_check_download_csv = abap_false.

  ENDMETHOD.

ENDCLASS.
