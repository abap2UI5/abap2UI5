CLASS ltcl_test_dissolve DEFINITION DEFERRED.
CLASS z2ui5_cl_ui5_srv_model DEFINITION LOCAL FRIENDS ltcl_test_dissolve.



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
    METHODS test_oref_dref_struc FOR TESTING RAISING cx_static_check.
    METHODS test_oref_dref       FOR TESTING RAISING cx_static_check.
    METHODS test_dref_struc      FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_test_dissolve IMPLEMENTATION.

  METHOD test_init.

    DATA(lo_app) = NEW ltcl_test_dissolve( ).

    DATA lt_attri TYPE z2ui5_if_ui5_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_ui5_srv_model( attri = REF #( lt_attri )
                                                 app   = lo_app ).

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

    DATA lt_attri TYPE z2ui5_if_ui5_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_ui5_srv_model( attri = REF #( lt_attri )
                                                 app   = lo_app ).

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

    DATA lt_attri TYPE z2ui5_if_ui5_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_ui5_srv_model( attri = REF #( lt_attri )
                                                 app   = lo_app2 ).

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
    DATA lt_attri TYPE z2ui5_if_ui5_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_ui5_srv_model( attri = REF #( lt_attri )
                                                 app   = lo_app ).

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

    DATA lt_attri TYPE z2ui5_if_ui5_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_ui5_srv_model( attri = REF #( lt_attri )
                                                 app   = lo_app ).

    lo_model->dissolve( ).
    lo_model->dissolve( ).
    lo_model->dissolve( ).

    cl_abap_unit_assert=>assert_not_initial( VALUE #( lt_attri[ name = `MR_STRUC` ] OPTIONAL ) ).
    cl_abap_unit_assert=>assert_not_initial( VALUE #( lt_attri[ name = `MR_STRUC->INPUT` ] OPTIONAL ) ).
    cl_abap_unit_assert=>assert_not_initial( VALUE #( lt_attri[ name = `MR_STRUC->S_02-INPUT` ] OPTIONAL ) ).

  ENDMETHOD.

  METHOD test_oref_dref.

    DATA(lo_app) = NEW ltcl_test_dissolve( ).
    DATA(lo_app2) = NEW ltcl_test_dissolve( ).
    lo_app->mo_app = lo_app2.

    CREATE DATA lo_app2->mr_value TYPE string.

    DATA lt_attri TYPE z2ui5_if_ui5_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_ui5_srv_model( attri = REF #( lt_attri )
                                                 app   = lo_app ).

    lo_model->dissolve( ).
    lo_model->dissolve( ).
    lo_model->dissolve( ).

    cl_abap_unit_assert=>assert_not_initial( VALUE #( lt_attri[ name = `MO_APP->MR_VALUE->*` ] OPTIONAL ) ).

  ENDMETHOD.

  METHOD test_oref_dref_struc.

    DATA(lo_app) = NEW ltcl_test_dissolve( ).
    DATA(lo_app2) = NEW ltcl_test_dissolve( ).
    lo_app->mo_app = lo_app2.

    CREATE DATA lo_app->mo_app->mr_struc.

    DATA lt_attri TYPE z2ui5_if_ui5_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_ui5_srv_model( attri = REF #( lt_attri )
                                                 app   = lo_app ).

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

    DATA lt_attri TYPE z2ui5_if_ui5_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_ui5_srv_model( attri = REF #( lt_attri )
                                                 app   = lo_app ).

    lo_model->dissolve( ).
    lo_model->dissolve( ).
    lo_model->dissolve( ).
    lo_model->dissolve( ).

    cl_abap_unit_assert=>assert_not_initial( VALUE #( lt_attri[ name = `MO_APP->MS_STRUC2-R_REF` ] OPTIONAL ) ).
    cl_abap_unit_assert=>assert_not_initial( VALUE #( lt_attri[ name = `MO_APP->MS_STRUC2-R_REF->*` ] OPTIONAL ) ).

  ENDMETHOD.
ENDCLASS.


CLASS ltcl_test_app_sub DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION MEDIUM.

  PUBLIC SECTION.

    DATA mv_value TYPE string ##NEEDED.
    DATA mr_value TYPE REF TO string.
ENDCLASS.


CLASS ltcl_test_app_sub IMPLEMENTATION.
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
    METHODS test_val_ref_plain_attri     FOR TESTING RAISING cx_static_check.
    METHODS test_val_ref_dref_deref      FOR TESTING RAISING cx_static_check.
    METHODS test_val_ref_oref_child      FOR TESTING RAISING cx_static_check.
    METHODS test_val_ref_oref_dref_deref FOR TESTING RAISING cx_static_check.

ENDCLASS.

CLASS z2ui5_cl_ui5_srv_model DEFINITION LOCAL FRIENDS ltcl_test_get_attri.


CLASS ltcl_test_get_attri IMPLEMENTATION.

  METHOD test_val_ref_plain_attri.

    DATA(lo_app_client) = NEW ltcl_test_app3( ).

    DATA lr_value TYPE REF TO data.
*    GET REFERENCE OF lo_app_client->mv_value INTO lr_value.
    lr_value = REF #( lo_app_client->mv_value ).

    DATA(lt_attri) = VALUE z2ui5_if_ui5_types=>ty_t_attri( ).

    DATA(lo_model) = NEW z2ui5_cl_ui5_srv_model( attri = REF #( lt_attri )
                                                  app  = lo_app_client ).

    DATA(lr_attri) = lo_model->attri_get_val_ref( `MV_VALUE` ).

    IF REF #( lo_app_client->mv_value ) <> lr_attri.
      cl_abap_unit_assert=>abort( ).
    ENDIF.

  ENDMETHOD.

  METHOD test_val_ref_dref_deref.

    DATA(lo_app_client) = NEW ltcl_test_app3( ).
    CREATE DATA lo_app_client->mr_value.

    DATA(lt_attri) = VALUE z2ui5_if_ui5_types=>ty_t_attri( ).
    DATA(lo_model) = NEW z2ui5_cl_ui5_srv_model( attri = REF #( lt_attri )
                                                  app  = lo_app_client ).

    DATA(lr_attri) = lo_model->attri_get_val_ref( `MR_VALUE->*` ).

    IF lr_attri <> lo_app_client->mr_value.
      cl_abap_unit_assert=>abort( ).
    ENDIF.

  ENDMETHOD.

  METHOD test_val_ref_oref_child.

    DATA(lo_app_client) = NEW ltcl_test_app3( ).

    DATA(lt_attri) = VALUE z2ui5_if_ui5_types=>ty_t_attri( ).
    DATA(lo_model) = NEW z2ui5_cl_ui5_srv_model( attri = REF #( lt_attri )
                                                  app  = lo_app_client ).

    DATA(lr_attri) = lo_model->attri_get_val_ref( `MO_APP->MV_VALUE` ).

    IF REF #( lo_app_client->mo_app->mv_value ) <> lr_attri.
      cl_abap_unit_assert=>abort( ).
    ENDIF.

  ENDMETHOD.

  METHOD test_val_ref_oref_dref_deref.

    DATA(lo_app_client) = NEW ltcl_test_app3( ).
    CREATE DATA lo_app_client->mo_app->mr_value.

    DATA(lt_attri) = VALUE z2ui5_if_ui5_types=>ty_t_attri( ).
    DATA(lo_model) = NEW z2ui5_cl_ui5_srv_model( attri = REF #( lt_attri )
                                                  app  = lo_app_client ).

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
    DATA mo_obj TYPE REF TO ltcl_test_app_root_attri.

    METHODS constructor.
ENDCLASS.


CLASS ltcl_test_app_root_attri IMPLEMENTATION.

  METHOD constructor.

    mr_tab = ir_tab.

  ENDMETHOD.

  METHOD test_obj_tab_ref.

    DATA(lo_app) = NEW ltcl_test_app_root( ).

    DATA(lt_attri) = VALUE z2ui5_if_ui5_types=>ty_t_attri( ).
    DATA(lo_model) = NEW z2ui5_cl_ui5_srv_model( attri = REF #( lt_attri )
                                                  app  = lo_app ).

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

    DATA(lo_app) = NEW ltcl_test_app_root2( ).

    DATA(lt_attri) = VALUE z2ui5_if_ui5_types=>ty_t_attri( ).
    DATA(lo_model) = NEW z2ui5_cl_ui5_srv_model( attri = REF #( lt_attri )
                                                  app  = lo_app ).

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
    DATA(lt_attri) = VALUE z2ui5_if_ui5_types=>ty_t_attri( ).
    DATA(lo_model) = NEW z2ui5_cl_ui5_srv_model( attri = REF #( lt_attri )
                                                  app  = lo_app ).

    DATA(ls_attri) = lo_model->main_attri_search( lo_app->mr_tab ).

    IF ls_attri->name <> `MR_TAB->*`.
      cl_abap_unit_assert=>abort( ).
    ENDIF.



    "test frontend backend draft
    lo_model->main_attri_db_save_srtti( ).

    lo_app = NEW ltcl_test_app_root4( ).
    lo_model = NEW z2ui5_cl_ui5_srv_model( attri = REF #( lt_attri )
                                            app  = lo_app ).
    lo_model->main_attri_db_load( ).

    IF lo_app->mr_tab IS NOT BOUND.
      cl_abap_unit_assert=>abort( ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.


CLASS ltcl_test_app_root5 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PUBLIC SECTION.

    " an anonymous ELEMENTARY data object - CREATE DATA ... TYPE string.
    " Neither a table nor a structure, so the dref save path used to skip
    " it and the value was gone after the first db_save
    DATA mr_value TYPE REF TO data.
    METHODS test_elem_ref_survives FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_test_app_root5 IMPLEMENTATION.

  METHOD test_elem_ref_survives.

    DATA(lo_app) = NEW ltcl_test_app_root5( ).

    CREATE DATA lo_app->mr_value TYPE string.
    FIELD-SYMBOLS <value> TYPE string.
    ASSIGN lo_app->mr_value->* TO <value>.
    <value> = `abc`.

    DATA(lt_attri) = VALUE z2ui5_if_ui5_types=>ty_t_attri( ).
    DATA(lo_model) = NEW z2ui5_cl_ui5_srv_model( attri = REF #( lt_attri )
                                                  app  = lo_app ).

    DATA(ls_attri) = lo_model->main_attri_search( lo_app->mr_value ).
    cl_abap_unit_assert=>assert_equals( exp = `MR_VALUE->*`
                                        act = ls_attri->name ).

    lo_model->main_attri_db_save_srtti( ).

    " the reference is detached from the serialization by the save...
    cl_abap_unit_assert=>assert_not_bound( lo_app->mr_value ).

    " ...and comes back, value and all, on the load into a new instance
    lo_app = NEW ltcl_test_app_root5( ).
    lo_model = NEW z2ui5_cl_ui5_srv_model( attri = REF #( lt_attri )
                                            app  = lo_app ).
    lo_model->main_attri_db_load( ).

    cl_abap_unit_assert=>assert_bound( lo_app->mr_value ).
    ASSIGN lo_app->mr_value->* TO <value>.
    cl_abap_unit_assert=>assert_equals( exp = `abc`
                                        act = <value> ).

  ENDMETHOD.

ENDCLASS.


CLASS ltcl_test_app_root6 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PUBLIC SECTION.

    DATA mv_value TYPE string.

    METHODS test_search_no_descr FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_test_app_root6 IMPLEMENTATION.

  METHOD test_search_no_descr.

    " a row whose o_typedescr the restore could not re-resolve must not take
    " the search down with it - attri_search read ->absolute_name on it
    " unguarded, so one unreachable attribute dumped CX_SY_REF_IS_INITIAL on
    " the first _bind( ) of the render instead of being passed over
    DATA(lo_app) = NEW ltcl_test_app_root6( ).
    lo_app->mv_value = `value`.

    " same type_kind/kind as the searched value, so the row passes the WHERE
    " prefilter and is the first one the loop reads - and no o_typedescr,
    " which is what a swallowed ASSIGN failure in the restore leaves behind
    DATA(lo_descr) = z2ui5_cl_ui5_util_context=>rtti_get_typedescr_by_data_ref( REF #( lo_app->mv_value ) ).
    DATA(lt_attri) = VALUE z2ui5_if_ui5_types=>ty_t_attri(
        ( name            = `MV_GONE`
          check_dissolved = abap_true
          type_kind       = lo_descr->type_kind
          kind            = lo_descr->kind ) ).

    DATA(lo_model) = NEW z2ui5_cl_ui5_srv_model( attri = REF #( lt_attri )
                                                 app   = lo_app ).

    DATA(ls_attri) = lo_model->main_attri_search( REF #( lo_app->mv_value ) ).
    cl_abap_unit_assert=>assert_equals( act = ls_attri->name
                                        exp = `MV_VALUE` ).

  ENDMETHOD.

ENDCLASS.


CLASS ltcl_test_diss_complex DEFINITION DEFERRED.
CLASS z2ui5_cl_ui5_srv_model DEFINITION LOCAL FRIENDS ltcl_test_diss_complex.


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

CLASS z2ui5_cl_ui5_srv_model DEFINITION LOCAL FRIENDS ltcl_test_sample335.


CLASS ltcl_test_sample335 IMPLEMENTATION.

  METHOD test_two_drefs_to_same_struc.

    DATA(lo_app) = NEW ltcl_app_root_335( ).

    DATA lt_attri TYPE z2ui5_if_ui5_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_ui5_srv_model( attri = REF #( lt_attri )
                                                  app  = lo_app ).

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

    DATA lt_attri TYPE z2ui5_if_ui5_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_ui5_srv_model( attri = REF #( lt_attri )
                                                   app = lo_app ).

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

    DATA lt_attri TYPE z2ui5_if_ui5_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_ui5_srv_model( attri = REF #( lt_attri )
                                                   app = lo_app ).

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

    DATA lt_attri TYPE z2ui5_if_ui5_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_ui5_srv_model( attri = REF #( lt_attri )
                                                   app = lo_app ).

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

    DATA lt_attri TYPE z2ui5_if_ui5_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_ui5_srv_model( attri = REF #( lt_attri )
                                                   app = lo_app ).

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

    DATA lt_attri TYPE z2ui5_if_ui5_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_ui5_srv_model( attri = REF #( lt_attri )
                                                   app = lo_app ).

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

    DATA lt_attri TYPE z2ui5_if_ui5_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_ui5_srv_model( attri = REF #( lt_attri )
                                                   app = lo_app ).

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

    DATA(lo_app) = NEW ltcl_app_complex( ).
    lo_app->mt_tab = VALUE #( ( col1 = `A` col2 = `1` ) ).

    DATA lt_attri TYPE z2ui5_if_ui5_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_ui5_srv_model( attri = REF #( lt_attri )
                                                   app = lo_app ).

    DATA(ls_attri) = lo_model->main_attri_search( REF #( lo_app->mt_tab ) ).

    cl_abap_unit_assert=>assert_equals( exp = `MT_TAB`
                                        act = ls_attri->name ).

  ENDMETHOD.

  METHOD test_search_nested_struc.

    DATA(lo_app) = NEW ltcl_app_complex( ).
    lo_app->ms_nested-inner-deep1 = `found`.

    DATA lt_attri TYPE z2ui5_if_ui5_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_ui5_srv_model( attri = REF #( lt_attri )
                                                   app = lo_app ).

    DATA(ls_attri) = lo_model->main_attri_search( REF #( lo_app->ms_nested-inner-deep1 ) ).

    cl_abap_unit_assert=>assert_equals( exp = `MS_NESTED-INNER-DEEP1`
                                        act = ls_attri->name ).

  ENDMETHOD.

  METHOD test_name_parent_chain.

    DATA(lo_app) = NEW ltcl_app_complex( ).
    lo_app->mo_mid = NEW #( ).
    lo_app->mo_mid->mo_inner = NEW #( ).

    DATA lt_attri TYPE z2ui5_if_ui5_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_ui5_srv_model( attri = REF #( lt_attri )
                                                   app = lo_app ).

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

CLASS z2ui5_cl_ui5_srv_model DEFINITION LOCAL FRIENDS ltcl_test_attri_create.

CLASS ltcl_test_attri_create IMPLEMENTATION.

  METHOD test_string_type_kind.
    DATA(lo_app) = NEW ltcl_app_complex( ).
    DATA lt_attri TYPE z2ui5_if_ui5_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_ui5_srv_model( attri = REF #( lt_attri )
                                                  app  = lo_app ).
    DATA(ls_result) = lo_model->attri_create_new( `MV_SIMPLE` ).
    cl_abap_unit_assert=>assert_equals( exp = cl_abap_datadescr=>typekind_string
                                        act = ls_result-type_kind ).
  ENDMETHOD.

  METHOD test_table_type_kind.
    DATA(lo_app) = NEW ltcl_app_complex( ).
    DATA lt_attri TYPE z2ui5_if_ui5_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_ui5_srv_model( attri = REF #( lt_attri )
                                                  app  = lo_app ).
    DATA(ls_result) = lo_model->attri_create_new( `MT_TAB` ).
    cl_abap_unit_assert=>assert_equals( exp = cl_abap_datadescr=>typekind_table
                                        act = ls_result-type_kind ).
  ENDMETHOD.

  METHOD test_oref_type_kind.
    DATA(lo_app) = NEW ltcl_app_complex( ).
    lo_app->mo_mid = NEW #( ).
    DATA lt_attri TYPE z2ui5_if_ui5_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_ui5_srv_model( attri = REF #( lt_attri )
                                                  app  = lo_app ).
    DATA(ls_result) = lo_model->attri_create_new( `MO_MID` ).
    cl_abap_unit_assert=>assert_equals( exp = cl_abap_datadescr=>typekind_oref
                                        act = ls_result-type_kind ).
  ENDMETHOD.

  METHOD test_int_kind.
    DATA(lo_app) = NEW ltcl_app_complex( ).
    DATA lt_attri TYPE z2ui5_if_ui5_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_ui5_srv_model( attri = REF #( lt_attri )
                                                  app  = lo_app ).
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
    METHODS test_omit_initial  FOR TESTING RAISING cx_static_check.
    METHODS test_json_node     FOR TESTING RAISING cx_static_check.
    METHODS test_json_invalid  FOR TESTING RAISING cx_static_check.
ENDCLASS.

CLASS z2ui5_cl_ui5_srv_model DEFINITION LOCAL FRIENDS ltcl_test_json_stringify.

CLASS ltcl_test_json_stringify IMPLEMENTATION.

  METHOD test_simple_string.
    DATA(lo_app) = NEW ltcl_app_complex( ).
    lo_app->mv_simple = `hello`.
    DATA lt_attri TYPE z2ui5_if_ui5_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_ui5_srv_model( attri = REF #( lt_attri )
                                                  app  = lo_app ).
    lo_model->dissolve( ).

    READ TABLE lt_attri REFERENCE INTO DATA(lr_simple) WITH KEY name = `MV_SIMPLE`.
    IF sy-subrc <> 0.
      cl_abap_unit_assert=>abort( ).
    ENDIF.
    lr_simple->bind        = abap_true.
    lr_simple->name_client = `/MV_SIMPLE`.

    DATA(lv_json) = lo_model->main_json_stringify( ).
    DATA(lo_result) = z2ui5_cl_ajson=>parse( lv_json ).
    cl_abap_unit_assert=>assert_equals( exp = `hello`
                                        act = lo_result->get_string( `/MV_SIMPLE` ) ).
  ENDMETHOD.

  METHOD test_empty_no_bind.
    DATA(lo_app) = NEW ltcl_app_complex( ).
    DATA lt_attri TYPE z2ui5_if_ui5_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_ui5_srv_model( attri = REF #( lt_attri )
                                                  app  = lo_app ).
    lo_model->dissolve( ).

    " No binding set on any attribute - stringify produces empty JSON object
    DATA(lv_json) = lo_model->main_json_stringify( ).
    cl_abap_unit_assert=>assert_equals( exp = `{}`
                                        act = lv_json ).
  ENDMETHOD.

  METHOD test_omit_initial.
    " the behavior family behind z2ui5_if_client~_bind( omit_initial ): an
    " INITIAL field stays absent from the model, so the control keeps its own
    " default instead of receiving `` (which an enum-typed property rejects).
    " A filled field of the same bind is untouched. (_bind itself wires a
    " row-preserving variant of this filter - lcl_empty_filter_keep_rows in
    " z2ui5_cl_ui5_client's locals - so table rows are never dropped; the
    " vendored filter here exercises the same custom_filter slot.)
    DATA(lo_app) = NEW ltcl_app_complex( ).
    lo_app->ms_nested-name = `filled`.
    DATA lt_attri TYPE z2ui5_if_ui5_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_ui5_srv_model( attri = REF #( lt_attri )
                                                  app  = lo_app ).
    lo_model->dissolve( ).

    READ TABLE lt_attri REFERENCE INTO DATA(lr_nested) WITH KEY name = `MS_NESTED`.
    IF sy-subrc <> 0.
      cl_abap_unit_assert=>abort( ).
    ENDIF.
    lr_nested->bind          = abap_true.
    lr_nested->name_client   = `/MS_NESTED`.
    lr_nested->custom_filter = z2ui5_cl_ajson_filter_lib=>create_empty_filter( ).

    DATA(lo_result) = z2ui5_cl_ajson=>parse( lo_model->main_json_stringify( ) ).

    cl_abap_unit_assert=>assert_equals( exp = `filled`
                                        act = lo_result->get_string( `/MS_NESTED/NAME` ) ).
    cl_abap_unit_assert=>assert_equals(
        exp = abap_false
        act = lo_result->exists( `/MS_NESTED/VALUE` )
        msg = `an initial field must stay ABSENT, not serialize as an empty string` ).
  ENDMETHOD.

  METHOD test_json_node.
    " what z2ui5_if_client~_bind( json = abap_true ) wires up: the ABAP string
    " already CONTAINS JSON, so it is spliced into the model as a node instead
    " of arriving quoted. Keys that no ABAP field name could carry (`sap.app`)
    " survive verbatim - that is the whole point for a card manifest
    DATA(lo_app) = NEW ltcl_app_complex( ).
    lo_app->mv_simple = `{"_version":"1.0","sap.app":{"type":"card"},"sap.card":{"type":"List"}}`.
    DATA lt_attri TYPE z2ui5_if_ui5_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_ui5_srv_model( attri = REF #( lt_attri )
                                                  app  = lo_app ).
    lo_model->dissolve( ).

    READ TABLE lt_attri REFERENCE INTO DATA(lr_simple) WITH KEY name = `MV_SIMPLE`.
    IF sy-subrc <> 0.
      cl_abap_unit_assert=>abort( ).
    ENDIF.
    lr_simple->bind        = abap_true.
    lr_simple->name_client = `/MV_SIMPLE`.
    lr_simple->check_json  = abap_true.

    DATA(lo_result) = CAST z2ui5_if_ajson( z2ui5_cl_ajson=>parse( lo_model->main_json_stringify( ) ) ).

    cl_abap_unit_assert=>assert_equals(
        exp = z2ui5_if_ajson_types=>node_type-object
        act = lo_result->get_node_type( `/MV_SIMPLE` )
        msg = `the raw JSON must become a node, not a quoted string` ).
    cl_abap_unit_assert=>assert_equals( exp = `card`
                                        act = lo_result->get_string( `/MV_SIMPLE/sap.app/type` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `List`
                                        act = lo_result->get_string( `/MV_SIMPLE/sap.card/type` ) ).
  ENDMETHOD.

  METHOD test_json_invalid.
    " a string the app declared as JSON but that is not must fail loudly here -
    " emitting it raw would produce a broken model the frontend cannot parse
    DATA(lo_app) = NEW ltcl_app_complex( ).
    lo_app->mv_simple = `not json at all`.
    DATA lt_attri TYPE z2ui5_if_ui5_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_ui5_srv_model( attri = REF #( lt_attri )
                                                  app  = lo_app ).
    lo_model->dissolve( ).

    READ TABLE lt_attri REFERENCE INTO DATA(lr_simple) WITH KEY name = `MV_SIMPLE`.
    IF sy-subrc <> 0.
      cl_abap_unit_assert=>abort( ).
    ENDIF.
    lr_simple->bind        = abap_true.
    lr_simple->name_client = `/MV_SIMPLE`.
    lr_simple->check_json  = abap_true.

    TRY.
        lo_model->main_json_stringify( ).
        cl_abap_unit_assert=>fail( `an unparseable json bind must raise` ).
      CATCH z2ui5_cx_ui5_util_error ##NO_HANDLER.
    ENDTRY.
  ENDMETHOD.

ENDCLASS.


CLASS ltcl_test_json_to_attri DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.
  PRIVATE SECTION.
    METHODS test_updates_bound   FOR TESTING RAISING cx_static_check.
    METHODS test_skips_unbound   FOR TESTING RAISING cx_static_check.
    METHODS test_skips_json      FOR TESTING RAISING cx_static_check.
ENDCLASS.

CLASS z2ui5_cl_ui5_srv_model DEFINITION LOCAL FRIENDS ltcl_test_json_to_attri.

CLASS ltcl_test_json_to_attri IMPLEMENTATION.

  METHOD test_updates_bound.
    DATA(lo_app) = NEW ltcl_app_complex( ).
    DATA lt_attri TYPE z2ui5_if_ui5_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_ui5_srv_model( attri = REF #( lt_attri )
                                                  app  = lo_app ).
    lo_model->dissolve( ).

    READ TABLE lt_attri REFERENCE INTO DATA(lr) WITH KEY name = `MV_SIMPLE`.
    IF sy-subrc <> 0.
      cl_abap_unit_assert=>abort( ).
    ENDIF.
    lr->bind        = abap_true.
    lr->name_client = `/MV_SIMPLE`.

    DATA lo_model_json TYPE REF TO z2ui5_if_ajson.
    lo_model_json = z2ui5_cl_ajson=>create_empty( ).
    lo_model_json->set( iv_path = `/MV_SIMPLE`
                        iv_val  = `updated` ).

    lo_model->main_json_to_attri( lo_model_json ).

    cl_abap_unit_assert=>assert_equals( exp = `updated`
                                        act = lo_app->mv_simple ).
  ENDMETHOD.

  METHOD test_skips_json.
    " _bind( json = abap_true ) is outbound only: the client renders the payload
    " but never authors it, and reading a JSON node back would mean writing an
    " object into a string field. The ABAP value must stay untouched
    DATA(lo_app) = NEW ltcl_app_complex( ).
    lo_app->mv_simple = `{"sap.app":{"type":"card"}}`.
    DATA lt_attri TYPE z2ui5_if_ui5_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_ui5_srv_model( attri = REF #( lt_attri )
                                                  app  = lo_app ).
    lo_model->dissolve( ).

    READ TABLE lt_attri REFERENCE INTO DATA(lr_json) WITH KEY name = `MV_SIMPLE`.
    IF sy-subrc <> 0.
      cl_abap_unit_assert=>abort( ).
    ENDIF.
    lr_json->bind        = abap_true.
    lr_json->name_client = `/MV_SIMPLE`.
    lr_json->check_json  = abap_true.

    DATA lo_model_json TYPE REF TO z2ui5_if_ajson.
    lo_model_json = z2ui5_cl_ajson=>create_empty( ).
    lo_model_json->set( iv_path = `/MV_SIMPLE`
                        iv_val  = `overwritten` ).

    lo_model->main_json_to_attri( lo_model_json ).

    cl_abap_unit_assert=>assert_equals(
        exp = `{"sap.app":{"type":"card"}}`
        act = lo_app->mv_simple
        msg = `a json bind must not be read back from the client model` ).
  ENDMETHOD.

  METHOD test_skips_unbound.
    DATA(lo_app) = NEW ltcl_app_complex( ).
    DATA lt_attri TYPE z2ui5_if_ui5_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_ui5_srv_model( attri = REF #( lt_attri )
                                                  app  = lo_app ).
    lo_model->dissolve( ).

    READ TABLE lt_attri REFERENCE INTO DATA(lr) WITH KEY name = `MV_SIMPLE`.
    IF sy-subrc <> 0.
      cl_abap_unit_assert=>abort( ).
    ENDIF.
    lr->bind        = abap_false.
    lr->name_client = `/MV_SIMPLE`.

    DATA lo_model_json TYPE REF TO z2ui5_if_ajson.
    lo_model_json = z2ui5_cl_ajson=>create_empty( ).
    lo_model_json->set( iv_path = `/MV_SIMPLE`
                        iv_val  = `should_not_update` ).

    lo_model->main_json_to_attri( lo_model_json ).

    " unbound attribute - value must not be written back from frontend
    cl_abap_unit_assert=>assert_equals( exp = ``
                                        act = lo_app->mv_simple ).
  ENDMETHOD.

ENDCLASS.


CLASS ltcl_test_attri_refresh DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.
  PRIVATE SECTION.
    METHODS test_bindings_preserved FOR TESTING RAISING cx_static_check.
ENDCLASS.

CLASS z2ui5_cl_ui5_srv_model DEFINITION LOCAL FRIENDS ltcl_test_attri_refresh.

CLASS ltcl_test_attri_refresh IMPLEMENTATION.

  METHOD test_bindings_preserved.
    DATA(lo_app) = NEW ltcl_app_complex( ).
    DATA lt_attri TYPE z2ui5_if_ui5_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_ui5_srv_model( attri = REF #( lt_attri )
                                                  app  = lo_app ).
    lo_model->dissolve( ).

    " Simulate an active binding on MV_SIMPLE
    READ TABLE lt_attri REFERENCE INTO DATA(lr) WITH KEY name = `MV_SIMPLE`.
    IF sy-subrc <> 0.
      cl_abap_unit_assert=>abort( ).
    ENDIF.
    lr->bind        = abap_true.
    lr->name_client = `/MV_SIMPLE`.

    " Refresh clears and re-dissolves but must restore binding info
    lo_model->main_attri_refresh( ).

    DATA(ls_after) = VALUE #( lt_attri[ name = `MV_SIMPLE` ] OPTIONAL ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = ls_after-bind ).
    cl_abap_unit_assert=>assert_equals( exp = `/MV_SIMPLE`
                                        act = ls_after-name_client ).
  ENDMETHOD.

ENDCLASS.


CLASS ltcl_test_entry_refs_children DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION MEDIUM.
  PRIVATE SECTION.
    METHODS test_dref_children_name_ref FOR TESTING RAISING cx_static_check.
    METHODS test_second_dref_children   FOR TESTING RAISING cx_static_check.
ENDCLASS.

CLASS z2ui5_cl_ui5_srv_model DEFINITION LOCAL FRIENDS ltcl_test_entry_refs_children.

CLASS ltcl_test_entry_refs_children IMPLEMENTATION.

  METHOD test_dref_children_name_ref.

    DATA(lo_app) = NEW ltcl_app_root_335( ).
    DATA lt_attri TYPE z2ui5_if_ui5_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_ui5_srv_model( attri = REF #( lt_attri )
                                                  app  = lo_app ).
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

    DATA(lo_app) = NEW ltcl_app_root_335( ).
    DATA lt_attri TYPE z2ui5_if_ui5_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_ui5_srv_model( attri = REF #( lt_attri )
                                                  app  = lo_app ).
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


"------------------------------------------------------------------------
" Helper: app with a tree-like table (rows carry a sub-table and a struct)
"------------------------------------------------------------------------
CLASS ltcl_app_tree DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    TYPES:
      BEGIN OF ty_s_node,
        user      TYPE string,
        validated TYPE abap_bool,
      END OF ty_s_node.
    TYPES ty_t_nodes TYPE STANDARD TABLE OF ty_s_node WITH EMPTY KEY.

    TYPES:
      BEGIN OF ty_s_adr,
        city TYPE string,
        zip  TYPE string,
      END OF ty_s_adr.

    TYPES:
      BEGIN OF ty_s_root,
        user    TYPE string,
        enabled TYPE abap_bool,
        s_adr   TYPE ty_s_adr,
        nodes   TYPE ty_t_nodes,
      END OF ty_s_root.
    TYPES ty_t_tree TYPE STANDARD TABLE OF ty_s_root WITH EMPTY KEY.

    DATA mt_tree TYPE ty_t_tree.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS ltcl_app_tree IMPLEMENTATION.
  METHOD z2ui5_if_app~main ##NEEDED.
  ENDMETHOD.
ENDCLASS.


CLASS ltcl_app_typed DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    TYPES:
      BEGIN OF ty_s_pos,
        qty TYPE i,
      END OF ty_s_pos.
    TYPES ty_t_pos TYPE STANDARD TABLE OF ty_s_pos WITH EMPTY KEY.

    " a table whose cells are NOT all strings - the only shape in which a
    " delta cell can fail to convert at all
    TYPES:
      BEGIN OF ty_s_row,
        name  TYPE string,
        price TYPE p LENGTH 9 DECIMALS 2,
        t_pos TYPE ty_t_pos,
        " the three kinds whose wire form is ISO text, not their ABAP form
        dt    TYPE d,
        tm    TYPE t,
        ts    TYPE timestamp,
      END OF ty_s_row.
    TYPES ty_t_tab TYPE STANDARD TABLE OF ty_s_row WITH EMPTY KEY.
    " the one table shape a row delta cannot be applied to
    TYPES ty_t_sorted TYPE SORTED TABLE OF ty_s_row WITH UNIQUE KEY name.

    DATA mt_tab TYPE ty_t_tab.
    DATA mt_sorted TYPE ty_t_sorted.
ENDCLASS.


CLASS ltcl_app_typed IMPLEMENTATION.
  METHOD z2ui5_if_app~main ##NEEDED.
  ENDMETHOD.
ENDCLASS.


CLASS ltcl_test_delta_apply DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.
  PRIVATE SECTION.
    METHODS test_update_first_row  FOR TESTING RAISING cx_static_check.
    METHODS test_update_second_row FOR TESTING RAISING cx_static_check.
    METHODS test_out_of_range      FOR TESTING RAISING cx_static_check.
    METHODS test_nested_cell       FOR TESTING RAISING cx_static_check.
    METHODS test_nested_mixed      FOR TESTING RAISING cx_static_check.
    METHODS test_struct_component  FOR TESTING RAISING cx_static_check.
    METHODS test_subtable_replace  FOR TESTING RAISING cx_static_check.

    " the trace of a cell the delta could not apply - see
    " z2ui5_if_client=>ty_s_model_skip
    METHODS test_skip_cell_converts FOR TESTING RAISING cx_static_check.
    " a d/t/timestamp cell arrives in the ISO spelling ajson wrote it in
    METHODS test_cell_iso_date_time  FOR TESTING RAISING cx_static_check.
    METHODS test_cell_plain_date     FOR TESTING RAISING cx_static_check.
    METHODS test_skip_cell_refused  FOR TESTING RAISING cx_static_check.
    METHODS test_skip_one_of_two    FOR TESTING RAISING cx_static_check.
    METHODS test_skip_absent_field  FOR TESTING RAISING cx_static_check.
    METHODS test_skip_nested_name   FOR TESTING RAISING cx_static_check.
    METHODS test_skip_nested_parent FOR TESTING RAISING cx_static_check.
    METHODS test_skip_sorted_table  FOR TESTING RAISING cx_static_check.

    METHODS typed_app_create
      RETURNING
        VALUE(result) TYPE REF TO ltcl_app_typed.

    METHODS tree_app_create
      RETURNING
        VALUE(result) TYPE REF TO ltcl_app_tree.
ENDCLASS.

CLASS z2ui5_cl_ui5_srv_model DEFINITION LOCAL FRIENDS ltcl_test_delta_apply.

CLASS ltcl_test_delta_apply IMPLEMENTATION.

  METHOD test_update_first_row.
    DATA(lo_app) = NEW ltcl_app_complex( ).
    lo_app->mt_tab = VALUE #( ( col1 = `A` col2 = `1` )
                               ( col1 = `B` col2 = `2` ) ).
    DATA lt_attri TYPE z2ui5_if_ui5_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_ui5_srv_model( attri = REF #( lt_attri )
                                                  app  = lo_app ).

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
    DATA lt_attri TYPE z2ui5_if_ui5_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_ui5_srv_model( attri = REF #( lt_attri )
                                                  app  = lo_app ).

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
    DATA lt_attri TYPE z2ui5_if_ui5_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_ui5_srv_model( attri = REF #( lt_attri )
                                                  app  = lo_app ).

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

  METHOD tree_app_create.

    result = NEW #( ).
    result->mt_tree = VALUE #( ( user    = `Manager`
                                 enabled = abap_false
                                 s_adr   = VALUE #( city = `Old Town`
                                                    zip  = `00000` )
                                 nodes   = VALUE #( ( user = `E1` validated = abap_false )
                                                    ( user = `E2` validated = abap_false ) ) ) ).

  ENDMETHOD.

  METHOD test_nested_cell.
    DATA(lo_app) = tree_app_create( ).
    DATA lt_attri TYPE z2ui5_if_ui5_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_ui5_srv_model( attri = REF #( lt_attri )
                                                  app  = lo_app ).

    " a cell edit inside the nested table arrives as a nested __delta
    DATA(lo_delta) = CAST z2ui5_if_ajson( z2ui5_cl_ajson=>parse(
        `{"__delta":{"0":{"NODES":{"__delta":{"1":{"VALIDATED":true}}}}}}` ) ).

    lo_model->delta_apply_to_table( io_val_front = lo_delta
                                    iv_name      = `MT_TREE` ).

    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = lo_app->mt_tree[ 1 ]-nodes[ 2 ]-validated ).
    cl_abap_unit_assert=>assert_equals( exp = abap_false
                                        act = lo_app->mt_tree[ 1 ]-nodes[ 1 ]-validated ).
    cl_abap_unit_assert=>assert_equals( exp = `E1`
                                        act = lo_app->mt_tree[ 1 ]-nodes[ 1 ]-user ).
    cl_abap_unit_assert=>assert_equals( exp = `Manager`
                                        act = lo_app->mt_tree[ 1 ]-user ).
  ENDMETHOD.

  METHOD test_nested_mixed.
    DATA(lo_app) = tree_app_create( ).
    DATA lt_attri TYPE z2ui5_if_ui5_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_ui5_srv_model( attri = REF #( lt_attri )
                                                  app  = lo_app ).

    " a root-level cell and a nested cell change in the same delta
    DATA(lo_delta) = CAST z2ui5_if_ajson( z2ui5_cl_ajson=>parse(
        `{"__delta":{"0":{"ENABLED":true,"NODES":{"__delta":{"0":{"USER":"E1-NEW"}}}}}}` ) ).

    lo_model->delta_apply_to_table( io_val_front = lo_delta
                                    iv_name      = `MT_TREE` ).

    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = lo_app->mt_tree[ 1 ]-enabled ).
    cl_abap_unit_assert=>assert_equals( exp = `E1-NEW`
                                        act = lo_app->mt_tree[ 1 ]-nodes[ 1 ]-user ).
    cl_abap_unit_assert=>assert_equals( exp = `E2`
                                        act = lo_app->mt_tree[ 1 ]-nodes[ 2 ]-user ).
  ENDMETHOD.

  METHOD test_struct_component.
    DATA(lo_app) = tree_app_create( ).
    DATA lt_attri TYPE z2ui5_if_ui5_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_ui5_srv_model( attri = REF #( lt_attri )
                                                  app  = lo_app ).

    " a struct member edit ships the whole struct value (no __delta marker)
    DATA(lo_delta) = CAST z2ui5_if_ajson( z2ui5_cl_ajson=>parse(
        `{"__delta":{"0":{"S_ADR":{"CITY":"Berlin","ZIP":"10115"}}}}` ) ).

    lo_model->delta_apply_to_table( io_val_front = lo_delta
                                    iv_name      = `MT_TREE` ).

    cl_abap_unit_assert=>assert_equals( exp = `Berlin`
                                        act = lo_app->mt_tree[ 1 ]-s_adr-city ).
    cl_abap_unit_assert=>assert_equals( exp = `10115`
                                        act = lo_app->mt_tree[ 1 ]-s_adr-zip ).
    cl_abap_unit_assert=>assert_equals( exp = `Manager`
                                        act = lo_app->mt_tree[ 1 ]-user ).
  ENDMETHOD.

  METHOD test_subtable_replace.
    DATA(lo_app) = tree_app_create( ).
    DATA lt_attri TYPE z2ui5_if_ui5_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_ui5_srv_model( attri = REF #( lt_attri )
                                                  app  = lo_app ).

    " a whole sub-table value (array leaf) replaces the nested table
    DATA(lo_delta) = CAST z2ui5_if_ajson( z2ui5_cl_ajson=>parse(
        `{"__delta":{"0":{"NODES":[{"USER":"NEW","VALIDATED":true}]}}}` ) ).

    lo_model->delta_apply_to_table( io_val_front = lo_delta
                                    iv_name      = `MT_TREE` ).

    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( lo_app->mt_tree[ 1 ]-nodes ) ).
    cl_abap_unit_assert=>assert_equals( exp = `NEW`
                                        act = lo_app->mt_tree[ 1 ]-nodes[ 1 ]-user ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = lo_app->mt_tree[ 1 ]-nodes[ 1 ]-validated ).
  ENDMETHOD.

  METHOD typed_app_create.

    result = NEW #( ).
    result->mt_tab = VALUE #( ( name  = `Notebook`
                                price = '1249.00'
                                t_pos = VALUE #( ( qty = 1 ) ) )
                              ( name  = `Monitor`
                                price = '299.00'
                                t_pos = VALUE #( ( qty = 2 ) ) ) ).

  ENDMETHOD.

  METHOD test_skip_cell_converts.

    DATA(lo_app) = typed_app_create( ).
    DATA lt_attri TYPE z2ui5_if_ui5_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_ui5_srv_model( attri = REF #( lt_attri )
                                                  app  = lo_app ).

    " the accepted case - this is what proves the wire is alive and the
    " refusal below is a conversion failure, not a dead binding
    DATA(lo_delta) = CAST z2ui5_if_ajson( z2ui5_cl_ajson=>parse(
        `{"__delta":{"0":{"PRICE":"1250.00"}}}` ) ).

    lo_model->delta_apply_to_table( io_val_front = lo_delta
                                    iv_name      = `MT_TAB` ).

    cl_abap_unit_assert=>assert_equals( exp = CONV decfloat34( '1250.00' )
                                        act = CONV decfloat34( lo_app->mt_tab[ 1 ]-price ) ).
    cl_abap_unit_assert=>assert_initial( lo_model->mt_skipped ).

  ENDMETHOD.

  METHOD test_cell_iso_date_time.

    DATA(lo_app) = typed_app_create( ).
    DATA lt_attri TYPE z2ui5_if_ui5_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_ui5_srv_model( attri = REF #( lt_attri )
                                                  app  = lo_app ).

    " exactly what the model holds after the outbound serialization - a
    " DatePicker with valueFormat yyyy-MM-dd edits the value in this form
    DATA(lo_delta) = CAST z2ui5_if_ajson( z2ui5_cl_ajson=>parse(
        `{"__delta":{"0":{"DT":"2024-01-15","TM":"12:30:45","TS":"2024-01-15T12:30:45Z"}}}` ) ).

    lo_model->delta_apply_to_table( io_val_front = lo_delta
                                    iv_name      = `MT_TAB` ).

    DATA lv_date TYPE d.
    lv_date = '20240115'.
    DATA lv_time TYPE t.
    lv_time = '123045'.
    DATA lv_ts TYPE timestamp.
    lv_ts = '20240115123045'.
    cl_abap_unit_assert=>assert_equals( exp = lv_date
                                        act = lo_app->mt_tab[ 1 ]-dt ).
    cl_abap_unit_assert=>assert_equals( exp = lv_time
                                        act = lo_app->mt_tab[ 1 ]-tm ).
    cl_abap_unit_assert=>assert_equals( exp = lv_ts
                                        act = lo_app->mt_tab[ 1 ]-ts ).
    cl_abap_unit_assert=>assert_initial( lo_model->mt_skipped ).

  ENDMETHOD.

  METHOD test_cell_plain_date.

    DATA(lo_app) = typed_app_create( ).
    DATA lt_attri TYPE z2ui5_if_ui5_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_ui5_srv_model( attri = REF #( lt_attri )
                                                  app  = lo_app ).

    " a value that never went through ajson's formatting keeps the direct
    " assignment, and a cleared cell clears the field
    DATA(lo_delta) = CAST z2ui5_if_ajson( z2ui5_cl_ajson=>parse(
        `{"__delta":{"0":{"DT":"20240115","TM":""}}}` ) ).
    lo_app->mt_tab[ 1 ]-tm = '120000'.

    lo_model->delta_apply_to_table( io_val_front = lo_delta
                                    iv_name      = `MT_TAB` ).

    DATA lv_date TYPE d.
    lv_date = '20240115'.
    cl_abap_unit_assert=>assert_equals( exp = lv_date
                                        act = lo_app->mt_tab[ 1 ]-dt ).
    cl_abap_unit_assert=>assert_initial( lo_app->mt_tab[ 1 ]-tm ).
    cl_abap_unit_assert=>assert_initial( lo_model->mt_skipped ).

  ENDMETHOD.

  METHOD test_skip_sorted_table.

    DATA(lo_app) = typed_app_create( ).
    INSERT VALUE #( name = `Monitor` price = '299.00' ) INTO TABLE lo_app->mt_sorted.
    DATA lt_attri TYPE z2ui5_if_ui5_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_ui5_srv_model( attri = REF #( lt_attri )
                                                  app  = lo_app ).

    " a sorted table cannot take a row delta - the edit used to vanish with
    " nothing recorded; now every cell of it is traced
    DATA(lo_delta) = CAST z2ui5_if_ajson( z2ui5_cl_ajson=>parse(
        `{"__delta":{"0":{"PRICE":"1250.00","NAME":"Screen"}}}` ) ).

    lo_model->delta_apply_to_table( io_val_front = lo_delta
                                    iv_name      = `MT_SORTED` ).

    cl_abap_unit_assert=>assert_equals( exp = CONV decfloat34( '299.00' )
                                        act = CONV decfloat34( lo_app->mt_sorted[ 1 ]-price ) ).
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( lo_model->mt_skipped ) ).
    cl_abap_unit_assert=>assert_equals( exp = `MT_SORTED`
                                        act = lo_model->mt_skipped[ 1 ]-name ).
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lo_model->mt_skipped[ 1 ]-row ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = xsdbool( line_exists( lo_model->mt_skipped[ field = `PRICE` value = `1250.00` ] ) ) ).

  ENDMETHOD.

  METHOD test_skip_cell_refused.

    DATA(lo_app) = typed_app_create( ).
    DATA lt_attri TYPE z2ui5_if_ui5_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_ui5_srv_model( attri = REF #( lt_attri )
                                                  app  = lo_app ).

    " the grouped thousands separator a locale-formatted Input sends
    DATA(lo_delta) = CAST z2ui5_if_ajson( z2ui5_cl_ajson=>parse(
        `{"__delta":{"1":{"PRICE":"1,250.00"}}}` ) ).

    lo_model->delta_apply_to_table( io_val_front = lo_delta
                                    iv_name      = `MT_TAB` ).

    " the cell is still SKIPPED - the old value stands and nothing raised
    cl_abap_unit_assert=>assert_equals( exp = CONV decfloat34( '299.00' )
                                        act = CONV decfloat34( lo_app->mt_tab[ 2 ]-price ) ).

    " ... but it is no longer silent
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( lo_model->mt_skipped ) ).
    cl_abap_unit_assert=>assert_equals( exp = `MT_TAB`
                                        act = lo_model->mt_skipped[ 1 ]-name ).
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lo_model->mt_skipped[ 1 ]-row ).
    cl_abap_unit_assert=>assert_equals( exp = `PRICE`
                                        act = lo_model->mt_skipped[ 1 ]-field ).

    " the entry quotes what the user typed, raw - the half a message needs
    cl_abap_unit_assert=>assert_equals( exp = `1,250.00`
                                        act = lo_model->mt_skipped[ 1 ]-value ).
    " a top-level cell has no parent row
    cl_abap_unit_assert=>assert_equals( exp = 0
                                        act = lo_model->mt_skipped[ 1 ]-row_parent ).

  ENDMETHOD.

  METHOD test_skip_one_of_two.

    DATA(lo_app) = typed_app_create( ).
    DATA lt_attri TYPE z2ui5_if_ui5_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_ui5_srv_model( attri = REF #( lt_attri )
                                                  app  = lo_app ).

    " one bad cell must not take the good ones down with it
    DATA(lo_delta) = CAST z2ui5_if_ajson( z2ui5_cl_ajson=>parse(
        `{"__delta":{"0":{"PRICE":"abc","NAME":"Laptop"},"1":{"PRICE":"350.00"}}}` ) ).

    lo_model->delta_apply_to_table( io_val_front = lo_delta
                                    iv_name      = `MT_TAB` ).

    cl_abap_unit_assert=>assert_equals( exp = `Laptop`
                                        act = lo_app->mt_tab[ 1 ]-name ).
    cl_abap_unit_assert=>assert_equals( exp = CONV decfloat34( '1249.00' )
                                        act = CONV decfloat34( lo_app->mt_tab[ 1 ]-price ) ).
    cl_abap_unit_assert=>assert_equals( exp = CONV decfloat34( '350.00' )
                                        act = CONV decfloat34( lo_app->mt_tab[ 2 ]-price ) ).

    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( lo_model->mt_skipped ) ).
    cl_abap_unit_assert=>assert_equals( exp = `PRICE`
                                        act = lo_model->mt_skipped[ 1 ]-field ).
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lo_model->mt_skipped[ 1 ]-row ).

  ENDMETHOD.

  METHOD test_skip_absent_field.

    DATA(lo_app) = typed_app_create( ).
    DATA lt_attri TYPE z2ui5_if_ui5_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_ui5_srv_model( attri = REF #( lt_attri )
                                                  app  = lo_app ).

    " PRICE is simply not in this delta, and an unknown component is not one
    " either - neither is an error, so neither may show up in the trace
    DATA(lo_delta) = CAST z2ui5_if_ajson( z2ui5_cl_ajson=>parse(
        `{"__delta":{"0":{"NAME":"Ultrabook","NOT_A_COMPONENT":"x"}}}` ) ).

    lo_model->delta_apply_to_table( io_val_front = lo_delta
                                    iv_name      = `MT_TAB` ).

    cl_abap_unit_assert=>assert_equals( exp = `Ultrabook`
                                        act = lo_app->mt_tab[ 1 ]-name ).
    cl_abap_unit_assert=>assert_initial( lo_model->mt_skipped ).

  ENDMETHOD.

  METHOD test_skip_nested_name.

    DATA(lo_app) = typed_app_create( ).
    DATA lt_attri TYPE z2ui5_if_ui5_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_ui5_srv_model( attri = REF #( lt_attri )
                                                  app  = lo_app ).

    DATA(lo_delta) = CAST z2ui5_if_ajson( z2ui5_cl_ajson=>parse(
        `{"__delta":{"0":{"T_POS":{"__delta":{"0":{"QTY":"seven"}}}}}}` ) ).

    lo_model->delta_apply_to_table( io_val_front = lo_delta
                                    iv_name      = `MT_TAB` ).

    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lo_app->mt_tab[ 1 ]-t_pos[ 1 ]-qty ).

    " the trace names the nested table, parent first - not the outer one
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( lo_model->mt_skipped ) ).
    cl_abap_unit_assert=>assert_equals( exp = `MT_TAB-T_POS`
                                        act = lo_model->mt_skipped[ 1 ]-name ).
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lo_model->mt_skipped[ 1 ]-row ).
    cl_abap_unit_assert=>assert_equals( exp = `QTY`
                                        act = lo_model->mt_skipped[ 1 ]-field ).

    " ... and the record that owns the inner table, plus the refused value
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lo_model->mt_skipped[ 1 ]-row_parent ).
    cl_abap_unit_assert=>assert_equals( exp = `seven`
                                        act = lo_model->mt_skipped[ 1 ]-value ).

  ENDMETHOD.

  METHOD test_skip_nested_parent.

    DATA(lo_app) = typed_app_create( ).
    DATA lt_attri TYPE z2ui5_if_ui5_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_ui5_srv_model( attri = REF #( lt_attri )
                                                  app  = lo_app ).

    " a nested refusal under the SECOND outer row: row stays the inner
    " table's index, row_parent names the outer record - the entry now
    " locates MT_TAB[2]-T_POS[1]-QTY instead of "some T_POS somewhere"
    DATA(lo_delta) = CAST z2ui5_if_ajson( z2ui5_cl_ajson=>parse(
        `{"__delta":{"1":{"T_POS":{"__delta":{"0":{"QTY":"many"}}}}}}` ) ).

    lo_model->delta_apply_to_table( io_val_front = lo_delta
                                    iv_name      = `MT_TAB` ).

    " the old inner value stands
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lo_app->mt_tab[ 2 ]-t_pos[ 1 ]-qty ).

    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( lo_model->mt_skipped ) ).
    cl_abap_unit_assert=>assert_equals( exp = `MT_TAB-T_POS`
                                        act = lo_model->mt_skipped[ 1 ]-name ).
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lo_model->mt_skipped[ 1 ]-row ).
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lo_model->mt_skipped[ 1 ]-row_parent ).
    cl_abap_unit_assert=>assert_equals( exp = `QTY`
                                        act = lo_model->mt_skipped[ 1 ]-field ).
    cl_abap_unit_assert=>assert_equals( exp = `many`
                                        act = lo_model->mt_skipped[ 1 ]-value ).

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

