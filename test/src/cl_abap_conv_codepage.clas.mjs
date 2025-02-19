await import("./cl_abap_conv_codepage.clas.locals.mjs");
const {cx_root} = await import("./cx_root.clas.mjs");
// cl_abap_conv_codepage.clas.abap
class cl_abap_conv_codepage {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CL_ABAP_CONV_CODEPAGE';
  static IMPLEMENTED_INTERFACES = [];
  static ATTRIBUTES = {};
  static METHODS = {"CREATE_IN": {"visibility": "U", "parameters": {"INSTANCE": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_ABAP_CONV_IN", RTTIName: "\\INTERFACE=IF_ABAP_CONV_IN"});}, "is_optional": " "}, "CODEPAGE": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}},
  "CREATE_OUT": {"visibility": "U", "parameters": {"INSTANCE": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_ABAP_CONV_OUT", RTTIName: "\\INTERFACE=IF_ABAP_CONV_OUT"});}, "is_optional": " "}, "CODEPAGE": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}}};
  constructor() {
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
  }
  async constructor_(INPUT) {
    if (super.constructor_) { await super.constructor_(INPUT); }
    return this;
  }
  async create_in(INPUT) {
    return cl_abap_conv_codepage.create_in(INPUT);
  }
  static async create_in(INPUT) {
    let instance = new abap.types.ABAPObject({qualifiedName: "IF_ABAP_CONV_IN", RTTIName: "\\INTERFACE=IF_ABAP_CONV_IN"});
    let codepage = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.codepage) {codepage.set(INPUT.codepage);}
    if (INPUT === undefined || INPUT.codepage === undefined) {codepage = new abap.types.Character(5).set('UTF-8');}
    instance.set(await (new abap.Classes['CLAS-CL_ABAP_CONV_CODEPAGE-LCL_IN']()).constructor_({codepage: codepage}));
    return instance;
  }
  async create_out(INPUT) {
    return cl_abap_conv_codepage.create_out(INPUT);
  }
  static async create_out(INPUT) {
    let instance = new abap.types.ABAPObject({qualifiedName: "IF_ABAP_CONV_OUT", RTTIName: "\\INTERFACE=IF_ABAP_CONV_OUT"});
    let codepage = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.codepage) {codepage.set(INPUT.codepage);}
    if (INPUT === undefined || INPUT.codepage === undefined) {codepage = new abap.types.Character(5).set('UTF-8');}
    instance.set(await (new abap.Classes['CLAS-CL_ABAP_CONV_CODEPAGE-LCL_OUT']()).constructor_({codepage: codepage}));
    return instance;
  }
}
abap.Classes['CL_ABAP_CONV_CODEPAGE'] = cl_abap_conv_codepage;
export {cl_abap_conv_codepage};
//# sourceMappingURL=cl_abap_conv_codepage.clas.mjs.map