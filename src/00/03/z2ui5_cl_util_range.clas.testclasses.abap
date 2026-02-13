
CLASS ltcl_unit_test_range DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    METHODS test_constructor             FOR TESTING RAISING cx_static_check.
    METHODS test_get_sql_empty_range     FOR TESTING RAISING cx_static_check.
    METHODS test_get_sql_eq              FOR TESTING RAISING cx_static_check.
    METHODS test_get_sql_ne              FOR TESTING RAISING cx_static_check.
    METHODS test_get_sql_gt              FOR TESTING RAISING cx_static_check.
    METHODS test_get_sql_ge              FOR TESTING RAISING cx_static_check.
    METHODS test_get_sql_lt              FOR TESTING RAISING cx_static_check.
    METHODS test_get_sql_le              FOR TESTING RAISING cx_static_check.
    METHODS test_get_sql_bt              FOR TESTING RAISING cx_static_check.
    METHODS test_get_sql_nb              FOR TESTING RAISING cx_static_check.
    METHODS test_get_sql_cp              FOR TESTING RAISING cx_static_check.
    METHODS test_get_sql_np              FOR TESTING RAISING cx_static_check.
    METHODS test_get_sql_excluding       FOR TESTING RAISING cx_static_check.
    METHODS test_get_sql_multiple        FOR TESTING RAISING cx_static_check.
    METHODS test_get_sql_fieldname_upper FOR TESTING RAISING cx_static_check.
    METHODS test_quote_simple            FOR TESTING RAISING cx_static_check.
    METHODS test_quote_with_apostrophe   FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_unit_test_range IMPLEMENTATION.

  METHOD test_constructor.

    DATA lt_range TYPE z2ui5_cl_util=>ty_t_range.
    lt_range = VALUE #( ( sign = `I` option = `EQ` low = `TEST` ) ).

    DATA(lo_range) = NEW z2ui5_cl_util_range(
        iv_fieldname = `MATNR`
        ir_range     = REF #( lt_range ) ).

    cl_abap_unit_assert=>assert_bound( lo_range ).

  ENDMETHOD.

  METHOD test_get_sql_empty_range.

    DATA lt_range TYPE z2ui5_cl_util=>ty_t_range.

    DATA(lo_range) = NEW z2ui5_cl_util_range(
        iv_fieldname = `MATNR`
        ir_range     = REF #( lt_range ) ).

    DATA(lv_sql) = lo_range->get_sql( ).

    cl_abap_unit_assert=>assert_initial( lv_sql ).

  ENDMETHOD.

  METHOD test_get_sql_eq.

    DATA lt_range TYPE z2ui5_cl_util=>ty_t_range.
    lt_range = VALUE #( ( sign = `I` option = `EQ` low = `100` ) ).

    DATA(lo_range) = NEW z2ui5_cl_util_range(
        iv_fieldname = `MATNR`
        ir_range     = REF #( lt_range ) ).

    DATA(lv_sql) = lo_range->get_sql( ).

    cl_abap_unit_assert=>assert_char_cp(
        act = lv_sql
        exp = `*MATNR EQ '100'*` ).

  ENDMETHOD.

  METHOD test_get_sql_ne.

    DATA lt_range TYPE z2ui5_cl_util=>ty_t_range.
    lt_range = VALUE #( ( sign = `I` option = `NE` low = `200` ) ).

    DATA(lo_range) = NEW z2ui5_cl_util_range(
        iv_fieldname = `STATUS`
        ir_range     = REF #( lt_range ) ).

    DATA(lv_sql) = lo_range->get_sql( ).

    cl_abap_unit_assert=>assert_char_cp(
        act = lv_sql
        exp = `*STATUS NE '200'*` ).

  ENDMETHOD.

  METHOD test_get_sql_gt.

    DATA lt_range TYPE z2ui5_cl_util=>ty_t_range.
    lt_range = VALUE #( ( sign = `I` option = `GT` low = `50` ) ).

    DATA(lo_range) = NEW z2ui5_cl_util_range(
        iv_fieldname = `AMOUNT`
        ir_range     = REF #( lt_range ) ).

    DATA(lv_sql) = lo_range->get_sql( ).

    cl_abap_unit_assert=>assert_char_cp(
        act = lv_sql
        exp = `*AMOUNT GT '50'*` ).

  ENDMETHOD.

  METHOD test_get_sql_ge.

    DATA lt_range TYPE z2ui5_cl_util=>ty_t_range.
    lt_range = VALUE #( ( sign = `I` option = `GE` low = `10` ) ).

    DATA(lo_range) = NEW z2ui5_cl_util_range(
        iv_fieldname = `QTY`
        ir_range     = REF #( lt_range ) ).

    DATA(lv_sql) = lo_range->get_sql( ).

    cl_abap_unit_assert=>assert_char_cp(
        act = lv_sql
        exp = `*QTY GE '10'*` ).

  ENDMETHOD.

  METHOD test_get_sql_lt.

    DATA lt_range TYPE z2ui5_cl_util=>ty_t_range.
    lt_range = VALUE #( ( sign = `I` option = `LT` low = `99` ) ).

    DATA(lo_range) = NEW z2ui5_cl_util_range(
        iv_fieldname = `PRICE`
        ir_range     = REF #( lt_range ) ).

    DATA(lv_sql) = lo_range->get_sql( ).

    cl_abap_unit_assert=>assert_char_cp(
        act = lv_sql
        exp = `*PRICE LT '99'*` ).

  ENDMETHOD.

  METHOD test_get_sql_le.

    DATA lt_range TYPE z2ui5_cl_util=>ty_t_range.
    lt_range = VALUE #( ( sign = `I` option = `LE` low = `500` ) ).

    DATA(lo_range) = NEW z2ui5_cl_util_range(
        iv_fieldname = `WEIGHT`
        ir_range     = REF #( lt_range ) ).

    DATA(lv_sql) = lo_range->get_sql( ).

    cl_abap_unit_assert=>assert_char_cp(
        act = lv_sql
        exp = `*WEIGHT LE '500'*` ).

  ENDMETHOD.

  METHOD test_get_sql_bt.

    DATA lt_range TYPE z2ui5_cl_util=>ty_t_range.
    lt_range = VALUE #( ( sign = `I` option = `BT` low = `100` high = `200` ) ).

    DATA(lo_range) = NEW z2ui5_cl_util_range(
        iv_fieldname = `MATNR`
        ir_range     = REF #( lt_range ) ).

    DATA(lv_sql) = lo_range->get_sql( ).

    cl_abap_unit_assert=>assert_char_cp(
        act = lv_sql
        exp = `*MATNR BETWEEN '100' AND '200'*` ).

  ENDMETHOD.

  METHOD test_get_sql_nb.

    DATA lt_range TYPE z2ui5_cl_util=>ty_t_range.
    lt_range = VALUE #( ( sign = `I` option = `NB` low = `A` high = `Z` ) ).

    DATA(lo_range) = NEW z2ui5_cl_util_range(
        iv_fieldname = `CODE`
        ir_range     = REF #( lt_range ) ).

    DATA(lv_sql) = lo_range->get_sql( ).

    cl_abap_unit_assert=>assert_char_cp(
        act = lv_sql
        exp = `*CODE NOT BETWEEN 'A' AND 'Z'*` ).

  ENDMETHOD.

  METHOD test_get_sql_cp.

    DATA lt_range TYPE z2ui5_cl_util=>ty_t_range.
    lt_range = VALUE #( ( sign = `I` option = `CP` low = `*TEST*` ) ).

    DATA(lo_range) = NEW z2ui5_cl_util_range(
        iv_fieldname = `DESCR`
        ir_range     = REF #( lt_range ) ).

    DATA(lv_sql) = lo_range->get_sql( ).

    cl_abap_unit_assert=>assert_char_cp(
        act = lv_sql
        exp = `*DESCR LIKE*` ).

  ENDMETHOD.

  METHOD test_get_sql_np.

    DATA lt_range TYPE z2ui5_cl_util=>ty_t_range.
    lt_range = VALUE #( ( sign = `I` option = `NP` low = `*OLD*` ) ).

    DATA(lo_range) = NEW z2ui5_cl_util_range(
        iv_fieldname = `NAME`
        ir_range     = REF #( lt_range ) ).

    DATA(lv_sql) = lo_range->get_sql( ).

    cl_abap_unit_assert=>assert_char_cp(
        act = lv_sql
        exp = `*NAME NOT LIKE*` ).

  ENDMETHOD.

  METHOD test_get_sql_excluding.

    DATA lt_range TYPE z2ui5_cl_util=>ty_t_range.
    lt_range = VALUE #( ( sign = `E` option = `EQ` low = `BLOCKED` ) ).

    DATA(lo_range) = NEW z2ui5_cl_util_range(
        iv_fieldname = `STATUS`
        ir_range     = REF #( lt_range ) ).

    DATA(lv_sql) = lo_range->get_sql( ).

    cl_abap_unit_assert=>assert_char_cp(
        act = lv_sql
        exp = `* NOT STATUS EQ 'BLOCKED'*` ).

  ENDMETHOD.

  METHOD test_get_sql_multiple.

    DATA lt_range TYPE z2ui5_cl_util=>ty_t_range.
    lt_range = VALUE #( ( sign = `I` option = `EQ` low = `A` )
                        ( sign = `I` option = `EQ` low = `B` ) ).

    DATA(lo_range) = NEW z2ui5_cl_util_range(
        iv_fieldname = `TYPE`
        ir_range     = REF #( lt_range ) ).

    DATA(lv_sql) = lo_range->get_sql( ).

    cl_abap_unit_assert=>assert_char_cp(
        act = lv_sql
        exp = `*TYPE EQ 'A' OR TYPE EQ 'B'*` ).

  ENDMETHOD.

  METHOD test_get_sql_fieldname_upper.

    DATA lt_range TYPE z2ui5_cl_util=>ty_t_range.
    lt_range = VALUE #( ( sign = `I` option = `EQ` low = `X` ) ).

    DATA(lo_range) = NEW z2ui5_cl_util_range(
        iv_fieldname = `lower_field`
        ir_range     = REF #( lt_range ) ).

    DATA(lv_sql) = lo_range->get_sql( ).

    cl_abap_unit_assert=>assert_char_cp(
        act = lv_sql
        exp = `*LOWER_FIELD EQ*` ).

  ENDMETHOD.

  METHOD test_quote_simple.

    DATA lt_range TYPE z2ui5_cl_util=>ty_t_range.
    lt_range = VALUE #( ( sign = `I` option = `EQ` low = `hello` ) ).

    DATA(lo_range) = NEW z2ui5_cl_util_range(
        iv_fieldname = `F`
        ir_range     = REF #( lt_range ) ).

    DATA(lv_sql) = lo_range->get_sql( ).

    cl_abap_unit_assert=>assert_char_cp(
        act = lv_sql
        exp = `*'hello'*` ).

  ENDMETHOD.

  METHOD test_quote_with_apostrophe.

    DATA lt_range TYPE z2ui5_cl_util=>ty_t_range.
    lt_range = VALUE #( ( sign = `I` option = `EQ` low = `it's` ) ).

    DATA(lo_range) = NEW z2ui5_cl_util_range(
        iv_fieldname = `F`
        ir_range     = REF #( lt_range ) ).

    DATA(lv_sql) = lo_range->get_sql( ).

    cl_abap_unit_assert=>assert_char_cp(
        act = lv_sql
        exp = `*'it''s'*` ).

  ENDMETHOD.

ENDCLASS.
