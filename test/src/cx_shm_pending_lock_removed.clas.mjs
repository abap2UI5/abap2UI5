const {cx_shm_attach_error} = await import("./cx_shm_attach_error.clas.mjs");
const {cx_root} = await import("./cx_root.clas.mjs");
// cx_shm_pending_lock_removed.clas.abap
class cx_shm_pending_lock_removed extends cx_shm_attach_error {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CX_SHM_PENDING_LOCK_REMOVED';
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
abap.Classes['CX_SHM_PENDING_LOCK_REMOVED'] = cx_shm_pending_lock_removed;
export {cx_shm_pending_lock_removed};
//# sourceMappingURL=cx_shm_pending_lock_removed.clas.mjs.map