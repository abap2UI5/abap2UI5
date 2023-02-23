# ABAP2UI5

Development of UI5 Apps in pure ABAP. You can also follow this project on [Twitter](https://twitter.com/OblomovDev) and keep up to date!

### Project features
* easy to use – implement just one interface for a full working UI5 application
* pure ABAP - 100% ABAP source code based, no JavaScript, EML, annotations or customizing needed
* cloud ready - works with all available ABAP stacks and language versions (ABAP for Cloud, Standard ABAP)
* small system footprint - based on a single http handler (no odata, no segw, no bopf, no bsp, no rap, no cds)
* easy installation - abapGit project, no additional app deployment needed

### Information
##### SCN Blog Series - Introduction of ABAP2UI5
* (1/3) Development of UI5 Apps in pure ABAP [(Blog SCN - 20.02.2023)](https://blogs.sap.com/2023/02/22/abap2ui5-development-of-ui5-apps-in-pure-abap-1-3/)<br>
* (2/3) Output of Lists and Tables, Toolbar and Editable [(Blog SCN - 20.02.2023)](https://blogs.sap.com/2023/02/22/abap2ui5-output-of-lists-and-tables-toolbar-and-editable-2-3/)<br>
* (3/3) Demo Applications developed with ABAP2UI5 (...)<br>

##### Others
* Recommended in the SAP Developer News [(Youtube - 26.01.2023)](https://www.youtube.com/watch?v=6BDK55xYttM)
* Part of ABAP Open Source Projects [(dotabap.org)](https://dotabap.org/)
* Development of UI5 Selection-Screens in pure ABAP (former version) [(Blog SCN - 22.01.2023)](https://blogs.sap.com/2023/01/22/abap2ui5-project-development-of-ui5-selection-screens-in-pure-abap-no-app-deployment-or-javascript-needed/)

### Demo Application [(Source Code)](https://github.com/oblomov-dev/ABAP2UI5/blob/main/src/00/z2ui5_cl_app_demo_01.clas.abap)
![tweet1](https://user-images.githubusercontent.com/102328295/220315102-2e1e6545-ac32-4ea3-9d10-7286998304e7.gif)

## Installation
Works with all available ABAP stacks and language versions:
* BTP ABAP Environment (ABAP for Cloud)
* S/4 Public Cloud ABAP Environment (ABAP for Cloud)
* S/4 Private Cloud or On-Premise (ABAP for Cloud, Standard ABAP)
* R/3 NetWeaver AS ABAP 7.50 (Standard ABAP) - downport to older releases possible

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
METHOD if_http_extension~handle_request.

   DATA lt_header TYPE tihttpnvp.
   server->request->get_header_fields( CHANGING fields = lt_header ).

   DATA lt_param TYPE tihttpnvp.
   server->request->get_form_fields( CHANGING fields = lt_param ).

   z2ui5_cl_http_handler=>client = VALUE #(
      t_header = lt_header
      t_param  = lt_param
      body     = server->request->get_cdata( ) ).

   DATA(lv_resp) = SWITCH #( server->request->get_method( )
      WHEN 'GET'  THEN z2ui5_cl_http_handler=>main_index_html( )
      WHEN 'POST' THEN z2ui5_cl_http_handler=>main_roundtrip( ) ).

   server->response->set_cdata( lv_resp ).
   server->response->set_status( code = 200 reason = 'success' ).

ENDMETHOD.
```
