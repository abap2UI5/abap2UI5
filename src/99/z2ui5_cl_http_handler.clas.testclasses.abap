" What this class IS, is the whole test: an empty subclass of
" z2ui5_cl_ui5_http_handler that exists so an ICF handler written against the
" old name keeps working. It declares nothing of its own, so there is nothing
" of its own to test - and the 355-line copy of the parent's suite that used to
" sit here tested the parent, twice, while making the parent's coverage report
" unreadable (the same statements attributed across two files).
"
" What a frozen alias promises is exactly two things, and they are what is
" asserted below: it still resolves, and what it resolves to is the released
" behaviour rather than a fork of it.
CLASS ltcl_test_alias DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    METHODS test_alias_resolves       FOR TESTING RAISING cx_static_check.
    METHODS test_alias_is_not_a_fork  FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_test_alias IMPLEMENTATION.

  METHOD test_alias_resolves.

    " an ICF handler on the old name reaches the same entry point
    DATA(ls_result) = z2ui5_cl_http_handler=>_http_get( ).

    cl_abap_unit_assert=>assert_equals( exp = 200
                                        act = ls_result-status_code ).

  ENDMETHOD.


  METHOD test_alias_is_not_a_fork.

    " byte-identical to what the released class returns: the alias adds
    " nothing and overrides nothing, which is the only reason it is safe to
    " leave frozen
    cl_abap_unit_assert=>assert_equals(
        exp = z2ui5_cl_ui5_http_handler=>_http_get( )-body
        act = z2ui5_cl_http_handler=>_http_get( )-body ).

    DATA ls_req TYPE z2ui5_cl_ui5_http_handler=>ty_s_http_req.
    ls_req-method = `POST`.
    ls_req-body   = `{"value":{"S_FRONT":{"ORIGIN":"O","PATHNAME":"/p","SEARCH":""}}}`.

    cl_abap_unit_assert=>assert_equals(
        exp = z2ui5_cl_ui5_http_handler=>_http_post( ls_req )-status_code
        act = z2ui5_cl_http_handler=>_http_post( ls_req )-status_code ).

  ENDMETHOD.

ENDCLASS.
