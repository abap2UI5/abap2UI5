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
    METHODS test_url_param_startup    FOR TESTING RAISING cx_static_check.
    METHODS test_app_url_hash_app     FOR TESTING RAISING cx_static_check.
    METHODS test_app_url_hash_shell   FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_test IMPLEMENTATION.

  METHOD test_bool_abap_true.

    cl_abap_unit_assert=>assert_equals(
        exp = `true`
        act = z2ui5_cl_ui5_util_context=>boolean_abap_2_json( abap_true ) ).

  ENDMETHOD.

  METHOD test_bool_abap_false.

    " an initial abap_bool is a boolean and renders as false,
    " it must not be confused with an initial string (see below)
    cl_abap_unit_assert=>assert_equals(
        exp = `false`
        act = z2ui5_cl_ui5_util_context=>boolean_abap_2_json( abap_false ) ).

  ENDMETHOD.

  METHOD test_bool_char_non_bool.

    " a plain single character type is not a boolean flag,
    " its value has to pass through unchanged
    DATA lv_char TYPE c LENGTH 1 VALUE 'X'.

    cl_abap_unit_assert=>assert_equals(
        exp = `X`
        act = z2ui5_cl_ui5_util_context=>boolean_abap_2_json( lv_char ) ).

  ENDMETHOD.

  METHOD test_bool_string_empty.

    " an initial string stays empty so the property is dropped
    " later and the UI5 default applies
    DATA lv_string TYPE string.

    cl_abap_unit_assert=>assert_equals(
        exp = ``
        act = z2ui5_cl_ui5_util_context=>boolean_abap_2_json( lv_string ) ).

  ENDMETHOD.

  METHOD test_bool_string_literal.

    cl_abap_unit_assert=>assert_equals(
        exp = `true`
        act = z2ui5_cl_ui5_util_context=>boolean_abap_2_json( `true` ) ).

  ENDMETHOD.

  METHOD test_bool_string_binding.

    cl_abap_unit_assert=>assert_equals(
        exp = `{path}`
        act = z2ui5_cl_ui5_util_context=>boolean_abap_2_json( `{path}` ) ).

  ENDMETHOD.

  METHOD test_bool_check_by_data.

    DATA lv_char TYPE c LENGTH 1 VALUE 'X'.
    DATA lv_int  TYPE i VALUE 5.

    cl_abap_unit_assert=>assert_true( z2ui5_cl_ui5_util_context=>boolean_check_by_data( abap_true ) ).
    cl_abap_unit_assert=>assert_true( z2ui5_cl_ui5_util_context=>boolean_check_by_data( abap_false ) ).
    cl_abap_unit_assert=>assert_false( z2ui5_cl_ui5_util_context=>boolean_check_by_data( lv_char ) ).
    cl_abap_unit_assert=>assert_false( z2ui5_cl_ui5_util_context=>boolean_check_by_data( `X` ) ).
    cl_abap_unit_assert=>assert_false( z2ui5_cl_ui5_util_context=>boolean_check_by_data( lv_int ) ).

  ENDMETHOD.

  METHOD test_bool_cache_hit.

    " second call for the same type is answered from the
    " descriptor-keyed cache and has to return the same result
    z2ui5_cl_ui5_util_context=>boolean_abap_2_json( abap_true ).

    cl_abap_unit_assert=>assert_equals(
        exp = `true`
        act = z2ui5_cl_ui5_util_context=>boolean_abap_2_json( abap_true ) ).

    cl_abap_unit_assert=>assert_equals(
        exp = `false`
        act = z2ui5_cl_ui5_util_context=>boolean_abap_2_json( abap_false ) ).

  ENDMETHOD.

  METHOD test_url_param_case.

    " the parameter-name lookup is case-insensitive on every input shape -
    " with a full URL and with a bare query string; the value keeps its case
    cl_abap_unit_assert=>assert_equals(
        exp = `MixedCase`
        act = z2ui5_cl_ui5_util_context=>url_param_get(
                  val = `app_start`
                  url = `https://h/p?APP_START=MixedCase` ) ).

    cl_abap_unit_assert=>assert_equals(
        exp = `MixedCase`
        act = z2ui5_cl_ui5_util_context=>url_param_get(
                  val = `app_start`
                  url = `?APP_START=MixedCase` ) ).

  ENDMETHOD.

  METHOD test_url_param_no_phantom.

    " an empty search string yields no parameters at all - the former
    " phantom nameless row leaked back out of url_param_create_url as `=&`
    cl_abap_unit_assert=>assert_initial(
        z2ui5_cl_ui5_util_context=>url_param_get_tab( `` ) ).

    cl_abap_unit_assert=>assert_equals(
        exp = 1
        act = lines( z2ui5_cl_ui5_util_context=>url_param_get_tab( `?a=1&` ) ) ).

  ENDMETHOD.

  METHOD test_url_param_startup.

    " sap-startup-params is unwrapped wherever it sits in the query string -
    " as a later parameter, as the first/only parameter (typical FLP target
    " mapping), and with lowercase percent-encoding
    cl_abap_unit_assert=>assert_equals(
        exp = `foo`
        act = z2ui5_cl_ui5_util_context=>url_param_get(
                  val = `app_start`
                  url = `?x=1&sap-startup-params=app_start%3Dfoo` ) ).

    cl_abap_unit_assert=>assert_equals(
        exp = `foo`
        act = z2ui5_cl_ui5_util_context=>url_param_get(
                  val = `app_start`
                  url = `?sap-startup-params=app_start%3Dfoo` ) ).

    cl_abap_unit_assert=>assert_equals(
        exp = `foo`
        act = z2ui5_cl_ui5_util_context=>url_param_get(
                  val = `app_start`
                  url = `?sap-startup-params=app_start%3dfoo` ) ).

  ENDMETHOD.

  METHOD test_app_url_hash_app.

    " the app-owned hash (route or app-state, leading `/`) must be dropped -
    " the backend prefers it over app_start, so keeping it would re-open the
    " current app instead of the requested one
    cl_abap_unit_assert=>assert_equals(
        exp = `https://h/p?app_start=zcl_new`
        act = z2ui5_cl_ui5_util_context=>app_get_url(
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
        act = z2ui5_cl_ui5_util_context=>app_get_url(
                  classname = `ZCL_NEW`
                  origin    = `https://h`
                  pathname  = `/p`
                  search    = ``
                  hash      = `#Shell-home&/app/ZCL_OLD/DRAFT1` ) ).

  ENDMETHOD.

ENDCLASS.


CLASS ltcl_string DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_trim_spaces       FOR TESTING RAISING cx_static_check.
    METHODS test_trim_tabs         FOR TESTING RAISING cx_static_check.
    METHODS test_trim_inner_kept   FOR TESTING RAISING cx_static_check.
    METHODS test_trim_case         FOR TESTING RAISING cx_static_check.
    METHODS test_bool_by_name      FOR TESTING RAISING cx_static_check.
    METHODS test_url_create        FOR TESTING RAISING cx_static_check.
    METHODS test_url_create_empty  FOR TESTING RAISING cx_static_check.
    METHODS test_url_roundtrip     FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_string IMPLEMENTATION.

  METHOD test_trim_spaces.

    cl_abap_unit_assert=>assert_equals( exp = `abc`
                                        act = z2ui5_cl_ui5_util_context=>c_trim( `   abc   ` ) ).

  ENDMETHOD.

  METHOD test_trim_tabs.

    " leading and trailing tabs are trimmed as well - a value pasted from a
    " spreadsheet arrives tab-padded and must not keep the padding
    DATA lv_val TYPE string.

    lv_val = z2ui5_cl_ui5_util_context=>cv_char_util_horizontal_tab
             && `abc`
             && z2ui5_cl_ui5_util_context=>cv_char_util_horizontal_tab.

    cl_abap_unit_assert=>assert_equals( exp = `abc`
                                        act = z2ui5_cl_ui5_util_context=>c_trim( lv_val ) ).

  ENDMETHOD.

  METHOD test_trim_inner_kept.

    " only the edges are trimmed, inner whitespace is data
    cl_abap_unit_assert=>assert_equals( exp = `a b`
                                        act = z2ui5_cl_ui5_util_context=>c_trim( ` a b ` ) ).

  ENDMETHOD.

  METHOD test_trim_case.

    cl_abap_unit_assert=>assert_equals( exp = `ABC`
                                        act = z2ui5_cl_ui5_util_context=>c_trim_upper( ` aBc ` ) ).

    cl_abap_unit_assert=>assert_equals( exp = `abc`
                                        act = z2ui5_cl_ui5_util_context=>c_trim_lower( ` aBc ` ) ).

  ENDMETHOD.

  METHOD test_bool_by_name.

    " the name check drives whether an attribute is serialised as a JSON
    " boolean, so both the hit list and the rejection of look-alikes matter
    cl_abap_unit_assert=>assert_true( z2ui5_cl_ui5_util_context=>boolean_check_by_name( `ABAP_BOOL` ) ).
    cl_abap_unit_assert=>assert_true( z2ui5_cl_ui5_util_context=>boolean_check_by_name( `XFELD` ) ).
    cl_abap_unit_assert=>assert_true( z2ui5_cl_ui5_util_context=>boolean_check_by_name( `BOOLE_D` ) ).

    cl_abap_unit_assert=>assert_false( z2ui5_cl_ui5_util_context=>boolean_check_by_name( `abap_bool` ) ).
    cl_abap_unit_assert=>assert_false( z2ui5_cl_ui5_util_context=>boolean_check_by_name( `STRING` ) ).
    cl_abap_unit_assert=>assert_false( z2ui5_cl_ui5_util_context=>boolean_check_by_name( `` ) ).

  ENDMETHOD.

  METHOD test_url_create.

    DATA lt_params TYPE z2ui5_cl_ui5_util_context=>ty_t_name_value.

    DATA temp1 TYPE z2ui5_cl_ui5_util_context=>ty_t_name_value.
    DATA temp2 LIKE LINE OF temp1.
    CLEAR temp1.

    temp2-n = `a`.
    temp2-v = `1`.
    INSERT temp2 INTO TABLE temp1.
    temp2-n = `b`.
    temp2-v = `2`.
    INSERT temp2 INTO TABLE temp1.
    lt_params = temp1.

    cl_abap_unit_assert=>assert_equals(
        exp = `a=1&b=2`
        act = z2ui5_cl_ui5_util_context=>url_param_create_url( lt_params ) ).

  ENDMETHOD.

  METHOD test_url_create_empty.

    " no parameters must produce an empty string, not a stray separator
    DATA lt_params TYPE z2ui5_cl_ui5_util_context=>ty_t_name_value.

    cl_abap_unit_assert=>assert_equals(
        exp = ``
        act = z2ui5_cl_ui5_util_context=>url_param_create_url( lt_params ) ).

  ENDMETHOD.

  METHOD test_url_roundtrip.

    " parsing a query string and rebuilding it has to be stable - the phantom
    " nameless row that once leaked out as `=&` broke exactly this
    DATA lt_params TYPE z2ui5_cl_ui5_util_context=>ty_t_name_value.
    lt_params = z2ui5_cl_ui5_util_context=>url_param_get_tab( `?a=1&b=2` ).

    cl_abap_unit_assert=>assert_equals(
        exp = `a=1&b=2`
        act = z2ui5_cl_ui5_util_context=>url_param_create_url( lt_params ) ).

  ENDMETHOD.

ENDCLASS.


CLASS ltcl_rtti DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_s_row,
        name TYPE string,
        city TYPE string,
      END OF ty_s_row.
    TYPES ty_t_row TYPE STANDARD TABLE OF ty_s_row WITH DEFAULT KEY.

    METHODS test_check_clike     FOR TESTING RAISING cx_static_check.
    METHODS test_check_table     FOR TESTING RAISING cx_static_check.
    METHODS test_check_structure FOR TESTING RAISING cx_static_check.
    METHODS test_check_ref_data  FOR TESTING RAISING cx_static_check.
    METHODS test_bound_not_init  FOR TESTING RAISING cx_static_check.
    METHODS test_struc_to_pairs  FOR TESTING RAISING cx_static_check.
    METHODS test_scan_flag       FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS z2ui5_cl_ui5_util_context DEFINITION LOCAL FRIENDS ltcl_rtti.


CLASS ltcl_rtti IMPLEMENTATION.

  METHOD test_check_clike.

    DATA lv_int  TYPE i VALUE 5.
    DATA lv_char TYPE c LENGTH 4.
    DATA lv_numc TYPE n LENGTH 4.
    DATA lv_date TYPE d.
    DATA ls_row  TYPE ty_s_row.

    cl_abap_unit_assert=>assert_true( z2ui5_cl_ui5_util_context=>rtti_check_clike( `abc` ) ).
    cl_abap_unit_assert=>assert_true( z2ui5_cl_ui5_util_context=>rtti_check_clike( lv_char ) ).
    " n, d and t are character-like too and must be accepted
    cl_abap_unit_assert=>assert_true( z2ui5_cl_ui5_util_context=>rtti_check_clike( lv_numc ) ).
    cl_abap_unit_assert=>assert_true( z2ui5_cl_ui5_util_context=>rtti_check_clike( lv_date ) ).

    cl_abap_unit_assert=>assert_false( z2ui5_cl_ui5_util_context=>rtti_check_clike( lv_int ) ).
    cl_abap_unit_assert=>assert_false( z2ui5_cl_ui5_util_context=>rtti_check_clike( ls_row ) ).

  ENDMETHOD.

  METHOD test_check_table.

    DATA lt_row TYPE ty_t_row.
    DATA ls_row TYPE ty_s_row.

    cl_abap_unit_assert=>assert_true( z2ui5_cl_ui5_util_context=>rtti_check_table( lt_row ) ).

    cl_abap_unit_assert=>assert_false( z2ui5_cl_ui5_util_context=>rtti_check_table( ls_row ) ).
    cl_abap_unit_assert=>assert_false( z2ui5_cl_ui5_util_context=>rtti_check_table( `abc` ) ).

  ENDMETHOD.

  METHOD test_check_structure.

    DATA ls_row TYPE ty_s_row.
    DATA lt_row TYPE ty_t_row.

    cl_abap_unit_assert=>assert_true( z2ui5_cl_ui5_util_context=>rtti_check_structure( ls_row ) ).

    cl_abap_unit_assert=>assert_false( z2ui5_cl_ui5_util_context=>rtti_check_structure( `abc` ) ).
    cl_abap_unit_assert=>assert_false( z2ui5_cl_ui5_util_context=>rtti_check_structure( lt_row ) ).

  ENDMETHOD.

  METHOD test_check_ref_data.

    DATA lr_data TYPE REF TO data.

    CREATE DATA lr_data TYPE string.

    cl_abap_unit_assert=>assert_true( z2ui5_cl_ui5_util_context=>rtti_check_ref_data( lr_data ) ).

    cl_abap_unit_assert=>assert_false( z2ui5_cl_ui5_util_context=>rtti_check_ref_data( `abc` ) ).

  ENDMETHOD.

  METHOD test_bound_not_init.

    " unbound, bound-but-initial and bound-with-value are three distinct
    " states; only the last one may report true
    DATA lr_unbound TYPE REF TO data.
    DATA lr_initial TYPE REF TO data.
    DATA lr_filled  TYPE REF TO data.
    FIELD-SYMBOLS <val> TYPE string.

    CREATE DATA lr_initial TYPE string.

    CREATE DATA lr_filled TYPE string.
    ASSIGN lr_filled->* TO <val>.
    <val> = `x`.

    cl_abap_unit_assert=>assert_false( z2ui5_cl_ui5_util_context=>check_bound_a_not_initial( lr_unbound ) ).
    cl_abap_unit_assert=>assert_false( z2ui5_cl_ui5_util_context=>check_bound_a_not_initial( lr_initial ) ).
    cl_abap_unit_assert=>assert_true( z2ui5_cl_ui5_util_context=>check_bound_a_not_initial( lr_filled ) ).

  ENDMETHOD.

  METHOD test_struc_to_pairs.

    DATA ls_row TYPE ty_s_row.
    DATA lt_pair TYPE z2ui5_cl_ui5_util_context=>ty_t_name_value.
    FIELD-SYMBOLS <temp3> LIKE LINE OF lt_pair.
    DATA temp4 LIKE sy-tabix.
    FIELD-SYMBOLS <temp5> LIKE LINE OF lt_pair.
    DATA temp6 LIKE sy-tabix.

    ls_row-name = `Ada`.
    ls_row-city = `London`.


    lt_pair = z2ui5_cl_ui5_util_context=>itab_get_by_struc( ls_row ).

    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( lt_pair ) ).

    " component names come back from RTTI in upper case


    temp4 = sy-tabix.
    READ TABLE lt_pair WITH KEY n = `NAME` ASSIGNING <temp3>.
    sy-tabix = temp4.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `Ada`
                                        act = <temp3>-v ).


    temp6 = sy-tabix.
    READ TABLE lt_pair WITH KEY n = `CITY` ASSIGNING <temp5>.
    sy-tabix = temp6.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `London`
                                        act = <temp5>-v ).

  ENDMETHOD.

  METHOD test_scan_flag.

    " returns the suffix of every prefixed component that is set - the RAP
    " message mapping builds %OP-%ACTION-<name> lookups on top of this
    TYPES:
      BEGIN OF ty_s_flags,
        flag_a TYPE abap_bool,
        flag_b TYPE abap_bool,
        other  TYPE abap_bool,
      END OF ty_s_flags.

    DATA ls_flags TYPE ty_s_flags.
    DATA lt_found TYPE string_table.
    FIELD-SYMBOLS <temp7> LIKE LINE OF lt_found.
    DATA temp8 LIKE sy-tabix.

    ls_flags-flag_a = abap_true.
    ls_flags-flag_b = abap_false.
    ls_flags-other  = abap_true.


    lt_found = z2ui5_cl_ui5_util_context=>scan_flag_prefix( val = ls_flags
                                                               prefix = `FLAG_` ).

    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( lt_found ) ).


    temp8 = sy-tabix.
    READ TABLE lt_found INDEX 1 ASSIGNING <temp7>.
    sy-tabix = temp8.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `A`
                                        act = <temp7> ).

  ENDMETHOD.

