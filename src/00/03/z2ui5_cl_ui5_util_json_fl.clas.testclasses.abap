" ajson's own upper-case mapping (create_upper_case of its mapping library),
" which z2ui5_cl_ui5_util_json_fl=>mapper_upper replaced and the vendored copy
" no longer carries - written out with the answers it gave, as the reference
" the framework's mapping is held to
CLASS ltcl_upper_case DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES z2ui5_if_ui5_ajs_map.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS ltcl_upper_case IMPLEMENTATION.

  METHOD z2ui5_if_ui5_ajs_map~to_json.
    rv_result = to_upper( iv_name ).
  ENDMETHOD.

  METHOD z2ui5_if_ui5_ajs_map~to_abap.
    CLEAR rv_result.
  ENDMETHOD.

  METHOD z2ui5_if_ui5_ajs_map~rename_node.
    cv_name = to_upper( cv_name ).
  ENDMETHOD.

ENDCLASS.


CLASS ltcl_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_number_initial       FOR TESTING RAISING cx_static_check.
    METHODS test_escape_controls      FOR TESTING RAISING cx_static_check.
    METHODS test_mapper_upper         FOR TESTING RAISING cx_static_check.
    METHODS test_mapper_upper_output  FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_test IMPLEMENTATION.

  METHOD test_number_initial.

    " every spelling of zero is initial, anything with a non-zero digit is
    " not - the predicate the client's local filters share
    cl_abap_unit_assert=>assert_true( z2ui5_cl_ui5_util_json_fl=>check_number_initial( `0` ) ).
    cl_abap_unit_assert=>assert_true( z2ui5_cl_ui5_util_json_fl=>check_number_initial( `0.00` ) ).
    cl_abap_unit_assert=>assert_true( z2ui5_cl_ui5_util_json_fl=>check_number_initial( `0.0E+00` ) ).
    cl_abap_unit_assert=>assert_true( z2ui5_cl_ui5_util_json_fl=>check_number_initial( `-0` ) ).
    cl_abap_unit_assert=>assert_false( z2ui5_cl_ui5_util_json_fl=>check_number_initial( `0.01` ) ).
    cl_abap_unit_assert=>assert_false( z2ui5_cl_ui5_util_json_fl=>check_number_initial( `-1` ) ).
    cl_abap_unit_assert=>assert_false( z2ui5_cl_ui5_util_json_fl=>check_number_initial( `1.0E+02` ) ).

  ENDMETHOD.

  METHOD test_mapper_upper.

    " the three answers of the mapping, side by side with the ajson mapping
    " it replaced (create_upper_case) - the same for every name shape the
    " serializer hands in: lower-cased component names, a numeric array
    " index, an already upper-cased leaf, an empty name
    DATA lv_name_act TYPE z2ui5_if_ui5_ajs_types=>ty_node-name.
    DATA lv_name_exp TYPE z2ui5_if_ui5_ajs_types=>ty_node-name.

    DATA(li_act) = z2ui5_cl_ui5_util_json_fl=>mapper_upper( ).
    DATA(li_exp) = CAST z2ui5_if_ui5_ajs_map( NEW ltcl_upper_case( ) ).
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

    DATA(lv_act) = z2ui5_cl_ui5_ajs=>create_empty( ii_custom_mapping = z2ui5_cl_ui5_util_json_fl=>mapper_upper( )
                     )->set( iv_path = `/`
                             iv_val  = ls_model )->stringify( ).
    DATA(lv_exp) = z2ui5_cl_ui5_ajs=>create_empty( ii_custom_mapping = NEW ltcl_upper_case( )
                     )->set( iv_path = `/`
                             iv_val  = ls_model )->stringify( ).

    cl_abap_unit_assert=>assert_equals( exp = lv_exp
                                        act = lv_act ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_act CS `"PRICE_NET":1.50` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_act CS `"V_TITLE":"t"` ) ).

  ENDMETHOD.

  METHOD test_escape_controls.

    " a JSON text carrying U+0001, a form feed and U+001F raw, which
    " JSON.parse refuses. Built by hand, not through ajson: ajson escapes
    " control characters itself since the 2026-11 mirror update, and this
    " method is the guard for every serializer that does not
    DATA(lv_ctrl) = z2ui5_cl_ui5_util_context=>conv_get_string_by_xstring( CONV xstring( `010C1F` ) ).
    DATA(lv_json) = `{"NAME":"a` && lv_ctrl && `b"}`.

    DATA(lv_act) = z2ui5_cl_ui5_util_json_fl=>escape_controls( lv_json ).

    cl_abap_unit_assert=>assert_equals( exp = `{"NAME":"a\u0001\u000C\u001Fb"}`
                                        act = lv_act ).
    cl_abap_unit_assert=>assert_false( xsdbool( lv_act CA lv_ctrl ) ).

    " tab, LF, CR and an escaped backslash are ajson's own and stay as they are
    lv_json = z2ui5_cl_ui5_ajs=>create_empty( )->set(
        iv_path = `/NAME`
        iv_val  = `x\u0001` && z2ui5_cl_ui5_util_context=>cv_char_util_horizontal_tab
                  && z2ui5_cl_ui5_util_context=>cv_char_util_newline )->stringify( ).
    cl_abap_unit_assert=>assert_equals( exp = lv_json
                                        act = z2ui5_cl_ui5_util_json_fl=>escape_controls( lv_json ) ).

  ENDMETHOD.

ENDCLASS.
