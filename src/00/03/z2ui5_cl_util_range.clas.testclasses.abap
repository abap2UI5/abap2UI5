
CLASS ltcl_unit_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    METHODS test_empty_range        FOR TESTING RAISING cx_static_check.
    METHODS test_eq_include         FOR TESTING RAISING cx_static_check.
    METHODS test_ne_include         FOR TESTING RAISING cx_static_check.
    METHODS test_gt_include         FOR TESTING RAISING cx_static_check.
    METHODS test_ge_include         FOR TESTING RAISING cx_static_check.
    METHODS test_lt_include         FOR TESTING RAISING cx_static_check.
    METHODS test_le_include         FOR TESTING RAISING cx_static_check.
    METHODS test_bt_include         FOR TESTING RAISING cx_static_check.
    METHODS test_nb_include         FOR TESTING RAISING cx_static_check.
    METHODS test_cp_include         FOR TESTING RAISING cx_static_check.
    METHODS test_np_include         FOR TESTING RAISING cx_static_check.
    METHODS test_exclude_sign       FOR TESTING RAISING cx_static_check.
    METHODS test_multiple_entries   FOR TESTING RAISING cx_static_check.
    METHODS test_quote_escape       FOR TESTING RAISING cx_static_check.
    METHODS test_fieldname_upper    FOR TESTING RAISING cx_static_check.
    METHODS test_constants          FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_unit_test IMPLEMENTATION.

  METHOD test_empty_range.

    DATA lt_range TYPE z2ui5_cl_util=>ty_t_range.

    DATA(lo_range) = NEW z2ui5_cl_util_range(
      iv_fieldname = `CARRID`
      ir_range     = REF #( lt_range ) ).

    cl_abap_unit_assert=>assert_initial( lo_range->get_sql( ) ).

  ENDMETHOD.

  METHOD test_eq_include.

    DATA(lt_range) = VALUE z2ui5_cl_util=>ty_t_range(
      ( sign = `I` option = `EQ` low = `AA` high = `` ) ).

    DATA(lo_range) = NEW z2ui5_cl_util_range(
      iv_fieldname = `CARRID`
      ir_range     = REF #( lt_range ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = `( CARRID EQ 'AA' )`
      act = lo_range->get_sql( ) ).

  ENDMETHOD.

  METHOD test_ne_include.

    DATA(lt_range) = VALUE z2ui5_cl_util=>ty_t_range(
      ( sign = `I` option = `NE` low = `BB` high = `` ) ).

    DATA(lo_range) = NEW z2ui5_cl_util_range(
      iv_fieldname = `CARRID`
      ir_range     = REF #( lt_range ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = `( CARRID NE 'BB' )`
      act = lo_range->get_sql( ) ).

  ENDMETHOD.

  METHOD test_gt_include.

    DATA(lt_range) = VALUE z2ui5_cl_util=>ty_t_range(
      ( sign = `I` option = `GT` low = `100` high = `` ) ).

    DATA(lo_range) = NEW z2ui5_cl_util_range(
      iv_fieldname = `AMOUNT`
      ir_range     = REF #( lt_range ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = `( AMOUNT GT '100' )`
      act = lo_range->get_sql( ) ).

  ENDMETHOD.

  METHOD test_ge_include.

    DATA(lt_range) = VALUE z2ui5_cl_util=>ty_t_range(
      ( sign = `I` option = `GE` low = `50` high = `` ) ).

    DATA(lo_range) = NEW z2ui5_cl_util_range(
      iv_fieldname = `AMOUNT`
      ir_range     = REF #( lt_range ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = `( AMOUNT GE '50' )`
      act = lo_range->get_sql( ) ).

  ENDMETHOD.

  METHOD test_lt_include.

    DATA(lt_range) = VALUE z2ui5_cl_util=>ty_t_range(
      ( sign = `I` option = `LT` low = `200` high = `` ) ).

    DATA(lo_range) = NEW z2ui5_cl_util_range(
      iv_fieldname = `AMOUNT`
      ir_range     = REF #( lt_range ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = `( AMOUNT LT '200' )`
      act = lo_range->get_sql( ) ).

  ENDMETHOD.

  METHOD test_le_include.

    DATA(lt_range) = VALUE z2ui5_cl_util=>ty_t_range(
      ( sign = `I` option = `LE` low = `300` high = `` ) ).

    DATA(lo_range) = NEW z2ui5_cl_util_range(
      iv_fieldname = `AMOUNT`
      ir_range     = REF #( lt_range ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = `( AMOUNT LE '300' )`
      act = lo_range->get_sql( ) ).

  ENDMETHOD.

  METHOD test_bt_include.

    DATA(lt_range) = VALUE z2ui5_cl_util=>ty_t_range(
      ( sign = `I` option = `BT` low = `100` high = `500` ) ).

    DATA(lo_range) = NEW z2ui5_cl_util_range(
      iv_fieldname = `AMOUNT`
      ir_range     = REF #( lt_range ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = `( AMOUNT BETWEEN '100' AND '500' )`
      act = lo_range->get_sql( ) ).

  ENDMETHOD.

  METHOD test_nb_include.

    DATA(lt_range) = VALUE z2ui5_cl_util=>ty_t_range(
      ( sign = `I` option = `NB` low = `100` high = `500` ) ).

    DATA(lo_range) = NEW z2ui5_cl_util_range(
      iv_fieldname = `AMOUNT`
      ir_range     = REF #( lt_range ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = `( AMOUNT NOT BETWEEN '100' AND '500' )`
      act = lo_range->get_sql( ) ).

  ENDMETHOD.

  METHOD test_cp_include.

    DATA(lt_range) = VALUE z2ui5_cl_util=>ty_t_range(
      ( sign = `I` option = `CP` low = `*test*` high = `` ) ).

    DATA(lo_range) = NEW z2ui5_cl_util_range(
      iv_fieldname = `NAME`
      ir_range     = REF #( lt_range ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = `( NAME LIKE '%test%' )`
      act = lo_range->get_sql( ) ).

  ENDMETHOD.

  METHOD test_np_include.

    DATA(lt_range) = VALUE z2ui5_cl_util=>ty_t_range(
      ( sign = `I` option = `NP` low = `*test*` high = `` ) ).

    DATA(lo_range) = NEW z2ui5_cl_util_range(
      iv_fieldname = `NAME`
      ir_range     = REF #( lt_range ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = `( NAME NOT LIKE '%test%' )`
      act = lo_range->get_sql( ) ).

  ENDMETHOD.

  METHOD test_exclude_sign.

    DATA(lt_range) = VALUE z2ui5_cl_util=>ty_t_range(
      ( sign = `E` option = `EQ` low = `XX` high = `` ) ).

    DATA(lo_range) = NEW z2ui5_cl_util_range(
      iv_fieldname = `CARRID`
      ir_range     = REF #( lt_range ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = `( NOT CARRID EQ 'XX' )`
      act = lo_range->get_sql( ) ).

  ENDMETHOD.

  METHOD test_multiple_entries.

    DATA(lt_range) = VALUE z2ui5_cl_util=>ty_t_range(
      ( sign = `I` option = `EQ` low = `AA` high = `` )
      ( sign = `I` option = `EQ` low = `BB` high = `` ) ).

    DATA(lo_range) = NEW z2ui5_cl_util_range(
      iv_fieldname = `CARRID`
      ir_range     = REF #( lt_range ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = `( CARRID EQ 'AA' OR CARRID EQ 'BB' )`
      act = lo_range->get_sql( ) ).

  ENDMETHOD.

  METHOD test_quote_escape.

    DATA(lt_range) = VALUE z2ui5_cl_util=>ty_t_range(
      ( sign = `I` option = `EQ` low = `O'Brien` high = `` ) ).

    DATA(lo_range) = NEW z2ui5_cl_util_range(
      iv_fieldname = `NAME`
      ir_range     = REF #( lt_range ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = `( NAME EQ 'O''Brien' )`
      act = lo_range->get_sql( ) ).

  ENDMETHOD.

  METHOD test_fieldname_upper.

    DATA(lt_range) = VALUE z2ui5_cl_util=>ty_t_range(
      ( sign = `I` option = `EQ` low = `test` high = `` ) ).

    DATA(lo_range) = NEW z2ui5_cl_util_range(
      iv_fieldname = `carrid`
      ir_range     = REF #( lt_range ) ).

    DATA(lv_sql) = lo_range->get_sql( ).

    cl_abap_unit_assert=>assert_true(
      xsdbool( lv_sql CS `CARRID` ) ).

  ENDMETHOD.

  METHOD test_constants.

    cl_abap_unit_assert=>assert_equals( exp = `I`  act = z2ui5_cl_util_range=>signs-including ).
    cl_abap_unit_assert=>assert_equals( exp = `E`  act = z2ui5_cl_util_range=>signs-excluding ).
    cl_abap_unit_assert=>assert_equals( exp = `EQ` act = z2ui5_cl_util_range=>options-equal ).
    cl_abap_unit_assert=>assert_equals( exp = `NE` act = z2ui5_cl_util_range=>options-not_equal ).
    cl_abap_unit_assert=>assert_equals( exp = `BT` act = z2ui5_cl_util_range=>options-between ).
    cl_abap_unit_assert=>assert_equals( exp = `NB` act = z2ui5_cl_util_range=>options-not_between ).
    cl_abap_unit_assert=>assert_equals( exp = `CP` act = z2ui5_cl_util_range=>options-contains_pattern ).
    cl_abap_unit_assert=>assert_equals( exp = `NP` act = z2ui5_cl_util_range=>options-not_contains_pattern ).
    cl_abap_unit_assert=>assert_equals( exp = `GT` act = z2ui5_cl_util_range=>options-greater_than ).
    cl_abap_unit_assert=>assert_equals( exp = `GE` act = z2ui5_cl_util_range=>options-greater_equal ).
    cl_abap_unit_assert=>assert_equals( exp = `LE` act = z2ui5_cl_util_range=>options-less_equal ).
    cl_abap_unit_assert=>assert_equals( exp = `LT` act = z2ui5_cl_util_range=>options-less_than ).

  ENDMETHOD.

ENDCLASS.
