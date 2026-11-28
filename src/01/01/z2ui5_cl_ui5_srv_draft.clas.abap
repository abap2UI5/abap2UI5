CLASS z2ui5_cl_ui5_srv_draft DEFINITION PUBLIC FINAL.

  PUBLIC SECTION.

    " The shipped draft store: Z2UI5_T_01, exactly as before. The interface
    " is what lets a host that has no such table supply its own - see there.
    INTERFACES z2ui5_if_ui5_draft_store.

    " No ALIASES - abaplint's no_aliases is an error in this repository, and
    " none are needed: every caller goes through get_instance( ), which hands
    " back an INTERFACE reference, and on one of those the method names are
    " plain. Only a caller holding a concrete z2ui5_cl_ui5_srv_draft would
    " have to qualify, and after this change none does.

    " The two types live on the interface now, with the methods that use them.
    " z2ui5_cl_ui5_srv_draft=>ty_s_draft stays a valid name because of these -
    " z2ui5_cl_ui5_app_cont declares ms_draft with it, and so do test classes.
    TYPES ty_s_db TYPE z2ui5_if_ui5_draft_store=>ty_s_db.
    TYPES ty_s_draft TYPE z2ui5_if_ui5_draft_store=>ty_s_draft.

    "! The longest draft expiry the framework accepts, ten years in hours -
    "! the cleanup turns hours into seconds as an integer, and the shipped
    "! exit clamps what an exit hands back to it
    CONSTANTS c_max_exp_time_in_hours TYPE i VALUE 87600.

    "! The fewest drafts prune_chain( ) keeps of a chain, the one just saved
    "! included. Two, because the frontend may continue the draft BEFORE
    "! the newest one: the retry of a request whose response was lost (the
    "! backend saved depth 1 already, the browser re-sends depth 2), a
    "! request a newer one superseded after the backend had processed it,
    "! and the error overlay's retry after a failed roundtrip all continue
    "! the id the browser adopted last, which the newest save made depth 2.
    "! Everything older is reached only through ids that prune_chain( )
    "! protects (the app stack, route and app state restores, share links).
    CONSTANTS c_min_keep_per_chain TYPE i VALUE 2.

    "! The most drafts prune_chain( ) keeps - the walk is keep - 1 keyed
    "! reads on every save, so a larger value only costs
    CONSTANTS c_max_keep_per_chain TYPE i VALUE 50.

    "! The store the framework uses. Without set_instance( ) this answers a
    "! fresh instance of this class on every call - which is what the call
    "! sites did before the seam existed, so a system that installs nothing
    "! behaves identically, statement for statement.
    CLASS-METHODS get_instance
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_if_ui5_draft_store.

    "! Install a host's own store. Meant for a runtime that is not an SAP
    "! system - a CAP or Node host binding its own persistence at startup -
    "! and for tests. Passing an unbound reference restores the default.
    "! @parameter store | the implementation to use from now on
    CLASS-METHODS set_instance
      IMPORTING
        store TYPE REF TO z2ui5_if_ui5_draft_store.

  PROTECTED SECTION.
    " Unbound unless a host installed one. Deliberately NOT pre-filled with a
    " default instance: the shipped store holds no state, and answering a
    " fresh one keeps the old per-call NEW semantics exactly.
    CLASS-DATA gi_me TYPE REF TO z2ui5_if_ui5_draft_store.

  PRIVATE SECTION.
    CONSTANTS c_seconds_per_hour TYPE i VALUE 3600.

    METHODS read
      IMPORTING
        id             TYPE clike
        check_load_app TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(result)  TYPE ty_s_db.

    " whether prune_chain( ) has to keep the id and end its walk there
    METHODS prune_check_stop
      IMPORTING
        id            TYPE string
        t_stop        TYPE string_table
        t_seen        TYPE string_table
      RETURNING
        VALUE(result) TYPE abap_bool.
ENDCLASS.


