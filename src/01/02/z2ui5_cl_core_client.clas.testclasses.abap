CLASS ltcl_test_client DEFINITION FINAL FOR TESTING
  DURATION LONG
  RISK LEVEL DANGEROUS.

  PRIVATE SECTION.
    METHODS first_test FOR TESTING RAISING cx_static_check.
ENDCLASS.

CLASS z2ui5_cl_core_client DEFINITION LOCAL FRIENDS ltcl_test_client.

CLASS ltcl_test_client IMPLEMENTATION.

  METHOD first_test.

*    DATA(lo_http) = NEW z2ui5_cl_fw_http_post( `` ).
*    DATA(lo_app) = NEW z2ui5_cl_fw_controller( lo_http ).
*    DATA(lo_client) = NEW z2ui5_cl_fw_client( lo_app ) ##NEEDED.

  ENDMETHOD.

ENDCLASS.
