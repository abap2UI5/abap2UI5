# ABAP2UI5

Development of UI5 apps in pure ABAP. Follow this project on [Twitter](https://twitter.com/OblomovDev) and keep up to date!

### Project features
* easy to use – 100% source code based, implement just one interface for a full working UI5 application
* pure ABAP - no additional Javascript or annotations needed
* cloud ready - works with all available ABAP stacks and language versions (ABAP Standard, ABAP Cloud)
* lightweight - based on a single http handler (no odata, no segw, no bsp, no rap, no cds)
* easy installation - AbapGit project, no additional app deployment needed

### Information
##### Blog series:
* ABAP2UI5 - Development of UI5 Apps in pure ABAP (1/3) [(Blog SCN - 20.02.2023)](https://blogs.sap.com/2023/01/22/abap2ui5-project-development-of-ui5-selection-screens-in-pure-abap-no-app-deployment-or-javascript-needed/) <br>
* ABAP2UI5 - Output of Lists and Tables, Toolbar and Editable (2/3) [(Blog SCN - 21.02.2023)](https://blogs.sap.com/2023/01/22/abap2ui5-project-development-of-ui5-selection-screens-in-pure-abap-no-app-deployment-or-javascript-needed/)<br>
* ABAP2UI5 - Full working UI5 demo applications (3/3) [(Blog SCN - 28.02.2023)](https://blogs.sap.com/2023/01/22/abap2ui5-project-development-of-ui5-selection-screens-in-pure-abap-no-app-deployment-or-javascript-needed/)<br>
##### Former version and functionality:<br>
* ABAP2UI5 - Development of UI5 Selection-Screens in pure ABAP [(Blog SCN - 22.01.2023)](https://blogs.sap.com/2023/01/22/abap2ui5-project-development-of-ui5-selection-screens-in-pure-abap-no-app-deployment-or-javascript-needed/)
<br>

### Demo Application [(Source Code)](https://github.com/oblomov-dev/ABAP2UI5/blob/main/src/00/z2ui5_cl_app_demo_02.clas.abap):
![tweet1](https://user-images.githubusercontent.com/102328295/220315102-2e1e6545-ac32-4ea3-9d10-7286998304e7.gif)


## Installation
Works with all ABAP stacks:
* BTP ABAP Environment (ABAP Cloud)
* S/4 Public Cloud ABAP Environment (ABAP Cloud)
* S/4 Private Cloud or On-Premise (ABAP Cloud, ABAP Standard)
* SAP NetWeaver AS ABAP 7.52 (ABAP Standard) - downport to older releases possible [(#3)](https://github.com/oblomov-dev/ABAP2UI5/issues/6)

Install with [abapGit](https://abapgit.org), create a new http service and call ABAP2UI5 [(more information)](https://github.com/oblomov-dev/abap2ui5/wiki).

#### ABAP Cloud:
```abap
  METHOD if_http_service_extension~handle_request.

    z2ui5_cl_http_handler=>client = VALUE #(
        t_header = request->get_header_fields( )
        t_param  = request->get_form_fields( )
        body     = request->get_text( ) ).

    DATA(lv_resp) = SWITCH #( request->get_method( )
        WHEN 'GET'  THEN z2ui5_cl_http_handler=>main_index_html( )
        WHEN 'POST' THEN z2ui5_cl_http_handler=>main_roundtrip( ) ).

    response->set_status( 200 )->set_text( lv_resp ).

  ENDMETHOD.
```

#### ABAP Standard:
```abap
method if_http_extension~handle_request.

    DATA lt_header TYPE tihttpnvp.
    server->request->get_header_fields( CHANGING fields = lt_header ).

    DATA lt_param TYPE tihttpnvp.
    server->request->get_form_fields( CHANGING fields = lt_param ).

    z2ui5_cl_http_handler=>client = VALUE #(
        t_header = lt_header
        t_param  = lt_param
        body     = server->request->get_cdata( ) ).

    data(lv_resp) = SWITCH #( server->request->get_method( )
        WHEN 'GET'  THEN z2ui5_cl_http_handler=>main_index_html( )
        WHEN 'POST' THEN z2ui5_cl_http_handler=>main_roundtrip( ) ).

    server->response->set_cdata( lv_resp ).
    server->response->set_status( code = 200 reason = 'success' ).

  endmethod.
```
