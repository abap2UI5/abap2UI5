CLASS z2ui5_cl_app_demo_49 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    DATA mt_table TYPE STANDARD TABLE OF z2ui5_t_draft.
    DATA ms_detail TYPE z2ui5_t_draft.
    DATA mv_check_columns TYPE abap_bool.
    DATA mv_check_sort TYPE abap_bool.
    DATA mv_check_table TYPE abap_bool.
    DATA mv_check_group TYPE abap_bool.

    DATA mv_contentheight TYPE string VALUE `70%`.
    DATA mv_contentwidth TYPE string VALUE `70%`.

    DATA mv_check_download_csv TYPE abap_bool.

    DATA:
      BEGIN OF ms_view,
        headerpinned   TYPE abap_bool,
        headerexpanded TYPE abap_bool,
        search_val     TYPE string,
        t_tab          TYPE STANDARD TABLE OF z2ui5_t_draft WITH EMPTY KEY,
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

    DATA mt_filter TYPE STANDARD TABLE OF ty_S_filter.


    DATA:
      BEGIN OF ms_table,
        check_zebra   TYPE abap_bool,
        title         TYPE string,
        sticky_header TYPE abap_bool,
        selmode       TYPE string,
      END OF ms_table.


    TYPES:
      BEGIN OF ty_S_sort,
        "  selkz      TYPE abap_bool,
        name TYPE string,
        type TYPE string,
        " descr      TYPE string,
        "  check_descending TYPE string,
      END OF ty_S_sort.

    DATA mt_sort TYPE STANDARD TABLE OF ty_S_sort.

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

  PRIVATE SECTION.
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

      WHEN 'BUTTON_DOWNLOAD'.
        mv_check_download_csv = abap_true.


      WHEN 'BUTTON_SEARCH'.
        app-next-s_cursor_pos-id = 'SEARCH'.
        app-next-s_cursor_pos-cursorpos = '99'.
        app-next-s_cursor_pos-selectionend = '99'.
        app-next-s_cursor_pos-selectionstart = '99'.
        ms_view-t_tab = mt_table.
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
        " DATA(lv_row_title) = client->get( )-event_data.
        ms_detail = mt_table[ uuid = client->get( )-event_data ].
        app-view_main = 'DETAIL'.


      WHEN 'BUTTON_POST'.

