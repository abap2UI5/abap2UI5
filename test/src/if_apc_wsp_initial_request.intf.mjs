// if_apc_wsp_initial_request.intf.abap
class if_apc_wsp_initial_request {
  static INTERNAL_TYPE = 'INTF';
  static ATTRIBUTES = {};
  static METHODS = {"GET_FORM_FIELDS": {"visibility": "U", "parameters": {"I_FORMFIELD_ENCODING": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}, "C_FIELDS": {"type": () => {return abap.types.TableFactory.construct(new abap.types.Structure({"name": new abap.types.String({qualifiedName: "STRING"}), "value": new abap.types.String({qualifiedName: "STRING"})}, "IHTTPNVP", "IHTTPNVP", {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"isUnique":false,"type":"STANDARD","keyFields":[],"name":"primary_key"},"secondary":[]}, "TIHTTPNVP");}, "is_optional": " "}}},
  "GET_HEADER_FIELDS": {"visibility": "U", "parameters": {"C_FIELDS": {"type": () => {return abap.types.TableFactory.construct(new abap.types.Structure({"name": new abap.types.String({qualifiedName: "STRING"}), "value": new abap.types.String({qualifiedName: "STRING"})}, "IHTTPNVP", "IHTTPNVP", {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"isUnique":false,"type":"STANDARD","keyFields":[],"name":"primary_key"},"secondary":[]}, "TIHTTPNVP");}, "is_optional": " "}}}};
}
abap.Classes['IF_APC_WSP_INITIAL_REQUEST'] = if_apc_wsp_initial_request;
export {if_apc_wsp_initial_request};
//# sourceMappingURL=if_apc_wsp_initial_request.intf.mjs.map