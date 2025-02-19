const {cx_root} = await import("./cx_root.clas.mjs");
// cl_sql_result_set.clas.abap
class cl_sql_result_set {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CL_SQL_RESULT_SET';
  static IMPLEMENTED_INTERFACES = [];
  static ATTRIBUTES = {"MV_MAGIC": {"type": () => {return new abap.types.Hex();}, "visibility": "I", "is_constant": " ", "is_class": " "},
  "MV_INDEX": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "I", "is_constant": " ", "is_class": " "},
  "MV_REF": {"type": () => {return new abap.types.DataReference(new abap.types.Character(4));}, "visibility": "I", "is_constant": " ", "is_class": " "}};
  static METHODS = {"SET_PARAM": {"visibility": "U", "parameters": {"DATA_REF": {"type": () => {return new abap.types.DataReference(new abap.types.Character(4));}, "is_optional": " "}}},
  "SET_PARAM_TABLE": {"visibility": "U", "parameters": {"ITAB_REF": {"type": () => {return new abap.types.DataReference(new abap.types.Character(4));}, "is_optional": " "}}},
  "NEXT": {"visibility": "U", "parameters": {"ROWS_RET": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}}},
  "CLOSE": {"visibility": "U", "parameters": {}},
  "NEXT_PACKAGE": {"visibility": "U", "parameters": {}}};
  constructor() {
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
    this.mv_magic = new abap.types.Hex();
    this.mv_index = new abap.types.Integer({qualifiedName: "I"});
    this.mv_ref = new abap.types.DataReference(new abap.types.Character(4));
  }
  async constructor_(INPUT) {
    if (super.constructor_) { await super.constructor_(INPUT); }
    return this;
  }
  async set_param(INPUT) {
    let data_ref = INPUT?.data_ref;
    if (data_ref === undefined) { data_ref = new abap.types.DataReference(new abap.types.Character(4)).set(INPUT.data_ref); }
    this.mv_ref.set(data_ref);
  }
  async next() {
    let rows_ret = new abap.types.Integer({qualifiedName: "I"});
    let lv_total = new abap.types.Integer({qualifiedName: "I"});
    let lv_value = new abap.types.String({qualifiedName: "STRING"});
    lv_total.set(this.mv_magic.length);
    const current = this.mv_magic[this.mv_index.get()];
    lv_value.set(Object.values(current)[0]);
    this.mv_ref.dereference().set(lv_value);
    this.mv_index.set(abap.operators.add(this.mv_index,abap.IntegerFactory.get(1)));
    rows_ret.set(abap.operators.minus(lv_total,this.mv_index));
    return rows_ret;
  }
  async close() {
    return;
  }
  async set_param_table(INPUT) {
    let itab_ref = INPUT?.itab_ref;
    if (itab_ref === undefined) { itab_ref = new abap.types.DataReference(new abap.types.Character(4)).set(INPUT.itab_ref); }
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
  }
  async next_package() {
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
  }
}
abap.Classes['CL_SQL_RESULT_SET'] = cl_sql_result_set;
export {cl_sql_result_set};
//# sourceMappingURL=cl_sql_result_set.clas.mjs.map