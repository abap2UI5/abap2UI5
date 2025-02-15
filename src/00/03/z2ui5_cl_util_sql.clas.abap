CLASS z2ui5_cl_util_sql DEFINITION PUBLIC.
  PUBLIC SECTION.

    INTERFACES if_serializable_object.

    TYPES:
      BEGIN OF t_go_button,
        event_name TYPE string,
        icon_name  TYPE string,
        text       TYPE string,
      END OF t_go_button.

    CLASS-METHODS factory
      IMPORTING
        i_sql           TYPE z2ui5_cl_util=>ty_s_sql OPTIONAL
      RETURNING
        VALUE(r_result) TYPE REF TO z2ui5_cl_util_sql.

    DATA ms_sql  TYPE z2ui5_cl_util=>ty_s_sql.

    METHODS read.
    METHODS count.

    CLASS-METHODS go_button
      RETURNING
        VALUE(r_val) TYPE z2ui5_cl_util_sql=>t_go_button.

ENDCLASS.

CLASS z2ui5_cl_util_sql IMPLEMENTATION.

  METHOD factory.

    r_result = NEW #( ).
    r_result->ms_sql = i_sql.

  ENDMETHOD.


  METHOD go_button.

    r_val = VALUE #( event_name = `GO`
                     icon_name = `sap-icon://simulate`
                     text = 'Go'(001) ).

  ENDMETHOD.


  METHOD read.


    IF ms_sql-t_ref IS NOT BOUND.
      CREATE DATA ms_sql-t_ref  TYPE STANDARD TABLE OF (ms_sql-tabname) WITH EMPTY KEY.
    ENDIF.

    "Variante lesen
    "SQL Select machen

    DATA lv_result TYPE string.

    FIELD-SYMBOLS <table> TYPE ANY TABLE.
    ASSIGN ms_sql-t_ref->* TO <table>.

    SELECT FROM (ms_sql-tabname)
     FIELDS
     *
     WHERE (lv_result)
     INTO TABLE @<table>
     UP TO @ms_sql-count ROWS.


  ENDMETHOD.


  METHOD count.


    IF ms_sql-t_ref IS NOT BOUND.
      CREATE DATA ms_sql-t_ref  TYPE STANDARD TABLE OF (ms_sql-tabname) WITH EMPTY KEY.
    ENDIF.

    "Variante lesen
    "SQL Select machen

    DATA lv_result TYPE string.

    SELECT FROM (ms_sql-tabname)
     FIELDS
     COUNT( * )
     WHERE (lv_result)
     INTO @ms_sql-count.

  ENDMETHOD.

ENDCLASS.
