// if_osql_test_environment.intf.abap
class if_osql_test_environment {
  static INTERNAL_TYPE = 'INTF';
  static ATTRIBUTES = {};
  static METHODS = {"CLEAR_DOUBLES": {"visibility": "U", "parameters": {}},
  "DESTROY": {"visibility": "U", "parameters": {}},
  "INSERT_TEST_DATA": {"visibility": "U", "parameters": {"I_DATA": {"type": () => {return abap.types.TableFactory.construct(new abap.types.Character(4), {"withHeader":false,"keyType":"DEFAULT"});}, "is_optional": " "}}}};
}
abap.Classes['IF_OSQL_TEST_ENVIRONMENT'] = if_osql_test_environment;if_osql_test_environment.ty_s_sobjname = new abap.types.Character(30, {"qualifiedName":"abap_compname"});
if_osql_test_environment.ty_t_sobjnames = abap.types.TableFactory.construct(new abap.types.Character(30, {"qualifiedName":"abap_compname"}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "if_osql_test_environment=>ty_t_sobjnames");
export {if_osql_test_environment};
//# sourceMappingURL=if_osql_test_environment.intf.mjs.map