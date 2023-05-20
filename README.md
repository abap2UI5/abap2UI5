# abap2UI5
Development of UI5 Apps in pure ABAP. Follow this project on [Twitter](https://twitter.com/OblomovDev)
 to keep up to date! 
#### Features
* easy to use – implement just one interface for a standalone UI5 application
* pure ABAP – development using 100% ABAP (no JavaScript, DDL, EML or Customizing)
* low system footprint – based on a plain http handler (no BSP, OData, CDS, BOPF or RAP)
* cloud and on-premise ready – works with both language versions (ABAP for Cloud, Standard ABAP)
* high system compatibility – runs on all ABAP releases (from NW 7.02 to ABAP 2305)
* easy installation – abapGit project, no additional app deployment needed

#### Compatibility
* BTP ABAP Environment (ABAP for Cloud)
* S/4 Public Cloud ABAP Environment (ABAP for Cloud)
* S/4 Private Cloud or On-Premise (ABAP for Cloud, Standard ABAP)
* R/3 NetWeaver AS ABAP 7.50 or higher (Standard ABAP)
* R/3 NetWeaver AS ABAP 7.02 to 7.42 - use the [low syntax branch](https://github.com/oblomov-dev/ABAP2UI5/tree/main_v702)

#### Information (Blog Series)
1. Introduction: Developing UI5 Apps in pure ABAP [(Blog SCN - 22.02.2023)](https://blogs.sap.com/2023/02/22/abap2ui5-development-of-ui5-apps-in-pure-abap-1-3/)<br>
2. Displaying Selection Screens & Tables [(Blog SCN - 23.02.2023)](https://blogs.sap.com/2023/02/22/abap2ui5-output-of-lists-and-tables-toolbar-and-editable-2-3/)<br>
3. Popups, F4-Help, Messages & Controller Logic [(Blog SCN - 30.03.2023)](https://blogs.sap.com/2023/03/30/abap2ui5-3-4-flow-logic-pop-ups-f4-help/)<br>
4. Advanced Functionality & Demonstrations [(Blog SCN - 02.04.2023)](https://blogs.sap.com/2023/04/02/abap2ui5-4-5-additional-features-demos/)<br>
5. Extensions with XML Views, HTML, JS & Custom Controls [(Blog SCN - 12.04.2023)](https://blogs.sap.com/2023/04/12/abap2ui5-5-6-extensions-with-xml-views-html-js-custom-controls/)<br>
6. Installation, Configuration & Debugging [(Blog SCN - 14.04.2023)](https://blogs.sap.com/2023/04/14/abap2ui5-6-7-installation-configuration-debugging/)<br>
7. Technical Background: Under the Hood of abap2UI5 [(Blog SCN - 26.04.2023)](https://blogs.sap.com/2023/04/26/abap2ui5-7-7-technical-background-under-the-hood-of-abap2ui5/)<br>

#### More
* Find abap2UI5 in the ABAP Open Source Projects [(dotabap.org)](https://dotabap.org/)
* Static Analysis & Continuous Integration with abaplint [(abaplint.app/abap2UI5)](https://abaplint.app/stats/oblomov-dev/abap2UI5)
* Try abap2UI5 compiled to JS running on openabap under nodejs [(github/abap2ui5-web)](https://github.com/larshp/abap2ui5-web)
* Part of the SAP Developer Code Challenge [(SCN - 17.05.2023)](https://groups.community.sap.com/t5/application-development/sap-developer-code-challenge-open-source-abap-week-2/m-p/260727#M1372)
* Featured in the Boring Enterprise Nerdletter [(newsletter - 08.03.2023)](https://boringenterprisenerds.substack.com/p/34-abap2ui5-sap-cva-burnout-c2c-shortwave)
* Featured in the SAP Developer News [(youtube - 26.01.2023)](https://www.youtube.com/watch?v=6BDK55xYttM)
* Development of UI5 Selection Screens in pure ABAP (former version) [(Blog SCN - 22.01.2023)](https://blogs.sap.com/2023/01/22/abap2ui5-project-development-of-ui5-selection-screens-in-pure-abap-no-app-deployment-or-javascript-needed/)

#### Demo
<img src="https://user-images.githubusercontent.com/102328295/235298442-7e444942-3063-43ff-ad4d-6434ddcc169e.gif" style="width: 55vw; min-width: 330px;"/>

#### Installation
Install with [abapGit](https://abapgit.org), create a new HTTP service and call abap2UI5. For more information, check out this [documentation.](https://blogs.sap.com/2023/04/14/abap2ui5-6-7-installation-configuration-debugging/)

##### ABAP for Cloud:
```abap
METHOD if_http_service_extension~handle_request.

   z2ui5_cl_http_handler=>client = VALUE #(
      t_header = request->get_header_fields( )
      t_param  = request->get_form_fields( )
      body     = request->get_text( ) ).

   DATA(lv_resp) = SWITCH #( request->get_method( )
      WHEN 'GET'  THEN z2ui5_cl_http_handler=>http_get( )
      WHEN 'POST' THEN z2ui5_cl_http_handler=>http_post( ) ).

   response->set_status( 200 )->set_text( lv_resp ).

ENDMETHOD.
```

##### Standard ABAP:
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
      WHEN 'GET'  THEN z2ui5_cl_http_handler=>http_get( )
      WHEN 'POST' THEN z2ui5_cl_http_handler=>http_post( ) ).

   server->response->set_cdata( lv_resp ).
   server->response->set_status( code = 200 reason = 'success' ).

ENDMETHOD.
```
#### FAQ
* read these [instructions](https://blogs.sap.com/2023/02/22/abap2ui5-development-of-ui5-apps-in-pure-abap-1-3/) when you develop your first app<br>
* running into problems with your app? or want to configure the theme, bootstrapping, language and title? see [configuration & debugging](https://blogs.sap.com/2023/04/14/abap2ui5-6-7-installation-configuration-debugging/)
* as always - your comments, questions, wishes and bugs are welcome, please create an [issue](https://github.com/oblomov-dev/ABAP2UI5/issues)