CLASS z2ui5_cl_ui5_srv_draft IMPLEMENTATION.

  METHOD z2ui5_if_ui5_draft_store~cleanup.

    " Z2UI5_T_01 deliberately has NO secondary index (maintainer decision,
    " 2026-08): the DELETE below and the COUNTs in count_entries* scan the
    " table, but the table is kept small by this very cleanup (drafts expire
    " after a few hours), and every write path (one INSERT per roundtrip)
    " would pay for an index on TIMESTAMPL/UNAME on every click. Do not add
    " one, and do not "optimize" these statements around the missing index.
    DATA temp54 TYPE z2ui5_if_ui5_exit=>ty_s_http_config_post.
    DATA ls_config LIKE temp54.
    DATA lv_hours TYPE i.
    DATA lv_n_hours_ago TYPE timestampl.
    CLEAR temp54.

    ls_config = temp54.
    z2ui5_cl_ui5_user_exit=>config_http_post( CHANGING cs_config = ls_config ).

    " z2ui5_cl_ui5_user_exit=>set_config_http_post clamps the expiry into
    " 1 .. c_max_exp_time_in_hours - but a subclass installed with
    " set_instance( ) may redefine that method, and an overflow here is a 500
    " on every first start, so the product is taken in a range that cannot
    " overflow whatever the exit did

    lv_hours = nmax( val1 = 1
                           val2 = nmin( val1 = ls_config-draft_exp_time_in_hours
                                        val2 = c_max_exp_time_in_hours ) ).

    lv_n_hours_ago = z2ui5_cl_ui5_util_context=>time_subtract_seconds(
                               time    = z2ui5_cl_ui5_util_context=>time_get_timestampl( )
                               seconds = c_seconds_per_hour * lv_hours ).

    DELETE FROM z2ui5_t_01 WHERE timestampl < lv_n_hours_ago ##SUBRC_OK.
    COMMIT WORK.

  ENDMETHOD.

  METHOD z2ui5_if_ui5_draft_store~create.
    DATA lv_uname TYPE z2ui5_cl_ui5_util_context=>ty_s_sy-uname.
    DATA temp55 TYPE ty_s_db.
    DATA ls_db LIKE temp55.
      DATA lv_owner TYPE z2ui5_t_01-uname.

    IF draft-id IS INITIAL.
      RAISE EXCEPTION TYPE z2ui5_cx_ui5_util_error
        EXPORTING val = `Internal error - cannot persist a draft without an id`.
    ENDIF.


    lv_uname = z2ui5_cl_ui5_util_context=>sy_get( )-uname.


    CLEAR temp55.
    temp55-id = draft-id.
    temp55-id_prev = draft-id_prev.
    temp55-id_prev_app = draft-id_prev_app.
    temp55-id_prev_app_stack = draft-id_prev_app_stack.
    temp55-uname = lv_uname.
    temp55-timestampl = z2ui5_cl_ui5_util_context=>time_get_timestampl( ).
    temp55-data = model_xml.

    ls_db = temp55.

    " INSERT first; only a key that already exists asks who owns it. The
    " write used to be a MODIFY guarded by a SELECT on every save - and on
    " an event roundtrip the id is always a fresh uuid, so that SELECT hit
    " an empty row on every user click, one database roundtrip for a
    " collision that does not happen there. The guard itself is unchanged
    " (defense in depth: a row another user owns must not be overwritable
    " by re-using its id) - it runs on the collision path now. One
    " legitimate path takes it every time: an app hop writes the target
    " under the id it already has (z2ui5_cl_ui5_action=>prepare_app_stack,
    " ms_draft-id = id_draft), so a nav_app_leave( ) back to a persisted
    " caller costs the failed INSERT, the SELECT and the UPDATE - one hop,
    " not one click. A duplicate key answers sy-subrc 4 on every target, the
    " transpiled runtime included (a UNIQUE constraint failure is 4 there).
    INSERT z2ui5_t_01 FROM ls_db.
    IF sy-subrc <> 0.

      SELECT SINGLE uname FROM z2ui5_t_01 INTO lv_owner
        WHERE id = ls_db-id
        .
      IF sy-subrc = 0 AND lv_owner <> lv_uname.
        RAISE EXCEPTION TYPE z2ui5_cx_ui5_util_error
          EXPORTING val = `NO_DRAFT_ENTRY_OF_PREVIOUS_REQUEST_FOUND`.
      ENDIF.
      UPDATE z2ui5_t_01 FROM ls_db.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE z2ui5_cx_ui5_util_error
          EXPORTING val = |CREATE_OF_DRAFT_ENTRY_ON_DATABASE_FAILED - draft { ls_db-id }|.
      ENDIF.
    ENDIF.
    COMMIT WORK AND WAIT.

  ENDMETHOD.

  METHOD read.
    DATA lv_uname TYPE z2ui5_cl_ui5_util_context=>ty_s_sy-uname.

    IF check_load_app = abap_true.

      " sy-subrc is checked after ENDIF, the pragma silences check_subrc here
      SELECT SINGLE * FROM z2ui5_t_01 INTO result
        WHERE id = id
         ##SUBRC_OK.

    ELSE.

      SELECT SINGLE id id_prev id_prev_app id_prev_app_stack uname
        FROM z2ui5_t_01 INTO CORRESPONDING FIELDS OF result
        WHERE id = id
         ##SUBRC_OK.

    ENDIF.

    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE z2ui5_cx_ui5_util_error
        EXPORTING val = `NO_DRAFT_ENTRY_OF_PREVIOUS_REQUEST_FOUND`.
    ENDIF.


    lv_uname = z2ui5_cl_ui5_util_context=>sy_get( )-uname.
    " Owner binding: a draft belongs to the user that created it and may only
    " be restored by that same user, so a leaked or guessed draft id cannot
    " load another user's serialized app state. Fail closed with the same
    " exception as 'not found', so callers degrade identically - a shared
    " bookmark id falls through to a fresh app start instead of erroring.
    " A blank owner (a row from before the UNAME column, tolerated through
    " 1.149.x) is no owner: such rows expired long ago and cleanup( ) drains
    " any left.
    IF result-uname <> lv_uname.
      RAISE EXCEPTION TYPE z2ui5_cx_ui5_util_error
        EXPORTING val = `NO_DRAFT_ENTRY_OF_PREVIOUS_REQUEST_FOUND`.
    ENDIF.

  ENDMETHOD.

  METHOD z2ui5_if_ui5_draft_store~read_draft.

    result = read( id ).

  ENDMETHOD.

  METHOD z2ui5_if_ui5_draft_store~read_info.

    DATA ls_db TYPE z2ui5_cl_ui5_srv_draft=>ty_s_db.
    ls_db = read( id             = id
                        check_load_app = abap_false ).

    MOVE-CORRESPONDING ls_db TO result.

  ENDMETHOD.

  METHOD z2ui5_if_ui5_draft_store~check_exists.

    " read before the SELECT: sy-subrc below is the SELECT's, and a method
    " call between the two would stand in its way
    DATA lv_uname TYPE z2ui5_cl_ui5_util_context=>ty_s_sy-uname.
