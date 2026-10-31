<p align="center"><a href="https://www.abap2ui5.org" target="_blank"><img src="https://github.com/abap2UI5/abap2UI5/assets/102328295/52ac0bb6-a219-4e9d-9e4f-62698dab3063" width="200"></a></p>

<p align="center">
  <strong>Build UI5 Apps Purely in ABAP – no JavaScript, OData, or RAP needed.</strong>
</p>

<p align="center">
  Just like the good old days when Selection Screens and ALVs delivered full UIs from a few lines of ABAP. Designed with a minimal system footprint, it runs in both on-premise and cloud environments.
</p>

<p align="center">
  <a href="https://github.com/abap2UI5/abap2UI5/stargazers"><img src="https://img.shields.io/github/stars/abap2UI5/abap2UI5?style=flat&color=blue" alt="GitHub stars"></a>
  <a href="LICENSE"><img src="https://img.shields.io/github/license/abap2UI5/abap2UI5?color=blue" alt="License: MIT"></a>
  <img src="https://img.shields.io/badge/ABAP-NW%207.02%20%E2%86%92%20Cloud-blue" alt="ABAP NW 7.02 to ABAP Cloud">
  <a href="https://www.linkedin.com/company/abap2ui5"><img src="https://img.shields.io/badge/LinkedIn-abap2UI5-blue?style=flat&logo=linkedin&logoColor=white" alt="LinkedIn"></a>
</p>

<p align="center">
  <a href="https://github.com/abap2UI5/abap2UI5/actions/workflows/test.yaml"><img src="https://github.com/abap2UI5/abap2UI5/actions/workflows/test.yaml/badge.svg?branch=main" alt="test"></a>
  <a href="https://github.com/abap2UI5/abap2UI5/actions/workflows/check_gates.yaml"><img src="https://github.com/abap2UI5/abap2UI5/actions/workflows/check_gates.yaml/badge.svg?branch=main" alt="check_gates"></a>
  <a href="https://github.com/abap2UI5/abap2UI5/actions/workflows/abaplint.yaml"><img src="https://github.com/abap2UI5/abap2UI5/actions/workflows/abaplint.yaml/badge.svg?branch=main" alt="abaplint"></a>
</p>

<!-- facts:start -->
<p align="center">
  <sub>1,533 ABAP unit tests · 87 JS unit specs · 18 browser test suites · 52 CI gates · 25 workflows · ABAP 7.02 → Cloud · UI5 1.71 → 2.x — counted from this repository by <code>npm run facts</code></sub>
</p>
<!-- facts:end -->

<p align="center">
  <a href="https://abap2ui5.github.io/why/">For managers</a> •
  <a href="https://abap2ui5.github.io/docs/">Documentation</a> •
  <a href="https://abap2ui5.github.io/samples-site/">Samples</a> •
  <a href="https://abap2ui5.github.io/playground/">Playground</a> •
  <a href="https://abap2ui5-addons.github.io/">Addons &amp; Tools</a> •
  <a href="https://github.com/abap2UI5/abap2UI5/issues">Issues</a> •
  <a href="https://join.slack.com/t/abapgit/shared_invite/zt-46tqufaht-QlrxTzlDqlx85CWbeUnOqg">Slack</a> •
  <a href="https://abap2ui5.github.io/docs/resources/sponsor.html">Sponsor</a>
</p>

## What it is

One ABAP class is one UI5 app. No JavaScript, no OData, no frontend project:
the class builds a UI5 view and binds its data, the framework carries every
roundtrip, and the app runs in a browser tab, a Fiori launchpad tile or SAP
Build Work Zone. Installed with abapGit, from NetWeaver 7.02 to ABAP Cloud.

```abap
CLASS zcl_my_app DEFINITION PUBLIC.
  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.
ENDCLASS.

CLASS zcl_my_app IMPLEMENTATION.
  METHOD z2ui5_if_app~main.
    client->message_box_display( `Hello World` ).
  ENDMETHOD.
ENDCLASS.
```

That's it – your first UI5 app is ready and abap2UI5 handles the rest! 🎉

