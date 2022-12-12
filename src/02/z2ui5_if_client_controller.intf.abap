INTERFACE z2ui5_if_client_controller PUBLIC.

  METHODS nav_to_page
    IMPORTING
      name TYPE string.

  METHODS nav_to_app
    IMPORTING
      app TYPE REF TO z2ui5_if_app.

  METHODS exit_to_home.

  METHODS exit_w_logoff.

  METHODS get_active_page
    RETURNING
      VALUE(r_result) TYPE string.

ENDINTERFACE.
