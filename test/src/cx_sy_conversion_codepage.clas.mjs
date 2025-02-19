const {cx_dynamic_check} = await import("./cx_dynamic_check.clas.mjs");
const {cx_root} = await import("./cx_root.clas.mjs");
// cx_sy_conversion_codepage.clas.abap
class cx_sy_conversion_codepage extends cx_dynamic_check {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CX_SY_CONVERSION_CODEPAGE';
  static IMPLEMENTED_INTERFACES = ["IF_MESSAGE","IF_MESSAGE"];
  static ATTRIBUTES = {"SOURCE_EXTRACT": {"type": () => {return new abap.types.XString({qualifiedName: "XSTRING"});}, "visibility": "U", "is_constant": " ", "is_class": " "}};
  static METHODS = {};
  constructor() {
    super();
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
    this.source_extract = new abap.types.XString({qualifiedName: "XSTRING"});
  }
  async constructor_(INPUT) {
    if (super.constructor_) { await super.constructor_(INPUT); }
    return this;
  }
}
abap.Classes['CX_SY_CONVERSION_CODEPAGE'] = cx_sy_conversion_codepage;
export {cx_sy_conversion_codepage};
//# sourceMappingURL=cx_sy_conversion_codepage.clas.mjs.map