CLASS zcl_tst_msgbox DEFINITION PUBLIC.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

  PROTECTED SECTION.
    DATA client TYPE REF TO z2ui5_if_client.
    METHODS view_display.
  PRIVATE SECTION.
ENDCLASS.


CLASS zcl_tst_msgbox IMPLEMENTATION.

  METHOD z2ui5_if_app~main.

    me->client = client.

    " e2e fixture for message_box_display( details = ... ) (message-box-
    " details spec). The frontend shows the details unfolded - no "Show
    " details" link to press first (expandBoxDetails in
    " app/webapp/core/actions/ControlCall.js). sap.m.MessageBox fills that
    " text at creation on 1.71 and only in the link's press handler from
    " 1.120 on, so the spec runs on both pinned releases and asks for the
    " TEXT on screen, not for a visible control.
    IF client->check_on_navigated( ).
      view_display( ).

    ELSEIF client->check_on_event( `SHOW` ).
      client->message_box_display(
          text    = `a box with details`
          type    = `error`
          details = `<p>the <strong>detail</strong> text</p>` ).
    ENDIF.

  ENDMETHOD.


  METHOD view_display.
    DATA view TYPE REF TO z2ui5_cl_ui5_view_builder.
    DATA page TYPE REF TO z2ui5_cl_ui5_view_builder.

    view = z2ui5_cl_ui5_view_builder=>factory( ).
    page = view->ele( n = `View` ns = `mvc`
        )->a( n = `xmlns`        v = `sap.m`
        )->a( n = `xmlns:mvc`    v = `sap.ui.core.mvc`
        )->a( n = `displayBlock` v = `true`
        )->a( n = `height`       v = `100%`
        )->ele( `Shell`
            )->ele( `Page`
                )->a( n = `title` v = `MESSAGE BOX DETAILS` ).

    page->tag( `Button`
        )->a( n = `id`    v = `btnShow`
        )->a( n = `text`  v = `show the box`
        )->a( n = `press` v = client->_event( `SHOW` ) ).

    client->view_display( view->stringify( ) ).
  ENDMETHOD.

ENDCLASS.
