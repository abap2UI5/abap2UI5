const {cl_abap_objectdescr} = await import("./cl_abap_objectdescr.clas.mjs");
const {cx_root} = await import("./cx_root.clas.mjs");
// cl_abap_classdescr.clas.abap
class cl_abap_classdescr extends cl_abap_objectdescr {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CL_ABAP_CLASSDESCR';
  static IMPLEMENTED_INTERFACES = [];
  static ATTRIBUTES = {"CLASS_KIND": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "visibility": "U", "is_constant": " ", "is_class": " "},
  "CREATE_VISIBILITY": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "visibility": "U", "is_constant": " ", "is_class": " "}};
  static METHODS = {"GET_CLASS_NAME": {"visibility": "U", "parameters": {"P_NAME": {"type": () => {return new abap.types.Character(200, {"qualifiedName":"abap_abstypename"});}, "is_optional": " "}, "P_OBJECT": {"type": () => {return new abap.types.ABAPObject({qualifiedName: undefined, RTTIName: undefined});}, "is_optional": " "}}},
  "GET_SUPER_CLASS_TYPE": {"visibility": "U", "parameters": {"P_DESCR_REF": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "CL_ABAP_CLASSDESCR", RTTIName: "\\CLASS=CL_ABAP_CLASSDESCR"});}, "is_optional": " "}}},
  "CONSTRUCTOR": {"visibility": "U", "parameters": {"P_OBJECT": {"type": () => {return new abap.types.Character(4);}, "is_optional": " "}}}};
  constructor() {
    super();
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
    this.class_kind = new abap.types.String({qualifiedName: "STRING"});
    this.create_visibility = new abap.types.String({qualifiedName: "STRING"});
  }
  async constructor_(INPUT) {
    let p_object = INPUT?.p_object || new abap.types.Character(4);
    await super.constructor_({p_object: p_object});
    return this;
  }
  async get_class_name(INPUT) {
    return cl_abap_classdescr.get_class_name(INPUT);
  }
  static async get_class_name(INPUT) {
    let p_name = new abap.types.Character(200, {"qualifiedName":"abap_abstypename"});
    let p_object = INPUT?.p_object;
    if (p_object === undefined) { p_object = new abap.types.ABAPObject({qualifiedName: undefined, RTTIName: undefined}).set(INPUT.p_object); }
    let lv_name = new abap.types.String({qualifiedName: "STRING"});
    lv_name.set(p_object.get().constructor.INTERNAL_NAME);
    p_name.set((await abap.Classes['KERNEL_INTERNAL_NAME'].internal_to_rtti({iv_internal: lv_name})));
    return p_name;
  }
  async get_super_class_type() {
    let p_descr_ref = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_CLASSDESCR", RTTIName: "\\CLASS=CL_ABAP_CLASSDESCR"});
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return p_descr_ref;
  }
}
abap.Classes['CL_ABAP_CLASSDESCR'] = cl_abap_classdescr;
export {cl_abap_classdescr};
//# sourceMappingURL=cl_abap_classdescr.clas.mjs.map