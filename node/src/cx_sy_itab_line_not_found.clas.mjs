const {cx_dynamic_check} = await import("./cx_dynamic_check.clas.mjs");
const {cx_root} = await import("./cx_root.clas.mjs");
// cx_sy_itab_line_not_found.clas.abap
class cx_sy_itab_line_not_found extends cx_dynamic_check {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CX_SY_ITAB_LINE_NOT_FOUND';
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
abap.Classes['CX_SY_ITAB_LINE_NOT_FOUND'] = cx_sy_itab_line_not_found;
export {cx_sy_itab_line_not_found};
//# sourceMappingURL=cx_sy_itab_line_not_found.clas.mjs.map