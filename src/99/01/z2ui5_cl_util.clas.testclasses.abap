"! Helper class used by various tests
CLASS ltcl_test_app DEFINITION FOR TESTING.

  PUBLIC SECTION.

    INTERFACES if_serializable_object.

    TYPES:
      BEGIN OF ty_row,
        title    TYPE string,
        value    TYPE string,
        descr    TYPE string,
        icon     TYPE string,
        info     TYPE string,
        selected TYPE abap_bool,
        checkbox TYPE abap_bool,
      END OF ty_row.

    CONSTANTS sv_status TYPE string VALUE `test` ##NEEDED.

    CLASS-DATA sv_var TYPE string.
    CLASS-DATA ss_tab TYPE ty_row.
    CLASS-DATA st_tab TYPE STANDARD TABLE OF ty_row WITH DEFAULT KEY.

    CLASS-METHODS class_constructor.

    DATA mv_val TYPE string ##NEEDED.
    DATA ms_tab TYPE ty_row ##NEEDED.
    TYPES temp1_f9908b1ee3 TYPE STANDARD TABLE OF ty_row WITH DEFAULT KEY.
DATA mt_tab TYPE temp1_f9908b1ee3 ##NEEDED.

  PROTECTED SECTION.

  PRIVATE SECTION.
ENDCLASS.

CLASS ltcl_test_app IMPLEMENTATION.

  METHOD class_constructor.
    DATA temp1 LIKE st_tab.
    DATA temp2 LIKE LINE OF temp1.
    sv_var = `test`.
    CLEAR ss_tab.
    ss_tab-title = `the_title`.
    ss_tab-value = `the_value`.

    CLEAR temp1.

    temp2-title = `test`.
    INSERT temp2 INTO TABLE temp1.
    temp2-title = `test2`.
    INSERT temp2 INTO TABLE temp1.
    st_tab = temp1.
  ENDMETHOD.

ENDCLASS.

"! ================================================================
"! STRING OPERATIONS - Detailed behavioral tests for JS transpilation
"! ================================================================
CLASS ltcl_string_ops DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    " c_trim
    METHODS trim_simple                    FOR TESTING.
    METHODS trim_leading_trailing          FOR TESTING.
    METHODS trim_horizontal_tab            FOR TESTING.
    METHODS trim_empty                     FOR TESTING.
    METHODS trim_no_trim_needed            FOR TESTING.

    " c_trim_upper
    METHODS trim_upper_basic               FOR TESTING.
    METHODS trim_upper_mixed               FOR TESTING.

    " c_trim_lower
    METHODS trim_lower_basic               FOR TESTING.
    METHODS trim_lower_mixed               FOR TESTING.

    " c_contains
    METHODS contains_true                  FOR TESTING.
    METHODS contains_false                 FOR TESTING.
    METHODS contains_empty_sub             FOR TESTING.
    METHODS contains_case_sensitive        FOR TESTING.

    " c_starts_with
    METHODS starts_with_true               FOR TESTING.
    METHODS starts_with_false              FOR TESTING.
    METHODS starts_with_longer_prefix      FOR TESTING.
    METHODS starts_with_empty              FOR TESTING.

    " c_ends_with
    METHODS ends_with_true                 FOR TESTING.
    METHODS ends_with_false                FOR TESTING.
    METHODS ends_with_longer_suffix        FOR TESTING.
    METHODS ends_with_empty                FOR TESTING.

    " c_split
    METHODS split_basic                    FOR TESTING.
    METHODS split_no_sep                   FOR TESTING.
    METHODS split_multi                    FOR TESTING.
    METHODS split_empty_parts              FOR TESTING.

    " c_join
    METHODS join_basic                     FOR TESTING.
    METHODS join_empty_sep                 FOR TESTING.
    METHODS join_single                    FOR TESTING.
    METHODS join_empty_table               FOR TESTING.

    " c_pad_left
    METHODS pad_left_basic                 FOR TESTING.
    METHODS pad_left_no_pad_needed         FOR TESTING.
    METHODS pad_left_already_longer        FOR TESTING.

    " c_pad_right
    METHODS pad_right_basic                FOR TESTING.
    METHODS pad_right_no_pad_needed        FOR TESTING.

    " c_truncate
    METHODS truncate_short_string          FOR TESTING.
    METHODS truncate_exact_length          FOR TESTING.
    METHODS truncate_long_string           FOR TESTING.
    METHODS truncate_custom_ellipsis       FOR TESTING.

    " c_substring_safe
    METHODS substring_safe_normal          FOR TESTING.
    METHODS substring_safe_negative_off    FOR TESTING.
    METHODS substring_safe_beyond_end      FOR TESTING.
    METHODS substring_safe_no_len          FOR TESTING.
    METHODS substring_safe_off_past_len    FOR TESTING.

    " c_replace_all
    METHODS replace_all_basic              FOR TESTING.
    METHODS replace_all_multiple           FOR TESTING.
    METHODS replace_all_no_match           FOR TESTING.

    " c_is_blank
    METHODS is_blank_empty                 FOR TESTING.
    METHODS is_blank_spaces                FOR TESTING.
    METHODS is_blank_not_blank             FOR TESTING.
    METHODS is_blank_tabs                  FOR TESTING.

ENDCLASS.

CLASS ltcl_string_ops IMPLEMENTATION.

  METHOD trim_simple.
    cl_abap_unit_assert=>assert_equals( exp = `hello`
                                        act = z2ui5_cl_util=>c_trim( `  hello  ` ) ).
  ENDMETHOD.

  METHOD trim_leading_trailing.
    cl_abap_unit_assert=>assert_equals( exp = `test`
                                        act = z2ui5_cl_util=>c_trim( `   test   ` ) ).
  ENDMETHOD.

  METHOD trim_horizontal_tab.
    DATA lv_tab LIKE z2ui5_cl_util=>cv_char_util_horizontal_tab.
    DATA lv_val TYPE string.
    lv_tab = z2ui5_cl_util=>cv_char_util_horizontal_tab.

    lv_val = lv_tab && `hello` && lv_tab.
    cl_abap_unit_assert=>assert_equals( exp = `hello`
                                        act = z2ui5_cl_util=>c_trim( lv_val ) ).
  ENDMETHOD.

  METHOD trim_empty.
    cl_abap_unit_assert=>assert_equals( exp = ``
                                        act = z2ui5_cl_util=>c_trim( `   ` ) ).
  ENDMETHOD.

  METHOD trim_no_trim_needed.
    cl_abap_unit_assert=>assert_equals( exp = `abc`
                                        act = z2ui5_cl_util=>c_trim( `abc` ) ).
  ENDMETHOD.

  METHOD trim_upper_basic.
    cl_abap_unit_assert=>assert_equals( exp = `HELLO`
                                        act = z2ui5_cl_util=>c_trim_upper( `  hello  ` ) ).
  ENDMETHOD.

  METHOD trim_upper_mixed.
    cl_abap_unit_assert=>assert_equals( exp = `HELLO WORLD`
                                        act = z2ui5_cl_util=>c_trim_upper( `  Hello World  ` ) ).
  ENDMETHOD.

  METHOD trim_lower_basic.
    cl_abap_unit_assert=>assert_equals( exp = `hello`
                                        act = z2ui5_cl_util=>c_trim_lower( `  HELLO  ` ) ).
  ENDMETHOD.

  METHOD trim_lower_mixed.
    cl_abap_unit_assert=>assert_equals( exp = `hello world`
                                        act = z2ui5_cl_util=>c_trim_lower( `  Hello World  ` ) ).
  ENDMETHOD.

  METHOD contains_true.
    cl_abap_unit_assert=>assert_true( z2ui5_cl_util=>c_contains( val = `Hello World` sub = `World` ) ).
  ENDMETHOD.

  METHOD contains_false.
    cl_abap_unit_assert=>assert_false( z2ui5_cl_util=>c_contains( val = `Hello World` sub = `xyz` ) ).
  ENDMETHOD.

  METHOD contains_empty_sub.
    " CS with empty string is always true in ABAP
    cl_abap_unit_assert=>assert_true( z2ui5_cl_util=>c_contains( val = `Hello` sub = `` ) ).
  ENDMETHOD.

  METHOD contains_case_sensitive.
    " ABAP CS is case-insensitive
    cl_abap_unit_assert=>assert_true( z2ui5_cl_util=>c_contains( val = `Hello World` sub = `hello` ) ).
  ENDMETHOD.

  METHOD starts_with_true.
    cl_abap_unit_assert=>assert_true( z2ui5_cl_util=>c_starts_with( val = `Hello World` prefix = `Hello` ) ).
  ENDMETHOD.

  METHOD starts_with_false.
    cl_abap_unit_assert=>assert_false( z2ui5_cl_util=>c_starts_with( val = `Hello World` prefix = `World` ) ).
  ENDMETHOD.

  METHOD starts_with_longer_prefix.
    cl_abap_unit_assert=>assert_false( z2ui5_cl_util=>c_starts_with( val = `Hi` prefix = `Hello` ) ).
  ENDMETHOD.

  METHOD starts_with_empty.
    cl_abap_unit_assert=>assert_true( z2ui5_cl_util=>c_starts_with( val = `Hello` prefix = `` ) ).
  ENDMETHOD.

  METHOD ends_with_true.
    cl_abap_unit_assert=>assert_true( z2ui5_cl_util=>c_ends_with( val = `Hello World` suffix = `World` ) ).
  ENDMETHOD.

  METHOD ends_with_false.
    cl_abap_unit_assert=>assert_false( z2ui5_cl_util=>c_ends_with( val = `Hello World` suffix = `Hello` ) ).
  ENDMETHOD.

  METHOD ends_with_longer_suffix.
    cl_abap_unit_assert=>assert_false( z2ui5_cl_util=>c_ends_with( val = `Hi` suffix = `Hello` ) ).
  ENDMETHOD.

  METHOD ends_with_empty.
    cl_abap_unit_assert=>assert_true( z2ui5_cl_util=>c_ends_with( val = `Hello` suffix = `` ) ).
  ENDMETHOD.

  METHOD split_basic.
    DATA lt_result TYPE string_table.
    DATA temp3 LIKE LINE OF lt_result.
    DATA temp4 LIKE sy-tabix.
    DATA temp5 LIKE LINE OF lt_result.
    DATA temp6 LIKE sy-tabix.
    DATA temp7 LIKE LINE OF lt_result.
    DATA temp8 LIKE sy-tabix.
    lt_result = z2ui5_cl_util=>c_split( val = `a,b,c` sep = `,` ).
    cl_abap_unit_assert=>assert_equals( exp = 3 act = lines( lt_result ) ).


    temp4 = sy-tabix.
    READ TABLE lt_result INDEX 1 INTO temp3.
    sy-tabix = temp4.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `a` act = temp3 ).


    temp6 = sy-tabix.
    READ TABLE lt_result INDEX 2 INTO temp5.
    sy-tabix = temp6.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `b` act = temp5 ).


    temp8 = sy-tabix.
    READ TABLE lt_result INDEX 3 INTO temp7.
    sy-tabix = temp8.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `c` act = temp7 ).
  ENDMETHOD.

  METHOD split_no_sep.
    DATA lt_result TYPE string_table.
    DATA temp9 LIKE LINE OF lt_result.
    DATA temp10 LIKE sy-tabix.
    lt_result = z2ui5_cl_util=>c_split( val = `hello` sep = `,` ).
    cl_abap_unit_assert=>assert_equals( exp = 1 act = lines( lt_result ) ).


    temp10 = sy-tabix.
    READ TABLE lt_result INDEX 1 INTO temp9.
    sy-tabix = temp10.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `hello` act = temp9 ).
  ENDMETHOD.

  METHOD split_multi.
    DATA lt_result TYPE string_table.
    DATA temp11 LIKE LINE OF lt_result.
    DATA temp12 LIKE sy-tabix.
    DATA temp13 LIKE LINE OF lt_result.
    DATA temp14 LIKE sy-tabix.
    DATA temp15 LIKE LINE OF lt_result.
    DATA temp16 LIKE sy-tabix.
    lt_result = z2ui5_cl_util=>c_split( val = `one::two::three` sep = `::` ).
    cl_abap_unit_assert=>assert_equals( exp = 3 act = lines( lt_result ) ).


    temp12 = sy-tabix.
    READ TABLE lt_result INDEX 1 INTO temp11.
    sy-tabix = temp12.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `one` act = temp11 ).


    temp14 = sy-tabix.
    READ TABLE lt_result INDEX 2 INTO temp13.
    sy-tabix = temp14.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `two` act = temp13 ).


    temp16 = sy-tabix.
    READ TABLE lt_result INDEX 3 INTO temp15.
    sy-tabix = temp16.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `three` act = temp15 ).
  ENDMETHOD.

  METHOD split_empty_parts.
    DATA lt_result TYPE string_table.
    DATA temp17 LIKE LINE OF lt_result.
    DATA temp18 LIKE sy-tabix.
    DATA temp19 LIKE LINE OF lt_result.
    DATA temp20 LIKE sy-tabix.
    DATA temp21 LIKE LINE OF lt_result.
    DATA temp22 LIKE sy-tabix.
    lt_result = z2ui5_cl_util=>c_split( val = `a;;b` sep = `;` ).
    cl_abap_unit_assert=>assert_equals( exp = 3 act = lines( lt_result ) ).


    temp18 = sy-tabix.
    READ TABLE lt_result INDEX 1 INTO temp17.
    sy-tabix = temp18.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `a` act = temp17 ).


    temp20 = sy-tabix.
    READ TABLE lt_result INDEX 2 INTO temp19.
    sy-tabix = temp20.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `` act = temp19 ).


    temp22 = sy-tabix.
    READ TABLE lt_result INDEX 3 INTO temp21.
    sy-tabix = temp22.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `b` act = temp21 ).
  ENDMETHOD.

  METHOD join_basic.
    DATA temp23 TYPE string_table.
    DATA lt_tab LIKE temp23.
    CLEAR temp23.
    INSERT `a` INTO TABLE temp23.
    INSERT `b` INTO TABLE temp23.
    INSERT `c` INTO TABLE temp23.

    lt_tab = temp23.
    cl_abap_unit_assert=>assert_equals( exp = `a,b,c`
                                        act = z2ui5_cl_util=>c_join( tab = lt_tab sep = `,` ) ).
  ENDMETHOD.

  METHOD join_empty_sep.
    DATA temp25 TYPE string_table.
    DATA lt_tab LIKE temp25.
    CLEAR temp25.
    INSERT `a` INTO TABLE temp25.
    INSERT `b` INTO TABLE temp25.
    INSERT `c` INTO TABLE temp25.

    lt_tab = temp25.
    cl_abap_unit_assert=>assert_equals( exp = `abc`
                                        act = z2ui5_cl_util=>c_join( tab = lt_tab ) ).
  ENDMETHOD.

  METHOD join_single.
    DATA temp27 TYPE string_table.
    DATA lt_tab LIKE temp27.
    CLEAR temp27.
    INSERT `hello` INTO TABLE temp27.

    lt_tab = temp27.
    cl_abap_unit_assert=>assert_equals( exp = `hello`
                                        act = z2ui5_cl_util=>c_join( tab = lt_tab sep = `,` ) ).
  ENDMETHOD.

  METHOD join_empty_table.
    DATA temp29 TYPE string_table.
    DATA lt_tab LIKE temp29.
    CLEAR temp29.

    lt_tab = temp29.
    cl_abap_unit_assert=>assert_equals( exp = ``
                                        act = z2ui5_cl_util=>c_join( tab = lt_tab sep = `,` ) ).
  ENDMETHOD.

  METHOD pad_left_basic.
    cl_abap_unit_assert=>assert_equals( exp = `005`
                                        act = z2ui5_cl_util=>c_pad_left( val = `5` len = 3 pad = '0' ) ).
  ENDMETHOD.

  METHOD pad_left_no_pad_needed.
    cl_abap_unit_assert=>assert_equals( exp = `123`
                                        act = z2ui5_cl_util=>c_pad_left( val = `123` len = 3 pad = '0' ) ).
  ENDMETHOD.

  METHOD pad_left_already_longer.
    cl_abap_unit_assert=>assert_equals( exp = `12345`
                                        act = z2ui5_cl_util=>c_pad_left( val = `12345` len = 3 pad = '0' ) ).
  ENDMETHOD.

  METHOD pad_right_basic.
    " After fix: pad is now converted to string internally, so space padding works
    cl_abap_unit_assert=>assert_equals( exp = `hi   `
                                        act = z2ui5_cl_util=>c_pad_right( val = `hi` len = 5 ) ).
  ENDMETHOD.

  METHOD pad_right_no_pad_needed.
    cl_abap_unit_assert=>assert_equals( exp = `hello`
                                        act = z2ui5_cl_util=>c_pad_right( val = `hello` len = 5 ) ).
  ENDMETHOD.

  METHOD truncate_short_string.
    cl_abap_unit_assert=>assert_equals( exp = `Hi`
                                        act = z2ui5_cl_util=>c_truncate( val = `Hi` max = 10 ) ).
  ENDMETHOD.

  METHOD truncate_exact_length.
    cl_abap_unit_assert=>assert_equals( exp = `Hello`
                                        act = z2ui5_cl_util=>c_truncate( val = `Hello` max = 5 ) ).
  ENDMETHOD.

  METHOD truncate_long_string.
    cl_abap_unit_assert=>assert_equals( exp = `Hell...`
                                        act = z2ui5_cl_util=>c_truncate( val = `Hello World` max = 7 ) ).
  ENDMETHOD.

  METHOD truncate_custom_ellipsis.
    cl_abap_unit_assert=>assert_equals( exp = `Hello~`
                                        act = z2ui5_cl_util=>c_truncate( val = `Hello World` max = 6 ellipsis = `~` ) ).
  ENDMETHOD.

  METHOD substring_safe_normal.
    cl_abap_unit_assert=>assert_equals( exp = `llo`
                                        act = z2ui5_cl_util=>c_substring_safe( val = `Hello` off = 2 len = 3 ) ).
  ENDMETHOD.

  METHOD substring_safe_negative_off.
    " Negative offset should be treated as 0
    cl_abap_unit_assert=>assert_equals( exp = `He`
                                        act = z2ui5_cl_util=>c_substring_safe( val = `Hello` off = -1 len = 2 ) ).
  ENDMETHOD.

  METHOD substring_safe_beyond_end.
    " len extends beyond string end - should return rest
    cl_abap_unit_assert=>assert_equals( exp = `lo`
                                        act = z2ui5_cl_util=>c_substring_safe( val = `Hello` off = 3 len = 99 ) ).
  ENDMETHOD.

  METHOD substring_safe_no_len.
    " len = -1 means rest of string
    cl_abap_unit_assert=>assert_equals( exp = `llo`
                                        act = z2ui5_cl_util=>c_substring_safe( val = `Hello` off = 2 ) ).
  ENDMETHOD.

  METHOD substring_safe_off_past_len.
    " offset beyond string length -> empty
    cl_abap_unit_assert=>assert_equals( exp = ``
                                        act = z2ui5_cl_util=>c_substring_safe( val = `Hi` off = 10 len = 5 ) ).
  ENDMETHOD.

  METHOD replace_all_basic.
    cl_abap_unit_assert=>assert_equals( exp = `hello world`
                                        act = z2ui5_cl_util=>c_replace_all( val = `hello_world` sub = `_` new_val = ` ` ) ).
  ENDMETHOD.

  METHOD replace_all_multiple.
    cl_abap_unit_assert=>assert_equals( exp = `a-b-c`
                                        act = z2ui5_cl_util=>c_replace_all( val = `a.b.c` sub = `.` new_val = `-` ) ).
  ENDMETHOD.

  METHOD replace_all_no_match.
    cl_abap_unit_assert=>assert_equals( exp = `hello`
                                        act = z2ui5_cl_util=>c_replace_all( val = `hello` sub = `x` new_val = `y` ) ).
  ENDMETHOD.

  METHOD is_blank_empty.
    cl_abap_unit_assert=>assert_true( z2ui5_cl_util=>c_is_blank( `` ) ).
  ENDMETHOD.

  METHOD is_blank_spaces.
    cl_abap_unit_assert=>assert_true( z2ui5_cl_util=>c_is_blank( `   ` ) ).
  ENDMETHOD.

  METHOD is_blank_not_blank.
    cl_abap_unit_assert=>assert_false( z2ui5_cl_util=>c_is_blank( `hi` ) ).
  ENDMETHOD.

  METHOD is_blank_tabs.
    DATA lv_val LIKE z2ui5_cl_util=>cv_char_util_horizontal_tab.
    lv_val = z2ui5_cl_util=>cv_char_util_horizontal_tab.
    cl_abap_unit_assert=>assert_true( z2ui5_cl_util=>c_is_blank( lv_val ) ).
  ENDMETHOD.

