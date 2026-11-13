* =====================================================================
* GENERATED FILE - DO NOT EDIT (AGENTS.md rule 2)
* The texts the HTTP service serves, generated from bundle/webapp/ and
* app_source/webapp/ by tools/app2abap/trans2abap.js. Change the sources
* and run 'npm run app2abap' to regenerate; the check_app2abap CI gate
* fails any manual edit here.
* =====================================================================
CLASS z2ui5_cl_ui5f_preload DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    " a digest of everything the node serves a browser - the page's script
    " get( ) returns and the frontend bundle get_bundle( ) returns - fixed
    " at generation time. Part of the ETag of
    " the page and of the bundle (z2ui5_cl_ui5_http_handler=>_get_etag)
    CONSTANTS build_hash TYPE string VALUE '903578033af6c594'.

    " the digest of the script get( ) returns as a CSP hash source, without
    " the quotes around it:
    " z2ui5_cl_ui5_http_handler=>_http_get lists it in the policy's
    " script-src, so this one inline script runs without 'unsafe-inline'.
    " It is the SHA-256 of get( ) byte for byte - a script that differs by one
    " character does not run at all, which the browser e2e legs would show
    CONSTANTS script_hash TYPE string VALUE 'sha256-OaHKi7+uelz3KfmVE6/CJIzN/0eUzS4sGkErt4w1yP0='.

    " a digest of the devtools bundle get_devtools( ) returns - the files
    " of the developer tools the frontend bundle does not carry. The ETag of
    " that bundle carries it (z2ui5_cl_ui5_http_handler=>_http_get_devtools)
    CONSTANTS devtools_hash TYPE string VALUE '713768082e5b7d13'.

    " the one inline script of the GET page: the page's minimal app (a
    " component with one view) and the embed control that view holds
    " (z2ui5.embed.Container) as a preload, and the call that starts it.
    " Nothing of the frontend - the control loads it from the node, as
    " get_bundle( )
    CLASS-METHODS get
      RETURNING
        VALUE(result) TYPE string.

    " the frontend as a script of its own, for a page that embeds the
    " component - the GET page of this node included:
    " sap.ui.require.preload( ) and nothing else - no function
    " around it, no start (z2ui5_cl_ui5_http_handler=>_http_get_bundle)
    CLASS-METHODS get_bundle
      RETURNING
        VALUE(result) TYPE string.

    " the developer tools as a script of the same shape: the dialog, its
    " fragment, the inspectors - everything under devtools/ the frontend
    " bundle does not carry (tools/app2abap/trans2abap.js, DEVTOOLS_EAGER).
    " Served on ?z2ui5-bundle=devtools
    " (z2ui5_cl_ui5_http_handler=>_http_get_devtools) and loaded by
    " z2ui5/devtools/DevTools.js when the tools are opened
    CLASS-METHODS get_devtools
      RETURNING
        VALUE(result) TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS z2ui5_cl_ui5f_preload IMPLEMENTATION.

  METHOD get.

    result = z2ui5_cl_ui5f_page=>get( ).

  ENDMETHOD.

  METHOD get_bundle.

    result = z2ui5_cl_ui5f_bundle=>get( ).

  ENDMETHOD.

  METHOD get_devtools.

    result = z2ui5_cl_ui5f_devtools=>get( ).

  ENDMETHOD.

ENDCLASS.
