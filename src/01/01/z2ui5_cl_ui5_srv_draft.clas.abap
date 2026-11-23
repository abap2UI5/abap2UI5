CLASS z2ui5_cl_ui5_srv_draft DEFINITION PUBLIC FINAL.

  PUBLIC SECTION.
    CONSTANTS c_seconds_per_hour TYPE i VALUE 3600.

    TYPES ty_s_db TYPE z2ui5_t_01.

    TYPES:
      "! The four draft ids an app carries between roundtrips - what create( )
      "! is given and what read_info( ) hands back.
      BEGIN OF ty_s_draft,
        id                TYPE string,
        id_prev           TYPE string,
        id_prev_app       TYPE string,
        id_prev_app_stack TYPE string,
      END OF ty_s_draft.

    METHODS count_entries
      RETURNING
        VALUE(result) TYPE i.

    METHODS count_entries_total
      RETURNING
        VALUE(result) TYPE i.

    METHODS create
      IMPORTING
        draft     TYPE ty_s_draft
        model_xml TYPE clike.

    METHODS read_draft
      IMPORTING
        id            TYPE clike
      RETURNING
        VALUE(result) TYPE ty_s_db.

    METHODS read_info
      IMPORTING
        id            TYPE clike
      RETURNING
        VALUE(result) TYPE ty_s_draft.

    METHODS check_exists
      IMPORTING
        id            TYPE clike
      RETURNING
        VALUE(result) TYPE abap_bool.

    METHODS cleanup.

  PROTECTED SECTION.
    METHODS read
      IMPORTING
        id             TYPE clike
        check_load_app TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(result)  TYPE ty_s_db.

  PRIVATE SECTION.
ENDCLASS.


