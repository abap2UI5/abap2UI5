CLASS ltcl_test_dissolve DEFINITION DEFERRED.
CLASS z2ui5_cl_core_srv_model DEFINITION LOCAL FRIENDS ltcl_test_dissolve.



CLASS ltcl_test_dissolve DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PUBLIC SECTION.

    TYPES:
      BEGIN OF s_01,
        input TYPE string,
        BEGIN OF s_02,
          input TYPE string,
          BEGIN OF s_03,
            input TYPE string,
            BEGIN OF s_04,
              input TYPE string,
            END OF s_04,
          END OF s_03,
        END OF s_02,
      END OF s_01.

    TYPES:
      BEGIN OF ty_s_struc,
        r_ref TYPE REF TO data,
        s_01  TYPE s_01,
      END OF ty_s_struc.

    DATA ms_struc  TYPE s_01 ##NEEDED.
    DATA mv_value  TYPE string ##NEEDED.
    DATA mr_value  TYPE REF TO data.
    DATA mr_struc  TYPE REF TO s_01.
    DATA mo_app    TYPE REF TO ltcl_test_dissolve.

    DATA ms_struc2 TYPE ty_s_struc.

  PRIVATE SECTION.
    METHODS test_init            FOR TESTING RAISING cx_static_check.
    METHODS test_struc           FOR TESTING RAISING cx_static_check.
    METHODS test_dref            FOR TESTING RAISING cx_static_check.
    METHODS test_struc_dref      FOR TESTING RAISING cx_static_check.
    METHODS test_oref            FOR TESTING RAISING cx_static_check.
    METHODS test_ref             FOR TESTING RAISING cx_static_check.
    METHODS test_oref_dref_struc FOR TESTING RAISING cx_static_check.
    METHODS test_oref_dref       FOR TESTING RAISING cx_static_check.
    METHODS test_dref_struc      FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_test_dissolve IMPLEMENTATION.

  METHOD test_ref.

*    DATA(lo_app) = NEW ltcl_test_dissolve( ).
*
*    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
*    DATA(lo_model) = NEW z2ui5_cl_core_srv_model( attri = REF #( lt_attri )
*                                                 app   = lo_app ).
*
*    lo_model->dissolve( ).
*
*    DATA(ls_attri) = lt_attri[ name = `MV_VALUE` ].
*    GET REFERENCE OF lo_app->mv_value INTO DATA(lr_ref).

*    IF ls_attri-r_ref <> lr_ref.
*      cl_abap_unit_assert=>abort( ).
*    ENDIF.

  ENDMETHOD.

  METHOD test_init.

    DATA lo_app TYPE REF TO ltcl_test_dissolve.
    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA temp1 LIKE REF TO lt_attri.
DATA lo_model TYPE REF TO z2ui5_cl_core_srv_model.
    DATA temp2 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp3 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp4 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp5 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp6 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp7 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp8 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp9 TYPE z2ui5_if_core_types=>ty_s_attri.
    CREATE OBJECT lo_app TYPE ltcl_test_dissolve.

    
    
    GET REFERENCE OF lt_attri INTO temp1.

CREATE OBJECT lo_model TYPE z2ui5_cl_core_srv_model EXPORTING attri = temp1 app = lo_app.

    lo_model->dissolve( ).
    lo_model->dissolve( ).
    lo_model->dissolve( ).

    
    CLEAR temp2.
    
    READ TABLE lt_attri INTO temp3 WITH KEY name = `MR_STRUC`.
    IF sy-subrc = 0.
      temp2 = temp3.
    ENDIF.
    cl_abap_unit_assert=>assert_not_initial( temp2 ).
    
    CLEAR temp4.
    
    READ TABLE lt_attri INTO temp5 WITH KEY name = `MR_VALUE`.
    IF sy-subrc = 0.
      temp4 = temp5.
    ENDIF.
    cl_abap_unit_assert=>assert_not_initial( temp4 ).
    
    CLEAR temp6.
    
    READ TABLE lt_attri INTO temp7 WITH KEY name = `MS_STRUC`.
    IF sy-subrc = 0.
      temp6 = temp7.
    ENDIF.
    cl_abap_unit_assert=>assert_not_initial( temp6 ).
    
    CLEAR temp8.
    
    READ TABLE lt_attri INTO temp9 WITH KEY name = `MV_VALUE`.
    IF sy-subrc = 0.
      temp8 = temp9.
    ENDIF.
    cl_abap_unit_assert=>assert_not_initial( temp8 ).

  ENDMETHOD.

  METHOD test_dref.

    DATA lo_app TYPE REF TO ltcl_test_dissolve.
    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA temp10 LIKE REF TO lt_attri.
DATA lo_model TYPE REF TO z2ui5_cl_core_srv_model.
    DATA temp11 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp12 TYPE z2ui5_if_core_types=>ty_s_attri.
    CREATE OBJECT lo_app TYPE ltcl_test_dissolve.
    CREATE DATA lo_app->mr_struc.
    CREATE DATA lo_app->mr_value TYPE string.

    
    
    GET REFERENCE OF lt_attri INTO temp10.

CREATE OBJECT lo_model TYPE z2ui5_cl_core_srv_model EXPORTING attri = temp10 app = lo_app.

    lo_model->dissolve( ).
    lo_model->dissolve( ).

    
    CLEAR temp11.
    
    READ TABLE lt_attri INTO temp12 WITH KEY name = `MR_VALUE->*`.
    IF sy-subrc = 0.
      temp11 = temp12.
    ENDIF.
    cl_abap_unit_assert=>assert_not_initial( temp11 ).

  ENDMETHOD.

  METHOD test_oref.

    DATA lo_app TYPE REF TO ltcl_test_dissolve.
    DATA lo_app2 TYPE REF TO ltcl_test_dissolve.
    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA temp13 LIKE REF TO lt_attri.
DATA lo_model TYPE REF TO z2ui5_cl_core_srv_model.
    DATA temp14 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp15 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp16 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp17 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp18 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp19 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp20 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp21 TYPE z2ui5_if_core_types=>ty_s_attri.
    CREATE OBJECT lo_app TYPE ltcl_test_dissolve.
    CREATE OBJECT lo_app->mo_app.
    
    CREATE OBJECT lo_app2 TYPE ltcl_test_dissolve.
    lo_app2->mo_app = lo_app.

    CREATE DATA lo_app->mo_app->mr_struc.
    CREATE DATA lo_app->mo_app->mr_value TYPE string.

    
    
    GET REFERENCE OF lt_attri INTO temp13.

