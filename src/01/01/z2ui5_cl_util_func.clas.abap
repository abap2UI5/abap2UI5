CLASS z2ui5_cl_util_func DEFINITION
  PUBLIC
  CREATE PUBLIC
  INHERITING FROM z2ui5_cl_util_api.

  PUBLIC SECTION.

    CLASS-METHODS db_save
      IMPORTING
        uname         TYPE clike OPTIONAL
        handle        TYPE clike OPTIONAL
        handle2       TYPE clike OPTIONAL
        handle3       TYPE clike OPTIONAL
        data          TYPE any
        check_commit  TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS db_load_by_id
      IMPORTING
        id            TYPE clike OPTIONAL
      EXPORTING
        VALUE(result) TYPE any.

    CLASS-METHODS db_load_by_handle
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



CLASS z2ui5_cl_util_func IMPLEMENTATION.

  METHOD db_load_by_handle.

    DATA lt_db TYPE STANDARD TABLE OF z2ui5_t_fw_02 WITH EMPTY KEY.

    SELECT data
      FROM z2ui5_t_fw_02
       WHERE
        uname = @uname
        AND handle = @handle
        AND handle2 = @handle2
        AND handle3 = @handle3
      INTO CORRESPONDING FIELDS OF TABLE @lt_db.

    DATA(ls_db) = lt_db[ 1 ].

    xml_parse(
      EXPORTING
        xml = ls_db-data
      IMPORTING
        any = result ).

  ENDMETHOD.


  METHOD db_load_by_id.

    DATA lt_db TYPE STANDARD TABLE OF z2ui5_t_fw_02 WITH EMPTY KEY.

    SELECT data
      FROM z2ui5_t_fw_02
      WHERE id = @id
      INTO CORRESPONDING FIELDS OF TABLE @lt_db.

    DATA(ls_db) = lt_db[ 1 ].

    xml_parse(
      EXPORTING
        xml = ls_db-data
      IMPORTING
        any = result ).

  ENDMETHOD.


  METHOD db_save.

    DATA(ls_db) = VALUE z2ui5_t_fw_02(
        id      = uuid_get_c32( )
        uname   = uname
        handle  = handle
        handle2 = handle2
        handle3 = handle3
        data    = xml_stringify( data ) ).

    MODIFY z2ui5_t_fw_02 FROM @ls_db.

    IF check_commit = abap_true.
      COMMIT WORK AND WAIT.
    ENDIF.

    result = ls_db-id.

  ENDMETHOD.

ENDCLASS.
