CLASS ltcl_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_bool_abap_true       FOR TESTING RAISING cx_static_check.
    METHODS test_bool_abap_false      FOR TESTING RAISING cx_static_check.
    METHODS test_bool_char_non_bool   FOR TESTING RAISING cx_static_check.
    METHODS test_bool_string_empty    FOR TESTING RAISING cx_static_check.
    METHODS test_bool_string_literal  FOR TESTING RAISING cx_static_check.
    METHODS test_bool_string_binding  FOR TESTING RAISING cx_static_check.
    METHODS test_bool_check_by_data   FOR TESTING RAISING cx_static_check.
    METHODS test_bool_cache_hit       FOR TESTING RAISING cx_static_check.
    METHODS test_url_param_case       FOR TESTING RAISING cx_static_check.
    METHODS test_url_param_no_phantom FOR TESTING RAISING cx_static_check.
    METHODS test_url_param_startup    FOR TESTING RAISING cx_static_check.
    METHODS test_url_param_encoded    FOR TESTING RAISING cx_static_check.
    METHODS test_c_trim_mixed          FOR TESTING RAISING cx_static_check.
    METHODS test_copy_ref_object       FOR TESTING RAISING cx_static_check.
    METHODS test_url_param_question   FOR TESTING RAISING cx_static_check.
    METHODS test_url_param_full_url   FOR TESTING RAISING cx_static_check.
    METHODS test_impl_intf_app        FOR TESTING RAISING cx_static_check.
    METHODS test_impl_intf_lower_case FOR TESTING RAISING cx_static_check.
    METHODS test_impl_intf_no_app     FOR TESTING RAISING cx_static_check.
    METHODS test_impl_intf_no_class   FOR TESTING RAISING cx_static_check.
    METHODS test_impl_intf_interface  FOR TESTING RAISING cx_static_check.
    METHODS test_ref_type_name_intf   FOR TESTING RAISING cx_static_check.
    METHODS test_ref_type_name_class  FOR TESTING RAISING cx_static_check.
    METHODS test_ref_type_name_lookup FOR TESTING RAISING cx_static_check.
    METHODS test_ref_type_name_no_ref FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_test IMPLEMENTATION.

  METHOD test_impl_intf_app.

    cl_abap_unit_assert=>assert_equals( exp = abap_true act =
        z2ui5_cl_ui5_util_context=>rtti_check_class_impl_intf( class = `Z2UI5_CL_UI5_APP_HI_WORLD`
                                                               intf  = `Z2UI5_IF_APP` ) ).

  ENDMETHOD.

  METHOD test_impl_intf_lower_case.

    " the interface name is normalised the way a class name is
    cl_abap_unit_assert=>assert_equals( exp = abap_true act =
        z2ui5_cl_ui5_util_context=>rtti_check_class_impl_intf( class = `Z2UI5_CL_UI5_APP_HI_WORLD`
                                                               intf  = `z2ui5_if_app` ) ).

  ENDMETHOD.

  METHOD test_impl_intf_no_app.

    " exists, is a class, implements something else entirely
    cl_abap_unit_assert=>assert_equals( exp = abap_false act =
        z2ui5_cl_ui5_util_context=>rtti_check_class_impl_intf( class = `Z2UI5_CL_UI5_UTIL_CONTEXT`
                                                               intf  = `Z2UI5_IF_APP` ) ).

  ENDMETHOD.

  METHOD test_impl_intf_no_class.

    cl_abap_unit_assert=>assert_equals( exp = abap_false act =
        z2ui5_cl_ui5_util_context=>rtti_check_class_impl_intf( class = `ZCL_THIS_CLASS_DOES_NOT_EXIST`
                                                               intf  = `Z2UI5_IF_APP` ) ).

  ENDMETHOD.

  METHOD test_impl_intf_interface.

    " an interface is not a class - it cannot be created, so it is no app
    cl_abap_unit_assert=>assert_equals( exp = abap_false act =
        z2ui5_cl_ui5_util_context=>rtti_check_class_impl_intf( class = `Z2UI5_IF_APP`
                                                               intf  = `Z2UI5_IF_APP` ) ).

  ENDMETHOD.

  METHOD test_ref_type_name_intf.

    " the name a dynamic lookup needs, taken from a declaration - which a
    " namespace rename rewrites - instead of a literal, which it does not
    DATA li_app TYPE REF TO z2ui5_if_app.

    cl_abap_unit_assert=>assert_equals(
        exp = `Z2UI5_IF_APP`
        act = z2ui5_cl_ui5_util_context=>rtti_get_ref_type_name( li_app ) ).

  ENDMETHOD.

  METHOD test_ref_type_name_class.

    DATA lo_exit TYPE REF TO z2ui5_cl_ui5_user_exit.

    cl_abap_unit_assert=>assert_equals(
        exp = `Z2UI5_CL_UI5_USER_EXIT`
        act = z2ui5_cl_ui5_util_context=>rtti_get_ref_type_name( lo_exit ) ).

  ENDMETHOD.

  METHOD test_ref_type_name_lookup.

    " what the framework does with it: the app pre-check of
    " z2ui5_cl_ui5_action=>app_create, with no name spelled out at all
    DATA li_app TYPE REF TO z2ui5_if_app.
    DATA lo_app TYPE REF TO object.

    CREATE OBJECT lo_app TYPE z2ui5_cl_ui5_app_hi_world.
    cl_abap_unit_assert=>assert_equals( exp = abap_true act =
        z2ui5_cl_ui5_util_context=>rtti_check_class_impl_intf(
            class = z2ui5_cl_ui5_util_context=>rtti_get_classname_by_ref( lo_app )
            intf  = z2ui5_cl_ui5_util_context=>rtti_get_ref_type_name( li_app ) ) ).

  ENDMETHOD.

  METHOD test_ref_type_name_no_ref.

    " a value that is no reference is a programming error at the caller -
    " it raises, it never answers with a name
    DATA lv_text TYPE string.
        DATA lx TYPE REF TO z2ui5_cx_ui5_util_error.
        DATA temp1 TYPE xsdboolean.

    TRY.
        z2ui5_cl_ui5_util_context=>rtti_get_ref_type_name( lv_text ).
        cl_abap_unit_assert=>fail( `a string is no typed reference` ).

      CATCH z2ui5_cx_ui5_util_error INTO lx.

        temp1 = boolc( lx->get_text( ) CS `RTTI_NOT_AN_OBJECT_REFERENCE` ).
        cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp1 ).
    ENDTRY.

  ENDMETHOD.

  METHOD test_bool_abap_true.

    cl_abap_unit_assert=>assert_equals(
        exp = `true`
        act = z2ui5_cl_ui5_util_context=>boolean_abap_2_json( abap_true ) ).

  ENDMETHOD.

  METHOD test_bool_abap_false.

    " an initial abap_bool is a boolean and renders as false,
    " it must not be confused with an initial string (see below)
    cl_abap_unit_assert=>assert_equals(
        exp = `false`
        act = z2ui5_cl_ui5_util_context=>boolean_abap_2_json( abap_false ) ).

  ENDMETHOD.

  METHOD test_bool_char_non_bool.

    " a plain single character type is not a boolean flag,
    " its value has to pass through unchanged
    DATA lv_char TYPE c LENGTH 1 VALUE 'X'.

    cl_abap_unit_assert=>assert_equals(
        exp = `X`
        act = z2ui5_cl_ui5_util_context=>boolean_abap_2_json( lv_char ) ).

  ENDMETHOD.

  METHOD test_bool_string_empty.

    " an initial string stays empty so the property is dropped
    " later and the UI5 default applies
    DATA lv_string TYPE string.

    cl_abap_unit_assert=>assert_equals(
        exp = ``
        act = z2ui5_cl_ui5_util_context=>boolean_abap_2_json( lv_string ) ).

  ENDMETHOD.

  METHOD test_bool_string_literal.

    cl_abap_unit_assert=>assert_equals(
        exp = `true`
        act = z2ui5_cl_ui5_util_context=>boolean_abap_2_json( `true` ) ).

  ENDMETHOD.

  METHOD test_bool_string_binding.

    cl_abap_unit_assert=>assert_equals(
        exp = `{path}`
        act = z2ui5_cl_ui5_util_context=>boolean_abap_2_json( `{path}` ) ).

  ENDMETHOD.

  METHOD test_bool_check_by_data.

    DATA lv_char TYPE c LENGTH 1 VALUE 'X'.
    DATA lv_int  TYPE i VALUE 5.

    cl_abap_unit_assert=>assert_equals( exp = abap_true act = z2ui5_cl_ui5_util_context=>boolean_check_by_data( abap_true ) ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = z2ui5_cl_ui5_util_context=>boolean_check_by_data( abap_false ) ).
    cl_abap_unit_assert=>assert_equals( exp = abap_false act = z2ui5_cl_ui5_util_context=>boolean_check_by_data( lv_char ) ).
    cl_abap_unit_assert=>assert_equals( exp = abap_false act = z2ui5_cl_ui5_util_context=>boolean_check_by_data( `X` ) ).
    cl_abap_unit_assert=>assert_equals( exp = abap_false act = z2ui5_cl_ui5_util_context=>boolean_check_by_data( lv_int ) ).

  ENDMETHOD.

  METHOD test_bool_cache_hit.

    " second call for the same type is answered from the
    " descriptor-keyed cache and has to return the same result
    z2ui5_cl_ui5_util_context=>boolean_abap_2_json( abap_true ).

    cl_abap_unit_assert=>assert_equals(
        exp = `true`
        act = z2ui5_cl_ui5_util_context=>boolean_abap_2_json( abap_true ) ).

    cl_abap_unit_assert=>assert_equals(
        exp = `false`
        act = z2ui5_cl_ui5_util_context=>boolean_abap_2_json( abap_false ) ).

  ENDMETHOD.

  METHOD test_url_param_case.

    " the parameter-name lookup is case-insensitive on every input shape -
    " with a full URL and with a bare query string; the value keeps its case
    cl_abap_unit_assert=>assert_equals(
        exp = `MixedCase`
        act = z2ui5_cl_ui5_util_context=>url_param_get(
                  val = `app_start`
                  url = `https://h/p?APP_START=MixedCase` ) ).

    cl_abap_unit_assert=>assert_equals(
        exp = `MixedCase`
        act = z2ui5_cl_ui5_util_context=>url_param_get(
                  val = `app_start`
                  url = `?APP_START=MixedCase` ) ).

  ENDMETHOD.

  METHOD test_url_param_no_phantom.

    " an empty search string yields no parameters at all - the former
    " phantom nameless row leaked back out of url_param_create_url as `=&`
    cl_abap_unit_assert=>assert_initial(
        z2ui5_cl_ui5_util_context=>url_param_get_tab( `` ) ).

    cl_abap_unit_assert=>assert_equals(
        exp = 1
        act = lines( z2ui5_cl_ui5_util_context=>url_param_get_tab( `?a=1&` ) ) ).

  ENDMETHOD.

  METHOD test_copy_ref_object.

    " an OBJECT reference handed to nav_app_leave( r_data = ... ): not a data
    " reference to dereference, copied as the value it is - the previous
    " app gets a reference to a copy of the reference variable
    DATA lo_obj TYPE REF TO z2ui5_cl_ui5_util_context.
    DATA lv_text TYPE string VALUE `x`.
    DATA lr_text LIKE REF TO lv_text.
    DATA lr_copy TYPE REF TO data.
    FIELD-SYMBOLS <copy> TYPE any.
    CREATE OBJECT lo_obj TYPE z2ui5_cl_ui5_util_context.
    cl_abap_unit_assert=>assert_equals( exp = abap_false act = z2ui5_cl_ui5_util_context=>rtti_check_ref_data( lo_obj ) ).



    GET REFERENCE OF lv_text INTO lr_text.
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = z2ui5_cl_ui5_util_context=>rtti_check_ref_data( lr_text ) ).


    lr_copy = z2ui5_cl_ui5_util_context=>conv_copy_ref_data( lo_obj ).
    cl_abap_unit_assert=>assert_bound( lr_copy ).

    ASSIGN lr_copy->* TO <copy>.
    cl_abap_unit_assert=>assert_equals( exp = lo_obj
                                        act = <copy> ).

  ENDMETHOD.

  METHOD test_c_trim_mixed.

    DATA lv_tab LIKE z2ui5_cl_ui5_util_context=>cv_char_util_horizontal_tab.
    lv_tab = z2ui5_cl_ui5_util_context=>cv_char_util_horizontal_tab.
    cl_abap_unit_assert=>assert_equals(
        exp = `x`
        act = z2ui5_cl_ui5_util_context=>c_trim( |{ lv_tab } { lv_tab } x { lv_tab } { lv_tab }| ) ).
    cl_abap_unit_assert=>assert_equals(
        exp = `a b`
        act = z2ui5_cl_ui5_util_context=>c_trim( `  a b  ` ) ).

  ENDMETHOD.

  METHOD test_url_param_encoded.

    " a percent-encoded & or = inside a value is that value's own - only
    " the sap-startup-params wrapper is decoded, nothing else is split
    DATA lt_params TYPE z2ui5_cl_ui5_util_context=>ty_t_name_value.
    FIELD-SYMBOLS <temp1> LIKE LINE OF lt_params.
    DATA temp2 LIKE sy-tabix.
    FIELD-SYMBOLS <temp3> LIKE LINE OF lt_params.
    DATA temp4 LIKE sy-tabix.
    FIELD-SYMBOLS <temp5> LIKE LINE OF lt_params.
    DATA temp6 LIKE sy-tabix.
    FIELD-SYMBOLS <temp7> LIKE LINE OF lt_params.
    DATA temp8 LIKE sy-tabix.
    FIELD-SYMBOLS <temp9> LIKE LINE OF lt_params.
    DATA temp10 LIKE sy-tabix.
    lt_params = z2ui5_cl_ui5_util_context=>url_param_get_tab( `?a=x%26y&b=1%3D2` ).

    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( lt_params ) ).


    temp2 = sy-tabix.
    READ TABLE lt_params WITH KEY n = `a` ASSIGNING <temp1>.
    sy-tabix = temp2.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `x%26y`
                                        act = <temp1>-v ).


    temp4 = sy-tabix.
    READ TABLE lt_params WITH KEY n = `b` ASSIGNING <temp3>.
    sy-tabix = temp4.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `1%3D2`
                                        act = <temp3>-v ).

    " ...and a parameter AFTER the wrapper is still a parameter of its own
    lt_params = z2ui5_cl_ui5_util_context=>url_param_get_tab(
                    `?sap-startup-params=app_start%3Dfoo%26x%3D1&sap-ui-theme=dark` ).



    temp6 = sy-tabix.
    READ TABLE lt_params WITH KEY n = `app_start` ASSIGNING <temp5>.
    sy-tabix = temp6.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `foo`
                                        act = <temp5>-v ).


    temp8 = sy-tabix.
    READ TABLE lt_params WITH KEY n = `x` ASSIGNING <temp7>.
    sy-tabix = temp8.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `1`
                                        act = <temp7>-v ).


    temp10 = sy-tabix.
    READ TABLE lt_params WITH KEY n = `sap-ui-theme` ASSIGNING <temp9>.
    sy-tabix = temp10.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `dark`
                                        act = <temp9>-v ).

  ENDMETHOD.

  METHOD test_url_param_question.

    " a literal ? in a value is legal and left unencoded by browsers - it
    " must not cut away the parameters before it
    DATA lt_params TYPE z2ui5_cl_ui5_util_context=>ty_t_name_value.
    FIELD-SYMBOLS <temp11> LIKE LINE OF lt_params.
    DATA temp12 LIKE sy-tabix.
    FIELD-SYMBOLS <temp13> LIKE LINE OF lt_params.
    DATA temp14 LIKE sy-tabix.
    lt_params = z2ui5_cl_ui5_util_context=>url_param_get_tab( `?app_start=zcl_x&title=why?` ).



    temp12 = sy-tabix.
    READ TABLE lt_params WITH KEY n = `app_start` ASSIGNING <temp11>.
    sy-tabix = temp12.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `zcl_x`
                                        act = <temp11>-v ).


    temp14 = sy-tabix.
    READ TABLE lt_params WITH KEY n = `title` ASSIGNING <temp13>.
    sy-tabix = temp14.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `why?`
                                        act = <temp13>-v ).

  ENDMETHOD.

  METHOD test_url_param_full_url.

    " a request URI / full URL: the path before the query is not a parameter
    cl_abap_unit_assert=>assert_equals(
        exp = `zcl_x`
        act = z2ui5_cl_ui5_util_context=>url_param_get(
                  val = `app_start`
                  url = `/sap/bc/z2ui5?app_start=zcl_x&b=2` ) ).

  ENDMETHOD.

  METHOD test_url_param_startup.
    DATA lt_params TYPE z2ui5_cl_ui5_util_context=>ty_t_name_value.
    FIELD-SYMBOLS <temp15> LIKE LINE OF lt_params.
    DATA temp16 LIKE sy-tabix.
    FIELD-SYMBOLS <temp17> LIKE LINE OF lt_params.
    DATA temp18 LIKE sy-tabix.
    FIELD-SYMBOLS <temp19> LIKE LINE OF lt_params.
    DATA temp20 LIKE sy-tabix.
    FIELD-SYMBOLS <temp21> LIKE LINE OF lt_params.
    DATA temp22 LIKE sy-tabix.

    " sap-startup-params is unwrapped wherever it sits in the query string -
    " as a later parameter, as the first/only parameter (typical FLP target
    " mapping), and with lowercase percent-encoding
    cl_abap_unit_assert=>assert_equals(
        exp = `foo`
        act = z2ui5_cl_ui5_util_context=>url_param_get(
                  val = `app_start`
                  url = `?x=1&sap-startup-params=app_start%3Dfoo` ) ).

    " ...and a parameter BEFORE the wrapper survives the unwrapping - it used
    " to be dropped, so `?app_start=x&sap-startup-params=...` lost the app
    " and a sap-client in front of the wrapper vanished from every rebuilt link

    lt_params = z2ui5_cl_ui5_util_context=>url_param_get_tab(
                          `?x=1&sap-client=100&sap-startup-params=app_start%3Dfoo&y=2` ).

    cl_abap_unit_assert=>assert_equals( exp = 4
                                        act = lines( lt_params ) ).


    temp16 = sy-tabix.
    READ TABLE lt_params WITH KEY n = `x` ASSIGNING <temp15>.
    sy-tabix = temp16.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `1`
                                        act = <temp15>-v ).


    temp18 = sy-tabix.
    READ TABLE lt_params WITH KEY n = `sap-client` ASSIGNING <temp17>.
    sy-tabix = temp18.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `100`
                                        act = <temp17>-v ).


    temp20 = sy-tabix.
    READ TABLE lt_params WITH KEY n = `app_start` ASSIGNING <temp19>.
    sy-tabix = temp20.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `foo`
                                        act = <temp19>-v ).


    temp22 = sy-tabix.
    READ TABLE lt_params WITH KEY n = `y` ASSIGNING <temp21>.
    sy-tabix = temp22.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `2`
                                        act = <temp21>-v ).

    cl_abap_unit_assert=>assert_equals(
        exp = `foo`
        act = z2ui5_cl_ui5_util_context=>url_param_get(
                  val = `app_start`
                  url = `?sap-startup-params=app_start%3Dfoo` ) ).

    cl_abap_unit_assert=>assert_equals(
        exp = `foo`
        act = z2ui5_cl_ui5_util_context=>url_param_get(
                  val = `app_start`
                  url = `?sap-startup-params=app_start%3dfoo` ) ).

  ENDMETHOD.

ENDCLASS.


