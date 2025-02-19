// if_system_uuid_static.intf.abap
class if_system_uuid_static {
  static INTERNAL_TYPE = 'INTF';
  static ATTRIBUTES = {};
  static METHODS = {"CREATE_UUID_X16": {"visibility": "U", "parameters": {"UUID": {"type": () => {return new abap.types.Hex({length: 16});}, "is_optional": " "}}},
  "CREATE_UUID_C32": {"visibility": "U", "parameters": {"UUID": {"type": () => {return new abap.types.Character(32, {"qualifiedName":"SYSUUID_C32","ddicName":"SYSUUID_C32","description":"UUID"});}, "is_optional": " "}}},
  "CREATE_UUID_C22": {"visibility": "U", "parameters": {"UUID": {"type": () => {return new abap.types.Character(22, {"qualifiedName":"SYSUUID_C22","ddicName":"SYSUUID_C22","description":"UUID"});}, "is_optional": " "}}}};
}
abap.Classes['IF_SYSTEM_UUID_STATIC'] = if_system_uuid_static;
export {if_system_uuid_static};
//# sourceMappingURL=if_system_uuid_static.intf.mjs.map