" a host's own store: what set_instance( ) installs. Every method is
" implemented - the transpiled runtime generates no stubs for a PARTIALLY
" IMPLEMENTED interface (abap-check section 4)
CLASS ltcl_store_double DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_ui5_draft_store.
ENDCLASS.


CLASS ltcl_store_double IMPLEMENTATION.

  METHOD z2ui5_if_ui5_draft_store~count_entries.
    result = 41.
  ENDMETHOD.

  METHOD z2ui5_if_ui5_draft_store~count_entries_total.
    result = 42.
  ENDMETHOD.

  METHOD z2ui5_if_ui5_draft_store~create ##NEEDED.
  ENDMETHOD.

  METHOD z2ui5_if_ui5_draft_store~read_draft.
    result-id = id.
  ENDMETHOD.

  METHOD z2ui5_if_ui5_draft_store~read_info.
    result-id = id.
  ENDMETHOD.

  METHOD z2ui5_if_ui5_draft_store~check_exists.
    result = abap_true.
  ENDMETHOD.

  METHOD z2ui5_if_ui5_draft_store~cleanup ##NEEDED.
  ENDMETHOD.

  METHOD z2ui5_if_ui5_draft_store~prune_chain ##NEEDED.
  ENDMETHOD.

  METHOD z2ui5_if_ui5_draft_store~touch ##NEEDED.
  ENDMETHOD.

ENDCLASS.


CLASS ltcl_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION LONG.

  PUBLIC SECTION.

    METHODS test_create_and_read  FOR TESTING.
    METHODS test_read_info        FOR TESTING.
    METHODS test_buffer           FOR TESTING.
    METHODS test_overwrite        FOR TESTING.
    METHODS test_owner_binding    FOR TESTING.
    METHODS test_owner_binding_write FOR TESTING RAISING cx_static_check.
    METHODS test_count_total      FOR TESTING.
    " the id chain the app stack navigates by comes back from both reads,
    " and the full read carries the owner and the time of the write
    METHODS test_nav_ids_read_back FOR TESTING RAISING cx_static_check.
    " a second write of the same id replaces the chain, not only the data
    METHODS test_nav_ids_overwrite FOR TESTING RAISING cx_static_check.
    " an id nobody wrote: both reads raise, check_exists answers false
    METHODS test_missing_draft     FOR TESTING RAISING cx_static_check.
    METHODS test_create_without_id FOR TESTING RAISING cx_static_check.
    " a row from before the UNAME column - its tolerance ended with 1.149.x:
    " nobody reads, finds or overwrites it
    METHODS test_blank_owner_refused FOR TESTING RAISING cx_static_check.
    " set_instance( ) is what get_instance( ) answers; unbound restores
    METHODS test_instance_seam     FOR TESTING RAISING cx_static_check.

  PROTECTED SECTION.

  PRIVATE SECTION.
    METHODS teardown.
ENDCLASS.


