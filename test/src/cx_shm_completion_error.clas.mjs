const {cx_shm_detach_error} = await import("./cx_shm_detach_error.clas.mjs");
const {cx_root} = await import("./cx_root.clas.mjs");
// cx_shm_completion_error.clas.abap
class cx_shm_completion_error extends cx_shm_detach_error {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CX_SHM_COMPLETION_ERROR';
  static IMPLEMENTED_INTERFACES = ["IF_MESSAGE","IF_MESSAGE","IF_MESSAGE","IF_MESSAGE"];
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
abap.Classes['CX_SHM_COMPLETION_ERROR'] = cx_shm_completion_error;
export {cx_shm_completion_error};
//# sourceMappingURL=cx_shm_completion_error.clas.mjs.map