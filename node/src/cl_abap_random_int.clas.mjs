const {cx_root} = await import("./cx_root.clas.mjs");
// cl_abap_random_int.clas.abap
class cl_abap_random_int {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CL_ABAP_RANDOM_INT';
  static IMPLEMENTED_INTERFACES = [];
  static ATTRIBUTES = {"MV_MIN": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "I", "is_constant": " ", "is_class": " "},
  "MV_MAX": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "I", "is_constant": " ", "is_class": " "}};
  static METHODS = {"CREATE": {"visibility": "U", "parameters": {"PRNG": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "CL_ABAP_RANDOM_INT", RTTIName: "\\CLASS=CL_ABAP_RANDOM_INT"});}, "is_optional": " "}, "SEED": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}, "MIN": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}, "MAX": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}}},
  "GET_NEXT": {"visibility": "U", "parameters": {"VALUE": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}}}};
  constructor() {
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
    this.mv_min = new abap.types.Integer({qualifiedName: "I"});
    this.mv_max = new abap.types.Integer({qualifiedName: "I"});
  }
  async constructor_(INPUT) {
    if (super.constructor_) { await super.constructor_(INPUT); }
    return this;
  }
  async create(INPUT) {
    return cl_abap_random_int.create(INPUT);
  }
  static async create(INPUT) {
    let prng = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_RANDOM_INT", RTTIName: "\\CLASS=CL_ABAP_RANDOM_INT"});
    let seed = new abap.types.Integer({qualifiedName: "I"});
    if (INPUT && INPUT.seed) {seed.set(INPUT.seed);}
    let min = new abap.types.Integer({qualifiedName: "I"});
    if (INPUT && INPUT.min) {min.set(INPUT.min);}
    if (INPUT === undefined || INPUT.min === undefined) {min = new abap.types.Integer().set(-2147483648);}
    let max = new abap.types.Integer({qualifiedName: "I"});
    if (INPUT && INPUT.max) {max.set(INPUT.max);}
    if (INPUT === undefined || INPUT.max === undefined) {max = new abap.types.Integer().set(2147483647);}
    prng.set(await (new abap.Classes['CL_ABAP_RANDOM_INT']()).constructor_());
    prng.get().mv_min.set(min);
    prng.get().mv_max.set(max);
    return prng;
  }
  async get_next() {
    let value = new abap.types.Integer({qualifiedName: "I"});
    value.set((await (await abap.Classes['CL_ABAP_RANDOM'].create()).get().intinrange({low: this.mv_min, high: this.mv_max})));
    return value;
  }
}
abap.Classes['CL_ABAP_RANDOM_INT'] = cl_abap_random_int;
export {cl_abap_random_int};
//# sourceMappingURL=cl_abap_random_int.clas.mjs.map