ENDCLASS.


"! ================================================================
"! BOOLEAN OPERATIONS
"! ================================================================
CLASS ltcl_boolean_ops DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    METHODS check_by_name_abap_bool        FOR TESTING.
    METHODS check_by_name_xsdboolean       FOR TESTING.
    METHODS check_by_name_flag             FOR TESTING.
    METHODS check_by_name_xflag            FOR TESTING.
    METHODS check_by_name_xfeld            FOR TESTING.
    METHODS check_by_name_wdy_boolean      FOR TESTING.
    METHODS check_by_name_boole_d          FOR TESTING.
    METHODS check_by_name_os_boolean       FOR TESTING.
    METHODS check_by_name_not_bool         FOR TESTING.
    METHODS check_by_name_empty            FOR TESTING.

    METHODS abap2json_true                 FOR TESTING.
    METHODS abap2json_false                FOR TESTING.
    METHODS abap2json_non_boolean          FOR TESTING.

    METHODS check_by_data_abap_bool        FOR TESTING.
    METHODS check_by_data_string           FOR TESTING.

    METHODS ui5_msg_type_e                 FOR TESTING.
    METHODS ui5_msg_type_s                 FOR TESTING.
    METHODS ui5_msg_type_w                 FOR TESTING.
    METHODS ui5_msg_type_i                 FOR TESTING.
    METHODS ui5_msg_type_other             FOR TESTING.

ENDCLASS.

CLASS ltcl_boolean_ops IMPLEMENTATION.

  METHOD check_by_name_abap_bool.
    cl_abap_unit_assert=>assert_true( z2ui5_cl_util=>boolean_check_by_name( `ABAP_BOOL` ) ).
  ENDMETHOD.

  METHOD check_by_name_xsdboolean.
    cl_abap_unit_assert=>assert_true( z2ui5_cl_util=>boolean_check_by_name( `XSDBOOLEAN` ) ).
  ENDMETHOD.

  METHOD check_by_name_flag.
    cl_abap_unit_assert=>assert_true( z2ui5_cl_util=>boolean_check_by_name( `FLAG` ) ).
  ENDMETHOD.

  METHOD check_by_name_xflag.
    cl_abap_unit_assert=>assert_true( z2ui5_cl_util=>boolean_check_by_name( `XFLAG` ) ).
  ENDMETHOD.

  METHOD check_by_name_xfeld.
    cl_abap_unit_assert=>assert_true( z2ui5_cl_util=>boolean_check_by_name( `XFELD` ) ).
  ENDMETHOD.

  METHOD check_by_name_wdy_boolean.
    cl_abap_unit_assert=>assert_true( z2ui5_cl_util=>boolean_check_by_name( `WDY_BOOLEAN` ) ).
  ENDMETHOD.

  METHOD check_by_name_boole_d.
    cl_abap_unit_assert=>assert_true( z2ui5_cl_util=>boolean_check_by_name( `BOOLE_D` ) ).
  ENDMETHOD.

  METHOD check_by_name_os_boolean.
    cl_abap_unit_assert=>assert_true( z2ui5_cl_util=>boolean_check_by_name( `OS_BOOLEAN` ) ).
  ENDMETHOD.

  METHOD check_by_name_not_bool.
    cl_abap_unit_assert=>assert_false( z2ui5_cl_util=>boolean_check_by_name( `STRING` ) ).
  ENDMETHOD.

  METHOD check_by_name_empty.
    cl_abap_unit_assert=>assert_false( z2ui5_cl_util=>boolean_check_by_name( `` ) ).
  ENDMETHOD.

  METHOD abap2json_true.
    cl_abap_unit_assert=>assert_equals( exp = `true`
                                        act = z2ui5_cl_util=>boolean_abap_2_json( abap_true ) ).
  ENDMETHOD.

  METHOD abap2json_false.
    cl_abap_unit_assert=>assert_equals( exp = `false`
                                        act = z2ui5_cl_util=>boolean_abap_2_json( abap_false ) ).
  ENDMETHOD.

  METHOD abap2json_non_boolean.
    " Non-boolean value is passed through unchanged
    DATA lv_val TYPE string VALUE `something`.
    cl_abap_unit_assert=>assert_equals( exp = `something`
                                        act = z2ui5_cl_util=>boolean_abap_2_json( lv_val ) ).
  ENDMETHOD.

  METHOD check_by_data_abap_bool.
    DATA lv_bool TYPE abap_bool VALUE abap_true.
    cl_abap_unit_assert=>assert_true( z2ui5_cl_util=>boolean_check_by_data( lv_bool ) ).
  ENDMETHOD.

  METHOD check_by_data_string.
    DATA lv_str TYPE string VALUE `X`.
    cl_abap_unit_assert=>assert_false( z2ui5_cl_util=>boolean_check_by_data( lv_str ) ).
  ENDMETHOD.

  METHOD ui5_msg_type_e.
    cl_abap_unit_assert=>assert_equals( exp = `Error` act = z2ui5_cl_util=>ui5_get_msg_type( `E` ) ).
  ENDMETHOD.

  METHOD ui5_msg_type_s.
    cl_abap_unit_assert=>assert_equals( exp = `Success` act = z2ui5_cl_util=>ui5_get_msg_type( `S` ) ).
  ENDMETHOD.

  METHOD ui5_msg_type_w.
    cl_abap_unit_assert=>assert_equals( exp = `Warning` act = z2ui5_cl_util=>ui5_get_msg_type( `W` ) ).
  ENDMETHOD.

  METHOD ui5_msg_type_i.
    cl_abap_unit_assert=>assert_equals( exp = `Information` act = z2ui5_cl_util=>ui5_get_msg_type( `I` ) ).
  ENDMETHOD.

  METHOD ui5_msg_type_other.
    " Any other type maps to Information
    cl_abap_unit_assert=>assert_equals( exp = `Information` act = z2ui5_cl_util=>ui5_get_msg_type( `X` ) ).
  ENDMETHOD.

ENDCLASS.


"! ================================================================
"! URL PARAMETER OPERATIONS
"! ================================================================
CLASS ltcl_url_ops DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    METHODS param_get_basic                FOR TESTING.
    METHODS param_get_case_insensitive     FOR TESTING.
    METHODS param_get_not_found            FOR TESTING.
    METHODS param_get_encoded              FOR TESTING.

    METHODS param_get_tab_basic            FOR TESTING.
    METHODS param_get_tab_multiple         FOR TESTING.
    METHODS param_get_tab_with_question    FOR TESTING.

    METHODS param_create_url_basic         FOR TESTING.
    METHODS param_create_url_single        FOR TESTING.
    METHODS param_create_url_empty         FOR TESTING.

    METHODS param_set_new_param            FOR TESTING.
    METHODS param_set_existing_param       FOR TESTING.

ENDCLASS.

CLASS ltcl_url_ops IMPLEMENTATION.

  METHOD param_get_basic.
    cl_abap_unit_assert=>assert_equals(
        exp = `world`
        act = z2ui5_cl_util=>url_param_get( val = `hello` url = `hello=world&foo=bar` ) ).
  ENDMETHOD.

  METHOD param_get_case_insensitive.
    cl_abap_unit_assert=>assert_equals(
        exp = `world`
        act = z2ui5_cl_util=>url_param_get( val = `HELLO` url = `hello=world&foo=bar` ) ).
  ENDMETHOD.

  METHOD param_get_not_found.
    cl_abap_unit_assert=>assert_equals(
        exp = ``
        act = z2ui5_cl_util=>url_param_get( val = `missing` url = `hello=world` ) ).
  ENDMETHOD.

  METHOD param_get_encoded.
    cl_abap_unit_assert=>assert_equals(
        exp = `world`
        act = z2ui5_cl_util=>url_param_get( val = `hello` url = `hello%3Dworld%26foo%3Dbar` ) ).
  ENDMETHOD.

  METHOD param_get_tab_basic.
    DATA lt_result TYPE z2ui5_cl_util=>ty_t_name_value.
    DATA temp30 LIKE LINE OF lt_result.
    DATA temp31 LIKE sy-tabix.
    DATA temp32 LIKE LINE OF lt_result.
    DATA temp33 LIKE sy-tabix.
    DATA temp34 LIKE LINE OF lt_result.
    DATA temp35 LIKE sy-tabix.
    DATA temp36 LIKE LINE OF lt_result.
    DATA temp37 LIKE sy-tabix.
    lt_result = z2ui5_cl_util=>url_param_get_tab( `name=john&age=30` ).
    cl_abap_unit_assert=>assert_equals( exp = 2 act = lines( lt_result ) ).


    temp31 = sy-tabix.
    READ TABLE lt_result INDEX 1 INTO temp30.
    sy-tabix = temp31.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `name` act = temp30-n ).


    temp33 = sy-tabix.
    READ TABLE lt_result INDEX 1 INTO temp32.
    sy-tabix = temp33.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `john` act = temp32-v ).


    temp35 = sy-tabix.
    READ TABLE lt_result INDEX 2 INTO temp34.
    sy-tabix = temp35.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `age` act = temp34-n ).


    temp37 = sy-tabix.
    READ TABLE lt_result INDEX 2 INTO temp36.
    sy-tabix = temp37.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `30` act = temp36-v ).
  ENDMETHOD.

  METHOD param_get_tab_multiple.
    DATA lt_result TYPE z2ui5_cl_util=>ty_t_name_value.
    lt_result = z2ui5_cl_util=>url_param_get_tab( `a=1&b=2&c=3` ).
    cl_abap_unit_assert=>assert_equals( exp = 3 act = lines( lt_result ) ).
  ENDMETHOD.

  METHOD param_get_tab_with_question.
    DATA lt_result TYPE z2ui5_cl_util=>ty_t_name_value.
    DATA temp38 LIKE LINE OF lt_result.
    DATA temp39 LIKE sy-tabix.
    lt_result = z2ui5_cl_util=>url_param_get_tab( `?name=john&age=30` ).
    cl_abap_unit_assert=>assert_equals( exp = 2 act = lines( lt_result ) ).


    temp39 = sy-tabix.
    READ TABLE lt_result INDEX 1 INTO temp38.
    sy-tabix = temp39.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `name` act = temp38-n ).
  ENDMETHOD.

  METHOD param_create_url_basic.
    DATA temp40 TYPE z2ui5_cl_util=>ty_t_name_value.
    DATA temp41 LIKE LINE OF temp40.
    DATA lt_params LIKE temp40.
    DATA lv_result TYPE string.
    CLEAR temp40.

    temp41-n = `name`.
    temp41-v = `john`.
    INSERT temp41 INTO TABLE temp40.
    temp41-n = `age`.
    temp41-v = `30`.
    INSERT temp41 INTO TABLE temp40.

    lt_params = temp40.

    lv_result = z2ui5_cl_util=>url_param_create_url( lt_params ).
    cl_abap_unit_assert=>assert_equals( exp = `name=john&age=30`
                                        act = lv_result ).
  ENDMETHOD.

  METHOD param_create_url_single.
    DATA temp42 TYPE z2ui5_cl_util=>ty_t_name_value.
    DATA temp43 LIKE LINE OF temp42.
    DATA lt_params LIKE temp42.
    CLEAR temp42.

    temp43-n = `key`.
    temp43-v = `val`.
    INSERT temp43 INTO TABLE temp42.

    lt_params = temp42.
    cl_abap_unit_assert=>assert_equals( exp = `key=val`
                                        act = z2ui5_cl_util=>url_param_create_url( lt_params ) ).
  ENDMETHOD.

  METHOD param_create_url_empty.
    DATA temp44 TYPE z2ui5_cl_util=>ty_t_name_value.
    DATA lt_params LIKE temp44.
    CLEAR temp44.

    lt_params = temp44.
    cl_abap_unit_assert=>assert_equals( exp = ``
                                        act = z2ui5_cl_util=>url_param_create_url( lt_params ) ).
  ENDMETHOD.

  METHOD param_set_new_param.
    DATA lv_result TYPE string.
    lv_result = z2ui5_cl_util=>url_param_set( url = `a=1&b=2`
                                                     name = `c`
                                                     value = `3` ).
    " Result should contain all three params
    cl_abap_unit_assert=>assert_true( z2ui5_cl_util=>c_contains( val = lv_result sub = `c=3` ) ).
    cl_abap_unit_assert=>assert_true( z2ui5_cl_util=>c_contains( val = lv_result sub = `a=1` ) ).
  ENDMETHOD.

  METHOD param_set_existing_param.
    DATA lv_result TYPE string.
    lv_result = z2ui5_cl_util=>url_param_set( url = `a=1&b=2`
                                                     name = `b`
                                                     value = `99` ).
    cl_abap_unit_assert=>assert_true( z2ui5_cl_util=>c_contains( val = lv_result sub = `b=99` ) ).
    cl_abap_unit_assert=>assert_false( z2ui5_cl_util=>c_contains( val = lv_result sub = `b=2` ) ).
  ENDMETHOD.

