CLASS z2ui5_cl_core_http_get DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    DATA ms_request TYPE z2ui5_if_types=>ty_s_http_request_get.

    METHODS constructor
      IMPORTING
        val TYPE z2ui5_if_types=>ty_s_http_request_get OPTIONAL.

    METHODS main
      RETURNING
        VALUE(result) TYPE string.

    METHODS get_js_cc_startup
      RETURNING
        VALUE(result) TYPE string.

  PROTECTED SECTION.

    METHODS get_default_config
      RETURNING
        VALUE(result) TYPE z2ui5_if_types=>ty_s_http_request_get.

    METHODS main_get_config
      RETURNING
        VALUE(result) TYPE z2ui5_if_types=>ty_s_http_request_get.

    METHODS main_get_index_html
      IMPORTING
        cs_config     TYPE z2ui5_if_types=>ty_s_http_request_get
      RETURNING
        VALUE(result) TYPE string.


  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_core_http_get IMPLEMENTATION.


  METHOD constructor.

    ms_request = val.

  ENDMETHOD.


  METHOD get_default_config.

    DATA(lv_csp)  = `<meta http-equiv="Content-Security-Policy" content="default-src 'self' 'unsafe-inline' 'unsafe-eval' data: ` &&
   `ui5.sap.com *.ui5.sap.com sapui5.hana.ondemand.com *.sapui5.hana.ondemand.com openui5.hana.ondemand.com *.openui5.hana.ondemand.com ` &&
   `sdk.openui5.org *.sdk.openui5.org cdn.jsdelivr.net *.cdn.jsdelivr.net cdnjs.cloudflare.com *.cdnjs.cloudflare.com schemas *.schemas"/>`.

    result = VALUE #(
        t_param = VALUE #(
            (  n = `TITLE`             v = `abap2UI5` )
            )
        t_config = VALUE #(
*            (  n = `src`               v = `https://sdk.openui5.org/1.71.67/resources/sap-ui-core.js` )
            (  n = `src`               v = `https://sdk.openui5.org/resources/sap-ui-cachebuster/sap-ui-core.js` )
*            (  n = `src`               v = `https://sdk.openui5.org/nightly/2/resources/sap-ui-core.js` )
            (  n = `data-sap-ui-theme` v = `sap_horizon` )
            )
        content_security_policy = lv_csp ).

  ENDMETHOD.


  METHOD get_js_cc_startup.

    result = ` ` &&
        z2ui5_cl_cc_timer=>get_js( ) &&
        z2ui5_cl_cc_focus=>get_js( ) &&
        z2ui5_cl_cc_title=>get_js( ) &&
        z2ui5_cl_cc_lp_title=>get_js( ) &&
        z2ui5_cl_cc_history=>get_js( ) &&
        z2ui5_cl_cc_scrolling=>get_js( ) &&
        z2ui5_cl_cc_info=>get_js( ) &&
        z2ui5_cl_cc_geoloc=>get_js( ) &&
        z2ui5_cl_cc_file_upl=>get_js( ) &&
        z2ui5_cl_cc_multiinput=>get_js( ) &&
        z2ui5_cl_cc_uitable=>get_js( ) &&
        z2ui5_cl_cc_util=>get_js( ) &&
        z2ui5_cl_cc_favicon=>get_js( ) &&
        z2ui5_cl_cc_dirty=>get_js( ) &&
