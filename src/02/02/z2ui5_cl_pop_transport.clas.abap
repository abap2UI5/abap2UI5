CLASS z2ui5_cl_pop_transport DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    INTERFACES if_serializable_object.
    INTERFACES z2ui5_if_app.

    TYPES trobj_name     TYPE c LENGTH 120.
    TYPES sxco_transport TYPE c LENGTH 20.

    TYPES: BEGIN OF ty_s_data,
             short_description TYPE string,
             transport         TYPE sxco_transport,
             task              TYPE sxco_transport,
             selkz             TYPE abap_bool,
           END OF ty_s_data.

    DATA client  TYPE REF TO z2ui5_if_client.
    DATA mv_init TYPE abap_bool.
    DATA ms_transport TYPE ty_s_data.

    CLASS-DATA mt_data TYPE STANDARD TABLE OF ty_s_data WITH EMPTY KEY.

    CLASS-METHODS factory
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_pop_transport.

    CLASS-METHODS add_DATA_to_tranport
      IMPORTING
        ir_data      TYPE REF TO datA
        iv_tabname   TYPE string
        is_transport TYPE ty_s_data.

  PROTECTED SECTION.

    CLASS-METHODS add_to_transport_onprem
      IMPORTING
        ir_data      TYPE REF TO datA
        iv_tabname   TYPE string
        is_transport TYPE ty_s_data.

    CLASS-METHODS get_tr_onprem.

    CLASS-METHODS set_e071k
      IMPORTING
        ir_data       TYPE REF TO datA
        iv_tabname    TYPE string
        is_transport  TYPE ty_s_data
      RETURNING
        VALUE(result) TYPE REF TO data.

    CLASS-METHODS set_e071
      IMPORTING
        iv_tabname    TYPE string
        is_transport  TYPE ty_s_data
      RETURNING
        VALUE(result) TYPE REF TO data.

    CLASS-METHODS get_e071k_tabkey
      IMPORTING
        !line            TYPE any
        dfies            TYPE z2ui5_cl_stmpncfctn_api=>ty_t_dfies
      RETURNING
        VALUE(rv_tabkey) TYPE trobj_name.

    CLASS-METHODS read_e070.

    METHODS on_init.

    METHODS render_view.

    METHODS on_event.

    METHODS get_tr_cloud.

  PRIVATE SECTION.

ENDCLASS.


CLASS z2ui5_cl_pop_transport IMPLEMENTATION.

  METHOD z2ui5_if_app~main.
    me->client = client.

    IF mv_init = abap_false.
      mv_init = abap_true.

      on_init( ).

      render_view( ).

    ENDIF.

    on_event( ).

    client->view_model_update( ).
  ENDMETHOD.

  METHOD on_init.

    IF z2ui5_cl_util_api=>rtti_check_lang_version_cloud( ) = abap_true.
      get_tr_cloud( ).
    ELSE.
      get_tr_onprem( ).
    ENDIF.

  ENDMETHOD.

  METHOD render_view.
    DATA(popup) = z2ui5_cl_xml_view=>factory_popup( ).

    popup->dialog( contentWidth = '40%'
                   afterclose   = client->_event( 'CLOSE' )
    )->table( mode  = 'SingleSelectLeft'
              items = client->_bind_edit( mt_data )
        )->columns(
            )->column( )->text( 'Transport' )->get_parent(
            )->column( )->text( 'Description' )->get_parent(
                )->get_parent(
        )->items(
            )->column_list_item( selected = '{SELKZ}'
                )->cells(
                    )->text( '{TRANSPORT}'
                    )->text( '{SHORT_DESCRIPTION}'
    )->get_parent( )->get_parent( )->get_parent( )->get_parent(
    )->buttons( )->button( text  = 'Select'
                           press = client->_event( 'TRANSPORT_SELECT' )
                           type  = 'Emphasized' ).

    client->popup_display( popup->stringify( ) ).
  ENDMETHOD.

  METHOD on_event.
    CASE client->get( )-event.

      WHEN `CLOSE`.

        CLEAR ms_transport.

        client->popup_destroy( ).

        client->nav_app_leave( client->get_app( client->get( )-s_draft-id_prev_app_stack ) ).

      WHEN `TRANSPORT_SELECT`.

        READ TABLE mt_data INTO DATA(line) WITH KEY selkz = abap_true.
        IF sy-subrc = 0.
          ms_transport = line.
        ENDIF.

        client->popup_destroy( ).

        client->nav_app_leave( client->get_app( client->get( )-s_draft-id_prev_app_stack ) ).

      WHEN OTHERS.

    ENDCASE.
  ENDMETHOD.

  METHOD factory.
    result = NEW #( ).
  ENDMETHOD.

  METHOD add_DATA_to_tranport.

    IF z2ui5_cl_util_api=>rtti_check_lang_version_cloud( ) = abap_false.
