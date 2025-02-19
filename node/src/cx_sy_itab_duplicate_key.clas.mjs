const {cx_sy_itab_error} = await import("./cx_sy_itab_error.clas.mjs");
const {cx_root} = await import("./cx_root.clas.mjs");
// cx_sy_itab_duplicate_key.clas.abap
class cx_sy_itab_duplicate_key extends cx_sy_itab_error {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CX_SY_ITAB_DUPLICATE_KEY';
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
abap.Classes['CX_SY_ITAB_DUPLICATE_KEY'] = cx_sy_itab_duplicate_key;
export {cx_sy_itab_duplicate_key};
//# sourceMappingURL=cx_sy_itab_duplicate_key.clas.mjs.map