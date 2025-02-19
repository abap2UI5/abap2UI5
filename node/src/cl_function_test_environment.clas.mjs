await import("./cl_function_test_environment.clas.locals.mjs");
const {cx_root} = await import("./cx_root.clas.mjs");
// cl_function_test_environment.clas.abap
class cl_function_test_environment {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CL_FUNCTION_TEST_ENVIRONMENT';
  static IMPLEMENTED_INTERFACES = ["IF_FUNCTION_TEST_ENVIRONMENT"];
  static ATTRIBUTES = {"GT_BACKUP": {"type": () => {return abap.types.TableFactory.construct(new abap.types.Structure({"name": new abap.types.Character(30, {"qualifiedName":"SXCO_FM_NAME","ddicName":"SXCO_FM_NAME","description":"Function module name"}), "backup": new abap.types.Integer({qualifiedName: "CL_FUNCTION_TEST_ENVIRONMENT=>TY_BACKUP-BACKUP"}), "double": new abap.types.ABAPObject({qualifiedName: "IF_FUNCTION_TESTDOUBLE", RTTIName: "\\INTERFACE=IF_FUNCTION_TESTDOUBLE"})}, "cl_function_test_environment=>ty_backup", undefined, {}, {}), {"withHeader":false,"keyType":"USER","primaryKey":{"name":"primary_key","type":"SORTED","isUnique":true,"keyFields":["NAME"]},"secondary":[]}, "");}, "visibility": "I", "is_constant": " ", "is_class": "X"}};
  static METHODS = {"CREATE": {"visibility": "U", "parameters": {"FUNCTION_TEST_ENVIRONMENT": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_FUNCTION_TEST_ENVIRONMENT", RTTIName: "\\INTERFACE=IF_FUNCTION_TEST_ENVIRONMENT"});}, "is_optional": " "}, "FUNCTION_MODULES": {"type": () => {return abap.types.TableFactory.construct(new abap.types.Character(30, {"qualifiedName":"SXCO_FM_NAME","ddicName":"SXCO_FM_NAME","description":"Function module name"}), {"withHeader":false,"keyType":"USER","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":["TABLE_LINE"]},"secondary":[]}, "if_function_test_environment=>tt_function_dependencies");}, "is_optional": " "}}}};
  constructor() {
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
    this.gt_backup = cl_function_test_environment.gt_backup;
  }
  async constructor_(INPUT) {
    if (super.constructor_) { await super.constructor_(INPUT); }
    return this;
  }
  async create(INPUT) {
    return cl_function_test_environment.create(INPUT);
  }
  static async create(INPUT) {
    let function_test_environment = new abap.types.ABAPObject({qualifiedName: "IF_FUNCTION_TEST_ENVIRONMENT", RTTIName: "\\INTERFACE=IF_FUNCTION_TEST_ENVIRONMENT"});
    let function_modules = INPUT?.function_modules;
    if (function_modules?.getQualifiedName === undefined || function_modules.getQualifiedName() !== "IF_FUNCTION_TEST_ENVIRONMENT=>TT_FUNCTION_DEPENDENCIES") { function_modules = undefined; }
    if (function_modules === undefined) { function_modules = abap.types.TableFactory.construct(new abap.types.Character(30, {"qualifiedName":"SXCO_FM_NAME","ddicName":"SXCO_FM_NAME","description":"Function module name"}), {"withHeader":false,"keyType":"USER","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":["TABLE_LINE"]},"secondary":[]}, "if_function_test_environment=>tt_function_dependencies").set(INPUT.function_modules); }
    let lv_module = new abap.types.Character(30, {"qualifiedName":"SXCO_FM_NAME","ddicName":"SXCO_FM_NAME","description":"Function module name"});
    let ls_row = new abap.types.Structure({"name": new abap.types.Character(30, {"qualifiedName":"SXCO_FM_NAME","ddicName":"SXCO_FM_NAME","description":"Function module name"}), "backup": new abap.types.Integer({qualifiedName: "CL_FUNCTION_TEST_ENVIRONMENT=>TY_BACKUP-BACKUP"}), "double": new abap.types.ABAPObject({qualifiedName: "IF_FUNCTION_TESTDOUBLE", RTTIName: "\\INTERFACE=IF_FUNCTION_TESTDOUBLE"})}, "cl_function_test_environment=>ty_backup", undefined, {}, {});
    abap.statements.assert(abap.compare.gt(abap.builtin.lines({val: function_modules}), abap.IntegerFactory.get(0)));
    for await (const unique178 of abap.statements.loop(function_modules)) {
      lv_module.set(unique178);
      ls_row.get().name.set(lv_module);
      ls_row.get().double.set(await (new abap.Classes['CLAS-CL_FUNCTION_TEST_ENVIRONMENT-LCL_DOUBLE']()).constructor_({iv_name: lv_module}));
      ls_row.get().backup = abap.FunctionModules[lv_module.get().trimEnd()];
      abap.statements.insertInternal({data: ls_row, table: cl_function_test_environment.gt_backup});
    }
    function_test_environment.set(await (new abap.Classes['CL_FUNCTION_TEST_ENVIRONMENT']()).constructor_());
    return function_test_environment;
  }
  async if_function_test_environment$get_double(INPUT) {
    let result = new abap.types.ABAPObject({qualifiedName: "IF_FUNCTION_TESTDOUBLE", RTTIName: "\\INTERFACE=IF_FUNCTION_TESTDOUBLE"});
    let function_name = INPUT?.function_name;
    if (function_name?.getQualifiedName === undefined || function_name.getQualifiedName() !== "SXCO_FM_NAME") { function_name = undefined; }
    if (function_name === undefined) { function_name = new abap.types.Character(30, {"qualifiedName":"SXCO_FM_NAME","ddicName":"SXCO_FM_NAME","description":"Function module name"}).set(INPUT.function_name); }
    let fs_ls_row_ = new abap.types.FieldSymbol(new abap.types.Structure({"name": new abap.types.Character(30, {"qualifiedName":"SXCO_FM_NAME","ddicName":"SXCO_FM_NAME","description":"Function module name"}), "backup": new abap.types.Integer({qualifiedName: "CL_FUNCTION_TEST_ENVIRONMENT=>TY_BACKUP-BACKUP"}), "double": new abap.types.ABAPObject({qualifiedName: "IF_FUNCTION_TESTDOUBLE", RTTIName: "\\INTERFACE=IF_FUNCTION_TESTDOUBLE"})}, "cl_function_test_environment=>ty_backup", undefined, {}, {}));
    abap.statements.readTable(cl_function_test_environment.gt_backup,{assigning: fs_ls_row_,
      withKey: (i) => {return abap.compare.eq(i.name, function_name);},
      withKeyValue: [{key: (i) => {return i.name}, value: function_name}],
      usesTableLine: false,
      withKeySimple: {"name": function_name}});
    abap.statements.assert(abap.compare.eq(abap.builtin.sy.get().subrc, abap.IntegerFactory.get(0)));
    result.set(fs_ls_row_.get().double);
    return result;
  }
  async if_function_test_environment$clear_doubles() {
    let fs_ls_row_ = new abap.types.FieldSymbol(new abap.types.Structure({"name": new abap.types.Character(30, {"qualifiedName":"SXCO_FM_NAME","ddicName":"SXCO_FM_NAME","description":"Function module name"}), "backup": new abap.types.Integer({qualifiedName: "CL_FUNCTION_TEST_ENVIRONMENT=>TY_BACKUP-BACKUP"}), "double": new abap.types.ABAPObject({qualifiedName: "IF_FUNCTION_TESTDOUBLE", RTTIName: "\\INTERFACE=IF_FUNCTION_TESTDOUBLE"})}, "cl_function_test_environment=>ty_backup", undefined, {}, {}));
    for await (const unique179 of abap.statements.loop(cl_function_test_environment.gt_backup)) {
      fs_ls_row_.assign(unique179);
      abap.FunctionModules[fs_ls_row_.get().name.get().trimEnd()] = fs_ls_row_.get().backup;
    }
    abap.statements.clear(cl_function_test_environment.gt_backup);
  }
}
abap.Classes['CL_FUNCTION_TEST_ENVIRONMENT'] = cl_function_test_environment;
cl_function_test_environment.gt_backup = abap.types.TableFactory.construct(new abap.types.Structure({"name": new abap.types.Character(30, {"qualifiedName":"SXCO_FM_NAME","ddicName":"SXCO_FM_NAME","description":"Function module name"}), "backup": new abap.types.Integer({qualifiedName: "CL_FUNCTION_TEST_ENVIRONMENT=>TY_BACKUP-BACKUP"}), "double": new abap.types.ABAPObject({qualifiedName: "IF_FUNCTION_TESTDOUBLE", RTTIName: "\\INTERFACE=IF_FUNCTION_TESTDOUBLE"})}, "cl_function_test_environment=>ty_backup", undefined, {}, {}), {"withHeader":false,"keyType":"USER","primaryKey":{"name":"primary_key","type":"SORTED","isUnique":true,"keyFields":["NAME"]},"secondary":[]}, "");
cl_function_test_environment.ty_backup = new abap.types.Structure({"name": new abap.types.Character(30, {"qualifiedName":"SXCO_FM_NAME","ddicName":"SXCO_FM_NAME","description":"Function module name"}), "backup": new abap.types.Integer({qualifiedName: "CL_FUNCTION_TEST_ENVIRONMENT=>TY_BACKUP-BACKUP"}), "double": new abap.types.ABAPObject({qualifiedName: "IF_FUNCTION_TESTDOUBLE", RTTIName: "\\INTERFACE=IF_FUNCTION_TESTDOUBLE"})}, "cl_function_test_environment=>ty_backup", undefined, {}, {});
export {cl_function_test_environment};
//# sourceMappingURL=cl_function_test_environment.clas.mjs.map