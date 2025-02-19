const {cx_xslt_exception} = await import("./cx_xslt_exception.clas.mjs");
const {cx_root} = await import("./cx_root.clas.mjs");
// cx_xslt_system_error.clas.abap
class cx_xslt_system_error extends cx_xslt_exception {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CX_XSLT_SYSTEM_ERROR';
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
abap.Classes['CX_XSLT_SYSTEM_ERROR'] = cx_xslt_system_error;
export {cx_xslt_system_error};
//# sourceMappingURL=cx_xslt_system_error.clas.mjs.map