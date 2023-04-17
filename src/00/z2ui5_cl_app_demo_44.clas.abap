CLASS z2ui5_cl_app_demo_44 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.
    INTERFACES if_oo_adt_classrun.

protected section.
private section.
ENDCLASS.



CLASS Z2UI5_CL_APP_DEMO_44 IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
    out->write( `Hello World` ).
  ENDMETHOD.


  METHOD z2ui5_if_app~main.
    client->set_next( VALUE #( xml_main = z2ui5_cl_xml_view=>factory( )->label( 'Hello World!' )->get_root( )->xml_get( ) ) ).
  ENDMETHOD.
ENDCLASS.