*        z2ui5_cl_cc_debug_tool=>get_js( )  &&
       `  `.

  ENDMETHOD.

  METHOD main_get_config.

    result = get_default_config( ).

    LOOP AT ms_request-t_param REFERENCE INTO DATA(lr_param).
      TRY.
          result-t_param[ n = lr_param->n ]-v = lr_param->v.
        CATCH cx_root.
          INSERT lr_param->* INTO TABLE result-t_param.
      ENDTRY.
    ENDLOOP.

    LOOP AT ms_request-t_config REFERENCE INTO DATA(lr_option).
      TRY.
          result-t_config[ n = lr_option->n ]-v = lr_option->v.
        CATCH cx_root.
          INSERT lr_option->* INTO TABLE result-t_config.
      ENDTRY.
    ENDLOOP.

    IF ms_request-content_security_policy IS NOT INITIAL.
      result-content_security_policy = ms_request-content_security_policy.
    ENDIF.

    IF ms_request-custom_js IS NOT INITIAL.
      result-custom_js = ms_request-custom_js.
    ENDIF.

  ENDMETHOD.


  METHOD main_get_index_html.


    DATA(lv_add_js) = get_js_cc_startup( ) && cs_config-custom_js.

    result = `<!DOCTYPE html>` && |\n| &&
               `<html lang="en">` && |\n| &&
               `<head>` && |\n| &&
                  cs_config-content_security_policy && |\n| &&
               `    <meta charset="UTF-8">` && |\n| &&
               `    <meta name="viewport" content="width=device-width, initial-scale=1.0">` && |\n| &&
               `    <meta http-equiv="X-UA-Compatible" content="IE=edge">` && |\n| &&
                | <title> { cs_config-t_param[ n = 'TITLE' ]-v }</title> \n| &&
                | <style>        html, body, body > div, #container, #container-uiarea \{\n| &
                |            height: 100%;\n| &
                |        \}</style> \n| &&
                `<script>` && |\n| &&
             `  function onInitComponent(){` && |\n| &&
             `    sap.ui.require.preload({` && |\n| &&
             `      "z2ui5/manifest.json": '` && NEW z2ui5_cl_core_ui5_app( )->manifest_json( ) && ` ',` && |\n| &&
             `      "z2ui5/Component.js": function(){` && NEW z2ui5_cl_core_ui5_app( )->component_js( ) && lv_add_js && ` },` && |\n| &&
             `      "z2ui5/css/style.css": function(){` && NEW z2ui5_cl_core_ui5_app( )->css_style_css( ) && `},` && |\n| &&
             `      "z2ui5/model/models.js": function(){` && NEW z2ui5_cl_core_ui5_app( )->model_models_js( ) && `},` && |\n| &&
             `      "z2ui5/i18n/i18n.properties": '` && NEW z2ui5_cl_core_ui5_app( )->i18n_i18n_properties( ) && `' ,` && |\n| &&
             `      "z2ui5/view/App.view.xml": '` && NEW z2ui5_cl_core_ui5_app( )->view_app_xml( )  && `' ,` && |\n| &&
             `      "z2ui5/controller/App.controller.js": function(){` && NEW z2ui5_cl_core_ui5_app( )->controller_app_js( ) && `},` && |\n| &&
             `      "z2ui5/view/View1.view.xml": '` && NEW z2ui5_cl_core_ui5_app( )->view_view1_xml( )  && `' ,` && |\n| &&
             `      "z2ui5/controller/View1.controller.js": function(){` && NEW z2ui5_cl_core_ui5_app( )->controller_view1_js( ) && `},` && |\n| &&
             `      "z2ui5/cc/DebugTool.fragment.xml": '` && z2ui5_cl_cc_debug_tool=>get_xml( )  && `' ,` && |\n| &&
             `      "z2ui5/cc/DebugTool.js": function(){` && z2ui5_cl_cc_debug_tool=>get_js( ) && `},` && |\n| &&
             `    });` && |\n| &&
             `    sap.ui.require(["sap/ui/core/ComponentSupport"], function(ComponentSupport){` && |\n| &&
             `      ComponentSupport.run();` && |\n| &&
             `    });` && |\n| &&
             `  }` && |\n| &&
             `</script>` && |\n| &&
                `<script id="sap-ui-bootstrap" data-sap-ui-resourceroots='{ "z2ui5": "./" }' data-sap-ui-oninit="onInitComponent" ` && |\n| &&
                 `data-sap-ui-compatVersion="edge" data-sap-ui-async="true" data-sap-ui-frameOptions="trusted" data-sap-ui-bindingSyntax="complex"`.

    LOOP AT cs_config-t_config REFERENCE INTO DATA(lr_config).
      result = result && | { lr_config->n }='{ lr_config->v }'|.
    ENDLOOP.

    result = result &&
        ` ></script></head>` && |\n| &&
        `<body class="sapUiBody sapUiSizeCompact" id="content">` && |\n| &&
        `    <div data-sap-ui-component data-name="z2ui5" data-id="container" data-settings='{"id" : "z2ui5"}' data-handle-validation="true"></div>` && |\n| &&
        ` </body></html>`.

  ENDMETHOD.


  METHOD main.

    DATA(ls_config) = main_get_config( ).
    result = main_get_index_html( ls_config ).
    NEW z2ui5_cl_core_draft_srv( )->cleanup( ).

  ENDMETHOD.

ENDCLASS.
