const {cx_dynamic_check} = await import("./cx_dynamic_check.clas.mjs");
const {cx_root} = await import("./cx_root.clas.mjs");
// cx_sy_create_object_error.clas.abap
class cx_sy_create_object_error extends cx_dynamic_check {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CX_SY_CREATE_OBJECT_ERROR';
  static IMPLEMENTED_INTERFACES = ["IF_MESSAGE","IF_MESSAGE"];
  static ATTRIBUTES = {"CLASSNAME": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "visibility": "U", "is_constant": " ", "is_class": " "}};
  static METHODS = {"CONSTRUCTOR": {"visibility": "U", "parameters": {"TEXTID": {"type": () => {return new abap.types.Character(32, {});}, "is_optional": " "}, "PREVIOUS": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "CX_ROOT", RTTIName: "\\CLASS=CX_ROOT"});}, "is_optional": " "}, "CLASSNAME": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}},
  "IF_MESSAGE~GET_TEXT": {"visibility": "U", "parameters": {}}};
  constructor() {
    super();
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
    this.classname = new abap.types.String({qualifiedName: "STRING"});
  }
  async constructor_(INPUT) {
    let textid = new abap.types.Character(32, {});
    if (INPUT && INPUT.textid) {textid.set(INPUT.textid);}
    let previous = new abap.types.ABAPObject({qualifiedName: "CX_ROOT", RTTIName: "\\CLASS=CX_ROOT"});
    if (INPUT && INPUT.previous) {previous.set(INPUT.previous);}
    let classname = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.classname) {classname.set(INPUT.classname);}
    await super.constructor_({textid: textid, previous: previous});
    this.me.get().classname.set(classname);
    return this;
  }
  async if_message$get_text() {
    let result = new abap.types.String({qualifiedName: "STRING"});
    result.set(new abap.types.Character(62).set('The object could not be created: The class ??? does not exist.'));
    return result;
  }
}
abap.Classes['CX_SY_CREATE_OBJECT_ERROR'] = cx_sy_create_object_error;
export {cx_sy_create_object_error};
//# sourceMappingURL=cx_sy_create_object_error.clas.mjs.map