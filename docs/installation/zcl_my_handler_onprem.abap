CLASS zcl_my_handler_onprem DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_http_extension.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS zcl_my_handler_onprem IMPLEMENTATION.

METHOD if_http_extension~handle_request.

   DATA(lv_resp) = SWITCH #( request->get_method( )
      WHEN 'GET'  THEN z2ui5_cl_http_handler=>http_get( )
      WHEN 'POST' THEN z2ui5_cl_http_handler=>http_post( request->get_text( ) ) ).

   response->set_status( 200 )->set_text( lv_resp
      )->set_header_field( i_name = `cache-control` i_value = `no-cache` ).

ENDMETHOD.

ENDCLASS.
