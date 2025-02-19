// if_sxmlp_list.intf.abap
class if_sxmlp_list {
  static INTERNAL_TYPE = 'INTF';
  static ATTRIBUTES = {};
  static METHODS = {"ADD_PART": {"visibility": "U", "parameters": {"PART": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_SXMLP_PART", RTTIName: "\\INTERFACE=IF_SXMLP_PART"});}, "is_optional": " "}}}};
}
abap.Classes['IF_SXMLP_LIST'] = if_sxmlp_list;
export {if_sxmlp_list};
//# sourceMappingURL=if_sxmlp_list.intf.mjs.map