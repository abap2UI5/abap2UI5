* =====================================================================
* GENERATED FILE - DO NOT EDIT (AGENTS.md rule 2)
* Embedded frontend resource, generated from app/webapp/ by
* .github/app2abap/trans2abap.js. Change the source under app/webapp/
* and run 'npm run app2abap' to regenerate; the check_app2abap CI gate
* fails any manual edit here.
* =====================================================================
CLASS z2ui5_cl_ui5f_preload DEFINITION
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


CLASS z2ui5_cl_ui5f_preload IMPLEMENTATION.

  METHOD get.

    result = |      "z2ui5/cc/CameraPicture.js": function()\{{ z2ui5_cl_ui5f_campic_js=>get( ) }\},| && |\n| &&
             |      "z2ui5/cc/CameraSelector.js": function()\{{ z2ui5_cl_ui5f_camsel_js=>get( ) }\},| && |\n| &&
             |      "z2ui5/cc/Dirty.js": function()\{{ z2ui5_cl_ui5f_dirty_js=>get( ) }\},| && |\n| &&
             |      "z2ui5/cc/Favicon.js": function()\{{ z2ui5_cl_ui5f_favicon_js=>get( ) }\},| && |\n| &&
             |      "z2ui5/cc/FileUploader.js": function()\{{ z2ui5_cl_ui5f_uploader_js=>get( ) }\},| && |\n| &&
             |      "z2ui5/cc/Focus.js": function()\{{ z2ui5_cl_ui5f_focus_js=>get( ) }\},| && |\n| &&
             |      "z2ui5/cc/Geolocation.js": function()\{{ z2ui5_cl_ui5f_geoloc_js=>get( ) }\},| && |\n| &&
             |      "z2ui5/cc/History.js": function()\{{ z2ui5_cl_ui5f_history_js=>get( ) }\},| && |\n| &&
             |      "z2ui5/cc/Info.js": function()\{{ z2ui5_cl_ui5f_info_js=>get( ) }\},| && |\n| &&
             |      "z2ui5/cc/LPTitle.js": function()\{{ z2ui5_cl_ui5f_lptitle_js=>get( ) }\},| && |\n| &&
             |      "z2ui5/cc/MessageManager.js": function()\{{ z2ui5_cl_ui5f_msgmgr_js=>get( ) }\},| && |\n| &&
             |      "z2ui5/cc/MultiInputExt.js": function()\{{ z2ui5_cl_ui5f_multiinp_js=>get( ) }\},| && |\n| &&
             |      "z2ui5/cc/Scrolling.js": function()\{{ z2ui5_cl_ui5f_scroll_js=>get( ) }\},| && |\n| &&
             |      "z2ui5/cc/SmartMultiInputExt.js": function()\{{ z2ui5_cl_ui5f_smartinp_js=>get( ) }\},| && |\n| &&
             |      "z2ui5/cc/Storage.js": function()\{{ z2ui5_cl_ui5f_storage_js=>get( ) }\},| && |\n| &&
             |      "z2ui5/cc/Timer.js": function()\{{ z2ui5_cl_ui5f_timer_js=>get( ) }\},| && |\n| &&
             |      "z2ui5/cc/Title.js": function()\{{ z2ui5_cl_ui5f_title_js=>get( ) }\},| && |\n| &&
             |      "z2ui5/cc/Tree.js": function()\{{ z2ui5_cl_ui5f_tree_js=>get( ) }\},| && |\n| &&
             |      "z2ui5/cc/UITableExt.js": function()\{{ z2ui5_cl_ui5f_uitable_js=>get( ) }\},| && |\n| &&
             |      "z2ui5/cc/UploadSetExt.js": function()\{{ z2ui5_cl_ui5f_upldset_js=>get( ) }\},| && |\n| &&
             |      "z2ui5/cc/Websocket.js": function()\{{ z2ui5_cl_ui5f_websock_js=>get( ) }\},| && |\n| &&
             |      "z2ui5/Component.js": function()\{{ z2ui5_cl_ui5f_comp_js=>get( ) }{ custom_js }\},| && |\n| &&
             |      "z2ui5/controller/App.controller.js": function()\{{ z2ui5_cl_ui5f_app_js=>get( ) }\},| && |\n| &&
             |      "z2ui5/controller/View1.controller.js": function()\{{ z2ui5_cl_ui5f_view1_js=>get( ) }\},| && |\n| &&
             |      "z2ui5/core/actions/Browser.js": function()\{{ z2ui5_cl_ui5f_browser_js=>get( ) }\},| && |\n| &&
             |      "z2ui5/core/actions/ControlCall.js": function()\{{ z2ui5_cl_ui5f_ctrlcall_js=>get( ) }\},| && |\n| &&
             |      "z2ui5/core/actions/Launchpad.js": function()\{{ z2ui5_cl_ui5f_launchpd_js=>get( ) }\},| && |\n| &&
             |      "z2ui5/core/actions/LegacyCustomJs.js": function()\{{ z2ui5_cl_ui5f_legacy_js=>get( ) }\},| && |\n| &&
             |      "z2ui5/core/actions/Shortcuts.js": function()\{{ z2ui5_cl_ui5f_shortcut_js=>get( ) }\},| && |\n| &&
             |      "z2ui5/core/actions/Slots.js": function()\{{ z2ui5_cl_ui5f_slots_js=>get( ) }\},| && |\n| &&
             |      "z2ui5/core/actions/Variants.js": function()\{{ z2ui5_cl_ui5f_variants_js=>get( ) }\},| && |\n| &&
             |      "z2ui5/core/actions/ViewOps.js": function()\{{ z2ui5_cl_ui5f_viewops_js=>get( ) }\},| && |\n| &&
             |      "z2ui5/core/AppState.js": function()\{{ z2ui5_cl_ui5f_appstate_js=>get( ) }\},| && |\n| &&
             |      "z2ui5/core/DeveloperTools.fragment.xml": '{ z2ui5_cl_ui5f_dtools_xml=>get( ) }',| && |\n| &&
             |      "z2ui5/core/DeveloperTools.js": function()\{{ z2ui5_cl_ui5f_dtools_js=>get( ) }\},| && |\n| &&
             |      "z2ui5/core/ErrorView.js": function()\{{ z2ui5_cl_ui5f_errview_js=>get( ) }\},| && |\n| &&
             |      "z2ui5/core/FrontendAction.js": function()\{{ z2ui5_cl_ui5f_frontact_js=>get( ) }\},| && |\n| &&
             |      "z2ui5/core/Lib.js": function()\{{ z2ui5_cl_ui5f_lib_js=>get( ) }\},| && |\n| &&
             |      "z2ui5/core/Router.js": function()\{{ z2ui5_cl_ui5f_router_js=>get( ) }\},| && |\n| &&
             |      "z2ui5/core/ScrollFocus.js": function()\{{ z2ui5_cl_ui5f_scrfocus_js=>get( ) }\},| && |\n| &&
             |      "z2ui5/core/Server.js": function()\{{ z2ui5_cl_ui5f_server_js=>get( ) }\},| && |\n| &&
             |      "z2ui5/core/Session.js": function()\{{ z2ui5_cl_ui5f_session_js=>get( ) }\},| && |\n| &&
             |      "z2ui5/core/ViewSlots.js": function()\{{ z2ui5_cl_ui5f_viewslot_js=>get( ) }\},| && |\n| &&
             |      "z2ui5/css/style.css": '{ styles_css }',| && |\n| &&
             |      "z2ui5/manifest.json": '{ z2ui5_cl_ui5f_manifest=>get( ) }',| && |\n| &&
             |      "z2ui5/model/formatter.js": function()\{{ z2ui5_cl_ui5f_format_js=>get( ) }\},| && |\n| &&
             |      "z2ui5/model/models.js": function()\{{ z2ui5_cl_ui5f_models_js=>get( ) }\},| && |\n| &&
             |      "z2ui5/Util.js": function()\{{ z2ui5_cl_ui5f_util_js=>get( ) }\},| && |\n| &&
             |      "z2ui5/view/App.view.xml": '{ z2ui5_cl_ui5f_app_xml=>get( ) }',| && |\n|.

  ENDMETHOD.

ENDCLASS.
