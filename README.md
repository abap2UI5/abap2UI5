> ⚙️ **Generated branch `cloud`** — built from `main` of [abap2UI5/abap2UI5](https://github.com/abap2UI5/abap2UI5) by its `auto-cloud` workflow. Do not commit here; change the source on `main`.

# abap2UI5 for ABAP Cloud

abap2UI5 for the **BTP ABAP environment** and **S/4HANA Public Cloud**. For
Standard ABAP (S/4HANA on-premise and private cloud, NetWeaver 7.50 and
later) pull the branch `main`, for NetWeaver 7.02 to 7.4x the branch `702`.

| | `main` | `cloud` |
|---|---|---|
| the framework (`src/00` to `src/02`) | the same code | the same code |
| the service | the ICF node `/sap/bc/z2ui5` | the HTTP service `Z2UI5`, `/sap/bc/http/sap/z2ui5` |
| its handler `Z2UI5_CL_UI5_ICF_HANDLER` | on `if_http_extension` | on `if_http_service_extension` |
| the app | the BSP `Z2UI5`, pulled with the rest | the Fiori project in `app/`, deployed |
| around it | - | the IAM app and the business catalog of `src/03` |

## Install

1. Pull this branch with abapGit (ADT) into a package of your own. `src/03`
   holds the HTTP service, its handler and the IAM objects.
2. Open `/sap/bc/http/sap/z2ui5` - abap2UI5 runs, the page is served by the
   HTTP service itself.
3. For the launchpad, deploy the Fiori project in `app/` to the system (SAP
   Business Application Studio or VS Code with the SAP Fiori tools:
   `npm install`, then add a deployment configuration and deploy). The app is
   one view with one control, which loads the abap2UI5 frontend from the
   HTTP service - it does not have to be deployed again after an abap2UI5
   update.

The launchpad component is `z2ui5` with the inbound `z2ui5-display`
(semantic object `z2ui5`, action `display`).

Everything else - building apps, the API, the samples - is the same as on
`main`: [abap2UI5.org](https://abap2UI5.org).
