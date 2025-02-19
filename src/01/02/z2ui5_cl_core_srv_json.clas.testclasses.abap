CLASS ltcl_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS request_json_to_abap FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_test IMPLEMENTATION.
  METHOD request_json_to_abap.

    DATA(lv_payload) = |\{"XX":\{"NAME":"test"\},"S_FRONT":\{"ID":"ID_NR","EDIT":\{"NAME":"test"\},"ORIGIN":"ORIGIN","PATHNAME":"PATHNAME","SEARCH":"SEARCH"| &&
            |,"VIEW":"MAIN","EVENT":"BUTTON_POST","T_EVENT_ARG":[]\}\}|.

    DATA(lo_mapper) = NEW z2ui5_cl_core_srv_json( ).
    DATA(ls_result) = lo_mapper->request_json_to_abap( lv_payload ).

    DATA(ls_exp) = VALUE z2ui5_if_core_types=>ty_s_request( s_front = VALUE #( id       = `ID_NR`
                                                                               view     = `MAIN`
                                                                               origin   = `ORIGIN`
                                                                               pathname = `PATHNAME`
                                                                               search   = `SEARCH`
                                                                               event    = `BUTTON_POST` ) ).

    cl_abap_unit_assert=>assert_equals( exp = ls_exp-s_front
                                        act = ls_result-s_front ).

    DATA(lt_tree) = VALUE z2ui5_if_ajson_types=>ty_nodes_ts( ).
    lt_tree = ls_result-o_model->mt_json_tree.

    cl_abap_unit_assert=>assert_equals( exp = `test`
                                        act = lt_tree[ name = `NAME` ]-value ).

    cl_abap_unit_assert=>assert_equals( exp = 3
                                        act = lines( lt_tree ) ).

  ENDMETHOD.

ENDCLASS.
