const {cx_dynamic_check} = await import("./cx_dynamic_check.clas.mjs");
const {cx_root} = await import("./cx_root.clas.mjs");
// cx_sy_sql_error.clas.abap
class cx_sy_sql_error extends cx_dynamic_check {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CX_SY_SQL_ERROR';
  static IMPLEMENTED_INTERFACES = ["IF_MESSAGE","IF_MESSAGE"];
  static ATTRIBUTES = {"SQLMSG": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "visibility": "U", "is_constant": " ", "is_class": " "}};
  static METHODS = {"CONSTRUCTOR": {"visibility": "U", "parameters": {"SQLMSG": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}}};
  constructor() {
    super();
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
    this.sqlmsg = new abap.types.String({qualifiedName: "STRING"});
  }
  async constructor_(INPUT) {
    let sqlmsg = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.sqlmsg) {sqlmsg.set(INPUT.sqlmsg);}
    await super.constructor_();
    this.me.get().sqlmsg.set(sqlmsg);
    return this;
  }
}
abap.Classes['CX_SY_SQL_ERROR'] = cx_sy_sql_error;
export {cx_sy_sql_error};
//# sourceMappingURL=cx_sy_sql_error.clas.mjs.map