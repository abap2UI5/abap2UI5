INTERFACE z2ui5_if_app
  PUBLIC .

  INTERFACES if_serializable_object.

  DATA id TYPE string.

  METHODS main
    IMPORTING
      client TYPE REF TO z2ui5_if_client.

ENDINTERFACE.
