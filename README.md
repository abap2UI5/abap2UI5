<details>

<summary>🚦 Build & test status</summary>
<br>

[![ABAP_702](https://github.com/abap2UI5/abap2UI5/actions/workflows/ABAP_702.yaml/badge.svg?branch=702)](https://github.com/abap2UI5/abap2UI5/actions/workflows/ABAP_702.yaml?query=branch%3A702)
[![ABAP_STANDARD](https://github.com/abap2UI5/abap2UI5/actions/workflows/ABAP_STANDARD.yaml/badge.svg)](https://github.com/abap2UI5/abap2UI5/actions/workflows/ABAP_STANDARD.yaml)
[![ABAP_CLOUD](https://github.com/abap2UI5/abap2UI5/actions/workflows/ABAP_CLOUD.yaml/badge.svg)](https://github.com/abap2UI5/abap2UI5/actions/workflows/ABAP_CLOUD.yaml)
[![UI5_2X](https://github.com/abap2UI5/abap2UI5/actions/workflows/UI5.yaml/badge.svg?branch=main)](https://github.com/abap2UI5/abap2UI5/actions/workflows/UI5.yaml)
<br>
[![auto_downport](https://github.com/abap2UI5/abap2UI5/actions/workflows/auto_downport.yaml/badge.svg)](https://github.com/abap2UI5/abap2UI5/actions/workflows/auto_downport.yaml)
[![auto_abaplint_fix](https://github.com/abap2UI5/abap2UI5/actions/workflows/auto_abaplint_fix.yaml/badge.svg)](https://github.com/abap2UI5/abap2UI5/actions/workflows/auto_abaplint_fix.yaml)
<br>
[![test_unit](https://github.com/abap2UI5/abap2UI5/actions/workflows/test_unit.yaml/badge.svg)](https://github.com/abap2UI5/abap2UI5/actions/workflows/test_unit.yaml)
[![test_node](https://github.com/abap2UI5/abap2UI5/actions/workflows/test_node.yaml/badge.svg)](https://github.com/abap2UI5/abap2UI5/actions/workflows/test_node.yaml)
[![test_browser](https://github.com/abap2UI5/abap2UI5/actions/workflows/test_browser.yaml/badge.svg)](https://github.com/abap2UI5/abap2UI5/actions/workflows/test_browser.yaml)
[![test_rename](https://github.com/abap2UI5/abap2UI5/actions/workflows/test_rename.yaml/badge.svg)](https://github.com/abap2UI5/abap2UI5/actions/workflows/test_rename.yaml)
<br>
[![create_app2abap](https://github.com/abap2UI5/abap2UI5/actions/workflows/create_app2abap.yaml/badge.svg)](https://github.com/abap2UI5/abap2UI5/actions/workflows/create_app2abap.yaml)
[![create_frontend](https://github.com/abap2UI5/abap2UI5/actions/workflows/create_frontend.yaml/badge.svg)](https://github.com/abap2UI5/abap2UI5/actions/workflows/create_frontend.yaml)
<br>
[![mirror_ajson](https://github.com/abap2UI5/abap2UI5/actions/workflows/mirror_ajson.yaml/badge.svg)](https://github.com/abap2UI5/abap2UI5/actions/workflows/mirror_ajson.yaml)
[![mirror_srtti](https://github.com/abap2UI5/abap2UI5/actions/workflows/mirror_srtti.yaml/badge.svg)](https://github.com/abap2UI5/abap2UI5/actions/workflows/mirror_srtti.yaml)

</details>

<p align="center"><a href="https://www.abap2ui5.org" target="_blank"><img src="https://github.com/abap2UI5/abap2UI5/assets/102328295/52ac0bb6-a219-4e9d-9e4f-62698dab3063" width="200"></a></p>

<p align="center">
  <strong>Build SAP UI5 apps purely in ABAP — no JavaScript, OData, or RAP.</strong>
  <br>
  Like the good old days of selection screens and ALVs: a full UI in a few lines of ABAP. Tiny footprint, runs on everything from NW 7.02 to ABAP Cloud.
</p>

<p align="center">
  <a href="https://abap2UI5.org">📚 Documentation</a> •
  <a href="https://github.com/abap2UI5/abap2UI5-samples">🎯 Samples (250+ apps)</a> •
  <a href="https://github.com/abap2UI5/abap2UI5/issues">💬 Issues</a> •
  <a href="https://www.linkedin.com/company/abap2ui5">🔗 LinkedIn</a> •
  <a href="https://communityinviter.com/apps/abapgit/abap">👥 Slack</a> •
  <a href="https://abap2ui5.github.io/docs/resources/sponsor.html">💖 Sponsor</a>
</p>

---

## Quick Start

A working app needs four things: the framework installed, an HTTP handler, an app class, and a browser URL.

**1. Install via abapGit** &nbsp;—&nbsp; clone `https://github.com/abap2UI5/abap2UI5` into a package of your choice. No transports, no extra deployment.

**2. Expose an ICF endpoint** &nbsp;—&nbsp; create a tiny HTTP handler class and register it in SICF (full reference: [`node/srv/zcl_sicf.clas.abap`](node/srv/zcl_sicf.clas.abap)):

```abap
CLASS zcl_sicf DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES if_http_extension.
ENDCLASS.

CLASS zcl_sicf IMPLEMENTATION.
  METHOD if_http_extension~handle_request.
    z2ui5_cl_http_handler=>factory( server )->main( ).
  ENDMETHOD.
ENDCLASS.
```

**3. Write your first app** &nbsp;—&nbsp; one class, one interface:

```abap
CLASS zcl_my_app DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.
ENDCLASS.

CLASS zcl_my_app IMPLEMENTATION.
  METHOD z2ui5_if_app~main.
    client->message_box_display( `Hello World` ).
  ENDMETHOD.
ENDCLASS.
```

**4. Open it in a browser** &nbsp;—&nbsp; navigate to your SICF endpoint and pass your app as a URL parameter:

```
https://<host>:<port>/sap/bc/z2ui5?app_start=ZCL_MY_APP
```

That's it — abap2UI5 handles the rest. 🎉

> 📖 Full setup walkthrough: [Getting Started Guide](https://abap2ui5.github.io/docs/get_started/quickstart.html) &nbsp;·&nbsp; 🎯 Build real apps: [abap2UI5-samples](https://github.com/abap2UI5/abap2UI5-samples) (template + Client API reference + 250+ examples)

## How It Works

abap2UI5 is a **stateful single-page app**. The browser loads a UI5 shell once, then talks to ABAP via JSON roundtrips:

```
 Browser (UI5 SPA)                     ABAP Backend
       │                                    │
       │── GET ────────────────────────────▶│  Returns HTML + UI5 shell
       │◀── HTML ─────────────────────────── │
       │                                    │
       │── POST { event, model deltas } ──▶ │  1. Load session draft
       │                                    │  2. Apply two-way bindings
       │                                    │  3. Call your app->main( )
       │                                    │  4. Persist new draft
       │◀── { view XML, model, actions } ── │
       │                                    │
       │  (UI5 renders, binds, awaits next event)
```

You never touch JSON, HTTP, or JavaScript yourself. You implement `z2ui5_if_app~main`, build views with the fluent XML builder, and bind ABAP variables to UI5 controls — the framework handles serialization, sessions, and rendering.

## Key Features

| | |
|---|---|
| 🧩 **One interface** | Implement `z2ui5_if_app` and you have a working SPA |
| 🪶 **Minimal footprint** | Only an HTTP handler — no BSP, OData, CDS, or RAP |
| ☁️ **Cloud & on-premise** | Works in ABAP Cloud and Standard ABAP |
| 🕰️ **Broad compatibility** | All releases from NW 7.02 to ABAP Cloud |
| 📦 **Easy install** | abapGit clone, no extra deployment |
| 🔄 **Two-way data binding** | Bind ABAP variables directly to UI5 controls |
| 🎨 **Full UI5 control library** | Generic XML builder gives access to every UI5 control |
| 🧰 **Built-in popups** | Confirm, inform, select, file up/download, table picker, PDF, and more |

## Get Involved

We welcome all contributions:

* [Issues](https://github.com/abap2UI5/abap2UI5/issues) — report bugs, request features, give feedback
* [Contribution guide](https://abap2ui5.github.io/docs/resources/contribution.html) — code, docs, tests
* [LinkedIn](https://www.linkedin.com/company/abap2ui5) — follow for updates
* [Sponsor](https://abap2ui5.github.io/docs/resources/sponsor.html) — support ongoing work

_Star the repo, hunt a bug, write a comment, or tell a colleague. Every bit counts._ 🙏

## Credits

This project thrives thanks to its [contributors](https://github.com/abap2UI5/abap2UI5/graphs/contributors) and these excellent tools:

| | |
|---|---|
| Code distribution | [abapGit](https://abapgit.org/) |
| Static analysis & transpilation | [abaplint](https://abaplint.org/) |
| Unit testing | [open-abap](https://github.com/open-abap) |
| JSON handling | [ajson](https://github.com/sbcgua/ajson) ([sbcgua](https://github.com/sbcgua)) |
| Runtime type info | [S-RTTI](https://github.com/sandraros/S-RTTI) ([sandrarossi](https://github.com/sandraros)) |
| Cloud/Standard compat | [Steampunkification](https://github.com/heliconialabs/steampunkification) |
| Browser testing | [Playwright](https://playwright.dev/) |
| Code cleanup | [ABAP Cleaner](https://github.com/SAP/abap-cleaner) |
| Docs | [VitePress](https://vitepress.dev/) |
| Live demos | [web-abap2ui5-samples](https://github.com/abap2UI5/web-abap2ui5-samples) ([larshp](https://github.com/larshp)) |

<details>
<summary>📰 Press, talks & community coverage</summary>
<br>

* Webinar on Launchpad Integration — [YouTube, 30.07.2025](https://www.youtube.com/watch?v=t5g3F3PHsbw&list=PLLpkZ_86h4quGSfsjohDHt9CrpjXdeA1P)
* Featured on SAP Developer News — [YouTube, 21.03.2025](https://www.youtube.com/watch?v=vKrpkDe2mkU&list=PL6RpkC85SLQAVBSQXN9522_1jNvPavBgg&t=90s)
* Webinar: Creating UI5 UIs from ABAP — [YouTube, 12.12.2024](https://www.youtube.com/watch?v=N2OAdxf7Lng)
* Boring Enterprise Nerdletter — [YouTube](https://www.youtube.com/watch?v=I81z6W_BTIA&t=1010s) · [Newsletter, 11.12.2024](https://boringenterprisenerds.substack.com/p/72-abap2ui5-aancos-crystal-ball-sapta)
* Webinar: Developing UI5 Apps with abap2UI5 — [YouTube, 07.11.2024](https://www.youtube.com/watch?v=0izPA2xrPPI)
* Featured on SAP Developer News — [YouTube, 14.06.2024](https://youtu.be/7n16u-Rx8IY?t=7)
* Cust&Code videos — [YouTube, 20.05.2024](https://www.youtube.com/watch?v=SD1vIt_ty0k)
* Running abap2UI5 backend in browser — [LinkedIn, 02.04.2024](https://www.linkedin.com/pulse/running-abap2ui5-backend-browser-lars-hvam-petersen-l8zff/)
* Boring Enterprise Nerdcast — [YouTube, 29.01.2024](https://youtu.be/svDZKFBvqR8?t=1050)
* Featured on SAP Developer News — [YouTube, 15.12.2023](https://www.youtube.com/watch?v=CfH9L03WUCg&t=350s)
* Advent of Code 2023 — [SAP Community, 27.11.2023](https://blogs.sap.com/2023/11/27/preparing-for-advent-of-code-2023/)
* Showcased at SAP TechEd 2023 — [YouTube, 02.11.2023](https://www.youtube.com/watch?v=kLbF0ooStZs&t=3052s)
* SAP Developer Code Challenge — [SAP Community, 17.05.2023](https://groups.community.sap.com/t5/application-development/sap-developer-code-challenge-open-source-abap-week-2/m-p/260727#M1372)
* Boring Enterprise Nerdletter — [YouTube](https://www.youtube.com/watch?v=G62exySitCo&list=PLlxj8-g1r2GlVYXVQnnV5izKwKtEn6KIp&t=1008s) · [Newsletter, 08.03.2023](https://boringenterprisenerds.substack.com/p/34-abap2ui5-sap-cva-burnout-c2c-shortwave)
* Featured on SAP Developer News — [YouTube, 26.01.2023](https://www.youtube.com/watch?v=6BDK55xYttM)

</details>