CLASS z2ui5_cl_ui5_srv_model DEFINITION LOCAL FRIENDS ltcl_test_two_tab_refs.

CLASS ltcl_test_two_tab_refs IMPLEMENTATION.

  METHOD test_both_get_name_ref.
    " Both MO_REF1->MR_DATA->* and MO_REF2->MR_DATA->* point to MT_TAB.
    " attri_update_entry_refs must set name_ref = MT_TAB for both paths.
    DATA(lo_app) = NEW ltcl_app_two_tab_drefs( ).
    lo_app->mt_tab = VALUE #( ( col1 = `A` col2 = `1` ) ).

    DATA lt_attri TYPE z2ui5_if_ui5_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_ui5_srv_model( attri = REF #( lt_attri )
                                                  app  = lo_app ).
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

    DATA lt_attri TYPE z2ui5_if_ui5_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_ui5_srv_model( attri = REF #( lt_attri )
                                                  app  = lo_app ).
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

CLASS z2ui5_cl_ui5_srv_model DEFINITION LOCAL FRIENDS ltcl_test_deep_nesting.

CLASS ltcl_test_deep_nesting IMPLEMENTATION.

  METHOD test_deep_struct_writeback.
    " MS_NESTED-INNER-DEEP1 is three levels deep inside a nested struct.
    " main_json_to_attri must write through all levels.
    DATA(lo_app) = NEW ltcl_app_complex( ).
    DATA lt_attri TYPE z2ui5_if_ui5_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_ui5_srv_model( attri = REF #( lt_attri )
                                                  app  = lo_app ).
    lo_model->dissolve( ).
    lo_model->dissolve( ).

    READ TABLE lt_attri REFERENCE INTO DATA(lr) WITH KEY name = `MS_NESTED-INNER-DEEP1`.
    IF sy-subrc <> 0.
      cl_abap_unit_assert=>abort( ).
    ENDIF.
    lr->bind        = abap_true.
    lr->name_client = `/MS_NESTED-INNER-DEEP1`.

    DATA lo_model_json TYPE REF TO z2ui5_if_ajson.
    lo_model_json = z2ui5_cl_ajson=>create_empty( ).
    lo_model_json->set( iv_path = `/MS_NESTED-INNER-DEEP1`
                        iv_val  = `deep_value` ).

    lo_model->main_json_to_attri( lo_model_json ).

    cl_abap_unit_assert=>assert_equals( exp = `deep_value`
                                        act = lo_app->ms_nested-inner-deep1 ).
  ENDMETHOD.

  METHOD test_deep_oref_writeback.
    " MO_MID->MO_INNER->MV_INNER is accessed through two oref hops.
    " main_json_to_attri must write the value all the way through.
    DATA(lo_app) = NEW ltcl_app_complex( ).
    lo_app->mo_mid = NEW #( ).
    lo_app->mo_mid->mo_inner = NEW #( ).

    DATA lt_attri TYPE z2ui5_if_ui5_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_ui5_srv_model( attri = REF #( lt_attri )
                                                  app  = lo_app ).
    lo_model->dissolve( ).
    lo_model->dissolve( ).
    lo_model->dissolve( ).

    READ TABLE lt_attri REFERENCE INTO DATA(lr_inner) WITH KEY name = `MO_MID->MO_INNER->MV_INNER`.
    IF sy-subrc <> 0.
      cl_abap_unit_assert=>abort( ).
    ENDIF.
    lr_inner->bind        = abap_true.
    lr_inner->name_client = `/MO_MID-MO_INNER-MV_INNER`.

    DATA lo_model_json TYPE REF TO z2ui5_if_ajson.
    lo_model_json = z2ui5_cl_ajson=>create_empty( ).
    lo_model_json->set( iv_path = `/MO_MID-MO_INNER-MV_INNER`
                        iv_val  = `inner_value` ).

    lo_model->main_json_to_attri( lo_model_json ).

    cl_abap_unit_assert=>assert_equals( exp = `inner_value`
                                        act = lo_app->mo_mid->mo_inner->mv_inner ).
  ENDMETHOD.

