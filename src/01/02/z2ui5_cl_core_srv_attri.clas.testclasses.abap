
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
    CREATE OBJECT lo_app_client TYPE ltcl_test_app2.
    DATA lr_value TYPE REF TO data.
    GET REFERENCE OF lo_app_client->mv_value INTO lr_value.

    DATA temp14 TYPE z2ui5_if_core_types=>ty_t_attri.
    CLEAR temp14.
    DATA temp15 LIKE LINE OF temp14.
    temp15-r_ref = lr_value.
    temp15-o_typedescr = cl_abap_datadescr=>describe_by_data_ref(
lr_value ).
    INSERT temp15 INTO TABLE temp14.
    DATA lt_attri LIKE temp14.
    lt_attri = temp14.

    DATA temp16 LIKE REF TO lt_attri.
    GET REFERENCE OF lt_attri INTO temp16.
DATA lo_model TYPE REF TO z2ui5_cl_core_srv_attri.
CREATE OBJECT lo_model TYPE z2ui5_cl_core_srv_attri EXPORTING attri = temp16 app = lo_app_client.

    DATA temp17 LIKE REF TO lo_app_client->mv_value.
    GET REFERENCE OF lo_app_client->mv_value INTO temp17.
DATA lr_attri TYPE REF TO z2ui5_if_core_types=>ty_s_attri.
lr_attri = lo_model->attri_search_a_dissolve( temp17 ).

    IF lr_attri->r_ref <> lr_value.
      cl_abap_unit_assert=>abort( ).
    ENDIF.

  ENDMETHOD.

  METHOD second_test.

    DATA lo_app_client TYPE REF TO ltcl_test_app2.
    CREATE OBJECT lo_app_client TYPE ltcl_test_app2.
    DATA lr_value TYPE REF TO data.
    GET REFERENCE OF lo_app_client->mv_value INTO lr_value.

    DATA temp18 LIKE REF TO lo_app_client->mv_value.
    GET REFERENCE OF lo_app_client->mv_value INTO temp18.
DATA temp1 TYPE z2ui5_if_core_types=>ty_t_attri.
CLEAR temp1.
DATA temp2 LIKE LINE OF temp1.
temp2-r_ref = temp18.
temp2-o_typedescr = cl_abap_datadescr=>describe_by_data_ref(
lr_value ).
INSERT temp2 INTO TABLE temp1.
DATA lt_attri LIKE temp1.
lt_attri = temp1.

    DATA temp19 LIKE REF TO lt_attri.
    GET REFERENCE OF lt_attri INTO temp19.
DATA lo_model TYPE REF TO z2ui5_cl_core_srv_attri.
CREATE OBJECT lo_model TYPE z2ui5_cl_core_srv_attri EXPORTING attri = temp19 app = lo_app_client.

    DATA temp20 LIKE REF TO lo_app_client->mv_value.
    GET REFERENCE OF lo_app_client->mv_value INTO temp20.
DATA lr_attri TYPE REF TO z2ui5_if_core_types=>ty_s_attri.
lr_attri = lo_model->attri_search_a_dissolve( temp20 ).

    IF lr_attri->r_ref <> lr_value.
      cl_abap_unit_assert=>abort( ).
    ENDIF.

  ENDMETHOD.

  METHOD third_test.

    DATA lo_app_client TYPE REF TO ltcl_test_app2.
    CREATE OBJECT lo_app_client TYPE ltcl_test_app2.
    DATA lr_value TYPE REF TO data.
    GET REFERENCE OF lo_app_client->mv_value INTO lr_value.

    CREATE OBJECT lo_app_client->mo_app.

    DATA temp21 LIKE REF TO lo_app_client->mv_value.
    GET REFERENCE OF lo_app_client->mv_value INTO temp21.
DATA temp3 LIKE REF TO lo_app_client->mo_app.
GET REFERENCE OF lo_app_client->mo_app INTO temp3.
DATA temp1 LIKE REF TO lo_app_client->mr_value2.
GET REFERENCE OF lo_app_client->mr_value2 INTO temp1.
DATA temp2 LIKE REF TO lo_app_client->mr_value.
GET REFERENCE OF lo_app_client->mr_value INTO temp2.
DATA temp4 TYPE z2ui5_if_core_types=>ty_t_attri.
CLEAR temp4.
DATA temp5 LIKE LINE OF temp4.
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
temp5-r_ref = temp21.
INSERT temp5 INTO TABLE temp4.
DATA lt_attri LIKE temp4.
lt_attri = temp4.

    FIELD-SYMBOLS <temp22> TYPE z2ui5_if_core_types=>ty_s_attri.
    READ TABLE lt_attri WITH KEY r_ref = lr_value ASSIGNING <temp22>.
