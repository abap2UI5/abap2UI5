CLASS ltcl_test_http_get DEFINITION FINAL FOR TESTING
  DURATION MEDIUM
  RISK LEVEL HARMLESS.

  PUBLIC SECTION.
  PROTECTED SECTION.

  PRIVATE SECTION.
    METHODS file_not_initial FOR TESTING RAISING cx_static_check.
    METHODS launchpad_compatibility FOR TESTING RAISING cx_static_check.
    METHODS path_setup FOR TESTING RAISING cx_static_check.
    METHODS js_no_debugger FOR TESTING RAISING cx_static_check.
    METHODS js_no_sap_ui_get_core FOR TESTING RAISING cx_static_check.
    METHODS js_no_window FOR TESTING RAISING cx_static_check.
    METHODS js_no_document FOR TESTING RAISING cx_static_check.
    METHODS bootstrap_with_open_ui5 FOR TESTING RAISING cx_static_check.
    METHODS js_no_jquery FOR TESTING RAISING cx_static_check.
ENDCLASS.

CLASS z2ui5_cl_core_http_get DEFINITION LOCAL FRIENDS ltcl_test_http_get.

CLASS ltcl_test_http_get IMPLEMENTATION.

  METHOD file_not_initial.

    DATA(lo_get) = NEW z2ui5_cl_core_http_get( ).
    DATA(lv_index_html) = lo_get->main( ).
    IF lv_index_html IS INITIAL.
      cl_abap_unit_assert=>fail( 'HTTP GET - index html initial' ).
    ENDIF.

  ENDMETHOD.


  METHOD launchpad_compatibility.

    DATA(lo_get) = NEW z2ui5_cl_core_http_get( ).
    DATA(lv_index_html) = lo_get->main( ).
    IF lv_index_html CS `&`.
      cl_abap_unit_assert=>fail( 'index.html contains the character & -> no launchpad compatibility' ).
    ENDIF.

  ENDMETHOD.


  METHOD path_setup.

    DATA(lo_get) = NEW z2ui5_cl_core_http_get( ).
    DATA(lv_index_html) = to_upper( lo_get->main( ) ).
    IF lv_index_html CS `SAP.Z2UI5.PATHNAME || '/SAP/TEST';`.
      cl_abap_unit_assert=>fail( 'path static' ).
    ENDIF.

    IF lv_index_html NS `SAP.Z2UI5.PATHNAME ||  WINDOW.LOCATION.PATHNAME;`.
      cl_abap_unit_assert=>fail( 'path static' ).
    ENDIF.

  ENDMETHOD.

  METHOD js_no_debugger.

    DATA(lo_get) = NEW z2ui5_cl_core_http_get( ).
    DATA(lv_index_html) = to_upper( lo_get->main( ) ).
    IF lv_index_html CS `DEBUGGER`.
      cl_abap_unit_assert=>fail( 'debugger command not allowed' ).
    ENDIF.

  ENDMETHOD.

  METHOD js_no_sap_ui_get_core.

    DATA(lo_get) = NEW z2ui5_cl_core_http_get( ).
    DATA(lv_index_html) = to_upper( lo_get->main( ) ) ##NEEDED.
    IF lv_index_html CS `SAP.UI.GETCORE`.
      cl_abap_unit_assert=>fail( 'sap.ui.get.core not allowed' ).
    ENDIF.

  ENDMETHOD.

  METHOD js_no_jquery.

    DATA(lo_get) = NEW z2ui5_cl_core_http_get( ).
    DATA(lv_index_html) = to_upper( lo_get->main( ) ).
    IF lv_index_html CS `JQUERY`.
      cl_abap_unit_assert=>fail( 'use of jquery not allowed' ).
    ENDIF.

  ENDMETHOD.

  METHOD js_no_window.

    DATA(lo_get) = NEW z2ui5_cl_core_http_get( ).
    DATA(lv_index_html) = to_upper( lo_get->main( ) ) ##NEEDED.
*    IF lv_index_html CS `WINDOW.`.
*      cl_abap_unit_assert=>fail( 'use of window not allowed' ).
*    ENDIF.

  ENDMETHOD.

  METHOD js_no_document.

    DATA(lo_get) = NEW z2ui5_cl_core_http_get( ).
    DATA(lv_index_html) = to_upper( lo_get->main( ) ) ##NEEDED.
*    IF lv_index_html CS `DOCUMENT.`.
*      cl_abap_unit_assert=>fail( 'use of document not allowed' ).
*    ENDIF.

  ENDMETHOD.

  METHOD bootstrap_with_open_ui5.

    DATA(lo_get) = NEW z2ui5_cl_core_http_get( ).
    DATA(lv_index_html) = to_upper( lo_get->main( ) ) ##NEEDED.
    DATA(lv_check) = xsdbool( lv_index_html CS `HTTPS://SDK.OPENUI5.ORG/RESOURCES` ).
    IF lv_check = abap_false.
      cl_abap_unit_assert=>fail( 'no bootstrap with openUI5' ).
    ENDIF.

    lv_check = xsdbool( lv_index_html CS `NIGHTLY` ).
    IF lv_check = abap_true.
      cl_abap_unit_assert=>fail( 'no bootstrap with nightly version' ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.
