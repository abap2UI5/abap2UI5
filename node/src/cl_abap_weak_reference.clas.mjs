const {cx_root} = await import("./cx_root.clas.mjs");
// cl_abap_weak_reference.clas.abap
class cl_abap_weak_reference {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CL_ABAP_WEAK_REFERENCE';
  static IMPLEMENTED_INTERFACES = [];
  static ATTRIBUTES = {"MV_REF": {"type": () => {return new abap.types.Hex();}, "visibility": "I", "is_constant": " ", "is_class": " "}};
  static METHODS = {"CONSTRUCTOR": {"visibility": "U", "parameters": {"OREF": {"type": () => {return new abap.types.ABAPObject({qualifiedName: undefined, RTTIName: undefined});}, "is_optional": " "}}},
  "GET": {"visibility": "U", "parameters": {"OREF": {"type": () => {return new abap.types.ABAPObject({qualifiedName: undefined, RTTIName: undefined});}, "is_optional": " "}}}};
  constructor() {
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
    this.mv_ref = new abap.types.Hex();
  }
  async constructor_(INPUT) {
    let oref = INPUT?.oref;
    if (oref === undefined) { oref = new abap.types.ABAPObject({qualifiedName: undefined, RTTIName: undefined}).set(INPUT.oref); }
    abap.statements.assert(abap.compare.initial(oref) === false);
    this.mv_ref = new WeakRef(oref);
    return this;
  }
  async get() {
    let oref = new abap.types.ABAPObject({qualifiedName: undefined, RTTIName: undefined});
    oref.set(this.mv_ref.deref());
    return oref;
  }
}
abap.Classes['CL_ABAP_WEAK_REFERENCE'] = cl_abap_weak_reference;
export {cl_abap_weak_reference};
//# sourceMappingURL=cl_abap_weak_reference.clas.mjs.map