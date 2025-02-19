CLASS ltcl_test_dissolve DEFINITION DEFERRED.
CLASS z2ui5_cl_core_srv_diss DEFINITION LOCAL FRIENDS ltcl_test_dissolve.

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

    DATA lo_app TYPE REF TO ltcl_test_dissolve.
    CREATE OBJECT lo_app TYPE ltcl_test_dissolve.

    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA temp11 LIKE REF TO lt_attri.
    GET REFERENCE OF lt_attri INTO temp11.
DATA lo_model TYPE REF TO z2ui5_cl_core_srv_diss.
CREATE OBJECT lo_model TYPE z2ui5_cl_core_srv_diss EXPORTING attri = temp11 app = lo_app.

    lo_model->main( ).

    DATA ls_attri LIKE LINE OF lt_attri.
    DATA temp2 LIKE LINE OF lt_attri.
    DATA temp3 LIKE sy-tabix.
    temp3 = sy-tabix.
    READ TABLE lt_attri WITH KEY name = `MV_VALUE` INTO temp2.
    sy-tabix = temp3.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    ls_attri = temp2.
    DATA lr_ref LIKE REF TO lo_app->mv_value.
    GET REFERENCE OF lo_app->mv_value INTO lr_ref.

    IF ls_attri-r_ref <> lr_ref.
      cl_abap_unit_assert=>abort( ).
    ENDIF.

  ENDMETHOD.

  METHOD test_init.

    DATA lo_app TYPE REF TO ltcl_test_dissolve.
    CREATE OBJECT lo_app TYPE ltcl_test_dissolve.

    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA temp12 LIKE REF TO lt_attri.
    GET REFERENCE OF lt_attri INTO temp12.
DATA lo_model TYPE REF TO z2ui5_cl_core_srv_diss.
CREATE OBJECT lo_model TYPE z2ui5_cl_core_srv_diss EXPORTING attri = temp12 app = lo_app.

    lo_model->main( ).
    lo_model->main( ).
    lo_model->main( ).

    DATA temp13 TYPE z2ui5_if_core_types=>ty_s_attri.
    CLEAR temp13.
    DATA temp14 TYPE z2ui5_if_core_types=>ty_s_attri.
    READ TABLE lt_attri INTO temp14 WITH KEY name = `MR_STRUC`.
    IF sy-subrc = 0.
      temp13 = temp14.
    ENDIF.
    cl_abap_unit_assert=>assert_not_initial( temp13 ).
    DATA temp15 TYPE z2ui5_if_core_types=>ty_s_attri.
    CLEAR temp15.
    DATA temp16 TYPE z2ui5_if_core_types=>ty_s_attri.
    READ TABLE lt_attri INTO temp16 WITH KEY name = `MR_VALUE`.
    IF sy-subrc = 0.
      temp15 = temp16.
    ENDIF.
    cl_abap_unit_assert=>assert_not_initial( temp15 ).
    DATA temp17 TYPE z2ui5_if_core_types=>ty_s_attri.
    CLEAR temp17.
    DATA temp18 TYPE z2ui5_if_core_types=>ty_s_attri.
    READ TABLE lt_attri INTO temp18 WITH KEY name = `MS_STRUC`.
    IF sy-subrc = 0.
      temp17 = temp18.
    ENDIF.
    cl_abap_unit_assert=>assert_not_initial( temp17 ).
    DATA temp19 TYPE z2ui5_if_core_types=>ty_s_attri.
    CLEAR temp19.
    DATA temp20 TYPE z2ui5_if_core_types=>ty_s_attri.
    READ TABLE lt_attri INTO temp20 WITH KEY name = `MV_VALUE`.
    IF sy-subrc = 0.
      temp19 = temp20.
    ENDIF.
    cl_abap_unit_assert=>assert_not_initial( temp19 ).

  ENDMETHOD.

  METHOD test_dref.

    DATA lo_app TYPE REF TO ltcl_test_dissolve.
    CREATE OBJECT lo_app TYPE ltcl_test_dissolve.
    CREATE DATA lo_app->mr_struc.
    CREATE DATA lo_app->mr_value TYPE string.

    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA temp21 LIKE REF TO lt_attri.
    GET REFERENCE OF lt_attri INTO temp21.
