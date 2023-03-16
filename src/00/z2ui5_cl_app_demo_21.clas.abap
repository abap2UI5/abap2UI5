CLASS z2ui5_cl_app_demo_21 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.


    TYPES:
      BEGIN OF ty_row,
        title    TYPE string,
        value    TYPE string,
        descr    TYPE string,
        icon     TYPE string,
        info     TYPE string,
        checkbox TYPE abap_bool,
      END OF ty_row.

    DATA t_tab TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.

    DATA mv_value TYPE string VALUE 'value'.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS Z2UI5_CL_APP_DEMO_21 IMPLEMENTATION.


  METHOD z2ui5_if_app~controller.

    CASE client->get( )-lifecycle_method.

      WHEN client->cs-lifecycle_method-on_init.
        t_tab = REDUCE #( INIT ret = VALUE #( ) FOR n = 1 WHILE n < 11 NEXT ret =
      VALUE #( BASE ret ( title = 'Hans'  value = 'red' info = 'completed'  descr = 'this is a description' checkbox = abap_true ) ) ).



      WHEN client->cs-lifecycle_method-on_event.

        CASE client->get( )-event.

          WHEN 'BUTTON_POPUP_DECIDE'.

            client->nav_app_call( z2ui5_cl_app_demo_20=>factory(
                   i_text          = 'Do really want to continue?'
                   i_cancel_text   = 'No'
                   i_cancel_event  = 'POPUP_CONFIRM_NO'
                   i_confirm_text  = 'Yes'
                   i_confirm_event = 'POPUP_CONFIRM_YES' )
               ).

          WHEN 'BUTTON_POPUP_SELECT'.
            DATA(lo_popup_select) = z2ui5_cl_app_demo_23=>factory(
                 event_callback = 'POPUP_SELECT_RETURN'
                 i_tab = VALUE #( descr = 'this is a description'
                                     (  title = 'title_01'  value = 'value_01' )
                                     (  title = 'title_02'  value = 'value_02' )
                                     (  title = 'title_03'  value = 'value_03' )
                                     (  title = 'title_04'  value = 'value_04' ) ) ).
            client->nav_app_call( lo_popup_select ).

          WHEN 'POPUP_SELECT_RETURN'.
            lo_popup_select = CAST z2ui5_cl_app_demo_23( client->get_app_by_id( client->get( )-id_prev_app ) ).
            DELETE lo_popup_select->t_tab WHERE selkz <> abap_true.
            client->popup_message_box( 'Entry selected: ' && lo_popup_select->t_tab[ 1 ]-title ).

          WHEN 'POPUP_CONFIRM_YES'.
            client->popup_message_box( 'decide yes' ).

          WHEN 'POPUP_CONFIRM_NO'.
            client->popup_message_box( 'decide no' ).

          WHEN 'F4HELP'.
            client->popup_message_box( 'F4HELP' ).

          WHEN 'BUTTON_POPUP_01'.
            client->view_popup( 'BAL_POPUP' ).

          WHEN 'BUTTON_POPUP_02'.
            client->view_show( 'MAIN' ).
            client->view_popup( 'BAL_POPUP' ).

          WHEN 'BUTTON_POPUP_03'.
            client->view_show( 'MAIN' ).
            client->view_popup( 'BAL_POPUP2' ).

          WHEN 'BUTTON_POPUP_04'.
            client->set( set_prev_view = abap_true ).
            client->view_popup( 'BAL_POPUP2' ).

          WHEN 'BUTTON_POPUP_05'.
            client->nav_app_call( z2ui5_cl_app_demo_20=>factory(

              i_text          = 'Do really want to continue?'
              i_cancel_text   = 'No'
              i_cancel_event  = 'POPUP_CONFIRM_NO'
              i_confirm_text  = 'Yes'
              i_confirm_event = 'POPUP_CONFIRM_YES' )
          ).

          WHEN 'BUTTON_POPUP_06'.
            " client->set( set_prev_view = abap_true ).
            client->view_popup( 'POPUP_TABLE' ).

          WHEN 'POPUP_TABLE_SEND'.
            client->popup_message_box( 'entries edited' ).

        WHEN 'BACK'.
            client->nav_app_leave( client->get( )-id_prev_app_stack ).

        ENDCASE.


      WHEN client->cs-lifecycle_method-on_rendering.

        DATA(view) = client->factory_view( 'MAIN' ).
        DATA(page) = view->page( title = 'Example - ZZ2UI5_CL_APP_DEMO_07' nav_button_tap = view->_event( 'BACK' ) ).


        page->input(
            value = view->_bind( mv_value )
            showvaluehelp = abap_true
            valuehelprequest = view->_event( 'F4HELP' )
             ).

        page->button(
             text    = 'Popup new app - popup renderung, no view'
             press   = view->_event( 'BUTTON_POPUP_DECIDE' )
        ).

        page->button(
             text    = 'Popup same app - popup rendering, no view rendering'
             press   = view->_event( 'BUTTON_POPUP_01' )
        ).

        page->button(
             text    = 'Popup same app - popup rendering, view rendering'
             press   = view->_event( 'BUTTON_POPUP_02' )
        ).

        page->button(
             text    = 'Popup same app - popup rendering, view rendering - frontend close'
             press   = view->_event( 'BUTTON_POPUP_03' )
        ).

        page->button(
             text    = 'Popup same app - popup rendering, view previous'
             press   = view->_event( 'BUTTON_POPUP_04' )
        ).


        page->button(
             text    = 'Popup next app - popup rendering, view previous'
             press   = view->_event( 'BUTTON_POPUP_05' )
        ).

        page->button(
            text    = 'Popup select'
            press   = view->_event( 'BUTTON_POPUP_06' )
       ).


        client->set( focus = mv_value ).

        page->footer( )->overflow_toolbar(
              )->toolbar_spacer(
              )->button(
                  text  = 'Send to Server'
                  press = view->_event( 'BUTTON_SEND' )
                  type  = 'Success' ).


        view = client->factory_view( 'BAL_POPUP' ).

        DATA(popup) = view->dialog( title = 'Example - ZZ2UI5_CL_APP_DEMO_07' ).

        popup->text( text = 'this is a message' ).
        popup->button( text = 'YES' press = view->_event( 'POPUP_CONFIRM_YES' ) ).
        popup->button( text = 'NO'  press = view->_event( 'POPUP_CONFIRM_NO' ) ).

        popup->footer( )->overflow_toolbar(
              )->toolbar_spacer(
              )->button(
                  text  = 'Send to Server'
                  press = view->_event( 'BUTTON_SEND' )
                  type  = 'Success' ).

        view = client->factory_view( 'BAL_POPUP2' ).

        popup = view->dialog( title = 'Example - ZZ2UI5_CL_APP_DEMO_07' ).

        popup->text( text = 'this popup frontend close' ).
        popup->button( text = 'YES' press = view->_event( 'POPUP_CONFIRM_YES' ) ).
        popup->button( text = 'NO'  press = view->_event( 'POPUP_CONFIRM_NO' ) ).

        popup->footer( )->overflow_toolbar(
              )->toolbar_spacer(
              )->button(
                  text  = 'frontend close'
                  press = view->_event_frontend_close_popup( )
                  type  = 'Success' ).




        view = client->factory_view( 'POPUP_TABLE' ).

        popup = view->dialog( title = 'Example - ZZ2UI5_CL_APP_DEMO_07' ).

        DATA(tab) = popup->table( view->_bind( t_tab ) ).

        "set toolbar
        tab->header_toolbar( )->overflow_toolbar(
            )->title( 'title of the table' ).

        "set header
        tab->columns(
            )->column( )->text( 'Title' )->get_parent(
            )->column( )->text( 'Color' )->get_parent(
            )->column( )->text( 'Info' )->get_parent(
            )->column( )->text( 'Description' )->get_parent(
            )->column( )->text( 'Checkbox' ).

        tab->items( )->column_list_item( )->cells(
            )->input( '{TITLE}'
            )->input( '{VALUE}'
            )->input( '{INFO}'
            )->input( '{DESCR}'
            )->checkbox( selected = '{CHECKBOX}' enabled = abap_true ).

        popup->footer( )->overflow_toolbar(
                    )->toolbar_spacer(
                    )->button(
                        text  = 'Commit'
                        press = view->_event( 'POPUP_TABLE_SEND' )
                        type  = 'Success' ).
    ENDCASE.

  ENDMETHOD.
ENDCLASS.
