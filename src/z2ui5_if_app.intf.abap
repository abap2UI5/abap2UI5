INTERFACE z2ui5_if_app PUBLIC.
  INTERFACES if_serializable_object.

  METHODS set_view
    IMPORTING
      view TYPE REF TO z2ui5_if_view.

  METHODS on_event
    IMPORTING
      client TYPE REF TO z2ui5_if_client.

ENDINTERFACE.
