CLASS ltcl_unit_test DEFINITION FINAL FOR TESTING
  DURATION MEDIUM
  RISK LEVEL HARMLESS.

  PUBLIC SECTION.
  PROTECTED SECTION.

  PRIVATE SECTION.
    METHODS test_index_html FOR TESTING RAISING cx_static_check.
    METHODS test_launchpad_compatibility FOR TESTING RAISING cx_static_check.
    METHODS test_path FOR TESTING RAISING cx_static_check.
    METHODS test_avoid_debugger FOR TESTING RAISING cx_static_check.
    METHODS test_avoid_sap_ui_get_core FOR TESTING RAISING cx_static_check.
    METHODS test_avoid_window FOR TESTING RAISING cx_static_check.
    METHODS test_avoid_document FOR TESTING RAISING cx_static_check.
    METHODS test_avoid_jquery FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_unit_test IMPLEMENTATION.

  METHOD test_index_html.

    DATA(lo_get) = NEW z2ui5_cl_fw_http_get( ).
    DATA(lv_index_html) = lo_get->main( ).
    IF lv_index_html IS INITIAL.
      cl_abap_unit_assert=>fail( 'HTTP GET - index html initial' ).
    ENDIF.

  ENDMETHOD.


  METHOD test_launchpad_compatibility.

    DATA(lo_get) = NEW z2ui5_cl_fw_http_get( ).
    DATA(lv_index_html) = lo_get->main( ).
    IF lv_index_html CS `&`.
      cl_abap_unit_assert=>fail( 'index.html contains the character & -> no launchpad compatibility' ).
    ENDIF.

  ENDMETHOD.


  METHOD test_path.

    DATA(lo_get) = NEW z2ui5_cl_fw_http_get( ).
    DATA(lv_index_html) = to_upper( lo_get->main( ) ).
    IF lv_index_html CS `SAP.Z2UI5.PATHNAME || '/SAP/TEST';`.
      cl_abap_unit_assert=>fail( 'path static' ).
    ENDIF.

    IF lv_index_html NS `SAP.Z2UI5.PATHNAME ||  WINDOW.LOCATION.PATHNAME;`.
      cl_abap_unit_assert=>fail( 'path static' ).
    ENDIF.

  ENDMETHOD.

  METHOD test_avoid_debugger.

    DATA(lo_get) = NEW z2ui5_cl_fw_http_get( ).
    DATA(lv_index_html) = to_upper( lo_get->main( ) ).
    IF lv_index_html CS `DEBUGGER`.
      cl_abap_unit_assert=>fail( 'debugger command not allowed' ).
    ENDIF.

  ENDMETHOD.

  METHOD test_avoid_sap_ui_get_core.

    DATA(lo_get) = NEW z2ui5_cl_fw_http_get( ).
    DATA(lv_index_html) = to_upper( lo_get->main( ) ) ##NEEDED.
*    IF lv_index_html CS `SAP.UI.GETCORE`.
*      cl_abap_unit_assert=>fail( 'sap.ui.get.core not allowed' ).
*    ENDIF.

  ENDMETHOD.

  METHOD test_avoid_jquery.

    DATA(lo_get) = NEW z2ui5_cl_fw_http_get( ).
    DATA(lv_index_html) = to_upper( lo_get->main( ) ).
    IF lv_index_html CS `JQUERY`.
      cl_abap_unit_assert=>fail( 'use of jquery not allowed' ).
    ENDIF.

  ENDMETHOD.

  METHOD test_avoid_window.

    DATA(lo_get) = NEW z2ui5_cl_fw_http_get( ).
    DATA(lv_index_html) = to_upper( lo_get->main( ) ) ##NEEDED.
*    IF lv_index_html CS `WINDOW.`.
*      cl_abap_unit_assert=>fail( 'use of window not allowed' ).
*    ENDIF.

  ENDMETHOD.

  METHOD test_avoid_document.

    DATA(lo_get) = NEW z2ui5_cl_fw_http_get( ).
    DATA(lv_index_html) = to_upper( lo_get->main( ) ) ##NEEDED.
*    IF lv_index_html CS `DOCUMENT.`.
*      cl_abap_unit_assert=>fail( 'use of document not allowed' ).
*    ENDIF.

  ENDMETHOD.

ENDCLASS.
