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

  METHOD test_url_param_startup.

    " sap-startup-params is unwrapped wherever it sits in the query string -
    " as a later parameter, as the first/only parameter (typical FLP target
    " mapping), and with lowercase percent-encoding
    cl_abap_unit_assert=>assert_equals(
        exp = `foo`
        act = z2ui5_cl_a2ui5_context=>url_param_get(
                  val = `app_start`
                  url = `?x=1&sap-startup-params=app_start%3Dfoo` ) ).

    cl_abap_unit_assert=>assert_equals(
        exp = `foo`
        act = z2ui5_cl_a2ui5_context=>url_param_get(
                  val = `app_start`
                  url = `?sap-startup-params=app_start%3Dfoo` ) ).

    cl_abap_unit_assert=>assert_equals(
        exp = `foo`
        act = z2ui5_cl_a2ui5_context=>url_param_get(
                  val = `app_start`
                  url = `?sap-startup-params=app_start%3dfoo` ) ).

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
                                        act = z2ui5_cl_a2ui5_context=>c_trim( `   abc   ` ) ).

  ENDMETHOD.

  METHOD test_trim_tabs.

    " leading and trailing tabs are trimmed as well - a value pasted from a
    " spreadsheet arrives tab-padded and must not keep the padding
    DATA lv_val TYPE string.

    lv_val = z2ui5_cl_a2ui5_context=>cv_char_util_horizontal_tab
             && `abc`
             && z2ui5_cl_a2ui5_context=>cv_char_util_horizontal_tab.

    cl_abap_unit_assert=>assert_equals( exp = `abc`
                                        act = z2ui5_cl_a2ui5_context=>c_trim( lv_val ) ).

  ENDMETHOD.

  METHOD test_trim_inner_kept.

    " only the edges are trimmed, inner whitespace is data
    cl_abap_unit_assert=>assert_equals( exp = `a b`
                                        act = z2ui5_cl_a2ui5_context=>c_trim( ` a b ` ) ).

  ENDMETHOD.

  METHOD test_trim_case.

    cl_abap_unit_assert=>assert_equals( exp = `ABC`
                                        act = z2ui5_cl_a2ui5_context=>c_trim_upper( ` aBc ` ) ).

    cl_abap_unit_assert=>assert_equals( exp = `abc`
                                        act = z2ui5_cl_a2ui5_context=>c_trim_lower( ` aBc ` ) ).

  ENDMETHOD.

  METHOD test_bool_by_name.

    " the name check drives whether an attribute is serialised as a JSON
    " boolean, so both the hit list and the rejection of look-alikes matter
    cl_abap_unit_assert=>assert_true( z2ui5_cl_a2ui5_context=>boolean_check_by_name( `ABAP_BOOL` ) ).
    cl_abap_unit_assert=>assert_true( z2ui5_cl_a2ui5_context=>boolean_check_by_name( `XFELD` ) ).
    cl_abap_unit_assert=>assert_true( z2ui5_cl_a2ui5_context=>boolean_check_by_name( `BOOLE_D` ) ).

    cl_abap_unit_assert=>assert_false( z2ui5_cl_a2ui5_context=>boolean_check_by_name( `abap_bool` ) ).
    cl_abap_unit_assert=>assert_false( z2ui5_cl_a2ui5_context=>boolean_check_by_name( `STRING` ) ).
    cl_abap_unit_assert=>assert_false( z2ui5_cl_a2ui5_context=>boolean_check_by_name( `` ) ).

  ENDMETHOD.

  METHOD test_url_create.

    DATA lt_params TYPE z2ui5_cl_a2ui5_context=>ty_t_name_value.

    lt_params = VALUE #( ( n = `a` v = `1` )
                         ( n = `b` v = `2` ) ).

    cl_abap_unit_assert=>assert_equals(
        exp = `a=1&b=2`
        act = z2ui5_cl_a2ui5_context=>url_param_create_url( lt_params ) ).

  ENDMETHOD.

  METHOD test_url_create_empty.

    " no parameters must produce an empty string, not a stray separator
    DATA lt_params TYPE z2ui5_cl_a2ui5_context=>ty_t_name_value.

    cl_abap_unit_assert=>assert_equals(
        exp = ``
        act = z2ui5_cl_a2ui5_context=>url_param_create_url( lt_params ) ).

  ENDMETHOD.

  METHOD test_url_roundtrip.

    " parsing a query string and rebuilding it has to be stable - the phantom
    " nameless row that once leaked out as `=&` broke exactly this
    DATA(lt_params) = z2ui5_cl_a2ui5_context=>url_param_get_tab( `?a=1&b=2` ).

    cl_abap_unit_assert=>assert_equals(
        exp = `a=1&b=2`
        act = z2ui5_cl_a2ui5_context=>url_param_create_url( lt_params ) ).

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
    TYPES ty_t_row TYPE STANDARD TABLE OF ty_s_row WITH EMPTY KEY.

    METHODS test_check_clike     FOR TESTING RAISING cx_static_check.
    METHODS test_check_table     FOR TESTING RAISING cx_static_check.
    METHODS test_check_structure FOR TESTING RAISING cx_static_check.
    METHODS test_check_ref_data  FOR TESTING RAISING cx_static_check.
    METHODS test_bound_not_init  FOR TESTING RAISING cx_static_check.
    METHODS test_struc_to_pairs  FOR TESTING RAISING cx_static_check.
    METHODS test_scan_flag       FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_rtti IMPLEMENTATION.

  METHOD test_check_clike.

    DATA lv_int  TYPE i VALUE 5.
    DATA lv_char TYPE c LENGTH 4.
    DATA lv_numc TYPE n LENGTH 4.
    DATA lv_date TYPE d.
    DATA ls_row  TYPE ty_s_row.

    cl_abap_unit_assert=>assert_true( z2ui5_cl_a2ui5_context=>rtti_check_clike( `abc` ) ).
    cl_abap_unit_assert=>assert_true( z2ui5_cl_a2ui5_context=>rtti_check_clike( lv_char ) ).
    " n, d and t are character-like too and must be accepted
    cl_abap_unit_assert=>assert_true( z2ui5_cl_a2ui5_context=>rtti_check_clike( lv_numc ) ).
    cl_abap_unit_assert=>assert_true( z2ui5_cl_a2ui5_context=>rtti_check_clike( lv_date ) ).

    cl_abap_unit_assert=>assert_false( z2ui5_cl_a2ui5_context=>rtti_check_clike( lv_int ) ).
    cl_abap_unit_assert=>assert_false( z2ui5_cl_a2ui5_context=>rtti_check_clike( ls_row ) ).

  ENDMETHOD.

  METHOD test_check_table.

    DATA lt_row TYPE ty_t_row.
    DATA ls_row TYPE ty_s_row.

    cl_abap_unit_assert=>assert_true( z2ui5_cl_a2ui5_context=>rtti_check_table( lt_row ) ).

    cl_abap_unit_assert=>assert_false( z2ui5_cl_a2ui5_context=>rtti_check_table( ls_row ) ).
    cl_abap_unit_assert=>assert_false( z2ui5_cl_a2ui5_context=>rtti_check_table( `abc` ) ).

  ENDMETHOD.

  METHOD test_check_structure.

    DATA ls_row TYPE ty_s_row.
    DATA lt_row TYPE ty_t_row.

    cl_abap_unit_assert=>assert_true( z2ui5_cl_a2ui5_context=>rtti_check_structure( ls_row ) ).

    cl_abap_unit_assert=>assert_false( z2ui5_cl_a2ui5_context=>rtti_check_structure( `abc` ) ).
    cl_abap_unit_assert=>assert_false( z2ui5_cl_a2ui5_context=>rtti_check_structure( lt_row ) ).

  ENDMETHOD.

  METHOD test_check_ref_data.

    DATA lr_data TYPE REF TO data.

    CREATE DATA lr_data TYPE string.

    cl_abap_unit_assert=>assert_true( z2ui5_cl_a2ui5_context=>rtti_check_ref_data( lr_data ) ).

    cl_abap_unit_assert=>assert_false( z2ui5_cl_a2ui5_context=>rtti_check_ref_data( `abc` ) ).

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

    cl_abap_unit_assert=>assert_false( z2ui5_cl_a2ui5_context=>check_bound_a_not_initial( lr_unbound ) ).
    cl_abap_unit_assert=>assert_false( z2ui5_cl_a2ui5_context=>check_bound_a_not_initial( lr_initial ) ).
    cl_abap_unit_assert=>assert_true( z2ui5_cl_a2ui5_context=>check_bound_a_not_initial( lr_filled ) ).

  ENDMETHOD.

  METHOD test_struc_to_pairs.

    DATA ls_row TYPE ty_s_row.

    ls_row-name = `Ada`.
    ls_row-city = `London`.

    DATA(lt_pair) = z2ui5_cl_a2ui5_context=>itab_get_by_struc( ls_row ).

    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( lt_pair ) ).

    " component names come back from RTTI in upper case
    cl_abap_unit_assert=>assert_equals( exp = `Ada`
                                        act = lt_pair[ n = `NAME` ]-v ).
    cl_abap_unit_assert=>assert_equals( exp = `London`
                                        act = lt_pair[ n = `CITY` ]-v ).

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

    ls_flags-flag_a = abap_true.
    ls_flags-flag_b = abap_false.
    ls_flags-other  = abap_true.

    DATA(lt_found) = z2ui5_cl_a2ui5_context=>scan_flag_prefix( val    = ls_flags
                                                               prefix = `FLAG_` ).

    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( lt_found ) ).
    cl_abap_unit_assert=>assert_equals( exp = `A`
                                        act = lt_found[ 1 ] ).

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
    TYPES ty_t_row TYPE STANDARD TABLE OF ty_s_row WITH EMPTY KEY.

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

    result = VALUE #( ( name = `Ada`   city = `London` )
                      ( name = `Alan`  city = `Wilmslow` )
                      ( name = `Grace` city = `New York` ) ).

  ENDMETHOD.

  METHOD test_filter_all_fields.

    " with no field list every component is searched, so a hit in `city`
    " keeps the row even though `name` does not match
    DATA(lt_row) = get_rows( ).

    z2ui5_cl_a2ui5_context=>itab_filter_by_val( EXPORTING val = `London`
                                                CHANGING  tab = lt_row ).

    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( lt_row ) ).
    cl_abap_unit_assert=>assert_equals( exp = `Ada`
                                        act = lt_row[ 1 ]-name ).

  ENDMETHOD.

  METHOD test_filter_ignore_case.

    DATA(lt_row) = get_rows( ).

    z2ui5_cl_a2ui5_context=>itab_filter_by_val( EXPORTING val         = `ada`
                                                          ignore_case = abap_true
                                                CHANGING  tab         = lt_row ).

    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( lt_row ) ).
    cl_abap_unit_assert=>assert_equals( exp = `Ada`
                                        act = lt_row[ 1 ]-name ).

  ENDMETHOD.

  METHOD test_filter_named_field.

    " restricted to `name`, the city value must not produce a hit
    DATA lt_fields TYPE string_table.

    DATA(lt_row) = get_rows( ).

    APPEND `NAME` TO lt_fields.

    z2ui5_cl_a2ui5_context=>itab_filter_by_val( EXPORTING val    = `London`
                                                          fields = lt_fields
                                                CHANGING  tab    = lt_row ).

    cl_abap_unit_assert=>assert_initial( lt_row ).

  ENDMETHOD.

  METHOD test_filter_no_match.

    DATA(lt_row) = get_rows( ).

    z2ui5_cl_a2ui5_context=>itab_filter_by_val( EXPORTING val = `Nobody`
                                                CHANGING  tab = lt_row ).

    cl_abap_unit_assert=>assert_initial( lt_row ).

  ENDMETHOD.

  METHOD test_filter_elementary.

    " a table with an elementary line type has no components - the filter
    " matches against the whole line instead of deleting every row
    DATA lt_str TYPE string_table.

    lt_str = VALUE #( ( `London` ) ( `Wilmslow` ) ( `New York` ) ).

    z2ui5_cl_a2ui5_context=>itab_filter_by_val( EXPORTING val = `London`
                                                CHANGING  tab = lt_str ).

    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( lt_str ) ).
    cl_abap_unit_assert=>assert_equals( exp = `London`
                                        act = lt_str[ 1 ] ).

  ENDMETHOD.

  METHOD test_corresponding.

    " components are matched by name, the rest stays initial
    TYPES:
      BEGIN OF ty_s_target,
        name    TYPE string,
        country TYPE string,
      END OF ty_s_target.
    TYPES ty_t_target TYPE STANDARD TABLE OF ty_s_target WITH EMPTY KEY.

    DATA lt_target TYPE ty_t_target.

    DATA(lt_row) = get_rows( ).

    z2ui5_cl_a2ui5_context=>itab_corresponding( EXPORTING val = lt_row
                                                CHANGING  tab = lt_target ).

    cl_abap_unit_assert=>assert_equals( exp = 3
                                        act = lines( lt_target ) ).
    cl_abap_unit_assert=>assert_equals( exp = `Ada`
                                        act = lt_target[ 1 ]-name ).
    cl_abap_unit_assert=>assert_initial( lt_target[ 1 ]-country ).

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
                                        act = z2ui5_cl_a2ui5_context=>ui5_get_msg_type( `E` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `Success`
                                        act = z2ui5_cl_a2ui5_context=>ui5_get_msg_type( `S` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `Warning`
                                        act = z2ui5_cl_a2ui5_context=>ui5_get_msg_type( `W` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `Information`
                                        act = z2ui5_cl_a2ui5_context=>ui5_get_msg_type( `I` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `Information`
                                        act = z2ui5_cl_a2ui5_context=>ui5_get_msg_type( `X` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `Information`
                                        act = z2ui5_cl_a2ui5_context=>ui5_get_msg_type( `` ) ).

  ENDMETHOD.

  METHOD test_box_empty_skips.

    " no messages means no popup at all, signalled by `skip`
    DATA lt_msg TYPE z2ui5_cl_a2ui5_context=>ty_t_msg.

    DATA(ls_box) = z2ui5_cl_a2ui5_context=>ui5_msg_box_format( lt_msg ).

    cl_abap_unit_assert=>assert_true( ls_box-skip ).

  ENDMETHOD.

  METHOD test_box_single.

    " a single message renders as plain text without a details list
    DATA lt_msg TYPE z2ui5_cl_a2ui5_context=>ty_t_msg.

    lt_msg = VALUE #( ( text = `boom` type = `E` ) ).

    DATA(ls_box) = z2ui5_cl_a2ui5_context=>ui5_msg_box_format( lt_msg ).

    cl_abap_unit_assert=>assert_false( ls_box-skip ).
    cl_abap_unit_assert=>assert_equals( exp = `boom`  act = ls_box-text ).
    cl_abap_unit_assert=>assert_equals( exp = `Error` act = ls_box-title ).
    cl_abap_unit_assert=>assert_equals( exp = `error` act = ls_box-type ).
    cl_abap_unit_assert=>assert_initial( ls_box-details ).

  ENDMETHOD.

  METHOD test_box_multiple.

    " several messages collapse into a count plus an HTML list, and the box
    " takes its severity from the first message
    DATA lt_msg TYPE z2ui5_cl_a2ui5_context=>ty_t_msg.

    lt_msg = VALUE #( ( text = `first`  type = `W` )
                      ( text = `second` type = `E` ) ).

    DATA(ls_box) = z2ui5_cl_a2ui5_context=>ui5_msg_box_format( lt_msg ).

    cl_abap_unit_assert=>assert_false( ls_box-skip ).
    cl_abap_unit_assert=>assert_equals( exp = `Warning` act = ls_box-title ).
    cl_abap_unit_assert=>assert_equals(
        exp = `<ul><li>first</li><li>second</li></ul>`
        act = ls_box-details ).

  ENDMETHOD.

  METHOD test_token_by_range.

    " every range option maps to its own token text; the placeholders
    " {LOW}/{HIGH} are substituted from the range row
    DATA lt_range TYPE z2ui5_cl_a2ui5_context=>ty_t_range.

    lt_range = VALUE #( ( sign = `I` option = `EQ` low = `X` )
                        ( sign = `I` option = `BT` low = `1` high = `9` )
                        ( sign = `I` option = `CP` low = `A` )
                        ( sign = `E` option = `EQ` low = `Y` ) ).

    DATA(lt_token) = z2ui5_cl_a2ui5_context=>filter_get_token_t_by_range_t( lt_range ).

    cl_abap_unit_assert=>assert_equals( exp = 4 act = lines( lt_token ) ).
    cl_abap_unit_assert=>assert_equals( exp = `=X`    act = lt_token[ 1 ]-key ).
    cl_abap_unit_assert=>assert_equals( exp = `1...9` act = lt_token[ 2 ]-key ).
    cl_abap_unit_assert=>assert_equals( exp = `*A*`   act = lt_token[ 3 ]-key ).
    " an excluding row renders negated, not like its including twin
    cl_abap_unit_assert=>assert_equals( exp = `!(=Y)` act = lt_token[ 4 ]-key ).

    " tokens come back visible and editable so the UI5 MultiInput can render
    " and remove them
    cl_abap_unit_assert=>assert_true( lt_token[ 1 ]-visible ).
    cl_abap_unit_assert=>assert_true( lt_token[ 1 ]-editable ).

  ENDMETHOD.

ENDCLASS.
