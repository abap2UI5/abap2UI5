**********************************************************************
* UTIL
**********************************************************************
class lcl_nodes_helper definition final.
  public section.

    data mt_nodes type z2ui5_if_ajson_types=>ty_nodes_tt.
    methods add
      importing
        iv_str type string.
    methods clear.
    methods sorted
      returning
        value(rt_nodes) type z2ui5_if_ajson_types=>ty_nodes_ts.

endclass.

class lcl_nodes_helper implementation.
  method add.

    field-symbols <n> like line of mt_nodes.
    data lv_children type string.
    data lv_index type string.
    data lv_order type string.

    append initial line to mt_nodes assigning <n>.

    split iv_str at '|' into
      <n>-path
      <n>-name
      <n>-type
      <n>-value
      lv_index
      lv_children
      lv_order.
    condense <n>-path.
    condense <n>-name.
    condense <n>-type.
    condense <n>-value.
    <n>-index = lv_index.
    <n>-children = lv_children.
    <n>-order = lv_order.

  endmethod.

  method sorted.
    rt_nodes = mt_nodes.
  endmethod.

  method clear.
    clear mt_nodes.
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
        iv_separator type string optional
      returning
        value(rv_json) type string.

  private section.
    data mo_cut type ref to lcl_json_parser.
    data mo_nodes type ref to lcl_nodes_helper.

    methods setup.
    methods parse for testing raising z2UI5_cx_ajson_error.
    methods parse_keeping_order for testing raising z2UI5_cx_ajson_error.
    methods parse_string for testing raising z2UI5_cx_ajson_error.
    methods parse_number for testing raising z2UI5_cx_ajson_error.
    methods parse_float for testing raising z2UI5_cx_ajson_error.
    methods parse_boolean for testing raising z2UI5_cx_ajson_error.
    methods parse_false for testing raising z2UI5_cx_ajson_error.
    methods parse_null for testing raising z2UI5_cx_ajson_error.
    methods parse_date for testing raising z2UI5_cx_ajson_error.
    methods parse_bare_values for testing raising z2UI5_cx_ajson_error.
    methods parse_error for testing raising z2UI5_cx_ajson_error.
    methods duplicate_key for testing raising z2UI5_cx_ajson_error.
    methods non_json for testing raising z2UI5_cx_ajson_error.

endclass.

class ltcl_parser_test implementation.

  method setup.
    create object mo_cut.
    create object mo_nodes.
  endmethod.

  method parse_bare_values.

    data lt_act type z2ui5_if_ajson_types=>ty_nodes_tt.

    mo_nodes->add( ' | |str |abc | |0' ).
    lt_act = mo_cut->parse( '"abc"' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_act
      exp = mo_nodes->mt_nodes ).

    mo_nodes->clear( ).
    mo_nodes->add( ' | |num |-123 | |0' ).
    lt_act = mo_cut->parse( '-123' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_act
      exp = mo_nodes->mt_nodes ).

    mo_nodes->clear( ).
    mo_nodes->add( ' | |bool |true | |0' ).
    lt_act = mo_cut->parse( 'true' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_act
      exp = mo_nodes->mt_nodes ).

    mo_nodes->clear( ).
    mo_nodes->add( ' | |bool |false | |0' ).
    lt_act = mo_cut->parse( 'false' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_act
      exp = mo_nodes->mt_nodes ).

    mo_nodes->clear( ).
    mo_nodes->add( ' | |null | | |0' ).
    lt_act = mo_cut->parse( 'null' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_act
      exp = mo_nodes->mt_nodes ).

  endmethod.

  method parse_error.

    data lt_act type z2ui5_if_ajson_types=>ty_nodes_tt.
    data lx_err type ref to z2UI5_cx_ajson_error.
    try.
      lt_act = mo_cut->parse( 'abc' ).
      cl_abap_unit_assert=>fail( 'Parsing of string w/o quotes must fail (spec)' ).
    catch z2UI5_cx_ajson_error into lx_err.
      cl_abap_unit_assert=>assert_char_cp(
        act = lx_err->get_text( )
        exp = '*parsing error*' ).
      cl_abap_unit_assert=>assert_char_cp(
        act = lx_err->location
        exp = 'Line 1, Offset 1' ).
    endtry.

    try.
      lt_act = mo_cut->parse( '{' && cl_abap_char_utilities=>newline
        && '"ok": "abc",' && cl_abap_char_utilities=>newline
        && '"error"' && cl_abap_char_utilities=>newline
        && '}' ).
      cl_abap_unit_assert=>fail( 'Parsing of invalid JSON must fail (spec)' ).
    catch z2UI5_cx_ajson_error into lx_err.
      cl_abap_unit_assert=>assert_char_cp(
        act = lx_err->get_text( )
        exp = '*parsing error*' ).
      cl_abap_unit_assert=>assert_char_cp(
        act = lx_err->location
        exp = 'Line 3, Offset 8' ).
    endtry.

  endmethod.

  method parse_string.
    mo_nodes->add( '                 |         |object |                        |  |1' ).
    mo_nodes->add( '/                |string   |str    |abc                     |  |0' ).

    data lt_act type z2ui5_if_ajson_types=>ty_nodes_tt.
    lt_act = mo_cut->parse( '{"string": "abc"}' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_act
      exp = mo_nodes->mt_nodes ).
  endmethod.

  method parse_number.
    mo_nodes->add( '                 |         |object |                        |  |1' ).
    mo_nodes->add( '/                |number   |num    |123                     |  |0' ).

    data lt_act type z2ui5_if_ajson_types=>ty_nodes_tt.
    lt_act = mo_cut->parse( '{"number": 123}' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_act
      exp = mo_nodes->mt_nodes ).
  endmethod.

  method parse_float.
    mo_nodes->add( '                 |         |object |                        |  |1' ).
    mo_nodes->add( '/                |float    |num    |123.45                  |  |0' ).

    data lt_act type z2ui5_if_ajson_types=>ty_nodes_tt.
    create object mo_cut.
    lt_act = mo_cut->parse( '{"float": 123.45}' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_act
      exp = mo_nodes->mt_nodes ).
  endmethod.

  method parse_boolean.
    mo_nodes->add( '                 |         |object |                        |  |1' ).
    mo_nodes->add( '/                |boolean  |bool   |true                    |  |0' ).

    data lt_act type z2ui5_if_ajson_types=>ty_nodes_tt.
    lt_act = mo_cut->parse( '{"boolean": true}' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_act
      exp = mo_nodes->mt_nodes ).
  endmethod.

  method parse_false.
    mo_nodes->add( '                 |         |object |                        |  |1' ).
    mo_nodes->add( '/                |false    |bool   |false                   |  |0' ).

    data lt_act type z2ui5_if_ajson_types=>ty_nodes_tt.
    lt_act = mo_cut->parse( '{"false": false}' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_act
      exp = mo_nodes->mt_nodes ).
  endmethod.

  method parse_null.
    mo_nodes->add( '                 |         |object |                        |  |1' ).
    mo_nodes->add( '/                |null     |null   |                        |  |0' ).

    data lt_act type z2ui5_if_ajson_types=>ty_nodes_tt.
    lt_act = mo_cut->parse( '{"null": null}' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_act
      exp = mo_nodes->mt_nodes ).
  endmethod.

  method parse_date.
    mo_nodes->add( '                 |         |object |                        |  |1' ).
    mo_nodes->add( '/                |date     |str    |2020-03-15              |  |0' ).

    data lt_act type z2ui5_if_ajson_types=>ty_nodes_tt.
    lt_act = mo_cut->parse( '{"date": "2020-03-15"}' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_act
      exp = mo_nodes->mt_nodes ).
  endmethod.

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

  method parse.

    data lo_cut type ref to lcl_json_parser.
    data lt_act type z2ui5_if_ajson_types=>ty_nodes_tt.
    data lo_nodes type ref to lcl_nodes_helper.

    create object lo_nodes.
    lo_nodes->add( '                 |         |object |                        |  |8' ).
    lo_nodes->add( '/                |string   |str    |abc                     |  |0' ).
    lo_nodes->add( '/                |number   |num    |123                     |  |0' ).
    lo_nodes->add( '/                |float    |num    |123.45                  |  |0' ).
    lo_nodes->add( '/                |boolean  |bool   |true                    |  |0' ).
    lo_nodes->add( '/                |false    |bool   |false                   |  |0' ).
    lo_nodes->add( '/                |null     |null   |                        |  |0' ).
    lo_nodes->add( '/                |date     |str    |2020-03-15              |  |0' ).
    lo_nodes->add( '/                |issues   |array  |                        |  |2' ).
    lo_nodes->add( '/issues/         |1        |object |                        |1 |5' ).
    lo_nodes->add( '/issues/1/       |message  |str    |Indentation problem ... |  |0' ).
    lo_nodes->add( '/issues/1/       |key      |str    |indentation             |  |0' ).
    lo_nodes->add( '/issues/1/       |start    |object |                        |  |2' ).
    lo_nodes->add( '/issues/1/start/ |row      |num    |4                       |  |0' ).
    lo_nodes->add( '/issues/1/start/ |col      |num    |3                       |  |0' ).
    lo_nodes->add( '/issues/1/       |end      |object |                        |  |2' ).
    lo_nodes->add( '/issues/1/end/   |row      |num    |4                       |  |0' ).
    lo_nodes->add( '/issues/1/end/   |col      |num    |26                      |  |0' ).
    lo_nodes->add( '/issues/1/       |filename |str    |./zxxx.prog.abap        |  |0' ).
    lo_nodes->add( '/issues/         |2        |object |                        |2 |5' ).
    lo_nodes->add( '/issues/2/       |message  |str    |Remove space before XXX |  |0' ).
    lo_nodes->add( '/issues/2/       |key      |str    |space_before_dot        |  |0' ).
    lo_nodes->add( '/issues/2/       |start    |object |                        |  |2' ).
    lo_nodes->add( '/issues/2/start/ |row      |num    |3                       |  |0' ).
    lo_nodes->add( '/issues/2/start/ |col      |num    |21                      |  |0' ).
    lo_nodes->add( '/issues/2/       |end      |object |                        |  |2' ).
    lo_nodes->add( '/issues/2/end/   |row      |num    |3                       |  |0' ).
    lo_nodes->add( '/issues/2/end/   |col      |num    |22                      |  |0' ).
    lo_nodes->add( '/issues/2/       |filename |str    |./zxxx.prog.abap        |  |0' ).

    create object lo_cut.
    lt_act = lo_cut->parse( sample_json( ) ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_act
      exp = lo_nodes->mt_nodes ).

    lt_act = lo_cut->parse( sample_json( |{ cl_abap_char_utilities=>newline }| ) ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_act
      exp = lo_nodes->mt_nodes ).

    lt_act = lo_cut->parse( sample_json( |{ cl_abap_char_utilities=>cr_lf }| ) ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_act
      exp = lo_nodes->mt_nodes ).

  endmethod.

  method parse_keeping_order.

    data lo_cut type ref to lcl_json_parser.
    data lt_act type z2ui5_if_ajson_types=>ty_nodes_tt.
    data lo_nodes type ref to lcl_nodes_helper.

    create object lo_nodes.
    lo_nodes->add( '                 |         |object |                        |  |8 |0' ).
    lo_nodes->add( '/                |string   |str    |abc                     |  |0 |1' ).
    lo_nodes->add( '/                |number   |num    |123                     |  |0 |2' ).
    lo_nodes->add( '/                |float    |num    |123.45                  |  |0 |3' ).
    lo_nodes->add( '/                |boolean  |bool   |true                    |  |0 |4' ).
    lo_nodes->add( '/                |false    |bool   |false                   |  |0 |5' ).
    lo_nodes->add( '/                |null     |null   |                        |  |0 |6' ).
    lo_nodes->add( '/                |date     |str    |2020-03-15              |  |0 |7' ).
    lo_nodes->add( '/                |issues   |array  |                        |  |2 |8' ).
    lo_nodes->add( '/issues/         |1        |object |                        |1 |5 |0' ).
    lo_nodes->add( '/issues/1/       |message  |str    |Indentation problem ... |  |0 |1' ).
    lo_nodes->add( '/issues/1/       |key      |str    |indentation             |  |0 |2' ).
    lo_nodes->add( '/issues/1/       |start    |object |                        |  |2 |3' ).
    lo_nodes->add( '/issues/1/start/ |row      |num    |4                       |  |0 |1' ).
    lo_nodes->add( '/issues/1/start/ |col      |num    |3                       |  |0 |2' ).
    lo_nodes->add( '/issues/1/       |end      |object |                        |  |2 |4' ).
    lo_nodes->add( '/issues/1/end/   |row      |num    |4                       |  |0 |1' ).
    lo_nodes->add( '/issues/1/end/   |col      |num    |26                      |  |0 |2' ).
    lo_nodes->add( '/issues/1/       |filename |str    |./zxxx.prog.abap        |  |0 |5' ).
    lo_nodes->add( '/issues/         |2        |object |                        |2 |5 |0' ).
    lo_nodes->add( '/issues/2/       |message  |str    |Remove space before XXX |  |0 |1' ).
    lo_nodes->add( '/issues/2/       |key      |str    |space_before_dot        |  |0 |2' ).
    lo_nodes->add( '/issues/2/       |start    |object |                        |  |2 |3' ).
    lo_nodes->add( '/issues/2/start/ |row      |num    |3                       |  |0 |1' ).
    lo_nodes->add( '/issues/2/start/ |col      |num    |21                      |  |0 |2' ).
    lo_nodes->add( '/issues/2/       |end      |object |                        |  |2 |4' ).
    lo_nodes->add( '/issues/2/end/   |row      |num    |3                       |  |0 |1' ).
    lo_nodes->add( '/issues/2/end/   |col      |num    |22                      |  |0 |2' ).
    lo_nodes->add( '/issues/2/       |filename |str    |./zxxx.prog.abap        |  |0 |5' ).

    create object lo_cut.
    lt_act = lo_cut->parse(
      iv_json = sample_json( )
      iv_keep_item_order = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_act
      exp = lo_nodes->mt_nodes ).

    lt_act = lo_cut->parse(
      iv_json = sample_json( |{ cl_abap_char_utilities=>newline }| )
      iv_keep_item_order = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_act
      exp = lo_nodes->mt_nodes ).

    lt_act = lo_cut->parse(
      iv_json = sample_json( |{ cl_abap_char_utilities=>cr_lf }| )
      iv_keep_item_order = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_act
      exp = lo_nodes->mt_nodes ).

  endmethod.

  method duplicate_key.

    data lo_cut type ref to lcl_json_parser.
    data lx type ref to z2UI5_cx_ajson_error.

    try.
      create object lo_cut.
      lo_cut->parse( '{ "a" = 1, "a" = 1 }' ).
      cl_abap_unit_assert=>fail( ).
    catch z2UI5_cx_ajson_error into lx.
      cl_abap_unit_assert=>assert_not_initial( lx ).
    endtry.

  endmethod.

  method non_json.

    data lo_cut type ref to lcl_json_parser.
    data lx type ref to z2UI5_cx_ajson_error.

    try.
      create object lo_cut.
      lo_cut->parse( '<html><head><title>X</title></head><body><h1>Y</h1></body></html>' ).
      cl_abap_unit_assert=>fail( ).
    catch z2UI5_cx_ajson_error into lx.
      cl_abap_unit_assert=>assert_not_initial( lx ).
    endtry.

  endmethod.

endclass.

**********************************************************************
* SERIALIZER
**********************************************************************

class ltcl_serializer_test definition final
  for testing
  risk level harmless
  duration short.

  public section.

    class-methods sample_json
      returning
        value(rv_json) type string.
    class-methods sample_nodes
      returning
        value(rt_nodes) type z2ui5_if_ajson_types=>ty_nodes_ts.

  private section.

    methods stringify_condensed for testing raising z2UI5_cx_ajson_error.
    methods stringify_indented for testing raising z2UI5_cx_ajson_error.
    methods array_index for testing raising z2UI5_cx_ajson_error.
    methods item_order for testing raising z2UI5_cx_ajson_error.
    methods simple_indented for testing raising z2UI5_cx_ajson_error.
    methods empty_set for testing raising z2UI5_cx_ajson_error.
    methods escape_string for testing raising z2UI5_cx_ajson_error.
    methods empty for testing raising z2UI5_cx_ajson_error.

endclass.

