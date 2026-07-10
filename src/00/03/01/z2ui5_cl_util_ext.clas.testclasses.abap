CLASS ltcl_unit_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    METHODS test_bal_read                  FOR TESTING RAISING cx_static_check.
    METHODS test_bal_create                FOR TESTING RAISING cx_static_check.
    METHODS test_bal_update                FOR TESTING RAISING cx_static_check.
    METHODS test_bal_delete                FOR TESTING RAISING cx_static_check.
    METHODS test_lock_get_dequeue        FOR TESTING RAISING cx_static_check.
    METHODS test_source_get_method         FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_unit_test IMPLEMENTATION.

  METHOD test_bal_read.

    IF sy-sysid = `ABC`.
      RETURN.
    ENDIF.

    DATA lt_msg TYPE z2ui5_cl_util=>ty_t_msg.
    DATA(lt_result) = z2ui5_cl_util_ext=>bal_read( object    = `TEST`
                                                    subobject = `TEST`
                                                    id        = `TEST` ) ##NEEDED.

  ENDMETHOD.

  METHOD test_bal_create.

    IF sy-sysid = `ABC`.
      RETURN.
    ENDIF.

    DATA lt_log TYPE z2ui5_cl_util=>ty_t_msg.
    z2ui5_cl_util_ext=>bal_create( object    = `TEST`
                                   subobject = `TEST`
                                   id        = `TEST`
                                   t_log     = lt_log ).

  ENDMETHOD.

  METHOD test_bal_update.

    IF sy-sysid = `ABC`.
      RETURN.
    ENDIF.

    DATA lt_log TYPE z2ui5_cl_util=>ty_t_msg.
    z2ui5_cl_util_ext=>bal_update( object    = `TEST`
                                   subobject = `TEST`
                                   id        = `TEST`
                                   t_log     = lt_log ).

  ENDMETHOD.

  METHOD test_bal_delete.

    IF sy-sysid = `ABC`.
      RETURN.
    ENDIF.

    z2ui5_cl_util_ext=>bal_delete( object    = `TEST`
                                   subobject = `TEST`
                                   id        = `TEST` ).

  ENDMETHOD.


  METHOD test_lock_get_dequeue.

    DATA lv_result TYPE string.

    lv_result = z2ui5_cl_util_ext=>lock_get_dequeue_by_enqueue( `ENQUEUE_EVVBAKE` ).
    cl_abap_unit_assert=>assert_equals( exp = `DEQUEUE_EVVBAKE`
                                        act = lv_result ).

    lv_result = z2ui5_cl_util_ext=>lock_get_dequeue_by_enqueue( `enqueue_evvbake` ).
    cl_abap_unit_assert=>assert_equals( exp = `DEQUEUE_EVVBAKE`
                                        act = lv_result ).

    lv_result = z2ui5_cl_util_ext=>lock_get_dequeue_by_enqueue( `DEQUEUE_EVVBAKE` ).
    cl_abap_unit_assert=>assert_equals( exp = `DEQUEUE_EVVBAKE`
                                        act = lv_result ).

  ENDMETHOD.

  METHOD test_source_get_method.

    IF sy-sysid = `ABC`.
      RETURN.
    ENDIF.

    DATA(lt_source) = z2ui5_cl_util_ext=>source_get_method(
      iv_classname  = `Z2UI5_CL_UTIL`
      iv_methodname = `UUID_GET_C32` ) ##NEEDED.

  ENDMETHOD.

ENDCLASS.
