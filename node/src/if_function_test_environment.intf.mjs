// if_function_test_environment.intf.abap
class if_function_test_environment {
  static INTERNAL_TYPE = 'INTF';
  static ATTRIBUTES = {};
  static METHODS = {"GET_DOUBLE": {"visibility": "U", "parameters": {"RESULT": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_FUNCTION_TESTDOUBLE", RTTIName: "\\INTERFACE=IF_FUNCTION_TESTDOUBLE"});}, "is_optional": " "}, "FUNCTION_NAME": {"type": () => {return new abap.types.Character(30, {"qualifiedName":"SXCO_FM_NAME","ddicName":"SXCO_FM_NAME","description":"Function module name"});}, "is_optional": " "}}},
  "CLEAR_DOUBLES": {"visibility": "U", "parameters": {}}};
}
abap.Classes['IF_FUNCTION_TEST_ENVIRONMENT'] = if_function_test_environment;if_function_test_environment.tt_function_dependencies = abap.types.TableFactory.construct(new abap.types.Character(30, {"qualifiedName":"SXCO_FM_NAME","ddicName":"SXCO_FM_NAME","description":"Function module name"}), {"withHeader":false,"keyType":"USER","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":["TABLE_LINE"]},"secondary":[]}, "if_function_test_environment=>tt_function_dependencies");
export {if_function_test_environment};
//# sourceMappingURL=if_function_test_environment.intf.mjs.map