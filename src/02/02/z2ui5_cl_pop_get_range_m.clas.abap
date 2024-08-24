CLASS z2ui5_cl_pop_get_range_m DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    TYPES:
      BEGIN OF ty_s_variant,
        uname   TYPE string,
        handle1 TYPE string,
        handle2 TYPE string,
        handle3 TYPE string,
      END OF ty_s_variant.
    DATA ms_variant TYPE ty_s_variant.

    TYPES:
      BEGIN OF ty_s_variant_out,
        s_variant     TYPE ty_s_variant,
        description   TYPE string,
        selkz         TYPE abap_bool,
        check_user    TYPE abap_bool,
        check_default TYPE abap_bool,
        t_filter      TYPE z2ui5_cl_util=>ty_t_filter_multi,
      END OF ty_s_variant_out.
    TYPES ty_t_variant_out TYPE STANDARD TABLE OF ty_s_variant_out WITH EMPTY KEY.
    DATA mt_variant TYPE ty_t_variant_out.

    DATA ms_variant_save TYPE ty_s_variant_out.


    CLASS-METHODS factory
      IMPORTING
        val             TYPE z2ui5_cl_util=>ty_t_filter_multi
        check_db_active TYPE abap_bool DEFAULT abap_true
        var_check_user  TYPE abap_bool DEFAULT abap_true
        var_handle1     TYPE clike DEFAULT sy-repid
        var_handle2     TYPE clike OPTIONAL
        var_handle3     TYPE clike OPTIONAL
      RETURNING
        VALUE(r_result) TYPE REF TO z2ui5_cl_pop_get_range_m.

    TYPES:
      BEGIN OF ty_s_result,
        t_sql           TYPE z2ui5_cl_util=>ty_t_filter_multi,
        check_confirmed TYPE abap_bool,
      END OF ty_s_result.

    DATA ms_result TYPE ty_s_result.

    METHODS result
      RETURNING
        VALUE(result) TYPE ty_s_result.

  PROTECTED SECTION.
    DATA check_db_active  TYPE abap_bool.
    DATA client                 TYPE REF TO z2ui5_if_client.
    DATA check_initialized      TYPE abap_bool.
    DATA mv_popup_name TYPE LINE OF string_table.
    METHODS popup_display.

    METHODS popup_variant_read.
    METHODS popup_variant_save.
    METHODS init.
    METHODS db_read.
    METHODS db_save.
    METHODS save_variant.

  PRIVATE SECTION.
ENDCLASS.



