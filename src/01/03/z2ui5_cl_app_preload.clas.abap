CLASS z2ui5_cl_app_preload DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CLASS-METHODS get
      IMPORTING
        styles_css    TYPE string
        custom_js     TYPE string
      RETURNING
        VALUE(result) TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS z2ui5_cl_app_preload IMPLEMENTATION.

  METHOD get.

    result = |      "z2ui5/cc/DebugTool.fragment.xml": '{ z2ui5_cl_app_debugtool_xml=>get( ) }',| && |\n| &&
             |      "z2ui5/cc/DebugTool.js": function()\{{ z2ui5_cl_app_debugtool_js=>get( ) }\},| && |\n| &&
             |      "z2ui5/cc/Lib.js": function()\{{ z2ui5_cl_app_lib_js=>get( ) }\},| && |\n| &&
             |      "z2ui5/cc/Server.js": function()\{{ z2ui5_cl_app_server_js=>get( ) }\},| && |\n| &&
             |      "z2ui5/Component.js": function()\{{ z2ui5_cl_app_component_js=>get( ) }{ custom_js }\},| && |\n| &&
             |      "z2ui5/controller/App.controller.js": function()\{{ z2ui5_cl_app_app_js=>get( ) }\},| && |\n| &&
             |      "z2ui5/controller/View1.controller.js": function()\{{ z2ui5_cl_app_view1_js=>get( ) }\},| && |\n| &&
             |      "z2ui5/css/style.css": '{ styles_css }',| && |\n| &&
             |      "z2ui5/manifest.json": '{ z2ui5_cl_app_manifest_json=>get( ) }',| && |\n| &&
             |      "z2ui5/model/models.js": function()\{{ z2ui5_cl_app_models_js=>get( ) }\},| && |\n| &&
             |      "z2ui5/view/App.view.xml": '{ z2ui5_cl_app_app_xml=>get( ) }',| && |\n| &&
             |      "z2ui5/view/View1.view.xml": '{ z2ui5_cl_app_view1_xml=>get( ) }',| && |\n|.

  ENDMETHOD.

ENDCLASS.