class ltcl_serializer_test implementation.

  method sample_json.

    rv_json =
      '{\n' &&
      '  "boolean": true,\n' &&
      '  "date": "2020-03-15",\n' &&
      '  "false": false,\n' &&
      '  "float": 123.45,\n' &&
      '  "issues": [\n' &&
      '    {\n' &&
      '      "end": {\n' &&
      '        "col": 26,\n' &&
      '        "row": 4\n' &&
      '      },\n' &&
      '      "filename": "./zxxx.prog.abap",\n' &&
      '      "key": "indentation",\n' &&
      '      "message": "Indentation problem ...",\n' &&
      '      "start": {\n' &&
      '        "col": 3,\n' &&
      '        "row": 4\n' &&
      '      }\n' &&
      '    },\n' &&
      '    {\n' &&
      '      "end": {\n' &&
      '        "col": 22,\n' &&
      '        "row": 3\n' &&
      '      },\n' &&
      '      "filename": "./zxxx.prog.abap",\n' &&
      '      "key": "space_before_dot",\n' &&
      '      "message": "Remove space before XXX",\n' &&
      '      "start": {\n' &&
      '        "col": 21,\n' &&
      '        "row": 3\n' &&
      '      }\n' &&
      '    }\n' &&
      '  ],\n' &&
      '  "null": null,\n' &&
      '  "number": 123,\n' &&
      '  "string": "abc"\n' &&
      '}'.

    rv_json = replace(
      val = rv_json
      sub = '\n'
      with = cl_abap_char_utilities=>newline
      occ = 0 ).

  endmethod.

  method sample_nodes.

    data lo_nodes type ref to lcl_nodes_helper.

    create object lo_nodes.
    lo_nodes->add( '                 |         |object |                        |  |8' ).
    lo_nodes->add( '/                |string   |str    |abc                     |  |0' ).
    lo_nodes->add( '/                |number   |num    |123                     |  |0' ).
    lo_nodes->add( '/                |float    |num    |123.45                  |  |0' ).
    lo_nodes->add( '/                |boolean  |bool   |true                    |  |0' ).
    lo_nodes->add( '/                |false    |bool   |false                   |  |0' ).
    lo_nodes->add( '/                |null     |null   |                        |  |0' ).
    lo_nodes->add( '/                |date     |str    |2020-03-15              |  |0' ).
    lo_nodes->add( '/                |issues   |array  |                        |  |2' ).
    lo_nodes->add( '/issues/         |1        |object |                        |1 |5' ).
    lo_nodes->add( '/issues/1/       |message  |str    |Indentation problem ... |  |0' ).
    lo_nodes->add( '/issues/1/       |key      |str    |indentation             |  |0' ).
    lo_nodes->add( '/issues/1/       |start    |object |                        |  |2' ).
    lo_nodes->add( '/issues/1/start/ |row      |num    |4                       |  |0' ).
    lo_nodes->add( '/issues/1/start/ |col      |num    |3                       |  |0' ).
    lo_nodes->add( '/issues/1/       |end      |object |                        |  |2' ).
    lo_nodes->add( '/issues/1/end/   |row      |num    |4                       |  |0' ).
    lo_nodes->add( '/issues/1/end/   |col      |num    |26                      |  |0' ).
    lo_nodes->add( '/issues/1/       |filename |str    |./zxxx.prog.abap        |  |0' ).
    lo_nodes->add( '/issues/         |2        |object |                        |2 |5' ).
    lo_nodes->add( '/issues/2/       |message  |str    |Remove space before XXX |  |0' ).
    lo_nodes->add( '/issues/2/       |key      |str    |space_before_dot        |  |0' ).
    lo_nodes->add( '/issues/2/       |start    |object |                        |  |2' ).
    lo_nodes->add( '/issues/2/start/ |row      |num    |3                       |  |0' ).
    lo_nodes->add( '/issues/2/start/ |col      |num    |21                      |  |0' ).
    lo_nodes->add( '/issues/2/       |end      |object |                        |  |2' ).
    lo_nodes->add( '/issues/2/end/   |row      |num    |3                       |  |0' ).
    lo_nodes->add( '/issues/2/end/   |col      |num    |22                      |  |0' ).
    lo_nodes->add( '/issues/2/       |filename |str    |./zxxx.prog.abap        |  |0' ).

    rt_nodes = lo_nodes->sorted( ).

  endmethod.

  method stringify_condensed.

    data lv_act type string.
    data lv_exp type string.

    lv_act = lcl_json_serializer=>stringify( sample_nodes( ) ).
    lv_exp = sample_json( ).

    lv_exp = replace(
      val = lv_exp
      sub = cl_abap_char_utilities=>newline
      with = ''
      occ = 0 ).
    condense lv_exp.
    lv_exp = replace(
      val = lv_exp
      sub = `: `
      with = ':'
      occ = 0 ).
    lv_exp = replace(
      val = lv_exp
      sub = `{ `
      with = '{'
      occ = 0 ).
    lv_exp = replace(
      val = lv_exp
      sub = `[ `
      with = '['
      occ = 0 ).
    lv_exp = replace(
      val = lv_exp
      sub = ` }`
      with = '}'
      occ = 0 ).
    lv_exp = replace(
      val = lv_exp
      sub = ` ]`
      with = ']'
      occ = 0 ).
    lv_exp = replace(
      val = lv_exp
      sub = `, `
      with = ','
      occ = 0 ).

    cl_abap_unit_assert=>assert_equals(
      act = lv_act
      exp = lv_exp ).

  endmethod.

  method stringify_indented.

    data lv_act type string.
    data lv_exp type string.

    lv_act = lcl_json_serializer=>stringify(
      it_json_tree = sample_nodes( )
      iv_indent    = 2 ).
    lv_exp = sample_json( ).

    cl_abap_unit_assert=>assert_equals(
      act = lv_act
      exp = lv_exp ).

  endmethod.

  method array_index.

    data lv_act type string.
    data lv_exp type string.
    data lo_nodes type ref to lcl_nodes_helper.

    create object lo_nodes.
    lo_nodes->add( '                |    |array  |                        |  |3' ).
    lo_nodes->add( '/               |1   |str    |abc                     |2 |0' ).
    lo_nodes->add( '/               |2   |num    |123                     |1 |0' ).
    lo_nodes->add( '/               |3   |num    |123.45                  |3 |0' ).

    lv_act = lcl_json_serializer=>stringify( lo_nodes->sorted( ) ).
    lv_exp = '[123,"abc",123.45]'.

    cl_abap_unit_assert=>assert_equals(
      act = lv_act
      exp = lv_exp ).

  endmethod.

  method item_order.

    data lv_act type string.
    data lv_exp type string.
    data lo_nodes type ref to lcl_nodes_helper.

    create object lo_nodes.
    lo_nodes->add( '                |       |object |                   |  |3 |0' ).
    lo_nodes->add( '/               |beta   |str    |b                  |  |0 |3' ).
    lo_nodes->add( '/               |zulu   |str    |z                  |  |0 |1' ).
    lo_nodes->add( '/               |alpha  |str    |a                  |  |0 |2' ).

    lv_act = lcl_json_serializer=>stringify( lo_nodes->sorted( ) ).
    lv_exp = '{"alpha":"a","beta":"b","zulu":"z"}'. " NAME order ! (it is also a UT)

    cl_abap_unit_assert=>assert_equals(
      act = lv_act
      exp = lv_exp ).

    lv_act = lcl_json_serializer=>stringify(
      it_json_tree = lo_nodes->sorted( )
      iv_keep_item_order = abap_true ).
    lv_exp = '{"zulu":"z","alpha":"a","beta":"b"}'.

    cl_abap_unit_assert=>assert_equals(
      act = lv_act
      exp = lv_exp ).

  endmethod.

  method simple_indented.

    data lv_act type string.
    data lv_exp type string.
    data lo_nodes type ref to lcl_nodes_helper.

    create object lo_nodes.
    lo_nodes->add( '                |    |array  |                        |  |3' ).
    lo_nodes->add( '/               |1   |object |                        |2 |2' ).
    lo_nodes->add( '/1/             |a   |num    |1                       |  |0' ).
    lo_nodes->add( '/1/             |b   |num    |2                       |  |0' ).
    lo_nodes->add( '/               |2   |num    |123                     |1 |0' ).
    lo_nodes->add( '/               |3   |num    |123.45                  |3 |0' ).

    lv_act = lcl_json_serializer=>stringify(
      it_json_tree = lo_nodes->sorted( )
      iv_indent    = 2 ).
    lv_exp = '[\n' &&
    '  123,\n' &&
    '  {\n' &&
    '    "a": 1,\n' &&
    '    "b": 2\n' &&
    '  },\n' &&
    '  123.45\n' &&
    ']'.
    lv_exp = replace(
      val = lv_exp
      sub = '\n'
      with = cl_abap_char_utilities=>newline
      occ = 0 ).

    cl_abap_unit_assert=>assert_equals(
      act = lv_act
      exp = lv_exp ).

  endmethod.

  method empty_set.

    data lv_act type string.
    data lv_exp type string.
    data lo_nodes type ref to lcl_nodes_helper.

    create object lo_nodes.
    lo_nodes->add( '                |    |array  |                        |  |0' ).

    lv_act = lcl_json_serializer=>stringify(
      it_json_tree = lo_nodes->sorted( )
      iv_indent    = 0 ).
    lv_exp = '[]'.

    cl_abap_unit_assert=>assert_equals(
      act = lv_act
      exp = lv_exp ).

    lv_act = lcl_json_serializer=>stringify(
      it_json_tree = lo_nodes->sorted( )
      iv_indent    = 2 ).
    lv_exp = '[]'.

    cl_abap_unit_assert=>assert_equals(
      act = lv_act
      exp = lv_exp ).

  endmethod.

  method escape_string.

    data lv_act type string.
    data lv_exp type string.
    data lv_val type string.
    data lo_nodes type ref to lcl_nodes_helper.

    create object lo_nodes.
    lv_val = 'a' && '"' && '\' && cl_abap_char_utilities=>horizontal_tab && cl_abap_char_utilities=>cr_lf.
    lo_nodes->add( | \| \|str \|{ lv_val }\| \|0| ).

    lv_act = lcl_json_serializer=>stringify( lo_nodes->sorted( ) ).
    lv_exp = '"a\"\\\t\r\n"'.

    cl_abap_unit_assert=>assert_equals(
      act = lv_act
      exp = lv_exp ).

  endmethod.

  method empty.

    data lv_act type string.
    data lv_exp type string.
    data lo_nodes type ref to lcl_nodes_helper.

    create object lo_nodes.

    lv_act = lcl_json_serializer=>stringify( lo_nodes->sorted( ) ).
    lv_exp = ''.

    cl_abap_unit_assert=>assert_equals(
      act = lv_act
      exp = lv_exp ).

  endmethod.

endclass.

**********************************************************************
* UTILS
**********************************************************************

class ltcl_utils_test definition final
  for testing
  risk level harmless
  duration short.

  private section.

    methods normalize_path for testing.
    methods split_path for testing.
    methods validate_array_index for testing raising z2UI5_cx_ajson_error.
    methods string_to_xstring_utf8 for testing.

endclass.

class z2ui5_cl_ajson definition local friends ltcl_utils_test.

class ltcl_utils_test implementation.

  method string_to_xstring_utf8.

    cl_abap_unit_assert=>assert_equals(
      act = lcl_utils=>string_to_xstring_utf8( '123' )
      exp = '313233' ).

  endmethod.

  method validate_array_index.

    cl_abap_unit_assert=>assert_equals(
      act = lcl_utils=>validate_array_index( iv_path = 'x' iv_index = '123' )
      exp = 123 ).

    try.
      lcl_utils=>validate_array_index( iv_path = 'x' iv_index = 'a' ).
      cl_abap_unit_assert=>fail( ).
    catch z2UI5_cx_ajson_error.
    endtry.

    try.
      lcl_utils=>validate_array_index( iv_path = 'x' iv_index = '0' ).
      cl_abap_unit_assert=>fail( ).
    catch z2UI5_cx_ajson_error.
    endtry.

  endmethod.

  method normalize_path.

    cl_abap_unit_assert=>assert_equals(
      act = lcl_utils=>normalize_path( '' )
      exp = '/' ).
    cl_abap_unit_assert=>assert_equals(
      act = lcl_utils=>normalize_path( '/' )
      exp = '/' ).
    cl_abap_unit_assert=>assert_equals(
      act = lcl_utils=>normalize_path( 'abc' )
      exp = '/abc/' ).
    cl_abap_unit_assert=>assert_equals(
      act = lcl_utils=>normalize_path( '/abc' )
      exp = '/abc/' ).
    cl_abap_unit_assert=>assert_equals(
      act = lcl_utils=>normalize_path( 'abc/' )
      exp = '/abc/' ).
    cl_abap_unit_assert=>assert_equals(
      act = lcl_utils=>normalize_path( '/abc/' )
      exp = '/abc/' ).

  endmethod.

  method split_path.

    data ls_exp type z2ui5_if_ajson_types=>ty_path_name.
    data lv_path type string.

    lv_path     = ''. " alias to root
    ls_exp-path = ''.
    ls_exp-name = ''.
    cl_abap_unit_assert=>assert_equals(
      act = lcl_utils=>split_path( lv_path )
      exp = ls_exp ).

    lv_path     = '/'.
    ls_exp-path = ''.
    ls_exp-name = ''.
    cl_abap_unit_assert=>assert_equals(
      act = lcl_utils=>split_path( lv_path )
      exp = ls_exp ).

    lv_path     = '/abc/'.
    ls_exp-path = '/'.
    ls_exp-name = 'abc'.
    cl_abap_unit_assert=>assert_equals(
      act = lcl_utils=>split_path( lv_path )
      exp = ls_exp ).

    lv_path     = 'abc'.
    ls_exp-path = '/'.
    ls_exp-name = 'abc'.
    cl_abap_unit_assert=>assert_equals(
      act = lcl_utils=>split_path( lv_path )
      exp = ls_exp ).

    lv_path     = '/abc'.
    ls_exp-path = '/'.
    ls_exp-name = 'abc'.
    cl_abap_unit_assert=>assert_equals(
      act = lcl_utils=>split_path( lv_path )
      exp = ls_exp ).

    lv_path     = 'abc/'.
    ls_exp-path = '/'.
    ls_exp-name = 'abc'.
    cl_abap_unit_assert=>assert_equals(
      act = lcl_utils=>split_path( lv_path )
      exp = ls_exp ).

    lv_path     = '/abc/xyz'.
    ls_exp-path = '/abc/'.
    ls_exp-name = 'xyz'.
    cl_abap_unit_assert=>assert_equals(
      act = lcl_utils=>split_path( lv_path )
      exp = ls_exp ).

    lv_path     = '/abc/xyz/'.
    ls_exp-path = '/abc/'.
    ls_exp-name = 'xyz'.
    cl_abap_unit_assert=>assert_equals(
      act = lcl_utils=>split_path( lv_path )
      exp = ls_exp ).

  endmethod.

endclass.

**********************************************************************
* READER
**********************************************************************

class ltcl_reader_test definition final
  for testing
  risk level harmless
  duration short.

  private section.

    methods get_value for testing raising z2UI5_cx_ajson_error.
    methods get_node_type for testing raising z2UI5_cx_ajson_error.
    methods exists for testing raising z2UI5_cx_ajson_error.
    methods value_integer for testing raising z2UI5_cx_ajson_error.
    methods value_number for testing raising z2UI5_cx_ajson_error.
    methods value_boolean for testing raising z2UI5_cx_ajson_error.
    methods value_string for testing raising z2UI5_cx_ajson_error.
    methods members for testing raising z2UI5_cx_ajson_error.
    methods slice for testing raising z2UI5_cx_ajson_error.
    methods array_to_string_table for testing raising z2UI5_cx_ajson_error.
    methods get_date for testing raising z2UI5_cx_ajson_error.
    methods get_timestamp for testing raising z2UI5_cx_ajson_error.

endclass.

class z2ui5_cl_ajson definition local friends ltcl_reader_test.

