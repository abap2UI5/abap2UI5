// if_system_uuid_rfc4122_static.intf.abap
class if_system_uuid_rfc4122_static {
  static INTERNAL_TYPE = 'INTF';
  static ATTRIBUTES = {};
  static METHODS = {"CREATE_UUID_C36_BY_VERSION": {"visibility": "U", "parameters": {"UUID": {"type": () => {return new abap.types.Character(36, {"qualifiedName":"SYSUUID_C36","ddicName":"SYSUUID_C36","description":"SYSUUID_C36"});}, "is_optional": " "}, "VERSION": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}}}};
}
abap.Classes['IF_SYSTEM_UUID_RFC4122_STATIC'] = if_system_uuid_rfc4122_static;
export {if_system_uuid_rfc4122_static};
//# sourceMappingURL=if_system_uuid_rfc4122_static.intf.mjs.map