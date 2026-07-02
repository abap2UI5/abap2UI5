CLASS z2ui5_cl_util_db DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CLASS-METHODS delete_by_handle
      IMPORTING
        uname        TYPE clike OPTIONAL
        handle       TYPE clike OPTIONAL
        handle2      TYPE clike OPTIONAL
        handle3      TYPE clike OPTIONAL
        check_commit TYPE abap_bool DEFAULT abap_true.

    CLASS-METHODS save
      IMPORTING
        uname         TYPE clike OPTIONAL
        handle        TYPE clike OPTIONAL
        handle2       TYPE clike OPTIONAL
        handle3       TYPE clike OPTIONAL
        data          TYPE any
        check_commit  TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS load_by_id
      IMPORTING
        id            TYPE clike OPTIONAL
      EXPORTING
        VALUE(result) TYPE any.

    CLASS-METHODS load_by_handle
      IMPORTING
        uname         TYPE clike OPTIONAL
        handle        TYPE clike OPTIONAL
        handle2       TYPE clike OPTIONAL
        handle3       TYPE clike OPTIONAL
      EXPORTING
        VALUE(result) TYPE any.

    TYPES ty_s_db TYPE z2ui5_t_91.
    TYPES ty_t_db TYPE STANDARD TABLE OF ty_s_db WITH EMPTY KEY.

    " only supplied parameters filter the selection, initial values of
    " unsupplied parameters do not restrict the result
    CLASS-METHODS load_multi_by_handle
      IMPORTING
        uname         TYPE clike OPTIONAL
        handle        TYPE clike OPTIONAL
        handle2       TYPE clike OPTIONAL
        handle3       TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE ty_t_db.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_util_db IMPLEMENTATION.



  METHOD delete_by_handle.

    DELETE FROM z2ui5_t_91
        WHERE
           uname = @uname
            AND handle = @handle
            AND handle2 = @handle2
            AND handle3 = @handle3.

    IF check_commit = abap_true.
      COMMIT WORK AND WAIT.
    ENDIF.

  ENDMETHOD.


  METHOD load_by_handle.

    SELECT SINGLE data
      FROM z2ui5_t_91
       WHERE
        uname = @uname
        AND handle = @handle
        AND handle2 = @handle2
        AND handle3 = @handle3 "#EC WARNOK
      INTO @DATA(lv_data).
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE z2ui5_cx_util_error
        EXPORTING
          val = `NO_ENTRY_FOR_HANDLE_EXISTS`.
    ENDIF.

    z2ui5_cl_util=>xml_parse(
      EXPORTING
        xml = lv_data
      IMPORTING
        any = result ).

  ENDMETHOD.


  METHOD load_multi_by_handle.

    DATA lr_uname   TYPE RANGE OF z2ui5_t_91-uname.
    DATA lr_handle  TYPE RANGE OF z2ui5_t_91-handle.
    DATA lr_handle2 TYPE RANGE OF z2ui5_t_91-handle2.
    DATA lr_handle3 TYPE RANGE OF z2ui5_t_91-handle3.

    IF uname IS SUPPLIED.
      lr_uname = VALUE #( ( sign = `I` option = `EQ` low = uname ) ).
    ENDIF.
    IF handle IS SUPPLIED.
      lr_handle = VALUE #( ( sign = `I` option = `EQ` low = handle ) ).
    ENDIF.
    IF handle2 IS SUPPLIED.
      lr_handle2 = VALUE #( ( sign = `I` option = `EQ` low = handle2 ) ).
    ENDIF.
    IF handle3 IS SUPPLIED.
      lr_handle3 = VALUE #( ( sign = `I` option = `EQ` low = handle3 ) ).
    ENDIF.

    SELECT FROM z2ui5_t_91
      FIELDS *
      WHERE uname   IN @lr_uname
        AND handle  IN @lr_handle
        AND handle2 IN @lr_handle2
        AND handle3 IN @lr_handle3 "#EC WARNOK
      INTO CORRESPONDING FIELDS OF TABLE @result.

  ENDMETHOD.


  METHOD load_by_id.

    SELECT SINGLE data
      FROM z2ui5_t_91
      WHERE id = @id  "#EC WARNOK
      INTO @DATA(lv_data).
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE z2ui5_cx_util_error
        EXPORTING
          val = |NO_ENTRY_FOR_ID_EXISTS: { id }|.
    ENDIF.

    z2ui5_cl_util=>xml_parse(
      EXPORTING
        xml = lv_data
      IMPORTING
        any = result ).

  ENDMETHOD.


  METHOD save.

    SELECT SINGLE id
      FROM z2ui5_t_91
       WHERE
        uname = @uname
        AND handle = @handle
        AND handle2 = @handle2 "#EC WARNOK
        AND handle3 = @handle3
      INTO @DATA(lv_id) ##SUBRC_OK.

    DATA(ls_db) = VALUE z2ui5_t_91(
        uname   = uname
        handle  = handle
        handle2 = handle2
        handle3 = handle3
        data    = z2ui5_cl_util=>xml_stringify( data ) ).

    IF lv_id IS NOT INITIAL.
      ls_db-id = lv_id.
    ELSE.
      ls_db-id = z2ui5_cl_util=>uuid_get_c32( ).
    ENDIF.

    MODIFY z2ui5_t_91 FROM @ls_db.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE z2ui5_cx_util_error
        EXPORTING
          val = `DB_SAVE_FAILED`.
    ENDIF.

    IF check_commit = abap_true.
      COMMIT WORK AND WAIT.
    ENDIF.

    result = ls_db-id.

  ENDMETHOD.

ENDCLASS.
