CLASS z2ui5_cl_app_demo_06 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    TYPES:
      BEGIN OF ty_row,
        count    TYPE i,
        value    TYPE string,
        descr    TYPE string,
        icon     TYPE string,
        info     TYPE string,
        checkbox TYPE abap_bool,
      END OF ty_row.

    DATA t_tab TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.
    DATA check_initialized TYPE abap_bool.
    DATA mv_key TYPE string.
    METHODS refresh_data.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS Z2UI5_CL_APP_DEMO_06 IMPLEMENTATION.


  METHOD refresh_data.

    DO 1000 TIMES.
      DATA(ls_row) = VALUE ty_row( count = sy-index  value = 'red'
        info = COND #( WHEN sy-index < 50 THEN 'completed' ELSE 'uncompleted' )
        descr = 'this is a description' checkbox = abap_true ).
      INSERT ls_row INTO TABLE t_tab.
    ENDDO.

  ENDMETHOD.


  METHOD z2ui5_if_app~main.

    IF check_initialized = abap_false.
      check_initialized = abap_true.
      refresh_data( ).
    ENDIF.

    CASE client->get( )-event.

      WHEN 'SORT_ASCENDING'.
        SORT t_tab BY count ASCENDING.
        client->popup_message_toast( 'sort ascending' ).

      WHEN 'SORT_DESCENDING'.
        SORT t_tab BY count DESCENDING.
        client->popup_message_toast( 'sort descending' ).

      WHEN 'BUTTON_POST'.
        client->popup_message_box( 'button post was pressed' ).

      WHEN 'BACK'.
        client->nav_app_leave( client->get_app( client->get( )-id_prev_app_stack ) ).

    ENDCASE.


    DATA(page) = Z2UI5_CL_XML_VIEW=>factory( )->shell(
        )->page(
            title          = 'abap2UI5 - Scroll Container with Table and Toolbar'
            navbuttonpress = client->_event( 'BACK' )
            shownavbutton  = abap_true
            )->header_content(
                )->link(
                    text = 'Source_Code'  target = '_blank'
                    href = Z2UI5_CL_XML_VIEW=>hlp_get_source_code_url( app = me get = client->get( ) )
        )->get_parent( ).

    DATA(tab) = page->scroll_container( height = '70%' vertical = abap_true
        )->table(
            growing             = abap_true
            growingthreshold    = '20'
            growingscrolltoload = abap_true
            items               = client->_bind_one( t_tab )
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
                text  = 'counter descending'
                icon = 'sap-icon://sort-descending'
                press = client->_event( 'SORT_DESCENDING' )
                        )->button(
                text  = 'counter ascending'
                icon = 'sap-icon://sort-ascending'
                press = client->_event( 'SORT_ASCENDING' )
            ).

    tab->columns(
        )->column(
            )->text( 'Color' )->get_parent(
        )->column(
            )->text( 'Info' )->get_parent(
        )->column(
            )->text( 'Description' )->get_parent(
        )->column(
            )->text( 'Checkbox' )->get_parent(
         )->column(
            )->text( 'Counter' ).

    tab->items( )->column_list_item( )->cells(
       )->text( '{VALUE}'
       )->text( '{INFO}'
       )->text( '{DESCR}'
       )->checkbox( selected = '{CHECKBOX}' enabled = abap_false
       )->text( '{COUNT}' ).

    client->set_next( VALUE #( xml_main = page->get_root( )->xml_get( ) )  ).

  ENDMETHOD.
ENDCLASS.
