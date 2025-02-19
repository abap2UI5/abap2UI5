// if_oauth2_client.intf.abap
class if_oauth2_client {
  static INTERNAL_TYPE = 'INTF';
  static ATTRIBUTES = {"C_PARAM_KIND_HEADER_FIELD": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "C_PARAM_KIND_FORM_FIELD": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "visibility": "U", "is_constant": "X", "is_class": "X"}};
  static METHODS = {"EXECUTE_CC_FLOW": {"visibility": "U", "parameters": {}},
  "SET_TOKEN": {"visibility": "U", "parameters": {"IO_HTTP_CLIENT": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_HTTP_CLIENT", RTTIName: "\\INTERFACE=IF_HTTP_CLIENT"});}, "is_optional": " "}, "I_PARAM_KIND": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}}};
}
abap.Classes['IF_OAUTH2_CLIENT'] = if_oauth2_client;
if_oauth2_client.if_oauth2_client$c_param_kind_header_field = new abap.types.String({qualifiedName: "STRING"});
if_oauth2_client.if_oauth2_client$c_param_kind_header_field.set('H');
if_oauth2_client.if_oauth2_client$c_param_kind_form_field = new abap.types.String({qualifiedName: "STRING"});
if_oauth2_client.if_oauth2_client$c_param_kind_form_field.set('F');
export {if_oauth2_client};
//# sourceMappingURL=if_oauth2_client.intf.mjs.map