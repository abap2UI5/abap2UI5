CLASS ltcl_unit_test DEFINITION FINAL FOR TESTING
  DURATION LONG
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    METHODS test_req_begin_fw_start FOR TESTING RAISING cx_static_check.
    METHODS test_req_begin_app_start FOR TESTING RAISING cx_static_check.
    METHODS test_req_end FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_unit_test IMPLEMENTATION.

  METHOD test_req_begin_fw_start.

    DATA(lv_body) = `{"OLOCATION":{"ORIGIN":"https:/url.abap-web.us10.hana.ondemand.com","PATHNAME":"/sap/bc/http/sap/z_http_service_for_ui","SEARCH":"?sap-client=100","VERSION":"com.sap.ui5.dist:sapui5-sdk-dist:1.115.0:war"}}`.

    DATA(lo_handler) = z2ui5_cl_fw_controller=>request_begin( lv_body ).

    cl_abap_unit_assert=>assert_bound( lo_handler->ms_db-app ).

    DATA(lo_app_fw) = CAST z2ui5_cl_fw_app_startup( lo_handler->ms_db-app ) ##NEEDED.

  ENDMETHOD.

  METHOD test_req_begin_app_start.

    DATA(lv_body) = `{"OLOCATION":{"ORIGIN":"https://url.abap-web.us10.hana.ondemand.com","PATHNAME":"/sap/bc/http/sap/z_http_service_for_ui","SEARCH":"?sap-client=100&app_start=z2ui5_cl_app_hello_world","VERSION":"c` &&
      `om.sap.ui5.dist:sapui5-sdk-dist:1.115.0:war"}}`.

    DATA(lo_handler) = z2ui5_cl_fw_controller=>request_begin( lv_body ).

    cl_abap_unit_assert=>assert_bound( lo_handler->ms_db-app ).

    DATA(lo_app_fw) = CAST z2ui5_cl_app_hello_world( lo_handler->ms_db-app ) ##NEEDED.

  ENDMETHOD.


  METHOD test_req_end.

    DATA(lv_body) = `{"OLOCATION":{"ORIGIN":"https://url.abap-web.us10.hana.ondemand.com","PATHNAME":"/sap/bc/http/sap/z_http_service_for_ui","SEARCH":"?sap-client=100&app_start=z2ui5_cl_app_hello_world","VERSION":"c` &&
          `om.sap.ui5.dist:sapui5-sdk-dist:1.115.0:war"}}`.

    DATA(lo_handler) = z2ui5_cl_fw_controller=>request_begin( lv_body ).

    CAST z2ui5_if_app( lo_handler->ms_db-app )->main( NEW z2ui5_cl_fw_client( lo_handler ) ).


    DATA(lv_resp) = lo_handler->request_end( ).

    IF lv_resp NS `QUANTITY`.
      cl_abap_unit_assert=>fail( ).
    ENDIF.

    IF lv_resp NS `EDIT`.
      cl_abap_unit_assert=>fail( ).
    ENDIF.

    IF lv_resp NS `ID`.
      cl_abap_unit_assert=>fail( ).
    ENDIF.

    IF lv_resp NS `mvc:View`.
      cl_abap_unit_assert=>fail( ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.
