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

    SELECT data
      FROM z2ui5_t_91
       WHERE
        uname = @uname
        AND handle = @handle
        AND handle2 = @handle2
        AND handle3 = @handle3
      INTO CORRESPONDING FIELDS OF TABLE @lt_db.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE z2ui5_cx_util_error
        EXPORTING
          val = `No entry for handle exists`.
    ENDIF.

    DATA(ls_db) = lt_db[ 1 ].

    z2ui5_cl_util=>xml_parse(
      EXPORTING
        xml = ls_db-data
      IMPORTING
        any = result ).

  ENDMETHOD.


  METHOD load_by_id.

    DATA lt_db TYPE STANDARD TABLE OF z2ui5_t_91 WITH EMPTY KEY.

    SELECT data
      FROM z2ui5_t_91
      WHERE id = @id
      INTO CORRESPONDING FIELDS OF TABLE @lt_db.
    ASSERT sy-subrc = 0.

    DATA(ls_db) = lt_db[ 1 ].

    z2ui5_cl_util=>xml_parse(
      EXPORTING
        xml = ls_db-data
      IMPORTING
        any = result ).

  ENDMETHOD.


  METHOD save.

    DATA lt_db TYPE STANDARD TABLE OF z2ui5_t_91 WITH EMPTY KEY.
    SELECT id
      FROM z2ui5_t_91
       WHERE
        uname = @uname
        AND handle = @handle
        AND handle2 = @handle2
        AND handle3 = @handle3
      INTO CORRESPONDING FIELDS OF TABLE @lt_db ##SUBRC_OK.

    DATA(ls_db) = VALUE z2ui5_t_91(
        uname   = uname
        handle  = handle
        handle2 = handle2
        handle3 = handle3
        data    = z2ui5_cl_util=>xml_stringify( data ) ).

    TRY.
        ls_db-id = lt_db[ 1 ]-id.
      CATCH cx_root.
        ls_db-id = z2ui5_cl_util=>uuid_get_c32( ).
    ENDTRY.

    MODIFY z2ui5_t_91 FROM @ls_db.
    ASSERT sy-subrc = 0.

    IF check_commit = abap_true.
      COMMIT WORK AND WAIT.
    ENDIF.

    result = ls_db-id.

  ENDMETHOD.



ENDCLASS.
