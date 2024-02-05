CLASS z2ui5_cl_fw_hlp_db DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS create
      IMPORTING
        !draft    TYPE z2ui5_if_types=>ty_s_draft
        model_xml TYPE string.

    METHODS load_app
      IMPORTING
        !id           TYPE clike
      RETURNING
        VALUE(result) TYPE z2ui5_if_fw_types=>ty_s_db.

    METHODS read
      IMPORTING
        !id             TYPE clike
        !check_load_app TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(result)   TYPE z2ui5_if_fw_types=>ty_s_db.

    METHODS cleanup.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS Z2UI5_CL_FW_HLP_DB IMPLEMENTATION.


  METHOD cleanup.

    DATA(lv_four_hours_ago) = z2ui5_cl_util_func=>time_substract_seconds(
        time = z2ui5_cl_util_func=>time_get_timestampl( )
        seconds = 60 * 60 * 4 ).

    DELETE FROM z2ui5_t_fw_01 WHERE timestampl < @lv_four_hours_ago.
    COMMIT WORK.

  ENDMETHOD.


  METHOD create.

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


  METHOD load_app.

    result = read( id ).

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

ENDCLASS.
