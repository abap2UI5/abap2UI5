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
    METHODS test_first  FOR TESTING RAISING cx_static_check.
    METHODS test_second FOR TESTING RAISING cx_static_check.
    METHODS third_test  FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS z2ui5_cl_core_srv_model DEFINITION LOCAL FRIENDS ltcl_test_search_attri.

CLASS ltcl_test_search_attri IMPLEMENTATION.
  METHOD test_first.

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

  METHOD test_second.

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
    METHODS test_first  FOR TESTING RAISING cx_static_check.
    METHODS test_second FOR TESTING RAISING cx_static_check.
    METHODS third_test  FOR TESTING RAISING cx_static_check.
    METHODS test4       FOR TESTING RAISING cx_static_check.

ENDCLASS.

CLASS z2ui5_cl_core_srv_model DEFINITION LOCAL FRIENDS ltcl_test_get_attri.


CLASS ltcl_test_get_attri IMPLEMENTATION.

  METHOD test_first.

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

  METHOD test_second.

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


CLASS ltcl_app_inner_335 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PUBLIC SECTION.
    DATA mr_data TYPE REF TO data ##NEEDED.

    METHODS constructor
      IMPORTING
        ir_data TYPE REF TO data OPTIONAL.

ENDCLASS.

CLASS ltcl_app_inner_335 IMPLEMENTATION.

  METHOD constructor.

    mr_data = ir_data.

  ENDMETHOD.

ENDCLASS.


CLASS ltcl_app_root_335 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION MEDIUM.

  PUBLIC SECTION.

    TYPES:
      BEGIN OF ty_s_row,
        comp1 TYPE string,
        comp2 TYPE string,
      END OF ty_s_row.

    DATA ms_struc  TYPE ty_s_row.
    DATA mo_obj    TYPE REF TO ltcl_app_inner_335.
    DATA mo_obj_2  TYPE REF TO ltcl_app_inner_335.

    METHODS constructor.

ENDCLASS.

CLASS ltcl_app_root_335 IMPLEMENTATION.

  METHOD constructor.
    DATA temp72 LIKE REF TO ms_struc.
    DATA temp73 LIKE REF TO ms_struc.

    CLEAR ms_struc.
    ms_struc-comp1 = `comp1`.
    ms_struc-comp2 = `comp2`.

    
    GET REFERENCE OF ms_struc INTO temp72.
CREATE OBJECT mo_obj TYPE ltcl_app_inner_335 EXPORTING ir_data = temp72.
    
    GET REFERENCE OF ms_struc INTO temp73.
CREATE OBJECT mo_obj_2 TYPE ltcl_app_inner_335 EXPORTING ir_data = temp73.

  ENDMETHOD.

ENDCLASS.


CLASS ltcl_test_sample335 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION MEDIUM.

  PRIVATE SECTION.
    METHODS test_two_drefs_to_same_struc FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_test_sample335 IMPLEMENTATION.

  METHOD test_two_drefs_to_same_struc.
    DATA lo_app TYPE REF TO ltcl_app_root_335.
    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA temp74 LIKE REF TO lt_attri.
DATA lo_model TYPE REF TO z2ui5_cl_core_srv_model.
    DATA temp75 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp76 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA ls_mr_data_1 LIKE temp75.
    DATA temp77 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp78 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA ls_mr_data_2 LIKE temp77.

    IF sy-sysid = `ABC`.
      RETURN.
    ENDIF.

    
    CREATE OBJECT lo_app TYPE ltcl_app_root_335.

    
    
    GET REFERENCE OF lt_attri INTO temp74.

CREATE OBJECT lo_model TYPE z2ui5_cl_core_srv_model EXPORTING attri = temp74 app = lo_app.

    lo_model->dissolve( ).
    lo_model->dissolve( ).
    lo_model->dissolve( ).

    
    CLEAR temp75.
    
    READ TABLE lt_attri INTO temp76 WITH KEY name = `MO_OBJ->MR_DATA`.
    IF sy-subrc = 0.
      temp75 = temp76.
    ENDIF.
    
    ls_mr_data_1 = temp75.
    cl_abap_unit_assert=>assert_equals( exp = `MS_STRUC`
                                        act = ls_mr_data_1-name_ref ).

    
    CLEAR temp77.
    
    READ TABLE lt_attri INTO temp78 WITH KEY name = `MO_OBJ_2->MR_DATA`.
    IF sy-subrc = 0.
      temp77 = temp78.
    ENDIF.
    
    ls_mr_data_2 = temp77.
    cl_abap_unit_assert=>assert_equals( exp = `MS_STRUC`
                                        act = ls_mr_data_2-name_ref ).

  ENDMETHOD.

ENDCLASS.


CLASS ltcl_test_diss_complex IMPLEMENTATION.

  METHOD test_table.

    DATA lo_app TYPE REF TO ltcl_app_complex.
    DATA temp79 TYPE ltcl_app_complex=>ty_t_tab.
    DATA temp80 LIKE LINE OF temp79.
    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA temp81 LIKE REF TO lt_attri.
DATA lo_model TYPE REF TO z2ui5_cl_core_srv_model.
    DATA temp82 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp83 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp84 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp85 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA ls_attri LIKE temp84.
    CREATE OBJECT lo_app TYPE ltcl_app_complex.
    
    CLEAR temp79.
    
    temp80-col1 = `A`.
    temp80-col2 = `1`.
    INSERT temp80 INTO TABLE temp79.
    temp80-col1 = `B`.
    temp80-col2 = `2`.
    INSERT temp80 INTO TABLE temp79.
    lo_app->mt_tab = temp79.

    
    
    GET REFERENCE OF lt_attri INTO temp81.

CREATE OBJECT lo_model TYPE z2ui5_cl_core_srv_model EXPORTING attri = temp81 app = lo_app.

    lo_model->dissolve( ).

    
    CLEAR temp82.
    
    READ TABLE lt_attri INTO temp83 WITH KEY name = `MT_TAB`.
    IF sy-subrc = 0.
      temp82 = temp83.
    ENDIF.
    cl_abap_unit_assert=>assert_not_initial( temp82 ).

    
    CLEAR temp84.
    
    READ TABLE lt_attri INTO temp85 WITH KEY name = `MT_TAB`.
    IF sy-subrc = 0.
      temp84 = temp85.
    ENDIF.
    
    ls_attri = temp84.
    cl_abap_unit_assert=>assert_equals( exp = cl_abap_datadescr=>typekind_table
                                        act = ls_attri-type_kind ).

  ENDMETHOD.

  METHOD test_nested_struc.

    DATA lo_app TYPE REF TO ltcl_app_complex.
    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA temp86 LIKE REF TO lt_attri.
DATA lo_model TYPE REF TO z2ui5_cl_core_srv_model.
    DATA temp87 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp88 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp89 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp90 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp91 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp92 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp93 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp94 TYPE z2ui5_if_core_types=>ty_s_attri.
    CREATE OBJECT lo_app TYPE ltcl_app_complex.
    CLEAR lo_app->ms_nested.
    lo_app->ms_nested-name = `test`.
    lo_app->ms_nested-value = `123`.
    CLEAR lo_app->ms_nested-inner.
    lo_app->ms_nested-inner-deep1 = `d1`.
    lo_app->ms_nested-inner-deep2 = `d2`.

    
    
    GET REFERENCE OF lt_attri INTO temp86.