CREATE OBJECT lo_model TYPE z2ui5_cl_core_srv_model EXPORTING attri = temp13 app = lo_app2.

    lo_model->dissolve( ).
    lo_model->dissolve( ).
    lo_model->dissolve( ).

    
    CLEAR temp14.
    
    READ TABLE lt_attri INTO temp15 WITH KEY name = `MO_APP->MV_VALUE`.
    IF sy-subrc = 0.
      temp14 = temp15.
    ENDIF.
    cl_abap_unit_assert=>assert_not_initial( temp14 ).
    
    CLEAR temp16.
    
    READ TABLE lt_attri INTO temp17 WITH KEY name = `MO_APP->MR_STRUC`.
    IF sy-subrc = 0.
      temp16 = temp17.
    ENDIF.
    cl_abap_unit_assert=>assert_not_initial( temp16 ).
    
    CLEAR temp18.
    
    READ TABLE lt_attri INTO temp19 WITH KEY name = `MO_APP->MR_VALUE`.
    IF sy-subrc = 0.
      temp18 = temp19.
    ENDIF.
    cl_abap_unit_assert=>assert_not_initial( temp18 ).
    
    CLEAR temp20.
    
    READ TABLE lt_attri INTO temp21 WITH KEY name = `MO_APP->MS_STRUC`.
    IF sy-subrc = 0.
      temp20 = temp21.
    ENDIF.
    cl_abap_unit_assert=>assert_not_initial( temp20 ).

  ENDMETHOD.

  METHOD test_struc.

    DATA lo_app TYPE REF TO ltcl_test_dissolve.
    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA temp22 LIKE REF TO lt_attri.
DATA lo_model TYPE REF TO z2ui5_cl_core_srv_model.
    DATA temp23 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp24 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp25 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp26 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp27 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp28 TYPE z2ui5_if_core_types=>ty_s_attri.
    CREATE OBJECT lo_app TYPE ltcl_test_dissolve.
    
    
    GET REFERENCE OF lt_attri INTO temp22.

CREATE OBJECT lo_model TYPE z2ui5_cl_core_srv_model EXPORTING attri = temp22 app = lo_app.

    lo_model->dissolve( ).
    lo_model->dissolve( ).
    lo_model->dissolve( ).
    lo_model->dissolve( ).
    lo_model->dissolve( ).

    
    CLEAR temp23.
    
    READ TABLE lt_attri INTO temp24 WITH KEY name = `MS_STRUC-INPUT`.
    IF sy-subrc = 0.
      temp23 = temp24.
    ENDIF.
    cl_abap_unit_assert=>assert_not_initial( temp23 ).
    
    CLEAR temp25.
    
    READ TABLE lt_attri INTO temp26 WITH KEY name = `MS_STRUC-S_02-INPUT`.
    IF sy-subrc = 0.
      temp25 = temp26.
    ENDIF.
    cl_abap_unit_assert=>assert_not_initial( temp25 ).
    
    CLEAR temp27.
    
    READ TABLE lt_attri INTO temp28 WITH KEY name = `MS_STRUC-S_02-S_03-S_04-INPUT`.
    IF sy-subrc = 0.
      temp27 = temp28.
    ENDIF.
    cl_abap_unit_assert=>assert_not_initial( temp27 ).

  ENDMETHOD.

  METHOD test_dref_struc.

    DATA lo_app TYPE REF TO ltcl_test_dissolve.
    DATA lo_app2 TYPE REF TO ltcl_test_dissolve.
    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA temp29 LIKE REF TO lt_attri.
DATA lo_model TYPE REF TO z2ui5_cl_core_srv_model.
    DATA temp30 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp31 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp32 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp33 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp34 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp35 TYPE z2ui5_if_core_types=>ty_s_attri.
    CREATE OBJECT lo_app TYPE ltcl_test_dissolve.
    CREATE OBJECT lo_app->mo_app.
    
    CREATE OBJECT lo_app2 TYPE ltcl_test_dissolve.
    lo_app2->mo_app = lo_app.

    CREATE DATA lo_app->mr_struc.

    
    
    GET REFERENCE OF lt_attri INTO temp29.

CREATE OBJECT lo_model TYPE z2ui5_cl_core_srv_model EXPORTING attri = temp29 app = lo_app.

    lo_model->dissolve( ).
    lo_model->dissolve( ).
    lo_model->dissolve( ).

    
    CLEAR temp30.
    
    READ TABLE lt_attri INTO temp31 WITH KEY name = `MR_STRUC`.
    IF sy-subrc = 0.
      temp30 = temp31.
    ENDIF.
    cl_abap_unit_assert=>assert_not_initial( temp30 ).
    
    CLEAR temp32.
    
    READ TABLE lt_attri INTO temp33 WITH KEY name = `MR_STRUC->INPUT`.
    IF sy-subrc = 0.
      temp32 = temp33.
    ENDIF.
    cl_abap_unit_assert=>assert_not_initial( temp32 ).
    
    CLEAR temp34.
    
    READ TABLE lt_attri INTO temp35 WITH KEY name = `MR_STRUC->S_02-INPUT`.
    IF sy-subrc = 0.
      temp34 = temp35.
    ENDIF.
    cl_abap_unit_assert=>assert_not_initial( temp34 ).

  ENDMETHOD.

  METHOD test_oref_dref.

    DATA lo_app TYPE REF TO ltcl_test_dissolve.
    DATA lo_app2 TYPE REF TO ltcl_test_dissolve.
    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA temp36 LIKE REF TO lt_attri.
DATA lo_model TYPE REF TO z2ui5_cl_core_srv_model.
    DATA temp37 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp38 TYPE z2ui5_if_core_types=>ty_s_attri.
    CREATE OBJECT lo_app TYPE ltcl_test_dissolve.
    CREATE OBJECT lo_app->mo_app.
    
    CREATE OBJECT lo_app2 TYPE ltcl_test_dissolve.
    lo_app->mo_app = lo_app2.

    CREATE DATA lo_app2->mr_value TYPE string.

    
    
    GET REFERENCE OF lt_attri INTO temp36.

CREATE OBJECT lo_model TYPE z2ui5_cl_core_srv_model EXPORTING attri = temp36 app = lo_app.

    lo_model->dissolve( ).
    lo_model->dissolve( ).
    lo_model->dissolve( ).

    
    CLEAR temp37.
    
    READ TABLE lt_attri INTO temp38 WITH KEY name = `MO_APP->MR_VALUE->*`.
    IF sy-subrc = 0.
      temp37 = temp38.
    ENDIF.
    cl_abap_unit_assert=>assert_not_initial( temp37 ).

  ENDMETHOD.

  METHOD test_oref_dref_struc.

    DATA lo_app TYPE REF TO ltcl_test_dissolve.
    DATA lo_app2 TYPE REF TO ltcl_test_dissolve.
    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA temp39 LIKE REF TO lt_attri.
