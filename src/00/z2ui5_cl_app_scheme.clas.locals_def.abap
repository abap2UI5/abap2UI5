*"* use this source file for any type of declarations (class
*"* definitions, interfaces or type declarations) you need for
*"* components in the private section

  CONSTANTS gv_lisp_trace TYPE abap_boolean VALUE abap_false ##NEEDED.

  CONSTANTS:
    c_lisp_input     TYPE string VALUE 'ABAP Lisp Input' ##NO_TEXT,
    c_lisp_eof       TYPE x LENGTH 2 VALUE 'FFFF', " we do not expect this in source code
    c_lisp_nil       TYPE string VALUE '''()',
    c_expr_separator TYPE string VALUE ` `,   " multiple expression output
    c_undefined      TYPE string VALUE '<undefined>'.

  CONSTANTS:
    c_error_message         TYPE string VALUE 'Error in processing' ##NO_TEXT,
    c_error_incorrect_input TYPE string VALUE 'Incorrect input' ##NO_TEXT,
    c_error_unexpected_end  TYPE string VALUE 'Unexpected end' ##NO_TEXT,
    c_error_eval            TYPE string VALUE 'EVAL( ) came up empty-handed' ##NO_TEXT,
    c_error_no_exp_in_body  TYPE string VALUE 'no expression in body' ##NO_TEXT.

  CONSTANTS:
    c_area_eval  TYPE string VALUE `Eval` ##NO_TEXT,
    c_area_parse TYPE string VALUE `Parse` ##NO_TEXT,
    c_area_radix TYPE string VALUE 'Radix' ##NO_TEXT.
  CONSTANTS:
    c_lisp_else TYPE string VALUE 'else' ##NO_TEXT,
    c_lisp_then TYPE c LENGTH 2 VALUE '=>'.
  CONSTANTS:
    c_eval_append           TYPE string VALUE 'append' ##NO_TEXT,
    c_eval_cons             TYPE string VALUE 'cons' ##NO_TEXT,
    c_eval_list             TYPE string VALUE 'list' ##NO_TEXT,

    c_eval_quote            TYPE string VALUE 'quote' ##NO_TEXT,
    c_eval_quasiquote       TYPE string VALUE 'quasiquote' ##NO_TEXT,
    c_eval_unquote          TYPE string VALUE 'unquote' ##NO_TEXT,
    c_eval_unquote_splicing TYPE string VALUE 'unquote-splicing' ##NO_TEXT.
  CONSTANTS:
    c_decimal_digits TYPE c LENGTH 10 VALUE '0123456789',
    c_hex_digits     TYPE c LENGTH 16 VALUE '0123456789ABCDEF',
    c_abcde          TYPE string VALUE `ABCDEFGHIJKLMNOPQRSTUVWXYZ`. " sy-abcde

  TYPES tv_char TYPE c LENGTH 1.
  TYPES tv_int TYPE int8.         " integer data type, use int8 if available
  TYPES tv_index TYPE tv_int.
  TYPES tv_real TYPE decfloat34.  " floating point data type
  TYPES tv_xword TYPE x LENGTH 2.
