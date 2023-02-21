CLASS z2ui5_cl_app_demo_13 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    TYPES:
      BEGIN OF ty_row,
        carrid   TYPE string,
        connid   TYPE string,
        descr    type string,
        price    TYPE string,
      END OF ty_row.

    DATA t_tab TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.

PROTECTED SECTION.
PRIVATE SECTION.
ENDCLASS.



CLASS Z2UI5_CL_APP_DEMO_13 IMPLEMENTATION.


  METHOD z2ui5_if_app~controller.

    CASE client->get( )-lifecycle_method.


      WHEN client->cs-lifecycle_method-on_init.

        t_tab = VALUE #(
          ( carrid = ''  connid = 'AZ - 0790 - 01.01.2023'   descr = 'CITYFROM Hamburg CITYTO London' price = 'price 128€' )
          ( carrid = ''  connid = 'AZ - 0791 - 07.02.2023'   descr = 'CITYFROM New York CITYTO Rom' price = 'price 128€' )
          ( carrid = ''  connid = 'AZ - 0792 - 08.03.2023'   descr = 'CITYFROM Rom CITYTO Paris' price = 'price 128€' )
          ( carrid = ''  connid = 'AZ - 0793 - 09.04.2023'   descr = 'CITYFROM Rom CITYTO Warsaw ' price = 'price 128€' )
          ( carrid = ''  connid = 'AZ - 0794 - 10.05.2023'   descr = 'CITYFROM Zurich  CITYTO Milano' price = 'price 128€' )
         ).


      WHEN client->cs-lifecycle_method-on_event.
        "implement event handling here


      WHEN client->cs-lifecycle_method-on_rendering.

        DATA(view) = client->factory_view( ).
        DATA(page) = view->page( title = 'Example ABAP2UI5 - Table SPFLI' nav_button_tap = view->_event_display_id( client->get( )-id_prev_app ) ).

        page->list(
           header_text = 'Flights Alitalia'
           items       = view->_bind_one_way( t_tab )
        )->standard_list_item(
           title       = '{CONNID}'
           description = '{DESCR}'
           icon        = '{ICON}'
           info        = '{PRICE}'
       ).

    ENDCASE.

  ENDMETHOD.
ENDCLASS.