CLASS ltcl_string DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_trim_spaces       FOR TESTING RAISING cx_static_check.
    METHODS test_trim_tabs         FOR TESTING RAISING cx_static_check.
    METHODS test_trim_inner_kept   FOR TESTING RAISING cx_static_check.
    METHODS test_trim_case         FOR TESTING RAISING cx_static_check.
    METHODS test_bool_by_name      FOR TESTING RAISING cx_static_check.
    METHODS test_url_create        FOR TESTING RAISING cx_static_check.
    METHODS test_url_create_empty  FOR TESTING RAISING cx_static_check.
    METHODS test_url_roundtrip     FOR TESTING RAISING cx_static_check.
    METHODS test_escape_html       FOR TESTING RAISING cx_static_check.
    METHODS test_escape_json       FOR TESTING RAISING cx_static_check.
    METHODS test_escape_js         FOR TESTING RAISING cx_static_check.
    METHODS test_escape_xml        FOR TESTING RAISING cx_static_check.
    METHODS test_truncate          FOR TESTING RAISING cx_static_check.
    METHODS test_filter_chars      FOR TESTING RAISING cx_static_check.
    METHODS test_cut_at            FOR TESTING RAISING cx_static_check.
    METHODS test_url_origin        FOR TESTING RAISING cx_static_check.
    METHODS test_url_authority     FOR TESTING RAISING cx_static_check.
    METHODS test_etag_match_rules  FOR TESTING RAISING cx_static_check.
    METHODS test_hash_checksum     FOR TESTING RAISING cx_static_check.
    METHODS test_ui5_binding_literal FOR TESTING RAISING cx_static_check.
    METHODS test_ui5_handler_string FOR TESTING RAISING cx_static_check.
    METHODS test_ui5_braces_balanced FOR TESTING RAISING cx_static_check.
    METHODS test_data_uri          FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_string IMPLEMENTATION.

  METHOD test_url_origin.

    cl_abap_unit_assert=>assert_equals( exp = `https://sdk.openui5.org`
                                        act = z2ui5_cl_ui5_util_context=>url_get_origin(
                                                  `https://sdk.openui5.org/resources/sap-ui-cachebuster/sap-ui-core.js` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `https://cdn.example:8443`
                                        act = z2ui5_cl_ui5_util_context=>url_get_origin(
                                                  `https://cdn.example:8443/ui5/resources/sap-ui-core.js?x=1` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `http://cdn.example`
                                        act = z2ui5_cl_ui5_util_context=>url_get_origin( `HTTP://cdn.example?q` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `//cdn.example`
                                        act = z2ui5_cl_ui5_util_context=>url_get_origin( `//cdn.example/resources/sap-ui-core.js` ) ).
    " the host alone, no path at all
    cl_abap_unit_assert=>assert_equals( exp = `https://cdn.example`
                                        act = z2ui5_cl_ui5_util_context=>url_get_origin( `https://cdn.example` ) ).
    " relative: the page's own origin, nothing to announce
    cl_abap_unit_assert=>assert_initial( z2ui5_cl_ui5_util_context=>url_get_origin(
                                             `/sap/public/bc/ui5_ui5/1/resources/sap-ui-core.js` ) ).
    cl_abap_unit_assert=>assert_initial( z2ui5_cl_ui5_util_context=>url_get_origin( `resources/sap-ui-core.js` ) ).
    cl_abap_unit_assert=>assert_initial( z2ui5_cl_ui5_util_context=>url_get_origin( `` ) ).
    " no host, or userinfo in front of it: nothing rather than a guess
    cl_abap_unit_assert=>assert_initial( z2ui5_cl_ui5_util_context=>url_get_origin( `https:///x.js` ) ).
    cl_abap_unit_assert=>assert_initial( z2ui5_cl_ui5_util_context=>url_get_origin( `https://u:p@cdn.example/x.js` ) ).

  ENDMETHOD.

  METHOD test_etag_match_rules.

    DATA lv_tag TYPE string.
    lv_tag = `"1.0-11-22-33"`.

    " exact, weak, listed, any, the Apache suffix - all a match
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = z2ui5_cl_ui5_util_context=>http_check_etag_match(
        if_none_match = `"1.0-11-22-33"`
        etag          = lv_tag ) ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = z2ui5_cl_ui5_util_context=>http_check_etag_match(
        if_none_match = `W/"1.0-11-22-33"`
        etag          = lv_tag ) ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = z2ui5_cl_ui5_util_context=>http_check_etag_match(
        if_none_match = `"a" , "1.0-11-22-33" ,"b"`
        etag          = lv_tag ) ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = z2ui5_cl_ui5_util_context=>http_check_etag_match(
        if_none_match = `*`
        etag          = lv_tag ) ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = z2ui5_cl_ui5_util_context=>http_check_etag_match(
        if_none_match = `"1.0-11-22-33-gzip"`
        etag          = lv_tag ) ).

    " another tag, a tag that merely starts like ours, nothing at all
    cl_abap_unit_assert=>assert_equals( exp = abap_false act = z2ui5_cl_ui5_util_context=>http_check_etag_match(
        if_none_match = `"1.0-99-99-99"`
        etag          = lv_tag ) ).
    cl_abap_unit_assert=>assert_equals( exp = abap_false act = z2ui5_cl_ui5_util_context=>http_check_etag_match(
        if_none_match = `"1.0-11-22-33-x"`
        etag          = lv_tag ) ).
    cl_abap_unit_assert=>assert_equals( exp = abap_false act = z2ui5_cl_ui5_util_context=>http_check_etag_match(
        if_none_match = ``
        etag          = lv_tag ) ).
    cl_abap_unit_assert=>assert_equals( exp = abap_false act = z2ui5_cl_ui5_util_context=>http_check_etag_match(
        if_none_match = `*`
        etag          = `` ) ).

  ENDMETHOD.

  METHOD test_escape_json.

    DATA lv_raw TYPE string.
    lv_raw = `a"b\c` && z2ui5_cl_ui5_util_context=>cv_char_util_horizontal_tab
                   && z2ui5_cl_ui5_util_context=>cv_char_util_cr_lf && `d`.
    cl_abap_unit_assert=>assert_equals( exp = `a\"b\\c\t\r\nd`
                                        act = z2ui5_cl_ui5_util_context=>c_escape_json( lv_raw ) ).
    cl_abap_unit_assert=>assert_equals( exp = `plain </b>`
                                        act = z2ui5_cl_ui5_util_context=>c_escape_json( `plain </b>` ) ).

  ENDMETHOD.

  METHOD test_escape_js.

    " both quotes, the backslash, the line terminators and the end of an
    " inline script - the backslash first, or it would double the others
    DATA lv_raw TYPE string.
    lv_raw = `a"b'c\d</e` && z2ui5_cl_ui5_util_context=>cv_char_util_cr_lf && `f`.
    cl_abap_unit_assert=>assert_equals( exp = `a\"b\'c\\d<\/e\r\nf`
                                        act = z2ui5_cl_ui5_util_context=>c_escape_js( lv_raw ) ).
    cl_abap_unit_assert=>assert_equals( exp = `/sap/bc/z2ui5`
                                        act = z2ui5_cl_ui5_util_context=>c_escape_js( `/sap/bc/z2ui5` ) ).

  ENDMETHOD.

  METHOD test_escape_xml.

    " the entities, the whitespace as character references, and a form feed
    " (illegal in XML 1.0 even as a reference) dropped
    DATA temp23 TYPE xstring.
    DATA lv_ff TYPE string.
    DATA lv_raw TYPE string.
    DATA temp24 TYPE xstring.
    DATA lv_nonchar TYPE string.
    temp23 = `0C`.

    lv_ff = z2ui5_cl_ui5_util_context=>conv_get_string_by_xstring( temp23 ).

    lv_raw = `a&b<c>d"e'f` && z2ui5_cl_ui5_util_context=>cv_char_util_newline
                   && z2ui5_cl_ui5_util_context=>cv_char_util_horizontal_tab && lv_ff && `g`.
    cl_abap_unit_assert=>assert_equals( exp = `a&amp;b&lt;c&gt;d&quot;e'f&#xA;&#x9;g`
                                        act = z2ui5_cl_ui5_util_context=>c_escape_xml( lv_raw ) ).

    " the non-characters U+FFFE and U+FFFF are dropped like a control
    " character - the XMLView parser refuses the document for one of them

    temp24 = `EFBFBE` && `EFBFBF`.

    lv_nonchar = z2ui5_cl_ui5_util_context=>conv_get_string_by_xstring( temp24 ).
    cl_abap_unit_assert=>assert_equals( exp = `ab`
                                        act = z2ui5_cl_ui5_util_context=>c_escape_xml( `a` && lv_nonchar && `b` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `plain`
                                        act = z2ui5_cl_ui5_util_context=>c_escape_xml( `plain` ) ).

  ENDMETHOD.

  METHOD test_truncate.

    cl_abap_unit_assert=>assert_equals( exp = `abcdefg...`
                                        act = z2ui5_cl_ui5_util_context=>c_truncate( val = `abcdefghijklmn`
                                                                                     max = 10 ) ).
    cl_abap_unit_assert=>assert_equals( exp = `abcdefghij`
                                        act = z2ui5_cl_ui5_util_context=>c_truncate( val = `abcdefghij`
                                                                                     max = 10 ) ).
    " no room for the ellipsis: a plain cut
    cl_abap_unit_assert=>assert_equals( exp = `ab`
                                        act = z2ui5_cl_ui5_util_context=>c_truncate( val = `abcdef`
                                                                                     max = 2 ) ).

  ENDMETHOD.

  METHOD test_filter_chars.

    cl_abap_unit_assert=>assert_equals( exp = `ZCL_X`
                                        act = z2ui5_cl_ui5_util_context=>c_filter_chars(
                                                  val     = `ZCL_X"><script>`
                                                  allowed = `ABCDEFGHIJKLMNOPQRSTUVWXYZ_` ) ).
    " nothing to strip: the value itself
    cl_abap_unit_assert=>assert_equals( exp = `abc`
                                        act = z2ui5_cl_ui5_util_context=>c_filter_chars( val     = `abc`
                                                                                         allowed = `abc` ) ).
    cl_abap_unit_assert=>assert_initial( z2ui5_cl_ui5_util_context=>c_filter_chars( val     = ``
                                                                                    allowed = `abc` ) ).

  ENDMETHOD.

  METHOD test_cut_at.

    cl_abap_unit_assert=>assert_equals( exp = `ZCL_X`
                                        act = z2ui5_cl_ui5_util_context=>c_cut_at( val = `ZCL_X?a=1`
                                                                                   sub = `?` ) ).
    " sub absent: the whole value, not the empty one substring_before answers
    cl_abap_unit_assert=>assert_equals( exp = `ZCL_X`
                                        act = z2ui5_cl_ui5_util_context=>c_cut_at( val = `ZCL_X`
                                                                                   sub = `?` ) ).

  ENDMETHOD.

  METHOD test_url_authority.

    cl_abap_unit_assert=>assert_equals( exp = `host.example:8443`
                                        act = z2ui5_cl_ui5_util_context=>url_get_authority(
                                                  `HTTPS://Host.Example:8443/path?q#f` ) ).
    " a default port is no port, whatever the scheme
    cl_abap_unit_assert=>assert_equals( exp = `host.example`
                                        act = z2ui5_cl_ui5_util_context=>url_get_authority( `host.example:443` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `host.example`
                                        act = z2ui5_cl_ui5_util_context=>url_get_authority( `http://host.example:80/` ) ).

  ENDMETHOD.

  METHOD test_ui5_binding_literal.

    cl_abap_unit_assert=>assert_equals( exp = `a \{/PATH\} \\\\server`
                                        act = z2ui5_cl_ui5_util_context=>ui5_escape_binding_literal( `a {/PATH} \\server` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `plain`
                                        act = z2ui5_cl_ui5_util_context=>ui5_escape_binding_literal( `plain` ) ).

  ENDMETHOD.

  METHOD test_ui5_handler_string.

    DATA lv_raw TYPE string.
    lv_raw = `it's a\b` && z2ui5_cl_ui5_util_context=>cv_char_util_cr_lf && `c`.
    cl_abap_unit_assert=>assert_equals( exp = `it\'s a\\b\nc`
                                        act = z2ui5_cl_ui5_util_context=>ui5_escape_handler_string( lv_raw ) ).
    cl_abap_unit_assert=>assert_equals( exp = `EVENT_ID`
                                        act = z2ui5_cl_ui5_util_context=>ui5_escape_handler_string( `EVENT_ID` ) ).

  ENDMETHOD.

  METHOD test_ui5_braces_balanced.

    cl_abap_unit_assert=>assert_equals( exp = abap_true act = z2ui5_cl_ui5_util_context=>ui5_check_braces_balanced( `{/A}` ) ).
    " a brace inside a string of the expression is text
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = z2ui5_cl_ui5_util_context=>ui5_check_braces_balanced( `{= ${/A} === '}' }` ) ).
    cl_abap_unit_assert=>assert_equals( exp = abap_false act = z2ui5_cl_ui5_util_context=>ui5_check_braces_balanced( `{0` ) ).
    cl_abap_unit_assert=>assert_equals( exp = abap_false act = z2ui5_cl_ui5_util_context=>ui5_check_braces_balanced( `}{` ) ).
    cl_abap_unit_assert=>assert_equals( exp = abap_false act = z2ui5_cl_ui5_util_context=>ui5_check_braces_balanced( `{'a}` ) ).

  ENDMETHOD.

  METHOD test_hash_checksum.

    DATA lv_a TYPE string.
    DATA lv_b TYPE string.
    DATA temp2 TYPE xsdboolean.
    lv_a = z2ui5_cl_ui5_util_context=>hash_checksum( `<html>shell content A</html>` ).

    lv_b = z2ui5_cl_ui5_util_context=>hash_checksum( `<html>shell content B</html>` ).
    cl_abap_unit_assert=>assert_not_initial( lv_a ).
    cl_abap_unit_assert=>assert_differs( exp = lv_a
                                         act = lv_b ).
    cl_abap_unit_assert=>assert_equals( exp = lv_a
                                        act = z2ui5_cl_ui5_util_context=>hash_checksum( `<html>shell content A</html>` ) ).
    " the byte count leads

    temp2 = boolc( lv_a CP `28-*` ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp2 ).

  ENDMETHOD.

  METHOD test_data_uri.

    " the payload is what follows the comma of a data URI...
    cl_abap_unit_assert=>assert_equals(
        exp = `4869`
        act = |{ z2ui5_cl_ui5_util_context=>conv_get_xstring_by_data_uri( `data:text/plain;base64,SGk=` ) }| ).

    " ...and a bare base64 value without the prefix is the payload itself -
    " it used to land in the metadata half and decode to nothing
    cl_abap_unit_assert=>assert_equals(
        exp = `4869`
        act = |{ z2ui5_cl_ui5_util_context=>conv_get_xstring_by_data_uri( `SGk=` ) }| ).

  ENDMETHOD.

  METHOD test_escape_html.

    " All five characters, and the ampersand FIRST: escaping it after the
    " others would hit the ones they just wrote (`&lt;` would become
    " `&amp;lt;`). The quote pair is what makes this the catalog's method
    " rather than the three-character one this class used to carry - a value
    " that lands in an attribute must not be able to close it.
    cl_abap_unit_assert=>assert_equals(
        exp = `Tom &amp; Jerry &lt;b&gt; said &quot;it&#39;s fine&quot;`
        act = z2ui5_cl_ui5_util_context=>c_escape_html( `Tom & Jerry <b> said "it's fine"` ) ).

    cl_abap_unit_assert=>assert_equals(
        exp = `nothing to escape`
        act = z2ui5_cl_ui5_util_context=>c_escape_html( `nothing to escape` ) ).

  ENDMETHOD.

  METHOD test_trim_spaces.

    cl_abap_unit_assert=>assert_equals( exp = `abc`
                                        act = z2ui5_cl_ui5_util_context=>c_trim( `   abc   ` ) ).

  ENDMETHOD.

  METHOD test_trim_tabs.

    " leading and trailing tabs are trimmed as well - a value pasted from a
    " spreadsheet arrives tab-padded and must not keep the padding
    DATA lv_val TYPE string.

    lv_val = z2ui5_cl_ui5_util_context=>cv_char_util_horizontal_tab
             && `abc`
             && z2ui5_cl_ui5_util_context=>cv_char_util_horizontal_tab.

    cl_abap_unit_assert=>assert_equals( exp = `abc`
                                        act = z2ui5_cl_ui5_util_context=>c_trim( lv_val ) ).

  ENDMETHOD.

  METHOD test_trim_inner_kept.

    " only the edges are trimmed, inner whitespace is data
    cl_abap_unit_assert=>assert_equals( exp = `a b`
                                        act = z2ui5_cl_ui5_util_context=>c_trim( ` a b ` ) ).

  ENDMETHOD.

  METHOD test_trim_case.

    cl_abap_unit_assert=>assert_equals( exp = `ABC`
                                        act = z2ui5_cl_ui5_util_context=>c_trim_upper( ` aBc ` ) ).

    cl_abap_unit_assert=>assert_equals( exp = `abc`
                                        act = z2ui5_cl_ui5_util_context=>c_trim_lower( ` aBc ` ) ).

  ENDMETHOD.

  METHOD test_bool_by_name.

    " the name check drives whether an attribute is serialised as a JSON
    " boolean, so both the hit list and the rejection of look-alikes matter
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = z2ui5_cl_ui5_util_context=>boolean_check_by_name( `ABAP_BOOL` ) ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = z2ui5_cl_ui5_util_context=>boolean_check_by_name( `XFELD` ) ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = z2ui5_cl_ui5_util_context=>boolean_check_by_name( `BOOLE_D` ) ).

    cl_abap_unit_assert=>assert_equals( exp = abap_false act = z2ui5_cl_ui5_util_context=>boolean_check_by_name( `abap_bool` ) ).
    cl_abap_unit_assert=>assert_equals( exp = abap_false act = z2ui5_cl_ui5_util_context=>boolean_check_by_name( `STRING` ) ).
    cl_abap_unit_assert=>assert_equals( exp = abap_false act = z2ui5_cl_ui5_util_context=>boolean_check_by_name( `` ) ).

  ENDMETHOD.

  METHOD test_url_create.

    DATA lt_params TYPE z2ui5_cl_ui5_util_context=>ty_t_name_value.

    DATA temp25 TYPE z2ui5_cl_ui5_util_context=>ty_t_name_value.
    DATA temp26 LIKE LINE OF temp25.
    CLEAR temp25.

    temp26-n = `a`.
    temp26-v = `1`.
    INSERT temp26 INTO TABLE temp25.
    temp26-n = `b`.
    temp26-v = `2`.
    INSERT temp26 INTO TABLE temp25.
    lt_params = temp25.

    cl_abap_unit_assert=>assert_equals(
        exp = `a=1&b=2`
        act = z2ui5_cl_ui5_util_context=>url_param_create_url( lt_params ) ).

  ENDMETHOD.

  METHOD test_url_create_empty.

    " no parameters must produce an empty string, not a stray separator
    DATA lt_params TYPE z2ui5_cl_ui5_util_context=>ty_t_name_value.

    cl_abap_unit_assert=>assert_equals(
        exp = ``
        act = z2ui5_cl_ui5_util_context=>url_param_create_url( lt_params ) ).

  ENDMETHOD.

  METHOD test_url_roundtrip.

    " parsing a query string and rebuilding it has to be stable - the phantom
    " nameless row that once leaked out as `=&` broke exactly this
    DATA lt_params TYPE z2ui5_cl_ui5_util_context=>ty_t_name_value.
    lt_params = z2ui5_cl_ui5_util_context=>url_param_get_tab( `?a=1&b=2` ).

    cl_abap_unit_assert=>assert_equals(
        exp = `a=1&b=2`
        act = z2ui5_cl_ui5_util_context=>url_param_create_url( lt_params ) ).

  ENDMETHOD.

ENDCLASS.


CLASS ltcl_rtti DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_s_row,
        name TYPE string,
        city TYPE string,
      END OF ty_s_row.
    TYPES ty_t_row TYPE STANDARD TABLE OF ty_s_row WITH DEFAULT KEY.

    " a structure with an include, for the component expansion: the
    " include's own components are expanded in place of the include entry
    TYPES BEGIN OF ty_s_incl.
    TYPES name TYPE string.
    TYPES city TYPE string.
    TYPES END OF ty_s_incl.
    TYPES BEGIN OF ty_s_with_incl.
    INCLUDE TYPE ty_s_incl.
    TYPES zip TYPE string.
    TYPES END OF ty_s_with_incl.

    " the same include renamed with a suffix. One level only: a suffix
    " inside a suffixed include chains on a system, but the transpiled
    " runtime's structdescr does not model the nesting
    TYPES BEGIN OF ty_s_with_suffix.
    TYPES id TYPE string.
    INCLUDE TYPE ty_s_incl AS inner RENAMING WITH SUFFIX _in.
    TYPES zip TYPE string.
    TYPES END OF ty_s_with_suffix.

    METHODS test_attri_include    FOR TESTING RAISING cx_static_check.
    METHODS test_attri_include_suffix FOR TESTING RAISING cx_static_check.
    METHODS test_check_clike     FOR TESTING RAISING cx_static_check.
    METHODS test_printable_decfloat FOR TESTING RAISING cx_static_check.
    METHODS test_srtti_pair_roundtrip FOR TESTING RAISING cx_static_check.
    METHODS test_html_get_plain FOR TESTING RAISING cx_static_check.
    METHODS test_check_table     FOR TESTING RAISING cx_static_check.
    METHODS test_check_structure FOR TESTING RAISING cx_static_check.
    METHODS test_check_ref_data  FOR TESTING RAISING cx_static_check.
    METHODS test_bound_not_init  FOR TESTING RAISING cx_static_check.
    METHODS test_struc_to_pairs  FOR TESTING RAISING cx_static_check.
    METHODS test_scan_flag       FOR TESTING RAISING cx_static_check.
    METHODS test_scan_flag_nested FOR TESTING RAISING cx_static_check.
    METHODS test_sel_tab_unbound  FOR TESTING RAISING cx_static_check.
    METHODS test_sel_tab_elem     FOR TESTING RAISING cx_static_check.
    METHODS test_sel_tab_of_tabs  FOR TESTING RAISING cx_static_check.
    METHODS test_sel_tab_existing FOR TESTING RAISING cx_static_check.
    METHODS test_error_attributes FOR TESTING RAISING cx_static_check.
    METHODS test_error_unbound    FOR TESTING RAISING cx_static_check.

ENDCLASS.


" an exception with attributes of its own - the public printable one is what
" the error dump shows, the table and the private one are not
CLASS ltcl_rtti_cx DEFINITION FINAL INHERITING FROM cx_static_check.
  PUBLIC SECTION.
    DATA mv_detail TYPE string.
    DATA mv_empty  TYPE string ##NEEDED.
    DATA mt_rows   TYPE string_table ##NEEDED.
    METHODS constructor
      IMPORTING
        detail TYPE string.
  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA mv_secret TYPE string.
ENDCLASS.

CLASS ltcl_rtti_cx IMPLEMENTATION.
  METHOD constructor ##ADT_SUPPRESS_GENERATION.
    super->constructor( ).
    mv_detail = detail.
    mv_secret = `secret`.
    APPEND `row` TO mt_rows.
  ENDMETHOD.
ENDCLASS.


CLASS z2ui5_cl_ui5_util_context DEFINITION LOCAL FRIENDS ltcl_rtti.


CLASS ltcl_rtti IMPLEMENTATION.

  METHOD test_attri_include.

    " the include is expanded into its own components, in place, and the
    " components after it follow - rtti_get_t_attri_by_include used to
    " re-describe the include by its absolute name, which a local type
    " like this one need not resolve; the descriptor the component carries
    " is the include's own
    DATA ls_with_incl TYPE ty_s_with_incl.

    DATA lt_comp TYPE abap_component_tab.
    FIELD-SYMBOLS <temp27> LIKE LINE OF lt_comp.
    DATA temp28 LIKE sy-tabix.
    FIELD-SYMBOLS <temp29> LIKE LINE OF lt_comp.
    DATA temp30 LIKE sy-tabix.
    FIELD-SYMBOLS <temp31> LIKE LINE OF lt_comp.
    DATA temp32 LIKE sy-tabix.
    lt_comp = z2ui5_cl_ui5_util_context=>rtti_get_t_attri_by_any( ls_with_incl ).

    cl_abap_unit_assert=>assert_equals( exp = 3
                                        act = lines( lt_comp ) ).


    temp28 = sy-tabix.
    READ TABLE lt_comp INDEX 1 ASSIGNING <temp27>.
    sy-tabix = temp28.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `NAME`
                                        act = <temp27>-name ).


    temp30 = sy-tabix.
    READ TABLE lt_comp INDEX 2 ASSIGNING <temp29>.
    sy-tabix = temp30.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `CITY`
                                        act = <temp29>-name ).


    temp32 = sy-tabix.
    READ TABLE lt_comp INDEX 3 ASSIGNING <temp31>.
    sy-tabix = temp32.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `ZIP`
                                        act = <temp31>-name ).
    " no include entry survives the expansion (a plain READ: the downport
    " does not rewrite a line_exists( ) inside a method call argument)
    READ TABLE lt_comp WITH KEY as_include = abap_true TRANSPORTING NO FIELDS. "#EC CI_SORTSEQ
    cl_abap_unit_assert=>assert_subrc( exp = 4 ).

  ENDMETHOD.

  METHOD test_attri_include_suffix.

    " RENAMING WITH SUFFIX names the components <name><suffix> on the
    " structure - the expansion used to report the bare include names, so
    " every binding path built from them (srv_model diss_struc,
    " srv_bind bind_tab_cell) named a component that does not exist
    DATA ls_struc TYPE ty_s_with_suffix.

    DATA lt_comp TYPE abap_component_tab.
    FIELD-SYMBOLS <temp33> LIKE LINE OF lt_comp.
    DATA temp34 LIKE sy-tabix.
    FIELD-SYMBOLS <temp35> LIKE LINE OF lt_comp.
    DATA temp36 LIKE sy-tabix.
    FIELD-SYMBOLS <temp37> LIKE LINE OF lt_comp.
    DATA temp38 LIKE sy-tabix.
    FIELD-SYMBOLS <temp39> LIKE LINE OF lt_comp.
    DATA temp40 LIKE sy-tabix.
    DATA temp41 LIKE LINE OF lt_comp.
    DATA lr_comp LIKE REF TO temp41.
      FIELD-SYMBOLS <lv_field> TYPE any.
    lt_comp = z2ui5_cl_ui5_util_context=>rtti_get_t_attri_by_any( ls_struc ).

    cl_abap_unit_assert=>assert_equals( exp = 4
                                        act = lines( lt_comp ) ).


    temp34 = sy-tabix.
    READ TABLE lt_comp INDEX 1 ASSIGNING <temp33>.
    sy-tabix = temp34.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `ID`
                                        act = <temp33>-name ).


    temp36 = sy-tabix.
    READ TABLE lt_comp INDEX 2 ASSIGNING <temp35>.
    sy-tabix = temp36.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `NAME_IN`
                                        act = <temp35>-name ).


    temp38 = sy-tabix.
    READ TABLE lt_comp INDEX 3 ASSIGNING <temp37>.
    sy-tabix = temp38.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `CITY_IN`
                                        act = <temp37>-name ).


    temp40 = sy-tabix.
    READ TABLE lt_comp INDEX 4 ASSIGNING <temp39>.
    sy-tabix = temp40.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `ZIP`
                                        act = <temp39>-name ).

    " every reported name is a component the structure really has


    LOOP AT lt_comp REFERENCE INTO lr_comp.

      ASSIGN COMPONENT lr_comp->name OF STRUCTURE ls_struc TO <lv_field> ##NEEDED.
      cl_abap_unit_assert=>assert_subrc( exp = 0 ).
    ENDLOOP.

  ENDMETHOD.

  METHOD test_html_get_plain.

    " tags become blanks, entities their characters, an unclosed tag takes
    " the rest with it - the contract the one-pass rewrite has to keep
    cl_abap_unit_assert=>assert_equals(
        exp = `a b`
        act = z2ui5_cl_ui5_util_context=>html_get_plain( `<td>a</td><td>b</td>` ) ).
    cl_abap_unit_assert=>assert_equals(
        exp = `x < y & z`
        act = z2ui5_cl_ui5_util_context=>html_get_plain( `<p>x &lt; y &amp; z</p>` ) ).
    cl_abap_unit_assert=>assert_equals(
        exp = `a`
        act = z2ui5_cl_ui5_util_context=>html_get_plain( `a <b` ) ).
    cl_abap_unit_assert=>assert_equals(
        exp = `plain`
        act = z2ui5_cl_ui5_util_context=>html_get_plain( `plain` ) ).

  ENDMETHOD.

  METHOD test_srtti_pair_roundtrip.

    " type and data as two documents: neither carries the other, and the
    " pair parses back into the same table - the combined document (one
    " lex for the type, one for the data) is what every draft used to carry
    FIELD-SYMBOLS <tab>  TYPE STANDARD TABLE.
    FIELD-SYMBOLS <back> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <row>  TYPE any.
    FIELD-SYMBOLS <col>  TYPE any.
    DATA lv_col   TYPE string.
    DATA lv_type  TYPE string.
    DATA lv_data  TYPE string.

    " a runtime-built line type, like a table an app creates dynamically
    DATA temp42 TYPE cl_abap_structdescr=>component_table.
    DATA temp43 LIKE LINE OF temp42.
    DATA temp1 TYPE REF TO cl_abap_datadescr.
    DATA lt_comp LIKE temp42.
    DATA lo_tab TYPE REF TO cl_abap_tabledescr.
    DATA lr_tab TYPE REF TO data.
    DATA temp3 TYPE xsdboolean.
    DATA temp4 TYPE xsdboolean.
    DATA lr_back TYPE REF TO data.
    CLEAR temp42.

    temp43-name = `COL1`.

    temp1 ?= cl_abap_datadescr=>describe_by_data( lv_col ).
    temp43-type = temp1.
    INSERT temp43 INTO TABLE temp42.

    lt_comp = temp42.

    lo_tab = cl_abap_tabledescr=>create( p_line_type  = cl_abap_structdescr=>create( lt_comp )
                                               p_table_kind = cl_abap_tabledescr=>tablekind_std ).

    CREATE DATA lr_tab TYPE HANDLE lo_tab.
    ASSIGN lr_tab->* TO <tab>.
    APPEND INITIAL LINE TO <tab> ASSIGNING <row>.
    ASSIGN COMPONENT `COL1` OF STRUCTURE <row> TO <col>.
    cl_abap_unit_assert=>assert_subrc( ).
    <col> = `payload-value`.

    z2ui5_cl_ui5_util_context=>xml_srtti_stringify_pair( EXPORTING data    = <tab>
                                                         IMPORTING ev_type = lv_type
                                                                   ev_data = lv_data ).
    cl_abap_unit_assert=>assert_not_initial( lv_type ).
    cl_abap_unit_assert=>assert_not_initial( lv_data ).

    temp3 = boolc( lv_type CS `payload-value` ).
    cl_abap_unit_assert=>assert_equals( exp = abap_false act = temp3 ).

    temp4 = boolc( lv_data CS `payload-value` ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp4 ).


    lr_back = z2ui5_cl_ui5_util_context=>xml_srtti_parse_pair( iv_type = lv_type
                                                                     iv_data = lv_data ).
    ASSIGN lr_back->* TO <back>.
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( <back> ) ).
    READ TABLE <back> INDEX 1 ASSIGNING <row>.
    cl_abap_unit_assert=>assert_subrc( ).
    ASSIGN COMPONENT `COL1` OF STRUCTURE <row> TO <col>.
    cl_abap_unit_assert=>assert_subrc( ).
    cl_abap_unit_assert=>assert_equals( exp = `payload-value`
                                        act = <col> ).

  ENDMETHOD.

  METHOD test_printable_decfloat.

    " decfloat16/34 are numbers like i, p and f: printable in an exception's
    " attribute dump and as a message box headline. They used to fall
    " through the CASE and rendered as UNKNOWN_ERROR / a `Data` headline.
    " Only the 34-digit kind here: the NodeJS runtime has no decfloat16
    " type, the production CASE names both
    DATA lv_d34 TYPE decfloat34 VALUE '2.25'.

    cl_abap_unit_assert=>assert_equals( exp = abap_true act = z2ui5_cl_ui5_util_context=>rtti_check_printable( lv_d34 ) ).

  ENDMETHOD.

  METHOD test_check_clike.

    DATA lv_int  TYPE i VALUE 5.
    DATA lv_char TYPE c LENGTH 4.
    DATA lv_numc TYPE n LENGTH 4.
    DATA lv_date TYPE d.
    DATA ls_row  TYPE ty_s_row.

    cl_abap_unit_assert=>assert_equals( exp = abap_true act = z2ui5_cl_ui5_util_context=>rtti_check_clike( `abc` ) ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = z2ui5_cl_ui5_util_context=>rtti_check_clike( lv_char ) ).
    " n, d and t are character-like too and must be accepted
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = z2ui5_cl_ui5_util_context=>rtti_check_clike( lv_numc ) ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = z2ui5_cl_ui5_util_context=>rtti_check_clike( lv_date ) ).

    cl_abap_unit_assert=>assert_equals( exp = abap_false act = z2ui5_cl_ui5_util_context=>rtti_check_clike( lv_int ) ).
    cl_abap_unit_assert=>assert_equals( exp = abap_false act = z2ui5_cl_ui5_util_context=>rtti_check_clike( ls_row ) ).

  ENDMETHOD.

  METHOD test_check_table.

    DATA lt_row TYPE ty_t_row.
    DATA ls_row TYPE ty_s_row.

    cl_abap_unit_assert=>assert_equals( exp = abap_true act = z2ui5_cl_ui5_util_context=>rtti_check_table( lt_row ) ).

    cl_abap_unit_assert=>assert_equals( exp = abap_false act = z2ui5_cl_ui5_util_context=>rtti_check_table( ls_row ) ).
    cl_abap_unit_assert=>assert_equals( exp = abap_false act = z2ui5_cl_ui5_util_context=>rtti_check_table( `abc` ) ).

  ENDMETHOD.

  METHOD test_check_structure.

    DATA ls_row TYPE ty_s_row.
    DATA lt_row TYPE ty_t_row.

    cl_abap_unit_assert=>assert_equals( exp = abap_true act = z2ui5_cl_ui5_util_context=>rtti_check_structure( ls_row ) ).

    cl_abap_unit_assert=>assert_equals( exp = abap_false act = z2ui5_cl_ui5_util_context=>rtti_check_structure( `abc` ) ).
    cl_abap_unit_assert=>assert_equals( exp = abap_false act = z2ui5_cl_ui5_util_context=>rtti_check_structure( lt_row ) ).

  ENDMETHOD.

  METHOD test_check_ref_data.

    DATA lr_data TYPE REF TO data.

    CREATE DATA lr_data TYPE string.

    cl_abap_unit_assert=>assert_equals( exp = abap_true act = z2ui5_cl_ui5_util_context=>rtti_check_ref_data( lr_data ) ).

    cl_abap_unit_assert=>assert_equals( exp = abap_false act = z2ui5_cl_ui5_util_context=>rtti_check_ref_data( `abc` ) ).

  ENDMETHOD.

  METHOD test_bound_not_init.

    " unbound, bound-but-initial and bound-with-value are three distinct
    " states; only the last one may report true
    DATA lr_unbound TYPE REF TO data.
    DATA lr_initial TYPE REF TO data.
    DATA lr_filled  TYPE REF TO data.
    FIELD-SYMBOLS <val> TYPE string.

    CREATE DATA lr_initial TYPE string.

    CREATE DATA lr_filled TYPE string.
    ASSIGN lr_filled->* TO <val>.
    <val> = `x`.

    cl_abap_unit_assert=>assert_equals( exp = abap_false act = z2ui5_cl_ui5_util_context=>check_bound_a_not_initial( lr_unbound ) ).
    cl_abap_unit_assert=>assert_equals( exp = abap_false act = z2ui5_cl_ui5_util_context=>check_bound_a_not_initial( lr_initial ) ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = z2ui5_cl_ui5_util_context=>check_bound_a_not_initial( lr_filled ) ).

  ENDMETHOD.

  METHOD test_struc_to_pairs.

    DATA ls_row TYPE ty_s_row.
    DATA lt_pair TYPE z2ui5_cl_ui5_util_context=>ty_t_name_value.
    FIELD-SYMBOLS <temp44> LIKE LINE OF lt_pair.
    DATA temp45 LIKE sy-tabix.
    FIELD-SYMBOLS <temp46> LIKE LINE OF lt_pair.
    DATA temp47 LIKE sy-tabix.

    ls_row-name = `Ada`.
    ls_row-city = `London`.


    lt_pair = z2ui5_cl_ui5_util_context=>itab_get_by_struc( ls_row ).

    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( lt_pair ) ).

    " component names come back from RTTI in upper case


    temp45 = sy-tabix.
    READ TABLE lt_pair WITH KEY n = `NAME` ASSIGNING <temp44>.
    sy-tabix = temp45.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `Ada`
                                        act = <temp44>-v ).


    temp47 = sy-tabix.
    READ TABLE lt_pair WITH KEY n = `CITY` ASSIGNING <temp46>.
    sy-tabix = temp47.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `London`
                                        act = <temp46>-v ).

  ENDMETHOD.

  METHOD test_scan_flag.

    " returns the suffix of every prefixed component that is set - the RAP
    " message mapping builds %OP-%ACTION-<name> lookups on top of this
    TYPES:
      BEGIN OF ty_s_flags,
        flag_a TYPE abap_bool,
        flag_b TYPE abap_bool,
        other  TYPE abap_bool,
      END OF ty_s_flags.

    DATA ls_flags TYPE ty_s_flags.
    DATA lt_found TYPE string_table.
    FIELD-SYMBOLS <temp48> LIKE LINE OF lt_found.
    DATA temp49 LIKE sy-tabix.

    ls_flags-flag_a = abap_true.
    ls_flags-flag_b = abap_false.
    ls_flags-other  = abap_true.


    lt_found = z2ui5_cl_ui5_util_context=>scan_flag_prefix( val = ls_flags
                                                               prefix = `FLAG_` ).

    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( lt_found ) ).


    temp49 = sy-tabix.
    READ TABLE lt_found INDEX 1 ASSIGNING <temp48>.
    sy-tabix = temp49.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `A`
                                        act = <temp48> ).

  ENDMETHOD.

  METHOD test_scan_flag_nested.

    " a `-` in the prefix walks into a nested structure, the shape of the
    " RAP prefixes %ELEMENT- and %OP-%ACTION- (spelled without the %, which
    " a TYPES statement here cannot declare): the component names never
    " contain the `-`, so the flat compare found nothing
    TYPES:
      BEGIN OF ty_s_row,
        pid TYPE string,
        BEGIN OF element,
          name TYPE abap_bool,
          city TYPE abap_bool,
        END OF element,
        BEGIN OF op,
          BEGIN OF action,
            approve TYPE abap_bool,
            reject  TYPE abap_bool,
          END OF action,
        END OF op,
      END OF ty_s_row.

    DATA ls_row TYPE ty_s_row.
    DATA lt_element TYPE string_table.
    FIELD-SYMBOLS <temp50> LIKE LINE OF lt_element.
    DATA temp51 LIKE sy-tabix.
    DATA lt_action TYPE string_table.
    FIELD-SYMBOLS <temp52> LIKE LINE OF lt_action.
    DATA temp53 LIKE sy-tabix.

    ls_row-pid               = `1`.
    ls_row-element-name      = abap_true.
    ls_row-op-action-approve = abap_true.


    lt_element = z2ui5_cl_ui5_util_context=>scan_flag_prefix( val  = ls_row
                                                                  prefix = `ELEMENT-` ).
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( lt_element ) ).


    temp51 = sy-tabix.
    READ TABLE lt_element INDEX 1 ASSIGNING <temp50>.
    sy-tabix = temp51.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `NAME`
                                        act = <temp50> ).


    lt_action = z2ui5_cl_ui5_util_context=>scan_flag_prefix( val  = ls_row
                                                                 prefix = `OP-ACTION-` ).
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( lt_action ) ).


    temp53 = sy-tabix.
    READ TABLE lt_action INDEX 1 ASSIGNING <temp52>.
    sy-tabix = temp53.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `APPROVE`
                                        act = <temp52> ).

    " a path that does not exist, or ends in a non-structure, finds nothing
    cl_abap_unit_assert=>assert_initial(
        z2ui5_cl_ui5_util_context=>scan_flag_prefix( val    = ls_row
                                                     prefix = `NOPE-` ) ).
    cl_abap_unit_assert=>assert_initial(
        z2ui5_cl_ui5_util_context=>scan_flag_prefix( val    = ls_row
                                                     prefix = `PID-` ) ).

  ENDMETHOD.

  METHOD test_sel_tab_unbound.

    " no table reference is the caller's mistake and is said so, not an
    " ASSIGN on nothing
    DATA lr_none TYPE REF TO data.
        DATA lx TYPE REF TO z2ui5_cx_ui5_util_error.

    TRY.
        z2ui5_cl_ui5_util_context=>rtti_create_sel_tab_type( lr_none ).
        cl_abap_unit_assert=>fail( `an unbound table reference must raise` ).

      CATCH z2ui5_cx_ui5_util_error INTO lx.
        cl_abap_unit_assert=>assert_char_cp( exp = `*no table reference*`
                                             act = lx->get_text( ) ).
    ENDTRY.

  ENDMETHOD.

  METHOD test_sel_tab_elem.

    " a table of scalars gets its line wrapped into TAB_LINE, flagged so the
    " caller knows to unwrap it on the way back, plus the selection flag
    DATA lt_names TYPE string_table.
    DATA temp54 TYPE string_table.
    DATA temp56 LIKE REF TO lt_names.
