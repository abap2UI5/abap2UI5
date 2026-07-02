# Setup — from nothing to a running app

You only do this **once per system/project**. After the framework is installed
and one HTTP entry point exists, every new app is just a new class implementing
`z2ui5_if_app` — no extra wiring.

## 1. Install the framework
Pull abap2UI5 into the system with **abapGit**:
- Repo: `https://github.com/abap2UI5/abap2UI5`
- It is self-contained — no other dependencies, no JS build, no OData/RAP.
- Works on NW 7.02+ (on-premise) and ABAP Cloud.

Optionally also install the examples for reference:
`https://github.com/abap2UI5/samples`.

## 2. Create the HTTP entry point
abap2UI5 needs one HTTP handler that hands incoming requests to the framework.
The handler is ~15 lines and the same for every app you ever build — the app
that runs is chosen at runtime (e.g. via startup parameter / launchpad), not
hard-coded here.

### On-premise (ICF node)
1. Create an ICF service node (transaction `SICF`, e.g. under
   `/sap/bc/z2ui5`).
2. Point it at a handler class whose `IF_HTTP_EXTENSION~HANDLE_REQUEST` delegates
   to the framework:
   ```abap
   METHOD if_http_extension~handle_request.
     DATA(app) = z2ui5_cl_http_handler=>factory( server ).
     app->main( ).
   ENDMETHOD.
   ```
   Use the reference handler `zcl_sicf` in the framework repo
   (`node/srv/zcl_sicf.clas.abap`) as the template.
3. Activate the service. The app is reachable at the service URL.

### ABAP Cloud
Use `z2ui5_cl_http_handler=>factory_cloud( )` from a class implementing
`if_http_service_extension`, exposed via an **HTTP service** (IAM/“Service
Binding”) in the ABAP Development Tools (Eclipse). The app class itself is
identical to on-premise.

> Exact, screenshot-level steps (SICF config, cloud service binding, launchpad
> integration) are in the official docs — link the user there rather than
> guessing system specifics: <https://abap2ui5.github.io/docs/>.

## 3. Run an app
- Open the ICF service URL in a browser; abap2UI5 serves the UI5 shell and starts
  the configured startup app.
- To launch a specific app, follow the project's startup mechanism (startup
  parameter / a small menu app that calls `client->nav_app_call( NEW zcl_my_app( ) )`).
- For local development without a backend, the framework repo ships a Node dev
  server (`npm run express`, port 3000) used for its own frontend tests — that is
  for framework development, not for running your ABAP apps.

## 4. Iterate
With the handler in place, building a new app is: write the class → activate →
launch it. No handler or routing changes are needed per app.
