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

    ms_struc = VALUE #(
        comp1 = `comp1`
        comp2 = `comp2` ).

    mo_obj   = NEW ltcl_app_inner_335( ir_data = REF #( ms_struc ) ).
    mo_obj_2 = NEW ltcl_app_inner_335( ir_data = REF #( ms_struc ) ).

  ENDMETHOD.

ENDCLASS.


CLASS ltcl_test_sample335 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION MEDIUM.

  PRIVATE SECTION.
    METHODS test_two_drefs_to_same_struc FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_test_sample335 IMPLEMENTATION.

  METHOD test_two_drefs_to_same_struc.

    IF sy-sysid = `ABC`.
      RETURN.
    ENDIF.

    DATA(lo_app) = NEW ltcl_app_root_335( ).

    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_core_srv_model( attri = REF #( lt_attri )
                                                  app   = lo_app ).

    lo_model->dissolve( ).
    lo_model->dissolve( ).
    lo_model->dissolve( ).

    DATA(ls_mr_data_1) = VALUE #( lt_attri[ name = `MO_OBJ->MR_DATA` ] OPTIONAL ).
    cl_abap_unit_assert=>assert_equals( exp = `MS_STRUC`
                                        act = ls_mr_data_1-name_ref ).

    DATA(ls_mr_data_2) = VALUE #( lt_attri[ name = `MO_OBJ_2->MR_DATA` ] OPTIONAL ).
    cl_abap_unit_assert=>assert_equals( exp = `MS_STRUC`
                                        act = ls_mr_data_2-name_ref ).

  ENDMETHOD.

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
    DATA(lo_app) = NEW ltcl_app_complex( ).
    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_core_srv_model( attri = REF #( lt_attri )
                                                  app   = lo_app ).
    DATA(ls_result) = lo_model->attri_create_new( `MV_SIMPLE` ).
    cl_abap_unit_assert=>assert_equals( exp = cl_abap_datadescr=>typekind_string
                                        act = ls_result-type_kind ).
  ENDMETHOD.

  METHOD test_table_type_kind.
    DATA(lo_app) = NEW ltcl_app_complex( ).
    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_core_srv_model( attri = REF #( lt_attri )
                                                  app   = lo_app ).
    DATA(ls_result) = lo_model->attri_create_new( `MT_TAB` ).
    cl_abap_unit_assert=>assert_equals( exp = cl_abap_datadescr=>typekind_table
                                        act = ls_result-type_kind ).
  ENDMETHOD.

  METHOD test_oref_type_kind.
    DATA(lo_app) = NEW ltcl_app_complex( ).
    lo_app->mo_mid = NEW #( ).
    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_core_srv_model( attri = REF #( lt_attri )
                                                  app   = lo_app ).
    DATA(ls_result) = lo_model->attri_create_new( `MO_MID` ).
    cl_abap_unit_assert=>assert_equals( exp = cl_abap_datadescr=>typekind_oref
                                        act = ls_result-type_kind ).
  ENDMETHOD.

  METHOD test_int_kind.
    DATA(lo_app) = NEW ltcl_app_complex( ).
    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_core_srv_model( attri = REF #( lt_attri )
                                                  app   = lo_app ).
    DATA(ls_result) = lo_model->attri_create_new( `MV_INT` ).
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
    DATA(lo_app) = NEW ltcl_app_complex( ).
    lo_app->mv_simple = `hello`.
    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_core_srv_model( attri = REF #( lt_attri )
                                                  app   = lo_app ).
    lo_model->dissolve( ).

    READ TABLE lt_attri REFERENCE INTO DATA(lr_simple) WITH KEY name = `MV_SIMPLE`.
    IF sy-subrc <> 0.
      cl_abap_unit_assert=>abort( ).
    ENDIF.
    lr_simple->bind_type   = z2ui5_if_core_types=>cs_bind_type-one_way.
    lr_simple->name_client = `/MV_SIMPLE`.

    DATA(lv_json) = lo_model->main_json_stringify( ).
    DATA(lo_result) = z2ui5_cl_ajson=>parse( lv_json ).
    cl_abap_unit_assert=>assert_equals( exp = `hello`
                                        act = lo_result->get_string( `/MV_SIMPLE` ) ).
  ENDMETHOD.

  METHOD test_empty_no_bind.
    DATA(lo_app) = NEW ltcl_app_complex( ).
    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_core_srv_model( attri = REF #( lt_attri )
                                                  app   = lo_app ).
    lo_model->dissolve( ).

    " No bind_type set on any attribute - stringify produces empty JSON object
    DATA(lv_json) = lo_model->main_json_stringify( ).
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
    DATA(lo_app) = NEW ltcl_app_complex( ).
    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_core_srv_model( attri = REF #( lt_attri )
                                                  app   = lo_app ).
    lo_model->dissolve( ).

    READ TABLE lt_attri REFERENCE INTO DATA(lr) WITH KEY name = `MV_SIMPLE`.
    IF sy-subrc <> 0.
      cl_abap_unit_assert=>abort( ).
    ENDIF.
    lr->bind_type   = z2ui5_if_core_types=>cs_bind_type-two_way.
    lr->view        = z2ui5_if_client=>cs_view-main.
    lr->name_client = `/MV_SIMPLE`.

    DATA lo_model_json TYPE REF TO z2ui5_if_ajson.
    lo_model_json = z2ui5_cl_ajson=>create_empty( ).
    lo_model_json->set( iv_path = `/MV_SIMPLE`
                        iv_val  = `updated` ).

    lo_model->main_json_to_attri( view  = z2ui5_if_client=>cs_view-main
                                  model = lo_model_json ).

    cl_abap_unit_assert=>assert_equals( exp = `updated`
                                        act = lo_app->mv_simple ).
  ENDMETHOD.

  METHOD test_skips_one_way.
    DATA(lo_app) = NEW ltcl_app_complex( ).
    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_core_srv_model( attri = REF #( lt_attri )
                                                  app   = lo_app ).
    lo_model->dissolve( ).

    READ TABLE lt_attri REFERENCE INTO DATA(lr) WITH KEY name = `MV_SIMPLE`.
    IF sy-subrc <> 0.
      cl_abap_unit_assert=>abort( ).
    ENDIF.
    lr->bind_type   = z2ui5_if_core_types=>cs_bind_type-one_way.
    lr->view        = z2ui5_if_client=>cs_view-main.
    lr->name_client = `/MV_SIMPLE`.

    DATA lo_model_json TYPE REF TO z2ui5_if_ajson.
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
    DATA(lo_app) = NEW ltcl_app_complex( ).
    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_core_srv_model( attri = REF #( lt_attri )
                                                  app   = lo_app ).
    lo_model->dissolve( ).

    READ TABLE lt_attri REFERENCE INTO DATA(lr) WITH KEY name = `MV_SIMPLE`.
    IF sy-subrc <> 0.
      cl_abap_unit_assert=>abort( ).
    ENDIF.
    lr->bind_type   = z2ui5_if_core_types=>cs_bind_type-two_way.
    lr->view        = z2ui5_if_client=>cs_view-popup.
    lr->name_client = `/MV_SIMPLE`.

    DATA lo_model_json TYPE REF TO z2ui5_if_ajson.
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
    DATA(lo_app) = NEW ltcl_app_complex( ).
    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_core_srv_model( attri = REF #( lt_attri )
                                                  app   = lo_app ).
    lo_model->dissolve( ).

    " Simulate an active binding on MV_SIMPLE
    READ TABLE lt_attri REFERENCE INTO DATA(lr) WITH KEY name = `MV_SIMPLE`.
    IF sy-subrc <> 0.
      cl_abap_unit_assert=>abort( ).
    ENDIF.
    lr->bind_type   = z2ui5_if_core_types=>cs_bind_type-two_way.
    lr->name_client = `/XX/MV_SIMPLE`.
    lr->view        = z2ui5_if_client=>cs_view-main.

    " Refresh clears and re-dissolves but must restore binding info
    lo_model->main_attri_refresh( ).

    DATA(ls_after) = VALUE #( lt_attri[ name = `MV_SIMPLE` ] OPTIONAL ).
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

    IF sy-sysid = `ABC`.
      RETURN.
    ENDIF.

    DATA(lo_app) = NEW ltcl_app_root_335( ).
    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_core_srv_model( attri = REF #( lt_attri )
                                                  app   = lo_app ).
    lo_model->dissolve( ).
    lo_model->dissolve( ).
    lo_model->dissolve( ).

    " MO_OBJ->MR_DATA points to MS_STRUC - dissolved children must get name_ref
    DATA(ls_child1) = VALUE #( lt_attri[ name = `MO_OBJ->MR_DATA->COMP1` ] OPTIONAL ).
    cl_abap_unit_assert=>assert_equals( exp = `MS_STRUC-COMP1`
                                        act = ls_child1-name_ref ).

    DATA(ls_child2) = VALUE #( lt_attri[ name = `MO_OBJ->MR_DATA->COMP2` ] OPTIONAL ).
    cl_abap_unit_assert=>assert_equals( exp = `MS_STRUC-COMP2`
                                        act = ls_child2-name_ref ).

  ENDMETHOD.

  METHOD test_second_dref_children.

    IF sy-sysid = `ABC`.
      RETURN.
    ENDIF.

    DATA(lo_app) = NEW ltcl_app_root_335( ).
    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_core_srv_model( attri = REF #( lt_attri )
                                                  app   = lo_app ).
    lo_model->dissolve( ).
    lo_model->dissolve( ).
    lo_model->dissolve( ).

    " MO_OBJ_2->MR_DATA also points to same MS_STRUC - children get name_ref too
    DATA(ls_child1) = VALUE #( lt_attri[ name = `MO_OBJ_2->MR_DATA->COMP1` ] OPTIONAL ).
    cl_abap_unit_assert=>assert_equals( exp = `MS_STRUC-COMP1`
                                        act = ls_child1-name_ref ).

    DATA(ls_child2) = VALUE #( lt_attri[ name = `MO_OBJ_2->MR_DATA->COMP2` ] OPTIONAL ).
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
    DATA(lo_app) = NEW ltcl_app_complex( ).
    lo_app->mt_tab = VALUE #( ( col1 = `A` col2 = `1` )
                               ( col1 = `B` col2 = `2` ) ).
    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_core_srv_model( attri = REF #( lt_attri )
                                                  app   = lo_app ).

    DATA lo_delta TYPE REF TO z2ui5_if_ajson.
    lo_delta = z2ui5_cl_ajson=>create_empty( ).
    lo_delta->set( iv_path = `/__delta/0/COL1`
                   iv_val  = `X` ).

    lo_model->delta_apply_to_table( io_val_front = lo_delta
                                    iv_name      = `MT_TAB` ).

    " Index 0 maps to ABAP table row 1
    cl_abap_unit_assert=>assert_equals( exp = `X`
                                        act = lo_app->mt_tab[ 1 ]-col1 ).
    cl_abap_unit_assert=>assert_equals( exp = `1`
                                        act = lo_app->mt_tab[ 1 ]-col2 ).
    cl_abap_unit_assert=>assert_equals( exp = `B`
                                        act = lo_app->mt_tab[ 2 ]-col1 ).
  ENDMETHOD.

  METHOD test_update_second_row.
    DATA(lo_app) = NEW ltcl_app_complex( ).
    lo_app->mt_tab = VALUE #( ( col1 = `A` col2 = `1` )
                               ( col1 = `B` col2 = `2` ) ).
    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_core_srv_model( attri = REF #( lt_attri )
                                                  app   = lo_app ).

    DATA lo_delta TYPE REF TO z2ui5_if_ajson.
    lo_delta = z2ui5_cl_ajson=>create_empty( ).
    lo_delta->set( iv_path = `/__delta/1/COL2`
                   iv_val  = `Y` ).

    lo_model->delta_apply_to_table( io_val_front = lo_delta
                                    iv_name      = `MT_TAB` ).

    " Index 1 maps to ABAP table row 2
    cl_abap_unit_assert=>assert_equals( exp = `A`
                                        act = lo_app->mt_tab[ 1 ]-col1 ).
    cl_abap_unit_assert=>assert_equals( exp = `Y`
                                        act = lo_app->mt_tab[ 2 ]-col2 ).
    cl_abap_unit_assert=>assert_equals( exp = `B`
                                        act = lo_app->mt_tab[ 2 ]-col1 ).
  ENDMETHOD.

  METHOD test_out_of_range.
    DATA(lo_app) = NEW ltcl_app_complex( ).
    lo_app->mt_tab = VALUE #( ( col1 = `A` col2 = `1` ) ).
    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_core_srv_model( attri = REF #( lt_attri )
                                                  app   = lo_app ).

    DATA lo_delta TYPE REF TO z2ui5_if_ajson.
    lo_delta = z2ui5_cl_ajson=>create_empty( ).
    lo_delta->set( iv_path = `/__delta/5/COL1`
                   iv_val  = `Z` ).

    " Index 5 is out of range for a 1-row table - no crash, table unchanged
    lo_model->delta_apply_to_table( io_val_front = lo_delta
                                    iv_name      = `MT_TAB` ).

    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( lo_app->mt_tab ) ).
    cl_abap_unit_assert=>assert_equals( exp = `A`
                                        act = lo_app->mt_tab[ 1 ]-col1 ).
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
    TYPES ty_t_tab TYPE STANDARD TABLE OF ty_s_row WITH EMPTY KEY.

    DATA mt_tab  TYPE ty_t_tab.
    DATA mo_ref1 TYPE REF TO ltcl_app_inner_335.
    DATA mo_ref2 TYPE REF TO ltcl_app_inner_335.

    METHODS constructor.

