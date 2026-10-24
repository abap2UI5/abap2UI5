CLASS ltcl_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    METHODS test_create_local  FOR TESTING RAISING cx_static_check.
    METHODS test_create_claude FOR TESTING RAISING cx_static_check.
    METHODS test_create_openai FOR TESTING RAISING cx_static_check.
    METHODS test_guide         FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_test IMPLEMENTATION.

  METHOD test_create_local.

    DATA temp1 TYPE z2ui5_cl_ui5_llm=>ty_t_rule.
    DATA temp2 LIKE LINE OF temp1.
    DATA li_llm TYPE REF TO z2ui5_if_ui5_llm.
    DATA temp3 TYPE z2ui5_if_ui5_llm=>ty_t_message.
    DATA temp4 LIKE LINE OF temp3.
    DATA ls_result TYPE z2ui5_if_ui5_llm=>ty_s_result.
    CLEAR temp1.

    temp2-contains = `hello`.
    temp2-answer = `Hello from abap2UI5.`.
    INSERT temp2 INTO TABLE temp1.

    li_llm = z2ui5_cl_ui5_llm=>create_local(
        t_rule = temp1 ).


    CLEAR temp3.

    temp4-role = z2ui5_if_ui5_llm=>cs_role-user.
    temp4-content = `Hello there`.
    INSERT temp4 INTO TABLE temp3.

    ls_result = li_llm->chat(
        temp3 ).

    cl_abap_unit_assert=>assert_equals( exp = `Hello from abap2UI5.`
                                        act = ls_result-text ).

  ENDMETHOD.

  METHOD test_create_claude.

    " no call - creating a provider reaches no network
    DATA li_llm TYPE REF TO z2ui5_if_ui5_llm.
    li_llm = z2ui5_cl_ui5_llm=>create_claude( model   = `test-model`
                                                    api_key = `test-key` ).
    cl_abap_unit_assert=>assert_bound( li_llm ).

  ENDMETHOD.

  METHOD test_create_openai.

    DATA li_llm TYPE REF TO z2ui5_if_ui5_llm.
    li_llm = z2ui5_cl_ui5_llm=>create_openai( model = `test-model`
                                                    url   = `http://localhost:11434/v1/chat/completions` ).
    cl_abap_unit_assert=>assert_bound( li_llm ).

  ENDMETHOD.

  METHOD test_guide.

    " the whole guide, its first line to its last - the class is generated
    " in chained statements of 400 lines, and a lost statement would cut it
    DATA lv_guide TYPE string.
    DATA temp1 TYPE xsdboolean.
    DATA temp2 TYPE xsdboolean.
    lv_guide = z2ui5_cl_ui5_llm=>guide( ).

    " its first line at offset 0 - not CP, whose # escapes the next character
    cl_abap_unit_assert=>assert_equals( exp = 0
                                        act = find( val = lv_guide sub = `# Building apps with abap2UI5` ) ).

    temp1 = boolc( lv_guide CS `z2ui5_if_app` ).
    cl_abap_unit_assert=>assert_true( temp1 ).

    temp2 = boolc( lv_guide CS `the user waits for the whole answer.` ).
    cl_abap_unit_assert=>assert_true( temp2 ).

  ENDMETHOD.

ENDCLASS.
