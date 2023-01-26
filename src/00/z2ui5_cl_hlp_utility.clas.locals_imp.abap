*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations

"! System class for ABAP ranges
"! Provides constants for  ranges sign and options
"! and conversion methods to transform generic range table in ds_trange
"! format to ds_texpr and ds_twhere formats
"! and the inverse operations
"! Please use public types defined in this class
class lcl_abap_range definition CREATE private .

  public section.

    types range_sign type ddsign .
    types range_option type ddoption .

    constants:
      begin of sign,
        including type range_sign value 'I',
        excluding type range_sign value 'E',
      end of sign .
    constants:
      begin of option,
        equal             type range_option value 'EQ',
        not_equal         type range_option value 'NE',
        greater           type range_option value 'GT',
        greater_equal     type range_option value 'GE',
        less              type range_option value 'LT',
        less_equal        type range_option value 'LE',
        between           type range_option value 'BT',
        not_between       type range_option value 'NB',
        cover_pattern     type range_option value 'CP',
        not_cover_pattern type range_option value 'NP',
      end   of option .

    types dswhere type rsdswhere.
    types ds_where_tab type standard table of dswhere with default key.

    types: begin of ds_where,
             tablename type rsdstabs-prim_tab,
             where_tab type ds_where_tab,
           end of ds_where.

    types: ds_twhere type standard table of ds_where with default key.

    types dsexpr type rsdsexpr.
* Expressions Polish notation ---------------------------------------- *
    types: ds_expr_tab type standard table of dsexpr with default key.

    types: begin of ds_expr,
             tablename type rsdstabs-prim_tab,
             expr_tab  type ds_expr_tab,
           end of ds_expr.

    types: ds_texpr  type standard table of ds_expr  with default key.

    types dsselopt type rsdsselopt.
* Selections as RANGES-tables ---------------------------------------- *
    types: ds_selopt_t type standard table of dsselopt with default key.

    types: begin of ds_frange,
             fieldname type rsdstabs-prim_fname,
             selopt_t  type ds_selopt_t,
           end of ds_frange.

    types: ds_frange_t type standard table of ds_frange with default key.

    types: begin of ds_range,
             tablename type rsdstabs-prim_tab,
             frange_t  type ds_frange_t,
           end of ds_range.

    types: ds_trange type standard table of ds_range with default key.

    types: begin of ds_type,
             clauses type ds_twhere,
             texpr   type ds_texpr,
             trange  type ds_trange,
           end   of ds_type.
    "! Converts dynamic selections from DS_TRANGE format to DS_TWHERE format.
    "! The module carries out a purely mechanic conversion, without checks (such as for valid dictionary field).
    class-methods ranges_to_where
      importing
        !ranges        type ds_trange
      exporting
        !where_clauses type ds_twhere .
    "!  Converts dynamic selections from DS_TRANGE format to DS_TEXPR
    "!  The selections are returned as an object with type DS_TEXPR
    "!  - a table of logical expressions in Polish notation.
    class-methods ranges_to_expressions
      importing
        !field_ranges type ds_trange
      exporting
        !expressions  type ds_texpr .
    "! Converts dynamic selections from the format DS_TEXPR to the format DS_TRANGE.
    "! The function module performs a mechanical conversion, and no checks take place
    "! (for example, to check the validity of a Dictionary field).
    "! The only check that is made is to ensure that correct expressions are used in EXPRESSIONS.
    class-methods expressions_to_ranges
      importing
        !expressions  type ds_texpr
      exporting
        !field_ranges type ds_trange
      raising
        zcx_abap_range_conv .
    "! Converts dynamic selections from DS_TWHERE format to DS_TRANGE format).
    "! The module carries out a purely mechanic conversion,
    "! without checks (such as for validity of dictionary field).
    "! Only the presence of correct expressions in WHERE_CLAUSES is checked.
    class-methods where_to_ranges
      importing
        !where_clauses type ds_twhere
      exporting
        !field_ranges  type ds_trange
      raising
        zcx_abap_range_conv .
protected section.
private section.
ENDCLASS.



CLASS lCL_ABAP_RANGE IMPLEMENTATION.


  method EXPRESSIONS_TO_RANGES.

    call function 'FREE_SELECTIONS_EX_2_RANGE'
      exporting
        expressions              = expressions                 "         Abgrenzungen in Form RSDS_TEXPR
      importing
        field_ranges             = field_ranges                 "         Abgrenzungen in Form RSDS_TRANGE
      exceptions
        expression_not_supported = 1                " (Noch) nicht unterstützter logischer Ausdruck
        incorrect_expression     = 2                " Inkorrekter logischer Ausdruck
        others                   = 3.
    case sy-subrc.
      when 1.
        raise exception type zcx_abap_range_conv exporting textid = zcx_abap_range_conv=>expression_not_supported.
      when 2.
        raise exception type zcx_abap_range_conv exporting textid = zcx_abap_range_conv=>incorrect_expression.
      when 3.
        raise exception type zcx_abap_range_conv exporting textid = zcx_abap_range_conv=>internal_error.
    endcase.
  endmethod.


  method RANGES_TO_EXPRESSIONS.

    call function 'FREE_SELECTIONS_RANGE_2_EX'
      exporting
        field_ranges = field_ranges                  " Abgrenzungen in der Form RSDS_TRANGE
      importing
        expressions  =  expressions                " Abgrenzungen in der Form RSDS_TEXPR
      .
  endmethod.


  method RANGES_TO_WHERE.

    call function 'FREE_SELECTIONS_RANGE_2_WHERE'
      exporting
        field_ranges  =  ranges                " Abgrenzungen in der Form RSDS_TRANGE
      importing
        where_clauses =  where_clauses                " Abgrenzungen in der Form RSDS_TWHERE
      .
  endmethod.


  method WHERE_TO_RANGES.

    call function 'FREE_SELECTIONS_WHERE_2_RANGE'
      exporting
        where_clauses            = where_clauses                 " Abgrenzungen in Form RSDS_TWHERE
      importing
        field_ranges             = field_ranges                 " Abgrenzungen in Form RSDS_TRANGE
      exceptions
        expression_not_supported = 1                " (Noch) nicht unterstützter logischer Ausdruck
        incorrect_expression     = 2                " Inkorrekter logischer Ausdruck
        others                   = 3.

    case sy-subrc.
      when 1.
        raise exception type zcx_abap_range_conv exporting textid = zcx_abap_range_conv=>expression_not_supported.
      when 2.
         raise exception type zcx_abap_range_conv exporting textid = zcx_abap_range_conv=>incorrect_expression.
      when 3.
        raise exception type zcx_abap_range_conv exporting textid = zcx_abap_range_conv=>internal_error.
    endcase.

  endmethod.
ENDCLASS.
