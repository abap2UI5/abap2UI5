CLASS lcl_app_01 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION MEDIUM.

  PUBLIC SECTION.
    DATA mr_tab  TYPE REF TO data.

ENDCLASS.

CLASS lcl_app_01 IMPLEMENTATION.

ENDCLASS.

CLASS lcl_test_01 DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    METHODS tab_ref_gen FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS lcl_test_01 IMPLEMENTATION.

  METHOD tab_ref_gen.

    IF sy-sysid = 'ABC'.
      RETURN.
    ENDIF.


    "create data
    DATA(lo_app) = NEW lcl_app_01( ).

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
      comp1 = 'comp1'
      comp2 = 'comp2'
      ) INTO TABLE <tab>.



    "test find binding
    DATA(lt_attri) = VALUE z2ui5_if_core_types=>ty_t_attri( ).
    DATA(lo_model) = NEW z2ui5_cl_core_srv_model( attri = REF #( lt_attri )
                                                  app   = lo_app ).

    DATA(ls_attri) = lo_model->main_attri_search( lo_app->mr_tab ).

    IF ls_attri->name <> 'MR_TAB->*'.
      cl_abap_unit_assert=>abort( ).
    ENDIF.



    "test frontend backend draft
    lo_model->main_attri_db_save_srtti( ).

    lo_app = NEW lcl_app_01( ).
    lo_model = NEW z2ui5_cl_core_srv_model( attri = REF #( lt_attri )
                                            app = lo_app ).
    lo_model->main_attri_db_load( ).

    IF lo_app->mr_tab IS NOT BOUND.
      cl_abap_unit_assert=>abort( ).
    ENDIF.

  ENDMETHOD.
ENDCLASS.