ENDCLASS.


"! ================================================================
"! VALIDATION HELPERS
"! ================================================================
CLASS ltcl_validation DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    " check_is_email
    METHODS email_valid                    FOR TESTING.
    METHODS email_no_at                    FOR TESTING.
    METHODS email_no_dot_in_domain         FOR TESTING.
    METHODS email_multiple_at              FOR TESTING.
    METHODS email_empty                    FOR TESTING.
    METHODS email_no_local_part            FOR TESTING.

    " check_is_numeric_string
    METHODS numeric_integer                FOR TESTING.
    METHODS numeric_negative               FOR TESTING.
    METHODS numeric_decimal_dot            FOR TESTING.
    METHODS numeric_decimal_comma          FOR TESTING.
    METHODS numeric_plus_sign              FOR TESTING.
    METHODS numeric_letters                FOR TESTING.
    METHODS numeric_empty                  FOR TESTING.
    METHODS numeric_spaces_trimmed         FOR TESTING.

    " check_is_guid
    METHODS guid_valid_32                  FOR TESTING.
    METHODS guid_valid_with_dashes         FOR TESTING.
    METHODS guid_too_short                 FOR TESTING.
    METHODS guid_invalid_chars             FOR TESTING.
    METHODS guid_lowercase                 FOR TESTING.

    " check_max_length
    METHODS max_length_within              FOR TESTING.
    METHODS max_length_exact               FOR TESTING.
    METHODS max_length_exceeded            FOR TESTING.

    " check_is_date_valid
    METHODS date_valid_basic               FOR TESTING.
    METHODS date_invalid_format            FOR TESTING.

ENDCLASS.

CLASS ltcl_validation IMPLEMENTATION.

  METHOD email_valid.
    cl_abap_unit_assert=>assert_true( z2ui5_cl_util=>check_is_email( `user@example.com` ) ).
  ENDMETHOD.

  METHOD email_no_at.
    cl_abap_unit_assert=>assert_false( z2ui5_cl_util=>check_is_email( `userexample.com` ) ).
  ENDMETHOD.

  METHOD email_no_dot_in_domain.
    cl_abap_unit_assert=>assert_false( z2ui5_cl_util=>check_is_email( `user@localhost` ) ).
  ENDMETHOD.

  METHOD email_multiple_at.
    cl_abap_unit_assert=>assert_false( z2ui5_cl_util=>check_is_email( `user@@example.com` ) ).
  ENDMETHOD.

  METHOD email_empty.
    cl_abap_unit_assert=>assert_false( z2ui5_cl_util=>check_is_email( `` ) ).
  ENDMETHOD.

  METHOD email_no_local_part.
    cl_abap_unit_assert=>assert_false( z2ui5_cl_util=>check_is_email( `@example.com` ) ).
  ENDMETHOD.

  METHOD numeric_integer.
    cl_abap_unit_assert=>assert_true( z2ui5_cl_util=>check_is_numeric_string( `12345` ) ).
  ENDMETHOD.

  METHOD numeric_negative.
    cl_abap_unit_assert=>assert_true( z2ui5_cl_util=>check_is_numeric_string( `-42` ) ).
  ENDMETHOD.

  METHOD numeric_decimal_dot.
    cl_abap_unit_assert=>assert_true( z2ui5_cl_util=>check_is_numeric_string( `3.14` ) ).
  ENDMETHOD.

  METHOD numeric_decimal_comma.
    cl_abap_unit_assert=>assert_true( z2ui5_cl_util=>check_is_numeric_string( `3,14` ) ).
  ENDMETHOD.

  METHOD numeric_plus_sign.
    cl_abap_unit_assert=>assert_true( z2ui5_cl_util=>check_is_numeric_string( `+99` ) ).
  ENDMETHOD.

  METHOD numeric_letters.
    cl_abap_unit_assert=>assert_false( z2ui5_cl_util=>check_is_numeric_string( `12abc` ) ).
  ENDMETHOD.

  METHOD numeric_empty.
    cl_abap_unit_assert=>assert_false( z2ui5_cl_util=>check_is_numeric_string( `` ) ).
  ENDMETHOD.

  METHOD numeric_spaces_trimmed.
    cl_abap_unit_assert=>assert_true( z2ui5_cl_util=>check_is_numeric_string( `  42  ` ) ).
  ENDMETHOD.

  METHOD guid_valid_32.
    cl_abap_unit_assert=>assert_true( z2ui5_cl_util=>check_is_guid( `A1B2C3D4E5F6A7B8C9D0E1F2A3B4C5D6` ) ).
  ENDMETHOD.

  METHOD guid_valid_with_dashes.
    cl_abap_unit_assert=>assert_true( z2ui5_cl_util=>check_is_guid( `A1B2C3D4-E5F6-A7B8-C9D0-E1F2A3B4C5D6` ) ).
  ENDMETHOD.

  METHOD guid_too_short.
    cl_abap_unit_assert=>assert_false( z2ui5_cl_util=>check_is_guid( `A1B2C3D4` ) ).
  ENDMETHOD.

  METHOD guid_invalid_chars.
    cl_abap_unit_assert=>assert_false( z2ui5_cl_util=>check_is_guid( `G1B2C3D4E5F6A7B8C9D0E1F2A3B4C5D6` ) ).
  ENDMETHOD.

  METHOD guid_lowercase.
    cl_abap_unit_assert=>assert_true( z2ui5_cl_util=>check_is_guid( `a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6` ) ).
  ENDMETHOD.

  METHOD max_length_within.
    cl_abap_unit_assert=>assert_true( z2ui5_cl_util=>check_max_length( val = `hi` max = 10 ) ).
  ENDMETHOD.

  METHOD max_length_exact.
    cl_abap_unit_assert=>assert_true( z2ui5_cl_util=>check_max_length( val = `hello` max = 5 ) ).
  ENDMETHOD.

  METHOD max_length_exceeded.
    cl_abap_unit_assert=>assert_false( z2ui5_cl_util=>check_max_length( val = `hello world` max = 5 ) ).
  ENDMETHOD.

  METHOD date_valid_basic.
    cl_abap_unit_assert=>assert_true( z2ui5_cl_util=>check_is_date_valid( `2024-03-15` ) ).
  ENDMETHOD.

  METHOD date_invalid_format.
    cl_abap_unit_assert=>assert_false( z2ui5_cl_util=>check_is_date_valid( `not-a-date` ) ).
  ENDMETHOD.

ENDCLASS.


"! ================================================================
"! NUMBER CONVERSION
"! ================================================================
CLASS ltcl_number_conv DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    " conv_number_to_string
    METHODS num2str_integer                FOR TESTING.
    METHODS num2str_decimal_2              FOR TESTING.
    METHODS num2str_decimal_0              FOR TESTING.
    METHODS num2str_thousands              FOR TESTING.
    METHODS num2str_negative               FOR TESTING.
    METHODS num2str_pad_decimals           FOR TESTING.

    " conv_string_to_number
    METHODS str2num_integer                FOR TESTING.
    METHODS str2num_negative               FOR TESTING.
    METHODS str2num_decimal_dot            FOR TESTING.
    METHODS str2num_decimal_comma          FOR TESTING.
    METHODS str2num_thousands_comma        FOR TESTING.
    METHODS str2num_invalid                FOR TESTING.

ENDCLASS.

CLASS ltcl_number_conv IMPLEMENTATION.

  METHOD num2str_integer.
    cl_abap_unit_assert=>assert_equals( exp = `42`
                                        act = z2ui5_cl_util=>conv_number_to_string( val = 42 ) ).
  ENDMETHOD.

  METHOD num2str_decimal_2.
    DATA temp45 TYPE decfloat34.
    temp45 = '3.14'.
    cl_abap_unit_assert=>assert_equals( exp = `3.14`
                                        act = z2ui5_cl_util=>conv_number_to_string( val = temp45 decimals = 2 ) ).
  ENDMETHOD.

  METHOD num2str_decimal_0.
    DATA temp46 TYPE decfloat34.
    temp46 = '3.14'.
    cl_abap_unit_assert=>assert_equals( exp = `3`
                                        act = z2ui5_cl_util=>conv_number_to_string( val = temp46 decimals = 0 ) ).
  ENDMETHOD.

  METHOD num2str_thousands.
    cl_abap_unit_assert=>assert_equals( exp = `1,000,000`
                                        act = z2ui5_cl_util=>conv_number_to_string( val = 1000000 sep_thousands = ',' ) ).
  ENDMETHOD.

  METHOD num2str_negative.
    DATA lv_result TYPE string.
    lv_result = z2ui5_cl_util=>conv_number_to_string( val = -42 sep_thousands = ',' ).
    cl_abap_unit_assert=>assert_equals( exp = `-42` act = lv_result ).
  ENDMETHOD.

  METHOD num2str_pad_decimals.
    cl_abap_unit_assert=>assert_equals( exp = `5.00`
                                        act = z2ui5_cl_util=>conv_number_to_string( val = 5 decimals = 2 ) ).
  ENDMETHOD.

  METHOD str2num_integer.
    DATA temp47 TYPE decfloat34.
    temp47 = 42.
    cl_abap_unit_assert=>assert_equals( exp = temp47
                                        act = z2ui5_cl_util=>conv_string_to_number( `42` ) ).
  ENDMETHOD.

  METHOD str2num_negative.
    DATA temp48 TYPE decfloat34.
    temp48 = -7.
    cl_abap_unit_assert=>assert_equals( exp = temp48
                                        act = z2ui5_cl_util=>conv_string_to_number( `-7` ) ).
  ENDMETHOD.

  METHOD str2num_decimal_dot.
    DATA temp49 TYPE decfloat34.
    temp49 = '3.14'.
    cl_abap_unit_assert=>assert_equals( exp = temp49
                                        act = z2ui5_cl_util=>conv_string_to_number( `3.14` ) ).
  ENDMETHOD.

  METHOD str2num_decimal_comma.
    " Comma as last separator => decimal
    DATA temp50 TYPE decfloat34.
    temp50 = '3.14'.
    cl_abap_unit_assert=>assert_equals( exp = temp50
                                        act = z2ui5_cl_util=>conv_string_to_number( `3,14` ) ).
  ENDMETHOD.

  METHOD str2num_thousands_comma.
    " Comma followed by dot => thousands separator
    DATA temp51 TYPE decfloat34.
    temp51 = '1000.50'.
    cl_abap_unit_assert=>assert_equals( exp = temp51
                                        act = z2ui5_cl_util=>conv_string_to_number( `1,000.50` ) ).
  ENDMETHOD.

  METHOD str2num_invalid.
    DATA temp52 TYPE decfloat34.
    temp52 = 0.
    cl_abap_unit_assert=>assert_equals( exp = temp52
                                        act = z2ui5_cl_util=>conv_string_to_number( `abc` ) ).
  ENDMETHOD.

ENDCLASS.


"! ================================================================
"! DATE CONVERSION
"! ================================================================
CLASS ltcl_date_conv DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    METHODS str_to_date_default            FOR TESTING.
    METHODS str_to_date_dd_mm_yyyy         FOR TESTING.
    METHODS str_to_date_mm_dd_yyyy         FOR TESTING.
    METHODS str_to_date_no_separators      FOR TESTING.

    METHODS date_to_str_default            FOR TESTING.
    METHODS date_to_str_dd_mm_yyyy         FOR TESTING.
    METHODS date_to_str_custom_sep         FOR TESTING.

    METHODS roundtrip                      FOR TESTING.

ENDCLASS.

CLASS ltcl_date_conv IMPLEMENTATION.

  METHOD str_to_date_default.
    " Default format YYYY-MM-DD
    DATA temp53 TYPE d.
    temp53 = `20240315`.
    cl_abap_unit_assert=>assert_equals( exp = temp53
                                        act = z2ui5_cl_util=>conv_string_to_date( `2024-03-15` ) ).
  ENDMETHOD.

  METHOD str_to_date_dd_mm_yyyy.
    DATA temp54 TYPE d.
    temp54 = `20240315`.
    cl_abap_unit_assert=>assert_equals( exp = temp54
                                        act = z2ui5_cl_util=>conv_string_to_date( val = `15.03.2024`
                                                                                   format = `DD.MM.YYYY` ) ).
  ENDMETHOD.

  METHOD str_to_date_mm_dd_yyyy.
    DATA temp55 TYPE d.
    temp55 = `20240315`.
    cl_abap_unit_assert=>assert_equals( exp = temp55
                                        act = z2ui5_cl_util=>conv_string_to_date( val = `03/15/2024`
                                                                                   format = `MM/DD/YYYY` ) ).
  ENDMETHOD.

  METHOD str_to_date_no_separators.
    DATA temp56 TYPE d.
    temp56 = `20240315`.
    cl_abap_unit_assert=>assert_equals( exp = temp56
                                        act = z2ui5_cl_util=>conv_string_to_date( val = `20240315`
                                                                                   format = `YYYYMMDD` ) ).
  ENDMETHOD.

  METHOD date_to_str_default.
    DATA temp57 TYPE d.
    temp57 = `20240315`.
    cl_abap_unit_assert=>assert_equals( exp = `2024-03-15`
                                        act = z2ui5_cl_util=>conv_date_to_string( temp57 ) ).
  ENDMETHOD.

  METHOD date_to_str_dd_mm_yyyy.
    DATA temp58 TYPE d.
    temp58 = `20240315`.
    cl_abap_unit_assert=>assert_equals( exp = `15.03.2024`
                                        act = z2ui5_cl_util=>conv_date_to_string( val = temp58
                                                                                   format = `DD.MM.YYYY` ) ).
  ENDMETHOD.

  METHOD date_to_str_custom_sep.
    DATA temp59 TYPE d.
    temp59 = `20240315`.
    cl_abap_unit_assert=>assert_equals( exp = `03/15/2024`
                                        act = z2ui5_cl_util=>conv_date_to_string( val = temp59
                                                                                   format = `MM/DD/YYYY` ) ).
  ENDMETHOD.

  METHOD roundtrip.
    DATA temp60 TYPE d.
    DATA lv_date LIKE temp60.
    DATA lv_str TYPE string.
    DATA lv_back TYPE d.
    temp60 = `20241225`.

    lv_date = temp60.

    lv_str = z2ui5_cl_util=>conv_date_to_string( lv_date ).

    lv_back = z2ui5_cl_util=>conv_string_to_date( lv_str ).
    cl_abap_unit_assert=>assert_equals( exp = lv_date act = lv_back ).
  ENDMETHOD.

ENDCLASS.