*      add_to_transport_cloud( ir_data      = ir_data
*                              iv_tabname   = iv_tabname
*                              is_transport = is_transport ).
*    ELSE.
      add_to_transport_onprem( ir_data      = ir_data
                               iv_tabname   = iv_tabname
                               is_transport = is_transport ).
    ENDIF.

  ENDMETHOD.

  METHOD get_e071k_tabkey.

    DATA lv_type       TYPE c LENGTH 1.
    DATA lv_tabkey     TYPE c LENGTH 999.
    DATA lv_tabkey_len TYPE i.
    DATA lv_field_len  TYPE i.
    DATA lv_offset     TYPE i.

    LOOP AT dfies INTO DATA(s_dfies) WHERE keyflag = abap_true.

      ASSIGN COMPONENT s_dfies-fieldname OF STRUCTURE line TO FIELD-SYMBOL(<value>).
      IF <value> IS NOT ASSIGNED.
        CONTINUE.
      ENDIF.

      lv_type = cl_abap_typedescr=>describe_by_data( <value> )->type_kind.

      IF lv_type NA 'CDNT'.
        lv_tabkey+lv_tabkey_len = '*'.
        rv_tabkey = lv_tabkey.
        RETURN.
      ELSE.
        lv_field_len = cl_abap_typedescr=>describe_by_data( <value> )->length / cl_abap_char_utilities=>charsize.
      ENDIF.

      lv_field_len = cl_abap_typedescr=>describe_by_data( <value> )->length / cl_abap_char_utilities=>charsize.
      lv_tabkey+lv_tabkey_len(lv_field_len) = <value>.
      lv_tabkey_len = lv_tabkey_len + lv_field_len.

    ENDLOOP.

    IF lv_tabkey_len > 119.

      IF lv_tabkey CS '_'.
        lv_offset = sy-fdpos.
        lv_tabkey+lv_offset = '*'.
      ELSE.
        lv_tabkey+119 = '*'.
      ENDIF.

    ENDIF.
    rv_tabkey = lv_tabkey.
  ENDMETHOD.

  METHOD add_to_transport_onprem.

    FIELD-SYMBOLS <t_e071k> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <t_e071>  TYPE STANDARD TABLE.

    DATA(r_e071k) = set_e071k( ir_data      = ir_data
                               iv_tabname   = iv_tabname
                               is_transport = is_transport ).

    DATA(r_e071) = set_e071( iv_tabname   = iv_tabname
                             is_transport = is_transport ).

    ASSIGN r_e071k->* TO <t_e071k>.
    ASSIGN r_e071->* TO <t_e071>.

    DATA(fb1) = 'TR_APPEND_TO_COMM_OBJS_KEYS'.

    CALL FUNCTION fb1
      EXPORTING  wi_trkorr = is_transport-task
      TABLES     wt_e071   = <t_e071>
                 wt_e071k  = <t_e071k>
      EXCEPTIONS OTHERS    = 1.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    DATA(fb2) = 'TR_SORT_AND_COMPRESS_COMM'.

    CALL FUNCTION fb2
      EXPORTING  iv_trkorr = is_transport-task
      EXCEPTIONS OTHERS    = 1.
    IF sy-subrc <> 0.
      RETURN.
    ELSE.
      COMMIT WORK AND WAIT.
    ENDIF.

  ENDMETHOD.

  METHOD get_tr_cloud.

