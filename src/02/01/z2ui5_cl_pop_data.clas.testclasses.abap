CLASS ltcl_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_factory_table  FOR TESTING RAISING cx_static_check.
    METHODS test_factory_struc  FOR TESTING RAISING cx_static_check.
    METHODS test_factory_title  FOR TESTING RAISING cx_static_check.
ENDCLASS.

CLASS ltcl_test IMPLEMENTATION.

  METHOD test_factory_table.
    TYPES:
      BEGIN OF ty_row,
        name TYPE string,
      END OF ty_row.
    DATA lt_tab TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.
    lt_tab = VALUE #( ( name = `A` ) ( name = `B` ) ).

    DATA(lo_pop) = z2ui5_cl_pop_data=>factory( lt_tab ).

    cl_abap_unit_assert=>assert_bound( lo_pop ).
    cl_abap_unit_assert=>assert_bound( lo_pop->mr_data ).
  ENDMETHOD.

  METHOD test_factory_struc.
    DATA:
      BEGIN OF ls_data,
        field1 TYPE string VALUE `hello`,
        field2 TYPE i VALUE 42,
      END OF ls_data.

    DATA(lo_pop) = z2ui5_cl_pop_data=>factory( ls_data ).

    cl_abap_unit_assert=>assert_bound( lo_pop ).
    cl_abap_unit_assert=>assert_bound( lo_pop->mr_data ).
  ENDMETHOD.

  METHOD test_factory_title.
    TYPES:
      BEGIN OF ty_row,
        col TYPE string,
      END OF ty_row.
    DATA lt_tab TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.

    DATA(lo_pop) = z2ui5_cl_pop_data=>factory( val   = lt_tab
                                               title = `My Data` ).

    cl_abap_unit_assert=>assert_bound( lo_pop ).
  ENDMETHOD.

ENDCLASS.


CLASS ltcl_test_roundtrip DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_s_row,
        name  TYPE string,
        count TYPE i,
      END OF ty_s_row.
    TYPES ty_t_tab TYPE STANDARD TABLE OF ty_s_row WITH EMPTY KEY.

    DATA mo_action TYPE REF TO z2ui5_cl_core_action.
    DATA mi_client TYPE REF TO z2ui5_if_client.

    METHODS client_create
      IMPORTING
        io_app TYPE REF TO z2ui5_if_app.

    METHODS roundtrip_event
      IMPORTING
        io_app   TYPE REF TO z2ui5_if_app
        iv_event TYPE string.

    METHODS test_init_table_calls_popup  FOR TESTING RAISING cx_static_check.
    METHODS test_init_struct_calls_popup FOR TESTING RAISING cx_static_check.
    METHODS test_event_leaves            FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_test_roundtrip IMPLEMENTATION.

  METHOD client_create.

    mo_action = NEW #( NEW z2ui5_cl_core_handler( `` ) ).
    mo_action->mo_app->mo_app = io_app.
    mi_client = NEW z2ui5_cl_core_client( mo_action ).

  ENDMETHOD.

  METHOD roundtrip_event.

    client_create( io_app ).
    io_app->check_initialized = abap_true.
    mo_action->ms_actual-event = iv_event.
    io_app->main( mi_client ).

  ENDMETHOD.

  METHOD test_init_table_calls_popup.

    DATA(lt_tab) = VALUE ty_t_tab( ( name = `row1` count = 1 ) ).
    DATA(lo_pop) = z2ui5_cl_pop_data=>factory( val   = lt_tab
                                               title = `Data Title` ).
    client_create( lo_pop ).

    lo_pop->z2ui5_if_app~main( mi_client ).

    DATA(lo_table_pop) = CAST z2ui5_cl_pop_table( mo_action->ms_next-o_app_call ).
    cl_abap_unit_assert=>assert_bound( lo_table_pop ).

  ENDMETHOD.

  METHOD test_init_struct_calls_popup.

    DATA(ls_row) = VALUE ty_s_row( name  = `row1`
                                   count = 1 ).
    DATA(lo_pop) = z2ui5_cl_pop_data=>factory( ls_row ).
    client_create( lo_pop ).

    lo_pop->z2ui5_if_app~main( mi_client ).

    cl_abap_unit_assert=>assert_bound( mo_action->ms_next-o_app_call ).

  ENDMETHOD.

  METHOD test_event_leaves.

    DATA(lt_tab) = VALUE ty_t_tab( ( name = `row1` ) ).
    DATA(lo_pop) = z2ui5_cl_pop_data=>factory( lt_tab ).
    roundtrip_event( io_app   = lo_pop
                     iv_event = `ANY_EVENT` ).

    cl_abap_unit_assert=>assert_bound( mo_action->ms_next-o_app_leave ).

  ENDMETHOD.

ENDCLASS.