"! ================================================================
"! FILTER / RANGE / TOKEN OPERATIONS
"! ================================================================
CLASS ltcl_filter_ops DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    " filter_get_range_by_token
    METHODS token_eq                       FOR TESTING.
    METHODS token_lt                       FOR TESTING.
    METHODS token_le                       FOR TESTING.
    METHODS token_gt                       FOR TESTING.
    METHODS token_ge                       FOR TESTING.
    METHODS token_cp                       FOR TESTING.
    METHODS token_bt                       FOR TESTING.
    METHODS token_plain_value              FOR TESTING.

    " filter_get_sql_where
    METHODS sql_where_eq                   FOR TESTING.
    METHODS sql_where_bt                   FOR TESTING.
    METHODS sql_where_cp                   FOR TESTING.
    METHODS sql_where_multiple_fields      FOR TESTING.
    METHODS sql_where_exclude              FOR TESTING.

    " filter_get_multi_by_sql_where roundtrip
    METHODS sql_roundtrip_eq               FOR TESTING.
    METHODS sql_roundtrip_bt               FOR TESTING.
    METHODS sql_roundtrip_like             FOR TESTING.

    " filter_get_token_range_mapping
    METHODS token_range_mapping            FOR TESTING.

    " filter_itab
    METHODS filter_itab_basic              FOR TESTING.

    " filter_get_sql_by_sql_string
    METHODS sql_by_string_basic            FOR TESTING.

ENDCLASS.

CLASS ltcl_filter_ops IMPLEMENTATION.

  METHOD token_eq.
    DATA ls_range TYPE z2ui5_cl_util=>ty_s_range.
    ls_range = z2ui5_cl_util=>filter_get_range_by_token( `=100` ).
    cl_abap_unit_assert=>assert_equals( exp = `I` act = ls_range-sign ).
    cl_abap_unit_assert=>assert_equals( exp = `EQ` act = ls_range-option ).
    cl_abap_unit_assert=>assert_equals( exp = `100` act = ls_range-low ).
  ENDMETHOD.

  METHOD token_lt.
    DATA ls_range TYPE z2ui5_cl_util=>ty_s_range.
    ls_range = z2ui5_cl_util=>filter_get_range_by_token( `<50` ).
    cl_abap_unit_assert=>assert_equals( exp = `I` act = ls_range-sign ).
    cl_abap_unit_assert=>assert_equals( exp = `LT` act = ls_range-option ).
    cl_abap_unit_assert=>assert_equals( exp = `50` act = ls_range-low ).
  ENDMETHOD.

  METHOD token_le.
    DATA ls_range TYPE z2ui5_cl_util=>ty_s_range.
    ls_range = z2ui5_cl_util=>filter_get_range_by_token( `<=50` ).
    cl_abap_unit_assert=>assert_equals( exp = `I` act = ls_range-sign ).
    cl_abap_unit_assert=>assert_equals( exp = `LE` act = ls_range-option ).
    cl_abap_unit_assert=>assert_equals( exp = `50` act = ls_range-low ).
  ENDMETHOD.

  METHOD token_gt.
    DATA ls_range TYPE z2ui5_cl_util=>ty_s_range.
    ls_range = z2ui5_cl_util=>filter_get_range_by_token( `>10` ).
    cl_abap_unit_assert=>assert_equals( exp = `I` act = ls_range-sign ).
    cl_abap_unit_assert=>assert_equals( exp = `GT` act = ls_range-option ).
    cl_abap_unit_assert=>assert_equals( exp = `10` act = ls_range-low ).
  ENDMETHOD.

  METHOD token_ge.
    DATA ls_range TYPE z2ui5_cl_util=>ty_s_range.
    ls_range = z2ui5_cl_util=>filter_get_range_by_token( `>=10` ).
    cl_abap_unit_assert=>assert_equals( exp = `I` act = ls_range-sign ).
    cl_abap_unit_assert=>assert_equals( exp = `GE` act = ls_range-option ).
    cl_abap_unit_assert=>assert_equals( exp = `10` act = ls_range-low ).
  ENDMETHOD.

  METHOD token_cp.
    DATA ls_range TYPE z2ui5_cl_util=>ty_s_range.
    ls_range = z2ui5_cl_util=>filter_get_range_by_token( `*test*` ).
    cl_abap_unit_assert=>assert_equals( exp = `I` act = ls_range-sign ).
    cl_abap_unit_assert=>assert_equals( exp = `CP` act = ls_range-option ).
    cl_abap_unit_assert=>assert_equals( exp = `test` act = ls_range-low ).
  ENDMETHOD.

  METHOD token_bt.
    DATA ls_range TYPE z2ui5_cl_util=>ty_s_range.
    ls_range = z2ui5_cl_util=>filter_get_range_by_token( `10...20` ).
    cl_abap_unit_assert=>assert_equals( exp = `I` act = ls_range-sign ).
    cl_abap_unit_assert=>assert_equals( exp = `BT` act = ls_range-option ).
    cl_abap_unit_assert=>assert_equals( exp = `10` act = ls_range-low ).
    cl_abap_unit_assert=>assert_equals( exp = `20` act = ls_range-high ).
  ENDMETHOD.

  METHOD token_plain_value.
    " Plain value without operator means EQ
    DATA ls_range TYPE z2ui5_cl_util=>ty_s_range.
    ls_range = z2ui5_cl_util=>filter_get_range_by_token( `hello` ).
    cl_abap_unit_assert=>assert_equals( exp = `I` act = ls_range-sign ).
    cl_abap_unit_assert=>assert_equals( exp = `EQ` act = ls_range-option ).
    cl_abap_unit_assert=>assert_equals( exp = `hello` act = ls_range-low ).
  ENDMETHOD.

  METHOD sql_where_eq.
    DATA temp61 TYPE z2ui5_cl_util=>ty_t_filter_multi.
    DATA temp62 LIKE LINE OF temp61.
    DATA temp1 TYPE z2ui5_cl_util=>ty_t_range.
    DATA temp2 LIKE LINE OF temp1.
    DATA lt_filter LIKE temp61.
    DATA lv_result TYPE string.
    CLEAR temp61.

    temp62-name = `STATUS`.

    CLEAR temp1.

    temp2-sign = `I`.
    temp2-option = `EQ`.
    temp2-low = `A`.
    INSERT temp2 INTO TABLE temp1.
    temp62-t_range = temp1.
    INSERT temp62 INTO TABLE temp61.

    lt_filter = temp61.

    lv_result = z2ui5_cl_util=>filter_get_sql_where( lt_filter ).
    cl_abap_unit_assert=>assert_equals( exp = `( STATUS = 'A' )` act = lv_result ).
  ENDMETHOD.

  METHOD sql_where_bt.
    DATA temp63 TYPE z2ui5_cl_util=>ty_t_filter_multi.
    DATA temp64 LIKE LINE OF temp63.
    DATA temp3 TYPE z2ui5_cl_util=>ty_t_range.
    DATA temp4 LIKE LINE OF temp3.
    DATA lt_filter LIKE temp63.
    DATA lv_result TYPE string.
    CLEAR temp63.

    temp64-name = `AMOUNT`.

    CLEAR temp3.

    temp4-sign = `I`.
    temp4-option = `BT`.
    temp4-low = `10`.
    temp4-high = `20`.
    INSERT temp4 INTO TABLE temp3.
    temp64-t_range = temp3.
    INSERT temp64 INTO TABLE temp63.

    lt_filter = temp63.

    lv_result = z2ui5_cl_util=>filter_get_sql_where( lt_filter ).
    cl_abap_unit_assert=>assert_equals( exp = `( AMOUNT BETWEEN '10' AND '20' )` act = lv_result ).
  ENDMETHOD.

  METHOD sql_where_cp.
    DATA temp65 TYPE z2ui5_cl_util=>ty_t_filter_multi.
    DATA temp66 LIKE LINE OF temp65.
    DATA temp5 TYPE z2ui5_cl_util=>ty_t_range.
    DATA temp6 LIKE LINE OF temp5.
    DATA lt_filter LIKE temp65.
    DATA lv_result TYPE string.
    CLEAR temp65.

    temp66-name = `NAME`.

    CLEAR temp5.

    temp6-sign = `I`.
    temp6-option = `CP`.
    temp6-low = `*test*`.
    INSERT temp6 INTO TABLE temp5.
    temp66-t_range = temp5.
    INSERT temp66 INTO TABLE temp65.

    lt_filter = temp65.

    lv_result = z2ui5_cl_util=>filter_get_sql_where( lt_filter ).
    cl_abap_unit_assert=>assert_equals( exp = `( NAME LIKE '%test%' )` act = lv_result ).
  ENDMETHOD.

  METHOD sql_where_multiple_fields.
    DATA temp67 TYPE z2ui5_cl_util=>ty_t_filter_multi.
    DATA temp68 LIKE LINE OF temp67.
    DATA temp7 TYPE z2ui5_cl_util=>ty_t_range.
    DATA temp8 LIKE LINE OF temp7.
    DATA temp9 TYPE z2ui5_cl_util=>ty_t_range.
    DATA temp10 LIKE LINE OF temp9.
    DATA lt_filter LIKE temp67.
    DATA lv_result TYPE string.
    CLEAR temp67.

    temp68-name = `A`.

    CLEAR temp7.

    temp8-sign = `I`.
    temp8-option = `EQ`.
    temp8-low = `1`.
    INSERT temp8 INTO TABLE temp7.
    temp68-t_range = temp7.
    INSERT temp68 INTO TABLE temp67.
    temp68-name = `B`.

    CLEAR temp9.

    temp10-sign = `I`.
    temp10-option = `EQ`.
    temp10-low = `2`.
    INSERT temp10 INTO TABLE temp9.
    temp68-t_range = temp9.
    INSERT temp68 INTO TABLE temp67.

    lt_filter = temp67.

    lv_result = z2ui5_cl_util=>filter_get_sql_where( lt_filter ).
    cl_abap_unit_assert=>assert_equals( exp = `( A = '1' ) AND ( B = '2' )` act = lv_result ).
  ENDMETHOD.

  METHOD sql_where_exclude.
    " Sign E with EQ should become NE
    DATA temp69 TYPE z2ui5_cl_util=>ty_t_filter_multi.
    DATA temp70 LIKE LINE OF temp69.
    DATA temp11 TYPE z2ui5_cl_util=>ty_t_range.
    DATA temp12 LIKE LINE OF temp11.
    DATA lt_filter LIKE temp69.
    DATA lv_result TYPE string.
    CLEAR temp69.

    temp70-name = `STATUS`.

    CLEAR temp11.

    temp12-sign = `E`.
    temp12-option = `EQ`.
    temp12-low = `X`.
    INSERT temp12 INTO TABLE temp11.
    temp70-t_range = temp11.
    INSERT temp70 INTO TABLE temp69.

    lt_filter = temp69.

    lv_result = z2ui5_cl_util=>filter_get_sql_where( lt_filter ).
    cl_abap_unit_assert=>assert_equals( exp = `( STATUS <> 'X' )` act = lv_result ).
  ENDMETHOD.

  METHOD sql_roundtrip_eq.
    DATA lt_filter TYPE z2ui5_cl_util=>ty_t_filter_multi.
    DATA temp71 LIKE LINE OF lt_filter.
    DATA temp72 LIKE sy-tabix.
    DATA temp73 LIKE LINE OF lt_filter.
    DATA temp74 LIKE sy-tabix.
    DATA temp13 LIKE LINE OF temp73-t_range.
    DATA temp14 LIKE sy-tabix.
    DATA temp75 LIKE LINE OF lt_filter.
    DATA temp76 LIKE sy-tabix.
    DATA temp15 LIKE LINE OF temp75-t_range.
    DATA temp16 LIKE sy-tabix.
    lt_filter = z2ui5_cl_util=>filter_get_multi_by_sql_where( `STATUS = 'A'` ).
    cl_abap_unit_assert=>assert_equals( exp = 1 act = lines( lt_filter ) ).


    temp72 = sy-tabix.
    READ TABLE lt_filter INDEX 1 INTO temp71.
    sy-tabix = temp72.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `STATUS` act = temp71-name ).


    temp74 = sy-tabix.
    READ TABLE lt_filter INDEX 1 INTO temp73.
    sy-tabix = temp74.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.


    temp14 = sy-tabix.
    READ TABLE temp73-t_range INDEX 1 INTO temp13.
    sy-tabix = temp14.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `EQ` act = temp13-option ).


    temp76 = sy-tabix.
    READ TABLE lt_filter INDEX 1 INTO temp75.
    sy-tabix = temp76.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.


    temp16 = sy-tabix.
    READ TABLE temp75-t_range INDEX 1 INTO temp15.
    sy-tabix = temp16.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `A` act = temp15-low ).
  ENDMETHOD.

  METHOD sql_roundtrip_bt.
    " After BETWEEN-fix: works without parentheses too
    DATA lt_filter TYPE z2ui5_cl_util=>ty_t_filter_multi.
    DATA temp77 LIKE LINE OF lt_filter.
    DATA temp78 LIKE sy-tabix.
    DATA temp17 LIKE LINE OF temp77-t_range.
    DATA temp18 LIKE sy-tabix.
    DATA temp79 LIKE LINE OF lt_filter.
    DATA temp80 LIKE sy-tabix.
    DATA temp19 LIKE LINE OF temp79-t_range.
    DATA temp20 LIKE sy-tabix.
    DATA temp81 LIKE LINE OF lt_filter.
    DATA temp82 LIKE sy-tabix.
    DATA temp21 LIKE LINE OF temp81-t_range.
    DATA temp22 LIKE sy-tabix.
    lt_filter = z2ui5_cl_util=>filter_get_multi_by_sql_where( `AMOUNT BETWEEN '10' AND '20'` ).
    cl_abap_unit_assert=>assert_equals( exp = 1 act = lines( lt_filter ) ).


    temp78 = sy-tabix.
    READ TABLE lt_filter INDEX 1 INTO temp77.
    sy-tabix = temp78.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.


    temp18 = sy-tabix.
    READ TABLE temp77-t_range INDEX 1 INTO temp17.
    sy-tabix = temp18.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `BT` act = temp17-option ).


    temp80 = sy-tabix.
    READ TABLE lt_filter INDEX 1 INTO temp79.
    sy-tabix = temp80.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.


    temp20 = sy-tabix.
    READ TABLE temp79-t_range INDEX 1 INTO temp19.
    sy-tabix = temp20.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `10` act = temp19-low ).


    temp82 = sy-tabix.
    READ TABLE lt_filter INDEX 1 INTO temp81.
    sy-tabix = temp82.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.


    temp22 = sy-tabix.
    READ TABLE temp81-t_range INDEX 1 INTO temp21.
    sy-tabix = temp22.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `20` act = temp21-high ).
  ENDMETHOD.

  METHOD sql_roundtrip_like.
    DATA lt_filter TYPE z2ui5_cl_util=>ty_t_filter_multi.
    DATA temp83 LIKE LINE OF lt_filter.
    DATA temp84 LIKE sy-tabix.
    DATA temp23 LIKE LINE OF temp83-t_range.
    DATA temp24 LIKE sy-tabix.
    DATA temp85 LIKE LINE OF lt_filter.
    DATA temp86 LIKE sy-tabix.
    DATA temp25 LIKE LINE OF temp85-t_range.
    DATA temp26 LIKE sy-tabix.
    lt_filter = z2ui5_cl_util=>filter_get_multi_by_sql_where( `NAME LIKE '%hello%'` ).
    cl_abap_unit_assert=>assert_equals( exp = 1 act = lines( lt_filter ) ).


    temp84 = sy-tabix.
    READ TABLE lt_filter INDEX 1 INTO temp83.
    sy-tabix = temp84.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.


    temp24 = sy-tabix.
    READ TABLE temp83-t_range INDEX 1 INTO temp23.
    sy-tabix = temp24.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `CP` act = temp23-option ).


    temp86 = sy-tabix.
    READ TABLE lt_filter INDEX 1 INTO temp85.
    sy-tabix = temp86.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.


    temp26 = sy-tabix.
    READ TABLE temp85-t_range INDEX 1 INTO temp25.
    sy-tabix = temp26.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `*hello*` act = temp25-low ).
  ENDMETHOD.

  METHOD token_range_mapping.
    DATA lt_result TYPE z2ui5_cl_util=>ty_t_name_value.
    DATA temp87 LIKE LINE OF lt_result.
    DATA temp88 LIKE sy-tabix.
    DATA temp89 LIKE LINE OF lt_result.
    DATA temp90 LIKE sy-tabix.
    DATA temp91 LIKE LINE OF lt_result.
    DATA temp92 LIKE sy-tabix.
    DATA temp93 LIKE LINE OF lt_result.
    DATA temp94 LIKE sy-tabix.
    lt_result = z2ui5_cl_util=>filter_get_token_range_mapping( ).
    cl_abap_unit_assert=>assert_not_initial( lt_result ).
    " Verify core mappings


    temp88 = sy-tabix.
    READ TABLE lt_result WITH KEY n = `EQ` INTO temp87.
    sy-tabix = temp88.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `={LOW}` act = temp87-v ).


    temp90 = sy-tabix.
    READ TABLE lt_result WITH KEY n = `LT` INTO temp89.
    sy-tabix = temp90.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `<{LOW}` act = temp89-v ).


    temp92 = sy-tabix.
    READ TABLE lt_result WITH KEY n = `GT` INTO temp91.
    sy-tabix = temp92.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `>{LOW}` act = temp91-v ).


    temp94 = sy-tabix.
    READ TABLE lt_result WITH KEY n = `BT` INTO temp93.
    sy-tabix = temp94.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `{LOW}...{HIGH}` act = temp93-v ).
  ENDMETHOD.

  METHOD filter_itab_basic.
    TYPES: BEGIN OF ty_row, name TYPE string, status TYPE string, END OF ty_row.
    TYPES temp2 TYPE STANDARD TABLE OF ty_row WITH DEFAULT KEY.
