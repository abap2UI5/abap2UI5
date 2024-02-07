CLASS z2ui5_cl_core_app DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_serializable_object .

    DATA mt_attri TYPE z2ui5_if_core_types=>ty_t_attri .
    DATA mo_app TYPE REF TO object .
    DATA ms_draft TYPE z2ui5_if_types=>ty_s_get-s_draft .

    METHODS attri_get_by_data
      IMPORTING
        !val          TYPE data
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_if_core_types=>ty_s_attri .

    METHODS model_json_stringify
      RETURNING
        VALUE(result) TYPE string .

    METHODS model_json_parse
      IMPORTING
        !view          TYPE string
        !io_json_model TYPE REF TO z2ui5_if_ajson .

    METHODS all_xml_stringify
      RETURNING
        VALUE(result) TYPE string .

    CLASS-METHODS all_xml_parse
      IMPORTING
        !val          TYPE string
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_core_app .

    CLASS-METHODS db_load
      IMPORTING
        !id           TYPE string
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_core_app .

    METHODS db_save.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_core_app IMPLEMENTATION.


  METHOD all_xml_parse.

    z2ui5_cl_util_func=>xml_parse(
        EXPORTING
            xml = val
        IMPORTING
            any = result ).

    LOOP AT result->mt_attri REFERENCE INTO DATA(lr_attri)
        WHERE data_rtti IS NOT INITIAL
          AND type_kind = cl_abap_classdescr=>typekind_dref.

      DATA(lv_assign) = 'RESULT->MO_APP->' && lr_attri->name.
      ASSIGN (lv_assign) TO FIELD-SYMBOL(<val>).
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE z2ui5_cx_util_error
          EXPORTING
            val = `LOAD_DRAFT_FROM_DATABASE_FAILED / ATTRI_NOT_FOUND ` && lr_attri->name.
      ENDIF.

      z2ui5_cl_util_func=>xml_srtti_parse(
        EXPORTING
          rtti_data = lr_attri->data_rtti
         IMPORTING
           e_data   = <val> ).

      CLEAR lr_attri->data_rtti.
    ENDLOOP.

  ENDMETHOD.


  METHOD all_xml_stringify.

    TRY.

        LOOP AT mt_attri REFERENCE INTO DATA(lr_attri).
          CLEAR lr_attri->r_ref.
          IF lr_attri->bind_type = z2ui5_if_core_types=>cs_bind_type-one_time.
            DELETE mt_attri.
          ENDIF.
        ENDLOOP.

        result = z2ui5_cl_util_func=>xml_stringify( me ).
        RETURN.

      CATCH cx_xslt_serialization_error INTO DATA(x).
    ENDTRY.

    TRY.

        LOOP AT mt_attri REFERENCE INTO lr_attri
            WHERE type_kind = cl_abap_classdescr=>typekind_dref.

          DATA(lv_name) = `MO_APP->` && lr_attri->name && `->*`.
          DATA(lv_name2) = `MO_APP->` && lr_attri->name.
          ASSIGN (lv_name) TO FIELD-SYMBOL(<val>).
          ASSIGN (lv_name2) TO FIELD-SYMBOL(<val_ref>).

          lr_attri->data_rtti = z2ui5_cl_util_func=>xml_srtti_stringify( <val> ).

          CLEAR <val>.
          CLEAR <val_ref>.
        ENDLOOP.

        LOOP AT mt_attri REFERENCE INTO lr_attri.
          CLEAR lr_attri->r_ref.
        ENDLOOP.

        result = z2ui5_cl_util_func=>xml_stringify( me ).

      CATCH cx_root INTO DATA(x2).

        RAISE EXCEPTION TYPE z2ui5_cx_util_error
          EXPORTING
            val = `<p>` && x->previous->get_text( ) && `<p>` && x2->get_text( ) && `<p> Please check if all generic data references are public attributes of your class`.

    ENDTRY.

  ENDMETHOD.


  METHOD attri_get_by_data.

    DATA(lr_data) = REF #( val ).

    DO 3 TIMES.

      TRY.
          result = REF #( mt_attri[ r_ref = lr_data ] ).
          RETURN.
        CATCH cx_root.
      ENDTRY.

      DATA(lo_dissolver) = NEW z2ui5_cl_core_model_srv(
        attri = REF #( mt_attri )
        app = mo_app ).
      lo_dissolver->main( ).

    ENDDO.

    RAISE EXCEPTION TYPE z2ui5_cx_util_error
      EXPORTING
        val = `BINDING_ERROR - No class attribute for binding found - Please check if the binded values are public attributes of your class or switch to bind_local`.

  ENDMETHOD.


  METHOD db_load.

    DATA(lo_db) = NEW z2ui5_cl_core_draft_srv( ).
    DATA(ls_db) = lo_db->read_draft( id ).
    result = all_xml_parse( ls_db-data ).

  ENDMETHOD.


  METHOD db_save.


    IF mo_app IS BOUND.
      CAST z2ui5_if_app( mo_app )->id_draft = ms_draft-id.
    ENDIF.

    DATA(lo_db) = NEW z2ui5_cl_core_draft_srv( ).
    lo_db->create(
        draft     = ms_draft
        model_xml = all_xml_stringify( ) ).

  ENDMETHOD.


  METHOD model_json_parse.

    DATA(lo_dissolver) = NEW z2ui5_cl_core_model_srv(
        attri = REF #( mt_attri )
        app = mo_app ).
    lo_dissolver->set_attri_ready( ).

    DATA(lo_json_mapper) = NEW z2ui5_cl_core_json_srv( ).
    lo_json_mapper->model_client_to_server(
        view    = view
        t_attri = REF #( mt_attri )
        model   = io_json_model ).

  ENDMETHOD.


  METHOD model_json_stringify.

    DATA(lo_json_mapper) = NEW z2ui5_cl_core_json_srv( ).
    result = lo_json_mapper->model_server_to_client( mt_attri ).

  ENDMETHOD.
ENDCLASS.
