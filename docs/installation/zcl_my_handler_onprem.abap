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

   DATA lt_header TYPE tihttpnvp.
   server->request->get_header_fields( CHANGING fields = lt_header ).

   DATA(lv_resp) = SWITCH #( server->request->get_method( )
      WHEN 'GET'  THEN z2ui5_cl_http_handler=>http_get( )
      WHEN 'POST' THEN z2ui5_cl_http_handler=>http_post(
         body      = server->request->get_cdata( ) 
         path_info = lt_header[ name = `~path_info` ]-value ) ).

   server->response->set_header_field( name = `cache-control` value = `no-cache` ).
   server->response->set_cdata( lv_resp ).
   server->response->set_status( code = 200 reason = `success` ).

ENDMETHOD.

ENDCLASS.
