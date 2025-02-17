CLASS z2ui5_cl_util_sql DEFINITION PUBLIC.
  PUBLIC SECTION.

    INTERFACES if_serializable_object.

    CLASS-METHODS factory
      IMPORTING
        i_sql           TYPE z2ui5_cl_util=>ty_s_sql OPTIONAL
      RETURNING
        VALUE(r_result) TYPE REF TO z2ui5_cl_util_sql.

    DATA ms_sql  TYPE z2ui5_cl_util=>ty_s_sql.

    METHODS read.
    METHODS count.


ENDCLASS.

CLASS z2ui5_cl_util_sql IMPLEMENTATION.

  METHOD factory.

    r_result = NEW #( ).
    r_result->ms_sql = i_sql.

  ENDMETHOD.


  METHOD read.


    IF ms_sql-t_ref IS NOT BOUND.
      ms_sql-t_ref = z2ui5_cl_util=>rtti_create_tab_by_name( ms_sql-tabname ).
    ENDIF.

    "Variante lesen
    "SQL Select machen

    DATA lv_result TYPE string.

    FIELD-SYMBOLS <table> TYPE ANY TABLE.
    ASSIGN ms_sql-t_ref->* TO <table>.

    SELECT FROM (ms_sql-tabname)
     FIELDS
     *
*     WHERE (lv_result)
     INTO TABLE @<table>
     UP TO @ms_sql-count ROWS.


  ENDMETHOD.


  METHOD count.


    IF ms_sql-t_ref IS NOT BOUND.
      ms_sql-t_ref = z2ui5_cl_util=>rtti_create_tab_by_name( ms_sql-tabname ).
    ENDIF.

    "Variante lesen
    "SQL Select machen

    DATA lv_result TYPE string.

    SELECT FROM (ms_sql-tabname)
     FIELDS
     COUNT( * )
*     WHERE (lv_result)
     INTO @ms_sql-count.

  ENDMETHOD.

ENDCLASS.
