// if_sxml_close_element.intf.abap
class if_sxml_close_element {
  static INTERNAL_TYPE = 'INTF';
  static ATTRIBUTES = {"QNAME": {"type": () => {return new abap.types.Structure({"name": new abap.types.String({qualifiedName: "STRING"}), "namespace": new abap.types.String({qualifiedName: "STRING"})}, undefined, undefined, {}, {});}, "visibility": "U", "is_constant": " ", "is_class": " "},
  "IF_SXML_NODE~TYPE": {"type": () => {return new abap.types.Integer({qualifiedName: "IF_SXML_NODE=>NODE_TYPE"});}, "visibility": "U", "is_constant": " ", "is_class": " "},
  "IF_SXML_NODE~CO_NT_INITIAL": {"type": () => {return new abap.types.Integer({qualifiedName: "IF_SXML_NODE=>NODE_TYPE"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "IF_SXML_NODE~CO_NT_ELEMENT_OPEN": {"type": () => {return new abap.types.Integer({qualifiedName: "IF_SXML_NODE=>NODE_TYPE"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "IF_SXML_NODE~CO_NT_ELEMENT_CLOSE": {"type": () => {return new abap.types.Integer({qualifiedName: "IF_SXML_NODE=>NODE_TYPE"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "IF_SXML_NODE~CO_NT_VALUE": {"type": () => {return new abap.types.Integer({qualifiedName: "IF_SXML_NODE=>NODE_TYPE"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "IF_SXML_NODE~CO_NT_ATTRIBUTE": {"type": () => {return new abap.types.Integer({qualifiedName: "IF_SXML_NODE=>NODE_TYPE"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "IF_SXML_NODE~CO_NT_FINAL": {"type": () => {return new abap.types.Integer({qualifiedName: "IF_SXML_NODE=>NODE_TYPE"});}, "visibility": "U", "is_constant": "X", "is_class": "X"}};
  static METHODS = {};
}
abap.Classes['IF_SXML_CLOSE_ELEMENT'] = if_sxml_close_element;
export {if_sxml_close_element};
//# sourceMappingURL=if_sxml_close_element.intf.mjs.map