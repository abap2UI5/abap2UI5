CLASS z2ui5_cl_util_range DEFINITION PUBLIC
  FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    CONSTANTS: BEGIN OF signs,
                 including TYPE string VALUE 'I',
                 excluding TYPE string VALUE 'E',
               END OF signs.
    CONSTANTS: BEGIN OF options,
                 equal                TYPE string VALUE 'EQ',
                 not_equal            TYPE string VALUE 'NE',
                 between              TYPE string VALUE 'BT',
                 not_between          TYPE string VALUE 'NB',
                 contains_pattern     TYPE string VALUE 'CP',
                 not_contains_pattern TYPE string VALUE 'NP',
                 greater_than         TYPE string VALUE 'GT',
                 greater_equal        TYPE string VALUE 'GE',
                 less_equal           TYPE string VALUE 'LE',
                 less_than            TYPE string VALUE 'LT',
               END OF options.
    METHODS constructor
      IMPORTING
        iv_fieldname TYPE clike
        ir_range     TYPE REF TO data.
    METHODS get_sql
      RETURNING
        VALUE(result) TYPE string.
  PROTECTED SECTION.
    DATA mv_fieldname TYPE string.
    DATA mr_range     TYPE REF TO data.
    CLASS-METHODS quote
      IMPORTING
        val        TYPE clike
      RETURNING
        VALUE(out) TYPE string.
ENDCLASS.

CLASS z2ui5_cl_util_range IMPLEMENTATION.
  METHOD constructor.


    mr_range = ir_range.
    mv_fieldname = |{ to_upper( iv_fieldname ) }|.


    mr_range = ir_range.
    mv_fieldname = |{ to_upper( iv_fieldname ) }|.
  ENDMETHOD.
  METHOD get_sql.


    FIELD-SYMBOLS <lt_range> TYPE STANDARD TABLE.
    DATA temp1 TYPE xsdboolean.
    FIELD-SYMBOLS <ls_range_item> TYPE ANY.
      FIELD-SYMBOLS <lv_sign> TYPE any.
      FIELD-SYMBOLS <lv_option> TYPE any.
      FIELD-SYMBOLS <lv_low> TYPE any.
      FIELD-SYMBOLS <lv_high> TYPE any.

    ASSIGN me->mr_range->* TO <lt_range>.

    
    temp1 = boolc( <lt_range> IS INITIAL ).
    IF temp1 = abap_true.
      RETURN.
    ENDIF.

    result = `(`.

    
    LOOP AT <lt_range> ASSIGNING <ls_range_item>.

      
      ASSIGN COMPONENT 'SIGN' OF STRUCTURE <ls_range_item> TO <lv_sign>.
      
      ASSIGN COMPONENT 'OPTION' OF STRUCTURE <ls_range_item> TO <lv_option>.
      
      ASSIGN COMPONENT 'LOW' OF STRUCTURE <ls_range_item> TO <lv_low>.
      
      ASSIGN COMPONENT 'HIGH' OF STRUCTURE <ls_range_item> TO <lv_high>.

      IF sy-tabix <> 1.
        result = |{ result } OR|.
      ENDIF.

      IF <lv_sign> = signs-excluding.
        result = |{ result } NOT|.
      ENDIF.

      result = |{ result } { me->mv_fieldname }|.

      CASE <lv_option>.
        WHEN options-equal OR
             options-not_equal OR
             options-greater_than OR
             options-greater_equal OR
             options-less_equal OR
             options-less_than.
          result = |{ result } { <lv_option> } { quote( <lv_low> ) }|.

        WHEN options-between.
          result = |{ result } BETWEEN { quote( <lv_low> ) } AND { quote( <lv_high> ) }|.

        WHEN options-not_between.
          result = |{ result } NOT BETWEEN { quote( <lv_low> ) } AND { quote( <lv_high> ) }|.

        WHEN options-contains_pattern.
          TRANSLATE <lv_low> USING '*%'.
          result = |{ result } LIKE { quote( <lv_low> ) }|.

        WHEN options-not_contains_pattern.
          TRANSLATE <lv_low> USING '*%'.
          result = |{ result } NOT LIKE { quote( <lv_low> ) }|.
      ENDCASE.
    ENDLOOP.

    result = |{ result } )|.


  ENDMETHOD.
  METHOD quote.


    out = |'{ replace( val  = val
                       sub  = `'`
                       with = `''`
                       occ  = 0 ) }'|.


  ENDMETHOD.
ENDCLASS.
