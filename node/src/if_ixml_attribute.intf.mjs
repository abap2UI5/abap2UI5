// if_ixml_attribute.intf.abap
class if_ixml_attribute {
  static INTERNAL_TYPE = 'INTF';
  static ATTRIBUTES = {"IF_IXML_NODE~CO_NODE_DOCUMENT": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "IF_IXML_NODE~CO_NODE_ELEMENT": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "IF_IXML_NODE~CO_NODE_TEXT": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "IF_IXML_NODE~CO_NODE_CDATA_SECTION": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": "X", "is_class": "X"}};
  static METHODS = {"GET_VALUE": {"visibility": "U", "parameters": {"VAL": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}},
  "SET_VALUE": {"visibility": "U", "parameters": {"VALUE": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}},
  "GET_NAME": {"visibility": "U", "parameters": {"VAL": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}}};
}
abap.Classes['IF_IXML_ATTRIBUTE'] = if_ixml_attribute;
export {if_ixml_attribute};
//# sourceMappingURL=if_ixml_attribute.intf.mjs.map