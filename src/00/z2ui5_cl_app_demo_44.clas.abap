CLASS z2ui5_cl_app_demo_44 DEFINITION PUBLIC.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

ENDCLASS.



CLASS Z2UI5_CL_APP_DEMO_44 IMPLEMENTATION.


  METHOD z2ui5_if_app~main.
    client->set_next( VALUE #( xml_main = z2ui5_cl_xml_view=>factory( )->label( `Hello World!` )->get_root( )->xml_get( ) ) ).
  ENDMETHOD.
ENDCLASS.