DATA ls_type TYPE z2ui5_cl_ui5_util_context=>ty_s_sel_tab_type.
    DATA temp57 TYPE REF TO cl_abap_structdescr.
    DATA lt_comp TYPE abap_component_tab.
    FIELD-SYMBOLS <temp58> LIKE LINE OF lt_comp.
    DATA temp59 LIKE sy-tabix.
    FIELD-SYMBOLS <temp60> LIKE LINE OF lt_comp.
    DATA temp61 LIKE sy-tabix.
    CLEAR temp54.
    INSERT `a` INTO TABLE temp54.
    lt_names = temp54.


    GET REFERENCE OF lt_names INTO temp56.

ls_type = z2ui5_cl_ui5_util_context=>rtti_create_sel_tab_type( ir_tab       = temp56
                                                                        add_sel_field = abap_true ).

    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = ls_type-check_table_line ).

    temp57 ?= ls_type-tabledescr->get_table_line_type( ).

    lt_comp = temp57->get_components( ).
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( lt_comp ) ).


    temp59 = sy-tabix.
    READ TABLE lt_comp INDEX 1 ASSIGNING <temp58>.
    sy-tabix = temp59.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `TAB_LINE`
                                        act = <temp58>-name ).


    temp61 = sy-tabix.
    READ TABLE lt_comp INDEX 2 ASSIGNING <temp60>.
    sy-tabix = temp61.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `ZZSELKZ`
                                        act = <temp60>-name ).

  ENDMETHOD.

  METHOD test_sel_tab_of_tabs.

    " a table of tables has no line a row could be selected from
    TYPES temp1 TYPE STANDARD TABLE OF string_table WITH DEFAULT KEY.
DATA lt_deep TYPE temp1.
        DATA temp62 LIKE REF TO lt_deep.
        DATA lx TYPE REF TO z2ui5_cx_ui5_util_error.

    TRY.

        GET REFERENCE OF lt_deep INTO temp62.
z2ui5_cl_ui5_util_context=>rtti_create_sel_tab_type( temp62 ).
        cl_abap_unit_assert=>fail( `a table of tables must raise` ).

      CATCH z2ui5_cx_ui5_util_error INTO lx.
        cl_abap_unit_assert=>assert_char_cp( exp = `*no selectable line*`
                                             act = lx->get_text( ) ).
    ENDTRY.

  ENDMETHOD.

  METHOD test_sel_tab_existing.

    " a line that already carries the selection field keeps it - no second
    " ZZSELKZ, and no flag on a structured line
    TYPES:
      BEGIN OF ty_s_sel,
        name    TYPE string,
        zzselkz TYPE abap_bool,
      END OF ty_s_sel.
    TYPES temp2 TYPE STANDARD TABLE OF ty_s_sel WITH DEFAULT KEY.
DATA lt_sel TYPE temp2.

    DATA temp63 LIKE REF TO lt_sel.
DATA ls_type TYPE z2ui5_cl_ui5_util_context=>ty_s_sel_tab_type.
    DATA temp64 TYPE REF TO cl_abap_structdescr.
    DATA lt_comp TYPE abap_component_tab.
    GET REFERENCE OF lt_sel INTO temp63.

ls_type = z2ui5_cl_ui5_util_context=>rtti_create_sel_tab_type( ir_tab       = temp63
                                                                        add_sel_field = abap_true ).

    cl_abap_unit_assert=>assert_equals( exp = abap_false
                                        act = ls_type-check_table_line ).

    temp64 ?= ls_type-tabledescr->get_table_line_type( ).

    lt_comp = temp64->get_components( ).
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( lt_comp ) ).

  ENDMETHOD.

  METHOD test_error_attributes.

    " the attributes of an exception, as name/value pairs for the error
    " popup: public, printable and filled - the table, the private one and
    " cx_root's own bookkeeping (PREVIOUS, TEXTID, ...) stay out
    DATA lx TYPE REF TO cx_root.
    DATA lt_attri TYPE z2ui5_cl_ui5_util_context=>ty_t_name_value.
    FIELD-SYMBOLS <temp65> LIKE LINE OF lt_attri.
    DATA temp66 LIKE sy-tabix.
    FIELD-SYMBOLS <temp67> LIKE LINE OF lt_attri.
    DATA temp68 LIKE sy-tabix.
    TRY.
        RAISE EXCEPTION TYPE ltcl_rtti_cx
          EXPORTING
            detail = `  the detail  `.
      CATCH cx_root INTO lx ##NO_HANDLER.
    ENDTRY.


    lt_attri = z2ui5_cl_ui5_util_context=>error_get_attributes( lx ).

    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( lt_attri ) ).


    temp66 = sy-tabix.
    READ TABLE lt_attri INDEX 1 ASSIGNING <temp65>.
    sy-tabix = temp66.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `MV_DETAIL`
                                        act = <temp65>-n ).


    temp68 = sy-tabix.
    READ TABLE lt_attri INDEX 1 ASSIGNING <temp67>.
    sy-tabix = temp68.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `the detail`
                                        act = <temp67>-v ).

  ENDMETHOD.

  METHOD test_error_unbound.

    " no exception, no attributes and no position - both answer nothing
    DATA lx TYPE REF TO cx_root.

    cl_abap_unit_assert=>assert_initial( z2ui5_cl_ui5_util_context=>error_get_attributes( lx ) ).
    cl_abap_unit_assert=>assert_initial( z2ui5_cl_ui5_util_context=>error_get_source_position( lx ) ).

  ENDMETHOD.

ENDCLASS.


CLASS ltcl_itab DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_s_row,
        name TYPE string,
        city TYPE string,
      END OF ty_s_row.
    TYPES ty_t_row TYPE STANDARD TABLE OF ty_s_row WITH DEFAULT KEY.

    METHODS get_rows RETURNING VALUE(result) TYPE ty_t_row.

    METHODS test_filter_all_fields  FOR TESTING RAISING cx_static_check.
    METHODS test_filter_ignore_case FOR TESTING RAISING cx_static_check.
    METHODS test_filter_named_field FOR TESTING RAISING cx_static_check.
    METHODS test_filter_no_match    FOR TESTING RAISING cx_static_check.
    METHODS test_filter_elementary  FOR TESTING RAISING cx_static_check.
    METHODS test_filter_deep_row    FOR TESTING RAISING cx_static_check.
    " an empty search is no filter - every row stays, also one with nothing
    " printable in it and with a field list that names nothing
    METHODS test_filter_empty_search FOR TESTING RAISING cx_static_check.
    METHODS test_corresponding      FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_itab IMPLEMENTATION.

  METHOD test_filter_deep_row.

    " a master-detail row carries a table of children: with no field list
    " every component is visited, and the table component used to be put
    " into a string template, which is a runtime error. It holds no text to
    " match and is skipped; the printable components still decide the row
    TYPES:
      BEGIN OF ty_s_deep,
        name     TYPE string,
        children TYPE string_table,
        ref      TYPE REF TO data,
      END OF ty_s_deep.
    TYPES temp3 TYPE STANDARD TABLE OF ty_s_deep WITH DEFAULT KEY.
