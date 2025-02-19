// if_ixml_node_collection.intf.abap
class if_ixml_node_collection {
  static INTERNAL_TYPE = 'INTF';
  static ATTRIBUTES = {};
  static METHODS = {"CREATE_ITERATOR": {"visibility": "U", "parameters": {"RVAL": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE_ITERATOR", RTTIName: "\\INTERFACE=IF_IXML_NODE_ITERATOR"});}, "is_optional": " "}}},
  "GET_LENGTH": {"visibility": "U", "parameters": {"RVAL": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}}},
  "GET_ITEM": {"visibility": "U", "parameters": {"RVAL": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE", RTTIName: "\\INTERFACE=IF_IXML_NODE"});}, "is_optional": " "}, "INDEX": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}}}};
}
abap.Classes['IF_IXML_NODE_COLLECTION'] = if_ixml_node_collection;
export {if_ixml_node_collection};
//# sourceMappingURL=if_ixml_node_collection.intf.mjs.map