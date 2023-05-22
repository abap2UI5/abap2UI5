CLASS lcl_utility DEFINITION INHERITING FROM cx_no_check.

  PUBLIC SECTION.

     CLASS-METHODS get_json_boolean
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS check_is_boolean
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS get_classname_by_ref
      IMPORTING
        in            TYPE REF TO object
      RETURNING
        VALUE(result) TYPE string.

  CLASS-METHODS get_replace
      IMPORTING
        iv_val        TYPE clike
        iv_begin      TYPE clike
        iv_end        TYPE clike
        iv_replace    TYPE clike DEFAULT ''
      RETURNING
        VALUE(result) TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.

CLASS lcl_utility IMPLEMENTATION.

 METHOD get_replace.

    result = iv_val.
    SPLIT result AT iv_begin INTO DATA(lv_1) DATA(lv_2).
    SPLIT lv_2 AT iv_end INTO DATA(lv_dummy) DATA(lv_4).
    IF lv_4 IS NOT INITIAL.
      result = lv_1 && iv_replace && lv_4.
    ENDIF.

  ENDMETHOD.

  METHOD get_classname_by_ref.

    DATA(lv_classname) = cl_abap_classdescr=>get_class_name( in ).
    result = substring_after( val = lv_classname sub = `\CLASS=` ).

  ENDMETHOD.

  METHOD get_json_boolean.

    IF check_is_boolean( val ).
      result = COND #( WHEN val = abap_true THEN `true` ELSE `false` ).
    ELSE.
      result = val.
    ENDIF.

  ENDMETHOD.

    METHOD check_is_boolean.

    TRY.
        DATA(lo_ele) = CAST cl_abap_elemdescr( cl_abap_elemdescr=>describe_by_data( val ) ).
        CASE lo_ele->get_relative_name( ).
          WHEN `ABAP_BOOL` OR `ABAP_BOOLEAN` OR `XSDBOOLEAN`.
            result = abap_true.
        ENDCASE.
      CATCH cx_root.
    ENDTRY.

  ENDMETHOD.

ENDCLASS.