DATA lt_deep TYPE temp3.

    DATA temp69 LIKE lt_deep.
    DATA temp70 LIKE LINE OF temp69.
    DATA temp2 TYPE string_table.
    DATA temp4 TYPE string_table.
    FIELD-SYMBOLS <temp71> LIKE LINE OF lt_deep.
    DATA temp72 LIKE sy-tabix.
    CLEAR temp69.

    temp70-name = `Ada`.

    CLEAR temp2.
    INSERT `London` INTO TABLE temp2.
    temp70-children = temp2.
    INSERT temp70 INTO TABLE temp69.
    temp70-name = `Alan`.

    CLEAR temp4.
    INSERT `Wilmslow` INTO TABLE temp4.
    temp70-children = temp4.
    INSERT temp70 INTO TABLE temp69.
    lt_deep = temp69.

    z2ui5_cl_ui5_util_context=>itab_filter_by_val( EXPORTING val = `Alan`
                                                CHANGING  tab    = lt_deep ).

    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( lt_deep ) ).


    temp72 = sy-tabix.
    READ TABLE lt_deep INDEX 1 ASSIGNING <temp71>.
    sy-tabix = temp72.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `Alan`
                                        act = <temp71>-name ).

  ENDMETHOD.

  METHOD get_rows.

    DATA temp73 TYPE ltcl_itab=>ty_t_row.
    DATA temp74 LIKE LINE OF temp73.
    CLEAR temp73.

    temp74-name = `Ada`.
    temp74-city = `London`.
    INSERT temp74 INTO TABLE temp73.
    temp74-name = `Alan`.
    temp74-city = `Wilmslow`.
    INSERT temp74 INTO TABLE temp73.
    temp74-name = `Grace`.
    temp74-city = `New York`.
    INSERT temp74 INTO TABLE temp73.
    result = temp73.

  ENDMETHOD.

  METHOD test_filter_all_fields.

    " with no field list every component is searched, so a hit in `city`
    " keeps the row even though `name` does not match
    DATA lt_row TYPE ltcl_itab=>ty_t_row.
    FIELD-SYMBOLS <temp75> LIKE LINE OF lt_row.
    DATA temp76 LIKE sy-tabix.
    lt_row = get_rows( ).

    z2ui5_cl_ui5_util_context=>itab_filter_by_val( EXPORTING val = `London`
                                                CHANGING  tab    = lt_row ).

    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( lt_row ) ).


    temp76 = sy-tabix.
    READ TABLE lt_row INDEX 1 ASSIGNING <temp75>.
    sy-tabix = temp76.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `Ada`
                                        act = <temp75>-name ).

  ENDMETHOD.

  METHOD test_filter_ignore_case.

    DATA lt_row TYPE ltcl_itab=>ty_t_row.
    FIELD-SYMBOLS <temp77> LIKE LINE OF lt_row.
    DATA temp78 LIKE sy-tabix.
    lt_row = get_rows( ).

    z2ui5_cl_ui5_util_context=>itab_filter_by_val( EXPORTING val      = `ada`
                                                          ignore_case = abap_true
                                                CHANGING  tab         = lt_row ).

    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( lt_row ) ).


    temp78 = sy-tabix.
    READ TABLE lt_row INDEX 1 ASSIGNING <temp77>.
    sy-tabix = temp78.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `Ada`
                                        act = <temp77>-name ).

  ENDMETHOD.

  METHOD test_filter_named_field.

    " restricted to `name`, the city value must not produce a hit
    DATA lt_fields TYPE string_table.

    DATA lt_row TYPE ltcl_itab=>ty_t_row.
    lt_row = get_rows( ).

    APPEND `NAME` TO lt_fields.

    z2ui5_cl_ui5_util_context=>itab_filter_by_val( EXPORTING val = `London`
                                                          fields = lt_fields
                                                CHANGING  tab    = lt_row ).

    cl_abap_unit_assert=>assert_initial( lt_row ).

  ENDMETHOD.

  METHOD test_filter_no_match.

    DATA lt_row TYPE ltcl_itab=>ty_t_row.
    lt_row = get_rows( ).

    z2ui5_cl_ui5_util_context=>itab_filter_by_val( EXPORTING val = `Nobody`
                                                CHANGING  tab    = lt_row ).

    cl_abap_unit_assert=>assert_initial( lt_row ).

  ENDMETHOD.

  METHOD test_filter_empty_search.

    TYPES:
      BEGIN OF ty_s_deep,
        children TYPE string_table,
        ref      TYPE REF TO data,
      END OF ty_s_deep.
    TYPES temp4 TYPE STANDARD TABLE OF ty_s_deep WITH DEFAULT KEY.
DATA lt_deep   TYPE temp4.
    DATA lt_fields TYPE string_table.

    " a row with nothing printable used to match nothing and was deleted -
    " the empty search filtered where it should not filter at all
    DATA temp79 LIKE lt_deep.
    DATA temp80 LIKE LINE OF temp79.
    DATA temp6 TYPE string_table.
    DATA temp8 TYPE string_table.
    DATA lt_row TYPE ltcl_itab=>ty_t_row.
    DATA lv_blank TYPE c LENGTH 10.
    CLEAR temp79.


    CLEAR temp6.
    INSERT `London` INTO TABLE temp6.
    temp80-children = temp6.
    INSERT temp80 INTO TABLE temp79.

    CLEAR temp8.
    temp80-children = temp8.
    INSERT temp80 INTO TABLE temp79.
    lt_deep = temp79.
    z2ui5_cl_ui5_util_context=>itab_filter_by_val( EXPORTING val = ``
                                                CHANGING  tab    = lt_deep ).
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( lt_deep ) ).

    " the ordinary rows, case-insensitive and through a field list naming a
    " component the rows do not have: still no filter

    lt_row = get_rows( ).
    APPEND `NO_SUCH_FIELD` TO lt_fields.
    z2ui5_cl_ui5_util_context=>itab_filter_by_val( EXPORTING val      = ``
                                                          fields      = lt_fields
                                                          ignore_case = abap_true
                                                CHANGING  tab         = lt_row ).
    cl_abap_unit_assert=>assert_equals( exp = 3
                                        act = lines( lt_row ) ).

    " a blank-padded CHAR search is empty too - its trailing blanks are no text

    lt_row = get_rows( ).
    z2ui5_cl_ui5_util_context=>itab_filter_by_val( EXPORTING val = lv_blank
                                                CHANGING  tab    = lt_row ).
    cl_abap_unit_assert=>assert_equals( exp = 3
                                        act = lines( lt_row ) ).

  ENDMETHOD.

  METHOD test_filter_elementary.

    " a table with an elementary line type has no components - the filter
    " matches against the whole line instead of deleting every row
    DATA lt_str TYPE string_table.

    DATA temp81 TYPE string_table.
    FIELD-SYMBOLS <temp83> LIKE LINE OF lt_str.
    DATA temp84 LIKE sy-tabix.
    CLEAR temp81.
    INSERT `London` INTO TABLE temp81.
    INSERT `Wilmslow` INTO TABLE temp81.
    INSERT `New York` INTO TABLE temp81.
    lt_str = temp81.

    z2ui5_cl_ui5_util_context=>itab_filter_by_val( EXPORTING val = `London`
                                                CHANGING  tab    = lt_str ).

    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( lt_str ) ).


    temp84 = sy-tabix.
    READ TABLE lt_str INDEX 1 ASSIGNING <temp83>.
    sy-tabix = temp84.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `London`
                                        act = <temp83> ).

  ENDMETHOD.

  METHOD test_corresponding.

    " components are matched by name, the rest stays initial
    TYPES:
      BEGIN OF ty_s_target,
        name    TYPE string,
        country TYPE string,
      END OF ty_s_target.
    TYPES ty_t_target TYPE STANDARD TABLE OF ty_s_target WITH DEFAULT KEY.

    DATA lt_target TYPE ty_t_target.

    DATA lt_row TYPE ltcl_itab=>ty_t_row.
    FIELD-SYMBOLS <temp85> LIKE LINE OF lt_target.
    DATA temp86 LIKE sy-tabix.
    FIELD-SYMBOLS <temp87> LIKE LINE OF lt_target.
    DATA temp88 LIKE sy-tabix.
    lt_row = get_rows( ).

    z2ui5_cl_ui5_util_context=>itab_corresponding( EXPORTING val = lt_row
                                                CHANGING  tab    = lt_target ).

    cl_abap_unit_assert=>assert_equals( exp = 3
                                        act = lines( lt_target ) ).


    temp86 = sy-tabix.
    READ TABLE lt_target INDEX 1 ASSIGNING <temp85>.
    sy-tabix = temp86.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `Ada`
                                        act = <temp85>-name ).


    temp88 = sy-tabix.
    READ TABLE lt_target INDEX 1 ASSIGNING <temp87>.
    sy-tabix = temp88.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_initial( <temp87>-country ).

  ENDMETHOD.

ENDCLASS.


" a plain object whose public attributes carry a message - what
" message_box_display( lo_result ) sees in an object that is neither an
" exception nor a log
CLASS ltcl_msg_carrier DEFINITION FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    " read by name through RTTI (msg_get_by_oref_attri), never statically
    DATA message TYPE string VALUE `Order 4711 saved` ##NEEDED.
    DATA type    TYPE c LENGTH 1 VALUE `S` ##NEEDED.
ENDCLASS.

CLASS ltcl_msg_carrier IMPLEMENTATION.
ENDCLASS.


CLASS ltcl_msg DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_msg_type_mapping FOR TESTING RAISING cx_static_check.
    METHODS test_box_empty_skips  FOR TESTING RAISING cx_static_check.
    METHODS test_box_single       FOR TESTING RAISING cx_static_check.
    METHODS test_box_multiple     FOR TESTING RAISING cx_static_check.
    METHODS test_box_multiple_escaped FOR TESTING RAISING cx_static_check.
    METHODS test_box_unbound_oref_skips FOR TESTING RAISING cx_static_check.
    METHODS test_box_exception_object FOR TESTING RAISING cx_static_check.
    METHODS test_box_plain_object     FOR TESTING RAISING cx_static_check.
    METHODS test_token_by_range   FOR TESTING RAISING cx_static_check.
    METHODS test_token_numeric_range FOR TESTING RAISING cx_static_check.
    METHODS test_token_odd_option FOR TESTING RAISING cx_static_check.
    METHODS test_token_dollar_value FOR TESTING RAISING cx_static_check.
    METHODS test_box_no_msg_skips FOR TESTING RAISING cx_static_check.
    " what msg_get_internal does with a STRUCTURE the caller handed in
    METHODS test_msg_initial_struct   FOR TESTING RAISING cx_static_check.
    METHODS test_msg_item_component   FOR TESTING RAISING cx_static_check.
    METHODS test_msg_item_plain_field FOR TESTING RAISING cx_static_check.
    METHODS test_msg_id_key_column FOR TESTING RAISING cx_static_check.
    METHODS test_msg_id_without_text  FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_msg IMPLEMENTATION.

  METHOD test_msg_initial_struct.

    " an all-initial structure carries no message, and says so by answering
    " NOTHING rather than one blank entry - the caller (message_box_display)
    " then falls back to the DATA renderer, which is the documented answer
    " for "nothing in here is a message"
    TYPES:
      BEGIN OF ty_s_msg_like,
        id   TYPE string,
        text TYPE string,
      END OF ty_s_msg_like.

    DATA temp89 TYPE ty_s_msg_like.
    DATA ls_empty LIKE temp89.
    CLEAR temp89.

    ls_empty = temp89.

    cl_abap_unit_assert=>assert_initial(
        z2ui5_cl_ui5_util_context=>msg_get_t( ls_empty ) ).

  ENDMETHOD.

  METHOD test_msg_id_key_column.

    " an ID column without a message NUMBER is a key, not a T100 message:
    " a table of business rows is data, and the box falls back to the data
    " renderer - it showed `2 Messages found` with I:0001: and I:0002:
    TYPES:
      BEGIN OF ty_s_row,
        id   TYPE c LENGTH 4,
        name TYPE string,
      END OF ty_s_row.
    TYPES ty_t_row TYPE STANDARD TABLE OF ty_s_row WITH DEFAULT KEY.

    DATA temp90 TYPE ty_t_row.
    DATA temp91 LIKE LINE OF temp90.
    DATA lt_rows LIKE temp90.
    CLEAR temp90.

    temp91-id = `0001`.
    temp91-name = `Ada`.
    INSERT temp91 INTO TABLE temp90.
    temp91-id = `0002`.
    temp91-name = `Alan`.
    INSERT temp91 INTO TABLE temp90.

    lt_rows = temp90.

    cl_abap_unit_assert=>assert_equals( exp = abap_true act = z2ui5_cl_ui5_util_context=>ui5_msg_box_format( lt_rows )-skip ).

  ENDMETHOD.

  METHOD test_msg_item_plain_field.

    " an ITEM that is a plain field (a position number) is no envelope:
    " it used to become the whole message, text `0010`, and the structure
    " was never handed to the data renderer
    TYPES:
      BEGIN OF ty_s_row,
        name TYPE string,
        item TYPE c LENGTH 4,
      END OF ty_s_row.

    DATA temp92 TYPE ty_s_row.
    DATA ls_row LIKE temp92.
    DATA ls_box TYPE z2ui5_cl_ui5_util_context=>ty_s_msg_box.
    CLEAR temp92.
    temp92-name = `Ada`.
    temp92-item = `0010`.

    ls_row = temp92.


    ls_box = z2ui5_cl_ui5_util_context=>ui5_msg_box_format( ls_row ).

    cl_abap_unit_assert=>assert_equals( exp = abap_true act = ls_box-skip ).

  ENDMETHOD.

  METHOD test_msg_item_component.

    " a component called ITEM is the BAPI shape: the messages are IN it, and
    " the structure around it is an envelope. So the walk hands ITEM on and
    " RETURNS - the envelope's own components are not mapped, which is what
    " keeps a TYPE or ID sitting next to ITEM out of the nested messages
    TYPES:
      BEGIN OF ty_s_item,
        type    TYPE c LENGTH 1,
        message TYPE string,
      END OF ty_s_item.
    TYPES ty_t_item TYPE STANDARD TABLE OF ty_s_item WITH DEFAULT KEY.
    TYPES:
      BEGIN OF ty_s_envelope,
        type TYPE c LENGTH 1,
        item TYPE ty_t_item,
      END OF ty_s_envelope.

    DATA ls_env TYPE ty_s_envelope.
    DATA temp93 TYPE ty_s_item.
    DATA temp94 TYPE ty_s_item.
    DATA lt_msg TYPE z2ui5_cl_ui5_util_context=>ty_t_msg.
    FIELD-SYMBOLS <temp95> LIKE LINE OF lt_msg.
    DATA temp96 LIKE sy-tabix.
    FIELD-SYMBOLS <temp97> LIKE LINE OF lt_msg.
    DATA temp98 LIKE sy-tabix.
    FIELD-SYMBOLS <temp99> LIKE LINE OF lt_msg.
    DATA temp100 LIKE sy-tabix.
    FIELD-SYMBOLS <temp101> LIKE LINE OF lt_msg.
    DATA temp102 LIKE sy-tabix.
    " the envelope's own type says Success and must NOT reach the messages
    ls_env-type = `S`.

    CLEAR temp93.
    temp93-type = `E`.
    temp93-message = `first`.
    APPEND temp93 TO ls_env-item.

    CLEAR temp94.
    temp94-type = `W`.
    temp94-message = `second`.
    APPEND temp94 TO ls_env-item.


    lt_msg = z2ui5_cl_ui5_util_context=>msg_get_t( ls_env ).

    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( lt_msg ) ).


    temp96 = sy-tabix.
    READ TABLE lt_msg INDEX 1 ASSIGNING <temp95>.
    sy-tabix = temp96.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `first`
                                        act = <temp95>-text ).


    temp98 = sy-tabix.
    READ TABLE lt_msg INDEX 1 ASSIGNING <temp97>.
    sy-tabix = temp98.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `E`
                                        act = <temp97>-type ).


    temp100 = sy-tabix.
    READ TABLE lt_msg INDEX 2 ASSIGNING <temp99>.
    sy-tabix = temp100.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `second`
                                        act = <temp99>-text ).


    temp102 = sy-tabix.
    READ TABLE lt_msg INDEX 2 ASSIGNING <temp101>.
    sy-tabix = temp102.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `W`
                                        act = <temp101>-type ).

  ENDMETHOD.

  METHOD test_msg_id_without_text.

    " the T100 shape: a structure that names a message by ID and NUMBER and
    " carries no TEXT. The walk assembles the text from the message class
    " rather than handing the caller a blank box - and the ID is upper-cased
    " first, because a lower-case one finds nothing
    TYPES:
      BEGIN OF ty_s_t100,
        id         TYPE string,
        number     TYPE n LENGTH 3,
        type       TYPE c LENGTH 1,
        message_v1 TYPE string,
      END OF ty_s_t100.

    DATA temp103 TYPE ty_s_t100.
    DATA ls_t100 LIKE temp103.
    DATA lt_msg TYPE z2ui5_cl_ui5_util_context=>ty_t_msg.
    FIELD-SYMBOLS <temp104> LIKE LINE OF lt_msg.
    DATA temp105 LIKE sy-tabix.
    FIELD-SYMBOLS <temp106> LIKE LINE OF lt_msg.
    DATA temp107 LIKE sy-tabix.
    FIELD-SYMBOLS <temp108> LIKE LINE OF lt_msg.
    DATA temp109 LIKE sy-tabix.
    FIELD-SYMBOLS <temp110> LIKE LINE OF lt_msg.
    DATA temp111 LIKE sy-tabix.
    CLEAR temp103.
    temp103-id = `z2ui5_test`.
    temp103-number = '001'.
    temp103-type = `E`.
    temp103-message_v1 = `4711`.

    ls_t100 = temp103.


    lt_msg = z2ui5_cl_ui5_util_context=>msg_get_t( ls_t100 ).

    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( lt_msg ) ).
    " the parts the walk mapped by name, whatever the message class says


    temp105 = sy-tabix.
    READ TABLE lt_msg INDEX 1 ASSIGNING <temp104>.
    sy-tabix = temp105.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `Z2UI5_TEST`
                                        act = <temp104>-id ).


    temp107 = sy-tabix.
    READ TABLE lt_msg INDEX 1 ASSIGNING <temp106>.
    sy-tabix = temp107.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `E`
                                        act = <temp106>-type ).


    temp109 = sy-tabix.
    READ TABLE lt_msg INDEX 1 ASSIGNING <temp108>.
    sy-tabix = temp109.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `4711`
                                        act = <temp108>-v1 ).
    " and a text was assembled rather than left blank


    temp111 = sy-tabix.
    READ TABLE lt_msg INDEX 1 ASSIGNING <temp110>.
    sy-tabix = temp111.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_not_initial( <temp110>-text ).

  ENDMETHOD.

  METHOD test_msg_type_mapping.

    " E and the two types above it (A abort, X exit) are errors; anything
    " that is not E/A/X/S/W falls back to Information - the UI5 MessageBox
    " has no other state to render
    cl_abap_unit_assert=>assert_equals( exp = `Error`
                                        act = z2ui5_cl_ui5_util_context=>ui5_get_msg_type( `E` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `Error`
                                        act = z2ui5_cl_ui5_util_context=>ui5_get_msg_type( `A` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `Error`
                                        act = z2ui5_cl_ui5_util_context=>ui5_get_msg_type( `X` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `Success`
                                        act = z2ui5_cl_ui5_util_context=>ui5_get_msg_type( `S` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `Warning`
                                        act = z2ui5_cl_ui5_util_context=>ui5_get_msg_type( `W` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `Information`
                                        act = z2ui5_cl_ui5_util_context=>ui5_get_msg_type( `I` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `Information`
                                        act = z2ui5_cl_ui5_util_context=>ui5_get_msg_type( `Z` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `Information`
                                        act = z2ui5_cl_ui5_util_context=>ui5_get_msg_type( `` ) ).

  ENDMETHOD.

  METHOD test_box_empty_skips.

    " no messages means no popup at all, signalled by `skip`
    DATA lt_msg TYPE z2ui5_cl_ui5_util_context=>ty_t_msg.

    DATA ls_box TYPE z2ui5_cl_ui5_util_context=>ty_s_msg_box.
    ls_box = z2ui5_cl_ui5_util_context=>ui5_msg_box_format( lt_msg ).

    cl_abap_unit_assert=>assert_equals( exp = abap_true act = ls_box-skip ).

  ENDMETHOD.

  METHOD test_box_single.

    " a single message renders as plain text without a details list
    DATA lt_msg TYPE z2ui5_cl_ui5_util_context=>ty_t_msg.

    DATA temp112 TYPE z2ui5_cl_ui5_util_context=>ty_t_msg.
    DATA temp113 LIKE LINE OF temp112.
    DATA ls_box TYPE z2ui5_cl_ui5_util_context=>ty_s_msg_box.
    CLEAR temp112.

    temp113-text = `boom`.
    temp113-type = `E`.
    INSERT temp113 INTO TABLE temp112.
    lt_msg = temp112.


    ls_box = z2ui5_cl_ui5_util_context=>ui5_msg_box_format( lt_msg ).

    cl_abap_unit_assert=>assert_equals( exp = abap_false act = ls_box-skip ).
    cl_abap_unit_assert=>assert_equals( exp = `boom`
                                        act = ls_box-text ).
    cl_abap_unit_assert=>assert_equals( exp = `Error`
                                        act = ls_box-title ).
    cl_abap_unit_assert=>assert_equals( exp = `error`
                                        act = ls_box-type ).
    cl_abap_unit_assert=>assert_initial( ls_box-details ).

  ENDMETHOD.

  METHOD test_box_multiple.

    " several messages collapse into a count plus an HTML list, and the box
    " takes its severity from the most severe message, not the first
    DATA lt_msg TYPE z2ui5_cl_ui5_util_context=>ty_t_msg.

    DATA temp114 TYPE z2ui5_cl_ui5_util_context=>ty_t_msg.
    DATA temp115 LIKE LINE OF temp114.
    DATA ls_box TYPE z2ui5_cl_ui5_util_context=>ty_s_msg_box.
    DATA temp116 TYPE z2ui5_cl_ui5_util_context=>ty_t_msg.
    DATA temp117 LIKE LINE OF temp116.
    CLEAR temp114.

    temp115-text = `first`.
    temp115-type = `W`.
    INSERT temp115 INTO TABLE temp114.
    temp115-text = `second`.
    temp115-type = `E`.
    INSERT temp115 INTO TABLE temp114.
    lt_msg = temp114.


    ls_box = z2ui5_cl_ui5_util_context=>ui5_msg_box_format( lt_msg ).

    cl_abap_unit_assert=>assert_equals( exp = abap_false act = ls_box-skip ).
    cl_abap_unit_assert=>assert_equals( exp = `Error`
                                        act = ls_box-title ).
    cl_abap_unit_assert=>assert_equals( exp = `error`
                                        act = ls_box-type ).
    cl_abap_unit_assert=>assert_equals( exp = `2 Messages found:`
                                        act = ls_box-text ).

    " a warning outranks success and information wherever it stands, and
    " between those two the first one decides

    CLEAR temp116.

    temp117-text = `a`.
    temp117-type = `S`.
    INSERT temp117 INTO TABLE temp116.
    temp117-text = `b`.
    temp117-type = `I`.
    INSERT temp117 INTO TABLE temp116.
    temp117-text = `c`.
    temp117-type = `W`.
    INSERT temp117 INTO TABLE temp116.
    lt_msg = temp116.
    cl_abap_unit_assert=>assert_equals( exp = `warning`
                                        act = z2ui5_cl_ui5_util_context=>ui5_msg_box_format( lt_msg )-type ).
    DELETE lt_msg INDEX 3.
    cl_abap_unit_assert=>assert_equals( exp = `success`
                                        act = z2ui5_cl_ui5_util_context=>ui5_msg_box_format( lt_msg )-type ).
    cl_abap_unit_assert=>assert_equals(
        exp = `<ul><li>first</li><li>second</li></ul>`
        act = ls_box-details ).

  ENDMETHOD.

  METHOD test_box_multiple_escaped.

    " the texts are DATA inside the HTML list: a token in angle brackets is
    " shown as written instead of being dropped by the frontend sanitizer
    " as an unknown element - every sibling renderer escapes, this did not
    DATA lt_msg TYPE z2ui5_cl_ui5_util_context=>ty_t_msg.

    DATA temp118 TYPE z2ui5_cl_ui5_util_context=>ty_t_msg.
    DATA temp119 LIKE LINE OF temp118.
    DATA ls_box TYPE z2ui5_cl_ui5_util_context=>ty_s_msg_box.
    CLEAR temp118.

    temp119-text = `Enter a value for <MATNR>`.
    temp119-type = `E`.
    INSERT temp119 INTO TABLE temp118.
    temp119-text = `a & b`.
    temp119-type = `E`.
    INSERT temp119 INTO TABLE temp118.
    lt_msg = temp118.


    ls_box = z2ui5_cl_ui5_util_context=>ui5_msg_box_format( lt_msg ).

    cl_abap_unit_assert=>assert_equals(
        exp = `<ul><li>Enter a value for &lt;MATNR&gt;</li><li>a &amp; b</li></ul>`
        act = ls_box-details ).

  ENDMETHOD.

  METHOD test_box_exception_object.

    " an exception is its text, an error by default
    DATA lx TYPE REF TO z2ui5_cx_ui5_util_error.
    DATA ls_box TYPE z2ui5_cl_ui5_util_context=>ty_s_msg_box.
    DATA temp5 TYPE xsdboolean.
    TRY.
        RAISE EXCEPTION TYPE z2ui5_cx_ui5_util_error
          EXPORTING
            val = `Posting failed`.
      CATCH z2ui5_cx_ui5_util_error INTO lx ##NO_HANDLER.
    ENDTRY.


    ls_box = z2ui5_cl_ui5_util_context=>ui5_msg_box_format( lx ).

    cl_abap_unit_assert=>assert_equals( exp = abap_false act = ls_box-skip ).
    cl_abap_unit_assert=>assert_equals( exp = `Error`
                                        act = ls_box-title ).

    temp5 = boolc( ls_box-text CS `Posting failed` ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp5 ).

  ENDMETHOD.

  METHOD test_box_plain_object.

    " neither exception nor log: the public attributes that carry a message
    " part are mapped - the fourth shape of msg_get_by_oref
    DATA lo_carrier TYPE REF TO ltcl_msg_carrier.
    DATA ls_box TYPE z2ui5_cl_ui5_util_context=>ty_s_msg_box.
    CREATE OBJECT lo_carrier TYPE ltcl_msg_carrier.


    ls_box = z2ui5_cl_ui5_util_context=>ui5_msg_box_format( lo_carrier ).

    cl_abap_unit_assert=>assert_equals( exp = abap_false act = ls_box-skip ).
    cl_abap_unit_assert=>assert_equals( exp = `Order 4711 saved`
                                        act = ls_box-text ).
    cl_abap_unit_assert=>assert_equals( exp = `Success`
                                        act = ls_box-title ).

  ENDMETHOD.

  METHOD test_box_unbound_oref_skips.

    " an unbound object reference carries no message: `skip`, like a
    " business table - it used to fall through msg_get_by_oref's handlers
    " into a describe on the null reference and end in a 500
    DATA lo_unbound TYPE REF TO object.

    DATA ls_box TYPE z2ui5_cl_ui5_util_context=>ty_s_msg_box.
    ls_box = z2ui5_cl_ui5_util_context=>ui5_msg_box_format( lo_unbound ).

    cl_abap_unit_assert=>assert_equals( exp = abap_true act = ls_box-skip ).

  ENDMETHOD.

  METHOD test_box_no_msg_skips.

    " a business table has none of the message components, so the message
    " formatter answers `skip` - it used to answer with one blank message
    " per row, which is what put an empty popup on the screen. `skip` is
    " what hands the data to ui5_data_box_format( )
    TYPES:
      BEGIN OF ty_s_row,
        carrid TYPE string,
        seats  TYPE i,
      END OF ty_s_row.
    TYPES temp5 TYPE STANDARD TABLE OF ty_s_row WITH DEFAULT KEY.
DATA lt_row TYPE temp5.

    DATA temp120 LIKE lt_row.
    DATA temp121 LIKE LINE OF temp120.
    DATA ls_box TYPE z2ui5_cl_ui5_util_context=>ty_s_msg_box.
    CLEAR temp120.

    temp121-carrid = `LH`.
    temp121-seats = 12.
    INSERT temp121 INTO TABLE temp120.
    lt_row = temp120.


    ls_box = z2ui5_cl_ui5_util_context=>ui5_msg_box_format( lt_row ).

    cl_abap_unit_assert=>assert_equals( exp = abap_true act = ls_box-skip ).

  ENDMETHOD.

  METHOD test_token_by_range.

    " every range option maps to its own token text; the placeholders
    " {LOW}/{HIGH} are substituted from the range row
    DATA lt_range TYPE z2ui5_cl_ui5_util_context=>ty_t_range.

    DATA temp122 TYPE z2ui5_cl_ui5_util_context=>ty_t_range.
    DATA temp123 LIKE LINE OF temp122.
    DATA lt_token TYPE z2ui5_cl_ui5_util_context=>ty_t_token.
    FIELD-SYMBOLS <temp124> LIKE LINE OF lt_token.
    DATA temp125 LIKE sy-tabix.
    FIELD-SYMBOLS <temp126> LIKE LINE OF lt_token.
    DATA temp127 LIKE sy-tabix.
    FIELD-SYMBOLS <temp128> LIKE LINE OF lt_token.
    DATA temp129 LIKE sy-tabix.
    FIELD-SYMBOLS <temp130> LIKE LINE OF lt_token.
    DATA temp131 LIKE sy-tabix.
    FIELD-SYMBOLS <temp132> LIKE LINE OF lt_token.
    DATA temp133 LIKE sy-tabix.
    FIELD-SYMBOLS <temp134> LIKE LINE OF lt_token.
    DATA temp135 LIKE sy-tabix.
    CLEAR temp122.

    CLEAR temp123.
    temp123-sign = `I`.
    temp123-option = `EQ`.
    temp123-low = `X`.
    INSERT temp123 INTO TABLE temp122.
    CLEAR temp123.
    temp123-sign = `I`.
    temp123-option = `BT`.
    temp123-low = `1`.
    temp123-high = `9`.
    INSERT temp123 INTO TABLE temp122.
    CLEAR temp123.
    temp123-sign = `I`.
    temp123-option = `CP`.
    temp123-low = `A`.
    INSERT temp123 INTO TABLE temp122.
    CLEAR temp123.
    temp123-sign = `E`.
    temp123-option = `EQ`.
    temp123-low = `Y`.
    INSERT temp123 INTO TABLE temp122.
    lt_range = temp122.


    lt_token = z2ui5_cl_ui5_util_context=>filter_get_token_t_by_range_t( lt_range ).

    cl_abap_unit_assert=>assert_equals( exp = 4
                                        act = lines( lt_token ) ).


    temp125 = sy-tabix.
    READ TABLE lt_token INDEX 1 ASSIGNING <temp124>.
    sy-tabix = temp125.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `=X`
                                        act = <temp124>-key ).


    temp127 = sy-tabix.
    READ TABLE lt_token INDEX 2 ASSIGNING <temp126>.
    sy-tabix = temp127.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `1...9`
                                        act = <temp126>-key ).


    temp129 = sy-tabix.
    READ TABLE lt_token INDEX 3 ASSIGNING <temp128>.
    sy-tabix = temp129.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `*A*`
                                        act = <temp128>-key ).
    " an excluding row renders negated, not like its including twin


    temp131 = sy-tabix.
    READ TABLE lt_token INDEX 4 ASSIGNING <temp130>.
    sy-tabix = temp131.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `!(=Y)`
                                        act = <temp130>-key ).

    " tokens come back visible and editable so the UI5 MultiInput can render
    " and remove them


    temp133 = sy-tabix.
    READ TABLE lt_token INDEX 1 ASSIGNING <temp132>.
    sy-tabix = temp133.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = <temp132>-visible ).


    temp135 = sy-tabix.
    READ TABLE lt_token INDEX 1 ASSIGNING <temp134>.
    sy-tabix = temp135.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = <temp134>-editable ).

  ENDMETHOD.

  METHOD test_token_numeric_range.

    " a select-option on an integer field: LOW and HIGH read as the numbers
    " they are, sign in front and unpadded - not `=42 ` and `5-...10 `
    TYPES:
      BEGIN OF ty_s_int_range,
        sign   TYPE c LENGTH 1,
        option TYPE c LENGTH 2,
        low    TYPE i,
        high   TYPE i,
      END OF ty_s_int_range.
    TYPES ty_t_int_range TYPE STANDARD TABLE OF ty_s_int_range WITH DEFAULT KEY.

    DATA temp136 TYPE ty_t_int_range.
    DATA temp137 LIKE LINE OF temp136.
    DATA lt_range LIKE temp136.
    DATA lt_token TYPE z2ui5_cl_ui5_util_context=>ty_t_token.
    FIELD-SYMBOLS <temp138> LIKE LINE OF lt_token.
    DATA temp139 LIKE sy-tabix.
    FIELD-SYMBOLS <temp140> LIKE LINE OF lt_token.
    DATA temp141 LIKE sy-tabix.
    CLEAR temp136.

    CLEAR temp137.
    temp137-sign = `I`.
    temp137-option = `EQ`.
    temp137-low = 42.
    INSERT temp137 INTO TABLE temp136.
    CLEAR temp137.
    temp137-sign = `I`.
    temp137-option = `BT`.
    temp137-low = -5.
    temp137-high = 10.
    INSERT temp137 INTO TABLE temp136.

    lt_range = temp136.


    lt_token = z2ui5_cl_ui5_util_context=>filter_get_token_t_by_range_t( lt_range ).



    temp139 = sy-tabix.
    READ TABLE lt_token INDEX 1 ASSIGNING <temp138>.
    sy-tabix = temp139.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `=42`
                                        act = <temp138>-key ).


    temp141 = sy-tabix.
    READ TABLE lt_token INDEX 2 ASSIGNING <temp140>.
    sy-tabix = temp141.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `-5...10`
                                        act = <temp140>-key ).

  ENDMETHOD.

  METHOD test_token_dollar_value.

    " LOW / HIGH are data and go into the token as written - `$&`, `$$` and
    " a backslash before a brace included, and a value that spells the other
    " placeholder is not substituted again
    DATA lt_range TYPE z2ui5_cl_ui5_util_context=>ty_t_range.

    DATA temp142 TYPE z2ui5_cl_ui5_util_context=>ty_t_range.
    DATA temp143 LIKE LINE OF temp142.
    DATA lt_token TYPE z2ui5_cl_ui5_util_context=>ty_t_token.
    FIELD-SYMBOLS <temp144> LIKE LINE OF lt_token.
    DATA temp145 LIKE sy-tabix.
    FIELD-SYMBOLS <temp146> LIKE LINE OF lt_token.
    DATA temp147 LIKE sy-tabix.
    FIELD-SYMBOLS <temp148> LIKE LINE OF lt_token.
    DATA temp149 LIKE sy-tabix.
    CLEAR temp142.

    CLEAR temp143.
    temp143-sign = `I`.
    temp143-option = `EQ`.
    temp143-low = `a$&b`.
    INSERT temp143 INTO TABLE temp142.
    CLEAR temp143.
    temp143-sign = `I`.
    temp143-option = `BT`.
    temp143-low = `$$`.
    temp143-high = `\{x\}`.
    INSERT temp143 INTO TABLE temp142.
    CLEAR temp143.
    temp143-sign = `I`.
    temp143-option = `BT`.
    temp143-low = `{HIGH}`.
    temp143-high = `9`.
    INSERT temp143 INTO TABLE temp142.
    lt_range = temp142.


    lt_token = z2ui5_cl_ui5_util_context=>filter_get_token_t_by_range_t( lt_range ).



    temp145 = sy-tabix.
    READ TABLE lt_token INDEX 1 ASSIGNING <temp144>.
    sy-tabix = temp145.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `=a$&b`
                                        act = <temp144>-key ).


    temp147 = sy-tabix.
    READ TABLE lt_token INDEX 2 ASSIGNING <temp146>.
    sy-tabix = temp147.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `$$...\{x\}`
                                        act = <temp146>-key ).


    temp149 = sy-tabix.
    READ TABLE lt_token INDEX 3 ASSIGNING <temp148>.
    sy-tabix = temp149.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `{HIGH}...9`
                                        act = <temp148>-key ).

  ENDMETHOD.

  METHOD test_token_odd_option.

    " a row without an option (appended with sign and low only), a lower-case
    " option and one the mapping does not know used to raise a raw
    " CX_SY_ITAB_LINE_NOT_FOUND for the whole table; they render as equality
    DATA lt_range TYPE z2ui5_cl_ui5_util_context=>ty_t_range.
    DATA ls_range LIKE LINE OF lt_range.
    DATA lv_option TYPE string.
    DATA lt_token TYPE z2ui5_cl_ui5_util_context=>ty_t_token.
    FIELD-SYMBOLS <temp150> LIKE LINE OF lt_token.
    DATA temp151 LIKE sy-tabix.
    FIELD-SYMBOLS <temp152> LIKE LINE OF lt_token.
    DATA temp153 LIKE sy-tabix.
    FIELD-SYMBOLS <temp154> LIKE LINE OF lt_token.
    DATA temp155 LIKE sy-tabix.

    " filled field by field and through a variable: a VALUE #( ) row with a
    " missing, lower-case or unknown option is exactly what the SAP syntax
    " check warns about for a range structure
    ls_range-sign = `I`.
    ls_range-low  = `X`.
    INSERT ls_range INTO TABLE lt_range.

    lv_option = `eq`.
    ls_range-option = lv_option.
    ls_range-low    = `Y`.
    INSERT ls_range INTO TABLE lt_range.

    lv_option = `ZZ`.
    ls_range-option = lv_option.
    ls_range-low    = `Z`.
    INSERT ls_range INTO TABLE lt_range.


    lt_token = z2ui5_cl_ui5_util_context=>filter_get_token_t_by_range_t( lt_range ).

    cl_abap_unit_assert=>assert_equals( exp = 3
                                        act = lines( lt_token ) ).


    temp151 = sy-tabix.
    READ TABLE lt_token INDEX 1 ASSIGNING <temp150>.
    sy-tabix = temp151.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `=X`
                                        act = <temp150>-key ).


    temp153 = sy-tabix.
    READ TABLE lt_token INDEX 2 ASSIGNING <temp152>.
    sy-tabix = temp153.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `=Y`
                                        act = <temp152>-key ).


    temp155 = sy-tabix.
    READ TABLE lt_token INDEX 3 ASSIGNING <temp154>.
    sy-tabix = temp155.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `=Z`
                                        act = <temp154>-key ).

  ENDMETHOD.