IF sy-subrc <> 0.
  ASSERT 1 = 0.
ENDIF.
DATA lr_attri LIKE REF TO <temp22>.
GET REFERENCE OF <temp22> INTO lr_attri.
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
    CREATE OBJECT lo_app_client TYPE ltcl_test_app3.
    " TODO: variable is assigned but never used (ABAP cleaner)
    DATA lr_value TYPE REF TO data.
    GET REFERENCE OF lo_app_client->mv_value INTO lr_value.

    DATA temp23 TYPE z2ui5_if_core_types=>ty_t_attri.
    CLEAR temp23.
    DATA lt_attri LIKE temp23.
    lt_attri = temp23.

    DATA temp24 LIKE REF TO lt_attri.
    GET REFERENCE OF lt_attri INTO temp24.
DATA lo_model TYPE REF TO z2ui5_cl_core_srv_attri.
CREATE OBJECT lo_model TYPE z2ui5_cl_core_srv_attri EXPORTING attri = temp24 app = lo_app_client.

    DATA lr_attri TYPE REF TO data.
    lr_attri = lo_model->attri_get_val_ref( `MV_VALUE` ).

    DATA temp25 LIKE REF TO lo_app_client->mv_value.
    GET REFERENCE OF lo_app_client->mv_value INTO temp25.
IF temp25 <> lr_attri.
      cl_abap_unit_assert=>abort( ).
    ENDIF.

  ENDMETHOD.

  METHOD second_test.

    DATA lo_app_client TYPE REF TO ltcl_test_app3.
    CREATE OBJECT lo_app_client TYPE ltcl_test_app3.
    CREATE DATA lo_app_client->mr_value.

    DATA temp26 TYPE z2ui5_if_core_types=>ty_t_attri.
    CLEAR temp26.
    DATA lt_attri LIKE temp26.
    lt_attri = temp26.
    DATA temp27 LIKE REF TO lt_attri.
    GET REFERENCE OF lt_attri INTO temp27.
DATA lo_model TYPE REF TO z2ui5_cl_core_srv_attri.
CREATE OBJECT lo_model TYPE z2ui5_cl_core_srv_attri EXPORTING attri = temp27 app = lo_app_client.

    DATA lr_attri TYPE REF TO data.
    lr_attri = lo_model->attri_get_val_ref( `MR_VALUE->*` ).

    IF lr_attri <> lo_app_client->mr_value.
      cl_abap_unit_assert=>abort( ).
    ENDIF.

  ENDMETHOD.

  METHOD third_test.

    DATA lo_app_client TYPE REF TO ltcl_test_app3.
    CREATE OBJECT lo_app_client TYPE ltcl_test_app3.

    DATA temp28 TYPE z2ui5_if_core_types=>ty_t_attri.
    CLEAR temp28.
    DATA lt_attri LIKE temp28.
    lt_attri = temp28.
    DATA temp29 LIKE REF TO lt_attri.
    GET REFERENCE OF lt_attri INTO temp29.
DATA lo_model TYPE REF TO z2ui5_cl_core_srv_attri.
CREATE OBJECT lo_model TYPE z2ui5_cl_core_srv_attri EXPORTING attri = temp29 app = lo_app_client.

    DATA lr_attri TYPE REF TO data.
    lr_attri = lo_model->attri_get_val_ref( `MO_APP->MV_VALUE` ).

    DATA temp30 LIKE REF TO lo_app_client->mo_app->mv_value.
    GET REFERENCE OF lo_app_client->mo_app->mv_value INTO temp30.
IF temp30 <> lr_attri.
      cl_abap_unit_assert=>abort( ).
    ENDIF.

  ENDMETHOD.

  METHOD test4.

    DATA lo_app_client TYPE REF TO ltcl_test_app3.
    CREATE OBJECT lo_app_client TYPE ltcl_test_app3.
    CREATE DATA lo_app_client->mo_app->mr_value.

    DATA temp31 TYPE z2ui5_if_core_types=>ty_t_attri.
    CLEAR temp31.
    DATA lt_attri LIKE temp31.
    lt_attri = temp31.
    DATA temp32 LIKE REF TO lt_attri.
    GET REFERENCE OF lt_attri INTO temp32.
DATA lo_model TYPE REF TO z2ui5_cl_core_srv_attri.
CREATE OBJECT lo_model TYPE z2ui5_cl_core_srv_attri EXPORTING attri = temp32 app = lo_app_client.

    DATA lr_attri TYPE REF TO data.
    lr_attri = lo_model->attri_get_val_ref( `MO_APP->MR_VALUE->*` ).

    IF lr_attri <> lo_app_client->mo_app->mr_value.
      cl_abap_unit_assert=>abort( ).
    ENDIF.

  ENDMETHOD.
ENDCLASS.
