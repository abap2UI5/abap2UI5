const {cx_root} = await import("./cx_root.clas.mjs");
// cl_abap_random.clas.abap
class cl_abap_random {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CL_ABAP_RANDOM';
  static IMPLEMENTED_INTERFACES = [];
  static ATTRIBUTES = {};
  static METHODS = {"CREATE": {"visibility": "U", "parameters": {"RO_RANDOM": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "CL_ABAP_RANDOM", RTTIName: "\\CLASS=CL_ABAP_RANDOM"});}, "is_optional": " "}, "SEED": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}}},
  "INT": {"visibility": "U", "parameters": {"RV_INTEGER": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}}},
  "INTINRANGE": {"visibility": "U", "parameters": {"RV_INTEGER": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}, "LOW": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}, "HIGH": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}}},
  "SEED": {"visibility": "U", "parameters": {"RV_SEED": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}}}};
  constructor() {
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
  }
  async constructor_(INPUT) {
    if (super.constructor_) { await super.constructor_(INPUT); }
    return this;
  }
  async create(INPUT) {
    return cl_abap_random.create(INPUT);
  }
  static async create(INPUT) {
    let ro_random = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_RANDOM", RTTIName: "\\CLASS=CL_ABAP_RANDOM"});
    let seed = new abap.types.Integer({qualifiedName: "I"});
    if (INPUT && INPUT.seed) {seed.set(INPUT.seed);}
    ro_random.set(await (new abap.Classes['CL_ABAP_RANDOM']()).constructor_());
    return ro_random;
  }
  async int() {
    let rv_integer = new abap.types.Integer({qualifiedName: "I"});
    rv_integer.set(Math.floor(Math.random() * 2147483647));
    return rv_integer;
  }
  async seed() {
    return cl_abap_random.seed();
  }
  static async seed() {
    let rv_seed = new abap.types.Integer({qualifiedName: "I"});
    rv_seed.set(Math.floor(Math.random() * 2147483647));
    return rv_seed;
  }
  async intinrange(INPUT) {
    let rv_integer = new abap.types.Integer({qualifiedName: "I"});
    let low = INPUT?.low;
    if (low?.getQualifiedName === undefined || low.getQualifiedName() !== "I") { low = undefined; }
    if (low === undefined) { low = new abap.types.Integer({qualifiedName: "I"}).set(INPUT.low); }
    let high = INPUT?.high;
    if (high?.getQualifiedName === undefined || high.getQualifiedName() !== "I") { high = undefined; }
    if (high === undefined) { high = new abap.types.Integer({qualifiedName: "I"}).set(INPUT.high); }
    let lv_interval = new abap.types.Integer({qualifiedName: "I"});
    abap.statements.assert(abap.compare.gt(high, low));
    abap.statements.assert(abap.compare.ge(low, abap.IntegerFactory.get(0)));
    lv_interval.set(abap.operators.add(abap.operators.minus(high,low),abap.IntegerFactory.get(1)));
    rv_integer.set((abap.builtin.abs({val: (await this.int())})));
    rv_integer.set(abap.operators.mod(rv_integer,lv_interval));
    rv_integer.set(abap.operators.add(rv_integer,low));
    return rv_integer;
  }
}
abap.Classes['CL_ABAP_RANDOM'] = cl_abap_random;
export {cl_abap_random};
//# sourceMappingURL=cl_abap_random.clas.mjs.map