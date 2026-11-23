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
    METHODS test_factory_eq         FOR TESTING RAISING cx_static_check.
    METHODS test_factory_ne         FOR TESTING RAISING cx_static_check.
    METHODS test_factory_bt         FOR TESTING RAISING cx_static_check.
    METHODS test_factory_cp         FOR TESTING RAISING cx_static_check.
    METHODS test_factory_gt         FOR TESTING RAISING cx_static_check.
    METHODS test_factory_ge         FOR TESTING RAISING cx_static_check.
    METHODS test_factory_lt         FOR TESTING RAISING cx_static_check.
    METHODS test_factory_le         FOR TESTING RAISING cx_static_check.
    METHODS test_factory_exclude    FOR TESTING RAISING cx_static_check.
    METHODS test_factory_with_sql   FOR TESTING RAISING cx_static_check.
    METHODS test_get_sql_multi      FOR TESTING RAISING cx_static_check.

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

  METHOD test_factory_eq.

    DATA(ls_range) = z2ui5_cl_util_range=>eq( `AA` ).

    cl_abap_unit_assert=>assert_equals( exp = `I`  act = ls_range-sign ).
    cl_abap_unit_assert=>assert_equals( exp = `EQ` act = ls_range-option ).
    cl_abap_unit_assert=>assert_equals( exp = `AA` act = ls_range-low ).

  ENDMETHOD.

  METHOD test_factory_ne.

    DATA(ls_range) = z2ui5_cl_util_range=>ne( `BB` ).

    cl_abap_unit_assert=>assert_equals( exp = `NE` act = ls_range-option ).
    cl_abap_unit_assert=>assert_equals( exp = `BB` act = ls_range-low ).

  ENDMETHOD.

  METHOD test_factory_bt.

    DATA(ls_range) = z2ui5_cl_util_range=>bt( low = `100` high = `500` ).

    cl_abap_unit_assert=>assert_equals( exp = `BT`  act = ls_range-option ).
    cl_abap_unit_assert=>assert_equals( exp = `100` act = ls_range-low ).
    cl_abap_unit_assert=>assert_equals( exp = `500` act = ls_range-high ).

  ENDMETHOD.

  METHOD test_factory_cp.

    DATA(ls_range) = z2ui5_cl_util_range=>cp( `*test*` ).

    cl_abap_unit_assert=>assert_equals( exp = `CP`      act = ls_range-option ).
    cl_abap_unit_assert=>assert_equals( exp = `*test*`  act = ls_range-low ).

  ENDMETHOD.

  METHOD test_factory_gt.

    DATA(ls_range) = z2ui5_cl_util_range=>gt( `100` ).

    cl_abap_unit_assert=>assert_equals( exp = `GT`  act = ls_range-option ).
    cl_abap_unit_assert=>assert_equals( exp = `100` act = ls_range-low ).

  ENDMETHOD.

  METHOD test_factory_ge.

    DATA(ls_range) = z2ui5_cl_util_range=>ge( `50` ).

    cl_abap_unit_assert=>assert_equals( exp = `GE` act = ls_range-option ).
    cl_abap_unit_assert=>assert_equals( exp = `50` act = ls_range-low ).

  ENDMETHOD.

  METHOD test_factory_lt.

    DATA(ls_range) = z2ui5_cl_util_range=>lt( `200` ).

    cl_abap_unit_assert=>assert_equals( exp = `LT`  act = ls_range-option ).
    cl_abap_unit_assert=>assert_equals( exp = `200` act = ls_range-low ).

  ENDMETHOD.

  METHOD test_factory_le.

    DATA(ls_range) = z2ui5_cl_util_range=>le( `300` ).

    cl_abap_unit_assert=>assert_equals( exp = `LE`  act = ls_range-option ).
    cl_abap_unit_assert=>assert_equals( exp = `300` act = ls_range-low ).

  ENDMETHOD.

  METHOD test_factory_exclude.

    DATA(ls_range) = z2ui5_cl_util_range=>eq( val = `XX` sign = `E` ).

    cl_abap_unit_assert=>assert_equals( exp = `E`  act = ls_range-sign ).
    cl_abap_unit_assert=>assert_equals( exp = `EQ` act = ls_range-option ).

  ENDMETHOD.

  METHOD test_factory_with_sql.

    DATA(lt_range) = VALUE z2ui5_cl_util=>ty_t_range(
      ( z2ui5_cl_util_range=>eq( `AA` ) )
      ( z2ui5_cl_util_range=>eq( `BB` ) ) ).

    DATA(lo_range) = NEW z2ui5_cl_util_range(
      iv_fieldname = `CARRID`
      ir_range     = REF #( lt_range ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = `( CARRID EQ 'AA' OR CARRID EQ 'BB' )`
      act = lo_range->get_sql( ) ).

  ENDMETHOD.

  METHOD test_get_sql_multi.

    DATA(lt_r1) = VALUE z2ui5_cl_util=>ty_t_range( ( z2ui5_cl_util_range=>eq( `LH` ) ) ).
    DATA(lt_r2) = VALUE z2ui5_cl_util=>ty_t_range( ( z2ui5_cl_util_range=>bt( low = `100` high = `500` ) ) ).

    DATA(lv_sql1) = NEW z2ui5_cl_util_range( iv_fieldname = `CARRID` ir_range = REF #( lt_r1 ) )->get_sql( ).
    DATA(lv_sql2) = NEW z2ui5_cl_util_range( iv_fieldname = `CONNID` ir_range = REF #( lt_r2 ) )->get_sql( ).

    DATA(lv_result) = z2ui5_cl_util_range=>get_sql_multi( VALUE #( ( lv_sql1 ) ( lv_sql2 ) ) ).

    cl_abap_unit_assert=>assert_true( xsdbool( lv_result CS `CARRID` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_result CS `AND` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_result CS `CONNID` ) ).

  ENDMETHOD.

ENDCLASS.
