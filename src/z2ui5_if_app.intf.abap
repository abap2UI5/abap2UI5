INTERFACE z2ui5_if_app PUBLIC.
  INTERFACES if_serializable_object.

  METHODS on_event
    IMPORTING
      client TYPE REF TO z2ui5_if_client.

  METHODS set_view
    IMPORTING
      view TYPE REF TO z2ui5_if_view
    RAISING cx_abap_context_info_error.

ENDINTERFACE.