CREATE OBJECT lo_model TYPE z2ui5_cl_core_srv_model EXPORTING attri = temp86 app = lo_app.

    lo_model->dissolve( ).
    lo_model->dissolve( ).
    lo_model->dissolve( ).

    
    CLEAR temp87.
    
    READ TABLE lt_attri INTO temp88 WITH KEY name = `MS_NESTED-NAME`.
    IF sy-subrc = 0.
      temp87 = temp88.
    ENDIF.
    cl_abap_unit_assert=>assert_not_initial( temp87 ).
    
    CLEAR temp89.
    
    READ TABLE lt_attri INTO temp90 WITH KEY name = `MS_NESTED-VALUE`.
    IF sy-subrc = 0.
      temp89 = temp90.
    ENDIF.
    cl_abap_unit_assert=>assert_not_initial( temp89 ).
    
    CLEAR temp91.
    
    READ TABLE lt_attri INTO temp92 WITH KEY name = `MS_NESTED-INNER-DEEP1`.
    IF sy-subrc = 0.
      temp91 = temp92.
    ENDIF.
    cl_abap_unit_assert=>assert_not_initial( temp91 ).
    
    CLEAR temp93.
    
    READ TABLE lt_attri INTO temp94 WITH KEY name = `MS_NESTED-INNER-DEEP2`.
    IF sy-subrc = 0.
      temp93 = temp94.
    ENDIF.
    cl_abap_unit_assert=>assert_not_initial( temp93 ).

  ENDMETHOD.

  METHOD test_oref_chain.

    DATA lo_app TYPE REF TO ltcl_app_complex.
    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA temp95 LIKE REF TO lt_attri.
DATA lo_model TYPE REF TO z2ui5_cl_core_srv_model.
    DATA temp96 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp97 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp98 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp99 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp100 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp101 TYPE z2ui5_if_core_types=>ty_s_attri.
    CREATE OBJECT lo_app TYPE ltcl_app_complex.
    CREATE OBJECT lo_app->mo_mid.
    CREATE OBJECT lo_app->mo_mid->mo_inner.

    
    
    GET REFERENCE OF lt_attri INTO temp95.

CREATE OBJECT lo_model TYPE z2ui5_cl_core_srv_model EXPORTING attri = temp95 app = lo_app.

    lo_model->dissolve( ).
    lo_model->dissolve( ).
    lo_model->dissolve( ).

    
    CLEAR temp96.
    
    READ TABLE lt_attri INTO temp97 WITH KEY name = `MO_MID->MV_MID`.
    IF sy-subrc = 0.
      temp96 = temp97.
    ENDIF.
    cl_abap_unit_assert=>assert_not_initial( temp96 ).
    
    CLEAR temp98.
    
    READ TABLE lt_attri INTO temp99 WITH KEY name = `MO_MID->MO_INNER`.
    IF sy-subrc = 0.
      temp98 = temp99.
    ENDIF.
    cl_abap_unit_assert=>assert_not_initial( temp98 ).
    
    CLEAR temp100.
    
    READ TABLE lt_attri INTO temp101 WITH KEY name = `MO_MID->MO_INNER->MV_INNER`.
    IF sy-subrc = 0.
      temp100 = temp101.
    ENDIF.
    cl_abap_unit_assert=>assert_not_initial(
      temp100 ).

  ENDMETHOD.

  METHOD test_table_in_dref.

    DATA lo_app TYPE REF TO ltcl_app_complex.
    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
    DATA ls_row LIKE LINE OF lo_app->mt_tab.
    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA temp102 LIKE REF TO lt_attri.
DATA lo_model TYPE REF TO z2ui5_cl_core_srv_model.
    DATA temp103 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp104 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp105 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp106 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp107 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp108 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA ls_tab LIKE temp107.
    CREATE OBJECT lo_app TYPE ltcl_app_complex.
    CREATE DATA lo_app->mr_tab LIKE lo_app->mt_tab.
    
    ASSIGN lo_app->mr_tab->* TO <tab>.
    
    ls_row-col1 = `X`.
    ls_row-col2 = `Y`.
    INSERT ls_row INTO TABLE <tab>.

    
    
    GET REFERENCE OF lt_attri INTO temp102.

CREATE OBJECT lo_model TYPE z2ui5_cl_core_srv_model EXPORTING attri = temp102 app = lo_app.

    lo_model->dissolve( ).
    lo_model->dissolve( ).

    
    CLEAR temp103.
    
    READ TABLE lt_attri INTO temp104 WITH KEY name = `MR_TAB`.
    IF sy-subrc = 0.
      temp103 = temp104.
    ENDIF.
    cl_abap_unit_assert=>assert_not_initial( temp103 ).
    
    CLEAR temp105.
    
    READ TABLE lt_attri INTO temp106 WITH KEY name = `MR_TAB->*`.
    IF sy-subrc = 0.
      temp105 = temp106.
    ENDIF.
    cl_abap_unit_assert=>assert_not_initial( temp105 ).

    
    CLEAR temp107.
    
    READ TABLE lt_attri INTO temp108 WITH KEY name = `MR_TAB->*`.
    IF sy-subrc = 0.
      temp107 = temp108.
    ENDIF.
    
    ls_tab = temp107.
    cl_abap_unit_assert=>assert_equals( exp = cl_abap_datadescr=>typekind_table
                                        act = ls_tab-type_kind ).

  ENDMETHOD.

  METHOD test_mixed_types.

    DATA lo_app TYPE REF TO ltcl_app_complex.
    DATA temp109 TYPE ltcl_app_complex=>ty_t_tab.
    DATA temp110 LIKE LINE OF temp109.
    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA temp111 LIKE REF TO lt_attri.
DATA lo_model TYPE REF TO z2ui5_cl_core_srv_model.
    DATA temp112 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp113 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp114 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp115 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp116 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp117 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp118 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp119 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp120 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp121 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp122 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp123 TYPE z2ui5_if_core_types=>ty_s_attri.
    CREATE OBJECT lo_app TYPE ltcl_app_complex.
    
    CLEAR temp109.
    
    temp110-col1 = `A`.
    temp110-col2 = `1`.
    INSERT temp110 INTO TABLE temp109.
    lo_app->mt_tab = temp109.
    lo_app->ms_nested-name = `test`.
    CREATE OBJECT lo_app->mo_mid.
    CREATE DATA lo_app->mr_tab LIKE lo_app->mt_tab.

    
    
    GET REFERENCE OF lt_attri INTO temp111.

CREATE OBJECT lo_model TYPE z2ui5_cl_core_srv_model EXPORTING attri = temp111 app = lo_app.

    lo_model->dissolve( ).
    lo_model->dissolve( ).
    lo_model->dissolve( ).

    
    CLEAR temp112.
    
    READ TABLE lt_attri INTO temp113 WITH KEY name = `MT_TAB`.
    IF sy-subrc = 0.
      temp112 = temp113.
    ENDIF.
    cl_abap_unit_assert=>assert_not_initial( temp112 ).
    
    CLEAR temp114.
    
    READ TABLE lt_attri INTO temp115 WITH KEY name = `MS_NESTED-NAME`.
    IF sy-subrc = 0.
      temp114 = temp115.
    ENDIF.
    cl_abap_unit_assert=>assert_not_initial( temp114 ).
    
    CLEAR temp116.
    
    READ TABLE lt_attri INTO temp117 WITH KEY name = `MO_MID->MV_MID`.
    IF sy-subrc = 0.
      temp116 = temp117.
    ENDIF.
    cl_abap_unit_assert=>assert_not_initial( temp116 ).
    
    CLEAR temp118.
    
    READ TABLE lt_attri INTO temp119 WITH KEY name = `MR_TAB`.
    IF sy-subrc = 0.
      temp118 = temp119.
    ENDIF.
    cl_abap_unit_assert=>assert_not_initial( temp118 ).
    
    CLEAR temp120.
    
    READ TABLE lt_attri INTO temp121 WITH KEY name = `MV_SIMPLE`.
    IF sy-subrc = 0.
      temp120 = temp121.
    ENDIF.
    cl_abap_unit_assert=>assert_not_initial( temp120 ).
    
    CLEAR temp122.
    
    READ TABLE lt_attri INTO temp123 WITH KEY name = `MV_INT`.
    IF sy-subrc = 0.
      temp122 = temp123.
    ENDIF.
    cl_abap_unit_assert=>assert_not_initial( temp122 ).

  ENDMETHOD.

  METHOD test_dissolve_idempotent.

    DATA lo_app TYPE REF TO ltcl_app_complex.
    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA temp124 LIKE REF TO lt_attri.
