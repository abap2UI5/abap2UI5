class ltcl_filters_test definition final
  for testing
  risk level harmless
  duration short.
  private section.
    methods empty_filter_simple for testing raising z2UI5_cx_ajson_error.
    methods empty_filter_deep for testing raising z2UI5_cx_ajson_error.
    methods path_filter for testing raising z2UI5_cx_ajson_error.
    methods path_filter_string for testing raising z2UI5_cx_ajson_error.
    methods path_filter_w_patterns for testing raising z2UI5_cx_ajson_error.
    methods path_filter_deep for testing raising z2UI5_cx_ajson_error.
    methods and_filter for testing raising z2UI5_cx_ajson_error.
endclass.


class ltcl_filters_test implementation.

  method empty_filter_simple.

    data li_json type ref to z2ui5_if_ajson.
    data li_json_filtered type ref to z2ui5_if_ajson.

    li_json = z2ui5_cl_ajson=>create_empty( ).
    li_json->set(
      iv_path = '/a'
      iv_val  = '1' ).
    li_json->set(
      iv_path = '/b'
      iv_val  = '' ).
    li_json->set(
      iv_path = '/c'
      iv_val  = '3' ).
    li_json->set(
      iv_path = '/d'
      iv_val  = 0 ).

    li_json_filtered = z2ui5_cl_ajson=>create_from(
      ii_source_json = li_json
      ii_filter = z2ui5_cl_ajson_filter_lib=>create_empty_filter( ) ).

    cl_abap_unit_assert=>assert_equals(
      act = li_json_filtered->stringify( )
      exp = '{"a":"1","c":"3"}' ).

  endmethod.

  method empty_filter_deep.

    data li_json type ref to z2ui5_if_ajson.
    data li_json_filtered type ref to z2ui5_if_ajson.

    li_json = z2ui5_cl_ajson=>create_empty( ).
    li_json->set(
      iv_path = '/a'
      iv_val  = '1' ).
    li_json->set(
      iv_path = '/b/c'
      iv_val  = '' ).
    li_json->set(
      iv_path = '/b/d'
      iv_val  = 0 ).
    li_json->set(
      iv_path = '/d/e'
      iv_val  = 0 ).

    li_json_filtered = z2ui5_cl_ajson=>create_from(
      ii_source_json = li_json
      ii_filter = z2ui5_cl_ajson_filter_lib=>create_empty_filter( ) ).

    cl_abap_unit_assert=>assert_equals(
      act = li_json_filtered->stringify( )
      exp = '{"a":"1"}' ).

  endmethod.

  method path_filter.

    data li_json type ref to z2ui5_if_ajson.
    data li_json_filtered type ref to z2ui5_if_ajson.
    data lt_paths type string_table.

    append '/b/c' to lt_paths.

    li_json = z2ui5_cl_ajson=>create_empty( ).
    li_json->set(
      iv_path = '/a'
      iv_val  = '1' ).
    li_json->set(
      iv_path = '/b/c'
      iv_val  = '2' ).
    li_json->set(
      iv_path = '/c/d'
      iv_val  = '3' ).

    li_json_filtered = z2ui5_cl_ajson=>create_from(
      ii_source_json = li_json
      ii_filter = z2ui5_cl_ajson_filter_lib=>create_path_filter( it_skip_paths = lt_paths ) ).

    cl_abap_unit_assert=>assert_equals(
      act = li_json_filtered->stringify( )
      exp = '{"a":"1","b":{},"c":{"d":"3"}}' ).

  endmethod.

  method path_filter_string.

    data li_json type ref to z2ui5_if_ajson.
    data li_json_filtered type ref to z2ui5_if_ajson.

    li_json = z2ui5_cl_ajson=>create_empty( ).
    li_json->set(
      iv_path = '/a'
      iv_val  = '1' ).
    li_json->set(
      iv_path = '/b/c'
      iv_val  = '2' ).
    li_json->set(
      iv_path = '/c/d'
      iv_val  = '3' ).

    li_json_filtered = z2ui5_cl_ajson=>create_from(
      ii_source_json = li_json
      ii_filter = z2ui5_cl_ajson_filter_lib=>create_path_filter( iv_skip_paths = '/b/c,/c/d' ) ).

    cl_abap_unit_assert=>assert_equals(
      act = li_json_filtered->stringify( )
      exp = '{"a":"1","b":{},"c":{}}' ).

  endmethod.

  method path_filter_w_patterns.

    data li_json type ref to z2ui5_if_ajson.
    data li_json_filtered type ref to z2ui5_if_ajson.

    li_json = z2ui5_cl_ajson=>create_empty( ).
    li_json->set(
      iv_path = '/@meta'
      iv_val  = 'meta' ).
    li_json->set(
      iv_path = '/a'
      iv_val  = '1' ).
    li_json->set(
      iv_path = '/b/c'
      iv_val  = '2' ).
    li_json->set(
      iv_path = '/c/d'
      iv_val  = '3' ).
    li_json->set(
      iv_path = '/c/@meta2'
      iv_val  = 'meta2' ).

    li_json_filtered = z2ui5_cl_ajson=>create_from(
      ii_source_json = li_json
      ii_filter = z2ui5_cl_ajson_filter_lib=>create_path_filter(
        iv_skip_paths = '/*/c,*/@*'
        iv_pattern_search = abap_true ) ).

    cl_abap_unit_assert=>assert_equals(
      act = li_json_filtered->stringify( )
      exp = '{"a":"1","b":{},"c":{"d":"3"}}' ).

  endmethod.

  method path_filter_deep.

    data li_json type ref to z2ui5_if_ajson.
    data li_json_filtered type ref to z2ui5_if_ajson.
    data lt_paths type string_table.

    append '/b' to lt_paths.

    li_json = z2ui5_cl_ajson=>create_empty( ).
    li_json->set(
      iv_path = '/a'
      iv_val  = '1' ).
    li_json->set(
      iv_path = '/b/c'
      iv_val  = '2' ).
    li_json->set(
      iv_path = '/b/d'
      iv_val  = 'x' ).
    li_json->set(
      iv_path = '/c/d'
      iv_val  = '3' ).

    li_json_filtered = z2ui5_cl_ajson=>create_from(
      ii_source_json = li_json
      ii_filter = z2ui5_cl_ajson_filter_lib=>create_path_filter( it_skip_paths = lt_paths ) ).

    cl_abap_unit_assert=>assert_equals(
      act = li_json_filtered->stringify( )
      exp = '{"a":"1","c":{"d":"3"}}' ).

  endmethod.

  method and_filter.

    data li_json type ref to z2ui5_if_ajson.
    data li_json_filtered type ref to z2ui5_if_ajson.
    data lt_filters type z2ui5_if_ajson_filter=>ty_filter_tab.

    append z2ui5_cl_ajson_filter_lib=>create_empty_filter( ) to lt_filters.
    append z2ui5_cl_ajson_filter_lib=>create_path_filter( iv_skip_paths = '/c' ) to lt_filters.

    li_json = z2ui5_cl_ajson=>create_empty( ).
    li_json->set(
      iv_path = '/a'
      iv_val  = '1' ).
    li_json->set(
      iv_path = '/b'
      iv_val  = '' ).
    li_json->set(
      iv_path = '/c'
      iv_val  = '3' ).
    li_json->set(
      iv_path = '/d'
      iv_val  = 0 ).

    li_json_filtered = z2ui5_cl_ajson=>create_from(
      ii_source_json = li_json
      ii_filter = z2ui5_cl_ajson_filter_lib=>create_and_filter( lt_filters ) ).

    cl_abap_unit_assert=>assert_equals(
      act = li_json_filtered->stringify( )
      exp = '{"a":"1"}' ).

  endmethod.

endclass.
