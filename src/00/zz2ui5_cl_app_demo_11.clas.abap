CLASS zz2ui5_cl_app_demo_11 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    CLASS-METHODS factory
      IMPORTING
        i_log           TYPE bapirettab
      RETURNING
        VALUE(r_result) TYPE REF TO zz2ui5_cl_app_demo_11.

    DATA mt_log TYPE bapirettab.

    TYPES: BEGIN OF ty_row,
             id          TYPE string,
             name        TYPE string,
             value       TYPE string,
             test1       TYPE string,
             test2       TYPE string,
             check_valid TYPE abap_bool,
           END OF ty_row.

    DATA mt_tab TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.


ENDCLASS.

CLASS zz2ui5_cl_app_demo_11 IMPLEMENTATION.

  METHOD factory.

    r_result = NEW #( ).
    r_result->mt_log = i_log.

  ENDMETHOD.


  METHOD z2ui5_if_app~controller.

    CASE client->get( )-lifecycle_method.


      WHEN client->cs-_lifecycle_method-on_init.
        client->display_view( 'POPUP_BAL' ).

        mt_tab = VALUE #( id = '010'
          ( name = 'Hans' value = 'red' test1 = 'das ist ein langer text' test2 = 'das ist noch ein langer text' check_valid = abap_true )
          ( name = 'Hans' value = 'red' test1 = 'das ist ein langer text' test2 = 'das ist noch ein langer text' check_valid = abap_true )
          ( name = 'Hans' value = 'red' test1 = 'das ist ein langer text' test2 = 'das ist noch ein langer text' check_valid = abap_true )
          ( name = 'Hans' value = 'red' test1 = 'das ist ein langer text' test2 = 'das ist noch ein langer text' check_valid = abap_true )
          ( name = 'Hans' value = 'red' test1 = 'das ist ein langer text' test2 = 'das ist noch ein langer text' check_valid = abap_true )
          ( name = 'Hans' value = 'red' test1 = 'das ist ein langer text' test2 = 'das ist noch ein langer text' check_valid = abap_true )
          ( name = 'Hans' value = 'red' test1 = 'das ist ein langer text' test2 = 'das ist noch ein langer text' check_valid = abap_true )
          ( name = 'Hans' value = 'red' test1 = 'das ist ein langer text' test2 = 'das ist noch ein langer text' check_valid = abap_true )
          ( name = 'Hans' value = 'red' test1 = 'das ist ein langer text' test2 = 'das ist noch ein langer text' check_valid = abap_true )
          ( name = 'Hans' value = 'red' test1 = 'das ist ein langer text' test2 = 'das ist noch ein langer text' check_valid = abap_true )
        ).


      WHEN client->cs-_lifecycle_method-on_event.
        CASE client->get( )-event_id.

          WHEN 'BUTTON_BACK'.
            client->nav_to_app( client->get_app_called( ) ).

        ENDCASE.



      WHEN client->cs-_lifecycle_method-on_rendering.

       data(view) = client->factory_view( 'POPUP_BAL' ).
       data(lo_form) = view->page( ).

        DATA(lo_tab) = lo_form->scroll_container( height = '70%' )->table(
            items  = view->_bind( val = mt_tab type = view->cs-bind_type-two_way )
        ).

        lo_tab->header_toolbar( )->overflow_toolbar(
            )->title( 'title'
             )->toolbar_spacer(
             )->button( text = 'edit' on_press_id = 'BTN01'
             )->button( text = 'edit' on_press_id = 'BTN02'
          ).

        lo_tab->columns(
            )->column( text = 'Name'
            )->column( text = 'Value'
            )->column( text = 'Test1'
            )->column( text = 'Test2'
            )->column( text = 'Checkbox'
         )->get_parent( )->items( )->column_list_item( )->cells(
            )->text( '{NAME}'
            )->text( '{VALUE}'
            )->button( text = '{TEST1}' on_press_id = '{NAME}'
            )->input( value = '{TEST2}'
            )->checkbox( selected = '{CHECK_VALID}'
         ).

    ENDCASE.

  ENDMETHOD.

ENDCLASS.
