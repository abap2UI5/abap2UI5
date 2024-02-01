**********************************************************************
* UTIL
**********************************************************************

class lcl_nodes_helper definition final.
  public section.

    data mt_nodes type z2ui5_if_ajson_types=>ty_nodes_tt read-only.

    methods add
      importing
        iv_str type string.
    methods sorted
      returning
        value(rt_nodes) type z2ui5_if_ajson_types=>ty_nodes_ts.

endclass.

class lcl_nodes_helper implementation.
  method add.

    field-symbols <n> like line of mt_nodes.
    data lv_children type string.
    data lv_index type string.

    append initial line to mt_nodes assigning <n>.

    split iv_str at '|' into
      <n>-path
      <n>-name
      <n>-type
      <n>-value
      lv_index
      lv_children.
    condense <n>-path.
    condense <n>-name.
    condense <n>-type.
    condense <n>-value.
    <n>-index = lv_index.
    <n>-children = lv_children.

  endmethod.

  method sorted.
    rt_nodes = mt_nodes.
  endmethod.
endclass.

**********************************************************************
* PARSER
**********************************************************************

class ltcl_parser_test definition final
  for testing
  risk level harmless
  duration short.

  public section.

    class-methods sample_json
      importing
        iv_separator   type string optional
      returning
        value(rv_json) type string.

endclass.

class ltcl_parser_test implementation.

  method sample_json.

    rv_json =
      '{\n' &&
      '  "string": "abc",\n' &&
      '  "number": 123,\n' &&
      '  "float": 123.45,\n' &&
      '  "boolean": true,\n' &&
      '  "false": false,\n' &&
      '  "null": null,\n' &&
      '  "date": "2020-03-15",\n' &&
      '  "issues": [\n' &&
      '    {\n' &&
      '      "message": "Indentation problem ...",\n' &&
      '      "key": "indentation",\n' &&
      '      "start": {\n' &&
      '        "row": 4,\n' &&
      '        "col": 3\n' &&
      '      },\n' &&
      '      "end": {\n' &&
      '        "row": 4,\n' &&
      '        "col": 26\n' &&
      '      },\n' &&
      '      "filename": "./zxxx.prog.abap"\n' &&
      '    },\n' &&
      '    {\n' &&
      '      "message": "Remove space before XXX",\n' &&
      '      "key": "space_before_dot",\n' &&
      '      "start": {\n' &&
      '        "row": 3,\n' &&
      '        "col": 21\n' &&
      '      },\n' &&
      '      "end": {\n' &&
      '        "row": 3,\n' &&
      '        "col": 22\n' &&
      '      },\n' &&
      '      "filename": "./zxxx.prog.abap"\n' &&
      '    }\n' &&
      '  ]\n' &&
      '}'.

    replace all occurrences of '\n' in rv_json with iv_separator.

  endmethod.

endclass.

**********************************************************************
* JSON UTILITIES
**********************************************************************

class ltcl_json_utils definition
  for testing
  risk level harmless
  duration short
  final.

  private section.

    methods json_diff for testing raising z2UI5_cx_ajson_error.
    methods json_diff_types for testing raising z2UI5_cx_ajson_error.
    methods json_diff_arrays for testing raising z2UI5_cx_ajson_error.
    methods json_merge for testing raising z2UI5_cx_ajson_error.
    methods json_sort for testing raising z2UI5_cx_ajson_error.
    methods is_equal for testing raising z2UI5_cx_ajson_error.

endclass.

class ltcl_json_utils implementation.

  method json_diff.

    data:
      lv_json       type string,
      lo_util       type ref to z2ui5_cl_ajson_utilities,
      lo_insert     type ref to z2ui5_if_ajson,
      lo_delete     type ref to z2ui5_if_ajson,
      lo_change     type ref to z2ui5_if_ajson,
      lo_insert_exp type ref to lcl_nodes_helper,
      lo_delete_exp type ref to lcl_nodes_helper,
      lo_change_exp type ref to lcl_nodes_helper.

    lv_json =
      '{\n' &&
      '  "string": "abc",\n' && " no changes
      '  "number": 789,\n' &&   " changed value
      '  "float": 123.45,\n' &&
      '  "boolean": "true",\n' && " changed type
      '  "true": true,\n' &&    " insert
