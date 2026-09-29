" The page-transition demo of view_display( transition = ... ) - start it
" with ?app_start=z2ui5_cl_ui5_app_anim_hub. Every transition button opens
" z2ui5_cl_ui5_app_anim_pg with that transition; the page's way back plays
" it reversed, the sap.m.NavContainer rule: the page being left runs the way
" it ARRIVED backwards. Two more entries show the cases the framework cannot
" tell by itself or tells without being asked: an app with screens of its
" own (z2ui5_cl_ui5_app_anim_wiz, transition_back), and the browser Back
" and Forward buttons under hash routing.
CLASS z2ui5_cl_ui5_app_anim_hub DEFINITION PUBLIC FINAL.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    " hash routing (KEEP), switched with the Switch - the browser buttons
    " then move between the pages as well, with the same transitions
    DATA routing TYPE abap_bool.

  PROTECTED SECTION.
    DATA client TYPE REF TO z2ui5_if_client.

    METHODS view_display.

  PRIVATE SECTION.
ENDCLASS.


CLASS z2ui5_cl_ui5_app_anim_hub IMPLEMENTATION.

  METHOD z2ui5_if_app~main.

    me->client = client.

    " the hub names no transition of its own: it is where the demo starts,
    " and a way back TO it plays what the page being left arrived with
    IF client->check_on_navigated( ).
      view_display( ).

    ELSEIF client->check_on_event( ).
      CASE client->get_event( ).
        WHEN `GO`.
          client->nav_app_call( z2ui5_cl_ui5_app_anim_pg=>factory( transition = client->get_event_arg( )
                                                                   level      = 1 ) ).
        WHEN `WIZARD`.
          client->nav_app_call( NEW z2ui5_cl_ui5_app_anim_wiz( ) ).
        WHEN `ROUTING`.
          " the Switch wrote the new state before main( ) ran
          DATA(lv_mode) = COND string( WHEN routing = abap_true
                                       THEN client->cs_nav_mode-keep
                                       ELSE client->cs_nav_mode-default ).
          client->follow_up_action( val   = client->cs_event-hash_routing
                                    t_arg = VALUE #( ( lv_mode ) ) ).
      ENDCASE.
    ENDIF.

  ENDMETHOD.

  METHOD view_display.

    DATA(view) = z2ui5_cl_ui5_view_builder=>factory(
        )->ele( n = `View` ns = `mvc`
            )->a( n = `xmlns`        v = `sap.m`
            )->a( n = `xmlns:mvc`    v = `sap.ui.core.mvc`
            )->a( n = `xmlns:core`   v = `sap.ui.core`
            )->a( n = `displayBlock` v = `true`
            )->a( n = `height`       v = `100%` ).

    DATA(content) = view->ele( `Shell`
        )->ele( `Page`
            )->a( n = `title` v = `Page transitions`
            )->ele( `VBox`
                )->a( n = `class` v = `sapUiSmallMargin` ).

    content->tag( n = `Icon` ns = `core`
        )->a( n = `src`   v = `sap-icon://home`
        )->a( n = `size`  v = `4rem`
        )->a( n = `color` v = `#0a6ed1`
        )->a( n = `class` v = `sapUiSmallMarginBottom` ).
    content->tag( `Title`
        )->a( n = `text`  t = `view_display( transition = ... )`
        )->a( n = `level` v = `H2` ).
    content->tag( `Text`
        )->a( n = `text` t = `Each button opens a page with one transition. Leave the page with its Back button or the ` &&
                             `nav button in its header: the transition plays reversed - the page being left runs ` &&
                             `the way it arrived backwards, as in sap.m.NavContainer.` ).

    DATA(buttons) = content->ele( `HBox`
        )->a( n = `wrap`  v = `Wrap`
        )->a( n = `class` v = `sapUiSmallMarginTop` ).
    " the five cs_transition names, the undocumented door, and none at all
    DATA(lt_transition) = VALUE string_table( ( client->cs_transition-slide )
                                              ( client->cs_transition-base_slide )
                                              ( client->cs_transition-fade )
                                              ( client->cs_transition-flip )
                                              ( client->cs_transition-show )
                                              ( `door` )
                                              ( `` ) ).
    LOOP AT lt_transition INTO DATA(lv_transition).
      DATA(lv_name) = COND string( WHEN lv_transition IS INITIAL THEN `none` ELSE lv_transition ).
      buttons->tag( `Button`
          )->a( n = `id`    t = |go-{ lv_name }|
          )->a( n = `text`  t = COND string( WHEN lv_transition = `door` THEN `door (undocumented)` ELSE lv_name )
          )->a( n = `icon`  v = `sap-icon://navigation-right-arrow`
          )->a( n = `class` v = `sapUiTinyMarginEnd sapUiTinyMarginBottom`
          )->a( n = `press` v = client->_event( val = `GO`
                                                arg = lv_transition ) ).
    ENDLOOP.

    content->tag( `Title`
        )->a( n = `text`  v = `More`
        )->a( n = `level` v = `H3`
        )->a( n = `class` v = `sapUiMediumMarginTop` ).
    content->tag( `Button`
        )->a( n = `id`    v = `wizard`
        )->a( n = `text`  t = `An app with screens of its own - Next and Previous ( transition_back )`
        )->a( n = `icon`  v = `sap-icon://step`
        )->a( n = `class` v = `sapUiTinyMarginBottom`
        )->a( n = `press` v = client->_event( `WIZARD` ) ).
    content->ele( `HBox`
        )->a( n = `alignItems` v = `Center`
        )->tag( `Switch`
            )->a( n = `id`     v = `routing`
            )->a( n = `state`  v = client->_bind( routing )
            )->a( n = `change` v = client->_event( `ROUTING` )
        )->tag( `Label`
            )->a( n = `text`  v = `Hash routing (KEEP) - the browser Back and Forward buttons move the pages too`
            )->a( n = `class` v = `sapUiTinyMarginBegin` ).

    client->view_display( view->stringify( ) ).

  ENDMETHOD.

ENDCLASS.
