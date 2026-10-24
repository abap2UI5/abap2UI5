CLASS zcl_tst_offline DEFINITION PUBLIC.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.
    DATA input TYPE string.
    DATA saved TYPE string.

  PROTECTED SECTION.
    DATA client TYPE REF TO z2ui5_if_client.
    METHODS view_display.
  PRIVATE SECTION.
ENDCLASS.


CLASS zcl_tst_offline IMPLEMENTATION.

  METHOD z2ui5_if_app~main.

    me->client = client.

    " e2e fixture for the offline queue (offline-queue spec): SAVE is the one
    " event allowed to wait for the network. Each SAVE appends the input to
    " `saved` and empties the field, so the order the queue was sent in is
    " the order there.
    IF client->check_on_init( ).
      view_display( ).
      client->follow_up_action( val   = client->cs_event-offline_queue
                                t_arg = VALUE #( ( `Saved offline - &1 waiting` ) ( `SAVE` ) ) ).

    ELSEIF client->check_on_navigated( ).
      view_display( ).

    ELSEIF client->check_on_event( `SAVE` ).
      saved = COND #( WHEN saved IS INITIAL THEN input ELSE |{ saved },{ input }| ).
      CLEAR input.
      client->view_model_update( ).

    ELSEIF client->check_on_event( `OTHER` ).
      client->message_toast_display( `other` ).
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
                )->a( n = `title` v = `OFFLINE QUEUE` ).

    page->tag( `Input`
        )->a( n = `id`    v = `inpValue`
        )->a( n = `value` v = client->_bind_edit( input ) ).
    page->tag( `Button`
        )->a( n = `id`    v = `btnSave`
        )->a( n = `text`  v = `save`
        )->a( n = `press` v = client->_event( `SAVE` ) ).
    page->tag( `Button`
        )->a( n = `id`    v = `btnOther`
        )->a( n = `text`  v = `other`
        )->a( n = `press` v = client->_event( `OTHER` ) ).
    page->tag( `Text`
        )->a( n = `id`   v = `txtSaved`
        )->a( n = `text` v = client->_bind( saved ) ).

    client->view_display( view->stringify( ) ).

  ENDMETHOD.

ENDCLASS.
