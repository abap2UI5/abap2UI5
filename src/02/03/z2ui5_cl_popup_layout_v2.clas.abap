CLASS z2ui5_cl_popup_layout_v2 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_serializable_object .
    INTERFACES z2ui5_if_app .

    TYPES:
      BEGIN OF fixvalue,
        low        TYPE string,
        high       TYPE string,
        option     TYPE string,
        ddlanguage TYPE string,
        ddtext     TYPE string,
      END OF fixvalue,
      fixvalues TYPE STANDARD TABLE OF fixvalue WITH EMPTY KEY.

    TYPES ty_s_t001 TYPE z2ui5_t001.
    TYPES ty_t_t001 TYPE STANDARD TABLE OF ty_s_t001 WITH EMPTY KEY.

    TYPES ty_s_t002 TYPE z2ui5_t002.

    TYPES ty_t_t002 TYPE STANDARD TABLE OF ty_s_t002 WITH EMPTY KEY.

    TYPES BEGIN OF ty_s_layout.
    types s_head   TYPE ty_s_t001.
    types t_layout TYPE ty_t_t002.
    types  END OF ty_s_layout.

    TYPES:
      BEGIN OF ty_s_layo.
        INCLUDE TYPE z2ui5_t001.
    TYPES: selkz TYPE abap_bool,
      END OF ty_s_layo .
    TYPES:
      ty_t_layo TYPE STANDARD TABLE OF ty_s_layo WITH EMPTY KEY.


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

    CLASS-METHODS on_event_layout
      IMPORTING client        TYPE REF TO z2ui5_if_client
                layout        TYPE ty_s_layout
      RETURNING VALUE(result) TYPE REF TO z2ui5_if_client.

    CLASS-METHODS render_layout_function
      IMPORTING
        !xml          TYPE REF TO z2ui5_cl_xml_view
        !client       TYPE REF TO z2ui5_if_client
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    CLASS-METHODS init_layout
      IMPORTING
        !tab          TYPE REF TO data
        !class        TYPE string
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

  PROTECTED SECTION.

    DATA client        TYPE REF TO z2ui5_if_client.
    DATA mv_init       TYPE abap_bool.

    METHODS on_init.
    METHODS render_edit.
    METHODS on_event.

    METHODS select_layouts
      IMPORTING
        !class        TYPE string
        !tab          TYPE string
      RETURNING
        VALUE(result) TYPE ty_t_t001.

    METHODS render_save.
    METHODS save_layout.
    METHODS render_open.
    METHODS get_selected_layout.
    METHODS get_layouts.
    METHODS init_edit.
    METHODS render_delete.

  PRIVATE SECTION.

    METHODS delete_selected_layout.

    CLASS-METHODS get_comps_by_data
      IMPORTING !table        TYPE REF TO data
      RETURNING VALUE(result) TYPE abap_component_tab .

    CLASS-METHODS get_comps_by_table
      IMPORTING !table        TYPE STANDARD TABLE
      RETURNING VALUE(result) TYPE abap_component_tab.

    CLASS-METHODS get_relative_name_of_table
      IMPORTING !table        TYPE any
      RETURNING VALUE(result) TYPE string.

    CLASS-METHODS get_comp_by_struc
      IMPORTING
        type          TYPE REF TO cl_abap_datadescr
      RETURNING
        VALUE(result) TYPE abap_component_tab.

ENDCLASS.



