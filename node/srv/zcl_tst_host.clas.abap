CLASS zcl_tst_host DEFINITION PUBLIC.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    TYPES:
      BEGIN OF ty_s_tab,
        id    TYPE string,
        class TYPE string,
        table TYPE string,
      END OF ty_s_tab.
    TYPES ty_t_tab TYPE STANDARD TABLE OF ty_s_tab WITH EMPTY KEY.

    " sample 338 as a fixture: an IconTabBar whose tabs are SUB-APPS of two
    " different classes, held in one REF TO object and created by name
    DATA mv_selectedkey     TYPE string.
    DATA mv_selectedkey_tmp TYPE string.
    DATA mt_tab             TYPE ty_t_tab.
    DATA mo_app             TYPE REF TO object.

  PROTECTED SECTION.
    DATA client       TYPE REF TO z2ui5_if_client.
    DATA mo_main_page TYPE REF TO z2ui5_cl_ui5_view_builder.

    METHODS view_display.
    METHODS render_sub_app.
  PRIVATE SECTION.
ENDCLASS.


CLASS zcl_tst_host IMPLEMENTATION.

  METHOD z2ui5_if_app~main.

    me->client = client.

    IF client->check_on_init( ).
      mt_tab = VALUE #( ( id = `1` class = `ZCL_TST_SUB_A` table = `T_A` )
                        ( id = `2` class = `ZCL_TST_SUB_B` table = `T_B` )
                        ( id = `3` class = `ZCL_TST_SUB_A` table = `T_A3` ) ).
      mv_selectedkey = `1`.
      view_display( ).
    ELSEIF client->check_on_navigated( ).
      render_sub_app( ).
    ENDIF.

    render_sub_app( ).

  ENDMETHOD.

  METHOD view_display.

    DATA view  TYPE REF TO z2ui5_cl_ui5_view_builder.
    DATA page  TYPE REF TO z2ui5_cl_ui5_view_builder.
    DATA items TYPE REF TO z2ui5_cl_ui5_view_builder.

    view = z2ui5_cl_ui5_view_builder=>factory( ).
    page = view->ele( n = `View` ns = `mvc`
        )->a( n = `xmlns`        v = `sap.m`
        )->a( n = `xmlns:mvc`    v = `sap.ui.core.mvc`
        )->a( n = `displayBlock` v = `true`
        )->a( n = `height`       v = `100%`
        )->ele( `Shell`
            )->ele( `Page`
                )->a( n = `title` v = `HOST` ).

    items = page->ele( `IconTabBar`
        " abap2ui5lint-disable-next-line event-without-handler -- the roundtrip alone is the point: selectedKey is written back by the binding, render_sub_app( ) reads it
        )->a( n = `select`      v = client->_event( `ONSELECTICONTABBAR` )
        )->a( n = `selectedKey` v = client->_bind( mv_selectedkey )
        )->ele( `items` ).

    LOOP AT mt_tab REFERENCE INTO DATA(line).
      items->ele( `IconTabFilter`
          )->a( n = `text` v = line->class
          )->a( n = `key`  v = line->id ).
    ENDLOOP.

    " the Page is what the sub-app builds into (see the nested-view samples)
    mo_main_page = page.

  ENDMETHOD.

  METHOD render_sub_app.

    FIELD-SYMBOLS <view_display> TYPE any.
    FIELD-SYMBOLS <page>         TYPE any.

    READ TABLE mt_tab REFERENCE INTO DATA(tab) WITH KEY id = mv_selectedkey.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    " a tab switch means a NEW instance - of whichever class the tab names
    IF mv_selectedkey <> mv_selectedkey_tmp.
      CREATE OBJECT mo_app TYPE (tab->class).
    ENDIF.

    " no CATCH around the dynamic calls: an error in the sub-app must reach
    " the response as a 500 the spec can see, not vanish in a RETURN
    CALL METHOD mo_app->(`SET_APP_DATA`)
      EXPORTING
        table = tab->table.

    view_display( ).

    ASSIGN mo_app->(`MO_PARENT_PAGE`) TO <page>.
    IF <page> IS ASSIGNED.
      <page> = mo_main_page.
    ENDIF.

    CALL METHOD mo_app->(`Z2UI5_IF_APP~MAIN`)
      EXPORTING
        client = client.

    ASSIGN mo_app->(`MV_VIEW_DISPLAY`) TO <view_display>.
    IF sy-subrc = 0 AND <view_display> = abap_true.
      <view_display> = abap_false.
      client->view_display( mo_main_page->stringify( ) ).
    ENDIF.

    IF mv_selectedkey <> mv_selectedkey_tmp.
      client->view_display( mo_main_page->stringify( ) ).
      mv_selectedkey_tmp = mv_selectedkey.
    ENDIF.

  ENDMETHOD.

ENDCLASS.
