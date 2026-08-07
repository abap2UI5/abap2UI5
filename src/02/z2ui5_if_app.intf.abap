INTERFACE z2ui5_if_app PUBLIC.

  INTERFACES if_serializable_object.

  CONSTANTS version TYPE string VALUE `1.142.0`.
  CONSTANTS origin  TYPE string VALUE `https://github.com/abap2UI5/abap2UI5`.
  CONSTANTS authors TYPE string VALUE `https://github.com/abap2UI5/abap2UI5/graphs/contributors`.
  CONSTANTS license TYPE string VALUE `MIT`.

  DATA id_draft          TYPE string.
  DATA id_app            TYPE string.
  DATA check_initialized TYPE abap_bool.
  DATA check_sticky      TYPE abap_bool.

  " The parameter is typed on z2ui5_if_client, the COMPONENT interface, not on
  " z2ui5_if_ui5_client, the compound over it. Both names reach the same
  " implementation, but only this direction accepts a reference of either type:
  " a z2ui5_if_ui5_client reference widens to z2ui5_if_client on its own, while
  " the reverse is a down-cast the caller would have to write. Apps hold their
  " client in a z2ui5_if_client attribute and pass it on to a nested app's
  " main( ) - the shipped popups in src/99 all do - so typing this on the
  " compound rejects every one of them. It can move to the new name once
  " nothing passes an old-typed reference in.
  METHODS main
    IMPORTING
      client TYPE REF TO z2ui5_if_client.

ENDINTERFACE.
