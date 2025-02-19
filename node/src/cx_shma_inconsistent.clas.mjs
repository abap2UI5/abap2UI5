const {cx_shma_dynamic} = await import("./cx_shma_dynamic.clas.mjs");
const {cx_root} = await import("./cx_root.clas.mjs");
// cx_shma_inconsistent.clas.abap
class cx_shma_inconsistent extends cx_shma_dynamic {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CX_SHMA_INCONSISTENT';
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
abap.Classes['CX_SHMA_INCONSISTENT'] = cx_shma_inconsistent;
export {cx_shma_inconsistent};
//# sourceMappingURL=cx_shma_inconsistent.clas.mjs.map