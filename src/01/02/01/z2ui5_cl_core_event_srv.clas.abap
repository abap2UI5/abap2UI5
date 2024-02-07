class Z2UI5_CL_CORE_EVENT_SRV definition
  public
  final
  create public .

public section.

  methods GET_EVENT
    importing
      !VAL type CLIKE optional
      !CHECK_VIEW_DESTROY type ABAP_BOOL default ABAP_FALSE
      !T_ARG type STRING_TABLE optional
    preferred parameter VAL
    returning
      value(RESULT) type STRING .
  methods GET_EVENT_CLIENT
    importing
      !VAL type CLIKE
      !T_ARG type STRING_TABLE optional
    returning
      value(RESULT) type STRING .
  PROTECTED SECTION.

    METHODS get_t_arg
      IMPORTING
        val           TYPE string_table
      RETURNING
        VALUE(result) TYPE string.

  PRIVATE SECTION.
ENDCLASS.



CLASS Z2UI5_CL_CORE_EVENT_SRV IMPLEMENTATION.


  METHOD get_event.

    result = `onEvent(  { 'EVENT' : '` && val && `', 'METHOD' : 'UPDATE' , 'CHECK_VIEW_DESTROY' : ` && z2ui5_cl_util_func=>boolean_abap_2_json( check_view_destroy ) && ` }`.
    result = result && get_t_arg( t_arg ).

  ENDMETHOD.


  METHOD get_event_client.

    result = `onEventFrontend( { 'EVENT' : '` && val && `' }` && get_t_arg( t_arg ).

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