One thing stays yours: the framework performs no authority check of its own, so an app that guards business data checks its authorizations at the top of `main`, like a transaction does – see the [security model](docs/security.md#what-the-app-has-to-do).

## Where to go

| | |
| --- | --- |
| **For managers** | [What abap2UI5 means for an organization](https://abap2ui5.github.io/why/) – what it can build, how it compares, what it costs, who runs it |
| **For developers** | [The documentation](https://abap2ui5.github.io/docs/) – quickstart, tutorial, cookbook, production, [developing with AI](https://abap2ui5.github.io/docs/get_started/ai) |
| **Try it** | [The playground](https://abap2ui5.github.io/playground/) – ABAP in the editor, the running app beside it, nothing installed; [the samples](https://abap2ui5.github.io/samples-site/) – hundreds of ready-to-run apps |
| **Around it** | [Addons & Tools](https://abap2ui5-addons.github.io/) – what to install beside it, and the tools for your editor, pipeline and agent |

Working with Claude Code? Two commands install the abap2UI5 plugin – the agent skills, the MCP server and the lint hook:

```
/plugin marketplace add abap2UI5/abap2UI5
/plugin install abap2ui5@abap2ui5
```

GitHub Copilot: `copilot plugin install abap2UI5/abap2UI5`. Every other assistant, editor and the full setup: [Developing with AI](https://abap2ui5.github.io/docs/get_started/ai).

## Credits
This project thrives thanks to its [contributors](https://github.com/abap2UI5/abap2UI5/graphs/contributors) and these outstanding open-source projects:
* Code versioning & distribution via [abapGit](https://abapgit.org/) [(contributors)](https://abapgit.org/sponsor.html)
* Static Code Checks via [abaplint](https://abaplint.org/) [(contributors)](https://github.com/abaplint/abaplint/graphs/contributors)
* Unit Testing via [open-abap](https://github.com/open-abap) [(contributors)](https://github.com/open-abap/open-abap-core/graphs/contributors)
* JSON handling through [ajson](https://github.com/sbcgua/ajson) [(sbcgua)](https://github.com/sbcgua)
* Runtime serialization using [S-RTTI](https://github.com/sandraros/S-RTTI) [(sandrarossi)](https://github.com/sandraros)
* ABAP Cloud & Standard compatibility with [Steampunkification](https://github.com/heliconialabs/steampunkification) [(contributors)](https://github.com/heliconialabs/steampunkification/graphs/contributors)
* Syntax downporting via the [downport branch](https://github.com/abap2UI5/abap2UI5/tree/702) by [abaplint](https://abaplint.org/) [(larshp)](https://github.com/larshp)
* Namespace renaming with [abaplint](https://abaplint.org/) [(larshp)](https://github.com/larshp)
* Browser testing with [Playwright](https://playwright.dev/) [(contributors)](https://github.com/microsoft/playwright/graphs/contributors)
* [Live demos](https://abap2ui5.github.io/web-abap2UI5-build/) built from [web-abap2UI5](https://github.com/abap2UI5/web-abap2UI5) [(larshp)](https://github.com/larshp)
* Code cleanup with [ABAP Cleaner](https://github.com/SAP/abap-cleaner) [(contributors)](https://github.com/SAP/abap-cleaner/graphs/contributors)
* Documentation created with [VitePress](https://vitepress.dev/) [(contributors)](https://github.com/vuejs/vitepress/graphs/contributors)

## Get Involved
We welcome all contributions! Here's how you can help:
* [Issues](https://github.com/abap2UI5/abap2UI5/issues) - Report issues and provide feedback
* [Contribution](https://abap2ui5.github.io/docs/resources/contribution.html) - Contribute code and documentation ([CONTRIBUTING.md](CONTRIBUTING.md) is the in-repo guide)
* [LinkedIn](https://www.linkedin.com/company/abap2ui5) - Follow abap2UI5 for updates and community highlights
* [Sponsor](https://abap2ui5.github.io/docs/resources/sponsor.html) - Sponsor our work to support ongoing innovation

_Share your knowledge, hunt for bugs, submit a PR, give us a ⭐, or tell your colleagues about abap2UI5. Every contribution counts!_
