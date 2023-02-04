CLASS z2ui5_cl_app_demo_03 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    DATA text_input TYPE string.
    DATA html TYPE string.
    DATA check_initialized TYPE abap_bool.

ENDCLASS.

CLASS z2ui5_cl_app_demo_03 IMPLEMENTATION.

  METHOD z2ui5_if_app~on_event.

    IF check_initialized = abap_false.
      check_initialized = abap_true.
      text_input = 'this is a line of text, you can write me'.

      html = `<h1 style="color:red; font-size:30px;">This is a heading</h1>` && |\n|  &&
     `<p style="color:green; font-size:22px;">This is a paragraph.</p>` && |\n|  &&
     `<div style="color:blue; font-size:14px;">This is some text content</div>` &&
         `<table>` && |\n|  &&
                      `  <tr>` && |\n|  &&
                      `    <th>Company</th>` && |\n|  &&
                      `    <th>Contact</th>` && |\n|  &&
                      `    <th>Country</th>` && |\n|  &&
                      `  </tr>` && |\n|  &&
                      `  <tr>` && |\n|  &&
                      `    <td>Alfreds Futterkiste</td>` && |\n|  &&
                      `    <td>Maria Anders</td>` && |\n|  &&
                      `    <td>Germany</td>` && |\n|  &&
                      `  </tr>` && |\n|  &&
                      `  <tr>` && |\n|  &&
                      `    <td>Centro comercial Moctezuma</td>` && |\n|  &&
                      `    <td>Francisco Chang</td>` && |\n|  &&
                      `    <td>Mexico</td>` && |\n|  &&
                      `  </tr>` && |\n|  &&
                      `  <tr>` && |\n|  &&
                      `    <td>Ernst Handel</td>` && |\n|  &&
                      `    <td>Roland Mendel</td>` && |\n|  &&
                      `    <td>Austria</td>` && |\n|  &&
                      `  </tr>` && |\n|  &&
                      `  <tr>` && |\n|  &&
                      `    <td>Island Trading</td>` && |\n|  &&
                      `    <td>Helen Bennett</td>` && |\n|  &&
                      `    <td>UK</td>` && |\n|  &&
                      `  </tr>` && |\n|  &&
                      `</table>`.
    ENDIF.


    CASE client->event( )->get_id( ).

      WHEN 'BTN_BACK'.
        client->controller( )->nav_to_app_called( ).

      WHEN 'BUTTON_POST'.
        html &&= `<div style="color:blue; font-size:14px;">` && text_input && `</div>`.

    ENDCASE.

  ENDMETHOD.

  METHOD z2ui5_if_app~set_view.

    view->factory_selscreen_page( event_nav_back_id = 'BTN_BACK' title = 'ABAP2UI5 - Write Output in HTML (CL_DEMO_OUTPUT)'
         )->begin_of_block( 'Selection Screen'
            )->begin_of_group( 'Write Output'
                )->label( 'Text'
                )->input( text_input
                )->button( text = 'write' on_press_id = 'BUTTON_POST'
           )->end_of_group(
           )->end_of_block(
         )->begin_of_block( 'HTML'
            )->html( html
       ).

  ENDMETHOD.

ENDCLASS.