class ltcl_reader_test implementation.

  method slice.

    data lo_cut type ref to z2ui5_cl_ajson.
    data lo_nodes type ref to lcl_nodes_helper.

    create object lo_nodes.
    lo_nodes->add( '          |         |array  |                        |  |2' ).
    lo_nodes->add( '/         |1        |object |                        |1 |5' ).
    lo_nodes->add( '/1/       |message  |str    |Indentation problem ... |  |0' ).
    lo_nodes->add( '/1/       |key      |str    |indentation             |  |0' ).
    lo_nodes->add( '/1/       |start    |object |                        |  |2' ).
    lo_nodes->add( '/1/start/ |row      |num    |4                       |  |0' ).
    lo_nodes->add( '/1/start/ |col      |num    |3                       |  |0' ).
    lo_nodes->add( '/1/       |end      |object |                        |  |2' ).
    lo_nodes->add( '/1/end/   |row      |num    |4                       |  |0' ).
    lo_nodes->add( '/1/end/   |col      |num    |26                      |  |0' ).
    lo_nodes->add( '/1/       |filename |str    |./zxxx.prog.abap        |  |0' ).
    lo_nodes->add( '/         |2        |object |                        |2 |5' ).
    lo_nodes->add( '/2/       |message  |str    |Remove space before XXX |  |0' ).
    lo_nodes->add( '/2/       |key      |str    |space_before_dot        |  |0' ).
    lo_nodes->add( '/2/       |start    |object |                        |  |2' ).
    lo_nodes->add( '/2/start/ |row      |num    |3                       |  |0' ).
    lo_nodes->add( '/2/start/ |col      |num    |21                      |  |0' ).
    lo_nodes->add( '/2/       |end      |object |                        |  |2' ).
    lo_nodes->add( '/2/end/   |row      |num    |3                       |  |0' ).
    lo_nodes->add( '/2/end/   |col      |num    |22                      |  |0' ).
    lo_nodes->add( '/2/       |filename |str    |./zxxx.prog.abap        |  |0' ).


    lo_cut = z2ui5_cl_ajson=>parse( ltcl_parser_test=>sample_json( ) ).
    lo_cut ?= lo_cut->z2ui5_if_ajson~slice( '/issues' ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->mt_json_tree
      exp = lo_nodes->sorted( ) ).

    " **********************************************************************

    create object lo_nodes.
    lo_nodes->add( '                 |         |object |                        |  |8' ).
    lo_nodes->add( '/                |string   |str    |abc                     |  |0' ).
    lo_nodes->add( '/                |number   |num    |123                     |  |0' ).
    lo_nodes->add( '/                |float    |num    |123.45                  |  |0' ).
    lo_nodes->add( '/                |boolean  |bool   |true                    |  |0' ).
    lo_nodes->add( '/                |false    |bool   |false                   |  |0' ).
    lo_nodes->add( '/                |null     |null   |                        |  |0' ).
    lo_nodes->add( '/                |date     |str    |2020-03-15              |  |0' ).
    lo_nodes->add( '/                |issues   |array  |                        |  |2' ).
    lo_nodes->add( '/issues/         |1        |object |                        |1 |5' ).
    lo_nodes->add( '/issues/1/       |message  |str    |Indentation problem ... |  |0' ).
    lo_nodes->add( '/issues/1/       |key      |str    |indentation             |  |0' ).
    lo_nodes->add( '/issues/1/       |start    |object |                        |  |2' ).
    lo_nodes->add( '/issues/1/start/ |row      |num    |4                       |  |0' ).
    lo_nodes->add( '/issues/1/start/ |col      |num    |3                       |  |0' ).
    lo_nodes->add( '/issues/1/       |end      |object |                        |  |2' ).
    lo_nodes->add( '/issues/1/end/   |row      |num    |4                       |  |0' ).
    lo_nodes->add( '/issues/1/end/   |col      |num    |26                      |  |0' ).
    lo_nodes->add( '/issues/1/       |filename |str    |./zxxx.prog.abap        |  |0' ).
    lo_nodes->add( '/issues/         |2        |object |                        |2 |5' ).
    lo_nodes->add( '/issues/2/       |message  |str    |Remove space before XXX |  |0' ).
    lo_nodes->add( '/issues/2/       |key      |str    |space_before_dot        |  |0' ).
    lo_nodes->add( '/issues/2/       |start    |object |                        |  |2' ).
    lo_nodes->add( '/issues/2/start/ |row      |num    |3                       |  |0' ).
    lo_nodes->add( '/issues/2/start/ |col      |num    |21                      |  |0' ).
    lo_nodes->add( '/issues/2/       |end      |object |                        |  |2' ).
    lo_nodes->add( '/issues/2/end/   |row      |num    |3                       |  |0' ).
    lo_nodes->add( '/issues/2/end/   |col      |num    |22                      |  |0' ).
    lo_nodes->add( '/issues/2/       |filename |str    |./zxxx.prog.abap        |  |0' ).

    lo_cut = z2ui5_cl_ajson=>parse( ltcl_parser_test=>sample_json( ) ).
    lo_cut ?= lo_cut->z2ui5_if_ajson~slice( '/' ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->mt_json_tree
      exp = lo_nodes->sorted( ) ).

    " **********************************************************************

    create object lo_nodes.
    lo_nodes->add( '  |         |object |                        | |2' ).
    lo_nodes->add( '/ |row      |num    |3                       | |0' ).
    lo_nodes->add( '/ |col      |num    |21                      | |0' ).

    lo_cut = z2ui5_cl_ajson=>parse( ltcl_parser_test=>sample_json( ) ).
    lo_cut ?= lo_cut->z2ui5_if_ajson~slice( '/issues/2/start/' ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->mt_json_tree
      exp = lo_nodes->sorted( ) ).

  endmethod.

  method get_value.

    data lo_cut type ref to z2ui5_if_ajson.
    lo_cut ?= z2ui5_cl_ajson=>parse( ltcl_parser_test=>sample_json( ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->get( '/string' )
      exp = 'abc' ).

    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->get( '/string/' )
      exp = 'abc' ). " Hmmm ?

    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->get( '/boolean' )
      exp = 'true' ).

    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->get( '/issues/2/start/row' )
      exp = '3' ).

  endmethod.

  method get_node_type.

    data li_cut type ref to z2ui5_if_ajson.
    li_cut = z2ui5_cl_ajson=>parse( ltcl_parser_test=>sample_json( ) ).

    cl_abap_unit_assert=>assert_equals(
      act = li_cut->get_node_type( '/' )
      exp = z2ui5_if_ajson_types=>node_type-object ).
    cl_abap_unit_assert=>assert_equals(
      act = li_cut->get_node_type( '/string' )
      exp = z2ui5_if_ajson_types=>node_type-string ).
    cl_abap_unit_assert=>assert_equals(
      act = li_cut->get_node_type( '/number' )
      exp = z2ui5_if_ajson_types=>node_type-number ).
    cl_abap_unit_assert=>assert_equals(
      act = li_cut->get_node_type( '/float' )
      exp = z2ui5_if_ajson_types=>node_type-number ).
    cl_abap_unit_assert=>assert_equals(
      act = li_cut->get_node_type( '/boolean' )
      exp = z2ui5_if_ajson_types=>node_type-boolean ).
    cl_abap_unit_assert=>assert_equals(
      act = li_cut->get_node_type( '/false' )
      exp = z2ui5_if_ajson_types=>node_type-boolean ).
    cl_abap_unit_assert=>assert_equals(
      act = li_cut->get_node_type( '/null' )
      exp = z2ui5_if_ajson_types=>node_type-null ).
    cl_abap_unit_assert=>assert_equals(
      act = li_cut->get_node_type( '/date' )
      exp = z2ui5_if_ajson_types=>node_type-string ).
    cl_abap_unit_assert=>assert_equals(
      act = li_cut->get_node_type( '/issues' )
      exp = z2ui5_if_ajson_types=>node_type-array ).

  endmethod.

  method get_date.

    data lo_cut type ref to z2ui5_cl_ajson.
    data lo_nodes type ref to lcl_nodes_helper.
    data lv_exp type d.

    create object lo_cut.
    lv_exp = '20200728'.

    create object lo_nodes.
    lo_nodes->add( '  |         |object |                        | |1' ).
    lo_nodes->add( '/ |date1    |str    |2020-07-28              | |0' ).
    lo_cut->mt_json_tree = lo_nodes->mt_nodes.

    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->z2ui5_if_ajson~get_date( '/date1' )
      exp = lv_exp ).

    create object lo_nodes.
    lo_nodes->add( '  |         |object |                        | |1' ).
    lo_nodes->add( '/ |date1    |str    |2020-07-28T01:00:00Z    | |0' ).
    lo_cut->mt_json_tree = lo_nodes->mt_nodes.

    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->z2ui5_if_ajson~get_date( '/date1' )
      exp = lv_exp ).

    create object lo_nodes.
    lo_nodes->add( '  |         |object |                        | |1' ).
    lo_nodes->add( '/ |date1    |str    |20200728                | |0' ).
    lo_cut->mt_json_tree = lo_nodes->mt_nodes.

    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->z2ui5_if_ajson~get_date( '/date1' )
      exp = '' ).

  endmethod.

  method get_timestamp.

    data lo_cut type ref to z2ui5_cl_ajson.
    data lo_nodes type ref to lcl_nodes_helper.
    data lv_exp type timestamp value `20200728000000`.

    create object lo_cut.

    create object lo_nodes.
    lo_nodes->add( '  |         |object |                        | |1' ).
    lo_nodes->add( '/ |timestamp|str    |2020-07-28T00:00:00Z    | |0' ).
    lo_cut->mt_json_tree = lo_nodes->mt_nodes.

    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->z2ui5_if_ajson~get_timestamp( '/timestamp' )
      exp = lv_exp ).

  endmethod.

  method exists.

    data lo_cut type ref to z2ui5_if_ajson.
    lo_cut ?= z2ui5_cl_ajson=>parse( ltcl_parser_test=>sample_json( ) ).


    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->exists( '/string' )
      exp = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->exists( '/string/' )
      exp = abap_true ). " mmmm ?

    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->exists( '/xxx' )
      exp = abap_false ).

    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->exists( '/issues/2/start/row' )
      exp = abap_true ).

  endmethod.

  method value_integer.

    data lo_cut type ref to z2ui5_if_ajson.
    lo_cut ?= z2ui5_cl_ajson=>parse( ltcl_parser_test=>sample_json( ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->get_integer( '/string' )
      exp = 0 ). " Hmmmm ????

    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->get_integer( '/number' )
      exp = 123 ).

    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->get_integer( '/float' )
      exp = 123 ).

  endmethod.

  method value_number.

    data lo_cut type ref to z2ui5_if_ajson.
    lo_cut ?= z2ui5_cl_ajson=>parse( ltcl_parser_test=>sample_json( ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->get_number( '/string' )
      exp = 0 ). " Hmmmm ????

    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->get_number( '/number' )
      exp = +'123.0' ).

    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->get_number( '/float' )
      exp = +'123.45' ).

  endmethod.

  method value_boolean.

    data lo_cut type ref to z2ui5_if_ajson.
    lo_cut ?= z2ui5_cl_ajson=>parse( ltcl_parser_test=>sample_json( ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->get_boolean( '/string' )
      exp = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->get_boolean( '/number' )
      exp = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->get_boolean( '/xxx' )
      exp = abap_false ).

    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->get_boolean( '/boolean' )
      exp = abap_true ).

  endmethod.

  method value_string.

    data lo_cut type ref to z2ui5_if_ajson.
    lo_cut ?= z2ui5_cl_ajson=>parse( ltcl_parser_test=>sample_json( ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->get_string( '/string' )
      exp = 'abc' ).

    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->get_string( '/number' )
      exp = '123' ).

    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->get_string( '/xxx' )
      exp = '' ).

    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->get_string( '/boolean' )
      exp = 'true' ).

  endmethod.

  method members.

    data lt_exp type string_table.
    data lo_cut type ref to z2ui5_if_ajson.
    lo_cut ?= z2ui5_cl_ajson=>parse( ltcl_parser_test=>sample_json( ) ).

    clear lt_exp.
    append '1' to lt_exp.
    append '2' to lt_exp.
    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->members( '/issues' )
      exp = lt_exp ).

    clear lt_exp.
    append 'col' to lt_exp.
    append 'row' to lt_exp.
    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->members( '/issues/1/start/' )
      exp = lt_exp ).

  endmethod.

  method array_to_string_table.

    data lo_cut type ref to z2ui5_cl_ajson.
    data lo_nodes type ref to lcl_nodes_helper.
    data lt_act type string_table.
    data lt_exp type string_table.

    create object lo_nodes.
    lo_nodes->add( '  |         |array  |                        | |6' ).
    lo_nodes->add( '/ |1        |num    |123                     |1|0' ).
    lo_nodes->add( '/ |2        |num    |234                     |2|0' ).
    lo_nodes->add( '/ |3        |str    |abc                     |3|0' ).
    lo_nodes->add( '/ |4        |bool   |true                    |4|0' ).
    lo_nodes->add( '/ |5        |bool   |false                   |5|0' ).
    lo_nodes->add( '/ |6        |null   |null                    |6|0' ).

    append '123' to lt_exp.
    append '234' to lt_exp.
    append 'abc' to lt_exp.
    append 'X' to lt_exp.
    append '' to lt_exp.
    append '' to lt_exp.

    create object lo_cut.
    lo_cut->mt_json_tree = lo_nodes->mt_nodes.

    lt_act = lo_cut->z2ui5_if_ajson~array_to_string_table( '/' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_act
      exp = lt_exp ).

    " negative
    data lx type ref to z2UI5_cx_ajson_error.

    create object lo_nodes.
    lo_nodes->add( '  |         |object |                        | |1' ).
    lo_nodes->add( '/ |a        |str    |abc                     | |0' ).
    lo_cut->mt_json_tree = lo_nodes->mt_nodes.

    try.
      lo_cut->z2ui5_if_ajson~array_to_string_table( '/x' ).
      cl_abap_unit_assert=>fail( ).
    catch z2UI5_cx_ajson_error into lx.
      cl_abap_unit_assert=>assert_equals(
        act = lx->message
        exp = 'Path not found: /x' ).
    endtry.

    try.
      lo_cut->z2ui5_if_ajson~array_to_string_table( '/' ).
      cl_abap_unit_assert=>fail( ).
    catch z2UI5_cx_ajson_error into lx.
      cl_abap_unit_assert=>assert_equals(
        act = lx->message
        exp = 'Array expected at: /' ).
    endtry.

    try.
      lo_cut->z2ui5_if_ajson~array_to_string_table( '/a' ).
      cl_abap_unit_assert=>fail( ).
    catch z2UI5_cx_ajson_error into lx.
      cl_abap_unit_assert=>assert_equals(
        act = lx->message
        exp = 'Array expected at: /a' ).
    endtry.

    create object lo_nodes.
    lo_nodes->add( '  |         |array  |                        | |1' ).
    lo_nodes->add( '/ |1        |object |                        |1|0' ).
    lo_cut->mt_json_tree = lo_nodes->mt_nodes.

    try.
      lo_cut->z2ui5_if_ajson~array_to_string_table( '/' ).
      cl_abap_unit_assert=>fail( ).
    catch z2UI5_cx_ajson_error into lx.
      cl_abap_unit_assert=>assert_equals(
        act = lx->message
        exp = 'Cannot convert [object] to string at [/1]' ).
    endtry.

  endmethod.

endclass.


**********************************************************************
* JSON TO ABAP
**********************************************************************

class ltcl_json_to_abap definition
  for testing
  risk level harmless
  duration short
  final.

  private section.

    types:
      begin of ty_struc,
        a type string,
        b type i,
      end of ty_struc,
      tty_struc type standard table of ty_struc with key a,
      tty_struc_sorted type sorted table of ty_struc with unique key a,
      tty_struc_hashed type hashed table of ty_struc with unique key a,
      begin of ty_complex,
        str   type string,
        int   type i,
        float type f,
        bool  type abap_bool,
        obj   type ty_struc,
        tab   type tty_struc,
        tab_plain  type string_table,
        tab_hashed type tty_struc_hashed,
        oref  type ref to object,
        date1 type d,
        date2 type d,
        timestamp1 type timestamp,
        timestamp2 type timestamp,
        timestamp3 type timestamp,
      end of ty_complex.

    methods to_abap_struc
      for testing
      raising z2UI5_cx_ajson_error.
    methods to_abap_timestamp_initial
      for testing
      raising z2UI5_cx_ajson_error.
    methods to_abap_value
      for testing
      raising z2UI5_cx_ajson_error.
    methods to_abap_array
      for testing
      raising z2UI5_cx_ajson_error.
    methods to_abap_array_of_arrays_simple
      for testing
      raising z2UI5_cx_ajson_error.
    methods to_abap_array_of_arrays
      for testing
      raising z2UI5_cx_ajson_error.
    methods to_abap_w_tab_of_struc
      for testing
      raising z2UI5_cx_ajson_error.
    methods to_abap_w_plain_tab
      for testing
      raising z2UI5_cx_ajson_error.
    methods to_abap_hashed_tab
      for testing
      raising z2UI5_cx_ajson_error.
    methods to_abap_sorted_tab
      for testing
      raising z2UI5_cx_ajson_error.
    methods to_abap_hashed_plain_tab
      for testing
      raising z2UI5_cx_ajson_error.
    methods to_abap_negative
      for testing
      raising z2UI5_cx_ajson_error.
    methods to_abap_corresponding
      for testing
      raising z2UI5_cx_ajson_error.
    methods to_abap_corresponding_negative
      for testing
      raising z2UI5_cx_ajson_error.
    methods to_abap_corresponding_public
      for testing
      raising z2UI5_cx_ajson_error.
    methods to_abap_corresponding_pub_neg
      for testing
      raising z2UI5_cx_ajson_error.

endclass.

class z2ui5_cl_ajson definition local friends ltcl_json_to_abap.

