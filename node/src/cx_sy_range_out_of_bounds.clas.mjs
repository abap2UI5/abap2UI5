const {cx_sy_data_access_error} = await import("./cx_sy_data_access_error.clas.mjs");
const {cx_root} = await import("./cx_root.clas.mjs");
// cx_sy_range_out_of_bounds.clas.abap
class cx_sy_range_out_of_bounds extends cx_sy_data_access_error {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CX_SY_RANGE_OUT_OF_BOUNDS';
  static IMPLEMENTED_INTERFACES = ["IF_MESSAGE","IF_MESSAGE","IF_MESSAGE","IF_MESSAGE"];
  static ATTRIBUTES = {};
  static METHODS = {"IF_MESSAGE~GET_TEXT": {"visibility": "U", "parameters": {}}};
  constructor() {
    super();
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
  }
  async constructor_(INPUT) {
    if (super.constructor_) { await super.constructor_(INPUT); }
    return this;
  }
  async if_message$get_text() {
    let result = new abap.types.String({qualifiedName: "STRING"});
    result.set(new abap.types.Character(19).set('Range out of bounds'));
    return result;
  }
}
abap.Classes['CX_SY_RANGE_OUT_OF_BOUNDS'] = cx_sy_range_out_of_bounds;
export {cx_sy_range_out_of_bounds};
//# sourceMappingURL=cx_sy_range_out_of_bounds.clas.mjs.map