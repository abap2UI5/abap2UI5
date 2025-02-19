// if_apc_wsp_event_handler.intf.abap
class if_apc_wsp_event_handler {
  static INTERNAL_TYPE = 'INTF';
  static ATTRIBUTES = {};
  static METHODS = {"ON_OPEN": {"visibility": "U", "parameters": {}},
  "ON_MESSAGE": {"visibility": "U", "parameters": {"I_MESSAGE": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_APC_WSP_MESSAGE", RTTIName: "\\INTERFACE=IF_APC_WSP_MESSAGE"});}, "is_optional": " "}}},
  "ON_CLOSE": {"visibility": "U", "parameters": {}},
  "ON_ERROR": {"visibility": "U", "parameters": {"I_REASON": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}}};
}
abap.Classes['IF_APC_WSP_EVENT_HANDLER'] = if_apc_wsp_event_handler;
export {if_apc_wsp_event_handler};
//# sourceMappingURL=if_apc_wsp_event_handler.intf.mjs.map