DATA lo_model TYPE REF TO z2ui5_cl_core_srv_model.
    DATA temp40 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp41 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp42 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp43 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp44 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp45 TYPE z2ui5_if_core_types=>ty_s_attri.
    CREATE OBJECT lo_app TYPE ltcl_test_dissolve.
    CREATE OBJECT lo_app->mo_app.
    
    CREATE OBJECT lo_app2 TYPE ltcl_test_dissolve.
    lo_app->mo_app = lo_app2.

    CREATE DATA lo_app->mo_app->mr_struc.

    
    
    GET REFERENCE OF lt_attri INTO temp39.

CREATE OBJECT lo_model TYPE z2ui5_cl_core_srv_model EXPORTING attri = temp39 app = lo_app.

    lo_model->dissolve( ).
    lo_model->dissolve( ).
    lo_model->dissolve( ).
    lo_model->dissolve( ).

    
    CLEAR temp40.
    
    READ TABLE lt_attri INTO temp41 WITH KEY name = `MO_APP->MR_STRUC`.
    IF sy-subrc = 0.
      temp40 = temp41.
    ENDIF.
    cl_abap_unit_assert=>assert_not_initial( temp40 ).
    
    CLEAR temp42.
    
    READ TABLE lt_attri INTO temp43 WITH KEY name = `MO_APP->MR_STRUC->INPUT`.
    IF sy-subrc = 0.
      temp42 = temp43.
    ENDIF.
    cl_abap_unit_assert=>assert_not_initial( temp42 ).
    
    CLEAR temp44.
    
    READ TABLE lt_attri INTO temp45 WITH KEY name = `MO_APP->MR_STRUC->S_02-INPUT`.
    IF sy-subrc = 0.
      temp44 = temp45.
    ENDIF.
    cl_abap_unit_assert=>assert_not_initial( temp44 ).

  ENDMETHOD.

  METHOD test_struc_dref.

    DATA lo_app TYPE REF TO ltcl_test_dissolve.
    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA temp46 LIKE REF TO lt_attri.
DATA lo_model TYPE REF TO z2ui5_cl_core_srv_model.
    DATA temp47 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp48 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp49 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp50 TYPE z2ui5_if_core_types=>ty_s_attri.
    CREATE OBJECT lo_app TYPE ltcl_test_dissolve.
    CREATE OBJECT lo_app->mo_app.
    CREATE DATA lo_app->mo_app->ms_struc2-r_ref TYPE string.

    
    
    GET REFERENCE OF lt_attri INTO temp46.

CREATE OBJECT lo_model TYPE z2ui5_cl_core_srv_model EXPORTING attri = temp46 app = lo_app.

    lo_model->dissolve( ).
    lo_model->dissolve( ).
    lo_model->dissolve( ).
    lo_model->dissolve( ).

    
    CLEAR temp47.
    
    READ TABLE lt_attri INTO temp48 WITH KEY name = `MO_APP->MS_STRUC2-R_REF`.
    IF sy-subrc = 0.
      temp47 = temp48.
    ENDIF.
    cl_abap_unit_assert=>assert_not_initial( temp47 ).
    
    CLEAR temp49.
    
    READ TABLE lt_attri INTO temp50 WITH KEY name = `MO_APP->MS_STRUC2-R_REF->*`.
    IF sy-subrc = 0.
      temp49 = temp50.
    ENDIF.
    cl_abap_unit_assert=>assert_not_initial( temp49 ).

  ENDMETHOD.
ENDCLASS.


CLASS ltcl_test_app2 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION MEDIUM.

  PUBLIC SECTION.

    DATA mv_value  TYPE string ##NEEDED.
    DATA mr_value  TYPE REF TO data ##NEEDED.
    DATA mr_value2 TYPE REF TO data ##NEEDED.
    DATA mo_app    TYPE REF TO ltcl_test_app2 ##NEEDED.

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


CLASS z2ui5_cl_core_srv_model DEFINITION LOCAL FRIENDS ltcl_test_search_attri.

CLASS ltcl_test_search_attri IMPLEMENTATION.
  METHOD first_test.

