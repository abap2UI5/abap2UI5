*
*CLASS ltcl_test_dissolve DEFINITION DEFERRED.
*CLASS z2ui5_cl_core_model_srv DEFINITION LOCAL FRIENDS ltcl_test_dissolve.
*
*CLASS ltcl_test_dissolve DEFINITION FINAL FOR TESTING
*  DURATION SHORT
*  RISK LEVEL HARMLESS.
*
*  PUBLIC SECTION.
*
*    TYPES:
*      BEGIN OF s_01,
*        input TYPE string,
*        BEGIN OF s_02,
*          input TYPE string,
*          BEGIN OF s_03,
*            input TYPE string,
*            BEGIN OF s_04,
*              input TYPE string,
*            END OF s_04,
*          END OF s_03,
*        END OF s_02,
*      END OF s_01.
*
*    DATA ms_struc TYPE s_01 ##NEEDED.
*    DATA mv_value TYPE string ##NEEDED.
*    DATA mr_value TYPE REF TO data.
*    DATA mr_struc TYPE REF TO s_01.
*    DATA mo_app TYPE REF TO ltcl_test_dissolve.
*
*  PRIVATE SECTION.
*    METHODS test_dissolve_init  FOR TESTING RAISING cx_static_check.
*    METHODS test_dissolve_struc FOR TESTING RAISING cx_static_check.
*    METHODS test_dissolve_dref  FOR TESTING RAISING cx_static_check.
*    METHODS test_dissolve_oref  FOR TESTING RAISING cx_static_check.
*    METHODS test_ref FOR TESTING RAISING cx_static_check.
*
*ENDCLASS.
*
*CLASS ltcl_test_dissolve IMPLEMENTATION.
*
*
*  METHOD test_ref.
*
*    DATA(lo_app)  = NEW ltcl_test_dissolve( ).
*
*    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
*    DATA(lo_model) = NEW z2ui5_cl_core_model_srv(
*      attri = REF #( lt_attri )
*      app   = lo_app ).
*
*    lo_model->dissolve( ).
*
*    DATA(ls_attri) = lt_attri[ name = `MV_VALUE` ].
*    GET REFERENCE OF lo_app->mv_value INTO DATA(lr_ref).
*
*    IF ls_attri-r_ref <> lr_ref.
*      cl_abap_unit_assert=>abort( ).
*    ENDIF.
*
*  ENDMETHOD.
*
*  METHOD test_dissolve_init.
*
*    DATA(lo_app)  = NEW ltcl_test_dissolve( ).
*
*    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
*    DATA(lo_model) = NEW z2ui5_cl_core_model_srv(
*      attri = REF #( lt_attri )
*      app   = lo_app ).
*
*    lo_model->dissolve( ).
*    lo_model->dissolve( ).
*    lo_model->dissolve( ).
*    lo_model->dissolve( ).
*
*    cl_abap_unit_assert=>assert_not_initial( VALUE #( lt_attri[ name = `MR_STRUC` ] OPTIONAL ) ).
*    cl_abap_unit_assert=>assert_not_initial( VALUE #( lt_attri[ name = `MR_VALUE` ] OPTIONAL ) ).
*    cl_abap_unit_assert=>assert_not_initial( VALUE #( lt_attri[ name = `MS_STRUC` ] OPTIONAL ) ).
*    cl_abap_unit_assert=>assert_not_initial( VALUE #( lt_attri[ name = `MV_VALUE` ] OPTIONAL ) ).
*
*  ENDMETHOD.
*
*  METHOD test_dissolve_dref.
*
*    DATA(lo_app)    = NEW ltcl_test_dissolve( ).
*    CREATE DATA lo_app->mr_struc.
*    CREATE DATA lo_app->mr_value TYPE string.
*
*    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
*    DATA(lo_model) = NEW z2ui5_cl_core_model_srv(
*      attri = REF #( lt_attri )
*      app   = lo_app ).
*
*    lo_model->dissolve( ).
*    lo_model->dissolve( ).
*    lo_model->dissolve( ).
*    lo_model->dissolve( ).
*    lo_model->dissolve( ).
*
*    cl_abap_unit_assert=>assert_not_initial( VALUE #( lt_attri[ name = `MR_VALUE->*` ] OPTIONAL ) ).
*
*  ENDMETHOD.
*
*  METHOD test_dissolve_oref.
*
*    DATA(lo_app)    = NEW ltcl_test_dissolve( ).
*    lo_app->mo_app = NEW #( ).
*    DATA(lo_app2) = NEW ltcl_test_dissolve( ).
*    lo_app2->mo_app = lo_app.
*
*    CREATE DATA lo_app->mo_app->mr_struc.
*    CREATE DATA lo_app->mo_app->mr_value TYPE string.
*
*    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
*    DATA(lo_model) = NEW z2ui5_cl_core_model_srv(
*      attri = REF #( lt_attri )
*      app   = lo_app2 ).
*
*    lo_model->dissolve( ).
*    lo_model->dissolve( ).
*    lo_model->dissolve( ).
*    lo_model->dissolve( ).
*
*    cl_abap_unit_assert=>assert_not_initial( VALUE #( lt_attri[ name = `MO_APP->MV_VALUE` ] OPTIONAL ) ).
*    cl_abap_unit_assert=>assert_not_initial( VALUE #( lt_attri[ name = `MO_APP->MR_STRUC` ] OPTIONAL ) ).
*    cl_abap_unit_assert=>assert_not_initial( VALUE #( lt_attri[ name = `MO_APP->MR_VALUE` ] OPTIONAL ) ).
*    cl_abap_unit_assert=>assert_not_initial( VALUE #( lt_attri[ name = `MO_APP->MS_STRUC` ] OPTIONAL ) ).
*
*  ENDMETHOD.
*
*  METHOD test_dissolve_struc.
*
*    DATA(lo_app)    = NEW ltcl_test_dissolve( ).
*    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
*    DATA(lo_model) = NEW z2ui5_cl_core_model_srv(
*      attri = REF #( lt_attri )
*      app   = lo_app ).
*
*    lo_model->dissolve( ).
*    lo_model->dissolve( ).
*    lo_model->dissolve( ).
*    lo_model->dissolve( ).
*    lo_model->dissolve( ).
*
*    cl_abap_unit_assert=>assert_not_initial( VALUE #( lt_attri[ name = `MS_STRUC-INPUT` ] OPTIONAL ) ).
*    cl_abap_unit_assert=>assert_not_initial( VALUE #( lt_attri[ name = `MS_STRUC-S_02-INPUT` ] OPTIONAL ) ).
*    cl_abap_unit_assert=>assert_not_initial( VALUE #( lt_attri[ name = `MS_STRUC-S_02-S_03-S_04-INPUT` ] OPTIONAL ) ).
*
*  ENDMETHOD.
*
*ENDCLASS.
*
*
*CLASS ltcl_test_app2 DEFINITION FINAL FOR TESTING
*  DURATION MEDIUM
*  RISK LEVEL HARMLESS.
*
*  PUBLIC SECTION.
*
*    DATA mv_value TYPE string ##NEEDED.
*    DATA mr_value TYPE REF TO data.
*    DATA mr_value2 TYPE REF TO data.
*    DATA mo_app TYPE REF TO ltcl_test_app2.
*
*    DATA xx TYPE string ##NEEDED.
*    METHODS constructor.
*ENDCLASS.
*
*CLASS ltcl_test_app2 IMPLEMENTATION.
*
*  METHOD constructor.
*
*  ENDMETHOD.
*
*ENDCLASS.
*
*CLASS ltcl_test_search_attri DEFINITION FINAL FOR TESTING
*  DURATION SHORT
*  RISK LEVEL HARMLESS.
*
*  PRIVATE SECTION.
*    METHODS first_test FOR TESTING RAISING cx_static_check.
*    METHODS second_test FOR TESTING RAISING cx_static_check.
*    METHODS third_test FOR TESTING RAISING cx_static_check.
*
*ENDCLASS.
*
*CLASS z2ui5_cl_core_model_srv DEFINITION LOCAL FRIENDS ltcl_test_search_attri.
*
*CLASS ltcl_test_search_attri IMPLEMENTATION.
*
*  METHOD first_test.
*
*    DATA(lo_app_client) = NEW ltcl_test_app2( ).
*    DATA lr_value TYPE REF TO data.
*    GET REFERENCE OF lo_app_client->mv_value INTO lr_value.
*
*    DATA(lt_attri) = VALUE z2ui5_if_core_types=>ty_t_attri( ( r_ref = lr_value ) ).
*
*    DATA(lo_model) = NEW z2ui5_cl_core_model_srv(
*      attri = REF #( lt_attri )
*      app   = lo_app_client ).
*
*    DATA(lr_attri) = lo_model->attri_search_a_dissolve( REF #( lo_app_client->mv_value ) ).
*
*    IF lr_attri->r_ref <> lr_value.
*      cl_abap_unit_assert=>abort( ).
*    ENDIF.
*
*  ENDMETHOD.
*
*  METHOD second_test.
*
*    DATA(lo_app_client) = NEW ltcl_test_app2( ).
*    DATA lr_value TYPE REF TO data.
*    GET REFERENCE OF lo_app_client->mv_value INTO lr_value.
*
*    DATA(lt_attri) = VALUE z2ui5_if_core_types=>ty_t_attri( ( r_ref = REF #( lo_app_client->mv_value ) ) ).
*
*    DATA(lo_model) = NEW z2ui5_cl_core_model_srv(
*      attri = REF #( lt_attri )
*      app   = lo_app_client ).
*
*    DATA(lr_attri) = lo_model->attri_search_a_dissolve( REF #( lo_app_client->mv_value ) ).
*
*    IF lr_attri->r_ref <> lr_value.
*      cl_abap_unit_assert=>abort( ).
*    ENDIF.
*
*  ENDMETHOD.
*
*  METHOD third_test.
*
*    DATA(lo_app_client) = NEW ltcl_test_app2( ).
*    DATA lr_value TYPE REF TO data.
*    GET REFERENCE OF lo_app_client->mv_value INTO lr_value.
*
*    lo_app_client->mo_app = NEW #( ).
*
*    DATA(lt_attri) = VALUE z2ui5_if_core_types=>ty_t_attri(
*       ( name = `1` r_ref = REF #( lo_app_client->mr_value ) )
*       ( name = `4` r_ref = REF #( lo_app_client->mr_value2 ) )
*       ( name = `2` r_ref = REF #( lo_app_client->mo_app  ) )
*       ( name = `3` r_ref = REF #( lo_app_client->mv_value ) )
*        ).
*
*    DATA(lr_attri) = REF #( lt_attri[ r_ref = lr_value ] ).
*    IF lr_attri->r_ref <> lr_value.
*      cl_abap_unit_assert=>abort( ).
*    ENDIF.
*
*  ENDMETHOD.
*
*
*ENDCLASS.
