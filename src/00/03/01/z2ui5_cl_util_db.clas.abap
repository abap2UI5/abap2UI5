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
    TYPES ty_t_db TYPE STANDARD TABLE OF ty_s_db WITH DEFAULT KEY.

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
           uname = uname
            AND handle = handle
            AND handle2 = handle2
            AND handle3 = handle3.

    IF check_commit = abap_true.
      COMMIT WORK AND WAIT.
    ENDIF.

  ENDMETHOD.


  METHOD load_by_handle.

    DATA lt_db TYPE STANDARD TABLE OF z2ui5_t_91 WITH DEFAULT KEY.

    DATA lv_data TYPE z2ui5_t_91-data.
    SELECT SINGLE data
      FROM z2ui5_t_91 INTO lv_data
       WHERE
        uname = uname
        AND handle = handle
        AND handle2 = handle2
        AND handle3 = handle3 "#EC WARNOK
      .
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
      DATA temp1 LIKE lr_uname.
      DATA temp2 LIKE LINE OF temp1.
      DATA temp3 LIKE lr_handle.
      DATA temp4 LIKE LINE OF temp3.
      DATA temp5 LIKE lr_handle2.
      DATA temp6 LIKE LINE OF temp5.
      DATA temp7 LIKE lr_handle3.
      DATA temp8 LIKE LINE OF temp7.

    IF uname IS SUPPLIED.

      CLEAR temp1.

      temp2-sign = `I`.
      temp2-option = `EQ`.
      temp2-low = uname.
      INSERT temp2 INTO TABLE temp1.
      lr_uname = temp1.
    ENDIF.
    IF handle IS SUPPLIED.

      CLEAR temp3.

      temp4-sign = `I`.
      temp4-option = `EQ`.
      temp4-low = handle.
      INSERT temp4 INTO TABLE temp3.
      lr_handle = temp3.
    ENDIF.
    IF handle2 IS SUPPLIED.

      CLEAR temp5.

      temp6-sign = `I`.
      temp6-option = `EQ`.
      temp6-low = handle2.
      INSERT temp6 INTO TABLE temp5.
      lr_handle2 = temp5.
    ENDIF.
    IF handle3 IS SUPPLIED.

      CLEAR temp7.

      temp8-sign = `I`.
      temp8-option = `EQ`.
      temp8-low = handle3.
      INSERT temp8 INTO TABLE temp7.
      lr_handle3 = temp7.
    ENDIF.

    SELECT * FROM z2ui5_t_91 INTO CORRESPONDING FIELDS OF TABLE result

      WHERE uname   IN lr_uname
        AND handle  IN lr_handle
        AND handle2 IN lr_handle2
        AND handle3 IN lr_handle3 "#EC WARNOK
      .

  ENDMETHOD.


  METHOD load_by_id.

    DATA lt_db TYPE STANDARD TABLE OF z2ui5_t_91 WITH DEFAULT KEY.

    DATA lv_data TYPE z2ui5_t_91-data.
    SELECT SINGLE data
      FROM z2ui5_t_91 INTO lv_data
      WHERE id = id  "#EC WARNOK
      .
    ASSERT sy-subrc = 0.

    z2ui5_cl_util=>xml_parse(
      EXPORTING
        xml = lv_data
      IMPORTING
        any = result ).

  ENDMETHOD.


  METHOD save.

    DATA lt_db TYPE STANDARD TABLE OF z2ui5_t_91 WITH DEFAULT KEY.
    DATA lv_id TYPE z2ui5_t_91-id.
    DATA temp9 TYPE z2ui5_t_91.
    DATA ls_db LIKE temp9.
    SELECT SINGLE id
      FROM z2ui5_t_91 INTO lv_id
       WHERE
        uname = uname
        AND handle = handle
        AND handle2 = handle2 "#EC WARNOK
        AND handle3 = handle3
       ##SUBRC_OK.


    CLEAR temp9.
    temp9-uname = uname.
    temp9-handle = handle.
    temp9-handle2 = handle2.
    temp9-handle3 = handle3.
    temp9-data = z2ui5_cl_util=>xml_stringify( data ).

    ls_db = temp9.

    IF lv_id IS NOT INITIAL.
      ls_db-id = lv_id.
    ELSE.
      ls_db-id = z2ui5_cl_util=>uuid_get_c32( ).
    ENDIF.

    MODIFY z2ui5_t_91 FROM ls_db.
    ASSERT sy-subrc = 0.

    IF check_commit = abap_true.
      COMMIT WORK AND WAIT.
    ENDIF.

    result = ls_db-id.

  ENDMETHOD.

ENDCLASS.