CLASS z2ui5_cl_popup_layout_v2 IMPLEMENTATION.

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

      client->view_model_update(  ).

    ENDIF.

    on_event( ).

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
( low = 'None'   ddtext = 'Default, none priority' ) ).

  ENDMETHOD.


  METHOD render_edit.

    DATA(popup) = z2ui5_cl_xml_view=>factory_popup(  ).

    DATA(dialog) = popup->dialog( title        = 'Layout'
                                  contentwidth = '50%'
                                  afterclose   = client->_event( 'CLOSE' ) )->content( ).

    DATA(tab) = dialog->table( growing = abap_true
                               items   = client->_bind_edit( ms_layout-t_layout ) ).

    DATA(list) = tab->column_list_item(  ).

    DATA(cells) = list->cells( ).

    DATA(columns) = tab->columns( ).

    DATA(lt_comp) = get_comps_by_table( ms_layout-t_layout ).

    LOOP AT lt_comp REFERENCE INTO DATA(comp).

      CASE comp->name.
        WHEN 'FNAME'.
          DATA(col) = columns->column( )->header( ).
          col->text( 'Row' ).
        WHEN 'VISIBLE'.
          col = columns->column( )->header( ).
          col->text( 'Visible' ).
        WHEN 'MERGE'.
          CHECK mv_extended_layout = abap_true.
          col = columns->column( )->header( ).
          col->text( 'Merge duplicates' ).
        WHEN 'HALIGN'.
          CHECK mv_extended_layout = abap_true.
          col = columns->column( )->header( ).
          col->text( 'Align' ).
        WHEN 'IMPORTANCE'.
          CHECK mv_extended_layout = abap_true.
          col = columns->column( )->header( ).
          col->text( 'Importance' ).
*        WHEN 'WIDTH'.
*          CHECK mv_extended_layout = abap_true.
*          col = columns->column( )->header(  ).
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
               )->toolbar_spacer(
               )->button(
                   text  = 'Back'
                   icon  = 'sap-icon://nav-back'
                   press = client->_event( 'CLOSE' )
             )->button(
                   text  = 'Save'
                   press = client->_event( 'EDIT_SAVE' )
                   icon  = 'sap-icon://save'
                   type  = 'Emphasized'
             ).

    client->popup_display( popup->get_root( )->xml_get( ) ).


  ENDMETHOD.


  METHOD on_event.

    CASE client->get( )-event.

      WHEN 'CLOSE'.

        client->popup_destroy( ).

        client->nav_app_leave( client->get_app( client->get( )-s_draft-id_prev_app_stack ) ).

      WHEN 'EDIT_SAVE'.

        render_save( ).

      WHEN 'SAVE_CLOSE'.

        client->popup_destroy( ).

        render_edit(  ).

      WHEN 'SAVE_SAVE'.

        save_layout( ).

        client->popup_destroy( ).

        client->nav_app_leave( client->get_app( client->get( )-s_draft-id_prev_app_stack ) ).

      WHEN 'OPEN_SELECT'.

        get_selected_layout( ).

        client->popup_destroy( ).

        client->nav_app_leave( client->get_app( client->get( )-s_draft-id_prev_app_stack ) ).

      WHEN 'DELETE_SELECT'.

        get_selected_layout( ).

        delete_selected_layout( ).

