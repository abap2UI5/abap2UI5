class z2ui5_cl_http_onprem definition
  public
  final
  create public .

  public section.
  interfaces if_http_extension.
  protected section.
  private section.
endclass.



class z2ui5_cl_http_onprem implementation.

method if_http_extension~handle_request.

 data lt_header type tihttpnvp.
    server->request->get_header_fields(
      changing
        fields = lt_header
    ).

    data lt_param type tihttpnvp.
    server->request->get_form_fields(
      changing
        fields             = lt_param
    ).

    z2ui5_cl_http_handler=>client = VALUE #(
        t_header = lt_header
        t_param  = lt_param
        o_body   = z2ui5_cl_hlp_tree_json=>factory( server->request->get_cdata( ) )
     ).

    data(lv_resp) = switch #( server->request->get_method( )
        when 'GET'  then z2ui5_cl_http_handler=>main_index_html( )
        when 'POST' then z2ui5_cl_http_handler=>main_roundtrip( )
      ).

    server->response->set_cdata( lv_resp ).
    server->response->set_status(
        code          = 200
        reason        = 'success'
    ).

  endmethod.

endclass.
