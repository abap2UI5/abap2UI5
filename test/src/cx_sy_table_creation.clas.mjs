const {cx_sy_type_creation} = await import("./cx_sy_type_creation.clas.mjs");
const {cx_root} = await import("./cx_root.clas.mjs");
// cx_sy_table_creation.clas.abap
class cx_sy_table_creation extends cx_sy_type_creation {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CX_SY_TABLE_CREATION';
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
abap.Classes['CX_SY_TABLE_CREATION'] = cx_sy_table_creation;
export {cx_sy_table_creation};
//# sourceMappingURL=cx_sy_table_creation.clas.mjs.map