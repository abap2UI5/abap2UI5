INTERFACE z2ui5_if_client PUBLIC.

  CONSTANTS cs LIKE z2ui5_if_view=>cs VALUE z2ui5_if_view=>cs.

  METHODS popup
    RETURNING
      VALUE(r_result) TYPE REF TO z2ui5_if_client_popup.

  METHODS event
    RETURNING
      VALUE(r_result) TYPE REF TO z2ui5_if_client_event.

  METHODS controller
    RETURNING
      VALUE(r_result) TYPE REF TO z2ui5_if_client_controller.

ENDINTERFACE.
