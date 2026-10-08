CLASS ltcl_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    DATA mi_filter TYPE REF TO z2ui5_if_ajson_filter.

    METHODS setup.

    METHODS keep_node
      IMPORTING
        iv_type        TYPE z2ui5_if_ajson_types=>ty_node_type OPTIONAL
        iv_value       TYPE string                             OPTIONAL
        iv_children    TYPE i                                  OPTIONAL
        iv_visit       TYPE z2ui5_if_ajson_filter=>ty_visit_type DEFAULT z2ui5_if_ajson_filter=>visit_type-value
      RETURNING
        VALUE(rv_keep) TYPE abap_bool
      RAISING
        z2ui5_cx_ajson_error.

    METHODS test_factory              FOR TESTING RAISING cx_static_check.
    METHODS test_keeps_filled_string  FOR TESTING RAISING cx_static_check.
    METHODS test_drops_empty_string   FOR TESTING RAISING cx_static_check.
    METHODS test_keeps_number         FOR TESTING RAISING cx_static_check.
    METHODS test_drops_zero           FOR TESTING RAISING cx_static_check.
    METHODS test_drops_zero_decimals  FOR TESTING RAISING cx_static_check.
    METHODS test_keeps_small_number   FOR TESTING RAISING cx_static_check.
    METHODS test_keeps_true           FOR TESTING RAISING cx_static_check.
    METHODS test_drops_false          FOR TESTING RAISING cx_static_check.
    METHODS test_keeps_filled_object  FOR TESTING RAISING cx_static_check.
    METHODS test_drops_empty_object   FOR TESTING RAISING cx_static_check.
    METHODS test_keeps_on_open_visit  FOR TESTING RAISING cx_static_check.
    METHODS test_number_initial       FOR TESTING RAISING cx_static_check.
    METHODS test_escape_controls      FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_test IMPLEMENTATION.

  METHOD setup.

    mi_filter = z2ui5_cl_ui5_util_json_fl=>create_no_empty_values( ).

  ENDMETHOD.

  METHOD keep_node.

    rv_keep = mi_filter->keep_node(
        is_node  = VALUE #( type     = iv_type
                            value    = iv_value
                            children = iv_children )
        iv_visit = iv_visit ).

  ENDMETHOD.

  METHOD test_number_initial.

    " every spelling of zero is initial, anything with a non-zero digit is
    " not - the predicate this filter and the client's local filters share
    cl_abap_unit_assert=>assert_true( z2ui5_cl_ui5_util_json_fl=>check_number_initial( `0` ) ).
    cl_abap_unit_assert=>assert_true( z2ui5_cl_ui5_util_json_fl=>check_number_initial( `0.00` ) ).
    cl_abap_unit_assert=>assert_true( z2ui5_cl_ui5_util_json_fl=>check_number_initial( `0.0E+00` ) ).
    cl_abap_unit_assert=>assert_true( z2ui5_cl_ui5_util_json_fl=>check_number_initial( `-0` ) ).
    cl_abap_unit_assert=>assert_false( z2ui5_cl_ui5_util_json_fl=>check_number_initial( `0.01` ) ).
    cl_abap_unit_assert=>assert_false( z2ui5_cl_ui5_util_json_fl=>check_number_initial( `-1` ) ).
    cl_abap_unit_assert=>assert_false( z2ui5_cl_ui5_util_json_fl=>check_number_initial( `1.0E+02` ) ).

  ENDMETHOD.

  METHOD test_factory.

    cl_abap_unit_assert=>assert_bound( mi_filter ).

  ENDMETHOD.

  METHOD test_keeps_filled_string.

    cl_abap_unit_assert=>assert_true( keep_node( iv_type  = z2ui5_if_ajson_types=>node_type-string
                                                 iv_value = `abc` ) ).

  ENDMETHOD.

  METHOD test_drops_empty_string.

    cl_abap_unit_assert=>assert_false( keep_node( iv_type  = z2ui5_if_ajson_types=>node_type-string
                                                  iv_value = `` ) ).

  ENDMETHOD.

  METHOD test_keeps_number.

    cl_abap_unit_assert=>assert_true( keep_node( iv_type  = z2ui5_if_ajson_types=>node_type-number
                                                 iv_value = `42` ) ).

  ENDMETHOD.

  METHOD test_drops_zero.

    cl_abap_unit_assert=>assert_false( keep_node( iv_type  = z2ui5_if_ajson_types=>node_type-number
                                                  iv_value = `0` ) ).

  ENDMETHOD.

  METHOD test_drops_zero_decimals.

    " a packed field with decimals and a float serialize their zero with a
    " fraction / an exponent - still initial
    cl_abap_unit_assert=>assert_false( keep_node( iv_type  = z2ui5_if_ajson_types=>node_type-number
                                                  iv_value = `0.00` ) ).
    cl_abap_unit_assert=>assert_false( keep_node( iv_type  = z2ui5_if_ajson_types=>node_type-number
                                                  iv_value = `0.0E+00` ) ).

  ENDMETHOD.

  METHOD test_keeps_small_number.

    cl_abap_unit_assert=>assert_true( keep_node( iv_type  = z2ui5_if_ajson_types=>node_type-number
                                                 iv_value = `0.01` ) ).
    cl_abap_unit_assert=>assert_true( keep_node( iv_type  = z2ui5_if_ajson_types=>node_type-number
                                                 iv_value = `-1` ) ).

  ENDMETHOD.

  METHOD test_keeps_true.

    cl_abap_unit_assert=>assert_true( keep_node( iv_type  = z2ui5_if_ajson_types=>node_type-boolean
                                                 iv_value = `true` ) ).

  ENDMETHOD.

  METHOD test_drops_false.

    cl_abap_unit_assert=>assert_false( keep_node( iv_type  = z2ui5_if_ajson_types=>node_type-boolean
                                                  iv_value = `false` ) ).

  ENDMETHOD.

  METHOD test_keeps_filled_object.

    cl_abap_unit_assert=>assert_true( keep_node( iv_children = 3
                                                 iv_visit    = z2ui5_if_ajson_filter=>visit_type-close ) ).

  ENDMETHOD.

  METHOD test_drops_empty_object.

    cl_abap_unit_assert=>assert_false( keep_node( iv_children = 0
                                                  iv_visit    = z2ui5_if_ajson_filter=>visit_type-close ) ).

  ENDMETHOD.

  METHOD test_keeps_on_open_visit.

    cl_abap_unit_assert=>assert_true( keep_node( iv_type  = z2ui5_if_ajson_types=>node_type-string
                                                 iv_value = ``
                                                 iv_visit = z2ui5_if_ajson_filter=>visit_type-open ) ).

  ENDMETHOD.

  METHOD test_escape_controls.

    " a bound string carrying U+0001 and a form feed, serialized the way
    " every model is: ajson leaves both raw, which JSON.parse refuses
    DATA(lv_ctrl) = z2ui5_cl_ui5_util_context=>conv_get_string_by_xstring( CONV xstring( `010C1F` ) ).
    DATA(lv_json) = z2ui5_cl_ajson=>create_empty( )->set( iv_path = `/NAME`
                                                         iv_val   = `a` && lv_ctrl && `b` )->stringify( ).

    DATA(lv_act) = z2ui5_cl_ui5_util_json_fl=>escape_controls( lv_json ).

    cl_abap_unit_assert=>assert_equals( exp = `{"NAME":"a\u0001\u000C\u001Fb"}`
                                        act = lv_act ).
    cl_abap_unit_assert=>assert_false( xsdbool( lv_act CA lv_ctrl ) ).

    " tab, LF, CR and an escaped backslash are ajson's own and stay as they are
    lv_json = z2ui5_cl_ajson=>create_empty( )->set(
        iv_path = `/NAME`
        iv_val  = `x\u0001` && z2ui5_cl_ui5_util_context=>cv_char_util_horizontal_tab
                  && z2ui5_cl_ui5_util_context=>cv_char_util_newline )->stringify( ).
    cl_abap_unit_assert=>assert_equals( exp = lv_json
                                        act = z2ui5_cl_ui5_util_json_fl=>escape_controls( lv_json ) ).

  ENDMETHOD.

ENDCLASS.
