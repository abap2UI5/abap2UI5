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

ENDCLASS.


CLASS ltcl_test IMPLEMENTATION.

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

    " sap-startup-params is unwrapped wherever it sits in the query string -
    " as a later parameter, as the first/only parameter (typical FLP target
    " mapping), and with lowercase percent-encoding
    cl_abap_unit_assert=>assert_equals(
        exp = `foo`
        act = z2ui5_cl_ui5_util_context=>url_param_get(
                  val = `app_start`
                  url = `?x=1&sap-startup-params=app_start%3Dfoo` ) ).

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

ENDCLASS.


CLASS ltcl_string IMPLEMENTATION.

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

    DATA temp15 TYPE z2ui5_cl_ui5_util_context=>ty_t_name_value.
    DATA temp16 LIKE LINE OF temp15.
    CLEAR temp15.

    temp16-n = `a`.
    temp16-v = `1`.
    INSERT temp16 INTO TABLE temp15.
    temp16-n = `b`.
    temp16-v = `2`.
    INSERT temp16 INTO TABLE temp15.
    lt_params = temp15.

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

    METHODS test_attri_include    FOR TESTING RAISING cx_static_check.
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
    FIELD-SYMBOLS <temp17> LIKE LINE OF lt_comp.
    DATA temp18 LIKE sy-tabix.
    FIELD-SYMBOLS <temp19> LIKE LINE OF lt_comp.
    DATA temp20 LIKE sy-tabix.
    FIELD-SYMBOLS <temp21> LIKE LINE OF lt_comp.
    DATA temp22 LIKE sy-tabix.
    lt_comp = z2ui5_cl_ui5_util_context=>rtti_get_t_attri_by_any( ls_with_incl ).

    cl_abap_unit_assert=>assert_equals( exp = 3
                                        act = lines( lt_comp ) ).


    temp18 = sy-tabix.
    READ TABLE lt_comp INDEX 1 ASSIGNING <temp17>.
    sy-tabix = temp18.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `NAME`
                                        act = <temp17>-name ).


    temp20 = sy-tabix.
    READ TABLE lt_comp INDEX 2 ASSIGNING <temp19>.
    sy-tabix = temp20.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `CITY`
                                        act = <temp19>-name ).


    temp22 = sy-tabix.
    READ TABLE lt_comp INDEX 3 ASSIGNING <temp21>.
    sy-tabix = temp22.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `ZIP`
                                        act = <temp21>-name ).
    " no include entry survives the expansion (a plain READ: the downport
    " does not rewrite a line_exists( ) inside a method call argument)
    READ TABLE lt_comp WITH KEY as_include = abap_true TRANSPORTING NO FIELDS. "#EC CI_SORTSEQ
    cl_abap_unit_assert=>assert_subrc( exp = 4 ).

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
    DATA temp23 TYPE cl_abap_structdescr=>component_table.
    DATA temp24 LIKE LINE OF temp23.
    DATA temp1 TYPE REF TO cl_abap_datadescr.
    DATA lt_comp LIKE temp23.
    DATA lo_tab TYPE REF TO cl_abap_tabledescr.
    DATA lr_tab TYPE REF TO data.
    DATA temp2 TYPE xsdboolean.
    DATA temp3 TYPE xsdboolean.
    DATA lr_back TYPE REF TO data.
    CLEAR temp23.

    temp24-name = `COL1`.

    temp1 ?= cl_abap_datadescr=>describe_by_data( lv_col ).
    temp24-type = temp1.
    INSERT temp24 INTO TABLE temp23.

    lt_comp = temp23.

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
    FIELD-SYMBOLS <temp25> LIKE LINE OF lt_pair.
    DATA temp26 LIKE sy-tabix.
    FIELD-SYMBOLS <temp27> LIKE LINE OF lt_pair.
    DATA temp28 LIKE sy-tabix.

    ls_row-name = `Ada`.
    ls_row-city = `London`.


    lt_pair = z2ui5_cl_ui5_util_context=>itab_get_by_struc( ls_row ).

    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( lt_pair ) ).

    " component names come back from RTTI in upper case


    temp26 = sy-tabix.
    READ TABLE lt_pair WITH KEY n = `NAME` ASSIGNING <temp25>.
    sy-tabix = temp26.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `Ada`
                                        act = <temp25>-v ).


    temp28 = sy-tabix.
    READ TABLE lt_pair WITH KEY n = `CITY` ASSIGNING <temp27>.
    sy-tabix = temp28.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `London`
                                        act = <temp27>-v ).

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
    FIELD-SYMBOLS <temp29> LIKE LINE OF lt_found.
    DATA temp30 LIKE sy-tabix.

    ls_flags-flag_a = abap_true.
    ls_flags-flag_b = abap_false.
    ls_flags-other  = abap_true.


    lt_found = z2ui5_cl_ui5_util_context=>scan_flag_prefix( val = ls_flags
                                                               prefix = `FLAG_` ).

    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( lt_found ) ).


    temp30 = sy-tabix.
    READ TABLE lt_found INDEX 1 ASSIGNING <temp29>.
    sy-tabix = temp30.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `A`
                                        act = <temp29> ).

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
    METHODS test_corresponding      FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_itab IMPLEMENTATION.

  METHOD get_rows.

    DATA temp31 TYPE ltcl_itab=>ty_t_row.
    DATA temp32 LIKE LINE OF temp31.
    CLEAR temp31.

    temp32-name = `Ada`.
    temp32-city = `London`.
    INSERT temp32 INTO TABLE temp31.
    temp32-name = `Alan`.
    temp32-city = `Wilmslow`.
    INSERT temp32 INTO TABLE temp31.
    temp32-name = `Grace`.
    temp32-city = `New York`.
    INSERT temp32 INTO TABLE temp31.
    result = temp31.

  ENDMETHOD.

  METHOD test_filter_all_fields.

    " with no field list every component is searched, so a hit in `city`
    " keeps the row even though `name` does not match
    DATA lt_row TYPE ltcl_itab=>ty_t_row.
    FIELD-SYMBOLS <temp33> LIKE LINE OF lt_row.
    DATA temp34 LIKE sy-tabix.
    lt_row = get_rows( ).

    z2ui5_cl_ui5_util_context=>itab_filter_by_val( EXPORTING val = `London`
                                                CHANGING  tab    = lt_row ).

    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( lt_row ) ).


    temp34 = sy-tabix.
    READ TABLE lt_row INDEX 1 ASSIGNING <temp33>.
    sy-tabix = temp34.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `Ada`
                                        act = <temp33>-name ).

  ENDMETHOD.

  METHOD test_filter_ignore_case.

    DATA lt_row TYPE ltcl_itab=>ty_t_row.
    FIELD-SYMBOLS <temp35> LIKE LINE OF lt_row.
    DATA temp36 LIKE sy-tabix.
    lt_row = get_rows( ).

    z2ui5_cl_ui5_util_context=>itab_filter_by_val( EXPORTING val      = `ada`
                                                          ignore_case = abap_true
                                                CHANGING  tab         = lt_row ).

    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( lt_row ) ).


    temp36 = sy-tabix.
    READ TABLE lt_row INDEX 1 ASSIGNING <temp35>.
    sy-tabix = temp36.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `Ada`
                                        act = <temp35>-name ).

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

  METHOD test_filter_elementary.

    " a table with an elementary line type has no components - the filter
    " matches against the whole line instead of deleting every row
    DATA lt_str TYPE string_table.

    DATA temp37 TYPE string_table.
    FIELD-SYMBOLS <temp39> LIKE LINE OF lt_str.
    DATA temp40 LIKE sy-tabix.
    CLEAR temp37.
    INSERT `London` INTO TABLE temp37.
    INSERT `Wilmslow` INTO TABLE temp37.
    INSERT `New York` INTO TABLE temp37.
    lt_str = temp37.

    z2ui5_cl_ui5_util_context=>itab_filter_by_val( EXPORTING val = `London`
                                                CHANGING  tab    = lt_str ).

    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( lt_str ) ).


    temp40 = sy-tabix.
    READ TABLE lt_str INDEX 1 ASSIGNING <temp39>.
    sy-tabix = temp40.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `London`
                                        act = <temp39> ).

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
    FIELD-SYMBOLS <temp41> LIKE LINE OF lt_target.
    DATA temp42 LIKE sy-tabix.
    FIELD-SYMBOLS <temp43> LIKE LINE OF lt_target.
    DATA temp44 LIKE sy-tabix.
    lt_row = get_rows( ).

    z2ui5_cl_ui5_util_context=>itab_corresponding( EXPORTING val = lt_row
                                                CHANGING  tab    = lt_target ).

    cl_abap_unit_assert=>assert_equals( exp = 3
                                        act = lines( lt_target ) ).


    temp42 = sy-tabix.
    READ TABLE lt_target INDEX 1 ASSIGNING <temp41>.
    sy-tabix = temp42.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `Ada`
                                        act = <temp41>-name ).


    temp44 = sy-tabix.
    READ TABLE lt_target INDEX 1 ASSIGNING <temp43>.
    sy-tabix = temp44.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_initial( <temp43>-country ).

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
    METHODS test_box_no_msg_skips FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_msg IMPLEMENTATION.

  METHOD test_msg_type_mapping.

    " anything that is not E/S/W falls back to Information - the UI5
    " MessageBox has no other state to render
    cl_abap_unit_assert=>assert_equals( exp = `Error`
                                        act = z2ui5_cl_ui5_util_context=>ui5_get_msg_type( `E` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `Success`
                                        act = z2ui5_cl_ui5_util_context=>ui5_get_msg_type( `S` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `Warning`
                                        act = z2ui5_cl_ui5_util_context=>ui5_get_msg_type( `W` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `Information`
                                        act = z2ui5_cl_ui5_util_context=>ui5_get_msg_type( `I` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `Information`
                                        act = z2ui5_cl_ui5_util_context=>ui5_get_msg_type( `X` ) ).
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

    DATA temp45 TYPE z2ui5_cl_ui5_util_context=>ty_t_msg.
    DATA temp46 LIKE LINE OF temp45.
    DATA ls_box TYPE z2ui5_cl_ui5_util_context=>ty_s_msg_box.
    CLEAR temp45.

    temp46-text = `boom`.
    temp46-type = `E`.
    INSERT temp46 INTO TABLE temp45.
    lt_msg = temp45.


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
    " takes its severity from the first message
    DATA lt_msg TYPE z2ui5_cl_ui5_util_context=>ty_t_msg.

    DATA temp47 TYPE z2ui5_cl_ui5_util_context=>ty_t_msg.
    DATA temp48 LIKE LINE OF temp47.
    DATA ls_box TYPE z2ui5_cl_ui5_util_context=>ty_s_msg_box.
    CLEAR temp47.

    temp48-text = `first`.
    temp48-type = `W`.
    INSERT temp48 INTO TABLE temp47.
    temp48-text = `second`.
    temp48-type = `E`.
    INSERT temp48 INTO TABLE temp47.
    lt_msg = temp47.


    ls_box = z2ui5_cl_ui5_util_context=>ui5_msg_box_format( lt_msg ).

    cl_abap_unit_assert=>assert_false( ls_box-skip ).
    cl_abap_unit_assert=>assert_equals( exp = `Warning`
                                        act = ls_box-title ).
    cl_abap_unit_assert=>assert_equals(
        exp = `<ul><li>first</li><li>second</li></ul>`
        act = ls_box-details ).

  ENDMETHOD.

  METHOD test_box_multiple_escaped.

    " the texts are DATA inside the HTML list: a token in angle brackets is
    " shown as written instead of being dropped by the frontend sanitizer
    " as an unknown element - every sibling renderer escapes, this did not
    DATA lt_msg TYPE z2ui5_cl_ui5_util_context=>ty_t_msg.

    DATA temp49 TYPE z2ui5_cl_ui5_util_context=>ty_t_msg.
    DATA temp50 LIKE LINE OF temp49.
    DATA ls_box TYPE z2ui5_cl_ui5_util_context=>ty_s_msg_box.
    CLEAR temp49.

    temp50-text = `Enter a value for <MATNR>`.
    temp50-type = `E`.
    INSERT temp50 INTO TABLE temp49.
    temp50-text = `a & b`.
    temp50-type = `E`.
    INSERT temp50 INTO TABLE temp49.
    lt_msg = temp49.


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
    TYPES temp1 TYPE STANDARD TABLE OF ty_s_row WITH DEFAULT KEY.
DATA lt_row TYPE temp1.

    DATA temp51 LIKE lt_row.
    DATA temp52 LIKE LINE OF temp51.
    DATA ls_box TYPE z2ui5_cl_ui5_util_context=>ty_s_msg_box.
    CLEAR temp51.

    temp52-carrid = `LH`.
    temp52-seats = 12.
    INSERT temp52 INTO TABLE temp51.
    lt_row = temp51.


    ls_box = z2ui5_cl_ui5_util_context=>ui5_msg_box_format( lt_row ).

    cl_abap_unit_assert=>assert_true( ls_box-skip ).

  ENDMETHOD.

  METHOD test_token_by_range.

    " every range option maps to its own token text; the placeholders
    " {LOW}/{HIGH} are substituted from the range row
    DATA lt_range TYPE z2ui5_cl_ui5_util_context=>ty_t_range.

    DATA temp53 TYPE z2ui5_cl_ui5_util_context=>ty_t_range.
    DATA temp54 LIKE LINE OF temp53.
    DATA lt_token TYPE z2ui5_cl_ui5_util_context=>ty_t_token.
    FIELD-SYMBOLS <temp55> LIKE LINE OF lt_token.
    DATA temp56 LIKE sy-tabix.
    FIELD-SYMBOLS <temp57> LIKE LINE OF lt_token.
    DATA temp58 LIKE sy-tabix.
    FIELD-SYMBOLS <temp59> LIKE LINE OF lt_token.
    DATA temp60 LIKE sy-tabix.
    FIELD-SYMBOLS <temp61> LIKE LINE OF lt_token.
    DATA temp62 LIKE sy-tabix.
    FIELD-SYMBOLS <temp63> LIKE LINE OF lt_token.
    DATA temp64 LIKE sy-tabix.
    FIELD-SYMBOLS <temp65> LIKE LINE OF lt_token.
    DATA temp66 LIKE sy-tabix.
    CLEAR temp53.

    temp54-sign = `I`.
    temp54-option = `EQ`.
    temp54-low = `X`.
    INSERT temp54 INTO TABLE temp53.
    temp54-sign = `I`.
    temp54-option = `BT`.
    temp54-low = `1`.
    temp54-high = `9`.
    INSERT temp54 INTO TABLE temp53.
    temp54-sign = `I`.
    temp54-option = `CP`.
    temp54-low = `A`.
    INSERT temp54 INTO TABLE temp53.
    temp54-sign = `E`.
    temp54-option = `EQ`.
    temp54-low = `Y`.
    INSERT temp54 INTO TABLE temp53.
    lt_range = temp53.


    lt_token = z2ui5_cl_ui5_util_context=>filter_get_token_t_by_range_t( lt_range ).

    cl_abap_unit_assert=>assert_equals( exp = 4
                                        act = lines( lt_token ) ).


    temp56 = sy-tabix.
    READ TABLE lt_token INDEX 1 ASSIGNING <temp55>.
    sy-tabix = temp56.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `=X`
                                        act = <temp55>-key ).


    temp58 = sy-tabix.
    READ TABLE lt_token INDEX 2 ASSIGNING <temp57>.
    sy-tabix = temp58.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `1...9`
                                        act = <temp57>-key ).


    temp60 = sy-tabix.
    READ TABLE lt_token INDEX 3 ASSIGNING <temp59>.
    sy-tabix = temp60.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `*A*`
                                        act = <temp59>-key ).
    " an excluding row renders negated, not like its including twin


    temp62 = sy-tabix.
    READ TABLE lt_token INDEX 4 ASSIGNING <temp61>.
    sy-tabix = temp62.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `!(=Y)`
                                        act = <temp61>-key ).

    " tokens come back visible and editable so the UI5 MultiInput can render
    " and remove them


    temp64 = sy-tabix.
    READ TABLE lt_token INDEX 1 ASSIGNING <temp63>.
    sy-tabix = temp64.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_true( <temp63>-visible ).


    temp66 = sy-tabix.
    READ TABLE lt_token INDEX 1 ASSIGNING <temp65>.
    sy-tabix = temp66.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_true( <temp65>-editable ).

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
    DATA temp67 TYPE ty_s_tky.
    DATA ls_tky LIKE temp67.
    CLEAR temp67.
    temp67-product_uuid = `ABC-1`.
    temp67-product_id = `4711`.

    ls_tky = temp67.

    cl_abap_unit_assert=>assert_equals(
        exp = `PRODUCT_UUID=ABC-1, PRODUCT_ID=4711`
        act = z2ui5_cl_ui5_util_context=>msg_get_rap_flatten( ls_tky ) ).

  ENDMETHOD.

  METHOD test_flatten_skips_empty.

    " an initial component contributes nothing - not an empty pair and not a
    " dangling separator
    DATA temp68 TYPE ty_s_tky.
    DATA ls_tky LIKE temp68.
    CLEAR temp68.
    temp68-product_id = `4711`.

    ls_tky = temp68.

    cl_abap_unit_assert=>assert_equals(
        exp = `PRODUCT_ID=4711`
        act = z2ui5_cl_ui5_util_context=>msg_get_rap_flatten( ls_tky ) ).

  ENDMETHOD.

  METHOD test_flatten_nested.

    " a nested structure is flattened by the recursion, and its pairs join the
    " outer ones in component order
    DATA temp69 TYPE ty_s_nested.
    DATA ls_nested LIKE temp69.
    CLEAR temp69.
    CLEAR temp69-inner.
    temp69-inner-a = `1`.
    temp69-inner-b = `2`.
    temp69-c = `3`.

    ls_nested = temp69.

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
    DATA temp70 TYPE ty_s_plain.
    DATA ls_plain LIKE temp70.
    CLEAR temp70.
    temp70-name = `Ada`.
    temp70-city = `London`.

    ls_plain = temp70.

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

    lv_int = 42.


    ls_box = z2ui5_cl_ui5_util_context=>ui5_data_box_format( lv_int ).

    cl_abap_unit_assert=>assert_false( ls_box-skip ).
    cl_abap_unit_assert=>assert_equals( exp = `42`
                                        act = ls_box-text ).

  ENDMETHOD.

  METHOD test_table.

    " a business table: the headline counts, the details carry every row
    " with its component names
    DATA lt_row TYPE ty_t_row.

    DATA temp71 TYPE ltcl_data_box=>ty_t_row.
    DATA temp72 LIKE LINE OF temp71.
    DATA ls_box TYPE z2ui5_cl_ui5_util_context=>ty_s_msg_box.
    CLEAR temp71.

    temp72-carrid = `LH`.
    temp72-seats = 12.
    INSERT temp72 INTO TABLE temp71.
    lt_row = temp71.


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
    DATA temp2 TYPE ltcl_data_box=>ty_t_row.
    DATA temp3 LIKE LINE OF temp2.
    DATA ls_box TYPE z2ui5_cl_ui5_util_context=>ty_s_msg_box.

    CLEAR ls_node.
    ls_node-name = `root`.

    CLEAR temp2.

    temp3-carrid = `LH`.
    temp3-seats = 1.
    INSERT temp3 INTO TABLE temp2.
    ls_node-nodes = temp2.


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

    DATA temp73 TYPE ltcl_data_box=>ty_t_row.
    DATA temp74 LIKE LINE OF temp73.
    DATA ls_box TYPE z2ui5_cl_ui5_util_context=>ty_s_msg_box.
    CLEAR temp73.

    temp74-carrid = `</ul><script>`.
    INSERT temp74 INTO TABLE temp73.
    lt_row = temp73.


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
      DATA temp75 TYPE ltcl_data_box=>ty_s_row.
    DATA ls_box TYPE z2ui5_cl_ui5_util_context=>ty_s_msg_box.
    DATA temp6 TYPE xsdboolean.

    DO 105 TIMES.

      CLEAR temp75.
      temp75-seats = sy-index.
      INSERT temp75 INTO TABLE lt_row.
    ENDDO.


    ls_box = z2ui5_cl_ui5_util_context=>ui5_data_box_format( lt_row ).

    cl_abap_unit_assert=>assert_equals( exp = `Table with 105 entries`
                                        act = ls_box-text ).

    temp6 = boolc( ls_box-details CS `... 5 more entries` ).
    cl_abap_unit_assert=>assert_true( temp6 ).

  ENDMETHOD.

ENDCLASS.
