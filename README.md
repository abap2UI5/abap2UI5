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
This project wouldn’t be where it is without the amazing [contributors](https://github.com/abap2UI5/abap2UI5/graphs/contributors) and the tools that help power it:
* Code versioning & distribution via [abapGit](https://abapgit.org/) [(authors)](https://abapgit.org/sponsor.html)
* Code analysis & testing via [abaplint](https://abaplint.org/) & [open-abap](https://github.com/open-abap) [(larshp)](https://github.com/larshp) 
* JSON handling through [ajson](https://github.com/sbcgua/ajson) [(sbcgua)](https://github.com/sbcgua)
* Runtime serialization using [S-RTTI](https://github.com/sandraros/S-RTTI) [(sandrarossi)](https://github.com/sandraros)
* ABAP Cloud & Standard ABAP compatibility with [Steampuncification](https://github.com/heliconialabs/steampunkification) ([authors](https://github.com/heliconialabs/steampunkification/graphs/contributors))
* Syntax downporting via the [downport repositories](https://github.com/abap2UI5-downports) automated by [abaplint](https://abaplint.org/) [(larshp)](https://github.com/larshp)
* Namespace renaming via the [mirror repository](https://github.com/abap2UI5/abap2UI5-mirror-renamed) automated by [abaplint](https://abaplint.org/) [(larshp)](https://github.com/larshp)
* Browser Testing with [Playwright](https://playwright.dev/) & [web-abap2UI5](https://github.com/abap2UI5/abap2UI5-web) [(larshp)](https://github.com/larshp)
* Live demos running via [web-abap2ui5-samples](https://github.com/abap2UI5/web-abap2ui5-samples) [(larshp)](https://github.com/larshp)
* Primarily developed on an [ABAP Cloud Developer Trial 2022](https://hub.docker.com/r/sapse/abap-cloud-developer-trial) [(hosted by Nuve Platform)](https://www.nuveplatform.com/)

_Thanks to everyone who submits PRs, shares knowledge in issues, comments, via Slack, or through other channels. This project thrives on your support!_ 

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

### What's next? 
#### Check out these next steps to dive deeper into abap2UI5:
* 🕹️ [**Quickstart**](https://github.com/abap2UI5/abap2UI5-documentation/blob/main/docs/quickstart.md) –  Install and get up and running with your first abap2UI5 app in no time 
* 🎓 [**Samples**](https://github.com/abap2UI5/abap2UI5-samples) – Learn through hands-on examples and start building your own apps
* 💅 [**Addons**](https://github.com/abap2UI5-addons) – Expand abap2UI5’s capabilities to fit your needs
* 🪐 [**Connectors**](https://github.com/abap2UI5-connectors) – Seamlessly access your apps from anywhere
* 🚜 [**Apps**](https://github.com/abap2UI5-apps) – Discover and try out apps built with abap2UI5
* 📺 [**More**](https://github.com/abap2UI5/abap2UI5-documentation/blob/main/links.md) – Stay inspired! Explore other awesome projects built using abap2UI5

#### FAQ
* Still have open questions? Check out the [documentation](https://github.com/abap2UI5/abap2UI5-documentation/) or find an answer in the [FAQ](https://github.com/abap2UI5/abap2UI5-documentation/blob/main/docs/faq.md)
* Want to help out? Check out the contribution [guidelines](https://github.com/abap2UI5/abap2UI5-documentation/blob/main/CONTRIBUTING.md)
* As always - your comments, questions, wishes and bug reports are welcome, please create an [issue](https://github.com/abap2UI5/abap2UI5/issues)

Whether you're an ABAP veteran or just starting, join us in making UI5 development easier, faster, and more ABAP-centric. Start exploring, contributing, and shaping the future of abap2UI5 today! 🎉
