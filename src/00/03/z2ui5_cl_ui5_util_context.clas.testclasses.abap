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

    cl_abap_unit_assert=>assert_true(
        z2ui5_cl_ui5_util_context=>rtti_check_class_impl_intf( class = `Z2UI5_CL_UI5_APP_HI_WORLD`
                                                               intf  = `Z2UI5_IF_APP` ) ).

  ENDMETHOD.

  METHOD test_impl_intf_lower_case.

    " the interface name is normalised the way a class name is
    cl_abap_unit_assert=>assert_true(
        z2ui5_cl_ui5_util_context=>rtti_check_class_impl_intf( class = `Z2UI5_CL_UI5_APP_HI_WORLD`
                                                               intf  = `z2ui5_if_app` ) ).

  ENDMETHOD.

  METHOD test_impl_intf_no_app.

    " exists, is a class, implements something else entirely
    cl_abap_unit_assert=>assert_false(
        z2ui5_cl_ui5_util_context=>rtti_check_class_impl_intf( class = `Z2UI5_CL_UI5_UTIL_CONTEXT`
                                                               intf  = `Z2UI5_IF_APP` ) ).

  ENDMETHOD.

  METHOD test_impl_intf_no_class.

    cl_abap_unit_assert=>assert_false(
        z2ui5_cl_ui5_util_context=>rtti_check_class_impl_intf( class = `ZCL_THIS_CLASS_DOES_NOT_EXIST`
                                                               intf  = `Z2UI5_IF_APP` ) ).

  ENDMETHOD.

  METHOD test_impl_intf_interface.

    " an interface is not a class - it cannot be created, so it is no app
    cl_abap_unit_assert=>assert_false(
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
    cl_abap_unit_assert=>assert_true(
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
        cl_abap_unit_assert=>assert_true( temp1 ).
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

    cl_abap_unit_assert=>assert_true( z2ui5_cl_ui5_util_context=>boolean_check_by_data( abap_true ) ).
    cl_abap_unit_assert=>assert_true( z2ui5_cl_ui5_util_context=>boolean_check_by_data( abap_false ) ).
    cl_abap_unit_assert=>assert_false( z2ui5_cl_ui5_util_context=>boolean_check_by_data( lv_char ) ).
    cl_abap_unit_assert=>assert_false( z2ui5_cl_ui5_util_context=>boolean_check_by_data( `X` ) ).
    cl_abap_unit_assert=>assert_false( z2ui5_cl_ui5_util_context=>boolean_check_by_data( lv_int ) ).

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
    cl_abap_unit_assert=>assert_false( z2ui5_cl_ui5_util_context=>rtti_check_ref_data( lo_obj ) ).



    GET REFERENCE OF lv_text INTO lr_text.
    cl_abap_unit_assert=>assert_true( z2ui5_cl_ui5_util_context=>rtti_check_ref_data( lr_text ) ).


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
    METHODS test_data_uri          FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_string IMPLEMENTATION.

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
    cl_abap_unit_assert=>assert_true( z2ui5_cl_ui5_util_context=>boolean_check_by_name( `ABAP_BOOL` ) ).
    cl_abap_unit_assert=>assert_true( z2ui5_cl_ui5_util_context=>boolean_check_by_name( `XFELD` ) ).
    cl_abap_unit_assert=>assert_true( z2ui5_cl_ui5_util_context=>boolean_check_by_name( `BOOLE_D` ) ).

    cl_abap_unit_assert=>assert_false( z2ui5_cl_ui5_util_context=>boolean_check_by_name( `abap_bool` ) ).
    cl_abap_unit_assert=>assert_false( z2ui5_cl_ui5_util_context=>boolean_check_by_name( `STRING` ) ).
    cl_abap_unit_assert=>assert_false( z2ui5_cl_ui5_util_context=>boolean_check_by_name( `` ) ).

  ENDMETHOD.

  METHOD test_url_create.

    DATA lt_params TYPE z2ui5_cl_ui5_util_context=>ty_t_name_value.

    DATA temp23 TYPE z2ui5_cl_ui5_util_context=>ty_t_name_value.
    DATA temp24 LIKE LINE OF temp23.
    CLEAR temp23.

    temp24-n = `a`.
    temp24-v = `1`.
    INSERT temp24 INTO TABLE temp23.
    temp24-n = `b`.
    temp24-v = `2`.
    INSERT temp24 INTO TABLE temp23.
    lt_params = temp23.

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
    METHODS test_hash_string      FOR TESTING RAISING cx_static_check.
    METHODS test_hash_fallback    FOR TESTING RAISING cx_static_check.
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

  METHOD test_hash_string.

    " the one promise: equal texts give equal answers, different texts
    " different ones - on every runtime. Where cl_abap_message_digest
    " exists (a system, and open-abap-core under npm run unit) the answer
    " is the SHA-256 of the characters; where it does not, the text itself,
    " and the comparison holds as before
    DATA lv_abc TYPE string.
    DATA lv_again TYPE string.
    DATA lv_other TYPE string.
    DATA lv_empty TYPE string.
    lv_abc   = z2ui5_cl_ui5_util_context=>hash_string( `abc` ).

    lv_again = z2ui5_cl_ui5_util_context=>hash_string( `abc` ).

    lv_other = z2ui5_cl_ui5_util_context=>hash_string( `abd` ).

    lv_empty = z2ui5_cl_ui5_util_context=>hash_string( `` ).

    cl_abap_unit_assert=>assert_equals( exp = lv_abc
                                        act = lv_again ).
    cl_abap_unit_assert=>assert_differs( exp = lv_abc
                                         act = lv_other ).
    cl_abap_unit_assert=>assert_differs( exp = lv_abc
                                         act = lv_empty ).

    IF z2ui5_cl_ui5_util_context=>rtti_check_class_exists( `CL_ABAP_MESSAGE_DIGEST` ) = abap_true.
      cl_abap_unit_assert=>assert_equals( exp = `BA7816BF8F01CFEA414140DE5DAE2223B00361A396177A9CB410FF61F20015AD`
                                          act = to_upper( lv_abc ) ).
      cl_abap_unit_assert=>assert_equals( exp = 64
                                          act = strlen( lv_empty ) ).
    ELSE.
      cl_abap_unit_assert=>assert_equals( exp = `abc`
                                          act = lv_abc ).
      cl_abap_unit_assert=>assert_initial( lv_empty ).
    ENDIF.

  ENDMETHOD.

  METHOD test_hash_fallback.

    " the fallback branch on every runtime: a digest class that does not
    " exist answers nothing, and hash_string( ) then answers the text
    " itself (asserted above where the runtime has no digest class)
    DATA lv_long TYPE string.
    lv_long = repeat( val = `{"ROW":"value"}`
                            occ = 1000 ).
    " (a class that exists without the method is the same CATCH on a system
    " - CX_SY_DYN_CALL_ILLEGAL_METHOD - and a JS TypeError no CATCH sees in
    " the transpiled runtime, so it is not asserted here)
    cl_abap_unit_assert=>assert_initial( z2ui5_cl_ui5_util_context=>hash_string_by_class(
                                             val       = lv_long
                                             classname = `ZZ_NO_SUCH_DIGEST_CLASS` ) ).

  ENDMETHOD.

  METHOD test_attri_include.

    " the include is expanded into its own components, in place, and the
    " components after it follow - rtti_get_t_attri_by_include used to
    " re-describe the include by its absolute name, which a local type
    " like this one need not resolve; the descriptor the component carries
    " is the include's own
    DATA ls_with_incl TYPE ty_s_with_incl.

    DATA lt_comp TYPE abap_component_tab.
    FIELD-SYMBOLS <temp25> LIKE LINE OF lt_comp.
    DATA temp26 LIKE sy-tabix.
    FIELD-SYMBOLS <temp27> LIKE LINE OF lt_comp.
    DATA temp28 LIKE sy-tabix.
    FIELD-SYMBOLS <temp29> LIKE LINE OF lt_comp.
    DATA temp30 LIKE sy-tabix.
    lt_comp = z2ui5_cl_ui5_util_context=>rtti_get_t_attri_by_any( ls_with_incl ).

    cl_abap_unit_assert=>assert_equals( exp = 3
                                        act = lines( lt_comp ) ).


    temp26 = sy-tabix.
    READ TABLE lt_comp INDEX 1 ASSIGNING <temp25>.
    sy-tabix = temp26.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `NAME`
                                        act = <temp25>-name ).


    temp28 = sy-tabix.
    READ TABLE lt_comp INDEX 2 ASSIGNING <temp27>.
    sy-tabix = temp28.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `CITY`
                                        act = <temp27>-name ).


    temp30 = sy-tabix.
    READ TABLE lt_comp INDEX 3 ASSIGNING <temp29>.
    sy-tabix = temp30.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `ZIP`
                                        act = <temp29>-name ).
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
    FIELD-SYMBOLS <temp31> LIKE LINE OF lt_comp.
    DATA temp32 LIKE sy-tabix.
    FIELD-SYMBOLS <temp33> LIKE LINE OF lt_comp.
    DATA temp34 LIKE sy-tabix.
    FIELD-SYMBOLS <temp35> LIKE LINE OF lt_comp.
    DATA temp36 LIKE sy-tabix.
    FIELD-SYMBOLS <temp37> LIKE LINE OF lt_comp.
    DATA temp38 LIKE sy-tabix.
    DATA temp39 LIKE LINE OF lt_comp.
    DATA lr_comp LIKE REF TO temp39.
      FIELD-SYMBOLS <lv_field> TYPE any.
    lt_comp = z2ui5_cl_ui5_util_context=>rtti_get_t_attri_by_any( ls_struc ).

    cl_abap_unit_assert=>assert_equals( exp = 4
                                        act = lines( lt_comp ) ).


    temp32 = sy-tabix.
    READ TABLE lt_comp INDEX 1 ASSIGNING <temp31>.
    sy-tabix = temp32.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `ID`
                                        act = <temp31>-name ).


    temp34 = sy-tabix.
    READ TABLE lt_comp INDEX 2 ASSIGNING <temp33>.
    sy-tabix = temp34.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `NAME_IN`
                                        act = <temp33>-name ).


    temp36 = sy-tabix.
    READ TABLE lt_comp INDEX 3 ASSIGNING <temp35>.
    sy-tabix = temp36.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `CITY_IN`
                                        act = <temp35>-name ).


    temp38 = sy-tabix.
    READ TABLE lt_comp INDEX 4 ASSIGNING <temp37>.
    sy-tabix = temp38.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `ZIP`
                                        act = <temp37>-name ).

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
    DATA temp40 TYPE cl_abap_structdescr=>component_table.
    DATA temp41 LIKE LINE OF temp40.
    DATA temp1 TYPE REF TO cl_abap_datadescr.
    DATA lt_comp LIKE temp40.
    DATA lo_tab TYPE REF TO cl_abap_tabledescr.
    DATA lr_tab TYPE REF TO data.
    DATA temp2 TYPE xsdboolean.
    DATA temp3 TYPE xsdboolean.
    DATA lr_back TYPE REF TO data.
    CLEAR temp40.

    temp41-name = `COL1`.

    temp1 ?= cl_abap_datadescr=>describe_by_data( lv_col ).
    temp41-type = temp1.
    INSERT temp41 INTO TABLE temp40.

    lt_comp = temp40.

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

    temp2 = boolc( lv_type CS `payload-value` ).
    cl_abap_unit_assert=>assert_false( temp2 ).

    temp3 = boolc( lv_data CS `payload-value` ).
    cl_abap_unit_assert=>assert_true( temp3 ).


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

    cl_abap_unit_assert=>assert_true( z2ui5_cl_ui5_util_context=>rtti_check_printable( lv_d34 ) ).

  ENDMETHOD.

  METHOD test_check_clike.

    DATA lv_int  TYPE i VALUE 5.
    DATA lv_char TYPE c LENGTH 4.
    DATA lv_numc TYPE n LENGTH 4.
    DATA lv_date TYPE d.
    DATA ls_row  TYPE ty_s_row.

    cl_abap_unit_assert=>assert_true( z2ui5_cl_ui5_util_context=>rtti_check_clike( `abc` ) ).
    cl_abap_unit_assert=>assert_true( z2ui5_cl_ui5_util_context=>rtti_check_clike( lv_char ) ).
    " n, d and t are character-like too and must be accepted
    cl_abap_unit_assert=>assert_true( z2ui5_cl_ui5_util_context=>rtti_check_clike( lv_numc ) ).
    cl_abap_unit_assert=>assert_true( z2ui5_cl_ui5_util_context=>rtti_check_clike( lv_date ) ).

    cl_abap_unit_assert=>assert_false( z2ui5_cl_ui5_util_context=>rtti_check_clike( lv_int ) ).
    cl_abap_unit_assert=>assert_false( z2ui5_cl_ui5_util_context=>rtti_check_clike( ls_row ) ).

  ENDMETHOD.

  METHOD test_check_table.

    DATA lt_row TYPE ty_t_row.
    DATA ls_row TYPE ty_s_row.

    cl_abap_unit_assert=>assert_true( z2ui5_cl_ui5_util_context=>rtti_check_table( lt_row ) ).

    cl_abap_unit_assert=>assert_false( z2ui5_cl_ui5_util_context=>rtti_check_table( ls_row ) ).
    cl_abap_unit_assert=>assert_false( z2ui5_cl_ui5_util_context=>rtti_check_table( `abc` ) ).

  ENDMETHOD.

  METHOD test_check_structure.

    DATA ls_row TYPE ty_s_row.
    DATA lt_row TYPE ty_t_row.

    cl_abap_unit_assert=>assert_true( z2ui5_cl_ui5_util_context=>rtti_check_structure( ls_row ) ).

    cl_abap_unit_assert=>assert_false( z2ui5_cl_ui5_util_context=>rtti_check_structure( `abc` ) ).
    cl_abap_unit_assert=>assert_false( z2ui5_cl_ui5_util_context=>rtti_check_structure( lt_row ) ).

  ENDMETHOD.

  METHOD test_check_ref_data.

    DATA lr_data TYPE REF TO data.

    CREATE DATA lr_data TYPE string.

    cl_abap_unit_assert=>assert_true( z2ui5_cl_ui5_util_context=>rtti_check_ref_data( lr_data ) ).

    cl_abap_unit_assert=>assert_false( z2ui5_cl_ui5_util_context=>rtti_check_ref_data( `abc` ) ).

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

    cl_abap_unit_assert=>assert_false( z2ui5_cl_ui5_util_context=>check_bound_a_not_initial( lr_unbound ) ).
    cl_abap_unit_assert=>assert_false( z2ui5_cl_ui5_util_context=>check_bound_a_not_initial( lr_initial ) ).
    cl_abap_unit_assert=>assert_true( z2ui5_cl_ui5_util_context=>check_bound_a_not_initial( lr_filled ) ).

  ENDMETHOD.

  METHOD test_struc_to_pairs.

    DATA ls_row TYPE ty_s_row.
    DATA lt_pair TYPE z2ui5_cl_ui5_util_context=>ty_t_name_value.
    FIELD-SYMBOLS <temp42> LIKE LINE OF lt_pair.
    DATA temp43 LIKE sy-tabix.
    FIELD-SYMBOLS <temp44> LIKE LINE OF lt_pair.
    DATA temp45 LIKE sy-tabix.

    ls_row-name = `Ada`.
    ls_row-city = `London`.


    lt_pair = z2ui5_cl_ui5_util_context=>itab_get_by_struc( ls_row ).

    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( lt_pair ) ).

    " component names come back from RTTI in upper case


    temp43 = sy-tabix.
    READ TABLE lt_pair WITH KEY n = `NAME` ASSIGNING <temp42>.
    sy-tabix = temp43.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `Ada`
                                        act = <temp42>-v ).


    temp45 = sy-tabix.
    READ TABLE lt_pair WITH KEY n = `CITY` ASSIGNING <temp44>.
    sy-tabix = temp45.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `London`
                                        act = <temp44>-v ).

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
    FIELD-SYMBOLS <temp46> LIKE LINE OF lt_found.
    DATA temp47 LIKE sy-tabix.

    ls_flags-flag_a = abap_true.
    ls_flags-flag_b = abap_false.
    ls_flags-other  = abap_true.


    lt_found = z2ui5_cl_ui5_util_context=>scan_flag_prefix( val = ls_flags
                                                               prefix = `FLAG_` ).

    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( lt_found ) ).


    temp47 = sy-tabix.
    READ TABLE lt_found INDEX 1 ASSIGNING <temp46>.
    sy-tabix = temp47.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `A`
                                        act = <temp46> ).

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
    FIELD-SYMBOLS <temp48> LIKE LINE OF lt_element.
    DATA temp49 LIKE sy-tabix.
    DATA lt_action TYPE string_table.
    FIELD-SYMBOLS <temp50> LIKE LINE OF lt_action.
    DATA temp51 LIKE sy-tabix.

    ls_row-pid               = `1`.
    ls_row-element-name      = abap_true.
    ls_row-op-action-approve = abap_true.


    lt_element = z2ui5_cl_ui5_util_context=>scan_flag_prefix( val  = ls_row
                                                                  prefix = `ELEMENT-` ).
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( lt_element ) ).


    temp49 = sy-tabix.
    READ TABLE lt_element INDEX 1 ASSIGNING <temp48>.
    sy-tabix = temp49.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `NAME`
                                        act = <temp48> ).


    lt_action = z2ui5_cl_ui5_util_context=>scan_flag_prefix( val  = ls_row
                                                                 prefix = `OP-ACTION-` ).
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( lt_action ) ).


    temp51 = sy-tabix.
    READ TABLE lt_action INDEX 1 ASSIGNING <temp50>.
    sy-tabix = temp51.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `APPROVE`
                                        act = <temp50> ).

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
    DATA temp52 TYPE string_table.
    DATA temp54 LIKE REF TO lt_names.
