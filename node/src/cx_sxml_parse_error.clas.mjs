const {cx_sxml_error} = await import("./cx_sxml_error.clas.mjs");
const {cx_root} = await import("./cx_root.clas.mjs");
// cx_sxml_parse_error.clas.abap
class cx_sxml_parse_error extends cx_sxml_error {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CX_SXML_PARSE_ERROR';
  static IMPLEMENTED_INTERFACES = ["IF_MESSAGE","IF_MESSAGE","IF_MESSAGE","IF_MESSAGE"];
  static ATTRIBUTES = {"ERROR_TEXT": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "visibility": "U", "is_constant": " ", "is_class": " "},
  "RAWSTRING": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "visibility": "U", "is_constant": " ", "is_class": " "},
  "XML_OFFSET": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": " ", "is_class": " "},
  "RC": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": " ", "is_class": " "},
  "KERNEL_PARSER": {"type": () => {return new abap.types.Character(32, {"qualifiedName":"SOTR_CONC","ddicName":"SOTR_CONC","description":"SOTR_CONC"});}, "visibility": "U", "is_constant": "X", "is_class": "X"}};
  static METHODS = {"CONSTRUCTOR": {"visibility": "U", "parameters": {"XML_OFFSET": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}}}};
  constructor() {
    super();
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
    this.error_text = new abap.types.String({qualifiedName: "STRING"});
    this.rawstring = new abap.types.String({qualifiedName: "STRING"});
    this.xml_offset = new abap.types.Integer({qualifiedName: "I"});
    this.rc = new abap.types.Integer({qualifiedName: "I"});
    this.kernel_parser = cx_sxml_parse_error.kernel_parser;
  }
  async constructor_(INPUT) {
    let xml_offset = INPUT?.xml_offset;
    if (xml_offset?.getQualifiedName === undefined || xml_offset.getQualifiedName() !== "I") { xml_offset = undefined; }
    if (xml_offset === undefined) { xml_offset = new abap.types.Integer({qualifiedName: "I"}).set(INPUT.xml_offset); }
    await super.constructor_();
    this.me.get().xml_offset.set(xml_offset);
    return this;
  }
}
abap.Classes['CX_SXML_PARSE_ERROR'] = cx_sxml_parse_error;
cx_sxml_parse_error.kernel_parser = new abap.types.Character(32, {"qualifiedName":"SOTR_CONC","ddicName":"SOTR_CONC","description":"SOTR_CONC"});
cx_sxml_parse_error.kernel_parser.set('00000000000000000000000000000000');
export {cx_sxml_parse_error};
//# sourceMappingURL=cx_sxml_parse_error.clas.mjs.map