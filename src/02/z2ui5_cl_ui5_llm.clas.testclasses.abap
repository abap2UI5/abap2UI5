CLASS ltcl_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    METHODS test_create_local  FOR TESTING RAISING cx_static_check.
    METHODS test_create_claude FOR TESTING RAISING cx_static_check.
    METHODS test_create_openai FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_test IMPLEMENTATION.

  METHOD test_create_local.

    DATA(li_llm) = z2ui5_cl_ui5_llm=>create_local(
        t_rule = VALUE #( ( contains = `hello` answer = `Hello from abap2UI5.` ) ) ).

    DATA(ls_result) = li_llm->chat(
        VALUE #( ( role = z2ui5_if_ui5_llm=>cs_role-user content = `Hello there` ) ) ).

    cl_abap_unit_assert=>assert_equals( exp = `Hello from abap2UI5.`
                                        act = ls_result-text ).

  ENDMETHOD.

  METHOD test_create_claude.

    " no call - creating a provider reaches no network
    DATA(li_llm) = z2ui5_cl_ui5_llm=>create_claude( model   = `test-model`
                                                    api_key = `test-key` ).
    cl_abap_unit_assert=>assert_bound( li_llm ).

  ENDMETHOD.

  METHOD test_create_openai.

    DATA(li_llm) = z2ui5_cl_ui5_llm=>create_openai( model = `test-model`
                                                    url   = `http://localhost:11434/v1/chat/completions` ).
    cl_abap_unit_assert=>assert_bound( li_llm ).

  ENDMETHOD.

ENDCLASS.
