"! <p class="shorttext synchronized">abap2UI5 - draft store</p>
"!
"! Where an app's serialized state lives between two roundtrips. The shipped
"! implementation is z2ui5_cl_ui5_srv_draft, which keeps it in Z2UI5_T_01 -
"! that is what every system gets and nothing about it changes.
"!
"! The interface exists so a HOST can supply its own. abap2UI5 already runs
"! outside an SAP system - node/srv/express.mjs serves the transpiled
"! framework, and a CAP or Node host has its own persistence (a CDS entity, a
"! document store) that it would rather use than a table it has to recreate.
"! Without a seam such a host has to fork the class; with one it implements
"! nine methods and calls set_instance( ) at startup.
"!
"! The contract the shipped implementation defines and a host must keep:
"! a draft belongs to the user that created it, and read_draft( ), read_info( )
"! and check_exists( ) answer "not found" for anybody else - identically, so a
"! caller cannot tell a foreign draft from a missing one. count_entries( ) is
"! owner-scoped for the same reason; count_entries_total( ) is deliberately not,
"! because it reports the size of the store itself.
INTERFACE z2ui5_if_ui5_draft_store
  PUBLIC.

  TYPES ty_s_db TYPE z2ui5_t_01.

  TYPES:
    "! The four draft ids an app carries between roundtrips - what create( )
    "! is given and what read_info( ) hands back.
    BEGIN OF ty_s_draft,
      id                TYPE string,
      id_prev           TYPE string,
      id_prev_app       TYPE string,
      id_prev_app_stack TYPE string,
    END OF ty_s_draft.

  "! Drafts of the calling user - owner-scoped like read_draft( ) and check_exists( ).
  METHODS count_entries
    RETURNING
      VALUE(result) TYPE i.

  "! The size of the whole store, every owner included - what the start page
  "! shows next to the own count, and what says whether cleanup( ) keeps up.
  METHODS count_entries_total
    RETURNING
      VALUE(result) TYPE i.

  "! Persist one roundtrip's state.
  "! @parameter draft | the id chain of this roundtrip; the id must be filled
  "! @parameter model_xml | the serialized app state
  METHODS create
    IMPORTING
      draft     TYPE ty_s_draft
      model_xml TYPE clike.

  "! The full row including the serialized state.
  "! Raises z2ui5_cx_ui5_util_error when there is no such draft FOR THIS USER.
  METHODS read_draft
    IMPORTING
      id            TYPE clike
    RETURNING
      VALUE(result) TYPE ty_s_db.

  "! The id chain only - no state. Same owner rule as read_draft( ).
  METHODS read_info
    IMPORTING
      id            TYPE clike
    RETURNING
      VALUE(result) TYPE ty_s_draft.

  "! Whether a draft of this user exists. Never raises.
  METHODS check_exists
    IMPORTING
      id            TYPE clike
    RETURNING
      VALUE(result) TYPE abap_bool.

  "! Drop expired drafts. Called once per app first start by the handler
  "! (factory_first_start) - a page load with ?app_start=, and every bookmark
  "! or route restore (#/z2ui5-xapp-state=, Back/Forward under KEEP routing),
  "! each of which builds a fresh app - never on an event roundtrip, so it
  "! must be cheap. The shipped implementation ends with a COMMIT WORK. It may
  "! raise: the shipped implementation reads the expiry from the exit
  "! (z2ui5_cl_ui5_user_exit=>set_config_http_post), which fails closed when
  "! the installed exit cannot be instantiated, and the handler's outer TRY
  "! answers that with the error page - a store must not swallow such a
  "! failure to keep this call quiet.
  METHODS cleanup.

  "! Delete the one draft that just fell out of the window of the chain
  "! being saved - 2 by default, 0 switches it off (z2ui5_if_ui5_exit=>
  "! ty_s_http_config_post-draft_keep_per_chain). The chain is the id_prev links of the CALLING
  "! user's drafts: the draft just saved is depth 1, keep of them survive,
  "! and the one at depth keep + 1 is deleted - one draft per save, so the
  "! cost is keep - 1 keyed reads, whatever the length of the chain. Never
  "! deleted, and never walked past: an id of t_protect, the draft's own
  "! id_prev_app and id_prev_app_stack (the apps to go back to), and a draft
  "! any draft of the user names as its id_prev_app or id_prev_app_stack.
  "! A keep below z2ui5_cl_ui5_srv_draft=>c_min_keep_per_chain is raised to
  "! it, 0 or less does nothing. Called after create( ), never raises
  "! anything a caller has to handle: a draft that is not deleted only lives
  "! until cleanup( ) takes it by age.
  "! @parameter draft | the id chain of the draft just saved
  "! @parameter keep | how many drafts of the chain survive, this one included
  "! @parameter t_protect | ids that survive whatever their depth - the draft
  "! an app state link or a route restore started from (z2ui5_cl_ui5_app_cont=>mt_draft_keep)
  METHODS prune_chain
    IMPORTING
      draft     TYPE ty_s_draft
      keep      TYPE i
      t_protect TYPE string_table OPTIONAL.

  "! Give a draft of the calling user the current time, so cleanup( ) counts
  "! its age from now. Called instead of create( ) when a roundtrip answers
  "! with the draft it continued (an unchanged timer tick, see
  "! z2ui5_cl_ui5_handler=>main_end_reuse) - a poll that changes nothing for
  "! longer than the expiry would otherwise lose its draft under its feet.
  "! An unknown or foreign id is left alone. Never raises.
  METHODS touch
    IMPORTING
      id TYPE clike.

ENDINTERFACE.
