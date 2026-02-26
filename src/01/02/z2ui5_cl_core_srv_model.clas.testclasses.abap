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

    DATA(lo_app) = NEW ltcl_test_dissolve( ).

    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_core_srv_model( attri = REF #( lt_attri )
                                                 app    = lo_app ).

    lo_model->dissolve( ).
    lo_model->dissolve( ).
    lo_model->dissolve( ).

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
    DATA(lo_model) = NEW z2ui5_cl_core_srv_model( attri = REF #( lt_attri )
                                                 app    = lo_app ).

    lo_model->dissolve( ).
    lo_model->dissolve( ).

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
    DATA(lo_model) = NEW z2ui5_cl_core_srv_model( attri = REF #( lt_attri )
                                                 app    = lo_app2 ).

    lo_model->dissolve( ).
    lo_model->dissolve( ).
    lo_model->dissolve( ).

    cl_abap_unit_assert=>assert_not_initial( VALUE #( lt_attri[ name = `MO_APP->MV_VALUE` ] OPTIONAL ) ).
    cl_abap_unit_assert=>assert_not_initial( VALUE #( lt_attri[ name = `MO_APP->MR_STRUC` ] OPTIONAL ) ).
    cl_abap_unit_assert=>assert_not_initial( VALUE #( lt_attri[ name = `MO_APP->MR_VALUE` ] OPTIONAL ) ).
    cl_abap_unit_assert=>assert_not_initial( VALUE #( lt_attri[ name = `MO_APP->MS_STRUC` ] OPTIONAL ) ).

  ENDMETHOD.

  METHOD test_struc.

    DATA(lo_app) = NEW ltcl_test_dissolve( ).
    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_core_srv_model( attri = REF #( lt_attri )
                                                 app    = lo_app ).

    lo_model->dissolve( ).
    lo_model->dissolve( ).
    lo_model->dissolve( ).
    lo_model->dissolve( ).
    lo_model->dissolve( ).

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
    DATA(lo_model) = NEW z2ui5_cl_core_srv_model( attri = REF #( lt_attri )
                                                 app    = lo_app ).

    lo_model->dissolve( ).
    lo_model->dissolve( ).
    lo_model->dissolve( ).

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
    DATA(lo_model) = NEW z2ui5_cl_core_srv_model( attri = REF #( lt_attri )
                                                 app    = lo_app ).

    lo_model->dissolve( ).
    lo_model->dissolve( ).
    lo_model->dissolve( ).

    cl_abap_unit_assert=>assert_not_initial( VALUE #( lt_attri[ name = `MO_APP->MR_VALUE->*` ] OPTIONAL ) ).

  ENDMETHOD.

  METHOD test_oref_dref_struc.

    DATA(lo_app) = NEW ltcl_test_dissolve( ).
    lo_app->mo_app = NEW #( ).
    DATA(lo_app2) = NEW ltcl_test_dissolve( ).
    lo_app->mo_app = lo_app2.

    CREATE DATA lo_app->mo_app->mr_struc.

    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_core_srv_model( attri = REF #( lt_attri )
                                                 app    = lo_app ).

    lo_model->dissolve( ).
    lo_model->dissolve( ).
    lo_model->dissolve( ).
    lo_model->dissolve( ).

    cl_abap_unit_assert=>assert_not_initial( VALUE #( lt_attri[ name = `MO_APP->MR_STRUC` ] OPTIONAL ) ).
    cl_abap_unit_assert=>assert_not_initial( VALUE #( lt_attri[ name = `MO_APP->MR_STRUC->INPUT` ] OPTIONAL ) ).
    cl_abap_unit_assert=>assert_not_initial( VALUE #( lt_attri[ name = `MO_APP->MR_STRUC->S_02-INPUT` ] OPTIONAL ) ).

  ENDMETHOD.

  METHOD test_struc_dref.

    DATA(lo_app) = NEW ltcl_test_dissolve( ).
    lo_app->mo_app = NEW #( ).
    CREATE DATA lo_app->mo_app->ms_struc2-r_ref TYPE string.

    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_core_srv_model( attri = REF #( lt_attri )
                                                 app    = lo_app ).

    lo_model->dissolve( ).
    lo_model->dissolve( ).
    lo_model->dissolve( ).
    lo_model->dissolve( ).

    cl_abap_unit_assert=>assert_not_initial( VALUE #( lt_attri[ name = `MO_APP->MS_STRUC2-R_REF` ] OPTIONAL ) ).
    cl_abap_unit_assert=>assert_not_initial( VALUE #( lt_attri[ name = `MO_APP->MS_STRUC2-R_REF->*` ] OPTIONAL ) ).

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
    mo_app = NEW #( ).
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

    DATA(lo_app_client) = NEW ltcl_test_app3( ).

    DATA lr_value TYPE REF TO data.
    GET REFERENCE OF lo_app_client->mv_value INTO lr_value.

    DATA(lt_attri) = VALUE z2ui5_if_core_types=>ty_t_attri( ).

    DATA(lo_model) = NEW z2ui5_cl_core_srv_model( attri = REF #( lt_attri )
                                                  app   = lo_app_client ).

    DATA(lr_attri) = lo_model->attri_get_val_ref( `MV_VALUE` ).

    IF REF #( lo_app_client->mv_value ) <> lr_attri.
      cl_abap_unit_assert=>abort( ).
    ENDIF.

  ENDMETHOD.

  METHOD second_test.

    DATA(lo_app_client) = NEW ltcl_test_app3( ).
    CREATE DATA lo_app_client->mr_value.

    DATA(lt_attri) = VALUE z2ui5_if_core_types=>ty_t_attri( ).
    DATA(lo_model) = NEW z2ui5_cl_core_srv_model( attri = REF #( lt_attri )
                                                  app   = lo_app_client ).

    DATA(lr_attri) = lo_model->attri_get_val_ref( `MR_VALUE->*` ).

    IF lr_attri <> lo_app_client->mr_value.
      cl_abap_unit_assert=>abort( ).
    ENDIF.

  ENDMETHOD.

  METHOD third_test.

    DATA(lo_app_client) = NEW ltcl_test_app3( ).

    DATA(lt_attri) = VALUE z2ui5_if_core_types=>ty_t_attri( ).
    DATA(lo_model) = NEW z2ui5_cl_core_srv_model( attri = REF #( lt_attri )
                                                  app   = lo_app_client ).

    DATA(lr_attri) = lo_model->attri_get_val_ref( `MO_APP->MV_VALUE` ).

    IF REF #( lo_app_client->mo_app->mv_value ) <> lr_attri.
      cl_abap_unit_assert=>abort( ).
    ENDIF.

  ENDMETHOD.

  METHOD test4.

    DATA(lo_app_client) = NEW ltcl_test_app3( ).
    CREATE DATA lo_app_client->mo_app->mr_value.

    DATA(lt_attri) = VALUE z2ui5_if_core_types=>ty_t_attri( ).
    DATA(lo_model) = NEW z2ui5_cl_core_srv_model( attri = REF #( lt_attri )
                                                  app   = lo_app_client ).

    DATA(lr_attri) = lo_model->attri_get_val_ref( `MO_APP->MR_VALUE->*` ).

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
    TYPES ty_t_tab TYPE STANDARD TABLE OF ty_s_row WITH EMPTY KEY.

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


    IF sy-sysid = `ABC`.
      RETURN.
    ENDIF.

    DATA(lo_app) = NEW ltcl_test_app_root( ).

    DATA(lt_attri) = VALUE z2ui5_if_core_types=>ty_t_attri( ).
    DATA(lo_model) = NEW z2ui5_cl_core_srv_model( attri = REF #( lt_attri )
                                                  app   = lo_app ).

    DATA(ls_attri) = lo_model->main_attri_search( lo_app->mo_obj->mr_tab ).

    IF ls_attri->name <> `MT_TAB`.
      cl_abap_unit_assert=>abort( ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.

CLASS ltcl_test_app_root IMPLEMENTATION.


  METHOD constructor.

    INSERT VALUE #(
        comp1 = `comp1`
        comp2 = `comp2`
      ) INTO TABLE mt_tab.

    mo_obj = NEW ltcl_test_app_root_attri(
      ir_tab = REF #( mt_tab ) ).

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

    IF sy-sysid = `ABC`.
      RETURN.
    ENDIF.

    DATA(lo_app) = NEW ltcl_test_app_root2( ).

    DATA(lt_attri) = VALUE z2ui5_if_core_types=>ty_t_attri( ).
    DATA(lo_model) = NEW z2ui5_cl_core_srv_model( attri = REF #( lt_attri )
                                                  app   = lo_app ).

    DATA(ls_attri) = lo_model->main_attri_search( lo_app->mo_obj->mr_struc ).

    IF ls_attri->name <> `MS_STRUC`.
      cl_abap_unit_assert=>abort( ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.

CLASS ltcl_test_app_root2 IMPLEMENTATION.

  METHOD constructor.

    ms_struc = VALUE #(
        comp1 = `comp1`
        comp2 = `comp2` ).

    mo_obj = NEW ltcl_test_app_root_attri2(
      ir_struc = REF #( ms_struc ) ).

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

    IF sy-sysid = `ABC`.
      RETURN.
    ENDIF.



    "create data
    DATA(lo_app) = NEW ltcl_test_app_root4( ).

    TYPES:
      BEGIN OF ty_s_row,
        comp1 TYPE string,
        comp2 TYPE string,
      END OF ty_s_row.
    TYPES ty_t_tab TYPE STANDARD TABLE OF ty_s_row WITH EMPTY KEY.

    CREATE DATA lo_app->mr_tab TYPE ty_t_tab.
    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
    ASSIGN lo_app->mr_tab->* TO <tab>.
    INSERT VALUE ty_s_row(
      comp1 = `comp1`
      comp2 = `comp2`
      ) INTO TABLE <tab>.



    "test find binding
    DATA(lt_attri) = VALUE z2ui5_if_core_types=>ty_t_attri( ).
    DATA(lo_model) = NEW z2ui5_cl_core_srv_model( attri = REF #( lt_attri )
                                                  app   = lo_app ).

    DATA(ls_attri) = lo_model->main_attri_search( lo_app->mr_tab ).

    IF ls_attri->name <> `MR_TAB->*`.
      cl_abap_unit_assert=>abort( ).
    ENDIF.



    "test frontend backend draft
    lo_model->main_attri_db_save_srtti( ).

    lo_app = NEW ltcl_test_app_root4( ).
    lo_model = NEW z2ui5_cl_core_srv_model( attri = REF #( lt_attri )
                                            app   = lo_app ).
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
    TYPES ty_t_tab TYPE STANDARD TABLE OF ty_s_row WITH EMPTY KEY.

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

    DATA(lo_app) = NEW ltcl_app_complex( ).
    lo_app->mt_tab = VALUE #( ( col1 = `A` col2 = `1` )
                               ( col1 = `B` col2 = `2` ) ).

    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_core_srv_model( attri = REF #( lt_attri )
                                                   app  = lo_app ).

    lo_model->dissolve( ).

    cl_abap_unit_assert=>assert_not_initial( VALUE #( lt_attri[ name = `MT_TAB` ] OPTIONAL ) ).

    DATA(ls_attri) = VALUE #( lt_attri[ name = `MT_TAB` ] OPTIONAL ).
    cl_abap_unit_assert=>assert_equals( exp = cl_abap_datadescr=>typekind_table
                                        act = ls_attri-type_kind ).

  ENDMETHOD.

  METHOD test_nested_struc.

    DATA(lo_app) = NEW ltcl_app_complex( ).
    lo_app->ms_nested = VALUE #( name = `test` value = `123`
                                  inner = VALUE #( deep1 = `d1` deep2 = `d2` ) ).

    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_core_srv_model( attri = REF #( lt_attri )
                                                   app  = lo_app ).

    lo_model->dissolve( ).
    lo_model->dissolve( ).
    lo_model->dissolve( ).

    cl_abap_unit_assert=>assert_not_initial( VALUE #( lt_attri[ name = `MS_NESTED-NAME` ] OPTIONAL ) ).
    cl_abap_unit_assert=>assert_not_initial( VALUE #( lt_attri[ name = `MS_NESTED-VALUE` ] OPTIONAL ) ).
    cl_abap_unit_assert=>assert_not_initial( VALUE #( lt_attri[ name = `MS_NESTED-INNER-DEEP1` ] OPTIONAL ) ).
    cl_abap_unit_assert=>assert_not_initial( VALUE #( lt_attri[ name = `MS_NESTED-INNER-DEEP2` ] OPTIONAL ) ).

  ENDMETHOD.

  METHOD test_oref_chain.

    DATA(lo_app) = NEW ltcl_app_complex( ).
    lo_app->mo_mid = NEW #( ).
    lo_app->mo_mid->mo_inner = NEW #( ).

    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_core_srv_model( attri = REF #( lt_attri )
                                                   app  = lo_app ).

    lo_model->dissolve( ).
    lo_model->dissolve( ).
    lo_model->dissolve( ).

    cl_abap_unit_assert=>assert_not_initial( VALUE #( lt_attri[ name = `MO_MID->MV_MID` ] OPTIONAL ) ).
    cl_abap_unit_assert=>assert_not_initial( VALUE #( lt_attri[ name = `MO_MID->MO_INNER` ] OPTIONAL ) ).
    cl_abap_unit_assert=>assert_not_initial(
      VALUE #( lt_attri[ name = `MO_MID->MO_INNER->MV_INNER` ] OPTIONAL ) ).

  ENDMETHOD.

  METHOD test_table_in_dref.

    DATA(lo_app) = NEW ltcl_app_complex( ).
    CREATE DATA lo_app->mr_tab LIKE lo_app->mt_tab.
    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
    ASSIGN lo_app->mr_tab->* TO <tab>.
    DATA ls_row LIKE LINE OF lo_app->mt_tab.
    ls_row-col1 = `X`.
    ls_row-col2 = `Y`.
    INSERT ls_row INTO TABLE <tab>.

    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_core_srv_model( attri = REF #( lt_attri )
                                                   app  = lo_app ).

    lo_model->dissolve( ).
    lo_model->dissolve( ).

    cl_abap_unit_assert=>assert_not_initial( VALUE #( lt_attri[ name = `MR_TAB` ] OPTIONAL ) ).
    cl_abap_unit_assert=>assert_not_initial( VALUE #( lt_attri[ name = `MR_TAB->*` ] OPTIONAL ) ).

    DATA(ls_tab) = VALUE #( lt_attri[ name = `MR_TAB->*` ] OPTIONAL ).
    cl_abap_unit_assert=>assert_equals( exp = cl_abap_datadescr=>typekind_table
                                        act = ls_tab-type_kind ).

  ENDMETHOD.

  METHOD test_mixed_types.

    DATA(lo_app) = NEW ltcl_app_complex( ).
    lo_app->mt_tab = VALUE #( ( col1 = `A` col2 = `1` ) ).
    lo_app->ms_nested-name = `test`.
    lo_app->mo_mid = NEW #( ).
    CREATE DATA lo_app->mr_tab LIKE lo_app->mt_tab.

    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_core_srv_model( attri = REF #( lt_attri )
                                                   app  = lo_app ).

    lo_model->dissolve( ).
    lo_model->dissolve( ).
    lo_model->dissolve( ).

    cl_abap_unit_assert=>assert_not_initial( VALUE #( lt_attri[ name = `MT_TAB` ] OPTIONAL ) ).
    cl_abap_unit_assert=>assert_not_initial( VALUE #( lt_attri[ name = `MS_NESTED-NAME` ] OPTIONAL ) ).
    cl_abap_unit_assert=>assert_not_initial( VALUE #( lt_attri[ name = `MO_MID->MV_MID` ] OPTIONAL ) ).
    cl_abap_unit_assert=>assert_not_initial( VALUE #( lt_attri[ name = `MR_TAB` ] OPTIONAL ) ).
    cl_abap_unit_assert=>assert_not_initial( VALUE #( lt_attri[ name = `MV_SIMPLE` ] OPTIONAL ) ).
    cl_abap_unit_assert=>assert_not_initial( VALUE #( lt_attri[ name = `MV_INT` ] OPTIONAL ) ).

  ENDMETHOD.

  METHOD test_dissolve_idempotent.

    DATA(lo_app) = NEW ltcl_app_complex( ).
    lo_app->ms_nested-name = `test`.
    lo_app->mo_mid = NEW #( ).

    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_core_srv_model( attri = REF #( lt_attri )
                                                   app  = lo_app ).

    lo_model->dissolve( ).
    lo_model->dissolve( ).
    lo_model->dissolve( ).
    DATA(lv_count_1) = lines( lt_attri ).

    lo_model->dissolve( ).
    DATA(lv_count_2) = lines( lt_attri ).

    cl_abap_unit_assert=>assert_equals( exp = lv_count_1
                                        act = lv_count_2 ).

  ENDMETHOD.

  METHOD test_search_table.

    IF sy-sysid = `ABC`.
      RETURN.
    ENDIF.

    DATA(lo_app) = NEW ltcl_app_complex( ).
    lo_app->mt_tab = VALUE #( ( col1 = `A` col2 = `1` ) ).

    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_core_srv_model( attri = REF #( lt_attri )
                                                   app  = lo_app ).

    DATA(ls_attri) = lo_model->main_attri_search( REF #( lo_app->mt_tab ) ).

    cl_abap_unit_assert=>assert_equals( exp = `MT_TAB`
                                        act = ls_attri->name ).

  ENDMETHOD.

  METHOD test_search_nested_struc.

    IF sy-sysid = `ABC`.
      RETURN.
    ENDIF.

    DATA(lo_app) = NEW ltcl_app_complex( ).
    lo_app->ms_nested-inner-deep1 = `found`.

    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_core_srv_model( attri = REF #( lt_attri )
                                                   app  = lo_app ).

    DATA(ls_attri) = lo_model->main_attri_search( REF #( lo_app->ms_nested-inner-deep1 ) ).

    cl_abap_unit_assert=>assert_equals( exp = `MS_NESTED-INNER-DEEP1`
                                        act = ls_attri->name ).

  ENDMETHOD.

  METHOD test_name_parent_chain.

    DATA(lo_app) = NEW ltcl_app_complex( ).
    lo_app->mo_mid = NEW #( ).
    lo_app->mo_mid->mo_inner = NEW #( ).

    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_core_srv_model( attri = REF #( lt_attri )
                                                   app  = lo_app ).

    lo_model->dissolve( ).
    lo_model->dissolve( ).
    lo_model->dissolve( ).

    DATA(ls_mid) = VALUE #( lt_attri[ name = `MO_MID->MO_INNER` ] OPTIONAL ).
    cl_abap_unit_assert=>assert_equals( exp = `MO_MID`
                                        act = ls_mid-name_parent ).

    DATA(ls_inner) = VALUE #( lt_attri[ name = `MO_MID->MO_INNER->MV_INNER` ] OPTIONAL ).
    cl_abap_unit_assert=>assert_equals( exp = `MO_MID->MO_INNER`
                                        act = ls_inner-name_parent ).

  ENDMETHOD.

ENDCLASS.