*    DATA(lo_app_client) = NEW ltcl_test_app2( ).
*    DATA lr_value TYPE REF TO data.
*    GET REFERENCE OF lo_app_client->mv_value INTO lr_value.
*
*    DATA(lt_attri) = VALUE z2ui5_if_core_types=>ty_t_attri( ( r_ref       = lr_value
*                                                              o_typedescr = cl_abap_datadescr=>describe_by_data_ref(
*                                                                                lr_value )
*         ) ).
*
*    DATA(lo_model) = NEW z2ui5_cl_core_srv_diss( attri = REF #( lt_attri )
*                                                  app  = lo_app_client ).
*
*    DATA(lr_attri) = lo_model->main_attri_search( REF #( lo_app_client->mv_value ) ).
*
*    IF lr_attri->r_ref <> lr_value.
*      cl_abap_unit_assert=>abort( ).
*    ENDIF.

  ENDMETHOD.

  METHOD second_test.

*    DATA(lo_app_client) = NEW ltcl_test_app2( ).
*    DATA lr_value TYPE REF TO data.
*    GET REFERENCE OF lo_app_client->mv_value INTO lr_value.
*
*    DATA(lt_attri) = VALUE z2ui5_if_core_types=>ty_t_attri( ( r_ref       = REF #( lo_app_client->mv_value )
*                                                              o_typedescr = cl_abap_datadescr=>describe_by_data_ref(
*                                                                                lr_value )
*         ) ).
*
*    DATA(lo_model) = NEW z2ui5_cl_core_srv_diss( attri = REF #( lt_attri )
*                                                  app  = lo_app_client ).
*
*    DATA(lr_attri) = lo_model->main_attri_search( REF #( lo_app_client->mv_value ) ).
*
*    IF lr_attri->r_ref <> lr_value.
*      cl_abap_unit_assert=>abort( ).
*    ENDIF.

  ENDMETHOD.

  METHOD third_test.

*    DATA(lo_app_client) = NEW ltcl_test_app2( ).
*    DATA lr_value TYPE REF TO data.
*    GET REFERENCE OF lo_app_client->mv_value INTO lr_value.
*
*    lo_app_client->mo_app = NEW #( ).
*
*    DATA(lt_attri) = VALUE z2ui5_if_core_types=>ty_t_attri( ( name = `1` r_ref = REF #( lo_app_client->mr_value ) )
*                                                            ( name = `4` r_ref = REF #( lo_app_client->mr_value2 ) )
*                                                            ( name = `2` r_ref = REF #( lo_app_client->mo_app ) )
*                                                            ( name = `3` r_ref = REF #( lo_app_client->mv_value ) ) ).
*
*    DATA(lr_attri) = REF #( lt_attri[ r_ref = lr_value ] ).
*    IF lr_attri->r_ref <> lr_value.
*      cl_abap_unit_assert=>abort( ).
*    ENDIF.

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

CLASS z2ui5_cl_core_srv_model DEFINITION LOCAL FRIENDS ltcl_test_get_attri.


CLASS ltcl_test_get_attri IMPLEMENTATION.

  METHOD first_test.

    DATA lo_app_client TYPE REF TO ltcl_test_app3.
    DATA lr_value TYPE REF TO data.
    DATA temp51 TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA lt_attri LIKE temp51.
    DATA temp52 LIKE REF TO lt_attri.
DATA lo_model TYPE REF TO z2ui5_cl_core_srv_model.
    DATA lr_attri TYPE REF TO data.
    DATA temp53 LIKE REF TO lo_app_client->mv_value.
    CREATE OBJECT lo_app_client TYPE ltcl_test_app3.

    
    GET REFERENCE OF lo_app_client->mv_value INTO lr_value.

    
    CLEAR temp51.
    
    lt_attri = temp51.

    
    GET REFERENCE OF lt_attri INTO temp52.

CREATE OBJECT lo_model TYPE z2ui5_cl_core_srv_model EXPORTING attri = temp52 app = lo_app_client.

    
    lr_attri = lo_model->attri_get_val_ref( `MV_VALUE` ).

    
    GET REFERENCE OF lo_app_client->mv_value INTO temp53.
IF temp53 <> lr_attri.
      cl_abap_unit_assert=>abort( ).
    ENDIF.

  ENDMETHOD.

  METHOD second_test.

    DATA lo_app_client TYPE REF TO ltcl_test_app3.
    DATA temp54 TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA lt_attri LIKE temp54.
    DATA temp55 LIKE REF TO lt_attri.
DATA lo_model TYPE REF TO z2ui5_cl_core_srv_model.
    DATA lr_attri TYPE REF TO data.
    CREATE OBJECT lo_app_client TYPE ltcl_test_app3.
    CREATE DATA lo_app_client->mr_value.

    
    CLEAR temp54.
    
    lt_attri = temp54.
    
    GET REFERENCE OF lt_attri INTO temp55.

CREATE OBJECT lo_model TYPE z2ui5_cl_core_srv_model EXPORTING attri = temp55 app = lo_app_client.

    
    lr_attri = lo_model->attri_get_val_ref( `MR_VALUE->*` ).

    IF lr_attri <> lo_app_client->mr_value.
      cl_abap_unit_assert=>abort( ).
    ENDIF.

  ENDMETHOD.

  METHOD third_test.

    DATA lo_app_client TYPE REF TO ltcl_test_app3.
    DATA temp56 TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA lt_attri LIKE temp56.
    DATA temp57 LIKE REF TO lt_attri.
DATA lo_model TYPE REF TO z2ui5_cl_core_srv_model.
    DATA lr_attri TYPE REF TO data.
    DATA temp58 LIKE REF TO lo_app_client->mo_app->mv_value.
    CREATE OBJECT lo_app_client TYPE ltcl_test_app3.

    
    CLEAR temp56.
    
    lt_attri = temp56.
    
    GET REFERENCE OF lt_attri INTO temp57.

CREATE OBJECT lo_model TYPE z2ui5_cl_core_srv_model EXPORTING attri = temp57 app = lo_app_client.

    
    lr_attri = lo_model->attri_get_val_ref( `MO_APP->MV_VALUE` ).

    
    GET REFERENCE OF lo_app_client->mo_app->mv_value INTO temp58.
IF temp58 <> lr_attri.
      cl_abap_unit_assert=>abort( ).
    ENDIF.

  ENDMETHOD.

  METHOD test4.

    DATA lo_app_client TYPE REF TO ltcl_test_app3.
    DATA temp59 TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA lt_attri LIKE temp59.
    DATA temp60 LIKE REF TO lt_attri.
DATA lo_model TYPE REF TO z2ui5_cl_core_srv_model.
    DATA lr_attri TYPE REF TO data.
    CREATE OBJECT lo_app_client TYPE ltcl_test_app3.
    CREATE DATA lo_app_client->mo_app->mr_value.

    
    CLEAR temp59.
    
    lt_attri = temp59.
    
    GET REFERENCE OF lt_attri INTO temp60.

CREATE OBJECT lo_model TYPE z2ui5_cl_core_srv_model EXPORTING attri = temp60 app = lo_app_client.

    
    lr_attri = lo_model->attri_get_val_ref( `MO_APP->MR_VALUE->*` ).

    IF lr_attri <> lo_app_client->mo_app->mr_value.
      cl_abap_unit_assert=>abort( ).
    ENDIF.

  ENDMETHOD.
ENDCLASS.



CLASS ltcl_test_app_root_attri DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION MEDIUM.

  PUBLIC SECTION.

    DATA mr_tab TYPE REF TO data.

    METHODS constructor
      IMPORTING
        ir_tab TYPE REF TO data OPTIONAL.

    METHODS test_obj_tab_ref       FOR TESTING RAISING cx_static_check.

ENDCLASS.

CLASS ltcl_test_app_root DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION MEDIUM.

  PUBLIC SECTION.

    TYPES:
      BEGIN OF ty_s_row,
        comp1 TYPE string,
        comp2 TYPE string,
      END OF ty_s_row.
    TYPES ty_t_tab TYPE STANDARD TABLE OF ty_s_row WITH DEFAULT KEY.

    DATA mt_tab  TYPE ty_t_tab.
*    DATA ms_struc TYPE ty_s_row.
    DATA mo_obj TYPE REF TO ltcl_test_app_root_attri.

    METHODS constructor.
ENDCLASS.


CLASS ltcl_test_app_root_attri IMPLEMENTATION.

  METHOD constructor.

*    mr_struc = ir_struc.
    mr_tab = ir_tab.

  ENDMETHOD.

  METHOD test_obj_tab_ref.
    DATA lo_app TYPE REF TO ltcl_test_app_root.
    DATA temp61 TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA lt_attri LIKE temp61.
    DATA temp62 LIKE REF TO lt_attri.
DATA lo_model TYPE REF TO z2ui5_cl_core_srv_model.
    DATA ls_attri TYPE REF TO z2ui5_if_core_types=>ty_s_attri.


    IF sy-sysid = `ABC`.
      RETURN.
    ENDIF.

    
    CREATE OBJECT lo_app TYPE ltcl_test_app_root.

    
    CLEAR temp61.
    
    lt_attri = temp61.
    
    GET REFERENCE OF lt_attri INTO temp62.

CREATE OBJECT lo_model TYPE z2ui5_cl_core_srv_model EXPORTING attri = temp62 app = lo_app.

    
    ls_attri = lo_model->main_attri_search( lo_app->mo_obj->mr_tab ).

    IF ls_attri->name <> `MT_TAB`.
      cl_abap_unit_assert=>abort( ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.

CLASS ltcl_test_app_root IMPLEMENTATION.


  METHOD constructor.

    DATA temp63 TYPE ltcl_test_app_root=>ty_s_row.
    DATA temp64 LIKE REF TO mt_tab.
    CLEAR temp63.
    temp63-comp1 = `comp1`.
    temp63-comp2 = `comp2`.
    INSERT temp63 INTO TABLE mt_tab.

    
    GET REFERENCE OF mt_tab INTO temp64.
CREATE OBJECT mo_obj TYPE ltcl_test_app_root_attri EXPORTING ir_tab = temp64.

  ENDMETHOD.
ENDCLASS.


CLASS ltcl_test_app_root_attri2 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION MEDIUM.

  PUBLIC SECTION.

    DATA mr_struc TYPE REF TO data.

    METHODS constructor
      IMPORTING
        ir_struc TYPE REF TO data OPTIONAL.

    METHODS test_obj_struc_ref       FOR TESTING RAISING cx_static_check.

ENDCLASS.

CLASS ltcl_test_app_root2 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION MEDIUM.

  PUBLIC SECTION.

    TYPES:
      BEGIN OF ty_s_row,
        comp1 TYPE string,
        comp2 TYPE string,
      END OF ty_s_row.

    DATA ms_struc TYPE ty_s_row.
    DATA mo_obj TYPE REF TO ltcl_test_app_root_attri2.

    METHODS constructor.
ENDCLASS.


CLASS ltcl_test_app_root_attri2 IMPLEMENTATION.

  METHOD constructor.

    mr_struc = ir_struc.

  ENDMETHOD.

  METHOD test_obj_struc_ref.
    DATA lo_app TYPE REF TO ltcl_test_app_root2.
    DATA temp65 TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA lt_attri LIKE temp65.
    DATA temp66 LIKE REF TO lt_attri.
DATA lo_model TYPE REF TO z2ui5_cl_core_srv_model.
    DATA ls_attri TYPE REF TO z2ui5_if_core_types=>ty_s_attri.

    IF sy-sysid = `ABC`.
      RETURN.
    ENDIF.

    
    CREATE OBJECT lo_app TYPE ltcl_test_app_root2.

    
    CLEAR temp65.
    
    lt_attri = temp65.
    
    GET REFERENCE OF lt_attri INTO temp66.

CREATE OBJECT lo_model TYPE z2ui5_cl_core_srv_model EXPORTING attri = temp66 app = lo_app.

    
    ls_attri = lo_model->main_attri_search( lo_app->mo_obj->mr_struc ).

    IF ls_attri->name <> `MS_STRUC`.
      cl_abap_unit_assert=>abort( ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.

CLASS ltcl_test_app_root2 IMPLEMENTATION.

  METHOD constructor.
    DATA temp67 LIKE REF TO ms_struc.

    CLEAR ms_struc.
    ms_struc-comp1 = `comp1`.
    ms_struc-comp2 = `comp2`.

    
    GET REFERENCE OF ms_struc INTO temp67.
CREATE OBJECT mo_obj TYPE ltcl_test_app_root_attri2 EXPORTING ir_struc = temp67.

  ENDMETHOD.
ENDCLASS.


CLASS ltcl_test_app_root4 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION MEDIUM.

  PUBLIC SECTION.

    DATA mr_tab  TYPE REF TO data.
    METHODS test_tab_ref_gen FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_test_app_root4 IMPLEMENTATION.

  METHOD test_tab_ref_gen.
    DATA lo_app TYPE REF TO ltcl_test_app_root4.
TYPES BEGIN OF ty_s_row.
TYPES comp1 TYPE string.
TYPES comp2 TYPE string.
TYPES END OF ty_s_row.
    TYPES ty_t_tab TYPE STANDARD TABLE OF ty_s_row WITH DEFAULT KEY.
    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
    DATA temp68 TYPE ty_s_row.
    DATA temp69 TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA lt_attri LIKE temp69.
    DATA temp70 LIKE REF TO lt_attri.
DATA lo_model TYPE REF TO z2ui5_cl_core_srv_model.
    DATA ls_attri TYPE REF TO z2ui5_if_core_types=>ty_s_attri.
    DATA temp71 LIKE REF TO lt_attri.

    IF sy-sysid = `ABC`.
      RETURN.
    ENDIF.



    "create data
    
    CREATE OBJECT lo_app TYPE ltcl_test_app_root4.

    
    

    CREATE DATA lo_app->mr_tab TYPE ty_t_tab.
    
    ASSIGN lo_app->mr_tab->* TO <tab>.
    
    CLEAR temp68.
    temp68-comp1 = `comp1`.
    temp68-comp2 = `comp2`.
    INSERT temp68 INTO TABLE <tab>.



    "test find binding
    
    CLEAR temp69.
    
    lt_attri = temp69.
    
    GET REFERENCE OF lt_attri INTO temp70.

CREATE OBJECT lo_model TYPE z2ui5_cl_core_srv_model EXPORTING attri = temp70 app = lo_app.

    
    ls_attri = lo_model->main_attri_search( lo_app->mr_tab ).

    IF ls_attri->name <> `MR_TAB->*`.
      cl_abap_unit_assert=>abort( ).
    ENDIF.



    "test frontend backend draft
    lo_model->main_attri_db_save_srtti( ).

    CREATE OBJECT lo_app TYPE ltcl_test_app_root4.
    
    GET REFERENCE OF lt_attri INTO temp71.
CREATE OBJECT lo_model TYPE z2ui5_cl_core_srv_model EXPORTING attri = temp71 app = lo_app.
    lo_model->main_attri_db_load( ).

    IF lo_app->mr_tab IS NOT BOUND.
      cl_abap_unit_assert=>abort( ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.


CLASS ltcl_test_diss_complex DEFINITION DEFERRED.
CLASS z2ui5_cl_core_srv_model DEFINITION LOCAL FRIENDS ltcl_test_diss_complex.


CLASS ltcl_app_inner DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PUBLIC SECTION.
    DATA mv_inner TYPE string ##NEEDED.
    DATA mr_data  TYPE REF TO data ##NEEDED.
ENDCLASS.

CLASS ltcl_app_inner IMPLEMENTATION.
ENDCLASS.


CLASS ltcl_app_middle DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PUBLIC SECTION.
    DATA mv_mid    TYPE string ##NEEDED.
    DATA mo_inner  TYPE REF TO ltcl_app_inner.
ENDCLASS.

CLASS ltcl_app_middle IMPLEMENTATION.
ENDCLASS.


CLASS ltcl_app_complex DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    TYPES:
      BEGIN OF ty_s_row,
        col1 TYPE string,
        col2 TYPE string,
      END OF ty_s_row.
    TYPES ty_t_tab TYPE STANDARD TABLE OF ty_s_row WITH DEFAULT KEY.

    TYPES:
      BEGIN OF ty_s_nested,
        name  TYPE string,
        value TYPE string,
        BEGIN OF inner,
          deep1 TYPE string,
          deep2 TYPE string,
        END OF inner,
      END OF ty_s_nested.

    TYPES:
      BEGIN OF ty_s_with_ref,
        text  TYPE string,
        r_tab TYPE REF TO data,
      END OF ty_s_with_ref.

    DATA mt_tab     TYPE ty_t_tab.
    DATA ms_nested  TYPE ty_s_nested.
    DATA mo_mid     TYPE REF TO ltcl_app_middle.
    DATA ms_ref     TYPE ty_s_with_ref ##NEEDED.
    DATA mr_tab     TYPE REF TO data.
    DATA mv_simple  TYPE string ##NEEDED.
    DATA mv_int     TYPE i ##NEEDED.
ENDCLASS.


CLASS ltcl_app_complex IMPLEMENTATION.
  METHOD z2ui5_if_app~main ##NEEDED.
  ENDMETHOD.
ENDCLASS.


CLASS ltcl_test_diss_complex DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_table                FOR TESTING RAISING cx_static_check.
    METHODS test_nested_struc         FOR TESTING RAISING cx_static_check.
    METHODS test_oref_chain           FOR TESTING RAISING cx_static_check.
    METHODS test_table_in_dref        FOR TESTING RAISING cx_static_check.
    METHODS test_mixed_types          FOR TESTING RAISING cx_static_check.
    METHODS test_dissolve_idempotent  FOR TESTING RAISING cx_static_check.
    METHODS test_search_table         FOR TESTING RAISING cx_static_check.
    METHODS test_search_nested_struc  FOR TESTING RAISING cx_static_check.
    METHODS test_name_parent_chain    FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_test_diss_complex IMPLEMENTATION.

  METHOD test_table.

    DATA lo_app TYPE REF TO ltcl_app_complex.
    DATA temp72 TYPE ltcl_app_complex=>ty_t_tab.
    DATA temp73 LIKE LINE OF temp72.
    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA temp74 LIKE REF TO lt_attri.
DATA lo_model TYPE REF TO z2ui5_cl_core_srv_model.
    DATA temp75 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp76 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp77 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp78 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA ls_attri LIKE temp77.
    CREATE OBJECT lo_app TYPE ltcl_app_complex.
    
    CLEAR temp72.
    
    temp73-col1 = `A`.
    temp73-col2 = `1`.
    INSERT temp73 INTO TABLE temp72.
    temp73-col1 = `B`.
    temp73-col2 = `2`.
    INSERT temp73 INTO TABLE temp72.
    lo_app->mt_tab = temp72.

    
    
    GET REFERENCE OF lt_attri INTO temp74.

CREATE OBJECT lo_model TYPE z2ui5_cl_core_srv_model EXPORTING attri = temp74 app = lo_app.

    lo_model->dissolve( ).

    
    CLEAR temp75.
    
    READ TABLE lt_attri INTO temp76 WITH KEY name = `MT_TAB`.
    IF sy-subrc = 0.
      temp75 = temp76.
    ENDIF.
    cl_abap_unit_assert=>assert_not_initial( temp75 ).

    
    CLEAR temp77.
    
    READ TABLE lt_attri INTO temp78 WITH KEY name = `MT_TAB`.
    IF sy-subrc = 0.
      temp77 = temp78.
    ENDIF.
    
    ls_attri = temp77.
    cl_abap_unit_assert=>assert_equals( exp = cl_abap_datadescr=>typekind_table
                                        act = ls_attri-type_kind ).

  ENDMETHOD.

  METHOD test_nested_struc.

    DATA lo_app TYPE REF TO ltcl_app_complex.
    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA temp79 LIKE REF TO lt_attri.
DATA lo_model TYPE REF TO z2ui5_cl_core_srv_model.
    DATA temp80 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp81 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp82 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp83 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp84 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp85 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp86 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp87 TYPE z2ui5_if_core_types=>ty_s_attri.
    CREATE OBJECT lo_app TYPE ltcl_app_complex.
    CLEAR lo_app->ms_nested.
    lo_app->ms_nested-name = `test`.
    lo_app->ms_nested-value = `123`.
    CLEAR lo_app->ms_nested-inner.
    lo_app->ms_nested-inner-deep1 = `d1`.
    lo_app->ms_nested-inner-deep2 = `d2`.

    
    
    GET REFERENCE OF lt_attri INTO temp79.

CREATE OBJECT lo_model TYPE z2ui5_cl_core_srv_model EXPORTING attri = temp79 app = lo_app.

    lo_model->dissolve( ).
    lo_model->dissolve( ).
    lo_model->dissolve( ).

    
    CLEAR temp80.
    
    READ TABLE lt_attri INTO temp81 WITH KEY name = `MS_NESTED-NAME`.
    IF sy-subrc = 0.
      temp80 = temp81.
    ENDIF.
    cl_abap_unit_assert=>assert_not_initial( temp80 ).
    
    CLEAR temp82.
    
    READ TABLE lt_attri INTO temp83 WITH KEY name = `MS_NESTED-VALUE`.
    IF sy-subrc = 0.
      temp82 = temp83.
    ENDIF.
    cl_abap_unit_assert=>assert_not_initial( temp82 ).
    
    CLEAR temp84.
    
    READ TABLE lt_attri INTO temp85 WITH KEY name = `MS_NESTED-INNER-DEEP1`.
    IF sy-subrc = 0.
      temp84 = temp85.
    ENDIF.
    cl_abap_unit_assert=>assert_not_initial( temp84 ).
    
    CLEAR temp86.
    
    READ TABLE lt_attri INTO temp87 WITH KEY name = `MS_NESTED-INNER-DEEP2`.
    IF sy-subrc = 0.
      temp86 = temp87.
    ENDIF.
    cl_abap_unit_assert=>assert_not_initial( temp86 ).

  ENDMETHOD.

  METHOD test_oref_chain.

    DATA lo_app TYPE REF TO ltcl_app_complex.
    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA temp88 LIKE REF TO lt_attri.
DATA lo_model TYPE REF TO z2ui5_cl_core_srv_model.
    DATA temp89 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp90 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp91 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp92 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp93 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp94 TYPE z2ui5_if_core_types=>ty_s_attri.
    CREATE OBJECT lo_app TYPE ltcl_app_complex.
    CREATE OBJECT lo_app->mo_mid.
    CREATE OBJECT lo_app->mo_mid->mo_inner.

    
    
    GET REFERENCE OF lt_attri INTO temp88.

CREATE OBJECT lo_model TYPE z2ui5_cl_core_srv_model EXPORTING attri = temp88 app = lo_app.

    lo_model->dissolve( ).
    lo_model->dissolve( ).
    lo_model->dissolve( ).

    
    CLEAR temp89.
    
    READ TABLE lt_attri INTO temp90 WITH KEY name = `MO_MID->MV_MID`.
    IF sy-subrc = 0.
      temp89 = temp90.
    ENDIF.
    cl_abap_unit_assert=>assert_not_initial( temp89 ).
    
    CLEAR temp91.
    
    READ TABLE lt_attri INTO temp92 WITH KEY name = `MO_MID->MO_INNER`.
    IF sy-subrc = 0.
      temp91 = temp92.
    ENDIF.
    cl_abap_unit_assert=>assert_not_initial( temp91 ).
    
    CLEAR temp93.
    
    READ TABLE lt_attri INTO temp94 WITH KEY name = `MO_MID->MO_INNER->MV_INNER`.
    IF sy-subrc = 0.
      temp93 = temp94.
    ENDIF.
    cl_abap_unit_assert=>assert_not_initial(
      temp93 ).

  ENDMETHOD.

  METHOD test_table_in_dref.

    DATA lo_app TYPE REF TO ltcl_app_complex.
    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
    DATA ls_row LIKE LINE OF lo_app->mt_tab.
    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA temp95 LIKE REF TO lt_attri.
DATA lo_model TYPE REF TO z2ui5_cl_core_srv_model.
    DATA temp96 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp97 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp98 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp99 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp100 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp101 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA ls_tab LIKE temp100.
    CREATE OBJECT lo_app TYPE ltcl_app_complex.
    CREATE DATA lo_app->mr_tab LIKE lo_app->mt_tab.
    
    ASSIGN lo_app->mr_tab->* TO <tab>.
    
    ls_row-col1 = `X`.
    ls_row-col2 = `Y`.
    INSERT ls_row INTO TABLE <tab>.

    
    
    GET REFERENCE OF lt_attri INTO temp95.

CREATE OBJECT lo_model TYPE z2ui5_cl_core_srv_model EXPORTING attri = temp95 app = lo_app.

    lo_model->dissolve( ).
    lo_model->dissolve( ).

    
    CLEAR temp96.
    
    READ TABLE lt_attri INTO temp97 WITH KEY name = `MR_TAB`.
    IF sy-subrc = 0.
      temp96 = temp97.
    ENDIF.
    cl_abap_unit_assert=>assert_not_initial( temp96 ).
    
    CLEAR temp98.
    
    READ TABLE lt_attri INTO temp99 WITH KEY name = `MR_TAB->*`.
    IF sy-subrc = 0.
      temp98 = temp99.
    ENDIF.
    cl_abap_unit_assert=>assert_not_initial( temp98 ).

    
    CLEAR temp100.
    
    READ TABLE lt_attri INTO temp101 WITH KEY name = `MR_TAB->*`.
    IF sy-subrc = 0.
      temp100 = temp101.
    ENDIF.
    
    ls_tab = temp100.
    cl_abap_unit_assert=>assert_equals( exp = cl_abap_datadescr=>typekind_table
                                        act = ls_tab-type_kind ).

  ENDMETHOD.

  METHOD test_mixed_types.

    DATA lo_app TYPE REF TO ltcl_app_complex.
    DATA temp102 TYPE ltcl_app_complex=>ty_t_tab.
    DATA temp103 LIKE LINE OF temp102.
    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA temp104 LIKE REF TO lt_attri.
DATA lo_model TYPE REF TO z2ui5_cl_core_srv_model.
    DATA temp105 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp106 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp107 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp108 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp109 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp110 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp111 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp112 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp113 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp114 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp115 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp116 TYPE z2ui5_if_core_types=>ty_s_attri.
    CREATE OBJECT lo_app TYPE ltcl_app_complex.
    
    CLEAR temp102.
    
    temp103-col1 = `A`.
    temp103-col2 = `1`.
    INSERT temp103 INTO TABLE temp102.
    lo_app->mt_tab = temp102.
    lo_app->ms_nested-name = `test`.
    CREATE OBJECT lo_app->mo_mid.
    CREATE DATA lo_app->mr_tab LIKE lo_app->mt_tab.

    
    
    GET REFERENCE OF lt_attri INTO temp104.

CREATE OBJECT lo_model TYPE z2ui5_cl_core_srv_model EXPORTING attri = temp104 app = lo_app.

    lo_model->dissolve( ).
    lo_model->dissolve( ).
    lo_model->dissolve( ).

    
    CLEAR temp105.
    
    READ TABLE lt_attri INTO temp106 WITH KEY name = `MT_TAB`.
    IF sy-subrc = 0.
      temp105 = temp106.
    ENDIF.
    cl_abap_unit_assert=>assert_not_initial( temp105 ).
    
    CLEAR temp107.
    
    READ TABLE lt_attri INTO temp108 WITH KEY name = `MS_NESTED-NAME`.
    IF sy-subrc = 0.
      temp107 = temp108.
    ENDIF.
    cl_abap_unit_assert=>assert_not_initial( temp107 ).
    
    CLEAR temp109.
    
    READ TABLE lt_attri INTO temp110 WITH KEY name = `MO_MID->MV_MID`.
    IF sy-subrc = 0.
      temp109 = temp110.
    ENDIF.
    cl_abap_unit_assert=>assert_not_initial( temp109 ).
    
    CLEAR temp111.
    
    READ TABLE lt_attri INTO temp112 WITH KEY name = `MR_TAB`.
    IF sy-subrc = 0.
      temp111 = temp112.
    ENDIF.
    cl_abap_unit_assert=>assert_not_initial( temp111 ).
    
    CLEAR temp113.
    
    READ TABLE lt_attri INTO temp114 WITH KEY name = `MV_SIMPLE`.
    IF sy-subrc = 0.
      temp113 = temp114.
    ENDIF.
    cl_abap_unit_assert=>assert_not_initial( temp113 ).
    
    CLEAR temp115.
    
    READ TABLE lt_attri INTO temp116 WITH KEY name = `MV_INT`.
    IF sy-subrc = 0.
      temp115 = temp116.
    ENDIF.
    cl_abap_unit_assert=>assert_not_initial( temp115 ).

  ENDMETHOD.

  METHOD test_dissolve_idempotent.

    DATA lo_app TYPE REF TO ltcl_app_complex.
    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA temp117 LIKE REF TO lt_attri.
DATA lo_model TYPE REF TO z2ui5_cl_core_srv_model.
    DATA lv_count_1 TYPE i.
    DATA lv_count_2 TYPE i.
    CREATE OBJECT lo_app TYPE ltcl_app_complex.
    lo_app->ms_nested-name = `test`.
    CREATE OBJECT lo_app->mo_mid.

    
    
    GET REFERENCE OF lt_attri INTO temp117.

CREATE OBJECT lo_model TYPE z2ui5_cl_core_srv_model EXPORTING attri = temp117 app = lo_app.

    lo_model->dissolve( ).
    lo_model->dissolve( ).
    lo_model->dissolve( ).
    
    lv_count_1 = lines( lt_attri ).

    lo_model->dissolve( ).
    
    lv_count_2 = lines( lt_attri ).

    cl_abap_unit_assert=>assert_equals( exp = lv_count_1
                                        act = lv_count_2 ).

  ENDMETHOD.

  METHOD test_search_table.
    DATA lo_app TYPE REF TO ltcl_app_complex.
    DATA temp118 TYPE ltcl_app_complex=>ty_t_tab.
    DATA temp119 LIKE LINE OF temp118.
    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA temp120 LIKE REF TO lt_attri.
DATA lo_model TYPE REF TO z2ui5_cl_core_srv_model.
    DATA temp121 LIKE REF TO lo_app->mt_tab.
DATA ls_attri TYPE REF TO z2ui5_if_core_types=>ty_s_attri.

    IF sy-sysid = `ABC`.
      RETURN.
    ENDIF.

    
    CREATE OBJECT lo_app TYPE ltcl_app_complex.
    
    CLEAR temp118.
    
    temp119-col1 = `A`.
    temp119-col2 = `1`.
    INSERT temp119 INTO TABLE temp118.
    lo_app->mt_tab = temp118.

    
    
    GET REFERENCE OF lt_attri INTO temp120.

CREATE OBJECT lo_model TYPE z2ui5_cl_core_srv_model EXPORTING attri = temp120 app = lo_app.

    
    GET REFERENCE OF lo_app->mt_tab INTO temp121.

ls_attri = lo_model->main_attri_search( temp121 ).

    cl_abap_unit_assert=>assert_equals( exp = `MT_TAB`
                                        act = ls_attri->name ).

  ENDMETHOD.

  METHOD test_search_nested_struc.
    DATA lo_app TYPE REF TO ltcl_app_complex.
    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA temp122 LIKE REF TO lt_attri.
DATA lo_model TYPE REF TO z2ui5_cl_core_srv_model.
    DATA temp123 LIKE REF TO lo_app->ms_nested-inner-deep1.
DATA ls_attri TYPE REF TO z2ui5_if_core_types=>ty_s_attri.

    IF sy-sysid = `ABC`.
      RETURN.
    ENDIF.

    
    CREATE OBJECT lo_app TYPE ltcl_app_complex.
    lo_app->ms_nested-inner-deep1 = `found`.

    
    
    GET REFERENCE OF lt_attri INTO temp122.

CREATE OBJECT lo_model TYPE z2ui5_cl_core_srv_model EXPORTING attri = temp122 app = lo_app.

    
    GET REFERENCE OF lo_app->ms_nested-inner-deep1 INTO temp123.

ls_attri = lo_model->main_attri_search( temp123 ).

    cl_abap_unit_assert=>assert_equals( exp = `MS_NESTED-INNER-DEEP1`
                                        act = ls_attri->name ).

  ENDMETHOD.

  METHOD test_name_parent_chain.

    DATA lo_app TYPE REF TO ltcl_app_complex.
    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA temp124 LIKE REF TO lt_attri.
DATA lo_model TYPE REF TO z2ui5_cl_core_srv_model.
    DATA temp125 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp126 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA ls_mid LIKE temp125.
    DATA temp127 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp128 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA ls_inner LIKE temp127.
    CREATE OBJECT lo_app TYPE ltcl_app_complex.
    CREATE OBJECT lo_app->mo_mid.
    CREATE OBJECT lo_app->mo_mid->mo_inner.

    
    
    GET REFERENCE OF lt_attri INTO temp124.

CREATE OBJECT lo_model TYPE z2ui5_cl_core_srv_model EXPORTING attri = temp124 app = lo_app.

    lo_model->dissolve( ).
    lo_model->dissolve( ).
    lo_model->dissolve( ).

    
    CLEAR temp125.
    
    READ TABLE lt_attri INTO temp126 WITH KEY name = `MO_MID->MO_INNER`.
    IF sy-subrc = 0.
      temp125 = temp126.
    ENDIF.
    
    ls_mid = temp125.
    cl_abap_unit_assert=>assert_equals( exp = `MO_MID`
                                        act = ls_mid-name_parent ).

    
    CLEAR temp127.
    
    READ TABLE lt_attri INTO temp128 WITH KEY name = `MO_MID->MO_INNER->MV_INNER`.
    IF sy-subrc = 0.
      temp127 = temp128.
    ENDIF.
    
    ls_inner = temp127.
    cl_abap_unit_assert=>assert_equals( exp = `MO_MID->MO_INNER`
                                        act = ls_inner-name_parent ).

  ENDMETHOD.

ENDCLASS.
