CLASS zcl_tst_cci DEFINITION PUBLIC.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

  PROTECTED SECTION.
    DATA client TYPE REF TO z2ui5_if_client.
    METHODS main_display
      IMPORTING
        control TYPE string.
    METHODS popup_display.
  PRIVATE SECTION.
ENDCLASS.


CLASS zcl_tst_cci IMPLEMENTATION.

  METHOD z2ui5_if_app~main.

    me->client = client.

    " e2e fixture for the community controls (cci-bundle spec): the
    " controls of the namespace z2ui5_cci are loaded BY CONTROL, from the
    " node, before the first view that names one is built
    " (bundle/webapp/core/CustomControls.js). The controls are the two of
    " node/srv/z2ui5_cl_cci_bundle, the stand-in for the addon's class. The
    " MAIN view of the start names none; MARK shows the first in the MAIN
    " view, POPUP the second in a popup, BOTH the two of them.
    IF client->check_on_init( ).
      main_display( `` ).

    ELSEIF client->check_on_event( `MARK` ).
      main_display( `TstMark` ).

    ELSEIF client->check_on_event( `BOTH` ).
      main_display( `BOTH` ).

    ELSEIF client->check_on_event( `POPUP` ).
      popup_display( ).

    ELSEIF client->check_on_navigated( ).
      main_display( `` ).
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
    IF control IS NOT INITIAL.
      page->a( n = `xmlns:z2ui5_cci` v = `z2ui5_cci.cc` ).
    ENDIF.
    page = page->ele( `Shell`
        )->ele( `Page`
            )->a( n = `title` v = `COMMUNITY CONTROLS` ).

    IF control IS INITIAL.
      page->tag( `Text`
          )->a( n = `text` v = `no community control in this view` ).
    ENDIF.
    IF control = `TstMark` OR control = `BOTH`.
      page->tag( n = `TstMark` ns = `z2ui5_cci`
          )->a( n = `text` v = `the first control` ).
    ENDIF.
    IF control = `BOTH`.
      page->tag( n = `TstOther` ns = `z2ui5_cci`
          )->a( n = `text` v = `the second control` ).
    ENDIF.
    page->tag( `Button`
        )->a( n = `text`  v = `main view with the first control`
        )->a( n = `press` v = client->_event( `MARK` ) ).
    page->tag( `Button`
        )->a( n = `text`  v = `main view with both controls`
        )->a( n = `press` v = client->_event( `BOTH` ) ).
    page->tag( `Button`
        )->a( n = `text`  v = `popup with the second control`
        )->a( n = `press` v = client->_event( `POPUP` ) ).

    client->view_display( view->stringify( ) ).
  ENDMETHOD.


  METHOD popup_display.
    DATA popup  TYPE REF TO z2ui5_cl_ui5_view_builder.
    DATA dialog TYPE REF TO z2ui5_cl_ui5_view_builder.

    popup = z2ui5_cl_ui5_view_builder=>factory( ).
    dialog = popup->ele( n = `FragmentDefinition` ns = `core`
        )->a( n = `xmlns`           v = `sap.m`
        )->a( n = `xmlns:core`      v = `sap.ui.core`
        )->a( n = `xmlns:z2ui5_cci` v = `z2ui5_cci.cc`
        )->ele( `Dialog`
            )->a( n = `title` v = `Popup` ).
    dialog->tag( n = `TstOther` ns = `z2ui5_cci`
        )->a( n = `text` v = `the second control` ).
    dialog->ele( `buttons`
        )->tag( `Button`
            )->a( n = `text`  v = `Close`
            )->a( n = `press` v = client->follow_up_action( val = client->cs_event-popup_close ) ).

    client->popup_display( popup->stringify( ) ).
  ENDMETHOD.

ENDCLASS.
