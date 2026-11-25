" The draft store of a test: the shipped store's contract on an internal
" table instead of Z2UI5_T_01. z2ui5_cl_ui5_test installs it for the
" duration of each roundtrip and puts the previous store back after, so a
" test writes no row to the database and two tests never see each other's
" drafts. What the framework writes is still serialized and read back -
" every event roundtrip restores the app from the draft the previous one
" saved, exactly as in production.
CLASS lcl_store DEFINITION FINAL.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_ui5_draft_store.

    " every draft written, in the order of the writes - a write of an id
    " that is there already replaces its row in place
    DATA mt_db TYPE STANDARD TABLE OF z2ui5_if_ui5_draft_store=>ty_s_db WITH EMPTY KEY.

    " whether the draft id was written after the first `count` rows - the
    " harness asks it to tell a draft saved during a roundtrip (the caller
    " a navigation hop saved) from one that was there before
    METHODS check_written_since
      IMPORTING
        id            TYPE clike
        count         TYPE i
      RETURNING
        VALUE(result) TYPE abap_bool.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS lcl_store IMPLEMENTATION.

  METHOD check_written_since.

    LOOP AT mt_db REFERENCE INTO DATA(lr_db) FROM count + 1.
      IF lr_db->id = id.
        result = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD z2ui5_if_ui5_draft_store~count_entries.

    result = lines( mt_db ).

  ENDMETHOD.

  METHOD z2ui5_if_ui5_draft_store~count_entries_total.

    result = lines( mt_db ).

  ENDMETHOD.

  METHOD z2ui5_if_ui5_draft_store~create.

    IF draft-id IS INITIAL.
      RAISE EXCEPTION TYPE z2ui5_cx_ui5_util_error
        EXPORTING val = `Internal error - cannot persist a draft without an id`.
    ENDIF.

    DATA(ls_db) = VALUE z2ui5_if_ui5_draft_store=>ty_s_db(
                            id                = draft-id
                            id_prev           = draft-id_prev
                            id_prev_app       = draft-id_prev_app
                            id_prev_app_stack = draft-id_prev_app_stack
                            uname             = z2ui5_cl_ui5_util_context=>sy_get( )-uname
                            timestampl        = z2ui5_cl_ui5_util_context=>time_get_timestampl( )
                            data              = model_xml ).

    LOOP AT mt_db REFERENCE INTO DATA(lr_db) WHERE id = draft-id. "#EC CI_SORTSEQ
      lr_db->* = ls_db.
      RETURN.
    ENDLOOP.
    INSERT ls_db INTO TABLE mt_db.

  ENDMETHOD.

  METHOD z2ui5_if_ui5_draft_store~read_draft.

    LOOP AT mt_db REFERENCE INTO DATA(lr_db) WHERE id = id. "#EC CI_SORTSEQ
      result = lr_db->*.
      RETURN.
    ENDLOOP.
    " the shipped store's answer for a missing draft, word for word
    RAISE EXCEPTION TYPE z2ui5_cx_ui5_util_error
      EXPORTING val = `NO_DRAFT_ENTRY_OF_PREVIOUS_REQUEST_FOUND`.

  ENDMETHOD.

  METHOD z2ui5_if_ui5_draft_store~read_info.

    DATA(ls_db) = z2ui5_if_ui5_draft_store~read_draft( id ).
    result = VALUE #( id                = ls_db-id
                      id_prev           = ls_db-id_prev
                      id_prev_app       = ls_db-id_prev_app
                      id_prev_app_stack = ls_db-id_prev_app_stack ).

  ENDMETHOD.

  METHOD z2ui5_if_ui5_draft_store~check_exists.

    LOOP AT mt_db TRANSPORTING NO FIELDS WHERE id = id. "#EC CI_SORTSEQ
      result = abap_true.
      RETURN.
    ENDLOOP.

  ENDMETHOD.

  METHOD z2ui5_if_ui5_draft_store~cleanup ##NEEDED.
    " a test lives for milliseconds - nothing expires in it
  ENDMETHOD.

  METHOD z2ui5_if_ui5_draft_store~prune_chain ##NEEDED.
    " every draft is kept: restore( ) and nav_left( ) read older ones, and
    " a test writes a handful
  ENDMETHOD.

  METHOD z2ui5_if_ui5_draft_store~touch ##NEEDED.
    " nothing expires, so there is no age to renew
  ENDMETHOD.

ENDCLASS.


" The caller z2ui5_cl_ui5_test=>start_called( ) puts in front of the app
" under test: it calls that app on its first start and does nothing else, so
" the app runs as the target of a nav_app_call - the way a popup app, a value
" help or a confirmation is reached - and its nav_app_leave( ) has somewhere
" to go back to (nav_left( ) of the harness)
CLASS lcl_caller DEFINITION FINAL.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    " OPTIONAL: a draft restore creates the instance without arguments
    METHODS constructor
      IMPORTING
        app TYPE REF TO z2ui5_if_app OPTIONAL.

  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA mo_app TYPE REF TO z2ui5_if_app.
ENDCLASS.


CLASS lcl_caller IMPLEMENTATION.

  METHOD constructor.

    mo_app = app.

  ENDMETHOD.

  METHOD z2ui5_if_app~main.

    IF client->check_on_init( ).
      client->nav_app_call( mo_app ).
      " the called app is saved in its own draft - this one need not carry it
      CLEAR mo_app.
    ENDIF.

  ENDMETHOD.

ENDCLASS.