class ltcl_json_to_abap implementation.

  method to_abap_struc.

    data lo_cut type ref to lcl_json_to_abap.
    data ls_mock type ty_complex.
    data ls_exp  type ty_complex.
    data lv_exp_date type d value '20200728'.
    data lv_exp_timestamp type timestamp value '20200728000000'.
    data lo_nodes type ref to lcl_nodes_helper.

    create object lo_nodes.
    lo_nodes->add( '       |           |object |                          | ' ).
    lo_nodes->add( '/      |str        |str    |hello                     | ' ).
    lo_nodes->add( '/      |int        |num    |5                         | ' ).
    lo_nodes->add( '/      |float      |num    |5.5                       | ' ).
    lo_nodes->add( '/      |bool       |bool   |true                      | ' ).
    lo_nodes->add( '/      |obj        |object |                          | ' ).
    lo_nodes->add( '/obj/  |a          |str    |world                     | ' ).
    lo_nodes->add( '/      |tab        |array  |                          | ' ).
    lo_nodes->add( '/      |date1      |str    |2020-07-28                | ' ).
    lo_nodes->add( '/      |date2      |str    |2020-07-28T00:00:00Z      | ' ).
    lo_nodes->add( '/      |timestamp1 |str    |2020-07-28T00:00:00       | ' ).
    lo_nodes->add( '/      |timestamp2 |str    |2020-07-28T00:00:00Z      | ' ).
    lo_nodes->add( '/      |timestamp3 |str    |2020-07-28T01:00:00+01:00 | ' ).

    create object lo_cut.
    lo_cut->to_abap(
      exporting
        it_nodes    = lo_nodes->sorted( )
      changing
        c_container = ls_mock ).

    ls_exp-str        = 'hello'.
    ls_exp-int        = 5.
    ls_exp-float      = '5.5'.
    ls_exp-bool       = abap_true.
    ls_exp-obj-a      = 'world'.
    ls_exp-date1      = lv_exp_date.
    ls_exp-date2      = lv_exp_date.
    ls_exp-timestamp1 = lv_exp_timestamp.
    ls_exp-timestamp2 = lv_exp_timestamp.
    ls_exp-timestamp3 = lv_exp_timestamp.

    cl_abap_unit_assert=>assert_equals(
      act = ls_mock
      exp = ls_exp ).

  endmethod.

  method to_abap_timestamp_initial.

    data lo_cut type ref to lcl_json_to_abap.
    data lv_mock type timestamp.
    data lo_nodes type ref to lcl_nodes_helper.

    create object lo_nodes.
    lo_nodes->add( '       |           |str    |0000-00-00T00:00:00Z| ' ).

    create object lo_cut.
    lo_cut->to_abap(
      exporting
        it_nodes    = lo_nodes->sorted( )
      changing
        c_container = lv_mock ).

    cl_abap_unit_assert=>assert_equals(
      act = lv_mock
      exp = 0 ).

  endmethod.

  method to_abap_value.

    data lo_cut type ref to lcl_json_to_abap.
    data lv_mock type string.
    data lo_nodes type ref to lcl_nodes_helper.

    create object lo_nodes.
    lo_nodes->add( '       |           |str    |hello                     | ' ).

    create object lo_cut.
    lo_cut->to_abap(
      exporting
        it_nodes    = lo_nodes->sorted( )
      changing
        c_container = lv_mock ).

    cl_abap_unit_assert=>assert_equals(
      act = lv_mock
      exp = 'hello' ).

  endmethod.

  method to_abap_array.

    data lo_cut type ref to lcl_json_to_abap.
    data lt_mock type string_table.
    data lt_exp type string_table.
    data lo_nodes type ref to lcl_nodes_helper.

    create object lo_nodes.
    lo_nodes->add( '       |           |array    |                     | ' ).
    lo_nodes->add( '/      |1          |str      |One                  |1' ).
    lo_nodes->add( '/      |2          |str      |Two                  |2' ).

    create object lo_cut.
    lo_cut->to_abap(
      exporting
        it_nodes    = lo_nodes->sorted( )
      changing
        c_container = lt_mock ).

    append 'One' to lt_exp.
    append 'Two' to lt_exp.

    cl_abap_unit_assert=>assert_equals(
      act = lt_mock
      exp = lt_exp ).

  endmethod.

  method to_abap_array_of_arrays_simple.

    data lo_cut   type ref to lcl_json_to_abap.
    data lt_mock  type table of string_table.
    data lt_exp   type table of string_table.
    data lt_tmp   type string_table.
    data lo_nodes type ref to lcl_nodes_helper.

    create object lo_nodes.
    lo_nodes->add( '       |           |array    |                    | ' ).
    lo_nodes->add( '/      |1          |array    |                    |1' ).
    lo_nodes->add( '/      |2          |array    |                    |2' ).
    lo_nodes->add( '/1/    |1          |str      |One                 |1' ).
    lo_nodes->add( '/2/    |1          |str      |Two                 |1' ).

    create object lo_cut.
    lo_cut->to_abap(
      exporting
        it_nodes    = lo_nodes->sorted( )
      changing
        c_container = lt_mock ).

    append 'One' to lt_tmp.
    append lt_tmp to lt_exp.
    clear lt_tmp.
    append 'Two' to lt_tmp.
    append lt_tmp to lt_exp.

    cl_abap_unit_assert=>assert_equals(
      act = lt_mock
      exp = lt_exp ).

  endmethod.

  method to_abap_array_of_arrays.

    data lo_cut   type ref to lcl_json_to_abap.
    data lt_mock  type table of string_table.
    data lt_exp   type table of string_table.
    data lt_tmp   type string_table.
    data lo_nodes type ref to lcl_nodes_helper.

    create object lo_nodes.
    lo_nodes->add( '       |           |array    |                    | ' ).
    lo_nodes->add( '/      |1          |array    |                    |1' ).
    lo_nodes->add( '/      |2          |array    |                    |2' ).
    lo_nodes->add( '/1/    |1          |str      |One                 |1' ).
    lo_nodes->add( '/1/    |2          |str      |Two                 |2' ).
    lo_nodes->add( '/2/    |1          |str      |Three               |1' ).
    lo_nodes->add( '/2/    |2          |str      |Four                |2' ).

    create object lo_cut.
    lo_cut->to_abap(
      exporting
        it_nodes    = lo_nodes->sorted( )
      changing
        c_container = lt_mock ).

    append 'One' to lt_tmp.
    append 'Two' to lt_tmp.
    append lt_tmp to lt_exp.
    clear lt_tmp.
    append 'Three' to lt_tmp.
    append 'Four' to lt_tmp.
    append lt_tmp to lt_exp.

    cl_abap_unit_assert=>assert_equals(
      act = lt_mock
      exp = lt_exp ).

  endmethod.

  method to_abap_w_tab_of_struc.

    data lo_cut type ref to lcl_json_to_abap.
    data ls_mock type ty_complex.
    data ls_exp  type ty_complex.
    data lo_nodes type ref to lcl_nodes_helper.

    create object lo_nodes.
    lo_nodes->add( '       |           |object |                          | ' ).
    lo_nodes->add( '/      |tab        |array  |                          | ' ).
    lo_nodes->add( '/tab/  |1          |object |                          |1' ).
    lo_nodes->add( '/tab/1/|a          |str    |One                       | ' ).
    lo_nodes->add( '/tab/  |2          |object |                          |2' ).
    lo_nodes->add( '/tab/2/|a          |str    |Two                       | ' ).

    create object lo_cut.
    lo_cut->to_abap(
      exporting
        it_nodes    = lo_nodes->sorted( )
      changing
        c_container = ls_mock ).

    data ls_elem like line of ls_exp-tab.
    ls_elem-a = 'One'.
    append ls_elem to ls_exp-tab.
    ls_elem-a = 'Two'.
    append ls_elem to ls_exp-tab.

    cl_abap_unit_assert=>assert_equals(
      act = ls_mock
      exp = ls_exp ).

  endmethod.

  method to_abap_w_plain_tab.

    data lo_cut type ref to lcl_json_to_abap.
    data ls_mock type ty_complex.
    data ls_exp  type ty_complex.
    data lo_nodes type ref to lcl_nodes_helper.

    create object lo_nodes.
    lo_nodes->add( '             |           |object |                          | ' ).
    lo_nodes->add( '/            |tab_plain  |array  |                          | ' ).
    lo_nodes->add( '/tab_plain/  |1          |str    |One                       |1' ).
    lo_nodes->add( '/tab_plain/  |2          |str    |Two                       |2' ).

    create object lo_cut.
    lo_cut->to_abap(
      exporting
        it_nodes    = lo_nodes->sorted( )
      changing
        c_container = ls_mock ).

    append 'One' to ls_exp-tab_plain.
    append 'Two' to ls_exp-tab_plain.

    cl_abap_unit_assert=>assert_equals(
      act = ls_mock
      exp = ls_exp ).

  endmethod.

  method to_abap_hashed_plain_tab.

    data lo_cut type ref to lcl_json_to_abap.
    data lt_mock type hashed table of string with unique key table_line.
    data lt_exp  type hashed table of string with unique key table_line.

    data lo_nodes type ref to lcl_nodes_helper.
    create object lo_nodes.
    lo_nodes->add( '            |           |array  |                          | ' ).
    lo_nodes->add( '/           |1          |str    |One                       |1' ).
    lo_nodes->add( '/           |2          |str    |Two                       |2' ).

    create object lo_cut.
    lo_cut->to_abap(
      exporting
        it_nodes    = lo_nodes->sorted( )
      changing
        c_container = lt_mock ).

    insert `One` into table lt_exp.
    insert `Two` into table lt_exp.

    cl_abap_unit_assert=>assert_equals(
      act = lt_mock
      exp = lt_exp ).

  endmethod.

  method to_abap_hashed_tab.

    data lo_cut type ref to lcl_json_to_abap.
    data lt_mock type tty_struc_hashed.
    data lt_exp  type tty_struc_hashed.

    data lo_nodes type ref to lcl_nodes_helper.
    create object lo_nodes.
    lo_nodes->add( '              |           |array  |                          | ' ).
    lo_nodes->add( '/             |1          |object |                          |1' ).
    lo_nodes->add( '/             |2          |object |                          |2' ).
    lo_nodes->add( '/1/           |a          |str    |One                       | ' ).
    lo_nodes->add( '/1/           |b          |num    |1                         | ' ).
    lo_nodes->add( '/2/           |a          |str    |Two                       | ' ).
    lo_nodes->add( '/2/           |b          |num    |2                         | ' ).

    create object lo_cut.
    lo_cut->to_abap(
      exporting
        it_nodes    = lo_nodes->sorted( )
      changing
        c_container = lt_mock ).

    data ls_elem like line of lt_exp.
    ls_elem-a = 'One'.
    ls_elem-b = 1.
    insert ls_elem into table lt_exp.
    ls_elem-a = 'Two'.
    ls_elem-b = 2.
    insert ls_elem into table lt_exp.

    cl_abap_unit_assert=>assert_equals(
      act = lt_mock
      exp = lt_exp ).

  endmethod.

  method to_abap_sorted_tab.

    data lo_cut type ref to lcl_json_to_abap.
    data lt_mock type tty_struc_sorted.
    data lt_exp  type tty_struc_sorted.

    data lo_nodes type ref to lcl_nodes_helper.
    create object lo_nodes.
    lo_nodes->add( '              |           |array  |                          | ' ).
    lo_nodes->add( '/             |1          |object |                          |1' ).
    lo_nodes->add( '/             |2          |object |                          |2' ).
    lo_nodes->add( '/1/           |a          |str    |One                       | ' ).
    lo_nodes->add( '/1/           |b          |num    |1                         | ' ).
    lo_nodes->add( '/2/           |a          |str    |Two                       | ' ).
    lo_nodes->add( '/2/           |b          |num    |2                         | ' ).

    create object lo_cut.
    lo_cut->to_abap(
      exporting
        it_nodes    = lo_nodes->sorted( )
      changing
        c_container = lt_mock ).

    data ls_elem like line of lt_exp.
    ls_elem-a = 'One'.
    ls_elem-b = 1.
    insert ls_elem into table lt_exp.
    ls_elem-a = 'Two'.
    ls_elem-b = 2.
    insert ls_elem into table lt_exp.

    cl_abap_unit_assert=>assert_equals(
      act = lt_mock
      exp = lt_exp ).

  endmethod.

  method to_abap_negative.

    data lo_cut type ref to lcl_json_to_abap.
    data lx type ref to z2UI5_cx_ajson_error.
    data ls_mock type ty_complex.

    create object lo_cut.

    data lo_nodes type ref to lcl_nodes_helper.

    try.
      create object lo_nodes.
      lo_nodes->add( '     |      |object | ' ).
      lo_nodes->add( '/    |str   |object | ' ).

      lo_cut->to_abap(
        exporting
          it_nodes    = lo_nodes->sorted( )
        changing
          c_container = ls_mock ).
      cl_abap_unit_assert=>fail( ).
    catch z2UI5_cx_ajson_error into lx.
      cl_abap_unit_assert=>assert_equals(
        act = lx->message
        exp = 'Expected structure' ).
    endtry.

    try.
      create object lo_nodes.
      lo_nodes->add( '     |      |object | ' ).
      lo_nodes->add( '/    |str   |array  | ' ).

      lo_cut->to_abap(
        exporting
          it_nodes    = lo_nodes->sorted( )
        changing
          c_container = ls_mock ).
      cl_abap_unit_assert=>fail( ).
    catch z2UI5_cx_ajson_error into lx.
      cl_abap_unit_assert=>assert_equals(
        act = lx->message
        exp = 'Expected table' ).
    endtry.

    try.
      create object lo_nodes.
      lo_nodes->add( '     |      |object |      ' ).
      lo_nodes->add( '/    |int   |str    |hello ' ).

      lo_cut->to_abap(
        exporting
          it_nodes    = lo_nodes->sorted( )
        changing
          c_container = ls_mock ).
      cl_abap_unit_assert=>fail( ).
    catch z2UI5_cx_ajson_error into lx.
      cl_abap_unit_assert=>assert_equals(
        act = lx->message
        exp = 'Source is not a number' ).
    endtry.

    try.
      create object lo_nodes.
      lo_nodes->add( '     |      |object |        ' ).
      lo_nodes->add( '/    |date1 |str    |baddate ' ).

      lo_cut->to_abap(
        exporting
          it_nodes    = lo_nodes->sorted( )
        changing
          c_container = ls_mock ).
      cl_abap_unit_assert=>fail( ).
    catch z2UI5_cx_ajson_error into lx.
      cl_abap_unit_assert=>assert_equals(
        act = lx->message
        exp = 'Unexpected date format' ).
    endtry.

    try.
      create object lo_nodes.
      lo_nodes->add( '    |        |object |        ' ).
      lo_nodes->add( '/   |missing |str    |123     ' ).

      lo_cut->to_abap(
        exporting
          it_nodes    = lo_nodes->sorted( )
        changing
          c_container = ls_mock ).
      cl_abap_unit_assert=>fail( ).
    catch z2UI5_cx_ajson_error into lx.
      cl_abap_unit_assert=>assert_equals(
        act = lx->message
        exp = 'Path not found' ).
    endtry.

    try.
      data lt_str type string_table.
      create object lo_nodes.
      lo_nodes->add( '      |     |array  |      | ' ).
      lo_nodes->add( '/     |a    |str    |hello |1' ).

      lo_cut->to_abap(
        exporting
          it_nodes    = lo_nodes->sorted( )
        changing
          c_container = lt_str ).
      cl_abap_unit_assert=>fail( ).
    catch z2UI5_cx_ajson_error into lx.
      cl_abap_unit_assert=>assert_equals(
        act = lx->message
        exp = 'Need index to access tables' ).
    endtry.

    try.
      data lr_obj type ref to object.
      create object lo_nodes.
      lo_nodes->add( '      |     |str  |hello      | ' ).

      lo_cut->to_abap(
        exporting
          it_nodes    = lo_nodes->sorted( )
        changing
          c_container = lr_obj ).
      cl_abap_unit_assert=>fail( ).
    catch z2UI5_cx_ajson_error into lx.
      cl_abap_unit_assert=>assert_equals(
        act = lx->message
        exp = 'Cannot assign to ref' ).
    endtry.

    try.
      data lr_data type ref to data.
      create object lo_nodes.
      lo_nodes->add( '      |     |str  |hello      | ' ).

      lo_cut->to_abap(
        exporting
          it_nodes    = lo_nodes->sorted( )
        changing
          c_container = lr_data ).
      cl_abap_unit_assert=>fail( ).
    catch z2UI5_cx_ajson_error into lx.
      cl_abap_unit_assert=>assert_equals(
        act = lx->message
        exp = 'Cannot assign to ref' ).
    endtry.

    try.
      data lt_hashed type hashed table of string with unique key table_line.
      create object lo_nodes.
      lo_nodes->add( '            |           |array  |                          | ' ).
      lo_nodes->add( '/           |1          |str    |One                       |1' ).
      lo_nodes->add( '/           |2          |str    |One                       |2' ).

      lo_cut->to_abap(
        exporting
          it_nodes    = lo_nodes->sorted( )
        changing
          c_container = lt_hashed ).
      cl_abap_unit_assert=>fail( ).
    catch z2UI5_cx_ajson_error into lx.
      cl_abap_unit_assert=>assert_equals(
        act = lx->message
        exp = 'Duplicate insertion' ).
    endtry.

  endmethod.

  method to_abap_corresponding.

    data lo_cut type ref to lcl_json_to_abap.
    data ls_act type ty_struc.
    data ls_exp  type ty_struc.
    data lo_nodes type ref to lcl_nodes_helper.

    create object lo_nodes.
    lo_nodes->add( '       |           |object |                          | ' ).
    lo_nodes->add( '/      |a          |str    |test                      | ' ).
    lo_nodes->add( '/      |c          |num    |24022022                  | ' ).

    ls_exp-a  = 'test'.

    create object lo_cut
      exporting
        iv_corresponding = abap_true.

    lo_cut->to_abap(
      exporting
        it_nodes    = lo_nodes->sorted( )
      changing
        c_container = ls_act ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_act
      exp = ls_exp ).

  endmethod.

  method to_abap_corresponding_negative.

    data lo_cut type ref to lcl_json_to_abap.
    data ls_act type ty_struc.
    data ls_exp  type ty_struc.
    data lo_nodes type ref to lcl_nodes_helper.
    data lx type ref to z2UI5_cx_ajson_error.

    create object lo_nodes.
    lo_nodes->add( '       |           |object |                          | ' ).
    lo_nodes->add( '/      |a          |str    |test                      | ' ).
    lo_nodes->add( '/      |c          |num    |24022022                  | ' ).

    ls_exp-a  = 'test'.
    ls_exp-b  = 24022022.

    try.
      create object lo_cut.
      lo_cut->to_abap(
        exporting
          it_nodes    = lo_nodes->sorted( )
        changing
          c_container = ls_act ).
      cl_abap_unit_assert=>fail( ).
    catch z2UI5_cx_ajson_error into lx.
      cl_abap_unit_assert=>assert_equals(
        act = lx->message
        exp = 'Path not found' ).
    endtry.

  endmethod.

  method to_abap_corresponding_public.

    data lo_cut type ref to z2ui5_cl_ajson.
    data ls_act type ty_struc.
    data ls_exp  type ty_struc.
    data li_json type ref to z2ui5_if_ajson.
    data lo_nodes type ref to lcl_nodes_helper.

    create object lo_nodes.
    lo_nodes->add( '       |           |object |                          | ' ).
    lo_nodes->add( '/      |a          |str    |test                      | ' ).
    lo_nodes->add( '/      |c          |num    |24022022                  | ' ).

    ls_exp-a  = 'test'.

    create object lo_cut.
    lo_cut->mt_json_tree = lo_nodes->mt_nodes.

    lo_cut->to_abap(
      exporting
        iv_corresponding = abap_true
      importing
        ev_container     = ls_act ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_act
      exp = ls_exp ).

    clear ls_act.
    li_json = lo_cut->to_abap_corresponding_only( ).
    li_json->to_abap( importing ev_container = ls_act ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_act
      exp = ls_exp ).

  endmethod.


  method to_abap_corresponding_pub_neg.

    data lo_cut type ref to z2ui5_cl_ajson.
    data ls_act type ty_struc.
    data ls_exp  type ty_struc.
    data lo_nodes type ref to lcl_nodes_helper.
    data lx type ref to z2UI5_cx_ajson_error.

    create object lo_nodes.
    lo_nodes->add( '       |           |object |                          | ' ).
    lo_nodes->add( '/      |a          |str    |test                      | ' ).
    lo_nodes->add( '/      |c          |num    |24022022                  | ' ).

    ls_exp-a  = 'test'.

    create object lo_cut.
    lo_cut->mt_json_tree = lo_nodes->mt_nodes.

    try.
      lo_cut->to_abap( importing ev_container = ls_act ).

      cl_abap_unit_assert=>fail( ).
    catch z2UI5_cx_ajson_error into lx.
      cl_abap_unit_assert=>assert_equals(
        act = lx->message
        exp = 'Path not found' ).
    endtry.

  endmethod.

endclass.

**********************************************************************
* WRITER
**********************************************************************

class ltcl_writer_test definition final
  for testing
  risk level harmless
  duration short.

  private section.

    methods set_ajson for testing raising z2UI5_cx_ajson_error.
    methods set_value for testing raising z2UI5_cx_ajson_error.
    methods ignore_empty for testing raising z2UI5_cx_ajson_error.
    methods set_obj for testing raising z2UI5_cx_ajson_error.
    methods set_obj_w_date_time for testing raising z2UI5_cx_ajson_error.
    methods set_tab for testing raising z2UI5_cx_ajson_error.
    methods set_tab_hashed for testing raising z2UI5_cx_ajson_error.
    methods set_tab_nested_struct for testing raising z2UI5_cx_ajson_error.
    methods prove_path_exists for testing raising z2UI5_cx_ajson_error.
    methods delete_subtree for testing raising z2UI5_cx_ajson_error.
    methods delete for testing raising z2UI5_cx_ajson_error.
    methods arrays for testing raising z2UI5_cx_ajson_error.
    methods arrays_negative for testing raising z2UI5_cx_ajson_error.
    methods root_assignment for testing raising z2UI5_cx_ajson_error.
    methods set_bool_abap_bool for testing raising z2UI5_cx_ajson_error.
    methods set_bool_int for testing raising z2UI5_cx_ajson_error.
    methods set_bool_tab for testing raising z2UI5_cx_ajson_error.
    methods set_str for testing raising z2UI5_cx_ajson_error.
    methods set_int for testing raising z2UI5_cx_ajson_error.
    methods set_date for testing raising z2UI5_cx_ajson_error.
    methods set_timestamp for testing raising z2UI5_cx_ajson_error.
    methods read_only for testing raising z2UI5_cx_ajson_error.
    methods set_array_obj for testing raising z2UI5_cx_ajson_error.
    methods set_with_type for testing raising z2UI5_cx_ajson_error.
    methods overwrite_w_keep_order_touch for testing raising z2UI5_cx_ajson_error.
    methods overwrite_w_keep_order_set for testing raising z2UI5_cx_ajson_error.
    methods setx for testing raising z2UI5_cx_ajson_error.
    methods setx_float for testing raising z2UI5_cx_ajson_error.
    methods setx_complex for testing raising z2UI5_cx_ajson_error.
    methods setx_complex_w_keep_order for testing raising z2UI5_cx_ajson_error.

    methods set_with_type_slice
      importing
        io_json_in type ref to z2ui5_cl_ajson
        io_json_out type ref to z2ui5_if_ajson
        iv_path type string
      raising
        z2UI5_cx_ajson_error.

endclass.

class z2ui5_cl_ajson definition local friends ltcl_writer_test.