*        ms_layout = init_layout( tab   = ms_layout-s_head-tab
*                                 class = ms_layout-s_head-class ).

        client->popup_destroy( ).

        client->nav_app_leave( client->get_app( client->get( )-s_draft-id_prev_app_stack ) ).
    ENDCASE.

  ENDMETHOD.


  METHOD factory.

    result = NEW #( ).

    result->ms_layout = layout.

    result->mv_open            = open_layout.
    result->mv_delete          = delete_layout.
    result->mv_extended_layout = extended_layout.

  ENDMETHOD.


  METHOD render_layout_function.

    result = xml.

    result->overflow_toolbar_menu_button( tooltip = 'Export' icon = 'sap-icon://action-settings'
       )->_generic( `menu`
          )->_generic( `Menu`
             )->menu_item( text =  'Change Layout'
                           icon = 'sap-icon://edit'
                           press = client->_event( val = 'LAYOUT_EDIT' )
             )->menu_item( text =  'Choose Layout'
                           icon = 'sap-icon://open-folder'
                           press = client->_event( val = 'LAYOUT_OPEN' )
             )->menu_item( text = 'Manage Layouts'
                           icon = 'sap-icon://delete'
                           press = client->_event( val = 'LAYOUT_DELETE' ) ).

  ENDMETHOD.


  METHOD render_save.

    DATA(popup) = z2ui5_cl_xml_view=>factory_popup(  ).

    DATA(dialog) = popup->dialog( title      = 'Save'
                                  afterclose = client->_event( 'SAVE_CLOSE' ) ).

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
                                        class   = ms_layout-s_head-class
                                        descr   = mv_descr
                                        def     = mv_def
                                        uname   = user
                                        tab     = ms_layout-s_head-tab ).

    LOOP AT ms_layout-t_layout INTO DATA(layout).

      t002  = VALUE #( BASE t002 ( layout   = mv_layout
                                   tab        = ms_layout-s_head-tab
                                   fname      = layout-fname
                                   rollname   = layout-rollname
                                   visible    = layout-visible
                                   halign     = layout-halign
                                   importance = layout-importance
                                   merge      = layout-merge
                                   width      = layout-width  ) ).

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


  METHOD render_delete.

    DATA(popup) = z2ui5_cl_xml_view=>factory_popup(  ).

    DATA(dialog) = popup->dialog( title      = 'Layout'
                                  afterclose = client->_event( 'CLOSE' ) ).

    dialog->table(
                headertext = 'Layout'
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


  METHOD render_open.

    DATA(popup) = z2ui5_cl_xml_view=>factory_popup(  ).

    DATA(dialog) = popup->dialog( title      = 'Layout'
                                  afterclose = client->_event( 'CLOSE' ) ).

    dialog->table(
                headertext = 'Layout'
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


  METHOD select_layouts.

    SELECT  * FROM z2ui5_t001
    WHERE class   = @class
    AND   tab     = @tab
    INTO CORRESPONDING FIELDS OF TABLE @result.
*    User?!
    ASSERT sy-subrc = 0.

  ENDMETHOD.


  METHOD get_selected_layout.


    DATA(t001) = VALUE #( mt_t001[ selkz = abap_true ] OPTIONAL ).

    IF t001 IS NOT INITIAL.

      SELECT SINGLE * FROM z2ui5_t001
      WHERE layout = @t001-layout
      AND   tab    = @t001-tab
      INTO CORRESPONDING FIELDS OF @ms_layout-s_head.
      ASSERT sy-subrc = 0.

      SELECT * FROM z2ui5_t002
      WHERE layout = @t001-layout
      AND   tab    = @t001-tab
      INTO CORRESPONDING FIELDS OF TABLE @ms_layout-t_layout.
      ASSERT sy-subrc = 0.

    ENDIF.

  ENDMETHOD.


  METHOD init_layout.

    " create the tab first if the db fields were added/deleted

    DATA(t_comp)   = get_comps_by_data( tab ).

    DATA(tab_name) = get_relative_name_of_table(  tab ).
    IF tab_name IS INITIAL.
      tab_name = class.
    ENDIF.


    LOOP AT t_comp REFERENCE INTO DATA(lr_comp).
      result-t_layout = VALUE ty_t_t002( BASE result-t_layout (
                      tab      = tab_name
                      fname    = lr_comp->name
                      rollname = lr_comp->type->get_relative_name( ) ) ).
    ENDLOOP.

* Select Layouts
    SELECT  layout,
            tab,
            descr,
            class,
            def,
            uname
     FROM z2ui5_t001
    WHERE class   = @class
    AND   tab     = @tab_name
    INTO TABLE @DATA(t_t001).
    ASSERT sy-subrc = 0.

* DEFAULT USER
    DATA(default) = VALUE #( t_t001[  class = class tab = tab_name def = abap_true uname = sy-uname ] OPTIONAL ).

    IF default IS INITIAL.
* DEFAULT
      default  = VALUE #( t_t001[ class = class tab = tab_name def = abap_true ] OPTIONAL ).
    ENDIF.


    IF default-layout IS NOT INITIAL.

      SELECT    mandt,
                layout,
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
      WHERE layout = @default-layout
      AND   tab    = @default-tab
      INTO TABLE @DATA(t_t002).
      ASSERT sy-subrc = 0.

      LOOP AT result-t_layout REFERENCE INTO DATA(layout).

        READ TABLE t_t002 REFERENCE INTO DATA(t002) WITH KEY fname = layout->fname.

        IF sy-subrc = 0.
          layout->* = t002->*.
        ELSE.
          layout->layout     = 'Default'.
          layout->halign     = 'Initial'.
          layout->importance = 'None'.
          layout->rollname   = layout->rollname.
          layout->fname      = layout->fname.
          layout->tab        = tab_name.
        ENDIF.

      ENDLOOP.

      result-s_head = default.
      RETURN.

    ENDIF.

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
    result-s_head-class  = class.
    result-s_head-tab    = tab_name.


  ENDMETHOD.


  METHOD get_layouts.

    mt_t001 = select_layouts(
      class = CONV #( ms_layout-s_head-class )
      tab   = CONV #( ms_layout-s_head-tab ) ).

    IF mt_t001 IS NOT INITIAL.

      DATA(t001) = REF #( mt_t001[  layout = ms_layout-s_head-layout ] OPTIONAL ).
      IF t001 IS BOUND.
        t001->selkz = abap_true.
        RETURN.
      ELSE.
        t001 = REF #( mt_t001[ 1 ] OPTIONAL ).
        t001->selkz = abap_true.
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

    CASE result->get( )-event.

      WHEN 'LAYOUT_OPEN'.
        client->view_destroy( ).
        result->nav_app_call( z2ui5_cl_popup_layout_v2=>factory( layout      = layout
                                                       open_layout = abap_true   ) ).

      WHEN 'LAYOUT_EDIT'.
        client->view_destroy( ).
        result->nav_app_call( z2ui5_cl_popup_layout_v2=>factory( layout = layout
                                                       extended_layout = abap_true   ) ).

      WHEN 'LAYOUT_DELETE'.
        client->view_destroy( ).
        result->nav_app_call( z2ui5_cl_popup_layout_v2=>factory( layout = layout
                                                       delete_layout = abap_true ) ).

    ENDCASE.

  ENDMETHOD.


  METHOD delete_selected_layout.

    DELETE  z2ui5_t001 FROM @ms_layout-s_head.
    DELETE  z2ui5_t002 FROM TABLE @ms_layout-t_layout.

    IF sy-subrc = 0.
      COMMIT WORK AND WAIT.
    ENDIF.

  ENDMETHOD.


  METHOD get_comps_by_data.

    TRY.
        result = get_comps_by_table( table->* ).
      CATCH cx_root.
    ENDTRY.


  ENDMETHOD.


  METHOD get_comps_by_table.

    TRY.
        DATA(typedesc) = cl_abap_typedescr=>describe_by_data( table ).

        CASE typedesc->kind.

          WHEN cl_abap_typedescr=>kind_table.
            DATA(tabledesc) = CAST cl_abap_tabledescr( typedesc ).
            DATA(structdesc) = CAST cl_abap_structdescr( tabledesc->get_table_line_type( ) ).

            DATA(comp) = structdesc->get_components( ).

            LOOP AT comp INTO DATA(com).


              IF com-as_include = abap_true.

                APPEND LINES OF  get_comp_by_struc( com-type ) TO result.

              ELSE.

                APPEND com TO result.

              ENDIF.

            ENDLOOP.


          WHEN OTHERS.
        ENDCASE.

      CATCH cx_root.
    ENDTRY.

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

  METHOD get_comp_by_struc.

    DATA struc TYPE REF TO cl_abap_structdescr.

    struc ?= type.

    DATA(comp) = struc->get_components( ).

    LOOP AT comp INTO DATA(com).


      IF com-as_include = abap_true.

        APPEND LINES OF  get_comp_by_struc( com-type ) TO result.

      ELSE.

        APPEND com TO result.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.