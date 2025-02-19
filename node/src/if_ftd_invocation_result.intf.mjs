// if_ftd_invocation_result.intf.abap
class if_ftd_invocation_result {
  static INTERNAL_TYPE = 'INTF';
  static ATTRIBUTES = {};
  static METHODS = {"GET_OUTPUT_CONFIGURATION": {"visibility": "U", "parameters": {"RESULT": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_FTD_OUTPUT_CONFIGURATION", RTTIName: "\\INTERFACE=IF_FTD_OUTPUT_CONFIGURATION"});}, "is_optional": " "}}}};
}
abap.Classes['IF_FTD_INVOCATION_RESULT'] = if_ftd_invocation_result;
export {if_ftd_invocation_result};
//# sourceMappingURL=if_ftd_invocation_result.intf.mjs.map