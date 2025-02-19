const {cx_sy_sql_error} = await import("./cx_sy_sql_error.clas.mjs");
const {cx_root} = await import("./cx_root.clas.mjs");
// cx_sy_open_sql_error.clas.abap
class cx_sy_open_sql_error extends cx_sy_sql_error {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CX_SY_OPEN_SQL_ERROR';
  static IMPLEMENTED_INTERFACES = ["IF_MESSAGE","IF_MESSAGE","IF_MESSAGE","IF_MESSAGE"];
  static ATTRIBUTES = {};
  static METHODS = {"CONSTRUCTOR": {"visibility": "U", "parameters": {"SQLMSG": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}}};
  constructor() {
    super();
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
  }
  async constructor_(INPUT) {
    let sqlmsg = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.sqlmsg) {sqlmsg.set(INPUT.sqlmsg);}
    await super.constructor_({sqlmsg: sqlmsg});
    return this;
  }
}
abap.Classes['CX_SY_OPEN_SQL_ERROR'] = cx_sy_open_sql_error;
export {cx_sy_open_sql_error};
//# sourceMappingURL=cx_sy_open_sql_error.clas.mjs.map