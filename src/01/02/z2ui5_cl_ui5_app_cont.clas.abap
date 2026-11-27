CLASS z2ui5_cl_ui5_app_cont DEFINITION PUBLIC FINAL.

  PUBLIC SECTION.

    INTERFACES if_serializable_object.

    DATA mt_attri TYPE REF TO z2ui5_if_ui5_types=>ty_t_attri.
    DATA mo_app   TYPE REF TO object.
    DATA ms_draft TYPE z2ui5_cl_ui5_srv_draft=>ty_s_draft.
    " Hash routing mode of THIS app (z2ui5_if_client=>cs_nav_mode), set via
    " follow_up_action( cs_event-hash_routing ). It lives on the app - and therefore in its
    " draft - rather than on the session, so it is re-sent with every response
    " of this app: an app configures routing ONCE (in check_on_init, the way a
    " UI5 app configures it once in the manifest) instead of re-asserting it on
    " every render, and an app the user navigates back to keeps its own mode
    " even when the app in between ran with a different one.
    DATA mv_nav_mode TYPE string.

    " Whether THIS app wants its draft id carried in the URL hash
    " (z2ui5-xapp-state), set via client->app_state_set_active( ) or
    " follow_up_action( cs_event-app_state_set_active ). On the app - and
    " therefore in its draft - for the same reason as mv_nav_mode above, and
    " it has to be: the intent is re-asserted on every response, but
    " ms_next-s_nav is per-request (z2ui5_cl_ui5_handler=>main clears it) and
    " the frontend reads a missing setAppStateActive as "clear the hash"
    " (bundle/webapp/core/Router.js). Held only on ms_next, the flag survived
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
    " The tag THIS app gave its last nav_app_call( tag = ... ) - why it
    " called. On the app - and therefore in its draft, saved at the hop - so
    " it is there again when the called app leaves and this app is restored
    " from the stack: z2ui5_if_client~get_nav_tag( ) answers it on that one
    " roundtrip. Every nav_app_call( ) writes it, an untagged one clears it.
    DATA mv_nav_tag TYPE string.

    DATA mv_check_sticky      TYPE abap_bool.
    DATA mv_check_initialized TYPE abap_bool.

    " automatic model update: set when main( ) changed a bound value and the
    " roundtrip then LEFT this app without a response of its own - a
    " nav_app_call ends the dispatch iteration in factory_stack_call, and
    " the change is never pushed. The next roundtrip this app answers
    " (coming back from the called app) pushes the model even when its own
    " main( ) changed nothing; main_end clears it with every display or
    " push. It replaces the digest of the client model that used to live
    " here (mv_model_client_hash, dropped 2026-10 - a draft written before
    " carries a surplus element and does not deserialize any more, the same
    " one-time break as the type_name note in z2ui5_if_ui5_types): the
    " pre-main( ) snapshot is a copy of the bound values now
    " (z2ui5_cl_ui5_srv_model=>main_snapshot), cheap enough to take on every
    " roundtrip, so nothing about the client model has to survive a draft
    " except this one bit
    DATA mv_model_client_stale TYPE abap_bool.

    " Draft ids pruning must never delete (z2ui5_if_ui5_draft_store=>
    " prune_chain, through draft_keep_per_chain): an id handed out
    " as an app state link (z2ui5_if_client~app_state_get_href) and the
    " draft a route or app state restore started from. On the app - and
    " therefore in its draft - because pruning walks the chain from the
    " draft being saved, and the ids it must stop at are known only to the
    " roundtrip that handed them out; every later draft of the app carries
    " them on, and a session restored from a share link inherits them. A
    " draft is a candidate exactly once, when it falls to depth keep + 1,
    " so the list keeps only the last c_draft_keep_max ids. Added 2026-11:
    " a draft written before carries no element for it and deserializes
    " with an empty list
    DATA mt_draft_keep TYPE string_table.

    CONSTANTS c_draft_keep_max TYPE i VALUE 50.

    " The declarative timer of THIS app (z2ui5_if_client~timer_set /
    " timer_stop) and the one last sent to the browser for it - see
    " z2ui5_if_ui5_types=>ty_s_timer. On the app - and therefore in its
    " draft - so the app need not remember whether the browser still runs
    " it: z2ui5_cl_ui5_handler=>main_end_timer arms it again whenever the app
    " gets the screen (a start, a restore, every hop back to it) and sends
    " nothing while it is unchanged and running. A hop away clears
    " ms_timer_sent (z2ui5_cl_ui5_action=>prepare_app_stack). Added 2026-11:
    " a draft written before carries no element for either and deserializes
    " with no timer
    DATA ms_timer      TYPE z2ui5_if_ui5_types=>ty_s_timer.
    DATA ms_timer_sent TYPE z2ui5_if_ui5_types=>ty_s_timer.

    "! the pre-main( ) snapshot of the bound values - see
    "! z2ui5_cl_ui5_srv_model=>main_snapshot
    METHODS model_snapshot
      RETURNING
        VALUE(result) TYPE z2ui5_cl_ui5_srv_model=>ty_t_snapshot.

    METHODS model_snapshot_changed
      IMPORTING
        snapshot      TYPE z2ui5_cl_ui5_srv_model=>ty_t_snapshot
      RETURNING
        VALUE(result) TYPE abap_bool.

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
    "! iv_path is the node of io_model the attributes sit below - the MODEL
    "! path of a request tree (ty_s_request-model_path), or nothing when
    "! io_model is the model itself
    METHODS model_json_parse
      IMPORTING
        io_model      TYPE REF TO z2ui5_if_ajson
        iv_path       TYPE string OPTIONAL
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

    "! The serializer the framework uses. Without set_serializer( ) this
    "! answers a fresh z2ui5_cl_ui5_serializer on every call - the asXML
    "! round trip that has always run here - so a system that installs
    "! nothing behaves identically.
    CLASS-METHODS get_serializer
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_if_ui5_serializer.

    "! Install a host's own serializer. Meant for a runtime that is not an
    "! SAP system, where CALL TRANSFORMATION id over a type descriptor has no
    "! counterpart, and for tests. An unbound reference restores the default.
    "! @parameter serializer | the implementation to use from now on
    CLASS-METHODS set_serializer
      IMPORTING
        serializer TYPE REF TO z2ui5_if_ui5_serializer.

    TYPES:
      BEGIN OF ty_s_buffer,
        id         TYPE string,
        app        TYPE REF TO z2ui5_cl_ui5_app_cont,
        " the draft as it was read - what z2ui5_cl_ui5_action=>
        " factory_by_frontend hands main_end_reuse to compare against. Empty
        " for a container db_load_by_app built around a live instance
        data       TYPE string,
        timestampl TYPE timestampl,
        s_draft    TYPE z2ui5_if_ui5_draft_store=>ty_s_draft,
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

    "! What db_load( ) read for this id in this request - empty when it was
    "! not read here
    CLASS-METHODS db_load_buffered
      IMPORTING
        !id           TYPE clike
      RETURNING
        VALUE(result) TYPE ty_s_buffer.

    "! Whether this container, saved under the ids of the draft it was
    "! loaded from, would be that draft byte for byte. When it would, the
    "! container takes those ids back (and the app its id_draft) and the
    "! caller answers with that draft instead of saving a new one; when it
    "! would not, nothing changed. See z2ui5_cl_ui5_handler=>main_end_reuse
    METHODS db_check_unchanged
      IMPORTING
        is_loaded     TYPE ty_s_buffer
      RETURNING
        VALUE(result) TYPE abap_bool.

    "! Remember a draft id pruning must keep - see mt_draft_keep
    METHODS draft_keep
      IMPORTING
        !id TYPE clike.

  PROTECTED SECTION.

  PRIVATE SECTION.
    " Unbound unless a host installed one. Deliberately NOT pre-filled: the
    " shipped serializer holds no state, and answering a fresh one keeps the
    " previous inline semantics exactly.
    CLASS-DATA gi_serializer TYPE REF TO z2ui5_if_ui5_serializer.

    METHODS create_model
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_ui5_srv_model.

    " the draft's document, read and parsed into a new container - the
    " half of a load that db_load and db_load_by_app share
    CLASS-METHODS draft_parse
      IMPORTING
        iv_id         TYPE clike
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_ui5_app_cont.
ENDCLASS.


