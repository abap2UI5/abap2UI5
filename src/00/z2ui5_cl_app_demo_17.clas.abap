CLASS z2ui5_cl_app_demo_17 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    DATA check_initialized TYPE abap_bool.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS Z2UI5_CL_APP_DEMO_17 IMPLEMENTATION.


  METHOD z2ui5_if_app~main.

        IF check_initialized = abap_false.
          check_initialized = abap_true.

        ENDIF.


        CASE client->get( )-event.

          WHEN 'BUTTON_ROUNDTRIP'.
            DATA(lv_dummy) = 'user pressed a button, your custom implementation can be called here'.

          WHEN 'BUTTON_MSG_BOX'.
            client->popup_message_box(
              text = 'this is a message box with a custom text'
              type = 'success' ).

          WHEN 'BACK'.
            client->nav_app_leave( client->get_app( client->get( )-id_prev_app_stack ) ).

        ENDCASE.

        DATA(view) = Z2UI5_CL_XML_VIEW=>factory( ).


        DATA(page) = view->object_page_layout(
             showtitleinheadercontent = abap_true
             showeditheaderbutton     = abap_true
             editheaderbuttonpress    =  client->_event( 'EDIT_HEADER_PRESS' )
             uppercaseanchorbar       =  abap_false
         ).

        DATA(header_title) = page->header_title(  )->object_page_dyn_header_title( ).

        header_title->expanded_heading(
                )->hbox(

                    )->title( text = 'Oblomov Dev' wrapping = abap_true ).

        header_title->snapped_heading(
                )->flex_box( alignitems = `Center`
                  )->avatar( src = lcl_help=>get_avatar( ) class = 'sapUiTinyMarginEnd'
                    )->title( text = 'Oblomov Dev' wrapping = abap_true ).

        header_title->expanded_content( ns = `uxap` )->text( `abap2UI5 Developer` ).
        header_title->snapped_Content( ns = `uxap` )->text( `abap2UI5 Developer` ).
        header_title->snapped_Title_On_Mobile( )->title( `abap2UI5 Developer` ).

        header_title->actions( ns = `uxap` )->overflow_toolbar(
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
                " icon = `sap-icon://edit`
                 text = 'Go Back'
                 press = client->_event( 'BACK' )
             ).

        DATA(header_content) = page->header_Content( ns = 'uxap' ).

        header_content->flex_box( wrap = 'Wrap'
           )->avatar( src = lcl_help=>get_avatar( ) class = 'sapUiSmallMarginEnd' displaySize = 'layout'
            )->vertical_layout( class = 'sapUiSmallMarginBeginEnd'
                )->link(  text    = '+33 6 4512 5158'
                )->link(  text    = 'email@email.com'
            )->get_parent(
            )->horizontal_layout( class = 'sapUiSmallMarginBeginEnd'
                )->label( text    = 'Hello! I an abap2UI5 developer'
                )->label( text    = 'San Jose, USA'
            )->get_parent(
            )->vertical_layout( class = 'sapUiSmallMarginBeginEnd'
                )->label(  text    = 'Hello! I an abap2UI5 developer'
                )->vbox(
                    )->label( 'Achived goals'
                    )->progress_indicator( percentvalue = '30%' displayvalue = '30%'
            )->get_parent(  )->get_parent(
          "  )->avatar( src = lcl_help=>get_avatar( ) class = 'sapUiSmallMarginEnd' displaySize = 'layout'
            )->vertical_layout( class = 'sapUiSmallMarginBeginEnd'
                )->label(  text    = 'San Jose, USA'
            )->get_parent(
        ).


        data(sections) = page->sections( ).

        sections->object_page_section( titleuppercase = abap_false id = 'goalsSectionSS1' title = '2014 Goals Plan'
            )->heading( ns = `uxap`
                )->message_strip( text = 'this is a message strip'
            )->get_parent(
            )->sub_sections(
                )->object_page_sub_section( id = 'goalssubSectionSS1' title = 'goals1'
                    )->blocks(
                          )->vbox(
                          )->label( text    = 'goals1'
                          )->label( text    = 'goals1'
                          )->label( text    = 'goals1'
                          )->label( text    = 'goals1'
                          )->label( text    = 'goals1'
                          )->label( text    = 'goals1'
                          )->label( text    = 'goals1'
                          )->label( text    = 'goals1'
                          )->label( text    = 'goals1'
                          )->label( text    = 'goals1'

                )->get_parent( )->get_parent( )->get_parent(
                )->object_page_sub_section( id = 'goalsSectionWS1' title = 'goals2'
                      )->blocks(
                            )->vbox(
                          )->label( text    = 'goals2'
                          )->label( text    = 'goals2'
                          )->label( text    = 'goals2'
                          )->label( text    = 'goals2'
                          )->label( text    = 'goals2'
                          )->label( text    = 'goals2'
                          )->label( text    = 'goals2'
                          )->label( text    = 'goals2').

         sections->object_page_section( titleuppercase = abap_false id = 'PersonalSection' title = 'Personal'
            )->heading( ns = `uxap`
           "     )->message_strip( text = 'this is a message strip'
            )->get_parent(
            )->sub_sections(
                )->object_page_sub_section( id = 'personalSectionSS1' title = 'Connect'
                    )->blocks(
                          )->label( text    = 'telefon'
                          )->label( text    = 'email'
                )->get_parent( )->get_parent(
                )->object_page_sub_section( id = 'personalSectionWS2' title = 'Payment information  '
                      )->blocks(
                          )->label( text    = 'Hello! I an abap2UI5 developer'
                          )->label( text    = 'San Jose, USA' ).


           sections->object_page_section( titleuppercase = abap_false id = 'employmentSection' title = 'Employment'
            )->heading( ns = `uxap`
           "     )->message_strip( text = 'this is a message strip'
            )->get_parent(
            )->sub_sections(
                )->object_page_sub_section( id = 'empSectionSS1' title = 'Job information'
                    )->blocks(
                          )->label( text    = 'info'
                          )->label( text    = 'info'
                          )->label( text    = 'info'
                          )->label( text    = 'info'
                          )->label( text    = 'info'
                )->get_parent( )->get_parent(
                )->object_page_sub_section( id = 'empSectionWS2' title = 'Employee Details '
                      )->blocks(
                            )->vbox(
                          )->label( text    = 'details'
                          )->label( text    = 'details'
                          )->label( text    = 'details'
                          )->label( text    = 'details'
                          )->label( text    = 'details'
                          )->label( text    = 'details'
                          )->label( text    = 'details'
                          )->label( text    = 'details' ).

          client->set_next( value #( xml_main = page->get_root(  )->xml_get( ) ) ).

  ENDMETHOD.
ENDCLASS.
