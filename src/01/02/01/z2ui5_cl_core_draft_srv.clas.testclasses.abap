CLASS ltcl_test DEFINITION FINAL FOR TESTING
  DURATION LONG
  RISK LEVEL HARMLESS.

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

    DATA(lo_draft) = NEW z2ui5_cl_core_draft_srv( ).

    lo_draft->create(
        draft     = VALUE #( id = `TEST_ID` )
        model_xml = `my xml`
    ).

    DATA(ls_db) = lo_draft->read_draft( `TEST_ID`  ).

    cl_abap_unit_assert=>assert_equals(
        act                  = ls_db-data
        exp                  = `my xml`  ).

  ENDMETHOD.

ENDCLASS.