CLASS z2ui5_cl_ui5_app_cont IMPLEMENTATION.

  METHOD all_xml_parse.

    result ?= get_serializer( )->parse( xml ).

  ENDMETHOD.

  METHOD get_serializer.

    IF gi_serializer IS BOUND.
      result = gi_serializer.
      RETURN.
    ENDIF.
    result = NEW z2ui5_cl_ui5_serializer( ).

  ENDMETHOD.

  METHOD set_serializer.

    gi_serializer = serializer.

  ENDMETHOD.

  METHOD all_xml_stringify.

    result = get_serializer( )->stringify( me ).

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

    DATA(ls_db) = z2ui5_cl_ui5_srv_draft=>get_instance( )->read_draft( id ).
    result = all_xml_parse( ls_db-data ).
    " the ids before anybody changed them - factory_by_frontend mints the
    " next ones right after
    DATA(ls_draft) = result->ms_draft.
    result->create_model( )->main_attri_db_load( ).

    INSERT VALUE #( id         = lv_id
                    app        = result
                    data       = ls_db-data
                    timestampl = ls_db-timestampl
                    s_draft    = ls_draft ) INTO TABLE mt_buffer.

  ENDMETHOD.

  METHOD db_load_buffer_clear.

    CLEAR mt_buffer.

  ENDMETHOD.

  METHOD db_load_by_app.

    " the container this request already built for the draft, when its app
    " IS the instance handed in. nav_app_leave( ) without a target resolves
    " the caller through get_app( ), which parses the draft and buffers the
    " container, and the stack hop then asked for the same draft again - the
    " asXML parse of the caller's whole state twice per popup close and
    " value-help return. The identity check is exactly what the comment
    " below asks for: that container's references ARE restored against
    " `app`, because `app` is the instance it deserialized. A buffered
    " container around a DIFFERENT instance of the same id stays unusable
    " here, as before
    READ TABLE mt_buffer REFERENCE INTO DATA(lr_buf)
         WITH TABLE KEY id = app->id_draft.
    IF sy-subrc = 0 AND lr_buf->app->mo_app = app.
      result = lr_buf->app.
      RETURN.
    ENDIF.

    result = draft_parse( app->id_draft ).

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
    " Never answered from an EXISTING buffer entry (beyond the identity case
    " at the top): a container that came from db_load( ) has its attributes
    " restored against the deserialized app, and this method's caller needs
    " them pointing at `app`. So the two loaders stay distinct in that
    " direction on purpose - do not "simplify" this into a buffer lookup.
    " An entry for the id around ANOTHER instance is REPLACED, not kept: the
    " stack now runs `app`, so that is what a later db_load( ) of the id has
    " to answer, and a second hop to `app` finds it at the top instead of
    " parsing the draft again. A plain INSERT used to fail on the unique key
    " with sy-subrc 4 and nobody noticed - the stale container stayed
    DELETE TABLE mt_buffer WITH TABLE KEY id = app->id_draft.
    INSERT VALUE #( id  = app->id_draft
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

    DATA(li_store) = z2ui5_cl_ui5_srv_draft=>get_instance( ).
    li_store->create( draft     = ms_draft
                      model_xml = all_xml_stringify( ) ).

    " draft_keep_per_chain (2 by default): the draft that fell out of the window
    " goes now instead of when cleanup( ) finds it old. Not for an app
    " whose app state hash is active - its URL names every draft, and a
    " bookmark of any of them must last until the expiry. A failure here
    " costs nothing but the draft's earlier end: the save above is done
    " and committed, and cleanup( ) still takes the draft by age
    DATA(ls_config) = VALUE z2ui5_if_ui5_exit=>ty_s_http_config_post( ).
    z2ui5_cl_ui5_user_exit=>config_http_post( CHANGING cs_config = ls_config ).
    IF ls_config-draft_keep_per_chain <= 0 OR mv_app_state_active = abap_true.
      RETURN.
    ENDIF.
    TRY.
        li_store->prune_chain( draft     = ms_draft
                               keep      = ls_config-draft_keep_per_chain
                               t_protect = mt_draft_keep ).
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

  ENDMETHOD.

  METHOD db_load_buffered.

    DATA(lv_id) = CONV string( id ).
    READ TABLE mt_buffer INTO result WITH TABLE KEY id = lv_id.
    IF sy-subrc <> 0.
      CLEAR result.
    ENDIF.

  ENDMETHOD.

  METHOD db_check_unchanged.

    " Only the shipped serializer, whose text IS the state. A host's own
    " need not answer the same text for the same state - the Node host's
    " (node/srv/zcl_serializer_live) answers a fresh id per call and keeps
    " a live copy behind each - so the compare could never succeed there
    " and would cost a copy per tick
    IF is_loaded-data IS INITIAL OR mo_app IS NOT BOUND OR gi_serializer IS BOUND.
      RETURN.
    ENDIF.

    " exactly what db_save( ) would write, under the loaded ids: the two
    " fields db_save( ) sets before it serializes, and the ids the draft
    " carried - every other byte is the app's state after main( )
    DATA(ls_draft) = ms_draft.
    DATA(lv_initialized) = mv_check_initialized.
    ms_draft = is_loaded-s_draft.
    mv_check_initialized = abap_true.
    app_refresh_draft_id( ).

    IF all_xml_stringify( ) = is_loaded-data.
      result = abap_true.
      RETURN.
    ENDIF.

    ms_draft = ls_draft.
    mv_check_initialized = lv_initialized.
    app_refresh_draft_id( ).

  ENDMETHOD.

  METHOD draft_keep.

    DATA(lv_id) = CONV string( id ).
    IF lv_id IS INITIAL OR line_exists( mt_draft_keep[ table_line = lv_id ] ). "#EC CI_SORTSEQ
      RETURN.
    ENDIF.
    INSERT lv_id INTO TABLE mt_draft_keep.
    WHILE lines( mt_draft_keep ) > c_draft_keep_max.
      DELETE mt_draft_keep INDEX 1.
    ENDWHILE.

  ENDMETHOD.

  METHOD model_json_parse.

    DATA(lo_model) = create_model( ).
    lo_model->main_json_to_attri( model     = io_model
                                  iv_prefix = iv_path ).
    result = lo_model->mt_skipped.

  ENDMETHOD.

  METHOD model_json_stringify.

    result = create_model( )->main_json_stringify( ).

  ENDMETHOD.

  METHOD model_snapshot.

    result = create_model( )->main_snapshot( ).

  ENDMETHOD.

  METHOD model_snapshot_changed.

    result = create_model( )->main_snapshot_changed( snapshot ).

  ENDMETHOD.

  METHOD draft_parse.

    DATA(ls_db) = z2ui5_cl_ui5_srv_draft=>get_instance( )->read_draft( iv_id ).
    result = all_xml_parse( ls_db-data ).

  ENDMETHOD.

  METHOD create_model.

    result = NEW z2ui5_cl_ui5_srv_model( attri = mt_attri
                                         app   = mo_app ).

  ENDMETHOD.
ENDCLASS.
