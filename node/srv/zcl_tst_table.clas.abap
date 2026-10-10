CLASS zcl_tst_table DEFINITION PUBLIC.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    TYPES:
      BEGIN OF ty_s_row,
        id   TYPE i,
        name TYPE string,
      END OF ty_s_row.
    TYPES ty_t_row TYPE STANDARD TABLE OF ty_s_row WITH DEFAULT KEY.

    DATA t_row TYPE ty_t_row.

  PROTECTED SECTION.
    DATA client TYPE REF TO z2ui5_if_client.
    METHODS view_display.
  PRIVATE SECTION.
ENDCLASS.


CLASS zcl_tst_table IMPLEMENTATION.

  METHOD z2ui5_if_app~main.

    me->client = client.

    " e2e fixture for the library preloads of a view (library-preload
    " spec): a MAIN view with one sap.ui.table.Table - a control of a
    " library manifest.json does not declare. The frontend loads that
    " library's preload bundle before it builds the view (core/Env.js
    " loadViewLibraries), so the browser asks for sap/ui/table/
    " library-preload.js once instead of for every module of the library
    " the view's controls need, one by one.
    IF client->check_on_init( ).
      DO 3 TIMES.
        APPEND VALUE #( id   = sy-index
                        name = |Row { sy-index }| ) TO t_row.
      ENDDO.
      view_display( ).
    ELSEIF client->check_on_navigated( ).
      view_display( ).
    ENDIF.

  ENDMETHOD.


  METHOD view_display.
    DATA view TYPE REF TO z2ui5_cl_ui5_view_builder.
    DATA page TYPE REF TO z2ui5_cl_ui5_view_builder.
    DATA tab  TYPE REF TO z2ui5_cl_ui5_view_builder.

    view = z2ui5_cl_ui5_view_builder=>factory( ).
    page = view->ele( n = `View` ns = `mvc`
        )->a( n = `xmlns`        v = `sap.m`
        )->a( n = `xmlns:mvc`    v = `sap.ui.core.mvc`
        )->a( n = `xmlns:t`      v = `sap.ui.table`
        )->a( n = `displayBlock` v = `true`
        )->a( n = `height`       v = `100%`
        )->ele( `Shell`
            )->ele( `Page`
                )->a( n = `title` v = `LIBRARY PRELOAD` ).

    tab = page->ele( n = `Table` ns = `t`
        )->a( n = `id`              v = `tabRows`
        )->a( n = `rows`            v = client->_bind( t_row )
        )->a( n = `visibleRowCount` v = `3` ).
    tab->ele( n = `columns` ns = `t`
        )->ele( n = `Column` ns = `t`
            )->ele( n = `label` ns = `t`
                )->tag( `Label`
                    )->a( n = `text` v = `Name`
            )->end(
            )->ele( n = `template` ns = `t`
                )->tag( `Text`
                    )->a( n = `id`   v = `txtName`
                    )->a( n = `text` v = `{NAME}` ).

    client->view_display( view->stringify( ) ).
  ENDMETHOD.

ENDCLASS.