ENDCLASS.


CLASS ltcl_test_refresh_ext DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.
  PRIVATE SECTION.
    METHODS test_oref_after_null_refresh FOR TESTING RAISING cx_static_check.
ENDCLASS.

CLASS z2ui5_cl_ui5_srv_model DEFINITION LOCAL FRIENDS ltcl_test_refresh_ext.

CLASS ltcl_test_refresh_ext IMPLEMENTATION.

  METHOD test_oref_after_null_refresh.
    " MO_MID is initially NULL so MO_MID->MV_MID is not discovered in first dissolve.
    " After instantiating MO_MID and calling main_attri_refresh, the child
    " MO_MID->MV_MID must appear while the existing MV_SIMPLE binding is preserved.
    DATA(lo_app) = NEW ltcl_app_complex( ).
    DATA lt_attri TYPE z2ui5_if_ui5_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_ui5_srv_model( attri = REF #( lt_attri )
                                                  app  = lo_app ).
    lo_model->dissolve( ).

    " Set an active binding on MV_SIMPLE before refresh
    READ TABLE lt_attri REFERENCE INTO DATA(lr) WITH KEY name = `MV_SIMPLE`.
    IF sy-subrc <> 0.
      cl_abap_unit_assert=>abort( ).
    ENDIF.
    lr->bind        = abap_true.
    lr->name_client = `/MV_SIMPLE`.

    " Now instantiate the previously-null oref and refresh
    lo_app->mo_mid = NEW #( ).
    lo_model->main_attri_refresh( ).

    " After refresh, MO_MID->MV_MID must now be discovered
    cl_abap_unit_assert=>assert_not_initial(
        VALUE #( lt_attri[ name = `MO_MID->MV_MID` ] OPTIONAL ) ).

    " The pre-existing MV_SIMPLE binding must be preserved
    DATA(ls_simple) = VALUE #( lt_attri[ name = `MV_SIMPLE` ] OPTIONAL ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = ls_simple-bind ).
    cl_abap_unit_assert=>assert_equals( exp = `/MV_SIMPLE`
                                        act = ls_simple-name_client ).
  ENDMETHOD.

ENDCLASS.


CLASS ltcl_test_json_types DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.
  PRIVATE SECTION.
    METHODS test_updates_integer FOR TESTING RAISING cx_static_check.
    METHODS test_multiple_attrs_same_var FOR TESTING RAISING cx_static_check.
ENDCLASS.

CLASS z2ui5_cl_ui5_srv_model DEFINITION LOCAL FRIENDS ltcl_test_json_types.

CLASS ltcl_test_json_types IMPLEMENTATION.

  METHOD test_updates_integer.
    " MV_INT is TYPE i - main_json_to_attri must write numeric JSON back correctly.
    DATA(lo_app) = NEW ltcl_app_complex( ).
    DATA lt_attri TYPE z2ui5_if_ui5_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_ui5_srv_model( attri = REF #( lt_attri )
                                                  app  = lo_app ).
    lo_model->dissolve( ).

    READ TABLE lt_attri REFERENCE INTO DATA(lr) WITH KEY name = `MV_INT`.
    IF sy-subrc <> 0.
      cl_abap_unit_assert=>abort( ).
    ENDIF.
    lr->bind        = abap_true.
    lr->name_client = `/MV_INT`.

    DATA lo_model_json TYPE REF TO z2ui5_if_ajson.
    lo_model_json = z2ui5_cl_ajson=>create_empty( ).
    lo_model_json->set( iv_path = `/MV_INT`
                        iv_val  = 42 ).

    lo_model->main_json_to_attri( lo_model_json ).

    cl_abap_unit_assert=>assert_equals( exp = 42
                                        act = lo_app->mv_int ).
  ENDMETHOD.

  METHOD test_multiple_attrs_same_var.
    " Bind the same variable (MV_SIMPLE) under two different name_client paths;
    " only the canonical path is present in the JSON, so its value is written
    " to the shared variable while the alias entry is skipped.
    DATA(lo_app) = NEW ltcl_app_complex( ).
    DATA lt_attri TYPE z2ui5_if_ui5_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_ui5_srv_model( attri = REF #( lt_attri )
                                                  app  = lo_app ).
    lo_model->dissolve( ).

    " First entry: bind MV_SIMPLE as /MV_SIMPLE
    READ TABLE lt_attri REFERENCE INTO DATA(lr1) WITH KEY name = `MV_SIMPLE`.
    IF sy-subrc <> 0.
      cl_abap_unit_assert=>abort( ).
    ENDIF.
    lr1->bind        = abap_true.
    lr1->name_client = `/MV_SIMPLE`.

    " Second entry: a copy with a different name_client path, also bound
    DATA ls_extra TYPE z2ui5_if_ui5_types=>ty_s_attri.
    ls_extra = lr1->*.
    ls_extra-name        = `MV_SIMPLE_ALIAS`.
    ls_extra-name_client = `/ALIAS`.
    INSERT ls_extra INTO TABLE lt_attri.

    DATA lo_model_json TYPE REF TO z2ui5_if_ajson.
    lo_model_json = z2ui5_cl_ajson=>create_empty( ).
    lo_model_json->set( iv_path = `/MV_SIMPLE`
                        iv_val  = `first` ).

    lo_model->main_json_to_attri( lo_model_json ).

    " Only the canonical path was present in JSON, so MV_SIMPLE gets 'first'
    cl_abap_unit_assert=>assert_equals( exp = `first`
                                        act = lo_app->mv_simple ).
  ENDMETHOD.

ENDCLASS.


CLASS ltcl_test_restore_fail DEFINITION DEFERRED.
CLASS z2ui5_cl_ui5_srv_model DEFINITION LOCAL FRIENDS ltcl_test_restore_fail.


CLASS ltcl_test_restore_fail DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PUBLIC SECTION.
    DATA mr_tab TYPE REF TO data ##NEEDED.

  PRIVATE SECTION.
    " A dref whose stored data cannot be read back: the attribute is left
    " CLEARED by main_attri_db_save_srtti, so a silent skip would run the app
    " on an empty table with nothing raised anywhere - see the comment in
    " main_attri_db_load_resolve.
    METHODS restore_bound_raises   FOR TESTING RAISING cx_static_check.
    METHODS restore_unbound_quiet  FOR TESTING RAISING cx_static_check.

    METHODS attri_with_broken_data
      IMPORTING
        iv_bind       TYPE abap_bool
      RETURNING
        VALUE(result) TYPE z2ui5_if_ui5_types=>ty_t_attri.
ENDCLASS.


CLASS ltcl_test_restore_fail IMPLEMENTATION.

  METHOD attri_with_broken_data.

    " the dref itself carries the stored data (main_attri_db_save_srtti puts
    " a table deref's payload on the PARENT), the dissolved child carries the
    " bind flag - the shape a generically created table has
    INSERT VALUE #( name       = `MR_TAB`
                    type_kind  = z2ui5_cl_ui5_util_context=>cv_typedescr_typekind_dref
                    srtti_data = `this is not the serialized type` ) INTO TABLE result.

    INSERT VALUE #( name        = `MR_TAB->*`
                    name_parent = `MR_TAB`
                    type_kind   = z2ui5_cl_ui5_util_context=>cv_typedescr_typekind_table
                    bind        = iv_bind ) INTO TABLE result.

  ENDMETHOD.

  METHOD restore_bound_raises.

    DATA(lo_app) = NEW ltcl_test_restore_fail( ).
    DATA(lt_attri) = attri_with_broken_data( abap_true ).
    DATA(lo_model) = NEW z2ui5_cl_ui5_srv_model( attri = REF #( lt_attri )
                                                  app  = lo_app ).

    TRY.
        lo_model->main_attri_db_load( ).
        cl_abap_unit_assert=>fail( `A failed restore of BOUND data must not pass silently` ).
      CATCH z2ui5_cx_ui5_util_error INTO DATA(x).
        cl_abap_unit_assert=>assert_true( xsdbool( x->get_text( ) CS `APP_STATE_RESTORE_ERROR` ) ).
    ENDTRY.

  ENDMETHOD.

  METHOD restore_unbound_quiet.

    DATA(lo_app) = NEW ltcl_test_restore_fail( ).
    DATA(lt_attri) = attri_with_broken_data( abap_false ).
    DATA(lo_model) = NEW z2ui5_cl_ui5_srv_model( attri = REF #( lt_attri )
                                                  app  = lo_app ).

    " nothing reads it, so it keeps the lenient treatment
    lo_model->main_attri_db_load( ).

    " ...and the failure really happened: the payload is still sitting on the
    " attribute (only a SUCCESSFUL restore clears it) and the reference the
    " save cleared is still unbound
    READ TABLE lt_attri INTO DATA(ls_attri) WITH KEY name = `MR_TAB`. "#EC CI_SORTSEQ
    cl_abap_unit_assert=>assert_subrc( ).
    cl_abap_unit_assert=>assert_not_initial( ls_attri-srtti_data ).
    cl_abap_unit_assert=>assert_initial( lo_app->mr_tab ).

  ENDMETHOD.

