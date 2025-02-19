// if_shm_build_instance.intf.abap
class if_shm_build_instance {
  static INTERNAL_TYPE = 'INTF';
  static ATTRIBUTES = {};
  static METHODS = {"BUILD": {"visibility": "U", "parameters": {"INST_NAME": {"type": () => {return new abap.types.Character(80, {"qualifiedName":"SHM_INST_NAME","ddicName":"SHM_INST_NAME","description":"SHM_INST_NAME"});}, "is_optional": " "}, "INVOCATION_MODE": {"type": () => {return new abap.types.Integer({qualifiedName: "SHM_CONSTR_INVOCATION_MODE"});}, "is_optional": " "}}}};
}
abap.Classes['IF_SHM_BUILD_INSTANCE'] = if_shm_build_instance;
export {if_shm_build_instance};
//# sourceMappingURL=if_shm_build_instance.intf.mjs.map