ENDCLASS.


" These methods are PRIVATE - they are internals of box_resolve's path, not
" API - so the test class needs friendship. Neither abaplint's transpiler nor
" the unit runner enforces visibility, which is why npm run check_visibility
" exists and why this pair has to be here rather than discovered on activation.
CLASS ltcl_msg_rap DEFINITION DEFERRED.
CLASS z2ui5_cl_ui5_util_context DEFINITION LOCAL FRIENDS ltcl_msg_rap.

" The RAP/message extraction family (msg_get_rap*, check_is_rap_struct).
"
" AGENTS.md names this class as the engine's real coverage gap - 35% of 3,175
" lines - and this block is the part of it that needs no system at all: it
" walks structures built from locally declared types, so it runs under the
" transpiler like any other test. It is also on a production path every app
" reaches, since client->message_box_display( ) over a BAPIRET2 or RAP result
" comes through z2ui5_cl_ui5_frontend=>box_resolve into exactly these methods.
CLASS ltcl_msg_rap DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_s_tky,
        product_uuid TYPE string,
        product_id   TYPE string,
      END OF ty_s_tky.

    TYPES:
      BEGIN OF ty_s_nested,
        BEGIN OF inner,
          a TYPE string,
          b TYPE string,
        END OF inner,
        c TYPE string,
      END OF ty_s_nested.

    TYPES:
      BEGIN OF ty_s_plain,
        name TYPE string,
        city TYPE string,
      END OF ty_s_plain.

    METHODS test_fail_text_known      FOR TESTING RAISING cx_static_check.
    METHODS test_fail_text_unknown    FOR TESTING RAISING cx_static_check.
    METHODS test_fail_text_all_causes FOR TESTING RAISING cx_static_check.
    METHODS test_flatten_pairs        FOR TESTING RAISING cx_static_check.
    METHODS test_flatten_skips_empty  FOR TESTING RAISING cx_static_check.
    METHODS test_flatten_nested       FOR TESTING RAISING cx_static_check.
    METHODS test_flatten_not_a_struct FOR TESTING RAISING cx_static_check.
    METHODS test_is_rap_struct_plain  FOR TESTING RAISING cx_static_check.
    METHODS test_rap_fail_rows        FOR TESTING RAISING cx_static_check.
    METHODS test_rap_msg_row          FOR TESTING RAISING cx_static_check.
    METHODS test_rap_meta_dashed      FOR TESTING RAISING cx_static_check.
    METHODS test_rap_not_a_struct     FOR TESTING RAISING cx_static_check.
    METHODS test_comp_str             FOR TESTING RAISING cx_static_check.

    " a RAP-shaped `failed` structure built at runtime - component names
    " with % cannot be declared statically. One entity table BOOKINGS whose
    " row carries %FAIL-CAUSE, %PID, %CID and a %TKY key
    METHODS failed_bookings
      IMPORTING
        with_dashed_meta TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(result)    TYPE REF TO data.

    " the value of one meta entry of a message, or nothing
    METHODS meta_of
      IMPORTING
        msg           TYPE z2ui5_cl_ui5_util_context=>ty_s_msg
        n             TYPE string
      RETURNING
        VALUE(result) TYPE string.

ENDCLASS.


