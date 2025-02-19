await import("./cl_apc_tcp_client_manager.clas.locals.mjs");
const {cx_root} = await import("./cx_root.clas.mjs");
// cl_apc_tcp_client_manager.clas.abap
class cl_apc_tcp_client_manager {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CL_APC_TCP_CLIENT_MANAGER';
  static IMPLEMENTED_INTERFACES = [];
  static ATTRIBUTES = {"CO_PROTOCOL_TYPE_TCP": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "CO_PROTOCOL_TYPE_TCPS": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": "X", "is_class": "X"}};
  static METHODS = {"CREATE": {"visibility": "U", "parameters": {"RI_CLIENT": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_APC_WSP_CLIENT", RTTIName: "\\INTERFACE=IF_APC_WSP_CLIENT"});}, "is_optional": " "}, "I_HOST": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "I_PORT": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "I_FRAME": {"type": () => {return new abap.types.Structure({"frame_type": new abap.types.Integer({qualifiedName: "IF_ABAP_CHANNEL_TYPES=>TY_APC_TCP_FRAME-FRAME_TYPE"}), "fixed_length": new abap.types.Integer({qualifiedName: "IF_ABAP_CHANNEL_TYPES=>TY_APC_TCP_FRAME-FIXED_LENGTH"}), "terminator": new abap.types.String({qualifiedName: "IF_ABAP_CHANNEL_TYPES=>TY_APC_TCP_FRAME-TERMINATOR"}), "length_field_length": new abap.types.Integer({qualifiedName: "IF_ABAP_CHANNEL_TYPES=>TY_APC_TCP_FRAME-LENGTH_FIELD_LENGTH"}), "length_field_offset": new abap.types.Integer({qualifiedName: "IF_ABAP_CHANNEL_TYPES=>TY_APC_TCP_FRAME-LENGTH_FIELD_OFFSET"}), "length_field_header": new abap.types.Integer({qualifiedName: "IF_ABAP_CHANNEL_TYPES=>TY_APC_TCP_FRAME-LENGTH_FIELD_HEADER"})}, "if_abap_channel_types=>ty_apc_tcp_frame", undefined, {}, {});}, "is_optional": " "}, "I_EVENT_HANDLER": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_APC_WSP_EVENT_HANDLER", RTTIName: "\\INTERFACE=IF_APC_WSP_EVENT_HANDLER"});}, "is_optional": " "}, "I_PROTOCOL": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}, "I_SSL_ID": {"type": () => {return new abap.types.Character(6, {"qualifiedName":"SSFAPPLSSL","ddicName":"SSFAPPLSSL","description":"SSL ID"});}, "is_optional": " "}}}};
  constructor() {
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
    this.co_protocol_type_tcp = cl_apc_tcp_client_manager.co_protocol_type_tcp;
    this.co_protocol_type_tcps = cl_apc_tcp_client_manager.co_protocol_type_tcps;
  }
  async constructor_(INPUT) {
    if (super.constructor_) { await super.constructor_(INPUT); }
    return this;
  }
  async create(INPUT) {
    return cl_apc_tcp_client_manager.create(INPUT);
  }
  static async create(INPUT) {
    let ri_client = new abap.types.ABAPObject({qualifiedName: "IF_APC_WSP_CLIENT", RTTIName: "\\INTERFACE=IF_APC_WSP_CLIENT"});
    let i_host = INPUT?.i_host;
    if (i_host?.getQualifiedName === undefined || i_host.getQualifiedName() !== "STRING") { i_host = undefined; }
    if (i_host === undefined) { i_host = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.i_host); }
    let i_port = INPUT?.i_port;
    if (i_port?.getQualifiedName === undefined || i_port.getQualifiedName() !== "STRING") { i_port = undefined; }
    if (i_port === undefined) { i_port = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.i_port); }
    let i_frame = INPUT?.i_frame;
    if (i_frame?.getQualifiedName === undefined || i_frame.getQualifiedName() !== "IF_ABAP_CHANNEL_TYPES=>TY_APC_TCP_FRAME") { i_frame = undefined; }
    if (i_frame === undefined) { i_frame = new abap.types.Structure({"frame_type": new abap.types.Integer({qualifiedName: "IF_ABAP_CHANNEL_TYPES=>TY_APC_TCP_FRAME-FRAME_TYPE"}), "fixed_length": new abap.types.Integer({qualifiedName: "IF_ABAP_CHANNEL_TYPES=>TY_APC_TCP_FRAME-FIXED_LENGTH"}), "terminator": new abap.types.String({qualifiedName: "IF_ABAP_CHANNEL_TYPES=>TY_APC_TCP_FRAME-TERMINATOR"}), "length_field_length": new abap.types.Integer({qualifiedName: "IF_ABAP_CHANNEL_TYPES=>TY_APC_TCP_FRAME-LENGTH_FIELD_LENGTH"}), "length_field_offset": new abap.types.Integer({qualifiedName: "IF_ABAP_CHANNEL_TYPES=>TY_APC_TCP_FRAME-LENGTH_FIELD_OFFSET"}), "length_field_header": new abap.types.Integer({qualifiedName: "IF_ABAP_CHANNEL_TYPES=>TY_APC_TCP_FRAME-LENGTH_FIELD_HEADER"})}, "if_abap_channel_types=>ty_apc_tcp_frame", undefined, {}, {}).set(INPUT.i_frame); }
    let i_event_handler = INPUT?.i_event_handler;
    if (i_event_handler?.getQualifiedName === undefined || i_event_handler.getQualifiedName() !== "IF_APC_WSP_EVENT_HANDLER") { i_event_handler = undefined; }
    if (i_event_handler === undefined) { i_event_handler = new abap.types.ABAPObject({qualifiedName: "IF_APC_WSP_EVENT_HANDLER", RTTIName: "\\INTERFACE=IF_APC_WSP_EVENT_HANDLER"}).set(INPUT.i_event_handler); }
    let i_protocol = new abap.types.Integer({qualifiedName: "I"});
    if (INPUT && INPUT.i_protocol) {i_protocol.set(INPUT.i_protocol);}
    if (INPUT === undefined || INPUT.i_protocol === undefined) {i_protocol = this.co_protocol_type_tcp;}
    let i_ssl_id = new abap.types.Character(6, {"qualifiedName":"SSFAPPLSSL","ddicName":"SSFAPPLSSL","description":"SSL ID"});
    if (INPUT && INPUT.i_ssl_id) {i_ssl_id.set(INPUT.i_ssl_id);}
    let lv_port = new abap.types.Integer({qualifiedName: "I"});
    lv_port.set(i_port);
    ri_client.set(await (new abap.Classes['CLAS-CL_APC_TCP_CLIENT_MANAGER-LCL_CLIENT']()).constructor_({iv_host: i_host, iv_port: lv_port, io_handler: i_event_handler, iv_protocol: i_protocol}));
    return ri_client;
  }
}
abap.Classes['CL_APC_TCP_CLIENT_MANAGER'] = cl_apc_tcp_client_manager;
cl_apc_tcp_client_manager.co_protocol_type_tcp = new abap.types.Integer({qualifiedName: "I"});
cl_apc_tcp_client_manager.co_protocol_type_tcp.set(1);
cl_apc_tcp_client_manager.co_protocol_type_tcps = new abap.types.Integer({qualifiedName: "I"});
cl_apc_tcp_client_manager.co_protocol_type_tcps.set(2);
export {cl_apc_tcp_client_manager};
//# sourceMappingURL=cl_apc_tcp_client_manager.clas.mjs.map