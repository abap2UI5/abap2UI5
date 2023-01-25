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

    data(lv_method) = server->request->get_method( ).
    data(lv_body)   = server->request->get_cdata( ).

    data(lv_resp) = switch #( lv_method
        when 'GET'  then z2ui5_cl_http_handler=>main_index_html( )
        when 'POST' then z2ui5_cl_http_handler=>main_roundtrip( value #(
                t_header = corresponding #( lt_header )
                t_param  = corresponding #( lt_param )
                o_body   = z2ui5_cl_hlp_tree_json=>factory( lv_body )
         ) )
      ).

    server->response->set_cdata( lv_resp ).
    server->response->set_status(
        code          = 200
        reason        = 'success'
    ).
  endmethod.

endclass.
