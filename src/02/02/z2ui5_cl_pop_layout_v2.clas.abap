CLASS z2ui5_cl_pop_layout_v2 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_serializable_object.
    INTERFACES z2ui5_if_app.

    TYPES:
      BEGIN OF fixvalue,
        low        TYPE string,
        high       TYPE string,
        option     TYPE string,
        ddlanguage TYPE string,
        ddtext     TYPE string,
      END OF fixvalue.
    TYPES fixvalues TYPE STANDARD TABLE OF fixvalue WITH EMPTY KEY.

    TYPES ty_s_Head TYPE z2ui5_t003.
    TYPES ty_t_head TYPE STANDARD TABLE OF ty_s_head WITH EMPTY KEY.

    TYPES:
      BEGIN OF ty_s_sub_columns,
        key   TYPE string,
        fname TYPE string,
      END OF ty_s_sub_columns.
    TYPES ty_t_sub_columns TYPE STANDARD TABLE OF ty_s_sub_columns WITH EMPTY KEY.

    TYPES  BEGIN OF ty_s_positions.
             INCLUDE TYPE z2ui5_t004.
    TYPES:   tlabel    TYPE string,
             t_sub_col TYPE ty_t_sub_columns,
           END OF ty_s_positions.
    TYPES ty_t_positions TYPE STANDARD TABLE OF ty_s_positions WITH EMPTY KEY.

    TYPES:
      BEGIN OF ty_s_layout,
        s_head   TYPE ty_s_head,
        t_layout TYPE ty_t_positions,
      END OF ty_s_layout.

    TYPES BEGIN OF ty_s_layo.
            INCLUDE TYPE z2ui5_t003.
    TYPES   selkz TYPE abap_bool.
    TYPES END OF ty_s_layo.
    TYPES ty_t_layo TYPE STANDARD TABLE OF ty_s_layo WITH EMPTY KEY.

    TYPES:
      BEGIN OF ty_s_controls,
        attribute TYPE string,
        control   TYPE string,
        active    TYPE abap_bool,
        others    TYPE abap_bool,
      END OF ty_s_controls.
    TYPES ty_t_controls TYPE STANDARD TABLE OF ty_s_controls WITH EMPTY KEY.

    TYPES handle        TYPE c LENGTH 40.
    TYPES control       TYPE c LENGTH 10.

    CLASS-DATA ui_table TYPE control VALUE 'ui.Table' ##NO_TEXT.
    CLASS-DATA m_table  TYPE control VALUE 'm.Table' ##NO_TEXT.

    DATA mt_controls         TYPE ty_t_controls.
    DATA mt_Head             TYPE ty_t_layo.
    DATA ms_layout           TYPE ty_s_layout.
    DATA ms_layout_tmp       TYPE ty_s_layout.
    DATA mv_descr            TYPE string.
    DATA mv_layout           TYPE string.
    DATA mv_def              TYPE abap_bool.
    DATA mv_usr              TYPE abap_bool.
    DATA mv_open             TYPE abap_bool.
    DATA mv_delete           TYPE abap_bool.
    DATA mt_halign           TYPE fixvalues.
    DATA mt_importance       TYPE fixvalues.

    DATA mv_active_subcolumn TYPE string.
    DATA mt_comps            TYPE ty_t_positions.
    DATA mt_sub_cols         TYPE ty_t_sub_columns.

    CLASS-METHODS on_event_layout
      IMPORTING
        !client       TYPE REF TO z2ui5_if_client
        !layout       TYPE ty_s_layout
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_if_client.

    CLASS-METHODS render_layout_function
      IMPORTING
        !xml          TYPE REF TO z2ui5_cl_xml_view
        !client       TYPE REF TO z2ui5_if_client
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    CLASS-METHODS init_layout
      IMPORTING
        !data         TYPE REF TO data
        !control      TYPE control
        handle01      TYPE handle OPTIONAL
        handle02      TYPE handle OPTIONAL
        handle03      TYPE handle OPTIONAL
        handle04      TYPE handle OPTIONAL
      RETURNING
        VALUE(result) TYPE ty_s_layout.

    CLASS-METHODS factory
      IMPORTING
        !layout       TYPE ty_s_layout
        open_layout   TYPE abap_bool OPTIONAL
        delete_layout TYPE abap_bool OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_pop_layout_v2.

  PROTECTED SECTION.
    DATA client  TYPE REF TO z2ui5_if_client.
    DATA mv_init TYPE abap_bool.

    METHODS on_init
      IMPORTING
        !control TYPE control.

    METHODS render_edit.
    METHODS on_event.

    METHODS select_layouts
      IMPORTING
        !control      TYPE control
        handle01      TYPE handle
        handle02      TYPE handle
        handle03      TYPE handle
        handle04      TYPE handle
      RETURNING
        VALUE(result) TYPE ty_t_head.

    METHODS render_save.
    METHODS save_layout.
    METHODS render_open.

    METHODS get_selected_layout
      RETURNING
        VALUE(result) TYPE ty_s_layo.

    METHODS get_layouts.
    METHODS init_edit.
    METHODS render_delete.

    METHODS check_width_unit
      IMPORTING
        !width        TYPE z2ui5_t004-width
      RETURNING
        VALUE(result) TYPE z2ui5_t004-width.

    CLASS-METHODS sort_by_seqence
      IMPORTING
        !Pos          TYPE ty_t_positions
      RETURNING
        VALUE(result) TYPE ty_t_positions.

    CLASS-METHODS set_text
      IMPORTING
        !layout       TYPE ty_s_positions
      RETURNING
        VALUE(result) TYPE ty_s_positions-tlabel.

    METHODS delete_selected_layout
      IMPORTING
        !Head TYPE ty_s_layo.

    METHODS set_selected_layout
      IMPORTING
        !Head TYPE ty_s_layo.

    METHODS render_add_subcolumn.
    METHODS on_event_subcoloumns.

    CLASS-METHODS get_relative_name_of_table
      IMPORTING
        !table        TYPE any
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS default_layout
      IMPORTING
        t_layout      TYPE ty_t_positions
        !control      TYPE control
        handle01      TYPE handle
        handle02      TYPE handle
        handle03      TYPE handle
        handle04      TYPE handle
      RETURNING
        VALUE(result) TYPE ty_s_layout.

    CLASS-METHODS set_sub_columns
      IMPORTING
        !layout       TYPE ty_t_positions
      RETURNING
        VALUE(result) TYPE ty_t_positions.

