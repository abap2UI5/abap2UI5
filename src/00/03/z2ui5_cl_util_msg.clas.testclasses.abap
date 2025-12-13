
CLASS ltcl_unit_test_msg_mapper DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    METHODS test_bal            FOR TESTING RAISING cx_static_check.
    METHODS test_cx            FOR TESTING RAISING cx_static_check.
    METHODS test_bapiret       FOR TESTING RAISING cx_static_check.
    METHODS test_bapirettab       FOR TESTING RAISING cx_static_check.
    METHODS test_sy       FOR TESTING RAISING cx_static_check.


ENDCLASS.

CLASS ltcl_unit_test_msg_mapper IMPLEMENTATION.

  METHOD test_sy.
    DATA lv_dummy2 TYPE string.
    DATA lv_dummy TYPE string.
    DATA lt_result TYPE z2ui5_cl_util=>ty_t_msg.
   DATA temp1 LIKE LINE OF lt_result.
   DATA temp2 LIKE sy-tabix.
    DATA temp3 LIKE LINE OF lt_result.
    DATA temp4 LIKE sy-tabix.
    DATA temp5 LIKE LINE OF lt_result.
    DATA temp6 LIKE sy-tabix.

    IF sy-sysid = `ABC`.
      RETURN.
    ENDIF.

    
    lv_dummy2 = `NET`.
    
    MESSAGE ID lv_dummy2 TYPE `I` NUMBER `001` INTO lv_dummy.
    
    lt_result = z2ui5_cl_util_msg=>msg_get_by_sy( ).

   
   
   temp2 = sy-tabix.
   READ TABLE lt_result INDEX 1 INTO temp1.
   sy-tabix = temp2.
   IF sy-subrc <> 0.
     ASSERT 1 = 0.
   ENDIF.
   cl_abap_unit_assert=>assert_equals( exp = `NET`
                                        act = temp1-id ).

    
    
    temp4 = sy-tabix.
    READ TABLE lt_result INDEX 1 INTO temp3.
    sy-tabix = temp4.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `001`
                                    act = temp3-no ).

    
    
    temp6 = sy-tabix.
    READ TABLE lt_result INDEX 1 INTO temp5.
    sy-tabix = temp6.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `I`
                                        act = temp5-type ).

  ENDMETHOD.

  METHOD test_bapiret.
    DATA temp7 TYPE bapirettab.
    DATA temp8 LIKE LINE OF temp7.
    DATA lt_msg LIKE temp7.
    DATA lt_result TYPE z2ui5_cl_util=>ty_t_msg.
    DATA temp1 LIKE LINE OF lt_msg.
    DATA temp2 LIKE sy-tabix.
    DATA temp9 LIKE LINE OF lt_result.
    DATA temp10 LIKE sy-tabix.
    DATA temp11 LIKE LINE OF lt_result.
    DATA temp12 LIKE sy-tabix.
    DATA temp13 LIKE LINE OF lt_result.
    DATA temp14 LIKE sy-tabix.

    IF sy-sysid = `ABC`.
      RETURN.
    ENDIF.

    
    CLEAR temp7.
    
    temp8-type = `E`.
    temp8-id = `MSG1`.
    temp8-number = `001`.
    temp8-message = `An empty Report field causes an empty XML Message to be sent`.
    INSERT temp8 INTO TABLE temp7.
    
    lt_msg = temp7.

    
    
    
    temp2 = sy-tabix.
    READ TABLE lt_msg INDEX 1 INTO temp1.
    sy-tabix = temp2.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    lt_result = z2ui5_cl_util_msg=>msg_get( temp1 ).

    
    
    temp10 = sy-tabix.
    READ TABLE lt_result INDEX 1 INTO temp9.
    sy-tabix = temp10.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `MSG1`
                                        act = temp9-id ).

    
    
    temp12 = sy-tabix.
    READ TABLE lt_result INDEX 1 INTO temp11.
    sy-tabix = temp12.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `001`
                                    act = temp11-no ).

    
    
    temp14 = sy-tabix.
    READ TABLE lt_result INDEX 1 INTO temp13.
    sy-tabix = temp14.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `E`
                                        act = temp13-type ).

  ENDMETHOD.

  METHOD test_bapirettab.
    DATA temp15 TYPE bapirettab.
    DATA temp16 LIKE LINE OF temp15.
    DATA lt_msg LIKE temp15.
    DATA lt_result TYPE z2ui5_cl_util=>ty_t_msg.
   DATA temp17 LIKE LINE OF lt_result.
   DATA temp18 LIKE sy-tabix.
    DATA temp19 LIKE LINE OF lt_result.
    DATA temp20 LIKE sy-tabix.
    DATA temp21 LIKE LINE OF lt_result.
    DATA temp22 LIKE sy-tabix.

    IF sy-sysid = `ABC`.
      RETURN.
    ENDIF.

    
    CLEAR temp15.
    
    temp16-type = `E`.
    temp16-id = `MSG1`.
    temp16-number = `001`.
    temp16-message = `An empty Report field causes an empty XML Message to be sent`.
    INSERT temp16 INTO TABLE temp15.
    temp16-type = `I`.
    temp16-id = `MSG2`.
    temp16-number = `002`.
    temp16-message = `Product already in use`.
    INSERT temp16 INTO TABLE temp15.
    
    lt_msg = temp15.

    
    lt_result = z2ui5_cl_util_msg=>msg_get( lt_msg ).

   
   
   temp18 = sy-tabix.
   READ TABLE lt_result INDEX 1 INTO temp17.
   sy-tabix = temp18.
   IF sy-subrc <> 0.
     ASSERT 1 = 0.
   ENDIF.
   cl_abap_unit_assert=>assert_equals( exp = `MSG1`
                                        act = temp17-id ).

    
    
    temp20 = sy-tabix.
    READ TABLE lt_result INDEX 1 INTO temp19.
    sy-tabix = temp20.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `001`
                                    act = temp19-no ).

    
    
    temp22 = sy-tabix.
    READ TABLE lt_result INDEX 1 INTO temp21.
    sy-tabix = temp22.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `E`
                                        act = temp21-type ).

  ENDMETHOD.

  METHOD test_cx.
        DATA lv_val TYPE i.
        DATA lx TYPE REF TO cx_root.
        DATA lt_result TYPE z2ui5_cl_util=>ty_t_msg.
    DATA temp23 LIKE LINE OF lt_result.
    DATA temp24 LIKE sy-tabix.

    TRY.
        
        lv_val = 1 / 0.
        
      CATCH cx_root INTO lx.
        
        lt_result = z2ui5_cl_util_msg=>msg_get( lx ).
    ENDTRY.

    
    
    temp24 = sy-tabix.
    READ TABLE lt_result INDEX 1 INTO temp23.
    sy-tabix = temp24.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `E`
                                        act = temp23-type ).


  ENDMETHOD.

  method test_bal.

  TYPES: BEGIN OF ty_log_entry,
         msgnumber   TYPE n LENGTH 6,      " Application Log: Internal Message Serial Number
         msgty       TYPE c LENGTH 1,      " Message Type
         msgid       TYPE c LENGTH 20,     " Message Class
         msgno       TYPE n LENGTH 3,      " Message Number
         msgv1       TYPE c LENGTH 50,     " Message Variable
         msgv2       TYPE c LENGTH 50,     " Message Variable
         msgv3       TYPE c LENGTH 50,     " Message Variable
         msgv4       TYPE c LENGTH 50,     " Message Variable
         msgv1_src   TYPE c LENGTH 15,     " Origin of a Message Variable
         msgv2_src   TYPE c LENGTH 15,     " Origin of a Message Variable
         msgv3_src   TYPE c LENGTH 15,     " Origin of a Message Variable
         msgv4_src   TYPE c LENGTH 15,     " Origin of a Message Variable
         detlevel    TYPE c LENGTH 1,      " Level of Detail
         probclass   TYPE c LENGTH 1,      " Problem Class
         alsort      TYPE c LENGTH 3,      " Sort Criterion/Grouping
         time_stmp   TYPE p LENGTH 8 DECIMALS 7, " Message Time Stamp
         msg_count   TYPE i,               " Cumulated Message Count
         context     TYPE c LENGTH 255,    " Context (Generic Placeholder)
         params      TYPE c LENGTH 255,    " Parameters (Generic Placeholder)
         msg_txt     TYPE string,          " Message Text
       END OF ty_log_entry.

  endmethod.

ENDCLASS.
