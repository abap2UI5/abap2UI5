" The page z2ui5_cl_ui5_app_anim_hub opens. It arrives with the transition
" it was opened with, and every way of leaving it shows what the framework
" plays:
"  Back, the header's nav button  nav_app_leave( ): the arrival reversed
"  Deeper                         nav_app_call( ) of the next level: the
"                                 same transition, forward
"  Re-render                      view_display( ) WITHOUT a transition: the
"                                 page is rebuilt in place, and the way
"                                 back still reverses how it arrived
"  Replace                        nav_app_leave( ) to a FRESH instance: a
"                                 forward move that takes this page's place
"  Popup app                      nav_app_call( ) of an app that shows a
"                                 dialog only - its return moves nothing
CLASS z2ui5_cl_ui5_app_anim_page DEFINITION PUBLIC FINAL.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    CLASS-METHODS factory
      IMPORTING
        transition    TYPE string
        level         TYPE i
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_ui5_app_anim_page.

  PROTECTED SECTION.
    DATA client     TYPE REF TO z2ui5_if_client.
    DATA transition TYPE string.
    DATA level      TYPE i.
    DATA renders    TYPE i.

    METHODS view_display
      IMPORTING
        arriving TYPE abap_bool.

  PRIVATE SECTION.
ENDCLASS.


CLASS z2ui5_cl_ui5_app_anim_page IMPLEMENTATION.

  METHOD factory.

    result = NEW #( ).
    result->transition = transition.
    result->level      = level.

  ENDMETHOD.

  METHOD z2ui5_if_app~main.

    me->client = client.

    " arriving - from the hub, back from a deeper page or the popup app, or
    " restored by the browser buttons: the page names its transition every
    " time, the framework finds the direction
    IF client->check_on_navigated( ).
      view_display( abap_true ).

    ELSEIF client->check_on_event( ).
      CASE client->get_event( ).
        WHEN `BACK`.
          client->nav_app_leave( ).
        WHEN `DEEPER`.
          client->nav_app_call( factory( transition = transition
                                         level      = level + 1 ) ).
        WHEN `RERENDER`.
          renders = renders + 1.
          view_display( abap_false ).
        WHEN `REPLACE`.
          client->nav_app_leave( factory( transition = transition
                                          level      = level ) ).
        WHEN `POPUP`.
          client->nav_app_call( NEW z2ui5_cl_ui5_app_anim_popup( ) ).
      ENDCASE.
    ENDIF.

  ENDMETHOD.

  METHOD view_display.

    " one color per level, so the two pages can be told apart while they move
    DATA(lv_color) = SWITCH string( level MOD 4
                                    WHEN 1 THEN `#0a6ed1`
                                    WHEN 2 THEN `#e9730c`
                                    WHEN 3 THEN `#107e3e`
                                    ELSE `#bb0000` ).
    DATA(lv_name) = COND string( WHEN transition IS INITIAL THEN `no transition` ELSE transition ).

    DATA(view) = z2ui5_cl_ui5_view_builder=>factory(
        )->ele( n = `View` ns = `mvc`
            )->a( n = `xmlns`        v = `sap.m`
            )->a( n = `xmlns:mvc`    v = `sap.ui.core.mvc`
            )->a( n = `xmlns:core`   v = `sap.ui.core`
            )->a( n = `displayBlock` v = `true`
            )->a( n = `height`       v = `100%` ).

    DATA(content) = view->ele( `Shell`
        )->ele( `Page`
            )->a( n = `title`          t = |Page { level } - { lv_name }|
            )->a( n = `showNavButton`  b = client->check_app_prev_stack( )
            )->a( n = `navButtonPress` v = client->_event_nav_app_leave( )
            )->ele( `VBox`
                )->a( n = `class` v = `sapUiSmallMargin` ).

    content->tag( `MessageStrip`
        )->a( n = `id`   v = `arrival`
        )->a( n = `text` t = |Page { level } arrived with: { lv_name }. Rendered { renders + 1 } time(s).|
        )->a( n = `type` v = `Information` ).
    content->tag( n = `Icon` ns = `core`
        )->a( n = `src`   v = `sap-icon://paper-plane`
        )->a( n = `size`  v = `6rem`
        )->a( n = `color` t = lv_color
        )->a( n = `class` v = `sapUiMediumMarginTopBottom` ).

    content->tag( `Button`
        )->a( n = `id`    v = `back`
        )->a( n = `text`  t = `Back - nav_app_leave( ): the transition reversed`
        )->a( n = `icon`  v = `sap-icon://navigation-left-arrow`
        )->a( n = `type`  v = `Emphasized`
        )->a( n = `class` v = `sapUiTinyMarginBottom`
        )->a( n = `press` v = client->_event( `BACK` )
        )->tag( `Button`
            )->a( n = `id`    v = `deeper`
            )->a( n = `text`  t = |Deeper - nav_app_call( ) of page { level + 1 }: { lv_name } forward|
            )->a( n = `icon`  v = `sap-icon://navigation-right-arrow`
            )->a( n = `class` v = `sapUiTinyMarginBottom`
            )->a( n = `press` v = client->_event( `DEEPER` )
        )->tag( `Button`
            )->a( n = `id`    v = `rerender`
            )->a( n = `text`  t = `Re-render - view_display( ) without a transition: rebuilt in place`
            )->a( n = `icon`  v = `sap-icon://refresh`
            )->a( n = `class` v = `sapUiTinyMarginBottom`
            )->a( n = `press` v = client->_event( `RERENDER` )
        )->tag( `Button`
            )->a( n = `id`    v = `replace`
            )->a( n = `text`  t = `Replace - nav_app_leave( ) to a new instance: a forward move`
            )->a( n = `icon`  v = `sap-icon://synchronize`
            )->a( n = `class` v = `sapUiTinyMarginBottom`
            )->a( n = `press` v = client->_event( `REPLACE` )
        )->tag( `Button`
            )->a( n = `id`    v = `popup`
            )->a( n = `text`  t = `Popup app - nav_app_call( ) of a dialog-only app: its return moves nothing`
            )->a( n = `icon`  v = `sap-icon://popup-window`
            )->a( n = `press` v = client->_event( `POPUP` ) ).

    IF arriving = abap_true.
      client->view_display( val        = view->stringify( )
                            transition = transition ).
    ELSE.
      client->view_display( view->stringify( ) ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.