*    DATA(lo_current_user) = xco_cp=>sy->user( ).
*
*    DATA(lo_kind_filter) = xco_cp_transport=>filter->kind( xco_cp_transport=>kind->task ).
*    DATA(lo_owner_filter) = xco_cp_transport=>filter->owner( xco_cp_abap_sql=>constraint->equal( lo_current_user->name ) ).
*    DATA(lo_status_filter) = xco_cp_transport=>filter->status( xco_cp_transport=>status->modifiable ).
*    DATA(lo_type_filter) = xco_cp_transport=>filter->type( io_type = xco_cp_transport=>type->customizing_task ).
*    DATA(lt_transports) = xco_cp_cts=>transports->where( VALUE #( ( lo_kind_filter )
*                                                                  ( lo_owner_filter )
*                                                                  ( lo_status_filter )
*                                                                  ( lo_type_filter ) )
*    )->resolve( xco_cp_transport=>resolution->request ).
*
*    LOOP AT lt_transports INTO DATA(lo_transport).
*      DATA(lo_transport_request) = lo_transport->get_request( ).
*
*      DATA(prop) = lo_transport_request->properties( )->get( ).
*
*      DATA(tasks) = lo_transport_request->get_tasks( ).
*
*      LOOP AT tasks INTO DATA(task).
*
*        IF lo_current_user->name = task->properties( )->get_owner( )->name.
*
*          DATA(data) = VALUE ty_s_data( short_description = prop-short_description
*                                        transport         = lo_transport_request->value
*                                        task              = task->value ).
*          APPEND data TO mt_data.
*
*        ENDIF.
*
*      ENDLOOP.
*
*    ENDLOOP.

  ENDMETHOD.

  METHOD get_tr_onprem.

    DATA lo_tab  TYPE REF TO data.
    DATA lo_line TYPE REF TO data.

    FIELD-SYMBOLS <table> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <line>  TYPE any.
    FIELD-SYMBOLS <value> TYPE any.

    read_e070( ).

    DATA(table_name) = 'E07T'.

    TRY.
        DATA(t_comp) = z2ui5_cl_util_api=>rtti_get_t_attri_by_table_name( table_name ).

        DATA(new_struct_desc) = cl_abap_structdescr=>create( t_comp ).

        DATA(new_table_desc) = cl_abap_tabledescr=>create( p_line_type  = new_struct_desc
                                                           p_table_kind = cl_abap_tabledescr=>tablekind_std ).

        CREATE DATA lo_tab TYPE HANDLE new_table_desc.
        CREATE DATA lo_line TYPE HANDLE new_struct_desc.

        ASSIGN lo_tab->* TO <table>.
        ASSIGN lo_line->* TO <line>.

        DATA(index) = 0.

        LOOP AT mt_data INTO DATA(line).
          index = index + 1.
          IF index = 1.
            DATA(where) = |TRKORR EQ '{ line-task }'|.
          ELSE.
            where = |{ where }OR TRKORR EQ '{ line-task }'|.
          ENDIF.
          where = |( { where } )|.
        ENDLOOP.

        SELECT trkorr,
               langu,
               as4text
          FROM (table_name)
          WHERE (where)
          INTO TABLE @<table>.
        IF sy-subrc <> 0.
          RETURN.
        ENDIF.

      CATCH cx_root.
    ENDTRY.

    LOOP AT <table> INTO <line>.

      ASSIGN COMPONENT 'TRKORR' OF STRUCTURE <line> TO <value>.
      IF <value> IS NOT ASSIGNED.
        CONTINUE.
      ELSE.

        READ TABLE mt_data REFERENCE INTO DATA(data) WITH KEY task = <value>.
        IF sy-subrc = 0.

          ASSIGN COMPONENT 'AS4TEXT' OF STRUCTURE <line> TO <value>.
          IF <value> IS NOT ASSIGNED.
            CONTINUE.
          ELSE.

            data->short_description = <value>.

          ENDIF.

        ENDIF.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD set_e071k.

    DATA t_e071k TYPE REF TO data.
    DATA s_e071k TYPE REF TO data.

    FIELD-SYMBOLS <t_e071k> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <s_e071k> TYPE any.
    FIELD-SYMBOLS <value>   TYPE any.
    FIELD-SYMBOLS <tab>     TYPE STANDARD TABLE.
    FIELD-SYMBOLS <line>    TYPE any.

    DATA(t_comp) = z2ui5_cl_util_api=>rtti_get_t_attri_by_table_name( 'E071K' ).

    TRY.

        DATA(struct_desc) = cl_abap_structdescr=>create( t_comp ).

        DATA(table_desc) = cl_abap_tabledescr=>create( p_line_type  = struct_desc
                                                       p_table_kind = cl_abap_tabledescr=>tablekind_std ).

        CREATE DATA t_e071k TYPE HANDLE table_desc.
        CREATE DATA s_e071k TYPE HANDLE struct_desc.

        ASSIGN t_e071k->* TO <t_e071k>.
        ASSIGN s_e071k->* TO <s_e071k>.

      CATCH cx_root.

    ENDTRY.

    DATA(dfies) = z2ui5_cl_util_api=>rtti_get_t_dfies_by_table_name( iv_tabname ).

