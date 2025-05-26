
CLASS ltcl_test_app2 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION MEDIUM.

  PUBLIC SECTION.

    DATA mv_value  TYPE string ##NEEDED.
    DATA mr_value  TYPE REF TO data.
    DATA mr_value2 TYPE REF TO data.
    DATA mo_app    TYPE REF TO ltcl_test_app2.

    DATA xx        TYPE string ##NEEDED.

    METHODS constructor.
ENDCLASS.


CLASS ltcl_test_app2 IMPLEMENTATION.
  METHOD constructor.

  ENDMETHOD.
ENDCLASS.


CLASS ltcl_test_search_attri DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS first_test  FOR TESTING RAISING cx_static_check.
    METHODS second_test FOR TESTING RAISING cx_static_check.
    METHODS third_test  FOR TESTING RAISING cx_static_check.

ENDCLASS.

CLASS z2ui5_cl_core_srv_attri DEFINITION LOCAL FRIENDS ltcl_test_search_attri.

CLASS ltcl_test_search_attri IMPLEMENTATION.
  METHOD first_test.

    DATA lo_app_client TYPE REF TO ltcl_test_app2.
    DATA lr_value TYPE REF TO data.
    DATA temp1 TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA temp2 LIKE LINE OF temp1.
    DATA lt_attri LIKE temp1.
    DATA temp3 LIKE REF TO lt_attri.
DATA lo_model TYPE REF TO z2ui5_cl_core_srv_attri.
    DATA temp4 LIKE REF TO lo_app_client->mv_value.
DATA lr_attri TYPE REF TO z2ui5_if_core_types=>ty_s_attri.
    CREATE OBJECT lo_app_client TYPE ltcl_test_app2.
    
    GET REFERENCE OF lo_app_client->mv_value INTO lr_value.

    
    CLEAR temp1.
    
    temp2-r_ref = lr_value.
    temp2-o_typedescr = cl_abap_datadescr=>describe_by_data_ref(
lr_value ).
    INSERT temp2 INTO TABLE temp1.
    
    lt_attri = temp1.

    
    GET REFERENCE OF lt_attri INTO temp3.

CREATE OBJECT lo_model TYPE z2ui5_cl_core_srv_attri EXPORTING attri = temp3 app = lo_app_client.

    
    GET REFERENCE OF lo_app_client->mv_value INTO temp4.

lr_attri = lo_model->attri_search_a_dissolve( temp4 ).

    IF lr_attri->r_ref <> lr_value.
      cl_abap_unit_assert=>abort( ).
    ENDIF.

  ENDMETHOD.

  METHOD second_test.

    DATA lo_app_client TYPE REF TO ltcl_test_app2.
    DATA lr_value TYPE REF TO data.
    DATA temp5 LIKE REF TO lo_app_client->mv_value.
DATA temp1 TYPE z2ui5_if_core_types=>ty_t_attri.
DATA temp2 LIKE LINE OF temp1.
DATA lt_attri LIKE temp1.
    DATA temp6 LIKE REF TO lt_attri.
DATA lo_model TYPE REF TO z2ui5_cl_core_srv_attri.
    DATA temp7 LIKE REF TO lo_app_client->mv_value.
DATA lr_attri TYPE REF TO z2ui5_if_core_types=>ty_s_attri.
    CREATE OBJECT lo_app_client TYPE ltcl_test_app2.
    
    GET REFERENCE OF lo_app_client->mv_value INTO lr_value.

    
    GET REFERENCE OF lo_app_client->mv_value INTO temp5.

CLEAR temp1.

temp2-r_ref = temp5.
temp2-o_typedescr = cl_abap_datadescr=>describe_by_data_ref(
lr_value ).
INSERT temp2 INTO TABLE temp1.

lt_attri = temp1.

    
    GET REFERENCE OF lt_attri INTO temp6.

CREATE OBJECT lo_model TYPE z2ui5_cl_core_srv_attri EXPORTING attri = temp6 app = lo_app_client.

    
    GET REFERENCE OF lo_app_client->mv_value INTO temp7.

