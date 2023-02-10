CLASS zz2ui5_cl_app_demo_01 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES zz2ui5_if_app.

    DATA product TYPE string.
    DATA quantity TYPE string.

    TYPES: BEGIN OF ty_row,
             id          TYPE string,
             name        TYPE string,
             value       TYPE string,
             test1       TYPE string,
             test2       TYPE string,
             check_valid TYPE abap_bool,
           END OF ty_row.

    DATA mt_tab TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.
    DATA ms_edit TYPE ty_row.

    DATA mo_app_popup_edit TYPE REF TO zz2ui5_if_app.

ENDCLASS.

CLASS zz2ui5_cl_app_demo_01 IMPLEMENTATION.


  METHOD zz2ui5_if_app~controller.

    CASE client->get( )-lifecycle_method.

      WHEN client->lifecycle_method-on_init.
        "set initial values
        product = 'tomato'.
        quantity = '500'.

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
            ( name = 'Hans' value = 'red' test1 = 'das ist ein langer text' test2 = 'das ist noch ein langer text' check_valid = abap_true )
            ( name = 'Hans' value = 'red' test1 = 'das ist ein langer text' test2 = 'das ist noch ein langer text' check_valid = abap_true )
            ( name = 'Hans' value = 'red' test1 = 'das ist ein langer text' test2 = 'das ist noch ein langer text' check_valid = abap_true )
            ( name = 'Hans' value = 'red' test1 = 'das ist ein langer text' test2 = 'das ist noch ein langer text' check_valid = abap_true )
            ( name = 'Hans' value = 'red' test1 = 'das ist ein langer text' test2 = 'das ist noch ein langer text' check_valid = abap_true )
            ( name = 'Hans' value = 'red' test1 = 'das ist ein langer text' test2 = 'das ist noch ein langer text' check_valid = abap_true )
            ).


      WHEN client->lifecycle_method-on_event.

        IF mo_app_popup_edit IS BOUND.
          CLEAR mo_app_popup_edit.
        ENDIF.

        "user event handling
        CASE client->get( )-event_id.

          WHEN 'BTN_BACK'.
            client->nav_to_app( client->get_app_called( ) ).

          WHEN 'BUTTON_APP'.
            client->nav_to_app( NEW zz2ui5_cl_app_demo_02( ) ).

          WHEN 'POPUP_SELECT_TABLE'.
            client->display_popup( 'POPUP_TABLE' ).

          WHEN 'TAB_CONFIRM'.
            client->display_message_toast( |tab confirm| ).

          WHEN 'TAB_CANCEL'.

          WHEN 'BUTTON_EDIT'.
            ms_edit = mt_tab[ 3 ].

            mo_app_popup_edit = zz2ui5_cl_app_demo_04=>factory(
                i_app        =   me
                i_name_attri = 'MS_EDIT'
            ) .

            client->nav_to_app( mo_app_popup_edit ).

          WHEN 'BUTTON_SE16N'.
            client->nav_to_app( zz2ui5_cl_app_demo_06=>create( ) ).

          WHEN 'BUTTON_ERROR'.
            client->nav_to_app( zz2ui5_cl_app_demo_05=>create(
                                  i_text      = 'Es ist ein Fehler passiert'
                                  i_text_long =  'Das ist ein ganz lange beschreibung Das ist ein ganz lange beschreibung Das ist ein ganz lange beschreibung Das ist ein ganz lange beschreibung Das ist ein ganz lange beschreibung Das ist ein gan' &&
'z lange beschreibung Das ist ein ganz lange beschreibungDas ist ein ganz lange beschreibung Das ist ein ganz lange beschreibung Das ist ein ganz lange beschreibung Das ist ein ganz lange beschreibung'
                                  i_type      = 'E'
                                ) ).

          WHEN 'BUTTON_BAL'.
            client->nav_to_app( zz2ui5_cl_app_demo_03=>factory( VALUE #(
      ( type = 'E' message = 'Das ist ein Fehler' id = 'CLNAME' number = '333' )
      ( type = 'S' message = 'Das ist ein Erfolg' id = 'CLNAME' number = '333' )
      ( type = 'I' message = 'Das ist eine Info' id = 'CLNAME' number = '333' )
      ) ) ).

          WHEN 'BUTTON_POST'.
            "do something
            client->display_message_toast( |{ product } { quantity } ST - GR successful| ).

        ENDCASE.

        client->display_view( 'FREESTYLE' ).



      WHEN client->lifecycle_method-on_rendering.

        DATA(lo_view) = client->factory_view( 'FREESTYLE' ).

        DATA(lo_page) = lo_view->add_page(
                   title             = 'App Title'
                   event_nav_back_id = COND #(  WHEN client->get( )-check_call_satck = abap_true THEN 'BTN_BACK' )
               ).

        lo_page->add_header_content( )->add_overflow_toolbar(
            )->add_button( text = 'App wechseln' on_press_id = 'BUTTON_APP'
          "  )->add_button( text = 'Post Goods Receipt' on_press_id = 'BUTTON_POST'
           " )->add_button( text = 'Post Goods Receipt' on_press_id = 'BUTTON_POST'
        ).

        lo_page = lo_page->add_content( ).

        DATA(lo_grid) = lo_page->add_grid( )->add_content( 'l' ).

        DATA(lo_form) = lo_grid->add_simple_form( )->add_content( 'f' ).
        lo_form = lo_form->add_vbox( ).
        lo_form->add_input( product ).
        lo_form->add_button( text = 'POPUP_SELECT_TABLE' on_press_id = 'POPUP_SELECT_TABLE' ).
        lo_form->add_input( product ).
        lo_form->add_button( text = 'BAL Anzeige' on_press_id = 'BUTTON_BAL' ).

        lo_form = lo_grid->add_simple_form( title = 'test' )->add_content( 'f' ).
        lo_form->add_title( 'new title' ).
        lo_form = lo_form->add_vbox( ).
        lo_form->add_label( 'label' ).
        lo_form->add_input( product ).
        lo_form->add_button( text = 'BUTTON_ERROR' on_press_id = 'BUTTON_ERROR' ).
        lo_form->add_label( 'label' ).
        lo_form->add_input( product ).
        lo_form->add_button( text = 'BUTTON_SE16N' on_press_id = 'BUTTON_SE16N' ).



        lo_grid = lo_page->add_grid( default_span  = 'L12 M12 S12' )->add_content( 'l' ).

        lo_form = lo_grid->add_simple_form( )->add_content( 'f' ).
        "lo_form = lo_form->add_vbox( ).
        lo_form->add_input( product ).
        lo_form->add_button(
                text = 'Post Goods Receipt'
                 on_press_id = 'BUTTON_EDIT'
                 type = client->cs-button-type-emphasized
                  ).
        lo_form->add_input( product ).
        lo_form->add_button( text = 'Post Goods Receipt' on_press_id = 'BUTTON_POST' ).

        lo_grid = lo_page->add_grid( default_span  = 'L12 M12 S12' )->add_content( 'l' ).

        lo_form = lo_grid->add_simple_form( )->add_content( 'f' ).
        "lo_form = lo_form->add_vbox( ).
        lo_form->add_input( product ).
        lo_form->add_button( text = 'Post Goods Receipt' on_press_id = 'BUTTON_POST' ).
        lo_form->add_input( product ).
        lo_form->add_button( text = 'Post Goods Receipt' on_press_id = 'BUTTON_POST' ).

        lo_grid = lo_page->add_grid( default_span  = 'L12 M12 S12' )->add_content( 'l' ).

        lo_form = lo_grid->add_simple_form( )->add_content( 'f' ).
        "lo_form = lo_form->add_vbox( ).
        lo_form->add_input( product ).
        lo_form->add_button( text = 'Post Goods Receipt' on_press_id = 'BUTTON_POST' ).
        lo_form->add_input( product ).
        lo_form->add_button( text = 'Post Goods Receipt' on_press_id = 'BUTTON_POST' ).


        DATA(lo_tab) = lo_grid->add_scroll_container( height = '70%' )->add_table(
            items  = mt_tab
        ).

        lo_tab->add_header_toolbar( )->add_overflow_toolbar(
            )->add_title( 'title'
             )->add_toolbar_spacer(
             )->add_button( text = 'edit' on_press_id = 'BTN01'
             )->add_button( text = 'edit' on_press_id = 'BTN02'
          ).

        lo_tab->add_columns(
            )->add_column( text = 'Name'
            )->add_column( text = 'Value'
            )->add_column( text = 'Test1'
            )->add_column( text = 'Test2'
            )->add_column( text = 'Checkbox'
         )->parent->add_items( )->add_column_list_item( )->add_cells(
            )->add_text( '{NAME}'
            )->add_text( '{VALUE}'
            )->add_button( text = '{TEST1}' on_press_id = '{NAME}'
            )->add_input( value = '{TEST2}'
            )->add_checkbox( selected_json = '{CHECK_VALID}'
         ).





        lo_page->parent->add_footer( )->add_overflow_toolbar(
             )->add_button( text = 'Post Goods Receipt' on_press_id = 'BUTTON_POST'
             )->add_button( text = 'Post Goods Receipt' on_press_id = 'BUTTON_POST'
             )->add_toolbar_spacer(
              )->add_button( text = 'Post Goods Receipt' on_press_id = 'BUTTON_POST'
             )->add_button( text = 'Post Goods Receipt' on_press_id = 'BUTTON_POST'
             ).





        lo_view = client->factory_view( 'POPUP_TABLE' ).

        lo_tab = lo_view->add_table_select_dialog(
                    title            = 'title'
                    event_id_confirm = 'TAB_CONFIRM'
                    event_id_cancel  = 'TAB_CANCEL'
                    items            = mt_tab
                 ).

        lo_tab->add_column_list_item( )->add_cells(
        )->add_text( '{NAME}'
        )->add_text( '{VALUE}'
        )->add_button( text = '{TEST1}' on_press_id = '{NAME}'
        )->add_input( value = '{TEST2}'
        )->add_checkbox( selected_json = '{CHECK_VALID}'
).
        lo_tab->add_columns(    )->add_column( text = 'Name'
        )->add_column( text = 'Value'
        )->add_column( text = 'Test1'
        )->add_column( text = 'Test2'
        )->add_column( text = 'Checkbox'
        ).
*        lo_tab->add_header_toolbar( )->add_overflow_toolbar(
*            )->add_title( 'title'
*             )->add_toolbar_spacer(
*             )->add_button( text = 'edit' on_press_id = 'BTN01'
*             )->add_button( text = 'edit' on_press_id = 'BTN02'
*          ).

*        lo_tab->add_columns(
*            )->add_column( text = 'Name'
*            )->add_column( text = 'Value'
*            )->add_column( text = 'Test1'
*            )->add_column( text = 'Test2'
*            )->add_column( text = 'Checkbox'
*         )->parent->add_items( )->add_column_list_item( )->add_cells(
*            )->add_text( '{NAME}'
*            )->add_text( '{VALUE}'
*            )->add_button( text = '{TEST1}' on_press_id = '{NAME}'
*            )->add_input( value = '{TEST2}'
*            )->add_checkbox( selected_json = '{CHECK_VALID}'
*         ).




    ENDCASE.

  ENDMETHOD.

ENDCLASS.
