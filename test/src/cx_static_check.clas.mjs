const {cx_root} = await import("./cx_root.clas.mjs");
// cx_static_check.clas.abap
class cx_static_check extends cx_root {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CX_STATIC_CHECK';
  static IMPLEMENTED_INTERFACES = ["IF_MESSAGE"];
  static ATTRIBUTES = {};
  static METHODS = {"CONSTRUCTOR": {"visibility": "U", "parameters": {"TEXTID": {"type": () => {return new abap.types.Character(32, {});}, "is_optional": " "}, "PREVIOUS": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "CX_ROOT", RTTIName: "\\CLASS=CX_ROOT"});}, "is_optional": " "}}}};
  constructor() {
    super();
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
  }
  async constructor_(INPUT) {
    let textid = new abap.types.Character(32, {});
    if (INPUT && INPUT.textid) {textid.set(INPUT.textid);}
    let previous = new abap.types.ABAPObject({qualifiedName: "CX_ROOT", RTTIName: "\\CLASS=CX_ROOT"});
    if (INPUT && INPUT.previous) {previous.set(INPUT.previous);}
    await super.constructor_({textid: textid, previous: previous});
    return this;
  }
}
abap.Classes['CX_STATIC_CHECK'] = cx_static_check;
export {cx_static_check};
//# sourceMappingURL=cx_static_check.clas.mjs.map