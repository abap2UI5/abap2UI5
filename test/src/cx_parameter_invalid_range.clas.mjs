const {cx_parameter_invalid} = await import("./cx_parameter_invalid.clas.mjs");
const {cx_root} = await import("./cx_root.clas.mjs");
// cx_parameter_invalid_range.clas.abap
class cx_parameter_invalid_range extends cx_parameter_invalid {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CX_PARAMETER_INVALID_RANGE';
  static IMPLEMENTED_INTERFACES = ["IF_MESSAGE","IF_MESSAGE","IF_MESSAGE","IF_MESSAGE"];
  static ATTRIBUTES = {};
  static METHODS = {"CONSTRUCTOR": {"visibility": "U", "parameters": {"TEXTID": {"type": () => {return new abap.types.Character(32, {});}, "is_optional": " "}, "PREVIOUS": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "CX_ROOT", RTTIName: "\\CLASS=CX_ROOT"});}, "is_optional": " "}, "PARAMETER": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "VALUE": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}}};
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
    let parameter = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.parameter) {parameter.set(INPUT.parameter);}
    let value = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.value) {value.set(INPUT.value);}
    await super.constructor_({textid: textid, previous: previous, parameter: parameter});
    return this;
  }
}
abap.Classes['CX_PARAMETER_INVALID_RANGE'] = cx_parameter_invalid_range;
export {cx_parameter_invalid_range};
//# sourceMappingURL=cx_parameter_invalid_range.clas.mjs.map