DATA lo_model TYPE REF TO z2ui5_cl_core_srv_model.
    DATA lv_count_1 TYPE i.
    DATA lv_count_2 TYPE i.
    CREATE OBJECT lo_app TYPE ltcl_app_complex.
    lo_app->ms_nested-name = `test`.
    CREATE OBJECT lo_app->mo_mid.

    
    
    GET REFERENCE OF lt_attri INTO temp124.

CREATE OBJECT lo_model TYPE z2ui5_cl_core_srv_model EXPORTING attri = temp124 app = lo_app.

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
    DATA temp125 TYPE ltcl_app_complex=>ty_t_tab.
    DATA temp126 LIKE LINE OF temp125.
    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA temp127 LIKE REF TO lt_attri.
DATA lo_model TYPE REF TO z2ui5_cl_core_srv_model.
    DATA temp128 LIKE REF TO lo_app->mt_tab.
DATA ls_attri TYPE REF TO z2ui5_if_core_types=>ty_s_attri.

    IF sy-sysid = `ABC`.
      RETURN.
    ENDIF.

    
    CREATE OBJECT lo_app TYPE ltcl_app_complex.
    
    CLEAR temp125.
    
    temp126-col1 = `A`.
    temp126-col2 = `1`.
    INSERT temp126 INTO TABLE temp125.
    lo_app->mt_tab = temp125.

    
    
    GET REFERENCE OF lt_attri INTO temp127.

CREATE OBJECT lo_model TYPE z2ui5_cl_core_srv_model EXPORTING attri = temp127 app = lo_app.

    
    GET REFERENCE OF lo_app->mt_tab INTO temp128.

ls_attri = lo_model->main_attri_search( temp128 ).

    cl_abap_unit_assert=>assert_equals( exp = `MT_TAB`
                                        act = ls_attri->name ).

  ENDMETHOD.

  METHOD test_search_nested_struc.
    DATA lo_app TYPE REF TO ltcl_app_complex.
    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA temp129 LIKE REF TO lt_attri.
DATA lo_model TYPE REF TO z2ui5_cl_core_srv_model.
    DATA temp130 LIKE REF TO lo_app->ms_nested-inner-deep1.
DATA ls_attri TYPE REF TO z2ui5_if_core_types=>ty_s_attri.

    IF sy-sysid = `ABC`.
      RETURN.
    ENDIF.

    
    CREATE OBJECT lo_app TYPE ltcl_app_complex.
    lo_app->ms_nested-inner-deep1 = `found`.

    
    
    GET REFERENCE OF lt_attri INTO temp129.

CREATE OBJECT lo_model TYPE z2ui5_cl_core_srv_model EXPORTING attri = temp129 app = lo_app.

    
    GET REFERENCE OF lo_app->ms_nested-inner-deep1 INTO temp130.

ls_attri = lo_model->main_attri_search( temp130 ).

    cl_abap_unit_assert=>assert_equals( exp = `MS_NESTED-INNER-DEEP1`
                                        act = ls_attri->name ).

  ENDMETHOD.

  METHOD test_name_parent_chain.

    DATA lo_app TYPE REF TO ltcl_app_complex.
    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA temp131 LIKE REF TO lt_attri.
DATA lo_model TYPE REF TO z2ui5_cl_core_srv_model.
    DATA temp132 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp133 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA ls_mid LIKE temp132.
    DATA temp134 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp135 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA ls_inner LIKE temp134.
    CREATE OBJECT lo_app TYPE ltcl_app_complex.
    CREATE OBJECT lo_app->mo_mid.
    CREATE OBJECT lo_app->mo_mid->mo_inner.

    
    
    GET REFERENCE OF lt_attri INTO temp131.

CREATE OBJECT lo_model TYPE z2ui5_cl_core_srv_model EXPORTING attri = temp131 app = lo_app.

    lo_model->dissolve( ).
    lo_model->dissolve( ).
    lo_model->dissolve( ).

    
    CLEAR temp132.
    
    READ TABLE lt_attri INTO temp133 WITH KEY name = `MO_MID->MO_INNER`.
    IF sy-subrc = 0.
      temp132 = temp133.
    ENDIF.
    
    ls_mid = temp132.
    cl_abap_unit_assert=>assert_equals( exp = `MO_MID`
                                        act = ls_mid-name_parent ).

    
    CLEAR temp134.
    
    READ TABLE lt_attri INTO temp135 WITH KEY name = `MO_MID->MO_INNER->MV_INNER`.
    IF sy-subrc = 0.
      temp134 = temp135.
    ENDIF.
    
    ls_inner = temp134.
    cl_abap_unit_assert=>assert_equals( exp = `MO_MID->MO_INNER`
                                        act = ls_inner-name_parent ).

  ENDMETHOD.

ENDCLASS.


CLASS ltcl_test_attri_create DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.
  PRIVATE SECTION.
    METHODS test_string_type_kind FOR TESTING RAISING cx_static_check.
    METHODS test_table_type_kind  FOR TESTING RAISING cx_static_check.
    METHODS test_oref_type_kind   FOR TESTING RAISING cx_static_check.
    METHODS test_int_kind         FOR TESTING RAISING cx_static_check.
ENDCLASS.

CLASS ltcl_test_attri_create IMPLEMENTATION.

  METHOD test_string_type_kind.
    DATA lo_app TYPE REF TO ltcl_app_complex.
    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA temp136 LIKE REF TO lt_attri.
DATA lo_model TYPE REF TO z2ui5_cl_core_srv_model.
    DATA ls_result TYPE z2ui5_if_core_types=>ty_s_attri.
    CREATE OBJECT lo_app TYPE ltcl_app_complex.
    
    
    GET REFERENCE OF lt_attri INTO temp136.

CREATE OBJECT lo_model TYPE z2ui5_cl_core_srv_model EXPORTING attri = temp136 app = lo_app.
    
    ls_result = lo_model->attri_create_new( `MV_SIMPLE` ).
    cl_abap_unit_assert=>assert_equals( exp = cl_abap_datadescr=>typekind_string
                                        act = ls_result-type_kind ).
  ENDMETHOD.

  METHOD test_table_type_kind.
    DATA lo_app TYPE REF TO ltcl_app_complex.
    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA temp137 LIKE REF TO lt_attri.
DATA lo_model TYPE REF TO z2ui5_cl_core_srv_model.
    DATA ls_result TYPE z2ui5_if_core_types=>ty_s_attri.
    CREATE OBJECT lo_app TYPE ltcl_app_complex.
    
    
    GET REFERENCE OF lt_attri INTO temp137.

CREATE OBJECT lo_model TYPE z2ui5_cl_core_srv_model EXPORTING attri = temp137 app = lo_app.
    
    ls_result = lo_model->attri_create_new( `MT_TAB` ).
    cl_abap_unit_assert=>assert_equals( exp = cl_abap_datadescr=>typekind_table
                                        act = ls_result-type_kind ).
  ENDMETHOD.

  METHOD test_oref_type_kind.
    DATA lo_app TYPE REF TO ltcl_app_complex.
    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA temp138 LIKE REF TO lt_attri.
DATA lo_model TYPE REF TO z2ui5_cl_core_srv_model.
    DATA ls_result TYPE z2ui5_if_core_types=>ty_s_attri.
    CREATE OBJECT lo_app TYPE ltcl_app_complex.
    CREATE OBJECT lo_app->mo_mid.
    
    
    GET REFERENCE OF lt_attri INTO temp138.

