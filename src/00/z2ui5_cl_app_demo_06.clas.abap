CLASS z2ui5_cl_app_demo_06 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    TYPES:
      BEGIN OF ty_row,
        title    TYPE string,
        value    TYPE string,
        descr    TYPE string,
        icon     TYPE string,
        info     TYPE string,
        checkbox TYPE abap_bool,
      END OF ty_row.

    DATA t_tab TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.
    DATA check_initialized TYPE abap_bool.
    data mv_key type string.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS Z2UI5_CL_APP_DEMO_06 IMPLEMENTATION.


  METHOD z2ui5_if_app~controller.

    CASE client->get( )-lifecycle_method.

      WHEN client->cs-lifecycle_method-on_event.

        IF check_initialized = abap_false.
          check_initialized = abap_true.

          DO 1000 TIMES.
            DATA(ls_row) = VALUE ty_row( title = 'row_' && sy-index  value = 'red' info = 'completed'  descr = 'this is a description' checkbox = abap_true ).
            INSERT ls_row INTO TABLE t_tab.
          ENDDO.

          RETURN.
        ENDIF.

        CASE client->get( )-event.

          WHEN 'BUTTON_SORT'.
            client->popup_message_box( 'button sort was pressed' ).
            SORT t_tab BY value.

          WHEN 'BUTTON_POST'.
            client->popup_message_box( 'button post was pressed' ).

          WHEN 'BACK'.
            client->nav_app_leave( client->get( )-id_prev_app_stack ).

        ENDCASE.

      WHEN client->cs-lifecycle_method-on_rendering.

        DATA(page) = client->factory_view(
            )->page(
                title          = 'abap2UI5 - Scroll Container with Table and Toolbar'
                navbuttonpress = client->_event( 'BACK' )
                )->header_content(
                    )->link(
                        text = 'Source_Code'
                        href = client->get( )-s_request-url_source_code
            )->get_parent( ).

        DATA(tab) = page->scroll_container( height = '70%' vertical = abap_true
            )->table(
                growing             = abap_true
                growingthreshold    = '20'
                growingscrolltoload = abap_true
                items               = client->_bind_one_way( t_tab )
                sticky              = 'ColumnHeaders,HeaderToolbar' ).

        tab->header_toolbar(
            )->overflow_toolbar(
                )->title( 'title of the table'
                )->button(
                    text  = 'letf side button'
                    icon  = 'sap-icon://account'
                    press = client->_event( 'BUTTON_SORT' )
                )->segmented_button( selected_key = mv_key
                    )->items(
                        )->segmented_button_item(
                            key = 'BLUE'
                            icon = 'sap-icon://accept'
                            text = 'blue'
                        )->segmented_button_item(
                            key = 'GREEN'
                            icon = 'sap-icon://add-favorite'
                            text = 'green'
                )->get_parent( )->get_parent(
                )->toolbar_spacer(
                )->generic_tag(
                        arialabelledby = 'genericTagLabel'
                        text           = 'Project Cost'
                        design         = 'StatusIconHidden'
                        status         = 'Error'
                        class          = 'sapUiSmallMarginBottom'
                    )->object_number(
                        state      = 'Error'
                        emphasized = 'false'
                        number     = '3.5M'
                        unit       = 'EUR'
                )->get_parent(
                )->toolbar_spacer(
                )->button(
                    text  = 'Sort'
                    icon = 'sap-icon://sort-descending'
                    press = client->_event( 'BUTTON_SORT' )
                )->button(
                    icon  = 'sap-icon://edit'
                    press = client->_event( 'BUTTON_POST' ) ).

        tab->columns(
            )->column(
                )->text( 'Title' )->get_parent(
            )->column(
                )->text( 'Color' )->get_parent(
            )->column(
                )->text( 'Info' )->get_parent(
            )->column(
                )->text( 'Description' )->get_parent(
            )->column(
                )->text( 'Checkbox' ).

        tab->items( )->column_list_item( )->cells(
           )->text( '{TITLE}'
           )->text( '{VALUE}'
           )->text( '{INFO}'
           )->text( '{DESCR}'
           )->checkbox( '{CHECKBOX}' ).

    ENDCASE.

  ENDMETHOD.
ENDCLASS.
