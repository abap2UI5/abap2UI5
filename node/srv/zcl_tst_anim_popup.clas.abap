" A popup-as-app, the shape of every built-in popup: nav_app_call( ) opens
" an app that shows a dialog and no view of its own, so its caller's page
" stays on screen. Closing hands back with nav_app_leave( ), the caller
" re-displays - and the page does NOT move: the display carries the app
" instance, and the frontend sees that the page on screen belongs to it.
CLASS zcl_tst_anim_popup DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS zcl_tst_anim_popup IMPLEMENTATION.

  METHOD z2ui5_if_app~main.

    IF client->check_on_navigated( ).
      DATA(popup) = z2ui5_cl_ui5_view_builder=>factory( ).
      DATA(dialog) = popup->ele( n = `FragmentDefinition` ns = `core`
          )->a( n = `xmlns`      v = `sap.m`
          )->a( n = `xmlns:core` v = `sap.ui.core`
          )->ele( `Dialog`
              )->a( n = `title` v = `A popup-as-app` ).
      dialog->tag( `Text`
          )->a( n = `text`  t = `This app shows a dialog and nothing else. Close it: the page behind it comes back ` &&
                              `without a transition - it never left.`
          )->a( n = `class` v = `sapUiSmallMargin` ).
      dialog->ele( `buttons`
          )->tag( `Button`
              )->a( n = `id`    v = `close`
              )->a( n = `text`  v = `Close`
              )->a( n = `press` v = client->_event( `CLOSE` ) ).
      client->popup_display( popup->stringify( ) ).

    ELSEIF client->check_on_event( `CLOSE` ).
      client->popup_destroy( ).
      client->nav_app_leave( ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.
