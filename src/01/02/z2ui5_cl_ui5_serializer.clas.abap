" Not FINAL, for one reason: the test class subclasses it to make xml_of( )
" fail. No shape of app data fails the transformation on BOTH a system and
" the transpiled runtime (open-abap skips what a system refuses), and the
" retry, the reattach on both failure paths and the chained first cause
" are exactly what has to be pinned. Nothing else is meant to inherit
CLASS z2ui5_cl_ui5_serializer DEFINITION PUBLIC CREATE PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_ui5_serializer.

  PROTECTED SECTION.

    "! The one transformation of the container - the step every failure of
    "! stringify( ) comes from, and the seam the test class overrides (see
    "! the class comment)
    METHODS xml_of
      IMPORTING
        container     TYPE REF TO z2ui5_cl_ui5_app_cont
      RETURNING
        VALUE(result) TYPE string.

  PRIVATE SECTION.

    " A draft that carries windowed tables starts with a frame:
    " `<!--z2ui5-kept MT_ROWS=1234 MT_GRID=567-->`, then the asXML of each
    " table in that order and of that many characters, then the asXML of
    " the container. A comment marker, because the container's asXML
    " starts with a tag and cannot contain one (a `<` in a value is
    " escaped), so a draft without the frame - every draft written before
    " it existed - is told apart by its first characters
    CONSTANTS c_kept_open  TYPE string VALUE `<!--z2ui5-kept`.
    CONSTANTS c_kept_close TYPE string VALUE `-->`.

    "! The container's asXML with the windowed tables of its app outside
    "! it, in the frame above: taken out (z2ui5_cl_ui5_srv_model
    "! =>main_kept_detach), the container transformed, the rows put back -
    "! on success and on failure. A table whose rows did not change since
    "! the draft was parsed or last written is not serialized again: its
    "! asXML is in the container's cache (mt_kept). That is the whole point
    "! of the frame - a table of 10,000 rows the browser holds 100 of is
    "! the most expensive part of the container, and most roundtrips leave
    "! it as it is
    METHODS xml_kept_of
      IMPORTING
        container     TYPE REF TO z2ui5_cl_ui5_app_cont
        model         TYPE REF TO z2ui5_cl_ui5_srv_model
      RETURNING
        VALUE(result) TYPE string.

    "! the frame of the tables, empty when there is none
    METHODS kept_frame
      IMPORTING
        it_kept       TYPE z2ui5_if_ui5_types=>ty_t_kept
      RETURNING
        VALUE(result) TYPE string.

    "! a draft split into the tables of its frame and the container's asXML
    "! - a draft without a frame is the container's asXML as it is
    METHODS kept_split
      IMPORTING
        val     TYPE string
      EXPORTING
        et_kept TYPE z2ui5_if_ui5_types=>ty_t_kept
        ev_xml  TYPE string.

    "! The model over a container, built from its public attributes rather
    "! than through z2ui5_cl_ui5_app_cont=>create_model( ), which is private.
    "! Same two arguments; no friendship needed for them.
    METHODS model_for
      IMPORTING
        container     TYPE REF TO z2ui5_cl_ui5_app_cont
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_ui5_srv_model.

    "! The interface hands the container as REF TO object (see there); this
    "! is the one place that knows what it really is.
    METHODS narrow
      IMPORTING
        container     TYPE REF TO object
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_ui5_app_cont.

ENDCLASS.


