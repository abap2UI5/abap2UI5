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

    IF gi_me IS NOT INITIAL.
      ri_exit = gi_me.
    ENDIF.

    DATA(exit_classes) = z2ui5_cl_util_abap=>rtti_get_classes_impl_intf( 'Z2UI5_IF_EXIT' ).
    DELETE exit_classes WHERE classname = 'Z2UI5_CL_EXIT'.

    IF exit_classes IS NOT INITIAL.
      lv_class_name = exit_classes[ 1 ]-classname.
      TRY.
          CREATE OBJECT gi_user_exit TYPE (lv_class_name).
        CATCH cx_root ##NO_HANDLER.
      ENDTRY.
    ENDIF.

    gi_me = NEW z2ui5_cl_exit( ).

    ri_exit = gi_me.

  ENDMETHOD.


  METHOD z2ui5_if_exit~get_draft_exp_time_in_hours.

    IF gi_user_exit IS NOT INITIAL.
      rv_draft_exp_time_in_hours = gi_user_exit->get_draft_exp_time_in_hours( ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.
