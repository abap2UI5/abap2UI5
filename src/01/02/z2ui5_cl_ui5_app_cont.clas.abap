CLASS z2ui5_cl_ui5_app_cont DEFINITION PUBLIC FINAL.

  PUBLIC SECTION.

    INTERFACES if_serializable_object.

    DATA mt_attri TYPE REF TO z2ui5_if_ui5_types=>ty_t_attri.
    DATA mo_app   TYPE REF TO object.
    DATA ms_draft TYPE z2ui5_cl_ui5_srv_draft=>ty_s_draft.
    " Hash routing mode of THIS app (z2ui5_if_client=>cs_nav_mode), set via
    " follow_up_action( cs_event-set_nav_routing ). It lives on the app - and therefore in its
    " draft - rather than on the session, so it is re-sent with every response
    " of this app: an app configures routing ONCE (in check_on_init, the way a
    " UI5 app configures it once in the manifest) instead of re-asserting it on
    " every render, and an app the user navigates back to keeps its own mode
    " even when the app in between ran with a different one.
    DATA mv_nav_mode TYPE string.

    " Whether THIS app wants its draft id carried in the URL hash
    " (z2ui5-xapp-state), set via client->set_app_state_active( ) or
    " follow_up_action( cs_event-set_app_state_active ). On the app - and
    " therefore in its draft - for the same reason as mv_nav_mode above, and
    " it has to be: the intent is re-asserted on every response, but
    " ms_next-s_nav is per-request (z2ui5_cl_ui5_handler=>main clears it) and
    " the frontend reads a missing setAppStateActive as "clear the hash"
    " (app/webapp/core/Router.js). Held only on ms_next, the flag survived
    " exactly one response: opening a bookmarked app-state URL restored the
    " draft, and the first button click then wiped z2ui5-xapp-state from the
    " address bar - the bookmark stopped tracking the app it was made for.
    " main_end re-sends it, the way it re-sends mv_nav_mode.
    DATA mv_app_state_active TYPE abap_bool.

    " What the browser told us about itself. It lives on the app - and
    " therefore in its draft - so the frontend sends it once per page load
    " instead of with every roundtrip. A draft reopened from a DIFFERENT
    " browser overwrites it: that browser's first roundtrip carries its own
    " block, and z2ui5_cl_ui5_handler=>session_merge takes whatever a request
    " brings over whatever the draft held.
    DATA ms_session TYPE z2ui5_if_ui5_types=>ty_s_session.

    " Lifecycle state of THIS app. Both were public DATA on z2ui5_if_app and
    " moved here: they are framework bookkeeping, not something an app
    " implements, and every reader already holds this wrapper. They live on
    " the app - and therefore in its draft - exactly like mv_nav_mode above,
    " so a restored draft knows whether its app already ran its init block and
    " whether the session is sticky.
    " The z2ui5_if_app attributes they replaced are gone: an app asks
    " client->check_on_init( ) whether this is the first render, and
    " client->set_session_stateful( ) to switch sticky on.
    DATA mv_check_sticky      TYPE abap_bool.
    DATA mv_check_initialized TYPE abap_bool.

    " The model exactly as the client is left holding it after this app's
    " last response - the full JSON string (`{}` for an empty model), or
    " INITIAL when unknown: a fresh app, a draft written before this
    " attribute existed, or an incoming model delta that invalidated it
    " (z2ui5_cl_ui5_action=>factory_by_frontend). It lives on the app - and
    " therefore in its draft - so the next roundtrip reuses it as the
    " pre-main( ) snapshot instead of serializing the whole model a second
    " time (z2ui5_cl_ui5_handler=>main_process / main_end). Staleness leans
    " one way only: a value that no longer matches re-serialization causes
    " at most one redundant model push - it can never suppress a push the
    " client needs, because it is only ever written to what the client was
    " actually left holding, and cleared the moment incoming deltas touch
    " the state it describes.
    DATA mv_model_client TYPE string.

    "! Refresh z2ui5_if_app~id_draft on the wrapped app. Not a courtesy: it is
    "! the handle db_load_by_app( ) resolves an app reference by, so it has to
    "! follow ms_draft-id whenever that changes.
    METHODS app_refresh_draft_id.

    METHODS model_json_stringify
      RETURNING
        VALUE(result) TYPE string.

    "! Apply the incoming client model to the app's bound attributes and
    "! return what the delta could NOT apply (see
    "! z2ui5_if_client=>ty_s_model_skip). The list is RETURNED rather than
    "! stored on this object on purpose: this object is serialized into the
    "! draft, and a trace that outlived its roundtrip would be handed to the
    "! app again after the next restore.
    METHODS model_json_parse
      IMPORTING
        io_model      TYPE REF TO z2ui5_if_ajson
      RETURNING
        VALUE(result) TYPE z2ui5_if_client=>ty_t_model_skip.

    METHODS all_xml_stringify
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS all_xml_parse
      IMPORTING
        !xml          TYPE clike
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_ui5_app_cont.

    TYPES:
      BEGIN OF ty_s_buffer,
        id  TYPE string,
        app TYPE REF TO z2ui5_cl_ui5_app_cont,
      END OF ty_s_buffer.

    CLASS-DATA mt_buffer TYPE SORTED TABLE OF ty_s_buffer WITH UNIQUE KEY id.

    CLASS-METHODS db_load
      IMPORTING
        !id           TYPE clike
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_ui5_app_cont.

    CLASS-METHODS db_load_by_app
      IMPORTING
        app           TYPE REF TO z2ui5_if_app
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_ui5_app_cont.

    CLASS-METHODS db_load_buffer_clear.

    METHODS constructor.
    METHODS db_save.

  PROTECTED SECTION.

  PRIVATE SECTION.
    METHODS create_model
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_ui5_srv_model.
ENDCLASS.


