CLASS z2ui5_cl_app_demo_24 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.
    CLASS-METHODS factory
      IMPORTING
        i_app           TYPE REF TO z2ui5_if_app
        i_name_attri    TYPE string
      RETURNING
        VALUE(r_result) TYPE REF TO z2ui5_cl_app_demo_24.


    DATA mv_input TYPE string.

    DATA mo_app TYPE REF TO z2ui5_if_app.
    DATA mv_name_attri TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_app_demo_24 IMPLEMENTATION.


  METHOD factory.

    r_result = NEW #( ).

    r_result->mo_app = i_app.
    r_result->mv_name_attri = i_name_attri.

  ENDMETHOD.


  METHOD z2ui5_if_app~controller.

    CASE client->get( )-lifecycle_method.

      WHEN client->cs-lifecycle_method-on_init.
        client->view_show( 'MAIN' ).


        "every event raised by an ui5 control , is send to this part
      WHEN client->cs-lifecycle_method-on_event.

        CASE client->get( )-event.

          WHEN 'CALL_NEW_APP'.
            client->nav_app_call( NEW z2ui5_cl_app_demo_25( )  ).

          WHEN 'CALL_NEW_APP_VIEW'.
            client->nav_app_call( NEW z2ui5_cl_app_demo_25( ) ).
            client->view_show( 'SECOND' ).

          WHEN 'CALL_NEW_APP_READ'.
            DATA(lo_app_next) = NEW z2ui5_cl_app_demo_25( ).
            lo_app_next->mv_input_previous = mv_input.
            client->nav_app_call( lo_app_next ).

          WHEN 'CALL_NEW_APP_EVENT'.
            client->nav_app_call( NEW z2ui5_cl_app_demo_25( ) ).
            client->set( event = 'NEW_APP_EVENT' ).

          WHEN 'CALL_NEW_APP_INPUT_RETURN'.
            DATA(lo_called_app) = CAST z2ui5_cl_app_demo_25( client->get_app_by_id( client->get( )-id_prev_app ) ).
            client->popup_message_box( `Input made in the previous app:` && lo_called_app->mv_input ).

          WHEN 'BACK'.
            client->nav_app_leave( client->get( )-id_prev_app_stack ).

        ENDCASE.


        "when the server is called, in the end this part is called to get the actual view of the app
      WHEN client->cs-lifecycle_method-on_rendering.

        "Definition of View Main
        DATA(view) = client->factory_view( ).

        view->page( title = 'abap2UI5 - Controller' nav_button_tap = view->_event( 'BACK' )
           )->header_content( )->link( text = 'Go to Source Code' href = client->get( )-s_request-url_source_code )->get_parent(

           )->grid( 'L6 M12 S12' )->content( 'l'

           )->simple_form( 'Controller' )->content( 'f'

             )->label( 'Demo'
             )->button( text = 'Call new app (default View)' press = view->_event( 'CALL_NEW_APP' )
             )->label( 'Demo'
             )->button( text = 'Call new app and set view' press = view->_event( 'CALL_NEW_APP_VIEW' )
                   )->label( 'Demo'
             )->button( text = 'Call new app and set event' press = view->_event( 'CALL_NEW_APP_EVENT' )
             )->label( 'Demo'
             )->button( text = 'Call new app and set data of previous app' press = view->_event( 'CALL_NEW_APP_READ' )
        ).


    ENDCASE.

  ENDMETHOD.
ENDCLASS.
