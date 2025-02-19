// if_sxml_node.intf.abap
class if_sxml_node {
  static INTERNAL_TYPE = 'INTF';
  static ATTRIBUTES = {"TYPE": {"type": () => {return new abap.types.Integer({qualifiedName: "IF_SXML_NODE=>NODE_TYPE"});}, "visibility": "U", "is_constant": " ", "is_class": " "},
  "CO_NT_INITIAL": {"type": () => {return new abap.types.Integer({qualifiedName: "IF_SXML_NODE=>NODE_TYPE"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "CO_NT_ELEMENT_OPEN": {"type": () => {return new abap.types.Integer({qualifiedName: "IF_SXML_NODE=>NODE_TYPE"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "CO_NT_ELEMENT_CLOSE": {"type": () => {return new abap.types.Integer({qualifiedName: "IF_SXML_NODE=>NODE_TYPE"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "CO_NT_VALUE": {"type": () => {return new abap.types.Integer({qualifiedName: "IF_SXML_NODE=>NODE_TYPE"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "CO_NT_ATTRIBUTE": {"type": () => {return new abap.types.Integer({qualifiedName: "IF_SXML_NODE=>NODE_TYPE"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "CO_NT_FINAL": {"type": () => {return new abap.types.Integer({qualifiedName: "IF_SXML_NODE=>NODE_TYPE"});}, "visibility": "U", "is_constant": "X", "is_class": "X"}};
  static METHODS = {};
}
abap.Classes['IF_SXML_NODE'] = if_sxml_node;
if_sxml_node.if_sxml_node$co_nt_initial = new abap.types.Integer({qualifiedName: "IF_SXML_NODE=>NODE_TYPE"});
if_sxml_node.if_sxml_node$co_nt_initial.set(0);
if_sxml_node.if_sxml_node$co_nt_element_open = new abap.types.Integer({qualifiedName: "IF_SXML_NODE=>NODE_TYPE"});
if_sxml_node.if_sxml_node$co_nt_element_open.set(1);
if_sxml_node.if_sxml_node$co_nt_element_close = new abap.types.Integer({qualifiedName: "IF_SXML_NODE=>NODE_TYPE"});
if_sxml_node.if_sxml_node$co_nt_element_close.set(2);
if_sxml_node.if_sxml_node$co_nt_value = new abap.types.Integer({qualifiedName: "IF_SXML_NODE=>NODE_TYPE"});
if_sxml_node.if_sxml_node$co_nt_value.set(4);
if_sxml_node.if_sxml_node$co_nt_attribute = new abap.types.Integer({qualifiedName: "IF_SXML_NODE=>NODE_TYPE"});
if_sxml_node.if_sxml_node$co_nt_attribute.set(32);
if_sxml_node.if_sxml_node$co_nt_final = new abap.types.Integer({qualifiedName: "IF_SXML_NODE=>NODE_TYPE"});
if_sxml_node.if_sxml_node$co_nt_final.set(128);
if_sxml_node.node_type = new abap.types.Integer({qualifiedName: "IF_SXML_NODE=>NODE_TYPE"});
export {if_sxml_node};
//# sourceMappingURL=if_sxml_node.intf.mjs.map