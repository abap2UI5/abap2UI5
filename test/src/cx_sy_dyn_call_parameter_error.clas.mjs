const {cx_sy_dyn_call_error} = await import("./cx_sy_dyn_call_error.clas.mjs");
const {cx_root} = await import("./cx_root.clas.mjs");
// cx_sy_dyn_call_parameter_error.clas.abap
class cx_sy_dyn_call_parameter_error extends cx_sy_dyn_call_error {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CX_SY_DYN_CALL_PARAMETER_ERROR';
  static IMPLEMENTED_INTERFACES = ["IF_MESSAGE","IF_MESSAGE","IF_MESSAGE","IF_MESSAGE"];
  static ATTRIBUTES = {"PARAMETER": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "visibility": "U", "is_constant": " ", "is_class": " "}};
  static METHODS = {};
  constructor() {
    super();
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
    this.parameter = new abap.types.String({qualifiedName: "STRING"});
  }
  async constructor_(INPUT) {
    if (super.constructor_) { await super.constructor_(INPUT); }
    return this;
  }
}
abap.Classes['CX_SY_DYN_CALL_PARAMETER_ERROR'] = cx_sy_dyn_call_parameter_error;
export {cx_sy_dyn_call_parameter_error};
//# sourceMappingURL=cx_sy_dyn_call_parameter_error.clas.mjs.map