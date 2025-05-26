CLASS ltcl_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS first_test FOR TESTING RAISING cx_static_check.
ENDCLASS.

CLASS z2ui5_cl_core_action DEFINITION LOCAL FRIENDS ltcl_test.

CLASS ltcl_test IMPLEMENTATION.
  METHOD first_test.

    DATA lo_http TYPE REF TO z2ui5_cl_core_handler.
    DATA lo_action TYPE REF TO z2ui5_cl_core_action.
    CREATE OBJECT lo_http TYPE z2ui5_cl_core_handler EXPORTING VAL = ``.
    
    CREATE OBJECT lo_action TYPE z2ui5_cl_core_action EXPORTING VAL = lo_http.

  ENDMETHOD.
ENDCLASS.
