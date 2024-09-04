<p align="center"><a href="http://www.abap2ui5.org" target="_blank"><img src="https://github.com/abap2UI5/abap2UI5/assets/102328295/52ac0bb6-a219-4e9d-9e4f-62698dab3063" width="200"></a></p>

<p align="center">
<a href="https://github.com/abap2ui5/abap2ui5/releases/"><img src="https://img.shields.io/github/v/release/abap2ui5/abap2ui5"></a>
<a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/License-MIT-yellow.svg"></a>
   <a href="https://github.com/abap2UI5/abap2UI5/issues/306"><img src="https://img.shields.io/badge/PRs-welcome-orange"></a>
    <br>
<a href="https://abaplint.app/stats/abap2UI5/abap2UI5"><img src="https://img.shields.io/badge/static_code_check-passing-green"></a>
<a href="https://github.com/abap2UI5/abap2UI5/actions/workflows/build_downport.yaml"><img src="https://img.shields.io/badge/syntax_downport_7.02-passing-green"></a>
<a href="https://github.com/abap2UI5/abap2UI5/actions/workflows/test.yml"><img src="https://img.shields.io/badge/unit_tests-passing-green"></a>
   <br>
<a href="https://github.com/abap2UI5/abap2UI5/graphs/contributors"><img src="https://img.shields.io/github/contributors/abap2ui5/abap2ui5"></a>
<a href="https://communityinviter.com/apps/abapgit/abap"><img src="https://img.shields.io/badge/Join-Slack-blue"></a>
   <a href="https://abap2ui5.github.io/web-abap2ui5-samples/"><img src="https://img.shields.io/badge/Live-Demo-pink"></a>
<a href="https://twitter.com/abap2UI5"><img src="https://img.shields.io/twitter/follow/abap2UI5"></a>
<a href="https://www.linkedin.com/company/abap2ui5"><img src="https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white"></a>
</p>

*...offers a pure ABAP approach for developing UI5 apps, entirely without JavaScript, OData and RAP — similar to the past, when only a few lines of ABAP sufficed to display input forms and tables using Selection Screens & ALVs. Designed with a minimal system footprint, it works in both on-premise and cloud environments.*

#### Key Features
* **100% ABAP:** Developing purely in ABAP (no JavaScript, DDL, EML or Customizing)
* **User-Friendly:** Implement just a single interface for a standalone UI5 application
* **Minimal System Footprint:** Based on a plain HTTP handler (no BSP, OData, CDS or RAP)
* **Cloud and On-Premise Ready:** Works with both language versions (ABAP for Cloud, Standard ABAP)
* **Broad System Compatibility:** Runs on all ABAP releases (from NW 7.02 to ABAP Cloud)
* **Easy Installation:** abapGit project, no additional app deployment required

