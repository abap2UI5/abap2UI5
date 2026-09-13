CLASS ltcl_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION LONG.

  PUBLIC SECTION.

    METHODS test_create           FOR TESTING.
    METHODS test_create_and_read  FOR TESTING.
    METHODS test_read_info        FOR TESTING.
    METHODS test_buffer           FOR TESTING.
    METHODS test_overwrite        FOR TESTING.
    METHODS test_owner_binding    FOR TESTING.
    METHODS test_owner_binding_write FOR TESTING RAISING cx_static_check.
    METHODS test_count_total      FOR TESTING.

  PROTECTED SECTION.

  PRIVATE SECTION.
ENDCLASS.


CLASS ltcl_test IMPLEMENTATION.
  METHOD test_create.

    DATA lo_draft TYPE REF TO z2ui5_cl_ui5_srv_draft.
    DATA ls_db TYPE z2ui5_t_01.
    lo_draft = NEW #( ).
    lo_draft->create( draft     = VALUE #( id = `TEST_ID` )
                      model_xml = `my xml` ).


    ls_db = lo_draft->read_draft( `TEST_ID` ).

    cl_abap_unit_assert=>assert_equals( exp = `my xml`
                                        act = ls_db-data ).

  ENDMETHOD.

  METHOD test_create_and_read.

    DATA lo_draft TYPE REF TO z2ui5_cl_ui5_srv_draft.
    DATA ls_db TYPE z2ui5_t_01.
    lo_draft = NEW #( ).
    lo_draft->create( draft     = VALUE #( id                = `TEST_CR`
                                           id_prev           = `PREV1`
                                           id_prev_app       = `APP1`
                                           id_prev_app_stack = `STACK1` )
                      model_xml = `<xml>data</xml>` ).


    ls_db = lo_draft->read_draft( `TEST_CR` ).

    cl_abap_unit_assert=>assert_equals( exp = `<xml>data</xml>`
                                        act = ls_db-data ).
    cl_abap_unit_assert=>assert_equals( exp = `TEST_CR`
                                        act = ls_db-id ).

  ENDMETHOD.

  METHOD test_read_info.

    DATA lo_draft TYPE REF TO z2ui5_cl_ui5_srv_draft.
    DATA ls_info TYPE z2ui5_cl_ui5_srv_draft=>ty_s_draft.
    lo_draft = NEW #( ).
    lo_draft->create( draft     = VALUE #( id = `TEST_INFO` id_prev_app_stack = `MY_STACK` )
                      model_xml = `info test` ).


    ls_info = lo_draft->read_info( `TEST_INFO` ).

    cl_abap_unit_assert=>assert_equals( exp = `TEST_INFO`
                                        act = ls_info-id ).
    cl_abap_unit_assert=>assert_equals( exp = `MY_STACK`
                                        act = ls_info-id_prev_app_stack ).

  ENDMETHOD.

  METHOD test_buffer.

    " there is NO read buffer: a second read after an overwrite must see the
    " new row, not a stale copy of the first - the property callers rely on
    DATA lo_draft TYPE REF TO z2ui5_cl_ui5_srv_draft.
    DATA ls_first TYPE z2ui5_t_01.
    DATA ls_second TYPE z2ui5_t_01.
    lo_draft = NEW #( ).
    DATA(ls_draft) = VALUE z2ui5_cl_ui5_srv_draft=>ty_s_draft( id = `TEST_BUF` ).

    lo_draft->create( draft     = ls_draft
                      model_xml = `buffered data` ).
    ls_first = lo_draft->read_draft( `TEST_BUF` ).

    lo_draft->create( draft     = ls_draft
                      model_xml = `overwritten data` ).
    ls_second = lo_draft->read_draft( `TEST_BUF` ).

    cl_abap_unit_assert=>assert_true( xsdbool( ls_first-data CS `buffered data` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( ls_second-data CS `overwritten data` ) ).

  ENDMETHOD.

  METHOD test_overwrite.

    DATA lo_draft TYPE REF TO z2ui5_cl_ui5_srv_draft.
    DATA ls_db TYPE z2ui5_t_01.
    lo_draft = NEW #( ).
    lo_draft->create( draft     = VALUE #( id = `TEST_OW` )
                      model_xml = `original` ).
    lo_draft->create( draft     = VALUE #( id = `TEST_OW` )
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

    DATA lo_draft TYPE REF TO z2ui5_cl_ui5_srv_draft.
    lo_draft = NEW #( ).

    TRY.
        lo_draft->read_draft( `TEST_OWNER` ).
        cl_abap_unit_assert=>fail( `a draft of another user must not be readable` ).
      CATCH z2ui5_cx_ui5_util_error ##NO_HANDLER.
    ENDTRY.

    cl_abap_unit_assert=>assert_false( lo_draft->check_exists( `TEST_OWNER` ) ).

  ENDMETHOD.

  METHOD test_owner_binding_write.

    " the write side of the owner binding: create( ) inserts first and asks
    " who owns the row only on a key collision - a foreign row must still
    " be refused there, and stay as it was
    DATA ls_db TYPE z2ui5_t_01.
    ls_db-id    = `TEST_OWNER_WRITE`.
    ls_db-uname = |{ sy-uname }_OTHER|.
    ls_db-data  = `foreign state`.
    MODIFY z2ui5_t_01 FROM @ls_db ##SUBRC_OK.
    COMMIT WORK.

    DATA lo_draft TYPE REF TO z2ui5_cl_ui5_srv_draft.
    lo_draft = NEW #( ).

    DATA ls_draft TYPE z2ui5_cl_ui5_srv_draft=>ty_s_draft.
    ls_draft-id = `TEST_OWNER_WRITE`.
    TRY.
        lo_draft->create( draft     = ls_draft
                          model_xml = `overwrite attempt` ).
        cl_abap_unit_assert=>fail( `a foreign row must not be overwritten` ).
      CATCH z2ui5_cx_ui5_util_error ##NO_HANDLER.
    ENDTRY.

    SELECT SINGLE data FROM z2ui5_t_01
      WHERE id = @( `TEST_OWNER_WRITE` )
      INTO @DATA(lv_data).
    cl_abap_unit_assert=>assert_subrc( exp = 0 ).
    cl_abap_unit_assert=>assert_equals( exp = `foreign state`
                                        act = lv_data ).

  ENDMETHOD.

  METHOD test_count_total.

    " count_entries_total( ) counts the table, count_entries( ) counts the
    " current user's share of it - a row owned by somebody else must move
    " exactly one of the two. The start page shows them as own/total
    DATA lo_draft TYPE REF TO z2ui5_cl_ui5_srv_draft.
    DATA ls_db TYPE z2ui5_t_01.
    DATA lv_own TYPE i.
    DATA lv_total TYPE i.

    " start from a known state, so a second run of the test counts the same
    DELETE FROM z2ui5_t_01 WHERE id = @( `TEST_COUNT_FOREIGN` ) ##SUBRC_OK.
    COMMIT WORK.

    lo_draft = NEW #( ).
    lv_own   = lo_draft->count_entries( ).
    lv_total = lo_draft->count_entries_total( ).

    ls_db-id    = `TEST_COUNT_FOREIGN`.
    ls_db-uname = |{ sy-uname }_OTHER_COUNT|.
    ls_db-data  = `foreign row`.
    MODIFY z2ui5_t_01 FROM @ls_db ##SUBRC_OK.
    COMMIT WORK.

    cl_abap_unit_assert=>assert_equals( exp = lv_own
                                        act = lo_draft->count_entries( )
                                        msg = `a row of another user must not raise the own count` ).

    cl_abap_unit_assert=>assert_equals( exp = lv_total + 1
                                        act = lo_draft->count_entries_total( )
                                        msg = `the total count must include every owner` ).

  ENDMETHOD.

ENDCLASS.
