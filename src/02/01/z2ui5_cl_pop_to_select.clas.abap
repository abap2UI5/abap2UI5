CLASS z2ui5_cl_pop_to_select DEFINITION
  PUBLIC FINAL
  CREATE PROTECTED.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    TYPES:
      BEGIN OF ty_s_result,
        row             TYPE REF TO data,
        table           TYPE REF TO data,
        check_confirmed TYPE abap_bool,
      END OF ty_s_result.

    DATA ms_result           TYPE ty_s_result.
    DATA mr_tab              TYPE REF TO data.
    DATA mr_tab_popup        TYPE REF TO data ##NEEDED.
    DATA mr_tab_popup_backup TYPE REF TO data ##NEEDED.

    CLASS-METHODS factory
      IMPORTING
        i_tab              TYPE STANDARD TABLE
        i_title            TYPE clike     OPTIONAL
        i_sort_field       TYPE clike     OPTIONAL
        i_descending       TYPE abap_bool OPTIONAL
        i_contentwidth     TYPE clike     OPTIONAL
        i_contentheight    TYPE clike     OPTIONAL
        i_growingthreshold TYPE clike     OPTIONAL
        i_multiselect      TYPE abap_bool OPTIONAL
        i_event_canceled   TYPE string    OPTIONAL
        i_event_confirmed  TYPE string    OPTIONAL
      RETURNING
        VALUE(r_result)    TYPE REF TO z2ui5_cl_pop_to_select.

    METHODS result
      RETURNING
        VALUE(result) TYPE ty_s_result.

  PROTECTED SECTION.
    DATA check_initialized TYPE abap_bool.
    DATA check_table_line  TYPE abap_bool.
    DATA client            TYPE REF TO z2ui5_if_client.
    DATA title             TYPE string.
    DATA sort_field        TYPE string.
    DATA content_width     TYPE string.
    DATA content_height    TYPE string.
    DATA growing_threshold TYPE string.
    DATA descending        TYPE abap_bool.
    DATA multiselect       TYPE abap_bool.
    DATA event_confirmed   TYPE string.
    DATA event_canceled    TYPE string.

    METHODS on_event.
    METHODS display.
    METHODS set_output_table.
    METHODS on_event_confirm.
    METHODS on_event_search.

  PRIVATE SECTION.
ENDCLASS.


