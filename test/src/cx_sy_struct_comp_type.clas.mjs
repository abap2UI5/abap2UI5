const {cx_sy_struct_creation} = await import("./cx_sy_struct_creation.clas.mjs");
const {cx_root} = await import("./cx_root.clas.mjs");
// cx_sy_struct_comp_type.clas.abap
class cx_sy_struct_comp_type extends cx_sy_struct_creation {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CX_SY_STRUCT_COMP_TYPE';
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
abap.Classes['CX_SY_STRUCT_COMP_TYPE'] = cx_sy_struct_comp_type;
export {cx_sy_struct_comp_type};
//# sourceMappingURL=cx_sy_struct_comp_type.clas.mjs.map