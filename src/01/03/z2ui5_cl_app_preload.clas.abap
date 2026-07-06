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

    result = |      "z2ui5/cc/CameraPicture.js": function()\{{ z2ui5_cl_app_camerapicture_js=>get( ) }\},| && |\n| &&
             |      "z2ui5/cc/CameraSelector.js": function()\{{ z2ui5_cl_app_cameraselector_js=>get( ) }\},| && |\n| &&
             |      "z2ui5/cc/Dirty.js": function()\{{ z2ui5_cl_app_dirty_js=>get( ) }\},| && |\n| &&
             |      "z2ui5/cc/Favicon.js": function()\{{ z2ui5_cl_app_favicon_js=>get( ) }\},| && |\n| &&
             |      "z2ui5/cc/FileUploader.js": function()\{{ z2ui5_cl_app_fileuploader_js=>get( ) }\},| && |\n| &&
             |      "z2ui5/cc/Focus.js": function()\{{ z2ui5_cl_app_focus_js=>get( ) }\},| && |\n| &&
             |      "z2ui5/cc/Geolocation.js": function()\{{ z2ui5_cl_app_geolocation_js=>get( ) }\},| && |\n| &&
             |      "z2ui5/cc/History.js": function()\{{ z2ui5_cl_app_history_js=>get( ) }\},| && |\n| &&
             |      "z2ui5/cc/Info.js": function()\{{ z2ui5_cl_app_info_js=>get( ) }\},| && |\n| &&
             |      "z2ui5/cc/LPTitle.js": function()\{{ z2ui5_cl_app_lptitle_js=>get( ) }\},| && |\n| &&
             |      "z2ui5/cc/MultiInputExt.js": function()\{{ z2ui5_cl_app_multiinputext_js=>get( ) }\},| && |\n| &&
             |      "z2ui5/cc/Scrolling.js": function()\{{ z2ui5_cl_app_scrolling_js=>get( ) }\},| && |\n| &&
             |      "z2ui5/cc/SmartMultiInputExt.js": function()\{{ z2ui5_cl_app_smartmultiinpu_js=>get( ) }\},| && |\n| &&
             |      "z2ui5/cc/Storage.js": function()\{{ z2ui5_cl_app_storage_js=>get( ) }\},| && |\n| &&
             |      "z2ui5/cc/Timer.js": function()\{{ z2ui5_cl_app_timer_js=>get( ) }\},| && |\n| &&
             |      "z2ui5/cc/Title.js": function()\{{ z2ui5_cl_app_title_js=>get( ) }\},| && |\n| &&
             |      "z2ui5/cc/Tree.js": function()\{{ z2ui5_cl_app_tree_js=>get( ) }\},| && |\n| &&
             |      "z2ui5/cc/UITableExt.js": function()\{{ z2ui5_cl_app_uitableext_js=>get( ) }\},| && |\n| &&
             |      "z2ui5/cc/UploadSetExt.js": function()\{{ z2ui5_cl_app_uploadsetext_js=>get( ) }\},| && |\n| &&
             |      "z2ui5/Component.js": function()\{{ z2ui5_cl_app_component_js=>get( ) }{ custom_js }\},| && |\n| &&
             |      "z2ui5/controller/App.controller.js": function()\{{ z2ui5_cl_app_app_js=>get( ) }\},| && |\n| &&
             |      "z2ui5/controller/View1.controller.js": function()\{{ z2ui5_cl_app_view1_js=>get( ) }\},| && |\n| &&
             |      "z2ui5/core/AppState.js": function()\{{ z2ui5_cl_app_appstate_js=>get( ) }\},| && |\n| &&
             |      "z2ui5/core/DebugTool.fragment.xml": '{ z2ui5_cl_app_debugtool_xml=>get( ) }',| && |\n| &&
             |      "z2ui5/core/DebugTool.js": function()\{{ z2ui5_cl_app_debugtool_js=>get( ) }\},| && |\n| &&
             |      "z2ui5/core/ErrorView.js": function()\{{ z2ui5_cl_app_errorview_js=>get( ) }\},| && |\n| &&
             |      "z2ui5/core/FrontendAction.js": function()\{{ z2ui5_cl_app_frontendaction_js=>get( ) }\},| && |\n| &&
             |      "z2ui5/core/Lib.js": function()\{{ z2ui5_cl_app_lib_js=>get( ) }\},| && |\n| &&
             |      "z2ui5/core/Messages.js": function()\{{ z2ui5_cl_app_messages_js=>get( ) }\},| && |\n| &&
             |      "z2ui5/core/Server.js": function()\{{ z2ui5_cl_app_server_js=>get( ) }\},| && |\n| &&
             |      "z2ui5/core/ViewSlots.js": function()\{{ z2ui5_cl_app_viewslots_js=>get( ) }\},| && |\n| &&
             |      "z2ui5/css/style.css": '{ styles_css }',| && |\n| &&
             |      "z2ui5/manifest.json": '{ z2ui5_cl_app_manifest_json=>get( ) }',| && |\n| &&
             |      "z2ui5/model/models.js": function()\{{ z2ui5_cl_app_models_js=>get( ) }\},| && |\n| &&
             |      "z2ui5/Util.js": function()\{{ z2ui5_cl_app_util_js=>get( ) }\},| && |\n| &&
             |      "z2ui5/view/App.view.xml": '{ z2ui5_cl_app_app_xml=>get( ) }',| && |\n|.

  ENDMETHOD.

ENDCLASS.
