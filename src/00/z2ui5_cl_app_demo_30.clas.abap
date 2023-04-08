CLASS z2ui5_cl_app_demo_30 DEFINITION PUBLIC.

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

    DATA check_initialized TYPE abap_bool.
    DATA t_tab TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_app_demo_30 IMPLEMENTATION.


  METHOD z2ui5_if_app~controller.

    IF check_initialized = abap_false.
      check_initialized = abap_true.

          t_tab = VALUE #(
            ( title = 'Peter'  info = 'completed'   descr = 'this is a description' icon = 'sap-icon://account' )
            ( title = 'Peter'  info = 'incompleted' descr = 'this is a description' icon = 'sap-icon://account' )
            ( title = 'Peter'  info = 'working'     descr = 'this is a description' icon = 'sap-icon://account' )
            ( title = 'Peter'  info = 'working'     descr = 'this is a description' icon = 'sap-icon://account' )
            ( title = 'Peter'  info = 'completed'   descr = 'this is a description' icon = 'sap-icon://account' )
            ( title = 'Peter'  info = 'completed'   descr = 'this is a description' icon = 'sap-icon://account' )
            ( title = 'Peter'  info = 'completed'   descr = 'this is a description' icon = 'sap-icon://account' )
            ( title = 'Peter'  info = 'completed'   descr = 'this is a description' icon = 'sap-icon://account' )
            ( title = 'Peter'  info = 'completed'   descr = 'this is a description' icon = 'sap-icon://account' )
            ( title = 'Peter'  info = 'completed'   descr = 'this is a description' icon = 'sap-icon://account' )
            ( title = 'Peter'  info = 'completed'   descr = 'this is a description' icon = 'sap-icon://account' )
            ( title = 'Peter'  info = 'completed'   descr = 'this is a description' icon = 'sap-icon://account' )
            ( title = 'Peter'  info = 'completed'   descr = 'this is a description' icon = 'sap-icon://account' )
            ( title = 'Peter'  info = 'completed'   descr = 'this is a description' icon = 'sap-icon://account' )
            ( title = 'Peter'  info = 'completed'   descr = 'this is a description' icon = 'sap-icon://account' )
            ( title = 'Peter'  info = 'completed'   descr = 'this is a description' icon = 'sap-icon://account' )
            ( title = 'Peter'  info = 'completed'   descr = 'this is a description' icon = 'sap-icon://account' )
            ( title = 'Peter'  info = 'completed'   descr = 'this is a description' icon = 'sap-icon://account' )
            ( title = 'Peter'  info = 'completed'   descr = 'this is a description' icon = 'sap-icon://account' )
            ( title = 'Peter'  info = 'completed'   descr = 'this is a description' icon = 'sap-icon://account' )
          ).

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

    DATA(view) = z2ui5_cl_xml_view_helper=>factory( ).


    DATA(page) = view->dynamic_page(
       "  headerExpanded = abap_true
      "   toggleHeaderOnTitleClick = client->_event( 'ON_TITLE' )
     ).


    DATA(header_title) = page->title( ns = 'f' )->get( )->dynamic_page_title( ).

    header_title->heading( ns = 'f' )->title( 'Header Title' ).

    header_title->expanded_content( 'f'
             )->label( text = 'this is a subheading' ).

    header_title->snapped_content( ns = 'f'
             )->label( text = 'this is a subheading' ).

    header_title->actions( ns = 'f' )->overflow_toolbar(
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

    header_title->navigation_actions(
            )->button( icon = 'sap-icon://full-screen' type  = 'Transparent'
            )->button( icon = 'sap-icon://exit-full-screen' type  = 'Transparent'
            )->button( icon = 'sap-icon://decline' type  = 'Transparent'
    ).

    DATA(header_content) = page->header( )->dynamic_page_header(  pinnable = abap_true
        )->horizontal_layout(
            )->vertical_layout(
                   )->object_attribute( title = 'Location' text = 'Warehouse A'
                   )->object_attribute( title = 'Halway' text = '23L'
                   )->object_attribute( title = 'Rack' text = '34'
             )->get_parent(
               )->vertical_layout(
                    )->object_attribute( title = 'Location' text = 'Warehouse A'
                    )->object_attribute( title = 'Halway' text = '23L'
                    )->object_attribute( title = 'Rack' text = '34'
             )->get_parent(
              )->vertical_layout(
                   )->object_attribute( title = 'Location' text = 'Warehouse A'
                   )->object_attribute( title = 'Halway' text = '23L'
                   )->object_attribute( title = 'Rack' text = '34'
             ).


    DATA(cont) = page->content( ns = 'f' ).

    cont->list(
         headertext = 'List Ouput'
         items      = client->_bind_one( t_tab )
         )->standard_list_item(
             title       = '{TITLE}'
             description = '{DESCR}'
             icon        = '{ICON}'
             info        = '{INFO}' ).


    client->set_next( VALUE #( xml_main = page->get_root(  )->xml_get( ) ) ).

    RETURN.
    DATA(sections) = page->sections( ).

    sections->object_page_section( titleuppercase = abap_false id = 'goalsSectionSS1' title = '2014 Goals Plan'
        )->heading(
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
       )->heading(
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
     )->heading(
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

    client->set_next( VALUE #( xml_main = page->get_root(  )->xml_get( ) ) ).

  ENDMETHOD.
ENDCLASS.
