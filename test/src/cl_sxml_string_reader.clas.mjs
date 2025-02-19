await import("./cl_sxml_string_reader.clas.locals.mjs");
const {cx_root} = await import("./cx_root.clas.mjs");
// cl_sxml_string_reader.clas.abap
class cl_sxml_string_reader {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CL_SXML_STRING_READER';
  static IMPLEMENTED_INTERFACES = [];
  static ATTRIBUTES = {};
  static METHODS = {"CREATE": {"visibility": "U", "parameters": {"READER": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_SXML_READER", RTTIName: "\\INTERFACE=IF_SXML_READER"});}, "is_optional": " "}, "INPUT": {"type": () => {return new abap.types.XString({qualifiedName: "XSTRING"});}, "is_optional": " "}}}};
  constructor() {
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
  }
  async constructor_(INPUT) {
    if (super.constructor_) { await super.constructor_(INPUT); }
    return this;
  }
  async create(INPUT) {
    return cl_sxml_string_reader.create(INPUT);
  }
  static async create(INPUT) {
    let reader = new abap.types.ABAPObject({qualifiedName: "IF_SXML_READER", RTTIName: "\\INTERFACE=IF_SXML_READER"});
    let input = INPUT?.input;
    if (input?.getQualifiedName === undefined || input.getQualifiedName() !== "XSTRING") { input = undefined; }
    if (input === undefined) { input = new abap.types.XString({qualifiedName: "XSTRING"}).set(INPUT.input); }
    reader.set(await (new abap.Classes['CLAS-CL_SXML_STRING_READER-LCL_READER']()).constructor_({iv_json: (await abap.Classes['CL_ABAP_CODEPAGE'].convert_from({source: input}))}));
    return reader;
  }
}
abap.Classes['CL_SXML_STRING_READER'] = cl_sxml_string_reader;
export {cl_sxml_string_reader};
//# sourceMappingURL=cl_sxml_string_reader.clas.mjs.map