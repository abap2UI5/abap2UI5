" The Node host's serializer (node/srv/host.mjs installs it in initialize( )):
" the draft keeps the LIVE container instead of its asXML.
"
" The shipped z2ui5_cl_ui5_serializer turns the container into asXML through
" CALL TRANSFORMATION id and S-RTTI, which open-abap reproduces by walking
" the whole object graph with RTTI and ASSIGN per attribute, and parses back
" the same way - by far the most expensive part of a roundtrip in this
" runtime, paid once to save and once to load on every click. In a process
" the roll area never ends: the object the draft describes is still there
" on the next request, so this implementation hands out an id for it and
" keeps the object itself in a class-wide table (gt_live). The draft row in
" Z2UI5_T_01 carries that id as its data, which is why a draft here cannot
" outlive the process - neither can the in-memory SQLite the host keeps the
" table in (node/setup/setup.mjs), so nothing is lost that was there before.
"
" What changes against the asXML draft: an id answers the container as it
" IS, not as it was when the id was written. Every roundtrip of an app
" saves the same object under a new id, so a Back/Forward or a bookmark
" into an earlier roundtrip of the same app shows its latest state, and a
" retry after a failed roundtrip runs on the state the failed one left -
" the semantics of a sticky session (client->set_session_stateful), which
" the framework already runs every app of this host with the live handler.
" On an SAP system nothing changes: the shipped serializer stays installed.
"
" The table is swept the way z2ui5_cl_ui5_srv_draft=>cleanup sweeps
" Z2UI5_T_01 - every entry older than the draft expiry the exit answers
" goes (sweep), and the host runs both together on a timer (host.mjs,
" DRAFT SWEEP). An id the table does not hold any more - swept, or written
" by an earlier process - answers the error a missing draft row answers,
" NO_DRAFT_ENTRY_OF_PREVIOUS_REQUEST_FOUND, so a caller cannot tell the two
" apart and the handler treats both as an expired draft.
"
" Packed into @abap2ui5/node-runtime next to zcl_sicf (node/setup/pack-npm.mjs,
" SHIPPED_SRV); not a browser-test fixture.
CLASS zcl_serializer_live DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_ui5_serializer.

    TYPES:
      BEGIN OF ty_s_live,
        id         TYPE string,
        container  TYPE REF TO object,
        timestampl TYPE timestampl,
      END OF ty_s_live.
    TYPES ty_t_live TYPE HASHED TABLE OF ty_s_live WITH UNIQUE KEY id.

    "! Drop every container older than the draft expiry the exit answers -
    "! the rule z2ui5_cl_ui5_srv_draft=>cleanup applies to the table, read
    "! from the same config, so the two stay in step. Answers how many
    "! entries went. iv_now is the clock for tests; unset, it is now.
    CLASS-METHODS sweep
      IMPORTING
        iv_now        TYPE timestampl OPTIONAL
      RETURNING
        VALUE(result) TYPE i.

    "! How many containers are kept right now.
    CLASS-METHODS count_entries
      RETURNING
        VALUE(result) TYPE i.

    "! Forget every container - what a sweep does to all of them at once.
    CLASS-METHODS clear.

  PROTECTED SECTION.
  PRIVATE SECTION.
    CONSTANTS c_seconds_per_hour TYPE i VALUE 3600.

    CLASS-DATA gt_live TYPE ty_t_live.
ENDCLASS.


CLASS zcl_serializer_live IMPLEMENTATION.

  METHOD z2ui5_if_ui5_serializer~stringify.

    IF container IS NOT BOUND.
      RAISE EXCEPTION TYPE z2ui5_cx_ui5_util_error
        EXPORTING val = `Internal error - cannot keep an unbound container as a draft`.
    ENDIF.

    DATA(lv_id) = z2ui5_cl_ui5_util_context=>uuid_get_c32( ).
    INSERT VALUE #( id         = lv_id
                    container  = container
                    timestampl = z2ui5_cl_ui5_util_context=>time_get_timestampl( ) ) INTO TABLE gt_live.
    result = lv_id.

  ENDMETHOD.

  METHOD z2ui5_if_ui5_serializer~parse.

    " an empty input answers an unbound reference - a first roundtrip,
    " see the interface
    IF val IS INITIAL.
      RETURN.
    ENDIF.

    DATA lv_id TYPE string.
    lv_id = val.
    READ TABLE gt_live INTO DATA(ls_live) WITH TABLE KEY id = lv_id.
    IF sy-subrc <> 0.
      " swept, or written by another process: the error of a missing
      " draft row, so the handler's expired-draft handling takes it
      RAISE EXCEPTION TYPE z2ui5_cx_ui5_util_error
        EXPORTING val = `NO_DRAFT_ENTRY_OF_PREVIOUS_REQUEST_FOUND`.
    ENDIF.
    result = ls_live-container.

  ENDMETHOD.

  METHOD sweep.

    DATA(ls_config) = VALUE z2ui5_if_ui5_exit=>ty_s_http_config_post( ).
    z2ui5_cl_ui5_user_exit=>get_instance( )->set_config_http_post( CHANGING cs_config = ls_config ).

    DATA(lv_now) = iv_now.
    IF lv_now IS INITIAL.
      lv_now = z2ui5_cl_ui5_util_context=>time_get_timestampl( ).
    ENDIF.
    " a positive expiry is guaranteed by the shipped exit, like cleanup( )
    DATA(lv_n_hours_ago) = z2ui5_cl_ui5_util_context=>time_subtract_seconds(
                               time    = lv_now
                               seconds = c_seconds_per_hour * ls_config-draft_exp_time_in_hours ).

    DATA(lv_before) = lines( gt_live ).
    DELETE gt_live WHERE timestampl < lv_n_hours_ago.
    result = lv_before - lines( gt_live ).

  ENDMETHOD.

  METHOD count_entries.

    result = lines( gt_live ).

  ENDMETHOD.

  METHOD clear.

    CLEAR gt_live.

  ENDMETHOD.

ENDCLASS.
