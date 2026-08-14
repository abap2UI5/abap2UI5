* =====================================================================
* GENERATED FILE - DO NOT EDIT (AGENTS.md rule 2)
* Build identity of the embedded frontend, generated from app/webapp/ by
* .github/app2abap/trans2abap.js. Change the source under app/webapp/
* and run 'npm run app2abap' to regenerate; the check_app2abap CI gate
* fails any manual edit here.
*
* The same two values ship to the browser in app/webapp/core/Build.js, so
* the frontend that is actually RUNNING can be compared against the one
* this backend embeds - see z2ui5_cl_ui5_handler=>main_end.
* =====================================================================
CLASS z2ui5_cl_ui5f_build DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    " abap2UI5 release these frontend artefacts were generated from.
    CONSTANTS version TYPE string VALUE `1.142.0`.

    " Fingerprint over app/webapp/** (core/Build.js excluded).
    CONSTANTS hash TYPE string VALUE `648b8b387a9d`.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS z2ui5_cl_ui5f_build IMPLEMENTATION.
ENDCLASS.
