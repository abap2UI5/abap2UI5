# ABAP2UI5

Development of UI5 Apps in pure ABAP [(Blog Post)](https://blogs.sap.com/2023/01/22/abap2ui5-project-development-of-ui5-selection-screens-in-pure-abap-no-app-deployment-or-javascript-needed/)[(Twitter)](https://twitter.com/OblomovDev).

Project features:
* easy to use – 100% abap source code based, just implement one interface for a standalone ui5 app
* lightweight - based on a single http handler (no odata, no segw, no bsp, no rap, no cds)
* easy installation - abapgit project, no additional app deployment or javascript needed, works with all abap stacks

## Example
ABAP2UI5 Application [(Source Code)](https://github.com/oblomov-dev/ABAP2UI5/blob/main/src/90/z2ui5_cl_app_demo_02.clas.abap):
![example](https://user-images.githubusercontent.com/102328295/216781915-85a1c1c6-b92a-4c0f-8f03-44a200fede5b.gif)

## Installation
Works with all ABAP stacks:
* BTP ABAP Environment (ABAP Cloud)
* S/4 Public Cloud ABAP Environment (ABAP Cloud)
* S/4 Private Cloud or On-Premise (ABAP Cloud, ABAP Standard)
* SAP NetWeaver AS ABAP 7.52 (ABAP Standard) - downport to older releases possible [(#3)](https://github.com/oblomov-dev/ABAP2UI5/issues/6)

Install with [abapGit](https://abapgit.org), create a new http service and call ABAP2UI5. For more information, read the [wiki](https://github.com/oblomov-dev/abap2ui5/wiki).

#### ABAP Cloud:
```abap
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
```

#### ABAP Standard:
```abap
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
```
