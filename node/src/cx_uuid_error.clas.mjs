const {cx_static_check} = await import("./cx_static_check.clas.mjs");
const {cx_root} = await import("./cx_root.clas.mjs");
// cx_uuid_error.clas.abap
class cx_uuid_error extends cx_static_check {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CX_UUID_ERROR';
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
abap.Classes['CX_UUID_ERROR'] = cx_uuid_error;
export {cx_uuid_error};
//# sourceMappingURL=cx_uuid_error.clas.mjs.map