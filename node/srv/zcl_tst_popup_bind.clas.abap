CLASS zcl_tst_popup_bind DEFINITION PUBLIC.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    TYPES:
      BEGIN OF ty_row,
        application TYPE string,
        object      TYPE string,
        description TYPE string,
      END OF ty_row.
    TYPES ty_t_row TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.

    " the statically typed table - the plain case
    DATA mt_tab TYPE ty_t_row.
    " the popup's edit buffer
    DATA ms_row TYPE ty_row.

  PROTECTED SECTION.
    DATA client TYPE REF TO z2ui5_if_client.
    METHODS view_display.
    METHODS popup_display.
    METHODS fill.
ENDCLASS.


CLASS zcl_tst_popup_bind IMPLEMENTATION.

  METHOD z2ui5_if_app~main.

    me->client = client.

    IF client->check_on_init( ).
      fill( ).
      view_display( ).
      RETURN.
    ENDIF.

    IF client->check_on_event( ).
      CASE client->get_event( ).
        WHEN `ROW_SELECT`.
          " the reported gesture: click a line, a popup opens.
          " NO view_display( ) here - only the popup is displayed.
          ms_row = mt_tab[ 1 ].
          popup_display( ).
      ENDCASE.
    ENDIF.

  ENDMETHOD.


  METHOD fill.

    mt_tab = VALUE ty_t_row(
      ( application = `ASSIGN_RSRC`  object = `CL_APP_006` description = `Login and Logoff from Resource` )
      ( application = `BARCODE_TEST` object = `CL_APP_001` description = `Barcode Testtool` )
      ( application = `DD04T_SEARCH` object = `CL_APP_009` description = `DD04T Search App` ) ).

  ENDMETHOD.


  METHOD view_display.

    DATA view  TYPE REF TO z2ui5_cl_ui5_view_builder.
    DATA page  TYPE REF TO z2ui5_cl_ui5_view_builder.
    DATA tab   TYPE REF TO z2ui5_cl_ui5_view_builder.
    DATA cells TYPE REF TO z2ui5_cl_ui5_view_builder.

    view = z2ui5_cl_ui5_view_builder=>factory( ).
    page = view->ele( n = `View` ns = `mvc`
        )->a( n = `xmlns`        v = `sap.m`
        )->a( n = `xmlns:mvc`    v = `sap.ui.core.mvc`
        )->a( n = `displayBlock` v = `true`
        )->a( n = `height`       v = `100%`
        )->ele( `Shell`
            )->ele( `Page`
                )->a( n = `title` v = `POPUP BIND` ).

    tab = page->ele( `Table`
        )->a( n = `items` v = client->_bind_edit( mt_tab ) ).

    tab->ele( `columns`
        )->ele( `Column` )->ele( `Text` )->a( n = `text` v = `Application` ).

    cells = tab->ele( `items`
        )->ele( `ColumnListItem`
            )->a( n = `type`  v = `Navigation`
            )->a( n = `press` v = client->_event( `ROW_SELECT` )
            )->ele( `cells` ).
    cells->tag( `Text` )->a( n = `text` v = `{APPLICATION}` ).

    client->view_display( view->stringify( ) ).

  ENDMETHOD.


  METHOD popup_display.

    DATA popup TYPE REF TO z2ui5_cl_ui5_view_builder.
    DATA dialog TYPE REF TO z2ui5_cl_ui5_view_builder.

    popup = z2ui5_cl_ui5_view_builder=>factory( ).
    dialog = popup->ele( n = `FragmentDefinition` ns = `core`
        )->a( n = `xmlns`      v = `sap.m`
        )->a( n = `xmlns:core` v = `sap.ui.core`
        )->ele( `Dialog`
            )->a( n = `title` v = `Edit` ).

    dialog->tag( `Input`
        )->a( n = `value` v = client->_bind_edit( ms_row-object ) ).
    dialog->tag( `Input`
        )->a( n = `value` v = client->_bind_edit( ms_row-description ) ).

    dialog->ele( `buttons`
        )->tag( `Button`
            )->a( n = `text`  v = `Cancel`
            )->a( n = `press` v = client->_event( client->cs_event-popup_close ) ).

    client->popup_display( popup->stringify( ) ).

  ENDMETHOD.

ENDCLASS.