ENDCLASS.

CLASS ltcl_app_two_tab_drefs IMPLEMENTATION.

  METHOD z2ui5_if_app~main ##NEEDED.
  ENDMETHOD.

  METHOD constructor.
    mo_ref1 = NEW ltcl_app_inner_335( ir_data = REF #( mt_tab ) ).
    mo_ref2 = NEW ltcl_app_inner_335( ir_data = REF #( mt_tab ) ).
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
    DATA(lo_app) = NEW ltcl_app_two_tab_drefs( ).
    lo_app->mt_tab = VALUE #( ( col1 = `A` col2 = `1` ) ).

    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_core_srv_model( attri = REF #( lt_attri )
                                                  app   = lo_app ).
    lo_model->dissolve( ).
    lo_model->dissolve( ).
    lo_model->dissolve( ).

    DATA(ls_ref1) = VALUE #( lt_attri[ name = `MO_REF1->MR_DATA->*` ] OPTIONAL ).
    cl_abap_unit_assert=>assert_equals( exp = `MT_TAB`
                                        act = ls_ref1-name_ref ).

    DATA(ls_ref2) = VALUE #( lt_attri[ name = `MO_REF2->MR_DATA->*` ] OPTIONAL ).
    cl_abap_unit_assert=>assert_equals( exp = `MT_TAB`
                                        act = ls_ref2-name_ref ).
  ENDMETHOD.

  METHOD test_canonical_search.
    " attri_search via the canonical MT_TAB attribute must resolve correctly
    DATA(lo_app) = NEW ltcl_app_two_tab_drefs( ).
    lo_app->mt_tab = VALUE #( ( col1 = `X` col2 = `Y` ) ).

    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_core_srv_model( attri = REF #( lt_attri )
                                                  app   = lo_app ).
    lo_model->dissolve( ).
    lo_model->dissolve( ).
    lo_model->dissolve( ).

    DATA(lr_tab) = lo_model->attri_get_val_ref( `MT_TAB` ).
    cl_abap_unit_assert=>assert_bound( lr_tab ).

    ASSIGN lr_tab->* TO FIELD-SYMBOL(<tab>).
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
    DATA(lo_app) = NEW ltcl_app_complex( ).
    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_core_srv_model( attri = REF #( lt_attri )
                                                  app   = lo_app ).
    lo_model->dissolve( ).
    lo_model->dissolve( ).

    READ TABLE lt_attri REFERENCE INTO DATA(lr) WITH KEY name = `MS_NESTED-INNER-DEEP1`.
    IF sy-subrc <> 0.
      cl_abap_unit_assert=>abort( ).
    ENDIF.
    lr->bind_type   = z2ui5_if_core_types=>cs_bind_type-two_way.
    lr->view        = z2ui5_if_client=>cs_view-main.
    lr->name_client = `/MS_NESTED-INNER-DEEP1`.

    DATA lo_model_json TYPE REF TO z2ui5_if_ajson.
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
    DATA(lo_app) = NEW ltcl_app_complex( ).
    lo_app->mo_mid = NEW #( ).
    lo_app->mo_mid->mo_inner = NEW #( ).

    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_core_srv_model( attri = REF #( lt_attri )
                                                  app   = lo_app ).
    lo_model->dissolve( ).
    lo_model->dissolve( ).
    lo_model->dissolve( ).

    READ TABLE lt_attri REFERENCE INTO DATA(lr_inner) WITH KEY name = `MO_MID->MO_INNER->MV_INNER`.
    IF sy-subrc <> 0.
      cl_abap_unit_assert=>abort( ).
    ENDIF.
    lr_inner->bind_type   = z2ui5_if_core_types=>cs_bind_type-two_way.
    lr_inner->view        = z2ui5_if_client=>cs_view-main.
    lr_inner->name_client = `/MO_MID-MO_INNER-MV_INNER`.

    DATA lo_model_json TYPE REF TO z2ui5_if_ajson.
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
    DATA(lo_app) = NEW ltcl_app_complex( ).
    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_core_srv_model( attri = REF #( lt_attri )
                                                  app   = lo_app ).
    lo_model->dissolve( ).

    " Set an active binding on MV_SIMPLE before refresh
    READ TABLE lt_attri REFERENCE INTO DATA(lr) WITH KEY name = `MV_SIMPLE`.
    IF sy-subrc <> 0.
      cl_abap_unit_assert=>abort( ).
    ENDIF.
    lr->bind_type   = z2ui5_if_core_types=>cs_bind_type-two_way.
    lr->name_client = `/XX/MV_SIMPLE`.
    lr->view        = z2ui5_if_client=>cs_view-main.

    " Now instantiate the previously-null oref and refresh
    lo_app->mo_mid = NEW #( ).
    lo_model->main_attri_refresh( ).

    " After refresh, MO_MID->MV_MID must now be discovered
    cl_abap_unit_assert=>assert_not_initial(
        VALUE #( lt_attri[ name = `MO_MID->MV_MID` ] OPTIONAL ) ).

    " The pre-existing MV_SIMPLE binding must be preserved
    DATA(ls_simple) = VALUE #( lt_attri[ name = `MV_SIMPLE` ] OPTIONAL ).
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
    DATA(lo_app) = NEW ltcl_app_complex( ).
    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_core_srv_model( attri = REF #( lt_attri )
                                                  app   = lo_app ).
    lo_model->dissolve( ).

    READ TABLE lt_attri REFERENCE INTO DATA(lr) WITH KEY name = `MV_INT`.
    IF sy-subrc <> 0.
      cl_abap_unit_assert=>abort( ).
    ENDIF.
    lr->bind_type   = z2ui5_if_core_types=>cs_bind_type-two_way.
    lr->view        = z2ui5_if_client=>cs_view-main.
    lr->name_client = `/MV_INT`.

    DATA lo_model_json TYPE REF TO z2ui5_if_ajson.
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
    DATA(lo_app) = NEW ltcl_app_complex( ).
    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_core_srv_model( attri = REF #( lt_attri )
                                                  app   = lo_app ).
    lo_model->dissolve( ).

    " First entry: bind MV_SIMPLE as /XX/MV_SIMPLE
    READ TABLE lt_attri REFERENCE INTO DATA(lr1) WITH KEY name = `MV_SIMPLE`.
    IF sy-subrc <> 0.
      cl_abap_unit_assert=>abort( ).
    ENDIF.
    lr1->bind_type   = z2ui5_if_core_types=>cs_bind_type-two_way.
    lr1->view        = z2ui5_if_client=>cs_view-main.
    lr1->name_client = `/XX/MV_SIMPLE`.

    " Second entry: a copy with a different name_client path, also two-way
    DATA ls_extra TYPE z2ui5_if_core_types=>ty_s_attri.
    ls_extra = lr1->*.
    ls_extra-name        = `MV_SIMPLE_ALIAS`.
    ls_extra-name_client = `/XX/ALIAS`.
    INSERT ls_extra INTO TABLE lt_attri.

    DATA lo_model_json TYPE REF TO z2ui5_if_ajson.
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
