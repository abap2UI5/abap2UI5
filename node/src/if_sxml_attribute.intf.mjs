// if_sxml_attribute.intf.abap
class if_sxml_attribute {
  static INTERNAL_TYPE = 'INTF';
  static ATTRIBUTES = {"QNAME": {"type": () => {return new abap.types.Structure({"name": new abap.types.String({qualifiedName: "STRING"}), "namespace": new abap.types.String({qualifiedName: "STRING"})}, undefined, undefined, {}, {});}, "visibility": "U", "is_constant": " ", "is_class": " "},
  "PREFIX": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "visibility": "U", "is_constant": " ", "is_class": " "},
  "VALUE_TYPE": {"type": () => {return new abap.types.Integer({qualifiedName: "IF_SXML_VALUE=>VALUE_TYPE"});}, "visibility": "U", "is_constant": " ", "is_class": " "}};
  static METHODS = {"GET_VALUE": {"visibility": "U", "parameters": {"VALUE": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}}};
}
abap.Classes['IF_SXML_ATTRIBUTE'] = if_sxml_attribute;
if_sxml_attribute.attributes = abap.types.TableFactory.construct(new abap.types.ABAPObject({qualifiedName: "IF_SXML_ATTRIBUTE", RTTIName: "\\INTERFACE=IF_SXML_ATTRIBUTE"}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "if_sxml_attribute=>attributes");
export {if_sxml_attribute};
//# sourceMappingURL=if_sxml_attribute.intf.mjs.map