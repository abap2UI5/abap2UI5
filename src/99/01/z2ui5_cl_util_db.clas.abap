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
      DATA temp9 LIKE lr_uname.
      DATA temp10 LIKE LINE OF temp9.
      DATA temp11 LIKE lr_handle.
      DATA temp12 LIKE LINE OF temp11.
      DATA temp13 LIKE lr_handle2.
      DATA temp14 LIKE LINE OF temp13.
      DATA temp15 LIKE lr_handle3.
      DATA temp16 LIKE LINE OF temp15.

    IF uname IS SUPPLIED.

      CLEAR temp9.

      temp10-sign = `I`.
      temp10-option = `EQ`.
      temp10-low = uname.
      INSERT temp10 INTO TABLE temp9.
      lr_uname = temp9.
    ENDIF.
    IF handle IS SUPPLIED.

      CLEAR temp11.

      temp12-sign = `I`.
      temp12-option = `EQ`.
      temp12-low = handle.
      INSERT temp12 INTO TABLE temp11.
      lr_handle = temp11.
    ENDIF.
    IF handle2 IS SUPPLIED.

      CLEAR temp13.

      temp14-sign = `I`.
      temp14-option = `EQ`.
      temp14-low = handle2.
      INSERT temp14 INTO TABLE temp13.
      lr_handle2 = temp13.
    ENDIF.
    IF handle3 IS SUPPLIED.

      CLEAR temp15.

      temp16-sign = `I`.
      temp16-option = `EQ`.
      temp16-low = handle3.
      INSERT temp16 INTO TABLE temp15.
      lr_handle3 = temp15.
    ENDIF.

    SELECT * FROM z2ui5_t_91 INTO CORRESPONDING FIELDS OF TABLE result

      WHERE uname   IN lr_uname
        AND handle  IN lr_handle
        AND handle2 IN lr_handle2
        AND handle3 IN lr_handle3 "#EC WARNOK
      .

  ENDMETHOD.


  METHOD load_by_id.

    DATA lv_data TYPE z2ui5_t_91-data.
    SELECT SINGLE data
      FROM z2ui5_t_91 INTO lv_data
      WHERE id = id  "#EC WARNOK
      .
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

    DATA lv_id TYPE z2ui5_t_91-id.
    DATA temp17 TYPE z2ui5_t_91.
    DATA ls_db LIKE temp17.
    SELECT SINGLE id
      FROM z2ui5_t_91 INTO lv_id
       WHERE
        uname = uname
        AND handle = handle
        AND handle2 = handle2 "#EC WARNOK
        AND handle3 = handle3
       ##SUBRC_OK.


    CLEAR temp17.
    temp17-uname = uname.
    temp17-handle = handle.
    temp17-handle2 = handle2.
    temp17-handle3 = handle3.
    temp17-data = z2ui5_cl_util=>xml_stringify( data ).

    ls_db = temp17.

    IF lv_id IS NOT INITIAL.
      ls_db-id = lv_id.
    ELSE.
      ls_db-id = z2ui5_cl_util=>uuid_get_c32( ).
    ENDIF.

    MODIFY z2ui5_t_91 FROM ls_db.
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
