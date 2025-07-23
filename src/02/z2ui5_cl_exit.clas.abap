CLASS z2ui5_cl_exit DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES z2ui5_if_exit.

    CLASS-METHODS get_instance
      RETURNING
        VALUE(ri_exit) TYPE REF TO z2ui5_if_exit.

    CLASS-METHODS get_user_exit_class
      RETURNING
        VALUE(r_class_name) TYPE string.

  PRIVATE SECTION.
    CLASS-DATA:
      gi_me        TYPE REF TO z2ui5_if_exit,
      gi_user_exit TYPE REF TO z2ui5_if_exit.

ENDCLASS.



CLASS z2ui5_cl_exit IMPLEMENTATION.

  METHOD get_instance.

    IF gi_me IS NOT INITIAL.
      ri_exit = gi_me.
      RETURN.
    ENDIF.

    DATA(lv_class_name) = get_user_exit_class( ).

    IF lv_class_name IS NOT INITIAL.
      TRY.
          CREATE OBJECT gi_user_exit TYPE (lv_class_name).
        CATCH cx_root ##NO_HANDLER.
      ENDTRY.
    ENDIF.

    gi_me = NEW z2ui5_cl_exit( ).

    ri_exit = gi_me.

  ENDMETHOD.


  METHOD z2ui5_if_exit~get_draft_exp_time_in_hours.

    CONSTANTS cv_draft_exp_time_in_hours TYPE string VALUE 4.

    IF gi_user_exit IS NOT INITIAL.
      rv_draft_exp_time_in_hours = gi_user_exit->get_draft_exp_time_in_hours( ).
    ENDIF.

    IF rv_draft_exp_time_in_hours IS INITIAL
        OR rv_draft_exp_time_in_hours <= 0.
      rv_draft_exp_time_in_hours = cv_draft_exp_time_in_hours.
    ENDIF.

  ENDMETHOD.


  METHOD z2ui5_if_exit~adjust_config.

    IF cs_config-title IS INITIAL.
      cs_config-title = `abap2UI5`.
    ENDIF.

    IF cs_config-theme IS INITIAL.
      cs_config-theme = `sap_horizon`.
    ENDIF.

    IF cs_config-src IS INITIAL.
      cs_config-src = `https://sdk.openui5.org/resources/sap-ui-cachebuster/sap-ui-core.js`.
*      ms_req_config-src     = `https://sdk.openui5.org/1.71.67/resources/sap-ui-core.js`.
*      ms_req_config-src     = `https://sdk.openui5.org/nightly/2/resources/sap-ui-core.js`.
    ENDIF.

    IF cs_config-content_security_policy IS INITIAL.
      cs_config-content_security_policy = |<meta http-equiv="Content-Security-Policy" content="default-src 'self' 'unsafe-inline' 'unsafe-eval' data: | &&
        |ui5.sap.com *.ui5.sap.com sapui5.hana.ondemand.com *.sapui5.hana.ondemand.com openui5.hana.ondemand.com *.openui5.hana.ondemand.com | &&
        |sdk.openui5.org *.sdk.openui5.org cdn.jsdelivr.net *.cdn.jsdelivr.net cdnjs.cloudflare.com *.cdnjs.cloudflare.com schemas *.schemas; worker-src 'self' blob:; "/>|.
    ENDIF.

    IF gi_user_exit IS NOT INITIAL.
      gi_user_exit->adjust_config( CHANGING cs_config = cs_config ).
    ENDIF.

  ENDMETHOD.


  METHOD get_user_exit_class.

    DATA(exit_classes) = z2ui5_cl_util_abap=>rtti_get_classes_impl_intf( 'Z2UI5_IF_EXIT' ).
    DELETE exit_classes WHERE classname = 'Z2UI5_CL_EXIT'.

    IF exit_classes IS NOT INITIAL.
      r_class_name = exit_classes[ 1 ]-classname.
    ENDIF.

  ENDMETHOD.

ENDCLASS.
