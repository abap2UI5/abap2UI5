const {cx_dynamic_check} = await import("./cx_dynamic_check.clas.mjs");
const {cx_root} = await import("./cx_root.clas.mjs");
// cx_oo_clif_not_exists.clas.abap
class cx_oo_clif_not_exists extends cx_dynamic_check {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CX_OO_CLIF_NOT_EXISTS';
  static IMPLEMENTED_INTERFACES = ["IF_MESSAGE","IF_MESSAGE"];
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
abap.Classes['CX_OO_CLIF_NOT_EXISTS'] = cx_oo_clif_not_exists;
export {cx_oo_clif_not_exists};
//# sourceMappingURL=cx_oo_clif_not_exists.clas.mjs.map