CLASS z2ui5_cl_ui5_srv_draft IMPLEMENTATION.

  METHOD cleanup.

    " Z2UI5_T_01 deliberately has NO secondary index (maintainer decision,
    " 2026-08): the DELETE below and the COUNTs in count_entries* scan the
    " table, but the table is kept small by this very cleanup (drafts expire
    " after a few hours), and every write path (one INSERT per roundtrip)
    " would pay for an index on TIMESTAMPL/UNAME on every click. Do not add
    " one, and do not "optimize" these statements around the missing index.
    DATA(ls_config) = VALUE z2ui5_if_ui5_exit=>ty_s_http_config_post( ).
    z2ui5_cl_ui5_user_exit=>get_instance( )->set_config_http_post( CHANGING cs_config = ls_config ).

    " z2ui5_cl_ui5_user_exit=>set_config_http_post already guarantees a positive
    " expiry ( <= 0 falls back to its default ), so no second clamp here
    DATA(lv_n_hours_ago) = z2ui5_cl_ui5_util_context=>time_subtract_seconds(
                               time    = z2ui5_cl_ui5_util_context=>time_get_timestampl( )
                               seconds = c_seconds_per_hour * ls_config-draft_exp_time_in_hours ).

    DELETE FROM z2ui5_t_01 WHERE timestampl < @lv_n_hours_ago ##SUBRC_OK.
    COMMIT WORK.

  ENDMETHOD.

  METHOD create.

    IF draft-id IS INITIAL.
      RAISE EXCEPTION TYPE z2ui5_cx_ui5_util_error
        EXPORTING val = `Internal error - cannot persist a draft without an id`.
    ENDIF.

    DATA(ls_db) = VALUE ty_s_db( id                = draft-id
                                 id_prev           = draft-id_prev
                                 id_prev_app       = draft-id_prev_app
                                 id_prev_app_stack = draft-id_prev_app_stack
                                 uname             = sy-uname
                                 timestampl        = z2ui5_cl_ui5_util_context=>time_get_timestampl( )
                                 data              = model_xml ).

    " MODIFY is an upsert on the key - guard the write the same way the read
    " side is guarded: a row another user owns must not be overwritable by
    " re-using its id (defense in depth; on the legitimate paths the id is
    " always a fresh uuid, so this SELECT hits an empty row). Blank-owner
    " legacy rows stay writable during the upgrade transition, like on the
    " read side
    SELECT SINGLE uname FROM z2ui5_t_01
      WHERE id = @ls_db-id
      INTO @DATA(lv_owner).
    IF sy-subrc = 0 AND lv_owner IS NOT INITIAL AND lv_owner <> sy-uname.
      RAISE EXCEPTION TYPE z2ui5_cx_ui5_util_error
        EXPORTING val = `NO_DRAFT_ENTRY_OF_PREVIOUS_REQUEST_FOUND`.
    ENDIF.

    MODIFY z2ui5_t_01 FROM @ls_db.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE z2ui5_cx_ui5_util_error
        EXPORTING val = `CREATE_OF_DRAFT_ENTRY_ON_DATABASE_FAILED`.
    ENDIF.
    COMMIT WORK AND WAIT.

  ENDMETHOD.

  METHOD read.

    IF check_load_app = abap_true.

      " sy-subrc is checked after ENDIF, the pragma silences check_subrc here
      SELECT SINGLE * FROM z2ui5_t_01
        WHERE id = @id
        INTO @result ##SUBRC_OK.

    ELSE.

      SELECT SINGLE id, id_prev, id_prev_app, id_prev_app_stack, uname
        FROM z2ui5_t_01
        WHERE id = @id
        INTO CORRESPONDING FIELDS OF @result ##SUBRC_OK.

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
    " REMOVAL CONDITION for the blank-owner tolerance (here, check_exists and
    " count_entries): one release after every installation has passed a
    " draft-expiry window on a version that writes UNAME - create( ) always
    " fills it, so no new blank row can appear and cleanup( ) drains the old
    " ones. npm run check:draftowner enforces the deadline: it holds these
    " tolerances present through the grace version and fails the build once
    " a later release still ships them (the gate names its anchors - update
    " it when this wording changes)
    IF result-uname IS NOT INITIAL AND result-uname <> sy-uname.
      RAISE EXCEPTION TYPE z2ui5_cx_ui5_util_error
        EXPORTING val = `NO_DRAFT_ENTRY_OF_PREVIOUS_REQUEST_FOUND`.
    ENDIF.

  ENDMETHOD.

  METHOD read_draft.

    result = read( id ).

  ENDMETHOD.

  METHOD read_info.

    DATA(ls_db) = read( id             = id
                        check_load_app = abap_false ).

    result = CORRESPONDING #( ls_db ).

  ENDMETHOD.

  METHOD check_exists.

    SELECT SINGLE id, uname FROM z2ui5_t_01
      WHERE id = @id
      INTO @DATA(ls_row).

    " existence is owner-scoped (see read( )): a draft owned by another user
    " counts as non-existent here. Legacy blank-owner rows stay visible during
    " the upgrade transition.
    result = xsdbool( sy-subrc = 0
                      AND ( ls_row-uname IS INITIAL OR ls_row-uname = sy-uname ) ).

  ENDMETHOD.

  METHOD count_entries.

    " owner-scoped like read/check_exists ( blank owner = legacy rows from
    " before the UNAME column existed, tolerated during upgrade )
    SELECT COUNT( * ) FROM z2ui5_t_01
      WHERE uname = @sy-uname OR uname = @space
      INTO @result.

  ENDMETHOD.

  METHOD count_entries_total.

    " the size of the draft table itself, every owner included - what the start
    " page shows next to the own count, and what says whether cleanup( ) is
    " keeping up. Deliberately NOT owner-scoped, and deliberately only a count:
    " everything that reads draft CONTENT stays owner-bound ( see read( ) )
    SELECT COUNT( * ) FROM z2ui5_t_01                     "#EC CI_NOWHERE
      INTO @result.

  ENDMETHOD.

ENDCLASS.
