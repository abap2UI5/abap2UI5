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
    lo_draft = z2ui5_cl_ui5_srv_draft=>get_instance( ).
    DATA(ls_draft) = VALUE z2ui5_cl_ui5_srv_draft=>ty_s_draft( id                = `TEST_NAV_IDS`
                                                               id_prev           = `NAV_PREV`
                                                               id_prev_app       = `NAV_PREV_APP`
                                                               id_prev_app_stack = `NAV_PREV_APP_STACK` ).
    lo_draft->create( draft     = ls_draft
                      model_xml = `nav state` ).

    DATA(ls_db) = lo_draft->read_draft( `TEST_NAV_IDS` ).
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
    lo_draft = z2ui5_cl_ui5_srv_draft=>get_instance( ).
    lo_draft->create( draft     = VALUE #( id                = `TEST_NAV_OW`
                                           id_prev           = `FIRST_PREV`
                                           id_prev_app       = `FIRST_APP`
                                           id_prev_app_stack = `FIRST_STACK` )
                      model_xml = `first` ).

    " the collision path (INSERT refused, UPDATE of the own row): a chain
    " that was emptied stays empty, it does not keep the first write's ids
    lo_draft->create( draft     = VALUE #( id      = `TEST_NAV_OW`
                                           id_prev = `SECOND_PREV` )
                      model_xml = `second` ).

    DATA(ls_info) = lo_draft->read_info( `TEST_NAV_OW` ).
    cl_abap_unit_assert=>assert_equals( exp = `SECOND_PREV`
                                        act = ls_info-id_prev ).
    cl_abap_unit_assert=>assert_initial( ls_info-id_prev_app ).
    cl_abap_unit_assert=>assert_initial( ls_info-id_prev_app_stack ).
    cl_abap_unit_assert=>assert_equals( exp = `second`
                                        act = lo_draft->read_draft( `TEST_NAV_OW` )-data ).

  ENDMETHOD.

  METHOD test_missing_draft.

    DATA lo_draft TYPE REF TO z2ui5_if_ui5_draft_store.
    lo_draft = z2ui5_cl_ui5_srv_draft=>get_instance( ).

    TRY.
        lo_draft->read_draft( `TEST_NEVER_WRITTEN` ).
        cl_abap_unit_assert=>fail( `a draft nobody wrote cannot be read` ).
      CATCH z2ui5_cx_ui5_util_error INTO DATA(lx_full).
        cl_abap_unit_assert=>assert_true( xsdbool( lx_full->get_text( ) CS `NO_DRAFT_ENTRY_OF_PREVIOUS_REQUEST_FOUND` ) ).
    ENDTRY.

    " the light read fails the same way - the caller cannot tell the two
    " reads apart by their failure
    TRY.
        lo_draft->read_info( `TEST_NEVER_WRITTEN` ).
        cl_abap_unit_assert=>fail( `the id chain of a draft nobody wrote cannot be read` ).
      CATCH z2ui5_cx_ui5_util_error INTO DATA(lx_info).
        cl_abap_unit_assert=>assert_true( xsdbool( lx_info->get_text( ) CS `NO_DRAFT_ENTRY_OF_PREVIOUS_REQUEST_FOUND` ) ).
    ENDTRY.

    cl_abap_unit_assert=>assert_false( lo_draft->check_exists( `TEST_NEVER_WRITTEN` ) ).

    " ...and an own draft does exist
    lo_draft->create( draft     = VALUE #( id = `TEST_EXISTS_OWN` )
                      model_xml = `own` ).
    cl_abap_unit_assert=>assert_true( lo_draft->check_exists( `TEST_EXISTS_OWN` ) ).

  ENDMETHOD.

  METHOD test_create_without_id.

    DATA lo_draft TYPE REF TO z2ui5_if_ui5_draft_store.
    lo_draft = z2ui5_cl_ui5_srv_draft=>get_instance( ).
    DATA(lv_before) = lo_draft->count_entries_total( ).

    TRY.
        lo_draft->create( draft     = VALUE #( id_prev = `SOME_PREV` )
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
    ls_db-id      = `TEST_LEGACY_ROW`.
    ls_db-id_prev = `LEGACY_PREV`.
    ls_db-data    = `legacy state`.
    MODIFY z2ui5_t_01 FROM @ls_db ##SUBRC_OK.
    COMMIT WORK.

    DATA lo_draft TYPE REF TO z2ui5_if_ui5_draft_store.
    lo_draft = z2ui5_cl_ui5_srv_draft=>get_instance( ).

    " a blank owner is no owner - the row is nobody's, like a foreign one
    cl_abap_unit_assert=>assert_false( lo_draft->check_exists( `TEST_LEGACY_ROW` ) ).
    TRY.
        lo_draft->read_draft( `TEST_LEGACY_ROW` ).
        cl_abap_unit_assert=>fail( `a blank-owner row must not be readable` ).
      CATCH z2ui5_cx_ui5_util_error ##NO_HANDLER.
    ENDTRY.

    " and it is not claimed by a write over it
    TRY.
        lo_draft->create( draft     = VALUE #( id = `TEST_LEGACY_ROW` )
                          model_xml = `claimed state` ).
        cl_abap_unit_assert=>fail( `a blank-owner row must not be overwritten` ).
      CATCH z2ui5_cx_ui5_util_error ##NO_HANDLER.
    ENDTRY.
    SELECT SINGLE data FROM z2ui5_t_01
      WHERE id = @( `TEST_LEGACY_ROW` )
      INTO @DATA(lv_data).
    cl_abap_unit_assert=>assert_subrc( exp = 0 ).
    cl_abap_unit_assert=>assert_equals( exp = `legacy state`
                                        act = lv_data ).

  ENDMETHOD.

  METHOD test_instance_seam.

    DATA li_double TYPE REF TO z2ui5_if_ui5_draft_store.
    li_double = NEW ltcl_store_double( ).

    z2ui5_cl_ui5_srv_draft=>set_instance( li_double ).
    cl_abap_unit_assert=>assert_equals( exp = li_double
                                        act = z2ui5_cl_ui5_srv_draft=>get_instance( ) ).
    cl_abap_unit_assert=>assert_equals( exp = 42
                                        act = z2ui5_cl_ui5_srv_draft=>get_instance( )->count_entries_total( ) ).

    " an unbound reference restores the shipped store
    DATA li_none TYPE REF TO z2ui5_if_ui5_draft_store.
    z2ui5_cl_ui5_srv_draft=>set_instance( li_none ).
    DATA(li_shipped) = z2ui5_cl_ui5_srv_draft=>get_instance( ).
    IF li_shipped = li_double.
      cl_abap_unit_assert=>fail( `the double must not outlive the reset` ).
    ENDIF.
    DATA lo_shipped TYPE REF TO z2ui5_cl_ui5_srv_draft.
    cl_abap_unit_assert=>assert_equals(
        exp = z2ui5_cl_ui5_util_context=>rtti_get_ref_type_name( lo_shipped )
        act = z2ui5_cl_ui5_util_context=>rtti_get_classname_by_ref( li_shipped ) ).

  ENDMETHOD.

  METHOD test_create_and_read.

    DATA lo_draft TYPE REF TO z2ui5_if_ui5_draft_store.
    DATA ls_db TYPE z2ui5_t_01.
    lo_draft = z2ui5_cl_ui5_srv_draft=>get_instance( ).
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

    DATA lo_draft TYPE REF TO z2ui5_if_ui5_draft_store.
    DATA ls_info TYPE z2ui5_cl_ui5_srv_draft=>ty_s_draft.
    lo_draft = z2ui5_cl_ui5_srv_draft=>get_instance( ).
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
    DATA lo_draft TYPE REF TO z2ui5_if_ui5_draft_store.
    DATA ls_first TYPE z2ui5_t_01.
    DATA ls_second TYPE z2ui5_t_01.
    lo_draft = z2ui5_cl_ui5_srv_draft=>get_instance( ).
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

    DATA lo_draft TYPE REF TO z2ui5_if_ui5_draft_store.
    DATA ls_db TYPE z2ui5_t_01.
    lo_draft = z2ui5_cl_ui5_srv_draft=>get_instance( ).
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

    DATA lo_draft TYPE REF TO z2ui5_if_ui5_draft_store.
    lo_draft = z2ui5_cl_ui5_srv_draft=>get_instance( ).

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

    DATA lo_draft TYPE REF TO z2ui5_if_ui5_draft_store.
    lo_draft = z2ui5_cl_ui5_srv_draft=>get_instance( ).

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
    DATA lo_draft TYPE REF TO z2ui5_if_ui5_draft_store.
    DATA ls_db TYPE z2ui5_t_01.
    DATA lv_own TYPE i.
    DATA lv_total TYPE i.

    " start from a known state, so a second run of the test counts the same
    DELETE FROM z2ui5_t_01 WHERE id = @( `TEST_COUNT_FOREIGN` ) ##SUBRC_OK.
    COMMIT WORK.

    lo_draft = z2ui5_cl_ui5_srv_draft=>get_instance( ).
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
    DATA(lv_prefix) = substring( val = z2ui5_cl_ui5_util_context=>uuid_get_c32( )
                                 len = 24 ).
    DATA(lv_prev) = ``.
    DO count TIMES.
      DATA(lv_id) = |{ lv_prefix }_{ sy-index }|.
      mi_store->create( draft     = VALUE #( id          = lv_id
                                             id_prev     = lv_prev
                                             id_prev_app = id_prev_app )
                        model_xml = lv_id ).
      INSERT lv_id INTO TABLE result.
      lv_prev = lv_id.
    ENDDO.

  ENDMETHOD.

  METHOD info.

    result = VALUE #( id      = id
                      id_prev = mi_store->read_info( id )-id_prev ).

  ENDMETHOD.

  METHOD keep_zero_deletes_nothing.

    DATA(lt_id) = chain( 4 ).

    mi_store->prune_chain( draft = info( lt_id[ 4 ] )
                           keep  = 0 ).

    LOOP AT lt_id INTO DATA(lv_id).
      cl_abap_unit_assert=>assert_true( act = mi_store->check_exists( lv_id )
                                        msg = |keep 0 is the behaviour before: { lv_id } stays| ).
    ENDLOOP.

  ENDMETHOD.

  METHOD keep_two_keeps_two.

    DATA(lt_id) = chain( 3 ).

    " the save of draft 3: drafts 3 and 2 stay, draft 1 (depth 3) goes
    mi_store->prune_chain( draft = info( lt_id[ 3 ] )
                           keep  = 2 ).
    cl_abap_unit_assert=>assert_false( mi_store->check_exists( lt_id[ 1 ] ) ).
    cl_abap_unit_assert=>assert_true( mi_store->check_exists( lt_id[ 2 ] ) ).
    cl_abap_unit_assert=>assert_true( mi_store->check_exists( lt_id[ 3 ] ) ).

    " the next save takes the next one - one per save, the chain stays at 2
    DATA(lv_next) = |{ lt_id[ 3 ] }_NEXT|.
    mi_store->create( draft     = VALUE #( id      = lv_next
                                           id_prev = lt_id[ 3 ] )
                      model_xml = `next` ).
    mi_store->prune_chain( draft = info( lv_next )
                           keep  = 2 ).
    cl_abap_unit_assert=>assert_false( mi_store->check_exists( lt_id[ 2 ] ) ).
    cl_abap_unit_assert=>assert_true( mi_store->check_exists( lt_id[ 3 ] ) ).
    cl_abap_unit_assert=>assert_true( mi_store->check_exists( lv_next ) ).

  ENDMETHOD.

  METHOD keep_one_is_raised_to_two.

    DATA(lt_id) = chain( 3 ).

    " one would delete the draft the retry of a lost response continues
    mi_store->prune_chain( draft = info( lt_id[ 3 ] )
                           keep  = 1 ).
    cl_abap_unit_assert=>assert_true( mi_store->check_exists( lt_id[ 2 ] ) ).
    cl_abap_unit_assert=>assert_false( mi_store->check_exists( lt_id[ 1 ] ) ).

  ENDMETHOD.

  METHOD protected_id_survives.

    DATA(lt_id) = chain( 3 ).

    " the draft a share link names, or a restore started from
    mi_store->prune_chain( draft     = info( lt_id[ 3 ] )
                           keep      = 2
                           t_protect = VALUE #( ( lt_id[ 1 ] ) ) ).
    cl_abap_unit_assert=>assert_true( mi_store->check_exists( lt_id[ 1 ] ) ).

  ENDMETHOD.

  METHOD referenced_draft_survives.

    DATA(lt_id) = chain( 3 ).
    " a draft somewhere else goes back to draft 1 - a called app whose
    " caller it is
    DATA(lv_callee) = |{ lt_id[ 1 ] }_CALLEE|.
    mi_store->create( draft     = VALUE #( id                = lv_callee
                                           id_prev_app_stack = lt_id[ 1 ] )
                      model_xml = `callee` ).

    mi_store->prune_chain( draft = info( lt_id[ 3 ] )
                           keep  = 2 ).
    cl_abap_unit_assert=>assert_true( mi_store->check_exists( lt_id[ 1 ] ) ).

  ENDMETHOD.

  METHOD walk_stops_at_previous_app.

    " the chain of a called app starts at the caller's hop draft: its
    " first draft has it as id_prev AND as id_prev_app
    DATA(lt_caller) = chain( 2 ).
    DATA(lt_id) = chain( count       = 2
                         id_prev_app = lt_caller[ 2 ] ).
    mi_store->create( draft     = VALUE #( id          = lt_id[ 1 ]
                                           id_prev     = lt_caller[ 2 ]
                                           id_prev_app = lt_caller[ 2 ] )
                      model_xml = `first after the hop` ).

    " depth 3 of the callee's draft 2 is the caller's hop draft - kept
    mi_store->prune_chain( draft = VALUE #( id          = lt_id[ 2 ]
                                            id_prev     = lt_id[ 1 ]
                                            id_prev_app = lt_caller[ 2 ] )
                           keep  = 2 ).
    cl_abap_unit_assert=>assert_true( mi_store->check_exists( lt_caller[ 2 ] ) ).
    cl_abap_unit_assert=>assert_true( mi_store->check_exists( lt_caller[ 1 ] ) ).

  ENDMETHOD.

  METHOD touch_renews_the_time.

    DATA(lt_id) = chain( 1 ).
    DATA(lv_before) = mi_store->read_draft( lt_id[ 1 ] )-timestampl.

    " dated back an hour, the way cleanup( ) would find a draft a poll
    " kept answering with
    DATA(lv_old) = z2ui5_cl_ui5_util_context=>time_subtract_seconds( time     = lv_before
                                                                      seconds = 3600 ).
    DATA(lv_id) = lt_id[ 1 ].
    UPDATE z2ui5_t_01 SET timestampl = @lv_old WHERE id = @lv_id ##SUBRC_OK.
    COMMIT WORK.

    mi_store->touch( lt_id[ 1 ] ).

    cl_abap_unit_assert=>assert_true(
        xsdbool( mi_store->read_draft( lt_id[ 1 ] )-timestampl > lv_old ) ).

  ENDMETHOD.

ENDCLASS.
