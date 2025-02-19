// if_http_extension.intf.abap
class if_http_extension {
  static INTERNAL_TYPE = 'INTF';
  static ATTRIBUTES = {"FLOW_RC": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": " ", "is_class": " "},
  "CO_FLOW_OK": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "CO_FLOW_OK_OTHERS_MAND": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": "X", "is_class": "X"}};
  static METHODS = {"HANDLE_REQUEST": {"visibility": "U", "parameters": {"SERVER": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_HTTP_SERVER", RTTIName: "\\INTERFACE=IF_HTTP_SERVER"});}, "is_optional": " "}}}};
}
abap.Classes['IF_HTTP_EXTENSION'] = if_http_extension;
if_http_extension.if_http_extension$co_flow_ok = new abap.types.Integer({qualifiedName: "I"});
if_http_extension.if_http_extension$co_flow_ok.set(0);
if_http_extension.if_http_extension$co_flow_ok_others_mand = new abap.types.Integer({qualifiedName: "I"});
if_http_extension.if_http_extension$co_flow_ok_others_mand.set(2);
export {if_http_extension};
//# sourceMappingURL=if_http_extension.intf.mjs.map