CLASS Z2UI5_CL_POP_GET_RANGE_M IMPLEMENTATION.


  METHOD db_read.
    TRY.

        CLEAR mt_variant.

        DATA lt_variant_user TYPE ty_t_variant_out.
        z2ui5_cl_util=>db_load_by_handle(
            EXPORTING
                uname   = ms_variant-uname
                handle  = ms_variant-handle1
                handle2 = ms_variant-handle2
                handle3 = ms_variant-handle3
            IMPORTING
                result  = lt_variant_user ).
        INSERT LINES OF lt_variant_user INTO TABLE mt_variant.

        DATA lt_variant TYPE ty_t_variant_out.
        z2ui5_cl_util=>db_load_by_handle(
            EXPORTING
                handle  = ms_variant-handle1
                handle2 = ms_variant-handle2
                handle3 = ms_variant-handle3
            IMPORTING
                result  = lt_variant
         ).
        INSERT LINES OF lt_variant INTO TABLE mt_variant.

      CATCH cx_root.
    ENDTRY.
  ENDMETHOD.


  METHOD db_save.

    DATA(lt_variant_user) = mt_variant.
    DELETE lt_variant_user WHERE s_variant-uname IS INITIAL.
    z2ui5_cl_util=>db_save(
        uname   = ms_variant-uname
        handle  = ms_variant-handle1
        handle2 = ms_variant-handle2
        handle3 = ms_variant-handle3
        data    = lt_variant_user
    ).

    DATA(lt_variant) = mt_variant.
    DELETE lt_variant WHERE s_variant-uname IS NOT INITIAL.
    z2ui5_cl_util=>db_save(
        handle  = ms_variant-handle1
        handle2 = ms_variant-handle2
        handle3 = ms_variant-handle3
        data    = lt_variant
    ).

  ENDMETHOD.


  METHOD factory.

    r_result = NEW #( ).
    r_result->ms_result-t_sql = val.
    r_result->check_db_active = check_db_active.

    r_result->ms_variant = VALUE #(
        uname  = COND #( WHEN var_check_user = abap_true THEN sy-uname )
        handle1 = var_handle1
        handle2 = var_handle2
        handle3 = var_handle3
    ).

  ENDMETHOD.


  METHOD init.

    db_read( ).
    popup_display( ).

  ENDMETHOD.


  METHOD popup_display.

    DATA(lo_popup) = z2ui5_cl_xml_view=>factory_popup( ).
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

    DATA(grid) = item->grid(    class = `sapUiSmallMarginTop sapUiSmallMarginBottom sapUiSmallMarginBegin` ).
    grid->text( `{NAME}` ).

    grid->multi_input( tokens = `{T_TOKEN}`
        enabled               = abap_false
             valuehelprequest = client->_event( val = `LIST_OPEN` t_arg = VALUE #( ( `${NAME}` ) ) )
            )->tokens(
                 )->token( key      = `{KEY}`
                           text     = `{TEXT}`
                           visible  = `{VISIBLE}`
                           selected = `{SELKZ}`
                           editable = `{EDITABLE}` ).

    grid->button( text  = `Select`
                  press = client->_event( val = `LIST_OPEN` t_arg = VALUE #( ( `${NAME}` ) ) ) ).
    grid->button( icon  = 'sap-icon://delete'
                  type  = `Transparent`
                  text  = `Clear`
                  press = client->_event( val = `LIST_DELETE` t_arg = VALUE #( ( `${NAME}` ) ) ) ).

    lo_popup->buttons(
        )->button( text  = `Clear All`
                   icon  = 'sap-icon://delete'
                   type  = `Transparent`
                   press = client->_event( val = `POPUP_DELETE_ALL` )
*        )->toolbar_spacer(
*        )->button( text  = 'DB Read'
*                  press = client->_event( 'BUTTON_DB_READ' )
*                 icon  = 'sap-icon://download-from-cloud'
*       )->button( text  = 'DB Save'
*                  press = client->_event( 'BUTTON_DB_SAVE' )
*                  icon  = 'sap-icon://save'
*        )->toolbar_spacer(
       )->button( text  = 'Cancel'
                  press = client->_event( 'BUTTON_CANCEL' )
       )->button( text  = 'OK'
                  press = client->_event( 'BUTTON_CONFIRM' )
                  type  = 'Emphasized' ).

    client->popup_display( lo_popup->stringify( ) ).
  ENDMETHOD.


  METHOD popup_variant_read.

    DATA(popup) = z2ui5_cl_xml_view=>factory_popup(  ).

    DATA(dialog) = popup->dialog( title      = 'Variant'
        contentheight = `50%`
        contentwidth  = `50%`
        afterclose    = client->_event( 'DB_READ_CLOSE' ) ).

    dialog->table(
                mode = 'SingleSelectLeft'
                items = client->_bind_edit( mt_variant )
                )->columns(
                    )->column( )->text( 'Layout' )->get_parent(
                    )->column( )->text( 'Description' )->get_parent(
                    )->column( )->text( 'Default' )->get_parent(
                    )->get_parent(
                )->items(
                    )->column_list_item( selected = '{SELKZ}'
                        )->cells(
                            )->text( '{S_VARIANT/HANDLE1}'
                            )->text( '{DESCR}'
                            )->text( '{DEF}' ).

*    dialog->footer( )->overflow_toolbar(
*          )->toolbar_spacer(
*          )->button(
*                text  = 'Back'
*                icon  = 'sap-icon://nav-back'
*                press = client->_event( 'DB_READ_CLOSE' )
*          )->button(
*                text  = 'Open'
*                icon  = 'sap-icon://accept'
*                press = client->_event( 'OPEN_SELECT' )
*                type  = 'Emphasized' ).

         dialog->buttons(
             )->button(
                text  = 'Back'
                icon  = 'sap-icon://nav-back'
                press = client->_event( 'DB_READ_CLOSE' )
          )->button(
                text  = 'Open'
                icon  = 'sap-icon://accept'
                press = client->_event( 'OPEN_SELECT' )
                type  = 'Emphasized' ).

    client->popup_display( popup->stringify( ) ).

  ENDMETHOD.


  METHOD popup_variant_save.

    DATA(popup) = z2ui5_cl_xml_view=>factory_popup(  ).

    DATA(dialog) = popup->dialog( title      = 'Save'
        contentheight = `50%`
                                 contentwidth  = `50%`
                                  afterclose = client->_event( 'DB_SAVE_CLOSE' ) ).

    DATA(form) = dialog->simple_form( title           = 'Layout'
                                      editable        = abap_true
                                      labelspanxl     = `4`
                                      labelspanl      = `4`
                                      labelspanm      = `4`
                                      labelspans      = `4`
                                      adjustlabelspan = abap_false
                                      ).

    form->toolbar( )->title( 'Layout' ).

    form->content( 'form'
                           )->label( 'Layout'
                           )->input( client->_bind_edit( ms_variant_save-s_variant-handle1 )
                           )->label( 'Description'
                           )->input( client->_bind_edit( ms_variant_save-description ) ).

    form->toolbar( )->title( `` ).

    form->content( 'form'
                           )->label( 'Default Layout'
                           )->switch( type = 'AcceptReject' state = client->_bind_edit( ms_variant_save-check_default )
                           )->label( 'User specific'
                           )->switch( type = 'AcceptReject' state = client->_bind_edit( ms_variant_save-check_user )
                           ).

*    dialog->footer( )->overflow_toolbar(
*          )->toolbar_spacer(
*          )->button(
*                text  = 'Back'
*                icon  = 'sap-icon://nav-back'
*                press = client->_event( 'DB_SAVE_CLOSE' )
*          )->button(
*                text  = 'Save'
*                press = client->_event( 'DB_SAVE' )
*                type  = 'Success'
*                icon  = 'sap-icon://save' ).

         dialog->buttons(
             )->button(
                text  = 'Back'
                icon  = 'sap-icon://nav-back'
                press = client->_event( 'DB_SAVE_CLOSE' )
          )->button(
                text  = 'Save'
                press = client->_event( 'DB_SAVE' )
                type  = 'Success'
                icon  = 'sap-icon://save' ).

    client->popup_display( popup->get_root( )->xml_get( ) ).

  ENDMETHOD.


  METHOD result.
    result = ms_result.
  ENDMETHOD.


  METHOD save_variant.

    db_read( ).
    ms_variant_save-t_filter = ms_result-t_sql.
    INSERT  ms_variant_save INTO TABLE mt_variant.
    db_save( ).
    db_read( ).
    popup_display( ).
    client->message_toast_display( `Variant saved` ).

  ENDMETHOD.


  METHOD z2ui5_if_app~main.
    me->client = client.

    IF check_initialized = abap_false.
      check_initialized = abap_true.
      init( ).
      RETURN.
    ENDIF.

    IF client->get( )-check_on_navigated = abap_true.

      DATA(lo_popup) = CAST z2ui5_cl_pop_get_range( client->get_app( client->get( )-s_draft-id_prev_app ) ).
      IF lo_popup->result( )-check_confirmed = abap_true.
        ASSIGN ms_result-t_sql[ name = mv_popup_name ] TO FIELD-SYMBOL(<tab>).
        <tab>-t_range = lo_popup->result( )-t_range.
        <tab>-t_token = z2ui5_cl_util=>filter_get_token_t_by_range_t( <tab>-t_range ).
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
        client->nav_app_call( z2ui5_cl_pop_get_range=>factory( ls_sql-t_range ) ).

      WHEN `BUTTON_DB_READ`.
        popup_variant_read( ).

      WHEN 'BUTTON_DB_SAVE'.
        popup_variant_save( ).

      WHEN `DB_SAVE_CLOSE`.
        popup_display( ).

      WHEN `DB_READ_CLOSE`.
        popup_display( ).

      WHEN `DB_SAVE`.
        save_variant( ).

      WHEN `BUTTON_CONFIRM`.
        ms_result-check_confirmed = abap_true.
        client->popup_destroy( ).
        client->nav_app_leave( client->get_app( client->get( )-s_draft-id_prev_app_stack ) ).

      WHEN `BUTTON_CANCEL`.
        client->popup_destroy( ).
        client->nav_app_leave( client->get_app( client->get( )-s_draft-id_prev_app_stack ) ).

      WHEN `OPEN_SELECT`.
        DATA(ls_variant) = mt_variant[ selkz = abap_true ].
        ms_result-t_sql = ls_variant-t_filter.
        popup_display( ).

      WHEN `POPUP_DELETE_ALL`.
        LOOP AT ms_result-t_sql REFERENCE INTO DATA(lr_sql).
          CLEAR lr_sql->t_range.
          CLEAR lr_sql->t_token.
        ENDLOOP.
        client->popup_model_update( ).

    ENDCASE.
  ENDMETHOD.
ENDCLASS.
