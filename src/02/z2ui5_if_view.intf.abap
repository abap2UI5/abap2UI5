INTERFACE z2ui5_if_view PUBLIC.

  CONSTANTS cs LIKE z2ui5_cl_control_library=>cs VALUE z2ui5_cl_control_library=>cs.

  METHODS factory_selscreen_page
    IMPORTING
      name              TYPE string OPTIONAL
      title             TYPE string DEFAULT 'screen_title'
      event_nav_back_id TYPE string OPTIONAL
        PREFERRED PARAMETER name
    RETURNING
      VALUE(r_result)   TYPE REF TO z2ui5_if_selscreen.

  METHODS factory_view
    IMPORTING
      name   type string optional
      parser TYPE ref to z2ui5_if_view_parser.

ENDINTERFACE.
