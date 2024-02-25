CLASS z2ui5_cl_popup_layout_v2 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app .

    TYPES:
      BEGIN OF fixvalue,
        low        TYPE string,
        high       TYPE string,
        option     TYPE string,
        ddlanguage TYPE string,
        ddtext     TYPE string,
      END OF fixvalue.

    TYPES fixvalues TYPE STANDARD TABLE OF fixvalue WITH EMPTY KEY.
    TYPES ty_s_t001 TYPE z2ui5_t001.
    TYPES ty_t_t001 TYPE STANDARD TABLE OF ty_s_t001 WITH EMPTY KEY.
    TYPES ty_s_t002 TYPE z2ui5_t002.
    TYPES ty_t_t002 TYPE STANDARD TABLE OF ty_s_t002 WITH EMPTY KEY.

    TYPES:
      BEGIN OF ty_s_layout,
        s_head   TYPE ty_s_t001,
        t_layout TYPE ty_t_t002,
      END OF ty_s_layout.

    TYPES:
      BEGIN OF ty_s_layo,
        mandt     TYPE mandt,
        layout    TYPE c LENGTH 12,
        tab       TYPE c LENGTH 30,
        descr     TYPE c LENGTH 50,
        classname TYPE c LENGTH 30,
        def       TYPE c LENGTH 1,
        uname     TYPE c LENGTH 12,
        selkz     TYPE abap_bool,
      END OF ty_s_layo.
    TYPES ty_t_layo TYPE STANDARD TABLE OF ty_s_layo WITH EMPTY KEY.

    DATA mt_t001 TYPE ty_t_layo.
    DATA ms_layout TYPE ty_s_layout.
    DATA mv_descr  TYPE string.
    DATA mv_layout TYPE string.
    DATA mv_def    TYPE abap_bool.
    DATA mv_usr    TYPE abap_bool.
    DATA mv_open   TYPE abap_bool.
    DATA mv_delete TYPE abap_bool.
    DATA mv_extended_layout TYPE abap_bool.
    DATA mt_halign     TYPE fixvalues.
    DATA mt_importance TYPE fixvalues.

    CLASS-METHODS init_layout
      IMPORTING
        !tab          TYPE REF TO data
        !classname    TYPE string
      RETURNING
        VALUE(result) TYPE ty_s_layout.

    CLASS-METHODS factory
      IMPORTING
        !layout          TYPE ty_s_layout
        !open_layout     TYPE abap_bool OPTIONAL
        !delete_layout   TYPE abap_bool OPTIONAL
        !extended_layout TYPE abap_bool OPTIONAL
      RETURNING
        VALUE(result)    TYPE REF TO z2ui5_cl_popup_layout_v2.

    TYPES:
      BEGIN OF ty_s_result,
        check_cancel TYPE abap_bool,
        s_layout     TYPE ty_s_layout,
      END OF ty_s_result.

    DATA ms_result TYPE ty_s_result.

    METHODS result
      RETURNING
        VALUE(result) TYPE ty_s_result.

  PROTECTED SECTION.

    DATA client        TYPE REF TO z2ui5_if_client.
    DATA mv_init       TYPE abap_bool.



    METHODS on_init.
    METHODS render_edit.
    METHODS on_event.

    METHODS select_layouts
      IMPORTING
        !classname    TYPE string
        !tab          TYPE string
      RETURNING
        VALUE(result) TYPE ty_t_t001.

    METHODS render_save.
    METHODS save_layout.
    METHODS render_open.
    METHODS get_selected_layout
      RETURNING VALUE(result) TYPE ty_s_layout.
    METHODS get_layouts.
    METHODS init_edit.
    METHODS render_delete.
    METHODS db_delete_layout.

    CLASS-METHODS db_read_head
      IMPORTING
        i_classname     TYPE string
        i_tab           TYPE string
      RETURNING
        VALUE(r_result) TYPE ty_t_t001.

    CLASS-METHODS db_read_layout
      IMPORTING
        layout        TYPE clike
        tab           TYPE clike
      RETURNING
        VALUE(result) TYPE ty_s_layout.

    CLASS-METHODS db_read_layout_multi
      IMPORTING
        i_classname   TYPE string
        i_tab_name    TYPE string
      RETURNING
        VALUE(r_t001) TYPE ty_t_t001.

    CLASS-METHODS db_read_layout_info
      IMPORTING
        i_def         TYPE z2ui5_t001
      RETURNING
        VALUE(r_t002) TYPE ty_t_t002.

  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_popup_layout_v2 IMPLEMENTATION.


  METHOD db_delete_layout.

    DATA(layout) = get_selected_layout( ).

    DELETE  z2ui5_t001 FROM @layout-s_head.
    DELETE  z2ui5_t002 FROM TABLE @layout-t_layout.

    IF sy-subrc = 0.
      COMMIT WORK AND WAIT.
    ENDIF.

  ENDMETHOD.


  METHOD db_read_head.

    SELECT  * FROM z2ui5_t001
    WHERE classname  = @i_classname
    AND   tab        = @i_tab
    INTO CORRESPONDING FIELDS OF TABLE @r_result ##SUBRC_OK.

  ENDMETHOD.


  METHOD db_read_layout.

    SELECT SINGLE * FROM z2ui5_t001
    WHERE layout  = @layout
    AND   tab     = @tab
    AND   handle1 = ``
    AND   handle2 = ``
    INTO CORRESPONDING FIELDS OF @result-s_head ##SUBRC_OK.

    SELECT * FROM z2ui5_t002
    WHERE layout = @layout
    AND   tab    = @tab
    AND   handle1 = ``
    AND   handle2 = ``
    INTO CORRESPONDING FIELDS OF TABLE @result-t_layout ##SUBRC_OK.

  ENDMETHOD.


  METHOD db_read_layout_info.

    SELECT    layout,
              tab,
              fname,
              rollname,
              visible,
              halign,
              importance,
              merge,
              width,
              text
     FROM z2ui5_t002
    WHERE layout = @i_def-layout
    AND   tab    = @i_def-tab
    INTO CORRESPONDING FIELDS OF TABLE @r_t002 ##SUBRC_OK.

  ENDMETHOD.


  METHOD db_read_layout_multi.

    SELECT  layout,
            tab,
            descr,
            classname,
            def,
            uname
     FROM z2ui5_t001
    WHERE classname   = @i_classname
    AND   tab     = @i_tab_name
    INTO CORRESPONDING FIELDS OF TABLE @r_t001 ##SUBRC_OK.

  ENDMETHOD.


  METHOD factory.

    result = NEW #( ).

    result->ms_layout          = layout.
    result->mv_open            = open_layout.
    result->mv_delete          = delete_layout.
    result->mv_extended_layout = extended_layout.

  ENDMETHOD.


  METHOD get_layouts.

    mt_t001 = select_layouts(
      classname = CONV #( ms_layout-s_head-classname )
      tab       = CONV #( ms_layout-s_head-tab ) ).

    IF mt_t001 IS NOT INITIAL.

      DATA(t001) = REF #( mt_t001[ layout = ms_layout-s_head-layout ] OPTIONAL ).
      IF t001 IS BOUND.
        t001->selkz = abap_true.
        RETURN.
      ELSE.
        t001 = REF #( mt_t001[ 1 ] OPTIONAL ).
        t001->selkz = abap_true.
      ENDIF.

    ENDIF.

  ENDMETHOD.


  METHOD get_selected_layout.

    DATA(t001) = VALUE #( mt_t001[ selkz = abap_true ] OPTIONAL ).
    IF t001 IS NOT INITIAL.

      result = db_read_layout(
           layout = t001-layout
           tab    = t001-tab ).

    ENDIF.

  ENDMETHOD.


  METHOD init_edit.

    mv_layout = ms_layout-s_head-layout.
    mv_descr  = ms_layout-s_head-descr.
    mv_def    = ms_layout-s_head-def.

    mv_usr    = xsdbool( ms_layout-s_head-uname IS NOT INITIAL ).

  ENDMETHOD.


  METHOD init_layout.

    " create the tab first if the db fields were added/deleted

    DATA(t_comp)   = z2ui5_cl_util=>rtti_get_t_attri_by_struc( tab ).
    DATA(tab_name) = z2ui5_cl_util=>rtti_tab_get_relative_name( tab ).
    IF tab_name IS INITIAL.
      tab_name = classname.
    ENDIF.


    LOOP AT t_comp REFERENCE INTO DATA(lr_comp).
      INSERT VALUE #(
                     tab      = tab_name
                     fname    = lr_comp->name
                     rollname = lr_comp->type->get_relative_name( ) ) INTO TABLE result-t_layout.
    ENDLOOP.

