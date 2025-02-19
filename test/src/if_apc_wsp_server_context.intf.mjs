// if_apc_wsp_server_context.intf.abap
class if_apc_wsp_server_context {
  static INTERNAL_TYPE = 'INTF';
  static ATTRIBUTES = {};
  static METHODS = {"GET_INITIAL_REQUEST": {"visibility": "U", "parameters": {"R_INITIAL_REQUEST": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_APC_WSP_INITIAL_REQUEST", RTTIName: "\\INTERFACE=IF_APC_WSP_INITIAL_REQUEST"});}, "is_optional": " "}}},
  "GET_BINDING_MANAGER": {"visibility": "U", "parameters": {"R_BINDING_MANAGER": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_APC_WSP_BINDING_MANAGER", RTTIName: "\\INTERFACE=IF_APC_WSP_BINDING_MANAGER"});}, "is_optional": " "}}}};
}
abap.Classes['IF_APC_WSP_SERVER_CONTEXT'] = if_apc_wsp_server_context;
export {if_apc_wsp_server_context};
//# sourceMappingURL=if_apc_wsp_server_context.intf.mjs.map