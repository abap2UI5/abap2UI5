CLASS z2ui5_cl_app_demo_06 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    data check_initialized type abap_bool.
    data filename type string.
    data path type string.
    data input type string.

ENDCLASS.

CLASS z2ui5_cl_app_demo_06 IMPLEMENTATION.

  METHOD z2ui5_if_app~on_event.

    IF check_initialized = abap_false.
      check_initialized = abap_true.
        filename = 'example.txt'.
        path = '.../test/test/'.
        input = 'your file input here'.
    ENDIF.

    CASE client->event( )->get_id( ).

      WHEN 'BTN_BACK'.
        client->controller( )->nav_to_app_called( ).

      WHEN 'BUTTON_UPLOAD'.
      "save the data of the variable input to the database

      WHEN 'BUTTON_DOWNLOAD'.
      "read data from database and fill the variable input

    ENDCASE.

  ENDMETHOD.

  METHOD z2ui5_if_app~set_view.

    view->factory_selscreen_page( event_nav_back_id = 'BTN_BACK' title = 'ABAP2UI5 Demo - Text Area'
         )->begin_of_block( 'Plain Input'
            )->begin_of_group( 'Info'
                )->label( 'filename'
                )->input( value = filename
                )->label( 'path'
                )->input( value = path
                )->label( 'Transfer'
                )->button( text = 'Download' on_press_id = 'BUTTON_DOWNLOAD'
                )->button( text = 'Upload' on_press_id = 'BUTTON_UPLOAD'
         )->end_of_group(
            )->begin_of_group( 'File'
                )->text_area( value = input height = '700px'
           ).
  ENDMETHOD.

ENDCLASS.
