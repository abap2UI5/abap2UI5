CLASS ltcl_test_json DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_get_string      FOR TESTING RAISING cx_static_check.
    METHODS test_get_integer     FOR TESTING RAISING cx_static_check.
    METHODS test_get_boolean     FOR TESTING RAISING cx_static_check.
    METHODS test_exists          FOR TESTING RAISING cx_static_check.
    METHODS test_members_object  FOR TESTING RAISING cx_static_check.
    METHODS test_array_iteration FOR TESTING RAISING cx_static_check.
    METHODS test_missing_path    FOR TESTING RAISING cx_static_check.
    METHODS test_invalid_json    FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_test_json IMPLEMENTATION.

  METHOD test_get_string.

    DATA(lo_json) = z2ui5_cl_ui5_json=>factory(
        `{"name":"Notebook","price":1249.5,"active":true}` ).

    cl_abap_unit_assert=>assert_equals( exp = `Notebook`
                                        act = lo_json->get_string( `/name` ) ).

    " numbers and booleans arrive as their raw JSON text
    cl_abap_unit_assert=>assert_equals( exp = `1249.5`
                                        act = lo_json->get_string( `/price` ) ).

  ENDMETHOD.

  METHOD test_get_integer.

    DATA(lo_json) = z2ui5_cl_ui5_json=>factory( `{"qty":7,"label":"7"}` ).

    cl_abap_unit_assert=>assert_equals( exp = 7
                                        act = lo_json->get_integer( `/qty` ) ).

    " a number sent as a STRING is not a JSON number - get_string reads it
    cl_abap_unit_assert=>assert_equals( exp = 0
                                        act = lo_json->get_integer( `/label` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `7`
                                        act = lo_json->get_string( `/label` ) ).

  ENDMETHOD.

  METHOD test_get_boolean.

    DATA(lo_json) = z2ui5_cl_ui5_json=>factory(
        `{"active":true,"closed":false,"zero":0,"one":1,"word":"false","text":"abc","nil":null}` ).

    cl_abap_unit_assert=>assert_true( lo_json->get_boolean( `/active` ) ).
    cl_abap_unit_assert=>assert_false( lo_json->get_boolean( `/closed` ) ).
    cl_abap_unit_assert=>assert_false( lo_json->get_boolean( `/missing` ) ).

    " "abap_false when missing or not true" - a number or a string is not
    " true, whatever it says (ajson itself answers abap_true for all four)
    cl_abap_unit_assert=>assert_false( lo_json->get_boolean( `/zero` ) ).
    cl_abap_unit_assert=>assert_false( lo_json->get_boolean( `/one` ) ).
    cl_abap_unit_assert=>assert_false( lo_json->get_boolean( `/word` ) ).
    cl_abap_unit_assert=>assert_false( lo_json->get_boolean( `/text` ) ).
    cl_abap_unit_assert=>assert_false( lo_json->get_boolean( `/nil` ) ).

  ENDMETHOD.

  METHOD test_exists.

    DATA(lo_json) = z2ui5_cl_ui5_json=>factory( `{"name":"","s":{"deep":1}}` ).

    " exists( ) is what tells an absent value from an empty one
    cl_abap_unit_assert=>assert_true( lo_json->exists( `/name` ) ).
    cl_abap_unit_assert=>assert_true( lo_json->exists( `/s/deep` ) ).
    cl_abap_unit_assert=>assert_false( lo_json->exists( `/nope` ) ).

  ENDMETHOD.

  METHOD test_members_object.

    DATA(lo_json) = z2ui5_cl_ui5_json=>factory( `{"b":1,"a":2}` ).

    DATA(lt_members) = lo_json->members( `/` ).

    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( lt_members ) ).

  ENDMETHOD.

  METHOD test_array_iteration.

    DATA(lo_json) = z2ui5_cl_ui5_json=>factory(
        `{"items":[{"name":"A"},{"name":"B"},{"name":"C"}]}` ).

    " array members are the 1-based indices, in document order - the loop
    " builds each child path from them
    DATA(lt_idx) = lo_json->members( `/items` ).
    cl_abap_unit_assert=>assert_equals( exp = 3
                                        act = lines( lt_idx ) ).

    DATA(lv_names) = ``.
    LOOP AT lt_idx INTO DATA(lv_idx).
      lv_names = lv_names && lo_json->get_string( |/items/{ lv_idx }/name| ).
    ENDLOOP.

    cl_abap_unit_assert=>assert_equals( exp = `ABC`
                                        act = lv_names ).

  ENDMETHOD.

  METHOD test_missing_path.

    DATA(lo_json) = z2ui5_cl_ui5_json=>factory( `{"a":1}` ).

    " a missing path answers with the type's initial value, never a dump
    cl_abap_unit_assert=>assert_initial( lo_json->get_string( `/b/c` ) ).
    cl_abap_unit_assert=>assert_initial( lo_json->get_integer( `/b/c` ) ).
    cl_abap_unit_assert=>assert_initial( lo_json->members( `/b` ) ).

  ENDMETHOD.

  METHOD test_invalid_json.

    DATA lv_raised TYPE abap_bool.

    TRY.
        z2ui5_cl_ui5_json=>factory( `not json at all {{{` ).
      CATCH z2ui5_cx_ui5_util_error.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).

  ENDMETHOD.

ENDCLASS.


" The next class pins z2ui5_t_02 rather than this class pool. A TABL cannot
" carry a test include of its own, so - like the z2ui5_cl_ui5f_preload tests
" in z2ui5_cl_ui5_http_handler's pool - the pin lives with the nearest
" released object. The structure is the released DDIC anchor for dynamic
" types (CREATE DATA ... TYPE STANDARD TABLE OF ('Z2UI5_T_02')), so its two
" fields ARE the contract: a rename compiles nothing here and breaks every
" app that spelled them dynamically.
CLASS ltcl_test_released_ddic DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_structure_shape FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_test_released_ddic IMPLEMENTATION.

  METHOD test_structure_shape.

    DATA ls_pair TYPE z2ui5_t_02.

    ls_pair-name  = `KEY`.
    ls_pair-value = `42`.

    cl_abap_unit_assert=>assert_equals( exp = `KEY`
                                        act = ls_pair-name ).
    cl_abap_unit_assert=>assert_equals( exp = `42`
                                        act = ls_pair-value ).

  ENDMETHOD.

ENDCLASS.