ENDCLASS.


" ---------------------------------------------------------------------------
" The shape catalogue: one attribute per FORM an app attribute can take, and
" the same invariants run over every row of mt_attri after every lifecycle
" step. A new form is one more attribute here - every test below picks it
" up. The forms and the numbering follow the test plan (S01-S24).
" ---------------------------------------------------------------------------

" a class that does NOT implement if_serializable_object: the view builder,
" the client, any helper an app keeps in an attribute. It must come back
" initial from the draft - and it must not fail the draft (S15)
CLASS ltcl_shp_dead DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PUBLIC SECTION.
    DATA mv_text TYPE string.
ENDCLASS.

CLASS ltcl_shp_dead IMPLEMENTATION.
ENDCLASS.


" a serializable helper instance with data of its own, a dref that points at
" the OUTER app's anonymous table (sample 339: mo_layout->mr_data) and a
" chain to another instance of itself (S12, S14, S18)
CLASS ltcl_shp_inner DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PUBLIC SECTION.
    INTERFACES if_serializable_object.

    TYPES:
      BEGIN OF ty_s_row,
        col1 TYPE string,
        col2 TYPE i,
      END OF ty_s_row.
    TYPES ty_t_row TYPE STANDARD TABLE OF ty_s_row WITH EMPTY KEY.

    DATA mv_inner  TYPE string.
    DATA mt_own    TYPE ty_t_row.
    DATA mr_shared TYPE REF TO data.
    DATA mo_deeper TYPE REF TO ltcl_shp_inner.
