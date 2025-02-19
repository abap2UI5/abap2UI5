const {cx_root} = await import("./cx_root.clas.mjs");
// cl_osql_test_environment.clas.abap
class cl_osql_test_environment {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CL_OSQL_TEST_ENVIRONMENT';
  static IMPLEMENTED_INTERFACES = ["IF_OSQL_TEST_ENVIRONMENT"];
  static ATTRIBUTES = {"MT_TABLES": {"type": () => {return abap.types.TableFactory.construct(new abap.types.Character(30, {"qualifiedName":"abap_compname"}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "if_osql_test_environment=>ty_t_sobjnames");}, "visibility": "I", "is_constant": " ", "is_class": " "},
  "MO_SQL": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "CL_SQL_STATEMENT", RTTIName: "\\CLASS=CL_SQL_STATEMENT"});}, "visibility": "I", "is_constant": " ", "is_class": " "},
  "MV_SCHEMA": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "visibility": "I", "is_constant": "X", "is_class": "X"}};
  static METHODS = {"INITIALIZE": {"visibility": "I", "parameters": {}},
  "VALIDATE": {"visibility": "I", "parameters": {}},
  "SET_RUNTIME_PREFIX": {"visibility": "I", "parameters": {}},
  "CREATE": {"visibility": "U", "parameters": {"R_RESULT": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_OSQL_TEST_ENVIRONMENT", RTTIName: "\\INTERFACE=IF_OSQL_TEST_ENVIRONMENT"});}, "is_optional": " "}, "I_DEPENDENCY_LIST": {"type": () => {return abap.types.TableFactory.construct(new abap.types.Character(30, {"qualifiedName":"abap_compname"}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "if_osql_test_environment=>ty_t_sobjnames");}, "is_optional": " "}}}};
  constructor() {
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
    this.mt_tables = abap.types.TableFactory.construct(new abap.types.Character(30, {"qualifiedName":"abap_compname"}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "if_osql_test_environment=>ty_t_sobjnames");
    this.mo_sql = new abap.types.ABAPObject({qualifiedName: "CL_SQL_STATEMENT", RTTIName: "\\CLASS=CL_SQL_STATEMENT"});
    this.mv_schema = cl_osql_test_environment.mv_schema;
  }
  async constructor_(INPUT) {
    if (super.constructor_) { await super.constructor_(INPUT); }
    return this;
  }
  async create(INPUT) {
    return cl_osql_test_environment.create(INPUT);
  }
  static async create(INPUT) {
    let r_result = new abap.types.ABAPObject({qualifiedName: "IF_OSQL_TEST_ENVIRONMENT", RTTIName: "\\INTERFACE=IF_OSQL_TEST_ENVIRONMENT"});
    let i_dependency_list = INPUT?.i_dependency_list;
    if (i_dependency_list?.getQualifiedName === undefined || i_dependency_list.getQualifiedName() !== "IF_OSQL_TEST_ENVIRONMENT=>TY_T_SOBJNAMES") { i_dependency_list = undefined; }
    if (i_dependency_list === undefined) { i_dependency_list = abap.types.TableFactory.construct(new abap.types.Character(30, {"qualifiedName":"abap_compname"}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "if_osql_test_environment=>ty_t_sobjnames").set(INPUT.i_dependency_list); }
    let lo_env = new abap.types.ABAPObject({qualifiedName: "CL_OSQL_TEST_ENVIRONMENT", RTTIName: "\\CLASS=CL_OSQL_TEST_ENVIRONMENT"});
    abap.statements.assert(abap.compare.eq(abap.builtin.sy.get().dbsys, new abap.types.Character(6).set('sqlite')));
    lo_env.set(await (new abap.Classes['CL_OSQL_TEST_ENVIRONMENT']()).constructor_());
    lo_env.get().mt_tables.set(i_dependency_list);
    lo_env.get().mo_sql.set(await (new abap.Classes['CL_SQL_STATEMENT']()).constructor_());
    await lo_env.get().initialize();
    r_result.set(lo_env);
    return r_result;
  }
  async validate() {
    let ref = new abap.types.DataReference(new abap.types.Character(4));
    let lv_table = new abap.types.Character(30, {"qualifiedName":"abap_compname"});
    let fs_fs_ = new abap.types.FieldSymbol(new abap.types.Character(4));
    for await (const unique186 of abap.statements.loop(this.mt_tables)) {
      lv_table.set(unique186);
      try {
        abap.statements.createData(ref,{"name": lv_table.get()});
        abap.statements.assign({target: fs_fs_, source: ref.dereference()});
        await abap.statements.select(fs_fs_, {select: "SELECT * FROM " + abap.buildDbTableName(lv_table.get().trimEnd().toLowerCase()) + " UP TO 1 ROWS"});
      } catch (e) {
        if ((abap.Classes['CX_SY_CREATE_DATA_ERROR'] && e instanceof abap.Classes['CX_SY_CREATE_DATA_ERROR']) || (abap.Classes['CX_SY_DYNAMIC_OSQL_SEMANTICS'] && e instanceof abap.Classes['CX_SY_DYNAMIC_OSQL_SEMANTICS'])) {
          throw new Error(`table ${lv_table.get().trimEnd()} invalid or does not exist`);
        } else {
          throw e;
        }
      }
    }
  }
  async initialize() {
    let lv_table = new abap.types.Character(30, {"qualifiedName":"abap_compname"});
    let lv_sql = new abap.types.String({qualifiedName: "STRING"});
    let lo_result = new abap.types.ABAPObject({qualifiedName: "CL_SQL_RESULT_SET", RTTIName: "\\CLASS=CL_SQL_RESULT_SET"});
    let lr_ref = new abap.types.DataReference(new abap.types.Character(4));
    if (abap.dbo.schemaPrefix !== "") throw new Error("already prefixed");
    await this.validate();
    await this.mo_sql.get().execute_update({statement: new abap.types.String().set(`ATTACH DATABASE ':memory:' AS ${abap.templateFormatting(cl_osql_test_environment.mv_schema)};`)});
    for await (const unique187 of abap.statements.loop(this.mt_tables)) {
      lv_table.set(unique187);
      lv_table.set(abap.builtin.to_lower({val: lv_table}));
      lo_result.set((await this.mo_sql.get().execute_query({statement: new abap.types.String().set(`SELECT sql FROM main.sqlite_master WHERE type='table' AND name='${abap.templateFormatting(lv_table)}';`)})));
      lr_ref.assign(lv_sql);
      await lo_result.get().set_param({data_ref: lr_ref});
      await lo_result.get().next();
      await lo_result.get().close();
      abap.statements.replace({target: lv_sql, all: false, with: new abap.types.String().set(`${abap.templateFormatting(cl_osql_test_environment.mv_schema)}'.'${abap.templateFormatting(lv_table)}`), of: lv_table});
      abap.statements.assert(abap.compare.eq(abap.builtin.sy.get().subrc, abap.IntegerFactory.get(0)));
      await this.mo_sql.get().execute_update({statement: lv_sql});
    }
    await this.set_runtime_prefix();
  }
  async set_runtime_prefix() {
    abap.dbo.schemaPrefix = this.mv_schema.get();
  }
  async if_osql_test_environment$clear_doubles() {
    let lv_table = new abap.types.Character(30, {"qualifiedName":"abap_compname"});
    for await (const unique188 of abap.statements.loop(this.mt_tables)) {
      lv_table.set(unique188);
      lv_table.set(abap.builtin.to_lower({val: lv_table}));
      await this.mo_sql.get().execute_update({statement: new abap.types.String().set(`DELETE FROM ${abap.templateFormatting(cl_osql_test_environment.mv_schema)}."${abap.templateFormatting(lv_table)}";`)});
    }
  }
  async if_osql_test_environment$destroy() {
    await this.mo_sql.get().execute_update({statement: new abap.types.String().set(`DETACH DATABASE ${abap.templateFormatting(cl_osql_test_environment.mv_schema)};`)});
    abap.dbo.schemaPrefix = "";
  }
  async if_osql_test_environment$insert_test_data(INPUT) {
    let i_data = INPUT?.i_data;
    let lo_table_descr = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_TABLEDESCR", RTTIName: "\\CLASS=CL_ABAP_TABLEDESCR"});
    let lo_struct_descr = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_STRUCTDESCR", RTTIName: "\\CLASS=CL_ABAP_STRUCTDESCR"});
    let lv_table = new abap.types.String({qualifiedName: "STRING"});
    await abap.statements.cast(lo_table_descr, (await abap.Classes['CL_ABAP_TYPEDESCR'].describe_by_data({p_data: i_data})));
    await abap.statements.cast(lo_struct_descr, (await lo_table_descr.get().get_table_line_type()));
    lv_table.set((await lo_struct_descr.get().get_relative_name()));
    abap.statements.assert(abap.compare.initial(lv_table) === false);
    abap.statements.readTable(this.mt_tables,{withKey: (i) => {return abap.compare.eq(i.table_line, lv_table);},
      withKeyValue: [{key: (i) => {return i.table_line}, value: lv_table}],
      usesTableLine: true,
      withKeySimple: {"table_line": lv_table}});
    abap.statements.assert(abap.compare.eq(abap.builtin.sy.get().subrc, abap.IntegerFactory.get(0)));
    await abap.statements.insertDatabase(lv_table.get().trimEnd().toLowerCase(), {"table": i_data});
    abap.statements.assert(abap.compare.eq(abap.builtin.sy.get().subrc, abap.IntegerFactory.get(0)));
  }
}
abap.Classes['CL_OSQL_TEST_ENVIRONMENT'] = cl_osql_test_environment;
cl_osql_test_environment.mv_schema = new abap.types.String({qualifiedName: "STRING"});
cl_osql_test_environment.mv_schema.set('double');
export {cl_osql_test_environment};
//# sourceMappingURL=cl_osql_test_environment.clas.mjs.map