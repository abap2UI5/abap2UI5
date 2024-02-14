CLASS ltcl_test DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    METHODS
      first_test FOR TESTING RAISING cx_static_check.
ENDCLASS.

CLASS z2ui5_cl_core_action DEFINITION LOCAL FRIENDS ltcl_test.

CLASS ltcl_test IMPLEMENTATION.

  METHOD first_test.

    DATA(lo_http) = NEW z2ui5_cl_core_http_post( `` ).
    DATA(lo_action) = NEW z2ui5_cl_core_action( lo_http ) ##NEEDED.

  ENDMETHOD.

ENDCLASS.
