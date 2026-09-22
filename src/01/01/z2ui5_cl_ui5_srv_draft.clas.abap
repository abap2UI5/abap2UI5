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
ENDCLASS.


CLASS z2ui5_cl_ui5_srv_draft IMPLEMENTATION.

  METHOD z2ui5_if_ui5_draft_store~cleanup.

    " Z2UI5_T_01 deliberately has NO secondary index (maintainer decision,
    " 2026-08): the DELETE below and the COUNTs in count_entries* scan the
    " table, but the table is kept small by this very cleanup (drafts expire
    " after a few hours), and every write path (one INSERT per roundtrip)
    " would pay for an index on TIMESTAMPL/UNAME on every click. Do not add
    " one, and do not "optimize" these statements around the missing index.
    DATA temp8 TYPE z2ui5_if_ui5_exit=>ty_s_http_config_post.
    DATA ls_config LIKE temp8.
    DATA lv_n_hours_ago TYPE timestampl.
    CLEAR temp8.

    ls_config = temp8.
    z2ui5_cl_ui5_user_exit=>get_instance( )->set_config_http_post( CHANGING cs_config = ls_config ).

    " z2ui5_cl_ui5_user_exit=>set_config_http_post already guarantees a positive
    " expiry ( <= 0 falls back to its default ), so no second clamp here

    lv_n_hours_ago = z2ui5_cl_ui5_util_context=>time_subtract_seconds(
                               time    = z2ui5_cl_ui5_util_context=>time_get_timestampl( )
                               seconds = c_seconds_per_hour * ls_config-draft_exp_time_in_hours ).

    DELETE FROM z2ui5_t_01 WHERE timestampl < lv_n_hours_ago ##SUBRC_OK.
    COMMIT WORK.

  ENDMETHOD.

  METHOD z2ui5_if_ui5_draft_store~create.
    DATA temp9 TYPE ty_s_db.
    DATA ls_db LIKE temp9.
      DATA lv_owner TYPE z2ui5_t_01-uname.

    IF draft-id IS INITIAL.
      RAISE EXCEPTION TYPE z2ui5_cx_ui5_util_error
        EXPORTING val = `Internal error - cannot persist a draft without an id`.
    ENDIF.


    CLEAR temp9.
    temp9-id = draft-id.
    temp9-id_prev = draft-id_prev.
    temp9-id_prev_app = draft-id_prev_app.
    temp9-id_prev_app_stack = draft-id_prev_app_stack.
    temp9-uname = sy-uname.
    temp9-timestampl = z2ui5_cl_ui5_util_context=>time_get_timestampl( ).
    temp9-data = model_xml.

    ls_db = temp9.

    " INSERT first; only a key that already exists asks who owns it. The
    " write used to be a MODIFY guarded by a SELECT on every save - and on
    " the legitimate paths the id is always a fresh uuid, so that SELECT hit
    " an empty row on every user click, one database roundtrip for a
    " collision that does not happen there. The guard itself is unchanged
    " (defense in depth: a row another user owns must not be overwritable
    " by re-using its id; blank-owner legacy rows stay writable during the
    " upgrade transition, like on the read side) - it runs on the collision
    " path now. A duplicate key answers sy-subrc 4 on every target, the
    " transpiled runtime included (a UNIQUE constraint failure is 4 there).
    " The blank-owner half of that guard is the FOURTH tolerance covered by
    " the REMOVAL CONDITION in read( ) - the write side of the same fail-open
    " branch, and the one that would otherwise outlive the three read
    " tolerances unnoticed, since npm run check:draftowner only holds what it
    " names. It names this branch too, so all four go in one change.
    INSERT z2ui5_t_01 FROM ls_db.
    IF sy-subrc <> 0.

      SELECT SINGLE uname FROM z2ui5_t_01 INTO lv_owner
        WHERE id = ls_db-id
        .
      IF sy-subrc = 0 AND lv_owner IS NOT INITIAL AND lv_owner <> sy-uname.
        RAISE EXCEPTION TYPE z2ui5_cx_ui5_util_error
          EXPORTING val = `NO_DRAFT_ENTRY_OF_PREVIOUS_REQUEST_FOUND`.
      ENDIF.
      UPDATE z2ui5_t_01 FROM ls_db.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE z2ui5_cx_ui5_util_error
          EXPORTING val = `CREATE_OF_DRAFT_ENTRY_ON_DATABASE_FAILED`.
      ENDIF.
    ENDIF.
    COMMIT WORK AND WAIT.

  ENDMETHOD.

  METHOD read.

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

    " Owner binding: a draft belongs to the user that created it and may only
    " be restored by that same user, so a leaked or guessed draft id cannot
    " load another user's serialized app state. Fail closed with the same
    " exception as 'not found', so callers degrade identically - a shared
    " bookmark id falls through to a fresh app start instead of erroring.
    " Legacy rows written before the UNAME column existed carry a blank owner
    " and stay readable during the upgrade transition (they expire in hours).
    " REMOVAL CONDITION for the blank-owner tolerance (here, check_exists,
    " count_entries and the collision guard in create( ) - four branches,
    " three reads and one write): one release after every installation has
    " passed a draft-expiry window on a version that writes UNAME - create( )
    " always fills it, so no new blank row can appear and cleanup( ) drains the old
    " ones. npm run check:draftowner enforces the deadline: it holds these
    " tolerances present through the grace version and fails the build once
    " a later release still ships them (the gate names its anchors - update
    " it when this wording changes)
    IF result-uname IS NOT INITIAL AND result-uname <> sy-uname.
      RAISE EXCEPTION TYPE z2ui5_cx_ui5_util_error
        EXPORTING val = `NO_DRAFT_ENTRY_OF_PREVIOUS_REQUEST_FOUND`.
    ENDIF.

  ENDMETHOD.

  METHOD z2ui5_if_ui5_draft_store~read_draft.

    result = read( id ).

  ENDMETHOD.

  METHOD z2ui5_if_ui5_draft_store~read_info.

    DATA ls_db TYPE z2ui5_t_01.
    ls_db = read( id             = id
                        check_load_app = abap_false ).

    MOVE-CORRESPONDING ls_db TO result.

  ENDMETHOD.

  METHOD z2ui5_if_ui5_draft_store~check_exists.

    DATA: BEGIN OF ls_row,
            id TYPE z2ui5_t_01-id,
            uname TYPE z2ui5_t_01-uname,
          END OF ls_row.
    DATA temp1 TYPE xsdboolean.
    SELECT SINGLE id uname FROM z2ui5_t_01 INTO ls_row
      WHERE id = id
      .

    " existence is owner-scoped (see read( )): a draft owned by another user
    " counts as non-existent here. Legacy blank-owner rows stay visible during
    " the upgrade transition.

    temp1 = boolc( sy-subrc = 0 AND ( ls_row-uname IS INITIAL OR ls_row-uname = sy-uname ) ).
    result = temp1.

  ENDMETHOD.

  METHOD z2ui5_if_ui5_draft_store~count_entries.

    " owner-scoped like read/check_exists ( blank owner = legacy rows from
    " before the UNAME column existed, tolerated during upgrade )
    SELECT COUNT( * ) FROM z2ui5_t_01 INTO result
      WHERE uname = sy-uname OR uname = space
      .

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