CLASS ltcl_msg_rap IMPLEMENTATION.

  METHOD test_fail_text_known.

    " the cause codes are a RAP contract, so the mapping is asserted by value
    cl_abap_unit_assert=>assert_equals( exp = `Entity not found`
                                        act = z2ui5_cl_ui5_util_context=>msg_get_rap_fail_text( 1 ) ).

    cl_abap_unit_assert=>assert_equals( exp = `Authorization failure`
                                        act = z2ui5_cl_ui5_util_context=>msg_get_rap_fail_text( 3 ) ).

    " 4 and 5 deliberately share one text - both are a concurrency conflict
    cl_abap_unit_assert=>assert_equals(
        exp = z2ui5_cl_ui5_util_context=>msg_get_rap_fail_text( 4 )
        act = z2ui5_cl_ui5_util_context=>msg_get_rap_fail_text( 5 ) ).

  ENDMETHOD.

  METHOD test_fail_text_unknown.

    " an unmapped cause still says something useful AND keeps the number, so
    " a code the framework does not know yet can still be looked up
    DATA lv_text TYPE string.
    lv_text = z2ui5_cl_ui5_util_context=>msg_get_rap_fail_text( 99 ).

    cl_abap_unit_assert=>assert_char_cp( exp = `*99*`
                                         act = lv_text ).

    cl_abap_unit_assert=>assert_char_cp( exp = `*Operation failed*`
                                         act = lv_text ).

  ENDMETHOD.

  METHOD test_fail_text_all_causes.

    " every mapped cause renders a non-empty text that is not the fallback -
    " one assert over the whole SWITCH, so a branch dropped by an edit shows
    DATA lv_cause TYPE i.
      DATA lv_text TYPE string.
      DATA temp6 TYPE xsdboolean.
    DO 12 TIMES.
      lv_cause = sy-index - 1.

      lv_text = z2ui5_cl_ui5_util_context=>msg_get_rap_fail_text( lv_cause ).

      cl_abap_unit_assert=>assert_not_initial(
          act = lv_text
          msg = |cause { lv_cause } renders no text| ).


      temp6 = boolc( lv_text CS `cause code` ).
      cl_abap_unit_assert=>assert_equals( exp = abap_false
          act = temp6
          msg = |cause { lv_cause } fell through to the ELSE branch| ).
    ENDDO.

  ENDMETHOD.

  METHOD test_flatten_pairs.

    " the key renders as NAME=VALUE pairs, comma separated - this is what a
    " message ends up quoting to say WHICH entity failed
    DATA temp156 TYPE ty_s_tky.
    DATA ls_tky LIKE temp156.
    CLEAR temp156.
    temp156-product_uuid = `ABC-1`.
    temp156-product_id = `4711`.

    ls_tky = temp156.

    cl_abap_unit_assert=>assert_equals(
        exp = `PRODUCT_UUID=ABC-1, PRODUCT_ID=4711`
        act = z2ui5_cl_ui5_util_context=>msg_get_rap_flatten( ls_tky ) ).

  ENDMETHOD.

  METHOD test_flatten_skips_empty.

    " an initial component contributes nothing - not an empty pair and not a
    " dangling separator
    DATA temp157 TYPE ty_s_tky.
    DATA ls_tky LIKE temp157.
    CLEAR temp157.
    temp157-product_id = `4711`.

    ls_tky = temp157.

    cl_abap_unit_assert=>assert_equals(
        exp = `PRODUCT_ID=4711`
        act = z2ui5_cl_ui5_util_context=>msg_get_rap_flatten( ls_tky ) ).

  ENDMETHOD.

  METHOD test_flatten_nested.

    " a nested structure is flattened by the recursion, and its pairs join the
    " outer ones in component order
    DATA temp158 TYPE ty_s_nested.
    DATA ls_nested LIKE temp158.
    CLEAR temp158.
    CLEAR temp158-inner.
    temp158-inner-a = `1`.
    temp158-inner-b = `2`.
    temp158-c = `3`.

    ls_nested = temp158.

    cl_abap_unit_assert=>assert_equals(
        exp = `A=1, B=2, C=3`
        act = z2ui5_cl_ui5_util_context=>msg_get_rap_flatten( ls_nested ) ).

  ENDMETHOD.

  METHOD test_flatten_not_a_struct.

    " anything that is not a structure returns empty rather than dumping - the
    " method is called on whatever a %TKY-shaped component turns out to hold
    DATA lv_scalar TYPE string.
    lv_scalar = `not a structure`.

    cl_abap_unit_assert=>assert_initial(
        z2ui5_cl_ui5_util_context=>msg_get_rap_flatten( lv_scalar ) ).

  ENDMETHOD.

  METHOD test_is_rap_struct_plain.

    " a structure with no %MSG / %FAIL / %OTHER component and no message table
    " is not RAP-shaped: box_resolve has to fall through to the plain path
    DATA temp159 TYPE ty_s_plain.
    DATA ls_plain LIKE temp159.
    CLEAR temp159.
    temp159-name = `Ada`.
    temp159-city = `London`.

    ls_plain = temp159.

    cl_abap_unit_assert=>assert_equals(
        exp = abap_false
        act = z2ui5_cl_ui5_util_context=>check_is_rap_struct( ls_plain ) ).

  ENDMETHOD.

  METHOD meta_of.

    DATA ls_meta TYPE z2ui5_cl_ui5_util_context=>ty_s_name_value.
    READ TABLE msg-t_meta INTO ls_meta WITH KEY n = n.
    IF sy-subrc = 0.
      result = ls_meta-v.
    ENDIF.

  ENDMETHOD.

  METHOD failed_bookings.

    DATA lo_str   TYPE REF TO cl_abap_elemdescr.
    DATA lo_c1    TYPE REF TO cl_abap_elemdescr.
    DATA lo_key   TYPE REF TO cl_abap_structdescr.
    DATA lo_fail  TYPE REF TO cl_abap_structdescr.
    DATA lo_row   TYPE REF TO cl_abap_structdescr.
    DATA lo_rows  TYPE REF TO cl_abap_tabledescr.
    DATA lo_top   TYPE REF TO cl_abap_structdescr.
    DATA lo_elem  TYPE REF TO cl_abap_structdescr.
    DATA lo_act   TYPE REF TO cl_abap_structdescr.
    DATA lo_op    TYPE REF TO cl_abap_structdescr.
    DATA lt_comp  TYPE cl_abap_structdescr=>component_table.

    FIELD-SYMBOLS <failed> TYPE any.
    FIELD-SYMBOLS <tab>    TYPE ANY TABLE.
    FIELD-SYMBOLS <ftab>   TYPE STANDARD TABLE.
    FIELD-SYMBOLS <row>    TYPE any.
    FIELD-SYMBOLS <comp>   TYPE any.
    DATA temp160 TYPE abap_component_tab.
    DATA temp161 LIKE LINE OF temp160.
    DATA temp162 TYPE abap_component_tab.
    DATA temp163 LIKE LINE OF temp162.
    DATA temp164 TYPE abap_component_tab.
    DATA temp165 LIKE LINE OF temp164.
      DATA temp166 TYPE abap_component_tab.
      DATA temp167 LIKE LINE OF temp166.
      DATA temp168 TYPE abap_component_tab.
      DATA temp169 LIKE LINE OF temp168.
      DATA temp170 TYPE abap_component_tab.
      DATA temp171 LIKE LINE OF temp170.
      DATA temp172 TYPE abap_componentdescr.
      DATA temp173 TYPE abap_componentdescr.
    DATA temp174 TYPE abap_component_tab.
    DATA temp175 LIKE LINE OF temp174.

    lo_str = cl_abap_elemdescr=>get_string( ).
    lo_c1  = cl_abap_elemdescr=>get_c( 1 ).


    CLEAR temp160.

    temp161-name = `PRODUCT_ID`.
    temp161-type = lo_str.
    INSERT temp161 INTO TABLE temp160.
    lo_key  = cl_abap_structdescr=>create( temp160 ).

    CLEAR temp162.

    temp163-name = `CAUSE`.
    temp163-type = cl_abap_elemdescr=>get_i( ).
    INSERT temp163 INTO TABLE temp162.
    lo_fail = cl_abap_structdescr=>create( temp162 ).


    CLEAR temp164.

    temp165-name = `%FAIL`.
    temp165-type = lo_fail.
    INSERT temp165 INTO TABLE temp164.
    temp165-name = `%TKY`.
    temp165-type = lo_key.
    INSERT temp165 INTO TABLE temp164.
    temp165-name = `%PID`.
    temp165-type = lo_str.
    INSERT temp165 INTO TABLE temp164.
    temp165-name = `%CID`.
    temp165-type = lo_str.
    INSERT temp165 INTO TABLE temp164.
    lt_comp = temp164.
    IF with_dashed_meta = abap_true.
      " as RAP declares them: %ELEMENT and %OP-%ACTION are nested structures
      " of flags, %ELEMENT-CUSTOMERID is the path to one of them

      CLEAR temp166.

      temp167-name = `CUSTOMERID`.
      temp167-type = lo_c1.
      INSERT temp167 INTO TABLE temp166.
      lo_elem = cl_abap_structdescr=>create( temp166 ).

      CLEAR temp168.

      temp169-name = `DEDUCTDISCOUNT`.
      temp169-type = lo_c1.
      INSERT temp169 INTO TABLE temp168.
      lo_act  = cl_abap_structdescr=>create( temp168 ).

      CLEAR temp170.

      temp171-name = `%ACTION`.
      temp171-type = lo_act.
      INSERT temp171 INTO TABLE temp170.
      lo_op   = cl_abap_structdescr=>create( temp170 ).

      CLEAR temp172.
      temp172-name = `%ELEMENT`.
      temp172-type = lo_elem.
      INSERT temp172 INTO TABLE lt_comp.

      CLEAR temp173.
      temp173-name = `%OP`.
      temp173-type = lo_op.
      INSERT temp173 INTO TABLE lt_comp.
    ENDIF.
    lo_row  = cl_abap_structdescr=>create( lt_comp ).
    lo_rows = cl_abap_tabledescr=>create( lo_row ).

    CLEAR temp174.

    temp175-name = `BOOKINGS`.
    temp175-type = lo_rows.
    INSERT temp175 INTO TABLE temp174.
    lo_top  = cl_abap_structdescr=>create( temp174 ).

    CREATE DATA result TYPE HANDLE lo_top.
    ASSIGN result->* TO <failed>.
    ASSIGN COMPONENT `BOOKINGS` OF STRUCTURE <failed> TO <tab>.
    cl_abap_unit_assert=>assert_subrc( ).
    ASSIGN <tab> TO <ftab>.
    APPEND INITIAL LINE TO <ftab> ASSIGNING <row>.

    ASSIGN COMPONENT `%FAIL-CAUSE` OF STRUCTURE <row> TO <comp>.
    cl_abap_unit_assert=>assert_subrc( ).
    <comp> = 2.
    ASSIGN COMPONENT `%PID` OF STRUCTURE <row> TO <comp>.
    cl_abap_unit_assert=>assert_subrc( ).
    <comp> = `pid-1`.
    ASSIGN COMPONENT `%CID` OF STRUCTURE <row> TO <comp>.
    cl_abap_unit_assert=>assert_subrc( ).
    <comp> = `cid-1`.
    ASSIGN COMPONENT `%TKY-PRODUCT_ID` OF STRUCTURE <row> TO <comp>.
    cl_abap_unit_assert=>assert_subrc( ).
    <comp> = `4711`.
    IF with_dashed_meta = abap_true.
      ASSIGN COMPONENT `%ELEMENT-CUSTOMERID` OF STRUCTURE <row> TO <comp>.
      cl_abap_unit_assert=>assert_subrc( ).
      <comp> = `X`.
      ASSIGN COMPONENT `%OP-%ACTION-DEDUCTDISCOUNT` OF STRUCTURE <row> TO <comp>.
      cl_abap_unit_assert=>assert_subrc( ).
      <comp> = `X`.
    ENDIF.

  ENDMETHOD.

  METHOD test_rap_fail_rows.

    " the `failed` response of a RAP call: one message per failed row, the
    " cause mapped to its text, the entity named in front, and the row's
    " key and ids carried as meta so the popup can say WHICH booking
    FIELD-SYMBOLS <failed> TYPE any.
    DATA lr_failed TYPE REF TO data.
    DATA lt_msg TYPE z2ui5_cl_ui5_util_context=>ty_t_msg.
    DATA ls_msg LIKE LINE OF lt_msg.
    FIELD-SYMBOLS <temp9> LIKE LINE OF lt_msg.
    DATA temp10 LIKE sy-tabix.
    DATA lt_any TYPE z2ui5_cl_ui5_util_context=>ty_t_msg.
    FIELD-SYMBOLS <temp176> LIKE LINE OF lt_any.
    DATA temp177 LIKE sy-tabix.
    lr_failed = failed_bookings( ).
    ASSIGN lr_failed->* TO <failed>.

    cl_abap_unit_assert=>assert_equals(
        exp = abap_true
        act = z2ui5_cl_ui5_util_context=>check_is_rap_struct( <failed> ) ).


    lt_msg = z2ui5_cl_ui5_util_context=>msg_get_rap( <failed> ).

    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( lt_msg ) ).



    temp10 = sy-tabix.
    READ TABLE lt_msg INDEX 1 ASSIGNING <temp9>.
    sy-tabix = temp10.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    ls_msg = <temp9>.
    cl_abap_unit_assert=>assert_equals( exp = `E`
                                        act = ls_msg-type ).
    cl_abap_unit_assert=>assert_equals( exp = `BOOKINGS: Entity is locked`
                                        act = ls_msg-text ).
    cl_abap_unit_assert=>assert_equals( exp = `pid-1`
                                        act = meta_of( msg = ls_msg n = `pid` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `cid-1`
                                        act = meta_of( msg = ls_msg n = `cid` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `PRODUCT_ID=4711`
                                        act = meta_of( msg = ls_msg n = `tky` ) ).
    " nothing of the dashed kind in this row
    cl_abap_unit_assert=>assert_initial( meta_of( msg = ls_msg
                                                  n   = `element` ) ).
    cl_abap_unit_assert=>assert_initial( meta_of( msg = ls_msg
                                                  n   = `action` ) ).

    " the same rows through the generic door every popup takes

    lt_any = z2ui5_cl_ui5_util_context=>msg_get_t( <failed> ).


    temp177 = sy-tabix.
    READ TABLE lt_any INDEX 1 ASSIGNING <temp176>.
    sy-tabix = temp177.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = ls_msg-text
                                        act = <temp176>-text ).

  ENDMETHOD.

  METHOD test_rap_msg_row.

    " the `reported` response: a row whose %MSG holds the message object -
    " its text is the message, the row's meta travels with it. The reference
    " component is built from cl_abap_refdescr=>create( )
    DATA lo_str  TYPE REF TO cl_abap_elemdescr.
    DATA lo_ref  TYPE REF TO cl_abap_refdescr.
    DATA lo_row  TYPE REF TO cl_abap_structdescr.
    DATA lo_rows TYPE REF TO cl_abap_tabledescr.
    DATA lo_top  TYPE REF TO cl_abap_structdescr.
    DATA lr_data TYPE REF TO data.
    DATA lx      TYPE REF TO cx_root.

    FIELD-SYMBOLS <reported> TYPE any.
    FIELD-SYMBOLS <tab>      TYPE ANY TABLE.
    FIELD-SYMBOLS <ftab>     TYPE STANDARD TABLE.
    FIELD-SYMBOLS <row>      TYPE any.
    FIELD-SYMBOLS <comp>     TYPE any.
    DATA temp178 TYPE REF TO cl_abap_classdescr.
    DATA temp179 TYPE abap_component_tab.
    DATA temp180 LIKE LINE OF temp179.
    DATA temp181 TYPE abap_component_tab.
    DATA temp182 LIKE LINE OF temp181.
    DATA lt_msg TYPE z2ui5_cl_ui5_util_context=>ty_t_msg.
    FIELD-SYMBOLS <temp183> LIKE LINE OF lt_msg.
    DATA temp184 LIKE sy-tabix.
    FIELD-SYMBOLS <temp185> LIKE LINE OF lt_msg.
    DATA temp186 LIKE sy-tabix.

    lo_str = cl_abap_elemdescr=>get_string( ).

    temp178 ?= cl_abap_typedescr=>describe_by_name( `CX_ROOT` ).
    lo_ref = cl_abap_refdescr=>create(
      temp178 ).

    CLEAR temp179.

    temp180-name = `%MSG`.
    temp180-type = lo_ref.
    INSERT temp180 INTO TABLE temp179.
    temp180-name = `%PID`.
    temp180-type = lo_str.
    INSERT temp180 INTO TABLE temp179.
    lo_row  = cl_abap_structdescr=>create( temp179 ).
    lo_rows = cl_abap_tabledescr=>create( lo_row ).

    CLEAR temp181.

    temp182-name = `BOOKINGS`.
    temp182-type = lo_rows.
    INSERT temp182 INTO TABLE temp181.
    lo_top  = cl_abap_structdescr=>create( temp181 ).

    CREATE DATA lr_data TYPE HANDLE lo_top.
    ASSIGN lr_data->* TO <reported>.
    ASSIGN COMPONENT `BOOKINGS` OF STRUCTURE <reported> TO <tab>.
    cl_abap_unit_assert=>assert_subrc( ).
    ASSIGN <tab> TO <ftab>.
    APPEND INITIAL LINE TO <ftab> ASSIGNING <row>.

    TRY.
        RAISE EXCEPTION TYPE z2ui5_cx_ui5_util_error
          EXPORTING
            val = `booking date in the past`.
      CATCH cx_root INTO lx ##NO_HANDLER.
    ENDTRY.
    ASSIGN COMPONENT `%MSG` OF STRUCTURE <row> TO <comp>.
    cl_abap_unit_assert=>assert_subrc( ).
    <comp> ?= lx.
    ASSIGN COMPONENT `%PID` OF STRUCTURE <row> TO <comp>.
    cl_abap_unit_assert=>assert_subrc( ).
    <comp> = `pid-9`.


    lt_msg = z2ui5_cl_ui5_util_context=>msg_get_rap( <reported> ).

    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( lt_msg ) ).


    temp184 = sy-tabix.
    READ TABLE lt_msg INDEX 1 ASSIGNING <temp183>.
    sy-tabix = temp184.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_char_cp( exp = `*booking date in the past*`
                                         act = <temp183>-text ).


    temp186 = sy-tabix.
    READ TABLE lt_msg INDEX 1 ASSIGNING <temp185>.
    sy-tabix = temp186.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `pid-9`
                                        act = meta_of( msg = <temp185> n = `pid` ) ).

  ENDMETHOD.

  METHOD test_rap_meta_dashed.

    " %ELEMENT-<field> and %OP-%ACTION-<name> are flags whose NAME carries
    " the information - the meta names the field and the action. The flags
    " sit in the nested structures %ELEMENT and %OP-%ACTION, as RAP declares
    " them
    FIELD-SYMBOLS <failed> TYPE any.
    DATA lr_failed TYPE REF TO data.
    DATA lt_msg TYPE z2ui5_cl_ui5_util_context=>ty_t_msg.
    FIELD-SYMBOLS <temp187> LIKE LINE OF lt_msg.
    DATA temp188 LIKE sy-tabix.
    FIELD-SYMBOLS <temp189> LIKE LINE OF lt_msg.
    DATA temp190 LIKE sy-tabix.
    lr_failed = failed_bookings( abap_true ).
    ASSIGN lr_failed->* TO <failed>.


    lt_msg = z2ui5_cl_ui5_util_context=>msg_get_rap( <failed> ).

    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( lt_msg ) ).


    temp188 = sy-tabix.
    READ TABLE lt_msg INDEX 1 ASSIGNING <temp187>.
    sy-tabix = temp188.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `CUSTOMERID`
                                        act = meta_of( msg = <temp187> n = `element` ) ).


    temp190 = sy-tabix.
    READ TABLE lt_msg INDEX 1 ASSIGNING <temp189>.
    sy-tabix = temp190.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `DEDUCTDISCOUNT`
                                        act = meta_of( msg = <temp189> n = `action` ) ).

  ENDMETHOD.

  METHOD test_rap_not_a_struct.

    " msg_get_rap on something that is not a structure answers nothing -
    " it is called on whatever box_resolve decided was RAP-shaped
    DATA lv_text TYPE string.
    DATA lt_lines TYPE string_table.
    lv_text = `plain text`.


    cl_abap_unit_assert=>assert_initial( z2ui5_cl_ui5_util_context=>msg_get_rap( lv_text ) ).
    cl_abap_unit_assert=>assert_initial( z2ui5_cl_ui5_util_context=>msg_get_rap( lt_lines ) ).

  ENDMETHOD.

  METHOD test_comp_str.

    " a printable component by name, as text; a missing one or a structure
    " (not printable) answers nothing instead of dumping its bytes
    DATA temp191 TYPE ty_s_nested.
    DATA ls_nested LIKE temp191.
    CLEAR temp191.
    CLEAR temp191-inner.
    temp191-inner-a = `1`.
    temp191-c = `three`.

    ls_nested = temp191.

    cl_abap_unit_assert=>assert_equals( exp = `three`
                                        act = z2ui5_cl_ui5_util_context=>get_comp_str( val = ls_nested
                                                                                      comp = `C` ) ).
    cl_abap_unit_assert=>assert_initial( z2ui5_cl_ui5_util_context=>get_comp_str( val = ls_nested
                                                                                comp  = `INNER` ) ).
    cl_abap_unit_assert=>assert_initial( z2ui5_cl_ui5_util_context=>get_comp_str( val = ls_nested
                                                                                comp  = `NO_SUCH` ) ).

  ENDMETHOD.

ENDCLASS.


" The generic renderer behind client->message_box_display( ): what an app
" throws in that is NOT a message. Every case here reached the box as
" nothing at all before - a blank popup, or no popup.
CLASS ltcl_data_box DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_s_row,
        carrid TYPE string,
        seats  TYPE i,
      END OF ty_s_row.
    TYPES ty_t_row TYPE STANDARD TABLE OF ty_s_row WITH DEFAULT KEY.

    TYPES:
      BEGIN OF ty_s_node,
        name  TYPE string,
        nodes TYPE ty_t_row,
      END OF ty_s_node.

    METHODS test_text_plain      FOR TESTING RAISING cx_static_check.
    METHODS test_text_html       FOR TESTING RAISING cx_static_check.
    METHODS test_number          FOR TESTING RAISING cx_static_check.
    METHODS test_table           FOR TESTING RAISING cx_static_check.
    METHODS test_tree            FOR TESTING RAISING cx_static_check.
    METHODS test_empty_table     FOR TESTING RAISING cx_static_check.
    METHODS test_escapes_markup  FOR TESTING RAISING cx_static_check.
    METHODS test_row_limit       FOR TESTING RAISING cx_static_check.
    METHODS test_object          FOR TESTING RAISING cx_static_check.
    METHODS test_exception       FOR TESTING RAISING cx_static_check.
    METHODS test_data_ref        FOR TESTING RAISING cx_static_check.
    METHODS test_unbound_refs    FOR TESTING RAISING cx_static_check.
    METHODS test_depth_limit     FOR TESTING RAISING cx_static_check.

ENDCLASS.


" an object an app might hand to message_box_display( ) - two public
" attributes, one class attribute and one constant that must not render
CLASS ltcl_data_box_obj DEFINITION FINAL.
  PUBLIC SECTION.
    CONSTANTS cv_kind TYPE string VALUE `constant` ##NEEDED.
    CLASS-DATA gv_shared TYPE string VALUE `class-wide` ##NEEDED.
    DATA mv_name TYPE string VALUE `Ada` ##NEEDED.
    DATA mv_year TYPE i VALUE 1815 ##NEEDED.
  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA mv_hidden TYPE string VALUE `private` ##NEEDED.
ENDCLASS.

CLASS ltcl_data_box_obj IMPLEMENTATION.
ENDCLASS.


