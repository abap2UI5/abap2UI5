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
    DATA view TYPE REF TO z2ui5_cl_ai_xml.
    DATA page TYPE REF TO z2ui5_cl_ai_xml.

    client->set_nav_routing( client->cs_nav_mode-keep ).

    view = z2ui5_cl_ai_xml=>factory( ).
    page = view->open( n = `View` ns = `mvc`
        )->a( n = `xmlns`        v = `sap.m`
        )->a( n = `xmlns:mvc`    v = `sap.ui.core.mvc`
        )->a( n = `displayBlock` v = `true`
        )->a( n = `height`       v = `100%`
        )->open( `Shell`
        )->open( `Page`
            )->a( n = `title` v = `NAV HUB KEEP` ).

    page->leaf( `Label` )->a( n = `text` v = `hubkeep-marker` ).
    page->leaf( `Input` )->a( n = `value` v = client->_bind( input ) ).
    page->leaf( `Button`
        )->a( n = `text`  v = |increment ({ counter })|
        )->a( n = `press` v = client->_event( `INC` ) ).
    page->leaf( `Button`
        )->a( n = `text`  v = `go-detail`
        )->a( n = `press` v = client->_event( `GO_DETAIL` ) ).

    client->view_display( view->stringify( ) ).
  ENDMETHOD.

ENDCLASS.