*      '  "false": false,\n' &&    " delete
      '  "null": null,\n' &&
      '  "date": "2020-03-15",\n' &&
      '  "issues": [\n' &&
      '    {\n' &&
      '      "message": "Indentation problem ...",\n' &&
      '      "key": "indentation",\n' &&
      '      "start": {\n' &&
      '        "row": 5,\n' &&  " array change
      '        "col": 3\n' &&
      '      },\n' &&
      '      "end": {\n' &&
      '        "new": 1,\n' &&  " array insert
*      '        "row": 4,\n' && " array delete
      '        "col": 26\n' &&
      '      },\n' &&
      '      "filename": "./zxxx.prog.abap"\n' &&
      '    },\n' &&
      '    {\n' &&
      '      "message": "Remove space before XXX",\n' &&
      '      "key": "space_before_dot",\n' &&
      '      "start": {\n' &&
      '        "row": 3,\n' &&
      '        "col": 21\n' &&
      '      },\n' &&
      '      "end": {\n' &&
      '        "row": 3,\n' &&
      '        "col": 22\n' &&
      '      },\n' &&
      '      "filename": "./zxxx.prog.abap"\n' &&
      '    }\n' &&
      '  ]\n' &&
      '}'.

    replace all occurrences of '\n' in lv_json with cl_abap_char_utilities=>newline.

    create object lo_insert_exp.
    lo_insert_exp->add( '                |        |object |        |0|3' ).
    lo_insert_exp->add( '/               |boolean |str    |true    |0|0' ). " changed type (insert new)
    lo_insert_exp->add( '/               |issues  |array  |        |0|1' ).
    lo_insert_exp->add( '/               |true    |bool   |true    |0|0' ). " insert
    lo_insert_exp->add( '/issues/        |1       |object |        |1|1' ).
    lo_insert_exp->add( '/issues/1/      |end     |object |        |0|1' ).
    lo_insert_exp->add( '/issues/1/end/  |new     |num    |1       |0|0' ). " array insert

    create object lo_delete_exp.
    lo_delete_exp->add( '                |        |object |        |0|3' ).
    lo_delete_exp->add( '/               |boolean |bool   |true    |0|0' ). " changed type (delete old)
    lo_delete_exp->add( '/               |false   |bool   |false   |0|0' ). " delete
    lo_delete_exp->add( '/               |issues  |array  |        |0|1' ).
    lo_delete_exp->add( '/issues/        |1       |object |        |1|1' ).
    lo_delete_exp->add( '/issues/1/      |end     |object |        |0|1' ).
    lo_delete_exp->add( '/issues/1/end/  |row     |num    |4       |0|0' ). " array delete

    create object lo_change_exp.
    lo_change_exp->add( '                |        |object |        |0|2' ).
    lo_change_exp->add( '/               |issues  |array  |        |0|1' ).
    lo_change_exp->add( '/               |number  |num    |789     |0|0' ). " changed value
    lo_change_exp->add( '/issues/        |1       |object |        |1|1' ).
    lo_change_exp->add( '/issues/1/      |start   |object |        |0|1' ).
    lo_change_exp->add( '/issues/1/start/|row     |num    |5       |0|0' ). " array change

    create object lo_util.

    lo_util->diff(
      exporting
        iv_json_a = ltcl_parser_test=>sample_json( )
        iv_json_b = lv_json
      importing
        eo_insert = lo_insert
        eo_delete = lo_delete
        eo_change = lo_change ).

    cl_abap_unit_assert=>assert_equals(
      act = lo_insert->mt_json_tree
      exp = lo_insert_exp->mt_nodes ).

    cl_abap_unit_assert=>assert_equals(
      act = lo_delete->mt_json_tree
      exp = lo_delete_exp->mt_nodes ).

    cl_abap_unit_assert=>assert_equals(
      act = lo_change->mt_json_tree
      exp = lo_change_exp->mt_nodes ).

  endmethod.

  method json_diff_types.

    data:
      lv_json_a     type string,
      lv_json_b     type string,
      lo_util       type ref to z2ui5_cl_ajson_utilities,
      lo_insert     type ref to z2ui5_if_ajson,
      lo_delete     type ref to z2ui5_if_ajson,
      lo_change     type ref to z2ui5_if_ajson,
      lo_insert_exp type ref to lcl_nodes_helper,
      lo_delete_exp type ref to lcl_nodes_helper.

    " Change single value to array
    lv_json_a =
      '{\n' &&
      '  "string": "abc",\n' &&
      '  "number": 123\n' &&
      '}'.

    lv_json_b =
      '{\n' &&
      '  "string": [\n' &&
      '    "a",\n' &&
      '    "b",\n' &&
      '    "c"\n' &&
      '  ],\n' &&
      '  "number": 123\n' &&
      '}'.

    replace all occurrences of '\n' in lv_json_a with cl_abap_char_utilities=>newline.
    replace all occurrences of '\n' in lv_json_b with cl_abap_char_utilities=>newline.

    create object lo_insert_exp.
    lo_insert_exp->add( '                |        |object |        |0|1' ).
    lo_insert_exp->add( '/               |string  |array  |        |0|3' ).
    lo_insert_exp->add( '/string/        |1       |str    |a       |1|0' ).
    lo_insert_exp->add( '/string/        |2       |str    |b       |2|0' ).
    lo_insert_exp->add( '/string/        |3       |str    |c       |3|0' ).

    create object lo_delete_exp.
    lo_delete_exp->add( '                |        |object |        |0|1' ).
    lo_delete_exp->add( '/               |string  |str    |abc     |0|0' ).

    create object lo_util.

    lo_util->diff(
      exporting
        iv_json_a = lv_json_a
        iv_json_b = lv_json_b
      importing
        eo_insert = lo_insert
        eo_delete = lo_delete
        eo_change = lo_change ).

    cl_abap_unit_assert=>assert_equals(
      act = lo_insert->mt_json_tree
      exp = lo_insert_exp->mt_nodes ).

    cl_abap_unit_assert=>assert_equals(
      act = lo_delete->mt_json_tree
      exp = lo_delete_exp->mt_nodes ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( lo_change->mt_json_tree )
      exp = 0 ).

    " Change array to single value
    lo_util->diff(
      exporting
        iv_json_a = lv_json_b
        iv_json_b = lv_json_a
      importing
        eo_insert = lo_insert
        eo_delete = lo_delete
        eo_change = lo_change ).

    cl_abap_unit_assert=>assert_equals(
      act = lo_insert->mt_json_tree
      exp = lo_delete_exp->mt_nodes ).

    cl_abap_unit_assert=>assert_equals(
      act = lo_delete->mt_json_tree
      exp = lo_insert_exp->mt_nodes ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( lo_change->mt_json_tree )
      exp = 0 ).

  endmethod.

  method json_diff_arrays.

    data:
      lv_json_a     type string,
      lv_json_b     type string,
      lo_util       type ref to z2ui5_cl_ajson_utilities,
      lo_insert     type ref to z2ui5_if_ajson,
      lo_delete     type ref to z2ui5_if_ajson,
      lo_change     type ref to z2ui5_if_ajson,
      lo_insert_exp type ref to lcl_nodes_helper.

    " Add empty array
    lv_json_a =
      '{\n' &&
      '  "number": 123\n' &&
      '}'.

    lv_json_b =
      '{\n' &&
      '  "names": [],\n' &&
      '  "number": 123\n' &&
      '}'.

    replace all occurrences of '\n' in lv_json_a with cl_abap_char_utilities=>newline.
    replace all occurrences of '\n' in lv_json_b with cl_abap_char_utilities=>newline.

    create object lo_util.

    " Empty arrays are ignored by default
    lo_util->diff(
      exporting
        iv_json_a = lv_json_a
        iv_json_b = lv_json_b
      importing
        eo_insert = lo_insert
        eo_delete = lo_delete
        eo_change = lo_change ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( lo_insert->mt_json_tree )
      exp = 0 ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( lo_delete->mt_json_tree )
      exp = 0 ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( lo_change->mt_json_tree )
      exp = 0 ).

    " Keep empty arrays
    lo_util->diff(
      exporting
        iv_json_a = lv_json_a
        iv_json_b = lv_json_b
        iv_keep_empty_arrays = abap_true
      importing
        eo_insert = lo_insert
        eo_delete = lo_delete
        eo_change = lo_change ).

    create object lo_insert_exp.
    lo_insert_exp->add( '                |        |object |        |0|1' ).
    lo_insert_exp->add( '/               |names   |array  |        |0|0' ).

    cl_abap_unit_assert=>assert_equals(
      act = lo_insert->mt_json_tree
      exp = lo_insert_exp->mt_nodes ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( lo_delete->mt_json_tree )
      exp = 0 ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( lo_change->mt_json_tree )
      exp = 0 ).

  endmethod.

  method json_merge.

    data:
      lv_json_a    type string,
      lv_json_b    type string,
      lo_util      type ref to z2ui5_cl_ajson_utilities,
      lo_merge     type ref to z2ui5_if_ajson,
      lo_merge_exp type ref to lcl_nodes_helper.

    " Merge new value of b into a
    lv_json_a =
      '{\n' &&
      '  "string": [\n' &&
      '    "a",\n' &&
      '    "c"\n' &&
      '  ],\n' &&
      '  "number": 123\n' &&
      '}'.

    lv_json_b =
      '{\n' &&
      '  "string": [\n' &&
      '    "a",\n' &&
      '    "b"\n' && " new array value
      '  ],\n' &&
      '  "number": 456,\n' && " existing values are not overwritten
      '  "float": 123.45\n' &&
      '}'.

    replace all occurrences of '\n' in lv_json_a with cl_abap_char_utilities=>newline.
    replace all occurrences of '\n' in lv_json_b with cl_abap_char_utilities=>newline.

    create object lo_merge_exp.
    lo_merge_exp->add( '                |        |object |        |0|3' ).
    lo_merge_exp->add( '/               |float   |num    |123.45  |0|0' ).
    lo_merge_exp->add( '/               |number  |num    |123     |0|0' ).
    lo_merge_exp->add( '/               |string  |array  |        |0|3' ).
    lo_merge_exp->add( '/string/        |1       |str    |a       |1|0' ).
    lo_merge_exp->add( '/string/        |2       |str    |c       |2|0' ).
    lo_merge_exp->add( '/string/        |3       |str    |b       |3|0' ).

    create object lo_util.

    lo_merge = lo_util->merge(
      iv_json_a = lv_json_a
      iv_json_b = lv_json_b ).

    cl_abap_unit_assert=>assert_equals(
      act = lo_merge->mt_json_tree
      exp = lo_merge_exp->mt_nodes ).

  endmethod.

  method json_sort.

    data:
      lv_json       type string,
      lo_util       type ref to z2ui5_cl_ajson_utilities,
      lv_sorted     type string,
      lv_sorted_exp type string.

    lv_json =
      '{\n' &&
      '  "string": "abc",\n' &&
      '  "number": 789,\n' &&
      '  "float": 123.45,\n' &&
      '  "boolean": "true",\n' &&
      '  "true": true,\n' &&
      '  "false": false,\n' &&
      '  "null": null,\n' &&
      '  "date": "2020-03-15"\n' &&
      '}'.

    replace all occurrences of '\n' in lv_json with cl_abap_char_utilities=>newline.

    lv_sorted_exp =
      '{\n' &&
      '  "boolean": "true",\n' &&
      '  "date": "2020-03-15",\n' &&
      '  "false": false,\n' &&
      '  "float": 123.45,\n' &&
      '  "null": null,\n' &&
      '  "number": 789,\n' &&
      '  "string": "abc",\n' &&
      '  "true": true\n' &&
      '}'.

    replace all occurrences of '\n' in lv_sorted_exp with cl_abap_char_utilities=>newline.

    create object lo_util.

    lv_sorted = lo_util->sort( iv_json = lv_json ).

    cl_abap_unit_assert=>assert_equals(
      act = lv_sorted
      exp = lv_sorted_exp ).

  endmethod.

  method is_equal.

    cl_abap_unit_assert=>assert_equals(
      act = z2ui5_cl_ajson_utilities=>new( )->is_equal(
        ii_json_a = z2ui5_cl_ajson=>parse( '{"a":1,"b":2}' )
        ii_json_b = z2ui5_cl_ajson=>parse( '{"a":1,"b":2}' ) )
      exp = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      act = z2ui5_cl_ajson_utilities=>new( )->is_equal(
        iv_json_a = '{"a":1,"b":2}'
        iv_json_b = '{"a":1,"b":2}' )
      exp = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      act = z2ui5_cl_ajson_utilities=>new( )->is_equal(
        iv_json_a = '{"a":1,"b":2}'
        iv_json_b = '{"a":1,"b":3}' )
      exp = abap_false ).

    cl_abap_unit_assert=>assert_equals(
      act = z2ui5_cl_ajson_utilities=>new( )->is_equal(
        iv_json_a = '{"a":1,"b":2}'
        iv_json_b = '{"a":1,"b":2,"c":3}' )
      exp = abap_false ).

    cl_abap_unit_assert=>assert_equals(
      act = z2ui5_cl_ajson_utilities=>new( )->is_equal(
        iv_json_a = '{"a":1,"b":2,"c":3}'
        iv_json_b = '{"a":1,"b":2}' )
      exp = abap_false ).

  endmethod.

endclass.
