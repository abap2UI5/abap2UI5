CLASS zcl_tst_nav_detail DEFINITION PUBLIC.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

  PROTECTED SECTION.
    DATA client TYPE REF TO z2ui5_if_client.
  PRIVATE SECTION.
ENDCLASS.


CLASS zcl_tst_nav_detail IMPLEMENTATION.

  METHOD z2ui5_if_app~main.
    DATA view TYPE REF TO z2ui5_cl_xml_view.
    DATA page TYPE REF TO z2ui5_cl_xml_view.

    me->client = client.

    " check_on_navigated also fires when browser Forward / reload restores
    " this app from its KEEP-route draft - the view must be rendered again
    " there (the app contract; see docs life_cycle.md)
    IF client->check_on_init( ) IS NOT INITIAL
        OR client->check_on_navigated( ) IS NOT INITIAL.
      view = z2ui5_cl_xml_view=>factory( ).
      page = view->shell( )->page( title = `NAV DETAIL` ).
      page->label( `detail-marker` ).
      client->view_display( view->stringify( ) ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.
