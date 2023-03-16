CLASS z2ui5_cl_app_demo_23 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    TYPES:
      BEGIN OF ty_row,
        selkz TYPE abap_bool,
        title TYPE string,
        value TYPE string,
        descr TYPE string,
      END OF ty_row,
      ty_tab TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.

    CLASS-METHODS factory
      IMPORTING
        i_tab          TYPE ty_tab
        event_callback type clike
      RETURNING
        VALUE(r_result) TYPE REF TO z2ui5_cl_app_demo_23.

    data mv_event_return type string.
    DATA t_tab TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_app_demo_23 IMPLEMENTATION.

  METHOD factory.

    r_result = NEW #( ).
    r_result->t_tab = i_tab.
    r_result->mv_event_return = event_callback.

  ENDMETHOD.




  METHOD z2ui5_if_app~controller.

    CASE client->get( )-lifecycle_method.

      WHEN client->cs-lifecycle_method-on_init.

      WHEN client->cs-lifecycle_method-on_event.

        CASE client->get( )-event.

          WHEN 'BUTTON_SEND'.
            client->set( event = mv_event_return ).
            client->nav_app_leave( client->get( )-id_prev_app_stack ).

        WHEN 'BACK'.
            client->nav_app_leave( client->get( )-id_prev_app_stack ).
        ENDCASE.

      WHEN client->cs-lifecycle_method-on_rendering.

        DATA(view) = client->factory_view( ).
        DATA(page) = view->page( title = 'abap2ui5 - Table with different Selection-Modes' nav_button_tap = view->_event( 'BACK' ) ).

        page->header_content( )->link( text = 'Go to Source Code' href = client->get( )-s_request-url_source_code ).

        DATA(tab) = page->table(
            header_text = 'Table'
            mode =  'SingleSelectLeft'
            items = view->_bind( t_tab ) ).

        tab->columns(
            )->column( )->text( 'Title' )->get_parent(
            )->column( )->text( 'Value' )->get_parent(
            )->column( )->text( 'Description' ).

        tab->items( )->column_list_item( selected = '{SELKZ}' )->cells(
           )->text( '{TITLE}'
           )->text( '{VALUE}'
           )->text( '{DESCR}' ).

        page->footer( )->overflow_toolbar(
             )->toolbar_spacer(
             )->button(
                 text  = 'Confirm'
                 press = view->_event( 'BUTTON_SEND' )
                 type  = 'Success' ).


    ENDCASE.

  ENDMETHOD.

ENDCLASS.
