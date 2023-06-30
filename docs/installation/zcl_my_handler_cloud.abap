CLASS y2ui5_cl_http_handler DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_http_service_extension.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS y2ui5_cl_http_handler IMPLEMENTATION.

  METHOD if_http_service_extension~handle_request.

    DATA(lt_tab) = request->get_header_fields( ).

    DATA(lv_resp) = SWITCH #( request->get_method( )
        WHEN 'GET'  THEN z2ui5_cl_http_handler=>http_get( )
        WHEN 'POST' THEN z2ui5_cl_http_handler=>http_post(
            body      = request->get_text( )
            path_info = lt_tab[ name = `~path_info` ]-value ) ).

    response->set_header_field( i_name = 'cache-control' i_value = 'no-cache' ).
    response->set_status( 200 )->set_text( lv_resp ).

  ENDMETHOD.
  
ENDCLASS.