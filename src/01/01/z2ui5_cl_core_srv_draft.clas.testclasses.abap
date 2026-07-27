CLASS ltcl_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION LONG.

  PUBLIC SECTION.

    METHODS constructor.
    METHODS test_create           FOR TESTING.
    METHODS test_create_and_read  FOR TESTING.
    METHODS test_read_info        FOR TESTING.
    METHODS test_buffer           FOR TESTING.
    METHODS test_overwrite        FOR TESTING.
    METHODS test_owner_binding    FOR TESTING.

  PROTECTED SECTION.

  PRIVATE SECTION.
ENDCLASS.


CLASS ltcl_test IMPLEMENTATION.
  METHOD constructor.

  ENDMETHOD.

  METHOD test_create.

    DATA lo_draft TYPE REF TO z2ui5_cl_core_srv_draft.
    DATA temp1 TYPE z2ui5_if_types=>ty_s_draft.
    DATA ls_db TYPE z2ui5_t_01.
    lo_draft = NEW #( ).


    CLEAR temp1.
    temp1-id = `TEST_ID`.
    lo_draft->create( draft     = temp1
                      model_xml = `my xml` ).


    ls_db = lo_draft->read_draft( `TEST_ID` ).

    cl_abap_unit_assert=>assert_equals( exp = `my xml`
                                        act = ls_db-data ).

  ENDMETHOD.

  METHOD test_create_and_read.

    DATA lo_draft TYPE REF TO z2ui5_cl_core_srv_draft.
    DATA temp2 TYPE z2ui5_if_types=>ty_s_draft.
    DATA ls_db TYPE z2ui5_t_01.
    lo_draft = NEW #( ).


    CLEAR temp2.
    temp2-id = `TEST_CR`.
    temp2-id_prev = `PREV1`.
    temp2-id_prev_app = `APP1`.
    temp2-id_prev_app_stack = `STACK1`.
    lo_draft->create( draft     = temp2
                      model_xml = `<xml>data</xml>` ).


    ls_db = lo_draft->read_draft( `TEST_CR` ).

    cl_abap_unit_assert=>assert_equals( exp = `<xml>data</xml>`
                                        act = ls_db-data ).
    cl_abap_unit_assert=>assert_equals( exp = `TEST_CR`
                                        act = ls_db-id ).

  ENDMETHOD.

  METHOD test_read_info.

    DATA lo_draft TYPE REF TO z2ui5_cl_core_srv_draft.
    DATA temp3 TYPE z2ui5_if_types=>ty_s_draft.
    DATA ls_info TYPE z2ui5_if_types=>ty_s_draft.
    lo_draft = NEW #( ).


    CLEAR temp3.
    temp3-id = `TEST_INFO`.
    temp3-id_prev_app_stack = `MY_STACK`.
    lo_draft->create( draft     = temp3
                      model_xml = `info test` ).


    ls_info = lo_draft->read_info( `TEST_INFO` ).

    cl_abap_unit_assert=>assert_equals( exp = `TEST_INFO`
                                        act = ls_info-id ).
    cl_abap_unit_assert=>assert_equals( exp = `MY_STACK`
                                        act = ls_info-id_prev_app_stack ).

  ENDMETHOD.

  METHOD test_buffer.

    DATA lo_draft TYPE REF TO z2ui5_cl_core_srv_draft.
    DATA temp4 TYPE z2ui5_if_types=>ty_s_draft.
    DATA ls_first TYPE z2ui5_t_01.
    DATA ls_second TYPE z2ui5_t_01.
    lo_draft = NEW #( ).


    CLEAR temp4.
    temp4-id = `TEST_BUF`.
    lo_draft->create( draft     = temp4
                      model_xml = `buffered data` ).


    ls_first = lo_draft->read_draft( `TEST_BUF` ).

    ls_second = lo_draft->read_draft( `TEST_BUF` ).

    cl_abap_unit_assert=>assert_equals( exp = ls_first-data
                                        act = ls_second-data ).

  ENDMETHOD.

  METHOD test_overwrite.

    DATA lo_draft TYPE REF TO z2ui5_cl_core_srv_draft.
    DATA temp5 TYPE z2ui5_if_types=>ty_s_draft.
    DATA temp6 TYPE z2ui5_if_types=>ty_s_draft.
    DATA ls_db TYPE z2ui5_t_01.
    lo_draft = NEW #( ).


    CLEAR temp5.
    temp5-id = `TEST_OW`.
    lo_draft->create( draft     = temp5
                      model_xml = `original` ).


    CLEAR temp6.
    temp6-id = `TEST_OW`.
    lo_draft->create( draft     = temp6
                      model_xml = `updated` ).


    ls_db = lo_draft->read_draft( `TEST_OW` ).

    cl_abap_unit_assert=>assert_equals( exp = `updated`
                                        act = ls_db-data ).

  ENDMETHOD.

  METHOD test_owner_binding.

    " a draft owned by a different user must not be readable (owner binding):
    " write a row with a foreign owner directly, then assert both read_draft
    " and check_exists refuse it for the current user
    DATA ls_db TYPE z2ui5_t_01.
    ls_db-id    = `TEST_OWNER`.
    ls_db-uname = |{ sy-uname }_OTHER|.
    ls_db-data  = `secret state`.
    MODIFY z2ui5_t_01 FROM @ls_db ##SUBRC_OK.
    COMMIT WORK.

    DATA lo_draft TYPE REF TO z2ui5_cl_core_srv_draft.
    lo_draft = NEW #( ).

    DATA lv_raised TYPE abap_bool.
    TRY.
        lo_draft->read_draft( `TEST_OWNER` ).
      CATCH z2ui5_cx_a2ui5_error.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).

    cl_abap_unit_assert=>assert_false( lo_draft->check_exists( `TEST_OWNER` ) ).

  ENDMETHOD.

ENDCLASS.
