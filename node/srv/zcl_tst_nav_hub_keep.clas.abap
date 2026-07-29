CLASS zcl_tst_nav_hub_keep DEFINITION PUBLIC.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.
    DATA input   TYPE string.
    DATA counter TYPE i.

  PROTECTED SECTION.
    DATA client TYPE REF TO z2ui5_if_client.
    METHODS view_display.
  PRIVATE SECTION.
ENDCLASS.


CLASS zcl_tst_nav_hub_keep IMPLEMENTATION.

  METHOD z2ui5_if_app~main.
    DATA lo_detail TYPE REF TO zcl_tst_nav_detail.

    me->client = client.

    IF client->check_on_init( ) IS NOT INITIAL.
      view_display( ).

    ELSEIF client->check_on_navigated( ) IS NOT INITIAL.
      view_display( ).

    ELSEIF client->check_on_event( ) IS NOT INITIAL.
      CASE client->get( )-event.
        WHEN `INC`.
          counter = counter + 1.
          view_display( ).
        WHEN `GO_DETAIL`.
          CREATE OBJECT lo_detail.
          client->nav_app_call( lo_detail ).
      ENDCASE.
    ENDIF.

  ENDMETHOD.


  METHOD view_display.
    DATA view TYPE REF TO z2ui5_cl_xml_view.
    DATA page TYPE REF TO z2ui5_cl_xml_view.

    client->set_nav_routing( client->cs_nav_mode-keep ).

    view = z2ui5_cl_xml_view=>factory( ).
    page = view->shell( )->page( title = `NAV HUB KEEP` ).

    page->label( `hubkeep-marker` ).
    page->input( client->_bind_edit( input ) ).
    page->button( text  = |increment ({ counter })|
                  press = client->_event( `INC` ) ).
    page->button( text  = `go-detail`
                  press = client->_event( `GO_DETAIL` ) ).

    client->view_display( view->stringify( ) ).
  ENDMETHOD.

ENDCLASS.
