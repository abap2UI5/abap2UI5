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
    TYPES temp1 TYPE STANDARD TABLE OF ty_s_deep WITH DEFAULT KEY.
DATA lt_deep TYPE temp1.

    DATA temp52 LIKE lt_deep.
    DATA temp53 LIKE LINE OF temp52.
    DATA temp2 TYPE string_table.
    DATA temp4 TYPE string_table.
    FIELD-SYMBOLS <temp54> LIKE LINE OF lt_deep.
    DATA temp55 LIKE sy-tabix.
    CLEAR temp52.

    temp53-name = `Ada`.

    CLEAR temp2.
    INSERT `London` INTO TABLE temp2.
    temp53-children = temp2.
    INSERT temp53 INTO TABLE temp52.
    temp53-name = `Alan`.

    CLEAR temp4.
    INSERT `Wilmslow` INTO TABLE temp4.
    temp53-children = temp4.
    INSERT temp53 INTO TABLE temp52.
    lt_deep = temp52.

    z2ui5_cl_ui5_util_context=>itab_filter_by_val( EXPORTING val = `Alan`
                                                CHANGING  tab    = lt_deep ).

    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( lt_deep ) ).


    temp55 = sy-tabix.
    READ TABLE lt_deep INDEX 1 ASSIGNING <temp54>.
    sy-tabix = temp55.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `Alan`
                                        act = <temp54>-name ).

  ENDMETHOD.

  METHOD get_rows.

    DATA temp56 TYPE ltcl_itab=>ty_t_row.
    DATA temp57 LIKE LINE OF temp56.
    CLEAR temp56.

    temp57-name = `Ada`.
    temp57-city = `London`.
    INSERT temp57 INTO TABLE temp56.
    temp57-name = `Alan`.
    temp57-city = `Wilmslow`.
    INSERT temp57 INTO TABLE temp56.
    temp57-name = `Grace`.
    temp57-city = `New York`.
    INSERT temp57 INTO TABLE temp56.
    result = temp56.

  ENDMETHOD.

  METHOD test_filter_all_fields.

    " with no field list every component is searched, so a hit in `city`
    " keeps the row even though `name` does not match
    DATA lt_row TYPE ltcl_itab=>ty_t_row.
    FIELD-SYMBOLS <temp58> LIKE LINE OF lt_row.
    DATA temp59 LIKE sy-tabix.
    lt_row = get_rows( ).

    z2ui5_cl_ui5_util_context=>itab_filter_by_val( EXPORTING val = `London`
                                                CHANGING  tab    = lt_row ).

    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( lt_row ) ).


    temp59 = sy-tabix.
    READ TABLE lt_row INDEX 1 ASSIGNING <temp58>.
    sy-tabix = temp59.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `Ada`
                                        act = <temp58>-name ).

  ENDMETHOD.

  METHOD test_filter_ignore_case.

    DATA lt_row TYPE ltcl_itab=>ty_t_row.
    FIELD-SYMBOLS <temp60> LIKE LINE OF lt_row.
    DATA temp61 LIKE sy-tabix.
    lt_row = get_rows( ).

    z2ui5_cl_ui5_util_context=>itab_filter_by_val( EXPORTING val      = `ada`
                                                          ignore_case = abap_true
                                                CHANGING  tab         = lt_row ).

    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( lt_row ) ).


    temp61 = sy-tabix.
    READ TABLE lt_row INDEX 1 ASSIGNING <temp60>.
    sy-tabix = temp61.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `Ada`
                                        act = <temp60>-name ).

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
    TYPES temp2 TYPE STANDARD TABLE OF ty_s_deep WITH DEFAULT KEY.
