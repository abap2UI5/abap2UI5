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

    DATA lt_db TYPE STANDARD TABLE OF z2ui5_t_91 WITH EMPTY KEY.

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


  METHOD load_by_id.

    DATA lt_db TYPE STANDARD TABLE OF z2ui5_t_91 WITH EMPTY KEY.

    SELECT SINGLE data
      FROM z2ui5_t_91
      WHERE id = @id  "#EC WARNOK
      INTO @DATA(lv_data).
    ASSERT sy-subrc = 0.

    z2ui5_cl_util=>xml_parse(
      EXPORTING
        xml = lv_data
      IMPORTING
        any = result ).

  ENDMETHOD.


  METHOD save.

    DATA lt_db TYPE STANDARD TABLE OF z2ui5_t_91 WITH EMPTY KEY.
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
    ASSERT sy-subrc = 0.

    IF check_commit = abap_true.
      COMMIT WORK AND WAIT.
    ENDIF.

    result = ls_db-id.

  ENDMETHOD.

ENDCLASS.
