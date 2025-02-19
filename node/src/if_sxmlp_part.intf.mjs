// if_sxmlp_part.intf.abap
class if_sxmlp_part {
  static INTERNAL_TYPE = 'INTF';
  static ATTRIBUTES = {};
  static METHODS = {"SERIALIZE": {"visibility": "U", "parameters": {"WRITER": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_SXML_WRITER", RTTIName: "\\INTERFACE=IF_SXML_WRITER"});}, "is_optional": " "}}}};
}
abap.Classes['IF_SXMLP_PART'] = if_sxmlp_part;
export {if_sxmlp_part};
//# sourceMappingURL=if_sxmlp_part.intf.mjs.map