const {cx_xslt_system_error} = await import("./cx_xslt_system_error.clas.mjs");
const {cx_root} = await import("./cx_root.clas.mjs");
// cx_xslt_format_error.clas.abap
class cx_xslt_format_error extends cx_xslt_system_error {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CX_XSLT_FORMAT_ERROR';
  static IMPLEMENTED_INTERFACES = ["IF_MESSAGE","IF_MESSAGE","IF_MESSAGE","IF_MESSAGE","IF_MESSAGE","IF_MESSAGE","IF_MESSAGE","IF_MESSAGE","IF_MESSAGE","IF_MESSAGE","IF_MESSAGE","IF_MESSAGE","IF_MESSAGE","IF_MESSAGE","IF_MESSAGE","IF_MESSAGE"];
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
abap.Classes['CX_XSLT_FORMAT_ERROR'] = cx_xslt_format_error;
export {cx_xslt_format_error};
//# sourceMappingURL=cx_xslt_format_error.clas.mjs.map