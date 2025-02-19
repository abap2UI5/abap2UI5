const {cx_sy_conversion_error} = await import("./cx_sy_conversion_error.clas.mjs");
const {cx_root} = await import("./cx_root.clas.mjs");
// cx_sy_conversion_data_loss.clas.abap
class cx_sy_conversion_data_loss extends cx_sy_conversion_error {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CX_SY_CONVERSION_DATA_LOSS';
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
abap.Classes['CX_SY_CONVERSION_DATA_LOSS'] = cx_sy_conversion_data_loss;
export {cx_sy_conversion_data_loss};
//# sourceMappingURL=cx_sy_conversion_data_loss.clas.mjs.map