CLASS ltcl_unit_test DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    METHODS test_json_attri  FOR TESTING RAISING cx_static_check.
    METHODS test_json_object FOR TESTING RAISING cx_static_check.
    METHODS test_index_html  FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_unit_test IMPLEMENTATION.

  METHOD test_json_attri.

    DATA(lo_tree) = NEW z2ui5_lcl_utility_tree_json( ).

    lo_tree->add_attribute( n = `AAA` v = `BBB` ).

    DATA(lv_result) = lo_tree->stringify( ).
    IF `{"AAA":"BBB"}` <> lv_result.
      cl_abap_unit_assert=>fail( 'json tree - wrong stringify attributes' ).
    ENDIF.

  ENDMETHOD.

  METHOD test_json_object.

    DATA(lo_tree) = NEW z2ui5_lcl_utility_tree_json( ).

    lo_tree->add_attribute_object( `CCC`
         )->add_attribute( n = `AAA` v = `BBB` ).

    DATA(lv_result) = lo_tree->stringify( ).
    IF `{"CCC":{"AAA":"BBB"}}` <> lv_result.
      cl_abap_unit_assert=>fail( 'json tree - wrong stringify object attributes' ).
    ENDIF.

  ENDMETHOD.

  METHOD test_index_html.

    z2ui5_cl_http_handler=>client = VALUE #(
       t_header = VALUE #( ( name = '~path' value = 'dummy' ) )
       ).

    DATA(lv_index_html) = z2ui5_cl_http_handler=>http_get(  ).

    IF lv_index_html IS INITIAL.
      cl_abap_unit_assert=>fail( 'HTTP GET - index html initial' ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.
