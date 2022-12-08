INTERFACE Z2UI5_IF_CLIENT_POPUP PUBLIC.
METHODS display_message_toast
    IMPORTING
      text TYPE string.
METHODS display_message_box
    IMPORTING
      text TYPE string
      type TYPE string.
ENDINTERFACE.
