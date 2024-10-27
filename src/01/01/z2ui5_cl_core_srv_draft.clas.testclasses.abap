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

    DATA(lo_draft) = NEW z2ui5_cl_core_srv_draft( ).

    lo_draft->create( draft     = VALUE #( id = `TEST_ID` )
                      model_xml = `my xml`
    ).

    DATA(ls_db) = lo_draft->read_draft( `TEST_ID` ).

    cl_abap_unit_assert=>assert_equals( exp = `my xml`
                                        act = ls_db-data ).

  ENDMETHOD.
ENDCLASS.
