// if_ixml_unknown.intf.abap
class if_ixml_unknown {
  static INTERNAL_TYPE = 'INTF';
  static ATTRIBUTES = {};
  static METHODS = {"QUERY_INTERFACE": {"visibility": "U", "parameters": {"RVAL": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_IXML_UNKNOWN", RTTIName: "\\INTERFACE=IF_IXML_UNKNOWN"});}, "is_optional": " "}, "IID": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}}}};
}
abap.Classes['IF_IXML_UNKNOWN'] = if_ixml_unknown;
export {if_ixml_unknown};
//# sourceMappingURL=if_ixml_unknown.intf.mjs.map