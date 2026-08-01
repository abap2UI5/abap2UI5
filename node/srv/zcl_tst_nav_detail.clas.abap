CLASS zcl_tst_nav_detail DEFINITION PUBLIC.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

  PROTECTED SECTION.
    DATA client TYPE REF TO z2ui5_if_client.
  PRIVATE SECTION.
ENDCLASS.


CLASS zcl_tst_nav_detail IMPLEMENTATION.

  METHOD z2ui5_if_app~main.
    DATA view TYPE REF TO z2ui5_cl_ai_xml.
    DATA page TYPE REF TO z2ui5_cl_ai_xml.

    me->client = client.

    " check_on_navigated also fires when browser Forward / reload restores
    " this app from its KEEP-route draft - the view must be rendered again
    " there (the app contract; see docs life_cycle.md)
    IF client->check_on_init( ) IS NOT INITIAL
        OR client->check_on_navigated( ) IS NOT INITIAL.
      view = z2ui5_cl_ai_xml=>factory( ).
      page = view->open( n = `View` ns = `mvc`
          )->a( n = `xmlns`        v = `sap.m`
          )->a( n = `xmlns:mvc`    v = `sap.ui.core.mvc`
          )->a( n = `displayBlock` v = `true`
          )->a( n = `height`       v = `100%`
          )->open( `Shell`
          )->open( `Page`
              )->a( n = `title` v = `NAV DETAIL` ).
      page->leaf( `Label` )->a( n = `text` v = `detail-marker` ).
      client->view_display( view->stringify( ) ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.
