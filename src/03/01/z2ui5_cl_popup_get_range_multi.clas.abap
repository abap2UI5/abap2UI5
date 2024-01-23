CLASS z2ui5_cl_popup_get_range_multi DEFINITION
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

    DATA mt_filter TYPE STANDARD TABLE OF ty_s_filter_pop WITH EMPTY KEY.

    CLASS-METHODS factory
      IMPORTING
        val             TYPE z2ui5_cl_util_func=>ty_t_sql_multi
      RETURNING
        VALUE(r_result) TYPE REF TO z2ui5_cl_popup_get_range_multi.

    TYPES:
      BEGIN OF ty_s_result,
        t_sql        TYPE z2ui5_cl_util_func=>ty_t_sql_multi,
        check_cancel TYPE abap_bool,
      END OF ty_s_result.

    DATA ms_result TYPE ty_s_result.

    METHODS result
      RETURNING VALUE(result) TYPE ty_s_result.

*  data mt_comp type cl_abap_structdescr=>component_table.

  PROTECTED SECTION.
    DATA client                 TYPE REF TO z2ui5_if_client.
    DATA check_initialized      TYPE abap_bool.
    DATA check_result_confirmed TYPE abap_bool.
    DATA mv_popup_name TYPE LINE OF string_table.
    METHODS popup_display.

  PRIVATE SECTION.
ENDCLASS.


CLASS z2ui5_cl_popup_get_range_multi IMPLEMENTATION.

  METHOD factory.
    r_result = NEW #( ).

    r_result->ms_result-t_sql = val.
*    DATA(lt_comp) = z2ui5_cl_util_func=>rtti_get_t_comp_by_data( data ).

*    LOOP AT lt_comp REFERENCE INTO DATA(lr_comp).
*      INSERT VALUE #( name    = lr_comp->name
*        ) INTO TABLE r_result->ms_result-t_sql.
*    ENDLOOP.
  ENDMETHOD.

  METHOD result.
    result = ms_result.
  ENDMETHOD.

  METHOD popup_display.

    DATA(lo_popup) = z2ui5_cl_xml_view=>factory_popup( client ).
    lo_popup = lo_popup->dialog( afterclose    = client->_event( 'BUTTON_CANCEL' )
                                 contentheight = `50%`
                                 contentwidth  = `50%`
                                 title         = 'Define Filter Conditons' ).

    DATA(vbox) = lo_popup->vbox( height         = `100%`
                                 justifycontent = 'SpaceBetween' ).

    DATA(item) = vbox->list( nodata          = `no conditions defined`
                             items           = client->_bind( ms_result-t_sql )
                             selectionchange = client->_event( 'SELCHANGE' )
                )->custom_list_item( ).

    DATA(grid) = item->grid( ).
    grid->label( `{NAME}` ).

    grid->multi_input( tokens = `{T_TOKEN}`
        enabled = abap_false
             valuehelprequest = client->_event( val = `LIST_OPEN` t_arg = VALUE #( ( `${NAME}` ) ) )
            )->tokens(
                 )->token( key      = `{KEY}`
                           text     = `{TEXT}`
                           visible  = `{VISIBLE}`
                           selected = `{SELKZ}`
                           editable = `{EDITABLE}` ).

    grid->button( text = `Select` press = client->_event( val = `LIST_OPEN` t_arg = VALUE #( ( `${NAME}` ) ) ) ).
    grid->button( icon =  'sap-icon://delete' type = `Transparent` text = `Clear` press = client->_event( val = `LIST_DELETE` t_arg = VALUE #( ( `${NAME}` ) ) ) ).

    lo_popup->footer( )->overflow_toolbar(
        )->button( text  = `Clear All`
                   icon  = 'sap-icon://delete'
                   type  = `Transparent`
                   press = client->_event( val = `POPUP_DELETE_ALL` )
        )->toolbar_spacer(
       )->button( text  = 'Cancel'
                  press = client->_event( 'BUTTON_CANCEL' )
       )->button( text  = 'OK'
                  press = client->_event( 'BUTTON_CONFIRM' )
                  type  = 'Emphasized' ).

    client->popup_display( lo_popup->stringify( ) ).
  ENDMETHOD.

  METHOD z2ui5_if_app~main.
    me->client = client.

    IF check_initialized = abap_false.
      check_initialized = abap_true.
      popup_display( ).
      RETURN.
    ENDIF.

    IF client->get( )-check_on_navigated = abap_true.

      DATA(lo_popup) = CAST z2ui5_cl_popup_get_range( client->get_app( client->get( )-s_draft-id_prev_app ) ) .
      IF lo_popup->result( )-check_cancel = abap_false.
        ASSIGN ms_result-t_sql[ name = mv_popup_name ] TO FIELD-SYMBOL(<tab>).
        <tab>-t_range = lo_popup->result( )-t_range.
        <tab>-t_token = z2ui5_cl_util_func=>get_token_t_by_range_t( <tab>-t_range ).
      ENDIF.
      popup_display( ).

    ENDIF.

    CASE client->get( )-event.

      WHEN 'LIST_DELETE'.
        DATA(lt_event) = client->get( )-t_event_arg.
        ASSIGN ms_result-t_sql[ name = lt_event[ 1 ] ] TO <tab>.
        CLEAR <tab>-t_token.
        CLEAR <tab>-t_range.
        client->popup_model_update( ).

      WHEN 'LIST_OPEN'.
        lt_event = client->get( )-t_event_arg.
        mv_popup_name = lt_event[ 1 ].
        DATA(ls_sql) = ms_result-t_sql[ name = mv_popup_name ].
        client->nav_app_call( z2ui5_cl_popup_get_range=>factory( ls_sql-t_range ) ).

      WHEN `BUTTON_CONFIRM`.
        client->popup_destroy( ).
        client->nav_app_leave( client->get_app( client->get( )-s_draft-id_prev_app_stack ) ).

      WHEN `BUTTON_CANCEL`.
        ms_result-check_cancel = abap_true.
        client->popup_destroy( ).
        client->nav_app_leave( client->get_app( client->get( )-s_draft-id_prev_app_stack ) ).

      WHEN `POPUP_DELETE_ALL`.
        LOOP AT ms_result-t_sql REFERENCE INTO DATA(lr_sql).
          CLEAR lr_sql->t_range.
          CLEAR lr_sql->t_token.
        ENDLOOP.
        client->popup_model_update( ).

    ENDCASE.
  ENDMETHOD.
ENDCLASS.
