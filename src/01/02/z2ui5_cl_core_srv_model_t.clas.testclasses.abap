CLASS lcl_app_01 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION MEDIUM.

  PUBLIC SECTION.
    DATA mr_tab  TYPE REF TO data.

ENDCLASS.

CLASS lcl_app_01 IMPLEMENTATION.

ENDCLASS.

CLASS lcl_test_01 DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    METHODS tab_ref_gen FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS lcl_test_01 IMPLEMENTATION.

  METHOD tab_ref_gen.
    DATA lo_app TYPE REF TO lcl_app_01.
TYPES BEGIN OF ty_s_row.
TYPES comp1 TYPE string.
TYPES comp2 TYPE string.
TYPES END OF ty_s_row.
    TYPES ty_t_tab TYPE STANDARD TABLE OF ty_s_row WITH DEFAULT KEY.
    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
    DATA temp1 TYPE ty_s_row.
    DATA temp2 TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA lt_attri LIKE temp2.
    DATA temp3 LIKE REF TO lt_attri.
DATA lo_model TYPE REF TO z2ui5_cl_core_srv_model.
    DATA ls_attri TYPE REF TO z2ui5_if_core_types=>ty_s_attri.
    DATA temp4 LIKE REF TO lt_attri.

    IF sy-sysid = 'ABC'.
      RETURN.
    ENDIF.


    "create data
    
    CREATE OBJECT lo_app TYPE lcl_app_01.

    
    

    CREATE DATA lo_app->mr_tab TYPE ty_t_tab.
    
    ASSIGN lo_app->mr_tab->* TO <tab>.
    
    CLEAR temp1.
    temp1-comp1 = 'comp1'.
    temp1-comp2 = 'comp2'.
    INSERT temp1 INTO TABLE <tab>.



    "test find binding
    
    CLEAR temp2.
    
    lt_attri = temp2.
    
    GET REFERENCE OF lt_attri INTO temp3.

CREATE OBJECT lo_model TYPE z2ui5_cl_core_srv_model EXPORTING attri = temp3 app = lo_app.

    
    ls_attri = lo_model->main_attri_search( lo_app->mr_tab ).

    IF ls_attri->name <> 'MR_TAB->*'.
      cl_abap_unit_assert=>abort( ).
    ENDIF.



    "test frontend backend draft
    lo_model->main_attri_db_save_srtti( ).

    CREATE OBJECT lo_app TYPE lcl_app_01.
    
    GET REFERENCE OF lt_attri INTO temp4.
CREATE OBJECT lo_model TYPE z2ui5_cl_core_srv_model EXPORTING attri = temp4 app = lo_app.
    lo_model->main_attri_db_load( ).

    IF lo_app->mr_tab IS NOT BOUND.
      cl_abap_unit_assert=>abort( ).
    ENDIF.

  ENDMETHOD.
ENDCLASS.
