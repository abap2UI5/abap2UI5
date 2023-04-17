CLASS z2ui5_cl_app_demo_43 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

*    TYPES:
*      BEGIN OF t_flight,
*        carrid TYPE string,
*        connid TYPE string,
*        fldate TYPE string,
*        price  TYPE string,
*      END OF t_flight.
*    DATA: mt_flight TYPE STANDARD TABLE OF t_flight.

protected section.
private section.
ENDCLASS.



CLASS Z2UI5_CL_APP_DEMO_43 IMPLEMENTATION.


  METHOD z2ui5_if_app~main.

*    SELECT carrid connid fldate price FROM sflight INTO TABLE mt_flight.
*
*    DATA(page) = z2ui5_cl_xml_view=>factory( )->page(
*            )->scroll_container( height = '70%' vertical = abap_true
*                )->table( items = client->_bind_one( mt_flight )
*                )->columns(
*                    )->column( )->text( 'Carrid' )->get_parent(
*                    )->column( )->text( 'Connid' )->get_parent(
*                    )->column( )->text( 'Fldate' )->get_parent(
*                    )->column( )->text( 'Price'  )->get_parent(
*                )->get_parent(
*                )->items( )->column_list_item( )->cells(
*                    )->text( '{CARRID}'
*                    )->text( '{CONNID}'
*                    )->text( '{FLDATE}'
*                    )->text( '{PRICE}' ).
*
*    client->set_next( VALUE #( xml_main = page->get_root( )->xml_get( ) )  ).

  ENDMETHOD.
ENDCLASS.
