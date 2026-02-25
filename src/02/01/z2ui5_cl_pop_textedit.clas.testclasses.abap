
CLASS ltcl_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    METHODS test_factory          FOR TESTING RAISING cx_static_check.
    METHODS test_factory_with_txt FOR TESTING RAISING cx_static_check.
    METHODS test_result_initial   FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_test IMPLEMENTATION.

  METHOD test_factory.

    DATA(lo_pop) = z2ui5_cl_pop_textedit=>factory( ).
    cl_abap_unit_assert=>assert_bound( lo_pop ).

  ENDMETHOD.

  METHOD test_factory_with_txt.

    DATA(lo_pop) = z2ui5_cl_pop_textedit=>factory(
      i_textarea       = `Some initial text`
      i_title          = `My Editor`
      i_check_editable = abap_true ).

    DATA(ls_result) = lo_pop->result( ).
    cl_abap_unit_assert=>assert_equals( exp = `Some initial text`
                                        act = ls_result-text ).
    cl_abap_unit_assert=>assert_false( ls_result-check_confirmed ).

  ENDMETHOD.

  METHOD test_result_initial.

    DATA(lo_pop) = z2ui5_cl_pop_textedit=>factory( ).
    DATA(ls_result) = lo_pop->result( ).
    cl_abap_unit_assert=>assert_false( ls_result-check_confirmed ).

  ENDMETHOD.

ENDCLASS.
