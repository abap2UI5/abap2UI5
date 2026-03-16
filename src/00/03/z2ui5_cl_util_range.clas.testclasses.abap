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

    DATA temp1 LIKE REF TO lt_range.
DATA lo_range TYPE REF TO z2ui5_cl_util_range.
    GET REFERENCE OF lt_range INTO temp1.

CREATE OBJECT lo_range TYPE z2ui5_cl_util_range EXPORTING iv_fieldname = `CARRID` ir_range = temp1.

    cl_abap_unit_assert=>assert_initial( lo_range->get_sql( ) ).

  ENDMETHOD.

  METHOD test_eq_include.

    DATA temp2 TYPE z2ui5_cl_util=>ty_t_range.
    DATA temp3 LIKE LINE OF temp2.
    DATA lt_range LIKE temp2.
    DATA temp4 LIKE REF TO lt_range.
DATA lo_range TYPE REF TO z2ui5_cl_util_range.
    CLEAR temp2.
    
    temp3-sign = `I`.
    temp3-option = `EQ`.
    temp3-low = `AA`.
    temp3-high = ``.
    INSERT temp3 INTO TABLE temp2.
    
    lt_range = temp2.

    
    GET REFERENCE OF lt_range INTO temp4.

CREATE OBJECT lo_range TYPE z2ui5_cl_util_range EXPORTING iv_fieldname = `CARRID` ir_range = temp4.

    cl_abap_unit_assert=>assert_equals(
      exp = `( CARRID EQ 'AA' )`
      act = lo_range->get_sql( ) ).

  ENDMETHOD.

  METHOD test_ne_include.

    DATA temp5 TYPE z2ui5_cl_util=>ty_t_range.
    DATA temp6 LIKE LINE OF temp5.
    DATA lt_range LIKE temp5.
    DATA temp7 LIKE REF TO lt_range.
DATA lo_range TYPE REF TO z2ui5_cl_util_range.
    CLEAR temp5.
    
    temp6-sign = `I`.
    temp6-option = `NE`.
    temp6-low = `BB`.
    temp6-high = ``.
    INSERT temp6 INTO TABLE temp5.
    
    lt_range = temp5.

    
    GET REFERENCE OF lt_range INTO temp7.

CREATE OBJECT lo_range TYPE z2ui5_cl_util_range EXPORTING iv_fieldname = `CARRID` ir_range = temp7.

    cl_abap_unit_assert=>assert_equals(
      exp = `( CARRID NE 'BB' )`
      act = lo_range->get_sql( ) ).

  ENDMETHOD.

  METHOD test_gt_include.

    DATA temp8 TYPE z2ui5_cl_util=>ty_t_range.
    DATA temp9 LIKE LINE OF temp8.
    DATA lt_range LIKE temp8.
    DATA temp10 LIKE REF TO lt_range.
DATA lo_range TYPE REF TO z2ui5_cl_util_range.
    CLEAR temp8.
    
    temp9-sign = `I`.
    temp9-option = `GT`.
    temp9-low = `100`.
    temp9-high = ``.
    INSERT temp9 INTO TABLE temp8.
    
    lt_range = temp8.

    
    GET REFERENCE OF lt_range INTO temp10.

CREATE OBJECT lo_range TYPE z2ui5_cl_util_range EXPORTING iv_fieldname = `AMOUNT` ir_range = temp10.

    cl_abap_unit_assert=>assert_equals(
      exp = `( AMOUNT GT '100' )`
      act = lo_range->get_sql( ) ).

  ENDMETHOD.

  METHOD test_ge_include.

    DATA temp11 TYPE z2ui5_cl_util=>ty_t_range.
    DATA temp12 LIKE LINE OF temp11.
    DATA lt_range LIKE temp11.
    DATA temp13 LIKE REF TO lt_range.
DATA lo_range TYPE REF TO z2ui5_cl_util_range.
    CLEAR temp11.
    
    temp12-sign = `I`.
    temp12-option = `GE`.
    temp12-low = `50`.
    temp12-high = ``.
    INSERT temp12 INTO TABLE temp11.
    
    lt_range = temp11.

    
    GET REFERENCE OF lt_range INTO temp13.

