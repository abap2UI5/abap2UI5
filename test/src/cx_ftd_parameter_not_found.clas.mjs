const {cx_no_check} = await import("./cx_no_check.clas.mjs");
const {cx_root} = await import("./cx_root.clas.mjs");
// cx_ftd_parameter_not_found.clas.abap
class cx_ftd_parameter_not_found extends cx_no_check {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CX_FTD_PARAMETER_NOT_FOUND';
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
abap.Classes['CX_FTD_PARAMETER_NOT_FOUND'] = cx_ftd_parameter_not_found;
export {cx_ftd_parameter_not_found};
//# sourceMappingURL=cx_ftd_parameter_not_found.clas.mjs.map