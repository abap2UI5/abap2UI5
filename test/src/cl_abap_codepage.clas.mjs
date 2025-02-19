const {cx_root} = await import("./cx_root.clas.mjs");
// cl_abap_codepage.clas.abap
class cl_abap_codepage {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CL_ABAP_CODEPAGE';
  static IMPLEMENTED_INTERFACES = [];
  static ATTRIBUTES = {};
  static METHODS = {"CONVERT_TO": {"visibility": "U", "parameters": {"OUTPUT": {"type": () => {return new abap.types.XString({qualifiedName: "XSTRING"});}, "is_optional": " "}, "CODEPAGE": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "SOURCE": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}},
  "CONVERT_FROM": {"visibility": "U", "parameters": {"OUTPUT": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "CODEPAGE": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "SOURCE": {"type": () => {return new abap.types.XString({qualifiedName: "XSTRING"});}, "is_optional": " "}}},
  "SAP_CODEPAGE": {"visibility": "U", "parameters": {"CODEPAGE": {"type": () => {return new abap.types.Character(20, {"qualifiedName":"abap_encoding"});}, "is_optional": " "}, "ENCODING": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}}};
  constructor() {
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
  }
  async constructor_(INPUT) {
    if (super.constructor_) { await super.constructor_(INPUT); }
    return this;
  }
  async convert_to(INPUT) {
    return cl_abap_codepage.convert_to(INPUT);
  }
  static async convert_to(INPUT) {
    let output = new abap.types.XString({qualifiedName: "XSTRING"});
    let codepage = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.codepage) {codepage.set(INPUT.codepage);}
    if (INPUT === undefined || INPUT.codepage === undefined) {codepage = new abap.types.Character(5).set('UTF-8');}
    let source = INPUT?.source;
    if (source?.getQualifiedName === undefined || source.getQualifiedName() !== "STRING") { source = undefined; }
    if (source === undefined) { source = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.source); }
    let conv = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_CONV_OUT_CE", RTTIName: "\\CLASS=CL_ABAP_CONV_OUT_CE"});
    conv.set((await abap.Classes['CL_ABAP_CONV_OUT_CE'].create({encoding: codepage})));
    await conv.get().convert({data: source, buffer: output});
    return output;
  }
  async convert_from(INPUT) {
    return cl_abap_codepage.convert_from(INPUT);
  }
  static async convert_from(INPUT) {
    let output = new abap.types.String({qualifiedName: "STRING"});
    let codepage = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.codepage) {codepage.set(INPUT.codepage);}
    if (INPUT === undefined || INPUT.codepage === undefined) {codepage = new abap.types.Character(5).set('UTF-8');}
    let source = INPUT?.source;
    if (source?.getQualifiedName === undefined || source.getQualifiedName() !== "XSTRING") { source = undefined; }
    if (source === undefined) { source = new abap.types.XString({qualifiedName: "XSTRING"}).set(INPUT.source); }
    let conv = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_CONV_IN_CE", RTTIName: "\\CLASS=CL_ABAP_CONV_IN_CE"});
    let data = new abap.types.String({qualifiedName: "STRING"});
    conv.set((await abap.Classes['CL_ABAP_CONV_IN_CE'].create({encoding: codepage})));
    await conv.get().convert({input: source, data: output});
    return output;
  }
  async sap_codepage(INPUT) {
    return cl_abap_codepage.sap_codepage(INPUT);
  }
  static async sap_codepage(INPUT) {
    let codepage = new abap.types.Character(20, {"qualifiedName":"abap_encoding"});
    let encoding = INPUT?.encoding;
    if (encoding?.getQualifiedName === undefined || encoding.getQualifiedName() !== "STRING") { encoding = undefined; }
    if (encoding === undefined) { encoding = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.encoding); }
    abap.statements.assert(abap.compare.eq(encoding, new abap.types.Character(8).set('UTF-16LE')));
    codepage.set(new abap.types.Character(4).set('4103'));
    return codepage;
  }
}
abap.Classes['CL_ABAP_CODEPAGE'] = cl_abap_codepage;
export {cl_abap_codepage};
//# sourceMappingURL=cl_abap_codepage.clas.mjs.map