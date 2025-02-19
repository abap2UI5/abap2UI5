const {cx_root} = await import("./cx_root.clas.mjs");
// cl_apc_wsp_ext_stateless_base.clas.abap
class cl_apc_wsp_ext_stateless_base {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CL_APC_WSP_EXT_STATELESS_BASE';
  static IMPLEMENTED_INTERFACES = ["IF_APC_WSP_EXTENSION"];
  static ATTRIBUTES = {};
  static METHODS = {};
  constructor() {
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
  }
  async constructor_(INPUT) {
    if (super.constructor_) { await super.constructor_(INPUT); }
    return this;
  }
  async if_apc_wsp_extension$on_start(INPUT) {
    let i_context = INPUT?.i_context;
    if (i_context?.getQualifiedName === undefined || i_context.getQualifiedName() !== "IF_APC_WSP_SERVER_CONTEXT") { i_context = undefined; }
    if (i_context === undefined) { i_context = new abap.types.ABAPObject({qualifiedName: "IF_APC_WSP_SERVER_CONTEXT", RTTIName: "\\INTERFACE=IF_APC_WSP_SERVER_CONTEXT"}).set(INPUT.i_context); }
    let i_message_manager = INPUT?.i_message_manager;
    if (i_message_manager?.getQualifiedName === undefined || i_message_manager.getQualifiedName() !== "IF_APC_WSP_MESSAGE_MANAGER") { i_message_manager = undefined; }
    if (i_message_manager === undefined) { i_message_manager = new abap.types.ABAPObject({qualifiedName: "IF_APC_WSP_MESSAGE_MANAGER", RTTIName: "\\INTERFACE=IF_APC_WSP_MESSAGE_MANAGER"}).set(INPUT.i_message_manager); }
    return;
  }
  async if_apc_wsp_extension$on_message(INPUT) {
    let i_message = INPUT?.i_message;
    if (i_message?.getQualifiedName === undefined || i_message.getQualifiedName() !== "IF_APC_WSP_MESSAGE") { i_message = undefined; }
    if (i_message === undefined) { i_message = new abap.types.ABAPObject({qualifiedName: "IF_APC_WSP_MESSAGE", RTTIName: "\\INTERFACE=IF_APC_WSP_MESSAGE"}).set(INPUT.i_message); }
    let i_message_manager = INPUT?.i_message_manager;
    if (i_message_manager?.getQualifiedName === undefined || i_message_manager.getQualifiedName() !== "IF_APC_WSP_MESSAGE_MANAGER") { i_message_manager = undefined; }
    if (i_message_manager === undefined) { i_message_manager = new abap.types.ABAPObject({qualifiedName: "IF_APC_WSP_MESSAGE_MANAGER", RTTIName: "\\INTERFACE=IF_APC_WSP_MESSAGE_MANAGER"}).set(INPUT.i_message_manager); }
    let i_context = INPUT?.i_context;
    if (i_context?.getQualifiedName === undefined || i_context.getQualifiedName() !== "IF_APC_WSP_SERVER_CONTEXT") { i_context = undefined; }
    if (i_context === undefined) { i_context = new abap.types.ABAPObject({qualifiedName: "IF_APC_WSP_SERVER_CONTEXT", RTTIName: "\\INTERFACE=IF_APC_WSP_SERVER_CONTEXT"}).set(INPUT.i_context); }
    return;
  }
}
abap.Classes['CL_APC_WSP_EXT_STATELESS_BASE'] = cl_apc_wsp_ext_stateless_base;
export {cl_apc_wsp_ext_stateless_base};
//# sourceMappingURL=cl_apc_wsp_ext_stateless_base.clas.mjs.map