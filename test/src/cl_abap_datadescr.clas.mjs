const {cl_abap_typedescr} = await import("./cl_abap_typedescr.clas.mjs");
const {cx_root} = await import("./cx_root.clas.mjs");
// cl_abap_datadescr.clas.abap
class cl_abap_datadescr extends cl_abap_typedescr {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CL_ABAP_DATADESCR';
  static IMPLEMENTED_INTERFACES = [];
  static ATTRIBUTES = {};
  static METHODS = {"GET_DATA_TYPE_KIND": {"visibility": "U", "parameters": {"P_TYPE_KIND": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"abap_typekind"});}, "is_optional": " "}, "P_DATA": {"type": () => {return new abap.types.Character(4);}, "is_optional": " "}}},
  "APPLIES_TO_DATA": {"visibility": "U", "parameters": {"P_FLAG": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});}, "is_optional": " "}, "P_DATA": {"type": () => {return new abap.types.Character(4);}, "is_optional": " "}}}};
  constructor() {
    super();
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
  }
  async constructor_(INPUT) {
    if (super.constructor_) { await super.constructor_(INPUT); }
    return this;
  }
  async get_data_type_kind(INPUT) {
    return cl_abap_datadescr.get_data_type_kind(INPUT);
  }
  static async get_data_type_kind(INPUT) {
    let p_type_kind = new abap.types.Character(1, {"qualifiedName":"abap_typekind"});
    let p_data = INPUT?.p_data;
    let descr = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_TYPEDESCR", RTTIName: "\\CLASS=CL_ABAP_TYPEDESCR"});
    descr.set((await abap.Classes['CL_ABAP_TYPEDESCR'].describe_by_data({p_data: p_data})));
    p_type_kind.set(descr.get().type_kind);
    return p_type_kind;
  }
  async applies_to_data(INPUT) {
    let p_flag = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    let p_data = INPUT?.p_data;
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return p_flag;
  }
}
abap.Classes['CL_ABAP_DATADESCR'] = cl_abap_datadescr;
export {cl_abap_datadescr};
//# sourceMappingURL=cl_abap_datadescr.clas.mjs.map