const {cx_root} = await import("./cx_root.clas.mjs");
// kernel_internal_name.clas.abap
class kernel_internal_name {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'KERNEL_INTERNAL_NAME';
  static IMPLEMENTED_INTERFACES = [];
  static ATTRIBUTES = {};
  static METHODS = {"INTERNAL_TO_RTTI": {"visibility": "U", "parameters": {"RV_RTTI": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "IV_INTERNAL": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}},
  "RTTI_TO_INTERNAL": {"visibility": "U", "parameters": {"RV_INTERNAL": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "IV_RTTI": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}}};
  constructor() {
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
  }
  async constructor_(INPUT) {
    if (super.constructor_) { await super.constructor_(INPUT); }
    return this;
  }
  async internal_to_rtti(INPUT) {
    return kernel_internal_name.internal_to_rtti(INPUT);
  }
  static async internal_to_rtti(INPUT) {
    let rv_rtti = new abap.types.String({qualifiedName: "STRING"});
    let iv_internal = INPUT?.iv_internal;
    if (iv_internal?.getQualifiedName === undefined || iv_internal.getQualifiedName() !== "STRING") { iv_internal = undefined; }
    if (iv_internal === undefined) { iv_internal = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.iv_internal); }
    rv_rtti.set(iv_internal);
    if (abap.compare.cp(rv_rtti, new abap.types.Character(7).set('*CLAS-*'))) {
      abap.statements.replace({target: rv_rtti, all: false, with: new abap.types.Character(12).set('\\CLASS#POOL='), of: new abap.types.Character(5).set('CLAS-')});
      abap.statements.replace({target: rv_rtti, all: false, with: new abap.types.Character(7).set('\\CLASS='), of: new abap.types.Character(1).set('-')});
      abap.statements.replace({target: rv_rtti, all: false, with: new abap.types.Character(1).set('-'), of: new abap.types.Character(1).set('#')});
    } else {
      rv_rtti.set(abap.operators.concat(new abap.types.Character(7).set('\\CLASS='),rv_rtti));
    }
    return rv_rtti;
  }
  async rtti_to_internal(INPUT) {
    return kernel_internal_name.rtti_to_internal(INPUT);
  }
  static async rtti_to_internal(INPUT) {
    let rv_internal = new abap.types.String({qualifiedName: "STRING"});
    let iv_rtti = INPUT?.iv_rtti;
    if (iv_rtti?.getQualifiedName === undefined || iv_rtti.getQualifiedName() !== "STRING") { iv_rtti = undefined; }
    if (iv_rtti === undefined) { iv_rtti = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.iv_rtti); }
    rv_internal.set(iv_rtti);
    if (abap.compare.cp(rv_internal, new abap.types.Character(8).set('\\CLASS=*'))) {
      abap.statements.replace({target: rv_internal, all: false, with: new abap.types.Character(1).set(''), of: new abap.types.Character(7).set('\\CLASS=')});
    } else if (abap.compare.cp(rv_internal, new abap.types.Character(13).set('\\CLASS-POOL=*'))) {
      abap.statements.replace({target: rv_internal, all: false, with: new abap.types.Character(5).set('CLAS-'), of: new abap.types.Character(12).set('\\CLASS-POOL=')});
      abap.statements.replace({target: rv_internal, all: false, with: new abap.types.Character(1).set('-'), of: new abap.types.Character(7).set('\\CLASS=')});
      abap.statements.replace({target: rv_internal, all: false, with: new abap.types.Character(1).set('-'), of: new abap.types.Character(11).set('\\INTERFACE=')});
    }
    return rv_internal;
  }
}
abap.Classes['KERNEL_INTERNAL_NAME'] = kernel_internal_name;
export {kernel_internal_name};
//# sourceMappingURL=kernel_internal_name.clas.mjs.map