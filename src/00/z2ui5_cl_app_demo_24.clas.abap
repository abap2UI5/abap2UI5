CLASS z2ui5_cl_app_demo_24 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    DATA mv_input TYPE string.
    DATA mv_input2 TYPE string.


  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS Z2UI5_CL_APP_DEMO_24 IMPLEMENTATION.


  METHOD z2ui5_if_app~controller.

    CASE client->get( )-lifecycle_method.

      WHEN client->cs-lifecycle_method-on_event.

        CASE client->get( )-event.

          WHEN 'CALL_NEW_APP'.
            client->nav_app_call( NEW z2ui5_cl_app_demo_25( ) ).

          WHEN 'CALL_NEW_APP_VIEW'.
            client->nav_app_call( NEW z2ui5_cl_app_demo_25( ) ).
            client->show_view( 'SECOND' ).

          WHEN 'CALL_NEW_APP_READ'.
            DATA(lo_app_next) = NEW z2ui5_cl_app_demo_25( ).
            lo_app_next->mv_input_previous_set = mv_input.
            client->nav_app_call( lo_app_next ).

          WHEN 'CALL_NEW_APP_EVENT'.
            client->nav_app_call( NEW z2ui5_cl_app_demo_25( ) ).
            client->set( event = 'NEW_APP_EVENT' ).

          WHEN 'CALL_PREVIOUS_APP_INPUT_RETURN'.
            DATA(lo_called_app) = CAST z2ui5_cl_app_demo_25( client->get_app_by_id( client->get( )-id_prev_app ) ).
            client->popup_message_box( `Input made in the previous app:` && lo_called_app->mv_input ).

          WHEN 'BACK'.
            client->nav_app_leave( client->get( )-id_prev_app_stack ).

        ENDCASE.


      WHEN client->cs-lifecycle_method-on_rendering.

        DATA(view) = client->factory_view( ).
        view->page( title = 'abap2UI5 - flow logic 1' navbuttonpress = client->_event( 'BACK' )
           )->header_content( )->link( text = 'Source_Code' href = client->get( )-s_request-url_source_code )->get_parent(

           )->grid( 'L6 M12 S12' )->content( 'l'

           )->simple_form( 'Controller' )->content( 'f'

             )->label( 'Demo'
             )->button( text = 'call new app (default View)' press = client->_event( 'CALL_NEW_APP' )
             )->label( 'Demo'
             )->button( text = 'call new app with view SECOND' press = client->_event( 'CALL_NEW_APP_VIEW' )
             )->label( 'Demo'
             )->button( text = 'call new app and set event' press = client->_event( 'CALL_NEW_APP_EVENT' )
             )->label( 'call new app and set this data'
             )->input( client->_bind( mv_input )
             )->button( text = 'call' press = client->_event( 'CALL_NEW_APP_READ' )
                  )->label( 'some data, you can read it in the next app'
             )->input( client->_bind( mv_input2 )
        ).

    ENDCASE.

  ENDMETHOD.
ENDCLASS.
