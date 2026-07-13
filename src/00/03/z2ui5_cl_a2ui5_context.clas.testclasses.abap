CLASS ltcl_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_bool_abap_true       FOR TESTING RAISING cx_static_check.
    METHODS test_bool_abap_false      FOR TESTING RAISING cx_static_check.
    METHODS test_bool_char_non_bool   FOR TESTING RAISING cx_static_check.
    METHODS test_bool_string_empty    FOR TESTING RAISING cx_static_check.
    METHODS test_bool_string_literal  FOR TESTING RAISING cx_static_check.
    METHODS test_bool_string_binding  FOR TESTING RAISING cx_static_check.
    METHODS test_bool_check_by_data   FOR TESTING RAISING cx_static_check.
    METHODS test_bool_cache_hit       FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_test IMPLEMENTATION.

  METHOD test_bool_abap_true.

    cl_abap_unit_assert=>assert_equals(
        exp = `true`
        act = z2ui5_cl_a2ui5_context=>boolean_abap_2_json( abap_true ) ).

  ENDMETHOD.

  METHOD test_bool_abap_false.

    " an initial abap_bool is a boolean and renders as false,
    " it must not be confused with an initial string (see below)
    cl_abap_unit_assert=>assert_equals(
        exp = `false`
        act = z2ui5_cl_a2ui5_context=>boolean_abap_2_json( abap_false ) ).

  ENDMETHOD.

  METHOD test_bool_char_non_bool.

    " a plain single character type is not a boolean flag,
    " its value has to pass through unchanged
    DATA lv_char TYPE c LENGTH 1 VALUE 'X'.

    cl_abap_unit_assert=>assert_equals(
        exp = `X`
        act = z2ui5_cl_a2ui5_context=>boolean_abap_2_json( lv_char ) ).

  ENDMETHOD.

  METHOD test_bool_string_empty.

    " an initial string stays empty so the property is dropped
    " later and the UI5 default applies
    DATA lv_string TYPE string.

    cl_abap_unit_assert=>assert_equals(
        exp = ``
        act = z2ui5_cl_a2ui5_context=>boolean_abap_2_json( lv_string ) ).

  ENDMETHOD.

  METHOD test_bool_string_literal.

    cl_abap_unit_assert=>assert_equals(
        exp = `true`
        act = z2ui5_cl_a2ui5_context=>boolean_abap_2_json( `true` ) ).

  ENDMETHOD.

  METHOD test_bool_string_binding.

    cl_abap_unit_assert=>assert_equals(
        exp = `{path}`
        act = z2ui5_cl_a2ui5_context=>boolean_abap_2_json( `{path}` ) ).

  ENDMETHOD.

  METHOD test_bool_check_by_data.

    DATA lv_char TYPE c LENGTH 1 VALUE 'X'.
    DATA lv_int  TYPE i VALUE 5.

    cl_abap_unit_assert=>assert_true( z2ui5_cl_a2ui5_context=>boolean_check_by_data( abap_true ) ).
    cl_abap_unit_assert=>assert_true( z2ui5_cl_a2ui5_context=>boolean_check_by_data( abap_false ) ).
    cl_abap_unit_assert=>assert_false( z2ui5_cl_a2ui5_context=>boolean_check_by_data( lv_char ) ).
    cl_abap_unit_assert=>assert_false( z2ui5_cl_a2ui5_context=>boolean_check_by_data( `X` ) ).
    cl_abap_unit_assert=>assert_false( z2ui5_cl_a2ui5_context=>boolean_check_by_data( lv_int ) ).

  ENDMETHOD.

  METHOD test_bool_cache_hit.

    " second call for the same type is answered from the
    " descriptor-keyed cache and has to return the same result
    z2ui5_cl_a2ui5_context=>boolean_abap_2_json( abap_true ).

    cl_abap_unit_assert=>assert_equals(
        exp = `true`
        act = z2ui5_cl_a2ui5_context=>boolean_abap_2_json( abap_true ) ).

    cl_abap_unit_assert=>assert_equals(
        exp = `false`
        act = z2ui5_cl_a2ui5_context=>boolean_abap_2_json( abap_false ) ).

  ENDMETHOD.

ENDCLASS.