CLASS ltcl_test IMPLEMENTATION.

  METHOD teardown.

    " whatever a test installed, the next one starts on the shipped store
    DATA li_none TYPE REF TO z2ui5_if_ui5_draft_store.
    z2ui5_cl_ui5_srv_draft=>set_instance( li_none ).

  ENDMETHOD.

  METHOD test_nav_ids_read_back.

    DATA lo_draft TYPE REF TO z2ui5_if_ui5_draft_store.
    DATA temp1 TYPE z2ui5_cl_ui5_srv_draft=>ty_s_draft.
    DATA ls_draft LIKE temp1.
    DATA ls_db TYPE z2ui5_if_ui5_draft_store=>ty_s_db.
    lo_draft = z2ui5_cl_ui5_srv_draft=>get_instance( ).

    CLEAR temp1.
    temp1-id = `TEST_NAV_IDS`.
    temp1-id_prev = `NAV_PREV`.
    temp1-id_prev_app = `NAV_PREV_APP`.
    temp1-id_prev_app_stack = `NAV_PREV_APP_STACK`.

    ls_draft = temp1.
    lo_draft->create( draft     = ls_draft
                      model_xml = `nav state` ).


    ls_db = lo_draft->read_draft( `TEST_NAV_IDS` ).
    cl_abap_unit_assert=>assert_equals( exp = `NAV_PREV`
                                        act = ls_db-id_prev ).
    cl_abap_unit_assert=>assert_equals( exp = `NAV_PREV_APP`
                                        act = ls_db-id_prev_app ).
    cl_abap_unit_assert=>assert_equals( exp = `NAV_PREV_APP_STACK`
                                        act = ls_db-id_prev_app_stack ).
    cl_abap_unit_assert=>assert_equals( exp = sy-uname
                                        act = ls_db-uname ).
    cl_abap_unit_assert=>assert_not_initial( ls_db-timestampl ).

    " the light read: the same four ids, nothing else to compare
    cl_abap_unit_assert=>assert_equals( exp = ls_draft
                                        act = lo_draft->read_info( `TEST_NAV_IDS` ) ).

  ENDMETHOD.

  METHOD test_nav_ids_overwrite.

    DATA lo_draft TYPE REF TO z2ui5_if_ui5_draft_store.
    DATA temp2 TYPE z2ui5_if_ui5_draft_store=>ty_s_draft.
    DATA temp3 TYPE z2ui5_if_ui5_draft_store=>ty_s_draft.
    DATA ls_info TYPE z2ui5_if_ui5_draft_store=>ty_s_draft.
    lo_draft = z2ui5_cl_ui5_srv_draft=>get_instance( ).

    CLEAR temp2.
    temp2-id = `TEST_NAV_OW`.
    temp2-id_prev = `FIRST_PREV`.
    temp2-id_prev_app = `FIRST_APP`.
    temp2-id_prev_app_stack = `FIRST_STACK`.
    lo_draft->create( draft     = temp2
                      model_xml = `first` ).

    " the collision path (INSERT refused, UPDATE of the own row): a chain
    " that was emptied stays empty, it does not keep the first write's ids

    CLEAR temp3.
    temp3-id = `TEST_NAV_OW`.
    temp3-id_prev = `SECOND_PREV`.
    lo_draft->create( draft     = temp3
                      model_xml = `second` ).


    ls_info = lo_draft->read_info( `TEST_NAV_OW` ).
    cl_abap_unit_assert=>assert_equals( exp = `SECOND_PREV`
                                        act = ls_info-id_prev ).
    cl_abap_unit_assert=>assert_initial( ls_info-id_prev_app ).
    cl_abap_unit_assert=>assert_initial( ls_info-id_prev_app_stack ).
    cl_abap_unit_assert=>assert_equals( exp = `second`
                                        act = lo_draft->read_draft( `TEST_NAV_OW` )-data ).

  ENDMETHOD.

  METHOD test_missing_draft.

    DATA lo_draft TYPE REF TO z2ui5_if_ui5_draft_store.
        DATA lx_full TYPE REF TO z2ui5_cx_ui5_util_error.
        DATA temp1 TYPE xsdboolean.
        DATA lx_info TYPE REF TO z2ui5_cx_ui5_util_error.
        DATA temp2 TYPE xsdboolean.
    DATA temp4 TYPE z2ui5_if_ui5_draft_store=>ty_s_draft.
    lo_draft = z2ui5_cl_ui5_srv_draft=>get_instance( ).

    TRY.
        lo_draft->read_draft( `TEST_NEVER_WRITTEN` ).
        cl_abap_unit_assert=>fail( `a draft nobody wrote cannot be read` ).

      CATCH z2ui5_cx_ui5_util_error INTO lx_full.

        temp1 = boolc( lx_full->get_text( ) CS `NO_DRAFT_ENTRY_OF_PREVIOUS_REQUEST_FOUND` ).
        cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp1 ).
    ENDTRY.

    " the light read fails the same way - the caller cannot tell the two
    " reads apart by their failure
    TRY.
        lo_draft->read_info( `TEST_NEVER_WRITTEN` ).
        cl_abap_unit_assert=>fail( `the id chain of a draft nobody wrote cannot be read` ).

      CATCH z2ui5_cx_ui5_util_error INTO lx_info.

        temp2 = boolc( lx_info->get_text( ) CS `NO_DRAFT_ENTRY_OF_PREVIOUS_REQUEST_FOUND` ).
        cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp2 ).
    ENDTRY.

    cl_abap_unit_assert=>assert_equals( exp = abap_false act = lo_draft->check_exists( `TEST_NEVER_WRITTEN` ) ).

    " ...and an own draft does exist

    CLEAR temp4.
    temp4-id = `TEST_EXISTS_OWN`.
    lo_draft->create( draft     = temp4
                      model_xml = `own` ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = lo_draft->check_exists( `TEST_EXISTS_OWN` ) ).

  ENDMETHOD.

  METHOD test_create_without_id.

    DATA lo_draft TYPE REF TO z2ui5_if_ui5_draft_store.
    DATA lv_before TYPE i.
        DATA temp5 TYPE z2ui5_if_ui5_draft_store=>ty_s_draft.
    lo_draft = z2ui5_cl_ui5_srv_draft=>get_instance( ).

    lv_before = lo_draft->count_entries_total( ).

    TRY.

        CLEAR temp5.
        temp5-id_prev = `SOME_PREV`.
        lo_draft->create( draft     = temp5
                          model_xml = `orphan` ).
        cl_abap_unit_assert=>fail( `a draft without an id must not be written` ).
      CATCH z2ui5_cx_ui5_util_error ##NO_HANDLER.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals( exp = lv_before
                                        act = lo_draft->count_entries_total( )
                                        msg = `nothing was written` ).

  ENDMETHOD.

  METHOD test_blank_owner_refused.

    " a row from before the UNAME column existed: no owner at all
    DATA ls_db TYPE z2ui5_t_01.
    DATA lo_draft TYPE REF TO z2ui5_if_ui5_draft_store.
        DATA temp6 TYPE z2ui5_if_ui5_draft_store=>ty_s_draft.
    DATA lv_data TYPE z2ui5_t_01-data.
    DATA temp1 TYPE string.
    ls_db-id      = `TEST_LEGACY_ROW`.
    ls_db-id_prev = `LEGACY_PREV`.
    ls_db-data    = `legacy state`.
    MODIFY z2ui5_t_01 FROM ls_db ##SUBRC_OK.
    COMMIT WORK.


    lo_draft = z2ui5_cl_ui5_srv_draft=>get_instance( ).

    " a blank owner is no owner - the row is nobody's, like a foreign one
    cl_abap_unit_assert=>assert_equals( exp = abap_false act = lo_draft->check_exists( `TEST_LEGACY_ROW` ) ).
    TRY.
        lo_draft->read_draft( `TEST_LEGACY_ROW` ).
        cl_abap_unit_assert=>fail( `a blank-owner row must not be readable` ).
      CATCH z2ui5_cx_ui5_util_error ##NO_HANDLER.
    ENDTRY.

    " and it is not claimed by a write over it
    TRY.

        CLEAR temp6.
        temp6-id = `TEST_LEGACY_ROW`.
        lo_draft->create( draft     = temp6
                          model_xml = `claimed state` ).
        cl_abap_unit_assert=>fail( `a blank-owner row must not be overwritten` ).
      CATCH z2ui5_cx_ui5_util_error ##NO_HANDLER.
    ENDTRY.


    temp1 = `TEST_LEGACY_ROW`.
