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

    DATA temp1 TYPE z2ui5_if_ui5_exit=>ty_s_http_config_post.
    DATA ls_config LIKE temp1.
    DATA lv_n_hours_ago TYPE timestampl.
    CLEAR temp1.

    ls_config = temp1.
    z2ui5_cl_ui5_user_exit=>get_instance( )->set_config_http_post( CHANGING cs_config = ls_config ).

    " z2ui5_cl_ui5_user_exit=>set_config_http_post already guarantees a positive
    " expiry ( <= 0 falls back to its default ), so no second clamp here

    lv_n_hours_ago = z2ui5_cl_ui5_util_context=>time_subtract_seconds(
                               time    = z2ui5_cl_ui5_util_context=>time_get_timestampl( )
                               seconds = c_seconds_per_hour * ls_config-draft_exp_time_in_hours ).

    DELETE FROM z2ui5_t_01 WHERE timestampl < lv_n_hours_ago ##SUBRC_OK.
    COMMIT WORK.

  ENDMETHOD.

  METHOD create.
    DATA temp2 TYPE ty_s_db.
    DATA ls_db LIKE temp2.

    IF draft-id IS INITIAL.
      RAISE EXCEPTION TYPE z2ui5_cx_ui5_util_error
        EXPORTING val = `Internal error - cannot persist a draft without an id`.
    ENDIF.


    CLEAR temp2.
    temp2-id = draft-id.
    temp2-id_prev = draft-id_prev.
    temp2-id_prev_app = draft-id_prev_app.
    temp2-id_prev_app_stack = draft-id_prev_app_stack.
    temp2-uname = sy-uname.
    temp2-timestampl = z2ui5_cl_ui5_util_context=>time_get_timestampl( ).
    temp2-data = model_xml.

    ls_db = temp2.

    MODIFY z2ui5_t_01 FROM ls_db.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE z2ui5_cx_ui5_util_error
        EXPORTING val = `CREATE_OF_DRAFT_ENTRY_ON_DATABASE_FAILED`.
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
    IF result-uname IS NOT INITIAL AND result-uname <> sy-uname.
      RAISE EXCEPTION TYPE z2ui5_cx_ui5_util_error
        EXPORTING val = `NO_DRAFT_ENTRY_OF_PREVIOUS_REQUEST_FOUND`.
    ENDIF.

  ENDMETHOD.

  METHOD read_draft.

    result = read( id ).

  ENDMETHOD.

  METHOD read_info.

    DATA ls_db TYPE z2ui5_t_01.
    ls_db = read( id             = id
                        check_load_app = abap_false ).

    MOVE-CORRESPONDING ls_db TO result.

  ENDMETHOD.

  METHOD check_exists.

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

  METHOD count_entries.

    " owner-scoped like read/check_exists ( blank owner = legacy rows from
    " before the UNAME column existed, tolerated during upgrade )
    SELECT COUNT( * ) FROM z2ui5_t_01 INTO result
      WHERE uname = sy-uname OR uname = space
      .

  ENDMETHOD.

  METHOD count_entries_total.

    " the size of the draft table itself, every owner included - what the start
    " page shows next to the own count, and what says whether cleanup( ) is
    " keeping up. Deliberately NOT owner-scoped, and deliberately only a count:
    " everything that reads draft CONTENT stays owner-bound ( see read( ) )
    SELECT COUNT( * ) FROM z2ui5_t_01                     "#EC CI_NOWHERE
      INTO result.

  ENDMETHOD.

ENDCLASS.
