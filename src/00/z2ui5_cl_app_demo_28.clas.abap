CLASS z2ui5_cl_app_demo_28 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    DATA mt_draft TYPE REF TO data.
    DATA mv_test TYPE REF TO data.

  PROTECTED SECTION.

    DATA client TYPE REF TO z2ui5_if_client.
    DATA:
      BEGIN OF app,
        check_initialized TYPE abap_bool,
        view_main         TYPE string,
        view_popup        TYPE string,
        get               TYPE z2ui5_if_client=>ty_s_get,
        next              TYPE z2ui5_if_client=>ty_s_next,
      END OF app.

    METHODS z2ui5_on_init.
    METHODS z2ui5_on_event.
    METHODS z2ui5_on_render.

  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_app_demo_28 IMPLEMENTATION.


  METHOD z2ui5_if_app~controller.

    me->client     = client.
    app-get        = client->get( ).
    app-view_popup = ``.

    IF app-check_initialized = abap_false.
      app-check_initialized = abap_true.
      z2ui5_on_init( ).
    ENDIF.

    IF app-get-event IS NOT INITIAL.
      z2ui5_on_event( ).
    ENDIF.

    z2ui5_on_render( ).

    client->set_next( app-next ).
    CLEAR app-get.
    CLEAR app-next.

  ENDMETHOD.


  METHOD z2ui5_on_event.

    CASE app-get-event.

      WHEN 'BUTTON_POST'.
*        client->popup_message_toast( |{ product } { quantity } - send to the server| ).
        app-view_popup = 'POPUP_CONFIRM'.

      WHEN 'BUTTON_CONFIRM'.
        client->popup_message_toast( |confirm| ).
        app-view_popup = ''.

      WHEN 'TIMER_FINISHED'.

        FIELD-SYMBOLS <mt_draft> TYPE STANDARD TABLE.

        " OF z2ui5_t_draft.
        ASSIGN mt_draft->* TO <mt_draft>.

        SELECT FROM z2ui5_t_draft
            FIELDS *
            ORDER BY uuid
          INTO TABLE @DATA(lt_data)
            UP TO 2 ROWS
            .
        APPEND LINES OF lt_data TO <mt_draft>.
        "!"mt_draft->* = CORRESPONDING #( lt_data ).
        "!
        app-next-s_timer-interval_ms = '2000'.
        app-next-s_timer-event_finished = 'TIMER_FINISHED'.

      WHEN 'BUTTON_CANCEL'.
        client->popup_message_toast( |cancel| ).
        app-view_popup = ''.

      WHEN 'BACK'.
        client->nav_app_leave( client->get_app( app-get-id_prev_app_stack ) ).

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
    FIELD-SYMBOLS <field> type string.
    assign  mv_test->* to <field>.
    <field> = 'test'.

    CREATE DATA mt_draft TYPE STANDARD TABLE OF z2ui5_t_draft.

    SELECT FROM z2ui5_t_draft
        FIELDS uuid, uuid_prev
        ORDER BY uuid
      INTO TABLE @DATA(lt_data)
        UP TO 10 ROWS
        .

    types ty_t_draft type STANDARD TABLE OF z2ui5_t_draft.
    FIELD-SYMBOLS: <tab> TYPE ty_t_draft.

    assign  mt_draft->*  to <tab>.
    <tab> = CORRESPONDING #( lt_data ).

    app-next-s_timer-interval_ms = '2000'.
    app-next-s_timer-event_finished = 'TIMER_FINISHED'.

  ENDMETHOD.


  METHOD z2ui5_on_render.

    DATA(lo_view) = z2ui5_cl_xml_view_helper=>factory( )->shell( )->page(
             title          = 'abap2UI5 - First Example'
             navbuttonpress = client->_event( 'BACK' )
             shownavbutton  = abap_true
         )->header_content(
             )->link(
                 text = 'Source_Code' target = '_blank'
                 href = z2ui5_cl_xml_view_helper=>hlp_get_source_code_url( app = me get = client->get( ) )
         )->get_parent(
         )->simple_form( title = 'Form Title' editable = abap_true
             )->content( 'form'
                 )->title( 'Input'
                 )->label( 'quantity' ).


    FIELD-SYMBOLS <field> type string.
    ASSIGN mv_test->* to <field>.

    lo_view->input( client->_bind( val = <field>  check_gen_data = abap_true ) ).

    lo_view->button(
                text  = 'post'
                press = client->_event( 'BUTTON_POST' )
            ).

FIELD-SYMBOLS <tab> type STANDARD TABLE.
    assign mt_draft->* to <tab>.
    DATA(tab) = lo_view->get_parent( )->get_parent( )->simple_form( title = 'Table' editable = abap_true
              )->content( 'form' )->table(
                items = client->_bind( val = <tab>  check_gen_data = abap_true )
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

    app-next-xml_main = lo_view->get_root( )->xml_get( ).

  ENDMETHOD.

ENDCLASS.
