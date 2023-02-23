CLASS z2ui5_cl_app_demo_03 DEFINITION PUBLIC.

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

PROTECTED SECTION.
PRIVATE SECTION.
ENDCLASS.



CLASS Z2UI5_CL_APP_DEMO_03 IMPLEMENTATION.


  METHOD z2ui5_if_app~controller.

    CASE client->get( )-lifecycle_method.


      WHEN client->cs-lifecycle_method-on_init.

        t_tab = VALUE #(
          ( title = 'Hans'  info = 'completed'   descr = 'this is a description' icon = 'sap-icon://account' )
          ( title = 'Hans'  info = 'incompleted' descr = 'this is a description' icon = 'sap-icon://account' )
          ( title = 'Hans'  info = 'working'     descr = 'this is a description' icon = 'sap-icon://account' )
          ( title = 'Hans'  info = 'working'     descr = 'this is a description' icon = 'sap-icon://account' )
          ( title = 'Hans'  info = 'completed'   descr = 'this is a description' icon = 'sap-icon://account' )
          ( title = 'Hans'  info = 'completed'   descr = 'this is a description' icon = 'sap-icon://account' )
        ).


      WHEN client->cs-lifecycle_method-on_event.
        "implement event handling here


      WHEN client->cs-lifecycle_method-on_rendering.

        DATA(view) = client->factory_view( ).
        DATA(page) = view->page( title = 'Example - ZZ2UI5_CL_APP_DEMO_03' nav_button_tap = view->_event_display_id( client->get( )-id_prev_app ) ).

        page->list(
           header_text = 'List Ouput'
           items       = view->_bind_one_way( t_tab )
        )->standard_list_item(
           title       = '{TITLE}'
           description = '{DESCR}'
           icon        = '{ICON}'
           info        = '{INFO}'
       ).

    ENDCASE.

  ENDMETHOD.
ENDCLASS.
