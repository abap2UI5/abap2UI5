const {cx_sy_conversion_error} = await import("./cx_sy_conversion_error.clas.mjs");
const {cx_root} = await import("./cx_root.clas.mjs");
// cx_sy_conversion_overflow.clas.abap
class cx_sy_conversion_overflow extends cx_sy_conversion_error {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CX_SY_CONVERSION_OVERFLOW';
  static IMPLEMENTED_INTERFACES = ["IF_MESSAGE","IF_MESSAGE","IF_MESSAGE","IF_MESSAGE"];
  static ATTRIBUTES = {};
  static METHODS = {"CONSTRUCTOR": {"visibility": "U", "parameters": {"TEXTID": {"type": () => {return new abap.types.Character(32, {});}, "is_optional": " "}, "PREVIOUS": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "CX_ROOT", RTTIName: "\\CLASS=CX_ROOT"});}, "is_optional": " "}, "VALUE": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}}};
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
    let value = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.value) {value.set(INPUT.value);}
    await super.constructor_({textid: textid, previous: previous});
    return this;
  }
}
abap.Classes['CX_SY_CONVERSION_OVERFLOW'] = cx_sy_conversion_overflow;
export {cx_sy_conversion_overflow};
//# sourceMappingURL=cx_sy_conversion_overflow.clas.mjs.map