* Select Layouts
    DATA(t_t001) = db_read_layout_multi(
          i_classname = classname
          i_tab_name  = tab_name ).

* DEFAULT USER
    DATA(def) = VALUE #( t_t001[  classname = classname tab = tab_name def = abap_true uname = sy-uname ] OPTIONAL ).

    IF def IS INITIAL.
* DEFAULT
      def  = VALUE #( t_t001[ classname = classname tab = tab_name def = abap_true ] OPTIONAL ).
    ENDIF.


    IF def-layout IS NOT INITIAL.

      DATA(t_t002) = db_read_layout_info( def ).

      LOOP AT result-t_layout REFERENCE INTO DATA(layout).

        TRY.
            DATA(t002) = REF #( t_t002[ fname = layout->fname ] ).
            layout->* = t002->*.
          CATCH cx_root.
            layout->layout     = 'Default'.
            layout->halign     = 'Initial'.
            layout->importance = 'None'.
            layout->rollname   = layout->rollname.
            layout->fname      = layout->fname.
            layout->tab        = tab_name.
        ENDTRY.

      ENDLOOP.

      result-s_head = def.

    ELSE.

*  Default Layout
      DATA(index) = 0.

      LOOP AT result-t_layout REFERENCE INTO layout.

        index = index + 1.

