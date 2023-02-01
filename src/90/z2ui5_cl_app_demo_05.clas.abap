CLASS z2ui5_cl_app_demo_05 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    DATA check_initialized TYPE abap_bool.
    DATA json TYPE string.
    data filename type string.
    data path type string.
    data input type string.
    data key_type type string.

ENDCLASS.

CLASS z2ui5_cl_app_demo_05 IMPLEMENTATION.

  METHOD z2ui5_if_app~on_event.

    IF check_initialized = abap_false.
      check_initialized = abap_true.
      json = `\{` && |\n|  &&
             `      "Chinese" : "你好世界",` && |\n|  &&
             `      "Dutch" : "Hallo wereld",` && |\n|  &&
             `      "English" : "Hello world",` && |\n|  &&
             `      "French" : "Bonjour monde",` && |\n|  &&
             `      "German" : "Hallo Welt",` && |\n|  &&
             `      "Greek" : "γειά σου κόσμος",` && |\n|  &&
             `      "Italian" : "Ciao mondo",` && |\n|  &&
             `      "Japanese" : "こんにちは世界",` && |\n|  &&
             `      "Korean" : "여보세요 세계",` && |\n|  &&
             `      "Portuguese" : "Olá mundo",` && |\n|  &&
             `      "Russian" : "Здравствуй мир",` && |\n|  &&
             `      "Spanish" : "Hola mundo"` && |\n|  &&
             `  }`.
    ENDIF.

    CASE client->event( )->get_id( ).

      WHEN 'BTN_BACK'.
        client->controller( )->nav_to_app_called( ).

      WHEN 'BUTTON_POST'.
        "roundtrip

    ENDCASE.

  ENDMETHOD.

  METHOD z2ui5_if_app~set_view.

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
                     value    = json
                     type     = view->cs-code_editor-type-json
       ).

  ENDMETHOD.

ENDCLASS.
