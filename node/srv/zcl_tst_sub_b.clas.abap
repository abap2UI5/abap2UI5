CLASS zcl_tst_sub_b DEFINITION PUBLIC.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    TYPES:
      BEGIN OF ty_s_row,
        carrid TYPE string,
        connid TYPE string,
      END OF ty_s_row.

    " the same embedding contract as zcl_tst_sub_a, with OTHER attribute
    " names (sample 342 next to 339): after a tab switch the rows the host
    " dissolved for the other class resolve to nothing on this one
    DATA mv_view_display TYPE abap_bool.
    DATA mv_init         TYPE abap_bool.
    DATA mo_parent_page  TYPE REF TO z2ui5_cl_ui5_view_builder.
    DATA mv_table        TYPE string.

    DATA mt_data     TYPE REF TO data.
    DATA mt_data_tmp TYPE REF TO data.
    DATA mo_lay      TYPE REF TO zcl_tst_layout.

    METHODS set_app_data
      IMPORTING
        table TYPE string.

  PROTECTED SECTION.
    METHODS on_event
      IMPORTING
        client TYPE REF TO z2ui5_if_client.
    METHODS render_main
      IMPORTING
        client TYPE REF TO z2ui5_if_client.
    METHODS get_data.
  PRIVATE SECTION.
ENDCLASS.


CLASS zcl_tst_sub_b IMPLEMENTATION.

  METHOD set_app_data.
    mv_table = table.
  ENDMETHOD.

  METHOD get_data.

    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <row> TYPE any.
    DATA ls_row   TYPE ty_s_row.
    DATA lv_selkz TYPE abap_bool.
    DATA lt_comp  TYPE abap_component_tab.
    DATA lo_line  TYPE REF TO cl_abap_structdescr.
    DATA lo_tab   TYPE REF TO cl_abap_tabledescr.

    lo_line ?= cl_abap_typedescr=>describe_by_data( ls_row ).
    lt_comp = lo_line->get_components( ).
    APPEND VALUE #( name = `SELKZ`
                    type = CAST #( cl_abap_datadescr=>describe_by_data( lv_selkz ) ) ) TO lt_comp.
    lo_tab = cl_abap_tabledescr=>create( p_line_type  = cl_abap_structdescr=>create( lt_comp )
                                         p_table_kind = cl_abap_tabledescr=>tablekind_std ).

    CREATE DATA mt_data TYPE HANDLE lo_tab.
    ASSIGN mt_data->* TO <tab>.
    ls_row = VALUE #( carrid = `b-1` connid = `0001` ).
    APPEND INITIAL LINE TO <tab> ASSIGNING <row>.
    MOVE-CORRESPONDING ls_row TO <row>.
    ls_row = VALUE #( carrid = `b-2` connid = `0002` ).
    APPEND INITIAL LINE TO <tab> ASSIGNING <row>.
    MOVE-CORRESPONDING ls_row TO <row>.

    mt_data_tmp = mt_data.

  ENDMETHOD.

  METHOD on_event.

    DATA lo_popup TYPE REF TO zcl_tst_popup_app.

    CASE client->get_event( ).
      WHEN `SELECTION_CHANGE`.
        CREATE OBJECT lo_popup.
        lo_popup->ms_data_row = VALUE #( app   = `SUB_B`
                                         class = `ZCL_TST_SUB_B`
                                         descr = `from sub-app b` ).
        client->nav_app_call( lo_popup ).
    ENDCASE.

  ENDMETHOD.

  METHOD render_main.

    FIELD-SYMBOLS <table> TYPE STANDARD TABLE.
    DATA page    TYPE REF TO z2ui5_cl_ui5_view_builder.
    DATA table   TYPE REF TO z2ui5_cl_ui5_view_builder.
    DATA columns TYPE REF TO z2ui5_cl_ui5_view_builder.
    DATA cells   TYPE REF TO z2ui5_cl_ui5_view_builder.
    DATA lv_index TYPE i.

    IF mo_parent_page IS INITIAL.
      page = z2ui5_cl_ui5_view_builder=>factory(
          )->ele( n = `View` ns = `mvc`
              )->a( n = `displayBlock` v = `true`
              )->a( n = `xmlns`        v = `sap.m`
              )->a( n = `xmlns:mvc`    v = `sap.ui.core.mvc` ).
    ELSE.
      page = mo_parent_page.
    ENDIF.

    mo_lay = zcl_tst_layout=>factory( i_data   = mt_data
                                      vis_cols = 2 ).
    ASSIGN mt_data->* TO <table>.

    table = page->ele( `Table`
        )->a( n = `items`           v = client->_bind( val = <table> )
        )->a( n = `mode`            v = `SingleSelectLeft`
        )->a( n = `selectionChange` v = client->_event( `SELECTION_CHANGE` ) ).

    columns = table->ele( `columns` ).
    LOOP AT mo_lay->ms_data-t_layout REFERENCE INTO DATA(layout).
      lv_index = sy-tabix.
      columns->ele( `Column`
          )->a( n = `visible` v = client->_bind( val       = layout->visible
                                                tab       = mo_lay->ms_data-t_layout
                                                tab_index = lv_index )
          )->tag( `Text`
              )->a( n = `text` v = layout->name ).
    ENDLOOP.

    cells = table->ele( `items`
        )->ele( `ColumnListItem`
            " abap2ui5lint-disable-next-line relative-binding-without-context -- SELKZ exists at runtime only
            )->a( n = `selected` v = `{SELKZ}`
            )->ele( `cells` ).
    LOOP AT mo_lay->ms_data-t_layout REFERENCE INTO layout.
      cells->tag( `Text`
          )->a( n = `text` v = |\{{ layout->name }\}| ).
    ENDLOOP.

    IF mo_parent_page IS INITIAL.
      client->view_display( page->stringify( ) ).
    ELSE.
      mv_view_display = abap_true.
    ENDIF.

  ENDMETHOD.

  METHOD z2ui5_if_app~main.

    " an init flag of its own, not check_on_init( ): the host creates a NEW
    " instance on every tab switch, in an event roundtrip where the
    " framework's init question was answered long ago (sample 342, where
    " 339 hangs its get_data( ) on check_on_init and stays empty after a
    " switch)
    " abap2ui5lint-disable-next-line manual-init-flag -- check_on_init( ) answers for the host's draft, not for this instance
    IF mv_init = abap_false.
      mv_init = abap_true.
      get_data( ).
      render_main( client ).
    ELSEIF client->check_on_navigated( ).
      render_main( client ).
    ENDIF.

    IF mo_lay->mr_data <> mt_data OR mt_data_tmp <> mt_data.
      client->message_toast_display( `ERROR - sub-app b: references diverged` ).
    ENDIF.

    on_event( client ).

  ENDMETHOD.

ENDCLASS.