CREATE OBJECT lo_range TYPE z2ui5_cl_util_range EXPORTING iv_fieldname = `AMOUNT` ir_range = temp13.

    cl_abap_unit_assert=>assert_equals(
      exp = `( AMOUNT GE '50' )`
      act = lo_range->get_sql( ) ).

  ENDMETHOD.

  METHOD test_lt_include.

    DATA temp14 TYPE z2ui5_cl_util=>ty_t_range.
    DATA temp15 LIKE LINE OF temp14.
    DATA lt_range LIKE temp14.
    DATA temp16 LIKE REF TO lt_range.
DATA lo_range TYPE REF TO z2ui5_cl_util_range.
    CLEAR temp14.
    
    temp15-sign = `I`.
    temp15-option = `LT`.
    temp15-low = `200`.
    temp15-high = ``.
    INSERT temp15 INTO TABLE temp14.
    
    lt_range = temp14.

    
    GET REFERENCE OF lt_range INTO temp16.

CREATE OBJECT lo_range TYPE z2ui5_cl_util_range EXPORTING iv_fieldname = `AMOUNT` ir_range = temp16.

    cl_abap_unit_assert=>assert_equals(
      exp = `( AMOUNT LT '200' )`
      act = lo_range->get_sql( ) ).

  ENDMETHOD.

  METHOD test_le_include.

    DATA temp17 TYPE z2ui5_cl_util=>ty_t_range.
    DATA temp18 LIKE LINE OF temp17.
    DATA lt_range LIKE temp17.
    DATA temp19 LIKE REF TO lt_range.
DATA lo_range TYPE REF TO z2ui5_cl_util_range.
    CLEAR temp17.
    
    temp18-sign = `I`.
    temp18-option = `LE`.
    temp18-low = `300`.
    temp18-high = ``.
    INSERT temp18 INTO TABLE temp17.
    
    lt_range = temp17.

    
    GET REFERENCE OF lt_range INTO temp19.

CREATE OBJECT lo_range TYPE z2ui5_cl_util_range EXPORTING iv_fieldname = `AMOUNT` ir_range = temp19.

    cl_abap_unit_assert=>assert_equals(
      exp = `( AMOUNT LE '300' )`
      act = lo_range->get_sql( ) ).

  ENDMETHOD.

  METHOD test_bt_include.

    DATA temp20 TYPE z2ui5_cl_util=>ty_t_range.
    DATA temp21 LIKE LINE OF temp20.
    DATA lt_range LIKE temp20.
    DATA temp22 LIKE REF TO lt_range.
DATA lo_range TYPE REF TO z2ui5_cl_util_range.
    CLEAR temp20.
    
    temp21-sign = `I`.
    temp21-option = `BT`.
    temp21-low = `100`.
    temp21-high = `500`.
    INSERT temp21 INTO TABLE temp20.
    
    lt_range = temp20.

    
    GET REFERENCE OF lt_range INTO temp22.

CREATE OBJECT lo_range TYPE z2ui5_cl_util_range EXPORTING iv_fieldname = `AMOUNT` ir_range = temp22.

    cl_abap_unit_assert=>assert_equals(
      exp = `( AMOUNT BETWEEN '100' AND '500' )`
      act = lo_range->get_sql( ) ).

  ENDMETHOD.

  METHOD test_nb_include.

    DATA temp23 TYPE z2ui5_cl_util=>ty_t_range.
    DATA temp24 LIKE LINE OF temp23.
    DATA lt_range LIKE temp23.
    DATA temp25 LIKE REF TO lt_range.
DATA lo_range TYPE REF TO z2ui5_cl_util_range.
    CLEAR temp23.
    
    temp24-sign = `I`.
    temp24-option = `NB`.
    temp24-low = `100`.
    temp24-high = `500`.
    INSERT temp24 INTO TABLE temp23.
    
    lt_range = temp23.

    
    GET REFERENCE OF lt_range INTO temp25.

CREATE OBJECT lo_range TYPE z2ui5_cl_util_range EXPORTING iv_fieldname = `AMOUNT` ir_range = temp25.

    cl_abap_unit_assert=>assert_equals(
      exp = `( AMOUNT NOT BETWEEN '100' AND '500' )`
      act = lo_range->get_sql( ) ).

  ENDMETHOD.

  METHOD test_cp_include.

    DATA temp26 TYPE z2ui5_cl_util=>ty_t_range.
    DATA temp27 LIKE LINE OF temp26.
    DATA lt_range LIKE temp26.
    DATA temp28 LIKE REF TO lt_range.
