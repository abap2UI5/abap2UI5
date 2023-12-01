CLASS z2ui5_cl_test_features DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    DATA mv_input TYPE string.
    DATA mv_input2 TYPE string.
    DATA mv_backend_event TYPE string.
    DATA mv_check_popup_active TYPE abap_bool.
    DATA mv_check_initialized TYPE abap_bool.
  PROTECTED SECTION.

    METHODS display_view
      IMPORTING
        client TYPE REF TO z2ui5_if_client.

  PRIVATE SECTION.
ENDCLASS.



CLASS Z2UI5_CL_TEST_FEATURES IMPLEMENTATION.


  METHOD display_view.

    DATA(view) = z2ui5_cl_xml_view=>factory( ).
    view->shell(
        )->page( title = 'abap2UI5 - flow logic - APP 01' navbuttonpress = client->_event( val = 'BACK' check_view_destroy = abap_true ) shownavbutton = abap_true
        )->header_content(
            )->link( text = 'Demo'        target = '_blank' href = `https://twitter.com/abap2UI5/status/1640743794206228480`
            )->link( text = 'Source_Code' target = '_blank' href = z2ui5_cl_demo_utility=>factory( client )->app_get_url_source_code( )
        )->get_parent(

       )->grid( 'L6 M12 S12' )->content( 'layout'

       )->simple_form( 'Controller' )->content( 'form'

         )->label( 'Test'
         )->button( text = 'z2ui5_cl_ui_pop_to_confirm' press = client->_event( 'z2ui5_cl_ui_pop_to_confirm' )
         )->label( 'Test'
         )->button( text = 'z2ui5_cl_ui_pop_messages' press = client->_event( 'z2ui5_cl_ui_pop_messages' )
         )->label( 'Demo'
         )->button( text = 'z2ui5_cl_ui_pop_to_select' press = client->_event( 'z2ui5_cl_ui_pop_to_select' )
         )->label( 'Demo'
         )->input( client->_bind_edit( mv_input )
         )->button( text = 'call new app (set data)' press = client->_event( 'CALL_NEW_APP_READ' )
              )->label( 'some data, you can read it in the next app'
         )->input( client->_bind_edit( mv_input2 )
    ).

    client->view_display( view->stringify( ) ).

  ENDMETHOD.


  METHOD z2ui5_if_app~main.

    if mv_check_initialized = abap_false.
    mv_check_initialized = abap_true.
       display_view( client ).
    endif.
*    IF client->get( )-check_on_navigated = abap_true.
*      display_view( client ).
*    ENDIF.

    IF   mv_check_popup_active = abap_true.

      DATA(lo_prev) = client->get_app( client->get(  )-s_draft-id_prev_app ).

      TRY.
          DATA(lo_popup_decide) = CAST z2ui5_cl_ui_pop_to_confirm( lo_prev ).
          client->message_box_display( `the result is ` && lo_popup_decide->check_result( ) ).
        CATCH cx_root.
      ENDTRY.

    ENDIF.

    mv_check_popup_active = abap_false.

    CASE client->get( )-event.

      WHEN 'z2ui5_cl_ui_pop_messages'.
        data(lo_popup_msg) = z2ui5_cl_ui_pop_messages=>factory(
          EXPORTING
            i_messages            =  VALUE #(
      ( message = 'An empty Report field causes an empty XML Message to be sent' type = 'E' id = 'MSG1' number = '001' )
      ( message = 'Check was executed for wrong Scenario' type = 'E' id = 'MSG1' number = '002' )
      ( message = 'Request was handled without errors' type = 'S' id = 'MSG1' number = '003' )
      ( message = 'product activated' type = 'S' id = 'MSG4' number = '375' )
      ( message = 'check the input values' type = 'W' id = 'MSG2' number = '375' )
      ( message = 'product already in use' type = 'I' id = 'MSG2' number = '375' )
       )
        ).

        client->nav_app_call( lo_popup_msg ).

      WHEN 'z2ui5_cl_ui_pop_to_confirm'.
        DATA(lo_app) = z2ui5_cl_ui_pop_to_confirm=>factory(
            i_question_text       = `this is a question`
        ).
        mv_check_popup_active = abap_true.
        client->nav_app_call( lo_app ).

      WHEN 'CALL_NEW_APP_READ'.
        DATA(lo_app_next) = NEW z2ui5_cl_demo_app_025( ).
        lo_app_next->mv_input_previous_set = mv_input.
        client->nav_app_call( lo_app_next ).

      WHEN 'CALL_NEW_APP_EVENT'.
        lo_app_next = NEW z2ui5_cl_demo_app_025( ).
        lo_app_next->mv_event_backend = 'NEW_APP_EVENT'.
        client->nav_app_call( lo_app_next  ).

      WHEN 'BACK'.
        DATA(lo_prev_stack_app) = client->get_app( client->get( )-s_draft-id_prev_app_stack ).
        client->nav_app_leave( lo_prev_stack_app ).

      WHEN OTHERS.

        CASE mv_backend_event.
          WHEN 'CALL_PREVIOUS_APP_INPUT_RETURN'.
            DATA(lo_called_app) = CAST z2ui5_cl_demo_app_025( client->get_app( client->get( )-s_draft-id_prev_app ) ).
            client->message_box_display( `Input made in the previous app:` && lo_called_app->mv_input ).
        ENDCASE.

    ENDCASE.

  ENDMETHOD.
ENDCLASS.
