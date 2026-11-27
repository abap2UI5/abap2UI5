"! The interface every abap2UI5 app implements: one class, and main( client )
"! is called on every roundtrip. How to build one - the class template, the
"! lifecycle, z2ui5_cl_ui5_view_builder, binding, events, popups, navigation -
"! is installed in this system: z2ui5_cl_ui5_llm=>guide( ) returns the guide
"! of exactly this release, written for a developer and for an AI assistant
"! working here, e.g. through ADT. Prefer it to what was written about older
"! releases. Online: https://abap2ui5.github.io/docs/ (llms.txt for machines);
"! for an agent with MCP: https://github.com/abap2UI5/mcp-server
INTERFACE z2ui5_if_app PUBLIC.
  INTERFACES if_serializable_object.

  CONSTANTS version TYPE string VALUE `1.151.0`.
  CONSTANTS origin  TYPE string VALUE `https://github.com/abap2UI5/abap2UI5`.
  CONSTANTS authors TYPE string VALUE `https://github.com/abap2UI5/abap2UI5/graphs/contributors`.
  CONSTANTS license TYPE string VALUE `MIT`.

  DATA id_draft TYPE string.
  DATA id_app   TYPE string.

  METHODS main
    IMPORTING
      client TYPE REF TO z2ui5_if_client.

ENDINTERFACE.