class ltcl_writer_test implementation.

  method prove_path_exists.

    data lo_cut type ref to z2ui5_cl_ajson.
    data lo_nodes_exp type ref to lcl_nodes_helper.

    lo_cut = z2ui5_cl_ajson=>create_empty( ).

    create object lo_nodes_exp.
    lo_nodes_exp->add( '        |      |object |     ||1' ).
    lo_nodes_exp->add( '/       |a     |object |     ||1' ).
    lo_nodes_exp->add( '/a/     |b     |object |     ||1' ).
    lo_nodes_exp->add( '/a/b/   |c     |object |     ||1' ).
    lo_nodes_exp->add( '/a/b/c/ |d     |object |     ||0' ).

    lo_cut->prove_path_exists( '/a/b/c/d/' ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->mt_json_tree
      exp = lo_nodes_exp->sorted( ) ).

    create object lo_nodes_exp.
    lo_nodes_exp->add( '         |      |object |     ||1' ).
    lo_nodes_exp->add( '/        |a     |object |     ||1' ).
    lo_nodes_exp->add( '/a/      |b     |object |     ||1' ).
    lo_nodes_exp->add( '/a/b/    |c     |object |     ||1' ).
    lo_nodes_exp->add( '/a/b/c/  |d     |object |     ||1' ).
    lo_nodes_exp->add( '/a/b/c/d |e     |object |     ||0' ).
    lo_cut->prove_path_exists( '/a/b/c/d/e/' ).

  endmethod.

  method delete_subtree.

    data lo_cut type ref to z2ui5_cl_ajson.
    data lo_nodes_exp type ref to lcl_nodes_helper.

    lo_cut = z2ui5_cl_ajson=>create_empty( ).

    create object lo_nodes_exp.
    lo_nodes_exp->add( '        |      |object |     ||1' ).
    lo_nodes_exp->add( '/       |a     |object |     ||1' ).
    lo_nodes_exp->add( '/a/     |b     |object |     ||1' ).
    lo_nodes_exp->add( '/a/b/   |c     |object |     ||1' ).
    lo_nodes_exp->add( '/a/b/c/ |d     |object |     ||0' ).

    lo_cut->mt_json_tree = lo_nodes_exp->mt_nodes.

    create object lo_nodes_exp.
    lo_nodes_exp->add( '        |      |object |     ||1' ).
    lo_nodes_exp->add( '/       |a     |object |     ||0' ).

    lo_cut->delete_subtree(
      iv_path = '/a/'
      iv_name = 'b' ).

    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->mt_json_tree
      exp = lo_nodes_exp->sorted( ) ).

  endmethod.

  method delete.

    data lo_cut type ref to z2ui5_cl_ajson.
    data lo_nodes_exp type ref to lcl_nodes_helper.

    lo_cut = z2ui5_cl_ajson=>create_empty( ).

    create object lo_nodes_exp.
    lo_nodes_exp->add( '        |      |object |     ||1' ).
    lo_nodes_exp->add( '/       |a     |object |     ||1' ).
    lo_nodes_exp->add( '/a/     |b     |object |     ||1' ).
    lo_nodes_exp->add( '/a/b/   |c     |object |     ||1' ).
    lo_nodes_exp->add( '/a/b/c/ |d     |object |     ||0' ).

    lo_cut->mt_json_tree = lo_nodes_exp->mt_nodes.

    create object lo_nodes_exp.
    lo_nodes_exp->add( '        |      |object |     ||1' ).
    lo_nodes_exp->add( '/       |a     |object |     ||0' ).

    lo_cut->z2ui5_if_ajson~delete( iv_path = '/a/b' ).

    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->mt_json_tree
      exp = lo_nodes_exp->sorted( ) ).

    create object lo_nodes_exp.
    lo_nodes_exp->add( '        |      |object |     ||1' ).
    lo_nodes_exp->add( '/       |a     |object |     ||1' ).
    lo_nodes_exp->add( '/a/     |b     |object |     ||1' ).
    lo_nodes_exp->add( '/a/b/   |c     |object |     ||1' ).
    lo_nodes_exp->add( '/a/b/c/ |d     |object |     ||0' ).

    lo_cut->mt_json_tree = lo_nodes_exp->mt_nodes.

    create object lo_nodes_exp.
    lo_nodes_exp->add( '        |      |object |     ||1' ).
    lo_nodes_exp->add( '/       |a     |object |     ||0' ).

    lo_cut->z2ui5_if_ajson~delete( iv_path = '/a/b/' ).

    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->mt_json_tree
      exp = lo_nodes_exp->sorted( ) ).

  endmethod.

  method set_ajson.

    data lo_nodes type ref to lcl_nodes_helper.
    data lo_src type ref to z2ui5_cl_ajson.
    data lo_cut type ref to z2ui5_cl_ajson.
    data li_writer type ref to z2ui5_if_ajson.

    lo_src = z2ui5_cl_ajson=>create_empty( ).
    lo_cut = z2ui5_cl_ajson=>create_empty( ).
    li_writer = lo_cut.

    " Prepare source
    create object lo_nodes.
    lo_nodes->add( '        |      |object |     ||1' ).
    lo_nodes->add( '/       |x     |object |     ||2' ).
    lo_nodes->add( '/x/     |b     |str    |abc  ||0' ).
    lo_nodes->add( '/x/     |c     |num    |10   ||0' ).
    lo_src->mt_json_tree = lo_nodes->mt_nodes.

    " Test 1 - assign root
    li_writer->set(
      iv_path = ''
      iv_val  = lo_src ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->mt_json_tree
      exp = lo_nodes->sorted( ) ).

    li_writer->set(
      iv_path = '/'
      iv_val  = lo_src ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->mt_json_tree
      exp = lo_nodes->sorted( ) ).

    " Test 2 - assign deep
    create object lo_nodes.
    lo_nodes->add( '        |      |object |     ||1' ).
    lo_nodes->add( '/       |a     |object |     ||1' ).
    lo_nodes->add( '/a/     |b     |object |     ||1' ).
    lo_nodes->add( '/a/b/     |c     |object |     ||1' ).
    lo_nodes->add( '/a/b/c/   |x     |object |     ||2' ).
    lo_nodes->add( '/a/b/c/x/ |b     |str    |abc  ||0' ).
    lo_nodes->add( '/a/b/c/x/ |c     |num    |10   ||0' ).

    li_writer->clear( ).
    li_writer->set(
      iv_path = '/a/b/c'
      iv_val  = lo_src ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->mt_json_tree
      exp = lo_nodes->sorted( ) ).

    " Test 3 - assign rewrite
    create object lo_nodes.
    lo_nodes->add( '        |      |object |     ||1' ).
    lo_nodes->add( '/       |a     |object |     ||1' ).
    lo_nodes->add( '/a/       |b     |object |     ||1' ).
    lo_nodes->add( '/a/b/     |x     |object |     ||2' ).
    lo_nodes->add( '/a/b/x/   |b     |str    |abc  ||0' ).
    lo_nodes->add( '/a/b/x/   |c     |num    |10   ||0' ).

    li_writer->set(
      iv_path = '/a/b'
      iv_val  = lo_src ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->mt_json_tree
      exp = lo_nodes->sorted( ) ).

  endmethod.

  method set_value.

    data lo_nodes type ref to lcl_nodes_helper.
    data lo_cut type ref to z2ui5_cl_ajson.
    data li_writer type ref to z2ui5_if_ajson.

    lo_cut = z2ui5_cl_ajson=>create_empty( ).
    li_writer = lo_cut.

    " Prepare source
    create object lo_nodes.
    lo_nodes->add( '        |      |object |     ||1' ).
    lo_nodes->add( '/       |x     |object |     ||2' ).
    lo_nodes->add( '/x/     |b     |str    |abc  ||0' ).
    lo_nodes->add( '/x/     |c     |num    |10   ||0' ).

    li_writer->set(
      iv_path = '/x/b'
      iv_val  = 'abc' ).
    li_writer->set(
      iv_path = '/x/c'
      iv_val  = 10 ).
    li_writer->set( " ignore empty
      iv_path = '/x/d'
      iv_val  = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->mt_json_tree
      exp = lo_nodes->sorted( ) ).

  endmethod.

  method ignore_empty.

    data lo_nodes type ref to lcl_nodes_helper.
    data li_cut type ref to z2ui5_if_ajson.

    li_cut = z2ui5_cl_ajson=>create_empty( ).

    create object lo_nodes.
    lo_nodes->add( '        |      |object |     ||1' ).
    lo_nodes->add( '/       |a     |num    |1    ||0' ).

    li_cut->set(
      iv_path = '/a'
      iv_val  = 1 ).
    li_cut->set( " ignore empty
      iv_path = '/b'
      iv_val  = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = li_cut->mt_json_tree
      exp = lo_nodes->sorted( ) ).

    create object lo_nodes.
    lo_nodes->add( '        |      |object |     ||2' ).
    lo_nodes->add( '/       |a     |num    |1    ||0' ).
    lo_nodes->add( '/       |b     |num    |0    ||0' ).

    li_cut->set(
      iv_ignore_empty = abap_false
      iv_path = '/b'
      iv_val  = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = li_cut->mt_json_tree
      exp = lo_nodes->sorted( ) ).

  endmethod.

  method set_obj.

    data lo_nodes type ref to lcl_nodes_helper.
    data lo_cut type ref to z2ui5_cl_ajson.
    data li_writer type ref to z2ui5_if_ajson.

    data:
      begin of ls_struc,
        b type string value 'abc',
        c type i value 10,
        d type d value '20220401',
      end of ls_struc.

    lo_cut = z2ui5_cl_ajson=>create_empty( ).
    li_writer = lo_cut.

    " Prepare source
    create object lo_nodes.
    lo_nodes->add( '        |      |object |           ||1' ).
    lo_nodes->add( '/       |x     |object |           ||3' ).
    lo_nodes->add( '/x/     |b     |str    |abc        ||0' ).
    lo_nodes->add( '/x/     |c     |num    |10         ||0' ).
    lo_nodes->add( '/x/     |d     |str    |2022-04-01 ||0' ).

    li_writer->set(
      iv_path = '/x'
      iv_val  = ls_struc ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->mt_json_tree
      exp = lo_nodes->sorted( ) ).

  endmethod.

  method set_obj_w_date_time.

    data lo_nodes type ref to lcl_nodes_helper.
    data lo_cut type ref to z2ui5_if_ajson.
    data li_writer type ref to z2ui5_if_ajson.

    data:
      begin of ls_struc,
        d       type d value '20220401',
        d_empty type d,
        t       type t value '200103',
        t_empty type t,
        ts      type timestamp value '20220401200103',
        p(5)    type p decimals 2 value '123.45',
      end of ls_struc.

    lo_cut = z2ui5_cl_ajson=>create_empty( )->format_datetime( ).
    li_writer = lo_cut.

    " Prepare source
    create object lo_nodes.
    lo_nodes->add( '      |        |object |           ||6' ).
    lo_nodes->add( '/     |d       |str    |2022-04-01 ||0' ).
    lo_nodes->add( '/     |d_empty |str    |           ||0' ).
    lo_nodes->add( '/     |t       |str    |20:01:03   ||0' ).
    lo_nodes->add( '/     |t_empty |str    |           ||0' ).
    lo_nodes->add( '/     |ts      |str    |2022-04-01T20:01:03Z ||0' ).
    lo_nodes->add( '/     |p       |num    |123.45     ||0' ).

    li_writer->set(
      iv_path = '/'
      iv_val  = ls_struc ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->mt_json_tree
      exp = lo_nodes->sorted( ) ).

  endmethod.

  method set_tab.

    data lo_nodes type ref to lcl_nodes_helper.
    data lo_cut type ref to z2ui5_cl_ajson.
    data li_writer type ref to z2ui5_if_ajson.
    data lt_tab type string_table.

    lo_cut = z2ui5_cl_ajson=>create_empty( ).
    li_writer = lo_cut.

    append 'hello' to lt_tab.
    append 'world' to lt_tab.

    " Prepare source
    create object lo_nodes.
    lo_nodes->add( '        |      |object |     | |1' ).
    lo_nodes->add( '/       |x     |array  |     | |2' ).
    lo_nodes->add( '/x/     |1     |str    |hello|1|0' ).
    lo_nodes->add( '/x/     |2     |str    |world|2|0' ).

    li_writer->set(
      iv_path = '/x'
      iv_val  = lt_tab ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->mt_json_tree
      exp = lo_nodes->sorted( ) ).

  endmethod.

  method set_tab_hashed.

    data lo_nodes type ref to lcl_nodes_helper.
    data lo_cut type ref to z2ui5_cl_ajson.
    data li_writer type ref to z2ui5_if_ajson.
    data lt_tab type hashed table of string with unique key table_line.

    lo_cut = z2ui5_cl_ajson=>create_empty( ).
    li_writer = lo_cut.

    insert `hello` into table lt_tab.
    insert `world` into table lt_tab.

    " Prepare source
    create object lo_nodes.
    lo_nodes->add( '        |      |object |     | |1' ).
    lo_nodes->add( '/       |x     |array  |     | |2' ).
    lo_nodes->add( '/x/     |1     |str    |hello|1|0' ).
    lo_nodes->add( '/x/     |2     |str    |world|2|0' ).

    li_writer->set(
      iv_path = '/x'
      iv_val  = lt_tab ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->mt_json_tree
      exp = lo_nodes->sorted( ) ).

  endmethod.

  method set_tab_nested_struct.

    types:
      begin of ty_include,
        str type string,
        int type i,
      end of ty_include,
      begin of ty_struct.
        include type ty_include.
    types: dat type xstring,
      end of ty_struct,
      ty_tab type standard table of ty_struct with key str.

    data lo_nodes type ref to lcl_nodes_helper.
    data li_cut type ref to z2ui5_if_ajson.
    data ls_tab type ty_struct.
    data lt_tab type ty_tab.

    li_cut = z2ui5_cl_ajson=>create_empty( ).

    ls_tab-str = 'hello'.
    ls_tab-int = 123.
    ls_tab-dat = '4041'.
    insert ls_tab into table lt_tab.
    ls_tab-str = 'world'.
    ls_tab-int = 456.
    ls_tab-dat = '6061'.
    insert ls_tab into table lt_tab.

    " prepare source
    create object lo_nodes.
    lo_nodes->add( '        |      |array  |     |0|2' ).
    lo_nodes->add( '/       |1     |object |     |1|3' ).
    lo_nodes->add( '/       |2     |object |     |2|3' ).
    lo_nodes->add( '/1/     |dat   |str    |4041 |0|0' ).
    lo_nodes->add( '/1/     |int   |num    |123  |0|0' ).
    lo_nodes->add( '/1/     |str   |str    |hello|0|0' ).
    lo_nodes->add( '/2/     |dat   |str    |6061 |0|0' ).
    lo_nodes->add( '/2/     |int   |num    |456  |0|0' ).
    lo_nodes->add( '/2/     |str   |str    |world|0|0' ).

    li_cut->set(
      iv_path = '/'
      iv_val  = lt_tab ).
    cl_abap_unit_assert=>assert_equals(
      act = li_cut->mt_json_tree
      exp = lo_nodes->sorted( ) ).

  endmethod.

  method arrays.

    data lo_cut type ref to z2ui5_cl_ajson.
    data lo_nodes_exp type ref to lcl_nodes_helper.
    data li_writer type ref to z2ui5_if_ajson.

    lo_cut = z2ui5_cl_ajson=>create_empty( ).
    li_writer = lo_cut.

    " touch
    create object lo_nodes_exp.
    lo_nodes_exp->add( '        |      |object |     | |1' ).
    lo_nodes_exp->add( '/       |a     |array  |     | |0' ).

    li_writer->touch_array( iv_path = '/a' ).

    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->mt_json_tree
      exp = lo_nodes_exp->sorted( ) ).

    " add string
    create object lo_nodes_exp.
    lo_nodes_exp->add( '        |      |object |     | |1' ).
    lo_nodes_exp->add( '/       |a     |array  |     | |1' ).
    lo_nodes_exp->add( '/a/     |1     |str    |hello|1|0' ).

    li_writer->push(
      iv_path = '/a'
      iv_val  = 'hello' ).

    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->mt_json_tree
      exp = lo_nodes_exp->sorted( ) ).

    " add obj
    create object lo_nodes_exp.
    lo_nodes_exp->add( '        |      |object |     | |1' ).
    lo_nodes_exp->add( '/       |a     |array  |     | |2' ).
    lo_nodes_exp->add( '/a/     |1     |str    |hello|1|0' ).
    lo_nodes_exp->add( '/a/     |2     |object |     |2|1' ).
    lo_nodes_exp->add( '/a/2/   |x     |str    |world| |0' ).

    data:
      begin of ls_dummy,
        x type string value 'world',
      end of ls_dummy.

    li_writer->push(
      iv_path = '/a'
      iv_val  = ls_dummy ).

    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->mt_json_tree
      exp = lo_nodes_exp->sorted( ) ).

    " re-touch
    li_writer->touch_array( iv_path = '/a' ).

    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->mt_json_tree
      exp = lo_nodes_exp->sorted( ) ).

    " re-touch with clear
    create object lo_nodes_exp.
    lo_nodes_exp->add( '        |      |object |     | |1' ).
    lo_nodes_exp->add( '/       |a     |array  |     | |0' ).

    li_writer->touch_array(
      iv_path = '/a'
      iv_clear = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->mt_json_tree
      exp = lo_nodes_exp->sorted( ) ).

    " free-add array item (index must be updated)
    create object lo_nodes_exp.
    lo_nodes_exp->add( '        |      |object |     | |1' ).
    lo_nodes_exp->add( '/       |a     |array  |     | |2' ).
    lo_nodes_exp->add( '/a/     |1     |object |     |1|1' ).
    lo_nodes_exp->add( '/a/1/   |x     |num    |123  | |0' ).
    lo_nodes_exp->add( '/a/     |2     |num    |234  |2|0' ).

    li_writer->set(
      iv_path = '/a/1/x'
      iv_val  = 123 ).
    li_writer->set(
      iv_path = '/a/2'
      iv_val  = 234 ).

    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->mt_json_tree
      exp = lo_nodes_exp->sorted( ) ).

  endmethod.

  method arrays_negative.

    data lo_cut type ref to z2ui5_cl_ajson.
    data li_writer type ref to z2ui5_if_ajson.

    lo_cut = z2ui5_cl_ajson=>create_empty( ).
    li_writer = lo_cut.

    li_writer->touch_array( iv_path = '/a' ).
    li_writer->push(
      iv_path = '/a'
      iv_val = 123 ).

    " touch another node
    data lx type ref to z2UI5_cx_ajson_error.
    try.
      li_writer->touch_array( iv_path = '/a/1' ).
      cl_abap_unit_assert=>fail( ).
    catch z2UI5_cx_ajson_error into lx.
      cl_abap_unit_assert=>assert_equals(
        act = lx->message
        exp = 'Path [/a/1] already used and is not array' ).
    endtry.

    " push to not array
    try.
      li_writer->push(
        iv_path = '/a/1'
        iv_val  = 123 ).
      cl_abap_unit_assert=>fail( ).
    catch z2UI5_cx_ajson_error into lx.
      cl_abap_unit_assert=>assert_equals(
        act = lx->message
        exp = 'Path [/a/1] is not array' ).
    endtry.

    " push to not array
    try.
      li_writer->push(
        iv_path = '/x'
        iv_val  = 123 ).
      cl_abap_unit_assert=>fail( ).
    catch z2UI5_cx_ajson_error into lx.
      cl_abap_unit_assert=>assert_equals(
        act = lx->message
        exp = 'Path [/x] does not exist' ).
    endtry.

    " set array item with non-numeric key
    try.
      li_writer->set(
        iv_path = '/a/abc/x'
        iv_val  = 123 ).
      cl_abap_unit_assert=>fail( ).
    catch z2UI5_cx_ajson_error into lx.
      cl_abap_unit_assert=>assert_equals(
        act = lx->message
        exp = 'Cannot add non-numeric key [abc] to array [/a/]' ).
    endtry.

    try.
      li_writer->set(
        iv_path = '/a/abc'
        iv_val  = 123 ).
      cl_abap_unit_assert=>fail( ).
    catch z2UI5_cx_ajson_error into lx.
      cl_abap_unit_assert=>assert_equals(
        act = lx->message
        exp = 'Cannot add non-numeric key [abc] to array [/a/]' ).
    endtry.

    " set array item with zero key
    try.
      li_writer->set(
        iv_path = '/a/0'
        iv_val  = 123 ).
      cl_abap_unit_assert=>fail( ).
    catch z2UI5_cx_ajson_error into lx.
      cl_abap_unit_assert=>assert_equals(
        act = lx->message
        exp = 'Cannot add zero key to array [/a/]' ).
    endtry.

  endmethod.


  method root_assignment.

    data lo_cut type ref to z2ui5_cl_ajson.
    data lo_nodes_exp type ref to lcl_nodes_helper.
    data li_writer type ref to z2ui5_if_ajson.
    data:
      begin of ls_dummy,
        x type string value 'hello',
      end of ls_dummy.

    lo_cut = z2ui5_cl_ajson=>create_empty( ).
    li_writer = lo_cut.

    " object
    create object lo_nodes_exp.
    lo_nodes_exp->add( '        |      |object |     ||1' ).
    lo_nodes_exp->add( '/       |x     |str    |hello||0' ).

    li_writer->set(
      iv_path = '/'
      iv_val  = ls_dummy ).

    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->mt_json_tree
      exp = lo_nodes_exp->sorted( ) ).

    " object empty path
    create object lo_nodes_exp.
    lo_nodes_exp->add( '        |      |object |     ||1' ).
    lo_nodes_exp->add( '/       |x     |str    |hello||0' ).

    li_writer->clear( ).
    li_writer->set(
      iv_path = ''
      iv_val  = ls_dummy ).

    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->mt_json_tree
      exp = lo_nodes_exp->sorted( ) ).

    " array
    create object lo_nodes_exp.
    lo_nodes_exp->add( '        |      |array  |     | |1' ).
    lo_nodes_exp->add( '/       |1     |str    |hello|1|0' ).

    li_writer->clear( ).
    li_writer->touch_array( iv_path = '' ).
    li_writer->push(
      iv_path = ''
      iv_val  = 'hello' ).

    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->mt_json_tree
      exp = lo_nodes_exp->sorted( ) ).

    " value
    create object lo_nodes_exp.
    lo_nodes_exp->add( '        |      |str    |hello||0' ).

    li_writer->clear( ).
    li_writer->set(
      iv_path = ''
      iv_val  = 'hello' ).

    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->mt_json_tree
      exp = lo_nodes_exp->sorted( ) ).

  endmethod.

  method set_bool_abap_bool.

    data lo_cut type ref to z2ui5_cl_ajson.
    data lo_nodes_exp type ref to lcl_nodes_helper.
    data li_writer type ref to z2ui5_if_ajson.

    " abap_bool
    lo_cut = z2ui5_cl_ajson=>create_empty( ).
    li_writer = lo_cut.
    create object lo_nodes_exp.
    lo_nodes_exp->add( '        |      |object |      ||2' ).
    lo_nodes_exp->add( '/       |a     |bool   |true  ||0' ).
    lo_nodes_exp->add( '/       |b     |bool   |false ||0' ).

    li_writer->set_boolean(
      iv_path = '/a'
      iv_val  = abap_true ).
    li_writer->set_boolean(
      iv_path = '/b'
      iv_val  = abap_false ).

    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->mt_json_tree
      exp = lo_nodes_exp->sorted( ) ).

  endmethod.

  method set_bool_int.

    data lo_cut type ref to z2ui5_cl_ajson.
    data lo_nodes_exp type ref to lcl_nodes_helper.
    data li_writer type ref to z2ui5_if_ajson.

    " int
    lo_cut = z2ui5_cl_ajson=>create_empty( ).
    li_writer = lo_cut.
    create object lo_nodes_exp.
    lo_nodes_exp->add( '        |      |object |      ||2' ).
    lo_nodes_exp->add( '/       |a     |bool   |true  ||0' ).
    lo_nodes_exp->add( '/       |b     |bool   |false ||0' ).

    li_writer->set_boolean(
      iv_path = '/a'
      iv_val  = 1 ).
    li_writer->set_boolean(
      iv_path = '/b'
      iv_val  = 0 ).

    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->mt_json_tree
      exp = lo_nodes_exp->sorted( ) ).

  endmethod.

  method set_bool_tab.

    data lo_cut type ref to z2ui5_cl_ajson.
    data lo_nodes_exp type ref to lcl_nodes_helper.
    data li_writer type ref to z2ui5_if_ajson.
    data lt_tab type string_table.

    " tab
    lo_cut = z2ui5_cl_ajson=>create_empty( ).
    li_writer = lo_cut.
    create object lo_nodes_exp.
    lo_nodes_exp->add( '        |      |object |      ||2' ).
    lo_nodes_exp->add( '/       |a     |bool   |true  ||0' ).
    lo_nodes_exp->add( '/       |b     |bool   |false ||0' ).

    append 'hello' to lt_tab.
    li_writer->set_boolean(
      iv_path = '/a'
      iv_val  = lt_tab ).
    clear lt_tab.
    li_writer->set_boolean(
      iv_path = '/b'
      iv_val  = lt_tab ).

    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->mt_json_tree
      exp = lo_nodes_exp->sorted( ) ).

  endmethod.

  method set_str.

    data lo_cut type ref to z2ui5_cl_ajson.
    data lo_nodes_exp type ref to lcl_nodes_helper.
    data li_writer type ref to z2ui5_if_ajson.
    data lv_date type d.

    lo_cut = z2ui5_cl_ajson=>create_empty( ).
    li_writer = lo_cut.
    create object lo_nodes_exp.
    lo_nodes_exp->add( '        |      |object |         ||3' ).
    lo_nodes_exp->add( '/       |a     |str    |123      ||0' ).
    lo_nodes_exp->add( '/       |b     |str    |X        ||0' ).
    lo_nodes_exp->add( '/       |c     |str    |20200705 ||0' ).

    li_writer->set_string(
      iv_path = '/a'
      iv_val  = '123' ).
    li_writer->set_string(
      iv_path = '/b'
      iv_val  = abap_true ).
    lv_date = '20200705'.
    li_writer->set_string(
      iv_path = '/c'
      iv_val  = lv_date ).

    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->mt_json_tree
      exp = lo_nodes_exp->sorted( ) ).

  endmethod.

  method set_int.

    data lo_cut type ref to z2ui5_cl_ajson.
    data lo_nodes_exp type ref to lcl_nodes_helper.
    data li_writer type ref to z2ui5_if_ajson.

    lo_cut = z2ui5_cl_ajson=>create_empty( ).
    li_writer = lo_cut.
    create object lo_nodes_exp.
    lo_nodes_exp->add( '        |      |object |         ||1' ).
    lo_nodes_exp->add( '/       |a     |num    |123      ||0' ).

    li_writer->set_integer(
      iv_path = '/a'
      iv_val  = 123 ).

    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->mt_json_tree
      exp = lo_nodes_exp->sorted( ) ).

  endmethod.

  method set_date.

    data lo_cut type ref to z2ui5_cl_ajson.
    data lo_nodes_exp type ref to lcl_nodes_helper.
    data li_writer type ref to z2ui5_if_ajson.
    data lv_date type d.

    lo_cut = z2ui5_cl_ajson=>create_empty( ).
    li_writer = lo_cut.
    create object lo_nodes_exp.
    lo_nodes_exp->add( '        |      |object |           ||2' ).
    lo_nodes_exp->add( '/       |a     |str    |2020-07-05 ||0' ).
    lo_nodes_exp->add( '/       |b     |str    |           ||0' ).

    lv_date = '20200705'.
    li_writer->set_date(
      iv_path = '/a'
      iv_val  = lv_date ).

    clear lv_date.
    li_writer->set_date(
      iv_path = '/b'
      iv_val  = lv_date ).

    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->mt_json_tree
      exp = lo_nodes_exp->sorted( ) ).

  endmethod.

  method set_timestamp.

    data lo_cut type ref to z2ui5_cl_ajson.
    data lo_nodes_exp type ref to lcl_nodes_helper.
    data li_writer type ref to z2ui5_if_ajson.
    data lv_timestamp type timestamp.

    lo_cut = z2ui5_cl_ajson=>create_empty( ).
    li_writer = lo_cut.
    create object lo_nodes_exp.
    lo_nodes_exp->add( '        |      |object |                     ||1' ).
    lo_nodes_exp->add( '/       |a     |str    |2021-05-05T12:00:00Z ||0' ).

    lv_timestamp = '20210505120000'.
    li_writer->set_timestamp(
      iv_path = '/a'
      iv_val  = lv_timestamp ).

    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->mt_json_tree
      exp = lo_nodes_exp->sorted( ) ).

  endmethod.

  method read_only.

    data lo_cut type ref to z2ui5_cl_ajson.
    data li_writer type ref to z2ui5_if_ajson.

    lo_cut = z2ui5_cl_ajson=>create_empty( ).
    li_writer = lo_cut.

    " Prepare source
    li_writer->set(
      iv_path = '/a'
      iv_val  = 'abc' ).
    li_writer->touch_array( iv_path = '/b' ).
    li_writer->push(
      iv_path = '/b'
      iv_val  = 'abc' ).

    lo_cut->freeze( ).

    try.
      li_writer->set(
        iv_path = '/c'
        iv_val  = 'abc' ).
      cl_abap_unit_assert=>fail( ).
    catch z2UI5_cx_ajson_error.
    endtry.

    try.
      li_writer->touch_array( iv_path = '/d' ).
      cl_abap_unit_assert=>fail( ).
    catch z2UI5_cx_ajson_error.
    endtry.

    try.
      li_writer->push(
        iv_path = '/b'
        iv_val  = 'xyz' ).
      cl_abap_unit_assert=>fail( ).
    catch z2UI5_cx_ajson_error.
    endtry.

    try.
      li_writer->delete( iv_path = '/a' ).
      cl_abap_unit_assert=>fail( ).
    catch z2UI5_cx_ajson_error.
    endtry.

    try.
      li_writer->clear( ).
      cl_abap_unit_assert=>fail( ).
    catch z2UI5_cx_ajson_error.
    endtry.

  endmethod.

  method set_array_obj.

    data lo_cut type ref to z2ui5_cl_ajson.
    data lo_nodes_exp type ref to lcl_nodes_helper.
    data li_writer type ref to z2ui5_if_ajson.

    create object lo_nodes_exp.
    lo_nodes_exp->add( '                 |         |object |                        |  |1' ).
    lo_nodes_exp->add( '/                |issues   |array  |                        |  |2' ).
    lo_nodes_exp->add( '/issues/         |1        |object |                        |1 |1' ).
    lo_nodes_exp->add( '/issues/         |2        |object |                        |2 |1' ).
    lo_nodes_exp->add( '/issues/1/       |end      |object |                        |  |2' ).
    lo_nodes_exp->add( '/issues/1/end/   |col      |num    |26                      |  |0' ).
    lo_nodes_exp->add( '/issues/1/end/   |row      |num    |4                       |  |0' ).
    lo_nodes_exp->add( '/issues/2/       |end      |object |                        |  |2' ).
    lo_nodes_exp->add( '/issues/2/end/   |col      |num    |22                      |  |0' ).
    lo_nodes_exp->add( '/issues/2/end/   |row      |num    |3                       |  |0' ).

    lo_cut = z2ui5_cl_ajson=>create_empty( ).
    li_writer = lo_cut.

    li_writer->touch_array( iv_path = '/issues' ).
    li_writer->set(
      iv_path = '/issues/1/end/col'
      iv_val  = 26 ).
    li_writer->set(
      iv_path = '/issues/1/end/row'
      iv_val  = 4 ).
    li_writer->set(
      iv_path = '/issues/2/end/col'
      iv_val  = 22 ).
    li_writer->set(
      iv_path = '/issues/2/end/row'
      iv_val  = 3 ).

    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->mt_json_tree
      exp = lo_nodes_exp->sorted( ) ).

  endmethod.

  method set_with_type.

    data lo_sample type ref to z2ui5_cl_ajson.
    data lo_cut type ref to z2ui5_cl_ajson.
    data li_writer type ref to z2ui5_if_ajson.

    lo_sample = z2ui5_cl_ajson=>parse( ltcl_parser_test=>sample_json( ) ).

    lo_cut = z2ui5_cl_ajson=>create_empty( ).
    li_writer = lo_cut.

    set_with_type_slice( io_json_in  = lo_sample
                         io_json_out = li_writer
                         iv_path     = '/' ).

    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->mt_json_tree
      exp = lo_sample->mt_json_tree ).

  endmethod.

  method set_with_type_slice.

    data lv_path type string.

    field-symbols <node> like line of io_json_in->mt_json_tree.

    loop at io_json_in->mt_json_tree assigning <node> where path = iv_path.
      lv_path = <node>-path && <node>-name && '/'.
      case <node>-type.
        when z2ui5_if_ajson_types=>node_type-array.
          io_json_out->touch_array( lv_path ).
          set_with_type_slice( io_json_in  = io_json_in
                               io_json_out = io_json_out
                               iv_path     = lv_path ).
        when z2ui5_if_ajson_types=>node_type-object.
          set_with_type_slice( io_json_in  = io_json_in
                               io_json_out = io_json_out
                               iv_path     = lv_path ).
        when others.
          io_json_out->set(
            iv_path      = lv_path
            iv_val       = <node>-value
            iv_node_type = <node>-type ).
      endcase.
    endloop.

  endmethod.

  method overwrite_w_keep_order_set.

    data li_cut type ref to z2ui5_if_ajson.
    data:
      begin of ls_dummy,
        b type i,
        a type i,
      end of ls_dummy.

    li_cut = z2ui5_cl_ajson=>create_empty(
    )->set(
      iv_ignore_empty = abap_false
      iv_path = '/'
      iv_val  = ls_dummy ).

    cl_abap_unit_assert=>assert_equals(
      act = li_cut->stringify( )
      exp = '{"a":0,"b":0}' ). " ordered by path, name

    li_cut = z2ui5_cl_ajson=>create_empty(
    )->keep_item_order(
    )->set(
      iv_ignore_empty = abap_false
      iv_path = '/'
      iv_val  = ls_dummy ).

    cl_abap_unit_assert=>assert_equals(
      act = li_cut->stringify( )
      exp = '{"b":0,"a":0}' ). " ordered by structure order

    li_cut->set(
      iv_path  = '/a'
      iv_val   = 1 ).

    cl_abap_unit_assert=>assert_equals(
      act = li_cut->stringify( )
      exp = '{"b":0,"a":1}' ). " still ordered after overwrite

  endmethod.

  method overwrite_w_keep_order_touch.

    data li_cut type ref to z2ui5_if_ajson.
    data:
      begin of ls_dummy,
        b type i,
        a type string_table,
      end of ls_dummy.

    li_cut = z2ui5_cl_ajson=>create_empty(
    )->set(
      iv_ignore_empty = abap_false
      iv_path = '/'
      iv_val  = ls_dummy ).

    cl_abap_unit_assert=>assert_equals(
      act = li_cut->stringify( )
      exp = '{"a":[],"b":0}' ). " ordered by path, name

    li_cut = z2ui5_cl_ajson=>create_empty(
    )->keep_item_order(
    )->set(
      iv_ignore_empty = abap_false
      iv_path = '/'
      iv_val  = ls_dummy ).

    cl_abap_unit_assert=>assert_equals(
      act = li_cut->stringify( )
      exp = '{"b":0,"a":[]}' ). " ordered by structure order

    li_cut->touch_array(
      iv_path  = '/a'
      iv_clear = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      act = li_cut->stringify( )
      exp = '{"b":0,"a":[]}' ). " still ordered after touch with clear

  endmethod.

  method setx.

    cl_abap_unit_assert=>assert_equals(
      act = z2ui5_cl_ajson=>new( )->setx( '/a:1' )->stringify( )
      exp = '{"a":1}' ).

    cl_abap_unit_assert=>assert_equals(
      act = z2ui5_cl_ajson=>new( )->setx( '/a : 1' )->stringify( )
      exp = '{"a":1}' ).

    cl_abap_unit_assert=>assert_equals(
      act = z2ui5_cl_ajson=>new( )->setx( '/a:"1"' )->stringify( )
      exp = '{"a":"1"}' ).

    cl_abap_unit_assert=>assert_equals(
      act = z2ui5_cl_ajson=>new( )->setx( '/a:abc' )->stringify( )
      exp = '{"a":"abc"}' ).

    cl_abap_unit_assert=>assert_equals(
      act = z2ui5_cl_ajson=>new( )->setx( '/a:null' )->stringify( )
      exp = '{"a":null}' ).

    cl_abap_unit_assert=>assert_equals(
      act = z2ui5_cl_ajson=>new( )->setx( '/a:true' )->stringify( )
      exp = '{"a":true}' ).

    cl_abap_unit_assert=>assert_equals(
      act = z2ui5_cl_ajson=>new( )->setx( '/a:"true"' )->stringify( )
      exp = '{"a":"true"}' ).

    cl_abap_unit_assert=>assert_equals(
      act = z2ui5_cl_ajson=>new( )->setx( '/a:false' )->stringify( )
      exp = '{"a":false}' ).

    cl_abap_unit_assert=>assert_equals(
      act = z2ui5_cl_ajson=>new( )->setx( '/a/b:1' )->stringify( )
      exp = '{"a":{"b":1}}' ).

    cl_abap_unit_assert=>assert_equals(
      act = z2ui5_cl_ajson=>new( )->setx( '/:1' )->stringify( )
      exp = '1' ). " Because set( path = '/' ) would write root node

    cl_abap_unit_assert=>assert_equals(
      act = z2ui5_cl_ajson=>new( )->setx( ':1' )->stringify( )
      exp = '1' ). " Because set( path = '' ) would write root node

