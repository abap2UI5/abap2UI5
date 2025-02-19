// if_apc_wsp_message_manager.intf.abap
class if_apc_wsp_message_manager {
  static INTERNAL_TYPE = 'INTF';
  static ATTRIBUTES = {};
  static METHODS = {"CREATE_MESSAGE": {"visibility": "U", "parameters": {"RI_MESSAGE": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_APC_WSP_MESSAGE", RTTIName: "\\INTERFACE=IF_APC_WSP_MESSAGE"});}, "is_optional": " "}}},
  "SEND": {"visibility": "U", "parameters": {"II_MESSAGE": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_APC_WSP_MESSAGE", RTTIName: "\\INTERFACE=IF_APC_WSP_MESSAGE"});}, "is_optional": " "}}}};
}
abap.Classes['IF_APC_WSP_MESSAGE_MANAGER'] = if_apc_wsp_message_manager;
export {if_apc_wsp_message_manager};
//# sourceMappingURL=if_apc_wsp_message_manager.intf.mjs.map