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

    "! Refresh z2ui5_if_app~id_draft on the wrapped app. Not a courtesy: it is
    "! the handle db_load_by_app( ) resolves an app reference by, so it has to
    "! follow ms_draft-id whenever that changes.
    METHODS app_refresh_draft_id.

    METHODS model_json_stringify
      RETURNING
        VALUE(result) TYPE string.

    METHODS model_json_parse
      IMPORTING
        io_model TYPE REF TO z2ui5_if_ajson.

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

    DATA lo_model TYPE REF TO z2ui5_cl_ui5_srv_model.
    DATA lv_restored TYPE abap_bool VALUE abap_true.
    DATA x_first TYPE REF TO cx_root.
        DATA x TYPE REF TO cx_root.
    DATA temp1 TYPE REF TO cx_root.
    lo_model = create_model( ).




    TRY.
        lo_model->main_attri_db_save_srtti( ).
        result = z2ui5_cl_ui5_util_context=>xml_stringify( me ).
        lo_model->main_attri_db_load( ).
        RETURN.
      CATCH cx_root INTO x_first.
        " main_attri_db_save_srtti clears the serialized data references -
        " restore them before the fallback below, otherwise the second
        " attempt would persist the half-cleared app state
        TRY.
            lo_model->main_attri_db_load( ).
          CATCH cx_root.
            lv_restored = abap_false.
        ENDTRY.
    ENDTRY.

    " the bare retry is only safe when the restore worked - serializing the
    " half-cleared state would SUCCEED and persist a draft with the cleared
    " drefs missing, discovered only on a later restore
    IF lv_restored = abap_true.
      TRY.
          result = z2ui5_cl_ui5_util_context=>xml_stringify( me ).
          RETURN.
        CATCH cx_root ##NO_HANDLER.
      ENDTRY.
    ENDIF.

    TRY.
        lo_model->main_attri_refresh( ).
        lo_model->main_attri_db_save_srtti( ).
        result = z2ui5_cl_ui5_util_context=>xml_stringify( me ).
        lo_model->main_attri_db_load( ).
        RETURN.

      CATCH cx_root INTO x.
    ENDTRY.

    " chain the FIRST serialization failure - it names the attribute/type
    " that is not serializable and carries the source position of the
    " transformation that gave up; the retries fail for the same root cause
    " or a follow-up one

    IF x_first IS BOUND.
      temp1 = x_first.
    ELSE.
      temp1 = x.
    ENDIF.
    RAISE EXCEPTION TYPE z2ui5_cx_ui5_util_error
      EXPORTING
        val      = |APP_SERIALIZATION_ERROR - the app state could not be serialized. | &&
                   |Please check if all generic data references are public attributes of your class|
        previous = temp1.

  ENDMETHOD.

  METHOD constructor.

    CREATE DATA mt_attri.

  ENDMETHOD.

  METHOD db_load.

    DATA temp2 TYPE string.
    DATA lv_id LIKE temp2.
    DATA lr_buf TYPE REF TO z2ui5_cl_ui5_app_cont=>ty_s_buffer.
    DATA lo_db TYPE REF TO z2ui5_cl_ui5_srv_draft.
    DATA ls_db TYPE z2ui5_t_01.
    DATA temp3 TYPE z2ui5_cl_ui5_app_cont=>ty_s_buffer.
    temp2 = id.

    lv_id = temp2.


    READ TABLE mt_buffer REFERENCE INTO lr_buf WITH KEY id = lv_id.
    IF sy-subrc = 0.
      result = lr_buf->app.
      RETURN.
    ENDIF.


    CREATE OBJECT lo_db TYPE z2ui5_cl_ui5_srv_draft.

    ls_db = lo_db->read_draft( id ).
    result = all_xml_parse( ls_db-data ).

    result->create_model( )->main_attri_db_load( ).


    CLEAR temp3.
    temp3-id = lv_id.
    temp3-app = result.
    INSERT temp3 INTO TABLE mt_buffer.

  ENDMETHOD.

  METHOD db_load_buffer_clear.

    CLEAR mt_buffer.

  ENDMETHOD.

  METHOD db_load_by_app.

    DATA lo_db TYPE REF TO z2ui5_cl_ui5_srv_draft.
    DATA ls_db TYPE z2ui5_t_01.
    CREATE OBJECT lo_db TYPE z2ui5_cl_ui5_srv_draft.

    ls_db = lo_db->read_draft( app->id_draft ).
    result = all_xml_parse( ls_db-data ).

    result->mo_app = app.
    result->create_model( )->main_attri_db_load( ).

  ENDMETHOD.

  METHOD app_refresh_draft_id.
    DATA temp4 TYPE REF TO z2ui5_if_app.

    IF mo_app IS NOT BOUND.
      RETURN.
    ENDIF.


    temp4 ?= mo_app.
    temp4->id_draft = ms_draft-id.

  ENDMETHOD.

  METHOD db_save.
    DATA lo_db TYPE REF TO z2ui5_cl_ui5_srv_draft.

    IF mo_app IS BOUND.
      mv_check_initialized = abap_true.
      app_refresh_draft_id( ).
    ENDIF.


    CREATE OBJECT lo_db TYPE z2ui5_cl_ui5_srv_draft.
    lo_db->create( draft     = ms_draft
                   model_xml = all_xml_stringify( ) ).

  ENDMETHOD.

  METHOD model_json_parse.

    create_model( )->main_json_to_attri( io_model ).

  ENDMETHOD.

  METHOD model_json_stringify.

    result = create_model( )->main_json_stringify( ).

  ENDMETHOD.

  METHOD create_model.

    CREATE OBJECT result TYPE z2ui5_cl_ui5_srv_model EXPORTING attri = mt_attri app = mo_app.

  ENDMETHOD.
ENDCLASS.