lr_attri = lo_model->attri_search_a_dissolve( temp7 ).

    IF lr_attri->r_ref <> lr_value.
      cl_abap_unit_assert=>abort( ).
    ENDIF.

  ENDMETHOD.

  METHOD third_test.

    DATA lo_app_client TYPE REF TO ltcl_test_app2.
    DATA lr_value TYPE REF TO data.
    DATA temp8 LIKE REF TO lo_app_client->mv_value.
DATA temp3 LIKE REF TO lo_app_client->mo_app.
DATA temp1 LIKE REF TO lo_app_client->mr_value2.
DATA temp2 LIKE REF TO lo_app_client->mr_value.
DATA temp4 TYPE z2ui5_if_core_types=>ty_t_attri.
DATA temp5 LIKE LINE OF temp4.
DATA lt_attri LIKE temp4.
    FIELD-SYMBOLS <temp9> TYPE z2ui5_if_core_types=>ty_s_attri.
DATA lr_attri LIKE REF TO <temp9>.
    CREATE OBJECT lo_app_client TYPE ltcl_test_app2.
    
    GET REFERENCE OF lo_app_client->mv_value INTO lr_value.

    CREATE OBJECT lo_app_client->mo_app.

    
    GET REFERENCE OF lo_app_client->mv_value INTO temp8.

GET REFERENCE OF lo_app_client->mo_app INTO temp3.

GET REFERENCE OF lo_app_client->mr_value2 INTO temp1.

GET REFERENCE OF lo_app_client->mr_value INTO temp2.

CLEAR temp4.

temp5-name = `1`.
temp5-r_ref = temp2.
INSERT temp5 INTO TABLE temp4.
temp5-name = `4`.
temp5-r_ref = temp1.
INSERT temp5 INTO TABLE temp4.
temp5-name = `2`.
temp5-r_ref = temp3.
INSERT temp5 INTO TABLE temp4.
temp5-name = `3`.
temp5-r_ref = temp8.
INSERT temp5 INTO TABLE temp4.

lt_attri = temp4.

    
    READ TABLE lt_attri WITH KEY r_ref = lr_value ASSIGNING <temp9>.
IF sy-subrc <> 0.
  ASSERT 1 = 0.
ENDIF.

GET REFERENCE OF <temp9> INTO lr_attri.
    IF lr_attri->r_ref <> lr_value.
      cl_abap_unit_assert=>abort( ).
    ENDIF.

  ENDMETHOD.
ENDCLASS.


CLASS ltcl_test_app_sub DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION MEDIUM.

  PUBLIC SECTION.

    DATA mv_value TYPE string ##NEEDED.
    DATA mr_value TYPE REF TO string.
*    DATA mr_value2 TYPE REF TO data.

    METHODS constructor.
ENDCLASS.


CLASS ltcl_test_app_sub IMPLEMENTATION.
  METHOD constructor.

  ENDMETHOD.
ENDCLASS.


CLASS ltcl_test_app3 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION MEDIUM.

  PUBLIC SECTION.

    DATA mv_value TYPE string ##NEEDED.
    DATA mr_value TYPE REF TO string.
*    DATA mr_value2 TYPE REF TO data.
    DATA mo_app   TYPE REF TO ltcl_test_app_sub.

    METHODS constructor.
ENDCLASS.


CLASS ltcl_test_app3 IMPLEMENTATION.
  METHOD constructor.
    CREATE OBJECT mo_app.
  ENDMETHOD.
ENDCLASS.


CLASS ltcl_test_get_attri DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS first_test  FOR TESTING RAISING cx_static_check.
    METHODS second_test FOR TESTING RAISING cx_static_check.
    METHODS third_test  FOR TESTING RAISING cx_static_check.
    METHODS test4       FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_test_get_attri IMPLEMENTATION.
  METHOD first_test.

    DATA lo_app_client TYPE REF TO ltcl_test_app3.
    DATA lr_value TYPE REF TO data.
    DATA temp10 TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA lt_attri LIKE temp10.
    DATA temp11 LIKE REF TO lt_attri.