SELECT SINGLE data FROM z2ui5_t_01 INTO lv_data
      WHERE id = temp1
      .
    cl_abap_unit_assert=>assert_subrc( exp = 0 ).
    cl_abap_unit_assert=>assert_equals( exp = `legacy state`
                                        act = lv_data ).

  ENDMETHOD.

  METHOD test_instance_seam.

    DATA li_double TYPE REF TO z2ui5_if_ui5_draft_store.
    DATA li_none TYPE REF TO z2ui5_if_ui5_draft_store.
    DATA li_shipped TYPE REF TO z2ui5_if_ui5_draft_store.
    DATA lo_shipped TYPE REF TO z2ui5_cl_ui5_srv_draft.
    CREATE OBJECT li_double TYPE ltcl_store_double.

    z2ui5_cl_ui5_srv_draft=>set_instance( li_double ).
    cl_abap_unit_assert=>assert_equals( exp = li_double
                                        act = z2ui5_cl_ui5_srv_draft=>get_instance( ) ).
    cl_abap_unit_assert=>assert_equals( exp = 42
                                        act = z2ui5_cl_ui5_srv_draft=>get_instance( )->count_entries_total( ) ).

    " an unbound reference restores the shipped store

    z2ui5_cl_ui5_srv_draft=>set_instance( li_none ).

    li_shipped = z2ui5_cl_ui5_srv_draft=>get_instance( ).
    IF li_shipped = li_double.
      cl_abap_unit_assert=>fail( `the double must not outlive the reset` ).
    ENDIF.

    cl_abap_unit_assert=>assert_equals(
        exp = z2ui5_cl_ui5_util_context=>rtti_get_ref_type_name( lo_shipped )
        act = z2ui5_cl_ui5_util_context=>rtti_get_classname_by_ref( li_shipped ) ).

  ENDMETHOD.

  METHOD test_create_and_read.

    DATA lo_draft TYPE REF TO z2ui5_if_ui5_draft_store.
    DATA ls_db TYPE z2ui5_t_01.
    DATA temp7 TYPE z2ui5_if_ui5_draft_store=>ty_s_draft.
    lo_draft = z2ui5_cl_ui5_srv_draft=>get_instance( ).

    CLEAR temp7.
    temp7-id = `TEST_CR`.
    temp7-id_prev = `PREV1`.
    temp7-id_prev_app = `APP1`.
    temp7-id_prev_app_stack = `STACK1`.
    lo_draft->create( draft     = temp7
                      model_xml = `<xml>data</xml>` ).


    ls_db = lo_draft->read_draft( `TEST_CR` ).

    cl_abap_unit_assert=>assert_equals( exp = `<xml>data</xml>`
                                        act = ls_db-data ).
    cl_abap_unit_assert=>assert_equals( exp = `TEST_CR`
                                        act = ls_db-id ).

  ENDMETHOD.

  METHOD test_read_info.

    DATA lo_draft TYPE REF TO z2ui5_if_ui5_draft_store.
    DATA ls_info TYPE z2ui5_cl_ui5_srv_draft=>ty_s_draft.
    DATA temp8 TYPE z2ui5_if_ui5_draft_store=>ty_s_draft.
    lo_draft = z2ui5_cl_ui5_srv_draft=>get_instance( ).

    CLEAR temp8.
    temp8-id = `TEST_INFO`.
    temp8-id_prev_app_stack = `MY_STACK`.
    lo_draft->create( draft     = temp8
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
    DATA lo_draft TYPE REF TO z2ui5_if_ui5_draft_store.
    DATA ls_first TYPE z2ui5_t_01.
    DATA ls_second TYPE z2ui5_t_01.
    DATA temp9 TYPE z2ui5_cl_ui5_srv_draft=>ty_s_draft.
    DATA ls_draft LIKE temp9.
    DATA temp3 TYPE xsdboolean.
    DATA temp4 TYPE xsdboolean.
    lo_draft = z2ui5_cl_ui5_srv_draft=>get_instance( ).

    CLEAR temp9.
    temp9-id = `TEST_BUF`.

    ls_draft = temp9.

    lo_draft->create( draft     = ls_draft
                      model_xml = `buffered data` ).
    ls_first = lo_draft->read_draft( `TEST_BUF` ).

    lo_draft->create( draft     = ls_draft
                      model_xml = `overwritten data` ).
    ls_second = lo_draft->read_draft( `TEST_BUF` ).


    temp3 = boolc( ls_first-data CS `buffered data` ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp3 ).

    temp4 = boolc( ls_second-data CS `overwritten data` ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp4 ).

  ENDMETHOD.

  METHOD test_overwrite.

    DATA lo_draft TYPE REF TO z2ui5_if_ui5_draft_store.
    DATA ls_db TYPE z2ui5_t_01.
    DATA temp10 TYPE z2ui5_if_ui5_draft_store=>ty_s_draft.
    DATA temp11 TYPE z2ui5_if_ui5_draft_store=>ty_s_draft.
    lo_draft = z2ui5_cl_ui5_srv_draft=>get_instance( ).

    CLEAR temp10.
    temp10-id = `TEST_OW`.
    lo_draft->create( draft     = temp10
                      model_xml = `original` ).

    CLEAR temp11.
    temp11-id = `TEST_OW`.
    lo_draft->create( draft     = temp11
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
    DATA lo_draft TYPE REF TO z2ui5_if_ui5_draft_store.
    ls_db-id    = `TEST_OWNER`.
    ls_db-uname = |{ sy-uname }_OTHER|.
    ls_db-data  = `secret state`.
    MODIFY z2ui5_t_01 FROM ls_db ##SUBRC_OK.
    COMMIT WORK.


    lo_draft = z2ui5_cl_ui5_srv_draft=>get_instance( ).

    TRY.
        lo_draft->read_draft( `TEST_OWNER` ).
        cl_abap_unit_assert=>fail( `a draft of another user must not be readable` ).
      CATCH z2ui5_cx_ui5_util_error ##NO_HANDLER.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals( exp = abap_false act = lo_draft->check_exists( `TEST_OWNER` ) ).

  ENDMETHOD.

  METHOD test_owner_binding_write.

    " the write side of the owner binding: create( ) inserts first and asks
    " who owns the row only on a key collision - a foreign row must still
    " be refused there, and stay as it was
    DATA ls_db TYPE z2ui5_t_01.
    DATA lo_draft TYPE REF TO z2ui5_if_ui5_draft_store.
    DATA ls_draft TYPE z2ui5_cl_ui5_srv_draft=>ty_s_draft.
    DATA lv_data TYPE z2ui5_t_01-data.
    DATA temp2 TYPE string.
    ls_db-id    = `TEST_OWNER_WRITE`.
    ls_db-uname = |{ sy-uname }_OTHER|.
    ls_db-data  = `foreign state`.
    MODIFY z2ui5_t_01 FROM ls_db ##SUBRC_OK.
    COMMIT WORK.


    lo_draft = z2ui5_cl_ui5_srv_draft=>get_instance( ).


    ls_draft-id = `TEST_OWNER_WRITE`.
    TRY.
        lo_draft->create( draft     = ls_draft
                          model_xml = `overwrite attempt` ).
        cl_abap_unit_assert=>fail( `a foreign row must not be overwritten` ).
      CATCH z2ui5_cx_ui5_util_error ##NO_HANDLER.
    ENDTRY.



    temp2 = `TEST_OWNER_WRITE`.
SELECT SINGLE data FROM z2ui5_t_01 INTO lv_data
      WHERE id = temp2
      .
    cl_abap_unit_assert=>assert_subrc( exp = 0 ).
    cl_abap_unit_assert=>assert_equals( exp = `foreign state`
                                        act = lv_data ).

  ENDMETHOD.

  METHOD test_count_total.

    " count_entries_total( ) counts the table, count_entries( ) counts the
    " current user's share of it - a row owned by somebody else must move
    " exactly one of the two. The start page shows them as own/total
    DATA lo_draft TYPE REF TO z2ui5_if_ui5_draft_store.
    DATA ls_db TYPE z2ui5_t_01.
    DATA lv_own TYPE i.
    DATA lv_total TYPE i.

    " start from a known state, so a second run of the test counts the same
    DATA temp12 TYPE string.
    temp12 = `TEST_COUNT_FOREIGN`.
DELETE FROM z2ui5_t_01 WHERE id = temp12 ##SUBRC_OK.
    COMMIT WORK.

    lo_draft = z2ui5_cl_ui5_srv_draft=>get_instance( ).
    lv_own   = lo_draft->count_entries( ).
    lv_total = lo_draft->count_entries_total( ).

    ls_db-id    = `TEST_COUNT_FOREIGN`.
    ls_db-uname = |{ sy-uname }_OTHER_COUNT|.
    ls_db-data  = `foreign row`.
    MODIFY z2ui5_t_01 FROM ls_db ##SUBRC_OK.
    COMMIT WORK.

    cl_abap_unit_assert=>assert_equals( exp = lv_own
                                        act = lo_draft->count_entries( )
                                        msg = `a row of another user must not raise the own count` ).

    cl_abap_unit_assert=>assert_equals( exp = lv_total + 1
                                        act = lo_draft->count_entries_total( )
                                        msg = `the total count must include every owner` ).

  ENDMETHOD.

ENDCLASS.


" prune_chain( ): the pruning that keeps a chain at N drafts
" (z2ui5_if_ui5_exit=>ty_s_http_config_post-draft_keep_per_chain). Every
" test writes its own chain under fresh ids, so a run on a system that
" kept rows of an earlier run reads only its own
CLASS ltcl_prune DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    DATA mi_store TYPE REF TO z2ui5_if_ui5_draft_store.

    METHODS setup.

    " drafts 1 .. count, each with the one before as id_prev - the chain
    " the roundtrips of one app write; answers the ids, oldest first
    METHODS chain
      IMPORTING
        count         TYPE i
        id_prev_app   TYPE string OPTIONAL
      RETURNING
        VALUE(result) TYPE string_table.

    METHODS info
      IMPORTING
        id            TYPE string
      RETURNING
        VALUE(result) TYPE z2ui5_if_ui5_draft_store=>ty_s_draft.

    METHODS keep_zero_deletes_nothing FOR TESTING RAISING cx_static_check.
    METHODS keep_two_keeps_two        FOR TESTING RAISING cx_static_check.
    METHODS keep_one_is_raised_to_two FOR TESTING RAISING cx_static_check.
    METHODS protected_id_survives     FOR TESTING RAISING cx_static_check.
    METHODS referenced_draft_survives FOR TESTING RAISING cx_static_check.
    METHODS walk_stops_at_previous_app FOR TESTING RAISING cx_static_check.
    METHODS touch_renews_the_time     FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_prune IMPLEMENTATION.

  METHOD setup.

    mi_store = z2ui5_cl_ui5_srv_draft=>get_instance( ).

  ENDMETHOD.

  METHOD chain.

    " the id column holds 32 characters - room for the suffixes the tests add
    DATA lv_prefix TYPE string.
    DATA lv_prev TYPE string.
      DATA lv_id TYPE string.
      DATA temp13 TYPE z2ui5_if_ui5_draft_store=>ty_s_draft.
    lv_prefix = substring( val = z2ui5_cl_ui5_util_context=>uuid_get_c32( )
                                 len = 24 ).

    lv_prev = ``.
    DO count TIMES.

      lv_id = |{ lv_prefix }_{ sy-index }|.

      CLEAR temp13.
      temp13-id = lv_id.
      temp13-id_prev = lv_prev.
      temp13-id_prev_app = id_prev_app.
      mi_store->create( draft     = temp13
                        model_xml = lv_id ).
      INSERT lv_id INTO TABLE result.
      lv_prev = lv_id.
    ENDDO.

  ENDMETHOD.

  METHOD info.

    CLEAR result.
    result-id = id.
    result-id_prev = mi_store->read_info( id )-id_prev.

  ENDMETHOD.

  METHOD keep_zero_deletes_nothing.

    DATA lt_id TYPE string_table.
    FIELD-SYMBOLS <temp14> LIKE LINE OF lt_id.
    DATA temp15 LIKE sy-tabix.
    DATA lv_id LIKE LINE OF lt_id.
    lt_id = chain( 4 ).



    temp15 = sy-tabix.
    READ TABLE lt_id INDEX 4 ASSIGNING <temp14>.
    sy-tabix = temp15.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    mi_store->prune_chain( draft = info( <temp14> )
                           keep  = 0 ).


    LOOP AT lt_id INTO lv_id.
      cl_abap_unit_assert=>assert_equals( exp = abap_true act = mi_store->check_exists( lv_id )
                                        msg = |keep 0 is the behaviour before: { lv_id } stays| ).
    ENDLOOP.

  ENDMETHOD.

  METHOD keep_two_keeps_two.

    DATA lt_id TYPE string_table.
    FIELD-SYMBOLS <temp16> LIKE LINE OF lt_id.
    DATA temp17 LIKE sy-tabix.
    FIELD-SYMBOLS <temp18> LIKE LINE OF lt_id.
    DATA temp19 LIKE sy-tabix.
    FIELD-SYMBOLS <temp20> LIKE LINE OF lt_id.
    DATA temp21 LIKE sy-tabix.
    FIELD-SYMBOLS <temp22> LIKE LINE OF lt_id.
    DATA temp23 LIKE sy-tabix.
    DATA lv_next TYPE string.
    FIELD-SYMBOLS <temp1> LIKE LINE OF lt_id.
    DATA temp2 LIKE sy-tabix.
    DATA temp24 TYPE z2ui5_if_ui5_draft_store=>ty_s_draft.
    FIELD-SYMBOLS <temp3> LIKE LINE OF lt_id.
    DATA temp4 LIKE sy-tabix.
    FIELD-SYMBOLS <temp25> LIKE LINE OF lt_id.
    DATA temp26 LIKE sy-tabix.
    FIELD-SYMBOLS <temp27> LIKE LINE OF lt_id.
    DATA temp28 LIKE sy-tabix.
    lt_id = chain( 3 ).

    " the save of draft 3: drafts 3 and 2 stay, draft 1 (depth 3) goes


    temp17 = sy-tabix.
    READ TABLE lt_id INDEX 3 ASSIGNING <temp16>.
    sy-tabix = temp17.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    mi_store->prune_chain( draft = info( <temp16> )
                           keep  = 2 ).


    temp19 = sy-tabix.
    READ TABLE lt_id INDEX 1 ASSIGNING <temp18>.
    sy-tabix = temp19.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = abap_false act = mi_store->check_exists( <temp18> ) ).


    temp21 = sy-tabix.
    READ TABLE lt_id INDEX 2 ASSIGNING <temp20>.
    sy-tabix = temp21.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = mi_store->check_exists( <temp20> ) ).


    temp23 = sy-tabix.
    READ TABLE lt_id INDEX 3 ASSIGNING <temp22>.
    sy-tabix = temp23.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = mi_store->check_exists( <temp22> ) ).

    " the next save takes the next one - one per save, the chain stays at 2



    temp2 = sy-tabix.
    READ TABLE lt_id INDEX 3 ASSIGNING <temp1>.
    sy-tabix = temp2.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    lv_next = |{ <temp1> }_NEXT|.

    CLEAR temp24.
    temp24-id = lv_next.


    temp4 = sy-tabix.
    READ TABLE lt_id INDEX 3 ASSIGNING <temp3>.
    sy-tabix = temp4.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    temp24-id_prev = <temp3>.
    mi_store->create( draft     = temp24
                      model_xml = `next` ).
    mi_store->prune_chain( draft = info( lv_next )
                           keep  = 2 ).


    temp26 = sy-tabix.
    READ TABLE lt_id INDEX 2 ASSIGNING <temp25>.
    sy-tabix = temp26.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = abap_false act = mi_store->check_exists( <temp25> ) ).


    temp28 = sy-tabix.
    READ TABLE lt_id INDEX 3 ASSIGNING <temp27>.
    sy-tabix = temp28.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = mi_store->check_exists( <temp27> ) ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = mi_store->check_exists( lv_next ) ).

  ENDMETHOD.

  METHOD keep_one_is_raised_to_two.

    DATA lt_id TYPE string_table.
    FIELD-SYMBOLS <temp29> LIKE LINE OF lt_id.
    DATA temp30 LIKE sy-tabix.
    FIELD-SYMBOLS <temp31> LIKE LINE OF lt_id.
    DATA temp32 LIKE sy-tabix.
    FIELD-SYMBOLS <temp33> LIKE LINE OF lt_id.
    DATA temp34 LIKE sy-tabix.
    lt_id = chain( 3 ).

    " one would delete the draft the retry of a lost response continues


    temp30 = sy-tabix.
    READ TABLE lt_id INDEX 3 ASSIGNING <temp29>.
    sy-tabix = temp30.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    mi_store->prune_chain( draft = info( <temp29> )
                           keep  = 1 ).


    temp32 = sy-tabix.
    READ TABLE lt_id INDEX 2 ASSIGNING <temp31>.
    sy-tabix = temp32.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = mi_store->check_exists( <temp31> ) ).


    temp34 = sy-tabix.
    READ TABLE lt_id INDEX 1 ASSIGNING <temp33>.
    sy-tabix = temp34.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = abap_false act = mi_store->check_exists( <temp33> ) ).

  ENDMETHOD.

  METHOD protected_id_survives.

    DATA lt_id TYPE string_table.
    DATA temp35 TYPE string_table.
    FIELD-SYMBOLS <temp5> LIKE LINE OF lt_id.
    DATA temp6 LIKE sy-tabix.
    FIELD-SYMBOLS <temp7> LIKE LINE OF lt_id.
    DATA temp8 LIKE sy-tabix.
    FIELD-SYMBOLS <temp37> LIKE LINE OF lt_id.
    DATA temp38 LIKE sy-tabix.
    lt_id = chain( 3 ).

    " the draft a share link names, or a restore started from

    CLEAR temp35.


    temp6 = sy-tabix.
    READ TABLE lt_id INDEX 1 ASSIGNING <temp5>.
    sy-tabix = temp6.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    INSERT <temp5> INTO TABLE temp35.


    temp8 = sy-tabix.
    READ TABLE lt_id INDEX 3 ASSIGNING <temp7>.
    sy-tabix = temp8.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    mi_store->prune_chain( draft     = info( <temp7> )
                           keep      = 2
                           t_protect = temp35 ).


    temp38 = sy-tabix.
    READ TABLE lt_id INDEX 1 ASSIGNING <temp37>.
    sy-tabix = temp38.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = mi_store->check_exists( <temp37> ) ).

  ENDMETHOD.

  METHOD referenced_draft_survives.

    DATA lt_id TYPE string_table.
    DATA lv_callee TYPE string.
    FIELD-SYMBOLS <temp9> LIKE LINE OF lt_id.
    DATA temp10 LIKE sy-tabix.
    DATA temp39 TYPE z2ui5_if_ui5_draft_store=>ty_s_draft.
    FIELD-SYMBOLS <temp11> LIKE LINE OF lt_id.
    DATA temp12 LIKE sy-tabix.
    FIELD-SYMBOLS <temp40> LIKE LINE OF lt_id.
    DATA temp41 LIKE sy-tabix.
    FIELD-SYMBOLS <temp42> LIKE LINE OF lt_id.
    DATA temp43 LIKE sy-tabix.
    lt_id = chain( 3 ).
    " a draft somewhere else goes back to draft 1 - a called app whose
    " caller it is



    temp10 = sy-tabix.
    READ TABLE lt_id INDEX 1 ASSIGNING <temp9>.
    sy-tabix = temp10.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    lv_callee = |{ <temp9> }_CALLEE|.

    CLEAR temp39.
    temp39-id = lv_callee.


    temp12 = sy-tabix.
    READ TABLE lt_id INDEX 1 ASSIGNING <temp11>.
    sy-tabix = temp12.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    temp39-id_prev_app_stack = <temp11>.
    mi_store->create( draft     = temp39
                      model_xml = `callee` ).



    temp41 = sy-tabix.
    READ TABLE lt_id INDEX 3 ASSIGNING <temp40>.
    sy-tabix = temp41.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    mi_store->prune_chain( draft = info( <temp40> )
                           keep  = 2 ).


    temp43 = sy-tabix.
    READ TABLE lt_id INDEX 1 ASSIGNING <temp42>.
    sy-tabix = temp43.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = mi_store->check_exists( <temp42> ) ).

  ENDMETHOD.

  METHOD walk_stops_at_previous_app.

    " the chain of a called app starts at the caller's hop draft: its
    " first draft has it as id_prev AND as id_prev_app
    DATA lt_caller TYPE string_table.
    DATA lt_id TYPE string_table.
    FIELD-SYMBOLS <temp13> LIKE LINE OF lt_caller.
    DATA temp14 LIKE sy-tabix.
    DATA temp44 TYPE z2ui5_if_ui5_draft_store=>ty_s_draft.
    FIELD-SYMBOLS <temp15> LIKE LINE OF lt_id.
    DATA temp16 LIKE sy-tabix.
    FIELD-SYMBOLS <temp17> LIKE LINE OF lt_caller.
    DATA temp18 LIKE sy-tabix.
    FIELD-SYMBOLS <temp19> LIKE LINE OF lt_caller.
    DATA temp20 LIKE sy-tabix.
    DATA temp45 TYPE z2ui5_if_ui5_draft_store=>ty_s_draft.
    FIELD-SYMBOLS <temp21> LIKE LINE OF lt_id.
    DATA temp22 LIKE sy-tabix.
    FIELD-SYMBOLS <temp23> LIKE LINE OF lt_id.
    DATA temp24 LIKE sy-tabix.
    FIELD-SYMBOLS <temp25> LIKE LINE OF lt_caller.
    DATA temp26 LIKE sy-tabix.
    FIELD-SYMBOLS <temp46> LIKE LINE OF lt_caller.
    DATA temp47 LIKE sy-tabix.
    FIELD-SYMBOLS <temp48> LIKE LINE OF lt_caller.
    DATA temp49 LIKE sy-tabix.
    lt_caller = chain( 2 ).



    temp14 = sy-tabix.
    READ TABLE lt_caller INDEX 2 ASSIGNING <temp13>.
    sy-tabix = temp14.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    lt_id = chain( count       = 2
                         id_prev_app = <temp13> ).

    CLEAR temp44.


    temp16 = sy-tabix.
    READ TABLE lt_id INDEX 1 ASSIGNING <temp15>.
    sy-tabix = temp16.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    temp44-id = <temp15>.


    temp18 = sy-tabix.
    READ TABLE lt_caller INDEX 2 ASSIGNING <temp17>.
    sy-tabix = temp18.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    temp44-id_prev = <temp17>.


    temp20 = sy-tabix.
    READ TABLE lt_caller INDEX 2 ASSIGNING <temp19>.
    sy-tabix = temp20.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    temp44-id_prev_app = <temp19>.
    mi_store->create( draft     = temp44
                      model_xml = `first after the hop` ).

    " depth 3 of the callee's draft 2 is the caller's hop draft - kept

    CLEAR temp45.


    temp22 = sy-tabix.
    READ TABLE lt_id INDEX 2 ASSIGNING <temp21>.
    sy-tabix = temp22.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    temp45-id = <temp21>.


    temp24 = sy-tabix.
    READ TABLE lt_id INDEX 1 ASSIGNING <temp23>.
    sy-tabix = temp24.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    temp45-id_prev = <temp23>.


    temp26 = sy-tabix.
    READ TABLE lt_caller INDEX 2 ASSIGNING <temp25>.
    sy-tabix = temp26.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    temp45-id_prev_app = <temp25>.
    mi_store->prune_chain( draft = temp45
                           keep  = 2 ).


    temp47 = sy-tabix.
    READ TABLE lt_caller INDEX 2 ASSIGNING <temp46>.
    sy-tabix = temp47.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = mi_store->check_exists( <temp46> ) ).


    temp49 = sy-tabix.
    READ TABLE lt_caller INDEX 1 ASSIGNING <temp48>.
    sy-tabix = temp49.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = mi_store->check_exists( <temp48> ) ).

  ENDMETHOD.

  METHOD touch_renews_the_time.

    DATA lt_id TYPE string_table.
    DATA lv_before TYPE timestampl.
    FIELD-SYMBOLS <temp27> LIKE LINE OF lt_id.
    DATA temp28 LIKE sy-tabix.
    DATA lv_old TYPE timestampl.
    DATA lv_id LIKE LINE OF lt_id.
    FIELD-SYMBOLS <temp29> LIKE LINE OF lt_id.
    DATA temp30 LIKE sy-tabix.
    FIELD-SYMBOLS <temp50> LIKE LINE OF lt_id.
    DATA temp51 LIKE sy-tabix.
    FIELD-SYMBOLS <temp52> LIKE LINE OF lt_id.
    DATA temp53 LIKE sy-tabix.
    DATA temp5 TYPE xsdboolean.
    lt_id = chain( 1 ).



    temp28 = sy-tabix.
    READ TABLE lt_id INDEX 1 ASSIGNING <temp27>.
    sy-tabix = temp28.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    lv_before = mi_store->read_draft( <temp27> )-timestampl.

    " dated back an hour, the way cleanup( ) would find a draft a poll
    " kept answering with

    lv_old = z2ui5_cl_ui5_util_context=>time_subtract_seconds( time     = lv_before
                                                                      seconds = 3600 ).



    temp30 = sy-tabix.
    READ TABLE lt_id INDEX 1 ASSIGNING <temp29>.
    sy-tabix = temp30.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    lv_id = <temp29>.
    UPDATE z2ui5_t_01 SET timestampl = lv_old WHERE id = lv_id ##SUBRC_OK.
    COMMIT WORK.



    temp51 = sy-tabix.
    READ TABLE lt_id INDEX 1 ASSIGNING <temp50>.
    sy-tabix = temp51.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    mi_store->touch( <temp50> ).



    temp53 = sy-tabix.
    READ TABLE lt_id INDEX 1 ASSIGNING <temp52>.
    sy-tabix = temp53.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.

    temp5 = boolc( mi_store->read_draft( <temp52> )-timestampl > lv_old ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act =
        temp5 ).

  ENDMETHOD.

ENDCLASS.
