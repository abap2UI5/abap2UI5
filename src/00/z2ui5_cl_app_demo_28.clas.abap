CLASS z2ui5_cl_app_demo_28 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

*    DATA product  TYPE string.
*    DATA quantity TYPE i.
*
*    DATA input21 TYPE string.
*    DATA input22 TYPE string.
*    DATA input41 TYPE string.

    DATA mt_draft TYPE REF TO data.
    DATA mv_test TYPE REF TO data.

  PROTECTED SECTION.

    DATA client TYPE REF TO z2ui5_if_client.
    DATA:
      BEGIN OF app,
        check_initialized TYPE abap_bool,
        view_main         TYPE string,
        view_popup        TYPE string,
        s_get             TYPE z2ui5_if_client=>ty_s_get,
        s_next            TYPE z2ui5_if_client=>ty_s_next,
      END OF app.

    METHODS z2ui5_on_init.
    METHODS z2ui5_on_event.
    METHODS z2ui5_on_render.

  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_app_demo_28 IMPLEMENTATION.


  METHOD z2ui5_if_app~controller.

    me->client     = client.
    app-s_get      = client->get( ).
    app-view_popup = ``.

    IF app-check_initialized = abap_false.
      app-check_initialized = abap_true.
      z2ui5_on_init( ).
    ENDIF.

    IF app-s_get-event IS NOT INITIAL.
      z2ui5_on_event( ).
    ENDIF.

    z2ui5_on_render( ).

    client->set_next( app-s_next ).
    CLEAR app-s_get.
    CLEAR app-s_next.

  ENDMETHOD.


  METHOD z2ui5_on_event.

    CASE app-s_get-event.

      WHEN 'BUTTON_POST'.
*        client->popup_message_toast( |{ product } { quantity } - send to the server| ).
        app-view_popup = 'POPUP_CONFIRM'.

      WHEN 'BUTTON_CONFIRM'.
        client->popup_message_toast( |confirm| ).
        app-view_popup = ''.

      WHEN 'BUTTON_CANCEL'.
        client->popup_message_toast( |cancel| ).
        app-view_popup = ''.

      WHEN 'BACK'.
        client->nav_app_leave( client->get_app( app-s_get-id_prev_app_stack ) ).

    ENDCASE.

  ENDMETHOD.


  METHOD z2ui5_on_init.

*    product  = 'tomato'.
*    quantity = '500'.
    app-view_main = 'VIEW_MAIN'.
*    input41 = 'faasdfdfsaVIp'.
*
*    input21 = '40'.
*    input22 = '40'.



    CREATE DATA mv_test TYPE string.
    mv_test->* = 'test'.

    CREATE DATA mt_draft TYPE STANDARD TABLE OF z2ui5_t_draft.

    SELECT FROM z2ui5_t_draft
        FIELDS uuid, uuid_prev
      INTO TABLE @DATA(lt_data)
        UP TO 10 ROWS.

    mt_draft->* = CORRESPONDING #( lt_data ).

  ENDMETHOD.


  METHOD z2ui5_on_render.

    DATA(lo_view) = z2ui5_cl_xml_view_helper=>factory( )->shell( )->page(
             title          = 'abap2UI5 - First Example'
             navbuttonpress = client->_event( 'BACK' )
             shownavbutton  = abap_true
         )->header_content(
             )->link(
                 text = 'Source_Code'
                 href = z2ui5_cl_xml_view_helper=>hlp_get_source_code_url( app = me get = client->get( ) )
         )->get_parent(
         )->simple_form( title = 'Form Title' editable = abap_true
             )->content( 'form'
                 )->title( 'Input'
                 )->label( 'quantity' ).

    lo_view->input( client->_bind( val = mv_test->*  check_gen_data = abap_true ) ).

    lo_view->button(
                text  = 'post'
                press = client->_event( 'BUTTON_POST' )
            ).

   data(tab) = lo_view->get_parent( )->get_parent( )->simple_form( title = 'Table' editable = abap_true
             )->content( 'form' )->table(
               items = client->_bind( val = mt_draft->*  check_gen_data = abap_true )
           ).

    tab->columns(
        )->column(
            )->text( 'UUID' )->get_parent(
        )->column(
            )->text( 'UUID_PREV' ).

    tab->items( )->column_list_item(
      )->cells(
          )->input( '{UUID}'
          )->input( '{UUID_PREV}'
      ).

    app-s_next-xml_main = lo_view->get_root( )->xml_get( ).

  ENDMETHOD.

ENDCLASS.
