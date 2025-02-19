const {cl_abap_datadescr} = await import("./cl_abap_datadescr.clas.mjs");
const {cx_root} = await import("./cx_root.clas.mjs");
// cl_abap_refdescr.clas.abap
class cl_abap_refdescr extends cl_abap_datadescr {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CL_ABAP_REFDESCR';
  static IMPLEMENTED_INTERFACES = [];
  static ATTRIBUTES = {"REFERENCED": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "CL_ABAP_TYPEDESCR", RTTIName: "\\CLASS=CL_ABAP_TYPEDESCR"});}, "visibility": "I", "is_constant": " ", "is_class": " "}};
  static METHODS = {"GET_REFERENCED_TYPE": {"visibility": "U", "parameters": {"TYPE": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "CL_ABAP_TYPEDESCR", RTTIName: "\\CLASS=CL_ABAP_TYPEDESCR"});}, "is_optional": " "}}},
  "GET_REF_TO_DATA": {"visibility": "U", "parameters": {"P_RESULT": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "CL_ABAP_REFDESCR", RTTIName: "\\CLASS=CL_ABAP_REFDESCR"});}, "is_optional": " "}}},
  "GET_REF_TO_OBJECT": {"visibility": "U", "parameters": {"P_RESULT": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "CL_ABAP_REFDESCR", RTTIName: "\\CLASS=CL_ABAP_REFDESCR"});}, "is_optional": " "}}},
  "CREATE": {"visibility": "U", "parameters": {"P_RESULT": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "CL_ABAP_REFDESCR", RTTIName: "\\CLASS=CL_ABAP_REFDESCR"});}, "is_optional": " "}, "P_REFERENCED_TYPE": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "CL_ABAP_TYPEDESCR", RTTIName: "\\CLASS=CL_ABAP_TYPEDESCR"});}, "is_optional": " "}}}};
  constructor() {
    super();
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
    this.referenced = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_TYPEDESCR", RTTIName: "\\CLASS=CL_ABAP_TYPEDESCR"});
  }
  async constructor_(INPUT) {
    if (super.constructor_) { await super.constructor_(INPUT); }
    return this;
  }
  async get_ref_to_object() {
    return cl_abap_refdescr.get_ref_to_object();
  }
  static async get_ref_to_object() {
    let p_result = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_REFDESCR", RTTIName: "\\CLASS=CL_ABAP_REFDESCR"});
    return p_result;
  }
  async create(INPUT) {
    return cl_abap_refdescr.create(INPUT);
  }
  static async create(INPUT) {
    let p_result = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_REFDESCR", RTTIName: "\\CLASS=CL_ABAP_REFDESCR"});
    let p_referenced_type = INPUT?.p_referenced_type;
    if (p_referenced_type?.getQualifiedName === undefined || p_referenced_type.getQualifiedName() !== "CL_ABAP_TYPEDESCR") { p_referenced_type = undefined; }
    if (p_referenced_type === undefined) { p_referenced_type = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_TYPEDESCR", RTTIName: "\\CLASS=CL_ABAP_TYPEDESCR"}).set(INPUT.p_referenced_type); }
    return p_result;
  }
  async get_referenced_type() {
    let type = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_TYPEDESCR", RTTIName: "\\CLASS=CL_ABAP_TYPEDESCR"});
    type.set(this.referenced);
    return type;
  }
  async get_ref_to_data() {
    return cl_abap_refdescr.get_ref_to_data();
  }
  static async get_ref_to_data() {
    let p_result = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_REFDESCR", RTTIName: "\\CLASS=CL_ABAP_REFDESCR"});
    let foo = new abap.types.DataReference(new abap.types.Character(4));
    await abap.statements.cast(p_result, (await abap.Classes['CL_ABAP_TYPEDESCR'].describe_by_data({p_data: foo})));
    return p_result;
  }
}
abap.Classes['CL_ABAP_REFDESCR'] = cl_abap_refdescr;
export {cl_abap_refdescr};
//# sourceMappingURL=cl_abap_refdescr.clas.mjs.map