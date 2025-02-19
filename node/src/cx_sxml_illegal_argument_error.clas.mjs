const {cx_sxml_error} = await import("./cx_sxml_error.clas.mjs");
const {cx_root} = await import("./cx_root.clas.mjs");
// cx_sxml_illegal_argument_error.clas.abap
class cx_sxml_illegal_argument_error extends cx_sxml_error {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CX_SXML_ILLEGAL_ARGUMENT_ERROR';
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
abap.Classes['CX_SXML_ILLEGAL_ARGUMENT_ERROR'] = cx_sxml_illegal_argument_error;
export {cx_sxml_illegal_argument_error};
//# sourceMappingURL=cx_sxml_illegal_argument_error.clas.mjs.map