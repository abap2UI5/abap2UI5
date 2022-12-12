INTERFACE z2ui5_if_client_popup PUBLIC.

  METHODS message_toast
    IMPORTING
      text TYPE string.

  METHODS message_box
    IMPORTING
      text TYPE string
      type TYPE string DEFAULT z2ui5_if_view=>cs-message_box-type-info.

ENDINTERFACE.
