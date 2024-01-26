CLASS ltcl_unit_test DEFINITION FINAL FOR TESTING
  DURATION long
  RISK LEVEL DANGEROUS.

  PRIVATE SECTION.
    METHODS first_test FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_unit_test IMPLEMENTATION.

  METHOD first_test.

    DATA(lo_handler) = NEW z2ui5_cl_fw_controller( ).
    DATA(lo_client) = NEW z2ui5_cl_fw_client( lo_handler ).

    DATA(li_client) = CAST z2ui5_if_client( lo_client ) ##NEEDED.

  ENDMETHOD.

ENDCLASS.
