CLASS z2ui5_cl_ui5_index_html DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CLASS-METHODS get
      IMPORTING
        is_config     TYPE z2ui5_if_types=>ty_s_http_config
      RETURNING
        VALUE(result) TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_ui5_index_html IMPLEMENTATION.

  METHOD get.

    IF is_config-styles_css IS INITIAL.
      DATA(lv_style_css) = z2ui5_cl_ui5_style_css=>get( ).
    ELSE.
      lv_style_css = is_config-styles_css.
    ENDIF.

    result = `<!DOCTYPE html>` && |\n| &&
               `<html lang="en">` && |\n| &&
               `<head>` && |\n| &&
                  is_config-content_security_policy && |\n| &&
               `    <meta charset="UTF-8">` && |\n| &&
               `    <meta name="viewport" content="width=device-width, initial-scale=1.0">` && |\n| &&
               `    <meta http-equiv="X-UA-Compatible" content="IE=edge">` && |\n| &&
                | <title> { is_config-title }</title> \n| &&
                | <style>        html, body, body > div, #container, #container-uiarea \{\n| &
                |            height: 100%;\n| &
                |        \}</style> \n| &&
                `<script>` && |\n| &&
             `  function onInitComponent(){` && |\n| &&
             `    sap.ui.require.preload({` && |\n| &&
             `      "z2ui5/manifest.json": '` && z2ui5_cl_ui5_manifest_json=>get( ) && ` ',` && |\n| &&
             `      "z2ui5/Component.js": function(){` &&  z2ui5_cl_ui5_component_js=>get( ) && is_config-custom_js && ` },` && |\n| &&
             `      "z2ui5/css/style.css": '` && lv_style_css && `',` && |\n| &&
             `      "z2ui5/model/models.js": function(){` &&  z2ui5_cl_ui5_model_js=>get( ) && `},` && |\n| &&
             `      "z2ui5/view/App.view.xml": '` && z2ui5_cl_ui5_app_xml=>get( ) && `' ,` && |\n| &&
             `      "z2ui5/controller/App.controller.js": function(){` && z2ui5_cl_ui5_app_js=>get( )  && z2ui5_cl_ui5_cc_js=>get( ) && `},` && |\n| &&
             `      "z2ui5/view/View1.view.xml": '` && z2ui5_cl_ui5_view1_xml=>get( )  && `' ,` && |\n| &&
             `      "z2ui5/controller/View1.controller.js": function(){` && z2ui5_cl_ui5_view1_js=>get( ) && `},` && |\n| &&
             `      "z2ui5/cc/Server.js": function(){` && z2ui5_cl_ui5_server_js=>get( )    && `} ,` && |\n| &&
             `      "z2ui5/cc/DebugTool.fragment.xml": '` && z2ui5_cl_ui5_debugtool_xml=>get( )   && `' ,` && |\n| &&
             `      "z2ui5/cc/DebugTool.js": function(){` && z2ui5_cl_ui5_debugtool_js=>get( )  && `},` && |\n| &&
             `    });` && |\n| &&
             `    sap.ui.require(["sap/ui/core/ComponentSupport"], function(ComponentSupport){` && |\n| &&
             `     window.z2ui5 = {}; ComponentSupport.run();` && |\n| &&
             `    });` && |\n| &&
             `  }` && |\n| &&
             `</script>` && |\n| &&
                `<script id="sap-ui-bootstrap" data-sap-ui-resourceroots='{ "z2ui5": "./" }' data-sap-ui-oninit="onInitComponent" ` && |\n| &&
                 `data-sap-ui-compatVersion="edge" data-sap-ui-async="true" data-sap-ui-frameOptions="trusted" data-sap-ui-bindingSyntax="complex"` && |\n| &&
                 `data-sap-ui-theme="` &&  is_config-theme   &&  `" src=" ` && is_config-src && `"   `.

    LOOP AT is_config-t_add_config REFERENCE INTO DATA(lr_config).
      result = result && | { lr_config->n }='{ lr_config->v }'|.
    ENDLOOP.

    result = result &&
        ` ></script></head>` && |\n| &&
        `<body class="sapUiBody sapUiSizeCompact" id="content">` && |\n| &&
        `    <div data-sap-ui-component data-name="z2ui5" data-id="container" data-settings='{"id" : "z2ui5"}' data-handle-validation="true"></div>` && |\n| &&
        ` </body></html>`.

  ENDMETHOD.

ENDCLASS.
