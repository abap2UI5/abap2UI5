// if_ftd_input_arguments.intf.abap
class if_ftd_input_arguments {
  static INTERNAL_TYPE = 'INTF';
  static ATTRIBUTES = {};
  static METHODS = {"GET_IMPORTING_PARAMETER": {"visibility": "U", "parameters": {"RESULT": {"type": () => {return new abap.types.DataReference(new abap.types.Character(4));}, "is_optional": " "}, "NAME": {"type": () => {return new abap.types.Character(30, {"qualifiedName":"abap_parmname"});}, "is_optional": " "}}},
  "GET_TABLE_PARAMETER": {"visibility": "U", "parameters": {"RESULT": {"type": () => {return new abap.types.DataReference(new abap.types.Character(4));}, "is_optional": " "}, "NAME": {"type": () => {return new abap.types.Character(30, {"qualifiedName":"abap_parmname"});}, "is_optional": " "}}}};
}
abap.Classes['IF_FTD_INPUT_ARGUMENTS'] = if_ftd_input_arguments;
export {if_ftd_input_arguments};
//# sourceMappingURL=if_ftd_input_arguments.intf.mjs.map