*    cl_abap_unit_assert=>assert_equals(
*      act = zcl_ajson=>new( )->setx( '' )->stringify( )
*      exp = '{}' ). " problem is that root node not set so it is not an object

*    cl_abap_unit_assert=>assert_equals(
*      act = zcl_ajson=>new( )->setx( '/a:' )->stringify( )
*      exp = '{}' ). " should setx ignore empty values or set an empty string ? Or null ?

    cl_abap_unit_assert=>assert_equals(
      act = z2ui5_cl_ajson=>new( )->setx( '/a:""' )->stringify( )
      exp = '{"a":""}' ).

  endmethod.

  method setx_float.

    cl_abap_unit_assert=>assert_equals(
      act = z2ui5_cl_ajson=>new( )->setx( '/a:1.123' )->stringify( )
      exp = '{"a":1.123}' ).

    cl_abap_unit_assert=>assert_equals(
      act = z2ui5_cl_ajson=>new( )->setx( '/a:00.123' )->stringify( )
      exp = '{"a":"00.123"}' ). " not a number

    cl_abap_unit_assert=>assert_equals(
      act = z2ui5_cl_ajson=>new( )->setx( '/a:.123' )->stringify( )
      exp = '{"a":".123"}' ).

    cl_abap_unit_assert=>assert_equals(
      act = z2ui5_cl_ajson=>new( )->setx( '/a:123.' )->stringify( )
      exp = '{"a":"123."}' ).

    cl_abap_unit_assert=>assert_equals(
      act = z2ui5_cl_ajson=>new( )->setx( '/a:1..123' )->stringify( )
      exp = '{"a":"1..123"}' ).

  endmethod.

  method setx_complex.

    cl_abap_unit_assert=>assert_equals(
      act = z2ui5_cl_ajson=>new( )->setx( '/a:{"b" : 1}' )->stringify( )
      exp = '{"a":{"b":1}}' ).

    cl_abap_unit_assert=>assert_equals(
      act = z2ui5_cl_ajson=>new( )->setx( '/a:{}' )->stringify( )
      exp = '{"a":{}}' ).

    cl_abap_unit_assert=>assert_equals(
      act = z2ui5_cl_ajson=>new( )->setx( '/a:[1, 2]' )->stringify( )
      exp = '{"a":[1,2]}' ).

    cl_abap_unit_assert=>assert_equals(
      act = z2ui5_cl_ajson=>new( )->setx( '/a:[]' )->stringify( )
      exp = '{"a":[]}' ).

    try.
      z2ui5_cl_ajson=>new( )->setx( '/a:{"b" : 1' ).
      cl_abap_unit_assert=>fail( ).
    catch z2UI5_cx_ajson_error.
    endtry.

    try.
      z2ui5_cl_ajson=>new( )->setx( '/a:[1, 2' ).
      cl_abap_unit_assert=>fail( ).
    catch z2UI5_cx_ajson_error.
    endtry.

  endmethod.

  method setx_complex_w_keep_order.

    data li_cut type ref to z2ui5_if_ajson.
    data:
      begin of ls_dummy,
        f type i value 5,
        e type i value 6,
      end of ls_dummy.

    li_cut = z2ui5_cl_ajson=>new( iv_keep_item_order = abap_true ).
    li_cut->setx( '/c:3' ).
    li_cut->set(
      iv_path = '/b'
      iv_val  = ls_dummy ).
    li_cut->setx( '/a:1' ).

    cl_abap_unit_assert=>assert_equals(
      act = li_cut->stringify( )
      exp = '{"c":3,"b":{"f":5,"e":6},"a":1}' ).

    li_cut->setx( '/b:{"z":9,"y":8}' ).

    cl_abap_unit_assert=>assert_equals(
      act = li_cut->stringify( )
      exp = '{"c":3,"b":{"z":9,"y":8},"a":1}' ).
    " TODO: a subtle bug here. The '/b:{"z":9,"y":8}' creates a json internally
    " without the ordering. It's just by chance that this UT passes, but the implementation
    " does not guarantee it. The parser should be instructed to keep the order of the parsed json

    li_cut->setx( '/0:9' ).

    cl_abap_unit_assert=>assert_equals(
      act = li_cut->stringify( )
      exp = '{"c":3,"b":{"z":9,"y":8},"a":1,"0":9}' ).

  endmethod.

endclass.


**********************************************************************
* INTEGRATED
**********************************************************************
class ltcl_integrated definition
  for testing
  risk level harmless
  duration short
  final.

  private section.

    types:
      begin of ty_loc,
        row type i,
        col type i,
      end of ty_loc,
      begin of ty_issue,
        message type string,
        key type string,
        filename type string,
        start type ty_loc,
        end type ty_loc,
      end of ty_issue,
      tt_issues type standard table of ty_issue with key message key,
      begin of ty_target,
        string type string,
        number type i,
        float type f,
        boolean type abap_bool,
        false type abap_bool,
        null type string,
        date type string, " ??? TODO
        issues type tt_issues,
      end of ty_target.

    methods reader for testing raising z2UI5_cx_ajson_error.
    methods array_index for testing raising z2UI5_cx_ajson_error.
    methods array_simple for testing raising z2UI5_cx_ajson_error.
    methods stringify for testing raising z2UI5_cx_ajson_error.
    methods item_order_integrated for testing raising z2UI5_cx_ajson_error.
    methods chaining for testing raising z2UI5_cx_ajson_error.
    methods push_json for testing raising z2UI5_cx_ajson_error.
    methods is_empty for testing raising z2UI5_cx_ajson_error.

endclass.

