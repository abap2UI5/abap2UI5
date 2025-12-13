CLASS z2ui5_cl_util_log DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS add
      IMPORTING
        val TYPE any.

    METHODS bal_save
      IMPORTING
        object    TYPE clike
        subobject TYPE clike
        id        TYPE clike.

    METHODS bal_read
      IMPORTING
        object    TYPE clike
        subobject TYPE clike
        id        TYPE clike.

    METHODS to_csv
      RETURNING
        VALUE(result) TYPE string.

    METHODS to_xlsx
      RETURNING
        VALUE(result) TYPE string.

    METHODS to_msg
      RETURNING
        VALUE(result) TYPE z2ui5_cl_util=>ty_t_msg.

  PROTECTED SECTION.
    DATA mt_log TYPE z2ui5_cl_util=>ty_t_msg.

  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_util_log IMPLEMENTATION.

  METHOD add.

    DATA lt_msg TYPE z2ui5_cl_util=>ty_t_msg.
    lt_msg = z2ui5_cl_util=>msg_get_t( val ).
    INSERT LINES OF lt_msg INTO TABLE mt_log.

  ENDMETHOD.

  METHOD bal_read.

    DATA lt_msg TYPE z2ui5_cl_util=>ty_t_msg.
    lt_msg = z2ui5_cl_util=>bal_read(
         object    = object
         subobject = subobject
         id        = id ).
    INSERT LINES OF lt_msg INTO TABLE mt_log.

  ENDMETHOD.

  METHOD bal_save.

    z2ui5_cl_util=>bal_save(
        object    = object
        subobject = subobject
        id        = id
        t_log     = mt_log ).

  ENDMETHOD.

  METHOD to_csv.

    result = z2ui5_cl_util=>itab_get_csv_by_itab( mt_log ).

  ENDMETHOD.

  METHOD to_xlsx.

    result = z2ui5_cl_util=>conv_get_xlsx_by_itab( mt_log ).

  ENDMETHOD.

  METHOD to_msg.

    result = mt_log.

  ENDMETHOD.

ENDCLASS.