*        CREATE DATA mt_table TYPE STANDARD TABLE OF (mv_name).
*        "FIELD-SYMBOLS <tab> TYPE table.
*        ASSIGN mt_table->* TO <tab>.

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
    ms_view-t_tab = mt_table.

  ENDMETHOD.


  METHOD z2ui5_on_render.

    DATA(lo_popup) = z2ui5_cl_xml_view=>factory_popup( ).

    CASE app-view_popup.

      WHEN `POPUP_FILTER`.

        lo_popup->dialog( 'abap2UI5 - Popup to select entry'
            )->table(
                mode = 'MultiSelect'
                items = client->_bind( mt_filter )
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

      WHEN `POPUP_SETUP`.

        lo_popup = lo_popup->dialog( title = 'View Setup'  resizable = abap_true
             contentheight = client->_bind( mv_contentheight ) contentwidth = client->_bind( mv_contentwidth ) ).

        lo_popup->custom_header(
              )->bar(
                  )->content_right(
              )->button( text = `zurücksetzten` press = client->_event( 'BUTTON_INIT' ) ).


        DATA(lo_tab) = lo_popup->tab_container( ).

        DATA(lo_cont) = lo_tab->tab(
                    text     = 'Table'
                    selected = client->_bind( mv_check_table ) ).

        lo_cont->hbox(
           )->text( `zebra mode`
           )->checkbox( client->_bind( ms_table-check_zebra ) ).

        lo_cont->hbox(
                  )->text( `sticky header`
                  )->checkbox( client->_bind( ms_table-sticky_header ) ).


        lo_cont->hbox(
           )->text( `Title`
           )->Input( client->_bind( ms_table-title ) ).

        lo_cont->hbox(
         )->text( `SelMode`
         )->input( client->_bind( ms_table-selmode ) ).

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
            )->items( )->column_list_item( "selected = '{SELKZ}'
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

        lo_popup->footer( )->overflow_toolbar(
              )->toolbar_spacer(
              )->button(
                  text  = 'continue'
                  press = client->_event( 'POPUP_FILTER_CONTINUE' )
                  type  = 'Emphasized' ).

    ENDCASE.

    app-next-xml_popup = lo_popup->get_root( )->xml_get( ).


    CASE app-view_main.
      WHEN 'MAIN'.
        z2ui5_on_render_main( ).
      WHEN 'DETAIL'.
        z2ui5_on_render_detail( ).
    ENDCASE.

  ENDMETHOD.

  METHOD init_table_output.

    CLEAR mt_filter.
    CLEAR mt_cols.
    CLEAR mt_sort.

    ms_view-headerexpanded = abap_true.
    ms_view-headerpinned   = abap_true.


    SELECT FROM z2ui5_t_draft
        FIELDS uuid, uuid_prev, timestampl, uname
      INTO CORRESPONDING FIELDS OF TABLE @mt_table
        UP TO 5 ROWS.


    DATA(lt_cols)   = lcl_db=>get_fieldlist_by_table( mt_table ).
    LOOP AT lt_cols REFERENCE INTO DATA(lr_col) FROM 2.

      INSERT VALUE #(
        name = lr_col->*
      ) INTO TABLE mt_filter.

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
                title          = 'abap2UI5 - Popups'
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
      DATA: lv_bas64enc TYPE string VALUE 'Teststring'.
      DATA: lv_base64dec TYPE string.

      DATA(lo_struc) = CAST cl_abap_structdescr( cl_abap_structdescr=>describe_by_data( ms_view-t_tab[ 1 ] ) ).
      DATA(lt_components) = lo_struc->get_components( ).

            DATA(lv_row) = ``.
       loop at lt_components into data(lv_name).
       lv_row = lv_row && lv_name-name && `;`.
       endloop.
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

      cl_web_http_utility=>encode_base64(
                              EXPORTING
                                unencoded = lv_row
                              RECEIVING
                                encoded   = lv_bas64enc ).

      view->zz_plain( `<html:iframe src="data:text/csv;base64,` && lv_bas64enc && `" hidden="hidden" />`).

      mv_check_download_csv = abap_false.
    ENDIF.
    DATA(page) = view->dynamic_page(
            headerexpanded = client->_bind( ms_view-headerexpanded )
            headerpinned   = client->_bind(  ms_view-headerpinned  ) ).

    DATA(header_title) = page->title( ns = 'f' )->get( )->dynamic_page_title( ).

    header_title->heading( ns = 'f' )->title( 'Header Title' ).

    header_title->expanded_content( 'f'
             )->label( text = 'this is a subheading' ).

    header_title->snapped_content( ns = 'f'
             )->label( text = 'this is a subheading' ).