DATA lo_range TYPE REF TO z2ui5_cl_util_range.
    CLEAR temp26.
    
    temp27-sign = `I`.
    temp27-option = `CP`.
    temp27-low = `*test*`.
    temp27-high = ``.
    INSERT temp27 INTO TABLE temp26.
    
    lt_range = temp26.

    
    GET REFERENCE OF lt_range INTO temp28.

CREATE OBJECT lo_range TYPE z2ui5_cl_util_range EXPORTING iv_fieldname = `NAME` ir_range = temp28.

    cl_abap_unit_assert=>assert_equals(
      exp = `( NAME LIKE '%test%' )`
      act = lo_range->get_sql( ) ).

  ENDMETHOD.

  METHOD test_np_include.

    DATA temp29 TYPE z2ui5_cl_util=>ty_t_range.
    DATA temp30 LIKE LINE OF temp29.
    DATA lt_range LIKE temp29.
    DATA temp31 LIKE REF TO lt_range.
DATA lo_range TYPE REF TO z2ui5_cl_util_range.
    CLEAR temp29.
    
    temp30-sign = `I`.
    temp30-option = `NP`.
    temp30-low = `*test*`.
    temp30-high = ``.
    INSERT temp30 INTO TABLE temp29.
    
    lt_range = temp29.

    
    GET REFERENCE OF lt_range INTO temp31.

CREATE OBJECT lo_range TYPE z2ui5_cl_util_range EXPORTING iv_fieldname = `NAME` ir_range = temp31.

    cl_abap_unit_assert=>assert_equals(
      exp = `( NAME NOT LIKE '%test%' )`
      act = lo_range->get_sql( ) ).

  ENDMETHOD.

  METHOD test_exclude_sign.

    DATA temp32 TYPE z2ui5_cl_util=>ty_t_range.
    DATA temp33 LIKE LINE OF temp32.
    DATA lt_range LIKE temp32.
    DATA temp34 LIKE REF TO lt_range.
DATA lo_range TYPE REF TO z2ui5_cl_util_range.
    CLEAR temp32.
    
    temp33-sign = `E`.
    temp33-option = `EQ`.
    temp33-low = `XX`.
    temp33-high = ``.
    INSERT temp33 INTO TABLE temp32.
    
    lt_range = temp32.

    
    GET REFERENCE OF lt_range INTO temp34.

CREATE OBJECT lo_range TYPE z2ui5_cl_util_range EXPORTING iv_fieldname = `CARRID` ir_range = temp34.

    cl_abap_unit_assert=>assert_equals(
      exp = `( NOT CARRID EQ 'XX' )`
      act = lo_range->get_sql( ) ).

  ENDMETHOD.

  METHOD test_multiple_entries.

    DATA temp35 TYPE z2ui5_cl_util=>ty_t_range.
    DATA temp36 LIKE LINE OF temp35.
    DATA lt_range LIKE temp35.
    DATA temp37 LIKE REF TO lt_range.
DATA lo_range TYPE REF TO z2ui5_cl_util_range.
    CLEAR temp35.
    
    temp36-sign = `I`.
    temp36-option = `EQ`.
    temp36-low = `AA`.
    temp36-high = ``.
    INSERT temp36 INTO TABLE temp35.
    temp36-sign = `I`.
    temp36-option = `EQ`.
    temp36-low = `BB`.
    temp36-high = ``.
    INSERT temp36 INTO TABLE temp35.
    
    lt_range = temp35.

    
    GET REFERENCE OF lt_range INTO temp37.

CREATE OBJECT lo_range TYPE z2ui5_cl_util_range EXPORTING iv_fieldname = `CARRID` ir_range = temp37.

    cl_abap_unit_assert=>assert_equals(
      exp = `( CARRID EQ 'AA' OR CARRID EQ 'BB' )`
      act = lo_range->get_sql( ) ).

  ENDMETHOD.

  METHOD test_quote_escape.

    DATA temp38 TYPE z2ui5_cl_util=>ty_t_range.
    DATA temp39 LIKE LINE OF temp38.
    DATA lt_range LIKE temp38.
    DATA temp40 LIKE REF TO lt_range.
DATA lo_range TYPE REF TO z2ui5_cl_util_range.
    CLEAR temp38.
    
    temp39-sign = `I`.
    temp39-option = `EQ`.
    temp39-low = `O'Brien`.
    temp39-high = ``.
    INSERT temp39 INTO TABLE temp38.
    
    lt_range = temp38.

    
    GET REFERENCE OF lt_range INTO temp40.

