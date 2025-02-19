const {cl_abap_datadescr} = await import("./cl_abap_datadescr.clas.mjs");
const {cx_root} = await import("./cx_root.clas.mjs");
// cl_abap_elemdescr.clas.abap
class cl_abap_elemdescr extends cl_abap_datadescr {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CL_ABAP_ELEMDESCR';
  static IMPLEMENTED_INTERFACES = [];
  static ATTRIBUTES = {"OUTPUT_LENGTH": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": " ", "is_class": " "},
  "EDIT_MASK": {"type": () => {return new abap.types.Character(7, {"qualifiedName":"abap_editmask"});}, "visibility": "U", "is_constant": " ", "is_class": " "},
  "HELP_ID": {"type": () => {return new abap.types.Character(62, {"qualifiedName":"abap_helpid"});}, "visibility": "U", "is_constant": " ", "is_class": " "}};
  static METHODS = {"GET_DDIC_FIXED_VALUES": {"visibility": "U", "parameters": {"P_FIXED_VALUES": {"type": () => {return abap.types.TableFactory.construct(new abap.types.Structure({"low": new abap.types.Character(10, {"qualifiedName":"cl_abap_elemdescr=>fixvalue-low"}), "high": new abap.types.Character(10, {"qualifiedName":"cl_abap_elemdescr=>fixvalue-high"}), "option": new abap.types.Character(2, {"qualifiedName":"cl_abap_elemdescr=>fixvalue-option"}), "ddlanguage": new abap.types.Character(1, {"qualifiedName":"cl_abap_elemdescr=>fixvalue-ddlanguage"}), "ddtext": new abap.types.Character(60, {"qualifiedName":"cl_abap_elemdescr=>fixvalue-ddtext"})}, "cl_abap_elemdescr=>fixvalue", undefined, {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "cl_abap_elemdescr=>fixvalues");}, "is_optional": " "}, "P_LANGU": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"sy-langu","conversionExit":"ISOLA"});}, "is_optional": " "}}},
  "GET_DDIC_FIELD": {"visibility": "U", "parameters": {"P_FLDDESCR": {"type": () => {return new abap.types.Structure({"tabname": new abap.types.Character(30, {}), "fieldname": new abap.types.Character(30, {}), "langu": new abap.types.Character(1, {}), "position": new abap.types.Numc({length: 4}), "offset": new abap.types.Numc({length: 6}), "domname": new abap.types.Character(30, {}), "rollname": new abap.types.Character(30, {}), "checktable": new abap.types.Character(1, {}), "leng": new abap.types.Numc({length: 6}), "intlen": new abap.types.Numc({length: 6}), "outputlen": new abap.types.Numc({length: 6}), "decimals": new abap.types.Numc({length: 6}), "datatype": new abap.types.Character(1, {}), "inttype": new abap.types.Character(1, {}), "reftable": new abap.types.Character(1, {}), "reffield": new abap.types.Character(1, {}), "precfield": new abap.types.Character(1, {}), "authorid": new abap.types.Character(1, {}), "memoryid": new abap.types.Character(1, {}), "logflag": new abap.types.Character(1, {}), "mask": new abap.types.Character(20, {}), "masklen": new abap.types.Character(1, {}), "convexit": new abap.types.Character(1, {}), "headlen": new abap.types.Character(1, {}), "scrlen1": new abap.types.Character(1, {}), "scrlen2": new abap.types.Character(1, {}), "scrlen3": new abap.types.Character(1, {}), "fieldtext": new abap.types.Character(1, {}), "reptext": new abap.types.Character(1, {}), "scrtext_s": new abap.types.Character(1, {}), "scrtext_m": new abap.types.Character(1, {}), "scrtext_l": new abap.types.Character(1, {}), "keyflag": new abap.types.Character(1, {}), "lowercase": new abap.types.Character(1, {}), "mac": new abap.types.Character(1, {}), "genkey": new abap.types.Character(1, {}), "noforkey": new abap.types.Character(1, {}), "valexi": new abap.types.Character(1, {}), "noauthch": new abap.types.Character(1, {}), "sign": new abap.types.Character(1, {}), "dynpfld": new abap.types.Character(1, {}), "f4availabl": new abap.types.Character(1, {}), "comptype": new abap.types.Character(1, {}), "outputstyle": new abap.types.Character(1, {}), "lfieldname": new abap.types.Character(132, {})}, "DFIES", "DFIES", {}, {});}, "is_optional": " "}, "P_LANGU": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"sy-langu","conversionExit":"ISOLA"});}, "is_optional": " "}}},
  "GET_I": {"visibility": "U", "parameters": {"R_RESULT": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "CL_ABAP_ELEMDESCR", RTTIName: "\\CLASS=CL_ABAP_ELEMDESCR"});}, "is_optional": " "}}},
  "GET_INT8": {"visibility": "U", "parameters": {"R_RESULT": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "CL_ABAP_ELEMDESCR", RTTIName: "\\CLASS=CL_ABAP_ELEMDESCR"});}, "is_optional": " "}}},
  "GET_F": {"visibility": "U", "parameters": {"R_RESULT": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "CL_ABAP_ELEMDESCR", RTTIName: "\\CLASS=CL_ABAP_ELEMDESCR"});}, "is_optional": " "}}},
  "GET_D": {"visibility": "U", "parameters": {"R_RESULT": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "CL_ABAP_ELEMDESCR", RTTIName: "\\CLASS=CL_ABAP_ELEMDESCR"});}, "is_optional": " "}}},
  "GET_T": {"visibility": "U", "parameters": {"R_RESULT": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "CL_ABAP_ELEMDESCR", RTTIName: "\\CLASS=CL_ABAP_ELEMDESCR"});}, "is_optional": " "}}},
  "GET_DECFLOAT16": {"visibility": "U", "parameters": {"R_RESULT": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "CL_ABAP_ELEMDESCR", RTTIName: "\\CLASS=CL_ABAP_ELEMDESCR"});}, "is_optional": " "}}},
  "GET_DECFLOAT34": {"visibility": "U", "parameters": {"R_RESULT": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "CL_ABAP_ELEMDESCR", RTTIName: "\\CLASS=CL_ABAP_ELEMDESCR"});}, "is_optional": " "}}},
  "GET_STRING": {"visibility": "U", "parameters": {"P_RESULT": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "CL_ABAP_ELEMDESCR", RTTIName: "\\CLASS=CL_ABAP_ELEMDESCR"});}, "is_optional": " "}}},
  "GET_UTCLONG": {"visibility": "U", "parameters": {"P_RESULT": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "CL_ABAP_ELEMDESCR", RTTIName: "\\CLASS=CL_ABAP_ELEMDESCR"});}, "is_optional": " "}}},
  "GET_C": {"visibility": "U", "parameters": {"P_RESULT": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "CL_ABAP_ELEMDESCR", RTTIName: "\\CLASS=CL_ABAP_ELEMDESCR"});}, "is_optional": " "}, "P_LENGTH": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}}},
  "GET_P": {"visibility": "U", "parameters": {"P_RESULT": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "CL_ABAP_ELEMDESCR", RTTIName: "\\CLASS=CL_ABAP_ELEMDESCR"});}, "is_optional": " "}, "P_LENGTH": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}, "P_DECIMALS": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}}},
  "GET_N": {"visibility": "U", "parameters": {"P_RESULT": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "CL_ABAP_ELEMDESCR", RTTIName: "\\CLASS=CL_ABAP_ELEMDESCR"});}, "is_optional": " "}, "P_LENGTH": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}}},
  "GET_X": {"visibility": "U", "parameters": {"P_RESULT": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "CL_ABAP_ELEMDESCR", RTTIName: "\\CLASS=CL_ABAP_ELEMDESCR"});}, "is_optional": " "}, "P_LENGTH": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}}},
  "GET_XSTRING": {"visibility": "U", "parameters": {"P_RESULT": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "CL_ABAP_ELEMDESCR", RTTIName: "\\CLASS=CL_ABAP_ELEMDESCR"});}, "is_optional": " "}}}};
  constructor() {
    super();
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
    this.output_length = new abap.types.Integer({qualifiedName: "I"});
    this.edit_mask = new abap.types.Character(7, {"qualifiedName":"abap_editmask"});
    this.help_id = new abap.types.Character(62, {"qualifiedName":"abap_helpid"});
  }
  async constructor_(INPUT) {
    if (super.constructor_) { await super.constructor_(INPUT); }
    return this;
  }
  async get_p(INPUT) {
    return cl_abap_elemdescr.get_p(INPUT);
  }
  static async get_p(INPUT) {
    let p_result = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_ELEMDESCR", RTTIName: "\\CLASS=CL_ABAP_ELEMDESCR"});
    let p_length = INPUT?.p_length;
    if (p_length?.getQualifiedName === undefined || p_length.getQualifiedName() !== "I") { p_length = undefined; }
    if (p_length === undefined) { p_length = new abap.types.Integer({qualifiedName: "I"}).set(INPUT.p_length); }
    let p_decimals = INPUT?.p_decimals;
    if (p_decimals?.getQualifiedName === undefined || p_decimals.getQualifiedName() !== "I") { p_decimals = undefined; }
    if (p_decimals === undefined) { p_decimals = new abap.types.Integer({qualifiedName: "I"}).set(INPUT.p_decimals); }
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return p_result;
  }
  async get_decfloat16() {
    return cl_abap_elemdescr.get_decfloat16();
  }
  static async get_decfloat16() {
    let r_result = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_ELEMDESCR", RTTIName: "\\CLASS=CL_ABAP_ELEMDESCR"});
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return r_result;
  }
  async get_decfloat34() {
    return cl_abap_elemdescr.get_decfloat34();
  }
  static async get_decfloat34() {
    let r_result = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_ELEMDESCR", RTTIName: "\\CLASS=CL_ABAP_ELEMDESCR"});
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return r_result;
  }
  async get_n(INPUT) {
    return cl_abap_elemdescr.get_n(INPUT);
  }
  static async get_n(INPUT) {
    let p_result = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_ELEMDESCR", RTTIName: "\\CLASS=CL_ABAP_ELEMDESCR"});
    let p_length = INPUT?.p_length;
    if (p_length?.getQualifiedName === undefined || p_length.getQualifiedName() !== "I") { p_length = undefined; }
    if (p_length === undefined) { p_length = new abap.types.Integer({qualifiedName: "I"}).set(INPUT.p_length); }
    let foo = new abap.types.DataReference(new abap.types.Character(4));
    abap.statements.createData(foo,{"typeName": "N","length": p_length});
    await abap.statements.cast(p_result, (await abap.Classes['CL_ABAP_TYPEDESCR'].describe_by_data_ref({p_data_ref: foo})));
    return p_result;
  }
  async get_x(INPUT) {
    return cl_abap_elemdescr.get_x(INPUT);
  }
  static async get_x(INPUT) {
    let p_result = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_ELEMDESCR", RTTIName: "\\CLASS=CL_ABAP_ELEMDESCR"});
    let p_length = INPUT?.p_length;
    if (p_length?.getQualifiedName === undefined || p_length.getQualifiedName() !== "I") { p_length = undefined; }
    if (p_length === undefined) { p_length = new abap.types.Integer({qualifiedName: "I"}).set(INPUT.p_length); }
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return p_result;
  }
  async get_xstring() {
    return cl_abap_elemdescr.get_xstring();
  }
  static async get_xstring() {
    let p_result = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_ELEMDESCR", RTTIName: "\\CLASS=CL_ABAP_ELEMDESCR"});
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return p_result;
  }
  async get_ddic_field(INPUT) {
    let p_flddescr = new abap.types.Structure({"tabname": new abap.types.Character(30, {}), "fieldname": new abap.types.Character(30, {}), "langu": new abap.types.Character(1, {}), "position": new abap.types.Numc({length: 4}), "offset": new abap.types.Numc({length: 6}), "domname": new abap.types.Character(30, {}), "rollname": new abap.types.Character(30, {}), "checktable": new abap.types.Character(1, {}), "leng": new abap.types.Numc({length: 6}), "intlen": new abap.types.Numc({length: 6}), "outputlen": new abap.types.Numc({length: 6}), "decimals": new abap.types.Numc({length: 6}), "datatype": new abap.types.Character(1, {}), "inttype": new abap.types.Character(1, {}), "reftable": new abap.types.Character(1, {}), "reffield": new abap.types.Character(1, {}), "precfield": new abap.types.Character(1, {}), "authorid": new abap.types.Character(1, {}), "memoryid": new abap.types.Character(1, {}), "logflag": new abap.types.Character(1, {}), "mask": new abap.types.Character(20, {}), "masklen": new abap.types.Character(1, {}), "convexit": new abap.types.Character(1, {}), "headlen": new abap.types.Character(1, {}), "scrlen1": new abap.types.Character(1, {}), "scrlen2": new abap.types.Character(1, {}), "scrlen3": new abap.types.Character(1, {}), "fieldtext": new abap.types.Character(1, {}), "reptext": new abap.types.Character(1, {}), "scrtext_s": new abap.types.Character(1, {}), "scrtext_m": new abap.types.Character(1, {}), "scrtext_l": new abap.types.Character(1, {}), "keyflag": new abap.types.Character(1, {}), "lowercase": new abap.types.Character(1, {}), "mac": new abap.types.Character(1, {}), "genkey": new abap.types.Character(1, {}), "noforkey": new abap.types.Character(1, {}), "valexi": new abap.types.Character(1, {}), "noauthch": new abap.types.Character(1, {}), "sign": new abap.types.Character(1, {}), "dynpfld": new abap.types.Character(1, {}), "f4availabl": new abap.types.Character(1, {}), "comptype": new abap.types.Character(1, {}), "outputstyle": new abap.types.Character(1, {}), "lfieldname": new abap.types.Character(132, {})}, "DFIES", "DFIES", {}, {});
    let p_langu = new abap.types.Character(1, {"qualifiedName":"sy-langu","conversionExit":"ISOLA"});
    if (INPUT && INPUT.p_langu) {p_langu.set(INPUT.p_langu);}
    if (INPUT === undefined || INPUT.p_langu === undefined) {p_langu = abap.builtin.sy.get().langu;}
    p_flddescr.get().tabname.set(this.absolute_name);
    p_flddescr.get().inttype.set(this.type_kind);
    p_flddescr.get().langu.set(abap.builtin.sy.get().langu);
    p_flddescr.get().position.set(abap.IntegerFactory.get(1));
    p_flddescr.get().leng.set(this.length);
    p_flddescr.get().decimals.set(this.decimals);
    p_flddescr.get().domname.set(abap.DDIC[this.relative_name.get()]?.domain || "");
    return p_flddescr;
  }
  async get_i() {
    return cl_abap_elemdescr.get_i();
  }
  static async get_i() {
    let r_result = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_ELEMDESCR", RTTIName: "\\CLASS=CL_ABAP_ELEMDESCR"});
    let foo = new abap.types.Integer({qualifiedName: "I"});
    await abap.statements.cast(r_result, (await abap.Classes['CL_ABAP_TYPEDESCR'].describe_by_data({p_data: foo})));
    return r_result;
  }
  async get_int8() {
    return cl_abap_elemdescr.get_int8();
  }
  static async get_int8() {
    let r_result = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_ELEMDESCR", RTTIName: "\\CLASS=CL_ABAP_ELEMDESCR"});
    let foo = new abap.types.Integer8({qualifiedName: "INT8"});
    await abap.statements.cast(r_result, (await abap.Classes['CL_ABAP_TYPEDESCR'].describe_by_data({p_data: foo})));
    return r_result;
  }
  async get_string() {
    return cl_abap_elemdescr.get_string();
  }
  static async get_string() {
    let p_result = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_ELEMDESCR", RTTIName: "\\CLASS=CL_ABAP_ELEMDESCR"});
    let foo = new abap.types.String({qualifiedName: "STRING"});
    await abap.statements.cast(p_result, (await abap.Classes['CL_ABAP_TYPEDESCR'].describe_by_data({p_data: foo})));
    return p_result;
  }
  async get_f() {
    return cl_abap_elemdescr.get_f();
  }
  static async get_f() {
    let r_result = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_ELEMDESCR", RTTIName: "\\CLASS=CL_ABAP_ELEMDESCR"});
    let foo = new abap.types.Float({qualifiedName: "F"});
    await abap.statements.cast(r_result, (await abap.Classes['CL_ABAP_TYPEDESCR'].describe_by_data({p_data: foo})));
    return r_result;
  }
  async get_d() {
    return cl_abap_elemdescr.get_d();
  }
  static async get_d() {
    let r_result = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_ELEMDESCR", RTTIName: "\\CLASS=CL_ABAP_ELEMDESCR"});
    let foo = new abap.types.Date({qualifiedName: "D"});
    await abap.statements.cast(r_result, (await abap.Classes['CL_ABAP_TYPEDESCR'].describe_by_data({p_data: foo})));
    return r_result;
  }
  async get_t() {
    return cl_abap_elemdescr.get_t();
  }
  static async get_t() {
    let r_result = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_ELEMDESCR", RTTIName: "\\CLASS=CL_ABAP_ELEMDESCR"});
    let foo = new abap.types.Time({qualifiedName: "T"});
    await abap.statements.cast(r_result, (await abap.Classes['CL_ABAP_TYPEDESCR'].describe_by_data({p_data: foo})));
    return r_result;
  }
  async get_c(INPUT) {
    return cl_abap_elemdescr.get_c(INPUT);
  }
  static async get_c(INPUT) {
    let p_result = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_ELEMDESCR", RTTIName: "\\CLASS=CL_ABAP_ELEMDESCR"});
    let p_length = INPUT?.p_length;
    if (p_length?.getQualifiedName === undefined || p_length.getQualifiedName() !== "I") { p_length = undefined; }
    if (p_length === undefined) { p_length = new abap.types.Integer({qualifiedName: "I"}).set(INPUT.p_length); }
    let foo = new abap.types.DataReference(new abap.types.Character(4));
    abap.statements.createData(foo,{"typeName": "C","length": p_length});
    await abap.statements.cast(p_result, (await abap.Classes['CL_ABAP_TYPEDESCR'].describe_by_data_ref({p_data_ref: foo})));
    return p_result;
  }
  async get_utclong() {
    return cl_abap_elemdescr.get_utclong();
  }
  static async get_utclong() {
    let p_result = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_ELEMDESCR", RTTIName: "\\CLASS=CL_ABAP_ELEMDESCR"});
    let foo = new abap.types.DataReference(new abap.types.Character(4));
    abap.statements.createData(foo,{"typeName": "UTCLONG"});
    await abap.statements.cast(p_result, (await abap.Classes['CL_ABAP_TYPEDESCR'].describe_by_data_ref({p_data_ref: foo})));
    return p_result;
  }
  async get_ddic_fixed_values(INPUT) {
    let p_fixed_values = abap.types.TableFactory.construct(new abap.types.Structure({"low": new abap.types.Character(10, {"qualifiedName":"cl_abap_elemdescr=>fixvalue-low"}), "high": new abap.types.Character(10, {"qualifiedName":"cl_abap_elemdescr=>fixvalue-high"}), "option": new abap.types.Character(2, {"qualifiedName":"cl_abap_elemdescr=>fixvalue-option"}), "ddlanguage": new abap.types.Character(1, {"qualifiedName":"cl_abap_elemdescr=>fixvalue-ddlanguage"}), "ddtext": new abap.types.Character(60, {"qualifiedName":"cl_abap_elemdescr=>fixvalue-ddtext"})}, "cl_abap_elemdescr=>fixvalue", undefined, {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "cl_abap_elemdescr=>fixvalues");
    let p_langu = new abap.types.Character(1, {"qualifiedName":"sy-langu","conversionExit":"ISOLA"});
    if (INPUT && INPUT.p_langu) {p_langu.set(INPUT.p_langu);}
    if (INPUT === undefined || INPUT.p_langu === undefined) {p_langu = abap.builtin.sy.get().langu;}
    let lv_dummy = new abap.types.String({qualifiedName: "STRING"});
    let lv_name = new abap.types.String({qualifiedName: "STRING"});
    let ls_row = new abap.types.Structure({"low": new abap.types.Character(10, {"qualifiedName":"cl_abap_elemdescr=>fixvalue-low"}), "high": new abap.types.Character(10, {"qualifiedName":"cl_abap_elemdescr=>fixvalue-high"}), "option": new abap.types.Character(2, {"qualifiedName":"cl_abap_elemdescr=>fixvalue-option"}), "ddlanguage": new abap.types.Character(1, {"qualifiedName":"cl_abap_elemdescr=>fixvalue-ddlanguage"}), "ddtext": new abap.types.Character(60, {"qualifiedName":"cl_abap_elemdescr=>fixvalue-ddtext"})}, "cl_abap_elemdescr=>fixvalue", undefined, {}, {});
    abap.statements.split({source: this.absolute_name, at: new abap.types.Character(1).set('='), targets: [lv_dummy,lv_name]});
    for (const f of abap.DDIC[lv_name.get()]?.fixedValues || []) {
      abap.statements.clear(ls_row);
        ls_row.get().low.set(f.low || "");
        ls_row.get().high.set(f.high || "");
        ls_row.get().option.set(f.option || "");
        ls_row.get().ddlanguage.set(f.ddlanguage || "");
        ls_row.get().ddtext.set(f.ddtext || "");
      abap.statements.append({source: ls_row, target: p_fixed_values});
    }
    return p_fixed_values;
  }
}
abap.Classes['CL_ABAP_ELEMDESCR'] = cl_abap_elemdescr;
cl_abap_elemdescr.fixvalue = new abap.types.Structure({"low": new abap.types.Character(10, {"qualifiedName":"cl_abap_elemdescr=>fixvalue-low"}), "high": new abap.types.Character(10, {"qualifiedName":"cl_abap_elemdescr=>fixvalue-high"}), "option": new abap.types.Character(2, {"qualifiedName":"cl_abap_elemdescr=>fixvalue-option"}), "ddlanguage": new abap.types.Character(1, {"qualifiedName":"cl_abap_elemdescr=>fixvalue-ddlanguage"}), "ddtext": new abap.types.Character(60, {"qualifiedName":"cl_abap_elemdescr=>fixvalue-ddtext"})}, "cl_abap_elemdescr=>fixvalue", undefined, {}, {});
cl_abap_elemdescr.fixvalues = abap.types.TableFactory.construct(new abap.types.Structure({"low": new abap.types.Character(10, {"qualifiedName":"cl_abap_elemdescr=>fixvalue-low"}), "high": new abap.types.Character(10, {"qualifiedName":"cl_abap_elemdescr=>fixvalue-high"}), "option": new abap.types.Character(2, {"qualifiedName":"cl_abap_elemdescr=>fixvalue-option"}), "ddlanguage": new abap.types.Character(1, {"qualifiedName":"cl_abap_elemdescr=>fixvalue-ddlanguage"}), "ddtext": new abap.types.Character(60, {"qualifiedName":"cl_abap_elemdescr=>fixvalue-ddtext"})}, "cl_abap_elemdescr=>fixvalue", undefined, {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "cl_abap_elemdescr=>fixvalues");
export {cl_abap_elemdescr};
//# sourceMappingURL=cl_abap_elemdescr.clas.mjs.map