ENDCLASS.


CLASS ltcl_itab DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_s_row,
        name TYPE string,
        city TYPE string,
      END OF ty_s_row.
    TYPES ty_t_row TYPE STANDARD TABLE OF ty_s_row WITH DEFAULT KEY.

    METHODS get_rows RETURNING VALUE(result) TYPE ty_t_row.

    METHODS test_filter_all_fields  FOR TESTING RAISING cx_static_check.
    METHODS test_filter_ignore_case FOR TESTING RAISING cx_static_check.
    METHODS test_filter_named_field FOR TESTING RAISING cx_static_check.
    METHODS test_filter_no_match    FOR TESTING RAISING cx_static_check.
    METHODS test_filter_elementary  FOR TESTING RAISING cx_static_check.
    METHODS test_corresponding      FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_itab IMPLEMENTATION.

  METHOD get_rows.

    DATA temp9 TYPE ltcl_itab=>ty_t_row.
    DATA temp10 LIKE LINE OF temp9.
    CLEAR temp9.

    temp10-name = `Ada`.
    temp10-city = `London`.
    INSERT temp10 INTO TABLE temp9.
    temp10-name = `Alan`.
    temp10-city = `Wilmslow`.
    INSERT temp10 INTO TABLE temp9.
    temp10-name = `Grace`.
    temp10-city = `New York`.
    INSERT temp10 INTO TABLE temp9.
    result = temp9.

  ENDMETHOD.

  METHOD test_filter_all_fields.

    " with no field list every component is searched, so a hit in `city`
    " keeps the row even though `name` does not match
    DATA lt_row TYPE ltcl_itab=>ty_t_row.
    FIELD-SYMBOLS <temp11> LIKE LINE OF lt_row.
    DATA temp12 LIKE sy-tabix.
    lt_row = get_rows( ).

    z2ui5_cl_ui5_util_context=>itab_filter_by_val( EXPORTING val = `London`
                                                CHANGING  tab    = lt_row ).

    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( lt_row ) ).


    temp12 = sy-tabix.
    READ TABLE lt_row INDEX 1 ASSIGNING <temp11>.
    sy-tabix = temp12.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `Ada`
                                        act = <temp11>-name ).

  ENDMETHOD.

  METHOD test_filter_ignore_case.

    DATA lt_row TYPE ltcl_itab=>ty_t_row.
    FIELD-SYMBOLS <temp13> LIKE LINE OF lt_row.
    DATA temp14 LIKE sy-tabix.
    lt_row = get_rows( ).

    z2ui5_cl_ui5_util_context=>itab_filter_by_val( EXPORTING val      = `ada`
                                                          ignore_case = abap_true
                                                CHANGING  tab         = lt_row ).

    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( lt_row ) ).


    temp14 = sy-tabix.
    READ TABLE lt_row INDEX 1 ASSIGNING <temp13>.
    sy-tabix = temp14.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `Ada`
                                        act = <temp13>-name ).

  ENDMETHOD.

  METHOD test_filter_named_field.

    " restricted to `name`, the city value must not produce a hit
    DATA lt_fields TYPE string_table.

    DATA lt_row TYPE ltcl_itab=>ty_t_row.
    lt_row = get_rows( ).

    APPEND `NAME` TO lt_fields.

    z2ui5_cl_ui5_util_context=>itab_filter_by_val( EXPORTING val = `London`
                                                          fields = lt_fields
                                                CHANGING  tab    = lt_row ).

    cl_abap_unit_assert=>assert_initial( lt_row ).

  ENDMETHOD.

  METHOD test_filter_no_match.

    DATA lt_row TYPE ltcl_itab=>ty_t_row.
    lt_row = get_rows( ).

    z2ui5_cl_ui5_util_context=>itab_filter_by_val( EXPORTING val = `Nobody`
                                                CHANGING  tab    = lt_row ).

    cl_abap_unit_assert=>assert_initial( lt_row ).

  ENDMETHOD.

  METHOD test_filter_elementary.

    " a table with an elementary line type has no components - the filter
    " matches against the whole line instead of deleting every row
    DATA lt_str TYPE string_table.

    DATA temp15 TYPE string_table.
    FIELD-SYMBOLS <temp17> LIKE LINE OF lt_str.
    DATA temp18 LIKE sy-tabix.
    CLEAR temp15.
    INSERT `London` INTO TABLE temp15.
    INSERT `Wilmslow` INTO TABLE temp15.
    INSERT `New York` INTO TABLE temp15.
    lt_str = temp15.

    z2ui5_cl_ui5_util_context=>itab_filter_by_val( EXPORTING val = `London`
                                                CHANGING  tab    = lt_str ).

    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( lt_str ) ).


    temp18 = sy-tabix.
    READ TABLE lt_str INDEX 1 ASSIGNING <temp17>.
    sy-tabix = temp18.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `London`
                                        act = <temp17> ).

  ENDMETHOD.

  METHOD test_corresponding.

    " components are matched by name, the rest stays initial
    TYPES:
      BEGIN OF ty_s_target,
        name    TYPE string,
        country TYPE string,
      END OF ty_s_target.
    TYPES ty_t_target TYPE STANDARD TABLE OF ty_s_target WITH DEFAULT KEY.

    DATA lt_target TYPE ty_t_target.

    DATA lt_row TYPE ltcl_itab=>ty_t_row.
    FIELD-SYMBOLS <temp19> LIKE LINE OF lt_target.
    DATA temp20 LIKE sy-tabix.
    FIELD-SYMBOLS <temp21> LIKE LINE OF lt_target.
    DATA temp22 LIKE sy-tabix.
    lt_row = get_rows( ).

    z2ui5_cl_ui5_util_context=>itab_corresponding( EXPORTING val = lt_row
                                                CHANGING  tab    = lt_target ).

    cl_abap_unit_assert=>assert_equals( exp = 3
                                        act = lines( lt_target ) ).


    temp20 = sy-tabix.
    READ TABLE lt_target INDEX 1 ASSIGNING <temp19>.
    sy-tabix = temp20.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `Ada`
                                        act = <temp19>-name ).


    temp22 = sy-tabix.
    READ TABLE lt_target INDEX 1 ASSIGNING <temp21>.
    sy-tabix = temp22.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_initial( <temp21>-country ).

  ENDMETHOD.

