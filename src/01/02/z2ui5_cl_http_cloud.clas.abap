CLASS z2ui5_cl_http_cloud DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_http_service_extension .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_http_cloud IMPLEMENTATION.


  METHOD if_http_service_extension~handle_request.

    z2ui5_cl_http_handler=>client = VALUE #(
        t_header = request->get_header_fields( )
        t_param  = request->get_form_fields( )
        o_body   = z2ui5_cl_hlp_tree_json=>factory( request->get_text( ) )
     ).

    DATA(lv_resp) = SWITCH #( request->get_method( )
        WHEN 'GET'  THEN z2ui5_cl_http_handler=>main_index_html( )
        WHEN 'POST' THEN z2ui5_cl_http_handler=>main_roundtrip( )
      ).

    response->set_status( 200 ).
    response->set_text( lv_resp ).

  ENDMETHOD.
ENDCLASS.