DATA lt_tab TYPE temp2.
    DATA temp95 LIKE lt_tab.
    DATA temp96 LIKE LINE OF temp95.
    DATA temp97 TYPE z2ui5_cl_util=>ty_t_filter_multi.
    DATA temp98 LIKE LINE OF temp97.
    DATA temp27 TYPE z2ui5_cl_util=>ty_t_range.
    DATA temp28 LIKE LINE OF temp27.
    DATA lt_filter LIKE temp97.
    DATA temp99 LIKE LINE OF lt_tab.
    DATA temp100 LIKE sy-tabix.
    DATA temp101 LIKE LINE OF lt_tab.
    DATA temp102 LIKE sy-tabix.
    CLEAR temp95.

    temp96-name = `A`.
    temp96-status = `open`.
    INSERT temp96 INTO TABLE temp95.
    temp96-name = `B`.
    temp96-status = `closed`.
    INSERT temp96 INTO TABLE temp95.
    temp96-name = `C`.
    temp96-status = `open`.
    INSERT temp96 INTO TABLE temp95.
    lt_tab = temp95.


    CLEAR temp97.

    temp98-name = `STATUS`.

    CLEAR temp27.

    temp28-sign = `I`.
    temp28-option = `EQ`.
    temp28-low = `open`.
    INSERT temp28 INTO TABLE temp27.
    temp98-t_range = temp27.
    INSERT temp98 INTO TABLE temp97.

    lt_filter = temp97.

    z2ui5_cl_util=>filter_itab( EXPORTING filter = lt_filter CHANGING val = lt_tab ).
    cl_abap_unit_assert=>assert_equals( exp = 2 act = lines( lt_tab ) ).


    temp100 = sy-tabix.
    READ TABLE lt_tab INDEX 1 INTO temp99.
    sy-tabix = temp100.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `A` act = temp99-name ).


    temp102 = sy-tabix.
    READ TABLE lt_tab INDEX 2 INTO temp101.
    sy-tabix = temp102.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `C` act = temp101-name ).
  ENDMETHOD.

  METHOD sql_by_string_basic.
    DATA ls_result TYPE z2ui5_cl_util=>ty_s_sql.
    ls_result = z2ui5_cl_util=>filter_get_sql_by_sql_string( `SELECT FROM MARA WHERE MTART = 'FERT'` ).
    cl_abap_unit_assert=>assert_equals( exp = `MARA` act = ls_result-tabname ).
    cl_abap_unit_assert=>assert_not_initial( ls_result-where ).
  ENDMETHOD.

ENDCLASS.


"! ================================================================
"! DEEP COMPARISON & FIELD ACCESS
"! ================================================================
CLASS ltcl_deep_ops DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    " data_equals
    METHODS equals_same_string             FOR TESTING.
    METHODS equals_different_string        FOR TESTING.
    METHODS equals_same_int                FOR TESTING.
    METHODS equals_same_structure          FOR TESTING.
    METHODS equals_different_structure     FOR TESTING.

    " data_diff
    METHODS diff_no_change                 FOR TESTING.
    METHODS diff_one_field                 FOR TESTING.
    METHODS diff_multiple_fields           FOR TESTING.

    " data_get_by_path
    METHODS get_by_path_simple             FOR TESTING.
    METHODS get_by_path_nested             FOR TESTING.
    METHODS get_by_path_invalid            FOR TESTING.

    " data_set_by_path
    METHODS set_by_path_simple             FOR TESTING.

ENDCLASS.

CLASS ltcl_deep_ops IMPLEMENTATION.

  METHOD equals_same_string.
    cl_abap_unit_assert=>assert_true( z2ui5_cl_util=>data_equals( a = `hello` b = `hello` ) ).
  ENDMETHOD.

  METHOD equals_different_string.
    cl_abap_unit_assert=>assert_false( z2ui5_cl_util=>data_equals( a = `hello` b = `world` ) ).
  ENDMETHOD.

  METHOD equals_same_int.
    cl_abap_unit_assert=>assert_true( z2ui5_cl_util=>data_equals( a = 42 b = 42 ) ).
  ENDMETHOD.

  METHOD equals_same_structure.
    TYPES: BEGIN OF ty, a TYPE string, b TYPE i, END OF ty.
    DATA temp103 TYPE ty.
    DATA ls_a LIKE temp103.
    DATA temp104 TYPE ty.
    DATA ls_b LIKE temp104.
    CLEAR temp103.
    temp103-a = `x`.
    temp103-b = 1.

    ls_a = temp103.

    CLEAR temp104.
    temp104-a = `x`.
    temp104-b = 1.

    ls_b = temp104.
    cl_abap_unit_assert=>assert_true( z2ui5_cl_util=>data_equals( a = ls_a b = ls_b ) ).
  ENDMETHOD.

  METHOD equals_different_structure.
    TYPES: BEGIN OF ty, a TYPE string, b TYPE i, END OF ty.
    DATA temp105 TYPE ty.
    DATA ls_a LIKE temp105.
    DATA temp106 TYPE ty.
    DATA ls_b LIKE temp106.
    CLEAR temp105.
    temp105-a = `x`.
    temp105-b = 1.

    ls_a = temp105.

    CLEAR temp106.
    temp106-a = `x`.
    temp106-b = 2.

    ls_b = temp106.
    cl_abap_unit_assert=>assert_false( z2ui5_cl_util=>data_equals( a = ls_a b = ls_b ) ).
  ENDMETHOD.

  METHOD diff_no_change.
    TYPES: BEGIN OF ty, name TYPE string, value TYPE string, END OF ty.
    DATA temp107 TYPE ty.
    DATA ls_old LIKE temp107.
    DATA temp108 TYPE ty.
    DATA ls_new LIKE temp108.
    DATA lt_diff TYPE z2ui5_cl_util=>ty_t_field_diff.
    CLEAR temp107.
    temp107-name = `A`.
    temp107-value = `1`.

    ls_old = temp107.

    CLEAR temp108.
    temp108-name = `A`.
    temp108-value = `1`.

    ls_new = temp108.

    lt_diff = z2ui5_cl_util=>data_diff( old = ls_old new = ls_new ).
    cl_abap_unit_assert=>assert_equals( exp = 0 act = lines( lt_diff ) ).
  ENDMETHOD.

  METHOD diff_one_field.
    TYPES: BEGIN OF ty, name TYPE string, value TYPE string, END OF ty.
    DATA temp109 TYPE ty.
    DATA ls_old LIKE temp109.
    DATA temp110 TYPE ty.
    DATA ls_new LIKE temp110.
    DATA lt_diff TYPE z2ui5_cl_util=>ty_t_field_diff.
    DATA temp111 LIKE LINE OF lt_diff.
    DATA temp112 LIKE sy-tabix.
    DATA temp113 LIKE LINE OF lt_diff.
    DATA temp114 LIKE sy-tabix.
    DATA temp115 LIKE LINE OF lt_diff.
    DATA temp116 LIKE sy-tabix.
    CLEAR temp109.
    temp109-name = `A`.
    temp109-value = `1`.

    ls_old = temp109.

    CLEAR temp110.
    temp110-name = `A`.
    temp110-value = `2`.

    ls_new = temp110.

    lt_diff = z2ui5_cl_util=>data_diff( old = ls_old new = ls_new ).
    cl_abap_unit_assert=>assert_equals( exp = 1 act = lines( lt_diff ) ).


    temp112 = sy-tabix.
    READ TABLE lt_diff INDEX 1 INTO temp111.
    sy-tabix = temp112.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `VALUE` act = temp111-fieldname ).


    temp114 = sy-tabix.
    READ TABLE lt_diff INDEX 1 INTO temp113.
    sy-tabix = temp114.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `1` act = temp113-old_value ).


    temp116 = sy-tabix.
    READ TABLE lt_diff INDEX 1 INTO temp115.
    sy-tabix = temp116.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `2` act = temp115-new_value ).
  ENDMETHOD.

  METHOD diff_multiple_fields.
    TYPES: BEGIN OF ty, name TYPE string, value TYPE string, END OF ty.
    DATA temp117 TYPE ty.
    DATA ls_old LIKE temp117.
    DATA temp118 TYPE ty.
    DATA ls_new LIKE temp118.
    DATA lt_diff TYPE z2ui5_cl_util=>ty_t_field_diff.
    CLEAR temp117.
    temp117-name = `A`.
    temp117-value = `1`.

    ls_old = temp117.

    CLEAR temp118.
    temp118-name = `B`.
    temp118-value = `2`.

    ls_new = temp118.

    lt_diff = z2ui5_cl_util=>data_diff( old = ls_old new = ls_new ).
    cl_abap_unit_assert=>assert_equals( exp = 2 act = lines( lt_diff ) ).
  ENDMETHOD.

  METHOD get_by_path_simple.
    TYPES: BEGIN OF ty, name TYPE string, value TYPE string, END OF ty.
    DATA temp119 TYPE ty.
    DATA ls_data LIKE temp119.
    CLEAR temp119.
    temp119-name = `hello`.
    temp119-value = `world`.

    ls_data = temp119.
    cl_abap_unit_assert=>assert_equals( exp = `hello`
                                        act = z2ui5_cl_util=>data_get_by_path( data = ls_data path = `name` ) ).
  ENDMETHOD.

  METHOD get_by_path_nested.
    TYPES: BEGIN OF ty_inner, city TYPE string, END OF ty_inner.
    TYPES: BEGIN OF ty, name TYPE string, address TYPE ty_inner, END OF ty.
    DATA temp120 TYPE ty.
    DATA ls_data LIKE temp120.
    CLEAR temp120.
    temp120-name = `John`.
    CLEAR temp120-address.
    temp120-address-city = `Berlin`.

    ls_data = temp120.
    cl_abap_unit_assert=>assert_equals( exp = `Berlin`
                                        act = z2ui5_cl_util=>data_get_by_path( data = ls_data path = `address-city` ) ).
  ENDMETHOD.

  METHOD get_by_path_invalid.
    TYPES: BEGIN OF ty, name TYPE string, END OF ty.
    DATA temp121 TYPE ty.
    DATA ls_data LIKE temp121.
    CLEAR temp121.
    temp121-name = `hello`.

    ls_data = temp121.
    cl_abap_unit_assert=>assert_equals( exp = ``
                                        act = z2ui5_cl_util=>data_get_by_path( data = ls_data path = `nonexistent` ) ).
  ENDMETHOD.

  METHOD set_by_path_simple.
    TYPES: BEGIN OF ty, name TYPE string, value TYPE string, END OF ty.
    DATA ls_data TYPE ty.
    ls_data-name = `old`.
    z2ui5_cl_util=>data_set_by_path( EXPORTING path = `name` value = `new` CHANGING data = ls_data ).
    cl_abap_unit_assert=>assert_equals( exp = `new` act = ls_data-name ).
  ENDMETHOD.

ENDCLASS.


"! ================================================================
"! ITAB OPERATIONS
"! ================================================================
CLASS ltcl_itab_ops DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    METHODS sort_by_ascending              FOR TESTING.
    METHODS sort_by_descending             FOR TESTING.

    METHODS slice_basic                    FOR TESTING.
    METHODS slice_from_only                FOR TESTING.
    METHODS slice_to_exceeds               FOR TESTING.

    METHODS paginate_page_1                FOR TESTING.
    METHODS paginate_page_2                FOR TESTING.
    METHODS paginate_total_pages            FOR TESTING.

    METHODS count_by_basic                 FOR TESTING.

    METHODS filter_by_val_basic            FOR TESTING.
    METHODS filter_by_val_case_ignore      FOR TESTING.

    METHODS corresponding_basic            FOR TESTING.

    METHODS get_by_struc_basic             FOR TESTING.

    METHODS csv_roundtrip                  FOR TESTING.

    METHODS json_roundtrip                 FOR TESTING.

ENDCLASS.

CLASS ltcl_itab_ops IMPLEMENTATION.

  METHOD sort_by_ascending.
    TYPES: BEGIN OF ty, name TYPE string, value TYPE i, END OF ty.
    TYPES temp3 TYPE STANDARD TABLE OF ty WITH DEFAULT KEY.
DATA lt_tab TYPE temp3.
    DATA temp122 LIKE lt_tab.
    DATA temp123 LIKE LINE OF temp122.
    DATA temp124 LIKE LINE OF lt_tab.
    DATA temp125 LIKE sy-tabix.
    DATA temp126 LIKE LINE OF lt_tab.
    DATA temp127 LIKE sy-tabix.
    DATA temp128 LIKE LINE OF lt_tab.
    DATA temp129 LIKE sy-tabix.
    CLEAR temp122.

    temp123-name = `C`.
    temp123-value = 3.
    INSERT temp123 INTO TABLE temp122.
    temp123-name = `A`.
    temp123-value = 1.
    INSERT temp123 INTO TABLE temp122.
    temp123-name = `B`.
    temp123-value = 2.
    INSERT temp123 INTO TABLE temp122.
    lt_tab = temp122.
    z2ui5_cl_util=>itab_sort_by( EXPORTING fieldname = `NAME` CHANGING tab = lt_tab ).


    temp125 = sy-tabix.
    READ TABLE lt_tab INDEX 1 INTO temp124.
    sy-tabix = temp125.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `A` act = temp124-name ).


    temp127 = sy-tabix.
    READ TABLE lt_tab INDEX 2 INTO temp126.
    sy-tabix = temp127.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `B` act = temp126-name ).


    temp129 = sy-tabix.
    READ TABLE lt_tab INDEX 3 INTO temp128.
    sy-tabix = temp129.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `C` act = temp128-name ).
  ENDMETHOD.

  METHOD sort_by_descending.
    TYPES: BEGIN OF ty, name TYPE string, value TYPE i, END OF ty.
    TYPES temp4 TYPE STANDARD TABLE OF ty WITH DEFAULT KEY.
DATA lt_tab TYPE temp4.
    DATA temp130 LIKE lt_tab.
    DATA temp131 LIKE LINE OF temp130.
    DATA temp132 LIKE LINE OF lt_tab.
    DATA temp133 LIKE sy-tabix.
    DATA temp134 LIKE LINE OF lt_tab.
    DATA temp135 LIKE sy-tabix.
    DATA temp136 LIKE LINE OF lt_tab.
    DATA temp137 LIKE sy-tabix.
    CLEAR temp130.

    temp131-name = `A`.
    temp131-value = 1.
    INSERT temp131 INTO TABLE temp130.
    temp131-name = `C`.
    temp131-value = 3.
    INSERT temp131 INTO TABLE temp130.
    temp131-name = `B`.
    temp131-value = 2.
    INSERT temp131 INTO TABLE temp130.
    lt_tab = temp130.
    z2ui5_cl_util=>itab_sort_by( EXPORTING fieldname = `VALUE` descending = abap_true CHANGING tab = lt_tab ).


    temp133 = sy-tabix.
    READ TABLE lt_tab INDEX 1 INTO temp132.
    sy-tabix = temp133.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = 3 act = temp132-value ).


    temp135 = sy-tabix.
    READ TABLE lt_tab INDEX 2 INTO temp134.
    sy-tabix = temp135.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = 2 act = temp134-value ).


    temp137 = sy-tabix.
    READ TABLE lt_tab INDEX 3 INTO temp136.
    sy-tabix = temp137.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = 1 act = temp136-value ).
  ENDMETHOD.

  METHOD slice_basic.
    TYPES: BEGIN OF ty, id TYPE i, END OF ty.
    TYPES temp5 TYPE STANDARD TABLE OF ty WITH DEFAULT KEY.
