CLASS z2ui5_cl_app_demo_05 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    DATA check_initialized TYPE abap_bool.
    DATA json TYPE string.
    DATA filename TYPE string.
    DATA path TYPE string.
    DATA input TYPE string.
    DATA key_type TYPE string.

ENDCLASS.

CLASS z2ui5_cl_app_demo_05 IMPLEMENTATION.

  METHOD z2ui5_if_app~on_event.

    IF check_initialized = abap_false.
      check_initialized = abap_true.
      filename = 'test'.
      path = '../../test/test'.
      key_type = client->cs-code_editor-type-xml.
    ENDIF.

    CASE client->event( )->get_id( ).

      WHEN 'BTN_BACK'.
        client->controller( )->nav_to_app_called( ).

      WHEN 'BUTTON_UPLOAD'.
        "save routine here

      WHEN 'BUTTON_DOWNLOAD'.
        input = SWITCH #( key_type
             WHEN client->cs-code_editor-type-json THEN
               `{` && |\n|  &&
              `      "Chinese" : "你好世界",` && |\n|  &&
              `      "Dutch" : "Hallo wereld",` && |\n|  &&
              `      "English" : "Hello world",` && |\n|  &&
              `      "French" : "Bonjour monde",` && |\n|  &&
              `      "German" : "Hallo Welt"` && |\n|  &&
              `  }`
            WHEN client->cs-code_editor-type-xml THEN
               `<note>` && |\n|  &&
               `  <to>Tove</to>` && |\n|  &&
               `  <from>Jani</from>` && |\n|  &&
               `  <heading>Reminder</heading>` && |\n|  &&
               `  <body>Don't forget me this weekend!</body>` && |\n|  &&
               `</note>`
            WHEN client->cs-code_editor-type-abap THEN
             `CLASS z2ui5_cl_app_demo_05 DEFINITION PUBLIC.` && |\n|  &&
             |\n|  &&
             `  PUBLIC SECTION.` && |\n|  &&
             |\n|  &&
             `    INTERFACES z2ui5_if_app.` && |\n|  &&
             |\n|  &&
             `    DATA check_initialized TYPE abap_bool.` && |\n|  &&
             `    DATA json TYPE string.` && |\n|  &&
             `    data filename type string.` && |\n|  &&
             `    data path type string.` && |\n|  &&
             `    data input type string.` && |\n|  &&
             `    data key_type type string.` && |\n|  &&
             |\n|  &&
             `ENDCLASS.`
             ).

    ENDCASE.

  ENDMETHOD.

  METHOD z2ui5_if_app~set_view.

    input = escape( format = cl_abap_format=>e_json_string val = input ).

    view->factory_selscreen_page( event_nav_back_id = 'BTN_BACK' title = 'ABAP2UI5 Demo - Upload/Download Editor'
         )->begin_of_block( 'Selection-Screen'
            )->begin_of_group( 'Info'
                 )->label( 'name'
                 )->input( filename
                 )->label( 'path'
                 )->input(  path
                 )->label( 'type'
                 )->segmented_button(
                        selected_key = key_type
                        t_button     = VALUE #(
                           ( key = view->cs-code_editor-type-json text = 'JSON' )
                           ( key = view->cs-code_editor-type-xml  text = 'XML' )
                           ( key = view->cs-code_editor-type-abap text = 'ABAP' )
                           ( key = view->cs-code_editor-type-yaml text = 'YAML' )
                           ( key = view->cs-code_editor-type-javascript text = 'JS' )    )
                 )->label('transfer'
                 )->button( text = 'Download' on_press_id = 'BUTTON_DOWNLOAD'
                 )->button( text = 'Upload' on_press_id = 'BUTTON_UPLOAD'
             )->end_of_group(
             )->end_of_block(
             )->begin_of_block( 'Code Editor'
                )->code_editor(
                     value    = input
                     type     = key_type
       ).

  ENDMETHOD.

ENDCLASS.
