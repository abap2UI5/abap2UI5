CLASS z2ui5_cl_app_demo_11 DEFINITION PUBLIC.

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

    DATA t_tab TYPE STANDARD TABLE OF ty_row WITH DEFAULT KEY.
    DATA check_editable_active TYPE abap_bool.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS Z2UI5_CL_APP_DEMO_11 IMPLEMENTATION.


  METHOD z2ui5_if_app~controller.

    CASE client->get( )-lifecycle_method.

      WHEN client->cs-lifecycle_method-on_init.

        check_editable_active = abap_false.

     "   t_tab = REDUCE #( INIT ret = VALUE #( ) FOR n = 1 WHILE n < 11 NEXT ret =
     "       VALUE #( BASE ret ( title = 'Hans'  value = 'red' info = 'completed'  descr = 'this is a description' checkbox = abap_true ) ) ).


      WHEN client->cs-lifecycle_method-on_event.

        CASE client->get( )-event.

          WHEN 'BUTTON_EDIT'.
            check_editable_active = boolc( check_editable_active = abap_false ).

        ENDCASE.


      WHEN client->cs-lifecycle_method-on_rendering.

        DATA view TYPE REF TO z2ui5_if_ui5_library.
        view = client->factory_view( ).
        DATA page TYPE REF TO z2ui5_if_ui5_library.
        page = view->page( title = 'Example - ZZ2UI5_CL_APP_DEMO_11' nav_button_tap = view->_event_display_id( client->get( )-id_prev_app ) ).

        DATA tab TYPE REF TO z2ui5_if_ui5_library.
        tab = page->table( view->_bind( t_tab ) ).

    ENDCASE.

  ENDMETHOD.
ENDCLASS.