CREATE OBJECT lo_model TYPE z2ui5_cl_core_srv_model EXPORTING attri = temp138 app = lo_app.
    
    ls_result = lo_model->attri_create_new( `MO_MID` ).
    cl_abap_unit_assert=>assert_equals( exp = cl_abap_datadescr=>typekind_oref
                                        act = ls_result-type_kind ).
  ENDMETHOD.

  METHOD test_int_kind.
    DATA lo_app TYPE REF TO ltcl_app_complex.
    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA temp139 LIKE REF TO lt_attri.
DATA lo_model TYPE REF TO z2ui5_cl_core_srv_model.
    DATA ls_result TYPE z2ui5_if_core_types=>ty_s_attri.
    CREATE OBJECT lo_app TYPE ltcl_app_complex.
    
    
    GET REFERENCE OF lt_attri INTO temp139.

CREATE OBJECT lo_model TYPE z2ui5_cl_core_srv_model EXPORTING attri = temp139 app = lo_app.
    
    ls_result = lo_model->attri_create_new( `MV_INT` ).
    cl_abap_unit_assert=>assert_equals( exp = cl_abap_typedescr=>kind_elem
                                        act = ls_result-kind ).
  ENDMETHOD.

ENDCLASS.


CLASS ltcl_test_json_stringify DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.
  PRIVATE SECTION.
    METHODS test_simple_string FOR TESTING RAISING cx_static_check.
    METHODS test_empty_no_bind FOR TESTING RAISING cx_static_check.
ENDCLASS.

CLASS ltcl_test_json_stringify IMPLEMENTATION.

  METHOD test_simple_string.
    DATA lo_app TYPE REF TO ltcl_app_complex.
    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA temp140 LIKE REF TO lt_attri.
DATA lo_model TYPE REF TO z2ui5_cl_core_srv_model.
    DATA lr_simple TYPE REF TO z2ui5_if_core_types=>ty_s_attri.
    DATA lv_json TYPE string.
    DATA lo_result TYPE REF TO z2ui5_cl_ajson.
    CREATE OBJECT lo_app TYPE ltcl_app_complex.
    lo_app->mv_simple = `hello`.
    
    
    GET REFERENCE OF lt_attri INTO temp140.

CREATE OBJECT lo_model TYPE z2ui5_cl_core_srv_model EXPORTING attri = temp140 app = lo_app.
    lo_model->dissolve( ).

    
    READ TABLE lt_attri REFERENCE INTO lr_simple WITH KEY name = `MV_SIMPLE`.
    IF sy-subrc <> 0.
      cl_abap_unit_assert=>abort( ).
    ENDIF.
    lr_simple->bind_type   = z2ui5_if_core_types=>cs_bind_type-one_way.
    lr_simple->name_client = `/MV_SIMPLE`.

    
    lv_json = lo_model->main_json_stringify( ).
    
    lo_result = z2ui5_cl_ajson=>parse( lv_json ).
    cl_abap_unit_assert=>assert_equals( exp = `hello`
                                        act = lo_result->get_string( `/MV_SIMPLE` ) ).
  ENDMETHOD.

  METHOD test_empty_no_bind.
    DATA lo_app TYPE REF TO ltcl_app_complex.
    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA temp141 LIKE REF TO lt_attri.
DATA lo_model TYPE REF TO z2ui5_cl_core_srv_model.
    DATA lv_json TYPE string.
    CREATE OBJECT lo_app TYPE ltcl_app_complex.
    
    
    GET REFERENCE OF lt_attri INTO temp141.

CREATE OBJECT lo_model TYPE z2ui5_cl_core_srv_model EXPORTING attri = temp141 app = lo_app.
    lo_model->dissolve( ).

    " No bind_type set on any attribute - stringify produces empty JSON object
    
    lv_json = lo_model->main_json_stringify( ).
    cl_abap_unit_assert=>assert_equals( exp = `{}`
                                        act = lv_json ).
  ENDMETHOD.

ENDCLASS.


CLASS ltcl_test_json_to_attri DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.
  PRIVATE SECTION.
    METHODS test_updates_two_way FOR TESTING RAISING cx_static_check.
    METHODS test_skips_one_way   FOR TESTING RAISING cx_static_check.
    METHODS test_view_filter     FOR TESTING RAISING cx_static_check.
ENDCLASS.

CLASS ltcl_test_json_to_attri IMPLEMENTATION.

  METHOD test_updates_two_way.
    DATA lo_app TYPE REF TO ltcl_app_complex.
    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA temp142 LIKE REF TO lt_attri.
DATA lo_model TYPE REF TO z2ui5_cl_core_srv_model.
    DATA lr TYPE REF TO z2ui5_if_core_types=>ty_s_attri.
    DATA lo_model_json TYPE REF TO z2ui5_if_ajson.
    CREATE OBJECT lo_app TYPE ltcl_app_complex.
    
    
    GET REFERENCE OF lt_attri INTO temp142.

CREATE OBJECT lo_model TYPE z2ui5_cl_core_srv_model EXPORTING attri = temp142 app = lo_app.
    lo_model->dissolve( ).

    
    READ TABLE lt_attri REFERENCE INTO lr WITH KEY name = `MV_SIMPLE`.
    IF sy-subrc <> 0.
      cl_abap_unit_assert=>abort( ).
    ENDIF.
    lr->bind_type   = z2ui5_if_core_types=>cs_bind_type-two_way.
    lr->view        = z2ui5_if_client=>cs_view-main.
    lr->name_client = `/MV_SIMPLE`.

    
    lo_model_json = z2ui5_cl_ajson=>create_empty( ).
    lo_model_json->set( iv_path = `/MV_SIMPLE`
                        iv_val  = `updated` ).

    lo_model->main_json_to_attri( view  = z2ui5_if_client=>cs_view-main
                                  model = lo_model_json ).

    cl_abap_unit_assert=>assert_equals( exp = `updated`
                                        act = lo_app->mv_simple ).
  ENDMETHOD.

  METHOD test_skips_one_way.
    DATA lo_app TYPE REF TO ltcl_app_complex.
    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA temp143 LIKE REF TO lt_attri.
DATA lo_model TYPE REF TO z2ui5_cl_core_srv_model.
    DATA lr TYPE REF TO z2ui5_if_core_types=>ty_s_attri.
    DATA lo_model_json TYPE REF TO z2ui5_if_ajson.
    CREATE OBJECT lo_app TYPE ltcl_app_complex.
    
    
    GET REFERENCE OF lt_attri INTO temp143.

CREATE OBJECT lo_model TYPE z2ui5_cl_core_srv_model EXPORTING attri = temp143 app = lo_app.
    lo_model->dissolve( ).

    
    READ TABLE lt_attri REFERENCE INTO lr WITH KEY name = `MV_SIMPLE`.
    IF sy-subrc <> 0.
      cl_abap_unit_assert=>abort( ).
    ENDIF.
    lr->bind_type   = z2ui5_if_core_types=>cs_bind_type-one_way.
    lr->view        = z2ui5_if_client=>cs_view-main.
    lr->name_client = `/MV_SIMPLE`.

    
    lo_model_json = z2ui5_cl_ajson=>create_empty( ).
    lo_model_json->set( iv_path = `/MV_SIMPLE`
                        iv_val  = `should_not_update` ).

    lo_model->main_json_to_attri( view  = z2ui5_if_client=>cs_view-main
                                  model = lo_model_json ).

    " ONE_WAY binding - value must not be written back from frontend
    cl_abap_unit_assert=>assert_equals( exp = ``
                                        act = lo_app->mv_simple ).
  ENDMETHOD.

  METHOD test_view_filter.
    DATA lo_app TYPE REF TO ltcl_app_complex.
    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA temp144 LIKE REF TO lt_attri.
DATA lo_model TYPE REF TO z2ui5_cl_core_srv_model.
    DATA lr TYPE REF TO z2ui5_if_core_types=>ty_s_attri.
    DATA lo_model_json TYPE REF TO z2ui5_if_ajson.
    CREATE OBJECT lo_app TYPE ltcl_app_complex.
    
    
    GET REFERENCE OF lt_attri INTO temp144.

