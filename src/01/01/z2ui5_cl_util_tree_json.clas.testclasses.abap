CLASS ltcl_unit_01_json DEFINITION FINAL FOR TESTING
  DURATION long
  RISK LEVEL harmless.

  PRIVATE SECTION.
    METHODS test_json_attri     FOR TESTING RAISING cx_static_check.
    METHODS test_json_object    FOR TESTING RAISING cx_static_check.
    METHODS test_json_struc     FOR TESTING RAISING cx_static_check.
    METHODS test_create_json    FOR TESTING RAISING cx_static_check.

ENDCLASS.

CLASS ltcl_unit_01_json IMPLEMENTATION.

  METHOD test_json_attri.

    DATA(lo_tree) = NEW z2ui5_cl_util_tree_json( ).
    lo_tree->add_attribute( n = `AAA`
                            v = `BBB` ).

    DATA(lv_result) = lo_tree->stringify( ).
    IF `{"AAA":"BBB"}` <> lv_result.
      cl_abap_unit_assert=>fail( 'json tree - wrong stringify attributes' ).
    ENDIF.

  ENDMETHOD.

  METHOD test_json_object.

    DATA(lo_tree) = NEW z2ui5_cl_util_tree_json( ).
    lo_tree->add_attribute_object( `CCC` )->add_attribute( n = `AAA`
                                                           v = `BBB` ).

    DATA(lv_result) = lo_tree->stringify( ).
    IF `{"CCC":{"AAA":"BBB"}}` <> lv_result.
      cl_abap_unit_assert=>fail( 'json tree - wrong stringify object attributes' ).
    ENDIF.

  ENDMETHOD.

  METHOD test_json_struc.

    DATA(lo_tree) = NEW z2ui5_cl_util_tree_json( ).

    TYPES:
      BEGIN OF ty_s_test,
        comp1 TYPE string,
        comp2 TYPE string,
      END OF ty_s_test.

    DATA(ls_test) = VALUE ty_s_test( comp1 = `AAA` comp2 = `BBB` ).
    lo_tree->add_attribute_object( `CCC` )->add_attribute_struc( ls_test ).

    DATA(lv_result) = lo_tree->stringify( ).
    IF `{"CCC":{"COMP1":"AAA","COMP2":"BBB"}}` <> lv_result.
      cl_abap_unit_assert=>fail( 'json tree - wrong stringify structure' ).
    ENDIF.

  ENDMETHOD.

  METHOD test_create_json.



    DATA(lo_json) = z2ui5_cl_util_tree_json=>factory( `{"CCC":{"COMP1":"AAA","COMP2":"BBB"}}` ).

    DATA(lo_attri) = lo_json->get_attribute( `CCC` )->get_attribute( `COMP2` ).

    DATA lr_ref TYPE REF TO data.
    lr_ref = lo_attri->get_val_ref( ).
    FIELD-SYMBOLS <any> TYPE any.
    ASSIGN lr_ref->* TO <any>.
    IF <any> <> `BBB`.
      cl_abap_unit_assert=>fail( quit = 5 ).
    ENDIF.

    DATA(lv_val) = lo_attri->get_val( ).
    IF lv_val <> `BBB`.
      cl_abap_unit_assert=>fail( quit = 5 ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.
