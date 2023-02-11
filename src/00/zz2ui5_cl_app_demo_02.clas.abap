CLASS zz2ui5_cl_app_demo_02 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES zz2ui5_if_app.


    DATA:
      BEGIN OF screen,
        check_initialized TYPE abap_bool,
        check_is_active   TYPE abap_bool,
        colour            TYPE string,
        combo_key         TYPE string,
        segment_key       TYPE string,
        radio_index       TYPE i,
        date              TYPE string,
        date_time         TYPE string,
        time_start        TYPE string,
        time_end          TYPE string,
      END OF screen.

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

CLASS zz2ui5_cl_app_demo_02 IMPLEMENTATION.


  METHOD zz2ui5_if_app~controller.

    CASE client->get( )-lifecycle_method.

      WHEN client->lifecycle_method-on_init.

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

        "set initial values
*        product = 'tomato'.
*        quantity = '500'.

        "  client->display_view( check_no_rerender = ABAp_true ).
        client->display_popup( 'POPUP' ).

      WHEN client->lifecycle_method-on_event.

        "user event handling
        CASE client->get( )-event_id.

          WHEN 'BTN_BACK'.
            client->nav_to_app( client->get_app_called( ) ).

          WHEN 'BUTTON_POST'.
            "do something
*            client->display_message_toast( |{ product } { quantity } ST - GR successful| ).

        ENDCASE.





      WHEN client->lifecycle_method-on_rendering.

        DATA(lo_view) = client->factory_view( ).
        DATA(lo_page) = lo_view->page(  title = 'App Title - Z2UI5_CL_APP_DEMO_02' ).


        DATA(lo_grid) = lo_page->grid( default_span  = 'L12 M12 S12' )->content( 'l' ).
        DATA(lo_form_h) = lo_grid->simple_form('Selection Screen Title' ).
        DATA(lo_form) = lo_form_h->content( 'f' ).


        lo_form->title( 'Input' ).

        lo_form->label( 'Input with value help' ).
        lo_form->input(
            value       = lo_view->_bind( screen-colour )
            placeholder = 'fill in your favorite colour'
            suggestion_items = VALUE #(
                ( descr = 'Green'  value = 'GREEN' )
                ( descr = 'Blue'   value = 'BLUE' )
                ( descr = 'Black'  value = 'BLACK' )
                ( descr = 'Grey'   value = 'GREY' )
                ( descr = 'Blue2'  value = 'BLUE2' )
                ( descr = 'Blue3'  value = 'BLUE3' )
              ) ).

        lo_form = lo_form_h->content( 'f' ).
        lo_form->title( 'Input with select options' ).


        lo_form->label( 'Checkbox' ).
        lo_form->checkbox(
            selected = lo_view->_bind( screen-check_is_active )
            text     = 'this is a checkbox'
        ).

        lo_form->label( 'Combobox' ).
        lo_form->combobox(
            selectedkey = lo_view->_bind( screen-combo_key )
            t_item      = VALUE #(
                    ( key = 'BLUE'  text = 'green' )
                    ( key = 'GREEN' text = 'blue' )
                    ( key = 'BLACK' text = 'red' )
                    ( key = 'GRAY'  text = 'gray' )
              ) ).

        lo_form->label( 'Segmented Button' ).
        lo_form->segmented_button(
            selected_key = lo_view->_bind( screen-segment_key )
            t_button     = VALUE #(
                ( key = 'BLUE'  icon = 'sap-icon://accept'       text = 'blue' )
                ( key = 'GREEN' icon = 'sap-icon://add-favorite' text = 'green' )
                ( key = 'BLACK' icon = 'sap-icon://attachment'   text = 'black' )
            ) ).

        screen-radio_index = '1'.
        lo_form->label( 'Radiobutton' ).
        lo_form->radiobutton_group(
            selected_index = lo_view->_bind( screen-radio_index )
            t_prop         = VALUE #( ( `Option A` ) ( `Option B` ) )
        ).

        lo_form->title( 'Time Inputs' ).

        lo_form->label( 'Date' ).
        lo_form->date_picker( lo_view->_bind( screen-date ) ).

        lo_form->label( 'Date and Time' ).
        lo_form->date_time_picker( lo_view->_bind( screen-date_time ) ).

        lo_form->label( 'Time Begin/End' ).
        lo_form->time_picker( lo_view->_bind( screen-time_start ) ).
        lo_form->time_picker( lo_view->_bind( screen-time_end ) ).

        lo_form->title( 'User Interaction'  ).

        lo_form->label( 'Roundtrip' ).
        lo_form->button( text = 'Client/Server Interaction' on_press_id = 'BUTTON_ROUNDTRIP'   ).

        lo_form->label( 'Popups' ).
        lo_form->button( text = 'Display Message Box'   on_press_id = 'BUTTON_MSG_BOX'   ).
        lo_form->button( text = 'Display Message Toast' on_press_id = 'BUTTON_MSG_TOAST' ).

        lo_form->label( 'System' ).
        lo_form->button( text = 'Restart' on_press_id = 'BUTTON_RESTART'   ).
        lo_form->button( text = 'Error'   on_press_id = 'BUTTON_ERROR'   ).

        lo_form->label( 'Call new app' ).
        lo_form->button( text = 'App & Screen change' on_press_id = 'BUTTON_CHANGE_APP'   ).


            lo_form = lo_form_h->content( 'f' ).
        lo_form->title( 'Table' ).

       lo_form_h = lo_grid->simple_form('Tabelle' ).
        lo_form = lo_form_h->content( 'f' ).

        DATA(lo_tab) = lo_form->scroll_container( height = '70%' )->table(
            items  = lo_view->_bind( val = mt_tab type = lo_view->cs-_bind_type-two_way )
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
