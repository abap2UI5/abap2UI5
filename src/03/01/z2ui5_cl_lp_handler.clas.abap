CLASS z2ui5_cl_lp_handler DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    " The handler of the ICF node /sap/bc/z2ui5 this package delivers - the
    " one class of the repository that exists on Standard ABAP only:
    " if_http_extension is no released API, so the branch for ABAP Cloud
    " carries a class of the same name on if_http_service_extension instead,
    " behind an HTTP service (cloud/src/03/01).
    " Everything it does is hand the request to the public entry point. The
    " name is the one installations have had since the node shipped from
    " abap2UI5/frontend, and their node names it - do not rename it.
    INTERFACES if_http_extension.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS z2ui5_cl_lp_handler IMPLEMENTATION.

  METHOD if_http_extension~handle_request.

    z2ui5_cl_ui5_http_handler=>run( server ).

  ENDMETHOD.

ENDCLASS.
