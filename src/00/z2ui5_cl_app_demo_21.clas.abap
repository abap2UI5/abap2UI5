CLASS z2ui5_cl_app_demo_21 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.
    
    DATA mv_value TYPE string VALUE 'value'.

  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA mv_id_popup_select TYPE string.
ENDCLASS.



CLASS z2ui5_cl_app_demo_21 IMPLEMENTATION.


  METHOD z2ui5_if_app~controller.

    CASE client->get( )-lifecycle_method.

      WHEN client->cs-lifecycle_method-on_init.


      WHEN client->cs-lifecycle_method-on_event.
        "implement event handling here

        CASE client->get( )-event.

          WHEN 'BUTTON_POPUP_COMFIRM'.

            client->nav_to_app_new( z2ui5_cl_app_demo_20=>factory(
                   i_text          = 'Do really want to continue?'
                   i_cancel_text   =  'No'
                   i_cancel_event  = 'POPUP_CONFIRM_NO'
                   i_confirm_text  =  'Yes'
                   i_confirm_event =  'POPUP_CONFIRM_YES'   )
               ).

          WHEN 'BUTTON_POPUP_SELECT'.
            DATA(lo_popup_select) = z2ui5_cl_app_demo_23=>factory(
                 event_return = 'POPUP_SELECT_RETURN'
                 i_tab = VALUE #( descr = 'this is a description'
                                     (  title = 'title_01'  value = 'value_01'  )
                                     (  title = 'title_02'  value = 'value_02'  )
                                     (  title = 'title_03'  value = 'value_03'  )
                                     (  title = 'title_04'  value = 'value_04'  ) ) ).
            client->nav_to_app_new( lo_popup_select ).

          WHEN 'POPUP_SELECT_RETURN'.
            lo_popup_select = CAST z2ui5_cl_app_demo_23( client->get_app_by_id( mv_id_popup_select ) ).
            DELETE lo_popup_select->t_tab WHERE selkz <> abap_true.
            client->display_message_box( 'Entry selected: ' && lo_popup_select->t_tab[ 1 ]-title ).

          WHEN 'POPUP_CONFIRM_YES'.
            client->display_message_box( 'confirm yes' ).

          WHEN 'POPUP_CONFIRM_NO'.
            client->display_message_box( 'confirm no' ).

          WHEN 'F4HELP'.
            client->display_message_box( 'F4HELP' ).

        ENDCASE.



      WHEN client->cs-lifecycle_method-on_rendering.

        DATA(view) = client->factory_view( ).
        DATA(page) = view->page( title = 'Example - ZZ2UI5_CL_APP_DEMO_07' nav_button_tap = view->_event_display_id( client->get( )-id_prev_app ) ).


        page->input(
            value = view->_bind( mv_value )
            showvaluehelp = abap_true
            valuehelprequest = view->_event( 'F4HELP' )
             ).

        page->button(
             text    = 'Popup confirm'
             press   = 'BUTTON_POPUP_CONFIRM'
        ).

        page->button(
            text    = 'Popup select'
            press   = 'BUTTON_POPUP_SELECT'
       ).


        client->set( focus = mv_value ).

        page->footer( )->overflow_toolbar(
              )->toolbar_spacer(
              )->button(
                  text  = 'Send to Server'
                  press = view->_event( 'BUTTON_SEND' )
                  type  = 'Success' ).
    ENDCASE.

  ENDMETHOD.
ENDCLASS.