DATA lo_model TYPE REF TO z2ui5_cl_core_srv_diss.
CREATE OBJECT lo_model TYPE z2ui5_cl_core_srv_diss EXPORTING attri = temp21 app = lo_app.

    lo_model->main( ).
    lo_model->main( ).

    DATA temp22 TYPE z2ui5_if_core_types=>ty_s_attri.
    CLEAR temp22.
    DATA temp23 TYPE z2ui5_if_core_types=>ty_s_attri.
    READ TABLE lt_attri INTO temp23 WITH KEY name = `MR_VALUE->*`.
    IF sy-subrc = 0.
      temp22 = temp23.
    ENDIF.
    cl_abap_unit_assert=>assert_not_initial( temp22 ).

  ENDMETHOD.

  METHOD test_oref.

    DATA lo_app TYPE REF TO ltcl_test_dissolve.
    CREATE OBJECT lo_app TYPE ltcl_test_dissolve.
    CREATE OBJECT lo_app->mo_app.
    DATA lo_app2 TYPE REF TO ltcl_test_dissolve.
    CREATE OBJECT lo_app2 TYPE ltcl_test_dissolve.
    lo_app2->mo_app = lo_app.

    CREATE DATA lo_app->mo_app->mr_struc.
    CREATE DATA lo_app->mo_app->mr_value TYPE string.

    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA temp24 LIKE REF TO lt_attri.
    GET REFERENCE OF lt_attri INTO temp24.
DATA lo_model TYPE REF TO z2ui5_cl_core_srv_diss.
CREATE OBJECT lo_model TYPE z2ui5_cl_core_srv_diss EXPORTING attri = temp24 app = lo_app2.

    lo_model->main( ).
    lo_model->main( ).
    lo_model->main( ).

    DATA temp25 TYPE z2ui5_if_core_types=>ty_s_attri.
    CLEAR temp25.
    DATA temp26 TYPE z2ui5_if_core_types=>ty_s_attri.
    READ TABLE lt_attri INTO temp26 WITH KEY name = `MO_APP->MV_VALUE`.
    IF sy-subrc = 0.
      temp25 = temp26.
    ENDIF.
    cl_abap_unit_assert=>assert_not_initial( temp25 ).
    DATA temp27 TYPE z2ui5_if_core_types=>ty_s_attri.
    CLEAR temp27.
    DATA temp28 TYPE z2ui5_if_core_types=>ty_s_attri.
    READ TABLE lt_attri INTO temp28 WITH KEY name = `MO_APP->MR_STRUC`.
    IF sy-subrc = 0.
      temp27 = temp28.
    ENDIF.
    cl_abap_unit_assert=>assert_not_initial( temp27 ).
    DATA temp29 TYPE z2ui5_if_core_types=>ty_s_attri.
    CLEAR temp29.
    DATA temp30 TYPE z2ui5_if_core_types=>ty_s_attri.
    READ TABLE lt_attri INTO temp30 WITH KEY name = `MO_APP->MR_VALUE`.
    IF sy-subrc = 0.
      temp29 = temp30.
    ENDIF.
    cl_abap_unit_assert=>assert_not_initial( temp29 ).
    DATA temp31 TYPE z2ui5_if_core_types=>ty_s_attri.
    CLEAR temp31.
    DATA temp32 TYPE z2ui5_if_core_types=>ty_s_attri.
    READ TABLE lt_attri INTO temp32 WITH KEY name = `MO_APP->MS_STRUC`.
    IF sy-subrc = 0.
      temp31 = temp32.
    ENDIF.
    cl_abap_unit_assert=>assert_not_initial( temp31 ).

  ENDMETHOD.

  METHOD test_struc.

    DATA lo_app TYPE REF TO ltcl_test_dissolve.
    CREATE OBJECT lo_app TYPE ltcl_test_dissolve.
    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA temp33 LIKE REF TO lt_attri.
    GET REFERENCE OF lt_attri INTO temp33.
