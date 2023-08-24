CLASS z2ui5_cl_fw_db DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:
      BEGIN OF ty_s_db,
        id                TYPE string,
        id_prev           TYPE string,
        id_prev_app       TYPE string,
        id_prev_app_stack TYPE string,
        t_attri           TYPE z2ui5_cl_fw_binding=>ty_t_attri,
        app               TYPE REF TO z2ui5_if_app,
      END OF ty_s_db .

    CLASS-METHODS create
      IMPORTING
        !id TYPE string
        !db TYPE ty_s_db .
    CLASS-METHODS load_app
      IMPORTING
        !id           TYPE clike
      RETURNING
        VALUE(result) TYPE ty_s_db .

    CLASS-METHODS read
      IMPORTING
        !id             TYPE clike
        !check_load_app TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(result)   TYPE z2ui5_t_draft .

    CLASS-METHODS cleanup.

    CLASS-METHODS trans_any_2_xml
      IMPORTING
        !db           TYPE ty_s_db
      RETURNING
        VALUE(result) TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_fw_db IMPLEMENTATION.


  METHOD cleanup.

    DATA(lv_time) = z2ui5_cl_fw_utility=>time_get_timestampl( ).


    DATA(lv_four_hours_ago) = z2ui5_cl_fw_utility=>time_substract_seconds(
                                time    = lv_time
                                seconds = 60 * 60 * 4
                              ).

    DELETE FROM z2ui5_t_draft WHERE timestampl < @lv_four_hours_ago.
    COMMIT WORK.

  ENDMETHOD.


  METHOD create.

    DATA(lv_xml) = trans_any_2_xml( db ).

    DATA(ls_draft) = VALUE z2ui5_t_draft( uuid                = id
                                          uuid_prev           = db-id_prev
                                          uuid_prev_app       = db-id_prev_app
                                          uuid_prev_app_stack = db-id_prev_app_stack
                                          uname               = z2ui5_cl_fw_utility=>func_get_user_tech( )
                                          timestampl          = z2ui5_cl_fw_utility=>time_get_timestampl( )
                                          data                = lv_xml ).

    MODIFY z2ui5_t_draft FROM @ls_draft.
    z2ui5_cl_fw_utility=>x_check_raise( when = xsdbool( sy-subrc <> 0 ) ).
    COMMIT WORK AND WAIT.

  ENDMETHOD.


  METHOD load_app.

    DATA(ls_db) = read( id ).

    z2ui5_cl_fw_utility=>trans_xml_2_any(
        EXPORTING
            xml  = ls_db-data
        IMPORTING
            any = result ).

    LOOP AT result-t_attri TRANSPORTING NO FIELDS WHERE data_rtti <> ``.
      DATA(lv_check_rtti) = abap_true.
    ENDLOOP.
    IF lv_check_rtti = abap_false.
      RETURN.
    ENDIF.

    DATA(lo_app) = CAST object( result-app ) ##NEEDED.
    LOOP AT result-t_attri REFERENCE INTO DATA(lr_attri) WHERE type_kind = cl_abap_classdescr=>typekind_dref.

      FIELD-SYMBOLS <ref> TYPE any.
      DATA(lv_assign) = 'LO_APP->' && lr_attri->name.
      ASSIGN (lv_assign) TO <ref>.

      z2ui5_cl_fw_utility=>rtti_xml_set_to_data(
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

    z2ui5_cl_fw_utility=>x_check_raise( when = xsdbool( sy-subrc <> 0 ) ).

  ENDMETHOD.


  METHOD trans_any_2_xml.

    TRY.
        result = z2ui5_cl_fw_utility=>trans_xml_any_2( db ).

      CATCH cx_xslt_serialization_error INTO DATA(x).
        TRY.

            DATA(ls_db) = db.
            DATA(lo_app) = CAST object( ls_db-app ).

            IF NOT line_exists( ls_db-t_attri[ type_kind = cl_abap_classdescr=>typekind_dref ] ).

              ls_db-t_attri = z2ui5_cl_fw_binding=>update_attri(
                  t_attri = ls_db-t_attri
                  app     = ls_db-app
              ).

            ENDIF.

            lo_app = CAST object( ls_db-app ).
            LOOP AT ls_db-t_attri REFERENCE INTO DATA(lr_attri) WHERE type_kind = cl_abap_classdescr=>typekind_dref.

              DATA(lv_assign) = 'LO_APP->' && lr_attri->name.
              FIELD-SYMBOLS <attri> TYPE any.
              FIELD-SYMBOLS <deref_attri> TYPE any.
              ASSIGN (lv_assign) TO <attri>.
              ASSIGN <attri>->* TO <deref_attri>.

              lr_attri->data_rtti = z2ui5_cl_fw_utility=>rtti_xml_get_by_data( <deref_attri> ).
              CLEAR <deref_attri>.
              CLEAR <attri>.

            ENDLOOP.

            result = z2ui5_cl_fw_utility=>trans_XML_any_2( REF #( ls_db ) ).

          CATCH cx_root INTO DATA(x2).

            RAISE EXCEPTION TYPE z2ui5_cx_fw_error
              EXPORTING
                val = x->get_text( ) && `<p>` && x->previous->get_text( ) && `<p>` && x2->get_text( ).

        ENDTRY.
    ENDTRY.

  ENDMETHOD.
ENDCLASS.
