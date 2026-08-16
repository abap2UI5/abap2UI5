CLASS zcl_tst_focus DEFINITION PUBLIC.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.
    DATA value   TYPE string.
    DATA enabled TYPE abap_bool.

  PROTECTED SECTION.
    DATA client TYPE REF TO z2ui5_if_client.
    METHODS view_display.
  PRIVATE SECTION.
ENDCLASS.


CLASS zcl_tst_focus IMPLEMENTATION.

  METHOD z2ui5_if_app~main.

    me->client = client.

    " e2e fixture for the SET_FOCUS follow-up action (focus-after-enable
    " spec): one roundtrip re-enables the input via its `enabled` binding AND
    " sends SET_FOCUS. The control reports enabled=true immediately, but the
    " DOM still carries the old disabled input until UI5 re-renders
    " asynchronously - the browser silently ignores focus() on a disabled
    " element, so the frontend has to re-apply the focus after the re-render
    " (see evSetFocus in app/webapp/core/FrontendAction.js).
    IF client->check_on_init( ) IS NOT INITIAL.
      enabled = abap_true.
      value   = `86801398`.
      view_display( ).

    ELSEIF client->check_on_navigated( ) IS NOT INITIAL.
      view_display( ).

    ELSEIF client->check_on_event( `LOCK` ) IS NOT INITIAL.
      enabled = abap_false.

    ELSEIF client->check_on_event( `UNLOCK_AND_FOCUS` ) IS NOT INITIAL.
      enabled = abap_true.
      client->follow_up_action( val   = client->cs_event-set_focus
                                t_arg = VALUE #( ( `inpDocNum` ) ( `0` ) ( `4` ) ) ).
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
                )->a( n = `title` v = `FOCUS AFTER ENABLE` ).

    page->tag( `Input`
        )->a( n = `id`      v = `inpDocNum`
        )->a( n = `value`   v = client->_bind( value )
        )->a( n = `enabled` v = client->_bind( enabled ) ).
    page->tag( `Button`
        )->a( n = `id`    v = `btnLock`
        )->a( n = `text`  v = `lock`
        )->a( n = `press` v = client->_event( `LOCK` ) ).
    page->tag( `Button`
        )->a( n = `id`    v = `btnUnlock`
        )->a( n = `text`  v = `unlock + focus`
        )->a( n = `press` v = client->_event( `UNLOCK_AND_FOCUS` ) ).

    client->view_display( view->stringify( ) ).
  ENDMETHOD.

ENDCLASS.
