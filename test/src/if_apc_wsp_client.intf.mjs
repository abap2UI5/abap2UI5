// if_apc_wsp_client.intf.abap
class if_apc_wsp_client {
  static INTERNAL_TYPE = 'INTF';
  static ATTRIBUTES = {};
  static METHODS = {"CONNECT": {"visibility": "U", "parameters": {}},
  "CLOSE": {"visibility": "U", "parameters": {}},
  "GET_MESSAGE_MANAGER": {"visibility": "U", "parameters": {"RI_MANAGER": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_APC_WSP_MESSAGE_MANAGER", RTTIName: "\\INTERFACE=IF_APC_WSP_MESSAGE_MANAGER"});}, "is_optional": " "}}}};
}
abap.Classes['IF_APC_WSP_CLIENT'] = if_apc_wsp_client;
export {if_apc_wsp_client};
//# sourceMappingURL=if_apc_wsp_client.intf.mjs.map