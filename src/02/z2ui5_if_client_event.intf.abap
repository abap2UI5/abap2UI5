INTERFACE Z2UI5_IF_CLIENT_EVENT PUBLIC.
CONSTANTS:
    BEGIN OF cs_event_type,
button TYPE string VALUE 'BUTTON',
END OF cs_event_type.
METHODS get_id
    RETURNING
      VALUE(r_result) TYPE string.
ENDINTERFACE.