*   is_transport-transport = assign_value( component = 'TRKORR'
*                                          structure = <s_e071k> ).                                         )

    ASSIGN COMPONENT 'TRKORR' OF STRUCTURE <s_e071k> TO <value>.
    IF <value> IS NOT ASSIGNED.
      RETURN.
    ELSE.
      <value> = is_transport-transport.
    ENDIF.
    UNASSIGN <value>.
    ASSIGN COMPONENT 'PGMID' OF STRUCTURE <s_e071k> TO <value>.
    IF <value> IS NOT ASSIGNED.
      RETURN.
    ELSE.
      <value> = 'R3TR'.
    ENDIF.
    UNASSIGN <value>.
    ASSIGN COMPONENT 'MASTERTYPE' OF STRUCTURE <s_e071k> TO <value>.
    IF <value> IS NOT ASSIGNED.
      RETURN.
    ELSE.
      <value> = 'TABU'.
    ENDIF.
    UNASSIGN <value>.
    ASSIGN COMPONENT 'OBJECT' OF STRUCTURE <s_e071k> TO <value>.
    IF <value> IS NOT ASSIGNED.
      RETURN.
    ELSE.
      <value> = 'TABU'.
    ENDIF.
    UNASSIGN <value>.
    ASSIGN COMPONENT 'MASTERNAME' OF STRUCTURE <s_e071k> TO <value>.
    IF <value> IS NOT ASSIGNED.
      RETURN.
    ELSE.
      <value> = iv_tabname.
    ENDIF.
    UNASSIGN <value>.
    ASSIGN COMPONENT 'OBJNAME' OF STRUCTURE <s_e071k> TO <value>.
    IF <value> IS NOT ASSIGNED.
      RETURN.
    ELSE.
      <value> = iv_tabname.
    ENDIF.
    UNASSIGN <value>.

    ASSIGN iR_data->* TO <tab>.

    IF <tab> IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT <tab> ASSIGNING <line>.

      ASSIGN COMPONENT 'TABKEY' OF STRUCTURE <s_e071k> TO <value>.
      IF <value> IS NOT ASSIGNED.
        RETURN.
      ELSE.
        <value> = get_e071k_tabkey( dfies = dfies
                                    line  = <line> ).
      ENDIF.

      APPEND <s_e071k> TO <t_e071k>.

    ENDLOOP.

    result = t_e071k.

  ENDMETHOD.

  METHOD set_e071.

    DATA t_e071 TYPE REF TO data.
    DATA s_e071 TYPE REF TO data.

    FIELD-SYMBOLS <t_e071> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <s_e071> TYPE any.
    FIELD-SYMBOLS <value>  TYPE any.

    DATA(t_comp) = z2ui5_cl_util_api=>rtti_get_t_attri_by_table_name( 'E071' ).

    TRY.

        DATA(struct_desc_new) = cl_abap_structdescr=>create( t_comp ).

        DATA(table_desc_new) = cl_abap_tabledescr=>create( p_line_type  = struct_desc_new
                                                           p_table_kind = cl_abap_tabledescr=>tablekind_std ).

        CREATE DATA t_e071 TYPE HANDLE table_desc_new.
        CREATE DATA s_e071 TYPE HANDLE struct_desc_new.

        ASSIGN t_e071->* TO <t_e071>.
        ASSIGN s_e071->* TO <s_e071>.

      CATCH cx_root.

    ENDTRY.

    ASSIGN COMPONENT 'TRKORR' OF STRUCTURE <s_e071> TO <value>.
    IF <value> IS NOT ASSIGNED.
      RETURN.
    ELSE.
      <value> = is_transport-transport.
    ENDIF.
    UNASSIGN <value>.
    ASSIGN COMPONENT 'PGMID' OF STRUCTURE <s_e071> TO <value>.
    IF <value> IS NOT ASSIGNED.
      RETURN.
    ELSE.
      <value> = 'R3TR'.
    ENDIF.
    UNASSIGN <value>.
    ASSIGN COMPONENT 'OBJECT' OF STRUCTURE <s_e071> TO <value>.
    IF <value> IS NOT ASSIGNED.
      RETURN.
    ELSE.
      <value> = 'TABU'.
    ENDIF.
    UNASSIGN <value>.
    ASSIGN COMPONENT 'OBJ_NAME' OF STRUCTURE <s_e071> TO <value>.
    IF <value> IS NOT ASSIGNED.
      RETURN.
    ELSE.
      <value> = iv_tabname.
    ENDIF.
    UNASSIGN <value>.
    ASSIGN COMPONENT 'OBJFUNC' OF STRUCTURE <s_e071> TO <value>.
    IF <value> IS NOT ASSIGNED.
      RETURN.
    ELSE.
      <value> = 'K'.
    ENDIF.
    UNASSIGN <value>.

    APPEND <s_e071> TO <t_e071>.

    result = t_e071.

  ENDMETHOD.

  METHOD read_e070.

    DATA lo_tab  TYPE REF TO data.
    DATA lo_line TYPE REF TO data.
    DATA ls_data TYPE ty_s_data.

    FIELD-SYMBOLS <table> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <line>  TYPE any.
    FIELD-SYMBOLS <value> TYPE any.

    DATA(table_name) = 'E070'.

    TRY.
        DATA(t_comp) = z2ui5_cl_util_api=>rtti_get_t_attri_by_table_name( table_name ).

        DATA(new_struct_desc) = cl_abap_structdescr=>create( t_comp ).

        DATA(new_table_desc) = cl_abap_tabledescr=>create( p_line_type  = new_struct_desc
                                                           p_table_kind = cl_abap_tabledescr=>tablekind_std ).

        CREATE DATA lo_tab TYPE HANDLE new_table_desc.
        CREATE DATA lo_line TYPE HANDLE new_struct_desc.

        ASSIGN lo_tab->* TO <table>.
        ASSIGN lo_line->* TO <line>.

        DATA(where) =
        |( TRFUNCTION EQ 'Q' ) AND ( TRSTATUS EQ 'D' ) AND ( KORRDEV EQ 'CUST' ) AND ( AS4USER EQ '{ sy-uname }' )|.

        SELECT trkorr,
               trfunction,
               trstatus,
               tarsystem,
               korrdev,
               as4user,
               as4date,
               as4time,
               strkorr
          FROM (table_name)
          WHERE (where)
          INTO TABLE @<table>.
        IF sy-subrc <> 0.
          RETURN.
        ENDIF.
      CATCH cx_root.
    ENDTRY.

    LOOP AT <table> INTO <line>.

      ASSIGN COMPONENT 'TRKORR' OF STRUCTURE <line> TO <value>.
      IF <value> IS NOT ASSIGNED.
        CONTINUE.
      ELSE.
        ls_data-transport = <value>.
      ENDIF.

      UNASSIGN <value>.

      ASSIGN COMPONENT 'STRKORR' OF STRUCTURE <line> TO <value>.
      IF <value> IS NOT ASSIGNED.
        CONTINUE.
      ELSE.
        ls_data-task = <value>.
      ENDIF.

      UNASSIGN <value>.

      APPEND ls_data TO mt_data.

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
