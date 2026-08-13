INTERFACE z2ui5_if_app PUBLIC.
  INTERFACES if_serializable_object.

  CONSTANTS version TYPE string VALUE `1.142.0`.
  CONSTANTS origin  TYPE string VALUE `https://github.com/abap2UI5/abap2UI5`.
  CONSTANTS authors TYPE string VALUE `https://github.com/abap2UI5/abap2UI5/graphs/contributors`.
  CONSTANTS license TYPE string VALUE `MIT`.

  "! Framework-owned. NOT obsolete, and it cannot move into the framework's
  "! own app wrapper (z2ui5_cl_core_app) the way the two flags below did: it
  "! is the HANDLE that maps an app reference back to its draft, and
  "! therefore back to that wrapper - z2ui5_cl_core_app=>db_load_by_app( )
  "! resolves an app by read_draft( app->id_draft ). It has to sit on the app
  "! instance because that is all the framework holds at the two moments it
  "! is needed: an app handed to nav_app_call( ) has no wrapper yet, and a
  "! draft is looked up before its wrapper is parsed. Public only because an
  "! ABAP interface has no protected section - the framework must be able to
  "! write it on any implementation. Read it if you need the draft id, but
  "! client->get( )-s_draft-id says the same thing on the running app.
  DATA id_draft          TYPE string.
  "! Framework-owned, same reason as id_draft: the id nav_app_set_id( ) mints
  "! on an app passed to nav_app_call( ) / nav_app_leave( ), before any
  "! wrapper for it exists. Do not write it.
  DATA id_app            TYPE string.
  "! obsolete - moved to z2ui5_cl_core_app=>mv_check_initialized, which is
  "! where the framework reads it now. This attribute is still kept in sync,
  "! so reading it works; writing it has no effect. client->check_on_init( )
  "! is the app-facing question it answers
  DATA check_initialized TYPE abap_bool.
  "! obsolete - moved to z2ui5_cl_core_app=>mv_check_sticky, which is where
  "! the framework reads it now. This attribute is still kept in sync, so
  "! reading it works; writing it has no effect -
  "! client->set_session_stateful( ) is how a session is switched to sticky
  DATA check_sticky      TYPE abap_bool.

  METHODS main
    IMPORTING
      client TYPE REF TO z2ui5_if_client.

ENDINTERFACE.
