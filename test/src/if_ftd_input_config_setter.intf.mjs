// if_ftd_input_config_setter.intf.abap
class if_ftd_input_config_setter {
  static INTERNAL_TYPE = 'INTF';
  static ATTRIBUTES = {};
  static METHODS = {"IGNORE_ALL_PARAMETERS": {"visibility": "U", "parameters": {"OUTPUT_CONFIGURATION_SETTER": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_FTD_OUTPUT_CONFIG_SETTER", RTTIName: "\\INTERFACE=IF_FTD_OUTPUT_CONFIG_SETTER"});}, "is_optional": " "}}}};
}
abap.Classes['IF_FTD_INPUT_CONFIG_SETTER'] = if_ftd_input_config_setter;
export {if_ftd_input_config_setter};
//# sourceMappingURL=if_ftd_input_config_setter.intf.mjs.map