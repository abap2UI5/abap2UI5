class Z2UI5_CL_CORE_DRAFT_SRV definition
  public
  final
  create public .

public section.

  methods CREATE
    importing
      !DRAFT type Z2UI5_IF_TYPES=>TY_S_DRAFT
      !MODEL_XML type CLIKE .
  methods READ_DRAFT
    importing
      !ID type CLIKE
    returning
      value(RESULT) type Z2UI5_IF_CORE_TYPES=>TY_S_DB .
  methods READ_INFO
    importing
      !ID type CLIKE
    returning
      value(RESULT) type Z2UI5_IF_TYPES=>TY_S_DRAFT .
  methods CLEANUP .
  PROTECTED SECTION.

    METHODS read
      IMPORTING
        !id             TYPE clike
        !check_load_app TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(result)   TYPE z2ui5_if_core_types=>ty_s_db.

  PRIVATE SECTION.
ENDCLASS.



CLASS Z2UI5_CL_CORE_DRAFT_SRV IMPLEMENTATION.


  METHOD cleanup.

    DATA(lv_four_hours_ago) = z2ui5_cl_util=>time_substract_seconds(
        time = z2ui5_cl_util=>time_get_timestampl( )
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
        uname             = z2ui5_cl_util=>user_get_tech( )
        timestampl        = z2ui5_cl_util=>time_get_timestampl( )
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
*      ASSERT 1 = 0.
      RAISE EXCEPTION TYPE z2ui5_cx_util_error
        EXPORTING
          val = `NO_DRAFT_ENTRY_OF_PREVIOUS_REQUEST_FOUND`.
    ENDIF.

  ENDMETHOD.


  METHOD read_draft.

    result = read( id ).

  ENDMETHOD.


  METHOD read_info.

    data(ls_db) = read(
      id             = id
      check_load_app = abap_false ).

    result = CORRESPONDING #( ls_db ).

  ENDMETHOD.
ENDCLASS.
