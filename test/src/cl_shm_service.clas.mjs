const {cx_root} = await import("./cx_root.clas.mjs");
// cl_shm_service.clas.abap
class cl_shm_service {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CL_SHM_SERVICE';
  static IMPLEMENTED_INTERFACES = [];
  static ATTRIBUTES = {};
  static METHODS = {"INITIALIZE": {"visibility": "U", "parameters": {"AREA_NAME": {"type": () => {return new abap.types.Character(30, {"qualifiedName":"SHM_AREA_NAME","ddicName":"SHM_AREA_NAME","description":"SHM_AREA_NAME"});}, "is_optional": " "}, "CLIENT": {"type": () => {return new abap.types.Character(3, {"qualifiedName":"SHMA_CLIENT","ddicName":"SHMA_CLIENT","description":"SHM_CLIENT"});}, "is_optional": " "}, "ATTRIBUTES": {"type": () => {return new abap.types.Structure({"area_name": new abap.types.Character(30, {"qualifiedName":"SHM_AREA_NAME","ddicName":"SHM_AREA_NAME","description":"SHM_AREA_NAME"}), "properties": new abap.types.Structure({"auto_build": new abap.types.Character(1, {}), "has_versions": new abap.types.Character(1, {})}, "SHM_PROPERTIES", "SHM_PROPERTIES", {}, {}), "auto_build": new abap.types.Character(1, {}), "has_versions": new abap.types.Character(1, {})}, "SHMA_ATTRIBUTES", "SHMA_ATTRIBUTES", {}, {});}, "is_optional": " "}}},
  "GET_AUTO_BUILD_CLASS_NAME": {"visibility": "U", "parameters": {"AUTO_BUILD_CLASS_NAME": {"type": () => {return new abap.types.Character(30, {"qualifiedName":"SHM_AUTO_BUILD_CLASS_NAME","ddicName":"SHM_AUTO_BUILD_CLASS_NAME","description":"SHM_AUTO_BUILD_CLASS_NAME"});}, "is_optional": " "}, "AREA_NAME": {"type": () => {return new abap.types.Character(30, {"qualifiedName":"SHM_AREA_NAME","ddicName":"SHM_AREA_NAME","description":"SHM_AREA_NAME"});}, "is_optional": " "}}},
  "TRACE_GET_SERVICE": {"visibility": "U", "parameters": {"TRACE_SERVICE": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_SHM_TRACE", RTTIName: "\\INTERFACE=IF_SHM_TRACE"});}, "is_optional": " "}, "AREA_NAME": {"type": () => {return new abap.types.Character(30, {"qualifiedName":"SHM_AREA_NAME","ddicName":"SHM_AREA_NAME","description":"SHM_AREA_NAME"});}, "is_optional": " "}}},
  "TRACE_IS_VARIANT_ACTIVE": {"visibility": "U", "parameters": {"IS_ACTIVE": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});}, "is_optional": " "}, "SERVICE_NAME": {"type": () => {return new abap.types.Character(32, {"qualifiedName":"SHMM_TRC_VARIANT_NAME","ddicName":"SHMM_TRC_VARIANT_NAME","description":"SHMM_TRC_VARIANT_NAME"});}, "is_optional": " "}}}};
  constructor() {
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
  }
  async constructor_(INPUT) {
    if (super.constructor_) { await super.constructor_(INPUT); }
    return this;
  }
  async initialize(INPUT) {
    return cl_shm_service.initialize(INPUT);
  }
  static async initialize(INPUT) {
    let area_name = INPUT?.area_name;
    if (area_name?.getQualifiedName === undefined || area_name.getQualifiedName() !== "SHM_AREA_NAME") { area_name = undefined; }
    if (area_name === undefined) { area_name = new abap.types.Character(30, {"qualifiedName":"SHM_AREA_NAME","ddicName":"SHM_AREA_NAME","description":"SHM_AREA_NAME"}).set(INPUT.area_name); }
    let client = new abap.types.Character(3, {"qualifiedName":"SHMA_CLIENT","ddicName":"SHMA_CLIENT","description":"SHM_CLIENT"});
    if (INPUT && INPUT.client) {client.set(INPUT.client);}
    let attributes = INPUT?.attributes || new abap.types.Structure({"area_name": new abap.types.Character(30, {"qualifiedName":"SHM_AREA_NAME","ddicName":"SHM_AREA_NAME","description":"SHM_AREA_NAME"}), "properties": new abap.types.Structure({"auto_build": new abap.types.Character(1, {}), "has_versions": new abap.types.Character(1, {})}, "SHM_PROPERTIES", "SHM_PROPERTIES", {}, {}), "auto_build": new abap.types.Character(1, {}), "has_versions": new abap.types.Character(1, {})}, "SHMA_ATTRIBUTES", "SHMA_ATTRIBUTES", {}, {});
    return;
  }
  async get_auto_build_class_name(INPUT) {
    return cl_shm_service.get_auto_build_class_name(INPUT);
  }
  static async get_auto_build_class_name(INPUT) {
    let auto_build_class_name = new abap.types.Character(30, {"qualifiedName":"SHM_AUTO_BUILD_CLASS_NAME","ddicName":"SHM_AUTO_BUILD_CLASS_NAME","description":"SHM_AUTO_BUILD_CLASS_NAME"});
    let area_name = INPUT?.area_name;
    if (area_name?.getQualifiedName === undefined || area_name.getQualifiedName() !== "SHM_AREA_NAME") { area_name = undefined; }
    if (area_name === undefined) { area_name = new abap.types.Character(30, {"qualifiedName":"SHM_AREA_NAME","ddicName":"SHM_AREA_NAME","description":"SHM_AREA_NAME"}).set(INPUT.area_name); }
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return auto_build_class_name;
  }
  async trace_get_service(INPUT) {
    return cl_shm_service.trace_get_service(INPUT);
  }
  static async trace_get_service(INPUT) {
    let trace_service = new abap.types.ABAPObject({qualifiedName: "IF_SHM_TRACE", RTTIName: "\\INTERFACE=IF_SHM_TRACE"});
    let area_name = new abap.types.Character(30, {"qualifiedName":"SHM_AREA_NAME","ddicName":"SHM_AREA_NAME","description":"SHM_AREA_NAME"});
    if (INPUT && INPUT.area_name) {area_name.set(INPUT.area_name);}
    return trace_service;
    return trace_service;
  }
  async trace_is_variant_active(INPUT) {
    return cl_shm_service.trace_is_variant_active(INPUT);
  }
  static async trace_is_variant_active(INPUT) {
    let is_active = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    let service_name = INPUT?.service_name;
    if (service_name?.getQualifiedName === undefined || service_name.getQualifiedName() !== "SHMM_TRC_VARIANT_NAME") { service_name = undefined; }
    if (service_name === undefined) { service_name = new abap.types.Character(32, {"qualifiedName":"SHMM_TRC_VARIANT_NAME","ddicName":"SHMM_TRC_VARIANT_NAME","description":"SHMM_TRC_VARIANT_NAME"}).set(INPUT.service_name); }
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return is_active;
  }
}
abap.Classes['CL_SHM_SERVICE'] = cl_shm_service;
export {cl_shm_service};
//# sourceMappingURL=cl_shm_service.clas.mjs.map