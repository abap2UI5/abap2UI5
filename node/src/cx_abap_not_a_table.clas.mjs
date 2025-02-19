const {cx_static_check} = await import("./cx_static_check.clas.mjs");
const {cx_root} = await import("./cx_root.clas.mjs");
// cx_abap_not_a_table.clas.abap
class cx_abap_not_a_table extends cx_static_check {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CX_ABAP_NOT_A_TABLE';
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
abap.Classes['CX_ABAP_NOT_A_TABLE'] = cx_abap_not_a_table;
export {cx_abap_not_a_table};
//# sourceMappingURL=cx_abap_not_a_table.clas.mjs.map