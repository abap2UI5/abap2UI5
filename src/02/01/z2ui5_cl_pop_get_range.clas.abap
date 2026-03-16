CLASS z2ui5_cl_pop_get_range DEFINITION PUBLIC.

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
    DATA client TYPE REF TO z2ui5_if_client.

    METHODS view_display.

  PRIVATE SECTION.
ENDCLASS.


CLASS z2ui5_cl_pop_get_range IMPLEMENTATION.

  METHOD factory.
    DATA temp7 TYPE z2ui5_cl_util=>ty_s_range.

    CREATE OBJECT r_result.

    z2ui5_cl_util=>itab_corresponding( EXPORTING val = t_range
                                       CHANGING  tab = r_result->ms_result-t_range ).

    
    CLEAR temp7.
    INSERT temp7 INTO TABLE r_result->ms_result-t_range.

  ENDMETHOD.

  METHOD result.

    result = ms_result.

  ENDMETHOD.

  METHOD view_display.

    DATA lo_popup TYPE REF TO z2ui5_cl_xml_view.
    DATA vbox TYPE REF TO z2ui5_cl_xml_view.
    DATA item TYPE REF TO z2ui5_cl_xml_view.
    DATA grid TYPE REF TO z2ui5_cl_xml_view.
    DATA temp8 TYPE string_table.
    lo_popup = z2ui5_cl_xml_view=>factory_popup( ).

    lo_popup = lo_popup->dialog( afterclose    = client->_event( `BUTTON_CANCEL` )
                                 contentheight = `50%`
                                 contentwidth  = `50%`
                                 title         = `Define Filter Conditons` ).

    
    vbox = lo_popup->vbox( height         = `100%`
                                 justifycontent = `SpaceBetween` ).

    
    item = vbox->list( nodata          = `no conditions defined`
                             items           = client->_bind_edit( mt_filter )
                             selectionchange = client->_event( `SELCHANGE` )
                )->custom_list_item( ).

    
    grid = item->grid( ).

    
    CLEAR temp8.
    INSERT `${KEY}` INTO TABLE temp8.
    grid->combobox( selectedkey = `{OPTION}`
                    items       = client->_bind( mt_mapping )
             )->item( key  = `{N}`
                      text = `{N}`
             )->get_parent(
             )->input( value  = `{LOW}`
                       submit = client->_event( `BUTTON_CONFIRM` )
             )->input( value   = `{HIGH}`
                       visible = `{= ${OPTION} === 'BT' }`
                       submit  = client->_event( `BUTTON_CONFIRM` )
             )->button( icon  = `sap-icon://decline`
                        type  = `Transparent`
                        press = client->_event( val   = `POPUP_DELETE`
                                                t_arg = temp8 ) ).

    lo_popup->buttons(
        )->button( text  = `Delete All`
                   icon  = `sap-icon://delete`
                   type  = `Transparent`
                   press = client->_event( val = `POPUP_DELETE_ALL` )
        )->button( text  = `Add Item`
                   icon  = `sap-icon://add`
                   press = client->_event( val = `POPUP_ADD` )
       )->button( text  = `Cancel`
                  press = client->_event( `BUTTON_CANCEL` )
       )->button( text  = `OK`
                  press = client->_event( `BUTTON_CONFIRM` )
                  type  = `Emphasized` ).

    client->popup_display( lo_popup->stringify( ) ).

  ENDMETHOD.

  METHOD z2ui5_if_app~main.
      DATA temp10 LIKE LINE OF ms_result-t_range.
      DATA lr_product LIKE REF TO temp10.
        DATA temp11 TYPE z2ui5_cl_pop_get_range=>ty_s_filter_pop.
        DATA temp12 LIKE LINE OF mt_filter.
        DATA lr_filter LIKE REF TO temp12.
          DATA temp13 TYPE z2ui5_cl_util=>ty_s_range.
        DATA temp14 TYPE z2ui5_cl_pop_get_range=>ty_s_filter_pop.
        DATA temp15 LIKE mt_filter.

    me->client = client.

    IF client->check_on_init( ) IS NOT INITIAL.
      mt_mapping = z2ui5_cl_util=>filter_get_token_range_mapping( ).

      CLEAR mt_filter.
      
      
      LOOP AT ms_result-t_range REFERENCE INTO lr_product.
        
        CLEAR temp11.
        temp11-low = lr_product->low.
        temp11-high = lr_product->high.
        temp11-option = lr_product->option.
        temp11-key = z2ui5_cl_util=>uuid_get_c32( ).
        INSERT temp11 INTO TABLE mt_filter.
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
          
          CLEAR temp13.
          temp13-sign = `I`.
          temp13-option = lr_filter->option.
          temp13-low = lr_filter->low.
          temp13-high = lr_filter->high.
          INSERT temp13 INTO TABLE ms_result-t_range.
        ENDLOOP.

        ms_result-check_confirmed = abap_true.
        client->popup_destroy( ).
        client->nav_app_leave( ).

      WHEN `BUTTON_CANCEL`.
        client->popup_destroy( ).
        client->nav_app_leave( ).

      WHEN `POPUP_ADD`.
        
        CLEAR temp14.
        temp14-key = z2ui5_cl_util=>uuid_get_c32( ).
        INSERT temp14 INTO TABLE mt_filter.
        client->popup_model_update( ).

      WHEN `POPUP_DELETE`.
        DELETE mt_filter WHERE key = client->get_event_arg( 1 ).
        client->popup_model_update( ).

      WHEN `POPUP_DELETE_ALL`.
        
        CLEAR temp15.
        mt_filter = temp15.
        client->popup_model_update( ).

    ENDCASE.

  ENDMETHOD.

ENDCLASS.
