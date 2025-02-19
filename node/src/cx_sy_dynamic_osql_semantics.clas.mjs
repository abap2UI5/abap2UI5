const {cx_sy_dynamic_osql_error} = await import("./cx_sy_dynamic_osql_error.clas.mjs");
const {cx_root} = await import("./cx_root.clas.mjs");
// cx_sy_dynamic_osql_semantics.clas.abap
class cx_sy_dynamic_osql_semantics extends cx_sy_dynamic_osql_error {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CX_SY_DYNAMIC_OSQL_SEMANTICS';
  static IMPLEMENTED_INTERFACES = ["IF_MESSAGE","IF_MESSAGE","IF_MESSAGE","IF_MESSAGE","IF_MESSAGE","IF_MESSAGE","IF_MESSAGE","IF_MESSAGE","IF_MESSAGE","IF_MESSAGE","IF_MESSAGE","IF_MESSAGE","IF_MESSAGE","IF_MESSAGE","IF_MESSAGE","IF_MESSAGE"];
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
abap.Classes['CX_SY_DYNAMIC_OSQL_SEMANTICS'] = cx_sy_dynamic_osql_semantics;
export {cx_sy_dynamic_osql_semantics};
//# sourceMappingURL=cx_sy_dynamic_osql_semantics.clas.mjs.map