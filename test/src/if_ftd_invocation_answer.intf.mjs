// if_ftd_invocation_answer.intf.abap
class if_ftd_invocation_answer {
  static INTERNAL_TYPE = 'INTF';
  static ATTRIBUTES = {};
  static METHODS = {"ANSWER": {"visibility": "U", "parameters": {"ARGUMENTS": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_FTD_INPUT_ARGUMENTS", RTTIName: "\\INTERFACE=IF_FTD_INPUT_ARGUMENTS"});}, "is_optional": " "}, "RESULT": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_FTD_INVOCATION_RESULT", RTTIName: "\\INTERFACE=IF_FTD_INVOCATION_RESULT"});}, "is_optional": " "}}}};
}
abap.Classes['IF_FTD_INVOCATION_ANSWER'] = if_ftd_invocation_answer;
export {if_ftd_invocation_answer};
//# sourceMappingURL=if_ftd_invocation_answer.intf.mjs.map