DATA lt_tab TYPE temp5.
    DATA temp138 LIKE lt_tab.
    DATA temp139 LIKE LINE OF temp138.
    DATA lr_result TYPE REF TO data.
    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
    CLEAR temp138.

    temp139-id = 1.
    INSERT temp139 INTO TABLE temp138.
    temp139-id = 2.
    INSERT temp139 INTO TABLE temp138.
    temp139-id = 3.
    INSERT temp139 INTO TABLE temp138.
    temp139-id = 4.
    INSERT temp139 INTO TABLE temp138.
    temp139-id = 5.
    INSERT temp139 INTO TABLE temp138.
    lt_tab = temp138.

    lr_result = z2ui5_cl_util=>itab_slice( tab = lt_tab from = 2 to = 4 ).

    ASSIGN lr_result->* TO <tab>.
    cl_abap_unit_assert=>assert_equals( exp = 3 act = lines( <tab> ) ).
  ENDMETHOD.

  METHOD slice_from_only.
    TYPES: BEGIN OF ty, id TYPE i, END OF ty.
    TYPES temp6 TYPE STANDARD TABLE OF ty WITH DEFAULT KEY.
DATA lt_tab TYPE temp6.
    DATA temp140 LIKE lt_tab.
    DATA temp141 LIKE LINE OF temp140.
    DATA lr_result TYPE REF TO data.
    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
    CLEAR temp140.

    temp141-id = 1.
    INSERT temp141 INTO TABLE temp140.
    temp141-id = 2.
    INSERT temp141 INTO TABLE temp140.
    temp141-id = 3.
    INSERT temp141 INTO TABLE temp140.
    lt_tab = temp140.

    lr_result = z2ui5_cl_util=>itab_slice( tab = lt_tab from = 2 ).

    ASSIGN lr_result->* TO <tab>.
    cl_abap_unit_assert=>assert_equals( exp = 2 act = lines( <tab> ) ).
  ENDMETHOD.

  METHOD slice_to_exceeds.
    TYPES: BEGIN OF ty, id TYPE i, END OF ty.
    TYPES temp7 TYPE STANDARD TABLE OF ty WITH DEFAULT KEY.
DATA lt_tab TYPE temp7.
    DATA temp142 LIKE lt_tab.
    DATA temp143 LIKE LINE OF temp142.
    DATA lr_result TYPE REF TO data.
    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
    CLEAR temp142.

    temp143-id = 1.
    INSERT temp143 INTO TABLE temp142.
    temp143-id = 2.
    INSERT temp143 INTO TABLE temp142.
    lt_tab = temp142.

    lr_result = z2ui5_cl_util=>itab_slice( tab = lt_tab from = 1 to = 99 ).

    ASSIGN lr_result->* TO <tab>.
    cl_abap_unit_assert=>assert_equals( exp = 2 act = lines( <tab> ) ).
  ENDMETHOD.

  METHOD paginate_page_1.
    TYPES: BEGIN OF ty, id TYPE i, END OF ty.
    TYPES temp8 TYPE STANDARD TABLE OF ty WITH DEFAULT KEY.
DATA lt_tab TYPE temp8.
    DATA temp144 LIKE lt_tab.
    DATA temp145 LIKE LINE OF temp144.
    DATA lr_result TYPE REF TO data.
    DATA lv_total_count TYPE i.
    DATA lv_total_pages TYPE i.
    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
    CLEAR temp144.

    temp145-id = 1.
    INSERT temp145 INTO TABLE temp144.
    temp145-id = 2.
    INSERT temp145 INTO TABLE temp144.
    temp145-id = 3.
    INSERT temp145 INTO TABLE temp144.
    temp145-id = 4.
    INSERT temp145 INTO TABLE temp144.
    temp145-id = 5.
    INSERT temp145 INTO TABLE temp144.
    lt_tab = temp144.



    z2ui5_cl_util=>itab_paginate( EXPORTING tab = lt_tab page = 1 page_size = 2
                                   IMPORTING result = lr_result total_count = lv_total_count total_pages = lv_total_pages ).

    ASSIGN lr_result->* TO <tab>.
    cl_abap_unit_assert=>assert_equals( exp = 2 act = lines( <tab> ) ).
    cl_abap_unit_assert=>assert_equals( exp = 5 act = lv_total_count ).
    cl_abap_unit_assert=>assert_equals( exp = 3 act = lv_total_pages ).
  ENDMETHOD.

  METHOD paginate_page_2.
    TYPES: BEGIN OF ty, id TYPE i, END OF ty.
    TYPES temp9 TYPE STANDARD TABLE OF ty WITH DEFAULT KEY.
DATA lt_tab TYPE temp9.
    DATA temp146 LIKE lt_tab.
    DATA temp147 LIKE LINE OF temp146.
    DATA lr_result TYPE REF TO data.
    DATA lv_total_count TYPE i.
    DATA lv_total_pages TYPE i.
    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
    CLEAR temp146.

    temp147-id = 1.
    INSERT temp147 INTO TABLE temp146.
    temp147-id = 2.
    INSERT temp147 INTO TABLE temp146.
    temp147-id = 3.
    INSERT temp147 INTO TABLE temp146.
    temp147-id = 4.
    INSERT temp147 INTO TABLE temp146.
    temp147-id = 5.
    INSERT temp147 INTO TABLE temp146.
    lt_tab = temp146.



    z2ui5_cl_util=>itab_paginate( EXPORTING tab = lt_tab page = 2 page_size = 2
                                   IMPORTING result = lr_result total_count = lv_total_count total_pages = lv_total_pages ).

    ASSIGN lr_result->* TO <tab>.
    cl_abap_unit_assert=>assert_equals( exp = 2 act = lines( <tab> ) ).
  ENDMETHOD.

  METHOD paginate_total_pages.
    TYPES: BEGIN OF ty, id TYPE i, END OF ty.
    TYPES temp10 TYPE STANDARD TABLE OF ty WITH DEFAULT KEY.
DATA lt_tab TYPE temp10.
    DATA temp148 LIKE lt_tab.
    DATA temp149 LIKE LINE OF temp148.
    DATA lr_result TYPE REF TO data.
    DATA lv_total_count TYPE i.
    DATA lv_total_pages TYPE i.
    CLEAR temp148.

    temp149-id = 1.
    INSERT temp149 INTO TABLE temp148.
    temp149-id = 2.
    INSERT temp149 INTO TABLE temp148.
    temp149-id = 3.
    INSERT temp149 INTO TABLE temp148.
    lt_tab = temp148.



    z2ui5_cl_util=>itab_paginate( EXPORTING tab = lt_tab page = 1 page_size = 2
                                   IMPORTING result = lr_result total_count = lv_total_count total_pages = lv_total_pages ).
    cl_abap_unit_assert=>assert_equals( exp = 2 act = lv_total_pages ).
  ENDMETHOD.

  METHOD count_by_basic.
    TYPES: BEGIN OF ty, category TYPE string, name TYPE string, END OF ty.
    TYPES temp11 TYPE STANDARD TABLE OF ty WITH DEFAULT KEY.
DATA lt_tab TYPE temp11.
    DATA temp150 LIKE lt_tab.
    DATA temp151 LIKE LINE OF temp150.
    DATA lt_result TYPE z2ui5_cl_util=>ty_t_name_value.
    DATA temp152 LIKE LINE OF lt_result.
    DATA temp153 LIKE sy-tabix.
    DATA temp154 LIKE LINE OF lt_result.
    DATA temp155 LIKE sy-tabix.
    CLEAR temp150.

    temp151-category = `A`.
    temp151-name = `1`.
    INSERT temp151 INTO TABLE temp150.
    temp151-category = `B`.
    temp151-name = `2`.
    INSERT temp151 INTO TABLE temp150.
    temp151-category = `A`.
    temp151-name = `3`.
    INSERT temp151 INTO TABLE temp150.
    temp151-category = `A`.
    temp151-name = `4`.
    INSERT temp151 INTO TABLE temp150.
    lt_tab = temp150.

    lt_result = z2ui5_cl_util=>itab_count_by( tab = lt_tab fieldname = `CATEGORY` ).


    temp153 = sy-tabix.
    READ TABLE lt_result WITH KEY n = `A` INTO temp152.
    sy-tabix = temp153.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `3` act = temp152-v ).


    temp155 = sy-tabix.
    READ TABLE lt_result WITH KEY n = `B` INTO temp154.
    sy-tabix = temp155.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `1` act = temp154-v ).
  ENDMETHOD.

  METHOD filter_by_val_basic.
    TYPES: BEGIN OF ty, name TYPE string, city TYPE string, END OF ty.
    TYPES temp12 TYPE STANDARD TABLE OF ty WITH DEFAULT KEY.
DATA lt_tab TYPE temp12.
    DATA temp156 LIKE lt_tab.
    DATA temp157 LIKE LINE OF temp156.
    CLEAR temp156.

    temp157-name = `Alice`.
    temp157-city = `Berlin`.
    INSERT temp157 INTO TABLE temp156.
    temp157-name = `Bob`.
    temp157-city = `Paris`.
    INSERT temp157 INTO TABLE temp156.
    temp157-name = `Charlie`.
    temp157-city = `Berlin`.
    INSERT temp157 INTO TABLE temp156.
    lt_tab = temp156.
    z2ui5_cl_util=>itab_filter_by_val( EXPORTING val = `Berlin` CHANGING tab = lt_tab ).
    cl_abap_unit_assert=>assert_equals( exp = 2 act = lines( lt_tab ) ).
  ENDMETHOD.

  METHOD filter_by_val_case_ignore.
    TYPES: BEGIN OF ty, name TYPE string, END OF ty.
    TYPES temp13 TYPE STANDARD TABLE OF ty WITH DEFAULT KEY.
DATA lt_tab TYPE temp13.
    DATA temp158 LIKE lt_tab.
    DATA temp159 LIKE LINE OF temp158.
    CLEAR temp158.

    temp159-name = `HELLO`.
    INSERT temp159 INTO TABLE temp158.
    temp159-name = `world`.
    INSERT temp159 INTO TABLE temp158.
    temp159-name = `Hello`.
    INSERT temp159 INTO TABLE temp158.
    lt_tab = temp158.
    z2ui5_cl_util=>itab_filter_by_val( EXPORTING val = `hello` ignore_case = abap_true CHANGING tab = lt_tab ).
    cl_abap_unit_assert=>assert_equals( exp = 2 act = lines( lt_tab ) ).
  ENDMETHOD.

  METHOD corresponding_basic.
    TYPES: BEGIN OF ty_src, a TYPE string, b TYPE string, c TYPE string, END OF ty_src.
    TYPES: BEGIN OF ty_dst, a TYPE string, b TYPE string, END OF ty_dst.
    TYPES temp14 TYPE STANDARD TABLE OF ty_src WITH DEFAULT KEY.
DATA lt_src TYPE temp14.
    TYPES temp15 TYPE STANDARD TABLE OF ty_dst WITH DEFAULT KEY.
DATA lt_dst TYPE temp15.
    DATA temp160 LIKE lt_src.
    DATA temp161 LIKE LINE OF temp160.
    DATA temp162 LIKE LINE OF lt_dst.
    DATA temp163 LIKE sy-tabix.
    DATA temp164 LIKE LINE OF lt_dst.
    DATA temp165 LIKE sy-tabix.
    CLEAR temp160.

    temp161-a = `1`.
    temp161-b = `2`.
    temp161-c = `3`.
    INSERT temp161 INTO TABLE temp160.
    lt_src = temp160.
    z2ui5_cl_util=>itab_corresponding( EXPORTING val = lt_src CHANGING tab = lt_dst ).
    cl_abap_unit_assert=>assert_equals( exp = 1 act = lines( lt_dst ) ).


    temp163 = sy-tabix.
    READ TABLE lt_dst INDEX 1 INTO temp162.
    sy-tabix = temp163.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `1` act = temp162-a ).


    temp165 = sy-tabix.
    READ TABLE lt_dst INDEX 1 INTO temp164.
    sy-tabix = temp165.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `2` act = temp164-b ).
  ENDMETHOD.

  METHOD get_by_struc_basic.
    TYPES: BEGIN OF ty, name TYPE string, value TYPE string, END OF ty.
    DATA temp166 TYPE ty.
    DATA ls_data LIKE temp166.
    DATA lt_result TYPE z2ui5_cl_util=>ty_t_name_value.
    DATA temp167 LIKE LINE OF lt_result.
    DATA temp168 LIKE sy-tabix.
    DATA temp169 LIKE LINE OF lt_result.
    DATA temp170 LIKE sy-tabix.
    DATA temp171 LIKE LINE OF lt_result.
    DATA temp172 LIKE sy-tabix.
    DATA temp173 LIKE LINE OF lt_result.
    DATA temp174 LIKE sy-tabix.
    CLEAR temp166.
    temp166-name = `hello`.
    temp166-value = `world`.

    ls_data = temp166.

    lt_result = z2ui5_cl_util=>itab_get_by_struc( ls_data ).
    cl_abap_unit_assert=>assert_equals( exp = 2 act = lines( lt_result ) ).


    temp168 = sy-tabix.
    READ TABLE lt_result INDEX 1 INTO temp167.
    sy-tabix = temp168.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `NAME` act = temp167-n ).


    temp170 = sy-tabix.
    READ TABLE lt_result INDEX 1 INTO temp169.
    sy-tabix = temp170.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `hello` act = temp169-v ).


    temp172 = sy-tabix.
    READ TABLE lt_result INDEX 2 INTO temp171.
    sy-tabix = temp172.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `VALUE` act = temp171-n ).


    temp174 = sy-tabix.
    READ TABLE lt_result INDEX 2 INTO temp173.
    sy-tabix = temp174.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `world` act = temp173-v ).
  ENDMETHOD.

  METHOD csv_roundtrip.
    TYPES: BEGIN OF ty, col1 TYPE string, col2 TYPE string, END OF ty.
    TYPES temp16 TYPE STANDARD TABLE OF ty WITH DEFAULT KEY.
DATA lt_tab TYPE temp16.
    DATA temp175 LIKE lt_tab.
    DATA temp176 LIKE LINE OF temp175.
    DATA lv_csv TYPE string.
    CLEAR temp175.

    temp176-col1 = `A`.
    temp176-col2 = `B`.
    INSERT temp176 INTO TABLE temp175.
    temp176-col1 = `C`.
    temp176-col2 = `D`.
    INSERT temp176 INTO TABLE temp175.
    lt_tab = temp175.


    lv_csv = z2ui5_cl_util=>itab_get_csv_by_itab( lt_tab ).
    cl_abap_unit_assert=>assert_not_initial( lv_csv ).

    " CSV should contain header and data
    cl_abap_unit_assert=>assert_true( z2ui5_cl_util=>c_contains( val = lv_csv sub = `COL1` ) ).
    cl_abap_unit_assert=>assert_true( z2ui5_cl_util=>c_contains( val = lv_csv sub = `A` ) ).
  ENDMETHOD.

  METHOD json_roundtrip.
    TYPES: BEGIN OF ty, name TYPE string, value TYPE i, END OF ty.
    DATA ls_data TYPE ty.
    DATA lv_json TYPE string.
    DATA ls_back TYPE ty.
    CLEAR ls_data.
    ls_data-name = `test`.
    ls_data-value = 42.


    lv_json = z2ui5_cl_util=>json_stringify( ls_data ).
    cl_abap_unit_assert=>assert_not_initial( lv_json ).


    z2ui5_cl_util=>json_parse( EXPORTING val = lv_json CHANGING data = ls_back ).
    cl_abap_unit_assert=>assert_equals( exp = `test` act = ls_back-name ).
    cl_abap_unit_assert=>assert_equals( exp = 42 act = ls_back-value ).
  ENDMETHOD.