CLASS z2ui5_cl_ui5_app_cont IMPLEMENTATION.

  METHOD all_xml_parse.

    z2ui5_cl_ui5_util_context=>xml_parse( EXPORTING xml = xml
                                       IMPORTING any    = result ).

  ENDMETHOD.

  METHOD all_xml_stringify.

    DATA(lo_model) = create_model( ).

    DATA x_first TYPE REF TO cx_root.

    TRY.
        lo_model->main_attri_db_save_srtti( ).
        result = z2ui5_cl_ui5_util_context=>xml_stringify( me ).
        " the live instance gets its references BACK, not a parsed copy: the
        " same objects the save detached, one assignment each instead of one
        " S-RTTI parse per reference (which is what a fresh container from
        " the draft has to pay, and what this instance never has to)
        lo_model->main_attri_reattach( ).
        RETURN.
      CATCH cx_root INTO x_first.
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
        result = z2ui5_cl_ui5_util_context=>xml_stringify( me ).
        lo_model->main_attri_reattach( ).
        RETURN.
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

    " chain the FIRST serialization failure - it names the attribute/type
    " that is not serializable and carries the source position of the
    " transformation that gave up; the retries fail for the same root cause
    " or a follow-up one.
    " x_first is always bound here: the only path to this statement runs
    " through the first CATCH, since every success above RETURNs
    RAISE EXCEPTION TYPE z2ui5_cx_ui5_util_error
      EXPORTING
        val      = |APP_SERIALIZATION_ERROR - the app state could not be serialized. | &&
                   |Please check if all generic data references are public attributes of your class|
        previous = x_first.

  ENDMETHOD.

  METHOD constructor.

    CREATE DATA mt_attri.

  ENDMETHOD.

  METHOD db_load.

    DATA(lv_id) = CONV string( id ).

    READ TABLE mt_buffer REFERENCE INTO DATA(lr_buf) WITH TABLE KEY id = lv_id.
    IF sy-subrc = 0.
      result = lr_buf->app.
      RETURN.
    ENDIF.

    DATA(lo_db) = NEW z2ui5_cl_ui5_srv_draft( ).
    DATA(ls_db) = lo_db->read_draft( id ).
    result = all_xml_parse( ls_db-data ).

    result->create_model( )->main_attri_db_load( ).

    INSERT VALUE #( id = lv_id app = result ) INTO TABLE mt_buffer.

  ENDMETHOD.

  METHOD db_load_buffer_clear.

    CLEAR mt_buffer.

  ENDMETHOD.

  METHOD db_load_by_app.

    DATA(lo_db) = NEW z2ui5_cl_ui5_srv_draft( ).
    DATA(ls_db) = lo_db->read_draft( app->id_draft ).
    result = all_xml_parse( ls_db-data ).

    " mo_app is assigned BEFORE the attribute load, and that ordering is the
    " whole difference to db_load( ): the references are restored against the
    " LIVE app instance the stack is navigating to, not against the one the
    " draft deserialized into.
    result->mo_app = app.
    result->create_model( )->main_attri_db_load( ).

    " Publish the container in the per-request buffer so a later db_load( ) of
    " the same draft id hands back THIS object instead of parsing the draft a
    " second time into a second container - two containers for one draft mean
    " whoever reaches the other one mutates state nobody else sees.
    " Only ever an insert: reading an EXISTING buffer entry here would be
    " wrong, because a container that came from db_load( ) has its attributes
    " restored against the deserialized app, and this method's caller needs
    " them pointing at `app`. So the two loaders stay distinct in that
    " direction on purpose - do not "simplify" this into a buffer lookup.
    " mt_buffer has a UNIQUE KEY, so this insert is the whole "only if absent"
    " logic: an id already in the buffer leaves the existing entry alone and
    " sets sy-subrc = 4, which is the wanted outcome and not an error
    INSERT VALUE #( id  = CONV string( app->id_draft )
                    app = result ) INTO TABLE mt_buffer.

  ENDMETHOD.

  METHOD app_refresh_draft_id.

    IF mo_app IS NOT BOUND.
      RETURN.
    ENDIF.

    CAST z2ui5_if_app( mo_app )->id_draft = ms_draft-id.

  ENDMETHOD.

  METHOD db_save.

    IF mo_app IS BOUND.
      mv_check_initialized = abap_true.
      app_refresh_draft_id( ).
    ENDIF.

    DATA(lo_db) = NEW z2ui5_cl_ui5_srv_draft( ).
    lo_db->create( draft     = ms_draft
                   model_xml = all_xml_stringify( ) ).

  ENDMETHOD.

  METHOD model_json_parse.

    DATA(lo_model) = create_model( ).
    lo_model->main_json_to_attri( io_model ).
    result = lo_model->mt_skipped.

  ENDMETHOD.

  METHOD model_json_stringify.

    result = create_model( )->main_json_stringify( ).

  ENDMETHOD.

  METHOD create_model.

    result = NEW z2ui5_cl_ui5_srv_model( attri = mt_attri
                                          app  = mo_app ).

  ENDMETHOD.
ENDCLASS.