DATA BEGIN OF ls_row.
DATA id TYPE z2ui5_t_01-id.
DATA uname TYPE z2ui5_t_01-uname.
DATA END OF ls_row.
    DATA temp1 TYPE xsdboolean.
    lv_uname = z2ui5_cl_ui5_util_context=>sy_get( )-uname.


    SELECT SINGLE id uname FROM z2ui5_t_01 INTO ls_row
      WHERE id = id
      .

    " existence is owner-scoped (see read( )): a draft owned by another user
    " counts as non-existent here.

    temp1 = boolc( sy-subrc = 0 AND ls_row-uname = lv_uname ).
    result = temp1.

  ENDMETHOD.

  METHOD z2ui5_if_ui5_draft_store~count_entries.

    DATA lv_uname TYPE z2ui5_cl_ui5_util_context=>ty_s_sy-uname.
    lv_uname = z2ui5_cl_ui5_util_context=>sy_get( )-uname.
    " owner-scoped like read/check_exists
    SELECT COUNT( * ) FROM z2ui5_t_01 INTO result
      WHERE uname = lv_uname
      .

  ENDMETHOD.

  METHOD z2ui5_if_ui5_draft_store~prune_chain.
    DATA lv_keep TYPE i.
    DATA lt_stop LIKE t_protect.
    DATA temp56 TYPE string_table.
    DATA lt_seen LIKE temp56.
    DATA lv_id LIKE draft-id_prev.
    DATA lv_uname TYPE z2ui5_cl_ui5_util_context=>ty_s_sy-uname.
    DATA lv_ref TYPE z2ui5_t_01-id.

    IF keep <= 0.
      RETURN.
    ENDIF.

    lv_keep = nmax( val1 = c_min_keep_per_chain
                          val2 = nmin( val1 = keep
                                       val2 = c_max_keep_per_chain ) ).

    " what survives and ends the walk: the ids the caller protects, and the
    " apps this draft goes back to - nav_app_leave( ) and get_app_prev( )
    " load them, and the first draft after a hop has the caller's hop
    " draft as its id_prev too, so the walk never crosses into the app it
    " came from

    lt_stop = t_protect.
    INSERT draft-id_prev_app INTO TABLE lt_stop.
    INSERT draft-id_prev_app_stack INTO TABLE lt_stop.
    " what the walk passed is kept as well - a chain that a leave closed
    " into a circle (the caller resumes under its hop-time id) must not
    " lead back to a draft inside the window

    CLEAR temp56.
    INSERT draft-id INTO TABLE temp56.

    lt_seen = temp56.


    lv_id = draft-id_prev.
    DO lv_keep - 1 TIMES.
      IF prune_check_stop( id     = lv_id
                           t_stop = lt_stop
                           t_seen = lt_seen ) = abap_true.
        RETURN.
      ENDIF.
      INSERT lv_id INTO TABLE lt_seen.
      " one keyed read per depth, each needs the one before - the chain
      " is a linked list, there is no set to read it as
      TRY.
          lv_id = read( id             = lv_id
                        check_load_app = abap_false )-id_prev.
        CATCH cx_root.
          " gone already (cleanup, an earlier prune), or not this user's
          RETURN.
      ENDTRY.
    ENDDO.

    " lv_id is depth keep + 1 now - the one draft this save deletes
    IF prune_check_stop( id     = lv_id
                         t_stop = lt_stop
                         t_seen = lt_seen ) = abap_true.
      RETURN.
    ENDIF.


    lv_uname = z2ui5_cl_ui5_util_context=>sy_get( )-uname.

    " a draft another one goes back to stays: a caller on an app stack, the
    " app a popup returns to - also when the draft naming it is not on this
    " chain (a leave rewrote the caller's id_prev, and the called app's rows
    " still name it). No index on the two columns (see cleanup( )): the
    " table this reads is the one prune_chain( ) keeps small
    " any one of them is enough, hence SINGLE without the key

    SELECT SINGLE id FROM z2ui5_t_01 INTO lv_ref
      WHERE uname = lv_uname
        AND ( id_prev_app = lv_id OR id_prev_app_stack = lv_id )
       ##NEEDED.                       "#EC CI_NOORDER
    IF sy-subrc = 0.
      RETURN.
    ENDIF.

    DELETE FROM z2ui5_t_01 WHERE id = lv_id AND uname = lv_uname.
    IF sy-subrc = 0.
      COMMIT WORK AND WAIT.
    ENDIF.

  ENDMETHOD.

  METHOD prune_check_stop.
    DATA temp58 LIKE sy-subrc.
    DATA temp2 TYPE xsdboolean.
      DATA temp59 LIKE sy-subrc.
      DATA temp3 TYPE xsdboolean.

    IF id IS INITIAL.
      result = abap_true.
      RETURN.
    ENDIF.
    " a handful of ids each - a sequential read is the cheap one here

    READ TABLE t_stop WITH KEY table_line = id TRANSPORTING NO FIELDS.
    temp58 = sy-subrc.

    temp2 = boolc( temp58 = 0 ).
    result = temp2. "#EC CI_SORTSEQ
    IF result = abap_false.

      READ TABLE t_seen WITH KEY table_line = id TRANSPORTING NO FIELDS.
      temp59 = sy-subrc.

      temp3 = boolc( temp59 = 0 ).
      result = temp3. "#EC CI_SORTSEQ
    ENDIF.

  ENDMETHOD.

  METHOD z2ui5_if_ui5_draft_store~touch.

    DATA lv_uname TYPE z2ui5_cl_ui5_util_context=>ty_s_sy-uname.
    DATA lv_now TYPE timestampl.
    lv_uname = z2ui5_cl_ui5_util_context=>sy_get( )-uname.

    lv_now = z2ui5_cl_ui5_util_context=>time_get_timestampl( ).

    " owner-scoped like every read: another user's draft keeps its age
    UPDATE z2ui5_t_01 SET timestampl = lv_now
      WHERE id = id AND uname = lv_uname.
    IF sy-subrc = 0.
      COMMIT WORK AND WAIT.
    ENDIF.

  ENDMETHOD.

  METHOD get_instance.

    IF gi_me IS BOUND.
      result = gi_me.
      RETURN.
    ENDIF.
    CREATE OBJECT result TYPE z2ui5_cl_ui5_srv_draft.

  ENDMETHOD.

  METHOD set_instance.

    gi_me = store.

  ENDMETHOD.

  METHOD z2ui5_if_ui5_draft_store~count_entries_total.

    " the size of the draft table itself, every owner included - what the start
    " page shows next to the own count, and what says whether cleanup( ) is
    " keeping up. Deliberately NOT owner-scoped, and deliberately only a count:
    " everything that reads draft CONTENT stays owner-bound ( see read( ) )
    SELECT COUNT( * ) FROM z2ui5_t_01                     "#EC CI_NOWHERE
      INTO result.

  ENDMETHOD.

ENDCLASS.