DATA lo_model TYPE REF TO z2ui5_cl_core_srv_diss.
CREATE OBJECT lo_model TYPE z2ui5_cl_core_srv_diss EXPORTING attri = temp33 app = lo_app.

    lo_model->main( ).
    lo_model->main( ).
    lo_model->main( ).
    lo_model->main( ).
    lo_model->main( ).

    DATA temp34 TYPE z2ui5_if_core_types=>ty_s_attri.
    CLEAR temp34.
    DATA temp35 TYPE z2ui5_if_core_types=>ty_s_attri.
    READ TABLE lt_attri INTO temp35 WITH KEY name = `MS_STRUC-INPUT`.
    IF sy-subrc = 0.
      temp34 = temp35.
    ENDIF.
    cl_abap_unit_assert=>assert_not_initial( temp34 ).
    DATA temp36 TYPE z2ui5_if_core_types=>ty_s_attri.
    CLEAR temp36.
    DATA temp37 TYPE z2ui5_if_core_types=>ty_s_attri.
    READ TABLE lt_attri INTO temp37 WITH KEY name = `MS_STRUC-S_02-INPUT`.
    IF sy-subrc = 0.
      temp36 = temp37.
    ENDIF.
    cl_abap_unit_assert=>assert_not_initial( temp36 ).
    DATA temp38 TYPE z2ui5_if_core_types=>ty_s_attri.
    CLEAR temp38.
    DATA temp39 TYPE z2ui5_if_core_types=>ty_s_attri.
    READ TABLE lt_attri INTO temp39 WITH KEY name = `MS_STRUC-S_02-S_03-S_04-INPUT`.
    IF sy-subrc = 0.
      temp38 = temp39.
    ENDIF.
    cl_abap_unit_assert=>assert_not_initial( temp38 ).

  ENDMETHOD.

  METHOD test_dref_struc.

    DATA lo_app TYPE REF TO ltcl_test_dissolve.
    CREATE OBJECT lo_app TYPE ltcl_test_dissolve.
    CREATE OBJECT lo_app->mo_app.
    DATA lo_app2 TYPE REF TO ltcl_test_dissolve.
    CREATE OBJECT lo_app2 TYPE ltcl_test_dissolve.
    lo_app2->mo_app = lo_app.

    CREATE DATA lo_app->mr_struc.

    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA temp40 LIKE REF TO lt_attri.
    GET REFERENCE OF lt_attri INTO temp40.
DATA lo_model TYPE REF TO z2ui5_cl_core_srv_diss.
CREATE OBJECT lo_model TYPE z2ui5_cl_core_srv_diss EXPORTING attri = temp40 app = lo_app.

    lo_model->main( ).
    lo_model->main( ).
    lo_model->main( ).

    DATA temp41 TYPE z2ui5_if_core_types=>ty_s_attri.
    CLEAR temp41.
    DATA temp42 TYPE z2ui5_if_core_types=>ty_s_attri.
    READ TABLE lt_attri INTO temp42 WITH KEY name = `MR_STRUC`.
    IF sy-subrc = 0.
      temp41 = temp42.
    ENDIF.
    cl_abap_unit_assert=>assert_not_initial( temp41 ).
    DATA temp43 TYPE z2ui5_if_core_types=>ty_s_attri.
    CLEAR temp43.
    DATA temp44 TYPE z2ui5_if_core_types=>ty_s_attri.
    READ TABLE lt_attri INTO temp44 WITH KEY name = `MR_STRUC->INPUT`.
    IF sy-subrc = 0.
      temp43 = temp44.
    ENDIF.
    cl_abap_unit_assert=>assert_not_initial( temp43 ).
    DATA temp45 TYPE z2ui5_if_core_types=>ty_s_attri.
    CLEAR temp45.
    DATA temp46 TYPE z2ui5_if_core_types=>ty_s_attri.
    READ TABLE lt_attri INTO temp46 WITH KEY name = `MR_STRUC->S_02-INPUT`.
    IF sy-subrc = 0.
      temp45 = temp46.
    ENDIF.
    cl_abap_unit_assert=>assert_not_initial( temp45 ).

  ENDMETHOD.

  METHOD test_oref_dref.

    DATA lo_app TYPE REF TO ltcl_test_dissolve.
    CREATE OBJECT lo_app TYPE ltcl_test_dissolve.
    CREATE OBJECT lo_app->mo_app.
    DATA lo_app2 TYPE REF TO ltcl_test_dissolve.
    CREATE OBJECT lo_app2 TYPE ltcl_test_dissolve.
    lo_app->mo_app = lo_app2.

    CREATE DATA lo_app2->mr_value TYPE string.

    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA temp47 LIKE REF TO lt_attri.
    GET REFERENCE OF lt_attri INTO temp47.
