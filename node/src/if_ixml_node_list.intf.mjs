// if_ixml_node_list.intf.abap
class if_ixml_node_list {
  static INTERNAL_TYPE = 'INTF';
  static ATTRIBUTES = {};
  static METHODS = {"GET_LENGTH": {"visibility": "U", "parameters": {"LENGTH": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}}},
  "CREATE_ITERATOR": {"visibility": "U", "parameters": {"RVAL": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE_ITERATOR", RTTIName: "\\INTERFACE=IF_IXML_NODE_ITERATOR"});}, "is_optional": " "}}},
  "GET_ITEM": {"visibility": "U", "parameters": {"VAL": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE", RTTIName: "\\INTERFACE=IF_IXML_NODE"});}, "is_optional": " "}, "INDEX": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}}},
  "CREATE_REV_ITERATOR_FILTERED": {"visibility": "U", "parameters": {"VAL": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE_ITERATOR", RTTIName: "\\INTERFACE=IF_IXML_NODE_ITERATOR"});}, "is_optional": " "}, "FILTER": {"type": () => {return new abap.types.Character(4);}, "is_optional": " "}}}};
}
abap.Classes['IF_IXML_NODE_LIST'] = if_ixml_node_list;
export {if_ixml_node_list};
//# sourceMappingURL=if_ixml_node_list.intf.mjs.map