CREATE OBJECT lo_range TYPE z2ui5_cl_util_range EXPORTING iv_fieldname = `NAME` ir_range = temp40.

    cl_abap_unit_assert=>assert_equals(
      exp = `( NAME EQ 'O''Brien' )`
      act = lo_range->get_sql( ) ).

  ENDMETHOD.

  METHOD test_fieldname_upper.

    DATA temp41 TYPE z2ui5_cl_util=>ty_t_range.
    DATA temp42 LIKE LINE OF temp41.
    DATA lt_range LIKE temp41.
    DATA temp43 LIKE REF TO lt_range.
DATA lo_range TYPE REF TO z2ui5_cl_util_range.
    DATA lv_sql TYPE string.
    DATA temp1 TYPE xsdboolean.
    CLEAR temp41.
    
    temp42-sign = `I`.
    temp42-option = `EQ`.
    temp42-low = `test`.
    temp42-high = ``.
    INSERT temp42 INTO TABLE temp41.
    
    lt_range = temp41.

    
    GET REFERENCE OF lt_range INTO temp43.

CREATE OBJECT lo_range TYPE z2ui5_cl_util_range EXPORTING iv_fieldname = `carrid` ir_range = temp43.

    
    lv_sql = lo_range->get_sql( ).

    
    temp1 = boolc( lv_sql CS `CARRID` ).
    cl_abap_unit_assert=>assert_true(
      temp1 ).

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

    DATA ls_range TYPE z2ui5_cl_util=>ty_s_range.
    ls_range = z2ui5_cl_util_range=>eq( `AA` ).

    cl_abap_unit_assert=>assert_equals( exp = `I`  act = ls_range-sign ).
    cl_abap_unit_assert=>assert_equals( exp = `EQ` act = ls_range-option ).
    cl_abap_unit_assert=>assert_equals( exp = `AA` act = ls_range-low ).

  ENDMETHOD.

  METHOD test_factory_ne.

    DATA ls_range TYPE z2ui5_cl_util=>ty_s_range.
    ls_range = z2ui5_cl_util_range=>ne( `BB` ).

    cl_abap_unit_assert=>assert_equals( exp = `NE` act = ls_range-option ).
    cl_abap_unit_assert=>assert_equals( exp = `BB` act = ls_range-low ).

  ENDMETHOD.

  METHOD test_factory_bt.

    DATA ls_range TYPE z2ui5_cl_util=>ty_s_range.
    ls_range = z2ui5_cl_util_range=>bt( low = `100` high = `500` ).

    cl_abap_unit_assert=>assert_equals( exp = `BT`  act = ls_range-option ).
    cl_abap_unit_assert=>assert_equals( exp = `100` act = ls_range-low ).
    cl_abap_unit_assert=>assert_equals( exp = `500` act = ls_range-high ).

  ENDMETHOD.

  METHOD test_factory_cp.

    DATA ls_range TYPE z2ui5_cl_util=>ty_s_range.
    ls_range = z2ui5_cl_util_range=>cp( `*test*` ).

    cl_abap_unit_assert=>assert_equals( exp = `CP`      act = ls_range-option ).
    cl_abap_unit_assert=>assert_equals( exp = `*test*`  act = ls_range-low ).

  ENDMETHOD.

  METHOD test_factory_gt.

    DATA ls_range TYPE z2ui5_cl_util=>ty_s_range.
    ls_range = z2ui5_cl_util_range=>gt( `100` ).

    cl_abap_unit_assert=>assert_equals( exp = `GT`  act = ls_range-option ).
    cl_abap_unit_assert=>assert_equals( exp = `100` act = ls_range-low ).

  ENDMETHOD.

  METHOD test_factory_ge.

    DATA ls_range TYPE z2ui5_cl_util=>ty_s_range.
    ls_range = z2ui5_cl_util_range=>ge( `50` ).

    cl_abap_unit_assert=>assert_equals( exp = `GE` act = ls_range-option ).
    cl_abap_unit_assert=>assert_equals( exp = `50` act = ls_range-low ).

  ENDMETHOD.

  METHOD test_factory_lt.

    DATA ls_range TYPE z2ui5_cl_util=>ty_s_range.
    ls_range = z2ui5_cl_util_range=>lt( `200` ).

    cl_abap_unit_assert=>assert_equals( exp = `LT`  act = ls_range-option ).
    cl_abap_unit_assert=>assert_equals( exp = `200` act = ls_range-low ).

  ENDMETHOD.

  METHOD test_factory_le.

    DATA ls_range TYPE z2ui5_cl_util=>ty_s_range.
    ls_range = z2ui5_cl_util_range=>le( `300` ).

    cl_abap_unit_assert=>assert_equals( exp = `LE`  act = ls_range-option ).
    cl_abap_unit_assert=>assert_equals( exp = `300` act = ls_range-low ).

  ENDMETHOD.

  METHOD test_factory_exclude.

    DATA ls_range TYPE z2ui5_cl_util=>ty_s_range.
    ls_range = z2ui5_cl_util_range=>eq( val = `XX` sign = `E` ).

    cl_abap_unit_assert=>assert_equals( exp = `E`  act = ls_range-sign ).
    cl_abap_unit_assert=>assert_equals( exp = `EQ` act = ls_range-option ).

  ENDMETHOD.

  METHOD test_factory_with_sql.

    DATA temp44 TYPE z2ui5_cl_util=>ty_t_range.
    DATA lt_range LIKE temp44.
    DATA temp46 LIKE REF TO lt_range.
