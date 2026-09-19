"! <p class="shorttext synchronized">abap2UI5 - app state serializer</p>
"!
"! How an app's state becomes a string between two roundtrips, and how it comes
"! back. The shipped implementation is z2ui5_cl_ui5_serializer, which uses
"! CALL TRANSFORMATION id over the container plus S-RTTI for the data
"! references - that is what every system gets and nothing about it changes.
"!
"! The interface exists because that mechanism is ABAP's type system and has no
"! counterpart anywhere else. abap2UI5 already runs outside an SAP system
"! (node/srv/express.mjs, over the transpiler and open-abap), and there the
"! asXML round trip is the single most expensive thing to reproduce: it walks
"! type descriptors a JavaScript object does not have. A host that would rather
"! persist its own shape - JSON keyed by class name, say - could not, because
"! both directions were wired straight into z2ui5_cl_ui5_app_cont.
"!
"! The contract an implementation has to keep is a round trip, not a format:
"! parse( stringify( container ) ) must answer a container the framework can go
"! on with - same app instance state, same mt_attri, same ms_draft. The string
"! in between is the implementation's business and nothing reads it but the
"! same implementation.
INTERFACE z2ui5_if_ui5_serializer
  PUBLIC.

  " Both ends are REF TO object rather than REF TO z2ui5_cl_ui5_app_cont, and
  " that is not laziness: an interface here may not reference a class
  " (abaplint intf_referencing_clas, an error in this repository) and naming
  " it would additionally close a cycle, since the container is what calls the
  " interface. The concrete type lives in the implementation, which narrows
  " once - the same shape z2ui5_cl_ui5_srv_model's constructor already uses
  " for the app object it is handed.

  "! The container and everything it holds, as a string for the draft store.
  "! @parameter container | the live z2ui5_cl_ui5_app_cont of this roundtrip
  "! @parameter result | what parse( ) will be given on the next roundtrip
  METHODS stringify
    IMPORTING
      container     TYPE REF TO object
    RETURNING
      VALUE(result) TYPE string.

  "! Rebuild a container from what stringify( ) produced. An empty input
  "! answers an unbound reference - that is how a first roundtrip arrives.
  "! @parameter val | the string a previous stringify( ) produced
  "! @parameter result | a z2ui5_cl_ui5_app_cont; the caller narrows it
  METHODS parse
    IMPORTING
      val           TYPE clike
    RETURNING
      VALUE(result) TYPE REF TO object.

ENDINTERFACE.