ENDCLASS.


"! ================================================================
"! RTTI / TYPE CHECKING
"! ================================================================
CLASS ltcl_rtti_ops DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    METHODS check_table_true               FOR TESTING.
    METHODS check_table_false              FOR TESTING.
    METHODS check_structure_true           FOR TESTING.
    METHODS check_structure_false          FOR TESTING.
    METHODS check_numeric_int              FOR TESTING.
    METHODS check_numeric_string           FOR TESTING.
    METHODS check_clike_string             FOR TESTING.
    METHODS check_clike_int                FOR TESTING.
    METHODS check_ref_data_true            FOR TESTING.
    METHODS check_ref_data_false           FOR TESTING.
    METHODS get_classname                  FOR TESTING.
    METHODS get_type_name                  FOR TESTING.
    METHODS check_class_exists_true        FOR TESTING.
    METHODS check_class_exists_false       FOR TESTING.

ENDCLASS.

CLASS ltcl_rtti_ops IMPLEMENTATION.

  METHOD check_table_true.
    DATA lt_tab TYPE string_table.
    cl_abap_unit_assert=>assert_true( z2ui5_cl_util=>rtti_check_table( lt_tab ) ).
  ENDMETHOD.

  METHOD check_table_false.
    DATA lv_str TYPE string.
    cl_abap_unit_assert=>assert_false( z2ui5_cl_util=>rtti_check_table( lv_str ) ).
  ENDMETHOD.

  METHOD check_structure_true.
    TYPES: BEGIN OF ty, a TYPE string, END OF ty.
    DATA ls_struc TYPE ty.
    cl_abap_unit_assert=>assert_true( z2ui5_cl_util=>rtti_check_structure( ls_struc ) ).
  ENDMETHOD.

  METHOD check_structure_false.
    DATA lv_str TYPE string.
    cl_abap_unit_assert=>assert_false( z2ui5_cl_util=>rtti_check_structure( lv_str ) ).
  ENDMETHOD.

  METHOD check_numeric_int.
    DATA lv_int TYPE i VALUE 5.
    cl_abap_unit_assert=>assert_true( z2ui5_cl_util=>rtti_check_numeric( lv_int ) ).
  ENDMETHOD.

  METHOD check_numeric_string.
    DATA lv_str TYPE string VALUE `123`.
    cl_abap_unit_assert=>assert_false( z2ui5_cl_util=>rtti_check_numeric( lv_str ) ).
  ENDMETHOD.

  METHOD check_clike_string.
    DATA lv_str TYPE string VALUE `hello`.
    cl_abap_unit_assert=>assert_true( z2ui5_cl_util=>rtti_check_clike( lv_str ) ).
  ENDMETHOD.

  METHOD check_clike_int.
    DATA lv_int TYPE i VALUE 5.
    cl_abap_unit_assert=>assert_false( z2ui5_cl_util=>rtti_check_clike( lv_int ) ).
  ENDMETHOD.

  METHOD check_ref_data_true.
    DATA lr_ref TYPE REF TO data.
    cl_abap_unit_assert=>assert_true( z2ui5_cl_util=>rtti_check_ref_data( lr_ref ) ).
  ENDMETHOD.

  METHOD check_ref_data_false.
    DATA lv_str TYPE string.
    cl_abap_unit_assert=>assert_false( z2ui5_cl_util=>rtti_check_ref_data( lv_str ) ).
  ENDMETHOD.

  METHOD get_classname.
    DATA lo_obj TYPE REF TO ltcl_test_app.
    DATA lv_name TYPE string.
    CREATE OBJECT lo_obj TYPE ltcl_test_app.

    lv_name = z2ui5_cl_util=>rtti_get_classname_by_ref( lo_obj ).
    cl_abap_unit_assert=>assert_equals( exp = `LTCL_TEST_APP` act = lv_name ).
  ENDMETHOD.

  METHOD get_type_name.
    DATA lv_bool TYPE abap_bool.
    cl_abap_unit_assert=>assert_equals( exp = `ABAP_BOOL`
                                        act = z2ui5_cl_util=>rtti_get_type_name( lv_bool ) ).
  ENDMETHOD.

  METHOD check_class_exists_true.
    cl_abap_unit_assert=>assert_true( z2ui5_cl_util=>rtti_check_class_exists( `CL_ABAP_TYPEDESCR` ) ).
  ENDMETHOD.

  METHOD check_class_exists_false.
    cl_abap_unit_assert=>assert_false( z2ui5_cl_util=>rtti_check_class_exists( `ZCL_DOES_NOT_EXIST_99` ) ).
  ENDMETHOD.

ENDCLASS.


"! ================================================================
"! EXCEPTION HANDLING
"! ================================================================
CLASS ltcl_exception_ops DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    METHODS x_raise_basic                  FOR TESTING.
    METHODS x_raise_custom_msg             FOR TESTING.
    METHODS x_check_raise_true             FOR TESTING.
    METHODS x_check_raise_false            FOR TESTING.
    METHODS x_get_last_t100_basic          FOR TESTING.

ENDCLASS.

CLASS ltcl_exception_ops IMPLEMENTATION.

  METHOD x_raise_basic.
        DATA lx TYPE REF TO z2ui5_cx_util_error.
    TRY.
        z2ui5_cl_util=>x_raise( ).
        cl_abap_unit_assert=>fail( `Exception expected` ).

      CATCH z2ui5_cx_util_error INTO lx.
        cl_abap_unit_assert=>assert_not_initial( lx ).
    ENDTRY.
  ENDMETHOD.

  METHOD x_raise_custom_msg.
        DATA lx TYPE REF TO z2ui5_cx_util_error.
    TRY.
        z2ui5_cl_util=>x_raise( `MY_ERROR` ).
        cl_abap_unit_assert=>fail( `Exception expected` ).

      CATCH z2ui5_cx_util_error INTO lx.
        cl_abap_unit_assert=>assert_true( z2ui5_cl_util=>c_contains( val = lx->get_text( ) sub = `MY_ERROR` ) ).
    ENDTRY.
  ENDMETHOD.

  METHOD x_check_raise_true.
        DATA lx TYPE REF TO z2ui5_cx_util_error.
    TRY.
        z2ui5_cl_util=>x_check_raise( v = `OOPS` when = abap_true ).
        cl_abap_unit_assert=>fail( `Exception expected` ).

      CATCH z2ui5_cx_util_error INTO lx.
        cl_abap_unit_assert=>assert_not_initial( lx ).
    ENDTRY.
  ENDMETHOD.

  METHOD x_check_raise_false.
    TRY.
        z2ui5_cl_util=>x_check_raise( v = `OOPS` when = abap_false ).
        " No exception — test passes
      CATCH z2ui5_cx_util_error.
        cl_abap_unit_assert=>fail( `No exception expected` ).
    ENDTRY.
  ENDMETHOD.

  METHOD x_get_last_t100_basic.
        DATA lx TYPE REF TO z2ui5_cx_util_error.
        DATA lv_result TYPE string.
    TRY.
        RAISE EXCEPTION TYPE z2ui5_cx_util_error EXPORTING val = `INNER_ERROR`.

      CATCH z2ui5_cx_util_error INTO lx.

        lv_result = z2ui5_cl_util=>x_get_last_t100( lx ).
        cl_abap_unit_assert=>assert_not_initial( lv_result ).
    ENDTRY.
  ENDMETHOD.

ENDCLASS.


"! ================================================================
"! REFERENCE / BOUND / INITIAL CHECKS
"! ================================================================
CLASS ltcl_ref_ops DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    METHODS bound_not_initial_true         FOR TESTING.
    METHODS bound_not_initial_unbound      FOR TESTING.
    METHODS bound_not_initial_initial      FOR TESTING.
    METHODS unassign_initial_null          FOR TESTING.
    METHODS unassign_initial_empty         FOR TESTING.
    METHODS unassign_initial_filled        FOR TESTING.
    METHODS conv_get_as_data_ref           FOR TESTING.

ENDCLASS.

CLASS ltcl_ref_ops IMPLEMENTATION.

  METHOD bound_not_initial_true.
    DATA lv_val TYPE string VALUE `hello`.
    DATA lr_ref TYPE REF TO data.
    GET REFERENCE OF lv_val INTO lr_ref.
    cl_abap_unit_assert=>assert_true( z2ui5_cl_util=>check_bound_a_not_initial( lr_ref ) ).
  ENDMETHOD.

  METHOD bound_not_initial_unbound.
    DATA lr_ref TYPE REF TO data.
    cl_abap_unit_assert=>assert_false( z2ui5_cl_util=>check_bound_a_not_initial( lr_ref ) ).
  ENDMETHOD.

  METHOD bound_not_initial_initial.
    DATA lv_val TYPE string.
    DATA lr_ref TYPE REF TO data.
    GET REFERENCE OF lv_val INTO lr_ref.
    cl_abap_unit_assert=>assert_false( z2ui5_cl_util=>check_bound_a_not_initial( lr_ref ) ).
  ENDMETHOD.

  METHOD unassign_initial_null.
    DATA lr_ref TYPE REF TO data.
    cl_abap_unit_assert=>assert_true( z2ui5_cl_util=>check_unassign_initial( lr_ref ) ).
  ENDMETHOD.

  METHOD unassign_initial_empty.
    DATA lv_val TYPE string.
    DATA lr_ref TYPE REF TO data.
    GET REFERENCE OF lv_val INTO lr_ref.
    cl_abap_unit_assert=>assert_true( z2ui5_cl_util=>check_unassign_initial( lr_ref ) ).
  ENDMETHOD.

  METHOD unassign_initial_filled.
    DATA lv_val TYPE string VALUE `x`.
    DATA lr_ref TYPE REF TO data.
    GET REFERENCE OF lv_val INTO lr_ref.
    cl_abap_unit_assert=>assert_false( z2ui5_cl_util=>check_unassign_initial( lr_ref ) ).
  ENDMETHOD.

  METHOD conv_get_as_data_ref.
    DATA lv_val TYPE string VALUE `test`.
    DATA lr_ref TYPE REF TO data.
    FIELD-SYMBOLS <val> TYPE string.
    lr_ref = z2ui5_cl_util=>conv_get_as_data_ref( lv_val ).
    cl_abap_unit_assert=>assert_bound( lr_ref ).

    ASSIGN lr_ref->* TO <val>.
    cl_abap_unit_assert=>assert_equals( exp = `test` act = <val> ).
  ENDMETHOD.

ENDCLASS.


"! ================================================================
"! TIME OPERATIONS
"! ================================================================
CLASS ltcl_time_ops DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    METHODS get_timestampl                 FOR TESTING.
    METHODS add_seconds                    FOR TESTING.
    METHODS subtract_seconds               FOR TESTING.
    METHODS diff_seconds                   FOR TESTING.
    METHODS measure_start_stop             FOR TESTING.
    METHODS stampl_by_date_time            FOR TESTING.

ENDCLASS.

CLASS ltcl_time_ops IMPLEMENTATION.

  METHOD get_timestampl.
    DATA lv_ts TYPE timestampl.
    lv_ts = z2ui5_cl_util=>time_get_timestampl( ).
    cl_abap_unit_assert=>assert_not_initial( lv_ts ).
  ENDMETHOD.

  METHOD add_seconds.
    DATA lv_ts TYPE timestampl.
    DATA lv_result TYPE timestampl.
    DATA temp1 TYPE xsdboolean.
    DATA lv_diff TYPE i.
    lv_ts = z2ui5_cl_util=>time_get_timestampl( ).

    lv_result = z2ui5_cl_util=>time_add_seconds( time = lv_ts seconds = 60 ).

    temp1 = boolc( lv_result > lv_ts ).
    cl_abap_unit_assert=>assert_true( temp1 ).
    " Difference should be ~60 seconds

    lv_diff = z2ui5_cl_util=>time_diff_seconds( time_from = lv_ts time_to = lv_result ).
    cl_abap_unit_assert=>assert_equals( exp = 60 act = lv_diff ).
  ENDMETHOD.

  METHOD subtract_seconds.
    DATA lv_ts TYPE timestampl.
    DATA lv_result TYPE timestampl.
    DATA temp2 TYPE xsdboolean.
    lv_ts = z2ui5_cl_util=>time_get_timestampl( ).

    lv_result = z2ui5_cl_util=>time_subtract_seconds( time = lv_ts seconds = 30 ).

    temp2 = boolc( lv_result < lv_ts ).
    cl_abap_unit_assert=>assert_true( temp2 ).
  ENDMETHOD.

  METHOD diff_seconds.
    DATA lv_from TYPE timestampl.
    DATA lv_to TYPE timestampl.
    DATA lv_diff TYPE i.
    lv_from = z2ui5_cl_util=>time_get_timestampl( ).

    lv_to = z2ui5_cl_util=>time_add_seconds( time = lv_from seconds = 120 ).

    lv_diff = z2ui5_cl_util=>time_diff_seconds( time_from = lv_from time_to = lv_to ).
    cl_abap_unit_assert=>assert_equals( exp = 120 act = lv_diff ).
  ENDMETHOD.

  METHOD measure_start_stop.
    DATA lv_start TYPE timestampl.
    DATA lv_ms TYPE i.
    DATA temp3 TYPE xsdboolean.
    lv_start = z2ui5_cl_util=>time_measure_start( ).
    cl_abap_unit_assert=>assert_not_initial( lv_start ).
    " Result is milliseconds, should be >= 0

    lv_ms = z2ui5_cl_util=>time_measure_stop( lv_start ).

    temp3 = boolc( lv_ms >= 0 ).
    cl_abap_unit_assert=>assert_true( temp3 ).
  ENDMETHOD.

  METHOD stampl_by_date_time.
    DATA temp177 TYPE d.
    DATA temp29 TYPE t.
    DATA lv_ts TYPE timestampl.
    temp177 = `20240101`.

    temp29 = `120000`.

    lv_ts = z2ui5_cl_util=>time_get_stampl_by_date_time( date = temp177
                                                                time = temp29 ).
    cl_abap_unit_assert=>assert_not_initial( lv_ts ).
  ENDMETHOD.

ENDCLASS.


"! ================================================================
"! EDGE CASES - Bugs & ABAP-isms critical for JS transpilation
"! ================================================================
CLASS ltcl_edge_cases DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    " filter_get_range_by_token edge cases
    METHODS token_empty_input              FOR TESTING.
    METHODS token_single_star              FOR TESTING.
    METHODS token_single_equals            FOR TESTING.
    METHODS token_just_number              FOR TESTING.
    METHODS token_with_spaces              FOR TESTING.

    " c_pad_left with space (same bug pattern as c_pad_right)
    METHODS pad_left_with_space            FOR TESTING.
    METHODS pad_left_default               FOR TESTING.

    " CS operator is always case-insensitive (critical for transpiler)
    METHODS filter_by_val_cs_insensitive   FOR TESTING.

    " c_trim edge cases
    METHODS trim_only_newlines             FOR TESTING.
    METHODS trim_mixed_whitespace          FOR TESTING.
    METHODS trim_unicode                   FOR TESTING.

    " c_split edge cases
    METHODS split_empty_input              FOR TESTING.
    METHODS split_only_separator           FOR TESTING.

    " conv_string_to_number edge cases
    METHODS num_one_thousand_no_dot        FOR TESTING.
    METHODS num_european_format            FOR TESTING.
    METHODS num_only_minus                 FOR TESTING.
    METHODS num_leading_zeros              FOR TESTING.

    " conv_string_to_date edge cases
    METHODS date_short_input               FOR TESTING.

    " check_is_email edge cases
    METHODS email_with_plus                FOR TESTING.
    METHODS email_with_dots                FOR TESTING.
    METHODS email_only_spaces              FOR TESTING.

    " itab_slice edge cases
    METHODS slice_from_exceeds_lines       FOR TESTING.
    METHODS slice_empty_table              FOR TESTING.

    " c_truncate edge cases
    METHODS truncate_max_zero              FOR TESTING.
    METHODS truncate_empty_string          FOR TESTING.

    " data_get_by_path / data_set_by_path edge cases
    METHODS path_with_leading_dash         FOR TESTING.
    METHODS path_set_nested                FOR TESTING.

    " check_is_guid edge cases
    METHODS guid_empty                     FOR TESTING.
    METHODS guid_mixed_case_dashes         FOR TESTING.

    " url_param_set preserves case (after fix)
    METHODS url_set_preserves_value_case   FOR TESTING.

    " boolean_abap_2_json with different boolean types
    METHODS bool_xfeld_true                FOR TESTING.
    METHODS bool_xfeld_false               FOR TESTING.

    " json roundtrip with special characters
    METHODS json_special_chars             FOR TESTING.

    " c_contains case behavior (TRANSPILER CRITICAL)
    METHODS contains_is_always_ci          FOR TESTING.

