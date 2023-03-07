# abap2UI5

Development of UI5 Apps in pure ABAP. Follow this project on [twitter](https://twitter.com/OblomovDev) to keep up to date!

### Project Features
* easy to use – implement just one interface for a standalone UI5 application
* pure ABAP – development in 100% ABAP source code (no JavaScript, EML, DDL or Customizing)
* low system footprint - based on a plain http handler (no OData, SEGW, BOPF, BSP, RAP or FE)
* cloud and on-premise ready – works with both language versions (ABAP for Cloud, Standard ABAP)
* high system compatibility - runs on all available ABAP stacks (NW 7.02 to ABAP 2302)
* easy installation - abapGit project, no additional app deployment needed

### Information
##### SCN Blog Series - Introduction to abap2UI5
* (1/3) Development of UI5 Apps in pure ABAP [(Blog SCN - 22.02.2023)](https://blogs.sap.com/2023/02/22/abap2ui5-development-of-ui5-apps-in-pure-abap-1-3/)<br>
* (2/3) Output of Lists & Tables--add toolbars and make editable [(Blog SCN - 22.02.2023)](https://blogs.sap.com/2023/02/22/abap2ui5-output-of-lists-and-tables-toolbar-and-editable-2-3/)<br>
* (3/3) Demo Applications developed with ABAP2UI5 (...)<br>

##### More
* abap2UI5 featured in the SAP Developer News [(youtube - 26.01.2023)](https://www.youtube.com/watch?v=6BDK55xYttM)
* find abap2UI5 in the ABAP Open Source Projects [(dotabap.org)](https://dotabap.org/)
* development of UI5 Selection-Screens in pure ABAP (former version) [(Blog SCN - 22.01.2023)](https://blogs.sap.com/2023/01/22/abap2ui5-project-development-of-ui5-selection-screens-in-pure-abap-no-app-deployment-or-javascript-needed/)
* twitter -- all upcoming news and updates [(twitter.com/OblomovDev)](https://twitter.com/OblomovDev)

### Demo Application [(Source Code)](https://github.com/oblomov-dev/ABAP2UI5/blob/main/src/00/z2ui5_cl_app_demo_01.clas.abap)
![tweet1](https://user-images.githubusercontent.com/102328295/220315102-2e1e6545-ac32-4ea3-9d10-7286998304e7.gif)

## Installation
Works with all available ABAP stacks and language versions:
* BTP ABAP Environment (ABAP for Cloud)
* S/4 Public Cloud ABAP Environment (ABAP for Cloud)
* S/4 Private Cloud or On-Premise (ABAP for Cloud, Standard ABAP)
* R/3 NetWeaver AS ABAP 7.50 or higher (Standard ABAP)
* R/3 Netweaver AS ABAP 7.02 to 7.40 (Standard ABAP) - use the low syntax [branch](https://github.com/oblomov-dev/ABAP2UI5/tree/main_v702)

Install with [abapGit](https://abapgit.org), create a new HTTP service and call abap2UI5 [(more information)](https://github.com/oblomov-dev/abap2ui5/wiki).

#### ABAP for Cloud:
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

#### Standard ABAP:
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
## FAQ
* read these [instructions](https://github.com/oblomov-dev/ABAP2UI5/wiki/First-App) when you develop your first app<br>
* running into problems with your app? see [debugging & troubleshooting](https://github.com/oblomov-dev/ABAP2UI5/wiki/Debugging-&-Troubleshooting)
* as always -- your comments, questions, wishes and bugs are welcome, please create an [issue](https://github.com/oblomov-dev/ABAP2UI5/issues)
