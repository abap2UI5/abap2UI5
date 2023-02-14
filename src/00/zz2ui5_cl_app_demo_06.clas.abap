CLASS zz2ui5_cl_app_demo_06 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.
    CLASS-METHODS create
      RETURNING
        VALUE(r_result) TYPE REF TO zz2ui5_cl_app_demo_06.


    TYPES: BEGIN OF ty_row,
             id          TYPE string,
             name        TYPE string,
             value       TYPE string,
             test1       TYPE string,
             test2       TYPE string,
             check_valid TYPE abap_bool,
           END OF ty_row.

    DATA mt_tab TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.

    DATA: mv_check_active TYPE abap_bool.
    DATA mv_text TYPE string.
    DATA mv_text_long TYPE string.
    DATA type TYPE string.

ENDCLASS.

CLASS zz2ui5_cl_app_demo_06 IMPLEMENTATION.

  METHOD create.

    r_result = NEW #( ).


  ENDMETHOD.



  METHOD z2ui5_if_app~controller.


    CASE client->get( )-lifecycle_method.


      WHEN client->cs-_lifecycle_method-on_init.
        client->display_view( 'TABLE' ).

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
            ( name = 'Hans' value = 'red' test1 = 'das ist ein langer text' test2 = 'das ist noch ein langer text' check_valid = abap_true )
         ).


      WHEN client->cs-_lifecycle_method-on_event.
        CASE client->get( )-event_id.

          WHEN 'BUTTON_BACK'.
            client->nav_to_app( client->get_app_called( ) ).

          WHEN 'EDIT'.
            mv_check_active = xsdbool( mv_check_active = abap_false ).

        ENDCASE.



      WHEN client->cs-_lifecycle_method-on_rendering.

*        DATA(lo_page) = client->factory_view( 'TABLE' )->add_page(
*            title = 'SE16 - edit'
*            ).
*
*        DATA(lo_tab) = lo_page->add_table(
*                 items  = mt_tab
*                 zz_check_update_model = abap_true
*             ).
*
*        lo_tab->add_header_toolbar( )->add_overflow_toolbar(
*            )->add_title( 'title'
*             )->add_toolbar_spacer(
*             )->add_button( text = 'edit' on_press_id = 'EDIT'
*             )->add_button( text = 'edit' on_press_id = 'EDIT'
*          ).
*
*        DATA(lo_cells) = lo_tab->add_columns(
*              )->add_column( text = 'Name'
*              )->add_column( text = 'Value'
*              )->add_column( text = 'Test1'
*              )->add_column( text = 'Test2'
*              )->add_column( text = 'Checkbox'
*           )->m_parent->add_items( )->add_column_list_item( )->add_cells( ).
*
*        IF mv_check_active = abap_true.
*          lo_cells->add_text( '{NAME}'
*              )->add_text( '{VALUE}'
*              )->add_button( text = '{TEST1}' on_press_id = '{NAME}'
*              )->add_input( value = '{TEST2}'
*              )->add_checkbox( selected_json = '{CHECK_VALID}'
*           ).
*        ELSE.
*          lo_cells->add_text( '{NAME}'
*             )->add_input( value = '{VALUE}'
*             )->add_input( value = '{TEST1}'
*             )->add_input( value = '{TEST2}'
*             )->add_input( value = '{NAME}'
*          ).
*        ENDIF.



    ENDCASE.

  ENDMETHOD.

ENDCLASS.
