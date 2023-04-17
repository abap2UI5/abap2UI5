CLASS z2ui5_cl_app_demo_44 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.
    INTERFACES if_oo_adt_classrun.

ENDCLASS.

CLASS z2ui5_cl_app_demo_44 IMPLEMENTATION.

  METHOD z2ui5_if_app~main.
    client->set_next( VALUE #( xml_main = z2ui5_cl_xml_view=>factory( )->label( 'Hello World!' )->get_root( )->xml_get( ) ) ).
  ENDMETHOD.


  METHOD if_oo_adt_classrun~main.
    out->write( `Hello World` ).
  ENDMETHOD.

ENDCLASS.
