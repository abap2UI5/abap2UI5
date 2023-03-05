CLASS z2ui5_cl_app_demo_04 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.
    CLASS-METHODS factory
      IMPORTING
        i_app           TYPE REF TO z2ui5_if_app
        i_name_attri    TYPE string
      RETURNING
        VALUE(r_result) TYPE REF TO z2ui5_cl_app_demo_04.


    DATA mo_app TYPE REF TO z2ui5_if_app.
    DATA mv_name_attri TYPE string.

PROTECTED SECTION.
PRIVATE SECTION.
ENDCLASS.



CLASS Z2UI5_CL_APP_DEMO_04 IMPLEMENTATION.


  METHOD factory.

    CREATE OBJECT r_result.

    r_result->mo_app = i_app.
    r_result->mv_name_attri = i_name_attri.

  ENDMETHOD.


  METHOD z2ui5_if_app~controller.

    CASE client->get( )-lifecycle_method.


        "when the app starts for the first time, this part is calles
      WHEN client->cs-lifecycle_method-on_init.

        "set init values or view here
        client->display_view( 'MAIN' ).
        client->display_message_box( 'method on_init of the abap controller was called' ).


        "every event raised by an ui5 control , is send to this part
      WHEN client->cs-lifecycle_method-on_event.

        CASE client->get( )-event.

          WHEN 'BUTTON_ROUNDTRIP'.
            client->display_message_box( 'server-client roundtrip, method on_event of the abap controller was called' ).

          WHEN 'BUTTON_RESTART'.
            DATA temp1 TYPE REF TO z2ui5_cl_app_demo_04.
            CREATE OBJECT temp1 TYPE z2ui5_cl_app_demo_04.
            client->nav_to_app( temp1 ).

          WHEN 'BUTTON_CHANGE_APP'.
            DATA temp2 TYPE REF TO z2ui5_cl_app_demo_01.
            CREATE OBJECT temp2 TYPE z2ui5_cl_app_demo_01.
            client->nav_to_app( temp2 ).

          WHEN 'BUTTON_CHANGE_VIEW'.

            "read the active view
            CASE client->get( )-view_active.
              WHEN 'MAIN'.
                client->display_view( 'SECOND' ).
              WHEN 'SECOND'.
                client->display_view( 'MAIN' ).
            ENDCASE.

        ENDCASE.


        "when the server is called, in the end this part is called to get the actual view of the app
      WHEN client->cs-lifecycle_method-on_rendering.

        "Definition of View Main
        DATA view TYPE REF TO z2ui5_if_ui5_library.
        view = client->factory_view( 'MAIN' ).

        view->page( title = 'ABAP2UI5 - Controller' nav_button_tap = view->_event_display_id( client->get( )-id_prev_app )

           )->grid( 'L6 M12 S12' )->content( 'l'
           )->simple_form( 'Controller' )->content( 'f'

             )->label( 'Roundtrip'
             )->button( text = 'Client/Server Interaction' press = view->_event( 'BUTTON_ROUNDTRIP' )

             )->label( 'System'
             )->button( text = 'Restart App' press = view->_event( 'BUTTON_RESTART' )

             )->label( 'Change View'
             )->button( text = 'Display View SECOND' press = view->_event( 'BUTTON_CHANGE_VIEW' )

             )->label( 'Change App'
             )->button( text = 'Display APP_DEMO_01' press = view->_event( 'BUTTON_CHANGE_APP' ) ).


        "Definition of View Second
        view = client->factory_view( 'SECOND' ).
        DATA temp3 TYPE string.
        IF client->get( )-check_previous_app IS NOT INITIAL.
          temp3 = view->_event_display_id( client->get( )-id_prev_app ).
        ELSE.
          CLEAR temp3.
        ENDIF.
        view->page( title = 'ABAP2UI5 - Controller' nav_button_tap = temp3

          )->grid( default_span  = 'L12 M12 S12' )->content( 'l'
          )->simple_form( 'View Second' )->content( 'f'

             )->label( 'Change View'
             )->button( text = 'Display View MAIN' press = view->_event( 'BUTTON_CHANGE_VIEW' ) ).

    ENDCASE.

  ENDMETHOD.
ENDCLASS.
