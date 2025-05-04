CLASS ltcl_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS request_json_to_abap FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_test IMPLEMENTATION.
  METHOD request_json_to_abap.

    DATA lv_payload TYPE string.
    DATA lo_mapper TYPE REF TO z2ui5_cl_core_srv_json.
    DATA ls_result TYPE z2ui5_if_core_types=>ty_s_request.
    DATA temp11 TYPE z2ui5_if_core_types=>ty_s_request.
    DATA ls_exp LIKE temp11.
    DATA temp12 TYPE z2ui5_if_ajson_types=>ty_nodes_ts.
    DATA lt_tree LIKE temp12.
    DATA temp13 LIKE LINE OF lt_tree.
    DATA temp14 LIKE sy-tabix.
    lv_payload = |\{"XX":\{"NAME":"test"\},"S_FRONT":\{"ID":"ID_NR","EDIT":\{"NAME":"test"\},"ORIGIN":"ORIGIN","PATHNAME":"PATHNAME","SEARCH":"SEARCH"| &&
            |,"VIEW":"MAIN","EVENT":"BUTTON_POST","T_EVENT_ARG":[]\}\}|.

    
    CREATE OBJECT lo_mapper TYPE z2ui5_cl_core_srv_json.
    
    ls_result = lo_mapper->request_json_to_abap( lv_payload ).

    
    CLEAR temp11.
    CLEAR temp11-s_front.
    temp11-s_front-id = `ID_NR`.
    temp11-s_front-view = `MAIN`.
    temp11-s_front-origin = `ORIGIN`.
    temp11-s_front-pathname = `PATHNAME`.
    temp11-s_front-search = `SEARCH`.
    temp11-s_front-event = `BUTTON_POST`.
    
    ls_exp = temp11.

    cl_abap_unit_assert=>assert_equals( exp = ls_exp-s_front
                                        act = ls_result-s_front ).

    
    CLEAR temp12.
    
    lt_tree = temp12.
    lt_tree = ls_result-o_model->mt_json_tree.

    
    
    temp14 = sy-tabix.
    READ TABLE lt_tree WITH KEY name = `NAME` INTO temp13.
    sy-tabix = temp14.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `test`
                                        act = temp13-value ).

    cl_abap_unit_assert=>assert_equals( exp = 3
                                        act = lines( lt_tree ) ).

  ENDMETHOD.

ENDCLASS.
