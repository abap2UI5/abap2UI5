// if_ixml_node_iterator.intf.abap
class if_ixml_node_iterator {
  static INTERNAL_TYPE = 'INTF';
  static ATTRIBUTES = {};
  static METHODS = {"RESET": {"visibility": "U", "parameters": {}},
  "GET_NEXT": {"visibility": "U", "parameters": {"RVAL": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE", RTTIName: "\\INTERFACE=IF_IXML_NODE"});}, "is_optional": " "}}}};
}
abap.Classes['IF_IXML_NODE_ITERATOR'] = if_ixml_node_iterator;
export {if_ixml_node_iterator};
//# sourceMappingURL=if_ixml_node_iterator.intf.mjs.map