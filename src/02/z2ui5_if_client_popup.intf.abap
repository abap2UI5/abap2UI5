INTERFACE Z2UI5_IF_CLIENT_POPUP PUBLIC.

METHODS message_toast
    IMPORTING
      text TYPE string.

METHODS message_box
    IMPORTING
      text TYPE string
      type TYPE string.

ENDINTERFACE.
