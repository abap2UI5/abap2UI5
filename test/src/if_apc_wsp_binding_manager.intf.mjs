// if_apc_wsp_binding_manager.intf.abap
class if_apc_wsp_binding_manager {
  static INTERNAL_TYPE = 'INTF';
  static ATTRIBUTES = {};
  static METHODS = {"BIND_AMC_MESSAGE_CONSUMER": {"visibility": "U", "parameters": {"I_APPLICATION_ID": {"type": () => {return new abap.types.Character();}, "is_optional": " "}, "I_CHANNEL_ID": {"type": () => {return new abap.types.Character();}, "is_optional": " "}}}};
}
abap.Classes['IF_APC_WSP_BINDING_MANAGER'] = if_apc_wsp_binding_manager;
export {if_apc_wsp_binding_manager};
//# sourceMappingURL=if_apc_wsp_binding_manager.intf.mjs.map