const {cx_transformation_error} = await import("./cx_transformation_error.clas.mjs");
const {cx_root} = await import("./cx_root.clas.mjs");
// cx_st_error.clas.abap
class cx_st_error extends cx_transformation_error {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CX_ST_ERROR';
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
abap.Classes['CX_ST_ERROR'] = cx_st_error;
export {cx_st_error};
//# sourceMappingURL=cx_st_error.clas.mjs.map