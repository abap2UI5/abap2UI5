const {cx_shm_attach_error} = await import("./cx_shm_attach_error.clas.mjs");
const {cx_root} = await import("./cx_root.clas.mjs");
// cx_shm_no_active_version.clas.abap
class cx_shm_no_active_version extends cx_shm_attach_error {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CX_SHM_NO_ACTIVE_VERSION';
  static IMPLEMENTED_INTERFACES = ["IF_MESSAGE","IF_MESSAGE","IF_MESSAGE","IF_MESSAGE","IF_MESSAGE","IF_MESSAGE","IF_MESSAGE","IF_MESSAGE"];
  static ATTRIBUTES = {};
  static METHODS = {};
  constructor() {
    super();
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
  }
  async constructor_(INPUT) {
    if (super.constructor_) { await super.constructor_(INPUT); }
    return this;
  }
}
abap.Classes['CX_SHM_NO_ACTIVE_VERSION'] = cx_shm_no_active_version;
export {cx_shm_no_active_version};
//# sourceMappingURL=cx_shm_no_active_version.clas.mjs.map