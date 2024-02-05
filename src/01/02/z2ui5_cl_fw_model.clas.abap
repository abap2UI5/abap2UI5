CLASS z2ui5_cl_fw_model DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:
      BEGIN OF ty_s_test,
        app     TYPE REF TO if_serializable_object,
        t_attri TYPE z2ui5_if_fw_types=>ty_t_attri,
      END OF ty_s_test.

    DATA mt_attri TYPE z2ui5_if_fw_types=>ty_t_attri.
    DATA mo_app TYPE REF TO object.

    METHODS attri_get_by_data
      IMPORTING
        val           TYPE data
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_if_fw_types=>ty_s_attri.

    METHODS json_client_stringify
      RETURNING
        VALUE(result) TYPE string.
    METHODS json_client_parse
      IMPORTING
        viewname TYPE string
        o_model  TYPE REF TO z2ui5_if_ajson.

    METHODS xml_db_stringify
      RETURNING
        VALUE(result) TYPE string.

    METHODS xml_db_parse
      IMPORTING
        val           TYPE string
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_fw_model.

    METHODS attri_get_val_ref
      IMPORTING
        i_lr_bind     TYPE REF TO z2ui5_if_fw_types=>ty_s_attri
      RETURNING
        VALUE(result) TYPE REF TO data.

    METHODS attri_set_refs.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_fw_model IMPLEMENTATION.

  METHOD attri_get_by_data.

    DATA(lr_data) = REF #( val ).

    IF mt_attri IS INITIAL.
      DATA(lo_dissolver) =  NEW z2ui5_cl_fw_hlp_dissolver(
        attri = REF #( mt_attri )
        app = mo_app ).
      lo_dissolver->main( ).
    ENDIF.

    DO 2 TIMES.

      LOOP AT mt_attri REFERENCE INTO DATA(lr_bind)
          WHERE check_ready = abap_true
          AND depth < 5.

        IF lr_bind->r_ref IS NOT BOUND.
          lr_bind->r_ref = attri_get_val_ref( lr_bind ).
        ENDIF.

        IF lr_data = lr_bind->r_ref.
          result = lr_bind.
          RETURN.
        ENDIF.
      ENDLOOP.

      DATA(lo_dissolver_2) =  NEW z2ui5_cl_fw_hlp_dissolver(
         attri = REF #( mt_attri )
         app = mo_app ).
      lo_dissolver_2->main( ).

      LOOP AT mt_attri REFERENCE INTO lr_bind
          WHERE check_ready = abap_true
          AND depth >= 5.

        IF lr_bind->r_ref IS NOT BOUND.
          lr_bind->r_ref = attri_get_val_ref( lr_bind ).
        ENDIF.

        IF lr_data = lr_bind->r_ref.
          result = lr_bind.
          RETURN.
        ENDIF.
      ENDLOOP.

    ENDDO.

    RAISE EXCEPTION TYPE z2ui5_cx_util_error
      EXPORTING
        val = `BINDING_ERROR - No class attribute for binding found - Please check if the binded values are public attributes of your class or switch to bind_local`.

  ENDMETHOD.


  METHOD attri_get_val_ref.

    FIELD-SYMBOLS <attri> TYPE any.
    DATA(lv_name) = `MO_APP->` && i_lr_bind->name.
    DATA lr_ref TYPE REF TO data.
    ASSIGN (lv_name) TO <attri>.
    ASSERT sy-subrc = 0.

    GET REFERENCE OF <attri> INTO result.
    ASSERT sy-subrc = 0.

  ENDMETHOD.


  METHOD json_client_parse.

    attri_set_refs( ).

    NEW z2ui5_cl_fw_hlp_json_mapper(
            )->model_client_to_server(
                view    = viewname
                t_attri = REF #( mt_attri )
                model   = o_model ).

  ENDMETHOD.


  METHOD json_client_stringify.

    result = NEW z2ui5_cl_fw_hlp_json_mapper(
            )->model_server_to_client( mt_attri ).

  ENDMETHOD.


  METHOD xml_db_parse.

    DATA lo_model TYPE REF TO z2ui5_cl_fw_model.

  DATA(ls_db) = VALUE ty_s_test( ).

    z2ui5_cl_util_func=>trans_xml_2_any(
        EXPORTING
            xml = val
        IMPORTING
            any = ls_db ).




    mo_app = ls_db-app.
    mt_attri = ls_db-t_attri.