class ltcl_integrated implementation.

  method array_simple.

    data lt_act type string_table.
    data lt_exp type string_table.
    data lv_exp type string.

    data lv_src type string.
    lv_src = '['.
    do 10 times.
      if sy-index <> 1.
        lv_src = lv_src && `, `.
      endif.
      lv_src = lv_src && |"{ sy-index }"|.
      lv_exp = |{ sy-index }|.
      append lv_exp to lt_exp.
    enddo.
    lv_src = lv_src && ']'.

    data li_reader type ref to z2ui5_if_ajson.
    li_reader = z2ui5_cl_ajson=>parse( lv_src ).
    li_reader->to_abap( importing ev_container = lt_act ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_act
      exp = lt_exp ).

  endmethod.

  method array_index.

    data lt_act type table of ty_loc.
    data lt_exp type table of ty_loc.
    data ls_exp type ty_loc.

    data lv_src type string.
    lv_src = '['.
    do 10 times.
      if sy-index <> 1.
        lv_src = lv_src && `, `.
      endif.
      lv_src = lv_src && |\{ "row": { sy-index } \}|.
      ls_exp-row = sy-index.
      append ls_exp to lt_exp.
    enddo.
    lv_src = lv_src && ']'.

    data li_reader type ref to z2ui5_if_ajson.
    li_reader = z2ui5_cl_ajson=>parse( lv_src ).
    li_reader->to_abap( importing ev_container = lt_act ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_act
      exp = lt_exp ).

  endmethod.

  method reader.

    data lv_source type string.
    data li_reader type ref to z2ui5_if_ajson.

    lv_source = ltcl_parser_test=>sample_json( ).
    li_reader = z2ui5_cl_ajson=>parse( lv_source ).

    cl_abap_unit_assert=>assert_equals(
      act = li_reader->get( '/string' )
      exp = 'abc' ).

    data ls_act type ty_target.
    data ls_exp type ty_target.
    field-symbols <i> like line of ls_exp-issues.

    ls_exp-string = 'abc'.
    ls_exp-number = 123.
    ls_exp-float = '123.45'.
    ls_exp-boolean = abap_true.
    ls_exp-false = abap_false.
    ls_exp-date = '2020-03-15'.

    append initial line to ls_exp-issues assigning <i>.
    <i>-message  = 'Indentation problem ...'.
    <i>-key      = 'indentation'.
    <i>-filename = './zxxx.prog.abap'.
    <i>-start-row = 4.
    <i>-start-col = 3.
    <i>-end-row   = 4.
    <i>-end-col   = 26.

    append initial line to ls_exp-issues assigning <i>.
    <i>-message  = 'Remove space before XXX'.
    <i>-key      = 'space_before_dot'.
    <i>-filename = './zxxx.prog.abap'.
    <i>-start-row = 3.
    <i>-start-col = 21.
    <i>-end-row   = 3.
    <i>-end-col   = 22.

    li_reader->to_abap( importing ev_container = ls_act ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_act
      exp = ls_exp ).

  endmethod.

  method stringify.

    data lo_cut type ref to z2ui5_cl_ajson.
    data li_writer type ref to z2ui5_if_ajson.
    data lv_exp type string.
    data: begin of ls_dummy, x type i, end of ls_dummy.
    data: begin of ls_data, str type string, cls type ref to z2ui5_cl_ajson, end of ls_data.

    ls_dummy-x = 1.
    lo_cut    = z2ui5_cl_ajson=>create_empty( ).
    li_writer = lo_cut.

    li_writer->set(
      iv_path = '/a'
      iv_val  = 1 ).
    li_writer->set(
      iv_path = '/b'
      iv_val  = 'B' ).
    li_writer->set(
      iv_path = '/c'
      iv_val  = abap_true ).
    li_writer->set_null( iv_path = '/d' ).

    " simple test
    lv_exp = '{"a":1,"b":"B","c":true,"d":null}'.
    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->stringify( )
      exp = lv_exp ).

    li_writer->touch_array( iv_path = '/e' ).
    li_writer->touch_array( iv_path = '/f' ).
    li_writer->push(
      iv_path = '/f'
      iv_val  = 5 ).
    li_writer->push(
      iv_path = '/f'
      iv_val  = ls_dummy ).
    li_writer->set(
      iv_path = '/g'
      iv_val  = ls_dummy ).

    " complex test
    lv_exp = '{"a":1,"b":"B","c":true,"d":null,"e":[],"f":[5,{"x":1}],"g":{"x":1}}'.
    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->stringify( )
      exp = lv_exp ).

    " complex test indented
    lv_exp =
      '{\n' &&
      '  "a": 1,\n' &&
      '  "b": "B",\n' &&
      '  "c": true,\n' &&
      '  "d": null,\n' &&
      '  "e": [],\n' &&
      '  "f": [\n' &&
      '    5,\n' &&
      '    {\n' &&
      '      "x": 1\n' &&
      '    }\n' &&
      '  ],\n' &&
      '  "g": {\n' &&
      '    "x": 1\n' &&
      '  }\n' &&
      '}'.
    lv_exp = replace(
      val = lv_exp
      sub = '\n'
      with = cl_abap_char_utilities=>newline
      occ = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->stringify( iv_indent = 2 )
      exp = lv_exp ).

    " structure with initial ref to class
    ls_data-str = 'test'.

    li_writer = lo_cut.
    li_writer->set(
      iv_path = '/'
      iv_val  = ls_data ).

    lv_exp = '{"cls":null,"str":"test"}'.
    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->stringify( )
      exp = lv_exp ).

  endmethod.

  method item_order_integrated.

    data:
      begin of ls_dummy,
        zulu type string,
        alpha type string,
        beta type string,
      end of ls_dummy.

    data lv_act type string.
    data lv_exp type string.
    data li_cut type ref to z2ui5_if_ajson.

    ls_dummy-alpha = 'a'.
    ls_dummy-beta  = 'b'.
    ls_dummy-zulu  = 'z'.

    " NAME order
    li_cut = z2ui5_cl_ajson=>create_empty( ).
    li_cut->set(
      iv_path = '/'
      iv_val  = ls_dummy ).

    lv_act = li_cut->stringify( ).
    lv_exp = '{"alpha":"a","beta":"b","zulu":"z"}'.

    cl_abap_unit_assert=>assert_equals(
      act = lv_act
      exp = lv_exp ).

    " STRUC order (keep)
    li_cut = z2ui5_cl_ajson=>create_empty( ).
    li_cut->keep_item_order( ).
    li_cut->set(
      iv_path = '/'
      iv_val  = ls_dummy ).

    lv_act = li_cut->stringify( ).
    lv_exp = '{"zulu":"z","alpha":"a","beta":"b"}'.

    cl_abap_unit_assert=>assert_equals(
      act = lv_act
      exp = lv_exp ).

  endmethod.

  method chaining.

    data li_cut type ref to z2ui5_if_ajson.

    li_cut = z2ui5_cl_ajson=>create_empty( ).

    cl_abap_unit_assert=>assert_bound(
      li_cut->set(
        iv_path = '/a'
        iv_val  = 1 ) ).

    cl_abap_unit_assert=>assert_bound( li_cut->delete( iv_path = '/a' ) ).

    cl_abap_unit_assert=>assert_bound( li_cut->touch_array( iv_path = '/array' ) ).

    cl_abap_unit_assert=>assert_bound(
      li_cut->push(
        iv_path = '/array'
        iv_val  = '1' ) ).

    cl_abap_unit_assert=>assert_bound( li_cut->keep_item_order( ) ).

  endmethod.

  method push_json.

    data li_cut type ref to z2ui5_if_ajson.
    data li_sub type ref to z2ui5_if_ajson.
    data lv_act type string.
    data lv_exp type string.

    li_cut = z2ui5_cl_ajson=>create_empty( ).
    li_sub = z2ui5_cl_ajson=>create_empty( )->set(
      iv_path = 'a'
      iv_val  = '1' ).

    li_cut->touch_array( '/list' ).
    li_cut->push(
      iv_path = '/list'
      iv_val  = 'hello' ).
    li_cut->push(
      iv_path = '/list'
      iv_val  = z2ui5_cl_ajson=>create_empty( )->set(
        iv_path = 'a'
        iv_val  = '1' ) ).
    li_cut->push(
      iv_path = '/list'
      iv_val  = z2ui5_cl_ajson=>create_empty( )->set(
        iv_path = '/'
        iv_val  = 'world' ) ).

    lv_act = li_cut->stringify( ).
    lv_exp = '{"list":["hello",{"a":"1"},"world"]}'.

    cl_abap_unit_assert=>assert_equals(
      act = lv_act
      exp = lv_exp ).

  endmethod.

  method is_empty.

    data li_cut type ref to z2ui5_if_ajson.

    li_cut = z2ui5_cl_ajson=>create_empty( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = li_cut->is_empty( ) ).

    li_cut->set(
      iv_path = '/x'
      iv_val  = '123' ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = li_cut->is_empty( ) ).

  endmethod.

endclass.

**********************************************************************
* ABAP TO JSON
**********************************************************************
class ltcl_abap_to_json definition
  for testing
  risk level harmless
  duration short
  final.

  private section.

    types:
      begin of ty_struc,
        a type string,
        b type i,
        c type abap_bool,
        d type xsdboolean,
      end of ty_struc,
      tt_struc type standard table of ty_struc with key a,
      begin of ty_struc_complex.
        include type ty_struc.
    types:
        el type string,
        struc type ty_struc,
        tab type tt_struc,
        stab type string_table,
      end of ty_struc_complex.

    types
      begin of ty_named_include.
        include type ty_struc as named_with_suffix renaming with suffix _suf.
    types:
        el type string,
      end of ty_named_include.

    methods set_ajson for testing raising z2UI5_cx_ajson_error.
    methods set_value_number for testing raising z2UI5_cx_ajson_error.
    methods set_value_string for testing raising z2UI5_cx_ajson_error.
    methods set_value_true for testing raising z2UI5_cx_ajson_error.
    methods set_value_false for testing raising z2UI5_cx_ajson_error.
    methods set_value_xsdboolean for testing raising z2UI5_cx_ajson_error.
    methods set_value_timestamp for testing raising z2UI5_cx_ajson_error.
    methods set_value_timestamp_initial for testing raising z2UI5_cx_ajson_error.
    methods set_null for testing raising z2UI5_cx_ajson_error.
    methods set_obj for testing raising z2UI5_cx_ajson_error.
    methods set_array for testing raising z2UI5_cx_ajson_error.
    methods set_complex_obj for testing raising z2UI5_cx_ajson_error.
    methods set_include_with_suffix for testing raising z2UI5_cx_ajson_error.
    methods prefix for testing raising z2UI5_cx_ajson_error.

endclass.

class z2ui5_cl_ajson definition local friends ltcl_abap_to_json.

