
CLASS ltcl_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    METHODS test_factory_w_bapiret FOR TESTING RAISING cx_static_check.
    METHODS test_factory_w_cx     FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_test IMPLEMENTATION.

  METHOD test_factory_w_bapiret.

    IF sy-sysid = `ABC`.
      RETURN.
    ENDIF.

    DATA(lt_msg) = VALUE bapirettab(
      ( type = `E` id = `MSG1` number = `001` message = `Error occurred` )
      ( type = `I` id = `MSG2` number = `002` message = `Info message` ) ).

    DATA(lo_pop) = z2ui5_cl_pop_messages=>factory( lt_msg ).
    cl_abap_unit_assert=>assert_bound( lo_pop ).
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( lo_pop->mt_msg ) ).

  ENDMETHOD.

  METHOD test_factory_w_cx.

    TRY.
        DATA(lv_val) = 1 / 0 ##NEEDED.
      CATCH cx_root INTO DATA(lx).
    ENDTRY.

    DATA(lo_pop) = z2ui5_cl_pop_messages=>factory( lx ).
    cl_abap_unit_assert=>assert_bound( lo_pop ).
    cl_abap_unit_assert=>assert_not_initial( lo_pop->mt_msg ).

  ENDMETHOD.

ENDCLASS.
