" An app with screens of its own: Next and Previous rebuild ITS view, no
" other app is involved - so nothing tells the framework which way the
" screen moves. Next is forward by default; Previous says it with
" transition_back = abap_true, and plays the step being left out in reverse.
" Done leaves the app with nav_app_leave( ) - back to the hub, reversed too.
CLASS zcl_tst_anim_wizard DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    CONSTANTS steps TYPE i VALUE 3.

  PROTECTED SECTION.
    DATA client TYPE REF TO z2ui5_if_client.
    DATA step   TYPE i VALUE 1.

    METHODS view_display
      IMPORTING
        back TYPE abap_bool DEFAULT abap_false.

  PRIVATE SECTION.
ENDCLASS.


CLASS zcl_tst_anim_wizard IMPLEMENTATION.

  METHOD z2ui5_if_app~main.

    me->client = client.

    IF client->check_on_navigated( ).
      view_display( ).

    ELSEIF client->check_on_event( ).
      CASE client->get_event( ).
        WHEN `NEXT`.
          step = step + 1.
          view_display( ).
        WHEN `PREVIOUS`.
          step = step - 1.
          view_display( back = abap_true ).
        WHEN `DONE`.
          client->nav_app_leave( ).
      ENDCASE.
    ENDIF.

  ENDMETHOD.


  METHOD view_display.

    DATA(lv_color) = SWITCH string( step
                                    WHEN 1 THEN `#0a6ed1`
                                    WHEN 2 THEN `#e9730c`
                                    ELSE `#107e3e` ).

    DATA(view) = z2ui5_cl_ui5_view_builder=>factory(
        )->ele( n = `View` ns = `mvc`
            )->a( n = `xmlns`        v = `sap.m`
            )->a( n = `xmlns:mvc`    v = `sap.ui.core.mvc`
            )->a( n = `xmlns:core`   v = `sap.ui.core`
            )->a( n = `displayBlock` v = `true`
            )->a( n = `height`       v = `100%` ).

    DATA(content) = view->ele( `Shell`
        )->ele( `Page`
            )->a( n = `title`          t = |Wizard - step { step } of { steps }|
            )->a( n = `showNavButton`  b = client->check_app_prev_stack( )
            )->a( n = `navButtonPress` v = client->_event_nav_app_leave( )
            )->ele( `VBox`
                )->a( n = `class` v = `sapUiSmallMargin` ).

    content->tag( `MessageStrip`
        )->a( n = `id`   v = `step`
        )->a( n = `text` t = |Step { step } of { steps } - the same app, a new view each time.|
        )->a( n = `type` v = `Information` ).
    content->tag( n = `Icon` ns = `core`
        )->a( n = `src`   v = `sap-icon://step`
        )->a( n = `size`  v = `6rem`
        )->a( n = `color` t = lv_color
        )->a( n = `class` v = `sapUiMediumMarginTopBottom` ).

    content->tag( `Button`
        )->a( n = `id`      v = `previous`
        )->a( n = `text`    t = `Previous - view_display( transition_back = abap_true )`
        )->a( n = `icon`    v = `sap-icon://navigation-left-arrow`
        )->a( n = `enabled` b = xsdbool( step > 1 )
        )->a( n = `class`   v = `sapUiTinyMarginBottom`
        )->a( n = `press`   v = client->_event( `PREVIOUS` )
        )->tag( `Button`
            )->a( n = `id`      v = `next`
            )->a( n = `text`    t = `Next - view_display( transition = slide )`
            )->a( n = `icon`    v = `sap-icon://navigation-right-arrow`
            )->a( n = `enabled` b = xsdbool( step < steps )
            )->a( n = `type`    v = `Emphasized`
            )->a( n = `class`   v = `sapUiTinyMarginBottom`
            )->a( n = `press`   v = client->_event( `NEXT` )
        )->tag( `Button`
            )->a( n = `id`    v = `done`
            )->a( n = `text`  t = `Done - nav_app_leave( ): back to the hub`
            )->a( n = `icon`  v = `sap-icon://accept`
            )->a( n = `press` v = client->_event( `DONE` ) ).

    client->view_display( val             = view->stringify( )
                          transition      = client->cs_transition-slide
                          transition_back = back ).

  ENDMETHOD.

ENDCLASS.
