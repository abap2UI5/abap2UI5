CLASS ltcl_unit_01_json DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    METHODS test_json_attri     FOR TESTING RAISING cx_static_check.
    METHODS test_json_object    FOR TESTING RAISING cx_static_check.
    METHODS test_json_struc     FOR TESTING RAISING cx_static_check.
    METHODS test_json_trans     FOR TESTING RAISING cx_static_check.
    METHODS test_json_trans_gen FOR TESTING RAISING cx_static_check.

ENDCLASS.

CLASS ltcl_unit_01_json IMPLEMENTATION.

  METHOD test_json_attri.

    DATA(lo_tree) = NEW z2ui5_cl_fw_utility_json( ).
    lo_tree->add_attribute( n = `AAA`
                            v = `BBB` ).

    DATA(lv_result) = lo_tree->stringify( ).
    IF `{"AAA":"BBB"}` <> lv_result.
      cl_abap_unit_assert=>fail( 'json tree - wrong stringify attributes' ).
    ENDIF.

  ENDMETHOD.

  METHOD test_json_object.

    DATA(lo_tree) = NEW z2ui5_cl_fw_utility_json( ).
    lo_tree->add_attribute_object( `CCC` )->add_attribute( n = `AAA`
                                                           v = `BBB` ).

    DATA(lv_result) = lo_tree->stringify( ).
    IF `{"CCC":{"AAA":"BBB"}}` <> lv_result.
      cl_abap_unit_assert=>fail( 'json tree - wrong stringify object attributes' ).
    ENDIF.

  ENDMETHOD.

  METHOD test_json_struc.

    DATA(lo_tree) = NEW z2ui5_cl_fw_utility_json( ).

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

  METHOD test_json_trans.

    TYPES:
      BEGIN OF ty_row,
        title    TYPE string,
        value    TYPE string,
        selected TYPE abap_bool,
      END OF ty_row.
    TYPES ty_t_tab TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.

    DATA(lt_tab) = VALUE ty_t_tab( ( title = 'Test'  value = 'this is a description' selected = abap_true )
                                   ( title = 'Test2' value = 'this is a new descr'   selected = abap_false ) ).

    DATA(lt_tab2) = VALUE ty_t_tab( ).

    DATA(lv_tab) = z2ui5_cl_fw_utility=>trans_any_2_json( lt_tab ).

    /ui2/cl_json=>deserialize( EXPORTING json = lv_tab
                               CHANGING  data = lt_tab2 ).

    IF lt_tab <> lt_tab2.
      cl_abap_unit_assert=>fail( msg  = 'json serial -  /ui2/cl_json wrong simple table'
                                 quit = 5 ).
    ENDIF.

  ENDMETHOD.

  METHOD test_json_trans_gen.

    TYPES:
      BEGIN OF ty_row,
        title    TYPE string,
        value    TYPE string,
        selected TYPE abap_bool,
      END OF ty_row.
    TYPES ty_t_tab TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.

    DATA(lt_tab) = VALUE ty_t_tab( ( title = 'Test'  value = 'this is a description' selected = abap_true )
                                   ( title = 'Test2' value = 'this is a new descr'   selected = abap_false ) ).

    DATA(lt_tab2) = VALUE ty_t_tab( ).

    DATA(lv_tab) = z2ui5_cl_fw_utility=>trans_any_2_json( lt_tab ).

    DATA lo_data TYPE REF TO data.
    /ui2/cl_json=>deserialize( EXPORTING json = lv_tab
                               CHANGING  data = lo_data ).

    z2ui5_cl_fw_utility=>trans_ref_tab_2_tab( EXPORTING ir_tab_from = lo_data
                                            IMPORTING t_result      = lt_tab2 ).

    IF lt_tab <> lt_tab2.
      cl_abap_unit_assert=>fail( msg  = 'json serial -  /ui2/cl_json wrong generic table'
                                 quit = 5 ).
    ENDIF.

  ENDMETHOD.
ENDCLASS.
