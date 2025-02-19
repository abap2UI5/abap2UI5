// if_apc_wsp_message.intf.abap
class if_apc_wsp_message {
  static INTERNAL_TYPE = 'INTF';
  static ATTRIBUTES = {};
  static METHODS = {"GET_BINARY": {"visibility": "U", "parameters": {"RV_BINARY": {"type": () => {return new abap.types.XString({qualifiedName: "XSTRING"});}, "is_optional": " "}}},
  "SET_BINARY": {"visibility": "U", "parameters": {"IV_BINARY": {"type": () => {return new abap.types.Hex();}, "is_optional": " "}}},
  "GET_TEXT": {"visibility": "U", "parameters": {"R_MESSAGE": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}}};
}
abap.Classes['IF_APC_WSP_MESSAGE'] = if_apc_wsp_message;
export {if_apc_wsp_message};
//# sourceMappingURL=if_apc_wsp_message.intf.mjs.map