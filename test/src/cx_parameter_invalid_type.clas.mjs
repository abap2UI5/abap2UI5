const {cx_parameter_invalid} = await import("./cx_parameter_invalid.clas.mjs");
const {cx_root} = await import("./cx_root.clas.mjs");
// cx_parameter_invalid_type.clas.abap
class cx_parameter_invalid_type extends cx_parameter_invalid {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CX_PARAMETER_INVALID_TYPE';
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
abap.Classes['CX_PARAMETER_INVALID_TYPE'] = cx_parameter_invalid_type;
export {cx_parameter_invalid_type};
//# sourceMappingURL=cx_parameter_invalid_type.clas.mjs.map