CLASS z2ui5_cl_app_demo_17 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    data check_initialized type abap_bool.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS Z2UI5_CL_APP_DEMO_17 IMPLEMENTATION.


  METHOD z2ui5_if_app~controller.

    CASE client->get( )-lifecycle_method.

      WHEN client->cs-lifecycle_method-on_event.

        IF check_initialized = abap_false.
          check_initialized = abap_true.


          RETURN.
        ENDIF.


        CASE client->get( )-event.

          WHEN 'BUTTON_ROUNDTRIP'.
            DATA(lv_dummy) = 'user pressed a button, your custom implementation can be called here'.

          WHEN 'BUTTON_MSG_BOX'.
            client->popup_message_box(
              text = 'this is a message box with a custom text'
              type = 'success' ).

          WHEN 'BACK'.
            client->nav_app_leave( client->get( )-id_prev_app_stack ).

        ENDCASE.


      WHEN client->cs-lifecycle_method-on_rendering.

        DATA(view) = client->factory_view( ).


        data(page) = view->object_page_layout(
             showtitleinheadercontent = abap_true
             showeditheaderbutton     = abap_true
             editheaderbuttonpress    =  client->_event( 'EDIT_HEADER_PRESS' )
             uppercaseanchorbar       =  abap_false
         ).

         data(header_title) = page->header_title(  )->object_page_dyn_header_title( ).

        header_title->expanded_heading(
                )->hbox(
                    )->title( text = 'Denise Smith' wrapping = abap_true ).

        header_title->snapped_heading(
                )->flex_box( alignitems = `Center`
                    ")->avatar( text = 'Denise Smith' ).
                    )->title( text = 'Denise Smith' ).

        header_title->expanded_content( )->text( `Senior UI Developer` ).
        header_title->snapped_Content( )->text( `Senior UI Developer` ).
        header_title->snapped_Title_On_Mobile( )->title( `Senior UI Developer` ).

        header_title->actions( )->overflow_toolbar(
             )->overflow_toolbar_button(
                 icon    = `sap-icon://edit`
                 text    = 'edit header'
                 type    = 'Emphasized'
                 tooltip = 'edit'
             )->overflow_toolbar_button(
                 icon    = `sap-icon://pull-down`
                 text    = 'show section'
                 type    = 'Emphasized'
                 tooltip = 'pull-down'
             )->overflow_toolbar_button(
                 icon = `sap-icon://show`
                 text = 'show state'
                 tooltip = 'show'
             )->button(
                 icon = `sap-icon://edit`
                 text = 'Toggle Footer'
                 press = client->_event( 'TOGGLE_FOOTER' )
             ).

       data(header_content) = page->header_Content(  ns = 'uxap' ).

       header_content->flex_box(
            )->link(  text    = '+33 6 4512 5158'
            )->link(  text    = 'DeniseSmith@sap.com'
            )->label( text    = 'Hello! I am Denise and I use UxAP'
            )->label( text    = 'San Jose, USA'
       ).

    ENDCASE.

  ENDMETHOD.
ENDCLASS.
