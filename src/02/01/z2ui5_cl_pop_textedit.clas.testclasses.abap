
CLASS ltcl_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    METHODS test_factory          FOR TESTING RAISING cx_static_check.
    METHODS test_factory_with_txt FOR TESTING RAISING cx_static_check.
    METHODS test_result_initial   FOR TESTING RAISING cx_static_check.
    METHODS test_factory_title    FOR TESTING RAISING cx_static_check.
    METHODS test_factory_editable FOR TESTING RAISING cx_static_check.
    METHODS test_factory_stretch  FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_test IMPLEMENTATION.

  METHOD test_factory.

    DATA lo_pop TYPE REF TO z2ui5_cl_pop_textedit.
    lo_pop = z2ui5_cl_pop_textedit=>factory( ).
    cl_abap_unit_assert=>assert_bound( lo_pop ).

  ENDMETHOD.

  METHOD test_factory_with_txt.

    DATA lo_pop TYPE REF TO z2ui5_cl_pop_textedit.
    DATA ls_result TYPE z2ui5_cl_pop_textedit=>ty_s_result.
    lo_pop = z2ui5_cl_pop_textedit=>factory(
      i_textarea       = `Some initial text`
      i_title          = `My Editor`
      i_check_editable = abap_true ).

    
    ls_result = lo_pop->result( ).
    cl_abap_unit_assert=>assert_equals( exp = `Some initial text`
                                        act = ls_result-text ).
    cl_abap_unit_assert=>assert_false( ls_result-check_confirmed ).

  ENDMETHOD.

  METHOD test_result_initial.

    DATA lo_pop TYPE REF TO z2ui5_cl_pop_textedit.
    DATA ls_result TYPE z2ui5_cl_pop_textedit=>ty_s_result.
    lo_pop = z2ui5_cl_pop_textedit=>factory( ).
    
    ls_result = lo_pop->result( ).
    cl_abap_unit_assert=>assert_false( ls_result-check_confirmed ).

  ENDMETHOD.

  METHOD test_factory_title.

    DATA lo_pop TYPE REF TO z2ui5_cl_pop_textedit.
    lo_pop = z2ui5_cl_pop_textedit=>factory(
      i_textarea = `hello`
      i_title    = `Custom Title` ).

    cl_abap_unit_assert=>assert_equals( exp = `Custom Title`
                                        act = lo_pop->mv_title ).

  ENDMETHOD.

  METHOD test_factory_editable.

    DATA lo_pop TYPE REF TO z2ui5_cl_pop_textedit.
    DATA lo_pop2 TYPE REF TO z2ui5_cl_pop_textedit.
    lo_pop = z2ui5_cl_pop_textedit=>factory(
      i_textarea       = `text`
      i_check_editable = abap_true ).

    cl_abap_unit_assert=>assert_true( lo_pop->mv_check_editable ).

    
    lo_pop2 = z2ui5_cl_pop_textedit=>factory( ).
    cl_abap_unit_assert=>assert_false( lo_pop2->mv_check_editable ).

  ENDMETHOD.

  METHOD test_factory_stretch.

    DATA lo_pop TYPE REF TO z2ui5_cl_pop_textedit.
    DATA lo_pop2 TYPE REF TO z2ui5_cl_pop_textedit.
    lo_pop = z2ui5_cl_pop_textedit=>factory(
      i_stretch_active = abap_false ).

    cl_abap_unit_assert=>assert_false( lo_pop->mv_stretch_active ).

    
    lo_pop2 = z2ui5_cl_pop_textedit=>factory( ).
    cl_abap_unit_assert=>assert_true( lo_pop2->mv_stretch_active ).

  ENDMETHOD.

ENDCLASS.