CLASS ltcl_data_box IMPLEMENTATION.

  METHOD test_text_plain.

    " a character value is its own text and needs no details
    DATA ls_box TYPE z2ui5_cl_ui5_util_context=>ty_s_msg_box.
    ls_box = z2ui5_cl_ui5_util_context=>ui5_data_box_format( `Hello World` ).

    cl_abap_unit_assert=>assert_equals( exp = abap_false act = ls_box-skip ).
    cl_abap_unit_assert=>assert_equals( exp = `Hello World`
                                        act = ls_box-text ).
    cl_abap_unit_assert=>assert_initial( ls_box-details ).

  ENDMETHOD.

  METHOD test_text_html.

    " markup in the box TEXT would be shown as the tags it is written with,
    " so it moves to the details ( a FormattedText in UI5 ) and the headline
    " becomes the plain text behind it
    DATA ls_box TYPE z2ui5_cl_ui5_util_context=>ty_s_msg_box.
    ls_box = z2ui5_cl_ui5_util_context=>ui5_data_box_format(
                       `<p>Order <strong>4711</strong> booked</p>` ).

    cl_abap_unit_assert=>assert_equals( exp = `Order 4711 booked`
                                        act = ls_box-text ).
    cl_abap_unit_assert=>assert_equals( exp = `<p>Order <strong>4711</strong> booked</p>`
                                        act = ls_box-details ).

  ENDMETHOD.

  METHOD test_number.

    " a number is shown as the number, not as a right-aligned char field
    DATA lv_int TYPE i.
    DATA ls_box TYPE z2ui5_cl_ui5_util_context=>ty_s_msg_box.
    DATA lv_amount TYPE p LENGTH 8 DECIMALS 2 VALUE '-12.50'.

    lv_int = 42.


    ls_box = z2ui5_cl_ui5_util_context=>ui5_data_box_format( lv_int ).

    cl_abap_unit_assert=>assert_equals( exp = abap_false act = ls_box-skip ).
    cl_abap_unit_assert=>assert_equals( exp = `42`
                                        act = ls_box-text ).

    " ... with its sign in front: the assignment wrote `5-` and `12.50-`
    lv_int = -5.
    cl_abap_unit_assert=>assert_equals(
        exp = `-5`
        act = z2ui5_cl_ui5_util_context=>ui5_data_box_format( lv_int )-text ).

    cl_abap_unit_assert=>assert_equals(
        exp = `-12.50`
        act = z2ui5_cl_ui5_util_context=>ui5_data_box_format( lv_amount )-text ).

  ENDMETHOD.

  METHOD test_table.

    " a business table: the headline counts, the details carry every row
    " with its component names
    DATA lt_row TYPE ty_t_row.

    DATA temp192 TYPE ltcl_data_box=>ty_t_row.
    DATA temp193 LIKE LINE OF temp192.
    DATA ls_box TYPE z2ui5_cl_ui5_util_context=>ty_s_msg_box.
    CLEAR temp192.

    temp193-carrid = `LH`.
    temp193-seats = 12.
    INSERT temp193 INTO TABLE temp192.
    lt_row = temp192.


    ls_box = z2ui5_cl_ui5_util_context=>ui5_data_box_format( lt_row ).

    cl_abap_unit_assert=>assert_equals( exp = abap_false act = ls_box-skip ).
    cl_abap_unit_assert=>assert_equals( exp = `Table with 1 entry`
                                        act = ls_box-text ).
    cl_abap_unit_assert=>assert_equals(
        exp = `<ol><li><ul><li><strong>CARRID</strong>: LH</li>` &&
              `<li><strong>SEATS</strong>: 12</li></ul></li></ol>`
        act = ls_box-details ).

  ENDMETHOD.

  METHOD test_tree.

    " a node with children below it - the recursion renders the nested table
    " as a nested list instead of stopping at the first level
    DATA ls_node TYPE ty_s_node.
    DATA temp11 TYPE ltcl_data_box=>ty_t_row.
    DATA temp12 LIKE LINE OF temp11.
    DATA ls_box TYPE z2ui5_cl_ui5_util_context=>ty_s_msg_box.

    CLEAR ls_node.
    ls_node-name = `root`.

    CLEAR temp11.

    temp12-carrid = `LH`.
    temp12-seats = 1.
    INSERT temp12 INTO TABLE temp11.
    ls_node-nodes = temp11.


    ls_box = z2ui5_cl_ui5_util_context=>ui5_data_box_format( ls_node ).

    cl_abap_unit_assert=>assert_equals( exp = `Structure with 2 fields`
                                        act = ls_box-text ).
    cl_abap_unit_assert=>assert_equals(
        exp = `<ul><li><strong>NAME</strong>: root</li>` &&
              `<li><strong>NODES</strong>: <ol><li><ul>` &&
              `<li><strong>CARRID</strong>: LH</li>` &&
              `<li><strong>SEATS</strong>: 1</li>` &&
              `</ul></li></ol></li></ul>`
        act = ls_box-details ).

  ENDMETHOD.

  METHOD test_empty_table.

    " an app that hands over the result of a call it just made expects no
    " popup when the call returned nothing - the same silence an empty
    " message table has always produced
    DATA lt_row TYPE ty_t_row.

    DATA ls_box TYPE z2ui5_cl_ui5_util_context=>ty_s_msg_box.
    ls_box = z2ui5_cl_ui5_util_context=>ui5_data_box_format( lt_row ).

    cl_abap_unit_assert=>assert_equals( exp = abap_true act = ls_box-skip ).

  ENDMETHOD.

  METHOD test_escapes_markup.

    " a value that looks like markup is data, not markup - it must not be
    " able to close the list the renderer is building
    DATA lt_row TYPE ty_t_row.

    DATA temp194 TYPE ltcl_data_box=>ty_t_row.
    DATA temp195 LIKE LINE OF temp194.
    DATA ls_box TYPE z2ui5_cl_ui5_util_context=>ty_s_msg_box.
    CLEAR temp194.

    temp195-carrid = `</ul><script>`.
    INSERT temp195 INTO TABLE temp194.
    lt_row = temp194.


    ls_box = z2ui5_cl_ui5_util_context=>ui5_data_box_format( lt_row ).

    cl_abap_unit_assert=>assert_equals(
        exp = `<ol><li><ul><li><strong>CARRID</strong>: &lt;/ul&gt;&lt;script&gt;</li>` &&
              `<li><strong>SEATS</strong>: 0</li></ul></li></ol>`
        act = ls_box-details ).

  ENDMETHOD.

  METHOD test_row_limit.

    " a dump is a diagnostic, not a report: the box stops after 100 rows and
    " says how many it left out
    DATA lt_row TYPE ty_t_row.
      DATA temp196 TYPE ltcl_data_box=>ty_s_row.
    DATA ls_box TYPE z2ui5_cl_ui5_util_context=>ty_s_msg_box.
    DATA temp7 TYPE xsdboolean.

    DO 105 TIMES.

      CLEAR temp196.
      temp196-seats = sy-index.
      INSERT temp196 INTO TABLE lt_row.
    ENDDO.


    ls_box = z2ui5_cl_ui5_util_context=>ui5_data_box_format( lt_row ).

    cl_abap_unit_assert=>assert_equals( exp = `Table with 105 entries`
                                        act = ls_box-text ).

    temp7 = boolc( ls_box-details CS `... 5 more entries` ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp7 ).

  ENDMETHOD.

  METHOD test_object.

    " an object renders its public instance attributes as a list - the
    " constant, the class attribute and the private one stay out
    DATA lo_obj TYPE REF TO ltcl_data_box_obj.
    DATA ls_box TYPE z2ui5_cl_ui5_util_context=>ty_s_msg_box.
    CREATE OBJECT lo_obj TYPE ltcl_data_box_obj.


    ls_box = z2ui5_cl_ui5_util_context=>ui5_data_box_format( lo_obj ).

    cl_abap_unit_assert=>assert_equals( exp = abap_false act = ls_box-skip ).
    cl_abap_unit_assert=>assert_char_cp( exp = `Object *`
                                         act = ls_box-text ).
    cl_abap_unit_assert=>assert_char_cp( exp = `*<li><strong>MV_NAME</strong>: Ada</li>*`
                                         act = ls_box-details ).
    cl_abap_unit_assert=>assert_char_cp( exp = `*<li><strong>MV_YEAR</strong>: 1815</li>*`
                                         act = ls_box-details ).
    cl_abap_unit_assert=>assert_char_np( exp = `*constant*`
                                         act = ls_box-details ).
    cl_abap_unit_assert=>assert_char_np( exp = `*class-wide*`
                                         act = ls_box-details ).
    cl_abap_unit_assert=>assert_char_np( exp = `*private*`
                                         act = ls_box-details ).

  ENDMETHOD.

  METHOD test_exception.

    " an exception object is its text, escaped - not its attribute dump
    DATA lx TYPE REF TO cx_root.
    DATA ls_box TYPE z2ui5_cl_ui5_util_context=>ty_s_msg_box.
    TRY.
        RAISE EXCEPTION TYPE z2ui5_cx_ui5_util_error
          EXPORTING
            val = `a <b>bold</b> failure`.
      CATCH cx_root INTO lx ##NO_HANDLER.
    ENDTRY.


    ls_box = z2ui5_cl_ui5_util_context=>ui5_data_box_format( lx ).

    cl_abap_unit_assert=>assert_equals( exp = abap_false act = ls_box-skip ).
    cl_abap_unit_assert=>assert_char_cp( exp = `*a &lt;b&gt;bold&lt;/b&gt; failure*`
                                         act = ls_box-details ).
    cl_abap_unit_assert=>assert_char_np( exp = `*<b>bold*`
                                         act = ls_box-details ).

  ENDMETHOD.

  METHOD test_data_ref.

    " a reference to data renders what it points to, as if the value had
    " been passed itself
    DATA lr_row TYPE REF TO ty_s_row.
    DATA ls_box TYPE z2ui5_cl_ui5_util_context=>ty_s_msg_box.
    CREATE DATA lr_row.
    CLEAR lr_row->*.
    lr_row->*-carrid = `LH`.
    lr_row->*-seats = 2.


    ls_box = z2ui5_cl_ui5_util_context=>ui5_data_box_format( lr_row ).

    cl_abap_unit_assert=>assert_equals( exp = abap_false act = ls_box-skip ).
    cl_abap_unit_assert=>assert_equals(
        exp = `<ul><li><strong>CARRID</strong>: LH</li><li><strong>SEATS</strong>: 2</li></ul>`
        act = ls_box-details ).

  ENDMETHOD.

  METHOD test_unbound_refs.

    " an unbound reference of either kind has nothing to show and must not
    " dereference
    DATA lr_row TYPE REF TO ty_s_row.
    DATA lo_obj TYPE REF TO object.

    DATA ls_data TYPE z2ui5_cl_ui5_util_context=>ty_s_msg_box.
    DATA ls_obj TYPE z2ui5_cl_ui5_util_context=>ty_s_msg_box.
    ls_data = z2ui5_cl_ui5_util_context=>ui5_data_box_format( lr_row ).
    cl_abap_unit_assert=>assert_initial( ls_data-details ).


    ls_obj = z2ui5_cl_ui5_util_context=>ui5_data_box_format( lo_obj ).
    cl_abap_unit_assert=>assert_initial( ls_obj-details ).

  ENDMETHOD.

  METHOD test_depth_limit.

    " the recursion stops at cv_data_max_depth with an ellipsis instead of
    " rendering a deep structure to the bottom - a tree six levels deep
    " shows its first levels and `...` where the limit cuts
    DATA lr_six TYPE REF TO ty_s_node.
    DATA temp13 TYPE ty_t_row.
    DATA temp14 LIKE LINE OF temp13.
    DATA lr_outer TYPE REF TO data.
    DATA lr_2 TYPE REF TO data.
    DATA lr_3 TYPE REF TO data.
    DATA lr_4 TYPE REF TO data.
    DATA lr_5 TYPE REF TO data.
    DATA ls_box TYPE z2ui5_cl_ui5_util_context=>ty_s_msg_box.
    CREATE DATA lr_six.
    CLEAR lr_six->*.
    lr_six->*-name = `l1`.

    CLEAR temp13.

    temp14-carrid = `l2`.
    INSERT temp14 INTO TABLE temp13.
    lr_six->*-nodes = temp13.

    " every reference level adds one to the depth - five hops around the
    " structure are enough to pass the limit
    GET REFERENCE OF lr_six INTO lr_outer.

    GET REFERENCE OF lr_outer INTO lr_2.

    GET REFERENCE OF lr_2 INTO lr_3.

    GET REFERENCE OF lr_3 INTO lr_4.

    GET REFERENCE OF lr_4 INTO lr_5.


    ls_box = z2ui5_cl_ui5_util_context=>ui5_data_box_format( lr_5 ).

    cl_abap_unit_assert=>assert_char_cp( exp = `*<em>...</em>*`
                                         act = ls_box-details ).

  ENDMETHOD.

ENDCLASS.


CLASS ltcl_time DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_diff_ms_fraction    FOR TESTING RAISING cx_static_check.
    METHODS test_diff_ms_minute_wrap FOR TESTING RAISING cx_static_check.
    METHODS test_diff_ms_midnight    FOR TESTING RAISING cx_static_check.
    METHODS test_diff_ms_negative    FOR TESTING RAISING cx_static_check.
    METHODS test_diff_ms_initial     FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_time IMPLEMENTATION.

  METHOD test_diff_ms_fraction.

    " below a second - what cl_abap_tstmp=>subtract loses in the transpiled
    " runtime, which answers whole seconds there
    cl_abap_unit_assert=>assert_equals(
        exp = 250
        act = z2ui5_cl_ui5_util_context=>time_diff_milliseconds( time_from = `20261003101500.1000000`
                                                                 time_to   = `20261003101500.3500000` ) ).

  ENDMETHOD.

  METHOD test_diff_ms_minute_wrap.

    " a timestamp is YYYYMMDDhhmmss, not a count - 10:15:59.9 to 10:16:00.1
    " is 200 ms, while the digits differ by 40.2
    cl_abap_unit_assert=>assert_equals(
        exp = 200
        act = z2ui5_cl_ui5_util_context=>time_diff_milliseconds( time_from = `20261003101559.9000000`
                                                                 time_to   = `20261003101600.1000000` ) ).
    cl_abap_unit_assert=>assert_equals(
        exp = 3600000
        act = z2ui5_cl_ui5_util_context=>time_diff_milliseconds( time_from = `20261003095959.0000000`
                                                                 time_to   = `20261003105959.0000000` ) ).

  ENDMETHOD.

  METHOD test_diff_ms_midnight.

    " across midnight and a year end
    cl_abap_unit_assert=>assert_equals(
        exp = 1500
        act = z2ui5_cl_ui5_util_context=>time_diff_milliseconds( time_from = `20261231235959.5000000`
                                                                 time_to   = `20270101000001.0000000` ) ).

  ENDMETHOD.

  METHOD test_diff_ms_negative.

    cl_abap_unit_assert=>assert_equals(
        exp = -1000
        act = z2ui5_cl_ui5_util_context=>time_diff_milliseconds( time_from = `20261003101501.0000000`
                                                                 time_to   = `20261003101500.0000000` ) ).

  ENDMETHOD.

  METHOD test_diff_ms_initial.

    DATA lv_initial TYPE timestampl.

    cl_abap_unit_assert=>assert_equals(
        exp = 0
        act = z2ui5_cl_ui5_util_context=>time_diff_milliseconds( time_from = lv_initial
                                                                 time_to   = `20261003101500.0000000` ) ).

  ENDMETHOD.

ENDCLASS.


