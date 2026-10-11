" The Node host's serializer (node/srv/host.mjs installs it in initialize( )):
" the draft keeps the LIVE container next to its asXML.
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
" A draft is still a snapshot (abap2UI5/protocol, spec/sessions.md "Drafts
" are snapshots", checked by session.id-reuse): an earlier id - the retry of
" a lost response, a Back/Forward or a bookmark into an earlier roundtrip -
" continues from the state it named, not from the latest one. So stringify
" keeps the asXML of the shipped serializer next to the live object, and
" parse hands out the live object only the FIRST time an id is asked for,
" and only while no later draft of the same container exists (its draft id
" is still the one this entry recorded). Every other parse of the id - a
" second one, or one after the container was saved again - builds the
" container from the asXML, exactly as the shipped serializer does. A
" roundtrip then costs one asXML stringify instead of a stringify and a
" parse, and a container that fails the transformation fails here as it
" fails on a system. On an SAP system nothing changes: the shipped
" serializer stays installed.
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
        "! the container's draft id when it was kept - a later save of the
        "! same object writes another one
        draft_id   TYPE string,
        "! the snapshot: the shipped serializer's asXML of the container
        xml        TYPE string,
        "! the live object went out once; from then on the snapshot answers
        handed_out TYPE abap_bool,
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

    "! the shipped asXML serializer, which writes and reads the snapshots
    CLASS-METHODS snapshot
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_if_ui5_serializer.
ENDCLASS.


CLASS zcl_serializer_live IMPLEMENTATION.

  METHOD z2ui5_if_ui5_serializer~stringify.

    IF container IS NOT BOUND.
      RAISE EXCEPTION TYPE z2ui5_cx_ui5_util_error
        EXPORTING val = `Internal error - cannot keep an unbound container as a draft`.
    ENDIF.

    " the snapshot first: it narrows the container and raises the shipped
    " serializer's error for one it cannot write, before anything is kept
    DATA(lv_xml) = snapshot( )->stringify( container ).
    DATA lo_cont TYPE REF TO z2ui5_cl_ui5_app_cont.
    lo_cont ?= container.

    DATA(lv_id) = z2ui5_cl_ui5_util_context=>uuid_get_c32( ).
    INSERT VALUE #( id         = lv_id
                    container  = container
                    draft_id   = lo_cont->ms_draft-id
                    xml        = lv_xml
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
    READ TABLE gt_live REFERENCE INTO DATA(lr_live) WITH TABLE KEY id = lv_id.
    IF sy-subrc <> 0.
      " swept, or written by another process: the error of a missing
      " draft row, so the handler's expired-draft handling takes it
      RAISE EXCEPTION TYPE z2ui5_cx_ui5_util_error
        EXPORTING val = `NO_DRAFT_ENTRY_OF_PREVIOUS_REQUEST_FOUND`.
    ENDIF.

    " the live object is the snapshot only until it goes out - the roundtrip
    " it goes out to changes it - and only while it was not saved again
    DATA lo_cont TYPE REF TO z2ui5_cl_ui5_app_cont.
    lo_cont ?= lr_live->container.
    IF lr_live->handed_out = abap_false AND lo_cont->ms_draft-id = lr_live->draft_id.
      lr_live->handed_out = abap_true.
      result = lo_cont.
      RETURN.
    ENDIF.

    result = snapshot( )->parse( lr_live->xml ).

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

  METHOD snapshot.

    result = NEW z2ui5_cl_ui5_serializer( ).

  ENDMETHOD.

ENDCLASS.