ENDCLASS.

CLASS ltcl_shp_inner IMPLEMENTATION.
ENDCLASS.


CLASS ltcl_app_shapes DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    TYPES:
      BEGIN OF ty_s_row,
        col1 TYPE string,
        col2 TYPE i,
      END OF ty_s_row.
    TYPES ty_t_row    TYPE STANDARD TABLE OF ty_s_row WITH EMPTY KEY.
    TYPES ty_t_sorted TYPE SORTED TABLE OF ty_s_row WITH UNIQUE KEY col1.
    " the shape of the runtime-built line: a known row plus SELKZ
    TYPES:
      BEGIN OF ty_s_row_sel,
        col1  TYPE string,
        col2  TYPE i,
        selkz TYPE abap_bool,
      END OF ty_s_row_sel.

    TYPES:
      BEGIN OF ty_s_deep,
        v1 TYPE string,
        BEGIN OF l1,
          v2 TYPE string,
          BEGIN OF l2,
            v3 TYPE string,
            BEGIN OF l3,
              v4 TYPE abap_bool,
            END OF l3,
          END OF l2,
        END OF l1,
      END OF ty_s_deep.

    TYPES:
      BEGIN OF ty_s_nested,
        id      TYPE string,
        t_items TYPE ty_t_row,
      END OF ty_s_nested.
    TYPES ty_t_nested TYPE STANDARD TABLE OF ty_s_nested WITH EMPTY KEY.

    TYPES:
      BEGIN OF ty_s_with_oref,
        text  TYPE string,
        o_obj TYPE REF TO ltcl_shp_inner,
      END OF ty_s_with_oref.

    TYPES:
      BEGIN OF ty_s_with_dref,
        text  TYPE string,
        r_tab TYPE REF TO data,
      END OF ty_s_with_dref.

    TYPES:
      BEGIN OF ty_s_row_ref,
        id     TYPE string,
        r_elem TYPE REF TO string,
        o_obj  TYPE REF TO ltcl_shp_inner,
      END OF ty_s_row_ref.
    TYPES ty_t_row_ref TYPE STANDARD TABLE OF ty_s_row_ref WITH EMPTY KEY.

    " S01 elementary
    DATA mv_string TYPE string.
    DATA mv_int    TYPE i.
    DATA mv_packed TYPE p LENGTH 8 DECIMALS 2.
    DATA mv_date   TYPE d.
    DATA mv_time   TYPE t.
    DATA mv_bool   TYPE abap_bool.
    DATA mv_xstr   TYPE xstring.
    " S02 flat structure, S03 four levels deep
    DATA ms_flat   TYPE ty_s_row.
    DATA ms_deep   TYPE ty_s_deep.
    " S04 standard, S05 sorted, S06 elementary line, S07 nested table
    DATA mt_std     TYPE ty_t_row.
    DATA mt_sorted  TYPE ty_t_sorted.
    DATA mt_strings TYPE string_table.
    DATA mt_nested  TYPE ty_t_nested.
    " S08 statically typed drefs
    DATA mr_typed_tab   TYPE REF TO ty_t_row.
    DATA mr_typed_struc TYPE REF TO ty_s_row.
    DATA mr_typed_elem  TYPE REF TO string.
    " S09 generic drefs created TYPE HANDLE (anonymous line type)
    DATA mr_handle_tab   TYPE REF TO data.
    DATA mr_handle_struc TYPE REF TO data.
    " S10 generic dref, elementary target
    DATA mr_elem TYPE REF TO data.
    " S11 drefs INTO other attributes
    DATA mr_alias_struc TYPE REF TO data.
    DATA mr_alias_tab   TYPE REF TO data.
    " S12 three drefs on ONE anonymous table - the third sits in mo_inner
    DATA mr_shared_a TYPE REF TO data.
    DATA mr_shared_b TYPE REF TO data.
    " S13 a dref whose target is a dref
    DATA mr_ref_ref TYPE REF TO data.
    " S14 serializable instance (with a chain inside), S15 a dead one
    DATA mo_inner TYPE REF TO ltcl_shp_inner.
    DATA mo_dead  TYPE REF TO ltcl_shp_dead.
    " S19 object as component, S20 dref as component - and both as cells
    DATA ms_with_oref TYPE ty_s_with_oref.
    DATA ms_with_dref TYPE ty_s_with_dref.
    DATA mt_rows_ref  TYPE ty_t_row_ref.
    " S25 a table whose rows hold RTTI descriptors - abap_component_tab, the
    " attribute every runtime-typed sample keeps (184, 190, 194, 199, 212)
    DATA mt_comp TYPE abap_component_tab.
    " S26 an anonymous STRUCTURE whose components are tables (194 ms_fixval)
    DATA mr_handle_nested TYPE REF TO data.
    " S27 a second helper over the same data as the first, and pointing at
    " a TYPED table attribute of the app (334: two objects, one target;
    " 347: the bound table aliased from inside a helper)
    DATA mo_inner_2 TYPE REF TO ltcl_shp_inner.

    METHODS fill.
    METHODS get_protected
      RETURNING
        VALUE(result) TYPE string.

  PROTECTED SECTION.
    " S23 - serialized with the rest, never dissolved, never bindable
    DATA mv_protected TYPE string.
    DATA mo_hidden    TYPE REF TO ltcl_shp_dead.
ENDCLASS.