*    header_title->actions( ns = 'f' )->overflow_toolbar(
*         )->overflow_toolbar_button(
*             icon    = `sap-icon://edit`
*             text    = 'edit header'
*             type    = 'Emphasized'
*             tooltip = 'edit'
*         )->overflow_toolbar_button(
*             icon    = `sap-icon://pull-down`
*             text    = 'show section'
*             type    = 'Emphasized'
*             tooltip = 'pull-down'
*         )->overflow_toolbar_button(
*             icon = `sap-icon://show`
*             text = 'show state'
*             tooltip = 'show'
*         )->button(
*            " icon = `sap-icon://edit`
*             text = 'Go Back'
*             press = client->_event( 'BACK' )
*         ).
*
*    header_title->navigation_actions(
*            )->button( icon = 'sap-icon://full-screen' type  = 'Transparent'
*            )->button( icon = 'sap-icon://exit-full-screen' type  = 'Transparent'
*            )->button( icon = 'sap-icon://decline' type  = 'Transparent'
*    ).

    page->header( )->dynamic_page_header(  pinnable = abap_true
       )->horizontal_layout(
           )->vertical_layout(
                  )->object_attribute( title = 'Location' text = 'Warehouse A'
                  )->object_attribute( title = 'Halway' text = '23L'
                  )->object_attribute( title = 'Rack' text = '34'
            )->get_parent(
              )->vertical_layout(
                   )->object_attribute( title = 'Location' text = 'Warehouse A'
                   )->object_attribute( title = 'Halway' text = '23L'
                   )->object_attribute( title = 'Rack' text = '34'
            )->get_parent(
             )->vertical_layout(
                  )->object_attribute( title = 'Location' text = 'Warehouse A'
                  )->object_attribute( title = 'Halway' text = '23L'
                  )->object_attribute( title = 'Rack' text = '34'
            ).

    DATA(cont) = page->content( ns = 'f' ).

    DATA(tab) = cont->table( items = client->_bind( val = ms_view-t_tab ) ). "mt_table ) ).

    tab->header_toolbar(
          )->toolbar(
              )->title( text = `Drafts (23)` level = `H2`
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
               "   icon = 'sap-icon://refresh'
                text = `Custom Action`
                  press = client->_event( 'BUTTON_CUSTOM' )

              )->button(
                  text = `Anlegen`
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



*"WRITE: / 'Base64 dec:', lv_base64dec.
*
*DATA: text TYPE string VALUE 'TestString.'.

    "START-OF-SELECTION.

*  "WRITE: / text.
*
*  DATA(o_base64) = NEW cl_hard_wired_encryptor( ).
*
*  DATA(enc_string) = o_base64->encrypt_string2string( text ).
* " WRITE: / 'Base64 encrypt_string2string: ', enc_string.
*
*  DATA(dec_string) = o_base64->decrypt_string2string( enc_string ).
* " WRITE: / 'Base64 decrypt_string2string: ', dec_string.
*
*  DATA(enc_xstring) = o_base64->encrypt_string2bytes( dec_string ).
* " WRITE: / 'Base64 encrypt_string2bytes:  ', enc_xstring.
*
*  DATA(enc_bytes) = o_base64->encrypt_bytes2bytes( enc_xstring ).
* "
*  DATA(dec_bytes) = o_base64->decrypt_bytes2bytes( enc_bytes ).
* " WRITE: / 'Base64 decrypt_bytes2bytes:   ', dec_bytes.
*
*  DATA(dec_string2) = o_base64->decrypt_bytes2string( dec_bytes ).
* " WRITE: / 'Base64 decrypt_bytes2string:  ', dec_string2.
*
*data lv_xstring type xstring.
*data lv_base64 type string.
*
*CALL FUNCTION 'SCMS_BASE64_ENCODE_STR'
*        EXPORTING
*          input  = lv_xstring
*        IMPORTING
*          output = lv_base64.
*
*         CALL METHOD cl_http_utility=>if_http_utility~decode_x_base64
*    EXPORTING
*      encoded = lv_base64
*    RECEIVING
*      decoded = lv_xstring.
*
*      DATA: xstr TYPE xstring,
*      str  TYPE string.
*TRY.
*
*str = cl_abap_codepage=>convert_from( source = xstr ). " default is UTF-8
*
*xstr = cl_abap_codepage=>convert_to( source = str ). " default is UTF-8
*
*CATCH cx_root.
*  " handle conversion errors
*ENDTRY.

  ENDMETHOD.


  METHOD z2ui5_on_render_detail.

    "  DATA(view) = z2ui5_cl_xml_view=>factory( )->shell( ).

    DATA(view) = z2ui5_cl_xml_view=>factory(
        )->page(
                title          = 'abap2UI5 - Popups'
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
                )->title( text = 'Oblomov Dev' wrapping = abap_true ).

    header_title->snapped_heading(
            )->flex_box( alignitems = `Center`
              )->avatar( src = `` class = 'sapUiTinyMarginEnd'
                )->title( text = 'Oblomov Dev' wrapping = abap_true ).

    header_title->expanded_content( ns = `uxap` )->text( `abap2UI5 Developer` ).
    header_title->snapped_Content( ns = `uxap` )->text( `abap2UI5 Developer` ).
    header_title->snapped_Title_On_Mobile( )->title( `abap2UI5 Developer` ).

    header_title->actions( ns = `uxap` )->overflow_toolbar(
         )->overflow_toolbar_button(
             icon    = `sap-icon://edit`
             text    = 'edit header'
             type    = 'Emphasized'
             tooltip = 'edit'
         )->overflow_toolbar_button(
             icon    = `sap-icon://pull-down`
             text    = 'show section'
             type    = 'Emphasized'
             tooltip = 'pull-down'
         )->overflow_toolbar_button(
             icon = `sap-icon://show`
             text = 'show state'
             tooltip = 'show'
         )->button(
            " icon = `sap-icon://edit`
             text = 'Go Back'
             press = client->_event( 'MAIN' )
         ).

    DATA(header_content) = page->header_Content( ns = 'uxap' ).

    header_content->flex_box( wrap = 'Wrap'
       )->avatar( src = `` class = 'sapUiSmallMarginEnd' displaySize = 'layout'
        )->vertical_layout( class = 'sapUiSmallMarginBeginEnd'
            )->link(  text    = '+33 6 4512 5158'
            )->link(  text    = 'email@email.com'
        )->get_parent(
        )->horizontal_layout( class = 'sapUiSmallMarginBeginEnd'
            )->label( text    = 'Hello! I an abap2UI5 developer'
            )->label( text    = 'San Jose, USA'
        )->get_parent(
        )->vertical_layout( class = 'sapUiSmallMarginBeginEnd'
            )->label(  text    = 'Hello! I an abap2UI5 developer'
            )->vbox(
                )->label( 'Achived goals'
                )->progress_indicator( percentvalue = '30%' displayvalue = '30%'
        )->get_parent(  )->get_parent(
        )->vertical_layout( class = 'sapUiSmallMarginBeginEnd'
            )->label(  text    = 'San Jose, USA'
        )->get_parent(
    ).


    DATA(sections) = page->sections( ).

    sections->object_page_section( titleuppercase = abap_false id = 'goalsSectionSS1' title = '2014 Goals Plan'
        )->heading( ns = `uxap`
            )->message_strip( text = 'this is a message strip'
        )->get_parent(
        )->sub_sections(
            )->object_page_sub_section( id = 'goalssubSectionSS1' title = 'goals1'
                )->blocks(
                      )->vbox(
                      )->label( text    = 'goals1'
                      )->label( text    = 'goals1'
                      )->label( text    = 'goals1'
                      )->label( text    = 'goals1'
                      )->label( text    = 'goals1'
                      )->label( text    = 'goals1'
                      )->label( text    = 'goals1'
                      )->label( text    = 'goals1'
                      )->label( text    = 'goals1'
                      )->label( text    = 'goals1'

            )->get_parent( )->get_parent( )->get_parent(
            )->object_page_sub_section( id = 'goalsSectionWS1' title = 'goals2'
                  )->blocks(
                        )->vbox(
                      )->label( text    = 'goals2'
                      )->label( text    = 'goals2'
                      )->label( text    = 'goals2'
                      )->label( text    = 'goals2'
                      )->label( text    = 'goals2'
                      )->label( text    = 'goals2'
                      )->label( text    = 'goals2'
                      )->label( text    = 'goals2').

    sections->object_page_section( titleuppercase = abap_false id = 'PersonalSection' title = 'Personal'
       )->heading( ns = `uxap`
      "     )->message_strip( text = 'this is a message strip'
       )->get_parent(
       )->sub_sections(
           )->object_page_sub_section( id = 'personalSectionSS1' title = 'Connect'
               )->blocks(
                     )->label( text    = 'telefon'
                     )->label( text    = 'email'
           )->get_parent( )->get_parent(
           )->object_page_sub_section( id = 'personalSectionWS2' title = 'Payment information  '
                 )->blocks(
                     )->label( text    = 'Hello! I an abap2UI5 developer'
                     )->label( text    = 'San Jose, USA' ).


    sections->object_page_section( titleuppercase = abap_false id = 'employmentSection' title = 'Employment'
     )->heading( ns = `uxap`
    "     )->message_strip( text = 'this is a message strip'
     )->get_parent(
     )->sub_sections(
         )->object_page_sub_section( id = 'empSectionSS1' title = 'Job information'
             )->blocks(
                   )->label( text    = 'info'
                   )->label( text    = 'info'
                   )->label( text    = 'info'
                   )->label( text    = 'info'
                   )->label( text    = 'info'
         )->get_parent( )->get_parent(
         )->object_page_sub_section( id = 'empSectionWS2' title = 'Employee Details '
               )->blocks(
                     )->vbox(
                   )->label( text    = 'details'
                   )->label( text    = 'details'
                   )->label( text    = 'details'
                   )->label( text    = 'details'
                   )->label( text    = 'details'
                   )->label( text    = 'details'
                   )->label( text    = 'details'
                   )->label( text    = 'details' ).

    app-next-xml_main = view->get_root( )->xml_get( ).


  ENDMETHOD.

ENDCLASS.
