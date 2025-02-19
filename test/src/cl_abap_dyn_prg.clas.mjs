const {cx_root} = await import("./cx_root.clas.mjs");
// cl_abap_dyn_prg.clas.abap
class cl_abap_dyn_prg {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CL_ABAP_DYN_PRG';
  static IMPLEMENTED_INTERFACES = [];
  static ATTRIBUTES = {};
  static METHODS = {"CHECK_TABLE_NAME_STR": {"visibility": "U", "parameters": {"VAL_STR": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "VAL": {"type": () => {return new abap.types.Character();}, "is_optional": " "}, "PACKAGES": {"type": () => {return new abap.types.Character();}, "is_optional": " "}, "INCL_SUB_PACKAGES": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});}, "is_optional": " "}}},
  "CHECK_WHITELIST_STR": {"visibility": "U", "parameters": {"VAL_STR": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "VAL": {"type": () => {return new abap.types.Character();}, "is_optional": " "}, "WHITELIST": {"type": () => {return new abap.types.Character();}, "is_optional": " "}}},
  "QUOTE": {"visibility": "U", "parameters": {"OUT": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "VAL": {"type": () => {return new abap.types.Character();}, "is_optional": " "}}},
  "ESCAPE_QUOTES": {"visibility": "U", "parameters": {"OUT": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "VAL": {"type": () => {return new abap.types.Character();}, "is_optional": " "}}},
  "ESCAPE_XSS_XML_HTML": {"visibility": "U", "parameters": {"OUT": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "VAL": {"type": () => {return new abap.types.Character();}, "is_optional": " "}}},
  "ESCAPE_XSS_URL": {"visibility": "U", "parameters": {"OUT": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "VAL": {"type": () => {return new abap.types.Character();}, "is_optional": " "}}}};
  constructor() {
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
  }
  async constructor_(INPUT) {
    if (super.constructor_) { await super.constructor_(INPUT); }
    return this;
  }
  async check_table_name_str(INPUT) {
    return cl_abap_dyn_prg.check_table_name_str(INPUT);
  }
  static async check_table_name_str(INPUT) {
    let val_str = new abap.types.String({qualifiedName: "STRING"});
    let val = INPUT?.val;
    let packages = INPUT?.packages;
    let incl_sub_packages = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    if (INPUT && INPUT.incl_sub_packages) {incl_sub_packages.set(INPUT.incl_sub_packages);}
    val_str.set(val);
    return val_str;
  }
  async check_whitelist_str(INPUT) {
    return cl_abap_dyn_prg.check_whitelist_str(INPUT);
  }
  static async check_whitelist_str(INPUT) {
    let val_str = new abap.types.String({qualifiedName: "STRING"});
    let val = INPUT?.val;
    let whitelist = INPUT?.whitelist;
    val_str.set(val);
    return val_str;
  }
  async quote(INPUT) {
    return cl_abap_dyn_prg.quote(INPUT);
  }
  static async quote(INPUT) {
    let out = new abap.types.String({qualifiedName: "STRING"});
    let val = INPUT?.val;
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return out;
  }
  async escape_xss_url(INPUT) {
    return cl_abap_dyn_prg.escape_xss_url(INPUT);
  }
  static async escape_xss_url(INPUT) {
    let out = new abap.types.String({qualifiedName: "STRING"});
    let val = INPUT?.val;
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return out;
  }
  async escape_quotes(INPUT) {
    return cl_abap_dyn_prg.escape_quotes(INPUT);
  }
  static async escape_quotes(INPUT) {
    let out = new abap.types.String({qualifiedName: "STRING"});
    let val = INPUT?.val;
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return out;
  }
  async escape_xss_xml_html(INPUT) {
    return cl_abap_dyn_prg.escape_xss_xml_html(INPUT);
  }
  static async escape_xss_xml_html(INPUT) {
    let out = new abap.types.String({qualifiedName: "STRING"});
    let val = INPUT?.val;
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return out;
  }
}
abap.Classes['CL_ABAP_DYN_PRG'] = cl_abap_dyn_prg;
export {cl_abap_dyn_prg};
//# sourceMappingURL=cl_abap_dyn_prg.clas.mjs.map