CLASS ltcl_app_shapes IMPLEMENTATION.

  METHOD z2ui5_if_app~main ##NEEDED.
  ENDMETHOD.

  METHOD get_protected.
    result = mv_protected.
  ENDMETHOD.

  METHOD fill.

    FIELD-SYMBOLS <tab>   TYPE STANDARD TABLE.
    FIELD-SYMBOLS <row>   TYPE any.
    FIELD-SYMBOLS <elem>  TYPE any.
    DATA ls_sel TYPE ty_s_row_sel.

    mv_string = `text`.
    mv_int    = 42.
    mv_packed = '1234.56'.
    mv_date   = '20240115'.
    mv_time   = '123045'.
    mv_bool   = abap_true.
    mv_xstr   = 'DEADBEEF'.

    ms_flat = VALUE #( col1 = `flat` col2 = 1 ).
    ms_deep-v1          = `v1`.
    ms_deep-l1-v2       = `v2`.
    ms_deep-l1-l2-v3    = `v3`.
    ms_deep-l1-l2-l3-v4 = abap_true.

    mt_std     = VALUE #( ( col1 = `a` col2 = 1 ) ( col1 = `b` col2 = 2 ) ).
    mt_sorted  = VALUE #( ( col1 = `x` col2 = 9 ) ( col1 = `y` col2 = 8 ) ).
    mt_strings = VALUE #( ( `one` ) ( `two` ) ).
    mt_nested  = VALUE #( ( id = `n1` t_items = VALUE #( ( col1 = `n1a` col2 = 1 ) ) )
                          ( id = `n2` t_items = VALUE #( ( col1 = `n2a` col2 = 2 ) ( col1 = `n2b` col2 = 3 ) ) ) ).

    CREATE DATA mr_typed_tab.
    mr_typed_tab->* = VALUE #( ( col1 = `typed` col2 = 7 ) ).
    CREATE DATA mr_typed_struc.
    mr_typed_struc->* = VALUE #( col1 = `typed-struc` col2 = 8 ).
    CREATE DATA mr_typed_elem.
    mr_typed_elem->* = `typed-elem`.

    " the anonymous line type of a runtime-built table: the components of a
    " known structure plus a field that exists in NO dictionary (SELKZ in
    " the samples)
    DATA(lo_line) = CAST cl_abap_structdescr( cl_abap_typedescr=>describe_by_data( ms_flat ) ).
    DATA(lt_comp) = lo_line->get_components( ).
    " c LENGTH 1, not abap_bool: a type-pool type carries a full absolute
    " name (\TYPE-POOL=ABAP\TYPE=ABAP_BOOL) that S-RTTI resolves by name -
    " fine on a system, unknown to the NodeJS runtime, which only answers
    " for the built-in types by their anonymous names
    DATA lv_flag TYPE c LENGTH 1.
    APPEND VALUE #( name = `SELKZ`
                    type = CAST #( cl_abap_datadescr=>describe_by_data( lv_flag ) ) ) TO lt_comp.
    DATA(lo_struc) = cl_abap_structdescr=>create( lt_comp ).
    DATA(lo_tab)   = cl_abap_tabledescr=>create( p_line_type  = lo_struc
                                                 p_table_kind = cl_abap_tabledescr=>tablekind_std ).

    CREATE DATA mr_handle_tab TYPE HANDLE lo_tab.
    ASSIGN mr_handle_tab->* TO <tab>.
    ls_sel = VALUE #( col1 = `handle-row-1` selkz = abap_true ).
    APPEND INITIAL LINE TO <tab> ASSIGNING <row>.
    MOVE-CORRESPONDING ls_sel TO <row>.
    ls_sel = VALUE #( col1 = `handle-row-2` ).
    APPEND INITIAL LINE TO <tab> ASSIGNING <row>.
    MOVE-CORRESPONDING ls_sel TO <row>.

    CREATE DATA mr_handle_struc TYPE HANDLE lo_struc.
    ASSIGN mr_handle_struc->* TO <row>.
    ls_sel = VALUE #( col1 = `handle-struc` ).
    MOVE-CORRESPONDING ls_sel TO <row>.

    CREATE DATA mr_elem TYPE string.
    ASSIGN mr_elem->* TO <elem>.
    <elem> = `elem`.

    mr_alias_struc = REF #( ms_flat ).
    mr_alias_tab   = REF #( mt_std ).

    " one data object, three references - two here, one in the helper
    CREATE DATA mr_shared_a TYPE HANDLE lo_tab.
    ASSIGN mr_shared_a->* TO <tab>.
    ls_sel = VALUE #( col1 = `shared` ).
    APPEND INITIAL LINE TO <tab> ASSIGNING <row>.
    MOVE-CORRESPONDING ls_sel TO <row>.
    mr_shared_b = mr_shared_a.

    mo_inner = NEW #( ).
    mo_inner->mv_inner  = `inner`.
    mo_inner->mt_own    = VALUE #( ( col1 = `own` col2 = 5 ) ).
    mo_inner->mr_shared = mr_shared_a.
    mo_inner->mo_deeper = NEW #( ).
    mo_inner->mo_deeper->mv_inner = `deeper`.

    mo_inner_2 = NEW #( ).
    mo_inner_2->mv_inner  = `inner-2`.
    mo_inner_2->mr_shared = REF #( mt_std ).

    mo_dead = NEW #( ).
    mo_dead->mv_text = `dead`.

    mt_comp = lt_comp.

    " a structure that exists at runtime only, with a table inside
    DATA lt_nested_comp TYPE abap_component_tab.
    APPEND VALUE #( name = `ID`
                    type = CAST #( cl_abap_datadescr=>describe_by_data( mv_string ) ) ) TO lt_nested_comp.
    APPEND VALUE #( name = `T_ITEMS`
                    type = CAST #( cl_abap_datadescr=>describe_by_data( mt_std ) ) ) TO lt_nested_comp.
    CREATE DATA mr_handle_nested TYPE HANDLE cl_abap_structdescr=>create( lt_nested_comp ).
    ASSIGN mr_handle_nested->* TO <row>.
    ASSIGN COMPONENT `T_ITEMS` OF STRUCTURE <row> TO <tab>.
    IF sy-subrc = 0.
      <tab> = mt_std.
    ENDIF.

    ms_with_oref-text  = `with-oref`.
    ms_with_oref-o_obj = NEW #( ).
    ms_with_oref-o_obj->mv_inner = `in-struc`.

    ms_with_dref-text = `with-dref`.
    CREATE DATA ms_with_dref-r_tab TYPE HANDLE lo_tab.
    ASSIGN ms_with_dref-r_tab->* TO <tab>.
    ls_sel = VALUE #( col1 = `in-struc-tab` ).
    APPEND INITIAL LINE TO <tab> ASSIGNING <row>.
    MOVE-CORRESPONDING ls_sel TO <row>.

    APPEND INITIAL LINE TO mt_rows_ref ASSIGNING FIELD-SYMBOL(<row_ref>).
    <row_ref>-id = `r1`.
    CREATE DATA <row_ref>-r_elem.
    <row_ref>-r_elem->* = `cell-ref`.
    <row_ref>-o_obj = NEW #( ).
    <row_ref>-o_obj->mv_inner = `cell-obj`.

    mv_protected = `protected`.
    mo_hidden = NEW #( ).

  ENDMETHOD.

ENDCLASS.


CLASS ltcl_test_shapes DEFINITION DEFERRED.
CLASS z2ui5_cl_ui5_srv_model DEFINITION LOCAL FRIENDS ltcl_test_shapes.


CLASS ltcl_test_shapes DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION MEDIUM.

  PRIVATE SECTION.

    DATA mo_app   TYPE REF TO ltcl_app_shapes.
    DATA mo_model TYPE REF TO z2ui5_cl_ui5_srv_model.
    DATA mr_attri TYPE REF TO z2ui5_if_ui5_types=>ty_t_attri.

    " the names every bound row must keep across the lifecycle
    DATA mt_bound TYPE string_table.

    METHODS setup.

    " L1: every form gets its rows
    METHODS dissolve_rows_complete   FOR TESTING RAISING cx_static_check.
    " L2: every bindable form is found, refs and aliases resolve to their owner
    METHODS bind_search_every_form   FOR TESTING RAISING cx_static_check.
    " L3: the model carries every bound row
    METHODS json_every_bound_row     FOR TESTING RAISING cx_static_check.
    " L5: save + restore in place (same instance, same roundtrip)
    METHODS save_restore_in_place    FOR TESTING RAISING cx_static_check.
    " L6/L8: save, XML roundtrip into a NEW instance, load, bind again
    METHODS draft_roundtrip_new_inst FOR TESTING RAISING cx_static_check.
    " S15/S23: the dead and the hidden object come back initial, quietly
    METHODS dead_objects_stay_quiet  FOR TESTING RAISING cx_static_check.
    " S13: a dref chain keeps its data
    METHODS dref_chain_survives      FOR TESTING RAISING cx_static_check.
    " S24 / sample 332: a CELL binding (tab + tab_index) into the helper's
    " table, made on the instance the draft restored
    METHODS cell_bind_after_restore  FOR TESTING RAISING cx_static_check.

    METHODS bind_all.
    METHODS bind
      IMPORTING
        ir_val TYPE REF TO data.

    " the draft roundtrip as the framework runs it: srtti save, asXML of the
    " app AND of the attribute table, parse into fresh instances, load
    METHODS roundtrip.

    " the invariants (I1-I8 of the plan)
    METHODS inv_descriptors_bound.
    METHODS inv_rows_reachable.
    METHODS inv_identity_shared.
    METHODS inv_search_finds_bound.
    METHODS inv_json_unchanged
      IMPORTING
        iv_before TYPE string.
    METHODS inv_srtti_cleared.

ENDCLASS.


CLASS ltcl_test_shapes IMPLEMENTATION.

  METHOD setup.

    mo_app = NEW #( ).
    mo_app->fill( ).

    DATA lt_attri TYPE z2ui5_if_ui5_types=>ty_t_attri.
    CREATE DATA mr_attri.
    mr_attri->* = lt_attri.
    mo_model = NEW #( attri = mr_attri
                      app   = mo_app ).

  ENDMETHOD.

  METHOD bind.

    DATA(lr_attri) = mo_model->main_attri_search( ir_val ).
    lr_attri->bind = abap_true.
    " a path the ajson writer accepts: no `-` and no `->` inside a segment
    DATA(lv_path) = lr_attri->name.
    REPLACE ALL OCCURRENCES OF `->*` IN lv_path WITH `_D`.
    REPLACE ALL OCCURRENCES OF `->` IN lv_path WITH `_`.
    REPLACE ALL OCCURRENCES OF `-` IN lv_path WITH `_`.
    lr_attri->name_client = |/{ lv_path }|.
    APPEND lr_attri->name TO mt_bound.

  ENDMETHOD.

  METHOD bind_all.

    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.

    CLEAR mt_bound.

    " S01
    bind( REF #( mo_app->mv_string ) ).
    bind( REF #( mo_app->mv_int ) ).
    bind( REF #( mo_app->mv_packed ) ).
    bind( REF #( mo_app->mv_date ) ).
    bind( REF #( mo_app->mv_time ) ).
    bind( REF #( mo_app->mv_bool ) ).
    " S02/S03 - the structure and a leaf four levels down
    bind( REF #( mo_app->ms_flat ) ).
    bind( REF #( mo_app->ms_deep-l1-l2-l3-v4 ) ).
    " S04-S07
    bind( REF #( mo_app->mt_std ) ).
    bind( REF #( mo_app->mt_sorted ) ).
    bind( REF #( mo_app->mt_strings ) ).
    bind( REF #( mo_app->mt_nested ) ).
    " S08 - the dereferenced data, exactly what _bind( <fs> ) hands over
    bind( mo_app->mr_typed_tab ).
    bind( REF #( mo_app->mr_typed_struc->col1 ) ).
    bind( mo_app->mr_typed_elem ).
    " S09/S10
    bind( mo_app->mr_handle_tab ).
    bind( mo_model->attri_get_val_ref( `MR_HANDLE_STRUC->COL1` ) ).
    bind( mo_app->mr_elem ).
    " S12 - the shared table through the helper's reference
    bind( mo_app->mo_inner->mr_shared ).
    " S14 - data inside the helper and its chain
    bind( REF #( mo_app->mo_inner->mv_inner ) ).
    bind( REF #( mo_app->mo_inner->mt_own ) ).
    bind( REF #( mo_app->mo_inner->mo_deeper->mv_inner ) ).
    " S26 - the table inside the anonymous structure
    bind( mo_model->attri_get_val_ref( `MR_HANDLE_NESTED->T_ITEMS` ) ).
    " S27 - the typed table, reached through the second helper's reference
    bind( REF #( mo_app->mo_inner_2->mv_inner ) ).
    " S19/S20 - through the component
    bind( REF #( mo_app->ms_with_oref-o_obj->mv_inner ) ).
    ASSIGN mo_app->ms_with_dref-r_tab->* TO <tab>.
    bind( REF #( <tab> ) ).

  ENDMETHOD.

  METHOD roundtrip.

    mo_model->main_attri_db_save_srtti( ).

    " the container serializes itself with the app AND mt_attri inside -
    " o_typedescr is a REF TO cl_abap_typedescr and does not survive this,
    " which is the state every restore starts from
    DATA(lv_app_xml)   = z2ui5_cl_ui5_util_context=>xml_stringify( mo_app ).
    DATA(lv_attri_xml) = z2ui5_cl_ui5_util_context=>xml_stringify( mr_attri->* ).

    CLEAR mo_app.
    z2ui5_cl_ui5_util_context=>xml_parse( EXPORTING xml = lv_app_xml
                                          IMPORTING any = mo_app ).
    CREATE DATA mr_attri.
    z2ui5_cl_ui5_util_context=>xml_parse( EXPORTING xml = lv_attri_xml
                                          IMPORTING any = mr_attri->* ).

    mo_model = NEW #( attri = mr_attri
                      app   = mo_app ).
    mo_model->main_attri_db_load( ).

  ENDMETHOD.

  METHOD inv_descriptors_bound.

    " I1 - every row the restore could reach carries its descriptor again;
    " the rows of a DEAD object are the documented exception (the object is
    " gone, so its attributes have no address), and attri_search skips them
    LOOP AT mr_attri->* REFERENCE INTO DATA(lr_attri).
      IF lr_attri->name CP `MO_DEAD->*`.
        CONTINUE.
      ENDIF.
      cl_abap_unit_assert=>assert_bound( act = lr_attri->o_typedescr
                                         msg = |I1: no descriptor on { lr_attri->name }| ).
    ENDLOOP.

  ENDMETHOD.

  METHOD inv_rows_reachable.

    " I3 - every row names data that exists on the instance
    LOOP AT mr_attri->* REFERENCE INTO DATA(lr_attri).
      IF lr_attri->name CP `MO_DEAD->*`.
        CONTINUE.
      ENDIF.
      TRY.
          DATA(lr_ref) = mo_model->attri_get_val_ref( lr_attri->name ).
          cl_abap_unit_assert=>assert_bound( act = lr_ref
                                             msg = |I3: { lr_attri->name } not reachable| ).
        CATCH cx_root.
          cl_abap_unit_assert=>fail( |I3: { lr_attri->name } not reachable| ).
      ENDTRY.
    ENDLOOP.

  ENDMETHOD.

  METHOD inv_identity_shared.

    " I4 - references that shared a data object share ONE again (identity,
    " not content: the 339 toasts compare content and would miss a copy)
    cl_abap_unit_assert=>assert_bound( act = mo_app->mr_shared_a
                                       msg = `I4: mr_shared_a lost` ).
    cl_abap_unit_assert=>assert_true( act = xsdbool( mo_app->mr_shared_a = mo_app->mr_shared_b )
                                      msg = `I4: mr_shared_a and mr_shared_b are two objects now` ).
    cl_abap_unit_assert=>assert_true( act = xsdbool( mo_app->mr_shared_a = mo_app->mo_inner->mr_shared )
                                      msg = `I4: the helper's mr_shared is a copy` ).
    " ...two helpers stay two objects (334)...
    cl_abap_unit_assert=>assert_true( act = xsdbool( mo_app->mo_inner <> mo_app->mo_inner_2 )
                                      msg = `I4: the two helpers collapsed into one object` ).
    cl_abap_unit_assert=>assert_equals( exp = `inner-2`
                                        act = mo_app->mo_inner_2->mv_inner ).
    " ...and the aliases point INTO their owner again, the one inside the
    " second helper included (347)
    DATA(lr_flat) = REF #( mo_app->ms_flat ).
    DATA(lr_std)  = REF #( mo_app->mt_std ).
    cl_abap_unit_assert=>assert_true( act = xsdbool( mo_app->mo_inner_2->mr_shared = lr_std )
                                      msg = `I4: the helper's alias of mt_std is a copy` ).
    cl_abap_unit_assert=>assert_true( act = xsdbool( mo_app->mr_alias_struc = lr_flat )
                                      msg = `I4: mr_alias_struc detached from ms_flat` ).
    cl_abap_unit_assert=>assert_true( act = xsdbool( mo_app->mr_alias_tab = lr_std )
                                      msg = `I4: mr_alias_tab detached from mt_std` ).

  ENDMETHOD.

  METHOD inv_search_finds_bound.

    " I5 - the binding search answers with the same row for every bound
    " attribute, on the instance as it is NOW
    LOOP AT mt_bound INTO DATA(lv_name).
      DATA(lr_ref) = mo_model->attri_get_val_ref( lv_name ).
      DATA(lr_attri) = mo_model->main_attri_search( lr_ref ).
      cl_abap_unit_assert=>assert_equals( act = lr_attri->name
                                          exp = lv_name
                                          msg = |I5: { lv_name } found as { lr_attri->name }| ).
    ENDLOOP.

  ENDMETHOD.

  METHOD inv_json_unchanged.

    " I2/I6 - the model the next render ships is the model before the save
    DATA(lv_after) = mo_model->main_json_stringify( ).
    cl_abap_unit_assert=>assert_equals( act = lv_after
                                        exp = iv_before
                                        msg = `I2: the model changed across the draft` ).
    LOOP AT mt_bound INTO DATA(lv_name).
      DATA(lr_attri) = REF #( mr_attri->*[ name = lv_name ] ).
      DATA(lv_key) = substring( val = lr_attri->name_client
                                off = 1 ).
      cl_abap_unit_assert=>assert_true( act = xsdbool( lv_after CS |"{ lv_key }"| )
                                        msg = |I6: { lv_name } missing from the model| ).
    ENDLOOP.

  ENDMETHOD.

  METHOD inv_srtti_cleared.

    " I8 - a successful restore leaves no payload behind
    LOOP AT mr_attri->* REFERENCE INTO DATA(lr_attri) "#EC CI_SORTSEQ
         WHERE srtti_data IS NOT INITIAL.
      cl_abap_unit_assert=>fail( |I8: { lr_attri->name } still carries srtti_data| ).
    ENDLOOP.

  ENDMETHOD.

  METHOD dissolve_rows_complete.

    mo_model->main_attri_refresh( ).

    DATA(lt_expected) = VALUE string_table(
        ( `MV_STRING` ) ( `MV_PACKED` ) ( `MV_XSTR` )
        ( `MS_FLAT` ) ( `MS_FLAT-COL1` )
        ( `MS_DEEP` ) ( `MS_DEEP-L1` ) ( `MS_DEEP-L1-L2` ) ( `MS_DEEP-L1-L2-L3` ) ( `MS_DEEP-L1-L2-L3-V4` )
        ( `MT_STD` ) ( `MT_SORTED` ) ( `MT_STRINGS` ) ( `MT_NESTED` )
        ( `MR_TYPED_TAB` ) ( `MR_TYPED_TAB->*` )
        ( `MR_TYPED_STRUC` ) ( `MR_TYPED_STRUC->COL1` )
        ( `MR_TYPED_ELEM` ) ( `MR_TYPED_ELEM->*` )
        ( `MR_HANDLE_TAB` ) ( `MR_HANDLE_TAB->*` )
        ( `MR_HANDLE_STRUC` ) ( `MR_HANDLE_STRUC->SELKZ` )
        ( `MR_ELEM` ) ( `MR_ELEM->*` )
        ( `MR_ALIAS_STRUC` ) ( `MR_ALIAS_STRUC->COL1` )
        ( `MR_ALIAS_TAB` ) ( `MR_ALIAS_TAB->*` )
        ( `MR_SHARED_A` ) ( `MR_SHARED_A->*` ) ( `MR_SHARED_B->*` )
        ( `MR_REF_REF` )
        ( `MO_INNER` ) ( `MO_INNER->MV_INNER` ) ( `MO_INNER->MT_OWN` )
        ( `MO_INNER->MR_SHARED` ) ( `MO_INNER->MR_SHARED->*` )
        ( `MO_INNER->MO_DEEPER` ) ( `MO_INNER->MO_DEEPER->MV_INNER` )
        ( `MO_DEAD` ) ( `MO_DEAD->MV_TEXT` )
        ( `MS_WITH_OREF-O_OBJ` ) ( `MS_WITH_OREF-O_OBJ->MV_INNER` )
        ( `MS_WITH_DREF-R_TAB` ) ( `MS_WITH_DREF-R_TAB->*` )
        ( `MT_ROWS_REF` ) ( `MT_COMP` )
        ( `MR_HANDLE_NESTED` ) ( `MR_HANDLE_NESTED->ID` ) ( `MR_HANDLE_NESTED->T_ITEMS` )
        ( `MO_INNER_2` ) ( `MO_INNER_2->MR_SHARED` ) ).

    LOOP AT lt_expected INTO DATA(lv_name).
      cl_abap_unit_assert=>assert_true( act = xsdbool( line_exists( mr_attri->*[ name = lv_name ] ) )
                                        msg = |L1: no row for { lv_name }| ).
    ENDLOOP.

    " protected attributes are not dissolved - nothing can bind them
    cl_abap_unit_assert=>assert_false( xsdbool( line_exists( mr_attri->*[ name = `MV_PROTECTED` ] ) ) ).
    cl_abap_unit_assert=>assert_false( xsdbool( line_exists( mr_attri->*[ name = `MO_HIDDEN` ] ) ) ).

    " the aliases know their owner
    cl_abap_unit_assert=>assert_equals( exp = `MS_FLAT`
                                        act = mr_attri->*[ name = `MR_ALIAS_STRUC` ]-name_ref ).
    cl_abap_unit_assert=>assert_equals( exp = `MT_STD`
                                        act = mr_attri->*[ name = `MR_ALIAS_TAB->*` ]-name_ref ).

    " of three references to one table exactly ONE row is canonical
    DATA(lv_canonical) = 0.
    LOOP AT mr_attri->* TRANSPORTING NO FIELDS "#EC CI_SORTSEQ
         WHERE ( name = `MR_SHARED_A->*` OR name = `MR_SHARED_B->*` OR name = `MO_INNER->MR_SHARED->*` )
           AND name_ref IS INITIAL.
      lv_canonical = lv_canonical + 1.
    ENDLOOP.
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lv_canonical
                                        msg = `L1: the shared table needs exactly one canonical row` ).

  ENDMETHOD.

  METHOD bind_search_every_form.

    bind_all( ).

    " every bind landed on the row it names...
    inv_search_finds_bound( ).

    " ...and an alias binds as its OWNER: the binding path must be the one
    " the model writes, and that is the owner's
    DATA(lr_attri) = mo_model->main_attri_search( mo_app->mr_alias_struc ).
    cl_abap_unit_assert=>assert_equals( exp = `MS_FLAT`
                                        act = lr_attri->name ).
    lr_attri = mo_model->main_attri_search( mo_app->mr_shared_b ).
    DATA(lr_attri_a) = mo_model->main_attri_search( mo_app->mr_shared_a ).
    cl_abap_unit_assert=>assert_equals( exp = lr_attri_a->name
                                        act = lr_attri->name ).

  ENDMETHOD.

  METHOD json_every_bound_row.

    bind_all( ).
    DATA(lv_json) = mo_model->main_json_stringify( ).

    LOOP AT mt_bound INTO DATA(lv_name).
      DATA(lr_attri) = REF #( mr_attri->*[ name = lv_name ] ).
      DATA(lv_key) = substring( val = lr_attri->name_client
                                off = 1 ).
      cl_abap_unit_assert=>assert_true( act = xsdbool( lv_json CS |"{ lv_key }"| )
                                        msg = |L3: { lv_name } missing from the model| ).
    ENDLOOP.

    " a few values, to see the data and not only the keys
    cl_abap_unit_assert=>assert_true( xsdbool( lv_json CS `"handle-row-1"` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_json CS `"elem"` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_json CS `"deeper"` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_json CS `"in-struc-tab"` ) ).

  ENDMETHOD.

  METHOD save_restore_in_place.

    bind_all( ).
    DATA(lv_before) = mo_model->main_json_stringify( ).

    " what all_xml_stringify does around the container's serialization
    mo_model->main_attri_db_save_srtti( ).
    cl_abap_unit_assert=>assert_not_bound( act = mo_app->mr_handle_tab
                                           msg = `L5: the save must detach the generic reference` ).
    mo_model->main_attri_db_load( ).

    inv_descriptors_bound( ).
    inv_rows_reachable( ).
    inv_identity_shared( ).
    inv_search_finds_bound( ).
    inv_json_unchanged( lv_before ).
    inv_srtti_cleared( ).

  ENDMETHOD.

  METHOD draft_roundtrip_new_inst.

    bind_all( ).
    DATA(lv_before) = mo_model->main_json_stringify( ).

    roundtrip( ).

    inv_descriptors_bound( ).
    inv_rows_reachable( ).
    inv_identity_shared( ).
    inv_search_finds_bound( ).
    inv_json_unchanged( lv_before ).
    inv_srtti_cleared( ).

    " the data behind the rows, not only the rows
    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
    ASSIGN mo_app->mr_handle_tab->* TO <tab>.
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( <tab> ) ).
    ASSIGN mo_app->ms_with_dref-r_tab->* TO <tab>.
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( <tab> ) ).
    cl_abap_unit_assert=>assert_equals( exp = `typed-elem`
                                        act = mo_app->mr_typed_elem->* ).
    cl_abap_unit_assert=>assert_equals( exp = `deeper`
                                        act = mo_app->mo_inner->mo_deeper->mv_inner ).
    cl_abap_unit_assert=>assert_equals( exp = `in-struc`
                                        act = mo_app->ms_with_oref-o_obj->mv_inner ).
    cl_abap_unit_assert=>assert_equals( exp = `cell-ref`
                                        act = mo_app->mt_rows_ref[ 1 ]-r_elem->* ).
    cl_abap_unit_assert=>assert_equals( exp = `cell-obj`
                                        act = mo_app->mt_rows_ref[ 1 ]-o_obj->mv_inner ).
    cl_abap_unit_assert=>assert_equals( exp = `protected`
                                        act = mo_app->get_protected( ) ).
    " S25 - the rows survive, the descriptors they held do not (an RTTI
    " descriptor is not serializable), and neither fact is an error
    cl_abap_unit_assert=>assert_equals( exp = 3
                                        act = lines( mo_app->mt_comp ) ).
    cl_abap_unit_assert=>assert_not_bound( mo_app->mt_comp[ 1 ]-type ).
    " S26 - the table inside the anonymous structure
    FIELD-SYMBOLS <nested> TYPE any.
    ASSIGN mo_app->mr_handle_nested->* TO <nested>.
    ASSIGN COMPONENT `T_ITEMS` OF STRUCTURE <nested> TO <tab>.
    cl_abap_unit_assert=>assert_subrc( ).
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( <tab> ) ).

    " L8 - the NEXT render binds again, and a second draft roundtrip on the
    " restored instance is as clean as the first
    DATA(lv_second) = mo_model->main_json_stringify( ).
    roundtrip( ).
    inv_descriptors_bound( ).
    inv_identity_shared( ).
    inv_search_finds_bound( ).
    inv_json_unchanged( lv_second ).

  ENDMETHOD.

  METHOD dead_objects_stay_quiet.

    bind_all( ).
    roundtrip( ).

    " S15 - not serializable, so gone; and nothing raised on the way
    cl_abap_unit_assert=>assert_not_bound( mo_app->mo_dead ).
    " the row it left behind carries no descriptor and is skipped by the
    " search instead of dumping it (S17 leaves the same shape behind)
    cl_abap_unit_assert=>assert_not_bound( mr_attri->*[ name = `MO_DEAD->MV_TEXT` ]-o_typedescr ).
    DATA(lr_attri) = mo_model->main_attri_search( REF #( mo_app->mv_string ) ).
    cl_abap_unit_assert=>assert_equals( exp = `MV_STRING`
                                        act = lr_attri->name ).

    " a refresh drops the orphan rows for good
    mo_model->main_attri_refresh( ).
    cl_abap_unit_assert=>assert_false( xsdbool( line_exists( mr_attri->*[ name = `MO_DEAD->MV_TEXT` ] ) ) ).

  ENDMETHOD.

  METHOD cell_bind_after_restore.

    bind_all( ).
    roundtrip( ).

    " the binder works on the container: the restored app and the restored
    " attribute table, exactly what the next render's _bind( ) sees
    DATA(lo_cont) = NEW z2ui5_cl_ui5_app_cont( ).
    lo_cont->mo_app   = mo_app.
    lo_cont->mt_attri = mr_attri.
    DATA(lo_bind) = NEW z2ui5_cl_ui5_srv_bind( lo_cont ).

    " row 1 of the helper's own table, the layout row of sample 332
    DATA(lr_row) = REF #( mo_app->mo_inner->mt_own[ 1 ] ).
    DATA(lv_path) = lo_bind->main( val    = REF #( lr_row->col1 )
                                   config = VALUE #( tab       = REF #( mo_app->mo_inner->mt_own )
                                                     tab_index = 1 ) ).
    cl_abap_unit_assert=>assert_equals( exp = `{/MO_INNER_MT_OWN/0/COL1}`
                                        act = lv_path ).

    " ...and a cell of the runtime-built table behind the generic reference
    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <row> TYPE any.
    ASSIGN mo_app->mr_handle_tab->* TO <tab>.
    READ TABLE <tab> INDEX 2 ASSIGNING <row>.
    cl_abap_unit_assert=>assert_subrc( ).
    ASSIGN COMPONENT `COL1` OF STRUCTURE <row> TO FIELD-SYMBOL(<cell>).
    cl_abap_unit_assert=>assert_subrc( ).
    lv_path = lo_bind->main( val    = REF #( <cell> )
                             config = VALUE #( tab       = mo_app->mr_handle_tab
                                               tab_index = 2 ) ).
    cl_abap_unit_assert=>assert_true( act = xsdbool( lv_path CP `{/*/1/COL1}` )
                                      msg = |cell path after restore: { lv_path }| ).

  ENDMETHOD.

  METHOD dref_chain_survives.

    FIELD-SYMBOLS <inner> TYPE REF TO data.
    FIELD-SYMBOLS <elem>  TYPE any.

    " S13 - the value behind mr_ref_ref->*->* is data like any other; the
    " dref save cleared the outer reference and never restored it. Built
    " here and not in fill( ): the NodeJS runtime cannot CREATE DATA a
    " REF TO data object, so this one test is skipped there (see
    " node/setup/abap_transpile.json) while the catalogue stays runnable
    CREATE DATA mo_app->mr_ref_ref TYPE REF TO data.
    ASSIGN mo_app->mr_ref_ref->* TO <inner>.
    CREATE DATA <inner> TYPE string.
    ASSIGN <inner>->* TO <elem>.
    <elem> = `ref-ref`.

    bind( <inner> ).
    cl_abap_unit_assert=>assert_true( xsdbool( line_exists( mr_attri->*[ name = `MR_REF_REF->*->*` ] ) ) ).
    roundtrip( ).

    cl_abap_unit_assert=>assert_bound( act = mo_app->mr_ref_ref
                                       msg = `S13: the outer reference was lost` ).
    ASSIGN mo_app->mr_ref_ref->* TO <inner>.
    cl_abap_unit_assert=>assert_bound( act = <inner>
                                       msg = `S13: the inner reference was lost` ).
    ASSIGN <inner>->* TO <elem>.
    cl_abap_unit_assert=>assert_equals( exp = `ref-ref`
                                        act = <elem> ).

    inv_search_finds_bound( ).

  ENDMETHOD.

ENDCLASS.


" ---------------------------------------------------------------------------
" Sample 338: a host holds its sub-app in a REF TO object and swaps it for an
" instance of ANOTHER class between two roundtrips - the rows of the old
" class stay in mt_attri with nothing to resolve to.
" ---------------------------------------------------------------------------

CLASS ltcl_shp_sub_a DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.
    DATA mt_table  TYPE REF TO data.
    DATA mo_layout TYPE REF TO ltcl_shp_inner.
    METHODS fill.
ENDCLASS.

CLASS ltcl_shp_sub_a IMPLEMENTATION.

  METHOD z2ui5_if_app~main ##NEEDED.
  ENDMETHOD.

  METHOD fill.
    FIELD-SYMBOLS <tab>  TYPE STANDARD TABLE.
    FIELD-SYMBOLS <row>  TYPE any.
    DATA lv_selkz TYPE c LENGTH 1.
    DATA ls_line  TYPE ltcl_shp_inner=>ty_s_row.
    " a runtime-built line type, like the samples: known components plus
    " a field no dictionary has
    DATA(lo_line) = CAST cl_abap_structdescr( cl_abap_typedescr=>describe_by_data( ls_line ) ).
    DATA(lt_comp) = lo_line->get_components( ).
    APPEND VALUE #( name = `SELKZ`
                    type = CAST #( cl_abap_datadescr=>describe_by_data( lv_selkz ) ) ) TO lt_comp.
    DATA(lo_tab) = cl_abap_tabledescr=>create( p_line_type  = cl_abap_structdescr=>create( lt_comp )
                                               p_table_kind = cl_abap_tabledescr=>tablekind_std ).
    CREATE DATA mt_table TYPE HANDLE lo_tab.
    ASSIGN mt_table->* TO <tab>.
    ls_line-col1 = `a`.
    APPEND INITIAL LINE TO <tab> ASSIGNING <row>.
    MOVE-CORRESPONDING ls_line TO <row>.
    mo_layout->mr_shared = mt_table.
  ENDMETHOD.

ENDCLASS.


CLASS ltcl_shp_sub_b DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.
    DATA mt_data TYPE REF TO data.
    DATA mo_lay  TYPE REF TO ltcl_shp_inner.
    METHODS fill.
ENDCLASS.

CLASS ltcl_shp_sub_b IMPLEMENTATION.

  METHOD z2ui5_if_app~main ##NEEDED.
  ENDMETHOD.

  METHOD fill.
    FIELD-SYMBOLS <tab>  TYPE STANDARD TABLE.
    FIELD-SYMBOLS <row>  TYPE any.
    DATA lv_selkz TYPE c LENGTH 1.
    DATA ls_line  TYPE ltcl_shp_inner=>ty_s_row.
    " a runtime-built line type, like the samples: known components plus
    " a field no dictionary has
    DATA(lo_line) = CAST cl_abap_structdescr( cl_abap_typedescr=>describe_by_data( ls_line ) ).
    DATA(lt_comp) = lo_line->get_components( ).
    APPEND VALUE #( name = `SELKZ`
                    type = CAST #( cl_abap_datadescr=>describe_by_data( lv_selkz ) ) ) TO lt_comp.
    DATA(lo_tab) = cl_abap_tabledescr=>create( p_line_type  = cl_abap_structdescr=>create( lt_comp )
                                               p_table_kind = cl_abap_tabledescr=>tablekind_std ).
    CREATE DATA mt_data TYPE HANDLE lo_tab.
    ASSIGN mt_data->* TO <tab>.
    ls_line-col1 = `b`.
    APPEND INITIAL LINE TO <tab> ASSIGNING <row>.
    MOVE-CORRESPONDING ls_line TO <row>.
    mo_lay->mr_shared = mt_data.
  ENDMETHOD.

ENDCLASS.


CLASS ltcl_app_host DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.
    DATA mv_selectedkey TYPE string.
    DATA mo_app         TYPE REF TO object.
ENDCLASS.

CLASS ltcl_app_host IMPLEMENTATION.
  METHOD z2ui5_if_app~main ##NEEDED.
  ENDMETHOD.
ENDCLASS.


CLASS ltcl_test_class_swap DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION MEDIUM.

  PRIVATE SECTION.
    METHODS swap_binds_without_dump FOR TESTING RAISING cx_static_check.
    METHODS swap_survives_draft     FOR TESTING RAISING cx_static_check.

    " the draft roundtrip; io_sub, when given, replaces the host's sub-app
    " BEFORE the load - the state a restore against a host whose tab has
    " switched runs into (db_load_by_app restores against the live instance)
    METHODS roundtrip
      IMPORTING
        io_sub   TYPE REF TO object OPTIONAL
      CHANGING
        co_app   TYPE REF TO ltcl_app_host
        cr_attri TYPE REF TO z2ui5_if_ui5_types=>ty_t_attri
        co_model TYPE REF TO z2ui5_cl_ui5_srv_model.
ENDCLASS.


CLASS ltcl_test_class_swap IMPLEMENTATION.

  METHOD roundtrip.

    co_model->main_attri_db_save_srtti( ).
    DATA(lv_app_xml)   = z2ui5_cl_ui5_util_context=>xml_stringify( co_app ).
    DATA(lv_attri_xml) = z2ui5_cl_ui5_util_context=>xml_stringify( cr_attri->* ).
    CLEAR co_app.
    z2ui5_cl_ui5_util_context=>xml_parse( EXPORTING xml = lv_app_xml
                                          IMPORTING any = co_app ).
    CREATE DATA cr_attri.
    z2ui5_cl_ui5_util_context=>xml_parse( EXPORTING xml = lv_attri_xml
                                          IMPORTING any = cr_attri->* ).
    IF io_sub IS BOUND.
      co_app->mo_app = io_sub.
    ENDIF.
    co_model = NEW #( attri = cr_attri
                      app   = co_app ).
    co_model->main_attri_db_load( ).

  ENDMETHOD.

  METHOD swap_binds_without_dump.

    " roundtrip 1: the host renders sub-app A and binds A's table
    DATA(lo_host) = NEW ltcl_app_host( ).
    DATA(lo_a) = NEW ltcl_shp_sub_a( ).
    lo_a->mo_layout = NEW #( ).
    lo_a->fill( ).
    lo_host->mo_app = lo_a.
    lo_host->mv_selectedkey = `1`.

    DATA lr_attri TYPE REF TO z2ui5_if_ui5_types=>ty_t_attri.
    CREATE DATA lr_attri.
    DATA(lo_model) = NEW z2ui5_cl_ui5_srv_model( attri = lr_attri
                                                 app   = lo_host ).
    DATA(ls_bind) = lo_model->main_attri_search( REF #( lo_host->mv_selectedkey ) ).
    ls_bind->bind = abap_true.
    ls_bind->name_client = `/MV_SELECTEDKEY`.
    ls_bind = lo_model->main_attri_search( lo_a->mt_table ).
    cl_abap_unit_assert=>assert_equals( exp = `MO_APP->MT_TABLE->*`
                                        act = ls_bind->name ).
    ls_bind->bind = abap_true.
    ls_bind->name_client = `/MO_APP_MT_TABLE`.

    " roundtrip 2: the tab switched - the host holds sub-app B, whose
    " attributes have OTHER names, when the draft is restored. The rows of
    " A are still there, resolve to nothing, and keep no descriptor
    DATA(lo_b) = NEW ltcl_shp_sub_b( ).
    lo_b->mo_lay = NEW #( ).
    lo_b->fill( ).
    roundtrip( EXPORTING io_sub   = lo_b
               CHANGING  co_app   = lo_host
                         cr_attri = lr_attri
                         co_model = lo_model ).
    lo_host->mv_selectedkey = `2`.
    cl_abap_unit_assert=>assert_not_bound( lr_attri->*[ name = `MO_APP->MO_LAYOUT->MV_INNER` ]-o_typedescr ).

    " the host's own bind first - it walks the A rows of its own kind and
    " used to dump on the first one without a descriptor
    ls_bind = lo_model->main_attri_search( REF #( lo_host->mv_selectedkey ) ).
    cl_abap_unit_assert=>assert_equals( exp = `MV_SELECTEDKEY`
                                        act = ls_bind->name ).

    " then B's table: not in mt_attri, so the search refreshes and finds it
    ls_bind = lo_model->main_attri_search( lo_b->mt_data ).
    cl_abap_unit_assert=>assert_equals( exp = `MO_APP->MT_DATA->*`
                                        act = ls_bind->name ).

    " the refresh dropped A's rows - nothing of the old class lingers
    cl_abap_unit_assert=>assert_false( xsdbool( line_exists( lr_attri->*[ name = `MO_APP->MT_TABLE->*` ] ) ) ).
    cl_abap_unit_assert=>assert_false( xsdbool( line_exists( lr_attri->*[ name = `MO_APP->MO_LAYOUT` ] ) ) ).

  ENDMETHOD.

  METHOD swap_survives_draft.

    " the same switch, and then the draft roundtrip that follows it - the
    " model must carry B's table, and the third roundtrip binds it again
    DATA(lo_host) = NEW ltcl_app_host( ).
    DATA(lo_a) = NEW ltcl_shp_sub_a( ).
    lo_a->mo_layout = NEW #( ).
    lo_a->fill( ).
    lo_host->mo_app = lo_a.

    DATA lr_attri TYPE REF TO z2ui5_if_ui5_types=>ty_t_attri.
    CREATE DATA lr_attri.
    DATA(lo_model) = NEW z2ui5_cl_ui5_srv_model( attri = lr_attri
                                                 app   = lo_host ).
    DATA(ls_bind) = lo_model->main_attri_search( lo_a->mt_table ).
    ls_bind->bind = abap_true.
    ls_bind->name_client = `/MO_APP_MT_TABLE`.

    roundtrip( CHANGING co_app   = lo_host
                        cr_attri = lr_attri
                        co_model = lo_model ).

    DATA(lo_b) = NEW ltcl_shp_sub_b( ).
    lo_b->mo_lay = NEW #( ).
    lo_b->fill( ).
    lo_host->mo_app = lo_b.
    ls_bind = lo_model->main_attri_search( lo_b->mt_data ).
    ls_bind->bind = abap_true.
    ls_bind->name_client = `/MO_APP_MT_DATA`.
    DATA(lv_before) = lo_model->main_json_stringify( ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_before CS `"MO_APP_MT_DATA"` ) ).

    roundtrip( CHANGING co_app   = lo_host
                        cr_attri = lr_attri
                        co_model = lo_model ).

    cl_abap_unit_assert=>assert_equals( exp = lv_before
                                        act = lo_model->main_json_stringify( ) ).
    DATA lo_b_restored TYPE REF TO ltcl_shp_sub_b.
    lo_b_restored ?= lo_host->mo_app.
    cl_abap_unit_assert=>assert_bound( lo_b_restored->mt_data ).
    cl_abap_unit_assert=>assert_true( act = xsdbool( lo_b_restored->mt_data = lo_b_restored->mo_lay->mr_shared )
                                      msg = `the layout's reference is a copy after the restore` ).
    ls_bind = lo_model->main_attri_search( lo_b_restored->mt_data ).
    cl_abap_unit_assert=>assert_equals( exp = `MO_APP->MT_DATA->*`
                                        act = ls_bind->name ).

  ENDMETHOD.

ENDCLASS.


" ---------------------------------------------------------------------------
" Sample 339 with the sort order turned around: the canonical row of a shared
" table is whichever of its rows sorts LAST in mt_attri. In 339 that is an
" outer attribute (MT_TABLE_TMP->*); here the helper's reference sorts last
" (MZ_INNER->MR_SHARED->*), so the payload lives on the NESTED object and
" the outer references are re-pointed from there.
" ---------------------------------------------------------------------------

CLASS ltcl_app_shared_last DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.
    DATA mr_table     TYPE REF TO data.
    DATA mr_table_tmp TYPE REF TO data.
    DATA mz_inner     TYPE REF TO ltcl_shp_inner.
ENDCLASS.

CLASS ltcl_app_shared_last IMPLEMENTATION.
  METHOD z2ui5_if_app~main ##NEEDED.
  ENDMETHOD.
ENDCLASS.


CLASS ltcl_test_shared_last DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION MEDIUM.

  PRIVATE SECTION.
    METHODS canonical_in_nested_object FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_test_shared_last IMPLEMENTATION.

  METHOD canonical_in_nested_object.

    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
    DATA ls_row TYPE ltcl_shp_inner=>ty_s_row.

    DATA(lo_app) = NEW ltcl_app_shared_last( ).
    lo_app->mz_inner = NEW #( ).
    DATA(lo_tab) = CAST cl_abap_tabledescr( cl_abap_typedescr=>describe_by_data( lo_app->mz_inner->mt_own ) ).
    CREATE DATA lo_app->mr_table TYPE HANDLE lo_tab.
    ASSIGN lo_app->mr_table->* TO <tab>.
    ls_row-col1 = `shared`.
    INSERT ls_row INTO TABLE <tab>.
    lo_app->mr_table_tmp = lo_app->mr_table.
    lo_app->mz_inner->mr_shared = lo_app->mr_table.

    DATA lr_attri TYPE REF TO z2ui5_if_ui5_types=>ty_t_attri.
    CREATE DATA lr_attri.
    DATA(lo_model) = NEW z2ui5_cl_ui5_srv_model( attri = lr_attri
                                                 app   = lo_app ).
    DATA(ls_bind) = lo_model->main_attri_search( lo_app->mr_table ).
    ls_bind->bind = abap_true.
    ls_bind->name_client = `/MR_TABLE`.

    " the canonical row is the nested one - and it is the row every one of
    " the three references binds to
    cl_abap_unit_assert=>assert_equals( exp = `MZ_INNER->MR_SHARED->*`
                                        act = ls_bind->name ).
    cl_abap_unit_assert=>assert_initial( lr_attri->*[ name = `MZ_INNER->MR_SHARED->*` ]-name_ref ).
    cl_abap_unit_assert=>assert_equals( exp = `MZ_INNER->MR_SHARED->*`
                                        act = lr_attri->*[ name = `MR_TABLE->*` ]-name_ref ).
    cl_abap_unit_assert=>assert_equals( exp = `MZ_INNER->MR_SHARED->*`
                                        act = lr_attri->*[ name = `MR_TABLE_TMP->*` ]-name_ref ).

    DATA(lv_before) = lo_model->main_json_stringify( ).

    lo_model->main_attri_db_save_srtti( ).
    " the payload sits on the nested object's reference
    cl_abap_unit_assert=>assert_not_initial( lr_attri->*[ name = `MZ_INNER->MR_SHARED` ]-srtti_data ).
    cl_abap_unit_assert=>assert_initial( lr_attri->*[ name = `MR_TABLE` ]-srtti_data ).

    DATA(lv_app_xml)   = z2ui5_cl_ui5_util_context=>xml_stringify( lo_app ).
    DATA(lv_attri_xml) = z2ui5_cl_ui5_util_context=>xml_stringify( lr_attri->* ).
    CLEAR lo_app.
    z2ui5_cl_ui5_util_context=>xml_parse( EXPORTING xml = lv_app_xml
                                          IMPORTING any = lo_app ).
    CREATE DATA lr_attri.
    z2ui5_cl_ui5_util_context=>xml_parse( EXPORTING xml = lv_attri_xml
                                          IMPORTING any = lr_attri->* ).
    lo_model = NEW #( attri = lr_attri
                      app   = lo_app ).
    lo_model->main_attri_db_load( ).

    cl_abap_unit_assert=>assert_bound( lo_app->mr_table ).
    cl_abap_unit_assert=>assert_true( xsdbool( lo_app->mr_table = lo_app->mr_table_tmp ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lo_app->mr_table = lo_app->mz_inner->mr_shared ) ).
    ASSIGN lo_app->mr_table->* TO <tab>.
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( <tab> ) ).
    cl_abap_unit_assert=>assert_equals( exp = lv_before
                                        act = lo_model->main_json_stringify( ) ).
    ls_bind = lo_model->main_attri_search( lo_app->mr_table ).
    cl_abap_unit_assert=>assert_equals( exp = `MZ_INNER->MR_SHARED->*`
                                        act = ls_bind->name ).

  ENDMETHOD.

ENDCLASS.


" ---------------------------------------------------------------------------
" Three of the small test samples as unit tests: 343 (binding a REF TO data
" itself is refused), 138 (a leaf six levels down a structure whose
" components all carry the same name) and 118 (date and time fields the
" model has to ship as they are, initial or not)
" ---------------------------------------------------------------------------

CLASS ltcl_app_samples DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    TYPES:
      BEGIN OF ty_s_row,
        id    TYPE i,
        descr TYPE string,
        adate TYPE d,
        atime TYPE t,
      END OF ty_s_row.
    TYPES ty_t_row TYPE STANDARD TABLE OF ty_s_row WITH EMPTY KEY.

    DATA mt_data1 TYPE REF TO data.
    DATA mt_rows  TYPE ty_t_row.
    DATA mr_rows  TYPE REF TO data.

    DATA:
      BEGIN OF ms_data,
        BEGIN OF ms_data2,
          val TYPE string,
          BEGIN OF ms_data2,
            val TYPE string,
            BEGIN OF ms_data2,
              val TYPE string,
              BEGIN OF ms_data2,
                val TYPE string,
                BEGIN OF ms_data2,
                  val TYPE string,
                  BEGIN OF ms_data2,
                    val TYPE string,
                  END OF ms_data2,
                END OF ms_data2,
              END OF ms_data2,
            END OF ms_data2,
          END OF ms_data2,
        END OF ms_data2,
        val2 TYPE string,
      END OF ms_data.
ENDCLASS.

CLASS ltcl_app_samples IMPLEMENTATION.
  METHOD z2ui5_if_app~main ##NEEDED.
  ENDMETHOD.
ENDCLASS.


CLASS ltcl_test_samples DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS bind_reference_refused  FOR TESTING RAISING cx_static_check.
    METHODS deep_same_name_leaf     FOR TESTING RAISING cx_static_check.
    METHODS dates_initial_or_broken FOR TESTING RAISING cx_static_check.
    " the bound that lets a deep structure through must still end a cycle
    METHODS cyclic_object_ends      FOR TESTING RAISING cx_static_check.
    " sample 199: rows the backend appends reach the client, and the client's
    " copy of the table comes back with the same count
    METHODS appended_rows_come_back FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_test_samples IMPLEMENTATION.

  METHOD bind_reference_refused.

    " sample 343: _bind( mt_data1 ) hands the REFERENCE over, not the table
    " behind it - refused with a message that says what to do instead
    DATA(lo_app) = NEW ltcl_app_samples( ).
    CREATE DATA lo_app->mt_data1 LIKE lo_app->mt_rows.
    DATA lt_attri TYPE z2ui5_if_ui5_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_ui5_srv_model( attri = REF #( lt_attri )
                                                 app   = lo_app ).
    TRY.
        lo_model->main_attri_search( REF #( lo_app->mt_data1 ) ).
        cl_abap_unit_assert=>fail( `a reference itself must not be bindable` ).
      CATCH z2ui5_cx_ui5_util_error INTO DATA(lx).
        cl_abap_unit_assert=>assert_true( xsdbool( lx->get_text( ) CS `NO DATA REFERENCES` ) ).
    ENDTRY.

  ENDMETHOD.

  METHOD deep_same_name_leaf.

    " sample 138: the leaf sits SEVEN components deep, every level named
    " ms_data2 - deeper than one dissolve pass reaches, so the search has
    " to keep dissolving until it gets there
    DATA(lo_app) = NEW ltcl_app_samples( ).
    lo_app->ms_data-ms_data2-ms_data2-ms_data2-ms_data2-ms_data2-ms_data2-val = `deep`.
    DATA lt_attri TYPE z2ui5_if_ui5_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_ui5_srv_model( attri = REF #( lt_attri )
                                                 app   = lo_app ).
    DATA(lr_attri) = lo_model->main_attri_search(
        REF #( lo_app->ms_data-ms_data2-ms_data2-ms_data2-ms_data2-ms_data2-ms_data2-val ) ).
    cl_abap_unit_assert=>assert_equals( exp = `MS_DATA-MS_DATA2-MS_DATA2-MS_DATA2-MS_DATA2-MS_DATA2-MS_DATA2-VAL`
                                        act = lr_attri->name ).
    " and a shallower leaf of the same name is a different row
    DATA(lr_upper) = lo_model->main_attri_search( REF #( lo_app->ms_data-ms_data2-val ) ).
    cl_abap_unit_assert=>assert_equals( exp = `MS_DATA-MS_DATA2-VAL`
                                        act = lr_upper->name ).

  ENDMETHOD.

  METHOD cyclic_object_ends.

    " a helper that points back at itself: every hop is one more `->`, and
    " the dissolve stops after max_dissolve_depth of them instead of running
    " until the pass limit - the rows it leaves are bindable up to there
    DATA(lo_app) = NEW ltcl_app_shapes( ).
    lo_app->mo_inner = NEW #( ).
    lo_app->mo_inner->mv_inner  = `loop`.
    lo_app->mo_inner->mo_deeper = lo_app->mo_inner.

    DATA lt_attri TYPE z2ui5_if_ui5_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_ui5_srv_model( attri = REF #( lt_attri )
                                                 app   = lo_app ).
    lo_model->main_attri_refresh( ).

    cl_abap_unit_assert=>assert_true( xsdbool( line_exists( lt_attri[ name = `MO_INNER->MO_DEEPER->MO_DEEPER->MV_INNER` ] ) ) ).
    DATA(lv_deepest) = 0.
    LOOP AT lt_attri REFERENCE INTO DATA(lr_attri).
      DATA(lv_hops) = count( val = lr_attri->name
                             sub = `->` ).
      IF lv_hops > lv_deepest.
        lv_deepest = lv_hops.
      ENDIF.
    ENDLOOP.
    cl_abap_unit_assert=>assert_true( act = xsdbool( lv_deepest <= 5 )
                                      msg = |the cycle ran { lv_deepest } hops deep| ).
    cl_abap_unit_assert=>assert_false( xsdbool( line_exists( lt_attri[ check_dissolved = abap_false ] ) ) ).

  ENDMETHOD.

  METHOD appended_rows_come_back.

    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
    DATA ls_row TYPE ltcl_app_samples=>ty_s_row.

    DATA(lo_app) = NEW ltcl_app_samples( ).
    " LIKE a data object, not TYPE a class-local type: the NodeJS runtime
    " cannot CREATE DATA by the name of a type a local class declares
    CREATE DATA lo_app->mr_rows LIKE lo_app->mt_rows.
    ASSIGN lo_app->mr_rows->* TO <tab>.
    ls_row-id = 1.
    ls_row-descr = `first`.
    INSERT ls_row INTO TABLE <tab>.

    DATA lt_attri TYPE z2ui5_if_ui5_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_ui5_srv_model( attri = REF #( lt_attri )
                                                 app   = lo_app ).
    DATA(lr_attri) = lo_model->main_attri_search( lo_app->mr_rows ).
    lr_attri->bind        = abap_true.
    lr_attri->name_client = `/MR_ROWS`.

    " the backend appends two rows and ships the table...
    ls_row-id = 2.
    ls_row-descr = `second`.
    INSERT ls_row INTO TABLE <tab>.
    ls_row-id = 3.
    ls_row-descr = `third`.
    INSERT ls_row INTO TABLE <tab>.
    DATA(lv_json) = lo_model->main_json_stringify( ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_json CS `"third"` ) ).

    " ...the client sends the whole table back with its next event, and the
    " backend holds exactly what it shipped - 199 compares the count
    CLEAR <tab>.
    DATA(lo_front) = CAST z2ui5_if_ajson( z2ui5_cl_ajson=>parse( lv_json ) ).
    lo_model->main_json_to_attri( lo_front ).
    ASSIGN lo_app->mr_rows->* TO <tab>.
    cl_abap_unit_assert=>assert_equals( exp = 3
                                        act = lines( <tab> ) ).
    READ TABLE <tab> INDEX 3 INTO ls_row.
    cl_abap_unit_assert=>assert_subrc( ).
    cl_abap_unit_assert=>assert_equals( exp = `third`
                                        act = ls_row-descr ).

  ENDMETHOD.

  METHOD dates_initial_or_broken.

    " sample 118: rows whose date or time is initial, all zeros, or an
    " empty string that was moved into the field - the model ships them,
    " it does not fail the roundtrip over one of them
    DATA(lo_app) = NEW ltcl_app_samples( ).
    DATA ls_row TYPE ltcl_app_samples=>ty_s_row.
    ls_row-id = 1.
    ls_row-descr = `initial`.
    APPEND ls_row TO lo_app->mt_rows.
    ls_row-id = 2.
    ls_row-descr = `zeros`.
    ls_row-adate = '00000000'.
    ls_row-atime = '000000'.
    APPEND ls_row TO lo_app->mt_rows.
    ls_row-id = 3.
    ls_row-descr = `valid`.
    ls_row-adate = '20240115'.
    ls_row-atime = '123045'.
    APPEND ls_row TO lo_app->mt_rows.
    ls_row-id = 4.
    ls_row-descr = `empty string moved in`.
    ls_row-adate = ``.
    ls_row-atime = ``.
    APPEND ls_row TO lo_app->mt_rows.

    DATA lt_attri TYPE z2ui5_if_ui5_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_ui5_srv_model( attri = REF #( lt_attri )
                                                 app   = lo_app ).
    DATA(lr_attri) = lo_model->main_attri_search( REF #( lo_app->mt_rows ) ).
    lr_attri->bind        = abap_true.
    lr_attri->name_client = `/MT_ROWS`.

    DATA(lv_json) = lo_model->main_json_stringify( ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_json CS `"empty string moved in"` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_json CS `2024-01-15` ) ).

  ENDMETHOD.

ENDCLASS.