DATA ls_type TYPE z2ui5_cl_ui5_util_context=>ty_s_sel_tab_type.
    DATA temp55 TYPE REF TO cl_abap_structdescr.
    DATA lt_comp TYPE abap_component_tab.
    FIELD-SYMBOLS <temp56> LIKE LINE OF lt_comp.
    DATA temp57 LIKE sy-tabix.
    FIELD-SYMBOLS <temp58> LIKE LINE OF lt_comp.
    DATA temp59 LIKE sy-tabix.
    CLEAR temp52.
    INSERT `a` INTO TABLE temp52.
    lt_names = temp52.


    GET REFERENCE OF lt_names INTO temp54.

ls_type = z2ui5_cl_ui5_util_context=>rtti_create_sel_tab_type( ir_tab       = temp54
                                                                        add_sel_field = abap_true ).

    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = ls_type-check_table_line ).

    temp55 ?= ls_type-tabledescr->get_table_line_type( ).

    lt_comp = temp55->get_components( ).
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( lt_comp ) ).


    temp57 = sy-tabix.
    READ TABLE lt_comp INDEX 1 ASSIGNING <temp56>.
    sy-tabix = temp57.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `TAB_LINE`
                                        act = <temp56>-name ).


    temp59 = sy-tabix.
    READ TABLE lt_comp INDEX 2 ASSIGNING <temp58>.
    sy-tabix = temp59.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `ZZSELKZ`
                                        act = <temp58>-name ).

  ENDMETHOD.

  METHOD test_sel_tab_of_tabs.

    " a table of tables has no line a row could be selected from
    TYPES temp1 TYPE STANDARD TABLE OF string_table WITH DEFAULT KEY.
