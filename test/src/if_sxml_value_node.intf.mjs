// if_sxml_value_node.intf.abap
class if_sxml_value_node {
  static INTERNAL_TYPE = 'INTF';
  static ATTRIBUTES = {"IF_SXML_NODE~TYPE": {"type": () => {return new abap.types.Integer({qualifiedName: "IF_SXML_NODE=>NODE_TYPE"});}, "visibility": "U", "is_constant": " ", "is_class": " "},
  "IF_SXML_NODE~CO_NT_INITIAL": {"type": () => {return new abap.types.Integer({qualifiedName: "IF_SXML_NODE=>NODE_TYPE"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "IF_SXML_NODE~CO_NT_ELEMENT_OPEN": {"type": () => {return new abap.types.Integer({qualifiedName: "IF_SXML_NODE=>NODE_TYPE"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "IF_SXML_NODE~CO_NT_ELEMENT_CLOSE": {"type": () => {return new abap.types.Integer({qualifiedName: "IF_SXML_NODE=>NODE_TYPE"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "IF_SXML_NODE~CO_NT_VALUE": {"type": () => {return new abap.types.Integer({qualifiedName: "IF_SXML_NODE=>NODE_TYPE"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "IF_SXML_NODE~CO_NT_ATTRIBUTE": {"type": () => {return new abap.types.Integer({qualifiedName: "IF_SXML_NODE=>NODE_TYPE"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "IF_SXML_NODE~CO_NT_FINAL": {"type": () => {return new abap.types.Integer({qualifiedName: "IF_SXML_NODE=>NODE_TYPE"});}, "visibility": "U", "is_constant": "X", "is_class": "X"}};
  static METHODS = {"GET_VALUE": {"visibility": "U", "parameters": {"VALUE": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}},
  "GET_VALUE_RAW": {"visibility": "U", "parameters": {"VALUE": {"type": () => {return new abap.types.XString({qualifiedName: "XSTRING"});}, "is_optional": " "}}},
  "SET_VALUE": {"visibility": "U", "parameters": {"VALUE": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}},
  "SET_VALUE_RAW": {"visibility": "U", "parameters": {"VALUE": {"type": () => {return new abap.types.XString({qualifiedName: "XSTRING"});}, "is_optional": " "}}}};
}
abap.Classes['IF_SXML_VALUE_NODE'] = if_sxml_value_node;
export {if_sxml_value_node};
//# sourceMappingURL=if_sxml_value_node.intf.mjs.map