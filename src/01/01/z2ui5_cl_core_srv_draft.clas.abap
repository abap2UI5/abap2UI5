CLASS z2ui5_cl_core_srv_draft DEFINITION PUBLIC FINAL.

  PUBLIC SECTION.
    CONSTANTS c_seconds_per_hour TYPE i VALUE 3600.
    CONSTANTS c_min_exp_time_in_hours TYPE i VALUE 1.

    TYPES ty_s_db TYPE z2ui5_t_01.

    METHODS count_entries
      RETURNING
        VALUE(result) TYPE i.

    METHODS create
      IMPORTING
        draft     TYPE z2ui5_if_types=>ty_s_draft
        model_xml TYPE clike.

    METHODS read_draft
      IMPORTING
        id            TYPE clike
      RETURNING
        VALUE(result) TYPE ty_s_db.

    METHODS read_info
      IMPORTING
        id            TYPE clike
      RETURNING
        VALUE(result) TYPE z2ui5_if_types=>ty_s_draft.

    METHODS check_exists
      IMPORTING
        id            TYPE clike
      RETURNING
        VALUE(result) TYPE abap_bool.

    METHODS cleanup.

  PROTECTED SECTION.
    METHODS read
      IMPORTING
        id             TYPE clike
        check_load_app TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(result)  TYPE ty_s_db.

  PRIVATE SECTION.
ENDCLASS.


CLASS z2ui5_cl_core_srv_draft IMPLEMENTATION.

  METHOD cleanup.

    DATA(ls_config) = VALUE z2ui5_if_types=>ty_s_http_config_post( ).
    z2ui5_cl_exit=>get_instance( )->set_config_http_post( CHANGING cs_config = ls_config ).

    DATA(lv_exp_time_in_hours) = ls_config-draft_exp_time_in_hours.
    IF lv_exp_time_in_hours < c_min_exp_time_in_hours.
      lv_exp_time_in_hours = c_min_exp_time_in_hours.
    ENDIF.

    DATA(lv_n_hours_ago) = z2ui5_cl_a2ui5_context=>time_subtract_seconds(
                               time    = z2ui5_cl_a2ui5_context=>time_get_timestampl( )
                               seconds = c_seconds_per_hour * lv_exp_time_in_hours ).

    DELETE FROM z2ui5_t_01 WHERE timestampl < @lv_n_hours_ago ##SUBRC_OK.
    COMMIT WORK.

  ENDMETHOD.

  METHOD create.

    ASSERT draft-id IS NOT INITIAL.

    DATA(ls_db) = VALUE ty_s_db( id                = draft-id
                                 id_prev           = draft-id_prev
                                 id_prev_app       = draft-id_prev_app
                                 id_prev_app_stack = draft-id_prev_app_stack
                                 timestampl        = z2ui5_cl_a2ui5_context=>time_get_timestampl( )
                                 data              = model_xml ).

    MODIFY z2ui5_t_01 FROM @ls_db.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE z2ui5_cx_a2ui5_error
        EXPORTING val = `CREATE_OF_DRAFT_ENTRY_ON_DATABASE_FAILED`.
    ENDIF.
    COMMIT WORK AND WAIT.

  ENDMETHOD.

  METHOD read.

    IF check_load_app = abap_true.

      " sy-subrc is checked after ENDIF, the pragma silences check_subrc here
      SELECT SINGLE * FROM z2ui5_t_01
        WHERE id = @id
        INTO @result ##SUBRC_OK.

    ELSE.

      SELECT SINGLE id, id_prev, id_prev_app, id_prev_app_stack
        FROM z2ui5_t_01
        WHERE id = @id
        INTO CORRESPONDING FIELDS OF @result ##SUBRC_OK.

    ENDIF.

    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE z2ui5_cx_a2ui5_error
        EXPORTING val = `NO_DRAFT_ENTRY_OF_PREVIOUS_REQUEST_FOUND`.
    ENDIF.

  ENDMETHOD.

  METHOD read_draft.

    result = read( id ).

  ENDMETHOD.

  METHOD read_info.

    DATA(ls_db) = read( id             = id
                        check_load_app = abap_false ).

    result = CORRESPONDING #( ls_db ).

  ENDMETHOD.

  METHOD check_exists.

    SELECT SINGLE id FROM z2ui5_t_01
      WHERE id = @id
      INTO @DATA(lv_id) ##NEEDED.

    result = xsdbool( sy-subrc = 0 ).

  ENDMETHOD.

  METHOD count_entries.

    SELECT COUNT( * ) FROM z2ui5_t_01                   "#EC CI_NOWHERE
      INTO @result.

  ENDMETHOD.

ENDCLASS.
