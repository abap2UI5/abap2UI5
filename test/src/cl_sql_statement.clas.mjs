const {cx_root} = await import("./cx_root.clas.mjs");
// cl_sql_statement.clas.abap
class cl_sql_statement {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CL_SQL_STATEMENT';
  static IMPLEMENTED_INTERFACES = [];
  static ATTRIBUTES = {"MV_CONNECTION": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "visibility": "I", "is_constant": " ", "is_class": " "}};
  static METHODS = {"CONSTRUCTOR": {"visibility": "U", "parameters": {"CON_REF": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "CL_SQL_CONNECTION", RTTIName: "\\CLASS=CL_SQL_CONNECTION"});}, "is_optional": " "}}},
  "EXECUTE_UPDATE": {"visibility": "U", "parameters": {"STATEMENT": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}},
  "EXECUTE_QUERY": {"visibility": "U", "parameters": {"RESULT_SET": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "CL_SQL_RESULT_SET", RTTIName: "\\CLASS=CL_SQL_RESULT_SET"});}, "is_optional": " "}, "STATEMENT": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}},
  "EXECUTE_DDL": {"visibility": "U", "parameters": {"STATEMENT": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}}};
  constructor() {
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
    this.mv_connection = new abap.types.String({qualifiedName: "STRING"});
  }
  async constructor_(INPUT) {
    let con_ref = new abap.types.ABAPObject({qualifiedName: "CL_SQL_CONNECTION", RTTIName: "\\CLASS=CL_SQL_CONNECTION"});
    if (INPUT && INPUT.con_ref) {con_ref.set(INPUT.con_ref);}
    if (abap.compare.initial(con_ref)) {
      this.mv_connection.set(new abap.types.Character(7).set('DEFAULT'));
    } else {
      this.mv_connection.set((await con_ref.get().get_con_name()));
    }
    abap.statements.assert(abap.compare.initial(this.mv_connection) === false);
    return this;
  }
  async execute_ddl(INPUT) {
    let statement = INPUT?.statement;
    if (statement?.getQualifiedName === undefined || statement.getQualifiedName() !== "STRING") { statement = undefined; }
    if (statement === undefined) { statement = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.statement); }
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(13).set('not supported')));
  }
  async execute_update(INPUT) {
    let statement = INPUT?.statement;
    if (statement?.getQualifiedName === undefined || statement.getQualifiedName() !== "STRING") { statement = undefined; }
    if (statement === undefined) { statement = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.statement); }
    let lv_sql_message = new abap.types.String({qualifiedName: "STRING"});
    abap.statements.assert(abap.compare.initial(statement) === false);
    if (abap.context.databaseConnections[this.mv_connection.get()] === undefined) {
      lv_sql_message.set(new abap.types.Character(19).set('not connected to db'));
    }
    if (abap.compare.initial(lv_sql_message) === false) {
      const unique14 = await (new abap.Classes['CX_SQL_EXCEPTION']()).constructor_();
      unique14.EXTRA_CX = {"INTERNAL_FILENAME": "cl_sql_statement.clas.abap","INTERNAL_LINE": 57};
      throw unique14;
    }
    try {
        await abap.context.databaseConnections[this.mv_connection.get()].execute(statement.get());
    } catch(e) {
        lv_sql_message.set(e + "");
    }
    if (abap.compare.initial(lv_sql_message) === false) {
      const unique15 = await (new abap.Classes['CX_SQL_EXCEPTION']()).constructor_();
      unique15.EXTRA_CX = {"INTERNAL_FILENAME": "cl_sql_statement.clas.abap","INTERNAL_LINE": 66};
      throw unique15;
    }
  }
  async execute_query(INPUT) {
    let result_set = new abap.types.ABAPObject({qualifiedName: "CL_SQL_RESULT_SET", RTTIName: "\\CLASS=CL_SQL_RESULT_SET"});
    let statement = INPUT?.statement;
    if (statement?.getQualifiedName === undefined || statement.getQualifiedName() !== "STRING") { statement = undefined; }
    if (statement === undefined) { statement = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.statement); }
    let lx_osql = new abap.types.ABAPObject({qualifiedName: "CX_SY_DYNAMIC_OSQL_SEMANTICS", RTTIName: "\\CLASS=CX_SY_DYNAMIC_OSQL_SEMANTICS"});
    let lv_sql_message = new abap.types.String({qualifiedName: "STRING"});
    abap.statements.assert(abap.compare.initial(statement) === false);
    abap.statements.assert(abap.compare.initial(this.mv_connection) === false);
    if (abap.context.databaseConnections[this.mv_connection.get()] === undefined) {
      lv_sql_message.set(new abap.types.Character(19).set('not connected to db'));
    }
    if (abap.compare.initial(lv_sql_message) === false) {
      const unique16 = await (new abap.Classes['CX_SQL_EXCEPTION']()).constructor_({sql_message: lv_sql_message});
      unique16.EXTRA_CX = {"INTERNAL_FILENAME": "cl_sql_statement.clas.abap","INTERNAL_LINE": 82};
      throw unique16;
    }
    result_set.set(await (new abap.Classes['CL_SQL_RESULT_SET']()).constructor_());
    try {
        const res = await abap.context.databaseConnections[this.mv_connection.get()].select({select: statement.get()});
        result_set.get().mv_magic = res.rows;
    } catch (e) {
      if ((abap.Classes['CX_SY_DYNAMIC_OSQL_SEMANTICS'] && e instanceof abap.Classes['CX_SY_DYNAMIC_OSQL_SEMANTICS'])) {
        lx_osql.set(e);
        const unique17 = await (new abap.Classes['CX_SQL_EXCEPTION']()).constructor_({sql_message: lx_osql.get().sqlmsg});
        unique17.EXTRA_CX = {"INTERNAL_FILENAME": "cl_sql_statement.clas.abap","INTERNAL_LINE": 92};
        throw unique17;
      } else {
        throw e;
      }
    }
    return result_set;
  }
}
abap.Classes['CL_SQL_STATEMENT'] = cl_sql_statement;
export {cl_sql_statement};
//# sourceMappingURL=cl_sql_statement.clas.mjs.map