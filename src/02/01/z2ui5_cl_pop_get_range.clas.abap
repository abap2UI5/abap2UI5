CLASS z2ui5_cl_pop_get_range DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    TYPES:
      BEGIN OF ty_s_filter_pop,
        option TYPE string,
        low    TYPE string,
        high   TYPE string,
        key    TYPE string,
      END OF ty_s_filter_pop.

    DATA mt_filter TYPE STANDARD TABLE OF ty_s_filter_pop WITH DEFAULT KEY.

    CLASS-METHODS factory
      IMPORTING
        t_range         TYPE ANY TABLE OPTIONAL
      RETURNING
        VALUE(r_result) TYPE REF TO z2ui5_cl_pop_get_range.

    TYPES:
      BEGIN OF ty_s_result,
        t_range         TYPE z2ui5_cl_util=>ty_t_range,
        check_confirmed TYPE abap_bool,
      END OF ty_s_result.

    DATA ms_result TYPE ty_s_result.

    METHODS result
      RETURNING
        VALUE(result) TYPE ty_s_result.

    DATA mt_mapping TYPE z2ui5_if_types=>ty_t_name_value.

  PROTECTED SECTION.

    DATA client            TYPE REF TO z2ui5_if_client.
    DATA check_initialized TYPE abap_bool.

    METHODS view_display.

  PRIVATE SECTION.
ENDCLASS.


