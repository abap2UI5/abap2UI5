CLASS ltcl_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION LONG.

  PUBLIC SECTION.

    METHODS constructor.
    METHODS test_create FOR TESTING.

  PROTECTED SECTION.

  PRIVATE SECTION.
ENDCLASS.


CLASS ltcl_test IMPLEMENTATION.
  METHOD constructor.

  ENDMETHOD.

  METHOD test_create.

    DATA lo_draft TYPE REF TO z2ui5_cl_core_srv_draft.
    DATA temp2 TYPE z2ui5_if_types=>ty_s_draft.
    DATA ls_db TYPE z2ui5_t_01.
    CREATE OBJECT lo_draft TYPE z2ui5_cl_core_srv_draft.

    
    CLEAR temp2.
    temp2-id = `TEST_ID`.
    lo_draft->create( draft     = temp2
                      model_xml = `my xml`
      ).

    
    ls_db = lo_draft->read_draft( `TEST_ID` ).

    cl_abap_unit_assert=>assert_equals( exp = `my xml`
                                        act = ls_db-data ).

  ENDMETHOD.
ENDCLASS.
