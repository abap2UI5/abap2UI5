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

    DATA(lo_app) = NEW ltcl_test_dissolve( ).

    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_core_srv_diss( attri = REF #( lt_attri )
                                                 app   = lo_app ).

    lo_model->main( ).

    DATA(ls_attri) = lt_attri[ name = `MV_VALUE` ].
    GET REFERENCE OF lo_app->mv_value INTO DATA(lr_ref).

    IF ls_attri-r_ref <> lr_ref.
      cl_abap_unit_assert=>abort( ).
    ENDIF.

  ENDMETHOD.

  METHOD test_init.

    DATA(lo_app) = NEW ltcl_test_dissolve( ).

    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_core_srv_diss( attri = REF #( lt_attri )
                                                 app   = lo_app ).

    lo_model->main( ).
    lo_model->main( ).
    lo_model->main( ).

    cl_abap_unit_assert=>assert_not_initial( VALUE #( lt_attri[ name = `MR_STRUC` ] OPTIONAL ) ).
    cl_abap_unit_assert=>assert_not_initial( VALUE #( lt_attri[ name = `MR_VALUE` ] OPTIONAL ) ).
    cl_abap_unit_assert=>assert_not_initial( VALUE #( lt_attri[ name = `MS_STRUC` ] OPTIONAL ) ).
    cl_abap_unit_assert=>assert_not_initial( VALUE #( lt_attri[ name = `MV_VALUE` ] OPTIONAL ) ).

  ENDMETHOD.

  METHOD test_dref.

    DATA(lo_app) = NEW ltcl_test_dissolve( ).
    CREATE DATA lo_app->mr_struc.
    CREATE DATA lo_app->mr_value TYPE string.

    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_core_srv_diss( attri = REF #( lt_attri )
                                                 app   = lo_app ).

    lo_model->main( ).
    lo_model->main( ).

    cl_abap_unit_assert=>assert_not_initial( VALUE #( lt_attri[ name = `MR_VALUE->*` ] OPTIONAL ) ).

  ENDMETHOD.

  METHOD test_oref.

    DATA(lo_app) = NEW ltcl_test_dissolve( ).
    lo_app->mo_app = NEW #( ).
    DATA(lo_app2) = NEW ltcl_test_dissolve( ).
    lo_app2->mo_app = lo_app.

    CREATE DATA lo_app->mo_app->mr_struc.
    CREATE DATA lo_app->mo_app->mr_value TYPE string.

    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_core_srv_diss( attri = REF #( lt_attri )
                                                 app   = lo_app2 ).

    lo_model->main( ).
    lo_model->main( ).
    lo_model->main( ).

    cl_abap_unit_assert=>assert_not_initial( VALUE #( lt_attri[ name = `MO_APP->MV_VALUE` ] OPTIONAL ) ).
    cl_abap_unit_assert=>assert_not_initial( VALUE #( lt_attri[ name = `MO_APP->MR_STRUC` ] OPTIONAL ) ).
    cl_abap_unit_assert=>assert_not_initial( VALUE #( lt_attri[ name = `MO_APP->MR_VALUE` ] OPTIONAL ) ).
    cl_abap_unit_assert=>assert_not_initial( VALUE #( lt_attri[ name = `MO_APP->MS_STRUC` ] OPTIONAL ) ).

  ENDMETHOD.

  METHOD test_struc.

    DATA(lo_app) = NEW ltcl_test_dissolve( ).
    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_core_srv_diss( attri = REF #( lt_attri )
                                                 app   = lo_app ).

    lo_model->main( ).
    lo_model->main( ).
    lo_model->main( ).
    lo_model->main( ).
    lo_model->main( ).

    cl_abap_unit_assert=>assert_not_initial( VALUE #( lt_attri[ name = `MS_STRUC-INPUT` ] OPTIONAL ) ).
    cl_abap_unit_assert=>assert_not_initial( VALUE #( lt_attri[ name = `MS_STRUC-S_02-INPUT` ] OPTIONAL ) ).
    cl_abap_unit_assert=>assert_not_initial( VALUE #( lt_attri[ name = `MS_STRUC-S_02-S_03-S_04-INPUT` ] OPTIONAL ) ).

  ENDMETHOD.

  METHOD test_dref_struc.

    DATA(lo_app) = NEW ltcl_test_dissolve( ).
    lo_app->mo_app = NEW #( ).
    DATA(lo_app2) = NEW ltcl_test_dissolve( ).
    lo_app2->mo_app = lo_app.

    CREATE DATA lo_app->mr_struc.

    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_core_srv_diss( attri = REF #( lt_attri )
                                                 app   = lo_app ).

    lo_model->main( ).
    lo_model->main( ).
    lo_model->main( ).

    cl_abap_unit_assert=>assert_not_initial( VALUE #( lt_attri[ name = `MR_STRUC` ] OPTIONAL ) ).
    cl_abap_unit_assert=>assert_not_initial( VALUE #( lt_attri[ name = `MR_STRUC->INPUT` ] OPTIONAL ) ).
    cl_abap_unit_assert=>assert_not_initial( VALUE #( lt_attri[ name = `MR_STRUC->S_02-INPUT` ] OPTIONAL ) ).

  ENDMETHOD.

  METHOD test_oref_dref.

    DATA(lo_app) = NEW ltcl_test_dissolve( ).
    lo_app->mo_app = NEW #( ).
    DATA(lo_app2) = NEW ltcl_test_dissolve( ).
    lo_app->mo_app = lo_app2.

    CREATE DATA lo_app2->mr_value TYPE string.

    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_core_srv_diss( attri = REF #( lt_attri )
                                                 app   = lo_app ).

    lo_model->main( ).
    lo_model->main( ).
    lo_model->main( ).

    cl_abap_unit_assert=>assert_not_initial( VALUE #( lt_attri[ name = `MO_APP->MR_VALUE->*` ] OPTIONAL ) ).

  ENDMETHOD.

  METHOD test_oref_dref_struc.

    DATA(lo_app) = NEW ltcl_test_dissolve( ).
    lo_app->mo_app = NEW #( ).
    DATA(lo_app2) = NEW ltcl_test_dissolve( ).
    lo_app->mo_app = lo_app2.

    CREATE DATA lo_app->mo_app->mr_struc.

    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_core_srv_diss( attri = REF #( lt_attri )
                                                 app   = lo_app ).

    lo_model->main( ).
    lo_model->main( ).
    lo_model->main( ).
    lo_model->main( ).

    cl_abap_unit_assert=>assert_not_initial( VALUE #( lt_attri[ name = `MO_APP->MR_STRUC` ] OPTIONAL ) ).
    cl_abap_unit_assert=>assert_not_initial( VALUE #( lt_attri[ name = `MO_APP->MR_STRUC->INPUT` ] OPTIONAL ) ).
    cl_abap_unit_assert=>assert_not_initial( VALUE #( lt_attri[ name = `MO_APP->MR_STRUC->S_02-INPUT` ] OPTIONAL ) ).

  ENDMETHOD.

  METHOD test_struc_dref.

    DATA(lo_app) = NEW ltcl_test_dissolve( ).
    lo_app->mo_app = NEW #( ).
    CREATE DATA lo_app->mo_app->ms_struc2-r_ref TYPE string.

    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_core_srv_diss( attri = REF #( lt_attri )
                                                 app   = lo_app ).

    lo_model->main( ).
    lo_model->main( ).
    lo_model->main( ).
    lo_model->main( ).

    cl_abap_unit_assert=>assert_not_initial( VALUE #( lt_attri[ name = `MO_APP->MS_STRUC2-R_REF` ] OPTIONAL ) ).
    cl_abap_unit_assert=>assert_not_initial( VALUE #( lt_attri[ name = `MO_APP->MS_STRUC2-R_REF->*` ] OPTIONAL ) ).

  ENDMETHOD.
ENDCLASS.
