CLASS z2ui5_cx_ajson_error DEFINITION
  PUBLIC
  INHERITING FROM cx_static_check FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    INTERFACES if_t100_message.

    TYPES ty_rc TYPE c LENGTH 4.

    CONSTANTS:
      BEGIN OF zcx_ajson_error,
        msgid TYPE symsgid      VALUE '00',
        msgno TYPE symsgno      VALUE '001',
        attr1 TYPE scx_attrname VALUE 'A1',
        attr2 TYPE scx_attrname VALUE 'A2',
        attr3 TYPE scx_attrname VALUE 'A3',
        attr4 TYPE scx_attrname VALUE 'A4',
      END OF zcx_ajson_error.

    DATA rc       TYPE ty_rc  READ-ONLY.
    DATA message  TYPE string READ-ONLY.
    DATA location TYPE string READ-ONLY.
    DATA a1       TYPE symsgv READ-ONLY.
    DATA a2       TYPE symsgv READ-ONLY.
    DATA a3       TYPE symsgv READ-ONLY.
    DATA a4       TYPE symsgv READ-ONLY.

    METHODS constructor
      IMPORTING
        textid    LIKE if_t100_message=>t100key OPTIONAL
        !previous LIKE previous                 OPTIONAL
        !rc       TYPE ty_rc                    OPTIONAL
        !message  TYPE string                   OPTIONAL
        location  TYPE string                   OPTIONAL
        a1        TYPE symsgv                   OPTIONAL
        a2        TYPE symsgv                   OPTIONAL
        a3        TYPE symsgv                   OPTIONAL
        a4        TYPE symsgv                   OPTIONAL.

    CLASS-METHODS raise
      IMPORTING
        iv_msg      TYPE string
        iv_location TYPE string OPTIONAL
        is_node     TYPE any    OPTIONAL
      RAISING
        z2ui5_cx_ajson_error.

    METHODS set_location
      IMPORTING
        iv_location TYPE string OPTIONAL
        is_node     TYPE any    OPTIONAL
      PREFERRED PARAMETER iv_location.

  PROTECTED SECTION.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_message_parts,
        a1 LIKE a1,
        a2 LIKE a1,
        a3 LIKE a1,
        a4 LIKE a1,
      END OF ty_message_parts.
ENDCLASS.


CLASS z2ui5_cx_ajson_error IMPLEMENTATION.
  METHOD constructor.
    super->constructor( previous = previous ).
    me->rc       = rc.
    me->message  = message.
    me->location = location.
    me->a1       = a1.
    me->a2       = a2.
    me->a3       = a3.
    me->a4       = a4.
    CLEAR me->textid.
    IF textid IS INITIAL.
      if_t100_message~t100key = zcx_ajson_error.
    ELSE.
      if_t100_message~t100key = textid.
    ENDIF.
  ENDMETHOD.

  METHOD raise.

    DATA lx TYPE REF TO z2ui5_cx_ajson_error.

    lx = NEW #( message = iv_msg ).
    lx->set_location( iv_location = iv_location
                      is_node     = is_node ).
    RAISE EXCEPTION lx.

  ENDMETHOD.

  METHOD set_location.

    DATA ls_msg      TYPE ty_message_parts.
    DATA lv_location TYPE string.
    DATA lv_tmp      TYPE string.
    FIELD-SYMBOLS <path> TYPE string.
    FIELD-SYMBOLS <name> TYPE string.

    IF iv_location IS NOT INITIAL.
      lv_location = iv_location.
    ELSEIF is_node IS NOT INITIAL.
      ASSIGN COMPONENT 'PATH' OF STRUCTURE is_node TO <path>.
      ASSIGN COMPONENT 'NAME' OF STRUCTURE is_node TO <name>.
      IF <path> IS ASSIGNED AND <name> IS ASSIGNED.
        lv_location = <path> && <name>.
      ENDIF.
    ENDIF.

    IF lv_location IS NOT INITIAL.
      lv_tmp = |{ message } @{ lv_location }|.
    ELSE.
      lv_tmp = message.
    ENDIF.

    ls_msg = lv_tmp.

    location = lv_location.
    a1       = ls_msg-a1.
    a2       = ls_msg-a2.
    a3       = ls_msg-a3.
    a4       = ls_msg-a4.

  ENDMETHOD.
ENDCLASS.