* Default ony 10 rows
        IF index <= 10.
          layout->visible = abap_true.
        ENDIF.

        IF layout->fname = 'MANDT' OR  layout->fname = 'ROW_ID'.
          layout->visible = abap_false.
        ENDIF.

        layout->layout     = 'Default'.
        layout->halign     = 'Initial'.
        layout->importance = 'None'.
        layout->tab        = tab_name.

      ENDLOOP.

      result-s_head-layout = 'Default'.
      result-s_head-descr  = 'System generated Layout'.
      result-s_head-def    = abap_true.
      result-s_head-classname  = classname.
      result-s_head-tab    = tab_name.

    ENDIF.
  ENDMETHOD.


  METHOD on_event.

    CASE client->get( )-event.

      WHEN 'CANCEL'.
        ms_result-check_cancel = abap_true.
        client->popup_destroy( ).
        client->nav_app_leave( ).

      WHEN 'OK'.
        client->popup_destroy( ).
        client->nav_app_leave( ).

      WHEN 'LAYOUT_SAVE'.
        render_save( ).

      WHEN 'CLOSE'.
        client->nav_app_leave( ).

      WHEN 'SAVE_CLOSE'.
        render_edit(  ).

      WHEN 'SAVE_SAVE'.
        save_layout( ).
        render_edit(  ).

      WHEN 'OPEN_SELECT'.
        ms_layout = get_selected_layout( ).
        client->popup_destroy( ).
        client->nav_app_leave( ).

      WHEN 'DELETE_SELECT'.
        db_delete_layout( ).
        client->popup_destroy( ).
        client->nav_app_leave( ).

      WHEN 'LAYOUT_LOAD'.
        client->nav_app_call( factory( layout = ms_layout
                                       open_layout = abap_true   ) ).

      WHEN 'LAYOUT_DELETE'.
        client->nav_app_call( factory( layout = ms_layout
                                       delete_layout = abap_true ) ).

    ENDCASE.

  ENDMETHOD.


  METHOD on_init.

    mt_halign     = VALUE #(
        ( low = 'Begin'     ddtext = 'Locale-specific positioning at the beginning of the line' )
        ( low = 'Center'    ddtext = 'Centered text alignment'                                  )
        ( low = 'End'       ddtext = 'Locale-specific positioning at the end of the line'       )
        ( low = 'Initial'   ddtext = 'Sets no text align, so the browser default is used'       )
        ( low = 'Left'      ddtext = 'Hard option for left alignment'                           )
        ( low = 'Right'     ddtext = 'Hard option for right alignment'                          )
    ).

    mt_importance = VALUE #(
        ( low = 'High'   ddtext = 'High priority'          )
        ( low = 'Low'    ddtext = 'Low priority'           )
        ( low = 'Medium' ddtext = 'Medium priority'        )
        ( low = 'None'   ddtext = 'Default, none priority' )
    ).

  ENDMETHOD.


  METHOD render_delete.

    DATA(popup) = z2ui5_cl_xml_view=>factory_popup(  ).

    DATA(dialog) = popup->dialog( title      = 'Layout - Delete'
            contentheight = `50%`
                                 contentwidth  = `50%`
                                  afterclose = client->_event( 'CLOSE' ) ).

    dialog->table(
*                headertext = 'Layout'
                mode = 'SingleSelectLeft'
                items = client->_bind_edit( mt_t001 )
                )->columns(
                    )->column( )->text( 'Layout' )->get_parent(
                    )->column( )->text( 'Description'
                    )->get_parent( )->get_parent(
                )->items(
                    )->column_list_item( selected = '{SELKZ}'
                        )->cells(
                            )->text( '{LAYOUT}'
                            )->text( '{DESCR}' ).

    dialog->footer( )->overflow_toolbar(
          )->toolbar_spacer(
          )->button(
                text  = 'Back'
                icon  = 'sap-icon://nav-back'
                press = client->_event( 'CLOSE' )
          )->button(
                text  = 'Delete'
                press = client->_event( 'DELETE_SELECT' )
                type  = 'Reject'
                icon  = 'sap-icon://delete' ).

    client->popup_display( popup->stringify( ) ).

  ENDMETHOD.


  METHOD render_edit.

    DATA(popup) = z2ui5_cl_xml_view=>factory_popup(  ).
    DATA(dialog) = popup->dialog( title        = 'Layout'
                                        contentheight = `50%`
                                 contentwidth  = `50%`
                                  afterclose   = client->_event( 'CANCEL' ) )->content( ).

    DATA(tab) = dialog->table( growing = abap_true
                               items   = client->_bind_edit( ms_layout-t_layout ) ).

    DATA(list) = tab->column_list_item(  ).
    DATA(cells) = list->cells( ).
    DATA(columns) = tab->columns( ).
    DATA(lt_comp) = z2ui5_cl_util=>rtti_get_t_attri_by_struc( ms_layout-t_layout ).

    LOOP AT lt_comp REFERENCE INTO DATA(comp).

      CASE comp->name.
        WHEN 'FNAME'.
          DATA(col) = columns->column( )->header(  `` ).
          col->text( 'Row' ).
        WHEN 'VISIBLE'.
          col = columns->column( )->header( `` ).
          col->text( 'Visible' ).
        WHEN 'MERGE'.
          CHECK mv_extended_layout = abap_true.
          col = columns->column( )->header(  `` ).
          col->text( 'Merge duplicates' ).
        WHEN 'HALIGN'.
          CHECK mv_extended_layout = abap_true.
          col = columns->column( )->header(  `` ).
          col->text( 'Align' ).
        WHEN 'IMPORTANCE'.
          CHECK mv_extended_layout = abap_true.
          col = columns->column( )->header(  `` ).
          col->text( 'Importance' ).
