const {cx_root} = await import("./cx_root.clas.mjs");
// cl_sql_connection.clas.abap
class cl_sql_connection {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CL_SQL_CONNECTION';
  static IMPLEMENTED_INTERFACES = [];
  static ATTRIBUTES = {"MV_CON_NAME": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "visibility": "I", "is_constant": " ", "is_class": " "}};
  static METHODS = {"GET_CONNECTION": {"visibility": "U", "parameters": {"CONNECTION": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "CL_SQL_CONNECTION", RTTIName: "\\CLASS=CL_SQL_CONNECTION"});}, "is_optional": " "}, "CON_NAME": {"type": () => {return new abap.types.Character();}, "is_optional": " "}, "SHARABLE": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});}, "is_optional": " "}}},
  "GET_ABAP_CONNECTION": {"visibility": "U", "parameters": {"CONNECTION": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "CL_SQL_CONNECTION", RTTIName: "\\CLASS=CL_SQL_CONNECTION"});}, "is_optional": " "}, "CON_NAME": {"type": () => {return new abap.types.Character();}, "is_optional": " "}}},
  "CREATE_STATEMENT": {"visibility": "U", "parameters": {"STATEMENT": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "CL_SQL_STATEMENT", RTTIName: "\\CLASS=CL_SQL_STATEMENT"});}, "is_optional": " "}}},
  "GET_CON_NAME": {"visibility": "U", "parameters": {"CON_NAME": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}}};
  constructor() {
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
    this.mv_con_name = new abap.types.String({qualifiedName: "STRING"});
  }
  async constructor_(INPUT) {
    if (super.constructor_) { await super.constructor_(INPUT); }
    return this;
  }
  async get_con_name() {
    let con_name = new abap.types.String({qualifiedName: "STRING"});
    con_name.set(this.mv_con_name);
    return con_name;
  }
  async create_statement() {
    let statement = new abap.types.ABAPObject({qualifiedName: "CL_SQL_STATEMENT", RTTIName: "\\CLASS=CL_SQL_STATEMENT"});
    statement.set(await (new abap.Classes['CL_SQL_STATEMENT']()).constructor_({con_ref: this.me}));
    return statement;
  }
  async get_connection(INPUT) {
    return cl_sql_connection.get_connection(INPUT);
  }
  static async get_connection(INPUT) {
    let connection = new abap.types.ABAPObject({qualifiedName: "CL_SQL_CONNECTION", RTTIName: "\\CLASS=CL_SQL_CONNECTION"});
    let con_name = INPUT?.con_name;
    let sharable = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    if (INPUT && INPUT.sharable) {sharable.set(INPUT.sharable);}
    if (INPUT === undefined || INPUT.sharable === undefined) {sharable = abap.builtin.abap_false;}
    abap.statements.assert(abap.compare.eq(sharable, abap.builtin.abap_true));
    connection.set(await (new abap.Classes['CL_SQL_CONNECTION']()).constructor_());
    connection.get().mv_con_name.set(con_name);
    return connection;
  }
  async get_abap_connection(INPUT) {
    return cl_sql_connection.get_abap_connection(INPUT);
  }
  static async get_abap_connection(INPUT) {
    let connection = new abap.types.ABAPObject({qualifiedName: "CL_SQL_CONNECTION", RTTIName: "\\CLASS=CL_SQL_CONNECTION"});
    let con_name = INPUT?.con_name;
    connection.set((await this.get_connection({con_name: con_name, sharable: abap.builtin.abap_true})));
    return connection;
  }
}
abap.Classes['CL_SQL_CONNECTION'] = cl_sql_connection;
export {cl_sql_connection};
//# sourceMappingURL=cl_sql_connection.clas.mjs.map