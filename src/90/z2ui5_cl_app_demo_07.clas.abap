CLASS z2ui5_cl_app_demo_07 DEFINITION PUBLIC.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

ENDCLASS.

CLASS z2ui5_cl_app_demo_07 IMPLEMENTATION.

  METHOD z2ui5_if_app~on_event.
  ENDMETHOD.

  METHOD z2ui5_if_app~set_view.

*    SELECT FROM I_Language
*     FIELDS *
*     INTO TABLE @DATA(tab)
*     UP TO 5 ROWS.
*
*  data(html) = cl_demo_output=>new(
*         )->begin_section( `Some Text`
*         )->write_text( |blah blah blah \n| &&
*                 |blah blah blah|
*         )->next_section( `Some Data`
*         )->begin_section( `Internal Table`
*         )->write_data( tab
*         )->next_section( `Structure`
*         )->write_data( tab[ 1 ]
*         )->end_section(
*         )->next_section( `HTML`
*         )->write_html( `<b>Text bold</b>`
*         )->get( ).   "instead of display
**        )->display( ).
*
*
*    view->factory_selscreen_page( title = 'ABAP2UI5 Demo - Write Output in HTML'
*         )->begin_of_block( 'HTML Output'
*         )->html( html ).

  ENDMETHOD.

ENDCLASS.