ENDCLASS.


CLASS z2ui5_cl_pop_layout_v2 IMPLEMENTATION.

  METHOD z2ui5_if_app~main.

    me->client = client.

    IF mv_init = abap_false.
      mv_init = abap_true.

      on_init( ms_layout-s_head-control ).

      init_edit( ).

      render_edit( ).

      client->popup_model_update( ).

    ENDIF.

    on_event( ).

  ENDMETHOD.

  METHOD on_init.

    CASE Control.
      WHEN m_table.
        mt_halign = VALUE #( ( low = 'Begin'     ddtext = 'Locale-specific positioning at the beginning of the line' )
                             ( low = 'Center'    ddtext = 'Centered text alignment'                                  )
                             ( low = 'End'       ddtext = 'Locale-specific positioning at the end of the line'       )
                             ( low = 'Initial'   ddtext = 'Sets no text align, so the browser default is used'       )
                             ( low = 'Left'      ddtext = 'Hard option for left alignment'                           )
                             ( low = 'Right'     ddtext = 'Hard option for right alignment'                          ) ).

      WHEN ui_table.
        mt_halign = VALUE #( ( low = 'Begin'     ddtext = 'Locale-specific positioning at the beginning of the line' )
                             ( low = 'Center'    ddtext = 'Centered text alignment'                                  )
                             ( low = 'End'       ddtext = 'Locale-specific positioning at the end of the line'       )
                             ( low = 'Left'      ddtext = 'Hard option for left alignment'                           )
                             ( low = 'Right'     ddtext = 'Hard option for right alignment'                          ) ).
    ENDCASE.

    mt_importance = VALUE #( ( low = 'High'   ddtext = 'High priority'          )
                             ( low = 'Low'    ddtext = 'Low priority'           )
                             ( low = 'Medium' ddtext = 'Medium priority'        )
                             ( low = 'None'   ddtext = 'Default, none priority' ) ).

    mt_controls = VALUE #( active = abap_true
                           ( control = m_table  attribute = 'VISIBLE' )
                           ( control = m_table  attribute = 'MERGE' )
                           ( control = m_table  attribute = 'HALIGN' )
                           ( control = m_table  attribute = 'IMPORTANCE' )
                           ( control = m_table  attribute = 'WIDTH' )
                           ( control = m_table  attribute = 'ALTERNATIVE_TEXT' )
                           ( control = m_table  attribute = 'SEQUENCE' )
                           ( control = m_table  attribute = 'SUBCOLUMN' )
                           ( control = ui_table attribute = 'VISIBLE' )
                           ( control = ui_table attribute = 'ALTERNATIVE_TEXT' )
                           ( control = ui_table attribute = 'HALIGN' )
                           ( control = ui_table attribute = 'WIDTH' )
                           ( control = ``         attribute = 'VISIBLE' )
                           ( control = ``         attribute = 'SEQUENCE' )
                           ( control = ``         attribute = 'ALTERNATIVE_TEXT' ) ).

  ENDMETHOD.

  METHOD render_edit.

    DATA(popup) = z2ui5_cl_xml_view=>factory_popup( ).

    DATA(dialog) = popup->dialog( title        = 'Edit Layout'
*                                  stretch      = abap_true
                                  contentwidth = '70%'
                                  afterclose   = client->_event( 'CLOSE' ) ).

    DATA(tab) = dialog->table( growing          = abap_true
                               growingthreshold = '80'
                               items            = client->_bind_edit( ms_layout-t_layout ) ).

    DATA(list) = tab->column_list_item( ).

    DATA(cells) = list->cells( ).

    DATA(columns) = tab->columns( ).

    DATA(lt_comp) = z2ui5_cl_util=>rtti_get_t_attri_by_any( ms_layout-t_layout ).

    DATA(col) = columns->column( )->header( `` ).
    col->text( 'Row' ).

    LOOP AT lt_comp REFERENCE INTO DATA(comp).

      READ TABLE mt_controls INTO DATA(control) WITH KEY control   = ms_layout-s_head-control
                                                         attribute = comp->name
                                                         active    = abap_true.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      CASE control-attribute.
        WHEN 'VISIBLE'.
          col = columns->column( '4.5rem' )->header( `` ).
          col->text( 'Visible' ).
        WHEN 'MERGE'.
          col = columns->column( '4.5rem' )->header( `` ).
          col->text( 'Merge' ).
        WHEN 'HALIGN'.
          col = columns->column( )->header( `` ).
          col->text( 'Align' ).
        WHEN 'IMPORTANCE'.
          col = columns->column( )->header( `` ).
          col->text( 'Importance' ).
        WHEN 'WIDTH'.
          col = columns->column( `7rem` )->header( `` ).
          col->text( 'Width in rem' ).
        WHEN 'SEQUENCE'.
          col = columns->column( `5rem` )->header( `` ).
          col->text( 'Sequence' ).
        WHEN 'ALTERNATIVE_TEXT'.
          col = columns->column( )->header( `` ).
          col->text( 'Alternative Text' ).
        WHEN 'SUBCOLUMN'.
          col = columns->column( )->header( `` ).
          col->text( 'Subcolumn' ).
      ENDCASE.

    ENDLOOP.

    LOOP AT lt_comp REFERENCE INTO comp.

      IF comp->name = 'FNAME'.
        cells->text( |\{{ comp->name }\}| ).
      ENDIF.

      READ TABLE mt_controls INTO control WITH KEY control   = ms_layout-s_head-control
                                                   attribute = comp->name
                                                   active    = abap_true.

      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      CASE comp->name.

        WHEN 'VISIBLE' OR 'MERGE'.

          cells->switch( type  = 'AcceptReject'
                         state = |\{{ comp->name }\}|     ).

        WHEN 'HALIGN'.

          cells->combobox( selectedkey = |\{{ comp->name }\}|
                           items       = client->_bind_local( mt_halign )
                        )->item( key  = '{LOW}'
                                 text = '{LOW} - {DDTEXT}' ).

        WHEN 'IMPORTANCE'.

          cells->combobox( selectedkey = |\{{ comp->name }\}|
                           items       = client->_bind_local( mt_importance )
                        )->item( key  = '{LOW}'
                                 text = '{LOW} - {DDTEXT}' ).

        WHEN 'WIDTH'.

          cells->input( value     = |\{{ comp->name }\}|
                        maxLength = `7` ).

        WHEN 'SEQUENCE'.

          cells->input( value     = |\{{ comp->name }\}|
                        maxLength = `5`
                        width     = `3rem` ).

        WHEN 'ALTERNATIVE_TEXT'.

          cells->input( |\{{ comp->name }\}| ).

        WHEN 'SUBCOLUMN'.

          cells->button( text  = |\{{ comp->name }\}|
                         icon  = `sap-icon://add`
                         press = client->_event( val   = 'CALL_SUBCOLUMN'
                                                 t_arg = VALUE #( ( `${FNAME}` ) ) ) ).

      ENDCASE.

    ENDLOOP.

    dialog->buttons(
          )->button( press = ''
                     icon  = 'sap-icon://edit'
                     type  = 'Emphasized'
          )->button( press = client->_event( 'LAYOUT_LOAD' )
                     icon  = 'sap-icon://open-folder'
                     type  = 'Ghost'
          )->button( press = client->_event( 'LAYOUT_DELETE' )
                     icon  = 'sap-icon://delete'
                     type  = 'Ghost'
          )->button( type    = 'Transparent'
                     enabled = abap_false
                     text    = `               `
         )->button( text  = 'Close'
                    icon  = 'sap-icon://sys-cancel-2'
                    press = client->_event( 'CLOSE' )
         )->button( text  = 'Okay'
                    icon  = 'sap-icon://accept'
                    press = client->_event( 'OKAY' )
         )->button( text  = 'Save'
                    press = client->_event( 'EDIT_SAVE' )
                    icon  = 'sap-icon://save'
                    type  = 'Emphasized' ).

    client->popup_display( popup->get_root( )->xml_get( ) ).

  ENDMETHOD.

  METHOD on_event.

    CASE client->get( )-event.

      WHEN 'LAYOUT_EDIT'.

        init_edit( ).

        render_edit( ).

      WHEN 'LAYOUT_LOAD'.

        get_layouts( ).

        render_open( ).

      WHEN 'LAYOUT_DELETE'.

        get_layouts( ).

        render_delete( ).

      WHEN 'OKAY'.

        client->popup_destroy( ).

        client->nav_app_leave( client->get_app( client->get( )-s_draft-id_prev_app_stack ) ).

      WHEN 'CLOSE'.

        client->popup_destroy( ).

        ms_layout = ms_layout_tmp.

        client->nav_app_leave( client->get_app( client->get( )-s_draft-id_prev_app_stack ) ).

      WHEN 'EDIT_SAVE'.

        render_save( ).

      WHEN 'SAVE_CLOSE'.

        client->popup_destroy( ).

        render_edit( ).

      WHEN 'SAVE_SAVE'.

        save_layout( ).

        client->popup_destroy( ).

        client->nav_app_leave( client->get_app( client->get( )-s_draft-id_prev_app_stack ) ).

      WHEN 'OPEN_SELECT'.

        set_selected_layout( get_selected_layout( ) ).

        client->popup_destroy( ).

        client->nav_app_leave( client->get_app( client->get( )-s_draft-id_prev_app_stack ) ).

      WHEN 'DELETE_SELECT'.

        delete_selected_layout( get_selected_layout( ) ).

        client->popup_destroy( ).

        client->nav_app_leave( client->get_app( client->get( )-s_draft-id_prev_app_stack ) ).

      WHEN OTHERS.

        on_event_subcoloumns( ).

    ENDCASE.

  ENDMETHOD.

  METHOD factory.

    result = NEW #( ).

    result->ms_layout     = layout.
    result->ms_layout_tmp = layout.

    result->mv_open       = open_layout.
    result->mv_delete     = delete_layout.

  ENDMETHOD.

  METHOD render_layout_function.

    result = xml.

    result->button( icon  = 'sap-icon://action-settings'
                    press = client->_event( val = 'LAYOUT_EDIT' ) ).

  ENDMETHOD.

  METHOD render_save.

    DATA(popup) = z2ui5_cl_xml_view=>factory_popup( ).

    DATA(dialog) = popup->dialog( title        = 'Save'
                                  contentwidth = '70%'
                                  afterclose   = client->_event( 'SAVE_CLOSE' ) ).

    DATA(form) = dialog->content( )->simple_form( title                   = 'Layout'
                                                  editable                = abap_true
                                                  labelspanxl             = `4`
                                                  labelspanl              = `4`
                                                  labelspanm              = `4`
                                                  labelspans              = `4`
                                                  adjustlabelspan         = abap_false
                                                  emptySpanXL             = `0`
                                                  emptySpanL              = `0`
                                                  emptySpanM              = `0`
                                                  emptySpanS              = `0`
                                                  columnsXL               = `2`
                                                  columnsL                = `2`
                                                  columnsM                = `2`
                                                  singleContainerFullSize = `true` ).

    form->toolbar( )->title( 'Layout' ).

    form->content( 'form'
                           )->label( 'Layout'
                           )->input( client->_bind_edit( mv_layout )
                           )->label( 'Description'
                           )->input( client->_bind_edit( mv_descr ) ).

    form->toolbar( )->title( `Save Options` ).

    form->content( 'form'
                           )->label( 'Default Layout'
                           )->switch( type  = 'AcceptReject'
                                      state = client->_bind_edit( mv_def )
                           )->label( 'User specific'
                           )->switch( type  = 'AcceptReject'
                                      state = client->_bind_edit( mv_usr ) ).

    dialog->buttons( )->button( text  = 'Back'
                                icon  = 'sap-icon://nav-back'
                                press = client->_event( 'SAVE_CLOSE' )
          )->button( text  = 'Save'
                     press = client->_event( 'SAVE_SAVE' )
                     type  = 'Success'
                     icon  = 'sap-icon://save' ).

    client->popup_display( popup->get_root( )->xml_get( ) ).

  ENDMETHOD.

  METHOD save_layout.

    DATA line      TYPE z2ui5_t004.
    DATA Positions TYPE STANDARD TABLE OF z2ui5_t004 WITH EMPTY KEY.

    IF mv_layout IS INITIAL.
      client->message_toast_display( 'Layoutname missing.' ).
      RETURN.
    ENDIF.

    IF mv_usr = abap_true.
      DATA(user) = sy-uname.
    ENDIF.

    DATA(Head) = VALUE z2ui5_t003( guid     = ms_layout-s_head-guid
                                   layout   = mv_layout
                                   control  = ms_layout-s_head-control
                                   handle01 = ms_layout-s_head-handle01
                                   handle02 = ms_layout-s_head-handle02
                                   handle03 = ms_layout-s_head-handle03
                                   handle04 = ms_layout-s_head-handle04
                                   descr    = mv_descr
                                   def      = mv_def
                                   uname    = user ).

    LOOP AT ms_layout-t_layout INTO DATA(layout).

      CLEAR line.

      line = CORRESPONDING #( ms_layout-s_head ).
      line = CORRESPONDING #( layout ).
      line-layout = mv_layout.

      line-width  = check_width_unit( line-width ).

      APPEND line TO Positions.

    ENDLOOP.

    " Does a matching Layout exist?
    SELECT guid FROM z2ui5_t003
      WHERE layout   = @Head-layout
        AND control  = @Head-control
        AND handle01 = @Head-handle01
        AND handle02 = @Head-handle02
        AND handle03 = @Head-handle03
        AND handle04 = @Head-handle04
      INTO TABLE @DATA(t_heads).

    IF sy-subrc = 0.

      IF t_heads IS NOT INITIAL.

        SELECT mandt, guid, pos_guid FROM z2ui5_t004
          FOR ALL ENTRIES IN @t_heads
          WHERE guid = @t_heads-guid
          INTO TABLE @DATA(t_del).

        IF sy-subrc = 0.
          " if structure was changed we do not want any dead entries ...
          DELETE z2ui5_t004 FROM TABLE @t_del.
          COMMIT WORK AND WAIT.
        ENDIF.

      ENDIF.
    ELSE.

      " guid already taken
      SELECT guid FROM z2ui5_t003
        WHERE guid = @head-guid
        INTO TABLE @t_heads.

      IF sy-subrc = 0.
        " Layout changed and saved under new name -> new Guid needed
        TRY.
            Head-guid = cl_system_uuid=>create_uuid_c32_static( ).

            LOOP AT Positions REFERENCE INTO DATA(r_pos).
              r_pos->guid = Head-guid.
            ENDLOOP.

          CATCH cx_root.
        ENDTRY.

      ENDIF.

    ENDIF.

    MODIFY z2ui5_t003 FROM @Head.
    IF sy-subrc = 0.

      MODIFY z2ui5_t004 FROM TABLE @Positions.

      IF sy-subrc = 0.

        COMMIT WORK AND WAIT.

        client->message_toast_display( 'Data saved.' ).

        ms_layout-s_head = Head.

        CLEAR ms_layout-t_layout.

        LOOP AT positions INTO DATA(pos).
          CLEAR layout.
          layout = CORRESPONDING #( pos ).
          layout-tlabel = set_text( layout ).
          APPEND layout TO ms_layout-t_layout.
        ENDLOOP.

        ms_layout-t_layout = sort_by_seqence( ms_layout-t_layout ).

      ENDIF.
    ENDIF.

  ENDMETHOD.

  METHOD render_delete.

    DATA(popup) = z2ui5_cl_xml_view=>factory_popup( ).

    DATA(dialog) = popup->dialog( title        = 'Delete Layout'
                                  contentwidth = '70%'
                                  afterclose   = client->_event( 'CLOSE' ) ).

    dialog->table( mode  = 'SingleSelectLeft'
                   items = client->_bind_edit( mt_head )
                )->columns(
                    )->column( )->text( 'Layout' )->get_parent(
                    )->column( )->text( 'Description'
                    )->get_parent( )->get_parent(
                )->items(
                    )->column_list_item( selected = '{SELKZ}'
                        )->cells(
                            )->text( '{LAYOUT}'
                            )->text( '{DESCR}' ).

    dialog->buttons(
          )->button( press = client->_event( 'LAYOUT_EDIT' )
                     icon  = 'sap-icon://edit'
                     type  = 'Ghost'
          )->button( press = client->_event( 'LAYOUT_LOAD' )
                     icon  = 'sap-icon://open-folder'
                     type  = 'Ghost'
          )->button( press = ''
                     icon  = 'sap-icon://delete'
                     type  = 'Emphasized'
          )->button( type    = 'Transparent'
                     enabled = abap_false
                     text    = `               `
         )->button( text  = 'Close'
                    icon  = 'sap-icon://sys-cancel-2'
                    press = client->_event( 'CLOSE' )
         )->button( text  = 'Delete'
                    icon  = 'sap-icon://delete'
                    press = client->_event( 'DELETE_SELECT' )
                    type  = 'Reject' ).

    client->popup_display( popup->stringify( ) ).

  ENDMETHOD.

  METHOD render_open.

    DATA(popup) = z2ui5_cl_xml_view=>factory_popup( ).

    DATA(dialog) = popup->dialog( title        = 'Select Layout'
                                  contentwidth = '70%'
                                  afterclose   = client->_event( 'CLOSE' ) ).

    dialog->table( mode  = 'SingleSelectLeft'
                   items = client->_bind_edit( mt_head )
                )->columns(
                    )->column( )->text( 'Layout' )->get_parent(
                    )->column( )->text( 'Description' )->get_parent(
                    )->column( )->text( 'Default' )->get_parent(
                    )->get_parent(
                )->items(
                    )->column_list_item( selected = '{SELKZ}'
                        )->cells(
                            )->text( '{LAYOUT}'
                            )->text( '{DESCR}'
                            )->text( '{DEF}' ).

    dialog->buttons(
          )->button( press = client->_event( 'LAYOUT_EDIT' )
                     icon  = 'sap-icon://edit'
                     type  = 'Ghost'
          )->button( press = ''
                     icon  = 'sap-icon://open-folder'
                     type  = 'Emphasized'
          )->button( press = client->_event( 'LAYOUT_DELETE' )
                     icon  = 'sap-icon://delete'
                     type  = 'Ghost'
          )->button( type    = 'Transparent'
                     enabled = abap_false
                     text    = `               `
         )->button( text  = 'Close'
                    icon  = 'sap-icon://sys-cancel-2'
                    press = client->_event( 'CLOSE' )
         )->button( text  = 'OK'
                    icon  = 'sap-icon://accept'
                    press = client->_event( 'OPEN_SELECT' )
                    type  = 'Emphasized' ).

    client->popup_display( popup->stringify( ) ).

  ENDMETHOD.

  METHOD select_layouts.

    SELECT guid,
           layout,
           control,
           handle01,
           handle02,
           handle03,
           handle04,
           descr,
           def,
           uname
      FROM z2ui5_t003
      WHERE control  = @control
        AND handle01 = @handle01
        AND handle02 = @handle02
        AND handle03 = @handle03
        AND handle04 = @handle04
      INTO CORRESPONDING FIELDS OF TABLE @result ##SUBRC_OK.

  ENDMETHOD.

  METHOD get_selected_layout.

    result = VALUE #( mt_head[ selkz = abap_true ] OPTIONAL ).

  ENDMETHOD.

  METHOD set_selected_layout.

    IF Head IS INITIAL.
      RETURN.
    ENDIF.

    SELECT SINGLE guid,
                  layout,
                  control,
                  handle01,
                  handle02,
                  handle03,
                  handle04,
                  descr,
                  def,
                  uname
      FROM z2ui5_t003
      WHERE guid = @Head-guid
      INTO CORRESPONDING FIELDS OF @ms_layout-s_head ##SUBRC_OK.

    SELECT guid,
           layout,
           control,
           handle01,
           handle02,
           handle03,
           handle04,
           fname,
           rollname,
           visible,
           merge,
           halign,
           importance,
           width,
           sequence,
           alternative_text,
           subcolumn
      FROM z2ui5_t004
      WHERE guid = @Head-guid
      INTO CORRESPONDING FIELDS OF TABLE @ms_layout-t_layout  ##SUBRC_OK.

  ENDMETHOD.

  METHOD init_layout.

    " create the tab first if the db fields were added/deleted
    DATA(t_comp) = z2ui5_cl_util_api=>rtti_get_t_attri_by_any( data ).

    LOOP AT t_comp REFERENCE INTO DATA(lr_comp).
      INSERT VALUE #( control  = control
                      handle01 = handle01
                      handle02 = handle02
                      handle03 = handle03
                      handle04 = handle04
                      fname    = lr_comp->name
                      rollname = lr_comp->type->get_relative_name( ) )
             INTO TABLE result-t_layout.
    ENDLOOP.

    " Select Layouts
    SELECT guid,
           layout,
           control,
           handle01,
           handle02,
           handle03,
           handle04,
           descr,
           def,
           uname
      FROM z2ui5_t003
      WHERE control  = @control
        AND handle01 = @handle01
        AND handle02 = @handle02
        AND handle03 = @handle03
        AND handle04 = @handle04
      INTO TABLE @DATA(Head).

    IF sy-subrc = 0.

      " Default all Handles + User
      DATA(def) = VALUE #( Head[ handle01 = handle01
                                 handle02 = handle02
                                 handle03 = handle03
                                 handle04 = handle04
                                 def      = abap_true
                                 uname    = sy-uname ] OPTIONAL ).

      IF def IS INITIAL.
        " Default frist 3 Handles + User
        def = VALUE #( Head[ handle01 = handle01
                             handle02 = handle02
                             handle03 = handle03
                             def      = abap_true
                             uname    = sy-uname ] OPTIONAL ).
        IF def IS INITIAL.
          " Default frist 2 Handles + User
          def = VALUE #( Head[ handle01 = handle01
                               handle02 = handle02
                               def      = abap_true
                               uname    = sy-uname ] OPTIONAL ).
          IF def IS INITIAL.
            " Default frist 1 Handles + User
            def = VALUE #( Head[ handle01 = handle01
                                 def      = abap_true
                                 uname    = sy-uname ] OPTIONAL ).
          ENDIF.
          IF def IS INITIAL.
            " Default User
            def = VALUE #( Head[ def   = abap_true
                                 uname = sy-uname ] OPTIONAL ).
          ENDIF.
          IF def IS INITIAL.
            " Default User
            def = VALUE #( Head[ def = abap_true ] OPTIONAL ).
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    IF def-layout IS NOT INITIAL.

      SELECT guid,
             pos_guid,
             layout,
             control,
             handle01,
             handle02,
             handle03,
             handle04,
             fname,
             rollname,
             visible,
             merge,
             halign,
             importance,
             width,
             sequence,
             alternative_text,
             subcolumn
        FROM z2ui5_t004
        WHERE guid = @def-guid
        INTO TABLE @DATA(t_pos) ##SUBRC_OK.

      LOOP AT result-t_layout REFERENCE INTO DATA(layout).

        TRY.
            DATA(pos) = REF #( t_pos[ fname = layout->fname ] ).
            layout->* = CORRESPONDING #( pos->* ).
          CATCH cx_root.

            TRY.
                DATA(pos_guid) = cl_system_uuid=>create_uuid_c32_static( ).
              CATCH cx_root.
            ENDTRY.

            layout->guid       = def-guid.
            layout->pos_guid   = pos_guid.
            layout->layout     = 'Default'.
            layout->control    = control.
            layout->halign     = 'Begin'.
            layout->importance = 'None'.
            layout->rollname   = layout->rollname.
            layout->fname      = layout->fname.
            layout->handle01   = handle01.
            layout->handle02   = handle02.
            layout->handle03   = handle03.
            layout->handle04   = handle04.
        ENDTRY.

        layout->tlabel = set_text( layout->* ).

      ENDLOOP.

      result-s_head   = CORRESPONDING #( def ).
      result-t_layout = sort_by_seqence( result-t_layout ).
      result-t_layout = set_sub_columns( result-t_layout ).

      RETURN.

    ENDIF.

    result = default_layout( t_layout = result-t_layout
                             control  = control
                             handle01 = handle01
                             handle02 = handle02
                             handle03 = handle03
                             handle04 = handle04 ).

  ENDMETHOD.

  METHOD default_layout.

    DATA layout TYPE REF TO ty_s_positions.

    TRY.
        DATA(guid) = cl_system_uuid=>create_uuid_c32_static( ).
      CATCH cx_root.
    ENDTRY.

    result-t_layout = t_layout.

    " Default Layout
    DATA(index) = 0.

    LOOP AT result-t_layout REFERENCE INTO layout.

      TRY.
          DATA(pos_guid) = cl_system_uuid=>create_uuid_c32_static( ).
        CATCH cx_root.
      ENDTRY.

      index = index + 1.

      " Default only 10 rows
      IF index <= 10.
        layout->visible = abap_true.
      ENDIF.

      IF    layout->fname = 'MANDT'
         OR layout->fname = 'ROW_ID'
         OR layout->fname = 'SELKZ'.
        layout->visible = abap_false.
        layout->width   = '5rem'.
      ENDIF.

      layout->guid       = guid.
      layout->pos_guid   = pos_guid.
      layout->layout     = 'Default'.
      layout->control    = control.
      layout->halign     = 'Begin'.
      layout->importance = 'None'.
      layout->handle01   = handle01.
      layout->handle02   = handle02.
      layout->handle03   = handle03.
      layout->handle04   = handle04.

      layout->tlabel     = set_text( layout->* ).

    ENDLOOP.

    result-s_head-guid     = guid.
    result-s_head-layout   = 'Default'.
    result-s_head-control  = control.
    result-s_head-descr    = 'System generated Layout'.
    result-s_head-def      = abap_true.
    result-s_head-handle01 = handle01.
    result-s_head-handle02 = handle02.
    result-s_head-handle03 = handle03.
    result-s_head-handle04 = handle04.

  ENDMETHOD.

  METHOD get_layouts.

    mt_head = select_layouts( control  = ms_layout-s_head-control
                              handle01 = ms_layout-s_head-handle01
                              handle02 = ms_layout-s_head-handle02
                              handle03 = ms_layout-s_head-handle03
                              handle04 = ms_layout-s_head-handle04 ).

    IF mt_head IS NOT INITIAL.

      DATA(Head) = REF #( mt_head[ layout = ms_layout-s_head-layout ] OPTIONAL ).
      IF Head IS BOUND.
        Head->selkz = abap_true.
        RETURN.
      ELSE.
        Head = REF #( mt_head[ 1 ] OPTIONAL ).
        Head->selkz = abap_true.
      ENDIF.

    ENDIF.

  ENDMETHOD.

  METHOD init_edit.

    mv_layout = ms_layout-s_head-layout.
    mv_descr  = ms_layout-s_head-descr.
    mv_def    = ms_layout-s_head-def.

    mv_usr    = xsdbool( ms_layout-s_head-uname IS NOT INITIAL ).

  ENDMETHOD.

  METHOD on_event_layout.

    result = client.

    IF result->get( )-event = 'LAYOUT_EDIT'.
      result->nav_app_call( factory( layout = layout ) ).
    ENDIF.

  ENDMETHOD.

  METHOD delete_selected_layout.

    DELETE FROM z2ui5_t003 WHERE guid = @Head-guid.

    DELETE FROM z2ui5_t004 WHERE guid = @Head-guid.

    IF sy-subrc = 0.
      COMMIT WORK AND WAIT.
    ENDIF.

  ENDMETHOD.

  METHOD get_relative_name_of_table.

    FIELD-SYMBOLS <table> TYPE any.

    TRY.
        DATA(typedesc) = cl_abap_typedescr=>describe_by_data( table ).

        CASE typedesc->kind.

          WHEN cl_abap_typedescr=>kind_table.
            DATA(tabledesc) = CAST cl_abap_tabledescr( typedesc ).
            DATA(structdesc) = CAST cl_abap_structdescr( tabledesc->get_table_line_type( ) ).
            result = structdesc->get_relative_name( ).
            RETURN.

          WHEN typedesc->kind_ref.

            ASSIGN table->* TO <table>.
            result = get_relative_name_of_table( <table> ).

        ENDCASE.
      CATCH cx_root.
    ENDTRY.

  ENDMETHOD.

  METHOD sort_by_seqence.

    " First all wit a seqence then the rest
    DATA(tab) = pos.

    DATA(index) = 0.

    DO 99 TIMES.

      index = index + 1.

      LOOP AT tab INTO DATA(line) WHERE sequence = index.

        APPEND line TO result.
        DELETE tab.

      ENDLOOP.

    ENDDO.

    APPEND LINES OF tab TO result.

  ENDMETHOD.

  METHOD set_text.

    IF layout-alternative_text IS INITIAL.
      result = z2ui5_cl_stmpncfctn_api=>rtti_get_data_element_texts( CONV #( layout-rollname ) )-long.
    ELSE.
      result = z2ui5_cl_stmpncfctn_api=>rtti_get_data_element_texts( CONV #( layout-alternative_text ) )-long.
    ENDIF.

    IF result IS INITIAL.
      result = layout-fname.
    ENDIF.

  ENDMETHOD.

  METHOD check_width_unit.

    IF width IS INITIAL.
      RETURN.
    ENDIF.

    result = width.

    IF width CO '0123456789., '.
      REPLACE ALL OCCURRENCES OF ` ` IN result WITH ``.
      result = |{ result }rem|.
    ENDIF.

  ENDMETHOD.

  METHOD render_add_subcolumn.

    DATA(lo_popup) = z2ui5_cl_xml_view=>factory_popup( ).

    lo_popup = lo_popup->dialog( afterclose   = client->_event( 'SUBCOLUMN_CANCEL' )
                                 contentwidth = `20%`
                                 title        = 'Define Sub Coloumns' ).

    DATA(vbox) = lo_popup->vbox( justifycontent = 'SpaceBetween' ).

    DATA(item) = vbox->list( nodata          = `no Subcolumns defined`
                             items           = client->_bind_edit( mt_sub_cols )
                             selectionchange = client->_event( 'SELCHANGE' )
                )->custom_list_item( ).

    DATA(grid) = item->grid( ).

    grid->combobox( selectedkey = `{FNAME}`
                    items       = client->_bind( mt_comps  )
                   )->item( key  = '{FNAME}'
                            text = '{FNAME}'
             )->get_parent(
             )->button( icon  = 'sap-icon://decline'
                        type  = `Transparent`
                        press = client->_event( val   = `SUBCOLUMN_DELETE`
                                                t_arg = VALUE #( ( `${KEY}` ) ) ) ).

    lo_popup->buttons(
        )->button( text  = `Delete All`
                   icon  = 'sap-icon://delete'
                   type  = `Transparent`
                   press = client->_event( val = `SUBCOLUMN_DELETE_ALL` )
        )->button( text  = `Add Item`
                   icon  = `sap-icon://add`
                   press = client->_event( val = `SUBCOLUMN_ADD` )
       )->button( text  = 'Cancel'
                  press = client->_event( 'SUBCOLUMN_CANCEL' )
       )->button( text  = 'OK'
                  press = client->_event( 'SUBCOLUMN_CONFIRM' )
                  type  = 'Emphasized' ).

    client->popup_display( lo_popup->stringify( ) ).

  ENDMETHOD.

  METHOD on_event_subcoloumns.

    CASE client->get( )-event.

      WHEN 'CALL_SUBCOLUMN'.

        DATA(arg) = client->get( )-t_event_arg.
        mv_active_SUBCOLumn = VALUE #( arg[ 1 ] OPTIONAL ).

        READ TABLE ms_layout-t_layout REFERENCE INTO DATA(layout) WITH KEY fname = mv_active_subcolumn.
        IF sy-subrc <> 0.
          RETURN.
        ENDIF.

        mt_comps    = ms_layout-t_layout.
        mt_sub_cols = layout->t_sub_col.

        render_add_subcolumn( ).

      WHEN `SUBCOLUMN_CONFIRM`.

        READ TABLE ms_layout-t_layout REFERENCE INTO layout WITH KEY fname = mv_active_subcolumn.
        IF sy-subrc <> 0.
          RETURN.
        ENDIF.

        CLEAR layout->subcolumn.

        LOOP AT mt_sub_cols REFERENCE INTO DATA(line).
          layout->subcolumn = |{ layout->subcolumn } { line->fname }|.
        ENDLOOP.
        SHIFT layout->subcolumn LEFT DELETING LEADING space.

        layout->t_sub_col = mt_sub_cols.

        client->popup_destroy( ).

        init_edit( ).
        render_edit( ).

      WHEN `SUBCOLUMN_CANCEL`.

        init_edit( ).
        render_edit( ).

      WHEN `SUBCOLUMN_ADD`.
        INSERT VALUE #( key = z2ui5_cl_util=>uuid_get_c32( ) ) INTO TABLE mt_sub_cols.
        client->popup_model_update( ).

      WHEN `SUBCOLUMN_DELETE`.
        DATA(lt_event) = client->get( )-t_event_arg.
        DELETE mt_sub_cols WHERE key = lt_event[ 1 ].
        client->popup_model_update( ).

      WHEN `SUBCOLUMN_DELETE_ALL`.
        mt_sub_cols = VALUE #( ).
        client->popup_model_update( ).

    ENDCASE.

  ENDMETHOD.

  METHOD set_sub_columns.

    result = layout.

    LOOP AT result REFERENCE INTO DATA(line) WHERE subcolumn IS NOT INITIAL.

      SPLIT line->subcolumn AT ` ` INTO TABLE DATA(tab).

      line->t_sub_col = VALUE #( FOR t IN tab
                                 ( key = z2ui5_cl_util=>uuid_get_c32( ) fname = t ) ).

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
