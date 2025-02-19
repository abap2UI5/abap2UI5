const {cx_sy_dyn_call_error} = await import("./cx_sy_dyn_call_error.clas.mjs");
const {cx_root} = await import("./cx_root.clas.mjs");
// cx_sy_dyn_call_illegal_method.clas.abap
class cx_sy_dyn_call_illegal_method extends cx_sy_dyn_call_error {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CX_SY_DYN_CALL_ILLEGAL_METHOD';
  static IMPLEMENTED_INTERFACES = ["IF_MESSAGE","IF_MESSAGE","IF_MESSAGE","IF_MESSAGE"];
  static ATTRIBUTES = {"PRIVATE_METHOD": {"type": () => {return new abap.types.Character(32, {"qualifiedName":"SOTR_CONC","ddicName":"SOTR_CONC","description":"SOTR_CONC"});}, "visibility": "U", "is_constant": "X", "is_class": "X"}};
  static METHODS = {"CONSTRUCTOR": {"visibility": "U", "parameters": {"TEXTID": {"type": () => {return new abap.types.Character(32, {});}, "is_optional": " "}, "PREVIOUS": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "CX_ROOT", RTTIName: "\\CLASS=CX_ROOT"});}, "is_optional": " "}, "CLASSNAME": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "METHODNAME": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}}};
  constructor() {
    super();
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
    this.private_method = cx_sy_dyn_call_illegal_method.private_method;
  }
  async constructor_(INPUT) {
    let textid = new abap.types.Character(32, {});
    if (INPUT && INPUT.textid) {textid.set(INPUT.textid);}
    let previous = new abap.types.ABAPObject({qualifiedName: "CX_ROOT", RTTIName: "\\CLASS=CX_ROOT"});
    if (INPUT && INPUT.previous) {previous.set(INPUT.previous);}
    let classname = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.classname) {classname.set(INPUT.classname);}
    let methodname = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.methodname) {methodname.set(INPUT.methodname);}
    await super.constructor_({previous: previous});
    return this;
  }
}
abap.Classes['CX_SY_DYN_CALL_ILLEGAL_METHOD'] = cx_sy_dyn_call_illegal_method;
cx_sy_dyn_call_illegal_method.private_method = new abap.types.Character(32, {"qualifiedName":"SOTR_CONC","ddicName":"SOTR_CONC","description":"SOTR_CONC"});
cx_sy_dyn_call_illegal_method.private_method.set('11111111111111111111111111111111');
export {cx_sy_dyn_call_illegal_method};
//# sourceMappingURL=cx_sy_dyn_call_illegal_method.clas.mjs.map