DATA lo_range TYPE REF TO z2ui5_cl_util_range.
    CLEAR temp44.
    INSERT z2ui5_cl_util_range=>eq( `AA` ) INTO TABLE temp44.
    INSERT z2ui5_cl_util_range=>eq( `BB` ) INTO TABLE temp44.
    
    lt_range = temp44.

    
    GET REFERENCE OF lt_range INTO temp46.

CREATE OBJECT lo_range TYPE z2ui5_cl_util_range EXPORTING iv_fieldname = `CARRID` ir_range = temp46.

    cl_abap_unit_assert=>assert_equals(
      exp = `( CARRID EQ 'AA' OR CARRID EQ 'BB' )`
      act = lo_range->get_sql( ) ).

  ENDMETHOD.

  METHOD test_get_sql_multi.

    DATA temp47 TYPE z2ui5_cl_util=>ty_t_range.
    DATA lt_r1 LIKE temp47.
    DATA temp49 TYPE z2ui5_cl_util=>ty_t_range.
    DATA lt_r2 LIKE temp49.
    DATA temp51 LIKE REF TO lt_r1.
DATA lv_sql1 TYPE string.
DATA temp1 TYPE REF TO z2ui5_cl_util_range.
    DATA temp52 LIKE REF TO lt_r2.
DATA lv_sql2 TYPE string.
DATA temp2 TYPE REF TO z2ui5_cl_util_range.
    DATA temp53 TYPE string_table.
    DATA lv_result TYPE string.
    DATA temp3 TYPE xsdboolean.
    DATA temp4 TYPE xsdboolean.
    DATA temp5 TYPE xsdboolean.
    CLEAR temp47.
    INSERT z2ui5_cl_util_range=>eq( `LH` ) INTO TABLE temp47.
    
    lt_r1 = temp47.
    
    CLEAR temp49.
    INSERT z2ui5_cl_util_range=>bt( low = `100` high = `500` ) INTO TABLE temp49.
    
    lt_r2 = temp49.

    
    GET REFERENCE OF lt_r1 INTO temp51.


CREATE OBJECT temp1 TYPE z2ui5_cl_util_range EXPORTING iv_fieldname = `CARRID` ir_range = temp51.
lv_sql1 = temp1->get_sql( ).
    
    GET REFERENCE OF lt_r2 INTO temp52.


CREATE OBJECT temp2 TYPE z2ui5_cl_util_range EXPORTING iv_fieldname = `CONNID` ir_range = temp52.
lv_sql2 = temp2->get_sql( ).

    
    CLEAR temp53.
    INSERT lv_sql1 INTO TABLE temp53.
    INSERT lv_sql2 INTO TABLE temp53.
    
    lv_result = z2ui5_cl_util_range=>get_sql_multi( temp53 ).

    
    temp3 = boolc( lv_result CS `CARRID` ).
    cl_abap_unit_assert=>assert_true( temp3 ).
    
    temp4 = boolc( lv_result CS `AND` ).
    cl_abap_unit_assert=>assert_true( temp4 ).
    
    temp5 = boolc( lv_result CS `CONNID` ).
    cl_abap_unit_assert=>assert_true( temp5 ).

  ENDMETHOD.

ENDCLASS.
