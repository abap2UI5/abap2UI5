INTERFACE z2ui5_if_app PUBLIC.
  INTERFACES if_serializable_object.

  CONSTANTS version TYPE string VALUE `1.144.0`.
  CONSTANTS origin  TYPE string VALUE `https://github.com/abap2UI5/abap2UI5`.
  CONSTANTS authors TYPE string VALUE `https://github.com/abap2UI5/abap2UI5/graphs/contributors`.
  CONSTANTS license TYPE string VALUE `MIT`.

  "! Framework bookkeeping, and NOT obsolete despite looking like the
  "! lifecycle mirrors that were removed. id_draft is the handle
  "! z2ui5_cl_ui5_app_cont=>db_load_by_app( ) resolves an app reference by,
  "! and both are written at moments when no wrapper exists yet - an app
  "! handed to nav_app_call( ), a draft looked up before it is parsed. They
  "! are public only because an ABAP interface has no protected section; an
  "! app neither sets nor reads them.
  DATA id_draft TYPE string.
  DATA id_app   TYPE string.

  METHODS main
    IMPORTING
      client TYPE REF TO z2ui5_if_client.

ENDINTERFACE.
