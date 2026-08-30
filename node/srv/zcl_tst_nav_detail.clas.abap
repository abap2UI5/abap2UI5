CLASS zcl_tst_nav_detail DEFINITION PUBLIC.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

  PROTECTED SECTION.
    DATA client TYPE REF TO z2ui5_if_client.
  PRIVATE SECTION.
ENDCLASS.


CLASS zcl_tst_nav_detail IMPLEMENTATION.

  METHOD z2ui5_if_app~main.
    DATA view TYPE REF TO z2ui5_cl_ui5_view_builder.
    DATA page TYPE REF TO z2ui5_cl_ui5_view_builder.

    me->client = client.

    " check_on_navigated also fires when browser Forward / reload restores
    " this app from its KEEP-route draft - the view must be rendered again
    " there (the app contract; see docs life_cycle.md) - and it is the WIDER
    " of the two: every entry point that hands an app its first request sets
    " check_on_navigated, so check_on_init implies it and an OR of the two
    " can never change the verdict (abap2ui5lint redundant-init-display)
    IF client->check_on_navigated( ).
      view = z2ui5_cl_ui5_view_builder=>factory( ).
      page = view->ele( n = `View` ns = `mvc`
          )->a( n = `xmlns`        v = `sap.m`
          )->a( n = `xmlns:mvc`    v = `sap.ui.core.mvc`
          )->a( n = `displayBlock` v = `true`
          )->a( n = `height`       v = `100%`
          )->ele( `Shell`
              )->ele( `Page`
                  )->a( n = `title` v = `NAV DETAIL` ).
      page->tag( `Label`
          )->a( n = `text` v = `detail-marker` ).
      client->view_display( view->stringify( ) ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.