DATA lt_deep TYPE temp1.
        DATA temp60 LIKE REF TO lt_deep.
        DATA lx TYPE REF TO z2ui5_cx_ui5_util_error.

    TRY.

        GET REFERENCE OF lt_deep INTO temp60.
z2ui5_cl_ui5_util_context=>rtti_create_sel_tab_type( temp60 ).
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

    DATA temp61 LIKE REF TO lt_sel.
DATA ls_type TYPE z2ui5_cl_ui5_util_context=>ty_s_sel_tab_type.
    DATA temp62 TYPE REF TO cl_abap_structdescr.
    DATA lt_comp TYPE abap_component_tab.
    GET REFERENCE OF lt_sel INTO temp61.

ls_type = z2ui5_cl_ui5_util_context=>rtti_create_sel_tab_type( ir_tab       = temp61
                                                                        add_sel_field = abap_true ).

    cl_abap_unit_assert=>assert_equals( exp = abap_false
                                        act = ls_type-check_table_line ).

    temp62 ?= ls_type-tabledescr->get_table_line_type( ).

    lt_comp = temp62->get_components( ).
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( lt_comp ) ).

  ENDMETHOD.

  METHOD test_error_attributes.

    " the attributes of an exception, as name/value pairs for the error
    " popup: public, printable and filled - the table, the private one and
    " cx_root's own bookkeeping (PREVIOUS, TEXTID, ...) stay out
    DATA lx TYPE REF TO cx_root.
    DATA lt_attri TYPE z2ui5_cl_ui5_util_context=>ty_t_name_value.
    FIELD-SYMBOLS <temp63> LIKE LINE OF lt_attri.
    DATA temp64 LIKE sy-tabix.
    FIELD-SYMBOLS <temp65> LIKE LINE OF lt_attri.
    DATA temp66 LIKE sy-tabix.
    TRY.
        RAISE EXCEPTION TYPE ltcl_rtti_cx
          EXPORTING
            detail = `  the detail  `.
      CATCH cx_root INTO lx ##NO_HANDLER.
    ENDTRY.


    lt_attri = z2ui5_cl_ui5_util_context=>error_get_attributes( lx ).

    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( lt_attri ) ).


    temp64 = sy-tabix.
    READ TABLE lt_attri INDEX 1 ASSIGNING <temp63>.
    sy-tabix = temp64.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `MV_DETAIL`
                                        act = <temp63>-n ).


    temp66 = sy-tabix.
    READ TABLE lt_attri INDEX 1 ASSIGNING <temp65>.
    sy-tabix = temp66.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `the detail`
                                        act = <temp65>-v ).

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

    DATA temp67 LIKE lt_deep.
    DATA temp68 LIKE LINE OF temp67.
    DATA temp2 TYPE string_table.
    DATA temp4 TYPE string_table.
    FIELD-SYMBOLS <temp69> LIKE LINE OF lt_deep.
    DATA temp70 LIKE sy-tabix.
    CLEAR temp67.

    temp68-name = `Ada`.

    CLEAR temp2.
    INSERT `London` INTO TABLE temp2.
    temp68-children = temp2.
    INSERT temp68 INTO TABLE temp67.
    temp68-name = `Alan`.

    CLEAR temp4.
    INSERT `Wilmslow` INTO TABLE temp4.
    temp68-children = temp4.
    INSERT temp68 INTO TABLE temp67.
    lt_deep = temp67.

    z2ui5_cl_ui5_util_context=>itab_filter_by_val( EXPORTING val = `Alan`
                                                CHANGING  tab    = lt_deep ).

    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( lt_deep ) ).


    temp70 = sy-tabix.
    READ TABLE lt_deep INDEX 1 ASSIGNING <temp69>.
    sy-tabix = temp70.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `Alan`
                                        act = <temp69>-name ).

  ENDMETHOD.

  METHOD get_rows.

    DATA temp71 TYPE ltcl_itab=>ty_t_row.
    DATA temp72 LIKE LINE OF temp71.
    CLEAR temp71.

    temp72-name = `Ada`.
    temp72-city = `London`.
    INSERT temp72 INTO TABLE temp71.
    temp72-name = `Alan`.
    temp72-city = `Wilmslow`.
    INSERT temp72 INTO TABLE temp71.
    temp72-name = `Grace`.
    temp72-city = `New York`.
    INSERT temp72 INTO TABLE temp71.
    result = temp71.

  ENDMETHOD.

  METHOD test_filter_all_fields.

    " with no field list every component is searched, so a hit in `city`
    " keeps the row even though `name` does not match
    DATA lt_row TYPE ltcl_itab=>ty_t_row.
    FIELD-SYMBOLS <temp73> LIKE LINE OF lt_row.
    DATA temp74 LIKE sy-tabix.
    lt_row = get_rows( ).

    z2ui5_cl_ui5_util_context=>itab_filter_by_val( EXPORTING val = `London`
                                                CHANGING  tab    = lt_row ).

    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( lt_row ) ).


    temp74 = sy-tabix.
    READ TABLE lt_row INDEX 1 ASSIGNING <temp73>.
    sy-tabix = temp74.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `Ada`
                                        act = <temp73>-name ).

  ENDMETHOD.

  METHOD test_filter_ignore_case.

    DATA lt_row TYPE ltcl_itab=>ty_t_row.
    FIELD-SYMBOLS <temp75> LIKE LINE OF lt_row.
    DATA temp76 LIKE sy-tabix.
    lt_row = get_rows( ).

    z2ui5_cl_ui5_util_context=>itab_filter_by_val( EXPORTING val      = `ada`
                                                          ignore_case = abap_true
                                                CHANGING  tab         = lt_row ).

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
    DATA temp77 LIKE lt_deep.
    DATA temp78 LIKE LINE OF temp77.
    DATA temp6 TYPE string_table.
    DATA temp8 TYPE string_table.
    DATA lt_row TYPE ltcl_itab=>ty_t_row.
    DATA lv_blank TYPE c LENGTH 10.
    CLEAR temp77.


    CLEAR temp6.
    INSERT `London` INTO TABLE temp6.
    temp78-children = temp6.
    INSERT temp78 INTO TABLE temp77.

    CLEAR temp8.
    temp78-children = temp8.
    INSERT temp78 INTO TABLE temp77.
    lt_deep = temp77.
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

    DATA temp79 TYPE string_table.
    FIELD-SYMBOLS <temp81> LIKE LINE OF lt_str.
    DATA temp82 LIKE sy-tabix.
    CLEAR temp79.
    INSERT `London` INTO TABLE temp79.
    INSERT `Wilmslow` INTO TABLE temp79.
    INSERT `New York` INTO TABLE temp79.
    lt_str = temp79.

    z2ui5_cl_ui5_util_context=>itab_filter_by_val( EXPORTING val = `London`
                                                CHANGING  tab    = lt_str ).

    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( lt_str ) ).


    temp82 = sy-tabix.
    READ TABLE lt_str INDEX 1 ASSIGNING <temp81>.
    sy-tabix = temp82.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `London`
                                        act = <temp81> ).

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
    FIELD-SYMBOLS <temp83> LIKE LINE OF lt_target.
    DATA temp84 LIKE sy-tabix.
    FIELD-SYMBOLS <temp85> LIKE LINE OF lt_target.
    DATA temp86 LIKE sy-tabix.
    lt_row = get_rows( ).

    z2ui5_cl_ui5_util_context=>itab_corresponding( EXPORTING val = lt_row
                                                CHANGING  tab    = lt_target ).

    cl_abap_unit_assert=>assert_equals( exp = 3
                                        act = lines( lt_target ) ).


    temp84 = sy-tabix.
    READ TABLE lt_target INDEX 1 ASSIGNING <temp83>.
    sy-tabix = temp84.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `Ada`
                                        act = <temp83>-name ).


    temp86 = sy-tabix.
    READ TABLE lt_target INDEX 1 ASSIGNING <temp85>.
    sy-tabix = temp86.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_initial( <temp85>-country ).

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

    DATA temp87 TYPE ty_s_msg_like.
    DATA ls_empty LIKE temp87.
    CLEAR temp87.

    ls_empty = temp87.

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

    DATA temp88 TYPE ty_t_row.
    DATA temp89 LIKE LINE OF temp88.
    DATA lt_rows LIKE temp88.
    CLEAR temp88.

    temp89-id = `0001`.
    temp89-name = `Ada`.
    INSERT temp89 INTO TABLE temp88.
    temp89-id = `0002`.
    temp89-name = `Alan`.
    INSERT temp89 INTO TABLE temp88.

    lt_rows = temp88.

    cl_abap_unit_assert=>assert_true( z2ui5_cl_ui5_util_context=>ui5_msg_box_format( lt_rows )-skip ).

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

    DATA temp90 TYPE ty_s_row.
    DATA ls_row LIKE temp90.
    DATA ls_box TYPE z2ui5_cl_ui5_util_context=>ty_s_msg_box.
    CLEAR temp90.
    temp90-name = `Ada`.
    temp90-item = `0010`.

    ls_row = temp90.


    ls_box = z2ui5_cl_ui5_util_context=>ui5_msg_box_format( ls_row ).

    cl_abap_unit_assert=>assert_true( ls_box-skip ).

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
    DATA temp91 TYPE ty_s_item.
    DATA temp92 TYPE ty_s_item.
    DATA lt_msg TYPE z2ui5_cl_ui5_util_context=>ty_t_msg.
    FIELD-SYMBOLS <temp93> LIKE LINE OF lt_msg.
    DATA temp94 LIKE sy-tabix.
    FIELD-SYMBOLS <temp95> LIKE LINE OF lt_msg.
    DATA temp96 LIKE sy-tabix.
    FIELD-SYMBOLS <temp97> LIKE LINE OF lt_msg.
    DATA temp98 LIKE sy-tabix.
    FIELD-SYMBOLS <temp99> LIKE LINE OF lt_msg.
    DATA temp100 LIKE sy-tabix.
    " the envelope's own type says Success and must NOT reach the messages
    ls_env-type = `S`.

    CLEAR temp91.
    temp91-type = `E`.
    temp91-message = `first`.
    APPEND temp91 TO ls_env-item.

    CLEAR temp92.
    temp92-type = `W`.
    temp92-message = `second`.
    APPEND temp92 TO ls_env-item.


    lt_msg = z2ui5_cl_ui5_util_context=>msg_get_t( ls_env ).

    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( lt_msg ) ).


    temp94 = sy-tabix.
    READ TABLE lt_msg INDEX 1 ASSIGNING <temp93>.
    sy-tabix = temp94.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `first`
                                        act = <temp93>-text ).


    temp96 = sy-tabix.
    READ TABLE lt_msg INDEX 1 ASSIGNING <temp95>.
    sy-tabix = temp96.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `E`
                                        act = <temp95>-type ).


    temp98 = sy-tabix.
    READ TABLE lt_msg INDEX 2 ASSIGNING <temp97>.
    sy-tabix = temp98.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `second`
                                        act = <temp97>-text ).


    temp100 = sy-tabix.
    READ TABLE lt_msg INDEX 2 ASSIGNING <temp99>.
    sy-tabix = temp100.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `W`
                                        act = <temp99>-type ).

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

    DATA temp101 TYPE ty_s_t100.
    DATA ls_t100 LIKE temp101.
    DATA lt_msg TYPE z2ui5_cl_ui5_util_context=>ty_t_msg.
    FIELD-SYMBOLS <temp102> LIKE LINE OF lt_msg.
    DATA temp103 LIKE sy-tabix.
    FIELD-SYMBOLS <temp104> LIKE LINE OF lt_msg.
    DATA temp105 LIKE sy-tabix.
    FIELD-SYMBOLS <temp106> LIKE LINE OF lt_msg.
    DATA temp107 LIKE sy-tabix.
    FIELD-SYMBOLS <temp108> LIKE LINE OF lt_msg.
    DATA temp109 LIKE sy-tabix.
    CLEAR temp101.
    temp101-id = `z2ui5_test`.
    temp101-number = '001'.
    temp101-type = `E`.
    temp101-message_v1 = `4711`.

    ls_t100 = temp101.


    lt_msg = z2ui5_cl_ui5_util_context=>msg_get_t( ls_t100 ).

    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( lt_msg ) ).
    " the parts the walk mapped by name, whatever the message class says


    temp103 = sy-tabix.
    READ TABLE lt_msg INDEX 1 ASSIGNING <temp102>.
    sy-tabix = temp103.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `Z2UI5_TEST`
                                        act = <temp102>-id ).


    temp105 = sy-tabix.
    READ TABLE lt_msg INDEX 1 ASSIGNING <temp104>.
    sy-tabix = temp105.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `E`
                                        act = <temp104>-type ).


    temp107 = sy-tabix.
    READ TABLE lt_msg INDEX 1 ASSIGNING <temp106>.
    sy-tabix = temp107.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `4711`
                                        act = <temp106>-v1 ).
    " and a text was assembled rather than left blank


    temp109 = sy-tabix.
    READ TABLE lt_msg INDEX 1 ASSIGNING <temp108>.
    sy-tabix = temp109.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_not_initial( <temp108>-text ).

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

    cl_abap_unit_assert=>assert_true( ls_box-skip ).

  ENDMETHOD.

  METHOD test_box_single.

    " a single message renders as plain text without a details list
    DATA lt_msg TYPE z2ui5_cl_ui5_util_context=>ty_t_msg.

    DATA temp110 TYPE z2ui5_cl_ui5_util_context=>ty_t_msg.
    DATA temp111 LIKE LINE OF temp110.
    DATA ls_box TYPE z2ui5_cl_ui5_util_context=>ty_s_msg_box.
    CLEAR temp110.

    temp111-text = `boom`.
    temp111-type = `E`.
    INSERT temp111 INTO TABLE temp110.
    lt_msg = temp110.


    ls_box = z2ui5_cl_ui5_util_context=>ui5_msg_box_format( lt_msg ).

    cl_abap_unit_assert=>assert_false( ls_box-skip ).
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

    DATA temp112 TYPE z2ui5_cl_ui5_util_context=>ty_t_msg.
    DATA temp113 LIKE LINE OF temp112.
    DATA ls_box TYPE z2ui5_cl_ui5_util_context=>ty_s_msg_box.
    DATA temp114 TYPE z2ui5_cl_ui5_util_context=>ty_t_msg.
    DATA temp115 LIKE LINE OF temp114.
    CLEAR temp112.

    temp113-text = `first`.
    temp113-type = `W`.
    INSERT temp113 INTO TABLE temp112.
    temp113-text = `second`.
    temp113-type = `E`.
    INSERT temp113 INTO TABLE temp112.
    lt_msg = temp112.


    ls_box = z2ui5_cl_ui5_util_context=>ui5_msg_box_format( lt_msg ).

    cl_abap_unit_assert=>assert_false( ls_box-skip ).
    cl_abap_unit_assert=>assert_equals( exp = `Error`
                                        act = ls_box-title ).
    cl_abap_unit_assert=>assert_equals( exp = `error`
                                        act = ls_box-type ).
    cl_abap_unit_assert=>assert_equals( exp = `2 Messages found:`
                                        act = ls_box-text ).

    " a warning outranks success and information wherever it stands, and
    " between those two the first one decides

    CLEAR temp114.

    temp115-text = `a`.
    temp115-type = `S`.
    INSERT temp115 INTO TABLE temp114.
    temp115-text = `b`.
    temp115-type = `I`.
    INSERT temp115 INTO TABLE temp114.
    temp115-text = `c`.
    temp115-type = `W`.
    INSERT temp115 INTO TABLE temp114.
    lt_msg = temp114.
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

    DATA temp116 TYPE z2ui5_cl_ui5_util_context=>ty_t_msg.
    DATA temp117 LIKE LINE OF temp116.
    DATA ls_box TYPE z2ui5_cl_ui5_util_context=>ty_s_msg_box.
    CLEAR temp116.

    temp117-text = `Enter a value for <MATNR>`.
    temp117-type = `E`.
    INSERT temp117 INTO TABLE temp116.
    temp117-text = `a & b`.
    temp117-type = `E`.
    INSERT temp117 INTO TABLE temp116.
    lt_msg = temp116.


    ls_box = z2ui5_cl_ui5_util_context=>ui5_msg_box_format( lt_msg ).

    cl_abap_unit_assert=>assert_equals(
        exp = `<ul><li>Enter a value for &lt;MATNR&gt;</li><li>a &amp; b</li></ul>`
        act = ls_box-details ).

  ENDMETHOD.

  METHOD test_box_exception_object.

    " an exception is its text, an error by default
    DATA lx TYPE REF TO z2ui5_cx_ui5_util_error.
    DATA ls_box TYPE z2ui5_cl_ui5_util_context=>ty_s_msg_box.
    DATA temp4 TYPE xsdboolean.
    TRY.
        RAISE EXCEPTION TYPE z2ui5_cx_ui5_util_error
          EXPORTING
            val = `Posting failed`.
      CATCH z2ui5_cx_ui5_util_error INTO lx ##NO_HANDLER.
    ENDTRY.


    ls_box = z2ui5_cl_ui5_util_context=>ui5_msg_box_format( lx ).

    cl_abap_unit_assert=>assert_false( ls_box-skip ).
    cl_abap_unit_assert=>assert_equals( exp = `Error`
                                        act = ls_box-title ).

    temp4 = boolc( ls_box-text CS `Posting failed` ).
    cl_abap_unit_assert=>assert_true( temp4 ).

  ENDMETHOD.

  METHOD test_box_plain_object.

    " neither exception nor log: the public attributes that carry a message
    " part are mapped - the fourth shape of msg_get_by_oref
    DATA lo_carrier TYPE REF TO ltcl_msg_carrier.
    DATA ls_box TYPE z2ui5_cl_ui5_util_context=>ty_s_msg_box.
    CREATE OBJECT lo_carrier TYPE ltcl_msg_carrier.


    ls_box = z2ui5_cl_ui5_util_context=>ui5_msg_box_format( lo_carrier ).

    cl_abap_unit_assert=>assert_false( ls_box-skip ).
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

    cl_abap_unit_assert=>assert_true( ls_box-skip ).

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

    DATA temp118 LIKE lt_row.
    DATA temp119 LIKE LINE OF temp118.
    DATA ls_box TYPE z2ui5_cl_ui5_util_context=>ty_s_msg_box.
    CLEAR temp118.

    temp119-carrid = `LH`.
    temp119-seats = 12.
    INSERT temp119 INTO TABLE temp118.
    lt_row = temp118.


    ls_box = z2ui5_cl_ui5_util_context=>ui5_msg_box_format( lt_row ).

    cl_abap_unit_assert=>assert_true( ls_box-skip ).

  ENDMETHOD.

  METHOD test_token_by_range.

    " every range option maps to its own token text; the placeholders
    " {LOW}/{HIGH} are substituted from the range row
    DATA lt_range TYPE z2ui5_cl_ui5_util_context=>ty_t_range.

    DATA temp120 TYPE z2ui5_cl_ui5_util_context=>ty_t_range.
    DATA temp121 LIKE LINE OF temp120.
    DATA lt_token TYPE z2ui5_cl_ui5_util_context=>ty_t_token.
    FIELD-SYMBOLS <temp122> LIKE LINE OF lt_token.
    DATA temp123 LIKE sy-tabix.
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
    CLEAR temp120.

    CLEAR temp121.
    temp121-sign = `I`.
    temp121-option = `EQ`.
    temp121-low = `X`.
    INSERT temp121 INTO TABLE temp120.
    CLEAR temp121.
    temp121-sign = `I`.
    temp121-option = `BT`.
    temp121-low = `1`.
    temp121-high = `9`.
    INSERT temp121 INTO TABLE temp120.
    CLEAR temp121.
    temp121-sign = `I`.
    temp121-option = `CP`.
    temp121-low = `A`.
    INSERT temp121 INTO TABLE temp120.
    CLEAR temp121.
    temp121-sign = `E`.
    temp121-option = `EQ`.
    temp121-low = `Y`.
    INSERT temp121 INTO TABLE temp120.
    lt_range = temp120.


    lt_token = z2ui5_cl_ui5_util_context=>filter_get_token_t_by_range_t( lt_range ).

    cl_abap_unit_assert=>assert_equals( exp = 4
                                        act = lines( lt_token ) ).


    temp123 = sy-tabix.
    READ TABLE lt_token INDEX 1 ASSIGNING <temp122>.
    sy-tabix = temp123.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `=X`
                                        act = <temp122>-key ).


    temp125 = sy-tabix.
    READ TABLE lt_token INDEX 2 ASSIGNING <temp124>.
    sy-tabix = temp125.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `1...9`
                                        act = <temp124>-key ).


    temp127 = sy-tabix.
    READ TABLE lt_token INDEX 3 ASSIGNING <temp126>.
    sy-tabix = temp127.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `*A*`
                                        act = <temp126>-key ).
    " an excluding row renders negated, not like its including twin


    temp129 = sy-tabix.
    READ TABLE lt_token INDEX 4 ASSIGNING <temp128>.
    sy-tabix = temp129.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `!(=Y)`
                                        act = <temp128>-key ).

    " tokens come back visible and editable so the UI5 MultiInput can render
    " and remove them


    temp131 = sy-tabix.
    READ TABLE lt_token INDEX 1 ASSIGNING <temp130>.
    sy-tabix = temp131.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_true( <temp130>-visible ).


    temp133 = sy-tabix.
    READ TABLE lt_token INDEX 1 ASSIGNING <temp132>.
    sy-tabix = temp133.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_true( <temp132>-editable ).

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

    DATA temp134 TYPE ty_t_int_range.
    DATA temp135 LIKE LINE OF temp134.
    DATA lt_range LIKE temp134.
    DATA lt_token TYPE z2ui5_cl_ui5_util_context=>ty_t_token.
    FIELD-SYMBOLS <temp136> LIKE LINE OF lt_token.
    DATA temp137 LIKE sy-tabix.
    FIELD-SYMBOLS <temp138> LIKE LINE OF lt_token.
    DATA temp139 LIKE sy-tabix.
    CLEAR temp134.

    CLEAR temp135.
    temp135-sign = `I`.
    temp135-option = `EQ`.
    temp135-low = 42.
    INSERT temp135 INTO TABLE temp134.
    CLEAR temp135.
    temp135-sign = `I`.
    temp135-option = `BT`.
    temp135-low = -5.
    temp135-high = 10.
    INSERT temp135 INTO TABLE temp134.

    lt_range = temp134.


    lt_token = z2ui5_cl_ui5_util_context=>filter_get_token_t_by_range_t( lt_range ).



    temp137 = sy-tabix.
    READ TABLE lt_token INDEX 1 ASSIGNING <temp136>.
    sy-tabix = temp137.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `=42`
                                        act = <temp136>-key ).


    temp139 = sy-tabix.
    READ TABLE lt_token INDEX 2 ASSIGNING <temp138>.
    sy-tabix = temp139.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `-5...10`
                                        act = <temp138>-key ).

  ENDMETHOD.

  METHOD test_token_dollar_value.

    " LOW / HIGH are data and go into the token as written - `$&`, `$$` and
    " a backslash before a brace included, and a value that spells the other
    " placeholder is not substituted again
    DATA lt_range TYPE z2ui5_cl_ui5_util_context=>ty_t_range.

    DATA temp140 TYPE z2ui5_cl_ui5_util_context=>ty_t_range.
    DATA temp141 LIKE LINE OF temp140.
    DATA lt_token TYPE z2ui5_cl_ui5_util_context=>ty_t_token.
    FIELD-SYMBOLS <temp142> LIKE LINE OF lt_token.
    DATA temp143 LIKE sy-tabix.
    FIELD-SYMBOLS <temp144> LIKE LINE OF lt_token.
    DATA temp145 LIKE sy-tabix.
    FIELD-SYMBOLS <temp146> LIKE LINE OF lt_token.
    DATA temp147 LIKE sy-tabix.
    CLEAR temp140.

    CLEAR temp141.
    temp141-sign = `I`.
    temp141-option = `EQ`.
    temp141-low = `a$&b`.
    INSERT temp141 INTO TABLE temp140.
    CLEAR temp141.
    temp141-sign = `I`.
    temp141-option = `BT`.
    temp141-low = `$$`.
    temp141-high = `\{x\}`.
    INSERT temp141 INTO TABLE temp140.
    CLEAR temp141.
    temp141-sign = `I`.
    temp141-option = `BT`.
    temp141-low = `{HIGH}`.
    temp141-high = `9`.
    INSERT temp141 INTO TABLE temp140.
    lt_range = temp140.


    lt_token = z2ui5_cl_ui5_util_context=>filter_get_token_t_by_range_t( lt_range ).



    temp143 = sy-tabix.
    READ TABLE lt_token INDEX 1 ASSIGNING <temp142>.
    sy-tabix = temp143.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `=a$&b`
                                        act = <temp142>-key ).


    temp145 = sy-tabix.
    READ TABLE lt_token INDEX 2 ASSIGNING <temp144>.
    sy-tabix = temp145.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `$$...\{x\}`
                                        act = <temp144>-key ).


    temp147 = sy-tabix.
    READ TABLE lt_token INDEX 3 ASSIGNING <temp146>.
    sy-tabix = temp147.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `{HIGH}...9`
                                        act = <temp146>-key ).

  ENDMETHOD.

  METHOD test_token_odd_option.

    " a row without an option (appended with sign and low only), a lower-case
    " option and one the mapping does not know used to raise a raw
    " CX_SY_ITAB_LINE_NOT_FOUND for the whole table; they render as equality
    DATA lt_range TYPE z2ui5_cl_ui5_util_context=>ty_t_range.
    DATA ls_range LIKE LINE OF lt_range.
    DATA lv_option TYPE string.
    DATA lt_token TYPE z2ui5_cl_ui5_util_context=>ty_t_token.
    FIELD-SYMBOLS <temp148> LIKE LINE OF lt_token.
    DATA temp149 LIKE sy-tabix.
    FIELD-SYMBOLS <temp150> LIKE LINE OF lt_token.
    DATA temp151 LIKE sy-tabix.
    FIELD-SYMBOLS <temp152> LIKE LINE OF lt_token.
    DATA temp153 LIKE sy-tabix.

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


    temp149 = sy-tabix.
    READ TABLE lt_token INDEX 1 ASSIGNING <temp148>.
    sy-tabix = temp149.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `=X`
                                        act = <temp148>-key ).


    temp151 = sy-tabix.
    READ TABLE lt_token INDEX 2 ASSIGNING <temp150>.
    sy-tabix = temp151.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `=Y`
                                        act = <temp150>-key ).


    temp153 = sy-tabix.
    READ TABLE lt_token INDEX 3 ASSIGNING <temp152>.
    sy-tabix = temp153.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `=Z`
                                        act = <temp152>-key ).

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
      DATA temp5 TYPE xsdboolean.
    DO 12 TIMES.
      lv_cause = sy-index - 1.

      lv_text = z2ui5_cl_ui5_util_context=>msg_get_rap_fail_text( lv_cause ).

      cl_abap_unit_assert=>assert_not_initial(
          act = lv_text
          msg = |cause { lv_cause } renders no text| ).


      temp5 = boolc( lv_text CS `cause code` ).
      cl_abap_unit_assert=>assert_false(
          act = temp5
          msg = |cause { lv_cause } fell through to the ELSE branch| ).
    ENDDO.

  ENDMETHOD.

  METHOD test_flatten_pairs.

    " the key renders as NAME=VALUE pairs, comma separated - this is what a
    " message ends up quoting to say WHICH entity failed
    DATA temp154 TYPE ty_s_tky.
    DATA ls_tky LIKE temp154.
    CLEAR temp154.
    temp154-product_uuid = `ABC-1`.
    temp154-product_id = `4711`.

    ls_tky = temp154.

    cl_abap_unit_assert=>assert_equals(
        exp = `PRODUCT_UUID=ABC-1, PRODUCT_ID=4711`
        act = z2ui5_cl_ui5_util_context=>msg_get_rap_flatten( ls_tky ) ).

  ENDMETHOD.

  METHOD test_flatten_skips_empty.

    " an initial component contributes nothing - not an empty pair and not a
    " dangling separator
    DATA temp155 TYPE ty_s_tky.
    DATA ls_tky LIKE temp155.
    CLEAR temp155.
    temp155-product_id = `4711`.

    ls_tky = temp155.

    cl_abap_unit_assert=>assert_equals(
        exp = `PRODUCT_ID=4711`
        act = z2ui5_cl_ui5_util_context=>msg_get_rap_flatten( ls_tky ) ).

  ENDMETHOD.

  METHOD test_flatten_nested.

    " a nested structure is flattened by the recursion, and its pairs join the
    " outer ones in component order
    DATA temp156 TYPE ty_s_nested.
    DATA ls_nested LIKE temp156.
    CLEAR temp156.
    CLEAR temp156-inner.
    temp156-inner-a = `1`.
    temp156-inner-b = `2`.
    temp156-c = `3`.

    ls_nested = temp156.

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
    DATA temp157 TYPE ty_s_plain.
    DATA ls_plain LIKE temp157.
    CLEAR temp157.
    temp157-name = `Ada`.
    temp157-city = `London`.

    ls_plain = temp157.

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
    DATA lt_comp  TYPE cl_abap_structdescr=>component_table.

    FIELD-SYMBOLS <failed> TYPE any.
    FIELD-SYMBOLS <tab>    TYPE ANY TABLE.
    FIELD-SYMBOLS <ftab>   TYPE STANDARD TABLE.
    FIELD-SYMBOLS <row>    TYPE any.
    FIELD-SYMBOLS <comp>   TYPE any.
    DATA temp158 TYPE abap_component_tab.
    DATA temp159 LIKE LINE OF temp158.
    DATA temp160 TYPE abap_component_tab.
    DATA temp161 LIKE LINE OF temp160.
    DATA temp162 TYPE abap_component_tab.
    DATA temp163 LIKE LINE OF temp162.
      DATA temp164 TYPE abap_componentdescr.
      DATA temp165 TYPE abap_componentdescr.
    DATA temp166 TYPE abap_component_tab.
    DATA temp167 LIKE LINE OF temp166.

    lo_str = cl_abap_elemdescr=>get_string( ).
    lo_c1  = cl_abap_elemdescr=>get_c( 1 ).


    CLEAR temp158.

    temp159-name = `PRODUCT_ID`.
    temp159-type = lo_str.
    INSERT temp159 INTO TABLE temp158.
    lo_key  = cl_abap_structdescr=>create( temp158 ).

    CLEAR temp160.

    temp161-name = `CAUSE`.
    temp161-type = cl_abap_elemdescr=>get_i( ).
    INSERT temp161 INTO TABLE temp160.
    lo_fail = cl_abap_structdescr=>create( temp160 ).


    CLEAR temp162.

    temp163-name = `%FAIL`.
    temp163-type = lo_fail.
    INSERT temp163 INTO TABLE temp162.
    temp163-name = `%TKY`.
    temp163-type = lo_key.
    INSERT temp163 INTO TABLE temp162.
    temp163-name = `%PID`.
    temp163-type = lo_str.
    INSERT temp163 INTO TABLE temp162.
    temp163-name = `%CID`.
    temp163-type = lo_str.
    INSERT temp163 INTO TABLE temp162.
    lt_comp = temp162.
    IF with_dashed_meta = abap_true.

      CLEAR temp164.
      temp164-name = `%ELEMENT-CUSTOMERID`.
      temp164-type = lo_c1.
      INSERT temp164 INTO TABLE lt_comp.

      CLEAR temp165.
      temp165-name = `%OP-%ACTION-DEDUCTDISCOUNT`.
      temp165-type = lo_c1.
      INSERT temp165 INTO TABLE lt_comp.
    ENDIF.
    lo_row  = cl_abap_structdescr=>create( lt_comp ).
    lo_rows = cl_abap_tabledescr=>create( lo_row ).

    CLEAR temp166.

    temp167-name = `BOOKINGS`.
    temp167-type = lo_rows.
    INSERT temp167 INTO TABLE temp166.
    lo_top  = cl_abap_structdescr=>create( temp166 ).

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
    FIELD-SYMBOLS <temp168> LIKE LINE OF lt_any.
    DATA temp169 LIKE sy-tabix.
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


    temp169 = sy-tabix.
    READ TABLE lt_any INDEX 1 ASSIGNING <temp168>.
    sy-tabix = temp169.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = ls_msg-text
                                        act = <temp168>-text ).

  ENDMETHOD.

  METHOD test_rap_msg_row.

    " the `reported` response: a row whose %MSG holds the message object -
    " its text is the message, the row's meta travels with it. A reference
    " component is built from cl_abap_refdescr=>create( ), which the
    " transpiled runtime cannot CREATE DATA yet (backlog
    " core-refdescr-create-no-kind) - skipped there by configuration
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
    DATA temp170 TYPE REF TO cl_abap_classdescr.
    DATA temp171 TYPE abap_component_tab.
    DATA temp172 LIKE LINE OF temp171.
    DATA temp173 TYPE abap_component_tab.
    DATA temp174 LIKE LINE OF temp173.
    DATA lt_msg TYPE z2ui5_cl_ui5_util_context=>ty_t_msg.
    FIELD-SYMBOLS <temp175> LIKE LINE OF lt_msg.
    DATA temp176 LIKE sy-tabix.
    FIELD-SYMBOLS <temp177> LIKE LINE OF lt_msg.
    DATA temp178 LIKE sy-tabix.

    lo_str = cl_abap_elemdescr=>get_string( ).

    temp170 ?= cl_abap_typedescr=>describe_by_name( `CX_ROOT` ).
    lo_ref = cl_abap_refdescr=>create(
      temp170 ).

    CLEAR temp171.

    temp172-name = `%MSG`.
    temp172-type = lo_ref.
    INSERT temp172 INTO TABLE temp171.
    temp172-name = `%PID`.
    temp172-type = lo_str.
    INSERT temp172 INTO TABLE temp171.
    lo_row  = cl_abap_structdescr=>create( temp171 ).
    lo_rows = cl_abap_tabledescr=>create( lo_row ).

    CLEAR temp173.

    temp174-name = `BOOKINGS`.
    temp174-type = lo_rows.
    INSERT temp174 INTO TABLE temp173.
    lo_top  = cl_abap_structdescr=>create( temp173 ).

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


    temp176 = sy-tabix.
    READ TABLE lt_msg INDEX 1 ASSIGNING <temp175>.
    sy-tabix = temp176.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_char_cp( exp = `*booking date in the past*`
                                         act = <temp175>-text ).


    temp178 = sy-tabix.
    READ TABLE lt_msg INDEX 1 ASSIGNING <temp177>.
    sy-tabix = temp178.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `pid-9`
                                        act = meta_of( msg = <temp177> n = `pid` ) ).

  ENDMETHOD.

  METHOD test_rap_meta_dashed.

    " %ELEMENT-<field> and %OP-%ACTION-<name> are flags whose NAME carries
    " the information - the meta names the field and the action. The
    " transpiled runtime reads such a name as a path (backlog
    " runtime-assign-component-dash-name) - skipped there by configuration
    FIELD-SYMBOLS <failed> TYPE any.
    DATA lr_failed TYPE REF TO data.
    DATA lt_msg TYPE z2ui5_cl_ui5_util_context=>ty_t_msg.
    FIELD-SYMBOLS <temp179> LIKE LINE OF lt_msg.
    DATA temp180 LIKE sy-tabix.
    FIELD-SYMBOLS <temp181> LIKE LINE OF lt_msg.
    DATA temp182 LIKE sy-tabix.
    lr_failed = failed_bookings( abap_true ).
    ASSIGN lr_failed->* TO <failed>.


    lt_msg = z2ui5_cl_ui5_util_context=>msg_get_rap( <failed> ).

    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( lt_msg ) ).


    temp180 = sy-tabix.
    READ TABLE lt_msg INDEX 1 ASSIGNING <temp179>.
    sy-tabix = temp180.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `CUSTOMERID`
                                        act = meta_of( msg = <temp179> n = `element` ) ).


    temp182 = sy-tabix.
    READ TABLE lt_msg INDEX 1 ASSIGNING <temp181>.
    sy-tabix = temp182.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `DEDUCTDISCOUNT`
                                        act = meta_of( msg = <temp181> n = `action` ) ).

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
    DATA temp183 TYPE ty_s_nested.
    DATA ls_nested LIKE temp183.
    CLEAR temp183.
    CLEAR temp183-inner.
    temp183-inner-a = `1`.
    temp183-c = `three`.

    ls_nested = temp183.

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

    cl_abap_unit_assert=>assert_false( ls_box-skip ).
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

    cl_abap_unit_assert=>assert_false( ls_box-skip ).
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

    DATA temp184 TYPE ltcl_data_box=>ty_t_row.
    DATA temp185 LIKE LINE OF temp184.
    DATA ls_box TYPE z2ui5_cl_ui5_util_context=>ty_s_msg_box.
    CLEAR temp184.

    temp185-carrid = `LH`.
    temp185-seats = 12.
    INSERT temp185 INTO TABLE temp184.
    lt_row = temp184.


    ls_box = z2ui5_cl_ui5_util_context=>ui5_data_box_format( lt_row ).

    cl_abap_unit_assert=>assert_false( ls_box-skip ).
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

    cl_abap_unit_assert=>assert_true( ls_box-skip ).

  ENDMETHOD.

  METHOD test_escapes_markup.

    " a value that looks like markup is data, not markup - it must not be
    " able to close the list the renderer is building
    DATA lt_row TYPE ty_t_row.

    DATA temp186 TYPE ltcl_data_box=>ty_t_row.
    DATA temp187 LIKE LINE OF temp186.
    DATA ls_box TYPE z2ui5_cl_ui5_util_context=>ty_s_msg_box.
    CLEAR temp186.

    temp187-carrid = `</ul><script>`.
    INSERT temp187 INTO TABLE temp186.
    lt_row = temp186.


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
      DATA temp188 TYPE ltcl_data_box=>ty_s_row.
    DATA ls_box TYPE z2ui5_cl_ui5_util_context=>ty_s_msg_box.
    DATA temp6 TYPE xsdboolean.

    DO 105 TIMES.

      CLEAR temp188.
      temp188-seats = sy-index.
      INSERT temp188 INTO TABLE lt_row.
    ENDDO.


    ls_box = z2ui5_cl_ui5_util_context=>ui5_data_box_format( lt_row ).

    cl_abap_unit_assert=>assert_equals( exp = `Table with 105 entries`
                                        act = ls_box-text ).

    temp6 = boolc( ls_box-details CS `... 5 more entries` ).
    cl_abap_unit_assert=>assert_true( temp6 ).

  ENDMETHOD.

  METHOD test_object.

    " an object renders its public instance attributes as a list - the
    " constant, the class attribute and the private one stay out
    DATA lo_obj TYPE REF TO ltcl_data_box_obj.
    DATA ls_box TYPE z2ui5_cl_ui5_util_context=>ty_s_msg_box.
    CREATE OBJECT lo_obj TYPE ltcl_data_box_obj.


    ls_box = z2ui5_cl_ui5_util_context=>ui5_data_box_format( lo_obj ).

    cl_abap_unit_assert=>assert_false( ls_box-skip ).
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

    cl_abap_unit_assert=>assert_false( ls_box-skip ).
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

    cl_abap_unit_assert=>assert_false( ls_box-skip ).
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
    FIELD-SYMBOLS <temp189> LIKE LINE OF lt_param.
    DATA temp190 LIKE sy-tabix.
    FIELD-SYMBOLS <temp191> LIKE LINE OF lt_param.
    DATA temp192 LIKE sy-tabix.
    FIELD-SYMBOLS <temp193> LIKE LINE OF lt_param.
    DATA temp194 LIKE sy-tabix.
    lt_param = z2ui5_cl_ui5_util_context=>url_param_get_tab( `?debug&a=1` ).

    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( lt_param ) ).


    temp190 = sy-tabix.
    READ TABLE lt_param INDEX 1 ASSIGNING <temp189>.
    sy-tabix = temp190.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `debug`
                                        act = <temp189>-n ).


    temp192 = sy-tabix.
    READ TABLE lt_param INDEX 1 ASSIGNING <temp191>.
    sy-tabix = temp192.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_initial( <temp191>-v ).


    temp194 = sy-tabix.
    READ TABLE lt_param INDEX 2 ASSIGNING <temp193>.
    sy-tabix = temp194.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `1`
                                        act = <temp193>-v ).

  ENDMETHOD.

  METHOD test_url_create_empty_value.

    " an empty LAST value keeps its `=` - only the separator behind it goes
    DATA lt_params TYPE z2ui5_cl_ui5_util_context=>ty_t_name_value.

    DATA temp195 TYPE z2ui5_cl_ui5_util_context=>ty_t_name_value.
    DATA temp196 LIKE LINE OF temp195.
    CLEAR temp195.

    temp196-n = `a`.
    temp196-v = `1`.
    INSERT temp196 INTO TABLE temp195.
    temp196-n = `b`.
    temp196-v = ``.
    INSERT temp196 INTO TABLE temp195.
    lt_params = temp195.

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

    DATA temp197 TYPE ty_s_num.
    DATA ls_num LIKE temp197.
    DATA lt_pair TYPE z2ui5_cl_ui5_util_context=>ty_t_name_value.
    FIELD-SYMBOLS <temp198> LIKE LINE OF lt_pair.
    DATA temp199 LIKE sy-tabix.
    FIELD-SYMBOLS <temp200> LIKE LINE OF lt_pair.
    DATA temp201 LIKE sy-tabix.
    FIELD-SYMBOLS <temp202> LIKE LINE OF lt_pair.
    DATA temp203 LIKE sy-tabix.
    CLEAR temp197.
    temp197-count = -5.
    temp197-amount = `-12.50`.
    temp197-label = `abc`.

    ls_num = temp197.


    lt_pair = z2ui5_cl_ui5_util_context=>itab_get_by_struc( ls_num ).



    temp199 = sy-tabix.
    READ TABLE lt_pair WITH KEY n = `COUNT` ASSIGNING <temp198>.
    sy-tabix = temp199.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `-5`
                                        act = <temp198>-v ).


    temp201 = sy-tabix.
    READ TABLE lt_pair WITH KEY n = `AMOUNT` ASSIGNING <temp200>.
    sy-tabix = temp201.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `-12.50`
                                        act = <temp200>-v ).


    temp203 = sy-tabix.
    READ TABLE lt_pair WITH KEY n = `LABEL` ASSIGNING <temp202>.
    sy-tabix = temp203.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `abc`
                                        act = <temp202>-v ).

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

    cl_abap_unit_assert=>assert_true( z2ui5_cl_ui5_util_context=>rtti_check_class_exists( to_lower( lv_name ) ) ).
    cl_abap_unit_assert=>assert_true( z2ui5_cl_ui5_util_context=>rtti_check_class_exists( lv_name ) ).

  ENDMETHOD.

  METHOD test_class_exists_case.

    " the answer is cached per upper-case name, so the spelling of the FIRST
    " question must not decide the answer to every later one
    DATA li_app TYPE REF TO z2ui5_if_app.
    DATA lv_name TYPE string.
    lv_name = z2ui5_cl_ui5_util_context=>rtti_get_ref_type_name( li_app ).

    cl_abap_unit_assert=>assert_false( z2ui5_cl_ui5_util_context=>rtti_check_class_exists( `zz_no_such_class_4711` ) ).
    cl_abap_unit_assert=>assert_false( z2ui5_cl_ui5_util_context=>rtti_check_class_exists( `ZZ_NO_SUCH_CLASS_4711` ) ).
    cl_abap_unit_assert=>assert_false( z2ui5_cl_ui5_util_context=>rtti_check_class_exists( `` ) ).
    " an interface is no class
    cl_abap_unit_assert=>assert_equals(
        exp = z2ui5_cl_ui5_util_context=>rtti_check_class_exists( lv_name )
        act = z2ui5_cl_ui5_util_context=>rtti_check_class_exists( to_lower( lv_name ) ) ).

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
    FIELD-SYMBOLS <temp204> LIKE LINE OF lt_token.
    DATA temp205 LIKE sy-tabix.
    DATA temp206 TYPE z2ui5_cl_ui5_util_context=>ty_t_range.

    lv_sign   = `E`.
    lv_option = `BT`.
    ls_range-sign   = lv_sign.
    ls_range-option = lv_option.
    ls_range-low    = `1`.
    ls_range-high   = `5`.
    APPEND ls_range TO lt_range.


    lt_token = z2ui5_cl_ui5_util_context=>filter_get_token_t_by_range_t( lt_range ).



    temp205 = sy-tabix.
    READ TABLE lt_token INDEX 1 ASSIGNING <temp204>.
    sy-tabix = temp205.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `!(1...5)`
                                        act = <temp204>-key ).

    CLEAR temp206.
    cl_abap_unit_assert=>assert_initial( z2ui5_cl_ui5_util_context=>filter_get_token_t_by_range_t( temp206 ) ).

  ENDMETHOD.

  METHOD test_uuid_shape.

    DATA lv_first TYPE string.
    DATA lv_second TYPE string.
    DATA temp7 TYPE xsdboolean.
    lv_first = z2ui5_cl_ui5_util_context=>uuid_get_c32( ).

    lv_second = z2ui5_cl_ui5_util_context=>uuid_get_c32( ).

    cl_abap_unit_assert=>assert_equals( exp = 32
                                        act = strlen( lv_first ) ).

    temp7 = boolc( to_upper( lv_first ) CO `0123456789ABCDEF` ).
    cl_abap_unit_assert=>assert_true( temp7 ).
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
