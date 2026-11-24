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

    "! The model over a container, built from its public attributes rather
    "! than through z2ui5_cl_ui5_app_cont=>create_model( ), which is private.
    "! Same two arguments; no friendship needed for them.
    METHODS model_for
      IMPORTING
        container     TYPE REF TO z2ui5_cl_ui5_app_cont
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_ui5_srv_model.

    "! The container's asXML with the rows main_attri_db_rows answers in
    "! place of its attribute table, which it gets back before this returns
    "! - also when the transformation fails, since a sticky session serves
    "! the next request on this very container
    METHODS xml_of_stored
      IMPORTING
        container     TYPE REF TO z2ui5_cl_ui5_app_cont
        model         TYPE REF TO z2ui5_cl_ui5_srv_model
      RETURNING
        VALUE(result) TYPE string.

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

  METHOD xml_of_stored.

    DATA lr_stored TYPE REF TO z2ui5_if_ui5_types=>ty_t_attri.

    DATA(lr_live) = container->mt_attri.
    CREATE DATA lr_stored.
    lr_stored->* = model->main_attri_db_rows( ).
    container->mt_attri = lr_stored.
    " CLEANUP, not CATCH: the failure goes on to stringify( ) as it was
    " raised - its first one is the cause the final error chains
    TRY.
        result = xml_of( container ).
      CLEANUP.
        container->mt_attri = lr_live.
    ENDTRY.
    container->mt_attri = lr_live.

  ENDMETHOD.

  METHOD xml_of.

    result = z2ui5_cl_ui5_util_context=>xml_stringify( container ).

  ENDMETHOD.

  METHOD z2ui5_if_ui5_serializer~parse.

    " The transformation needs a CONCRETELY typed target - it rebuilds the
    " object from the class named in the asXML, and a REF TO object gives it
    " nothing to build into. So the typed local is load-bearing, not style.
    DATA lo_cont TYPE REF TO z2ui5_cl_ui5_app_cont.

    z2ui5_cl_ui5_util_context=>xml_parse( EXPORTING xml = val
                                          IMPORTING any = lo_cont ).
    result = lo_cont.

  ENDMETHOD.

  METHOD z2ui5_if_ui5_serializer~stringify.

    DATA(lo_cont) = narrow( container ).
    DATA(lo_model) = model_for( lo_cont ).

    DATA lx_first TYPE REF TO cx_root.

    TRY.
        lo_model->main_attri_db_save_srtti( ).
        result = xml_of_stored( container = lo_cont
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
        result = xml_of_stored( container = lo_cont
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