DATA lo_model TYPE REF TO z2ui5_cl_core_srv_attri.
    DATA lr_attri TYPE REF TO data.
    DATA temp12 LIKE REF TO lo_app_client->mv_value.
    CREATE OBJECT lo_app_client TYPE ltcl_test_app3.
    " TODO: variable is assigned but never used (ABAP cleaner)
    
    GET REFERENCE OF lo_app_client->mv_value INTO lr_value.

    
    CLEAR temp10.
    
    lt_attri = temp10.

    
    GET REFERENCE OF lt_attri INTO temp11.

CREATE OBJECT lo_model TYPE z2ui5_cl_core_srv_attri EXPORTING attri = temp11 app = lo_app_client.

    
    lr_attri = lo_model->attri_get_val_ref( `MV_VALUE` ).

    
    GET REFERENCE OF lo_app_client->mv_value INTO temp12.
IF temp12 <> lr_attri.
      cl_abap_unit_assert=>abort( ).
    ENDIF.

  ENDMETHOD.

  METHOD second_test.

    DATA lo_app_client TYPE REF TO ltcl_test_app3.
    DATA temp13 TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA lt_attri LIKE temp13.
    DATA temp14 LIKE REF TO lt_attri.
DATA lo_model TYPE REF TO z2ui5_cl_core_srv_attri.
    DATA lr_attri TYPE REF TO data.
    CREATE OBJECT lo_app_client TYPE ltcl_test_app3.
    CREATE DATA lo_app_client->mr_value.

    
    CLEAR temp13.
    
    lt_attri = temp13.
    
    GET REFERENCE OF lt_attri INTO temp14.

CREATE OBJECT lo_model TYPE z2ui5_cl_core_srv_attri EXPORTING attri = temp14 app = lo_app_client.

    
    lr_attri = lo_model->attri_get_val_ref( `MR_VALUE->*` ).

    IF lr_attri <> lo_app_client->mr_value.
      cl_abap_unit_assert=>abort( ).
    ENDIF.

  ENDMETHOD.

  METHOD third_test.

    DATA lo_app_client TYPE REF TO ltcl_test_app3.
    DATA temp15 TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA lt_attri LIKE temp15.
    DATA temp16 LIKE REF TO lt_attri.
DATA lo_model TYPE REF TO z2ui5_cl_core_srv_attri.
    DATA lr_attri TYPE REF TO data.
    DATA temp17 LIKE REF TO lo_app_client->mo_app->mv_value.
    CREATE OBJECT lo_app_client TYPE ltcl_test_app3.

    
    CLEAR temp15.
    
    lt_attri = temp15.
    
    GET REFERENCE OF lt_attri INTO temp16.

CREATE OBJECT lo_model TYPE z2ui5_cl_core_srv_attri EXPORTING attri = temp16 app = lo_app_client.

    
    lr_attri = lo_model->attri_get_val_ref( `MO_APP->MV_VALUE` ).

    
    GET REFERENCE OF lo_app_client->mo_app->mv_value INTO temp17.
IF temp17 <> lr_attri.
      cl_abap_unit_assert=>abort( ).
    ENDIF.

  ENDMETHOD.

  METHOD test4.

    DATA lo_app_client TYPE REF TO ltcl_test_app3.
    DATA temp18 TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA lt_attri LIKE temp18.
    DATA temp19 LIKE REF TO lt_attri.
DATA lo_model TYPE REF TO z2ui5_cl_core_srv_attri.
    DATA lr_attri TYPE REF TO data.
    CREATE OBJECT lo_app_client TYPE ltcl_test_app3.
    CREATE DATA lo_app_client->mo_app->mr_value.

    
    CLEAR temp18.
    
    lt_attri = temp18.
    
    GET REFERENCE OF lt_attri INTO temp19.

CREATE OBJECT lo_model TYPE z2ui5_cl_core_srv_attri EXPORTING attri = temp19 app = lo_app_client.

    
    lr_attri = lo_model->attri_get_val_ref( `MO_APP->MR_VALUE->*` ).

    IF lr_attri <> lo_app_client->mo_app->mr_value.
      cl_abap_unit_assert=>abort( ).
    ENDIF.

  ENDMETHOD.
ENDCLASS.
