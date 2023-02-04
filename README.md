# ABAP2UI5

Development of UI5 Apps in pure ABAP [(Blog Post)](https://blogs.sap.com/2023/01/22/abap2ui5-project-development-of-ui5-selection-screens-in-pure-abap-no-app-deployment-or-javascript-needed/)[(Twitter)](https://twitter.com/OblomovDev).

Project features:
* easy to use – 100% abap source code based, just implement one interface for a standalone ui5 app
* lightweight - based on a single http handler (no odata, no segw, no bsp, no rap, no cds)
* easy installation - abapgit project, no additional app deployment or javascript needed

## Installation
Works with all availible abap stacks:
* BTP ABAP Environment (Abap Cloud)
* S/4 Public Cloud ABAP Environment (Abap Cloud)
* S/4 Private Cloud or On-Premise (Abap Cloud, Abap Standard)
* SAP NetWeaver AS ABAP 7.52 (Abap Standard) - downport to older releases possible [(#3)](https://github.com/oblomov-dev/ABAP2UI5/issues/6)

Install with [abapGit](https://abapgit.org) and create a new http endpoint to call ABAP2UI5.

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
 
For more information, read the [wiki](https://github.com/oblomov-dev/abap2ui5/wiki).

## Example
After installing the abap2ui5 project in your system, you only have to create a new abap class and implement the interface Z2UI5_IF_APP. It has two methods to define the view and the behaviour of the app. Nothing more is needed to create a new standalone UI5 app [(Sample Code)](https://github.com/oblomov-dev/abap2ui5/blob/main/src/90/z2ui5_cl_app_demo_02.clas.abap).<br>
View Definition:<br>
<img width="900" alt="image" src="https://user-images.githubusercontent.com/102328295/207578802-c15add24-5ee9-4eb9-8373-49ecff6cb2a3.png">
<br>
Controller Definition: <br>
<img width="700" alt="image" src="https://user-images.githubusercontent.com/102328295/207333675-3e9418dc-ca5c-4948-b967-1b34776d25e7.png">
<br>
To start the new ui5 app, you only have to call the delivered http endpoint and use the url parameter "app" with the name of your new abap class.
