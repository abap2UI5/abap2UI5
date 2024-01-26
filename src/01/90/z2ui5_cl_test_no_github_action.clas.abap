CLASS z2ui5_cl_test_no_github_action DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC FOR TESTING RISK LEVEL harmless.

  PUBLIC SECTION.

      METHODS test_trans_json_any_2__w_tab     FOR TESTING RAISING cx_static_check.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_test_no_github_action IMPLEMENTATION.

  METHOD test_trans_json_any_2__w_tab.

*    TYPES:
*      BEGIN OF ty_row,
*        title    TYPE string,
*        value    TYPE string,
*        selected TYPE abap_bool,
*      END OF ty_row.
*    TYPES ty_t_tab TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.
*
*    DATA(lt_tab) = VALUE ty_t_tab( ( title = 'Test'  value = 'this is a description' selected = abap_true )
*                                   ( title = 'Test2' value = 'this is a new descr'   selected = abap_false ) ).
*
*
*    DATA(lv_tab_json) = z2ui5_cl_util_func=>trans_json_by_any( lt_tab ).
*
*    DATA(lv_result) = `[{"TITLE":"Test","VALUE":"this is a description","SELECTED":true},{"TITLE":"Test2","VALUE":"this is a new descr","SELECTED":false}]`.
*
*    IF lv_result <> lv_tab_json.
*      cl_abap_unit_assert=>fail(  ).
*    ENDIF.

  ENDMETHOD.

ENDCLASS.
