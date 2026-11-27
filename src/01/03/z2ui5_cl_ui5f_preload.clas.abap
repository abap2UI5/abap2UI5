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
    " get( ) returns and the frontend bundle get_bundle( ) returns, which
    " names the custom controls bundle by its own digest - fixed
    " at generation time. Part of the ETag of
    " the page and of the bundle (z2ui5_cl_ui5_http_handler=>_get_etag)
    CONSTANTS build_hash TYPE string VALUE '1de56c07aca73809'.

    " the digest of the script get( ) returns as a CSP hash source, without
    " the quotes around it:
    " z2ui5_cl_ui5_http_handler=>_http_get lists it in the policy's
    " script-src, so this one inline script runs without 'unsafe-inline'.
    " It is the SHA-256 of get( ) byte for byte - a script that differs by one
    " character does not run at all, which the browser e2e legs would show
    CONSTANTS script_hash TYPE string VALUE 'sha256-2+TU64TvnM1cUDYzsYuy9YGhChhn/Y0bUbNG5tDk100='.

    " a digest of the devtools bundle get_devtools( ) returns - the files
    " of the developer tools the frontend bundle does not carry. The ETag of
    " that bundle carries it (z2ui5_cl_ui5_http_handler=>_http_get_devtools)
    CONSTANTS devtools_hash TYPE string VALUE '29e3d6a45f0528eb'.

    " a digest of the custom controls bundle get_cc( ) returns. The
    " frontend bundle carries it too (the ccBundle of its z2ui5/embed
    " module) and asks for the controls by it - as ?z2ui5-bundle=cc with
    " this value as z2ui5-version, which lets a browser keep the answer
    " (z2ui5_cl_ui5_http_handler=>_is_bundle_versioned). The ETag of that
    " bundle carries it as well
    CONSTANTS cc_hash TYPE string VALUE '463a916e8fb00e7f'.

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

    " the custom controls as a script of the same shape: every file of
    " bundle/webapp/cc/, which the frontend bundle does not carry.
    " Served on ?z2ui5-bundle=cc
    " (z2ui5_cl_ui5_http_handler=>_http_get_cc) and loaded by
    " z2ui5/core/CustomControls before the first view that names a
    " control is built
    CLASS-METHODS get_cc
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

  METHOD get_cc.

    result = z2ui5_cl_ui5f_cc=>get( ).

  ENDMETHOD.

ENDCLASS.
