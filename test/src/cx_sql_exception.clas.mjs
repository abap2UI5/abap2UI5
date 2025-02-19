const {cx_static_check} = await import("./cx_static_check.clas.mjs");
const {cx_root} = await import("./cx_root.clas.mjs");
// cx_sql_exception.clas.abap
class cx_sql_exception extends cx_static_check {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CX_SQL_EXCEPTION';
  static IMPLEMENTED_INTERFACES = ["IF_MESSAGE","IF_MESSAGE"];
  static ATTRIBUTES = {"SQL_MESSAGE": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "visibility": "U", "is_constant": " ", "is_class": " "}};
  static METHODS = {"CONSTRUCTOR": {"visibility": "U", "parameters": {"TEXTID": {"type": () => {return new abap.types.Character(32, {});}, "is_optional": " "}, "SQL_MESSAGE": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "PREVIOUS": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "CX_ROOT", RTTIName: "\\CLASS=CX_ROOT"});}, "is_optional": " "}}}};
  constructor() {
    super();
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
    this.sql_message = new abap.types.String({qualifiedName: "STRING"});
  }
  async constructor_(INPUT) {
    let textid = new abap.types.Character(32, {});
    if (INPUT && INPUT.textid) {textid.set(INPUT.textid);}
    let sql_message = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.sql_message) {sql_message.set(INPUT.sql_message);}
    let previous = new abap.types.ABAPObject({qualifiedName: "CX_ROOT", RTTIName: "\\CLASS=CX_ROOT"});
    if (INPUT && INPUT.previous) {previous.set(INPUT.previous);}
    await super.constructor_({textid: textid, previous: previous});
    this.me.get().sql_message.set(sql_message);
    return this;
  }
}
abap.Classes['CX_SQL_EXCEPTION'] = cx_sql_exception;
export {cx_sql_exception};
//# sourceMappingURL=cx_sql_exception.clas.mjs.map