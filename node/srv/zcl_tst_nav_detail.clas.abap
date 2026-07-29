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

    IF client->check_on_init( ) IS NOT INITIAL.
      view = z2ui5_cl_xml_view=>factory( ).
      page = view->shell( )->page( title = `NAV DETAIL` ).
      page->label( `detail-marker` ).
      client->view_display( view->stringify( ) ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.