CREATE OBJECT lo_model TYPE z2ui5_cl_core_srv_model EXPORTING attri = temp144 app = lo_app.
    lo_model->dissolve( ).

    
    READ TABLE lt_attri REFERENCE INTO lr WITH KEY name = `MV_SIMPLE`.
    IF sy-subrc <> 0.
      cl_abap_unit_assert=>abort( ).
    ENDIF.
    lr->bind_type   = z2ui5_if_core_types=>cs_bind_type-two_way.
    lr->view        = z2ui5_if_client=>cs_view-popup.
    lr->name_client = `/MV_SIMPLE`.

    
    lo_model_json = z2ui5_cl_ajson=>create_empty( ).
    lo_model_json->set( iv_path = `/MV_SIMPLE`
                        iv_val  = `should_not_update` ).

    " Attribute belongs to POPUP view, called with MAIN view - must not be updated
    lo_model->main_json_to_attri( view  = z2ui5_if_client=>cs_view-main
                                  model = lo_model_json ).

    cl_abap_unit_assert=>assert_equals( exp = ``
                                        act = lo_app->mv_simple ).
  ENDMETHOD.

ENDCLASS.


CLASS ltcl_test_attri_refresh DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.
  PRIVATE SECTION.
    METHODS test_bindings_preserved FOR TESTING RAISING cx_static_check.
ENDCLASS.

CLASS ltcl_test_attri_refresh IMPLEMENTATION.

  METHOD test_bindings_preserved.
    DATA lo_app TYPE REF TO ltcl_app_complex.
    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA temp145 LIKE REF TO lt_attri.
DATA lo_model TYPE REF TO z2ui5_cl_core_srv_model.
    DATA lr TYPE REF TO z2ui5_if_core_types=>ty_s_attri.
    DATA temp146 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp147 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA ls_after LIKE temp146.
    CREATE OBJECT lo_app TYPE ltcl_app_complex.
    
    
    GET REFERENCE OF lt_attri INTO temp145.

CREATE OBJECT lo_model TYPE z2ui5_cl_core_srv_model EXPORTING attri = temp145 app = lo_app.
    lo_model->dissolve( ).

    " Simulate an active binding on MV_SIMPLE
    
    READ TABLE lt_attri REFERENCE INTO lr WITH KEY name = `MV_SIMPLE`.
    IF sy-subrc <> 0.
      cl_abap_unit_assert=>abort( ).
    ENDIF.
    lr->bind_type   = z2ui5_if_core_types=>cs_bind_type-two_way.
    lr->name_client = `/XX/MV_SIMPLE`.
    lr->view        = z2ui5_if_client=>cs_view-main.

    " Refresh clears and re-dissolves but must restore binding info
    lo_model->main_attri_refresh( ).

    
    CLEAR temp146.
    
    READ TABLE lt_attri INTO temp147 WITH KEY name = `MV_SIMPLE`.
    IF sy-subrc = 0.
      temp146 = temp147.
    ENDIF.
    
    ls_after = temp146.
    cl_abap_unit_assert=>assert_equals( exp = z2ui5_if_core_types=>cs_bind_type-two_way
                                        act = ls_after-bind_type ).
    cl_abap_unit_assert=>assert_equals( exp = `/XX/MV_SIMPLE`
                                        act = ls_after-name_client ).
    cl_abap_unit_assert=>assert_equals( exp = z2ui5_if_client=>cs_view-main
                                        act = ls_after-view ).
  ENDMETHOD.

ENDCLASS.


CLASS ltcl_test_entry_refs_children DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION MEDIUM.
  PRIVATE SECTION.
    METHODS test_dref_children_name_ref FOR TESTING RAISING cx_static_check.
    METHODS test_second_dref_children   FOR TESTING RAISING cx_static_check.
ENDCLASS.

CLASS ltcl_test_entry_refs_children IMPLEMENTATION.

  METHOD test_dref_children_name_ref.
    DATA lo_app TYPE REF TO ltcl_app_root_335.
    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA temp148 LIKE REF TO lt_attri.
DATA lo_model TYPE REF TO z2ui5_cl_core_srv_model.
    DATA temp149 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp150 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA ls_child1 LIKE temp149.
    DATA temp151 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp152 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA ls_child2 LIKE temp151.

    IF sy-sysid = `ABC`.
      RETURN.
    ENDIF.

    
    CREATE OBJECT lo_app TYPE ltcl_app_root_335.
    
    
    GET REFERENCE OF lt_attri INTO temp148.

CREATE OBJECT lo_model TYPE z2ui5_cl_core_srv_model EXPORTING attri = temp148 app = lo_app.
    lo_model->dissolve( ).
    lo_model->dissolve( ).
    lo_model->dissolve( ).

    " MO_OBJ->MR_DATA points to MS_STRUC - dissolved children must get name_ref
    
    CLEAR temp149.
    
    READ TABLE lt_attri INTO temp150 WITH KEY name = `MO_OBJ->MR_DATA->COMP1`.
    IF sy-subrc = 0.
      temp149 = temp150.
    ENDIF.
    
    ls_child1 = temp149.
    cl_abap_unit_assert=>assert_equals( exp = `MS_STRUC-COMP1`
                                        act = ls_child1-name_ref ).

    
    CLEAR temp151.
    
    READ TABLE lt_attri INTO temp152 WITH KEY name = `MO_OBJ->MR_DATA->COMP2`.
    IF sy-subrc = 0.
      temp151 = temp152.
    ENDIF.
    
    ls_child2 = temp151.
    cl_abap_unit_assert=>assert_equals( exp = `MS_STRUC-COMP2`
                                        act = ls_child2-name_ref ).

  ENDMETHOD.

  METHOD test_second_dref_children.
    DATA lo_app TYPE REF TO ltcl_app_root_335.
    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA temp153 LIKE REF TO lt_attri.
DATA lo_model TYPE REF TO z2ui5_cl_core_srv_model.
    DATA temp154 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp155 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA ls_child1 LIKE temp154.
    DATA temp156 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp157 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA ls_child2 LIKE temp156.

    IF sy-sysid = `ABC`.
      RETURN.
    ENDIF.

    
    CREATE OBJECT lo_app TYPE ltcl_app_root_335.
    
    
    GET REFERENCE OF lt_attri INTO temp153.

CREATE OBJECT lo_model TYPE z2ui5_cl_core_srv_model EXPORTING attri = temp153 app = lo_app.
    lo_model->dissolve( ).
    lo_model->dissolve( ).
    lo_model->dissolve( ).

    " MO_OBJ_2->MR_DATA also points to same MS_STRUC - children get name_ref too
    
    CLEAR temp154.
    
    READ TABLE lt_attri INTO temp155 WITH KEY name = `MO_OBJ_2->MR_DATA->COMP1`.
    IF sy-subrc = 0.
      temp154 = temp155.
    ENDIF.
    
    ls_child1 = temp154.
    cl_abap_unit_assert=>assert_equals( exp = `MS_STRUC-COMP1`
                                        act = ls_child1-name_ref ).

    
    CLEAR temp156.
    
    READ TABLE lt_attri INTO temp157 WITH KEY name = `MO_OBJ_2->MR_DATA->COMP2`.
    IF sy-subrc = 0.
      temp156 = temp157.
    ENDIF.
    
    ls_child2 = temp156.
    cl_abap_unit_assert=>assert_equals( exp = `MS_STRUC-COMP2`
                                        act = ls_child2-name_ref ).

  ENDMETHOD.

ENDCLASS.


CLASS ltcl_test_delta_apply DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.
  PRIVATE SECTION.
    METHODS test_update_first_row  FOR TESTING RAISING cx_static_check.
    METHODS test_update_second_row FOR TESTING RAISING cx_static_check.
    METHODS test_out_of_range      FOR TESTING RAISING cx_static_check.
