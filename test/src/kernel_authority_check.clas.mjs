const {cx_root} = await import("./cx_root.clas.mjs");
// kernel_authority_check.clas.abap
class kernel_authority_check {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'KERNEL_AUTHORITY_CHECK';
  static IMPLEMENTED_INTERFACES = [];
  static ATTRIBUTES = {};
  static METHODS = {"CALL": {"visibility": "U", "parameters": {}}};
  constructor() {
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
  }
  async constructor_(INPUT) {
    if (super.constructor_) { await super.constructor_(INPUT); }
    return this;
  }
  async call() {
    return kernel_authority_check.call();
  }
  static async call() {
    abap.builtin.sy.get().subrc.set(abap.IntegerFactory.get(0));
  }
}
abap.Classes['KERNEL_AUTHORITY_CHECK'] = kernel_authority_check;
export {kernel_authority_check};
//# sourceMappingURL=kernel_authority_check.clas.mjs.map