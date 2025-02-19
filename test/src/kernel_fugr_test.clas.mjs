const {cx_root} = await import("./cx_root.clas.mjs");
// kernel_fugr_test.clas.abap
class kernel_fugr_test {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'KERNEL_FUGR_TEST';
  static IMPLEMENTED_INTERFACES = [];
  static ATTRIBUTES = {};
  static METHODS = {};
  constructor() {
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
  }
  async constructor_(INPUT) {
    if (super.constructor_) { await super.constructor_(INPUT); }
    return this;
  }
}
abap.Classes['KERNEL_FUGR_TEST'] = kernel_fugr_test;
export {kernel_fugr_test};
//# sourceMappingURL=kernel_fugr_test.clas.mjs.map