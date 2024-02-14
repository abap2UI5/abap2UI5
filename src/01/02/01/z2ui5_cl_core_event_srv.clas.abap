CLASS z2ui5_cl_core_event_srv DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS get_event
      IMPORTING
        !val                TYPE clike OPTIONAL
        !check_view_destroy TYPE abap_bool DEFAULT abap_false
        !t_arg              TYPE string_table OPTIONAL
          PREFERRED PARAMETER val
      RETURNING
        VALUE(result)       TYPE string.

    METHODS get_event_client
      IMPORTING
        !val          TYPE clike
        !t_arg        TYPE string_table OPTIONAL
      RETURNING
        VALUE(result) TYPE string.

  PROTECTED SECTION.

    METHODS get_t_arg
      IMPORTING
        val           TYPE string_table
      RETURNING
        VALUE(result) TYPE string.

  PRIVATE SECTION.
ENDCLASS.


CLASS z2ui5_cl_core_event_srv IMPLEMENTATION.

  METHOD get_event.

    result = |{ z2ui5_if_core_types=>cs_ui5-event_backend_function }(['{ val }'{ COND #( WHEN check_view_destroy = abap_true THEN `,true`) }]|.
    result = result && get_t_arg( t_arg ).

  ENDMETHOD.


  METHOD get_event_client.

    result = |{ z2ui5_if_core_types=>cs_ui5-event_frontend_function }('{ val }'|.
    result = result && get_t_arg( t_arg ).

  ENDMETHOD.


  METHOD get_t_arg.

    IF val IS NOT INITIAL.

      LOOP AT val REFERENCE INTO DATA(lr_arg).
        DATA(lv_new) = lr_arg->*.
        IF lv_new IS INITIAL.
          CONTINUE.
        ENDIF.
        IF lv_new(1) <> `$` AND lv_new(1) <> `{`.
          lv_new = `"` && lv_new && `"`.
        ENDIF.
        result = result && `, ` && lv_new.
      ENDLOOP.

    ENDIF.

    result = result && `)`.

  ENDMETHOD.
ENDCLASS.
