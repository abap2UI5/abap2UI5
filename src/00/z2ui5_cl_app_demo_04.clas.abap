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
    DATA check_initialized TYPE abap_bool.
    DATA mv_view_main TYPE string.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS Z2UI5_CL_APP_DEMO_04 IMPLEMENTATION.


  METHOD factory.

    r_result = NEW #( ).

    r_result->mo_app = i_app.
    r_result->mv_name_attri = i_name_attri.

  ENDMETHOD.


  METHOD z2ui5_if_app~main.

    IF check_initialized = abap_false.
      check_initialized = abap_true.

      mv_view_main = 'MAIN'.
      client->popup_message_box( 'app started, init values set' ).

    ENDIF.


    CASE client->get( )-event.

      WHEN 'BUTTON_ROUNDTRIP'.
        client->popup_message_box( 'server-client roundtrip, method on_event of the abap controller was called' ).

      WHEN 'BUTTON_RESTART'.
        client->nav_app_call( NEW z2ui5_cl_app_demo_04( ) ).

      WHEN 'BUTTON_CHANGE_APP'.
        client->nav_app_call( NEW z2ui5_cl_app_demo_01( ) ).

      WHEN 'BUTTON_CHANGE_VIEW'.

        CASE mv_view_main.
          WHEN 'MAIN'.
            mv_view_main = 'SECOND'.
          WHEN 'SECOND'.
            mv_view_main = 'MAIN'.
        ENDCASE.

      WHEN 'BUTTON_ERROR'.
        DATA(lv_dummy) = 1 / 0.

      WHEN 'BACK'.
        client->nav_app_leave( client->get_app( client->get( )-id_prev_app_stack ) ).

    ENDCASE.

    CASE mv_view_main.

      WHEN 'MAIN'.

        DATA(page) = Z2UI5_CL_XML_VIEW=>factory( )->shell(
            )->page(
                title          = 'abap2UI5 - Controller'
                navbuttonpress = client->_event( 'BACK' )
                shownavbutton = abap_true
                )->header_content(
                    )->link(
                        text = 'Source_Code'
                        href = Z2UI5_CL_XML_VIEW=>hlp_get_source_code_url( app = me get = client->get( ) )
                        target = '_blank'
                )->get_parent( ).

        page->grid( 'L6 M12 S12' )->content( 'layout'
            )->simple_form( 'Controller' )->content( 'form'
                )->label( 'Roundtrip'
                )->button(
                    text  = 'Client/Server Interaction'
                    press = client->_event( 'BUTTON_ROUNDTRIP' )
                )->label( 'System'
                )->button(
                    text  = 'Restart App'
                    press = client->_event( 'BUTTON_RESTART' )
                )->label( 'Change View'
                )->button(
                    text  = 'Display View SECOND'
                    press = client->_event( 'BUTTON_CHANGE_VIEW' )
                )->label( 'CX_SY_ZERO_DIVIDE'
                )->button(
                    text  = 'Error not catched by the user'
                    press = client->_event( 'BUTTON_ERROR' ) ).

      WHEN 'SECOND'.

        page = Z2UI5_CL_XML_VIEW=>factory( )->shell(
            )->page(
                title          = 'abap2UI5 - Controller'
                navbuttonpress = client->_event( 'BACK' )
                shownavbutton = abap_true
                ).

        page->grid( 'L12 M12 S12' )->content( 'layout'
            )->simple_form( 'View Second' )->content( 'form'
                )->label( 'Change View'
                )->button(
                    text  = 'Display View MAIN'
                    press = client->_event( 'BUTTON_CHANGE_VIEW' ) ).

    ENDCASE.

    client->set_next( VALUE #( xml_main = page->get_root(  )->xml_get( ) ) ).


  ENDMETHOD.
ENDCLASS.
