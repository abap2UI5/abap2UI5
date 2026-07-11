CLASS ltcl_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    DATA mi_filter TYPE REF TO z2ui5_if_ajson_filter.

    METHODS setup.

    METHODS keep_node
      IMPORTING
        iv_type         TYPE z2ui5_if_ajson_types=>ty_node_type OPTIONAL
        iv_value        TYPE string                             OPTIONAL
        iv_children     TYPE i                                  OPTIONAL
        iv_visit        TYPE z2ui5_if_ajson_filter=>ty_visit_type DEFAULT z2ui5_if_ajson_filter=>visit_type-value
      RETURNING
        VALUE(rv_keep)  TYPE abap_bool
      RAISING
        z2ui5_cx_ajson_error.

    METHODS test_factory              FOR TESTING RAISING cx_static_check.
    METHODS test_keeps_filled_string  FOR TESTING RAISING cx_static_check.
    METHODS test_drops_empty_string   FOR TESTING RAISING cx_static_check.
    METHODS test_keeps_number         FOR TESTING RAISING cx_static_check.
    METHODS test_drops_zero           FOR TESTING RAISING cx_static_check.
    METHODS test_keeps_true           FOR TESTING RAISING cx_static_check.
    METHODS test_drops_false          FOR TESTING RAISING cx_static_check.
    METHODS test_keeps_filled_object  FOR TESTING RAISING cx_static_check.
    METHODS test_drops_empty_object   FOR TESTING RAISING cx_static_check.
    METHODS test_keeps_on_open_visit  FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_test IMPLEMENTATION.

  METHOD setup.

    mi_filter = z2ui5_cl_abap2ui5_json_fltr=>create_no_empty_values( ).

  ENDMETHOD.

  METHOD keep_node.

    rv_keep = mi_filter->keep_node(
        is_node  = VALUE #( type     = iv_type
                            value    = iv_value
                            children = iv_children )
        iv_visit = iv_visit ).

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

ENDCLASS.
