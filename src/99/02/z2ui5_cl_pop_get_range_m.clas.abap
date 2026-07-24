CLASS z2ui5_cl_pop_get_range_m DEFINITION PUBLIC.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    CLASS-METHODS factory
      IMPORTING
        val             TYPE z2ui5_cl_a2ui5_context=>ty_t_filter_multi
      RETURNING
        VALUE(r_result) TYPE REF TO z2ui5_cl_pop_get_range_m.

    TYPES:
      BEGIN OF ty_s_result,
        t_filter        TYPE z2ui5_cl_a2ui5_context=>ty_t_filter_multi,
        check_confirmed TYPE abap_bool,
      END OF ty_s_result.

    DATA ms_result TYPE ty_s_result.

    METHODS result
      RETURNING
        VALUE(result) TYPE ty_s_result.

  PROTECTED SECTION.
    DATA client        TYPE REF TO z2ui5_if_client.
    DATA mv_popup_name TYPE string.

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
    DATA temp12 TYPE string_table.
    DATA temp14 TYPE string_table.
    DATA temp16 TYPE string_table.
    lo_popup = z2ui5_cl_xml_view=>factory_popup( ).
    lo_popup = lo_popup->dialog( afterclose    = client->_event( `BUTTON_CANCEL` )
                                 contentheight = `50%`
                                 contentwidth  = `50%`
                                 title         = `Define Filter Conditions` ).


    vbox = lo_popup->vbox( height         = `100%`
                                 justifycontent = `SpaceBetween` ).


    item = vbox->list( nodata = `No conditions defined`
                             items  = client->_bind( ms_result-t_filter )
                )->custom_list_item( ).


    grid = item->grid( class = `sapUiSmallMarginTop sapUiSmallMarginBottom sapUiSmallMarginBegin` ).
    grid->text( `{NAME}` ).


    CLEAR temp12.
    INSERT `${NAME}` INTO TABLE temp12.
    grid->multi_input( tokens           = `{T_TOKEN}`
                       enabled          = abap_false
                       valuehelprequest = client->_event( val   = `LIST_OPEN`
                                                          t_arg = temp12 )
            )->tokens(
                 )->token( key      = `{KEY}`
                           text     = `{TEXT}`
                           visible  = `{VISIBLE}`
                           selected = `{SELKZ}`
                           editable = `{EDITABLE}` ).


    CLEAR temp14.
    INSERT `${NAME}` INTO TABLE temp14.
    grid->button( text  = `Select`
                  press = client->_event( val   = `LIST_OPEN`
                                          t_arg = temp14 ) ).

    CLEAR temp16.
    INSERT `${NAME}` INTO TABLE temp16.
    grid->button( icon  = `sap-icon://delete`
                  type  = `Transparent`
                  text  = `Clear`
                  press = client->_event( val   = `LIST_DELETE`
                                          t_arg = temp16 ) ).

    lo_popup->buttons(
        )->button( text  = `Clear All`
                   icon  = `sap-icon://delete`
                   type  = `Transparent`
                   press = client->_event( `POPUP_DELETE_ALL` )
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
    DATA ls_get TYPE z2ui5_if_types=>ty_s_get.
      DATA temp18 TYPE REF TO z2ui5_cl_pop_get_range.
      DATA lo_popup LIKE temp18.
      DATA ls_popup_result TYPE z2ui5_cl_pop_get_range=>ty_s_result.
        FIELD-SYMBOLS <tab> TYPE z2ui5_cl_a2ui5_context=>ty_s_filter_multi.
        DATA temp19 LIKE LINE OF ms_result-t_filter.
        DATA temp20 LIKE sy-tabix.
        DATA temp21 LIKE LINE OF ms_result-t_filter.
        DATA lr_filter LIKE REF TO temp21.
    me->client = client.

    IF client->check_on_init( ) IS NOT INITIAL.
      init( ).
      RETURN.
    ENDIF.


    ls_get = client->get( ).

    IF ls_get-check_on_navigated = abap_true.


      temp18 ?= client->get_app_prev( ).

      lo_popup = temp18.

      ls_popup_result = lo_popup->result( ).
      IF ls_popup_result-check_confirmed = abap_true.

        READ TABLE ms_result-t_filter WITH KEY name = mv_popup_name ASSIGNING <tab>.
        <tab>-t_range = ls_popup_result-t_range.
        <tab>-t_token = z2ui5_cl_a2ui5_context=>filter_get_token_t_by_range_t( <tab>-t_range ).
      ENDIF.
      popup_display( ).

    ENDIF.

    CASE ls_get-event.

      WHEN `LIST_DELETE`.
        READ TABLE ms_result-t_filter WITH KEY name = client->get_event_arg( 1 ) ASSIGNING <tab>.
        CLEAR <tab>-t_token.
        CLEAR <tab>-t_range.
        client->popup_model_update( ).

      WHEN `LIST_OPEN`.
        mv_popup_name = client->get_event_arg( 1 ).


        temp20 = sy-tabix.
        READ TABLE ms_result-t_filter WITH KEY name = mv_popup_name INTO temp19.
        sy-tabix = temp20.
        IF sy-subrc <> 0.
          ASSERT 1 = 0.
        ENDIF.
        client->nav_app_call( z2ui5_cl_pop_get_range=>factory(
            temp19-t_range ) ).

      WHEN `BUTTON_CONFIRM`.
        ms_result-check_confirmed = abap_true.
        client->popup_destroy( ).
        client->nav_app_leave( ).

      WHEN `BUTTON_CANCEL`.
        client->popup_destroy( ).
        client->nav_app_leave( ).

      WHEN `POPUP_DELETE_ALL`.


        LOOP AT ms_result-t_filter REFERENCE INTO lr_filter.
          CLEAR lr_filter->t_range.
          CLEAR lr_filter->t_token.
        ENDLOOP.
        client->popup_model_update( ).

    ENDCASE.
  ENDMETHOD.

ENDCLASS.
