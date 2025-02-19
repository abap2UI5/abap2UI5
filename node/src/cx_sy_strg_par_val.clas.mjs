const {cx_dynamic_check} = await import("./cx_dynamic_check.clas.mjs");
const {cx_root} = await import("./cx_root.clas.mjs");
// cx_sy_strg_par_val.clas.abap
class cx_sy_strg_par_val extends cx_dynamic_check {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CX_SY_STRG_PAR_VAL';
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
abap.Classes['CX_SY_STRG_PAR_VAL'] = cx_sy_strg_par_val;
export {cx_sy_strg_par_val};
//# sourceMappingURL=cx_sy_strg_par_val.clas.mjs.map