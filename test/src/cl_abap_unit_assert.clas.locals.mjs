const {cx_root} = await import("./cx_root.clas.mjs");
// cl_abap_unit_assert.clas.locals_imp.abap
class lcl_dump {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CLAS-CL_ABAP_UNIT_ASSERT-LCL_DUMP';
  static IMPLEMENTED_INTERFACES = [];
  static ATTRIBUTES = {};
  static METHODS = {"DUMP_STRUCTURE": {"visibility": "I", "parameters": {"RV_STR": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "IV_VAL": {"type": () => {return new abap.types.Character(4);}, "is_optional": " "}}},
  "TO_STRING": {"visibility": "U", "parameters": {"RV_STR": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "IV_VAL": {"type": () => {return new abap.types.Character(4);}, "is_optional": " "}}}};
  constructor() {
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
  }
  async constructor_(INPUT) {
    if (super.constructor_) { await super.constructor_(INPUT); }
    return this;
  }
  async to_string(INPUT) {
    return lcl_dump.to_string(INPUT);
  }
  static async to_string(INPUT) {
    let rv_str = new abap.types.String({qualifiedName: "STRING"});
    let iv_val = INPUT?.iv_val;
    let lv_type = new abap.types.Character(1, {});
    let lv_name = new abap.types.String({qualifiedName: "STRING"});
    abap.statements.describe({field: iv_val, type: lv_type});
    let unique149 = lv_type;
    if (abap.compare.eq(unique149, new abap.types.Character(1).set('u')) || abap.compare.eq(unique149, new abap.types.Character(1).set('v'))) {
      rv_str.set((await this.dump_structure({iv_val: iv_val})));
    } else if (abap.compare.eq(unique149, new abap.types.Character(1).set('h'))) {
      rv_str.set(new abap.types.String().set(`[itab]`));
    } else if (abap.compare.eq(unique149, new abap.types.Character(1).set('r'))) {
      lv_name.set(iv_val.get().constructor.name);
      rv_str.set(new abap.types.String().set(`[object, ${abap.templateFormatting(lv_name)}]`));
    } else {
      rv_str.set(new abap.types.String().set(`${abap.templateFormatting(iv_val)}`));
    }
    return rv_str;
  }
  async dump_structure(INPUT) {
    return lcl_dump.dump_structure(INPUT);
  }
  static async dump_structure(INPUT) {
    let rv_str = new abap.types.String({qualifiedName: "STRING"});
    let iv_val = INPUT?.iv_val;
    let lt_components = abap.types.TableFactory.construct(new abap.types.String({qualifiedName: "STRING"}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "");
    let lv_name = new abap.types.String({qualifiedName: "STRING"});
    let lv_str = new abap.types.String({qualifiedName: "STRING"});
    let fs_fs_ = new abap.types.FieldSymbol(new abap.types.Character(4));
    Object.keys(iv_val.get()).forEach((name) => lt_components.append(new abap.types.String().set(name)));
    for await (const unique150 of abap.statements.loop(lt_components)) {
      lv_name.set(unique150);
      if (abap.compare.ne(rv_str, new abap.types.Character(1).set(''))) {
        rv_str.set(abap.operators.concat(rv_str,new abap.types.String().set(`, `)));
      }
      abap.statements.assign({component: lv_name, target: fs_fs_, source: iv_val});
      abap.statements.assert(abap.compare.eq(abap.builtin.sy.get().subrc, abap.IntegerFactory.get(0)));
      lv_str.set((await this.to_string({iv_val: fs_fs_})));
      rv_str.set(abap.operators.concat(rv_str,abap.operators.concat(lv_name,abap.operators.concat(new abap.types.String().set(`: `),new abap.types.String().set(`${abap.templateFormatting(lv_str)}`)))));
    }
    return rv_str;
  }
}
abap.Classes['CLAS-CL_ABAP_UNIT_ASSERT-LCL_DUMP'] = lcl_dump;
export {lcl_dump};
//# sourceMappingURL=cl_abap_unit_assert.clas.locals.mjs.map