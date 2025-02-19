const {cx_root} = await import("./cx_root.clas.mjs");
// cl_abap_exceptional_values.clas.abap
class cl_abap_exceptional_values {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CL_ABAP_EXCEPTIONAL_VALUES';
  static IMPLEMENTED_INTERFACES = [];
  static ATTRIBUTES = {};
  static METHODS = {"GET_MAX_VALUE": {"visibility": "U", "parameters": {"OUT": {"type": () => {return new abap.types.DataReference(new abap.types.Character(4));}, "is_optional": " "}, "IN": {"type": () => {return new abap.types.Character(4);}, "is_optional": " "}}},
  "GET_MIN_VALUE": {"visibility": "U", "parameters": {"OUT": {"type": () => {return new abap.types.DataReference(new abap.types.Character(4));}, "is_optional": " "}, "IN": {"type": () => {return new abap.types.Character(4);}, "is_optional": " "}}}};
  constructor() {
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
  }
  async constructor_(INPUT) {
    if (super.constructor_) { await super.constructor_(INPUT); }
    return this;
  }
  async get_max_value(INPUT) {
    return cl_abap_exceptional_values.get_max_value(INPUT);
  }
  static async get_max_value(INPUT) {
    let out = new abap.types.DataReference(new abap.types.Character(4));
    let $in = INPUT?.in;
    let lv_type = new abap.types.Character(1, {});
    let lv_length = new abap.types.Integer({qualifiedName: "I"});
    let lv_decimals = new abap.types.Integer({qualifiedName: "I"});
    let lv_digits_before_decimal = new abap.types.Integer({qualifiedName: "I"});
    let lv_integer_part = new abap.types.String({qualifiedName: "STRING"});
    let lv_decimal_part = new abap.types.String({qualifiedName: "STRING"});
    let fs_out_ = new abap.types.FieldSymbol(new abap.types.Character(4));
    abap.statements.describe({field: $in, type: lv_type});
    let unique1 = lv_type;
    if (abap.compare.eq(unique1, abap.Classes['CL_ABAP_TYPEDESCR'].typekind_int)) {
      out.assign(abap.Classes['CL_ABAP_MATH'].max_int4);
    } else if (abap.compare.eq(unique1, abap.Classes['CL_ABAP_TYPEDESCR'].typekind_packed)) {
      abap.statements.describe({field: $in, length: lv_length, decimals: lv_decimals, mode: 'BYTE'});
      abap.statements.createData(out,{"typeName": "P","length": lv_length,"decimals": lv_decimals});
      abap.statements.assign({target: fs_out_, source: out.dereference()});
      lv_digits_before_decimal.set(abap.operators.minus(abap.operators.minus(abap.operators.multiply(lv_length,abap.IntegerFactory.get(2)),abap.IntegerFactory.get(1)),lv_decimals));
      const indexBackup1 = abap.builtin.sy.get().index.get();
      const unique2 = lv_digits_before_decimal.get();
      for (let unique3 = 0; unique3 < unique2; unique3++) {
        abap.builtin.sy.get().index.set(unique3 + 1);
        lv_integer_part.set(abap.operators.concat(lv_integer_part,new abap.types.Character(1).set('9')));
      }
      abap.builtin.sy.get().index.set(indexBackup1);
      if (abap.compare.gt(lv_decimals, abap.IntegerFactory.get(0))) {
        lv_decimal_part.set(new abap.types.Character(1).set('.'));
        const indexBackup2 = abap.builtin.sy.get().index.get();
        const unique4 = lv_decimals.get();
        for (let unique5 = 0; unique5 < unique4; unique5++) {
          abap.builtin.sy.get().index.set(unique5 + 1);
          lv_decimal_part.set(abap.operators.concat(lv_decimal_part,new abap.types.Character(1).set('9')));
        }
        abap.builtin.sy.get().index.set(indexBackup2);
      }
      fs_out_.set(abap.operators.concat(lv_integer_part,lv_decimal_part));
    } else {
      console.dir(INPUT);
      abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    }
    return out;
  }
  async get_min_value(INPUT) {
    return cl_abap_exceptional_values.get_min_value(INPUT);
  }
  static async get_min_value(INPUT) {
    let out = new abap.types.DataReference(new abap.types.Character(4));
    let $in = INPUT?.in;
    let lv_type = new abap.types.Character(1, {});
    let fs_out_ = new abap.types.FieldSymbol(new abap.types.Character(4));
    abap.statements.describe({field: $in, type: lv_type});
    let unique6 = lv_type;
    if (abap.compare.eq(unique6, abap.Classes['CL_ABAP_TYPEDESCR'].typekind_int)) {
      out.assign(abap.Classes['CL_ABAP_MATH'].min_int4);
    } else if (abap.compare.eq(unique6, abap.Classes['CL_ABAP_TYPEDESCR'].typekind_packed)) {
      out.set((await this.get_max_value({in: $in})));
      abap.statements.assign({target: fs_out_, source: out.dereference()});
      fs_out_.set(abap.operators.multiply(fs_out_,abap.IntegerFactory.get(-1)));
    } else {
      console.dir(INPUT);
      abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    }
    return out;
  }
}
abap.Classes['CL_ABAP_EXCEPTIONAL_VALUES'] = cl_abap_exceptional_values;
export {cl_abap_exceptional_values};
//# sourceMappingURL=cl_abap_exceptional_values.clas.mjs.map