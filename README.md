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
This project owes much to the fantastic [contributors](https://github.com/abap2UI5/abap2UI5/graphs/contributors) and supporting tools:
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

#### What's next? 
* [Quickstart](https://github.com/abap2UI5/abap2UI5-documentation/blob/main/docs/quickstart.md) –  Install and get started with your first abap2UI5 app
* [Samples](https://github.com/abap2UI5/abap2UI5-samples) – Learn through hands-on examples and start building your own apps
* [Blogs](https://github.com/abap2UI5/abap2UI5-documentation/blob/main/docs/blogs.md) - Dive into these articles for in-depth insights and updates
* [Addons](https://github.com/abap2UI5-addons) – Expand abap2UI5’s capabilities to fit your needs
* [Connectors](https://github.com/abap2UI5-connectors) – Seamlessly access your apps from anywhere
* [Apps](https://github.com/abap2UI5-apps) – Discover and try out abap2UI5 apps 
* [More](https://github.com/abap2UI5/abap2UI5-documentation/blob/main/links.md) – Explore other exciting projects built using abap2UI5

#### Get Involved
* Questions? Check out the [documentation](https://github.com/abap2UI5/abap2UI5-documentation/) or find an answer in the [FAQ](https://github.com/abap2UI5/abap2UI5-documentation/blob/main/docs/faq.md)
* Feedback or bugs? Please create an [issue](https://github.com/abap2UI5/abap2UI5/issues)
* Want to contribute? We welcome every PR! Review our [contribution guidelines](https://github.com/abap2UI5/abap2UI5-documentation/blob/main/CONTRIBUTING.md) to get started

_Stay updated by following us on [LinkedIn!](https://www.linkedin.com/company/abap2ui5) Your comments and likes are greatly appreciated. This project thrives on your support! 🚀_ 


