CLASS z2ui5_cl_app_demo_33 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.
    data mv_type type string.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS Z2UI5_CL_APP_DEMO_33 IMPLEMENTATION.


  METHOD z2ui5_if_app~controller.

    CASE client->get( )-event.
      WHEN 'BACK'.
        client->nav_app_leave( client->get_app( client->get( )-id_prev_app_stack ) ).

      when others.
      mv_type = client->get( )-event.

    ENDCASE.

    DATA(page) = Z2UI5_CL_XML_VIEW=>factory( )->shell(
        )->page(
            title          = 'abap2UI5 - Illustrated Messages'
            navbuttonpress = client->_event( 'BACK' )
              shownavbutton = abap_true
            )->header_content(
                )->link(
                    text = 'Source_Code'  target = '_blank'
                    href = Z2UI5_CL_XML_VIEW=>hlp_get_source_code_url( app = me get = client->get( ) )
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
