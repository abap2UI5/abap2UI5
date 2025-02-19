// if_ftd_output_configuration.intf.abap
class if_ftd_output_configuration {
  static INTERNAL_TYPE = 'INTF';
  static ATTRIBUTES = {};
  static METHODS = {"SET_EXPORTING_PARAMETER": {"visibility": "U", "parameters": {"SELF": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_FTD_OUTPUT_CONFIGURATION", RTTIName: "\\INTERFACE=IF_FTD_OUTPUT_CONFIGURATION"});}, "is_optional": " "}, "NAME": {"type": () => {return new abap.types.Character(30, {"qualifiedName":"abap_parmname"});}, "is_optional": " "}, "VALUE": {"type": () => {return new abap.types.Character(4);}, "is_optional": " "}}},
  "SET_TABLE_PARAMETER": {"visibility": "U", "parameters": {"SELF": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_FTD_OUTPUT_CONFIGURATION", RTTIName: "\\INTERFACE=IF_FTD_OUTPUT_CONFIGURATION"});}, "is_optional": " "}, "NAME": {"type": () => {return new abap.types.Character(30, {"qualifiedName":"abap_parmname"});}, "is_optional": " "}, "VALUE": {"type": () => {return new abap.types.Character(4);}, "is_optional": " "}}}};
}
abap.Classes['IF_FTD_OUTPUT_CONFIGURATION'] = if_ftd_output_configuration;
export {if_ftd_output_configuration};
//# sourceMappingURL=if_ftd_output_configuration.intf.mjs.map