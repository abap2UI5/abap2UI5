// cx_root.clas.abap
class cx_root extends Error {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CX_ROOT';
  static IMPLEMENTED_INTERFACES = ["IF_MESSAGE"];
  static ATTRIBUTES = {"PREVIOUS": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "CX_ROOT", RTTIName: "\\CLASS=CX_ROOT"});}, "visibility": "U", "is_constant": " ", "is_class": " "},
  "TEXTID": {"type": () => {return new abap.types.Character(32, {});}, "visibility": "U", "is_constant": " ", "is_class": " "}};
  static METHODS = {"CONSTRUCTOR": {"visibility": "U", "parameters": {"TEXTID": {"type": () => {return new abap.types.Character(32, {});}, "is_optional": " "}, "PREVIOUS": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "CX_ROOT", RTTIName: "\\CLASS=CX_ROOT"});}, "is_optional": " "}}},
  "GET_SOURCE_POSITION": {"visibility": "U", "parameters": {"PROGRAM_NAME": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "INCLUDE_NAME": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "SOURCE_LINE": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}}}};
  constructor() {
    super();
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
    this.previous = new abap.types.ABAPObject({qualifiedName: "CX_ROOT", RTTIName: "\\CLASS=CX_ROOT"});
    this.textid = new abap.types.Character(32, {});
    this.get_longtext = this.if_message$get_longtext;
    this.get_text = this.if_message$get_text;
  }
  async constructor_(INPUT) {
    let textid = new abap.types.Character(32, {});
    if (INPUT && INPUT.textid) {textid.set(INPUT.textid);}
    let previous = new abap.types.ABAPObject({qualifiedName: "CX_ROOT", RTTIName: "\\CLASS=CX_ROOT"});
    if (INPUT && INPUT.previous) {previous.set(INPUT.previous);}
    this.me.get().previous.set(previous);
    this.me.get().textid.set(textid);
    return this;
  }
  async get_source_position(INPUT) {
    let program_name = INPUT?.program_name || new abap.types.String({qualifiedName: "STRING"});
    let include_name = INPUT?.include_name || new abap.types.String({qualifiedName: "STRING"});
    let source_line = INPUT?.source_line || new abap.types.Integer({qualifiedName: "I"});
    abap.statements.clear(program_name);
    abap.statements.clear(include_name);
    abap.statements.clear(source_line);
    source_line.set(this.EXTRA_CX.INTERNAL_LINE || 1);
    program_name.set(this.EXTRA_CX.INTERNAL_FILENAME || "error");
  }
  async if_message$get_longtext(INPUT) {
    let result = new abap.types.String({qualifiedName: "STRING"});
    let preserve_newlines = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    if (INPUT && INPUT.preserve_newlines) {preserve_newlines.set(INPUT.preserve_newlines);}
    result.set(new abap.types.Character(29).set('OpenAbapGetLongtextDummyValue'));
    return result;
  }
  async if_message$get_text() {
    let result = new abap.types.String({qualifiedName: "STRING"});
    result.set((await abap.Classes['CL_MESSAGE_HELPER'].get_text_for_message({text: this.me})));
    return result;
  }
}
abap.Classes['CX_ROOT'] = cx_root;
export {cx_root};
//# sourceMappingURL=cx_root.clas.mjs.map