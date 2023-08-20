CLASS z2ui5_cl_fw_db DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    TYPES:
      BEGIN OF ty_s_db,
        id                TYPE string,
        id_prev           TYPE string,
        id_prev_app       TYPE string,
        id_prev_app_stack TYPE string,
        BEGIN OF s_bind,
          t_attri     TYPE z2ui5_cl_fw_handler=>ty_t_attri,
        END OF s_bind,
        app               TYPE REF TO z2ui5_if_app,
      END OF ty_s_db.

    CLASS-METHODS create
      IMPORTING
        id TYPE string
        db TYPE ty_s_db.

    CLASS-METHODS load_app
      IMPORTING
        id            TYPE clike
      RETURNING
        VALUE(result) TYPE ty_s_db.

    CLASS-METHODS read
      IMPORTING
        id             TYPE clike
        check_load_app TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(result)  TYPE z2ui5_t_draft.

    CLASS-METHODS cleanup.

ENDCLASS.



CLASS Z2UI5_CL_FW_DB IMPLEMENTATION.


  METHOD cleanup.

    DATA(lv_time) = z2ui5_cl_fw_utility=>get_timestampl( ).
    DATA(lv_four_hours_ago) = cl_abap_tstmp=>subtractsecs( tstmp = lv_time
                                                           secs  = 60 * 60 * 4 ).

    DELETE FROM z2ui5_t_draft WHERE timestampl < @lv_four_hours_ago.
    COMMIT WORK.

  ENDMETHOD.


  METHOD create.

    TRY.
        DATA(lv_xml) = z2ui5_cl_fw_utility=>trans_object_2_xml( REF #( db ) ).

      CATCH cx_xslt_serialization_error INTO DATA(x).
        TRY.

            DATA(ls_db) = db.
            DATA(lo_app) = CAST object( ls_db-app ).

            IF NOT line_exists( ls_db-s_bind-t_attri[ type_kind = cl_abap_classdescr=>typekind_dref ] ).
              RAISE EXCEPTION x.
            ENDIF.

            lo_app = CAST object( ls_db-app ).
            LOOP AT ls_db-s_bind-t_attri REFERENCE INTO DATA(lr_attri) WHERE type_kind = cl_abap_classdescr=>typekind_dref.

              DATA(lv_assign) = 'LO_APP->' && lr_attri->name.
              FIELD-SYMBOLS <attri> TYPE any.
              FIELD-SYMBOLS <deref_attri> TYPE any.
              ASSIGN (lv_assign) TO <attri>.
              ASSIGN <attri>->* TO <deref_attri>.

              lr_attri->data_rtti = z2ui5_cl_fw_utility=>rtti_get( <deref_attri> ).
              CLEAR <deref_attri>.
              CLEAR <attri>.

            ENDLOOP.

            lv_xml = z2ui5_cl_fw_utility=>trans_object_2_xml( REF #( ls_db ) ).

          CATCH cx_root INTO DATA(x2).

            RAISE EXCEPTION TYPE z2ui5_cl_fw_error
              EXPORTING
                val = x->get_text( ) && `<p>` && x->previous->get_text( ) && `<p>` && x2->get_text( ).

        ENDTRY.
    ENDTRY.

    DATA(ls_draft) = VALUE z2ui5_t_draft( uuid                = id
                                          uuid_prev           = db-id_prev
                                          uuid_prev_app       = db-id_prev_app
                                          uuid_prev_app_stack = db-id_prev_app_stack
                                          uname               = z2ui5_cl_fw_utility=>get_user_tech( )
                                          timestampl          = z2ui5_cl_fw_utility=>get_timestampl( )
                                          data                = lv_xml ).

    MODIFY z2ui5_t_draft FROM @ls_draft.
    z2ui5_cl_fw_utility=>raise( when = xsdbool( sy-subrc <> 0 ) ).
    COMMIT WORK AND WAIT.

  ENDMETHOD.


  METHOD load_app.

    DATA(ls_db) = read( id ).

    z2ui5_cl_fw_utility=>trans_xml_2_object(
        EXPORTING
            xml  = ls_db-data
        IMPORTING
            data = result ).

    LOOP AT result-s_bind-t_attri TRANSPORTING NO FIELDS WHERE data_rtti <> ``.
      DATA(lv_check_rtti) = abap_true.
    ENDLOOP.
    IF lv_check_rtti = abap_false.
      RETURN.
    ENDIF.

    DATA(lo_app) = CAST object( result-app ) ##NEEDED.
    LOOP AT result-s_bind-t_attri REFERENCE INTO DATA(lr_attri) WHERE type_kind = cl_abap_classdescr=>typekind_dref.

      FIELD-SYMBOLS <ref> TYPE any.
      DATA(lv_assign) = 'LO_APP->' && lr_attri->name.
      ASSIGN (lv_assign) TO <ref>.

      z2ui5_cl_fw_utility=>rtti_set(
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
        FROM z2ui5_t_draft
        WHERE uuid = @id
        INTO @result.

    ELSE.

      SELECT SINGLE uuid, uuid_prev, uuid_prev_app, uuid_prev_app_stack
        FROM z2ui5_t_draft
        WHERE uuid = @id
        INTO CORRESPONDING FIELDS OF @result.

    ENDIF.

    z2ui5_cl_fw_utility=>raise( when = xsdbool( sy-subrc <> 0 ) ).

  ENDMETHOD.
ENDCLASS.
