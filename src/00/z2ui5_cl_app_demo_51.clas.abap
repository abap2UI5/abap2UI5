CLASS z2ui5_cl_app_demo_51 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    DATA product  TYPE string.
    DATA quantity TYPE string.
    DATA check_initialized TYPE abap_bool.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_app_demo_51 IMPLEMENTATION.


  METHOD z2ui5_if_app~main.

    IF check_initialized = abap_false.
      check_initialized = abap_true.
      product  = 'tomato'.
      quantity = '500'.
    ENDIF.

    CASE client->get( )-event.
      WHEN 'BUTTON_POST'.
        client->popup_message_toast( |{ product } { quantity } - send to the server| ).
      WHEN 'BACK'.
        client->nav_app_leave( client->get_app( client->get( )-id_prev_app_stack  ) ).
    ENDCASE.

    DATA(page) = z2ui5_cl_xml_view=>factory( )->shell(
          )->page(
               id = 'id_page'
               title = 'abapScheme - Workbench'
               shownavbutton = abap_true
               navbuttonpress = client->_event( 'BACK' ) ).

  page->header_content(
  )->toolbar(
    )->button(
        text  = 'Evaluate'
        press = client->_event( 'BUTTON_EVAL' )
        icon = 'sap-icon://begin'
        type    = 'Emphasized'
    ")->toolbar_spacer(
    )->button( text = 'S-Expression' press = client->_event( 'BUTTON_SEXP' )
               icon = 'sap-icon://tree'
    )->button( text = 'Trace' press = client->_event( 'BUTTON_TRACE' )
                icon = 'sap-icon://step'
    )->button(
         text = 'Previous'
         press = client->_event( 'BUTTON_PREV' )
         icon  = 'sap-icon://navigation-left-arrow'
    )->button(
         text = 'Next'
         press = client->_event( 'BUTTON_NEXT' )
         icon  = 'sap-icon://navigation-right-arrow'
    )->button(
         text = 'Refresh'
         type  = 'Reject'
         press = client->_event( 'BUTTON_RESET' )
         icon  = 'sap-icon://delete'
    )->link( text = 'Help on..' href = 'https://github.com/nomssi/abap_scheme/wiki'
             " icon  = 'sap-icon://learning-assistant' // 'sap-icon://sys-help'
   )->get_parent( ).


*             )->toolbar(
*        )->button(
*            text  = 'Evaluate'
*            press = client->_event( 'BUTTON_EVAL' )
*            icon = 'sap-icon://begin'
*            type    = 'Emphasized'
*        )->toolbar_spacer(
*        )->button( text = 'S-Expression' press = client->_event( 'BUTTON_SEXP' )
*                   icon = 'sap-icon://tree'
*        )->button( text = 'Trace' press = client->_event( 'BUTTON_TRACE' )
*                    icon = 'sap-icon://step'
*        )->button(
*             text = 'Previous'
*             press = client->_event( 'BUTTON_PREV' )
*             icon  = 'sap-icon://navigation-left-arrow'
*        )->button(
*             text = 'Next'
*             press = client->_event( 'BUTTON_NEXT' )
*             icon  = 'sap-icon://navigation-right-arrow'
*        )->button(
*             text = 'Refresh'
*             type  = 'Reject'
*             press = client->_event( 'BUTTON_RESET' )
*             icon  = 'sap-icon://delete'
*        )->link( text = 'Help on..' href = 'https://github.com/nomssi/abap_scheme/wiki'
*                 " icon  = 'sap-icon://learning-assistant' // 'sap-icon://sys-help'
*                 ).

    client->set_next( VALUE #( xml_main = page->get_root( )->xml_get( ) ) ).

  ENDMETHOD.
ENDCLASS.
