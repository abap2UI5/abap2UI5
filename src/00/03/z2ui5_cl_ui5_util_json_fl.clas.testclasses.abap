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
    METHODS test_mapper_upper         FOR TESTING RAISING cx_static_check.
    METHODS test_mapper_upper_output  FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_test IMPLEMENTATION.

  METHOD setup.

    mi_filter = z2ui5_cl_ui5_util_json_fl=>create_no_empty_values( ).

  ENDMETHOD.

  METHOD keep_node.

    DATA temp1 TYPE z2ui5_if_ajson_types=>ty_node.
    CLEAR temp1.
    temp1-type = iv_type.
    temp1-value = iv_value.
    temp1-children = iv_children.
    rv_keep = mi_filter->keep_node(
        is_node  = temp1
        iv_visit = iv_visit ).

  ENDMETHOD.

  METHOD test_number_initial.

    " every spelling of zero is initial, anything with a non-zero digit is
    " not - the predicate this filter and the client's local filters share
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = z2ui5_cl_ui5_util_json_fl=>check_number_initial( `0` ) ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = z2ui5_cl_ui5_util_json_fl=>check_number_initial( `0.00` ) ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = z2ui5_cl_ui5_util_json_fl=>check_number_initial( `0.0E+00` ) ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = z2ui5_cl_ui5_util_json_fl=>check_number_initial( `-0` ) ).
    cl_abap_unit_assert=>assert_equals( exp = abap_false act = z2ui5_cl_ui5_util_json_fl=>check_number_initial( `0.01` ) ).
    cl_abap_unit_assert=>assert_equals( exp = abap_false act = z2ui5_cl_ui5_util_json_fl=>check_number_initial( `-1` ) ).
    cl_abap_unit_assert=>assert_equals( exp = abap_false act = z2ui5_cl_ui5_util_json_fl=>check_number_initial( `1.0E+02` ) ).

  ENDMETHOD.

  METHOD test_factory.

    cl_abap_unit_assert=>assert_bound( mi_filter ).

  ENDMETHOD.

  METHOD test_keeps_filled_string.

    cl_abap_unit_assert=>assert_equals( exp = abap_true act = keep_node( iv_type  = z2ui5_if_ajson_types=>node_type-string
                                                 iv_value = `abc` ) ).

  ENDMETHOD.

  METHOD test_drops_empty_string.

    cl_abap_unit_assert=>assert_equals( exp = abap_false act = keep_node( iv_type  = z2ui5_if_ajson_types=>node_type-string
                                                  iv_value = `` ) ).

  ENDMETHOD.

  METHOD test_keeps_number.

    cl_abap_unit_assert=>assert_equals( exp = abap_true act = keep_node( iv_type  = z2ui5_if_ajson_types=>node_type-number
                                                 iv_value = `42` ) ).

  ENDMETHOD.

  METHOD test_drops_zero.

    cl_abap_unit_assert=>assert_equals( exp = abap_false act = keep_node( iv_type  = z2ui5_if_ajson_types=>node_type-number
                                                  iv_value = `0` ) ).

  ENDMETHOD.

  METHOD test_drops_zero_decimals.

    " a packed field with decimals and a float serialize their zero with a
    " fraction / an exponent - still initial
    cl_abap_unit_assert=>assert_equals( exp = abap_false act = keep_node( iv_type  = z2ui5_if_ajson_types=>node_type-number
                                                  iv_value = `0.00` ) ).
    cl_abap_unit_assert=>assert_equals( exp = abap_false act = keep_node( iv_type  = z2ui5_if_ajson_types=>node_type-number
                                                  iv_value = `0.0E+00` ) ).

  ENDMETHOD.

  METHOD test_keeps_small_number.

    cl_abap_unit_assert=>assert_equals( exp = abap_true act = keep_node( iv_type  = z2ui5_if_ajson_types=>node_type-number
                                                 iv_value = `0.01` ) ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = keep_node( iv_type  = z2ui5_if_ajson_types=>node_type-number
                                                 iv_value = `-1` ) ).

  ENDMETHOD.

  METHOD test_keeps_true.

    cl_abap_unit_assert=>assert_equals( exp = abap_true act = keep_node( iv_type  = z2ui5_if_ajson_types=>node_type-boolean
                                                 iv_value = `true` ) ).

  ENDMETHOD.

  METHOD test_drops_false.

    cl_abap_unit_assert=>assert_equals( exp = abap_false act = keep_node( iv_type  = z2ui5_if_ajson_types=>node_type-boolean
                                                  iv_value = `false` ) ).

  ENDMETHOD.

  METHOD test_keeps_filled_object.

    cl_abap_unit_assert=>assert_equals( exp = abap_true act = keep_node( iv_children = 3
                                                 iv_visit    = z2ui5_if_ajson_filter=>visit_type-close ) ).

  ENDMETHOD.

  METHOD test_drops_empty_object.

    cl_abap_unit_assert=>assert_equals( exp = abap_false act = keep_node( iv_children = 0
                                                  iv_visit    = z2ui5_if_ajson_filter=>visit_type-close ) ).

  ENDMETHOD.

  METHOD test_keeps_on_open_visit.

    cl_abap_unit_assert=>assert_equals( exp = abap_true act = keep_node( iv_type  = z2ui5_if_ajson_types=>node_type-string
                                                 iv_value = ``
                                                 iv_visit = z2ui5_if_ajson_filter=>visit_type-open ) ).

  ENDMETHOD.

  METHOD test_mapper_upper.

    " the three answers of the mapping, side by side with the ajson mapping
    " it replaced (create_upper_case) - the same for every name shape the
    " serializer hands in: lower-cased component names, a numeric array
    " index, an already upper-cased leaf, an empty name
    DATA lv_name_act TYPE z2ui5_if_ajson_types=>ty_node-name.
    DATA lv_name_exp TYPE z2ui5_if_ajson_types=>ty_node-name.

    DATA li_act TYPE REF TO z2ui5_if_ajson_mapping.
    DATA li_exp TYPE REF TO z2ui5_if_ajson_mapping.
    DATA temp2 TYPE string_table.
    DATA lt_names LIKE temp2.
    DATA lv_name LIKE LINE OF lt_names.
      DATA temp4 TYPE z2ui5_if_ajson_types=>ty_node.
      DATA temp5 TYPE z2ui5_if_ajson_types=>ty_node.
    DATA li_again TYPE REF TO z2ui5_if_ajson_mapping.
    DATA temp1 TYPE xsdboolean.
    li_act = z2ui5_cl_ui5_util_json_fl=>mapper_upper( ).

    li_exp = z2ui5_cl_ajson_mapping=>create_upper_case( ).

    CLEAR temp2.
    INSERT `name` INTO TABLE temp2.
    INSERT `price_net` INTO TABLE temp2.
    INSERT `1` INTO TABLE temp2.
    INSERT `ALREADY` INTO TABLE temp2.
    INSERT `` INTO TABLE temp2.
    INSERT `MiXeD_09` INTO TABLE temp2.

    lt_names = temp2.


    LOOP AT lt_names INTO lv_name.
      cl_abap_unit_assert=>assert_equals( exp = li_exp->to_json( iv_path = `/T/1/`
                                                                iv_name  = lv_name )
                                          act = li_act->to_json( iv_path = `/T/1/`
                                                                iv_name  = lv_name )
                                          msg = lv_name ).
      " the reader upper-cases the answer and takes the node name for an
      " empty one - so the two are the same mapping there as well
      cl_abap_unit_assert=>assert_equals( exp = to_upper( lv_name )
                                          act = to_upper( li_act->to_abap( iv_path = `/`
                                                                           iv_name = lv_name ) ) ).
      cl_abap_unit_assert=>assert_initial( li_exp->to_abap( iv_path = `/`
                                                            iv_name = lv_name ) ).
      lv_name_act = lv_name.
      lv_name_exp = lv_name.

      CLEAR temp4.
      li_act->rename_node( EXPORTING is_node = temp4
                           CHANGING  cv_name = lv_name_act ).

      CLEAR temp5.
      li_exp->rename_node( EXPORTING is_node = temp5
                           CHANGING  cv_name = lv_name_exp ).
      cl_abap_unit_assert=>assert_equals( exp = lv_name_exp
                                          act = lv_name_act ).
    ENDLOOP.

    " one shared instance, as before
    cl_abap_unit_assert=>assert_bound( li_act ).

    li_again = z2ui5_cl_ui5_util_json_fl=>mapper_upper( ).

    temp1 = boolc( li_again = li_act ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp1 ).

  ENDMETHOD.

  METHOD test_mapper_upper_output.

    " a model-shaped value - a table of flat rows next to a structure and a
    " scalar - serialized through both mappings is the same text
    TYPES: BEGIN OF ty_s_row,
             id        TYPE i,
             name      TYPE string,
             price_net TYPE p LENGTH 9 DECIMALS 2,
             active    TYPE abap_bool,
           END OF ty_s_row.
    TYPES: BEGIN OF ty_s_model,
             t_rows  TYPE STANDARD TABLE OF ty_s_row WITH DEFAULT KEY,
             s_head  TYPE ty_s_row,
             v_title TYPE string,
           END OF ty_s_model.

    DATA temp6 TYPE ty_s_model.
    DATA temp1 TYPE ty_s_model-t_rows.
    DATA temp2 LIKE LINE OF temp1.
    DATA ls_model LIKE temp6.
    DATA lv_act TYPE string.
    DATA lv_exp TYPE string.
    DATA temp3 TYPE xsdboolean.
    DATA temp4 TYPE xsdboolean.
    CLEAR temp6.

    CLEAR temp1.

    CLEAR temp2.
    temp2-id = 1.
    temp2-name = `a`.
    temp2-price_net = '1.50'.
    temp2-active = abap_true.
    INSERT temp2 INTO TABLE temp1.
    CLEAR temp2.
    temp2-id = 2.
    temp2-name = `b`.
    INSERT temp2 INTO TABLE temp1.
    temp6-t_rows = temp1.
    CLEAR temp6-s_head.
    temp6-s_head-id = 3.
    temp6-s_head-name = `h`.
    temp6-v_title = `t`.

    ls_model = temp6.


    lv_act = z2ui5_cl_ajson=>create_empty( ii_custom_mapping = z2ui5_cl_ui5_util_json_fl=>mapper_upper( )
                     )->set( iv_path = `/`
                             iv_val  = ls_model )->stringify( ).

    lv_exp = z2ui5_cl_ajson=>create_empty( ii_custom_mapping = z2ui5_cl_ajson_mapping=>create_upper_case( )
                     )->set( iv_path = `/`
                             iv_val  = ls_model )->stringify( ).

    cl_abap_unit_assert=>assert_equals( exp = lv_exp
                                        act = lv_act ).

    temp3 = boolc( lv_act CS `"PRICE_NET":1.50` ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp3 ).

    temp4 = boolc( lv_act CS `"V_TITLE":"t"` ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp4 ).

  ENDMETHOD.

  METHOD test_escape_controls.

    " a bound string carrying U+0001 and a form feed, serialized the way
    " every model is: ajson leaves both raw, which JSON.parse refuses
    DATA temp7 TYPE xstring.
    DATA lv_ctrl TYPE string.
    DATA lv_json TYPE string.
    DATA lv_act TYPE string.
    DATA temp5 TYPE xsdboolean.
    temp7 = `010C1F`.

    lv_ctrl = z2ui5_cl_ui5_util_context=>conv_get_string_by_xstring( temp7 ).

    lv_json = z2ui5_cl_ajson=>create_empty( )->set( iv_path = `/NAME`
                                                         iv_val   = `a` && lv_ctrl && `b` )->stringify( ).


    lv_act = z2ui5_cl_ui5_util_json_fl=>escape_controls( lv_json ).

    cl_abap_unit_assert=>assert_equals( exp = `{"NAME":"a\u0001\u000C\u001Fb"}`
                                        act = lv_act ).

    temp5 = boolc( lv_act CA lv_ctrl ).
    cl_abap_unit_assert=>assert_equals( exp = abap_false act = temp5 ).

    " tab, LF, CR and an escaped backslash are ajson's own and stay as they are
    lv_json = z2ui5_cl_ajson=>create_empty( )->set(
        iv_path = `/NAME`
        iv_val  = `x\u0001` && z2ui5_cl_ui5_util_context=>cv_char_util_horizontal_tab
                  && z2ui5_cl_ui5_util_context=>cv_char_util_newline )->stringify( ).
    cl_abap_unit_assert=>assert_equals( exp = lv_json
                                        act = z2ui5_cl_ui5_util_json_fl=>escape_controls( lv_json ) ).

  ENDMETHOD.

ENDCLASS.