DATA lt_deep   TYPE temp2.
    DATA lt_fields TYPE string_table.

    " a row with nothing printable used to match nothing and was deleted -
    " the empty search filtered where it should not filter at all
    DATA temp62 LIKE lt_deep.
    DATA temp63 LIKE LINE OF temp62.
    DATA temp6 TYPE string_table.
    DATA temp8 TYPE string_table.
    DATA lt_row TYPE ltcl_itab=>ty_t_row.
    DATA lv_blank TYPE c LENGTH 10.
    CLEAR temp62.


    CLEAR temp6.
    INSERT `London` INTO TABLE temp6.
    temp63-children = temp6.
    INSERT temp63 INTO TABLE temp62.

    CLEAR temp8.
    temp63-children = temp8.
    INSERT temp63 INTO TABLE temp62.
    lt_deep = temp62.
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

    DATA temp64 TYPE string_table.
    FIELD-SYMBOLS <temp66> LIKE LINE OF lt_str.
    DATA temp67 LIKE sy-tabix.
    CLEAR temp64.
    INSERT `London` INTO TABLE temp64.
    INSERT `Wilmslow` INTO TABLE temp64.
    INSERT `New York` INTO TABLE temp64.
    lt_str = temp64.

    z2ui5_cl_ui5_util_context=>itab_filter_by_val( EXPORTING val = `London`
                                                CHANGING  tab    = lt_str ).

    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( lt_str ) ).


    temp67 = sy-tabix.
    READ TABLE lt_str INDEX 1 ASSIGNING <temp66>.
    sy-tabix = temp67.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `London`
                                        act = <temp66> ).

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
    FIELD-SYMBOLS <temp68> LIKE LINE OF lt_target.
    DATA temp69 LIKE sy-tabix.
    FIELD-SYMBOLS <temp70> LIKE LINE OF lt_target.
    DATA temp71 LIKE sy-tabix.
    lt_row = get_rows( ).

    z2ui5_cl_ui5_util_context=>itab_corresponding( EXPORTING val = lt_row
                                                CHANGING  tab    = lt_target ).

    cl_abap_unit_assert=>assert_equals( exp = 3
                                        act = lines( lt_target ) ).


    temp69 = sy-tabix.
    READ TABLE lt_target INDEX 1 ASSIGNING <temp68>.
    sy-tabix = temp69.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `Ada`
                                        act = <temp68>-name ).


    temp71 = sy-tabix.
    READ TABLE lt_target INDEX 1 ASSIGNING <temp70>.
    sy-tabix = temp71.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_initial( <temp70>-country ).

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

    DATA temp72 TYPE ty_s_msg_like.
    DATA ls_empty LIKE temp72.
    CLEAR temp72.

    ls_empty = temp72.

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

    DATA temp73 TYPE ty_t_row.
    DATA temp74 LIKE LINE OF temp73.
    DATA lt_rows LIKE temp73.
    CLEAR temp73.

    temp74-id = `0001`.
    temp74-name = `Ada`.
    INSERT temp74 INTO TABLE temp73.
    temp74-id = `0002`.
    temp74-name = `Alan`.
    INSERT temp74 INTO TABLE temp73.

    lt_rows = temp73.

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

    DATA temp75 TYPE ty_s_row.
    DATA ls_row LIKE temp75.
    DATA ls_box TYPE z2ui5_cl_ui5_util_context=>ty_s_msg_box.
    CLEAR temp75.
    temp75-name = `Ada`.
    temp75-item = `0010`.

    ls_row = temp75.


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
    DATA temp76 TYPE ty_s_item.
    DATA temp77 TYPE ty_s_item.
    DATA lt_msg TYPE z2ui5_cl_ui5_util_context=>ty_t_msg.
    FIELD-SYMBOLS <temp78> LIKE LINE OF lt_msg.
    DATA temp79 LIKE sy-tabix.
    FIELD-SYMBOLS <temp80> LIKE LINE OF lt_msg.
    DATA temp81 LIKE sy-tabix.
    FIELD-SYMBOLS <temp82> LIKE LINE OF lt_msg.
    DATA temp83 LIKE sy-tabix.
    FIELD-SYMBOLS <temp84> LIKE LINE OF lt_msg.
    DATA temp85 LIKE sy-tabix.
    " the envelope's own type says Success and must NOT reach the messages
    ls_env-type = `S`.

    CLEAR temp76.
    temp76-type = `E`.
    temp76-message = `first`.
    APPEND temp76 TO ls_env-item.

    CLEAR temp77.
    temp77-type = `W`.
    temp77-message = `second`.
    APPEND temp77 TO ls_env-item.


    lt_msg = z2ui5_cl_ui5_util_context=>msg_get_t( ls_env ).

    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( lt_msg ) ).


    temp79 = sy-tabix.
    READ TABLE lt_msg INDEX 1 ASSIGNING <temp78>.
    sy-tabix = temp79.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `first`
                                        act = <temp78>-text ).


    temp81 = sy-tabix.
    READ TABLE lt_msg INDEX 1 ASSIGNING <temp80>.
    sy-tabix = temp81.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `E`
                                        act = <temp80>-type ).


    temp83 = sy-tabix.
    READ TABLE lt_msg INDEX 2 ASSIGNING <temp82>.
    sy-tabix = temp83.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `second`
                                        act = <temp82>-text ).


    temp85 = sy-tabix.
    READ TABLE lt_msg INDEX 2 ASSIGNING <temp84>.
    sy-tabix = temp85.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `W`
                                        act = <temp84>-type ).

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

    DATA temp86 TYPE ty_s_t100.
    DATA ls_t100 LIKE temp86.
    DATA lt_msg TYPE z2ui5_cl_ui5_util_context=>ty_t_msg.
    FIELD-SYMBOLS <temp87> LIKE LINE OF lt_msg.
    DATA temp88 LIKE sy-tabix.
    FIELD-SYMBOLS <temp89> LIKE LINE OF lt_msg.
    DATA temp90 LIKE sy-tabix.
    FIELD-SYMBOLS <temp91> LIKE LINE OF lt_msg.
    DATA temp92 LIKE sy-tabix.
    FIELD-SYMBOLS <temp93> LIKE LINE OF lt_msg.
    DATA temp94 LIKE sy-tabix.
    CLEAR temp86.
    temp86-id = `z2ui5_test`.
    temp86-number = '001'.
    temp86-type = `E`.
    temp86-message_v1 = `4711`.

    ls_t100 = temp86.


    lt_msg = z2ui5_cl_ui5_util_context=>msg_get_t( ls_t100 ).

    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( lt_msg ) ).
    " the parts the walk mapped by name, whatever the message class says


    temp88 = sy-tabix.
    READ TABLE lt_msg INDEX 1 ASSIGNING <temp87>.
    sy-tabix = temp88.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `Z2UI5_TEST`
                                        act = <temp87>-id ).


    temp90 = sy-tabix.
    READ TABLE lt_msg INDEX 1 ASSIGNING <temp89>.
    sy-tabix = temp90.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `E`
                                        act = <temp89>-type ).


    temp92 = sy-tabix.
    READ TABLE lt_msg INDEX 1 ASSIGNING <temp91>.
    sy-tabix = temp92.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `4711`
                                        act = <temp91>-v1 ).
    " and a text was assembled rather than left blank


    temp94 = sy-tabix.
    READ TABLE lt_msg INDEX 1 ASSIGNING <temp93>.
    sy-tabix = temp94.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_not_initial( <temp93>-text ).

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

    DATA temp95 TYPE z2ui5_cl_ui5_util_context=>ty_t_msg.
    DATA temp96 LIKE LINE OF temp95.
    DATA ls_box TYPE z2ui5_cl_ui5_util_context=>ty_s_msg_box.
    CLEAR temp95.

    temp96-text = `boom`.
    temp96-type = `E`.
    INSERT temp96 INTO TABLE temp95.
    lt_msg = temp95.


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

    DATA temp97 TYPE z2ui5_cl_ui5_util_context=>ty_t_msg.
    DATA temp98 LIKE LINE OF temp97.
    DATA ls_box TYPE z2ui5_cl_ui5_util_context=>ty_s_msg_box.
    DATA temp99 TYPE z2ui5_cl_ui5_util_context=>ty_t_msg.
    DATA temp100 LIKE LINE OF temp99.
    CLEAR temp97.

    temp98-text = `first`.
    temp98-type = `W`.
    INSERT temp98 INTO TABLE temp97.
    temp98-text = `second`.
    temp98-type = `E`.
    INSERT temp98 INTO TABLE temp97.
    lt_msg = temp97.


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

    CLEAR temp99.

    temp100-text = `a`.
    temp100-type = `S`.
    INSERT temp100 INTO TABLE temp99.
    temp100-text = `b`.
    temp100-type = `I`.
    INSERT temp100 INTO TABLE temp99.
    temp100-text = `c`.
    temp100-type = `W`.
    INSERT temp100 INTO TABLE temp99.
    lt_msg = temp99.
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

    DATA temp101 TYPE z2ui5_cl_ui5_util_context=>ty_t_msg.
    DATA temp102 LIKE LINE OF temp101.
    DATA ls_box TYPE z2ui5_cl_ui5_util_context=>ty_s_msg_box.
    CLEAR temp101.

    temp102-text = `Enter a value for <MATNR>`.
    temp102-type = `E`.
    INSERT temp102 INTO TABLE temp101.
    temp102-text = `a & b`.
    temp102-type = `E`.
    INSERT temp102 INTO TABLE temp101.
    lt_msg = temp101.


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
    TYPES temp3 TYPE STANDARD TABLE OF ty_s_row WITH DEFAULT KEY.