CLASS z2ui5_cl_pop_get_range IMPLEMENTATION.
  METHOD factory.
    DATA temp1 TYPE z2ui5_cl_util=>ty_s_range.

    CREATE OBJECT r_result.

    z2ui5_cl_util=>itab_corresponding( EXPORTING val = t_range
                                       CHANGING  tab = r_result->ms_result-t_range
      ).

    
    CLEAR temp1.
    INSERT temp1 INTO TABLE r_result->ms_result-t_range.

  ENDMETHOD.

  METHOD result.

    result = ms_result.

  ENDMETHOD.

  METHOD view_display.

    DATA lo_popup TYPE REF TO z2ui5_cl_xml_view.
    DATA vbox TYPE REF TO z2ui5_cl_xml_view.
    DATA item TYPE REF TO z2ui5_cl_xml_view.
    DATA grid TYPE REF TO z2ui5_cl_xml_view.
    DATA temp2 TYPE string_table.
    lo_popup = z2ui5_cl_xml_view=>factory_popup( ).

    lo_popup = lo_popup->dialog( afterclose    = client->_event( 'BUTTON_CANCEL' )
                                 contentheight = `50%`
                                 contentwidth  = `50%`
                                 title         = 'Define Filter Conditons' ).

    
    vbox = lo_popup->vbox( height         = `100%`
                                 justifycontent = 'SpaceBetween' ).

    
    item = vbox->list( nodata          = `no conditions defined`
                             items           = client->_bind_edit( mt_filter )
                             selectionchange = client->_event( 'SELCHANGE' )
                )->custom_list_item( ).

    
    grid = item->grid( ).

    
    CLEAR temp2.
    INSERT `${KEY}` INTO TABLE temp2.
    grid->combobox( selectedkey = `{OPTION}`
                    items       = client->_bind( mt_mapping )
             )->item( key  = '{N}'
                      text = '{N}'
             )->get_parent(
             )->input( value  = `{LOW}`
                       submit = client->_event( 'BUTTON_CONFIRM' )
             )->input( value   = `{HIGH}`
                       visible = `{= ${OPTION} === 'BT' }`
                       submit  = client->_event( 'BUTTON_CONFIRM' )
             )->button( icon  = 'sap-icon://decline'
                        type  = `Transparent`
                        press = client->_event( val   = `POPUP_DELETE`
                                                t_arg = temp2 ) ).

    lo_popup->buttons(
        )->button( text  = `Delete All`
                   icon  = 'sap-icon://delete'
                   type  = `Transparent`
                   press = client->_event( val = `POPUP_DELETE_ALL` )
        )->button( text  = `Add Item`
                   icon  = `sap-icon://add`
                   press = client->_event( val = `POPUP_ADD` )
       )->button( text  = 'Cancel'
                  press = client->_event( 'BUTTON_CANCEL' )
       )->button( text  = 'OK'
                  press = client->_event( 'BUTTON_CONFIRM' )
                  type  = 'Emphasized' ).

    client->popup_display( lo_popup->stringify( ) ).

  ENDMETHOD.

  METHOD z2ui5_if_app~main.
      DATA temp4 LIKE LINE OF ms_result-t_range.
      DATA lr_product LIKE REF TO temp4.
        DATA temp5 TYPE z2ui5_cl_pop_get_range=>ty_s_filter_pop.
        DATA temp6 LIKE LINE OF mt_filter.
        DATA lr_filter LIKE REF TO temp6.
          DATA temp7 TYPE z2ui5_cl_util=>ty_s_range.
        DATA temp8 TYPE z2ui5_cl_pop_get_range=>ty_s_filter_pop.
        DATA lt_event TYPE string_table.
        DATA temp9 LIKE LINE OF lt_event.
        DATA temp10 LIKE sy-tabix.
        DATA temp11 LIKE mt_filter.

    me->client = client.

    IF check_initialized = abap_false.
      check_initialized = abap_true.

      mt_mapping = z2ui5_cl_util=>filter_get_token_range_mapping( ).

      CLEAR mt_filter.
      
      
      LOOP AT ms_result-t_range REFERENCE INTO lr_product.
        
        CLEAR temp5.
        temp5-low = lr_product->low.
        temp5-high = lr_product->high.
        temp5-option = lr_product->option.
        temp5-key = z2ui5_cl_util=>uuid_get_c32( ).
        INSERT temp5 INTO TABLE mt_filter.
      ENDLOOP.

      view_display( ).
      RETURN.
    ENDIF.

    CASE client->get( )-event.

      WHEN `BUTTON_CONFIRM`.

        CLEAR ms_result-t_range.
        
        
        LOOP AT mt_filter REFERENCE INTO lr_filter.
          IF lr_filter->low IS INITIAL AND lr_filter->high IS INITIAL.
            CONTINUE.
          ENDIF.
          
          CLEAR temp7.
          temp7-sign = `I`.
          temp7-option = lr_filter->option.
          temp7-low = lr_filter->low.
          temp7-high = lr_filter->high.
          INSERT temp7 INTO TABLE ms_result-t_range.
        ENDLOOP.

        ms_result-check_confirmed = abap_true.
        client->popup_destroy( ).
        client->nav_app_leave( client->get_app( client->get( )-s_draft-id_prev_app_stack ) ).

      WHEN `BUTTON_CANCEL`.
        client->popup_destroy( ).
        client->nav_app_leave( client->get_app( client->get( )-s_draft-id_prev_app_stack ) ).

      WHEN `POPUP_ADD`.
        
        CLEAR temp8.
        temp8-key = z2ui5_cl_util=>uuid_get_c32( ).
        INSERT temp8 INTO TABLE mt_filter.
        client->popup_model_update( ).

      WHEN `POPUP_DELETE`.
        
        lt_event = client->get( )-t_event_arg.
        
        
        temp10 = sy-tabix.
        READ TABLE lt_event INDEX 1 INTO temp9.
        sy-tabix = temp10.
        IF sy-subrc <> 0.
          ASSERT 1 = 0.
        ENDIF.
        DELETE mt_filter WHERE key = temp9.
        client->popup_model_update( ).

      WHEN `POPUP_DELETE_ALL`.
        
        CLEAR temp11.
        mt_filter = temp11.
        client->popup_model_update( ).

    ENDCASE.

  ENDMETHOD.
ENDCLASS.
