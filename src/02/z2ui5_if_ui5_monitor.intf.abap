"! <p class="shorttext synchronized">abap2UI5 - roundtrip monitor</p>
"!
"! The framework's monitoring seam: implement this interface in a class of
"! your own, in a package of your own, and abap2UI5 finds it the way it finds
"! the user exit - the first implementing class by name - and calls
"! on_roundtrip once per POST roundtrip, after the response is built, on
"! success and on failure alike. Usage, performance and error logs hang off
"! it (abap2UI5-addons/admin-cockpit); the framework itself persists nothing.
"!
"! Not called for the page request (GET), for HEAD, or for a POST the CSRF
"! gate rejected - those run no app.
"!
"! The call is synchronous: whatever it costs, the user waits for. It must
"! never raise - anything it raises is caught and ignored, and so is a class
"! that cannot be instantiated. A broken monitor costs its log entries, never
"! the app (the user exit fails closed instead: it is a hardening control).
"!
"! The database LUW when it runs, read off check_sticky:
"! check_sticky = abap_false - the LUW is empty. On success the framework has
"! committed its own work (the draft save), on failure it rolled the LUW back
"! before the call, so a COMMIT WORK of the implementation commits its own
"! writes and nothing of the app.
"! check_sticky = abap_true - the LUW belongs to the app. A stateful app may
"! hold uncommitted work and locks across roundtrips, which a COMMIT WORK
"! here would commit or release. Do not commit then: keep the entry and write
"! it on a later roundtrip that is not sticky, or through a database
"! connection of its own.
"! The framework offers no commit helper - its utility class is not
"! released API - so an implementation issues COMMIT WORK itself.
INTERFACE z2ui5_if_ui5_monitor
  PUBLIC.

  TYPES:
    "! One POST roundtrip, as on_roundtrip receives it.
    BEGIN OF ty_s_roundtrip,
      " the app class that answered (upper case) - the one the response
      " names, or the one that failed; empty when the request failed before
      " an app was resolved
      app            TYPE string,
      " the event of this roundtrip as the request carried it
      " (client->get( )-event), empty on a first start / navigation
      event          TYPE string,
      " the draft id the response carries (new id), and the one the request
      " came with - empty on a first start; draft_id is empty on failure
      draft_id       TYPE string,
      draft_id_prev  TYPE string,
      uname          TYPE string,
      " the app runs in a stateful session - see the LUW note above
      check_sticky   TYPE abap_bool,
      " abap_true on the first request of an app start (no draft id in)
      check_start    TYPE abap_bool,
      " start of the roundtrip, UTC (GET TIME STAMP)
      timestampl     TYPE timestampl,
      " durations in milliseconds (0 when not measurable on this runtime)
      ms_total       TYPE i,
      " request parse + draft read/deserialize
      ms_load        TYPE i,
      " the app's main( ) incl. the app-to-app dispatch loop
      ms_main        TYPE i,
      " model/view serialize + draft save
      ms_render      TYPE i,
      " sizes in characters of the JSON strings; bytes_response and
      " bytes_model are 0 on failure (the 500 body is built later, above
      " the engine) and bytes_model is 0 when no model was sent
      bytes_request  TYPE i,
      bytes_response TYPE i,
      bytes_model    TYPE i,
      " end-to-end time of the PREVIOUS roundtrip as measured by the
      " browser, sent by the frontend with this request; 0 when unknown
      ms_client_prev TYPE i,
      " abap_true when the roundtrip ended in an exception
      check_error    TYPE abap_bool,
      " the full exception chain text, as the 500 body renders it - the
      " error id in it is the one the user sees
      error_text     TYPE string,
      " the exception class of the innermost (root cause) exception
      error_class    TYPE string,
    END OF ty_s_roundtrip.

  "! Called once per POST roundtrip, after the response is built - also when
  "! it failed. Must never raise; the framework catches and ignores anything.
  "! The implementation decides itself whether and how to persist.
  "! @parameter is_roundtrip | what the roundtrip did and cost
  METHODS on_roundtrip
    IMPORTING
      is_roundtrip TYPE ty_s_roundtrip.

ENDINTERFACE.
