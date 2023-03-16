CLASS z2ui5_cl_app_demo_19 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    TYPES:
      BEGIN OF ty_row,
        selkz TYPE abap_bool,
        title TYPE string,
        value TYPE string,
        descr TYPE string,
      END OF ty_row.

    DATA t_tab TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.
    DATA t_tab_sel TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.
    DATA mv_sel_mode TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS Z2UI5_CL_APP_DEMO_19 IMPLEMENTATION.


  METHOD z2ui5_if_app~controller.

    CASE client->get( )-lifecycle_method.

      WHEN client->cs-lifecycle_method-on_init.
        mv_sel_mode = 'None'.
        t_tab = VALUE #( descr = 'this is a description'
            (  title = 'title_01'  value = 'value_01' )
            (  title = 'title_02'  value = 'value_02' )
            (  title = 'title_03'  value = 'value_03' )
            (  title = 'title_04'  value = 'value_04' )
            (  title = 'title_05'  value = 'value_05' ) ).

      WHEN client->cs-lifecycle_method-on_event.

        CASE client->get( )-event.
          WHEN 'BUTTON_SEGMENT_CHANGE'.
            client->popup_message_toast( `Selection Mode changed` ).

          WHEN 'BUTTON_READ_SEL'.
            t_tab_sel = t_tab.
            DELETE t_tab_sel WHERE selkz <> abap_true.

          WHEN 'BACK'.
            client->nav_app_leave( client->get( )-id_prev_app_stack ).

        ENDCASE.

      WHEN client->cs-lifecycle_method-on_rendering.

        DATA(view) = client->factory_view( ).
        DATA(page) = view->page( title = 'abap2ui5 - Table with different Selection-Modes' nav_button_tap = view->_event( 'BACK' ) ).

        page->header_content( )->link( text = 'Go to Source Code' href = client->get( )-s_request-url_source_code ).

        page->segmented_button(
           selected_key = view->_bind( mv_sel_mode )
           selection_change = view->_event( 'BUTTON_SEGMENT_CHANGE' )
          )->get( )->items( )->get(
                )->segmented_button_item( key = 'None'  text = 'None'
                )->segmented_button_item( key = 'SingleSelect' text = 'SingleSelect'
                )->segmented_button_item( key = 'SingleSelectLeft' text = 'SingleSelectLeft'
                )->segmented_button_item( key = 'SingleSelectMaster' text = 'SingleSelectMaster'
                )->segmented_button_item( key = 'MultiSelect' text = 'MultiSelect' ).

        DATA(tab) = page->table(
            header_text = 'Table'
            mode = mv_sel_mode
            items = view->_bind( t_tab ) ).

        tab->columns(
            )->column( )->text( 'Title' )->get_parent(
            )->column( )->text( 'Value' )->get_parent(
            )->column( )->text( 'Description' ).

        tab->items( )->column_list_item( selected = '{SELKZ}' )->cells(
           )->text( '{TITLE}'
           )->text( '{VALUE}'
           )->text( '{DESCR}' ).

        DATA(tab2) = page->table( view->_bind_one_way( t_tab_sel ) ).

        tab2->header_toolbar( )->overflow_toolbar(
            )->title( 'Selected Entries'
            )->button( icon = 'sap-icon://pull-down' text = 'copy selected entries' press = view->_event( 'BUTTON_READ_SEL' )
          ).

        tab2->columns(
            )->column( )->text( 'Title' )->get_parent(
            )->column( )->text( 'Value' )->get_parent(
            )->column( )->text( 'Description' ).

        tab2->items( )->column_list_item( )->cells(
           )->text( '{TITLE}'
           )->text( '{VALUE}'
           )->text( '{DESCR}' ).

    ENDCASE.

  ENDMETHOD.
ENDCLASS.
