CLASS ltcl_test DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    METHODS request_json_to_abap FOR TESTING RAISING cx_static_check.
    METHODS model_front_to_back FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_test IMPLEMENTATION.

  METHOD request_json_to_abap.


    DATA(lv_payload) = `{"EDIT":{"NAME":"test"},"ARGUMENTS":[],"S_FRONTEND":{"ID":"ID_NR","EDIT":{"NAME":"test"},"ORIGIN":"ORIGIN","PATHNAME":"PATHNAME","SEARCH":"SEARCH"` &&
            `,"VIEWNAME":"MAIN","EVENT":"BUTTON_POST","T_EVENT_ARG":[]}}`.

    DATA(lo_mapper) = NEW z2ui5_cl_core_json_srv( ).
    DATA(ls_result) = lo_mapper->request_json_to_abap( lv_payload ).

    DATA(ls_exp) = VALUE z2ui5_if_core_types=>ty_s_http_request_post(
        s_frontend = VALUE #(
        id = `ID_NR`
        view    = `MAIN`
        origin = `ORIGIN`
        pathname = `PATHNAME`
        search   = `SEARCH`
        event   =  `BUTTON_POST`
    ) ).

    cl_abap_unit_assert=>assert_equals(
        act = ls_result-s_frontend
        exp = ls_exp-s_frontend ).

    DATA lt_tree TYPE z2ui5_if_ajson_types=>ty_nodes_ts.
    lt_tree = ls_result-o_model->mt_json_tree.

    cl_abap_unit_assert=>assert_equals(
       act = lt_tree[ name = `NAME` ]-value
       exp = `test` ).

    cl_abap_unit_assert=>assert_equals(
       act = lines( lt_tree )
       exp = 2 ).

  ENDMETHOD.

  METHOD model_front_to_back.

*      NEW z2ui5_cl_core_json_srv( )->model_front_to_back(
*         viewname = `MAIN`
*         app      = lo_ap
*         t_attri  = lt_attri
*         model    = lo_ajson ).

  ENDMETHOD.


ENDCLASS.