DATA lt_row TYPE temp3.

    DATA temp103 LIKE lt_row.
    DATA temp104 LIKE LINE OF temp103.
    DATA ls_box TYPE z2ui5_cl_ui5_util_context=>ty_s_msg_box.
    CLEAR temp103.

    temp104-carrid = `LH`.
    temp104-seats = 12.
    INSERT temp104 INTO TABLE temp103.
    lt_row = temp103.


    ls_box = z2ui5_cl_ui5_util_context=>ui5_msg_box_format( lt_row ).

    cl_abap_unit_assert=>assert_true( ls_box-skip ).

  ENDMETHOD.

  METHOD test_token_by_range.

    " every range option maps to its own token text; the placeholders
    " {LOW}/{HIGH} are substituted from the range row
    DATA lt_range TYPE z2ui5_cl_ui5_util_context=>ty_t_range.

    DATA temp105 TYPE z2ui5_cl_ui5_util_context=>ty_t_range.
    DATA temp106 LIKE LINE OF temp105.
    DATA lt_token TYPE z2ui5_cl_ui5_util_context=>ty_t_token.
    FIELD-SYMBOLS <temp107> LIKE LINE OF lt_token.
    DATA temp108 LIKE sy-tabix.
    FIELD-SYMBOLS <temp109> LIKE LINE OF lt_token.
    DATA temp110 LIKE sy-tabix.
    FIELD-SYMBOLS <temp111> LIKE LINE OF lt_token.
    DATA temp112 LIKE sy-tabix.
    FIELD-SYMBOLS <temp113> LIKE LINE OF lt_token.
    DATA temp114 LIKE sy-tabix.
    FIELD-SYMBOLS <temp115> LIKE LINE OF lt_token.
    DATA temp116 LIKE sy-tabix.
    FIELD-SYMBOLS <temp117> LIKE LINE OF lt_token.
    DATA temp118 LIKE sy-tabix.
    CLEAR temp105.

    CLEAR temp106.
    temp106-sign = `I`.
    temp106-option = `EQ`.
    temp106-low = `X`.
    INSERT temp106 INTO TABLE temp105.
    CLEAR temp106.
    temp106-sign = `I`.
    temp106-option = `BT`.
    temp106-low = `1`.
    temp106-high = `9`.
    INSERT temp106 INTO TABLE temp105.
    CLEAR temp106.
    temp106-sign = `I`.
    temp106-option = `CP`.
    temp106-low = `A`.
    INSERT temp106 INTO TABLE temp105.
    CLEAR temp106.
    temp106-sign = `E`.
    temp106-option = `EQ`.
    temp106-low = `Y`.
    INSERT temp106 INTO TABLE temp105.
    lt_range = temp105.


    lt_token = z2ui5_cl_ui5_util_context=>filter_get_token_t_by_range_t( lt_range ).

    cl_abap_unit_assert=>assert_equals( exp = 4
                                        act = lines( lt_token ) ).


    temp108 = sy-tabix.
    READ TABLE lt_token INDEX 1 ASSIGNING <temp107>.
    sy-tabix = temp108.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `=X`
                                        act = <temp107>-key ).


    temp110 = sy-tabix.
    READ TABLE lt_token INDEX 2 ASSIGNING <temp109>.
    sy-tabix = temp110.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `1...9`
                                        act = <temp109>-key ).


    temp112 = sy-tabix.
    READ TABLE lt_token INDEX 3 ASSIGNING <temp111>.
    sy-tabix = temp112.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `*A*`
                                        act = <temp111>-key ).
    " an excluding row renders negated, not like its including twin


    temp114 = sy-tabix.
    READ TABLE lt_token INDEX 4 ASSIGNING <temp113>.
    sy-tabix = temp114.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `!(=Y)`
                                        act = <temp113>-key ).

    " tokens come back visible and editable so the UI5 MultiInput can render
    " and remove them


    temp116 = sy-tabix.
    READ TABLE lt_token INDEX 1 ASSIGNING <temp115>.
    sy-tabix = temp116.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_true( <temp115>-visible ).


    temp118 = sy-tabix.
    READ TABLE lt_token INDEX 1 ASSIGNING <temp117>.
    sy-tabix = temp118.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_true( <temp117>-editable ).

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

    DATA temp119 TYPE ty_t_int_range.
    DATA temp120 LIKE LINE OF temp119.
    DATA lt_range LIKE temp119.
    DATA lt_token TYPE z2ui5_cl_ui5_util_context=>ty_t_token.
    FIELD-SYMBOLS <temp121> LIKE LINE OF lt_token.
    DATA temp122 LIKE sy-tabix.
    FIELD-SYMBOLS <temp123> LIKE LINE OF lt_token.
    DATA temp124 LIKE sy-tabix.
    CLEAR temp119.

    CLEAR temp120.
    temp120-sign = `I`.
    temp120-option = `EQ`.
    temp120-low = 42.
    INSERT temp120 INTO TABLE temp119.
    CLEAR temp120.
    temp120-sign = `I`.
    temp120-option = `BT`.
    temp120-low = -5.
    temp120-high = 10.
    INSERT temp120 INTO TABLE temp119.

    lt_range = temp119.


    lt_token = z2ui5_cl_ui5_util_context=>filter_get_token_t_by_range_t( lt_range ).



    temp122 = sy-tabix.
    READ TABLE lt_token INDEX 1 ASSIGNING <temp121>.
    sy-tabix = temp122.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `=42`
                                        act = <temp121>-key ).


    temp124 = sy-tabix.
    READ TABLE lt_token INDEX 2 ASSIGNING <temp123>.
    sy-tabix = temp124.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `-5...10`
                                        act = <temp123>-key ).

  ENDMETHOD.

  METHOD test_token_dollar_value.

    " LOW / HIGH are data and go into the token as written - `$&`, `$$` and
    " a backslash before a brace included, and a value that spells the other
    " placeholder is not substituted again
    DATA lt_range TYPE z2ui5_cl_ui5_util_context=>ty_t_range.

    DATA temp125 TYPE z2ui5_cl_ui5_util_context=>ty_t_range.
    DATA temp126 LIKE LINE OF temp125.
    DATA lt_token TYPE z2ui5_cl_ui5_util_context=>ty_t_token.
    FIELD-SYMBOLS <temp127> LIKE LINE OF lt_token.
    DATA temp128 LIKE sy-tabix.
    FIELD-SYMBOLS <temp129> LIKE LINE OF lt_token.
    DATA temp130 LIKE sy-tabix.
    FIELD-SYMBOLS <temp131> LIKE LINE OF lt_token.
    DATA temp132 LIKE sy-tabix.
    CLEAR temp125.

    CLEAR temp126.
    temp126-sign = `I`.
    temp126-option = `EQ`.
    temp126-low = `a$&b`.
    INSERT temp126 INTO TABLE temp125.
    CLEAR temp126.
    temp126-sign = `I`.
    temp126-option = `BT`.
    temp126-low = `$$`.
    temp126-high = `\{x\}`.
    INSERT temp126 INTO TABLE temp125.
    CLEAR temp126.
    temp126-sign = `I`.
    temp126-option = `BT`.
    temp126-low = `{HIGH}`.
    temp126-high = `9`.
    INSERT temp126 INTO TABLE temp125.
    lt_range = temp125.


    lt_token = z2ui5_cl_ui5_util_context=>filter_get_token_t_by_range_t( lt_range ).



    temp128 = sy-tabix.
    READ TABLE lt_token INDEX 1 ASSIGNING <temp127>.
    sy-tabix = temp128.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `=a$&b`
                                        act = <temp127>-key ).


    temp130 = sy-tabix.
    READ TABLE lt_token INDEX 2 ASSIGNING <temp129>.
    sy-tabix = temp130.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `$$...\{x\}`
                                        act = <temp129>-key ).


    temp132 = sy-tabix.
    READ TABLE lt_token INDEX 3 ASSIGNING <temp131>.
    sy-tabix = temp132.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `{HIGH}...9`
                                        act = <temp131>-key ).

  ENDMETHOD.

  METHOD test_token_odd_option.

    " a row without an option (appended with sign and low only), a lower-case
    " option and one the mapping does not know used to raise a raw
    " CX_SY_ITAB_LINE_NOT_FOUND for the whole table; they render as equality
    DATA lt_range TYPE z2ui5_cl_ui5_util_context=>ty_t_range.
    DATA ls_range LIKE LINE OF lt_range.
    DATA lv_option TYPE string.
    DATA lt_token TYPE z2ui5_cl_ui5_util_context=>ty_t_token.
    FIELD-SYMBOLS <temp133> LIKE LINE OF lt_token.
    DATA temp134 LIKE sy-tabix.
    FIELD-SYMBOLS <temp135> LIKE LINE OF lt_token.
    DATA temp136 LIKE sy-tabix.
    FIELD-SYMBOLS <temp137> LIKE LINE OF lt_token.
    DATA temp138 LIKE sy-tabix.

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


    temp134 = sy-tabix.
    READ TABLE lt_token INDEX 1 ASSIGNING <temp133>.
    sy-tabix = temp134.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `=X`
                                        act = <temp133>-key ).


    temp136 = sy-tabix.
    READ TABLE lt_token INDEX 2 ASSIGNING <temp135>.
    sy-tabix = temp136.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `=Y`
                                        act = <temp135>-key ).


    temp138 = sy-tabix.
    READ TABLE lt_token INDEX 3 ASSIGNING <temp137>.
    sy-tabix = temp138.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `=Z`
                                        act = <temp137>-key ).

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
    DATA temp139 TYPE ty_s_tky.
    DATA ls_tky LIKE temp139.
    CLEAR temp139.
    temp139-product_uuid = `ABC-1`.
    temp139-product_id = `4711`.

    ls_tky = temp139.

    cl_abap_unit_assert=>assert_equals(
        exp = `PRODUCT_UUID=ABC-1, PRODUCT_ID=4711`
        act = z2ui5_cl_ui5_util_context=>msg_get_rap_flatten( ls_tky ) ).

  ENDMETHOD.

  METHOD test_flatten_skips_empty.

    " an initial component contributes nothing - not an empty pair and not a
    " dangling separator
    DATA temp140 TYPE ty_s_tky.
    DATA ls_tky LIKE temp140.
    CLEAR temp140.
    temp140-product_id = `4711`.

    ls_tky = temp140.

    cl_abap_unit_assert=>assert_equals(
        exp = `PRODUCT_ID=4711`
        act = z2ui5_cl_ui5_util_context=>msg_get_rap_flatten( ls_tky ) ).

  ENDMETHOD.

  METHOD test_flatten_nested.

    " a nested structure is flattened by the recursion, and its pairs join the
    " outer ones in component order
    DATA temp141 TYPE ty_s_nested.
    DATA ls_nested LIKE temp141.
    CLEAR temp141.
    CLEAR temp141-inner.
    temp141-inner-a = `1`.
    temp141-inner-b = `2`.
    temp141-c = `3`.

    ls_nested = temp141.

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
    DATA temp142 TYPE ty_s_plain.
    DATA ls_plain LIKE temp142.
    CLEAR temp142.
    temp142-name = `Ada`.
    temp142-city = `London`.

    ls_plain = temp142.

    cl_abap_unit_assert=>assert_equals(
        exp = abap_false
        act = z2ui5_cl_ui5_util_context=>check_is_rap_struct( ls_plain ) ).

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

    DATA temp143 TYPE ltcl_data_box=>ty_t_row.
    DATA temp144 LIKE LINE OF temp143.
    DATA ls_box TYPE z2ui5_cl_ui5_util_context=>ty_s_msg_box.
    CLEAR temp143.

    temp144-carrid = `LH`.
    temp144-seats = 12.
    INSERT temp144 INTO TABLE temp143.
    lt_row = temp143.


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
    DATA temp9 TYPE ltcl_data_box=>ty_t_row.
    DATA temp10 LIKE LINE OF temp9.
    DATA ls_box TYPE z2ui5_cl_ui5_util_context=>ty_s_msg_box.

    CLEAR ls_node.
    ls_node-name = `root`.

    CLEAR temp9.

    temp10-carrid = `LH`.
    temp10-seats = 1.
    INSERT temp10 INTO TABLE temp9.
    ls_node-nodes = temp9.


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

    DATA temp145 TYPE ltcl_data_box=>ty_t_row.
    DATA temp146 LIKE LINE OF temp145.
    DATA ls_box TYPE z2ui5_cl_ui5_util_context=>ty_s_msg_box.
    CLEAR temp145.

    temp146-carrid = `</ul><script>`.
    INSERT temp146 INTO TABLE temp145.
    lt_row = temp145.


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
      DATA temp147 TYPE ltcl_data_box=>ty_s_row.
    DATA ls_box TYPE z2ui5_cl_ui5_util_context=>ty_s_msg_box.
    DATA temp6 TYPE xsdboolean.

    DO 105 TIMES.

      CLEAR temp147.
      temp147-seats = sy-index.
      INSERT temp147 INTO TABLE lt_row.
    ENDDO.


    ls_box = z2ui5_cl_ui5_util_context=>ui5_data_box_format( lt_row ).

    cl_abap_unit_assert=>assert_equals( exp = `Table with 105 entries`
                                        act = ls_box-text ).

    temp6 = boolc( ls_box-details CS `... 5 more entries` ).
    cl_abap_unit_assert=>assert_true( temp6 ).

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
    FIELD-SYMBOLS <temp148> LIKE LINE OF lt_param.
    DATA temp149 LIKE sy-tabix.
    FIELD-SYMBOLS <temp150> LIKE LINE OF lt_param.
    DATA temp151 LIKE sy-tabix.
    FIELD-SYMBOLS <temp152> LIKE LINE OF lt_param.
    DATA temp153 LIKE sy-tabix.
    lt_param = z2ui5_cl_ui5_util_context=>url_param_get_tab( `?debug&a=1` ).

    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( lt_param ) ).


    temp149 = sy-tabix.
    READ TABLE lt_param INDEX 1 ASSIGNING <temp148>.
    sy-tabix = temp149.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `debug`
                                        act = <temp148>-n ).


    temp151 = sy-tabix.
    READ TABLE lt_param INDEX 1 ASSIGNING <temp150>.
    sy-tabix = temp151.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_initial( <temp150>-v ).


    temp153 = sy-tabix.
    READ TABLE lt_param INDEX 2 ASSIGNING <temp152>.
    sy-tabix = temp153.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `1`
                                        act = <temp152>-v ).

  ENDMETHOD.

  METHOD test_url_create_empty_value.

    " an empty LAST value keeps its `=` - only the separator behind it goes
    DATA lt_params TYPE z2ui5_cl_ui5_util_context=>ty_t_name_value.

    DATA temp154 TYPE z2ui5_cl_ui5_util_context=>ty_t_name_value.
    DATA temp155 LIKE LINE OF temp154.
    CLEAR temp154.

    temp155-n = `a`.
    temp155-v = `1`.
    INSERT temp155 INTO TABLE temp154.
    temp155-n = `b`.
    temp155-v = ``.
    INSERT temp155 INTO TABLE temp154.
    lt_params = temp154.

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

    DATA temp156 TYPE ty_s_num.
    DATA ls_num LIKE temp156.
    DATA lt_pair TYPE z2ui5_cl_ui5_util_context=>ty_t_name_value.
    FIELD-SYMBOLS <temp157> LIKE LINE OF lt_pair.
    DATA temp158 LIKE sy-tabix.
    FIELD-SYMBOLS <temp159> LIKE LINE OF lt_pair.
    DATA temp160 LIKE sy-tabix.
    FIELD-SYMBOLS <temp161> LIKE LINE OF lt_pair.
    DATA temp162 LIKE sy-tabix.
    CLEAR temp156.
    temp156-count = -5.
    temp156-amount = `-12.50`.
    temp156-label = `abc`.

    ls_num = temp156.


    lt_pair = z2ui5_cl_ui5_util_context=>itab_get_by_struc( ls_num ).



    temp158 = sy-tabix.
    READ TABLE lt_pair WITH KEY n = `COUNT` ASSIGNING <temp157>.
    sy-tabix = temp158.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `-5`
                                        act = <temp157>-v ).


    temp160 = sy-tabix.
    READ TABLE lt_pair WITH KEY n = `AMOUNT` ASSIGNING <temp159>.
    sy-tabix = temp160.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `-12.50`
                                        act = <temp159>-v ).


    temp162 = sy-tabix.
    READ TABLE lt_pair WITH KEY n = `LABEL` ASSIGNING <temp161>.
    sy-tabix = temp162.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `abc`
                                        act = <temp161>-v ).

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
    FIELD-SYMBOLS <temp163> LIKE LINE OF lt_token.
    DATA temp164 LIKE sy-tabix.
    DATA temp165 TYPE z2ui5_cl_ui5_util_context=>ty_t_range.

    lv_sign   = `E`.
    lv_option = `BT`.
    ls_range-sign   = lv_sign.
    ls_range-option = lv_option.
    ls_range-low    = `1`.
    ls_range-high   = `5`.
    APPEND ls_range TO lt_range.


    lt_token = z2ui5_cl_ui5_util_context=>filter_get_token_t_by_range_t( lt_range ).



    temp164 = sy-tabix.
    READ TABLE lt_token INDEX 1 ASSIGNING <temp163>.
    sy-tabix = temp164.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `!(1...5)`
                                        act = <temp163>-key ).

    CLEAR temp165.
    cl_abap_unit_assert=>assert_initial( z2ui5_cl_ui5_util_context=>filter_get_token_t_by_range_t( temp165 ) ).

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
