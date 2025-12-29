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
