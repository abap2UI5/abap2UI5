// if_ixml_named_node_map.intf.abap
class if_ixml_named_node_map {
  static INTERNAL_TYPE = 'INTF';
  static ATTRIBUTES = {};
  static METHODS = {"CREATE_ITERATOR": {"visibility": "U", "parameters": {"ITERATOR": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE_ITERATOR", RTTIName: "\\INTERFACE=IF_IXML_NODE_ITERATOR"});}, "is_optional": " "}}},
  "GET_LENGTH": {"visibility": "U", "parameters": {"VAL": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}}},
  "GET_NAMED_ITEM_NS": {"visibility": "U", "parameters": {"VAL": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE", RTTIName: "\\INTERFACE=IF_IXML_NODE"});}, "is_optional": " "}, "NAME": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}},
  "GET_NAMED_ITEM": {"visibility": "U", "parameters": {"VAL": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE", RTTIName: "\\INTERFACE=IF_IXML_NODE"});}, "is_optional": " "}, "NAME": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}},
  "SET_NAMED_ITEM_NS": {"visibility": "U", "parameters": {"NODE": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE", RTTIName: "\\INTERFACE=IF_IXML_NODE"});}, "is_optional": " "}}},
  "REMOVE_NAMED_ITEM": {"visibility": "U", "parameters": {"NAME": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}}};
}
abap.Classes['IF_IXML_NAMED_NODE_MAP'] = if_ixml_named_node_map;
export {if_ixml_named_node_map};
//# sourceMappingURL=if_ixml_named_node_map.intf.mjs.map