CLASS z2ui5_cl_app_demo_49 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    DATA mt_table TYPE STANDARD TABLE OF z2ui5_t_draft.
    DATA mv_check_columns TYPE abap_bool.
    DATA mv_check_sort TYPE abap_bool.
    DATA mv_check_group TYPE abap_bool.

    TYPES:
      BEGIN OF ty_S_filter,
        selkz TYPE abap_bool,
        name  TYPE string,
        value TYPE string,
      END OF ty_S_filter.

    DATA mt_filter TYPE STANDARD TABLE OF ty_S_filter.

    TYPES:
      BEGIN OF ty_S_cols,
        selkz  TYPE abap_bool,
        name   TYPE string,
        length TYPE string,
      END OF ty_S_cols.

    DATA mt_cols TYPE STANDARD TABLE OF ty_S_cols.


    TYPES:
      BEGIN OF ty_S_sort,
      "  selkz      TYPE abap_bool,
        name             TYPE string,
        type          type string,
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

      WHEN 'BUTTON_TABLE'.
*        FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
*        CREATE DATA mt_table TYPE STANDARD TABLE OF (mv_name).
*        ASSIGN mt_table->* TO <tab>.



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

      WHEN 'BUTTON_CANCEL'.
        client->popup_message_toast( |cancel| ).
        app-view_popup = ''.

      WHEN 'BACK'.
        client->nav_app_leave( client->get_app( app-get-id_prev_app_stack ) ).

    ENDCASE.

  ENDMETHOD.


  METHOD z2ui5_on_init.

    app-view_main = 'VIEW_MAIN'.
    "    mv_name = `Z2UI5_T_DRAFT`.

    DATA(lt_cols)   = lcl_db=>get_fieldlist_by_table( mt_table ).
    LOOP AT lt_cols REFERENCE INTO DATA(lr_col) FROM 2.

      INSERT VALUE #(
        name = lr_col->*
      ) INTO TABLE mt_filter.

      INSERT VALUE #(
         selkz = abap_true
         name = lr_col->*
         length = `10px`
       ) INTO TABLE mt_cols.

      INSERT VALUE #(
       "  selkz = abap_true
         name = lr_col->*
      "   length = `10px`
       ) INTO TABLE mt_sort.

    ENDLOOP.

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

        lo_popup = lo_popup->dialog( title = 'View Setup'  contentheight = `70%` contentwidth = `70%` ).

         data(lo_tab) = lo_popup->tab_container( ).

            lo_tab->tab(
                        text     = 'Columns'
                        selected = client->_bind( mv_check_columns )
               )->table(
                mode = 'MultiSelect'
                items = client->_bind( mt_cols )
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
            )->get_parent( )->get_parent( )->get_parent( )->get_parent(  )->get_parent( ).

          data(lo_hbox) = lo_tab->tab(
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
       )->get_parent( )->get_parent( ).
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

    DATA(lo_view) = z2ui5_cl_xml_view=>factory( )->shell( )->page(
             title          = 'abap2UI5 - Change the table type with RTTI'
             navbuttonpress = client->_event( 'BACK' )
             shownavbutton  = abap_true
         )->header_content(
             )->link(
                 text = 'Source_Code' target = '_blank'
                 href = z2ui5_cl_xml_view=>hlp_get_source_code_url( app = me get = client->get( ) )
         )->get_parent(
         )->simple_form(
                title = 'SE16'
                editable = abap_true
                columnsm = `1`
                columnsl = `1`
                columnsxl = `1`
                layout = `ResponsiveGridLayout`
             )->content( `form` ).
*                 )->title( ns = `core` text = `Table`
*                 )->label( 'Name' ).

    "  lo_view->input( client->_bind( mv_name  ) ).

*    lo_view->button(
*                text  = 'search'
*                press = client->_event( 'BUTTON_TABLE' )
*            ).





*    lo_view = lo_view->get_parent( )->get_parent( )->simple_form( title = 'cols' editable = abap_true
*            )->content( 'form' ).

    lo_view->title( ns = `core` text = 'Filter' ).

    lo_view->button(
            text  = 'filter'
            press = client->_event( 'POPUP_FILTER' )
        ).

    LOOP AT mt_filter REFERENCE INTO DATA(lr_col)
        WHERE selkz = abap_true.
      lo_view->label( lr_col->name ).
      lo_view->input( lr_col->value ).
    ENDLOOP.

*    lo_view->button(
*                text  = 'search'
*                press = client->_event( 'BUTTON_POST' )
*            ).

*    IF mt_table IS not INITIAL.


    SELECT FROM z2ui5_t_draft
        FIELDS *
      INTO CORRESPONDING FIELDS OF TABLE @mt_table
        UP TO 5 ROWS.

    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
    ASSIGN mt_table TO <tab>.
*   DATA(tab) = lo_view->get_parent( )->get_parent( )->simple_form( title = 'Table' editable = abap_true
*              )->content( 'form' )->table(
*                items = client->_bind( val = <tab> ) " check_gen_data = abap_true )
*            ).

    DATA(tab) = lo_view->title( ns = `core` text = 'Content - Tablename' )->table(
                     items = client->_bind( val = <tab> )
                 ).

    tab->header_toolbar(
          )->overflow_toolbar(
            "  )->title( 'title of the table'
              )->toolbar_spacer(
              )->button(
                  icon = 'sap-icon://action-settings'
                  press = client->_event( 'BUTTON_SETUP' )
              ).


    DATA(lo_columns) = tab->columns( ).
    LOOP AT mt_cols REFERENCE INTO DATA(lr_field)
          WHERE selkz = abap_true.
      lo_columns->column( width = lr_field->length )->button(  text = lr_field->name ).
    ENDLOOP.

    DATA(lo_cells) = tab->items( )->column_list_item( )->cells( ).
    LOOP AT mt_cols REFERENCE INTO lr_field
          WHERE selkz = abap_true.
      lo_cells->input( `{` && lr_field->name && `}` ).
    ENDLOOP.
*
*    ENDIF.

    app-next-xml_main = lo_view->get_root( )->xml_get( ).
    app-next-xml_popup = lo_popup->get_root( )->xml_get( ).

  ENDMETHOD.
ENDCLASS.
