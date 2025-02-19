// if_oo_clif_source.intf.abap
class if_oo_clif_source {
  static INTERNAL_TYPE = 'INTF';
  static ATTRIBUTES = {};
  static METHODS = {"GET_SOURCE": {"visibility": "U", "parameters": {"SOURCE": {"type": () => {return abap.types.TableFactory.construct(new abap.types.String({qualifiedName: "STRING"}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"isUnique":false,"type":"STANDARD","keyFields":[],"name":"primary_key"},"secondary":[]}, "STRING_TABLE");}, "is_optional": " "}}}};
}
abap.Classes['IF_OO_CLIF_SOURCE'] = if_oo_clif_source;
export {if_oo_clif_source};
//# sourceMappingURL=if_oo_clif_source.intf.mjs.map