ENDCLASS.

CLASS ltcl_test_delta_apply IMPLEMENTATION.

  METHOD test_update_first_row.
    DATA lo_app TYPE REF TO ltcl_app_complex.
    DATA temp158 TYPE ltcl_app_complex=>ty_t_tab.
    DATA temp159 LIKE LINE OF temp158.
    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA temp160 LIKE REF TO lt_attri.
DATA lo_model TYPE REF TO z2ui5_cl_core_srv_model.
    DATA lo_delta TYPE REF TO z2ui5_if_ajson.
    DATA temp161 LIKE LINE OF lo_app->mt_tab.
    DATA temp162 LIKE sy-tabix.
    DATA temp163 LIKE LINE OF lo_app->mt_tab.
    DATA temp164 LIKE sy-tabix.
    DATA temp165 LIKE LINE OF lo_app->mt_tab.
    DATA temp166 LIKE sy-tabix.
    CREATE OBJECT lo_app TYPE ltcl_app_complex.
    
    CLEAR temp158.
    
    temp159-col1 = `A`.
    temp159-col2 = `1`.
    INSERT temp159 INTO TABLE temp158.
    temp159-col1 = `B`.
    temp159-col2 = `2`.
    INSERT temp159 INTO TABLE temp158.
    lo_app->mt_tab = temp158.
    
    
    GET REFERENCE OF lt_attri INTO temp160.

CREATE OBJECT lo_model TYPE z2ui5_cl_core_srv_model EXPORTING attri = temp160 app = lo_app.

    
    lo_delta = z2ui5_cl_ajson=>create_empty( ).
    lo_delta->set( iv_path = `/__delta/0/COL1`
                   iv_val  = `X` ).

    lo_model->delta_apply_to_table( io_val_front = lo_delta
                                    iv_name      = `MT_TAB` ).

    " Index 0 maps to ABAP table row 1
    
    
    temp162 = sy-tabix.
    READ TABLE lo_app->mt_tab INDEX 1 INTO temp161.
    sy-tabix = temp162.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `X`
                                        act = temp161-col1 ).
    
    
    temp164 = sy-tabix.
    READ TABLE lo_app->mt_tab INDEX 1 INTO temp163.
    sy-tabix = temp164.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `1`
                                        act = temp163-col2 ).
    
    
    temp166 = sy-tabix.
    READ TABLE lo_app->mt_tab INDEX 2 INTO temp165.
    sy-tabix = temp166.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `B`
                                        act = temp165-col1 ).
  ENDMETHOD.

  METHOD test_update_second_row.
    DATA lo_app TYPE REF TO ltcl_app_complex.
    DATA temp167 TYPE ltcl_app_complex=>ty_t_tab.
    DATA temp168 LIKE LINE OF temp167.
    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA temp169 LIKE REF TO lt_attri.
DATA lo_model TYPE REF TO z2ui5_cl_core_srv_model.
    DATA lo_delta TYPE REF TO z2ui5_if_ajson.
    DATA temp170 LIKE LINE OF lo_app->mt_tab.
    DATA temp171 LIKE sy-tabix.
    DATA temp172 LIKE LINE OF lo_app->mt_tab.
    DATA temp173 LIKE sy-tabix.
    DATA temp174 LIKE LINE OF lo_app->mt_tab.
    DATA temp175 LIKE sy-tabix.
    CREATE OBJECT lo_app TYPE ltcl_app_complex.
    
    CLEAR temp167.
    
    temp168-col1 = `A`.
    temp168-col2 = `1`.
    INSERT temp168 INTO TABLE temp167.
    temp168-col1 = `B`.
    temp168-col2 = `2`.
    INSERT temp168 INTO TABLE temp167.
    lo_app->mt_tab = temp167.
    
    
    GET REFERENCE OF lt_attri INTO temp169.

CREATE OBJECT lo_model TYPE z2ui5_cl_core_srv_model EXPORTING attri = temp169 app = lo_app.

    
    lo_delta = z2ui5_cl_ajson=>create_empty( ).
    lo_delta->set( iv_path = `/__delta/1/COL2`
                   iv_val  = `Y` ).

    lo_model->delta_apply_to_table( io_val_front = lo_delta
                                    iv_name      = `MT_TAB` ).

    " Index 1 maps to ABAP table row 2
    
    
    temp171 = sy-tabix.
    READ TABLE lo_app->mt_tab INDEX 1 INTO temp170.
    sy-tabix = temp171.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `A`
                                        act = temp170-col1 ).
    
    
    temp173 = sy-tabix.
    READ TABLE lo_app->mt_tab INDEX 2 INTO temp172.
    sy-tabix = temp173.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `Y`
                                        act = temp172-col2 ).
    
    
    temp175 = sy-tabix.
    READ TABLE lo_app->mt_tab INDEX 2 INTO temp174.
    sy-tabix = temp175.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `B`
                                        act = temp174-col1 ).
  ENDMETHOD.

  METHOD test_out_of_range.
    DATA lo_app TYPE REF TO ltcl_app_complex.
    DATA temp176 TYPE ltcl_app_complex=>ty_t_tab.
    DATA temp177 LIKE LINE OF temp176.
    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA temp178 LIKE REF TO lt_attri.
DATA lo_model TYPE REF TO z2ui5_cl_core_srv_model.
    DATA lo_delta TYPE REF TO z2ui5_if_ajson.
    DATA temp179 LIKE LINE OF lo_app->mt_tab.
    DATA temp180 LIKE sy-tabix.
    CREATE OBJECT lo_app TYPE ltcl_app_complex.
    
    CLEAR temp176.
    
    temp177-col1 = `A`.
    temp177-col2 = `1`.
    INSERT temp177 INTO TABLE temp176.
    lo_app->mt_tab = temp176.
    
    
    GET REFERENCE OF lt_attri INTO temp178.

CREATE OBJECT lo_model TYPE z2ui5_cl_core_srv_model EXPORTING attri = temp178 app = lo_app.

    
    lo_delta = z2ui5_cl_ajson=>create_empty( ).
    lo_delta->set( iv_path = `/__delta/5/COL1`
                   iv_val  = `Z` ).

    " Index 5 is out of range for a 1-row table - no crash, table unchanged
    lo_model->delta_apply_to_table( io_val_front = lo_delta
                                    iv_name      = `MT_TAB` ).

    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( lo_app->mt_tab ) ).
    
    
    temp180 = sy-tabix.
    READ TABLE lo_app->mt_tab INDEX 1 INTO temp179.
    sy-tabix = temp180.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `A`
                                        act = temp179-col1 ).
  ENDMETHOD.

ENDCLASS.


"------------------------------------------------------------------------
" Helper: two orefs whose MR_DATA both point to the same MT_TAB table
"------------------------------------------------------------------------
CLASS ltcl_app_two_tab_drefs DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    TYPES:
      BEGIN OF ty_s_row,
        col1 TYPE string,
        col2 TYPE string,
      END OF ty_s_row.
    TYPES ty_t_tab TYPE STANDARD TABLE OF ty_s_row WITH DEFAULT KEY.

    DATA mt_tab  TYPE ty_t_tab.
    DATA mo_ref1 TYPE REF TO ltcl_app_inner_335.
    DATA mo_ref2 TYPE REF TO ltcl_app_inner_335.

    METHODS constructor.

ENDCLASS.

CLASS ltcl_app_two_tab_drefs IMPLEMENTATION.

  METHOD z2ui5_if_app~main ##NEEDED.
  ENDMETHOD.

  METHOD constructor.
    DATA temp181 LIKE REF TO mt_tab.
    DATA temp182 LIKE REF TO mt_tab.
    GET REFERENCE OF mt_tab INTO temp181.
CREATE OBJECT mo_ref1 TYPE ltcl_app_inner_335 EXPORTING ir_data = temp181.
    
    GET REFERENCE OF mt_tab INTO temp182.