class ltcl_abap_to_json implementation.

  method set_ajson.

    data lo_nodes type ref to lcl_nodes_helper.
    data lo_src type ref to z2ui5_cl_ajson.
    lo_src = z2ui5_cl_ajson=>create_empty( ).

    create object lo_nodes.
    lo_nodes->add( '        |      |object |     ||1' ).
    lo_nodes->add( '/       |a     |object |     ||1' ).
    lo_nodes->add( '/a/     |b     |object |     ||1' ).
    lo_nodes->add( '/a/b/   |c     |object |     ||0' ).
    lo_src->mt_json_tree = lo_nodes->mt_nodes.

    data lt_nodes type z2ui5_if_ajson_types=>ty_nodes_tt.
    lt_nodes = lcl_abap_to_json=>convert( iv_data = lo_src ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_nodes
      exp = lo_nodes->mt_nodes ).

  endmethod.

  method set_value_number.

    data lo_nodes_exp type ref to lcl_nodes_helper.
    data lt_nodes type z2ui5_if_ajson_types=>ty_nodes_tt.

    " number
    create object lo_nodes_exp.
    lo_nodes_exp->add( '        |      |num |1     ||' ).

    lt_nodes = lcl_abap_to_json=>convert( iv_data = 1 ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_nodes
      exp = lo_nodes_exp->mt_nodes ).

  endmethod.

  method set_value_string.

    data lo_nodes_exp type ref to lcl_nodes_helper.
    data lt_nodes type z2ui5_if_ajson_types=>ty_nodes_tt.

    " string
    create object lo_nodes_exp.
    lo_nodes_exp->add( '        |      |str |abc     ||' ).

    lt_nodes = lcl_abap_to_json=>convert( iv_data = 'abc' ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_nodes
      exp = lo_nodes_exp->mt_nodes ).

  endmethod.

  method set_value_true.

    data lo_nodes_exp type ref to lcl_nodes_helper.
    data lt_nodes type z2ui5_if_ajson_types=>ty_nodes_tt.

    " true
    create object lo_nodes_exp.
    lo_nodes_exp->add( '        |      |bool |true     ||' ).

    lt_nodes = lcl_abap_to_json=>convert( iv_data = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_nodes
      exp = lo_nodes_exp->mt_nodes ).

  endmethod.

  method set_value_false.

    data lo_nodes_exp type ref to lcl_nodes_helper.
    data lt_nodes type z2ui5_if_ajson_types=>ty_nodes_tt.

    " false
    create object lo_nodes_exp.
    lo_nodes_exp->add( '        |      |bool |false    ||' ).

    lt_nodes = lcl_abap_to_json=>convert( iv_data = abap_false ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_nodes
      exp = lo_nodes_exp->mt_nodes ).

  endmethod.

  method set_value_xsdboolean.

    data lo_nodes_exp type ref to lcl_nodes_helper.
    data lt_nodes type z2ui5_if_ajson_types=>ty_nodes_tt.

    data lv_xsdboolean type xsdboolean.
    create object lo_nodes_exp.
    lo_nodes_exp->add( '        |      |bool |true     ||' ).

    lv_xsdboolean = 'X'.
    lt_nodes = lcl_abap_to_json=>convert( iv_data = lv_xsdboolean ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_nodes
      exp = lo_nodes_exp->mt_nodes ).

  endmethod.

  method set_null.

    data lo_nodes_exp type ref to lcl_nodes_helper.
    data lt_nodes type z2ui5_if_ajson_types=>ty_nodes_tt.
    data lv_null_ref type ref to data.

    " null
    create object lo_nodes_exp.
    lo_nodes_exp->add( '       |      |null |null ||' ).

    lt_nodes = lcl_abap_to_json=>convert( iv_data = lv_null_ref ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_nodes
      exp = lo_nodes_exp->mt_nodes ).

  endmethod.

  method set_value_timestamp.

    data lo_nodes_exp type ref to lcl_nodes_helper.
    data lt_nodes type z2ui5_if_ajson_types=>ty_nodes_tt.
    data lv_timezone type timezone value ''.

    data lv_timestamp type timestamp.
    create object lo_nodes_exp.
    lo_nodes_exp->add( '        |      |str |2022-08-31T00:00:00Z||' ).

    convert date '20220831' time '000000'
      into time stamp lv_timestamp time zone lv_timezone.
    lt_nodes = lcl_abap_to_json=>convert( lcl_abap_to_json=>format_timestamp( lv_timestamp ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_nodes
      exp = lo_nodes_exp->mt_nodes ).

  endmethod.

  method set_value_timestamp_initial.

    data lo_nodes_exp type ref to lcl_nodes_helper.
    data lt_nodes type z2ui5_if_ajson_types=>ty_nodes_tt.

    data lv_timestamp type timestamp.
    create object lo_nodes_exp.
    lo_nodes_exp->add( '        |      |str |0000-00-00T00:00:00Z||' ).

    lv_timestamp = 0.
    lt_nodes = lcl_abap_to_json=>convert( lcl_abap_to_json=>format_timestamp( lv_timestamp ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_nodes
      exp = lo_nodes_exp->mt_nodes ).

  endmethod.

  method prefix.

    data lo_nodes_exp type ref to lcl_nodes_helper.
    data lt_nodes type z2ui5_if_ajson_types=>ty_nodes_tt.
    data ls_prefix type z2ui5_if_ajson_types=>ty_path_name.

    ls_prefix-path = '/a/'.
    ls_prefix-name = 'b'.
    create object lo_nodes_exp.
    lo_nodes_exp->add( '/a/       |b     |num |1     ||' ).

    lt_nodes = lcl_abap_to_json=>convert(
      iv_data   = 1
      is_prefix = ls_prefix ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_nodes
      exp = lo_nodes_exp->mt_nodes ).

  endmethod.

  method set_obj.

    data lo_nodes_exp type ref to lcl_nodes_helper.
    data ls_struc type ty_struc.
    data lt_nodes type z2ui5_if_ajson_types=>ty_nodes_tt.

    ls_struc-a = 'abc'.
    ls_struc-b = 10.
    ls_struc-c = abap_true.
    ls_struc-d = 'X'.

    create object lo_nodes_exp.
    lo_nodes_exp->add( '       |      |object |     ||4' ).
    lo_nodes_exp->add( '/      |a     |str    |abc  ||0' ).
    lo_nodes_exp->add( '/      |b     |num    |10   ||0' ).
    lo_nodes_exp->add( '/      |c     |bool   |true ||0' ).
    lo_nodes_exp->add( '/      |d     |bool   |true ||0' ).

    lt_nodes = lcl_abap_to_json=>convert( iv_data = ls_struc ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_nodes
      exp = lo_nodes_exp->mt_nodes ).

  endmethod.

  method set_complex_obj.

    data lo_nodes_exp type ref to lcl_nodes_helper.
    data ls_struc type ty_struc_complex.
    data lt_nodes type z2ui5_if_ajson_types=>ty_nodes_tt.
    field-symbols <i> like line of ls_struc-tab.

    ls_struc-a = 'abc'.
    ls_struc-b = 10.
    ls_struc-c = abap_true.
    ls_struc-d = 'X'.
    ls_struc-el = 'elem'.

    ls_struc-struc-a = 'deep'.
    ls_struc-struc-b = 123.

    append 'hello' to ls_struc-stab.
    append 'world' to ls_struc-stab.

    append initial line to ls_struc-tab assigning <i>.
    <i>-a = 'abc'.
    append initial line to ls_struc-tab assigning <i>.
    <i>-a = 'bcd'.

    create object lo_nodes_exp.
    lo_nodes_exp->add( '       |      |object |     ||8' ).
    lo_nodes_exp->add( '/      |a     |str    |abc  ||0' ).
    lo_nodes_exp->add( '/      |b     |num    |10   ||0' ).
    lo_nodes_exp->add( '/      |c     |bool   |true ||0' ).
    lo_nodes_exp->add( '/      |d     |bool   |true ||0' ).
    lo_nodes_exp->add( '/      |el    |str    |elem ||0' ).
    lo_nodes_exp->add( '/      |struc |object |     ||4' ).
    lo_nodes_exp->add( '/struc/|a     |str    |deep ||0' ).
    lo_nodes_exp->add( '/struc/|b     |num    |123  ||0' ).
    lo_nodes_exp->add( '/struc/|c     |bool   |false||0' ).
    lo_nodes_exp->add( '/struc/|d     |bool   |false||0' ).

    lo_nodes_exp->add( '/      |tab   |array  |     | |2' ).
    lo_nodes_exp->add( '/tab/  |1     |object |     |1|4' ).
    lo_nodes_exp->add( '/tab/1/|a     |str    |abc  | |0' ).
    lo_nodes_exp->add( '/tab/1/|b     |num    |0    | |0' ).
    lo_nodes_exp->add( '/tab/1/|c     |bool   |false| |0' ).
    lo_nodes_exp->add( '/tab/1/|d     |bool   |false| |0' ).
    lo_nodes_exp->add( '/tab/  |2     |object |     |2|4' ).
    lo_nodes_exp->add( '/tab/2/|a     |str    |bcd  | |0' ).
    lo_nodes_exp->add( '/tab/2/|b     |num    |0    | |0' ).
    lo_nodes_exp->add( '/tab/2/|c     |bool   |false| |0' ).
    lo_nodes_exp->add( '/tab/2/|d     |bool   |false| |0' ).

    lo_nodes_exp->add( '/      |stab  |array  |     | |2' ).
    lo_nodes_exp->add( '/stab/ |1     |str    |hello|1|0' ).
    lo_nodes_exp->add( '/stab/ |2     |str    |world|2|0' ).

    lt_nodes = lcl_abap_to_json=>convert( iv_data = ls_struc ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_nodes
      exp = lo_nodes_exp->mt_nodes ).

  endmethod.

  method set_include_with_suffix.

    data lo_nodes_exp type ref to lcl_nodes_helper.
    data ls_struc type ty_named_include.
    data lt_nodes type z2ui5_if_ajson_types=>ty_nodes_tt.

    ls_struc-a_suf = 'abc'.
    ls_struc-b_suf = 10.
    ls_struc-c_suf = abap_true.
    ls_struc-d_suf = 'X'.
    ls_struc-el    = 'elem'.

    create object lo_nodes_exp.
    lo_nodes_exp->add( '       |      |object |     ||5' ).
    lo_nodes_exp->add( '/      |a_suf |str    |abc  ||0' ).
    lo_nodes_exp->add( '/      |b_suf |num    |10   ||0' ).
    lo_nodes_exp->add( '/      |c_suf |bool   |true ||0' ).
    lo_nodes_exp->add( '/      |d_suf |bool   |true ||0' ).
    lo_nodes_exp->add( '/      |el    |str    |elem ||0' ).

    lt_nodes = lcl_abap_to_json=>convert( iv_data = ls_struc ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_nodes
      exp = lo_nodes_exp->mt_nodes ).

  endmethod.

  method set_array.

    data lo_nodes_exp type ref to lcl_nodes_helper.
    data lt_nodes type z2ui5_if_ajson_types=>ty_nodes_tt.

    data lt_tab type table of ty_struc.
    field-symbols <s> like line of lt_tab.

    append initial line to lt_tab assigning <s>.
    <s>-a = 'abc'.
    <s>-b = 10.
    append initial line to lt_tab assigning <s>.
    <s>-a = 'bcd'.
    <s>-b = 20.

    create object lo_nodes_exp.
    lo_nodes_exp->add( '       |      |array  |     | |2' ).
    lo_nodes_exp->add( '/      |1     |object |     |1|4' ).
    lo_nodes_exp->add( '/1/    |a     |str    |abc  | |0' ).
    lo_nodes_exp->add( '/1/    |b     |num    |10   | |0' ).
    lo_nodes_exp->add( '/1/    |c     |bool   |false| |0' ).
    lo_nodes_exp->add( '/1/    |d     |bool   |false| |0' ).
    lo_nodes_exp->add( '/      |2     |object |     |2|4' ).
    lo_nodes_exp->add( '/2/    |a     |str    |bcd  | |0' ).
    lo_nodes_exp->add( '/2/    |b     |num    |20   | |0' ).
    lo_nodes_exp->add( '/2/    |c     |bool   |false| |0' ).
    lo_nodes_exp->add( '/2/    |d     |bool   |false| |0' ).

    lt_nodes = lcl_abap_to_json=>convert( iv_data = lt_tab ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_nodes
      exp = lo_nodes_exp->mt_nodes ).

    data lt_strtab type string_table.
    append 'abc' to lt_strtab.
    append 'bcd' to lt_strtab.

    create object lo_nodes_exp.
    lo_nodes_exp->add( '       |      |array  |     | |2' ).
    lo_nodes_exp->add( '/      |1     |str    |abc  |1|0' ).
    lo_nodes_exp->add( '/      |2     |str    |bcd  |2|0' ).

    lt_nodes = lcl_abap_to_json=>convert( iv_data = lt_strtab ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_nodes
      exp = lo_nodes_exp->mt_nodes ).

  endmethod.

endclass.

**********************************************************************
* FILTER TEST
**********************************************************************

class ltcl_filter_test definition final
  for testing
  duration short
  risk level harmless.

  public section.
    interfaces z2ui5_if_ajson_filter.

  private section.

    types:
      begin of ty_visit_history,
        path type string,
        type type z2ui5_if_ajson_filter=>ty_visit_type,
      end of ty_visit_history.

    data mt_visit_history type table of ty_visit_history.

    methods simple_test for testing raising z2UI5_cx_ajson_error.
    methods array_test for testing raising z2UI5_cx_ajson_error.
    methods visit_types for testing raising z2UI5_cx_ajson_error.


endclass.

class ltcl_filter_test implementation.

  method z2ui5_if_ajson_filter~keep_node.

    data ls_visit_history like line of mt_visit_history.

    if iv_visit > 0.
      ls_visit_history-type = iv_visit.
      ls_visit_history-path = is_node-path && is_node-name && '/'.
      append ls_visit_history to mt_visit_history.
    endif.

    rv_keep = boolc( not is_node-name ca 'xX' and not is_node-value ca 'xX' ).

  endmethod.

  method simple_test.

    data lo_json type ref to z2ui5_cl_ajson.
    data lo_json_filtered type ref to z2ui5_cl_ajson.
    data lo_nodes_exp type ref to lcl_nodes_helper.

    lo_json = z2ui5_cl_ajson=>create_empty( ).
    lo_json->set(
      iv_path = '/a'
      iv_val  = 1 ).
    lo_json->set(
      iv_path = '/b'
      iv_val  = 1 ).
    lo_json->set(
      iv_path = '/x'
      iv_val  = 1 ).
    lo_json->set(
      iv_path = '/c/x'
      iv_val  = 1 ).
    lo_json->set(
      iv_path = '/c/y'
      iv_val  = 1 ).

    lo_json_filtered = z2ui5_cl_ajson=>create_from(
      ii_source_json = lo_json
      ii_filter      = me ).

    create object lo_nodes_exp.
    lo_nodes_exp->add( '       |      |object |     | |3' ).
    lo_nodes_exp->add( '/      |a     |num    |1    | |0' ).
    lo_nodes_exp->add( '/      |b     |num    |1    | |0' ).
    lo_nodes_exp->add( '/      |c     |object |     | |1' ).
    lo_nodes_exp->add( '/c/    |y     |num    |1    | |0' ).

    cl_abap_unit_assert=>assert_equals(
      act = lo_json_filtered->mt_json_tree
      exp = lo_nodes_exp->sorted( ) ).

  endmethod.

  method array_test.

    data lo_json type ref to z2ui5_cl_ajson.
    data lo_json_filtered type ref to z2ui5_cl_ajson.
    data lo_nodes_exp type ref to lcl_nodes_helper.

    lo_json = z2ui5_cl_ajson=>create_empty( ).
    lo_json->touch_array( '/' ).
    lo_json->push(
      iv_path = '/'
      iv_val  = 'a' ).
    lo_json->push(
      iv_path = '/'
      iv_val  = 'x' ).
    lo_json->push(
      iv_path = '/'
      iv_val  = 'b' ).

    lo_json_filtered = z2ui5_cl_ajson=>create_from(
      ii_source_json = lo_json
      ii_filter      = me ).

    create object lo_nodes_exp.
    lo_nodes_exp->add( '       |      |array  |     | |2' ).
    lo_nodes_exp->add( '/      |1     |str    |a    |1|0' ).
    lo_nodes_exp->add( '/      |2     |str    |b    |2|0' ).

    cl_abap_unit_assert=>assert_equals(
      act = lo_json_filtered->mt_json_tree
      exp = lo_nodes_exp->sorted( ) ).

  endmethod.

  method visit_types.

    data lo_json type ref to z2ui5_cl_ajson.
    data lo_json_filtered type ref to z2ui5_cl_ajson.

    data lt_visits_exp like mt_visit_history.
    field-symbols <v> like line of lt_visits_exp.

    data:
      begin of ls_dummy,
        d type i value 10,
        e type i value 20,
      end of ls_dummy.

    clear mt_visit_history.

    lo_json = z2ui5_cl_ajson=>create_empty( ).
    lo_json->touch_array( '/' ).
    lo_json->push(
      iv_path = '/'
      iv_val  = 'a' ).
    lo_json->push(
      iv_path = '/'
      iv_val  = 'b' ).
    lo_json->push(
      iv_path = '/'
      iv_val  = ls_dummy ).

    lo_json_filtered = z2ui5_cl_ajson=>create_from(
      ii_source_json = lo_json
      ii_filter      = me ).

    append initial line to lt_visits_exp assigning <v>.
    <v>-path = '/'.
    <v>-type = z2ui5_if_ajson_filter=>visit_type-open.
    append initial line to lt_visits_exp assigning <v>.
    <v>-path = '/3/'.
    <v>-type = z2ui5_if_ajson_filter=>visit_type-open.
    append initial line to lt_visits_exp assigning <v>.
    <v>-path = '/3/'.
    <v>-type = z2ui5_if_ajson_filter=>visit_type-close.
    append initial line to lt_visits_exp assigning <v>.
    <v>-path = '/'.
    <v>-type = z2ui5_if_ajson_filter=>visit_type-close.

    cl_abap_unit_assert=>assert_equals(
      act = mt_visit_history
      exp = lt_visits_exp ).

  endmethod.

endclass.

**********************************************************************
* MAPPER TEST
**********************************************************************

class ltcl_mapper_test definition final
  for testing
  duration short
  risk level harmless.

  public section.
    interfaces z2ui5_if_ajson_mapping.

  private section.

    methods simple_test for testing raising z2UI5_cx_ajson_error.
    methods array_test for testing raising z2UI5_cx_ajson_error.
    methods duplication_test for testing raising z2UI5_cx_ajson_error.
    methods empty_name_test for testing raising z2UI5_cx_ajson_error.
    methods trivial for testing raising z2UI5_cx_ajson_error.

endclass.

class ltcl_mapper_test implementation.

  method z2ui5_if_ajson_mapping~rename_node.
    if cv_name+0(1) = 'a'.
      cv_name = to_upper( cv_name ).
    endif.
    if cv_name = 'set_this_empty'.
      clear cv_name.
    endif.
    " watch dog for array
    if is_node-index <> 0.
      cl_abap_unit_assert=>fail( 'rename must not be called for direct array items' ).
    endif.
  endmethod.

  method z2ui5_if_ajson_mapping~to_abap.
  endmethod.

  method z2ui5_if_ajson_mapping~to_json.
  endmethod.

  method simple_test.

    data lo_json type ref to z2ui5_cl_ajson.
    data lo_json_filtered type ref to z2ui5_cl_ajson.
    data lo_nodes_exp type ref to lcl_nodes_helper.

    lo_json = z2ui5_cl_ajson=>create_empty( ).
    lo_json->set(
      iv_path = '/ab'
      iv_val  = 1 ).
    lo_json->set(
      iv_path = '/bc'
      iv_val  = 2 ).
    lo_json->set(
      iv_path = '/c/ax'
      iv_val  = 3 ).
    lo_json->set(
      iv_path = '/c/by'
      iv_val  = 4 ).
    lo_json->set(
      iv_path = '/a/ax'
      iv_val  = 5 ).
    lo_json->set(
      iv_path = '/a/by'
      iv_val  = 6 ).

    lo_json_filtered = z2ui5_cl_ajson=>create_from(
      ii_source_json = lo_json
      ii_mapper      = me ).

    create object lo_nodes_exp.
    lo_nodes_exp->add( '       |      |object |     | |4' ).
    lo_nodes_exp->add( '/      |AB    |num    |1    | |0' ).
    lo_nodes_exp->add( '/      |bc    |num    |2    | |0' ).
    lo_nodes_exp->add( '/      |c     |object |     | |2' ).
    lo_nodes_exp->add( '/c/    |AX    |num    |3    | |0' ).
    lo_nodes_exp->add( '/c/    |by    |num    |4    | |0' ).
    lo_nodes_exp->add( '/      |A     |object |     | |2' ).
    lo_nodes_exp->add( '/A/    |AX    |num    |5    | |0' ).
    lo_nodes_exp->add( '/A/    |by    |num    |6    | |0' ).

    cl_abap_unit_assert=>assert_equals(
      act = lo_json_filtered->mt_json_tree
      exp = lo_nodes_exp->sorted( ) ).

  endmethod.

  method array_test.

    data lo_json type ref to z2ui5_cl_ajson.
    data lo_json_filtered type ref to z2ui5_cl_ajson.
    data lo_nodes_exp type ref to lcl_nodes_helper.

    lo_json = z2ui5_cl_ajson=>create_empty( ).
    lo_json->touch_array( iv_path = '/' ).
    lo_json->set(
      iv_path = '/1/ab'
      iv_val  = 1 ).
    lo_json->set(
      iv_path = '/1/bc'
      iv_val  = 2 ).
    lo_json->set(
      iv_path = '/2/ax'
      iv_val  = 3 ).
    lo_json->set(
      iv_path = '/2/by'
      iv_val  = 4 ).

    lo_json_filtered = z2ui5_cl_ajson=>create_from(
      ii_source_json = lo_json
      ii_mapper      = me ).

    create object lo_nodes_exp.
    lo_nodes_exp->add( '       |      |array  |     | |2' ).
    lo_nodes_exp->add( '/      |1     |object |     |1|2' ).
    lo_nodes_exp->add( '/      |2     |object |     |2|2' ).
    lo_nodes_exp->add( '/1/    |AB    |num    |1    | |0' ).
    lo_nodes_exp->add( '/1/    |bc    |num    |2    | |0' ).
    lo_nodes_exp->add( '/2/    |AX    |num    |3    | |0' ).
    lo_nodes_exp->add( '/2/    |by    |num    |4    | |0' ).

    cl_abap_unit_assert=>assert_equals(
      act = lo_json_filtered->mt_json_tree
      exp = lo_nodes_exp->sorted( ) ).
  endmethod.

  method duplication_test.

    data lo_json type ref to z2ui5_cl_ajson.
    data lx_err type ref to z2UI5_cx_ajson_error.

    lo_json = z2ui5_cl_ajson=>create_empty( ).
    lo_json->set(
      iv_path = '/ab'
      iv_val  = 1 ).
    lo_json->set(
      iv_path = '/AB'
      iv_val  = 2 ).

    try.
      z2ui5_cl_ajson=>create_from(
        ii_source_json = lo_json
        ii_mapper      = me ).
      cl_abap_unit_assert=>fail( ).
    catch z2UI5_cx_ajson_error into lx_err.
      cl_abap_unit_assert=>assert_char_cp(
        act = lx_err->get_text( )
        exp = 'Renamed node has a duplicate @/AB' ).
    endtry.

  endmethod.

  method trivial.

    data lo_json type ref to z2ui5_cl_ajson.
    data lo_json_filtered type ref to z2ui5_cl_ajson.
    data lo_nodes_exp type ref to lcl_nodes_helper.

    lo_json = z2ui5_cl_ajson=>create_empty( ).
    lo_json_filtered = z2ui5_cl_ajson=>create_from(
      ii_source_json = lo_json
      ii_mapper      = me ).
    cl_abap_unit_assert=>assert_initial( lo_json_filtered->mt_json_tree ).

    lo_json->set(
      iv_path = '/'
      iv_val  = 1 ).
    lo_json_filtered = z2ui5_cl_ajson=>create_from(
      ii_source_json = lo_json
      ii_mapper      = me ).

    create object lo_nodes_exp.
    lo_nodes_exp->add( '       |      |num    |1    | |0' ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_json_filtered->mt_json_tree
      exp = lo_nodes_exp->sorted( ) ).

  endmethod.

  method empty_name_test.

    data lo_json type ref to z2ui5_cl_ajson.
    data lx_err type ref to z2UI5_cx_ajson_error.

    lo_json = z2ui5_cl_ajson=>create_empty( ).
    lo_json->set(
      iv_path = '/set_this_empty'
      iv_val  = 1 ).

    try.
      z2ui5_cl_ajson=>create_from(
        ii_source_json = lo_json
        ii_mapper      = me ).
      cl_abap_unit_assert=>fail( ).
    catch z2UI5_cx_ajson_error into lx_err.
      cl_abap_unit_assert=>assert_char_cp(
        act = lx_err->get_text( )
        exp = 'Renamed node name cannot be empty @/set_this_empty' ).
    endtry.

  endmethod.

endclass.

**********************************************************************
* CLONING TEST
**********************************************************************

class ltcl_cloning_test definition final
  for testing
  duration short
  risk level harmless.

  public section.
    interfaces z2ui5_if_ajson_mapping.
    interfaces z2ui5_if_ajson_filter.

  private section.

    methods clone_test for testing raising z2UI5_cx_ajson_error.
    methods filter_test for testing raising z2UI5_cx_ajson_error.
    methods mapper_test for testing raising z2UI5_cx_ajson_error.
    methods mapper_and_filter for testing raising z2UI5_cx_ajson_error.
    methods opts_copying for testing raising z2UI5_cx_ajson_error.

endclass.

class ltcl_cloning_test implementation.

  method clone_test.

    data li_json type ref to z2ui5_if_ajson.
    data li_json_new type ref to z2ui5_if_ajson.
    data lo_nodes_exp type ref to lcl_nodes_helper.

    li_json = z2ui5_cl_ajson=>create_empty( ).
    li_json->set(
      iv_path = '/ab'
      iv_val  = 1 ).
    li_json->set(
      iv_path = '/xy'
      iv_val  = 2 ).

    li_json_new = li_json->clone( ).

    create object lo_nodes_exp.
    lo_nodes_exp->add( '       |      |object |     | |2' ).
    lo_nodes_exp->add( '/      |ab    |num    |1    | |0' ).
    lo_nodes_exp->add( '/      |xy    |num    |2    | |0' ).

    cl_abap_unit_assert=>assert_equals(
      act = li_json->mt_json_tree
      exp = lo_nodes_exp->sorted( ) ).
    cl_abap_unit_assert=>assert_equals(
      act = li_json_new->mt_json_tree
      exp = lo_nodes_exp->sorted( ) ).

    " ensure disconnection
    li_json->set(
      iv_path = '/ab'
      iv_val  = 5 ).
    cl_abap_unit_assert=>assert_equals(
      act = li_json->get_integer( '/ab' )
      exp = 5 ).
    cl_abap_unit_assert=>assert_equals(
      act = li_json_new->get_integer( '/ab' )
      exp = 1 ).

  endmethod.

  method filter_test.

    data li_json type ref to z2ui5_if_ajson.
    data li_json_new type ref to z2ui5_if_ajson.
    data lo_nodes_exp type ref to lcl_nodes_helper.

    li_json = z2ui5_cl_ajson=>create_empty( ).
    li_json->set(
      iv_path = '/ab'
      iv_val  = 1 ).
    li_json->set(
      iv_path = '/xy'
      iv_val  = 2 ).

    li_json_new = li_json->filter( me ).

    create object lo_nodes_exp.
    lo_nodes_exp->add( '       |      |object |     | |1' ).
    lo_nodes_exp->add( '/      |ab    |num    |1    | |0' ).

    cl_abap_unit_assert=>assert_equals(
      act = li_json_new->mt_json_tree
      exp = lo_nodes_exp->sorted( ) ).

  endmethod.

  method mapper_test.

    data li_json type ref to z2ui5_if_ajson.
    data li_json_new type ref to z2ui5_if_ajson.
    data lo_nodes_exp type ref to lcl_nodes_helper.

    li_json = z2ui5_cl_ajson=>create_empty( ).
    li_json->set(
      iv_path = '/ab'
      iv_val  = 1 ).
    li_json->set(
      iv_path = '/xy'
      iv_val  = 2 ).

    li_json_new = li_json->map( me ).

    create object lo_nodes_exp.
    lo_nodes_exp->add( '       |      |object |     | |2' ).
    lo_nodes_exp->add( '/      |AB    |num    |1    | |0' ).
    lo_nodes_exp->add( '/      |xy    |num    |2    | |0' ).

    cl_abap_unit_assert=>assert_equals(
      act = li_json_new->mt_json_tree
      exp = lo_nodes_exp->sorted( ) ).

  endmethod.

  method z2ui5_if_ajson_mapping~rename_node.
    if cv_name+0(1) = 'a'.
      cv_name = to_upper( cv_name ).
    endif.
  endmethod.

  method z2ui5_if_ajson_mapping~to_abap.

  endmethod.

  method z2ui5_if_ajson_mapping~to_json.

  endmethod.

  method z2ui5_if_ajson_filter~keep_node.
    rv_keep = boolc( is_node-name is initial or is_node-name+0(1) <> 'x' ).
  endmethod.

  method mapper_and_filter.

    data li_json type ref to z2ui5_if_ajson.
    data li_json_new type ref to z2ui5_if_ajson.
    data lo_nodes_exp type ref to lcl_nodes_helper.

    li_json = z2ui5_cl_ajson=>new( ).
    li_json->set(
      iv_path = '/ab'
      iv_val  = 1 ).
    li_json->set(
      iv_path = '/bc'
      iv_val  = 2 ).
    li_json->set(
      iv_path = '/xy'
      iv_val  = 3 ).

    li_json_new = z2ui5_cl_ajson=>create_from(
      ii_source_json = li_json
      ii_filter = me
      ii_mapper = me ).

    create object lo_nodes_exp.
    lo_nodes_exp->add( '       |      |object |     | |2' ).
    lo_nodes_exp->add( '/      |AB    |num    |1    | |0' ).
    lo_nodes_exp->add( '/      |bc    |num    |2    | |0' ).

    cl_abap_unit_assert=>assert_equals(
      act = li_json_new->mt_json_tree
      exp = lo_nodes_exp->sorted( ) ).

  endmethod.

  method opts_copying.

    data li_json type ref to z2ui5_if_ajson.
    data li_json_new type ref to z2ui5_if_ajson.

    li_json = z2ui5_cl_ajson=>new( )->keep_item_order( ).
    li_json->set(
      iv_path = '/ab'
      iv_val  = 1 ).

    li_json_new = li_json->clone( ).

    cl_abap_unit_assert=>assert_equals(
      act = li_json_new->opts( )-keep_item_order
      exp = abap_true ).

  endmethod.

endclass.