*        WHEN 'WIDTH'.
*          CHECK mv_extended_layout = abap_true.
*          col = columns->column( )->header( `` ).
*          col->text( 'Width in px' ).
      ENDCASE.

    ENDLOOP.

    LOOP AT lt_comp REFERENCE INTO comp.

      CASE comp->name.
        WHEN 'FNAME'.

          cells->text( `{` && comp->name && `}` ).

        WHEN 'VISIBLE' OR 'MERGE'.

          cells->switch( type  = 'AcceptReject'
                         state = `{` && comp->name && `}` ).

        WHEN 'HALIGN'.

          cells->combobox(
                    selectedkey = `{` && comp->name && `}`
                    items       = client->_bind_local( mt_halign )
                        )->item(
                            key = '{LOW}'
                            text = '{LOW} - {DDTEXT}' ).

        WHEN 'IMPORTANCE'.

          cells->combobox(
                    selectedkey = `{` && comp->name && `}`
                    items       = client->_bind_local( mt_importance )
                        )->item(
                            key = '{LOW}'
                            text = '{LOW} - {DDTEXT}' ).

*        WHEN 'WIDTH'.
*
*          cells->input( value = `{` && comp->name && `}` ).

      ENDCASE.

    ENDLOOP.

    dialog->get_parent(
           )->footer( )->overflow_toolbar(
              )->button(
                   text  = 'DB Delete'
                   press = client->_event( 'LAYOUT_DELETE' )
                   icon  = 'sap-icon://delete'
              )->button(
                   text  = 'DB Read'
                   press = client->_event( 'LAYOUT_LOAD' )
                   icon  = 'sap-icon://download-from-cloud'
             )->button(
                   text  = 'DB Save'
                   press = client->_event( 'LAYOUT_SAVE' )
                   icon  = 'sap-icon://save'
                     )->toolbar_spacer(
                                  )->button(
                   text  = 'Cancel'
                   icon  = 'sap-icon://sys-cancel-2'
                   press = client->_event( 'CANCEL' )
             )->button(
                   text  = 'OK'
                   icon  = 'sap-icon://accept'
                   press = client->_event( 'OK' )
                   type  = 'Emphasized'
                   ).

    client->popup_display( popup->get_root( )->xml_get( ) ).


  ENDMETHOD.


  METHOD render_open.

    DATA(popup) = z2ui5_cl_xml_view=>factory_popup(  ).

    DATA(dialog) = popup->dialog( title      = 'Layout - Open'
            contentheight = `50%`
                                 contentwidth  = `50%`
                                  afterclose = client->_event( 'CLOSE' ) ).

    dialog->table(
*                headertext = 'Layout'
                mode = 'SingleSelectLeft'
                items = client->_bind_edit( mt_t001 )
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

    dialog->footer( )->overflow_toolbar(
          )->toolbar_spacer(
          )->button(
                text  = 'Back'
                icon  = 'sap-icon://nav-back'
                press = client->_event( 'CLOSE' )
          )->button(
                text  = 'Open'
                icon  = 'sap-icon://accept'
                press = client->_event( 'OPEN_SELECT' )
                type  = 'Emphasized' ).

    client->popup_display( popup->stringify( ) ).

  ENDMETHOD.


  METHOD render_save.

    DATA(popup) = z2ui5_cl_xml_view=>factory_popup(  ).

    DATA(dialog) = popup->dialog( title      = 'Layout - Save'
            contentheight = `50%`
                                 contentwidth  = `50%`
                                  afterclose = client->_event( 'SAVE_CLOSE' ) ).

    DATA(form) = dialog->simple_form(
*    title           = 'Layout'
                                      editable        = abap_true
                                      labelspanxl     = `4`
                                      labelspanl      = `4`
                                      labelspanm      = `4`
                                      labelspans      = `4`
                                      adjustlabelspan = abap_false
                                      ).

*    form->toolbar( )->title( 'Layout' ).

    form->content( 'form'
                           )->label( 'Layout'
                           )->input( client->_bind_edit( mv_layout )
                           )->label( 'Description'
                           )->input( client->_bind_edit( mv_descr ) ).

    form->toolbar( )->title( `` ).

    form->content( 'form'
                           )->label( 'Default Layout'
                           )->switch( type = 'AcceptReject' state = client->_bind_edit( mv_def )
                           )->label( 'User specific'
                           )->switch( type = 'AcceptReject' state = client->_bind_edit( mv_usr )
                           ).

    dialog->footer( )->overflow_toolbar(
          )->toolbar_spacer(
          )->button(
                text  = 'Back'
                icon  = 'sap-icon://nav-back'
                press = client->_event( 'SAVE_CLOSE' )
          )->button(
                text  = 'Save'
                press = client->_event( 'SAVE_SAVE' )
                type  = 'Success'
                icon  = 'sap-icon://save' ).

    client->popup_display( popup->get_root( )->xml_get( ) ).

  ENDMETHOD.


  METHOD result.

    ms_result-s_layout = ms_layout.
    result = ms_result.

  ENDMETHOD.


  METHOD save_layout.

    DATA t002 TYPE STANDARD TABLE OF z2ui5_t002 WITH EMPTY KEY.

    IF mv_layout IS INITIAL.
      client->message_toast_display( 'Layoutname missing.' ).
      RETURN.
    ENDIF.

    IF mv_usr = abap_true.
      DATA(user) = sy-uname.
    ENDIF.

    DATA(t001) = VALUE z2ui5_t001(      layout  = mv_layout
                                        classname   = ms_layout-s_head-classname
                                        descr   = mv_descr
                                        def     = mv_def
                                        uname   = user
                                        tab     = ms_layout-s_head-tab ).

    LOOP AT ms_layout-t_layout INTO DATA(layout).

      INSERT VALUE #( layout   = mv_layout
                                   tab        = ms_layout-s_head-tab
                                   fname      = layout-fname
                                   rollname   = layout-rollname
                                   visible    = layout-visible
                                   halign     = layout-halign
                                   importance = layout-importance
                                   merge      = layout-merge
                                   width      = layout-width  ) INTO TABLE t002.

    ENDLOOP.

    " gibt es das Layyout schon?
    SELECT SINGLE layout FROM z2ui5_t001
    WHERE layout = @t001-layout
    AND   tab    = @t001-tab
    INTO @t001-layout.

    IF sy-subrc = 0.