CREATE OBJECT mo_ref2 TYPE ltcl_app_inner_335 EXPORTING ir_data = temp182.
  ENDMETHOD.

ENDCLASS.


CLASS ltcl_test_two_tab_refs DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION MEDIUM.
  PRIVATE SECTION.
    METHODS test_both_get_name_ref  FOR TESTING RAISING cx_static_check.
    METHODS test_canonical_search   FOR TESTING RAISING cx_static_check.
ENDCLASS.

CLASS ltcl_test_two_tab_refs IMPLEMENTATION.

  METHOD test_both_get_name_ref.
    " Both MO_REF1->MR_DATA->* and MO_REF2->MR_DATA->* point to MT_TAB.
    " attri_update_entry_refs must set name_ref = MT_TAB for both paths.
    DATA lo_app TYPE REF TO ltcl_app_two_tab_drefs.
    DATA temp183 TYPE ltcl_app_two_tab_drefs=>ty_t_tab.
    DATA temp184 LIKE LINE OF temp183.
    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA temp185 LIKE REF TO lt_attri.
DATA lo_model TYPE REF TO z2ui5_cl_core_srv_model.
    DATA temp186 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp187 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA ls_ref1 LIKE temp186.
    DATA temp188 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp189 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA ls_ref2 LIKE temp188.
    CREATE OBJECT lo_app TYPE ltcl_app_two_tab_drefs.
    
    CLEAR temp183.
    
    temp184-col1 = `A`.
    temp184-col2 = `1`.
    INSERT temp184 INTO TABLE temp183.
    lo_app->mt_tab = temp183.

    
    
    GET REFERENCE OF lt_attri INTO temp185.

CREATE OBJECT lo_model TYPE z2ui5_cl_core_srv_model EXPORTING attri = temp185 app = lo_app.
    lo_model->dissolve( ).
    lo_model->dissolve( ).
    lo_model->dissolve( ).

    
    CLEAR temp186.
    
    READ TABLE lt_attri INTO temp187 WITH KEY name = `MO_REF1->MR_DATA->*`.
    IF sy-subrc = 0.
      temp186 = temp187.
    ENDIF.
    
    ls_ref1 = temp186.
    cl_abap_unit_assert=>assert_equals( exp = `MT_TAB`
                                        act = ls_ref1-name_ref ).

    
    CLEAR temp188.
    
    READ TABLE lt_attri INTO temp189 WITH KEY name = `MO_REF2->MR_DATA->*`.
    IF sy-subrc = 0.
      temp188 = temp189.
    ENDIF.
    
    ls_ref2 = temp188.
    cl_abap_unit_assert=>assert_equals( exp = `MT_TAB`
                                        act = ls_ref2-name_ref ).
  ENDMETHOD.

  METHOD test_canonical_search.
    " attri_search via the canonical MT_TAB attribute must resolve correctly
    DATA lo_app TYPE REF TO ltcl_app_two_tab_drefs.
    DATA temp190 TYPE ltcl_app_two_tab_drefs=>ty_t_tab.
    DATA temp191 LIKE LINE OF temp190.
    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA temp192 LIKE REF TO lt_attri.
DATA lo_model TYPE REF TO z2ui5_cl_core_srv_model.
    DATA lr_tab TYPE REF TO data.
    FIELD-SYMBOLS <tab> TYPE data.
    CREATE OBJECT lo_app TYPE ltcl_app_two_tab_drefs.
    
    CLEAR temp190.
    
    temp191-col1 = `X`.
    temp191-col2 = `Y`.
    INSERT temp191 INTO TABLE temp190.
    lo_app->mt_tab = temp190.

    
    
    GET REFERENCE OF lt_attri INTO temp192.

CREATE OBJECT lo_model TYPE z2ui5_cl_core_srv_model EXPORTING attri = temp192 app = lo_app.
    lo_model->dissolve( ).
    lo_model->dissolve( ).
    lo_model->dissolve( ).

    
    lr_tab = lo_model->attri_get_val_ref( `MT_TAB` ).
    cl_abap_unit_assert=>assert_bound( lr_tab ).

    
    ASSIGN lr_tab->* TO <tab>.
    cl_abap_unit_assert=>assert_not_initial( <tab> ).
  ENDMETHOD.

ENDCLASS.


CLASS ltcl_test_deep_nesting DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.
  PRIVATE SECTION.
    METHODS test_deep_struct_writeback FOR TESTING RAISING cx_static_check.
    METHODS test_deep_oref_writeback   FOR TESTING RAISING cx_static_check.
ENDCLASS.

CLASS ltcl_test_deep_nesting IMPLEMENTATION.

  METHOD test_deep_struct_writeback.
    " MS_NESTED-INNER-DEEP1 is three levels deep inside a nested struct.
    " main_json_to_attri must write through all levels.
    DATA lo_app TYPE REF TO ltcl_app_complex.
    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA temp193 LIKE REF TO lt_attri.
DATA lo_model TYPE REF TO z2ui5_cl_core_srv_model.
    DATA lr TYPE REF TO z2ui5_if_core_types=>ty_s_attri.
    DATA lo_model_json TYPE REF TO z2ui5_if_ajson.
    CREATE OBJECT lo_app TYPE ltcl_app_complex.
    
    
    GET REFERENCE OF lt_attri INTO temp193.

CREATE OBJECT lo_model TYPE z2ui5_cl_core_srv_model EXPORTING attri = temp193 app = lo_app.
    lo_model->dissolve( ).
    lo_model->dissolve( ).

    
    READ TABLE lt_attri REFERENCE INTO lr WITH KEY name = `MS_NESTED-INNER-DEEP1`.
    IF sy-subrc <> 0.
      cl_abap_unit_assert=>abort( ).
    ENDIF.
    lr->bind_type   = z2ui5_if_core_types=>cs_bind_type-two_way.
    lr->view        = z2ui5_if_client=>cs_view-main.
    lr->name_client = `/MS_NESTED-INNER-DEEP1`.

    
    lo_model_json = z2ui5_cl_ajson=>create_empty( ).
    lo_model_json->set( iv_path = `/MS_NESTED-INNER-DEEP1`
                        iv_val  = `deep_value` ).

    lo_model->main_json_to_attri( view  = z2ui5_if_client=>cs_view-main
                                  model = lo_model_json ).

    cl_abap_unit_assert=>assert_equals( exp = `deep_value`
                                        act = lo_app->ms_nested-inner-deep1 ).
  ENDMETHOD.

  METHOD test_deep_oref_writeback.
    " MO_MID->MO_INNER->MV_INNER is accessed through two oref hops.
    " main_json_to_attri must write the value all the way through.
    DATA lo_app TYPE REF TO ltcl_app_complex.
    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA temp194 LIKE REF TO lt_attri.
DATA lo_model TYPE REF TO z2ui5_cl_core_srv_model.
    DATA lr_inner TYPE REF TO z2ui5_if_core_types=>ty_s_attri.
    DATA lo_model_json TYPE REF TO z2ui5_if_ajson.
    CREATE OBJECT lo_app TYPE ltcl_app_complex.
    CREATE OBJECT lo_app->mo_mid.
    CREATE OBJECT lo_app->mo_mid->mo_inner.

    
    
    GET REFERENCE OF lt_attri INTO temp194.