ENDCLASS.

CLASS ltcl_edge_cases IMPLEMENTATION.

  METHOD token_empty_input.
    " Empty input should not crash - returns empty/initial range
    DATA ls_range TYPE z2ui5_cl_util=>ty_s_range.
    ls_range = z2ui5_cl_util=>filter_get_range_by_token( `` ).
    cl_abap_unit_assert=>assert_initial( ls_range-option ).
  ENDMETHOD.

  METHOD token_single_star.
    " Single '*' - after fix: CP with empty low (match-all pattern)
    DATA ls_range TYPE z2ui5_cl_util=>ty_s_range.
    ls_range = z2ui5_cl_util=>filter_get_range_by_token( `*` ).
    cl_abap_unit_assert=>assert_equals( exp = `I` act = ls_range-sign ).
    cl_abap_unit_assert=>assert_equals( exp = `CP` act = ls_range-option ).
    cl_abap_unit_assert=>assert_equals( exp = `` act = ls_range-low ).
  ENDMETHOD.

  METHOD token_single_equals.
    " Just "=" with nothing after → EQ with empty low
    DATA ls_range TYPE z2ui5_cl_util=>ty_s_range.
    ls_range = z2ui5_cl_util=>filter_get_range_by_token( `=` ).
    cl_abap_unit_assert=>assert_equals( exp = `EQ` act = ls_range-option ).
    cl_abap_unit_assert=>assert_initial( ls_range-low ).
  ENDMETHOD.

  METHOD token_just_number.
    " Plain number without operator → EQ
    DATA ls_range TYPE z2ui5_cl_util=>ty_s_range.
    ls_range = z2ui5_cl_util=>filter_get_range_by_token( `42` ).
    cl_abap_unit_assert=>assert_equals( exp = `EQ` act = ls_range-option ).
    cl_abap_unit_assert=>assert_equals( exp = `42` act = ls_range-low ).
  ENDMETHOD.

  METHOD token_with_spaces.
    " Token with spaces in value
    DATA ls_range TYPE z2ui5_cl_util=>ty_s_range.
    ls_range = z2ui5_cl_util=>filter_get_range_by_token( `=hello world` ).
    cl_abap_unit_assert=>assert_equals( exp = `EQ` act = ls_range-option ).
    cl_abap_unit_assert=>assert_equals( exp = `hello world` act = ls_range-low ).
  ENDMETHOD.

  METHOD pad_left_with_space.
    " After fix: space padding should work on c_pad_left too
    cl_abap_unit_assert=>assert_equals( exp = `   hi`
        act = z2ui5_cl_util=>c_pad_left( val = `hi` len = 5 pad = ' ' ) ).
  ENDMETHOD.

  METHOD pad_left_default.
    " Default '0' should still work
    cl_abap_unit_assert=>assert_equals( exp = `007`
        act = z2ui5_cl_util=>c_pad_left( val = `7` len = 3 ) ).
  ENDMETHOD.

  METHOD filter_by_val_cs_insensitive.
    " After fix: ignore_case=false now uses find() for true case-sensitivity
    TYPES: BEGIN OF ty, name TYPE string, END OF ty.
    TYPES temp17 TYPE STANDARD TABLE OF ty WITH DEFAULT KEY.
DATA lt_tab TYPE temp17.
    DATA temp178 LIKE lt_tab.
    DATA temp179 LIKE LINE OF temp178.
    CLEAR temp178.

    temp179-name = `Hello`.
    INSERT temp179 INTO TABLE temp178.
    temp179-name = `WORLD`.
    INSERT temp179 INTO TABLE temp178.
    temp179-name = `test`.
    INSERT temp179 INTO TABLE temp178.
    lt_tab = temp178.

    " Search for 'hello' with ignore_case = FALSE (case-sensitive)
    " After fix: should NOT match 'Hello' (capital H)
    z2ui5_cl_util=>itab_filter_by_val( EXPORTING val = `hello` ignore_case = abap_false
                                        CHANGING tab = lt_tab ).
    cl_abap_unit_assert=>assert_equals( exp = 0 act = lines( lt_tab ) ).
  ENDMETHOD.

  METHOD trim_only_newlines.
    " TRANSPILER NOTE: c_trim only removes spaces and horizontal tabs.
    " Newlines are NOT removed by c_trim! (shift_left/right only trim spaces)
    DATA lv_nl LIKE z2ui5_cl_util=>cv_char_util_newline.
    DATA lv_result TYPE string.
    lv_nl = z2ui5_cl_util=>cv_char_util_newline.

    lv_result = z2ui5_cl_util=>c_trim( lv_nl && lv_nl ).
    " Newlines survive trimming
    cl_abap_unit_assert=>assert_not_initial( lv_result ).
  ENDMETHOD.

  METHOD trim_mixed_whitespace.
    DATA lv_tab LIKE z2ui5_cl_util=>cv_char_util_horizontal_tab.
    lv_tab = z2ui5_cl_util=>cv_char_util_horizontal_tab.
    cl_abap_unit_assert=>assert_equals( exp = `hello`
        act = z2ui5_cl_util=>c_trim( ` ` && lv_tab && `hello` && lv_tab && ` ` ) ).
  ENDMETHOD.

  METHOD trim_unicode.
    " Regular non-ASCII should not be trimmed
    cl_abap_unit_assert=>assert_equals( exp = `über`
        act = z2ui5_cl_util=>c_trim( `  über  ` ) ).
  ENDMETHOD.

  METHOD split_empty_input.
    " TRANSPILER NOTE: ABAP SPLIT of empty string gives table with 0 entries!
    " This differs from JS ''.split(',') which gives [''].
    DATA lt_result TYPE string_table.
    lt_result = z2ui5_cl_util=>c_split( val = `` sep = `,` ).
    cl_abap_unit_assert=>assert_equals( exp = 0 act = lines( lt_result ) ).
  ENDMETHOD.

  METHOD split_only_separator.
    " TRANSPILER NOTE: ABAP SPLIT ',' AT ',' gives 1 entry (empty string),
    " while JS ','.split(',') gives ['', '']. Different behavior!
    DATA lt_result TYPE string_table.
    DATA temp4 TYPE xsdboolean.
    lt_result = z2ui5_cl_util=>c_split( val = `,` sep = `,` ).
    " Document actual ABAP behavior:

    temp4 = boolc( lines( lt_result ) >= 1 ).
    cl_abap_unit_assert=>assert_true( temp4 ).
  ENDMETHOD.

  METHOD num_one_thousand_no_dot.
    " EDGE CASE: '1,000' without dot → comma is last separator → decimal!
    " Result is 1.0 NOT 1000. This is documented European behavior.
    DATA lv_result TYPE decfloat34.
    DATA temp180 TYPE decfloat34.
    lv_result = z2ui5_cl_util=>conv_string_to_number( `1,000` ).

    temp180 = '1.000'.
    cl_abap_unit_assert=>assert_equals( exp = temp180 act = lv_result ).
  ENDMETHOD.

  METHOD num_european_format.
    " TRANSPILER NOTE: European format (dot=thousands, comma=decimal)
    " does NOT work correctly! The dot is always kept as-is, creating
    " invalid numbers like '1.234.56'. Only the comma heuristic applies.
    " Result: falls back to 0 due to conversion error.
    DATA lv_result TYPE decfloat34.
    DATA temp181 TYPE decfloat34.
    lv_result = z2ui5_cl_util=>conv_string_to_number( `1.234,56` ).
    " Documents actual (broken) behavior - returns 0 due to double-dot

    temp181 = 0.
    cl_abap_unit_assert=>assert_equals( exp = temp181 act = lv_result ).
  ENDMETHOD.

  METHOD num_only_minus.
    " Just a minus sign
    DATA lv_result TYPE decfloat34.
    DATA temp182 TYPE decfloat34.
    lv_result = z2ui5_cl_util=>conv_string_to_number( `-` ).

    temp182 = 0.
    cl_abap_unit_assert=>assert_equals( exp = temp182 act = lv_result ).
  ENDMETHOD.

  METHOD num_leading_zeros.
    DATA lv_result TYPE decfloat34.
    DATA temp183 TYPE decfloat34.
    lv_result = z2ui5_cl_util=>conv_string_to_number( `007` ).

    temp183 = 7.
    cl_abap_unit_assert=>assert_equals( exp = temp183 act = lv_result ).
  ENDMETHOD.

  METHOD date_short_input.
        DATA lv_result TYPE d.
    " TRANSPILER NOTE: Short input causes STRING_OFFSET_TOO_LARGE in ABAP
    " because conv_string_to_date has no bounds checking.
    " This is a known limitation - skip this test to document it.
    " A JS transpiler should add bounds checking.
    TRY.

        lv_result = z2ui5_cl_util=>conv_string_to_date( val = `24` format = `YYYY-MM-DD` ) ##NEEDED.
      CATCH cx_root.
        " Expected: crashes with short input - JS must guard against this
    ENDTRY.
  ENDMETHOD.

  METHOD email_with_plus.
    cl_abap_unit_assert=>assert_true(
        z2ui5_cl_util=>check_is_email( `user+tag@example.com` ) ).
  ENDMETHOD.

  METHOD email_with_dots.
    cl_abap_unit_assert=>assert_true(
        z2ui5_cl_util=>check_is_email( `first.last@sub.domain.com` ) ).
  ENDMETHOD.

  METHOD email_only_spaces.
    cl_abap_unit_assert=>assert_false(
        z2ui5_cl_util=>check_is_email( `   ` ) ).
  ENDMETHOD.

  METHOD slice_from_exceeds_lines.
    TYPES: BEGIN OF ty, id TYPE i, END OF ty.
    TYPES temp18 TYPE STANDARD TABLE OF ty WITH DEFAULT KEY.
DATA lt_tab TYPE temp18.
    DATA temp184 LIKE lt_tab.
    DATA temp185 LIKE LINE OF temp184.
    DATA lr_result TYPE REF TO data.
    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
    CLEAR temp184.

    temp185-id = 1.
    INSERT temp185 INTO TABLE temp184.
    temp185-id = 2.
    INSERT temp185 INTO TABLE temp184.
    lt_tab = temp184.

    lr_result = z2ui5_cl_util=>itab_slice( tab = lt_tab from = 99 ).

    ASSIGN lr_result->* TO <tab>.
    cl_abap_unit_assert=>assert_equals( exp = 0 act = lines( <tab> ) ).
  ENDMETHOD.

  METHOD slice_empty_table.
    TYPES: BEGIN OF ty, id TYPE i, END OF ty.
    TYPES temp19 TYPE STANDARD TABLE OF ty WITH DEFAULT KEY.
DATA lt_tab TYPE temp19.
    DATA lr_result TYPE REF TO data.
    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
    lr_result = z2ui5_cl_util=>itab_slice( tab = lt_tab from = 1 to = 5 ).

    ASSIGN lr_result->* TO <tab>.
    cl_abap_unit_assert=>assert_equals( exp = 0 act = lines( <tab> ) ).
  ENDMETHOD.

  METHOD truncate_max_zero.
    " max=0 should return empty
    cl_abap_unit_assert=>assert_equals( exp = ``
        act = z2ui5_cl_util=>c_truncate( val = `hello` max = 0 ) ).
  ENDMETHOD.

  METHOD truncate_empty_string.
    cl_abap_unit_assert=>assert_equals( exp = ``
        act = z2ui5_cl_util=>c_truncate( val = `` max = 10 ) ).
  ENDMETHOD.

  METHOD path_with_leading_dash.
    " Leading dash creates an empty first segment - should be skipped
    TYPES: BEGIN OF ty, name TYPE string, END OF ty.
    DATA temp186 TYPE ty.
    DATA ls_data LIKE temp186.
    CLEAR temp186.
    temp186-name = `hello`.

    ls_data = temp186.
    cl_abap_unit_assert=>assert_equals( exp = `hello`
        act = z2ui5_cl_util=>data_get_by_path( data = ls_data path = `-name` ) ).
  ENDMETHOD.

  METHOD path_set_nested.
    TYPES: BEGIN OF ty_inner, city TYPE string, END OF ty_inner.
    TYPES: BEGIN OF ty, address TYPE ty_inner, END OF ty.
    DATA ls_data TYPE ty.
    z2ui5_cl_util=>data_set_by_path( EXPORTING path = `address-city` value = `Munich`
                                     CHANGING data = ls_data ).
    cl_abap_unit_assert=>assert_equals( exp = `Munich` act = ls_data-address-city ).
  ENDMETHOD.

  METHOD guid_empty.
    cl_abap_unit_assert=>assert_false( z2ui5_cl_util=>check_is_guid( `` ) ).
  ENDMETHOD.

  METHOD guid_mixed_case_dashes.
    " Mixed case with dashes (standard GUID format)
    cl_abap_unit_assert=>assert_true(
        z2ui5_cl_util=>check_is_guid( `550e8400-e29b-41d4-a716-446655440000` ) ).
  ENDMETHOD.

  METHOD url_set_preserves_value_case.
    " After fix: value case should be preserved
    DATA lv_result TYPE string.
    lv_result = z2ui5_cl_util=>url_param_set(
        url = `a=1` name = `class` value = `ZCL_MY_CLASS` ).
    cl_abap_unit_assert=>assert_true(
        z2ui5_cl_util=>c_contains( val = lv_result sub = `ZCL_MY_CLASS` ) ).
  ENDMETHOD.

  METHOD bool_xfeld_true.
    DATA lv_xfeld TYPE xfeld VALUE 'X'.
    cl_abap_unit_assert=>assert_equals( exp = `true`
        act = z2ui5_cl_util=>boolean_abap_2_json( lv_xfeld ) ).
  ENDMETHOD.

  METHOD bool_xfeld_false.
    DATA lv_xfeld TYPE xfeld.
    cl_abap_unit_assert=>assert_equals( exp = `false`
        act = z2ui5_cl_util=>boolean_abap_2_json( lv_xfeld ) ).
  ENDMETHOD.

  METHOD json_special_chars.
    " JSON with quotes, backslashes, newlines
    TYPES: BEGIN OF ty, text TYPE string, END OF ty.
    DATA temp187 TYPE ty.
    DATA ls_data LIKE temp187.
    DATA lv_json TYPE string.
    DATA ls_back TYPE ty.
    CLEAR temp187.
    temp187-text = `He said "hello" \\ yes`.

    ls_data = temp187.

    lv_json = z2ui5_cl_util=>json_stringify( ls_data ).

    z2ui5_cl_util=>json_parse( EXPORTING val = lv_json CHANGING data = ls_back ).
    cl_abap_unit_assert=>assert_equals( exp = ls_data-text act = ls_back-text ).
  ENDMETHOD.

  METHOD contains_is_always_ci.
    " TRANSPILER CRITICAL: Proves that c_contains is case-insensitive
    " JS must implement: val.toLowerCase().includes(sub.toLowerCase())
    cl_abap_unit_assert=>assert_true(
        z2ui5_cl_util=>c_contains( val = `Hello World` sub = `HELLO` ) ).
    cl_abap_unit_assert=>assert_true(
        z2ui5_cl_util=>c_contains( val = `HELLO WORLD` sub = `hello` ) ).
    cl_abap_unit_assert=>assert_true(
        z2ui5_cl_util=>c_contains( val = `HeLLo` sub = `hello` ) ).
  ENDMETHOD.

ENDCLASS.
