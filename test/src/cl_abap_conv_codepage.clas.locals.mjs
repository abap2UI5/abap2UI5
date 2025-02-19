const {cx_root} = await import("./cx_root.clas.mjs");
// cl_abap_conv_codepage.clas.locals_imp.abap
class lcl_in {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CLAS-CL_ABAP_CONV_CODEPAGE-LCL_IN';
  static IMPLEMENTED_INTERFACES = ["IF_ABAP_CONV_IN"];
  static ATTRIBUTES = {"MV_ENCODING": {"type": () => {return new abap.types.Character(20, {"qualifiedName":"abap_encoding"});}, "visibility": "I", "is_constant": " ", "is_class": " "}};
  static METHODS = {"CONSTRUCTOR": {"visibility": "U", "parameters": {"CODEPAGE": {"type": () => {return new abap.types.Character(20, {"qualifiedName":"abap_encoding"});}, "is_optional": " "}}}};
  constructor() {
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
    this.mv_encoding = new abap.types.Character(20, {"qualifiedName":"abap_encoding"});
  }
  async constructor_(INPUT) {
    let codepage = INPUT?.codepage;
    if (codepage?.getQualifiedName === undefined || codepage.getQualifiedName() !== "ABAP_ENCODING") { codepage = undefined; }
    if (codepage === undefined) { codepage = new abap.types.Character(20, {"qualifiedName":"abap_encoding"}).set(INPUT.codepage); }
    this.mv_encoding.set(codepage);
    return this;
  }
  async if_abap_conv_in$convert(INPUT) {
    let result = new abap.types.String({qualifiedName: "STRING"});
    let source = INPUT?.source;
    if (source?.getQualifiedName === undefined || source.getQualifiedName() !== "XSTRING") { source = undefined; }
    if (source === undefined) { source = new abap.types.XString({qualifiedName: "XSTRING"}).set(INPUT.source); }
    let conv = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_CONV_IN_CE", RTTIName: "\\CLASS=CL_ABAP_CONV_IN_CE"});
    conv.set((await abap.Classes['CL_ABAP_CONV_IN_CE'].create({encoding: this.mv_encoding})));
    await conv.get().convert({input: source, data: result});
    return result;
  }
}
abap.Classes['CLAS-CL_ABAP_CONV_CODEPAGE-LCL_IN'] = lcl_in;
class lcl_out {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CLAS-CL_ABAP_CONV_CODEPAGE-LCL_OUT';
  static IMPLEMENTED_INTERFACES = ["IF_ABAP_CONV_OUT"];
  static ATTRIBUTES = {"MV_ENCODING": {"type": () => {return new abap.types.Character(20, {"qualifiedName":"abap_encoding"});}, "visibility": "I", "is_constant": " ", "is_class": " "}};
  static METHODS = {"CONSTRUCTOR": {"visibility": "U", "parameters": {"CODEPAGE": {"type": () => {return new abap.types.Character(20, {"qualifiedName":"abap_encoding"});}, "is_optional": " "}}}};
  constructor() {
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
    this.mv_encoding = new abap.types.Character(20, {"qualifiedName":"abap_encoding"});
  }
  async constructor_(INPUT) {
    let codepage = INPUT?.codepage;
    if (codepage?.getQualifiedName === undefined || codepage.getQualifiedName() !== "ABAP_ENCODING") { codepage = undefined; }
    if (codepage === undefined) { codepage = new abap.types.Character(20, {"qualifiedName":"abap_encoding"}).set(INPUT.codepage); }
    this.mv_encoding.set(codepage);
    return this;
  }
  async if_abap_conv_out$convert(INPUT) {
    let result = new abap.types.XString({qualifiedName: "XSTRING"});
    let source = INPUT?.source;
    if (source?.getQualifiedName === undefined || source.getQualifiedName() !== "STRING") { source = undefined; }
    if (source === undefined) { source = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.source); }
    let conv = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_CONV_OUT_CE", RTTIName: "\\CLASS=CL_ABAP_CONV_OUT_CE"});
    conv.set((await abap.Classes['CL_ABAP_CONV_OUT_CE'].create({encoding: this.mv_encoding})));
    await conv.get().convert({data: source, buffer: result});
    return result;
  }
}
abap.Classes['CLAS-CL_ABAP_CONV_CODEPAGE-LCL_OUT'] = lcl_out;
export {lcl_in, lcl_out};
//# sourceMappingURL=cl_abap_conv_codepage.clas.locals.mjs.map