const {cx_oa2c} = await import("./cx_oa2c.clas.mjs");
const {cx_root} = await import("./cx_root.clas.mjs");
// cx_oa2c_config_not_found.clas.abap
class cx_oa2c_config_not_found extends cx_oa2c {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CX_OA2C_CONFIG_NOT_FOUND';
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
abap.Classes['CX_OA2C_CONFIG_NOT_FOUND'] = cx_oa2c_config_not_found;
export {cx_oa2c_config_not_found};
//# sourceMappingURL=cx_oa2c_config_not_found.clas.mjs.map