DATA lo_model TYPE REF TO z2ui5_cl_core_srv_diss.
CREATE OBJECT lo_model TYPE z2ui5_cl_core_srv_diss EXPORTING attri = temp47 app = lo_app.

    lo_model->main( ).
    lo_model->main( ).
    lo_model->main( ).

    DATA temp48 TYPE z2ui5_if_core_types=>ty_s_attri.
    CLEAR temp48.
    DATA temp49 TYPE z2ui5_if_core_types=>ty_s_attri.
    READ TABLE lt_attri INTO temp49 WITH KEY name = `MO_APP->MR_VALUE->*`.
    IF sy-subrc = 0.
      temp48 = temp49.
    ENDIF.
    cl_abap_unit_assert=>assert_not_initial( temp48 ).

  ENDMETHOD.

  METHOD test_oref_dref_struc.

    DATA lo_app TYPE REF TO ltcl_test_dissolve.
    CREATE OBJECT lo_app TYPE ltcl_test_dissolve.
    CREATE OBJECT lo_app->mo_app.
    DATA lo_app2 TYPE REF TO ltcl_test_dissolve.
    CREATE OBJECT lo_app2 TYPE ltcl_test_dissolve.
    lo_app->mo_app = lo_app2.

    CREATE DATA lo_app->mo_app->mr_struc.

    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA temp50 LIKE REF TO lt_attri.
    GET REFERENCE OF lt_attri INTO temp50.
DATA lo_model TYPE REF TO z2ui5_cl_core_srv_diss.
CREATE OBJECT lo_model TYPE z2ui5_cl_core_srv_diss EXPORTING attri = temp50 app = lo_app.

    lo_model->main( ).
    lo_model->main( ).
    lo_model->main( ).
    lo_model->main( ).

    DATA temp51 TYPE z2ui5_if_core_types=>ty_s_attri.
    CLEAR temp51.
    DATA temp52 TYPE z2ui5_if_core_types=>ty_s_attri.
    READ TABLE lt_attri INTO temp52 WITH KEY name = `MO_APP->MR_STRUC`.
    IF sy-subrc = 0.
      temp51 = temp52.
    ENDIF.
    cl_abap_unit_assert=>assert_not_initial( temp51 ).
    DATA temp53 TYPE z2ui5_if_core_types=>ty_s_attri.
    CLEAR temp53.
    DATA temp54 TYPE z2ui5_if_core_types=>ty_s_attri.
    READ TABLE lt_attri INTO temp54 WITH KEY name = `MO_APP->MR_STRUC->INPUT`.
    IF sy-subrc = 0.
      temp53 = temp54.
    ENDIF.
    cl_abap_unit_assert=>assert_not_initial( temp53 ).
    DATA temp55 TYPE z2ui5_if_core_types=>ty_s_attri.
    CLEAR temp55.
    DATA temp56 TYPE z2ui5_if_core_types=>ty_s_attri.
    READ TABLE lt_attri INTO temp56 WITH KEY name = `MO_APP->MR_STRUC->S_02-INPUT`.
    IF sy-subrc = 0.
      temp55 = temp56.
    ENDIF.
    cl_abap_unit_assert=>assert_not_initial( temp55 ).

  ENDMETHOD.

  METHOD test_struc_dref.

    DATA lo_app TYPE REF TO ltcl_test_dissolve.
    CREATE OBJECT lo_app TYPE ltcl_test_dissolve.
    CREATE OBJECT lo_app->mo_app.
    CREATE DATA lo_app->mo_app->ms_struc2-r_ref TYPE string.

    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA temp57 LIKE REF TO lt_attri.
    GET REFERENCE OF lt_attri INTO temp57.
DATA lo_model TYPE REF TO z2ui5_cl_core_srv_diss.
CREATE OBJECT lo_model TYPE z2ui5_cl_core_srv_diss EXPORTING attri = temp57 app = lo_app.

    lo_model->main( ).
    lo_model->main( ).
    lo_model->main( ).
    lo_model->main( ).

    DATA temp58 TYPE z2ui5_if_core_types=>ty_s_attri.
    CLEAR temp58.
    DATA temp59 TYPE z2ui5_if_core_types=>ty_s_attri.
    READ TABLE lt_attri INTO temp59 WITH KEY name = `MO_APP->MS_STRUC2-R_REF`.
    IF sy-subrc = 0.
      temp58 = temp59.
    ENDIF.
    cl_abap_unit_assert=>assert_not_initial( temp58 ).
    DATA temp60 TYPE z2ui5_if_core_types=>ty_s_attri.
    CLEAR temp60.
    DATA temp61 TYPE z2ui5_if_core_types=>ty_s_attri.
    READ TABLE lt_attri INTO temp61 WITH KEY name = `MO_APP->MS_STRUC2-R_REF->*`.
    IF sy-subrc = 0.
      temp60 = temp61.
    ENDIF.
    cl_abap_unit_assert=>assert_not_initial( temp60 ).

  ENDMETHOD.
ENDCLASS.
