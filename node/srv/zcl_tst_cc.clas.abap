CLASS zcl_tst_cc DEFINITION PUBLIC.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.
    DATA value TYPE string.

  PROTECTED SECTION.
    DATA client TYPE REF TO z2ui5_if_client.
    METHODS main_display
      IMPORTING
        with_control TYPE abap_bool.
    METHODS popup_display.
    METHODS nest_display.
  PRIVATE SECTION.
ENDCLASS.


CLASS zcl_tst_cc IMPLEMENTATION.

  METHOD z2ui5_if_app~main.

    me->client = client.

    " e2e fixture for the custom controls bundle (cc-bundle spec). The
    " controls of bundle/webapp/cc are no part of the frontend bundle: the
    " frontend loads them, once per page, before the first view that names
    " one is built (bundle/webapp/core/CustomControls.js). Every way a view
    " reaches the screen is a button here, and each of them carries a
    " z2ui5:InputExt - a sap.m.Input that writes its inputMode property onto
    " the inner <input>, which is what the spec reads to see that the
    " control is the real one. The MAIN view of the start names NO control,
    " so the spec chooses which display is the first to need the bundle;
    " started with cc=main in the URL, the very first view does.
    IF client->check_on_init( ).
      value = `4711`.
      main_display( xsdbool( client->get( )-s_config-search CS `cc=main` ) ).

    ELSEIF client->check_on_event( `MAIN` ).
      main_display( abap_true ).

    ELSEIF client->check_on_event( `POPUP` ).
      popup_display( ).

    ELSEIF client->check_on_event( `NEST` ).
      nest_display( ).

    ELSEIF client->check_on_navigated( ).
      main_display( abap_false ).
    ENDIF.

  ENDMETHOD.


  METHOD main_display.
    DATA view TYPE REF TO z2ui5_cl_ui5_view_builder.
    DATA page TYPE REF TO z2ui5_cl_ui5_view_builder.

    view = z2ui5_cl_ui5_view_builder=>factory( ).
    page = view->ele( n = `View` ns = `mvc`
        )->a( n = `xmlns`        v = `sap.m`
        )->a( n = `xmlns:mvc`    v = `sap.ui.core.mvc`
        )->a( n = `displayBlock` v = `true`
        )->a( n = `height`       v = `100%` ).
    IF with_control = abap_true.
      page->a( n = `xmlns:z2ui5` v = `z2ui5.cc` ).
    ENDIF.
    page = page->ele( `Shell`
        )->ele( `Page`
            )->a( n = `title` v = `CUSTOM CONTROLS BUNDLE` ).

    IF with_control = abap_true.
      page->tag( n = `InputExt` ns = `z2ui5`
          )->a( n = `id`        v = `inpMain`
          )->a( n = `inputMode` v = `numeric`
          )->a( n = `value`     v = client->_bind( value ) ).
    ELSE.
      page->tag( `Text`
          )->a( n = `id`   v = `txtPlain`
          )->a( n = `text` v = `no custom control in this view` ).
    ENDIF.
    page->tag( `Button`
        )->a( n = `id`    v = `btnMain`
        )->a( n = `text`  v = `main view with a control`
        )->a( n = `press` v = client->_event( `MAIN` ) ).
    page->tag( `Button`
        )->a( n = `id`    v = `btnPopup`
        )->a( n = `text`  v = `popup with a control`
        )->a( n = `press` v = client->_event( `POPUP` ) ).
    page->tag( `Button`
        )->a( n = `id`    v = `btnNest`
        )->a( n = `text`  v = `nested view with a control`
        )->a( n = `press` v = client->_event( `NEST` ) ).
    page->tag( `VBox`
        )->a( n = `id` v = `nestHost` ).

    client->view_display( view->stringify( ) ).
  ENDMETHOD.


  METHOD popup_display.
    DATA popup  TYPE REF TO z2ui5_cl_ui5_view_builder.
    DATA dialog TYPE REF TO z2ui5_cl_ui5_view_builder.

    popup = z2ui5_cl_ui5_view_builder=>factory( ).
    dialog = popup->ele( n = `FragmentDefinition` ns = `core`
        )->a( n = `xmlns`       v = `sap.m`
        )->a( n = `xmlns:core`  v = `sap.ui.core`
        )->a( n = `xmlns:z2ui5` v = `z2ui5.cc`
        )->ele( `Dialog`
            )->a( n = `title` v = `Popup` ).

    dialog->tag( n = `InputExt` ns = `z2ui5`
        )->a( n = `id`        v = `inpPopup`
        )->a( n = `inputMode` v = `tel`
        )->a( n = `value`     v = client->_bind( value ) ).
    dialog->ele( `buttons`
        )->tag( `Button`
            )->a( n = `id`    v = `btnPopupClose`
            )->a( n = `text`  v = `Close`
            )->a( n = `press` v = client->follow_up_action( val = client->cs_event-popup_close ) ).

    client->popup_display( popup->stringify( ) ).
  ENDMETHOD.


  METHOD nest_display.
    DATA view TYPE REF TO z2ui5_cl_ui5_view_builder.

    view = z2ui5_cl_ui5_view_builder=>factory( ).
    view->ele( n = `View` ns = `mvc`
        )->a( n = `xmlns`       v = `sap.m`
        )->a( n = `xmlns:mvc`   v = `sap.ui.core.mvc`
        )->a( n = `xmlns:z2ui5` v = `z2ui5.cc`
        )->tag( n = `InputExt` ns = `z2ui5`
            )->a( n = `id`        v = `inpNest`
            )->a( n = `inputMode` v = `decimal`
            )->a( n = `value`     v = client->_bind( value ) ).

    client->nest_view_display( val            = view->stringify( )
                               id             = `nestHost`
                               method_insert  = `addItem`
                               method_destroy = `removeAllItems` ).
  ENDMETHOD.

ENDCLASS.
