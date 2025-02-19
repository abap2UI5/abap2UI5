const {cx_dynamic_check} = await import("./cx_dynamic_check.clas.mjs");
const {cx_root} = await import("./cx_root.clas.mjs");
// cx_sy_codepage_converter_init.clas.abap
class cx_sy_codepage_converter_init extends cx_dynamic_check {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CX_SY_CODEPAGE_CONVERTER_INIT';
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
abap.Classes['CX_SY_CODEPAGE_CONVERTER_INIT'] = cx_sy_codepage_converter_init;
export {cx_sy_codepage_converter_init};
//# sourceMappingURL=cx_sy_codepage_converter_init.clas.mjs.map