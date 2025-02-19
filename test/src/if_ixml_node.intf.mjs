// if_ixml_node.intf.abap
class if_ixml_node {
  static INTERNAL_TYPE = 'INTF';
  static ATTRIBUTES = {"CO_NODE_DOCUMENT": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "CO_NODE_ELEMENT": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "CO_NODE_TEXT": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "CO_NODE_CDATA_SECTION": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": "X", "is_class": "X"}};
  static METHODS = {"APPEND_CHILD": {"visibility": "U", "parameters": {"NEW_CHILD": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE", RTTIName: "\\INTERFACE=IF_IXML_NODE"});}, "is_optional": " "}}},
  "GET_ATTRIBUTES": {"visibility": "U", "parameters": {"MAP": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_IXML_NAMED_NODE_MAP", RTTIName: "\\INTERFACE=IF_IXML_NAMED_NODE_MAP"});}, "is_optional": " "}}},
  "GET_FIRST_CHILD": {"visibility": "U", "parameters": {"NODE": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE", RTTIName: "\\INTERFACE=IF_IXML_NODE"});}, "is_optional": " "}}},
  "GET_CHILDREN": {"visibility": "U", "parameters": {"VAL": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE_LIST", RTTIName: "\\INTERFACE=IF_IXML_NODE_LIST"});}, "is_optional": " "}}},
  "QUERY_INTERFACE": {"visibility": "U", "parameters": {"RVAL": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_IXML_UNKNOWN", RTTIName: "\\INTERFACE=IF_IXML_UNKNOWN"});}, "is_optional": " "}, "IID": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}}},
  "REMOVE_NODE": {"visibility": "U", "parameters": {}},
  "GET_PARENT": {"visibility": "U", "parameters": {"VAL": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE", RTTIName: "\\INTERFACE=IF_IXML_NODE"});}, "is_optional": " "}}},
  "REPLACE_CHILD": {"visibility": "U", "parameters": {"NEW_CHILD": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "OLD_CHILD": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}},
  "GET_NAME": {"visibility": "U", "parameters": {"VAL": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}},
  "GET_DEPTH": {"visibility": "U", "parameters": {"VAL": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}}},
  "IS_LEAF": {"visibility": "U", "parameters": {"VAL": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});}, "is_optional": " "}}},
  "GET_NAMESPACE": {"visibility": "U", "parameters": {"VAL": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}},
  "GET_VALUE": {"visibility": "U", "parameters": {"VAL": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}},
  "GET_TYPE": {"visibility": "U", "parameters": {"VAL": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}},
  "SET_NAME": {"visibility": "U", "parameters": {"NAME": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}},
  "SET_NAMESPACE_PREFIX": {"visibility": "U", "parameters": {"VAL": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}},
  "REMOVE_CHILD": {"visibility": "U", "parameters": {"CHILD": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE", RTTIName: "\\INTERFACE=IF_IXML_NODE"});}, "is_optional": " "}}},
  "SET_VALUE": {"visibility": "U", "parameters": {"VALUE": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}},
  "GET_GID": {"visibility": "U", "parameters": {"RVAL": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}}},
  "INSERT_CHILD": {"visibility": "U", "parameters": {"RVAL": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}, "NEW_CHILD": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE", RTTIName: "\\INTERFACE=IF_IXML_NODE"});}, "is_optional": " "}, "REF_CHILD": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE", RTTIName: "\\INTERFACE=IF_IXML_NODE"});}, "is_optional": " "}}},
  "GET_NEXT": {"visibility": "U", "parameters": {"RVAL": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE", RTTIName: "\\INTERFACE=IF_IXML_NODE"});}, "is_optional": " "}}},
  "GET_NAMESPACE_PREFIX": {"visibility": "U", "parameters": {"RV_PREFIX": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}},
  "GET_NAMESPACE_URI": {"visibility": "U", "parameters": {"RVAL": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}},
  "GET_HEIGHT": {"visibility": "U", "parameters": {"RVAL": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}}},
  "CREATE_FILTER_NAME_NS": {"visibility": "U", "parameters": {"RVAL": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE_FILTER", RTTIName: "\\INTERFACE=IF_IXML_NODE_FILTER"});}, "is_optional": " "}, "NAME": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "NAMESPACE": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}},
  "GET_COLUMN": {"visibility": "U", "parameters": {"RVAL": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}}},
  "CREATE_ITERATOR_FILTERED": {"visibility": "U", "parameters": {"RVAL": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE_ITERATOR", RTTIName: "\\INTERFACE=IF_IXML_NODE_ITERATOR"});}, "is_optional": " "}, "FILTER": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE_FILTER", RTTIName: "\\INTERFACE=IF_IXML_NODE_FILTER"});}, "is_optional": " "}}},
  "CLONE": {"visibility": "U", "parameters": {"RVAL": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE", RTTIName: "\\INTERFACE=IF_IXML_NODE"});}, "is_optional": " "}}}};
}
abap.Classes['IF_IXML_NODE'] = if_ixml_node;
if_ixml_node.if_ixml_node$co_node_document = new abap.types.Integer({qualifiedName: "I"});
if_ixml_node.if_ixml_node$co_node_document.set(1);
if_ixml_node.if_ixml_node$co_node_element = new abap.types.Integer({qualifiedName: "I"});
if_ixml_node.if_ixml_node$co_node_element.set(4);
if_ixml_node.if_ixml_node$co_node_text = new abap.types.Integer({qualifiedName: "I"});
if_ixml_node.if_ixml_node$co_node_text.set(16);
if_ixml_node.if_ixml_node$co_node_cdata_section = new abap.types.Integer({qualifiedName: "I"});
if_ixml_node.if_ixml_node$co_node_cdata_section.set(32);
export {if_ixml_node};
//# sourceMappingURL=if_ixml_node.intf.mjs.map