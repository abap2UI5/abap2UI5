CLASS z2ui5_cl_app_demo_35 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    DATA mt_table TYPE REF TO data.
    DATA mv_name TYPE string.

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



CLASS z2ui5_cl_app_demo_35 IMPLEMENTATION.


  METHOD z2ui5_if_app~main.

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

        CREATE DATA mt_table TYPE STANDARD TABLE OF (mv_name).
        FIELD-SYMBOLS <tab> TYPE table.
        ASSIGN mt_table->* TO <tab>.

        SELECT FROM (mv_name)
            FIELDS *
          INTO CORRESPONDING FIELDS OF TABLE @<tab>
            UP TO 100 ROWS.


      WHEN 'BUTTON_CONFIRM'.
        client->popup_message_toast( |confirm| ).
        app-view_popup = ''.

      WHEN 'BUTTON_CANCEL'.
        client->popup_message_toast( |cancel| ).
        app-view_popup = ''.

      WHEN 'BACK'.
        client->nav_app_leave( client->get_app( app-get-id_prev_app_stack ) ).

    ENDCASE.

  ENDMETHOD.


  METHOD z2ui5_on_init.

    app-view_main = 'VIEW_MAIN'.
    mv_name = `Z2UI5_T_DRAFT`.

  ENDMETHOD.


  METHOD z2ui5_on_render.

    DATA(lo_view) = z2ui5_cl_xml_view=>factory( )->shell( )->page(
             title          = 'abap2UI5 - Change the table type with RTTI'
             navbuttonpress = client->_event( 'BACK' )
             shownavbutton  = abap_true
         )->header_content(
             )->link(
                 text = 'Source_Code' target = '_blank'
                 href = z2ui5_cl_xml_view=>hlp_get_source_code_url( app = me get = client->get( ) )
         )->get_parent(
         )->simple_form( title = 'SE16' editable = abap_true
             )->content( `form`
                 )->title( 'Table'
                 )->label( 'Name' ).

    lo_view->input( client->_bind( mv_name  ) ).

    lo_view->button(
                text  = 'search'
                press = client->_event( 'BUTTON_POST' )
            ).

    IF mt_table IS BOUND.

      FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
      ASSIGN mt_table->* TO <tab>.
      DATA(tab) = lo_view->get_parent( )->get_parent( )->simple_form( title = 'Table' editable = abap_true
                )->content( 'form' )->table(
                  items = client->_bind( val = <tab>  check_gen_data = abap_true )
              ).

      DATA(lt_fields) = lcl_db=>get_fieldlist_by_table( <tab> ).

      DATA(lo_columns) = tab->columns( ).
      LOOP AT lt_fields INTO DATA(lv_field) FROM 2.
        lo_columns->column( )->text( lv_field ).
      ENDLOOP.

      DATA(lo_cells) = tab->items( )->column_list_item( selected = '{SELKZ}' )->cells( ).
      LOOP AT lt_fields INTO lv_field FROM 2.
        lo_cells->input( `{` && lv_field && `}` ).
      ENDLOOP.

    ENDIF.

    app-next-xml_main = lo_view->get_root( )->xml_get( ).

  ENDMETHOD.
ENDCLASS.
