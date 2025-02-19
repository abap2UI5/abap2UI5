// if_function_testdouble.intf.abap
class if_function_testdouble {
  static INTERNAL_TYPE = 'INTF';
  static ATTRIBUTES = {};
  static METHODS = {"CONFIGURE_CALL": {"visibility": "U", "parameters": {"INPUT_CONFIGURATION_SETTER": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_FTD_INPUT_CONFIG_SETTER", RTTIName: "\\INTERFACE=IF_FTD_INPUT_CONFIG_SETTER"});}, "is_optional": " "}}}};
}
abap.Classes['IF_FUNCTION_TESTDOUBLE'] = if_function_testdouble;
export {if_function_testdouble};
//# sourceMappingURL=if_function_testdouble.intf.mjs.map