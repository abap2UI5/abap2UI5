CLASS z2ui5_cl_app_demo_33 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.
    DATA mv_type TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS Z2UI5_CL_APP_DEMO_33 IMPLEMENTATION.


  METHOD z2ui5_if_app~main.

    CASE client->get( )-event.
      WHEN 'BACK'.
        client->nav_app_leave( client->get_app( client->get( )-id_prev_app_stack ) ).

      WHEN 'BUTTON_MESSAGE_BOX'.
        client->popup_message_box( 'Action of illustrated message' ).

      WHEN OTHERS.
        mv_type = client->get( )-event.

    ENDCASE.

    DATA(page) = z2ui5_cl_xml_view=>factory( )->shell(
        )->page(
            title          = 'abap2UI5 - Illustrated Messages'
            navbuttonpress = client->_event( 'BACK' )
              shownavbutton = abap_true
            )->header_content(
                 )->link(
                    text = 'Demo'  target = '_blank'
                    href = `https://twitter.com/OblomovDev/status/1647175810917318657`
                )->link(
                    text = 'Source_Code'  target = '_blank'
                    href = z2ui5_cl_xml_view=>hlp_get_source_code_url( app = me get = client->get( ) )
            )->get_parent( ).
    page->link( text = 'Documentation'  target = '_blank' href = `https://openui5.hana.ondemand.com/api/sap.m.IllustratedMessageType#properties` ).
    page->button( text = 'NoActivities' press = client->_event( 'sapIllus-NoActivities' ) ).
    page->button( text = 'AddPeople' press = client->_event( 'sapIllus-AddPeople' ) ).
    page->button( text = 'Connection' press = client->_event( 'sapIllus-Connection' ) ).
    page->button( text = 'NoDimensionsSet' press = client->_event( 'sapIllus-NoDimensionsSet' ) ).
    page->button( text = 'NoEntries' press = client->_event( 'sapIllus-NoEntries' ) ).
    page->illustrated_message( illustrationtype = mv_type
    )->additional_content(  )->button(
                text  = 'information'
                press = client->_event( 'BUTTON_MESSAGE_BOX' ) ).

    client->set_next( VALUE #( xml_main = page->get_root(  )->xml_get( ) ) ).

  ENDMETHOD.
ENDCLASS.
