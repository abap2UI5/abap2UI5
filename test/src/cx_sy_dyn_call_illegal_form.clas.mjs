const {cx_sy_dyn_call_error} = await import("./cx_sy_dyn_call_error.clas.mjs");
const {cx_root} = await import("./cx_root.clas.mjs");
// cx_sy_dyn_call_illegal_form.clas.abap
class cx_sy_dyn_call_illegal_form extends cx_sy_dyn_call_error {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CX_SY_DYN_CALL_ILLEGAL_FORM';
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
abap.Classes['CX_SY_DYN_CALL_ILLEGAL_FORM'] = cx_sy_dyn_call_illegal_form;
export {cx_sy_dyn_call_illegal_form};
//# sourceMappingURL=cx_sy_dyn_call_illegal_form.clas.mjs.map