*    DATA(lo_app) = CAST object( result-app ) ##NEEDED.
*    LOOP AT result-t_attri REFERENCE INTO DATA(lr_attri)
*        WHERE data_rtti IS NOT INITIAL
*          AND type_kind = cl_abap_classdescr=>typekind_dref.
*
*      DATA(lv_assign) = 'LO_APP->' && lr_attri->name.
*      ASSIGN (lv_assign) TO <ref>.
*      IF sy-subrc <> 0.
*        RAISE EXCEPTION TYPE z2ui5_cx_util_error
*          EXPORTING
*            val = `LOAD_DRAFT_FROM_DATABASE_FAILED / ATTRI_NOT_FOUND ` && lr_attri->name.
*      ENDIF.
*
*      z2ui5_cl_util_func=>trans_srtti_xml_2_data(
*        EXPORTING
*          rtti_data = lr_attri->data_rtti
*         IMPORTING
*           e_data   = <ref> ).
*
*      CLEAR lr_attri->data_rtti.
*    ENDLOOP.

  ENDMETHOD.

  METHOD xml_db_stringify.

    FIELD-SYMBOLS <attri> TYPE any.
    FIELD-SYMBOLS <deref_attri> TYPE any.

    TRY.

        DATA(ls_db) = VALUE ty_s_test(
            t_attri = mt_attri
            app = CAST #( mo_app )
        ).

        result = z2ui5_cl_util_func=>trans_xml_by_any( ls_db ).

      CATCH cx_xslt_serialization_error INTO DATA(x).
*        TRY.
*
*            DATA(ls_db) = db.
*            DATA(lo_app) = CAST object( ls_db-app ).
*
*            IF NOT line_exists( ls_db-t_attri[ type_kind = cl_abap_classdescr=>typekind_dref ] ).
*
*              ASSERT 1 = 0.
*              ls_db-t_attri = z2ui5_cl_fw_binding=>update_attri(
*                  t_attri = ls_db-t_attri
*                  app     = ls_db-app ).
*
*            ENDIF.
*
*            lo_app = CAST object( ls_db-app ).
*            LOOP AT ls_db-t_attri REFERENCE INTO DATA(lr_attri) WHERE type_kind = cl_abap_classdescr=>typekind_dref.
*
*              DATA(lv_assign) = 'LO_APP->' && lr_attri->name.
*
*              UNASSIGN <deref_attri>.
*              UNASSIGN <attri>.
*              ASSIGN (lv_assign) TO <attri>.
*              ASSIGN <attri>->* TO <deref_attri>.
*              IF sy-subrc <> 0.
*                CONTINUE.
*              ENDIF.
*
*              lr_attri->data_rtti = z2ui5_cl_util_func=>trans_srtti_xml_by_data( <deref_attri> ).
*
*              CLEAR <deref_attri>.
*              CLEAR <attri>.
*            ENDLOOP.
*
*            result = z2ui5_cl_util_func=>trans_xml_by_any( ls_db ).
*
*          CATCH z2ui5_cx_util_error INTO DATA(x_util).
*            RAISE EXCEPTION x_util.
*
*          CATCH cx_root INTO DATA(x2).
*
*            RAISE EXCEPTION TYPE z2ui5_cx_util_error
*              EXPORTING
*                val = `<p>` && x->previous->get_text( ) && `<p>` && x2->get_text( ) && `<p> Please check if all generic data references are public attributes of your class`.
*
*        ENDTRY.
    ENDTRY.


  ENDMETHOD.

  METHOD attri_set_refs.

    LOOP AT mt_attri REFERENCE INTO DATA(lr_attri)
    WHERE bind_type IS NOT INITIAL.
      lr_attri->r_ref = attri_get_val_ref( lr_attri ).
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
