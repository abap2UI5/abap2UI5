INTERFACE zz2ui5_if_app
  PUBLIC .

  INTERFACES if_serializable_object.

  METHODS controller
    IMPORTING
      client TYPE REF TO zz2ui5_if_app_client.

ENDINTERFACE.
