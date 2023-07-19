CLASS zcl_my_handler_cloud DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_http_service_extension.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_my_handler_cloud IMPLEMENTATION.

  METHOD if_http_service_extension~handle_request.

   DATA(lv_resp) = SWITCH #( server->request->get_method( )
      WHEN 'GET'  THEN z2ui5_cl_http_handler=>http_get( )
      WHEN 'POST' THEN z2ui5_cl_http_handler=>http_post( server->request->get_cdata( ) ) ).

   server->response->set_header_field( name = `cache-control` value = `no-cache` ).
   server->response->set_cdata( lv_resp ).
   server->response->set_status( code = 200 reason = `success` ).

  ENDMETHOD.

ENDCLASS.
