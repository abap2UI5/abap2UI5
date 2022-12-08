INTERFACE Z2UI5_IF_APP PUBLIC.
INTERFACES if_serializable_object.
METHODS set_view
    IMPORTING
      view TYPE REF TO z2ui5_if_view.
METHODS on_event DEFAULT IGNORE
    IMPORTING
      client TYPE REF TO z2ui5_if_client.
ENDINTERFACE.