" Edge cases of the public helpers apps call: initial and empty input,
" special and non-ASCII characters, signs, and calendar boundaries
CLASS ltcl_edge DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    " a string from its UTF-8 bytes - the source stays 7-bit ASCII
    CLASS-METHODS utf8
      IMPORTING
        hex           TYPE string
      RETURNING
        VALUE(result) TYPE string.

    METHODS test_url_value_with_equals  FOR TESTING RAISING cx_static_check.
    METHODS test_url_empty_input        FOR TESTING RAISING cx_static_check.
    METHODS test_url_name_without_value FOR TESTING RAISING cx_static_check.
    METHODS test_url_create_empty_value FOR TESTING RAISING cx_static_check.
    METHODS test_trim_blank_only        FOR TESTING RAISING cx_static_check.
    METHODS test_trim_case_unicode      FOR TESTING RAISING cx_static_check.
    METHODS test_trim_many_layers       FOR TESTING RAISING cx_static_check.
    METHODS test_utf8_roundtrip         FOR TESTING RAISING cx_static_check.
    METHODS test_utf8_empty             FOR TESTING RAISING cx_static_check.
    METHODS test_base64_roundtrip       FOR TESTING RAISING cx_static_check.
    METHODS test_escape_html_entity     FOR TESTING RAISING cx_static_check.
    METHODS test_struc_pairs_signs      FOR TESTING RAISING cx_static_check.
    METHODS test_class_exists_case      FOR TESTING RAISING cx_static_check.
    " a lower-case name asked FIRST answers like the upper-case one
    METHODS test_class_exists_lower     FOR TESTING RAISING cx_static_check.
    METHODS test_bool_to_json           FOR TESTING RAISING cx_static_check.
    METHODS test_token_excluding_bt     FOR TESTING RAISING cx_static_check.
    METHODS test_uuid_shape             FOR TESTING RAISING cx_static_check.
    METHODS test_subtract_leap_day      FOR TESTING RAISING cx_static_check.
    METHODS test_subtract_year_end      FOR TESTING RAISING cx_static_check.
    METHODS test_diff_ms_leap_day       FOR TESTING RAISING cx_static_check.
    METHODS test_msg_type_case          FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_edge IMPLEMENTATION.

  METHOD utf8.

    DATA lv_xstr TYPE xstring.
    lv_xstr = hex.
    result = z2ui5_cl_ui5_util_context=>conv_get_string_by_xstring( lv_xstr ).

  ENDMETHOD.

  METHOD test_url_value_with_equals.

    " a base64 value ends in `=` - only the FIRST `=` separates name and
    " value, the rest belongs to the value
    cl_abap_unit_assert=>assert_equals(
        exp = `ab==`
        act = z2ui5_cl_ui5_util_context=>url_param_get( val = `token`
                                                        url = `?token=ab==&x=1` ) ).
    cl_abap_unit_assert=>assert_equals(
        exp = `1`
        act = z2ui5_cl_ui5_util_context=>url_param_get( val = `x`
                                                        url = `?token=ab==&x=1` ) ).

  ENDMETHOD.

  METHOD test_url_empty_input.

    cl_abap_unit_assert=>assert_initial( z2ui5_cl_ui5_util_context=>url_param_get_tab( `` ) ).
    cl_abap_unit_assert=>assert_initial( z2ui5_cl_ui5_util_context=>url_param_get_tab( `?` ) ).
    cl_abap_unit_assert=>assert_initial( z2ui5_cl_ui5_util_context=>url_param_get_tab( `?&&` ) ).
    cl_abap_unit_assert=>assert_equals(
        exp = ``
        act = z2ui5_cl_ui5_util_context=>url_param_get( val = `a`
                                                        url = `` ) ).
    " a name that is not there - and the empty name, which matches no
    " parameter either
    cl_abap_unit_assert=>assert_equals(
        exp = ``
        act = z2ui5_cl_ui5_util_context=>url_param_get( val = ``
                                                        url = `?=x&a=1` ) ).

  ENDMETHOD.

  METHOD test_url_name_without_value.

    " `?debug&a=1` - a flag without `=` is a parameter with an empty value,
    " and it does not swallow the one after it
    DATA lt_param TYPE z2ui5_cl_ui5_util_context=>ty_t_name_value.
    FIELD-SYMBOLS <temp197> LIKE LINE OF lt_param.
    DATA temp198 LIKE sy-tabix.
    FIELD-SYMBOLS <temp199> LIKE LINE OF lt_param.
    DATA temp200 LIKE sy-tabix.
    FIELD-SYMBOLS <temp201> LIKE LINE OF lt_param.
    DATA temp202 LIKE sy-tabix.
    lt_param = z2ui5_cl_ui5_util_context=>url_param_get_tab( `?debug&a=1` ).

    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( lt_param ) ).


    temp198 = sy-tabix.
    READ TABLE lt_param INDEX 1 ASSIGNING <temp197>.
    sy-tabix = temp198.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `debug`
                                        act = <temp197>-n ).


    temp200 = sy-tabix.
    READ TABLE lt_param INDEX 1 ASSIGNING <temp199>.
    sy-tabix = temp200.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_initial( <temp199>-v ).


    temp202 = sy-tabix.
    READ TABLE lt_param INDEX 2 ASSIGNING <temp201>.
    sy-tabix = temp202.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `1`
                                        act = <temp201>-v ).

  ENDMETHOD.

  METHOD test_url_create_empty_value.

    " an empty LAST value keeps its `=` - only the separator behind it goes
    DATA lt_params TYPE z2ui5_cl_ui5_util_context=>ty_t_name_value.

    DATA temp203 TYPE z2ui5_cl_ui5_util_context=>ty_t_name_value.
    DATA temp204 LIKE LINE OF temp203.
    CLEAR temp203.

    temp204-n = `a`.
    temp204-v = `1`.
    INSERT temp204 INTO TABLE temp203.
    temp204-n = `b`.
    temp204-v = ``.
    INSERT temp204 INTO TABLE temp203.
    lt_params = temp203.

    cl_abap_unit_assert=>assert_equals(
        exp = `a=1&b=`
        act = z2ui5_cl_ui5_util_context=>url_param_create_url( lt_params ) ).

  ENDMETHOD.

  METHOD test_trim_blank_only.

    DATA lv_val TYPE string.
    lv_val = |  { z2ui5_cl_ui5_util_context=>cv_char_util_horizontal_tab }  |.

    cl_abap_unit_assert=>assert_equals( exp = ``
                                        act = z2ui5_cl_ui5_util_context=>c_trim( lv_val ) ).
    cl_abap_unit_assert=>assert_equals( exp = ``
                                        act = z2ui5_cl_ui5_util_context=>c_trim( `` ) ).
    cl_abap_unit_assert=>assert_equals( exp = ``
                                        act = z2ui5_cl_ui5_util_context=>c_trim_upper( `   ` ) ).

  ENDMETHOD.

  METHOD test_trim_case_unicode.

    " to_upper / to_lower are not ASCII-only
    DATA lv_lower TYPE string.
    DATA lv_upper TYPE string.
    lv_lower = utf8( `C3A4C3B6C3BC` ).

    lv_upper = utf8( `C384C396C39C` ).

    cl_abap_unit_assert=>assert_equals( exp = lv_upper
                                        act = z2ui5_cl_ui5_util_context=>c_trim_upper( | { lv_lower } | ) ).
    cl_abap_unit_assert=>assert_equals( exp = lv_lower
                                        act = z2ui5_cl_ui5_util_context=>c_trim_lower( | { lv_upper } | ) ).

  ENDMETHOD.

  METHOD test_trim_many_layers.

    " spaces and tabs alternating at the edges, more layers than a fixed
    " number of passes - a pasted value is trimmed completely, whatever
    " the padding looks like
    DATA lv_pad TYPE string.
    DO 12 TIMES.
      lv_pad = |{ lv_pad } { z2ui5_cl_ui5_util_context=>cv_char_util_horizontal_tab }|.
    ENDDO.

    cl_abap_unit_assert=>assert_equals( exp = `x`
                                        act = z2ui5_cl_ui5_util_context=>c_trim( |{ lv_pad }x{ lv_pad }| ) ).

  ENDMETHOD.

  METHOD test_utf8_roundtrip.

    " a string beyond Latin-1 - an umlaut, the euro sign - is UTF-8 on the
    " way out and back unchanged
    DATA lv_text TYPE string.
    DATA lv_xstr TYPE xstring.
    lv_text = |a { utf8( `C3A4` ) } { utf8( `E282AC` ) } <&>|.


    lv_xstr = z2ui5_cl_ui5_util_context=>conv_get_xstring_by_string( lv_text ).

    cl_abap_unit_assert=>assert_equals( exp = `6120C3A420E282AC203C263E`
                                        act = |{ lv_xstr }| ).
    cl_abap_unit_assert=>assert_equals( exp = lv_text
                                        act = z2ui5_cl_ui5_util_context=>conv_get_string_by_xstring( lv_xstr ) ).

  ENDMETHOD.

  METHOD test_utf8_empty.

    DATA lv_empty TYPE xstring.

    cl_abap_unit_assert=>assert_initial( z2ui5_cl_ui5_util_context=>conv_get_xstring_by_string( `` ) ).
    cl_abap_unit_assert=>assert_initial( z2ui5_cl_ui5_util_context=>conv_get_string_by_xstring( lv_empty ) ).

  ENDMETHOD.

  METHOD test_base64_roundtrip.

    DATA lv_empty TYPE xstring.

    DATA lv_xstr TYPE xstring.
    DATA lv_b64 TYPE string.
    lv_xstr = z2ui5_cl_ui5_util_context=>conv_get_xstring_by_string( |{ utf8( `C3A4` ) }?| ).

    lv_b64 = z2ui5_cl_ui5_util_context=>conv_encode_x_base64( lv_xstr ).

    cl_abap_unit_assert=>assert_equals( exp = `w6Q/`
                                        act = lv_b64 ).
    cl_abap_unit_assert=>assert_equals( exp = lv_xstr
                                        act = z2ui5_cl_ui5_util_context=>conv_decode_x_base64( lv_b64 ) ).
    cl_abap_unit_assert=>assert_initial( z2ui5_cl_ui5_util_context=>conv_encode_x_base64( lv_empty ) ).

  ENDMETHOD.

  METHOD test_escape_html_entity.
    DATA lv_wide TYPE string.

    " an entity in the input is text and escaped again - the method has no
    " notion of "already escaped", which is what makes it safe to apply once
    cl_abap_unit_assert=>assert_equals( exp = `&amp;amp; &amp;lt;`
                                        act = z2ui5_cl_ui5_util_context=>c_escape_html( `&amp; &lt;` ) ).
    cl_abap_unit_assert=>assert_equals( exp = ``
                                        act = z2ui5_cl_ui5_util_context=>c_escape_html( `` ) ).
    " outside ASCII nothing is markup - an umlaut, the euro sign, an emoji

    lv_wide = utf8( `C3A420E282AC20F09F9880` ).
    cl_abap_unit_assert=>assert_equals( exp = lv_wide
                                        act = z2ui5_cl_ui5_util_context=>c_escape_html( lv_wide ) ).

  ENDMETHOD.

  METHOD test_struc_pairs_signs.

    " a number reads as the number it is - the sign in front, no padding -
    " not the way a MOVE into a string writes it (`5-`, `12.50-`)
    TYPES:
      BEGIN OF ty_s_num,
        count  TYPE i,
        amount TYPE p LENGTH 8 DECIMALS 2,
        label  TYPE c LENGTH 10,
      END OF ty_s_num.

    DATA temp205 TYPE ty_s_num.
    DATA ls_num LIKE temp205.
    DATA lt_pair TYPE z2ui5_cl_ui5_util_context=>ty_t_name_value.
    FIELD-SYMBOLS <temp206> LIKE LINE OF lt_pair.
    DATA temp207 LIKE sy-tabix.
    FIELD-SYMBOLS <temp208> LIKE LINE OF lt_pair.
    DATA temp209 LIKE sy-tabix.
    FIELD-SYMBOLS <temp210> LIKE LINE OF lt_pair.
    DATA temp211 LIKE sy-tabix.
    CLEAR temp205.
    temp205-count = -5.
    temp205-amount = `-12.50`.
    temp205-label = `abc`.

    ls_num = temp205.


    lt_pair = z2ui5_cl_ui5_util_context=>itab_get_by_struc( ls_num ).



    temp207 = sy-tabix.
    READ TABLE lt_pair WITH KEY n = `COUNT` ASSIGNING <temp206>.
    sy-tabix = temp207.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `-5`
                                        act = <temp206>-v ).


    temp209 = sy-tabix.
    READ TABLE lt_pair WITH KEY n = `AMOUNT` ASSIGNING <temp208>.
    sy-tabix = temp209.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `-12.50`
                                        act = <temp208>-v ).


    temp211 = sy-tabix.
    READ TABLE lt_pair WITH KEY n = `LABEL` ASSIGNING <temp210>.
    sy-tabix = temp211.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `abc`
                                        act = <temp210>-v ).

  ENDMETHOD.

  METHOD test_class_exists_lower.

    " the answer is cached under the upper-case name, and RTTI is asked in
    " that spelling too: it used to be asked in the caller's, so a class
    " first asked in lower case could be cached as missing for the whole
    " roll area. The name comes from a typed reference (a namespace rename
    " rewrites it) and is asked here first - no other test asks for it
    DATA lo_class TYPE REF TO z2ui5_cl_ui5_util_http.
    DATA lv_name TYPE string.
    lv_name = z2ui5_cl_ui5_util_context=>rtti_get_ref_type_name( lo_class ).

    cl_abap_unit_assert=>assert_equals( exp = abap_true act = z2ui5_cl_ui5_util_context=>rtti_check_class_exists( to_lower( lv_name ) ) ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = z2ui5_cl_ui5_util_context=>rtti_check_class_exists( lv_name ) ).

  ENDMETHOD.

  METHOD test_class_exists_case.

    " the answer is cached per upper-case name, so the spelling of the FIRST
    " question must not decide the answer to every later one
    DATA li_app TYPE REF TO z2ui5_if_app.
    DATA lv_name TYPE string.
    lv_name = z2ui5_cl_ui5_util_context=>rtti_get_ref_type_name( li_app ).

    cl_abap_unit_assert=>assert_equals( exp = abap_false act = z2ui5_cl_ui5_util_context=>rtti_check_class_exists( `zz_no_such_class_4711` ) ).
    cl_abap_unit_assert=>assert_equals( exp = abap_false act = z2ui5_cl_ui5_util_context=>rtti_check_class_exists( `ZZ_NO_SUCH_CLASS_4711` ) ).
    cl_abap_unit_assert=>assert_equals( exp = abap_false act = z2ui5_cl_ui5_util_context=>rtti_check_class_exists( `` ) ).
    " an interface resolves too - describe_by_name answers for every
    " global type - and the lower-case spelling gets the same answer
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = z2ui5_cl_ui5_util_context=>rtti_check_class_exists( lv_name ) ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = z2ui5_cl_ui5_util_context=>rtti_check_class_exists( to_lower( lv_name ) ) ).

  ENDMETHOD.

  METHOD test_bool_to_json.

    DATA lv_bool TYPE abap_bool.
    DATA lv_char TYPE c LENGTH 1.

    lv_bool = abap_true.
    cl_abap_unit_assert=>assert_equals( exp = `true`
                                        act = z2ui5_cl_ui5_util_context=>boolean_abap_2_json( lv_bool ) ).
    lv_bool = abap_false.
    cl_abap_unit_assert=>assert_equals( exp = `false`
                                        act = z2ui5_cl_ui5_util_context=>boolean_abap_2_json( lv_bool ) ).
    " a flag-sized CHAR that is no boolean type goes through as it is
    lv_char = `X`.
    cl_abap_unit_assert=>assert_equals( exp = `X`
                                        act = z2ui5_cl_ui5_util_context=>boolean_abap_2_json( lv_char ) ).

  ENDMETHOD.

  METHOD test_token_excluding_bt.

    " an excluding interval reads negated, like every excluding row
    DATA lt_range TYPE z2ui5_cl_ui5_util_context=>ty_t_range.
    DATA ls_range TYPE z2ui5_cl_ui5_util_context=>ty_s_range.
    DATA lv_sign TYPE string.
    DATA lv_option TYPE string.
    DATA lt_token TYPE z2ui5_cl_ui5_util_context=>ty_t_token.
    FIELD-SYMBOLS <temp212> LIKE LINE OF lt_token.
    DATA temp213 LIKE sy-tabix.
    DATA temp214 TYPE z2ui5_cl_ui5_util_context=>ty_t_range.

    lv_sign   = `E`.
    lv_option = `BT`.
    ls_range-sign   = lv_sign.
    ls_range-option = lv_option.
    ls_range-low    = `1`.
    ls_range-high   = `5`.
    APPEND ls_range TO lt_range.


    lt_token = z2ui5_cl_ui5_util_context=>filter_get_token_t_by_range_t( lt_range ).



    temp213 = sy-tabix.
    READ TABLE lt_token INDEX 1 ASSIGNING <temp212>.
    sy-tabix = temp213.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `!(1...5)`
                                        act = <temp212>-key ).

    CLEAR temp214.
    cl_abap_unit_assert=>assert_initial( z2ui5_cl_ui5_util_context=>filter_get_token_t_by_range_t( temp214 ) ).

  ENDMETHOD.

  METHOD test_uuid_shape.

    DATA lv_first TYPE string.
    DATA lv_second TYPE string.
    DATA temp8 TYPE xsdboolean.
    lv_first = z2ui5_cl_ui5_util_context=>uuid_get_c32( ).

    lv_second = z2ui5_cl_ui5_util_context=>uuid_get_c32( ).

    cl_abap_unit_assert=>assert_equals( exp = 32
                                        act = strlen( lv_first ) ).

    temp8 = boolc( to_upper( lv_first ) CO `0123456789ABCDEF` ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp8 ).
    cl_abap_unit_assert=>assert_differs( exp = lv_first
                                         act = lv_second ).

  ENDMETHOD.

  METHOD test_subtract_leap_day.

    " back across midnight into the 29th of February of a leap year. Compared
    " in whole seconds: the transpiled runtime's cl_abap_tstmp answers with a
    " stray fraction (20240229235950.0005376) - a runtime artefact, see the
    " packed-precision entry of the abap-check skill, section 4
    DATA lv_time TYPE timestampl.
    DATA lv_second TYPE p LENGTH 8 DECIMALS 0.
    lv_time = `20240301000010.0000000`.

    lv_second = z2ui5_cl_ui5_util_context=>time_subtract_seconds(
                    time    = lv_time
                    seconds = 20 ).

    cl_abap_unit_assert=>assert_equals( exp = `20240229235950`
                                        act = |{ lv_second }| ).

  ENDMETHOD.

  METHOD test_subtract_year_end.

    " one second back across a year end, and a negative count goes forward
    " (in whole seconds, as above)
    DATA lv_time   TYPE timestampl.
    DATA lv_second TYPE p LENGTH 8 DECIMALS 0.
    lv_time = `20250101000000.0000000`.

    lv_second = z2ui5_cl_ui5_util_context=>time_subtract_seconds(
                    time    = lv_time
                    seconds = 1 ).
    cl_abap_unit_assert=>assert_equals( exp = `20241231235959`
                                        act = |{ lv_second }| ).

    lv_time = `20241231235959.0000000`.
    lv_second = z2ui5_cl_ui5_util_context=>time_subtract_seconds(
                    time    = lv_time
                    seconds = -1 ).
    cl_abap_unit_assert=>assert_equals( exp = `20250101000000`
                                        act = |{ lv_second }| ).

  ENDMETHOD.

  METHOD test_diff_ms_leap_day.

    " the 29th of February counts in a leap year and does not exist in any
    " other - a day is 86 400 000 ms either way
    cl_abap_unit_assert=>assert_equals(
        exp = 2 * 86400000
        act = z2ui5_cl_ui5_util_context=>time_diff_milliseconds( time_from = `20240228120000.0000000`
                                                                 time_to   = `20240301120000.0000000` ) ).
    cl_abap_unit_assert=>assert_equals(
        exp = 86400000
        act = z2ui5_cl_ui5_util_context=>time_diff_milliseconds( time_from = `20250228120000.0000000`
                                                                 time_to   = `20250301120000.0000000` ) ).

  ENDMETHOD.

  METHOD test_msg_type_case.

    " a message type is one upper-case letter; anything else, a lower-case
    " letter included, is no SAP type and renders as Information
    cl_abap_unit_assert=>assert_equals( exp = `Information`
                                        act = z2ui5_cl_ui5_util_context=>ui5_get_msg_type( `e` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `Information`
                                        act = z2ui5_cl_ui5_util_context=>ui5_get_msg_type( `Error` ) ).

  ENDMETHOD.

ENDCLASS.


" an object with one public attribute, for rtti_get_t_attri_by_oref
CLASS ltcl_attri_probe DEFINITION FINAL FOR TESTING.
  PUBLIC SECTION.
    DATA mv_text TYPE string ##NEEDED.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS ltcl_attri_probe IMPLEMENTATION.
ENDCLASS.


" the public methods the framework calls that had no test of their own -
" each was only covered through the core class that calls it
CLASS ltcl_coverage DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_s_flat,
        text TYPE string,
        date TYPE d,
        time TYPE t,
        flag TYPE abap_bool,
        num  TYPE i,
      END OF ty_s_flat.
    TYPES ty_t_flat TYPE STANDARD TABLE OF ty_s_flat WITH DEFAULT KEY.
    TYPES ty_t_sorted TYPE SORTED TABLE OF ty_s_flat WITH UNIQUE KEY text.
    TYPES:
      BEGIN OF ty_s_nested,
        id   TYPE string,
        flat TYPE ty_s_flat,
      END OF ty_s_nested.
    TYPES BEGIN OF ty_s_incl.
    TYPES name TYPE string.
    TYPES END OF ty_s_incl.
    TYPES BEGIN OF ty_s_with_incl.
    INCLUDE TYPE ty_s_incl.
    TYPES zip TYPE string.
    TYPES END OF ty_s_with_incl.

    METHODS test_check_table_standard FOR TESTING RAISING cx_static_check.
    METHODS test_typedescr_by_data    FOR TESTING RAISING cx_static_check.
    METHODS test_flat_components      FOR TESTING RAISING cx_static_check.
    METHODS test_flat_components_none FOR TESTING RAISING cx_static_check.
    METHODS test_attri_by_include     FOR TESTING RAISING cx_static_check.
    METHODS test_expand_components    FOR TESTING RAISING cx_static_check.
    METHODS test_unassign_initial     FOR TESTING RAISING cx_static_check.
    METHODS test_unassign_object      FOR TESTING RAISING cx_static_check.
    METHODS test_unassign_data        FOR TESTING RAISING cx_static_check.
    METHODS test_as_data_ref          FOR TESTING RAISING cx_static_check.
    METHODS test_timestampl           FOR TESTING RAISING cx_static_check.
    METHODS test_attri_by_oref        FOR TESTING RAISING cx_static_check.
    METHODS test_check_abap_cloud     FOR TESTING RAISING cx_static_check.
    METHODS test_classes_impl_intf    FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_coverage IMPLEMENTATION.

  METHOD test_check_table_standard.

    DATA lt_std TYPE ty_t_flat.
    DATA lt_sorted TYPE ty_t_sorted.
    DATA ls_flat TYPE ty_s_flat.

    DATA temp215 LIKE REF TO lt_std.
    DATA temp216 LIKE REF TO lt_sorted.
    DATA temp217 LIKE REF TO ls_flat.
    GET REFERENCE OF lt_std INTO temp215.
cl_abap_unit_assert=>assert_equals( exp = abap_true act = z2ui5_cl_ui5_util_context=>rtti_check_table_standard( temp215 ) ).

    GET REFERENCE OF lt_sorted INTO temp216.
cl_abap_unit_assert=>assert_equals( exp = abap_false act = z2ui5_cl_ui5_util_context=>rtti_check_table_standard( temp216 ) ).

    GET REFERENCE OF ls_flat INTO temp217.
cl_abap_unit_assert=>assert_equals( exp = abap_false act = z2ui5_cl_ui5_util_context=>rtti_check_table_standard( temp217 ) ).

  ENDMETHOD.

  METHOD test_typedescr_by_data.

    DATA ls_flat TYPE ty_s_flat.
    DATA lt_flat TYPE ty_t_flat.

    cl_abap_unit_assert=>assert_equals( exp = cl_abap_typedescr=>kind_struct
                                        act = z2ui5_cl_ui5_util_context=>rtti_get_typedescr_by_data( ls_flat )->kind ).
    cl_abap_unit_assert=>assert_equals( exp = cl_abap_typedescr=>kind_table
                                        act = z2ui5_cl_ui5_util_context=>rtti_get_typedescr_by_data( lt_flat )->kind ).

  ENDMETHOD.

  METHOD test_flat_components.

    DATA lt_flat TYPE ty_t_flat.

    " the line of a standard table, every component with its json_kind
    DATA temp218 LIKE REF TO lt_flat.
DATA lt_comp TYPE z2ui5_cl_ui5_util_context=>ty_t_flat_comp.
    FIELD-SYMBOLS <temp219> LIKE LINE OF lt_comp.
    DATA temp220 LIKE sy-tabix.
    FIELD-SYMBOLS <temp221> LIKE LINE OF lt_comp.
    DATA temp222 LIKE sy-tabix.
    FIELD-SYMBOLS <temp223> LIKE LINE OF lt_comp.
    DATA temp224 LIKE sy-tabix.
    FIELD-SYMBOLS <temp225> LIKE LINE OF lt_comp.
    DATA temp226 LIKE sy-tabix.
    FIELD-SYMBOLS <temp227> LIKE LINE OF lt_comp.
    DATA temp228 LIKE sy-tabix.
    FIELD-SYMBOLS <temp229> LIKE LINE OF lt_comp.
    DATA temp230 LIKE sy-tabix.
    GET REFERENCE OF lt_flat INTO temp218.

lt_comp = z2ui5_cl_ui5_util_context=>rtti_get_flat_components( temp218 ).

    cl_abap_unit_assert=>assert_equals( exp = 5
                                        act = lines( lt_comp ) ).


    temp220 = sy-tabix.
    READ TABLE lt_comp INDEX 1 ASSIGNING <temp219>.
    sy-tabix = temp220.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `TEXT`
                                        act = <temp219>-name ).


    temp222 = sy-tabix.
    READ TABLE lt_comp INDEX 1 ASSIGNING <temp221>.
    sy-tabix = temp222.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `S`
                                        act = <temp221>-json_kind ).


    temp224 = sy-tabix.
    READ TABLE lt_comp INDEX 2 ASSIGNING <temp223>.
    sy-tabix = temp224.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `D`
                                        act = <temp223>-json_kind ).


    temp226 = sy-tabix.
    READ TABLE lt_comp INDEX 3 ASSIGNING <temp225>.
    sy-tabix = temp226.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `T`
                                        act = <temp225>-json_kind ).


    temp228 = sy-tabix.
    READ TABLE lt_comp INDEX 4 ASSIGNING <temp227>.
    sy-tabix = temp228.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `B`
                                        act = <temp227>-json_kind ).


    temp230 = sy-tabix.
    READ TABLE lt_comp INDEX 5 ASSIGNING <temp229>.
    sy-tabix = temp230.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `N`
                                        act = <temp229>-json_kind ).

  ENDMETHOD.

  METHOD test_flat_components_none.

    DATA lt_sorted TYPE ty_t_sorted.
    DATA ls_nested TYPE ty_s_nested.
    DATA lv_text TYPE string.

    " a sorted table, a nested structure, a scalar: none is flat. (A
    " structure with an include is refused too on a system - the transpiled
    " runtime hands its components out already expanded, so it is not
    " asserted here)
    DATA temp231 LIKE REF TO lt_sorted.
    DATA temp232 LIKE REF TO ls_nested.
    DATA temp233 LIKE REF TO lv_text.
    GET REFERENCE OF lt_sorted INTO temp231.
cl_abap_unit_assert=>assert_initial( z2ui5_cl_ui5_util_context=>rtti_get_flat_components( temp231 ) ).

    GET REFERENCE OF ls_nested INTO temp232.
cl_abap_unit_assert=>assert_initial( z2ui5_cl_ui5_util_context=>rtti_get_flat_components( temp232 ) ).

    GET REFERENCE OF lv_text INTO temp233.
cl_abap_unit_assert=>assert_initial( z2ui5_cl_ui5_util_context=>rtti_get_flat_components( temp233 ) ).

  ENDMETHOD.

  METHOD test_attri_by_include.

    DATA ls_with_incl TYPE ty_s_with_incl.
    DATA lv_text TYPE string.

    DATA temp234 TYPE REF TO cl_abap_datadescr.
    DATA lt_comp TYPE abap_component_tab.
    FIELD-SYMBOLS <temp235> LIKE LINE OF lt_comp.
    DATA temp236 LIKE sy-tabix.
    FIELD-SYMBOLS <temp237> LIKE LINE OF lt_comp.
    DATA temp238 LIKE sy-tabix.
        DATA temp239 TYPE REF TO cl_abap_datadescr.
    temp234 ?= cl_abap_typedescr=>describe_by_data( ls_with_incl ).

    lt_comp = z2ui5_cl_ui5_util_context=>rtti_get_t_attri_by_include(
        temp234 ).
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( lt_comp ) ).


    temp236 = sy-tabix.
    READ TABLE lt_comp INDEX 1 ASSIGNING <temp235>.
    sy-tabix = temp236.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `NAME`
                                        act = <temp235>-name ).


    temp238 = sy-tabix.
    READ TABLE lt_comp INDEX 2 ASSIGNING <temp237>.
    sy-tabix = temp238.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `ZIP`
                                        act = <temp237>-name ).

    " no structure: the error names it, it is no dump
    TRY.

        temp239 ?= cl_abap_typedescr=>describe_by_data( lv_text ).
        z2ui5_cl_ui5_util_context=>rtti_get_t_attri_by_include(
            temp239 ).
        cl_abap_unit_assert=>fail( `a non-structure include must raise` ).
      CATCH z2ui5_cx_ui5_util_error ##NO_HANDLER.
    ENDTRY.

  ENDMETHOD.

  METHOD test_expand_components.

    DATA ls_with_incl TYPE ty_s_with_incl.

    DATA temp240 TYPE REF TO cl_abap_structdescr.
    DATA lt_raw TYPE abap_component_tab.
    DATA lt_comp TYPE abap_component_tab.
    temp240 ?= cl_abap_typedescr=>describe_by_data( ls_with_incl ).

    lt_raw = temp240->get_components( ).

    lt_comp = z2ui5_cl_ui5_util_context=>expand_components( lt_raw ).

    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( lt_comp ) ).
    READ TABLE lt_comp WITH KEY as_include = abap_true TRANSPORTING NO FIELDS. "#EC CI_SORTSEQ
    cl_abap_unit_assert=>assert_subrc( exp = 4 ).

    " the recursion guard: past 16 levels the expansion refuses
    TRY.
        z2ui5_cl_ui5_util_context=>expand_components( val   = lt_raw
                                                      depth = 17 ).
        cl_abap_unit_assert=>fail( `the depth guard must raise` ).
      CATCH z2ui5_cx_ui5_util_error ##NO_HANDLER.
    ENDTRY.

  ENDMETHOD.

  METHOD test_unassign_initial.

    DATA lv_empty TYPE string.
    DATA lv_full TYPE string VALUE `x`.
    DATA lr_none TYPE REF TO data.
    DATA temp241 LIKE REF TO lv_empty.
    DATA temp242 LIKE REF TO lv_full.

    cl_abap_unit_assert=>assert_equals( exp = abap_true act = z2ui5_cl_ui5_util_context=>check_unassign_initial( lr_none ) ).

    GET REFERENCE OF lv_empty INTO temp241.
cl_abap_unit_assert=>assert_equals( exp = abap_true act = z2ui5_cl_ui5_util_context=>check_unassign_initial( temp241 ) ).

    GET REFERENCE OF lv_full INTO temp242.
cl_abap_unit_assert=>assert_equals( exp = abap_false act = z2ui5_cl_ui5_util_context=>check_unassign_initial( temp242 ) ).

  ENDMETHOD.

  METHOD test_unassign_object.

    DATA lo_probe TYPE REF TO ltcl_attri_probe.
    DATA lr_oref TYPE REF TO data.
    DATA lo_back TYPE REF TO object.
    DATA temp9 TYPE xsdboolean.
    CREATE OBJECT lo_probe.

    GET REFERENCE OF lo_probe INTO lr_oref.


    lo_back = z2ui5_cl_ui5_util_context=>unassign_object( lr_oref ).

    cl_abap_unit_assert=>assert_bound( lo_back ).

    temp9 = boolc( lo_back = lo_probe ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp9 ).

  ENDMETHOD.

  METHOD test_unassign_data.

    DATA lv_text TYPE string VALUE `x`.
    DATA lr_text TYPE REF TO data.
    DATA lr_outer TYPE REF TO data.
    DATA lr_back TYPE REF TO data.
    DATA temp10 TYPE xsdboolean.
    GET REFERENCE OF lv_text INTO lr_text.

    GET REFERENCE OF lr_text INTO lr_outer.


    lr_back = z2ui5_cl_ui5_util_context=>unassign_data( lr_outer ).


    temp10 = boolc( lr_back = lr_text ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp10 ).

  ENDMETHOD.

  METHOD test_as_data_ref.

    DATA lv_text TYPE string VALUE `x`.

    DATA lr_ref TYPE REF TO data.
    FIELD-SYMBOLS <val> TYPE data.
    lr_ref = z2ui5_cl_ui5_util_context=>conv_get_as_data_ref( lv_text ).

    cl_abap_unit_assert=>assert_bound( lr_ref ).

    ASSIGN lr_ref->* TO <val>.
    cl_abap_unit_assert=>assert_equals( exp = `x`
                                        act = <val> ).

  ENDMETHOD.

  METHOD test_timestampl.

    DATA lv_first TYPE timestampl.
    DATA lv_second TYPE timestampl.
    DATA temp11 TYPE xsdboolean.
    lv_first = z2ui5_cl_ui5_util_context=>time_get_timestampl( ).

    lv_second = z2ui5_cl_ui5_util_context=>time_get_timestampl( ).

    cl_abap_unit_assert=>assert_not_initial( lv_first ).

    temp11 = boolc( lv_second >= lv_first ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp11 ).

  ENDMETHOD.

  METHOD test_attri_by_oref.

    DATA lo_probe TYPE REF TO ltcl_attri_probe.
    DATA lt_attri TYPE abap_attrdescr_tab.
    CREATE OBJECT lo_probe.


    lt_attri = z2ui5_cl_ui5_util_context=>rtti_get_t_attri_by_oref( lo_probe ).

    READ TABLE lt_attri WITH KEY name = `MV_TEXT` TRANSPORTING NO FIELDS. "#EC CI_SORTSEQ
    cl_abap_unit_assert=>assert_subrc( exp = 0 ).

  ENDMETHOD.

  METHOD test_check_abap_cloud.

    " the answer is latched - the second call gives the first one's answer
    DATA lv_first TYPE abap_bool.
    lv_first = z2ui5_cl_ui5_util_context=>check_abap_cloud( ).

    cl_abap_unit_assert=>assert_equals( exp = lv_first
                                        act = z2ui5_cl_ui5_util_context=>check_abap_cloud( ) ).

  ENDMETHOD.

  METHOD test_classes_impl_intf.

    " the repository lookup is the environment's - where it answers, the
    " shipped exit class is among the implementations of the exit
    " interface, and every row names a class
    DATA lt_classes TYPE z2ui5_cl_ui5_util_context=>ty_t_classes.
    TRY.
        lt_classes = z2ui5_cl_ui5_util_context=>rtti_get_classes_impl_intf( `Z2UI5_IF_UI5_EXIT` ).
      CATCH cx_root.
        RETURN.
    ENDTRY.
    IF lt_classes IS INITIAL.
      RETURN.
    ENDIF.

    READ TABLE lt_classes WITH KEY classname = `Z2UI5_CL_UI5_USER_EXIT` TRANSPORTING NO FIELDS. "#EC CI_SORTSEQ
    cl_abap_unit_assert=>assert_subrc( exp = 0 ).
    READ TABLE lt_classes WITH KEY classname = `` TRANSPORTING NO FIELDS. "#EC CI_SORTSEQ
    cl_abap_unit_assert=>assert_subrc( exp = 4 ).

  ENDMETHOD.

ENDCLASS.
