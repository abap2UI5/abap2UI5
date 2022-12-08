INTERFACE Z2UI5_IF_CLIENT_CONTROLLER PUBLIC.
METHODS nav_to_screen
    IMPORTING
      name TYPE string.
METHODS nav_to_app
    IMPORTING
      app TYPE REF TO z2ui5_if_app.
METHODS exit_to_home.
METHODS exit_w_logoff.
METHODS get_active_screen
    RETURNING
      VALUE(r_result) TYPE string.
ENDINTERFACE.
