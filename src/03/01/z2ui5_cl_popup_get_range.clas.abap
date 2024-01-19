CLASS z2ui5_cl_popup_get_range DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

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

*    CLASS-DATA st_mapping TYPE z2ui5_if_client=>ty_t_name_value.

    DATA mv_value       TYPE string.
    DATA mv_value2      TYPE string.
    DATA mt_token       TYPE z2ui5_cl_util_func=>ty_t_token.

    TYPES:
      BEGIN OF ty_s_filter,
        product TYPE z2ui5_cl_util_func=>ty_t_range,
      END OF ty_s_filter.

    DATA ms_filter TYPE ty_s_filter.

    CLASS-METHODS factory
      IMPORTING
        t_range         TYPE z2ui5_cl_util_func=>ty_t_range  OPTIONAL
*        i_title               TYPE string DEFAULT `Title`
*        i_icon                TYPE string DEFAULT 'sap-icon://question-mark'
*        i_button_text_confirm TYPE string DEFAULT `OK`
*        i_button_text_cancel  TYPE string DEFAULT `Cancel`
      RETURNING
        VALUE(r_result) TYPE REF TO z2ui5_cl_popup_get_range.

    TYPES:
      BEGIN OF ty_s_result,
        t_range      TYPE z2ui5_cl_util_func=>ty_t_range,
        check_cancel TYPE abap_bool,
      END OF ty_s_result.
    DATA ms_result TYPE ty_s_result.

    METHODS result
      RETURNING
        VALUE(result) TYPE ty_s_result.

  PROTECTED SECTION.

    DATA client TYPE REF TO z2ui5_if_client.

    DATA title TYPE string.
    DATA icon TYPE string.
    DATA question_text TYPE string.
    DATA button_text_confirm TYPE string.
    DATA button_text_cancel TYPE string.
    DATA check_initialized TYPE abap_bool.
    DATA check_result_confirmed TYPE abap_bool.
    METHODS view_display.
  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_popup_get_range IMPLEMENTATION.

  METHOD factory.

    r_result = NEW #( ).
    r_result->ms_result-t_range = t_range.
*    r_result->title = i_title.
*    r_result->icon = i_icon.
*    r_result->question_text = i_question_text.
*    r_result->button_text_confirm = i_button_text_confirm.
*    r_result->button_text_cancel = i_button_text_cancel.

  ENDMETHOD.


  METHOD result.

    result = ms_result.

  ENDMETHOD.


  METHOD view_display.

    DATA(lo_popup) = z2ui5_cl_xml_view=>factory_popup( client ).

    lo_popup = lo_popup->dialog(
    contentheight = `50%`
    contentwidth = `50%`
        title = 'Define Filter Conditons' ).

    DATA(vbox) = lo_popup->vbox( height = `100%` justifycontent = 'SpaceBetween' ).

    DATA(item) = vbox->list(
           "   headertext = `Product`
              nodata = `no conditions defined`
             items           = client->_bind_edit( mt_filter )
             selectionchange = client->_event( 'SELCHANGE' )
                )->custom_list_item( ).

    DATA(grid) = item->grid( ).

    grid->combobox(
                 selectedkey = `{OPTION}`
                 items       = client->_bind_local( z2ui5_cl_util_func=>get_token_range_mapping( ) )
             )->item(
                     key = '{N}'
                     text = '{N}'
             )->get_parent(
             )->input( value = `{LOW}`
             )->input( value = `{HIGH}`  visible = `{= ${OPTION} === 'BT' }`
             )->button( icon = 'sap-icon://decline' type = `Transparent` press = client->_event( val = `POPUP_DELETE` t_arg = VALUE #( ( `${KEY}` ) ) )
             ).

    lo_popup->footer( )->overflow_toolbar(
        )->button( text = `Delete All` icon = 'sap-icon://delete' type = `Transparent` press = client->_event( val = `POPUP_DELETE_ALL` )
        )->button( text = `Add Item`   icon = `sap-icon://add` press = client->_event( val = `POPUP_ADD` )
        )->toolbar_spacer(
       )->button(
            text  = 'Cancel'
            press = client->_event( 'BUTTON_CANCEL' )
       )->button(
            text  = 'OK'
            press = client->_event( 'BUTTON_CONFIRM' )
            type  = 'Emphasized'
       ).

    client->popup_display( lo_popup->stringify( ) ).

  ENDMETHOD.


  METHOD z2ui5_if_app~main.

    me->client = client.

    IF check_initialized = abap_false.
      check_initialized = abap_true.



      view_display( ).
      RETURN.
    ENDIF.

    CASE client->get( )-event.
      WHEN `BUTTON_CONFIRM`.

        CLEAR ms_filter-product.
        LOOP AT mt_filter REFERENCE INTO DATA(lr_filter).
          INSERT VALUE #(
              sign = `I`
              option = lr_filter->option
              low = lr_filter->low
              high = lr_filter->high
           ) INTO TABLE ms_filter-product.
        ENDLOOP.

        check_result_confirmed = abap_true.
        client->popup_destroy( ).
        client->nav_app_leave( client->get_app( client->get( )-s_draft-id_prev_app_stack ) ).

      WHEN `BUTTON_CANCEL`.

        CLEAR mt_filter.
        LOOP AT ms_filter-product REFERENCE INTO DATA(lr_product).
          INSERT VALUE #(
                   low = lr_product->low
                   high = lr_product->high
                   option = lr_product->option
                   key = z2ui5_cl_util_func=>func_get_uuid_32( )
           ) INTO TABLE mt_filter.
        ENDLOOP.

        check_result_confirmed = abap_false.
        client->popup_destroy( ).
        client->nav_app_leave( client->get_app( client->get( )-s_draft-id_prev_app_stack ) ).

      WHEN `POPUP_ADD`.
        INSERT VALUE #( key = z2ui5_cl_util_func=>func_get_uuid_32( ) ) INTO TABLE mt_filter.
        client->popup_model_update( ).

      WHEN `POPUP_DELETE`.
        DATA(lt_event) = client->get( )-t_event_arg.
        DELETE mt_filter WHERE key = lt_event[ 1 ].
        client->popup_model_update( ).

      WHEN `POPUP_DELETE_ALL`.
        mt_filter = VALUE #( ).
        client->popup_model_update( ).

    ENDCASE.

  ENDMETHOD.
ENDCLASS.