" The page-transition demo, walked through the public HTTP handler with the
" POSTs the frontend sends. The animation itself is the frontend's; what has
" to hold on this side of the wire is what it plays from: the transition the
" page arrives with, the flag that makes a way back a way back, and the app
" instance that tells the frontend a page it already shows.
CLASS ltcl_demo DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    " the draft id of the last response - the next event is sent on it
    DATA mv_id TYPE string.

    METHODS hub_offers_all     FOR TESTING RAISING cx_static_check.
    METHODS page_arrives_back  FOR TESTING RAISING cx_static_check.
    METHODS wizard_steps_back  FOR TESTING RAISING cx_static_check.
    METHODS popup_moves_nothing FOR TESTING RAISING cx_static_check.

    METHODS start
      RETURNING
        VALUE(result) TYPE string.
    METHODS send
      IMPORTING
        event         TYPE string
        arg           TYPE string OPTIONAL
      RETURNING
        VALUE(result) TYPE string.
    METHODS post
      IMPORTING
        front         TYPE string
      RETURNING
        VALUE(result) TYPE string.
    METHODS instance_of
      IMPORTING
        body          TYPE string
      RETURNING
        VALUE(result) TYPE string.
ENDCLASS.


CLASS ltcl_demo IMPLEMENTATION.

  METHOD hub_offers_all.

    DATA(lv_body) = start( ).

    " one button per transition - the five names, door and none
    DATA(lt_button) = VALUE string_table( ( `go-slide` ) ( `go-baseSlide` ) ( `go-fade` ) ( `go-flip` )
                                          ( `go-show` ) ( `go-door` ) ( `go-none` ) ).
    LOOP AT lt_button INTO DATA(lv_button).
      cl_abap_unit_assert=>assert_true( act = xsdbool( find( val = lv_body
                                                             sub = lv_button ) >= 0 )
                                        msg = |the hub offers no { lv_button }| ).
    ENDLOOP.
    " the hub names no transition of its own: it is where the demo starts
    cl_abap_unit_assert=>assert_false( xsdbool( find( val = lv_body
                                                      sub = `"transition"` ) >= 0 ) ).

  ENDMETHOD.

  METHOD page_arrives_back.

    start( ).

    " the page arrives with the transition its button names - forward
    DATA(lv_body) = send( event = `GO`
                          arg   = `fade` ).
    cl_abap_unit_assert=>assert_true( xsdbool( find( val = lv_body
                                                     sub = `Page 1 - fade` ) >= 0 ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( find( val = lv_body
                                                     sub = `"transition":"fade"` ) >= 0 ) ).
    cl_abap_unit_assert=>assert_false( xsdbool( find( val = lv_body
                                                      sub = `"navBack"` ) >= 0 ) ).

    " a re-render in place names none
    lv_body = send( `RERENDER` ).
    cl_abap_unit_assert=>assert_true( xsdbool( find( val = lv_body
                                                     sub = `Rendered 2 time(s)` ) >= 0 ) ).
    cl_abap_unit_assert=>assert_false( xsdbool( find( val = lv_body
                                                      sub = `"transition"` ) >= 0 ) ).

    " Back returns to the hub as a way back - the frontend plays fade reversed
    lv_body = send( `BACK` ).
    cl_abap_unit_assert=>assert_true( xsdbool( find( val = lv_body
                                                     sub = `go-fade` ) >= 0 ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( find( val = lv_body
                                                     sub = `"navBack":true` ) >= 0 ) ).

  ENDMETHOD.

  METHOD wizard_steps_back.

    start( ).

    DATA(lv_body) = send( `WIZARD` ).
    cl_abap_unit_assert=>assert_true( xsdbool( find( val = lv_body
                                                     sub = `"transition":"slide"` ) >= 0 ) ).

    lv_body = send( `NEXT` ).
    cl_abap_unit_assert=>assert_true( xsdbool( find( val = lv_body
                                                     sub = `Step 2 of 3` ) >= 0 ) ).
    cl_abap_unit_assert=>assert_false( xsdbool( find( val = lv_body
                                                      sub = `"transitionBack"` ) >= 0 ) ).

    " Previous stays in the same app - only the app can say it goes back
    lv_body = send( `PREVIOUS` ).
    cl_abap_unit_assert=>assert_true( xsdbool( find( val = lv_body
                                                     sub = `Step 1 of 3` ) >= 0 ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( find( val = lv_body
                                                     sub = `"transitionBack":true` ) >= 0 ) ).

    " Done leaves the wizard - back to the hub, recognized as a way back
    lv_body = send( `DONE` ).
    cl_abap_unit_assert=>assert_true( xsdbool( find( val = lv_body
                                                     sub = `"navBack":true` ) >= 0 ) ).

  ENDMETHOD.

  METHOD popup_moves_nothing.

    start( ).
    DATA(lv_page) = instance_of( send( event = `GO`
                                       arg   = `flip` ) ).
    cl_abap_unit_assert=>assert_not_initial( lv_page ).

    " the popup app shows a dialog, not a view: the page stays on screen
    DATA(lv_body) = send( `POPUP` ).
    cl_abap_unit_assert=>assert_true( xsdbool( find( val = lv_body
                                                     sub = `A popup-as-app` ) >= 0 ) ).
    cl_abap_unit_assert=>assert_false( xsdbool( find( val = lv_body
                                                      sub = `"transition"` ) >= 0 ) ).

    " closing it re-displays the page as the SAME instance it arrived as -
    " the frontend finds that page on screen and moves nothing
    lv_body = send( `CLOSE` ).
    cl_abap_unit_assert=>assert_true( xsdbool( find( val = lv_body
                                                     sub = `"navBack":true` ) >= 0 ) ).
    cl_abap_unit_assert=>assert_equals( exp = lv_page
                                        act = instance_of( lv_body ) ).

  ENDMETHOD.

  METHOD start.

    result = post( `{"ORIGIN":"O","PATHNAME":"/p","SEARCH":"?app_start=Z2UI5_CL_UI5_APP_ANIM_HUB"}` ).

  ENDMETHOD.

  METHOD send.

    result = post( `{"ID":"` && mv_id && `","EVENT":"` && event && `","T_EVENT_ARG":["` && arg &&
                   `"],"ORIGIN":"O","PATHNAME":"/p","SEARCH":""}` ).

  ENDMETHOD.

  METHOD post.

    DATA(ls_req) = VALUE z2ui5_cl_ui5_http_handler=>ty_s_http_req( method = `POST` ).
    ls_req-body = `{"value":{"S_FRONT":` && front && `}}`.

    DATA(ls_res) = z2ui5_cl_ui5_http_handler=>_main( ls_req ).
    cl_abap_unit_assert=>assert_equals( exp = 200
                                        act = ls_res-status_code
                                        msg = ls_res-body ).

    result = ls_res-body.
    mv_id = substring_before( val = substring_after( val = result
                                                     sub = `"ID":"` )
                              sub = `"` ).
    cl_abap_unit_assert=>assert_not_initial( mv_id ).

  ENDMETHOD.

  METHOD instance_of.

    result = substring_before( val = substring_after( val = body
                                                      sub = `"appInstance":"` )
                               sub = `"` ).

  ENDMETHOD.

ENDCLASS.
