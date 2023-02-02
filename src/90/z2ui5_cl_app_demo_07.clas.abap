CLASS z2ui5_cl_app_demo_07 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    DATA html TYPE string.

ENDCLASS.

CLASS z2ui5_cl_app_demo_07 IMPLEMENTATION.

  METHOD z2ui5_if_app~on_event.

    CASE client->event( )->get_id( ).

      WHEN 'BUTTON_BACK'.
        client->controller( )->nav_to_app_called( ).

      WHEN 'BUTTON_WRITE'.

        SELECT FROM I_Language
         FIELDS *
         INTO TABLE @data(lt_tab)
         UP TO 5 ROWS.

*      html = cl_demo_output=>new(
*         )->begin_section( `Some Text`
*         )->write_text( |blah blah blah \n| &&
*                 |blah blah blah|
*         )->next_section( `Some Data`
*         )->begin_section( `Elementary Object`
*         )->write_data( lt_tab
*         )->next_section( `Internal Table`
*         )->write_data( lt_tab[ 1 ]
*         )->end_section(
*         )->next_section( `XML`
*         )->write_xml( html
*         )->get( ).
**        )->display( ).

    ENDCASE.

  ENDMETHOD.

  METHOD z2ui5_if_app~set_view.

    view->factory_selscreen_page( event_nav_back_id = 'BUTTON_BACK' title = 'ABAP2UI5 Demo - Write Output in HTML'
         )->begin_of_block( 'Selection Screen'
            )->begin_of_group( 'Write Output'
                )->button( text = 'write' on_press_id = 'BUTTON_WRITE'
           )->end_of_group(
         )->end_of_block(
         )->begin_of_block( 'HTML Output'
          )->html( html ).

  ENDMETHOD.

ENDCLASS.
