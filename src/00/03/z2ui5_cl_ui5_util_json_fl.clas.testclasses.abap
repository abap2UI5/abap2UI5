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

  METHOD test_mapper_upper.

    " the three answers of the mapping, side by side with the ajson mapping
    " it replaced (create_upper_case) - the same for every name shape the
    " serializer hands in: lower-cased component names, a numeric array
    " index, an already upper-cased leaf, an empty name
    DATA lv_name_act TYPE z2ui5_if_ajson_types=>ty_node-name.
    DATA lv_name_exp TYPE z2ui5_if_ajson_types=>ty_node-name.

    DATA(li_act) = z2ui5_cl_ui5_util_json_fl=>mapper_upper( ).
    DATA(li_exp) = z2ui5_cl_ajson_mapping=>create_upper_case( ).
    DATA(lt_names) = VALUE string_table( ( `name` ) ( `price_net` ) ( `1` ) ( `ALREADY` ) ( `` ) ( `MiXeD_09` ) ).

    LOOP AT lt_names INTO DATA(lv_name).
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
      li_act->rename_node( EXPORTING is_node = VALUE #( )
                           CHANGING  cv_name = lv_name_act ).
      li_exp->rename_node( EXPORTING is_node = VALUE #( )
                           CHANGING  cv_name = lv_name_exp ).
      cl_abap_unit_assert=>assert_equals( exp = lv_name_exp
                                          act = lv_name_act ).
    ENDLOOP.

    " one shared instance, as before
    cl_abap_unit_assert=>assert_bound( li_act ).
    DATA(li_again) = z2ui5_cl_ui5_util_json_fl=>mapper_upper( ).
    cl_abap_unit_assert=>assert_true( xsdbool( li_again = li_act ) ).

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
             t_rows  TYPE STANDARD TABLE OF ty_s_row WITH EMPTY KEY,
             s_head  TYPE ty_s_row,
             v_title TYPE string,
           END OF ty_s_model.

    DATA(ls_model) = VALUE ty_s_model( t_rows  = VALUE #( ( id = 1 name = `a` price_net = '1.50' active = abap_true )
                                                          ( id = 2 name = `b` ) )
                                       s_head  = VALUE #( id = 3 name = `h` )
                                       v_title = `t` ).

    DATA(lv_act) = z2ui5_cl_ajson=>create_empty( ii_custom_mapping = z2ui5_cl_ui5_util_json_fl=>mapper_upper( )
                     )->set( iv_path = `/`
                             iv_val  = ls_model )->stringify( ).
    DATA(lv_exp) = z2ui5_cl_ajson=>create_empty( ii_custom_mapping = z2ui5_cl_ajson_mapping=>create_upper_case( )
                     )->set( iv_path = `/`
                             iv_val  = ls_model )->stringify( ).

    cl_abap_unit_assert=>assert_equals( exp = lv_exp
                                        act = lv_act ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_act CS `"PRICE_NET":1.50` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_act CS `"V_TITLE":"t"` ) ).

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
