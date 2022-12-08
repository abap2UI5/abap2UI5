INTERFACE Z2UI5_IF_CLIENT PUBLIC.
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