CLASS z2ui5_cl_pop_to_select IMPLEMENTATION.

  METHOD factory.
      DATA temp1 TYPE string.

    CREATE OBJECT r_result.
    IF i_title IS INITIAL.
      
      IF i_multiselect = abap_true.
        temp1 = `Multi select`.
      ELSE.
        temp1 = `Single select`.
      ENDIF.
      r_result->title = temp1.
    ELSE.
      r_result->title = i_title.
    ENDIF.

    r_result->sort_field        = i_sort_field.
    r_result->descending        = i_descending.
    r_result->content_height    = i_contentheight.
    r_result->content_width     = i_contentwidth.
    r_result->growing_threshold = i_growingthreshold.
    r_result->multiselect       = i_multiselect.
    r_result->event_confirmed   = i_event_confirmed.
    r_result->event_canceled    = i_event_canceled.

    r_result->mr_tab            = z2ui5_cl_util=>conv_copy_ref_data( i_tab ).
    CREATE DATA r_result->ms_result-row LIKE LINE OF i_tab.
    CREATE DATA r_result->ms_result-table LIKE i_tab.

  ENDMETHOD.

  METHOD display.

    FIELD-SYMBOLS <tab_out> TYPE STANDARD TABLE.
    DATA popup TYPE REF TO z2ui5_cl_xml_view.
    DATA temp2 TYPE string_table.
    DATA temp1 TYPE string_table.
    DATA tab TYPE REF TO z2ui5_cl_xml_view.
    DATA lt_comp TYPE abap_component_tab.
    DATA list TYPE REF TO z2ui5_cl_xml_view.
    DATA cells TYPE REF TO z2ui5_cl_xml_view.
    DATA ls_comp LIKE LINE OF lt_comp.
    DATA columns TYPE REF TO z2ui5_cl_xml_view.
      DATA temp4 TYPE REF TO cl_abap_elemdescr.
      DATA temp5 TYPE z2ui5_cl_util_abap=>ty_s_data_element_text-medium.
      DATA data_element_name TYPE string.
      DATA medium_label TYPE z2ui5_cl_util_abap=>ty_s_data_element_text-medium.
      DATA text LIKE temp5.

    ASSIGN mr_tab_popup->* TO <tab_out>.

    
    popup = z2ui5_cl_xml_view=>factory_popup( ).
    
    CLEAR temp2.
    INSERT `${$parameters>/value}` INTO TABLE temp2.
    INSERT `${$parameters>/clearButtonPressed}` INTO TABLE temp2.
    
    CLEAR temp1.
    INSERT `${$parameters>/selectedContexts[0]/sPath}` INTO TABLE temp1.
    
    tab = popup->table_select_dialog(
        items            = |\{path:'|
                          && client->_bind_edit( val  = <tab_out>
                                                 path = abap_true )
                          && |', sorter : \{ path : '{ to_upper( sort_field ) }', descending : |
                          && z2ui5_cl_util=>boolean_abap_2_json( me->descending )
                          && | \} \}|
        cancel           = client->_event( 'CANCEL' )
        search           = client->_event(
                               val   = 'SEARCH'
                               t_arg = temp2 )
        confirm          = client->_event( val   = 'CONFIRM'
                                           t_arg = temp1 )
        growing          = abap_true
        contentwidth     = content_width
        contentheight    = content_height
        growingthreshold = growing_threshold
        title            = title
        multiselect      = multiselect ).

    
    lt_comp = z2ui5_cl_util=>rtti_get_t_attri_by_any( <tab_out> ).
    DELETE lt_comp WHERE name = 'ZZSELKZ'.

    
    list = tab->column_list_item( valign   = `Top`
                                        selected = `{ZZSELKZ}` ).
    
    cells = list->cells( ).

    
    LOOP AT lt_comp INTO ls_comp.
      cells->text( |\{{ ls_comp-name }\}| ).
    ENDLOOP.

    
    columns = tab->columns( ).
    LOOP AT lt_comp INTO ls_comp.
      
      temp4 ?= ls_comp-type.
      
      
      data_element_name = substring_after( val = temp4->absolute_name sub = '\TYPE=' ).
      
      medium_label = z2ui5_cl_util=>rtti_get_data_element_texts( data_element_name )-medium.
      IF medium_label IS NOT INITIAL.
        temp5 = medium_label.
      ELSE.
        temp5 = ls_comp-name.
      ENDIF.
      
      text = temp5.
      columns->column( '8rem' )->header( `` )->text( text ).
    ENDLOOP.

    client->popup_display( popup->stringify( ) ).

  ENDMETHOD.

  METHOD z2ui5_if_app~main.

    me->client = client.

    IF check_initialized = abap_false.
      check_initialized = abap_true.
      set_output_table( ).
      display( ).
      RETURN.
    ENDIF.

    on_event( ).

  ENDMETHOD.

  METHOD on_event.

    CASE client->get( )-event.

      WHEN 'CONFIRM'.
        ms_result-check_confirmed = abap_true.
        on_event_confirm( ).

      WHEN 'CANCEL'.
        client->popup_destroy( ).
        client->nav_app_leave( client->get_app( client->get( )-s_draft-id_prev_app_stack ) ).
        client->follow_up_action( client->_event( event_canceled ) ).

      WHEN 'SEARCH'.
        on_event_search( ).

    ENDCASE.

  ENDMETHOD.

  METHOD result.

    result = ms_result.

  ENDMETHOD.

  METHOD set_output_table.

    FIELD-SYMBOLS <row>      TYPE any.
    FIELD-SYMBOLS <row2>     TYPE any.
    FIELD-SYMBOLS <tab>      TYPE STANDARD TABLE.
    FIELD-SYMBOLS <tab_out>  TYPE STANDARD TABLE.
    FIELD-SYMBOLS <tab_out2> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <field>    TYPE any.
    DATA lr_row TYPE REF TO data.
    DATA lo_type TYPE REF TO cl_abap_typedescr.
    DATA temp5 TYPE REF TO cl_abap_tabledescr.
    DATA lo_table LIKE temp5.
        DATA temp6 TYPE REF TO cl_abap_structdescr.
        DATA lo_struct LIKE temp6.
        DATA lt_comp TYPE abap_component_tab.
        DATA temp7 TYPE REF TO cl_abap_elemdescr.
        DATA lo_elem LIKE temp7.
        DATA temp8 TYPE abap_componentdescr.
        DATA temp11 TYPE REF TO cl_abap_datadescr.
    DATA temp9 LIKE sy-subrc.
      DATA lo_type_bool TYPE REF TO cl_abap_typedescr.
      DATA temp10 TYPE abap_componentdescr.
      DATA temp12 TYPE REF TO cl_abap_datadescr.
    DATA lo_line_type TYPE REF TO cl_abap_structdescr.
    DATA lo_tab_type TYPE REF TO cl_abap_tabledescr.

    ASSIGN mr_tab->* TO <tab>.

    
    lo_type = cl_abap_structdescr=>describe_by_data( <tab> ).
    
    temp5 ?= lo_type.
    
    lo_table = temp5.
    TRY.
        
        temp6 ?= lo_table->get_table_line_type( ).
        
        lo_struct = temp6.
        
        lt_comp = lo_struct->get_components( ).
      CATCH cx_root.
        check_table_line = abap_true.
        
        temp7 ?= lo_table->get_table_line_type( ).
        
        lo_elem = temp7.
        
        CLEAR temp8.
        temp8-name = 'TAB_LINE'.
        
        temp11 ?= lo_elem.
        temp8-type = temp11.
        INSERT temp8 INTO TABLE lt_comp.
    ENDTRY.

    
    READ TABLE lt_comp WITH KEY name = `ZZSELKZ` TRANSPORTING NO FIELDS.
    temp9 = sy-subrc.
    IF NOT temp9 = 0.
      
      lo_type_bool = cl_abap_structdescr=>describe_by_name( 'ABAP_BOOL' ).
      
      CLEAR temp10.
      temp10-name = `ZZSELKZ`.
      
      temp12 ?= lo_type_bool.
      temp10-type = temp12.
      INSERT temp10 INTO TABLE lt_comp.
    ENDIF.

    
    lo_line_type = cl_abap_structdescr=>create( lt_comp ).
    
    lo_tab_type = cl_abap_tabledescr=>create( lo_line_type ).

    CREATE DATA mr_tab_popup TYPE HANDLE lo_tab_type.
    CREATE DATA mr_tab_popup_backup TYPE HANDLE lo_tab_type.

    ASSIGN mr_tab_popup->* TO <tab_out>.
    ASSIGN mr_tab_popup_backup->* TO <tab_out2>.
    LOOP AT <tab> ASSIGNING <row>.

      CREATE DATA lr_row LIKE LINE OF <tab_out>.
      ASSIGN lr_row->* TO <row2>.
      IF check_table_line = abap_true.
        ASSIGN lr_row->('TAB_LINE') TO <field>.
        ASSERT sy-subrc = 0.
        <field> = <row>.
      ELSE.
        MOVE-CORRESPONDING <row> TO <row2>.
      ENDIF.
      INSERT <row2> INTO TABLE <tab_out>.

    ENDLOOP.

    <tab_out2> = <tab_out>.

  ENDMETHOD.

  METHOD on_event_confirm.

    FIELD-SYMBOLS <tab>                 TYPE STANDARD TABLE.
    FIELD-SYMBOLS <row_selected>        TYPE any.
    FIELD-SYMBOLS <selkz>               TYPE any.
    FIELD-SYMBOLS <row_result>          TYPE any.
    FIELD-SYMBOLS <table_result>        TYPE ANY TABLE.
    FIELD-SYMBOLS <table_line_selected> TYPE any.

    ASSIGN mr_tab_popup->* TO <tab>.
    ASSIGN ms_result-table->* TO <table_result>.

    LOOP AT <tab> ASSIGNING <row_selected>.

      ASSIGN ('<ROW_SELECTED>-ZZSELKZ') TO <selkz>.
      ASSERT sy-subrc = 0.
      IF <selkz> = abap_false.
        CONTINUE.
      ENDIF.

      ASSIGN ms_result-row->* TO <row_result>.
      IF check_table_line = abap_true.
        ASSIGN ('<ROW_SELECTED>-TAB_LINE') TO <table_line_selected>.
        ASSERT sy-subrc = 0.
        <row_result> = <table_line_selected>.
      ELSE.
        MOVE-CORRESPONDING <row_selected> TO <row_result>.
      ENDIF.

      INSERT <row_result> INTO TABLE <table_result>.
      IF multiselect = abap_false.
        EXIT.
      ELSE.
        CLEAR <row_result>.
      ENDIF.

    ENDLOOP.

    client->popup_destroy( ).
    client->nav_app_leave( client->get_app( client->get( )-s_draft-id_prev_app_stack ) ).
    client->follow_up_action( client->_event( val    = event_confirmed
                                              r_data = <table_result> ) ).

  ENDMETHOD.

  METHOD on_event_search.

    FIELD-SYMBOLS <tab_out>        TYPE STANDARD TABLE.
    FIELD-SYMBOLS <tab_out_backup> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <row2>           TYPE any.
    FIELD-SYMBOLS <field2>         TYPE any.

    DATA lt_arg TYPE string_table.
    DATA ls_arg TYPE string.
    DATA lt_comp TYPE abap_component_tab.
      DATA lv_check_continue LIKE abap_false.
      DATA ls_comp LIKE LINE OF lt_comp.
        DATA lv_assign TYPE string.
    lt_arg = client->get( )-t_event_arg.
    
    READ TABLE lt_arg INTO ls_arg INDEX 1.
    ASSERT sy-subrc = 0.

    ASSIGN mr_tab_popup->* TO <tab_out>.
    ASSIGN mr_tab_popup_backup->* TO <tab_out_backup>.

    <tab_out> = <tab_out_backup>.

    
    lt_comp = z2ui5_cl_util=>rtti_get_t_attri_by_any( <tab_out> ).
    LOOP AT <tab_out> ASSIGNING <row2>.
      
      lv_check_continue = abap_false.
      
      LOOP AT lt_comp INTO ls_comp.
        
        lv_assign = |<ROW2>-{ ls_comp-name }|.
        ASSIGN (lv_assign) TO <field2>.
        ASSERT sy-subrc = 0.
        IF to_upper( <field2> ) CS to_upper( ls_arg ).
          lv_check_continue = abap_true.
          EXIT.
        ENDIF.
      ENDLOOP.
      IF lv_check_continue = abap_true.
        CONTINUE.
      ENDIF.
      DELETE <tab_out>.
    ENDLOOP.
    client->popup_model_update( ).

  ENDMETHOD.

ENDCLASS.
