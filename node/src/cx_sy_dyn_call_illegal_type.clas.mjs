const {cx_sy_dyn_call_parameter_error} = await import("./cx_sy_dyn_call_parameter_error.clas.mjs");
const {cx_root} = await import("./cx_root.clas.mjs");
// cx_sy_dyn_call_illegal_type.clas.abap
class cx_sy_dyn_call_illegal_type extends cx_sy_dyn_call_parameter_error {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CX_SY_DYN_CALL_ILLEGAL_TYPE';
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
abap.Classes['CX_SY_DYN_CALL_ILLEGAL_TYPE'] = cx_sy_dyn_call_illegal_type;
export {cx_sy_dyn_call_illegal_type};
//# sourceMappingURL=cx_sy_dyn_call_illegal_type.clas.mjs.map