// if_abap_channel_types.intf.abap
class if_abap_channel_types {
  static INTERNAL_TYPE = 'INTF';
  static ATTRIBUTES = {};
  static METHODS = {};
}
abap.Classes['IF_ABAP_CHANNEL_TYPES'] = if_abap_channel_types;if_abap_channel_types.ty_apc_tcp_frame = new abap.types.Structure({"frame_type": new abap.types.Integer({qualifiedName: "IF_ABAP_CHANNEL_TYPES=>TY_APC_TCP_FRAME-FRAME_TYPE"}), "fixed_length": new abap.types.Integer({qualifiedName: "IF_ABAP_CHANNEL_TYPES=>TY_APC_TCP_FRAME-FIXED_LENGTH"}), "terminator": new abap.types.String({qualifiedName: "IF_ABAP_CHANNEL_TYPES=>TY_APC_TCP_FRAME-TERMINATOR"}), "length_field_length": new abap.types.Integer({qualifiedName: "IF_ABAP_CHANNEL_TYPES=>TY_APC_TCP_FRAME-LENGTH_FIELD_LENGTH"}), "length_field_offset": new abap.types.Integer({qualifiedName: "IF_ABAP_CHANNEL_TYPES=>TY_APC_TCP_FRAME-LENGTH_FIELD_OFFSET"}), "length_field_header": new abap.types.Integer({qualifiedName: "IF_ABAP_CHANNEL_TYPES=>TY_APC_TCP_FRAME-LENGTH_FIELD_HEADER"})}, "if_abap_channel_types=>ty_apc_tcp_frame", undefined, {}, {});
if_abap_channel_types.ty_tihttpnvp = abap.types.TableFactory.construct(new abap.types.Structure({"name": new abap.types.String({qualifiedName: "STRING"}), "value": new abap.types.String({qualifiedName: "STRING"})}, "IHTTPNVP", "IHTTPNVP", {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"isUnique":false,"type":"STANDARD","keyFields":[],"name":"primary_key"},"secondary":[]}, "TIHTTPNVP");
export {if_abap_channel_types};
//# sourceMappingURL=if_abap_channel_types.intf.mjs.map