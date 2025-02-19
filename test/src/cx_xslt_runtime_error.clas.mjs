const {cx_transformation_error} = await import("./cx_transformation_error.clas.mjs");
const {cx_root} = await import("./cx_root.clas.mjs");
// cx_xslt_runtime_error.clas.abap
class cx_xslt_runtime_error extends cx_transformation_error {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CX_XSLT_RUNTIME_ERROR';
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
abap.Classes['CX_XSLT_RUNTIME_ERROR'] = cx_xslt_runtime_error;
export {cx_xslt_runtime_error};
//# sourceMappingURL=cx_xslt_runtime_error.clas.mjs.map