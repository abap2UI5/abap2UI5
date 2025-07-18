CLASS z2ui5_cl_exit DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES z2ui5_if_exit.

    CLASS-METHODS get_instance
        RETURNING
          VALUE(ri_exit) TYPE REF TO z2ui5_if_exit.

  PRIVATE SECTION.
    CLASS-DATA:
      gi_me        TYPE REF TO z2ui5_if_exit,
      gi_user_exit TYPE REF TO z2ui5_if_exit.

ENDCLASS.



CLASS z2ui5_cl_exit IMPLEMENTATION.

  METHOD get_instance.

    DATA lv_class_name TYPE string.
    DATA exit_classes TYPE z2ui5_cl_util_abap=>ty_t_classes.
        DATA temp1 LIKE LINE OF exit_classes.
        DATA temp2 LIKE sy-tabix.

    IF gi_me IS NOT INITIAL.
      ri_exit = gi_me.
    ENDIF.

    
    exit_classes = z2ui5_cl_util_abap=>rtti_get_classes_impl_intf( 'Z2UI5_IF_EXIT' ).
    DELETE exit_classes WHERE classname = 'Z2UI5_CL_EXIT'.

    TRY.
        
        
        temp2 = sy-tabix.
        READ TABLE exit_classes INDEX 1 INTO temp1.
        sy-tabix = temp2.
        IF sy-subrc <> 0.
          ASSERT 1 = 0.
        ENDIF.
        lv_class_name = temp1-classname.
        CREATE OBJECT gi_user_exit TYPE (lv_class_name).
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

    CREATE OBJECT gi_me TYPE z2ui5_cl_exit.

    ri_exit = gi_me.

  ENDMETHOD.


  METHOD z2ui5_if_exit~get_draft_exp_time_in_hours.

    IF gi_user_exit IS NOT INITIAL.
      rv_draft_exp_time_in_hours = gi_user_exit->get_draft_exp_time_in_hours( ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.