CLASS z2ui5_cl_ui5_serializer IMPLEMENTATION.

  METHOD model_for.

    result = NEW z2ui5_cl_ui5_srv_model( attri = container->mt_attri
                                         app   = container->mo_app ).

  ENDMETHOD.

  METHOD narrow.

    result ?= container.

  ENDMETHOD.

  METHOD xml_of.

    result = z2ui5_cl_ui5_util_context=>xml_stringify( container ).

  ENDMETHOD.

  METHOD z2ui5_if_ui5_serializer~parse.

    " The transformation needs a CONCRETELY typed target - it rebuilds the
    " object from the class named in the asXML, and a REF TO object gives it
    " nothing to build into. So the typed local is load-bearing, not style.
    DATA lo_cont TYPE REF TO z2ui5_cl_ui5_app_cont.
    DATA lt_kept TYPE z2ui5_if_ui5_types=>ty_t_kept.
    DATA lv_xml  TYPE string.

    kept_split( EXPORTING val     = CONV string( val )
                IMPORTING et_kept = lt_kept
                          ev_xml  = lv_xml ).
    z2ui5_cl_ui5_util_context=>xml_parse( EXPORTING xml = lv_xml
                                          IMPORTING any = lo_cont ).
    result = lo_cont.

    IF lt_kept IS INITIAL OR lo_cont IS NOT BOUND.
      RETURN.
    ENDIF.
    " the rows into the app the container brought back, and the cache
    " seeded with them: the next save of this container compares instead
    " of serializing
    lo_cont->mt_kept = model_for( lo_cont )->main_kept_load( lt_kept ).

  ENDMETHOD.

  METHOD xml_kept_of.

    " the cache holds data references to copies of the rows - it stays out
    " of the transformation like everything else that is no state
    DATA(lt_kept) = container->mt_kept.
    CLEAR container->mt_kept.

    TRY.
        model->main_kept_detach( CHANGING ct_kept = lt_kept ).
        result = kept_frame( lt_kept ) && xml_of( container ).
      CLEANUP.
        " the rows back before the caller sees the failure, which passes
        " on unchanged: the caller retries on this instance, and in a
        " sticky session the same instance serves the next request
        model->main_kept_reattach( ).
        container->mt_kept = lt_kept.
    ENDTRY.

    model->main_kept_reattach( ).
    container->mt_kept = lt_kept.

  ENDMETHOD.

  METHOD kept_frame.

    IF it_kept IS INITIAL.
      RETURN.
    ENDIF.

    DATA(lv_head) = c_kept_open.
    DATA(lv_body) = ``.
    LOOP AT it_kept INTO DATA(ls_kept).
      lv_head = |{ lv_head } { ls_kept-name }={ strlen( ls_kept-xml ) }|.
      lv_body = lv_body && ls_kept-xml.
    ENDLOOP.
    result = lv_head && c_kept_close && lv_body.

  ENDMETHOD.

  METHOD kept_split.

    DATA lt_part TYPE string_table.
    DATA lv_name TYPE string.
    DATA lv_len  TYPE string.

    CLEAR et_kept.
    ev_xml = val.
    DATA(lv_open) = strlen( c_kept_open ).
    IF strlen( val ) < lv_open.
      RETURN.
    ENDIF.
    IF substring( val = val
                  len = lv_open ) <> c_kept_open.
      RETURN.
    ENDIF.

    DATA(lv_end) = find( val = val
                         sub = c_kept_close ).
    IF lv_end < 0.
      RAISE EXCEPTION TYPE z2ui5_cx_ui5_util_error
        EXPORTING val = `APP_STATE_RESTORE_ERROR - the draft's frame of windowed tables is not closed`.
    ENDIF.
    SPLIT condense( substring( val = val
                               off = lv_open
                               len = lv_end - lv_open ) ) AT ` ` INTO TABLE lt_part.

    DATA(lv_off) = lv_end + strlen( c_kept_close ).
    LOOP AT lt_part INTO DATA(lv_part).
      SPLIT lv_part AT `=` INTO lv_name lv_len.
      DATA(lv_chars) = CONV i( lv_len ).
      APPEND VALUE #( name = lv_name
                      xml  = substring( val = val
                                        off = lv_off
                                        len = lv_chars ) ) TO et_kept.
      lv_off = lv_off + lv_chars.
    ENDLOOP.
    ev_xml = substring( val = val
                        off = lv_off ).

  ENDMETHOD.

  METHOD z2ui5_if_ui5_serializer~stringify.

    DATA(lo_cont) = narrow( container ).
    DATA(lo_model) = model_for( lo_cont ).

    DATA lx_first TYPE REF TO cx_root.

    TRY.
        lo_model->main_attri_db_save_srtti( ).
        result = xml_kept_of( container = lo_cont
                              model     = lo_model ).
        " the live instance gets its references BACK, not a parsed copy: the
        " same objects the save detached, one assignment each instead of one
        " S-RTTI parse per reference (which is what a fresh container from
        " the draft has to pay, and what this instance never has to)
        lo_model->main_attri_reattach( ).
        RETURN.
      CATCH cx_root INTO lx_first.
        " main_attri_db_save_srtti detached the data references - put them
        " back before the retry below, otherwise the second save would
        " start from the half-cleared app state
        lo_model->main_attri_reattach( ).
    ENDTRY.

    " the one retry that can turn out differently: rows rebuilt from the
    " instance as it is NOW (a reference created after the last dissolve
    " has no row, so its anonymous target went into the asXML and failed
    " there), then saved and serialized again. A bare second stringify of
    " the same rows used to sit here - what the first attempt refused, the
    " same attempt refuses again
    TRY.
        lo_model->main_attri_refresh( ).
        lo_model->main_attri_db_save_srtti( ).
        result = xml_kept_of( container = lo_cont
                              model     = lo_model ).
        lo_model->main_attri_reattach( ).
        RETURN.
      CATCH cx_root.
        " the retry's save detached the references again - put them back
        " like the first CATCH does. The exception below ends THIS request,
        " and in a sticky session the same instance serves the next one,
        " whose main( ) then ran on an app whose data references were
        " initial
        lo_model->main_attri_reattach( ).
    ENDTRY.

    " chain the FIRST serialization failure - it names the attribute/type
    " that is not serializable and carries the source position of the
    " transformation that gave up; the retries fail for the same root cause
    " or a follow-up one.
    " lx_first is always bound here: the only path to this statement runs
    " through the first CATCH, since every success above RETURNs
    RAISE EXCEPTION TYPE z2ui5_cx_ui5_util_error
      EXPORTING
        val      = |APP_SERIALIZATION_ERROR - the app state could not be serialized. | &&
                   |Please check if all generic data references are public attributes of your class|
        previous = lx_first.

  ENDMETHOD.

ENDCLASS.
