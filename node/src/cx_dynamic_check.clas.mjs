const {cx_root} = await import("./cx_root.clas.mjs");
// cx_dynamic_check.clas.abap
class cx_dynamic_check extends cx_root {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CX_DYNAMIC_CHECK';
  static IMPLEMENTED_INTERFACES = ["IF_MESSAGE"];
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
abap.Classes['CX_DYNAMIC_CHECK'] = cx_dynamic_check;
export {cx_dynamic_check};
//# sourceMappingURL=cx_dynamic_check.clas.mjs.map