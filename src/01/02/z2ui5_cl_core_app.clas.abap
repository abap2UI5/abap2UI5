CLASS z2ui5_cl_core_app DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    INTERFACES if_serializable_object.

    DATA mt_attri TYPE REF TO z2ui5_if_core_types=>ty_t_attri.
    DATA mo_app   TYPE REF TO object.
    DATA ms_draft TYPE z2ui5_if_types=>ty_s_get-s_draft.

    METHODS model_json_stringify
      RETURNING
        VALUE(result) TYPE string.

    METHODS model_json_parse
      IMPORTING
        iv_view  TYPE clike
        io_model TYPE REF TO z2ui5_if_ajson.

    METHODS all_xml_stringify
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS all_xml_parse
      IMPORTING
        !xml          TYPE clike
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_core_app.

    CLASS-METHODS db_load
      IMPORTING
        !id           TYPE clike
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_core_app.

    CLASS-METHODS db_load_by_app
      IMPORTING
        app           TYPE REF TO z2ui5_if_app
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_core_app.

    METHODS constructor.
    METHODS db_save.

  PROTECTED SECTION.

  PRIVATE SECTION.
ENDCLASS.


CLASS z2ui5_cl_core_app IMPLEMENTATION.

  METHOD all_xml_parse.

    z2ui5_cl_util=>xml_parse( EXPORTING xml = xml
                              IMPORTING any = result ).

  ENDMETHOD.

  METHOD all_xml_stringify.

    DATA(lo_dissolver) = NEW z2ui5_cl_core_srv_model( attri = mt_attri
                                                     app    = mo_app ).

    TRY.
        result = z2ui5_cl_util=>xml_stringify( me ).
        RETURN.
      CATCH cx_root.
    ENDTRY.

    TRY.
        lo_dissolver->main_attri_db_save_srtti( ).
        result = z2ui5_cl_util=>xml_stringify( me ).
*        if mo_app->client->ms_next-o_app_call.
        lo_dissolver->main_attri_db_load( ).
*        endif.
        RETURN.
      CATCH cx_root.
    ENDTRY.

    TRY.
        lo_dissolver->main_attri_refresh( ).
        lo_dissolver->main_attri_db_save_srtti( ).
        result = z2ui5_cl_util=>xml_stringify( me ).
*         if mo_app->client->ms_next-o_app_call.
        lo_dissolver->main_attri_db_load( ).
*        endif.
        RETURN.
      CATCH cx_root INTO DATA(x).
    ENDTRY.

    RAISE EXCEPTION TYPE z2ui5_cx_util_error
      EXPORTING
        val = |<p>{ x->get_text( ) } or <p> Please check if all generic data references are public attributes of your class|.

  ENDMETHOD.

  METHOD constructor.

    CREATE DATA mt_attri.

  ENDMETHOD.

  METHOD db_load.

    DATA(lo_db) = NEW z2ui5_cl_core_srv_draft( ).
    DATA(ls_db) = lo_db->read_draft( id ).
    result = all_xml_parse( ls_db-data ).

    DATA(lo_model) = NEW z2ui5_cl_core_srv_model( attri = result->mt_attri
                                                  app   = result->mo_app ).

    lo_model->main_attri_db_load( ).

  ENDMETHOD.

  METHOD db_load_by_app.

    DATA(lo_db) = NEW z2ui5_cl_core_srv_draft( ).
    DATA(ls_db) = lo_db->read_draft( app->id_draft ).
    result = all_xml_parse( ls_db-data ).

    result->mo_app = app.
    DATA(lo_model) = NEW z2ui5_cl_core_srv_model( attri = result->mt_attri
                                                  app   = result->mo_app ).

    lo_model->main_attri_db_load( ).

  ENDMETHOD.

  METHOD db_save.

    IF mo_app IS BOUND.
      CAST z2ui5_if_app( mo_app )->id_draft = ms_draft-id.
      CAST z2ui5_if_app( mo_app )->check_initialized = abap_true.
    ENDIF.

    DATA(lo_db) = NEW z2ui5_cl_core_srv_draft( ).
    lo_db->create( draft     = ms_draft
                   model_xml = all_xml_stringify( ) ).

  ENDMETHOD.

  METHOD model_json_parse.

    DATA(lo_json_mapper) = NEW z2ui5_cl_core_srv_model(
      attri = mt_attri
      app   = mo_app ).
    lo_json_mapper->main_json_to_attri(
        view  = iv_view
        model = io_model ).

  ENDMETHOD.

  METHOD model_json_stringify.

    DATA(lo_json_mapper) = NEW z2ui5_cl_core_srv_model(
      attri = mt_attri
      app   = mo_app ).

    result = lo_json_mapper->main_json_stringify( ).

  ENDMETHOD.
ENDCLASS.
