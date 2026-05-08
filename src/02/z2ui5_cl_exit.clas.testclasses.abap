
CLASS ltcl_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    METHODS test_get_instance            FOR TESTING RAISING cx_static_check.
    METHODS test_get_instance_singleton  FOR TESTING RAISING cx_static_check.
    METHODS test_set_config_http_get     FOR TESTING RAISING cx_static_check.
    METHODS test_set_config_http_post    FOR TESTING RAISING cx_static_check.
    METHODS test_post_default_exp_time   FOR TESTING RAISING cx_static_check.
    METHODS test_init_context            FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_test IMPLEMENTATION.

  METHOD test_get_instance.

    DATA li_exit TYPE REF TO z2ui5_if_exit.
    li_exit = z2ui5_cl_exit=>get_instance( ).
    cl_abap_unit_assert=>assert_bound( li_exit ).

  ENDMETHOD.

  METHOD test_get_instance_singleton.

    DATA li_exit1 TYPE REF TO z2ui5_if_exit.
    DATA li_exit2 TYPE REF TO z2ui5_if_exit.
    li_exit1 = z2ui5_cl_exit=>get_instance( ).
    
    li_exit2 = z2ui5_cl_exit=>get_instance( ).
    cl_abap_unit_assert=>assert_equals( exp = li_exit1
                                        act = li_exit2 ).

  ENDMETHOD.

  METHOD test_set_config_http_get.

    DATA li_exit TYPE REF TO z2ui5_if_exit.
    DATA ls_config TYPE z2ui5_if_types=>ty_s_http_config.
    li_exit = z2ui5_cl_exit=>get_instance( ).
    

    li_exit->set_config_http_get( CHANGING cs_config = ls_config ).

    cl_abap_unit_assert=>assert_not_initial( ls_config-title ).
    cl_abap_unit_assert=>assert_not_initial( ls_config-theme ).
    cl_abap_unit_assert=>assert_not_initial( ls_config-src ).
    cl_abap_unit_assert=>assert_not_initial( ls_config-content_security_policy ).
    cl_abap_unit_assert=>assert_not_initial( ls_config-t_security_header ).

  ENDMETHOD.

  METHOD test_set_config_http_post.

    DATA li_exit TYPE REF TO z2ui5_if_exit.
    DATA ls_config TYPE z2ui5_if_types=>ty_s_http_config_post.
    li_exit = z2ui5_cl_exit=>get_instance( ).
    

    li_exit->set_config_http_post( CHANGING cs_config = ls_config ).

    cl_abap_unit_assert=>assert_equals( exp = 4
                                        act = ls_config-draft_exp_time_in_hours ).

  ENDMETHOD.

  METHOD test_post_default_exp_time.

    DATA li_exit TYPE REF TO z2ui5_if_exit.
    DATA ls_config TYPE z2ui5_if_types=>ty_s_http_config_post.
    li_exit = z2ui5_cl_exit=>get_instance( ).
    
    ls_config-draft_exp_time_in_hours = -1.

    li_exit->set_config_http_post( CHANGING cs_config = ls_config ).

    cl_abap_unit_assert=>assert_equals( exp = 4
                                        act = ls_config-draft_exp_time_in_hours ).

  ENDMETHOD.

  METHOD test_init_context.

    DATA ls_req TYPE z2ui5_cl_util_http=>ty_s_http_req.
    DATA temp1 TYPE z2ui5_cl_util=>ty_t_name_value.
    DATA temp2 LIKE LINE OF temp1.
    ls_req-path = `/sap/test`.
    
    CLEAR temp1.
    
    temp2-n = `app_start`.
    temp2-v = `z2ui5_cl_app_hello_world`.
    INSERT temp2 INTO TABLE temp1.
    temp2-n = `sap-client`.
    temp2-v = `100`.
    INSERT temp2 INTO TABLE temp1.
    ls_req-t_params = temp1.

    z2ui5_cl_exit=>init_context( ls_req ).

  ENDMETHOD.

ENDCLASS.
