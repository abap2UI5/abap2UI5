<p align="center"><a href="http://www.abap2ui5.org" target="_blank"><img src="https://github.com/abap2UI5/abap2UI5/assets/102328295/52ac0bb6-a219-4e9d-9e4f-62698dab3063" width="200"></a></p>

<p align="center">
<a href="https://github.com/abap2ui5/abap2ui5/releases/"><img src="https://img.shields.io/github/v/release/abap2ui5/abap2ui5"></a>
<a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/License-MIT-yellow.svg"></a>
<a href="https://abaplint.app/stats/abap2UI5/abap2UI5"><img src="https://img.shields.io/badge/tested_with-abaplint-green"></a>
   <br>
<a href="https://github.com/abap2UI5/abap2UI5/issues/306"><img src="https://img.shields.io/badge/PRs-welcome-green"></a>
<a href="https://github.com/abap2UI5/abap2UI5/graphs/contributors"><img src="https://img.shields.io/github/contributors/abap2ui5/abap2ui5"></a>
<a href="https://twitter.com/abap2UI5"><img src="https://img.shields.io/twitter/follow/abap2UI5"></a>
</p>

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
* R/3 NetWeaver AS ABAP 7.02 to 7.42 - use the [downport repository](https://github.com/abap2UI5/abap2UI5-downport)

#### Information (Blog Series)
1. Introduction: Developing UI5 Apps in pure ABAP [(Blog SCN - 22.02.2023)](https://blogs.sap.com/2023/02/22/abap2ui5-development-of-ui5-apps-in-pure-abap-1-3/)<br>
2. Displaying Selection Screens & Tables [(Blog SCN - 23.02.2023)](https://blogs.sap.com/2023/02/22/abap2ui5-output-of-lists-and-tables-toolbar-and-editable-2-3/)<br>
3. Popups, F4-Help, Messages & Controller Logic [(Blog SCN - 30.03.2023)](https://blogs.sap.com/2023/03/30/abap2ui5-3-4-flow-logic-pop-ups-f4-help/)<br>
4. Advanced Functionality & Demonstrations [(Blog SCN - 02.04.2023)](https://blogs.sap.com/2023/04/02/abap2ui5-4-5-additional-features-demos/)<br>
5. Extensions with XML Views, HTML, JS & CC [(Blog SCN - 12.04.2023)](https://blogs.sap.com/2023/04/12/abap2ui5-5-6-extensions-with-xml-views-html-js-custom-controls/)<br>
6. Installation, Configuration & Debugging [(Blog SCN - 14.04.2023)](https://blogs.sap.com/2023/04/14/abap2ui5-6-7-installation-configuration-debugging/)<br>
7. Technical Background: Under the Hood of abap2UI5 [(Blog SCN - 26.04.2023)](https://blogs.sap.com/2023/04/26/abap2ui5-7-7-technical-background-under-the-hood-of-abap2ui5/)<br>

#### More
* Find abap2UI5 in the ABAP Open Source Projects [(dotabap.org)](https://dotabap.org/)
* Check out the open-source game engine Axage using abap2UI5 [(SCN - 31.05.2023)](https://groups.community.sap.com/t5/application-development/sap-developer-code-challenge-open-source-abap-week-4/td-p/263470)
* Part of the SAP Developer Code Challenge [(SCN - 17.05.2023)](https://groups.community.sap.com/t5/application-development/sap-developer-code-challenge-open-source-abap-week-2/m-p/260727#M1372)
* Check out abap2UI5 transpiled to JS running on open-abap under nodejs [(twitter - 19.04.2023)](https://twitter.com/LarsHvam/status/1648575595897405446)
* Featured in the Boring Enterprise Nerdletter [(newsletter - 08.03.2023)](https://boringenterprisenerds.substack.com/p/34-abap2ui5-sap-cva-burnout-c2c-shortwave)
* Featured in the SAP Developer News [(youtube - 26.01.2023)](https://www.youtube.com/watch?v=6BDK55xYttM)
* And finally: Don't forget to explore the [Demo Repository 🧭](https://github.com/abap2UI5/abap2UI5-demos) 

#### Installation
Install with [abapGit](https://abapgit.org) ![abapGit](https://docs.abapgit.org/img/favicon.png), create a new HTTP service and replace the handler method with the following code:
##### Standard ABAP  🏠
```abap
METHOD if_http_extension~handle_request.

   DATA lt_header TYPE tihttpnvp.
   server->request->get_header_fields( CHANGING fields = lt_header ).

   DATA(lv_resp) = SWITCH #( server->request->get_method( )
      WHEN 'GET'  THEN z2ui5_cl_http_handler=>http_get( )
      WHEN 'POST' THEN z2ui5_cl_http_handler=>http_post(
         body      = server->request->get_cdata( ) 
         path_info = lt_header[ name = `~path_info` ]-value ) ).

   server->response->set_header_field( name  = 'cache-control' value = 'no-cache' ).
   server->response->set_cdata( lv_resp ).
   server->response->set_status( code = 200 reason = 'success' ).

ENDMETHOD.
```
##### ABAP for Cloud  :cloud:
```abap
METHOD if_http_service_extension~handle_request.

   DATA(lt_header) = request->get_header_fields( ).

   DATA(lv_resp) = SWITCH #( request->get_method( )
      WHEN 'GET'  THEN z2ui5_cl_http_handler=>http_get( check_logging = abap_true )
      WHEN 'POST' THEN z2ui5_cl_http_handler=>http_post(
         body      = request->get_text( )
         path_info = lt_header[ name = `~path_info` ]-value ) ).

   response->set_header_field( i_name = 'cache-control' i_value = 'no-cache' ).
   response->set_status( 200 )->set_text( lv_resp ).

ENDMETHOD.
```
#### FAQ
* check out this [documentation](https://blogs.sap.com/2023/04/14/abap2ui5-6-7-installation-configuration-debugging/) for detailed installation guidelines<br>
* read these [instructions](https://blogs.sap.com/2023/02/22/abap2ui5-development-of-ui5-apps-in-pure-abap-1-3/) when you develop your first app<br>
* want to configure the theme, bootstrapping, language and title? see [configuration & debugging](https://blogs.sap.com/2023/04/14/abap2ui5-6-7-installation-configuration-debugging/)
* as always - your comments, questions, wishes and bugs are welcome, please create an [issue](https://github.com/abap2UI5/abap2UI5/issues)