CREATE OBJECT lo_model TYPE z2ui5_cl_core_srv_model EXPORTING attri = temp194 app = lo_app.
    lo_model->dissolve( ).
    lo_model->dissolve( ).
    lo_model->dissolve( ).

    
    READ TABLE lt_attri REFERENCE INTO lr_inner WITH KEY name = `MO_MID->MO_INNER->MV_INNER`.
    IF sy-subrc <> 0.
      cl_abap_unit_assert=>abort( ).
    ENDIF.
    lr_inner->bind_type   = z2ui5_if_core_types=>cs_bind_type-two_way.
    lr_inner->view        = z2ui5_if_client=>cs_view-main.
    lr_inner->name_client = `/MO_MID-MO_INNER-MV_INNER`.

    
    lo_model_json = z2ui5_cl_ajson=>create_empty( ).
    lo_model_json->set( iv_path = `/MO_MID-MO_INNER-MV_INNER`
                        iv_val  = `inner_value` ).

    lo_model->main_json_to_attri( view  = z2ui5_if_client=>cs_view-main
                                  model = lo_model_json ).

    cl_abap_unit_assert=>assert_equals( exp = `inner_value`
                                        act = lo_app->mo_mid->mo_inner->mv_inner ).
  ENDMETHOD.

ENDCLASS.


CLASS ltcl_test_refresh_ext DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.
  PRIVATE SECTION.
    METHODS test_oref_after_null_refresh FOR TESTING RAISING cx_static_check.
ENDCLASS.

CLASS ltcl_test_refresh_ext IMPLEMENTATION.

  METHOD test_oref_after_null_refresh.
    " MO_MID is initially NULL so MO_MID->MV_MID is not discovered in first dissolve.
    " After instantiating MO_MID and calling main_attri_refresh, the child
    " MO_MID->MV_MID must appear while the existing MV_SIMPLE binding is preserved.
    DATA lo_app TYPE REF TO ltcl_app_complex.
    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA temp195 LIKE REF TO lt_attri.
DATA lo_model TYPE REF TO z2ui5_cl_core_srv_model.
    DATA lr TYPE REF TO z2ui5_if_core_types=>ty_s_attri.
    DATA temp196 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp197 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp198 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA temp199 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA ls_simple LIKE temp198.
    CREATE OBJECT lo_app TYPE ltcl_app_complex.
    
    
    GET REFERENCE OF lt_attri INTO temp195.

CREATE OBJECT lo_model TYPE z2ui5_cl_core_srv_model EXPORTING attri = temp195 app = lo_app.
    lo_model->dissolve( ).

    " Set an active binding on MV_SIMPLE before refresh
    
    READ TABLE lt_attri REFERENCE INTO lr WITH KEY name = `MV_SIMPLE`.
    IF sy-subrc <> 0.
      cl_abap_unit_assert=>abort( ).
    ENDIF.
    lr->bind_type   = z2ui5_if_core_types=>cs_bind_type-two_way.
    lr->name_client = `/XX/MV_SIMPLE`.
    lr->view        = z2ui5_if_client=>cs_view-main.

    " Now instantiate the previously-null oref and refresh
    CREATE OBJECT lo_app->mo_mid.
    lo_model->main_attri_refresh( ).

    " After refresh, MO_MID->MV_MID must now be discovered
    
    CLEAR temp196.
    
    READ TABLE lt_attri INTO temp197 WITH KEY name = `MO_MID->MV_MID`.
    IF sy-subrc = 0.
      temp196 = temp197.
    ENDIF.
    cl_abap_unit_assert=>assert_not_initial(
        temp196 ).

    " The pre-existing MV_SIMPLE binding must be preserved
    
    CLEAR temp198.
    
    READ TABLE lt_attri INTO temp199 WITH KEY name = `MV_SIMPLE`.
    IF sy-subrc = 0.
      temp198 = temp199.
    ENDIF.
    
    ls_simple = temp198.
    cl_abap_unit_assert=>assert_equals( exp = z2ui5_if_core_types=>cs_bind_type-two_way
                                        act = ls_simple-bind_type ).
    cl_abap_unit_assert=>assert_equals( exp = `/XX/MV_SIMPLE`
                                        act = ls_simple-name_client ).
  ENDMETHOD.

ENDCLASS.


CLASS ltcl_test_json_types DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.
  PRIVATE SECTION.
    METHODS test_updates_integer FOR TESTING RAISING cx_static_check.
    METHODS test_multiple_attrs_same_var FOR TESTING RAISING cx_static_check.
ENDCLASS.

CLASS ltcl_test_json_types IMPLEMENTATION.

  METHOD test_updates_integer.
    " MV_INT is TYPE i - main_json_to_attri must write numeric JSON back correctly.
    DATA lo_app TYPE REF TO ltcl_app_complex.
    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA temp200 LIKE REF TO lt_attri.
DATA lo_model TYPE REF TO z2ui5_cl_core_srv_model.
    DATA lr TYPE REF TO z2ui5_if_core_types=>ty_s_attri.
    DATA lo_model_json TYPE REF TO z2ui5_if_ajson.
    CREATE OBJECT lo_app TYPE ltcl_app_complex.
    
    
    GET REFERENCE OF lt_attri INTO temp200.

CREATE OBJECT lo_model TYPE z2ui5_cl_core_srv_model EXPORTING attri = temp200 app = lo_app.
    lo_model->dissolve( ).

    
    READ TABLE lt_attri REFERENCE INTO lr WITH KEY name = `MV_INT`.
    IF sy-subrc <> 0.
      cl_abap_unit_assert=>abort( ).
    ENDIF.
    lr->bind_type   = z2ui5_if_core_types=>cs_bind_type-two_way.
    lr->view        = z2ui5_if_client=>cs_view-main.
    lr->name_client = `/MV_INT`.

    
    lo_model_json = z2ui5_cl_ajson=>create_empty( ).
    lo_model_json->set( iv_path = `/MV_INT`
                        iv_val  = 42 ).

    lo_model->main_json_to_attri( view  = z2ui5_if_client=>cs_view-main
                                  model = lo_model_json ).

    cl_abap_unit_assert=>assert_equals( exp = 42
                                        act = lo_app->mv_int ).
  ENDMETHOD.

  METHOD test_multiple_attrs_same_var.
    " Bind the same variable (MV_SIMPLE) under two different name_client paths
    " and verify that the last written value wins (both writes target the same memory).
    DATA lo_app TYPE REF TO ltcl_app_complex.
    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA temp201 LIKE REF TO lt_attri.
DATA lo_model TYPE REF TO z2ui5_cl_core_srv_model.
    DATA lr1 TYPE REF TO z2ui5_if_core_types=>ty_s_attri.
    DATA ls_extra TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA lo_model_json TYPE REF TO z2ui5_if_ajson.
    CREATE OBJECT lo_app TYPE ltcl_app_complex.
    
    
    GET REFERENCE OF lt_attri INTO temp201.

CREATE OBJECT lo_model TYPE z2ui5_cl_core_srv_model EXPORTING attri = temp201 app = lo_app.
    lo_model->dissolve( ).

    " First entry: bind MV_SIMPLE as /XX/MV_SIMPLE
    
    READ TABLE lt_attri REFERENCE INTO lr1 WITH KEY name = `MV_SIMPLE`.
    IF sy-subrc <> 0.
      cl_abap_unit_assert=>abort( ).
    ENDIF.
    lr1->bind_type   = z2ui5_if_core_types=>cs_bind_type-two_way.
    lr1->view        = z2ui5_if_client=>cs_view-main.
    lr1->name_client = `/XX/MV_SIMPLE`.

    " Second entry: a copy with a different name_client path, also two-way
    
    ls_extra = lr1->*.
    ls_extra-name        = `MV_SIMPLE_ALIAS`.
    ls_extra-name_client = `/XX/ALIAS`.
    INSERT ls_extra INTO TABLE lt_attri.

    
    lo_model_json = z2ui5_cl_ajson=>create_empty( ).
    lo_model_json->set( iv_path = `/XX/MV_SIMPLE`
                        iv_val  = `first` ).

    lo_model->main_json_to_attri( view  = z2ui5_if_client=>cs_view-main
                                  model = lo_model_json ).

    " Only the canonical path was present in JSON, so MV_SIMPLE gets 'first'
    cl_abap_unit_assert=>assert_equals( exp = `first`
                                        act = lo_app->mv_simple ).
  ENDMETHOD.

ENDCLASS.