#### Compatibility
* BTP ABAP Environment (ABAP for Cloud)
* S/4 Public Cloud (ABAP for Cloud)
* S/4 Private Cloud or On-Premise (ABAP for Cloud, Standard ABAP)
* R/3 NetWeaver AS ABAP 7.50 or higher (Standard ABAP)
* R/3 NetWeaver AS ABAP 7.02 to 7.42 - use the [downported repositories](https://github.com/abap2UI5-downports)

#### References
* Find abap2UI5 on ABAP Open Source Projects [(dotabap.org)](https://dotabap.org/)
* Featured on SAP Developer News [(youtube - 26.01.2023)](https://www.youtube.com/watch?v=6BDK55xYttM)
* Highlighted in the Boring Enterprise Nerdletter [(newsletter - 08.03.2023)](https://boringenterprisenerds.substack.com/p/34-abap2ui5-sap-cva-burnout-c2c-shortwave)
* Part of the SAP Developer Code Challenge [(SCN - 17.05.2023)](https://groups.community.sap.com/t5/application-development/sap-developer-code-challenge-open-source-abap-week-2/m-p/260727#M1372)
* Showcased at SAP TechEd 2023 [(youtube - 02.11.2023)](https://www.youtube.com/watch?v=kLbF0ooStZs&t=3052s)
* Join the Advent of Code 2023 with abap2UI5 [(SCN - 27.11.2023)](https://blogs.sap.com/2023/11/27/preparing-for-advent-of-code-2023/)
* Featured on SAP Developer News [(youtube - 15.12.2023)](https://www.youtube.com/watch?v=CfH9L03WUCg&t=350s)
* Highlighted in the Boring Enterprise Nerdcast [(youtube - 29.01.2024)](https://youtu.be/svDZKFBvqR8?t=1050)
* Running abap2UI5 Backend in Browser [(LinkedIn - 02.04.2024)](https://www.linkedin.com/pulse/running-abap2ui5-backend-browser-lars-hvam-petersen-l8zff/?trackingId=4mhMb1v%2FSoa8SmDSiuCEpg%3D%3D)
* Check out Cust&Code Videos with abap2UI5 [(youtube - 20.05.2024)](https://www.youtube.com/watch?v=SD1vIt_ty0k)
* Featured on SAP Developer News [(youtube - 14.06.2024)](https://youtu.be/7n16u-Rx8IY?t=7)
  
#### Credits
* These [**contributors**](https://github.com/abap2UI5/abap2UI5/graphs/contributors) continuously drive the evolution of this project forward
* Code versioning & distribution are managed via [**abapGit**](https://abapgit.org/) [(authors)](https://abapgit.org/sponsor.html)
* Static code analysis and quality assurance are performed via [**abaplint**](https://abaplint.org/) and [**open-abap**](https://github.com/open-abap) [(larshp)](https://github.com/larshp) 
* JSON handling for frontend-backend communication is implemented with [**ajson**](https://github.com/sbcgua/ajson) [(sbcgua)](https://github.com/sbcgua)
* Serialization of values of variables created at runtime is implemented with [**S-RTTI**](https://github.com/sandraros/S-RTTI) [(sandrarossi)](https://github.com/sandraros)
* Compatibility with lower releases is ensured through automatic syntax downport with [**abaplint**](https://abaplint.org/) [(larshp)](https://github.com/larshp) 
* ABAP for Cloud & Standard ABAP compatibility in a single codeline is achieved with [**Steampuncification**](https://github.com/heliconialabs/steampunkification)
* Live demos running in the browser are based on [**abap2UI5-web**](https://github.com/abap2UI5/abap2UI5-web) and [**web-abap2ui5-samples**](https://github.com/abap2UI5/web-abap2ui5-samples) [(larshp)](https://github.com/larshp)
* Included Frontend Frameworks: **[Animate.css](https://animate.style/) [bwip-js](https://github.com/metafloor/bwip-js) [Chart.js](https://www.chartjs.org/) [Driver.js](https://driverjs.com/) [Font Awesome](https://fontawesome.com/) [ImageMapster](http://www.outsharked.com/imagemapster/)**
* The code is primarily developed on an [**ABAP Cloud Developer Trial 2022**](https://hub.docker.com/r/sapse/abap-cloud-developer-trial) [(hosted by Nuve Platform)](https://www.nuveplatform.com/)

_A big thank you to everyone who submits PRs, shares knowledge in issues, comments, via Slack, or through other channels. This project thrives on your support!_


### What's next?
| Check out... |
|----------------------------------------------|
| 🎓 **[Sample Repository - Learn how to code with abap2UI5](https://github.com/abap2UI5/abap2UI5-samples)**|
| 💅 **[Addons - Extend abap2UI5’s functionality](https://github.com/abap2UI5-addons)**| test|
| 🪐 **[Connectors - Access your apps from anywhere](https://github.com/abap2UI5-connectors)**|
| 🚜 **[Apps - Discover & try out abap2UI5 apps](https://github.com/abap2UI5-apps)**|
| 📺 **[More - Explore other projects using abap2UI5](https://github.com/abap2UI5/abap2UI5-documentation/blob/main/links.md)**|

### Blogs & Articles
#### I. Development & Technical Background
1. Introduction: Developing UI5 Apps Purely in ABAP [(SCN - 22.02.2023)](https://blogs.sap.com/2023/02/22/abap2ui5-development-of-ui5-apps-in-pure-abap-1-3/)<br>
2. Displaying Selection Screens & Tables [(SCN - 23.02.2023)](https://blogs.sap.com/2023/02/22/abap2ui5-output-of-lists-and-tables-toolbar-and-editable-2-3/)<br>
3. Popups, F4-Help, Messages & Controller Logic [(SCN - 30.03.2023)](https://blogs.sap.com/2023/03/30/abap2ui5-3-4-flow-logic-pop-ups-f4-help/)<br>
4. Advanced Functionality & Demonstrations [(SCN - 02.04.2023)](https://blogs.sap.com/2023/04/02/abap2ui5-4-5-additional-features-demos/)<br>
5. Creating UIs with XML Views, HTML, CSS & JavaScript [(SCN - 12.04.2023)](https://blogs.sap.com/2023/04/12/abap2ui5-5-6-extensions-with-xml-views-html-js-custom-controls/)<br>
6. Installation, Configuration & Troubleshooting [(SCN - 14.04.2023)](https://blogs.sap.com/2023/04/14/abap2ui5-6-7-installation-configuration-debugging/)<br>
7. Technical Background: Under the Hood of abap2UI5 [(SCN - 26.04.2023)](https://blogs.sap.com/2023/04/26/abap2ui5-7-7-technical-background-under-the-hood-of-abap2ui5/)<br>
8. Repository Organization: Working with abapGit, abaplint & open-abap [(SCN - 21.08.2023)](https://blogs.sap.com/2023/08/21/abap2ui5-a1-repository-setup-with-abapgit-abaplint-open-abap/)<br>
9. Update I: Community Feedback & New Features [(SCN - 11.09.2023)](https://blogs.sap.com/2023/09/11/abap2ui5-a2-community-feedback-new-features/)<br>
10. Extensions I: Exploring External Libraries & Native Device Capabilities [(SCN - 04.12.2023)](https://blogs.sap.com/2023/12/04/abap2ui5-a3-extensions-i-exploring-external-libraries-native-device-capabilities/)<br>
11. Extensions II: Guideline for Developing New Features in JavaScript [(SCN - 11.12.2023)](https://blogs.sap.com/2023/12/11/abap2ui5-a4-extensions-ii-guideline-for-developing-new-features-in-javascript/)<br>
12. Update II: Community Feedback, New Features & Outlook [(SCN - 08.01.2024)](https://blogs.sap.com/2024/01/08/abap2ui5-12-update-ii-community-feedback-new-features-outlook-january-2024/)<br>

#### II. On-Stack & Side-By-Side Extensibility
1. Overview & Use Cases [(LinkedIn - 04.08.2024)](https://www.linkedin.com/pulse/use-cases-abap2ui5-overview-abap2ui5-udbde)
2. Running abap2UI5 on older R/3 Releases [(LinkedIn - 14.07.2024)](https://www.linkedin.com/pulse/running-abap2ui5-older-r3-releases-downport-compatibility-abaplint-mjkle/)
3. Calling Apps Remotely via RFC [(LinkedIn - 25.06.2024)](https://www.linkedin.com/pulse/calling-abap2ui5-apps-remotely-via-rfc-abap2ui5-btoue/)
   
#### III. SAP Fiori Launchpad Integration
1. Installation & Configration [(LinkedIn - 03.06.2024)](https://www.linkedin.com/pulse/copy-abap2ui5-host-your-apps-sap-fiori-launchpad-abap2ui5-ocn2e/?trackingId=Eot1XiIJHbM2a2ebDSF3dg%3D%3D&lipi=urn%3Ali%3Apage%3Ad_flagship3_pulse_read%3B4FqT5lkFQBioKDKsj%2F3ZTw%3D%3D)<br>
2. Setup Title, Parameters & Navigation [(LinkedIn - 06.06.2024)](https://www.linkedin.com/pulse/abap2ui5-host-your-apps-sap-fiori-launchpad-23-features-abap2ui5-upche/?trackingId=WdScbzEUGgKY%2FS2Ibiy5fA%3D%3D&lipi=urn%3Ali%3Apage%3Ad_flagship3_pulse_read%3B4FqT5lkFQBioKDKsj%2F3ZTw%3D%3D)<br>
3. Integration of KPIs [(LinkedIn - 07.06.2024)](https://www.linkedin.com/pulse/abap2ui5-host-your-apps-sap-fiori-launchpad-33-kpis-abap2ui5-uuxxe/?trackingId=RedZMaZUkHn%2Bv6oSTwtVQw%3D%3D&lipi=urn%3Ali%3Apage%3Ad_flagship3_pulse_read%3B4FqT5lkFQBioKDKsj%2F3ZTw%3D%3D)<br>

#### IV. SAP BTP Integration
1. Installation & Configuration [(LinkedIn - 09.06.2024)](https://www.linkedin.com/pulse/abap2ui5-integration-sap-business-technology-platform-13-installation-lf1re/?trackingId=jFrPiQOaJTZn6WCiK5gS3g%3D%3D)<br>
2. Setup SAP Build Workzone Websites [(LinkedIn - 16.06.2024)](https://www.linkedin.com/pulse/abap2ui5-integration-sap-business-technology-platform-23-setup-ujdqe/?trackingId=bIEcH1OFtZU8kU2PCwcp%2BA%3D%3D)
3. Setup SAP Mobile Start [(LinkedIn - 17.06.2024)](https://www.linkedin.com/pulse/abap2ui5-integration-sap-business-technology-platform-33-setup-uzure/?trackingId=He2W8FnZZ5UxpbGKHOeLEg%3D%3D)

### Installation
Install with [abapGit](https://abapgit.org) ![abapGit](https://docs.abapgit.org/img/favicon.png) and set up a new HTTP service with the following handler:
##### Standard ABAP  🏠
```abap
METHOD if_http_extension~handle_request.

   server->response->set_cdata( z2ui5_cl_http_handler=>main( server->request->get_cdata( ) ) ).
   server->response->set_header_field( name = `cache-control` value = `no-cache` ).
   server->response->set_status( code = 200 reason = `success` ).

ENDMETHOD.
```
##### ABAP for Cloud  :cloud:
<details>
<summary>show code...</summary>
   
```abap
METHOD if_http_service_extension~handle_request.

   response->set_text( z2ui5_cl_http_handler=>main( request->get_text( ) ) ).
   response->set_header_field( i_name = `cache-control` i_value = `no-cache` ).
   response->set_status( 200 ).

ENDMETHOD.
```

</details>

#### Usage
Implement the abap2UI5 interface as shown in the following example:
```abap
CLASS z2ui5_cl_app_hello_world DEFINITION PUBLIC.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.
    DATA name TYPE string.

ENDCLASS.

CLASS z2ui5_cl_app_hello_world IMPLEMENTATION.

  METHOD z2ui5_if_app~main.

    CASE client->get( )-event.
      WHEN 'POST'.
        client->message_toast_display( |Your name is { name }.| ).
    ENDCASE.

    client->view_display( z2ui5_cl_xml_view=>factory(
      )->page( 'abap2UI5 - Hello World App'
         )->simple_form( )->content( ns = `form`
            )->title( 'Input here and send it to the server...'
            )->label( 'What is your name?'
            )->input( client->_bind_edit( name )
            )->button( text = 'post' press = client->_event( 'POST' )
      )->stringify( ) ).

  ENDMETHOD.
ENDCLASS.
```
Or check out this bigger example with tables and events:
<details>
<summary>show code...</summary>
   
```abap
CLASS z2ui5_cl_demo_app DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES Z2UI5_if_app.

    TYPES:
      BEGIN OF ty_row,
        title    TYPE string,
        value    TYPE string,
        descr    TYPE string,
        icon     TYPE string,
        info     TYPE string,
        selected TYPE abap_bool,
        checkbox TYPE abap_bool,
      END OF ty_row.

    DATA t_tab TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.
    DATA check_initialized TYPE abap_bool.

ENDCLASS.

CLASS z2ui5_cl_demo_app IMPLEMENTATION.

  METHOD Z2UI5_if_app~main.

    IF check_initialized = abap_false.
      check_initialized = abap_true.

      t_tab = VALUE #(
        ( title = 'row_01'  info = 'completed'   descr = 'this is a description' icon = 'sap-icon://account' )
        ( title = 'row_02'  info = 'incompleted' descr = 'this is a description' icon = 'sap-icon://account' )
        ( title = 'row_03'  info = 'working'     descr = 'this is a description' icon = 'sap-icon://account' )
        ( title = 'row_04'  info = 'working'     descr = 'this is a description' icon = 'sap-icon://account' )
        ( title = 'row_05'  info = 'completed'   descr = 'this is a description' icon = 'sap-icon://account' )
        ( title = 'row_06'  info = 'completed'   descr = 'this is a description' icon = 'sap-icon://account' )
      ).

      DATA(view) = z2ui5_cl_xml_view=>factory( ).
      DATA(page) = view->shell(
          )->page(
              title          = 'abap2UI5 - List'
              navbuttonpress = client->_event( 'BACK' )
                shownavbutton = abap_true
              )->header_content(
                  )->link(
                      text = 'Source_Code'  target = '_blank'
                      href = z2ui5_cl_demo_utility=>factory( client )->app_get_url_source_code( )
              )->get_parent( ).

      page->list(
          headertext      = 'List Ouput'
          items           = client->_bind_edit( t_tab )
          mode            = `SingleSelectMaster`
          selectionchange = client->_event( 'SELCHANGE' )
          )->standard_list_item(
              title       = '{TITLE}'
              description = '{DESCR}'
              icon        = '{ICON}'
              info        = '{INFO}'
              press       = client->_event( 'TEST' )
              selected    = `{SELECTED}`
         ).

      client->view_display( view->stringify( ) ).

    ENDIF.

    CASE client->get( )-event.

      WHEN 'SELCHANGE'.
        client->message_box_display( `item pressed with title ` && t_tab[ selected = abap_true ]-title ).

      WHEN 'BACK'.
        client->nav_app_leave( client->get_app( client->get( )-s_draft-id_prev_app_stack ) ).
    ENDCASE.

  ENDMETHOD.
ENDCLASS.
```

</details>

#### FAQ
* Still have open questions? Check out the [documentation](https://github.com/abap2UI5/abap2UI5-documentation/) or find an answer in the [FAQ](https://github.com/abap2UI5/abap2UI5-documentation/blob/main/docs/faq.md)
* Want to help out? Check out the contribution [guidelines](https://github.com/abap2UI5/abap2UI5-documentation/blob/main/CONTRIBUTING.md)
* As always - your comments, questions, wishes and bug reports are welcome, please create an [issue](https://github.com/abap2UI5/abap2UI5/issues)
