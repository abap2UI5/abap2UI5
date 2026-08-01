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
    METHODS test_url_param_case       FOR TESTING RAISING cx_static_check.
    METHODS test_url_param_no_phantom FOR TESTING RAISING cx_static_check.
    METHODS test_app_url_hash_app     FOR TESTING RAISING cx_static_check.
    METHODS test_app_url_hash_shell   FOR TESTING RAISING cx_static_check.

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

  METHOD test_url_param_case.

    " the parameter-name lookup is case-insensitive on every input shape -
    " with a full URL and with a bare query string; the value keeps its case
    cl_abap_unit_assert=>assert_equals(
        exp = `MixedCase`
        act = z2ui5_cl_a2ui5_context=>url_param_get(
                  val = `app_start`
                  url = `https://h/p?APP_START=MixedCase` ) ).

    cl_abap_unit_assert=>assert_equals(
        exp = `MixedCase`
        act = z2ui5_cl_a2ui5_context=>url_param_get(
                  val = `app_start`
                  url = `?APP_START=MixedCase` ) ).

  ENDMETHOD.

  METHOD test_url_param_no_phantom.

    " an empty search string yields no parameters at all - the former
    " phantom nameless row leaked back out of url_param_create_url as `=&`
    cl_abap_unit_assert=>assert_initial(
        z2ui5_cl_a2ui5_context=>url_param_get_tab( `` ) ).

    cl_abap_unit_assert=>assert_equals(
        exp = 1
        act = lines( z2ui5_cl_a2ui5_context=>url_param_get_tab( `?a=1&` ) ) ).

  ENDMETHOD.

  METHOD test_app_url_hash_app.

    " the app-owned hash (route or app-state, leading `/`) must be dropped -
    " the backend prefers it over app_start, so keeping it would re-open the
    " current app instead of the requested one
    cl_abap_unit_assert=>assert_equals(
        exp = `https://h/p?app_start=zcl_new`
        act = z2ui5_cl_a2ui5_context=>app_get_url(
                  classname = `ZCL_NEW`
                  origin    = `https://h`
                  pathname  = `/p`
                  search    = ``
                  hash      = `#/app/ZCL_OLD/DRAFT1` ) ).

  ENDMETHOD.

  METHOD test_app_url_hash_shell.

    " inside the FLP the shell part of the hash survives, only the app part
    " after `&/` is cut
    cl_abap_unit_assert=>assert_equals(
        exp = `https://h/p?app_start=zcl_new#Shell-home`
        act = z2ui5_cl_a2ui5_context=>app_get_url(
                  classname = `ZCL_NEW`
                  origin    = `https://h`
                  pathname  = `/p`
                  search    = ``
                  hash      = `#Shell-home&/app/ZCL_OLD/DRAFT1` ) ).

  ENDMETHOD.

ENDCLASS.