* postionen lesen und loeschen
      SELECT    layout,
                tab,
                fname,
                rollname,
                visible,
                halign,
                importance,
                merge,
                width
       FROM z2ui5_t002
      WHERE layout = @t001-layout
      AND   tab    = @t001-tab
      INTO TABLE @DATA(del).

      IF sy-subrc = 0.
        DELETE z2ui5_t002 FROM TABLE @del.
        COMMIT WORK AND WAIT.
      ENDIF.

    ENDIF.

    MODIFY z2ui5_t001 FROM @t001.
    IF sy-subrc = 0.

      MODIFY z2ui5_t002 FROM TABLE @t002.

      IF sy-subrc = 0.

        COMMIT WORK AND WAIT.

        client->message_toast_display( 'Data saved.' ).

        ms_layout-s_head = t001.
        ms_layout-t_layout = t002.

      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD select_layouts.

    result = db_read_head(
          i_classname = classname
          i_tab       = tab ).


  ENDMETHOD.


  METHOD z2ui5_if_app~main.

    me->client = client.

    IF mv_init = abap_false.
      mv_init = abap_true.
      on_init( ).

      CASE abap_true.
        WHEN mv_open.
          get_layouts( ).
          render_open( ).

        WHEN mv_delete.
          get_layouts( ).
          render_delete( ).

        WHEN OTHERS.
          init_edit( ).
          render_edit( ).

      ENDCASE.

      RETURN.
    ENDIF.

    IF client->get( )-check_on_navigated = abap_true.

      TRY.
          DATA(app) = CAST z2ui5_cl_popup_layout_v2( client->get_app( client->get( )-s_draft-id_prev_app ) ).
          DATA(ls_result) = app->result( ).
          IF ls_result-check_cancel = abap_true.
            RETURN.
          ENDIF.
          ms_layout = app->ms_layout.

        CATCH cx_root.
      ENDTRY.

      render_edit( ).
      RETURN.
    ENDIF.

    on_event( ).

  ENDMETHOD.
ENDCLASS.