ENDCLASS.


CLASS ltcl_msg DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_msg_type_mapping FOR TESTING RAISING cx_static_check.
    METHODS test_box_empty_skips  FOR TESTING RAISING cx_static_check.
    METHODS test_box_single       FOR TESTING RAISING cx_static_check.
    METHODS test_box_multiple     FOR TESTING RAISING cx_static_check.
    METHODS test_token_by_range   FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_msg IMPLEMENTATION.

  METHOD test_msg_type_mapping.

    " anything that is not E/S/W falls back to Information - the UI5
    " MessageBox has no other state to render
    cl_abap_unit_assert=>assert_equals( exp = `Error`
                                        act = z2ui5_cl_ui5_util_context=>ui5_get_msg_type( `E` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `Success`
                                        act = z2ui5_cl_ui5_util_context=>ui5_get_msg_type( `S` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `Warning`
                                        act = z2ui5_cl_ui5_util_context=>ui5_get_msg_type( `W` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `Information`
                                        act = z2ui5_cl_ui5_util_context=>ui5_get_msg_type( `I` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `Information`
                                        act = z2ui5_cl_ui5_util_context=>ui5_get_msg_type( `X` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `Information`
                                        act = z2ui5_cl_ui5_util_context=>ui5_get_msg_type( `` ) ).

  ENDMETHOD.

  METHOD test_box_empty_skips.

    " no messages means no popup at all, signalled by `skip`
    DATA lt_msg TYPE z2ui5_cl_ui5_util_context=>ty_t_msg.

    DATA ls_box TYPE z2ui5_cl_ui5_util_context=>ty_s_msg_box.
    ls_box = z2ui5_cl_ui5_util_context=>ui5_msg_box_format( lt_msg ).

    cl_abap_unit_assert=>assert_true( ls_box-skip ).

  ENDMETHOD.

  METHOD test_box_single.

    " a single message renders as plain text without a details list
    DATA lt_msg TYPE z2ui5_cl_ui5_util_context=>ty_t_msg.

    DATA temp23 TYPE z2ui5_cl_ui5_util_context=>ty_t_msg.
    DATA temp24 LIKE LINE OF temp23.
    DATA ls_box TYPE z2ui5_cl_ui5_util_context=>ty_s_msg_box.
    CLEAR temp23.

    temp24-text = `boom`.
    temp24-type = `E`.
    INSERT temp24 INTO TABLE temp23.
    lt_msg = temp23.


    ls_box = z2ui5_cl_ui5_util_context=>ui5_msg_box_format( lt_msg ).

    cl_abap_unit_assert=>assert_false( ls_box-skip ).
    cl_abap_unit_assert=>assert_equals( exp = `boom`
                                        act = ls_box-text ).
    cl_abap_unit_assert=>assert_equals( exp = `Error`
                                        act = ls_box-title ).
    cl_abap_unit_assert=>assert_equals( exp = `error`
                                        act = ls_box-type ).
    cl_abap_unit_assert=>assert_initial( ls_box-details ).

  ENDMETHOD.

  METHOD test_box_multiple.

    " several messages collapse into a count plus an HTML list, and the box
    " takes its severity from the first message
    DATA lt_msg TYPE z2ui5_cl_ui5_util_context=>ty_t_msg.

    DATA temp25 TYPE z2ui5_cl_ui5_util_context=>ty_t_msg.
    DATA temp26 LIKE LINE OF temp25.
    DATA ls_box TYPE z2ui5_cl_ui5_util_context=>ty_s_msg_box.
    CLEAR temp25.

    temp26-text = `first`.
    temp26-type = `W`.
    INSERT temp26 INTO TABLE temp25.
    temp26-text = `second`.
    temp26-type = `E`.
    INSERT temp26 INTO TABLE temp25.
    lt_msg = temp25.


    ls_box = z2ui5_cl_ui5_util_context=>ui5_msg_box_format( lt_msg ).

    cl_abap_unit_assert=>assert_false( ls_box-skip ).
    cl_abap_unit_assert=>assert_equals( exp = `Warning`
                                        act = ls_box-title ).
    cl_abap_unit_assert=>assert_equals(
        exp = `<ul><li>first</li><li>second</li></ul>`
        act = ls_box-details ).

  ENDMETHOD.

  METHOD test_token_by_range.

    " every range option maps to its own token text; the placeholders
    " {LOW}/{HIGH} are substituted from the range row
    DATA lt_range TYPE z2ui5_cl_ui5_util_context=>ty_t_range.

    DATA temp27 TYPE z2ui5_cl_ui5_util_context=>ty_t_range.
    DATA temp28 LIKE LINE OF temp27.
    DATA lt_token TYPE z2ui5_cl_ui5_util_context=>ty_t_token.
    FIELD-SYMBOLS <temp29> LIKE LINE OF lt_token.
    DATA temp30 LIKE sy-tabix.
    FIELD-SYMBOLS <temp31> LIKE LINE OF lt_token.
    DATA temp32 LIKE sy-tabix.
    FIELD-SYMBOLS <temp33> LIKE LINE OF lt_token.
    DATA temp34 LIKE sy-tabix.
    FIELD-SYMBOLS <temp35> LIKE LINE OF lt_token.
    DATA temp36 LIKE sy-tabix.
    FIELD-SYMBOLS <temp37> LIKE LINE OF lt_token.
    DATA temp38 LIKE sy-tabix.
    FIELD-SYMBOLS <temp39> LIKE LINE OF lt_token.
    DATA temp40 LIKE sy-tabix.
    CLEAR temp27.

    temp28-sign = `I`.
    temp28-option = `EQ`.
    temp28-low = `X`.
    INSERT temp28 INTO TABLE temp27.
    temp28-sign = `I`.
    temp28-option = `BT`.
    temp28-low = `1`.
    temp28-high = `9`.
    INSERT temp28 INTO TABLE temp27.
    temp28-sign = `I`.
    temp28-option = `CP`.
    temp28-low = `A`.
    INSERT temp28 INTO TABLE temp27.
    temp28-sign = `E`.
    temp28-option = `EQ`.
    temp28-low = `Y`.
    INSERT temp28 INTO TABLE temp27.
    lt_range = temp27.


    lt_token = z2ui5_cl_ui5_util_context=>filter_get_token_t_by_range_t( lt_range ).

    cl_abap_unit_assert=>assert_equals( exp = 4
                                        act = lines( lt_token ) ).


    temp30 = sy-tabix.
    READ TABLE lt_token INDEX 1 ASSIGNING <temp29>.
    sy-tabix = temp30.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `=X`
                                        act = <temp29>-key ).


    temp32 = sy-tabix.
    READ TABLE lt_token INDEX 2 ASSIGNING <temp31>.
    sy-tabix = temp32.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `1...9`
                                        act = <temp31>-key ).


    temp34 = sy-tabix.
    READ TABLE lt_token INDEX 3 ASSIGNING <temp33>.
    sy-tabix = temp34.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `*A*`
                                        act = <temp33>-key ).
    " an excluding row renders negated, not like its including twin


    temp36 = sy-tabix.
    READ TABLE lt_token INDEX 4 ASSIGNING <temp35>.
    sy-tabix = temp36.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `!(=Y)`
                                        act = <temp35>-key ).

    " tokens come back visible and editable so the UI5 MultiInput can render
    " and remove them


    temp38 = sy-tabix.
    READ TABLE lt_token INDEX 1 ASSIGNING <temp37>.
    sy-tabix = temp38.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_true( <temp37>-visible ).


    temp40 = sy-tabix.
    READ TABLE lt_token INDEX 1 ASSIGNING <temp39>.
    sy-tabix = temp40.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_true( <temp39>-editable ).

  ENDMETHOD.

ENDCLASS.


" These methods are PRIVATE - they are internals of box_resolve's path, not
" API - so the test class needs friendship. Neither abaplint's transpiler nor
" the unit runner enforces visibility, which is why npm run check_visibility
" exists and why this pair has to be here rather than discovered on activation.
CLASS ltcl_msg_rap DEFINITION DEFERRED.
CLASS z2ui5_cl_ui5_util_context DEFINITION LOCAL FRIENDS ltcl_msg_rap.

" The RAP/message extraction family (msg_get_rap*, check_is_rap_struct).
"
" AGENTS.md names this class as the engine's real coverage gap - 35% of 3,175
" lines - and this block is the part of it that needs no system at all: it
" walks structures built from locally declared types, so it runs under the
" transpiler like any other test. It is also on a production path every app
" reaches, since client->message_box_display( ) over a BAPIRET2 or RAP result
" comes through z2ui5_cl_ui5_frontend=>box_resolve into exactly these methods.
CLASS ltcl_msg_rap DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_s_tky,
        product_uuid TYPE string,
        product_id   TYPE string,
      END OF ty_s_tky.

    TYPES:
      BEGIN OF ty_s_nested,
        BEGIN OF inner,
          a TYPE string,
          b TYPE string,
        END OF inner,
        c TYPE string,
      END OF ty_s_nested.

    TYPES:
      BEGIN OF ty_s_plain,
        name TYPE string,
        city TYPE string,
      END OF ty_s_plain.

    METHODS test_fail_text_known      FOR TESTING RAISING cx_static_check.
    METHODS test_fail_text_unknown    FOR TESTING RAISING cx_static_check.
    METHODS test_fail_text_all_causes FOR TESTING RAISING cx_static_check.
    METHODS test_flatten_pairs        FOR TESTING RAISING cx_static_check.
    METHODS test_flatten_skips_empty  FOR TESTING RAISING cx_static_check.
    METHODS test_flatten_nested       FOR TESTING RAISING cx_static_check.
    METHODS test_flatten_not_a_struct FOR TESTING RAISING cx_static_check.
    METHODS test_is_rap_struct_plain  FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_msg_rap IMPLEMENTATION.

  METHOD test_fail_text_known.

    " the cause codes are a RAP contract, so the mapping is asserted by value
    cl_abap_unit_assert=>assert_equals( exp = `Entity not found`
                                        act = z2ui5_cl_ui5_util_context=>msg_get_rap_fail_text( 1 ) ).

    cl_abap_unit_assert=>assert_equals( exp = `Authorization failure`
                                        act = z2ui5_cl_ui5_util_context=>msg_get_rap_fail_text( 3 ) ).

    " 4 and 5 deliberately share one text - both are a concurrency conflict
    cl_abap_unit_assert=>assert_equals(
        exp = z2ui5_cl_ui5_util_context=>msg_get_rap_fail_text( 4 )
        act = z2ui5_cl_ui5_util_context=>msg_get_rap_fail_text( 5 ) ).

  ENDMETHOD.

  METHOD test_fail_text_unknown.

    " an unmapped cause still says something useful AND keeps the number, so
    " a code the framework does not know yet can still be looked up
    DATA lv_text TYPE string.
    lv_text = z2ui5_cl_ui5_util_context=>msg_get_rap_fail_text( 99 ).

    cl_abap_unit_assert=>assert_char_cp( exp = `*99*`
                                         act = lv_text ).

    cl_abap_unit_assert=>assert_char_cp( exp = `*Operation failed*`
                                         act = lv_text ).

  ENDMETHOD.

  METHOD test_fail_text_all_causes.

    " every mapped cause renders a non-empty text that is not the fallback -
    " one assert over the whole SWITCH, so a branch dropped by an edit shows
    DATA lv_cause TYPE i.
      DATA lv_text TYPE string.
      DATA temp1 TYPE xsdboolean.
    DO 12 TIMES.
      lv_cause = sy-index - 1.

      lv_text = z2ui5_cl_ui5_util_context=>msg_get_rap_fail_text( lv_cause ).

      cl_abap_unit_assert=>assert_not_initial(
          act = lv_text
          msg = |cause { lv_cause } renders no text| ).


      temp1 = boolc( lv_text CS `cause code` ).
      cl_abap_unit_assert=>assert_false(
          act = temp1
          msg = |cause { lv_cause } fell through to the ELSE branch| ).
    ENDDO.

  ENDMETHOD.

  METHOD test_flatten_pairs.

    " the key renders as NAME=VALUE pairs, comma separated - this is what a
    " message ends up quoting to say WHICH entity failed
    DATA temp41 TYPE ty_s_tky.
    DATA ls_tky LIKE temp41.
    CLEAR temp41.
    temp41-product_uuid = `ABC-1`.
    temp41-product_id = `4711`.

    ls_tky = temp41.

    cl_abap_unit_assert=>assert_equals(
        exp = `PRODUCT_UUID=ABC-1, PRODUCT_ID=4711`
        act = z2ui5_cl_ui5_util_context=>msg_get_rap_flatten( ls_tky ) ).

  ENDMETHOD.

  METHOD test_flatten_skips_empty.

    " an initial component contributes nothing - not an empty pair and not a
    " dangling separator
    DATA temp42 TYPE ty_s_tky.
    DATA ls_tky LIKE temp42.
    CLEAR temp42.
    temp42-product_id = `4711`.

    ls_tky = temp42.

    cl_abap_unit_assert=>assert_equals(
        exp = `PRODUCT_ID=4711`
        act = z2ui5_cl_ui5_util_context=>msg_get_rap_flatten( ls_tky ) ).

  ENDMETHOD.

  METHOD test_flatten_nested.

    " a nested structure is flattened by the recursion, and its pairs join the
    " outer ones in component order
    DATA temp43 TYPE ty_s_nested.
    DATA ls_nested LIKE temp43.
    CLEAR temp43.
    CLEAR temp43-inner.
    temp43-inner-a = `1`.
    temp43-inner-b = `2`.
    temp43-c = `3`.

    ls_nested = temp43.

    cl_abap_unit_assert=>assert_equals(
        exp = `A=1, B=2, C=3`
        act = z2ui5_cl_ui5_util_context=>msg_get_rap_flatten( ls_nested ) ).

  ENDMETHOD.

  METHOD test_flatten_not_a_struct.

    " anything that is not a structure returns empty rather than dumping - the
    " method is called on whatever a %TKY-shaped component turns out to hold
    DATA lv_scalar TYPE string.
    lv_scalar = `not a structure`.

    cl_abap_unit_assert=>assert_initial(
        z2ui5_cl_ui5_util_context=>msg_get_rap_flatten( lv_scalar ) ).

  ENDMETHOD.

  METHOD test_is_rap_struct_plain.

    " a structure with no %MSG / %FAIL / %OTHER component and no message table
    " is not RAP-shaped: box_resolve has to fall through to the plain path
    DATA temp44 TYPE ty_s_plain.
    DATA ls_plain LIKE temp44.
    CLEAR temp44.
    temp44-name = `Ada`.
    temp44-city = `London`.

    ls_plain = temp44.

    cl_abap_unit_assert=>assert_equals(
        exp = abap_false
        act = z2ui5_cl_ui5_util_context=>check_is_rap_struct( ls_plain ) ).

  ENDMETHOD.

ENDCLASS.
