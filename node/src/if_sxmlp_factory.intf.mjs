// if_sxmlp_factory.intf.abap
class if_sxmlp_factory {
  static INTERNAL_TYPE = 'INTF';
  static ATTRIBUTES = {};
  static METHODS = {"CREATE_LIST": {"visibility": "U", "parameters": {"RVAL": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_SXMLP_LIST", RTTIName: "\\INTERFACE=IF_SXMLP_LIST"});}, "is_optional": " "}, "NAME": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "NSURI": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "PREFIX": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}}};
}
abap.Classes['IF_SXMLP_FACTORY'] = if_sxmlp_factory;
export {if_sxmlp_factory};
//# sourceMappingURL=if_sxmlp_factory.intf.mjs.map