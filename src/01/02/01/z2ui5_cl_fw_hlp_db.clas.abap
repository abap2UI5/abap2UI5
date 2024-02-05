CLASS z2ui5_cl_fw_hlp_db DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CLASS-METHODS create2
      IMPORTING
        !draft    TYPE z2ui5_if_types=>ty_s_get-s_draft
        model_xml TYPE string.

    CLASS-METHODS create
      IMPORTING
        !id TYPE string
        !db TYPE z2ui5_if_fw_types=>ty_s_db.

    CLASS-METHODS load_app
      IMPORTING
        !id           TYPE clike
      RETURNING
        VALUE(result) TYPE z2ui5_if_fw_types=>ty_s_db.

    CLASS-METHODS load_app2
      IMPORTING
        !id           TYPE clike
      RETURNING
        VALUE(result) TYPE z2ui5_if_fw_types=>ty_s_db2.

    CLASS-METHODS read
      IMPORTING
        !id             TYPE clike
        !check_load_app TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(result)   TYPE z2ui5_if_fw_types=>ty_s_db2.

    CLASS-METHODS cleanup.

    CLASS-METHODS trans_any_2_xml
      IMPORTING
        !db           TYPE z2ui5_if_fw_types=>ty_s_db
      RETURNING
        VALUE(result) TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_fw_hlp_db IMPLEMENTATION.


  METHOD cleanup.

    DATA(lv_four_hours_ago) = z2ui5_cl_util_func=>time_substract_seconds(
        time = z2ui5_cl_util_func=>time_get_timestampl( )
        seconds = 60 * 60 * 4 ).

    DELETE FROM z2ui5_t_fw_01 WHERE timestampl < @lv_four_hours_ago.
    COMMIT WORK.

  ENDMETHOD.


  METHOD create.

    db-app->id_draft = id.
    DATA(lv_xml) = trans_any_2_xml( db ).

    DATA(ls_draft) = VALUE z2ui5_if_fw_types=>ty_s_db2( id                = id
                                     id_prev           = db-id_prev
                                     id_prev_app       = db-id_prev_app
                                     id_prev_app_stack = db-id_prev_app_stack
                                     uname             = z2ui5_cl_util_func=>user_get_tech( )
                                     timestampl        = z2ui5_cl_util_func=>time_get_timestampl( )
                                     data              = lv_xml ).

    MODIFY z2ui5_t_fw_01 FROM @ls_draft.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE z2ui5_cx_util_error
        EXPORTING
          val = `CREATE_OF_DRAFT_ENTRY_ON_DATABASE_FAILED`.
    ENDIF.
    COMMIT WORK AND WAIT.

  ENDMETHOD.

  METHOD load_app2.

    result = read( id ).


  ENDMETHOD.


  METHOD load_app.

    DATA(ls_db) = read( id ).
    FIELD-SYMBOLS <ref> TYPE any.

    z2ui5_cl_util_func=>trans_xml_2_any(
        EXPORTING
            xml = ls_db-data
        IMPORTING
            any = result ).

    DATA(lo_app) = CAST object( result-app ) ##NEEDED.
    LOOP AT result-t_attri REFERENCE INTO DATA(lr_attri)
        WHERE data_rtti IS NOT INITIAL
          AND type_kind = cl_abap_classdescr=>typekind_dref.

      DATA(lv_assign) = 'LO_APP->' && lr_attri->name.
      ASSIGN (lv_assign) TO <ref>.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE z2ui5_cx_util_error
          EXPORTING
            val = `LOAD_DRAFT_FROM_DATABASE_FAILED / ATTRI_NOT_FOUND ` && lr_attri->name.
      ENDIF.

      z2ui5_cl_util_func=>trans_srtti_xml_2_data(
        EXPORTING
          rtti_data = lr_attri->data_rtti
         IMPORTING
           e_data   = <ref> ).

      CLEAR lr_attri->data_rtti.
    ENDLOOP.

  ENDMETHOD.


  METHOD read.

    IF check_load_app = abap_true.

      SELECT SINGLE *
        FROM z2ui5_t_fw_01
        WHERE id = @id
        INTO @result.

    ELSE.

      SELECT SINGLE id, id_prev, id_prev_app, id_prev_app_stack
        FROM z2ui5_t_fw_01
        WHERE id = @id
        INTO CORRESPONDING FIELDS OF @result.

    ENDIF.

    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE z2ui5_cx_util_error
        EXPORTING
          val = `NO_DRAFT_ENTRY_OF_PREVIOUS_REQUEST_FOUND`.
    ENDIF.

  ENDMETHOD.


  METHOD trans_any_2_xml.

    FIELD-SYMBOLS <attri> TYPE any.
    FIELD-SYMBOLS <deref_attri> TYPE any.

    TRY.
        result = z2ui5_cl_util_func=>trans_xml_by_any( db ).

      CATCH cx_xslt_serialization_error INTO DATA(x).
        TRY.

            DATA(ls_db) = db.
            DATA(lo_app) = CAST object( ls_db-app ).

            IF NOT line_exists( ls_db-t_attri[ type_kind = cl_abap_classdescr=>typekind_dref ] ).

              ASSERT 1 = 0.
*              ls_db-t_attri = z2ui5_cl_fw_binding=>update_attri(
*                  t_attri = ls_db-t_attri
*                  app     = ls_db-app ).

            ENDIF.

            lo_app = CAST object( ls_db-app ).
            LOOP AT ls_db-t_attri REFERENCE INTO DATA(lr_attri) WHERE type_kind = cl_abap_classdescr=>typekind_dref.

              DATA(lv_assign) = 'LO_APP->' && lr_attri->name.

              UNASSIGN <deref_attri>.
              UNASSIGN <attri>.
              ASSIGN (lv_assign) TO <attri>.
              ASSIGN <attri>->* TO <deref_attri>.
              IF sy-subrc <> 0.
                CONTINUE.
              ENDIF.

              lr_attri->data_rtti = z2ui5_cl_util_func=>trans_srtti_xml_by_data( <deref_attri> ).

              CLEAR <deref_attri>.
              CLEAR <attri>.
            ENDLOOP.

            result = z2ui5_cl_util_func=>trans_xml_by_any( ls_db ).

          CATCH z2ui5_cx_util_error INTO DATA(x_util).
            RAISE EXCEPTION x_util.

          CATCH cx_root INTO DATA(x2).

            RAISE EXCEPTION TYPE z2ui5_cx_util_error
              EXPORTING
                val = `<p>` && x->previous->get_text( ) && `<p>` && x2->get_text( ) && `<p> Please check if all generic data references are public attributes of your class`.

        ENDTRY.
    ENDTRY.

  ENDMETHOD.

  METHOD create2.

    DATA(ls_db) = VALUE z2ui5_t_fw_01(
        id                = draft-id
        id_prev           = draft-id_prev
        id_prev_app       = draft-id_prev_app
        id_prev_app_stack = draft-id_prev_app_stack
        uname             = z2ui5_cl_util_func=>user_get_tech( )
        timestampl        = z2ui5_cl_util_func=>time_get_timestampl( )
        data              = model_xml
     ).

    MODIFY z2ui5_t_fw_01 FROM @ls_db.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE z2ui5_cx_util_error
        EXPORTING
          val = `CREATE_OF_DRAFT_ENTRY_ON_DATABASE_FAILED`.
    ENDIF.
    COMMIT WORK AND WAIT.

  ENDMETHOD.

ENDCLASS.
