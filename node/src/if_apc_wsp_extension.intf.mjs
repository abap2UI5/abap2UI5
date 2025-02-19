// if_apc_wsp_extension.intf.abap
class if_apc_wsp_extension {
  static INTERNAL_TYPE = 'INTF';
  static ATTRIBUTES = {};
  static METHODS = {"ON_START": {"visibility": "U", "parameters": {"I_CONTEXT": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_APC_WSP_SERVER_CONTEXT", RTTIName: "\\INTERFACE=IF_APC_WSP_SERVER_CONTEXT"});}, "is_optional": " "}, "I_MESSAGE_MANAGER": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_APC_WSP_MESSAGE_MANAGER", RTTIName: "\\INTERFACE=IF_APC_WSP_MESSAGE_MANAGER"});}, "is_optional": " "}}},
  "ON_MESSAGE": {"visibility": "U", "parameters": {"I_MESSAGE": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_APC_WSP_MESSAGE", RTTIName: "\\INTERFACE=IF_APC_WSP_MESSAGE"});}, "is_optional": " "}, "I_MESSAGE_MANAGER": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_APC_WSP_MESSAGE_MANAGER", RTTIName: "\\INTERFACE=IF_APC_WSP_MESSAGE_MANAGER"});}, "is_optional": " "}, "I_CONTEXT": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_APC_WSP_SERVER_CONTEXT", RTTIName: "\\INTERFACE=IF_APC_WSP_SERVER_CONTEXT"});}, "is_optional": " "}}}};
}
abap.Classes['IF_APC_WSP_EXTENSION'] = if_apc_wsp_extension;
export {if_apc_wsp_extension};
//# sourceMappingURL=if_apc_wsp_extension.intf.mjs.map