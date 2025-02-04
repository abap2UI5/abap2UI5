CLASS ltcl_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS request_json_to_abap FOR TESTING RAISING cx_static_check.
    METHODS test_empty_app FOR TESTING RAISING cx_static_check.

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



  METHOD test_empty_app.

    TRY.

        DATA(lv_payload) = |\{"S_FRONT":\{"CONFIG":\{"UI5VersionInfo":\{"version":"1.132.1","buildTimestamp":"202501211848","gav":"com.sap.openui5.dist:sdk:1.132.1:war"\},"pathname":"https://solid-robot-xgqpgj6wjqwfvw96-3000.app.github.dev/"\},"ORIG| &&
|IN":"https://solid-robot-xgqpgj6wjqwfvw96-3000.app.github.dev","PATHNAME":"/","HASH":""\}\}|.

        DATA(lo_mapper) = NEW z2ui5_cl_core_srv_json( ).
        DATA(ls_result) = lo_mapper->request_json_to_abap( lv_payload ).

        DATA(lo_comp) = ls_result-s_front-o_comp_data.
        DATA(lv_app_start) = lo_comp->get( `/startupParameters/app_start/1` ).

        cl_abap_unit_assert=>abort( ).

      CATCH cx_root.
        "exception is fine when there is no ap_start parameter
    ENDTRY.


  ENDMETHOD.

ENDCLASS.
