// if_apc_tcp_frame_types.intf.abap
class if_apc_tcp_frame_types {
  static INTERNAL_TYPE = 'INTF';
  static ATTRIBUTES = {"CO_FRAME_TYPE_FIXED_LENGTH": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "CO_FRAME_TYPE_TERMINATOR": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "CO_FRAME_TYPE_LENGTH_FIELD": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": "X", "is_class": "X"}};
  static METHODS = {};
}
abap.Classes['IF_APC_TCP_FRAME_TYPES'] = if_apc_tcp_frame_types;
if_apc_tcp_frame_types.if_apc_tcp_frame_types$co_frame_type_fixed_length = new abap.types.Integer({qualifiedName: "I"});
if_apc_tcp_frame_types.if_apc_tcp_frame_types$co_frame_type_fixed_length.set(1);
if_apc_tcp_frame_types.if_apc_tcp_frame_types$co_frame_type_terminator = new abap.types.Integer({qualifiedName: "I"});
if_apc_tcp_frame_types.if_apc_tcp_frame_types$co_frame_type_terminator.set(2);
if_apc_tcp_frame_types.if_apc_tcp_frame_types$co_frame_type_length_field = new abap.types.Integer({qualifiedName: "I"});
if_apc_tcp_frame_types.if_apc_tcp_frame_types$co_frame_type_length_field.set(3);
export {if_apc_tcp_frame_types};
//# sourceMappingURL=if_apc_tcp_frame_types.intf.mjs.map