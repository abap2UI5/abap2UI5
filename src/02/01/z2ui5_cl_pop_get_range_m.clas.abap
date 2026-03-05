CLASS z2ui5_cl_pop_get_range_m DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    CLASS-METHODS factory
      IMPORTING
        val             TYPE z2ui5_cl_util=>ty_t_filter_multi
      RETURNING
        VALUE(r_result) TYPE REF TO z2ui5_cl_pop_get_range_m.

    TYPES:
      BEGIN OF ty_s_result,
        t_filter        TYPE z2ui5_cl_util=>ty_t_filter_multi,
        check_confirmed TYPE abap_bool,
      END OF ty_s_result.

    DATA ms_result TYPE ty_s_result.

    METHODS result
      RETURNING
        VALUE(result) TYPE ty_s_result.

  PROTECTED SECTION.
    DATA client        TYPE REF TO z2ui5_if_client.
    DATA mv_popup_name TYPE LINE OF string_table.

    METHODS popup_display.

    METHODS init.

  PRIVATE SECTION.
ENDCLASS.


CLASS z2ui5_cl_pop_get_range_m IMPLEMENTATION.

  METHOD factory.

    CREATE OBJECT r_result.
    r_result->ms_result-t_filter = val.

  ENDMETHOD.

  METHOD init.

    popup_display( ).

  ENDMETHOD.

  METHOD popup_display.

    DATA lo_popup TYPE REF TO z2ui5_cl_xml_view.
    DATA vbox TYPE REF TO z2ui5_cl_xml_view.
    DATA item TYPE REF TO z2ui5_cl_xml_view.
    DATA grid TYPE REF TO z2ui5_cl_xml_view.
    DATA temp5 TYPE string_table.
    DATA temp7 TYPE string_table.
    DATA temp9 TYPE string_table.
    lo_popup = z2ui5_cl_xml_view=>factory_popup( ).
    lo_popup = lo_popup->dialog( afterclose    = client->_event( `BUTTON_CANCEL` )
                                 contentheight = `50%`
                                 contentwidth  = `50%`
                                 title         = `Define Filter Conditons` ).

    
    vbox = lo_popup->vbox( height         = `100%`
                                 justifycontent = `SpaceBetween` ).

    
    item = vbox->list( nodata          = `no conditions defined`
                             items           = client->_bind( ms_result-t_filter )
                             selectionchange = client->_event( `SELCHANGE` )
                )->custom_list_item( ).

    
    grid = item->grid( class = `sapUiSmallMarginTop sapUiSmallMarginBottom sapUiSmallMarginBegin` ).
    grid->text( `{NAME}` ).

    
    CLEAR temp5.
    INSERT `${NAME}` INTO TABLE temp5.
    grid->multi_input( tokens           = `{T_TOKEN}`
                       enabled          = abap_false
                       valuehelprequest = client->_event( val   = `LIST_OPEN`
                                                          t_arg = temp5 )
            )->tokens(
                 )->token( key      = `{KEY}`
                           text     = `{TEXT}`
                           visible  = `{VISIBLE}`
                           selected = `{SELKZ}`
                           editable = `{EDITABLE}` ).

    
    CLEAR temp7.
    INSERT `${NAME}` INTO TABLE temp7.
    grid->button( text  = `Select`
                  press = client->_event( val   = `LIST_OPEN`
                                          t_arg = temp7 ) ).
    
    CLEAR temp9.
    INSERT `${NAME}` INTO TABLE temp9.
    grid->button( icon  = `sap-icon://delete`
                  type  = `Transparent`
                  text  = `Clear`
                  press = client->_event( val   = `LIST_DELETE`
                                          t_arg = temp9 ) ).

    lo_popup->buttons(
        )->button( text  = `Clear All`
                   icon  = `sap-icon://delete`
                   type  = `Transparent`
                   press = client->_event( val = `POPUP_DELETE_ALL` )
       )->button( text  = `Cancel`
                  press = client->_event( `BUTTON_CANCEL` )
       )->button( text  = `OK`
                  press = client->_event( `BUTTON_CONFIRM` )
                  type  = `Emphasized` ).

    client->popup_display( lo_popup->stringify( ) ).
  ENDMETHOD.

  METHOD result.
    result = ms_result.
  ENDMETHOD.

  METHOD z2ui5_if_app~main.
      DATA temp11 TYPE REF TO z2ui5_cl_pop_get_range.
      DATA lo_popup LIKE temp11.
        FIELD-SYMBOLS <tab> TYPE z2ui5_cl_util=>ty_s_filter_multi.
        DATA lt_event TYPE string_table.
        DATA temp5 LIKE LINE OF lt_event.
        DATA temp6 LIKE sy-tabix.
        DATA temp12 LIKE LINE OF lt_event.
        DATA temp13 LIKE sy-tabix.
        DATA ls_sql TYPE z2ui5_cl_util=>ty_s_filter_multi.
        DATA temp7 LIKE LINE OF ms_result-t_filter.
        DATA temp8 LIKE sy-tabix.
        DATA temp14 LIKE LINE OF ms_result-t_filter.
        DATA lr_sql LIKE REF TO temp14.
    me->client = client.

    IF client->check_on_init( ) IS NOT INITIAL.
      init( ).
      RETURN.
    ENDIF.

    IF client->get( )-check_on_navigated = abap_true.

      
      temp11 ?= client->get_app( client->get( )-s_draft-id_prev_app ).
      
      lo_popup = temp11.
      IF lo_popup->result( )-check_confirmed = abap_true.
        
        READ TABLE ms_result-t_filter WITH KEY name = mv_popup_name ASSIGNING <tab>.
        <tab>-t_range = lo_popup->result( )-t_range.
        <tab>-t_token = z2ui5_cl_util=>filter_get_token_t_by_range_t( <tab>-t_range ).
      ENDIF.
      popup_display( ).

    ENDIF.

    CASE client->get( )-event.

      WHEN `LIST_DELETE`.
        
        lt_event = client->get( )-t_event_arg.
        
        
        temp6 = sy-tabix.
        READ TABLE lt_event INDEX 1 INTO temp5.
        sy-tabix = temp6.
        IF sy-subrc <> 0.
          ASSERT 1 = 0.
        ENDIF.
        READ TABLE ms_result-t_filter WITH KEY name = temp5 ASSIGNING <tab>.
        CLEAR <tab>-t_token.
        CLEAR <tab>-t_range.
        client->popup_model_update( ).

      WHEN `LIST_OPEN`.
        lt_event = client->get( )-t_event_arg.
        
        
        temp13 = sy-tabix.
        READ TABLE lt_event INDEX 1 INTO temp12.
        sy-tabix = temp13.
        IF sy-subrc <> 0.
          ASSERT 1 = 0.
        ENDIF.
        mv_popup_name = temp12.
        
        
        
        temp8 = sy-tabix.
        READ TABLE ms_result-t_filter WITH KEY name = mv_popup_name INTO temp7.
        sy-tabix = temp8.
        IF sy-subrc <> 0.
          ASSERT 1 = 0.
        ENDIF.
        ls_sql = temp7.
        client->nav_app_call( z2ui5_cl_pop_get_range=>factory( ls_sql-t_range ) ).

      WHEN `BUTTON_CONFIRM`.
        ms_result-check_confirmed = abap_true.
        client->popup_destroy( ).
        client->nav_app_leave( ).

      WHEN `BUTTON_CANCEL`.
        client->popup_destroy( ).
        client->nav_app_leave( ).

      WHEN `POPUP_DELETE_ALL`.
        
        
        LOOP AT ms_result-t_filter REFERENCE INTO lr_sql.
          CLEAR lr_sql->t_range.
          CLEAR lr_sql->t_token.
        ENDLOOP.
        client->popup_model_update( ).

    ENDCASE.
  ENDMETHOD.

ENDCLASS.
