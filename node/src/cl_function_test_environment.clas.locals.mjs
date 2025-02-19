const {cx_root} = await import("./cx_root.clas.mjs");
// cl_function_test_environment.clas.locals_imp.abap
class lcl_input_arguments {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CLAS-CL_FUNCTION_TEST_ENVIRONMENT-LCL_INPUT_ARGUMENTS';
  static IMPLEMENTED_INTERFACES = ["IF_FTD_INPUT_ARGUMENTS"];
  static ATTRIBUTES = {"MT_IMPORTING": {"type": () => {return abap.types.TableFactory.construct(new abap.types.Structure({"name": new abap.types.Character(30, {"qualifiedName":"abap_parmname"}), "value": new abap.types.DataReference(new abap.types.Character(4))}, "lcl_input_arguments=>ty_name_value", undefined, {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "");}, "visibility": "U", "is_constant": " ", "is_class": " "},
  "MT_TABLES": {"type": () => {return abap.types.TableFactory.construct(new abap.types.Structure({"name": new abap.types.Character(30, {"qualifiedName":"abap_parmname"}), "value": new abap.types.DataReference(new abap.types.Character(4))}, "lcl_input_arguments=>ty_name_value", undefined, {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "");}, "visibility": "U", "is_constant": " ", "is_class": " "}};
  static METHODS = {};
  constructor() {
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
    this.mt_importing = abap.types.TableFactory.construct(new abap.types.Structure({"name": new abap.types.Character(30, {"qualifiedName":"abap_parmname"}), "value": new abap.types.DataReference(new abap.types.Character(4))}, "lcl_input_arguments=>ty_name_value", undefined, {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "");
    this.mt_tables = abap.types.TableFactory.construct(new abap.types.Structure({"name": new abap.types.Character(30, {"qualifiedName":"abap_parmname"}), "value": new abap.types.DataReference(new abap.types.Character(4))}, "lcl_input_arguments=>ty_name_value", undefined, {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "");
  }
  async constructor_(INPUT) {
    if (super.constructor_) { await super.constructor_(INPUT); }
    return this;
  }
  async if_ftd_input_arguments$get_importing_parameter(INPUT) {
    let result = new abap.types.DataReference(new abap.types.Character(4));
    let name = INPUT?.name;
    if (name?.getQualifiedName === undefined || name.getQualifiedName() !== "ABAP_PARMNAME") { name = undefined; }
    if (name === undefined) { name = new abap.types.Character(30, {"qualifiedName":"abap_parmname"}).set(INPUT.name); }
    let ls_row = new abap.types.Structure({"name": new abap.types.Character(30, {"qualifiedName":"abap_parmname"}), "value": new abap.types.DataReference(new abap.types.Character(4))}, "lcl_input_arguments=>ty_name_value", undefined, {}, {});
    abap.statements.readTable(this.mt_importing,{into: ls_row,
      withKey: (i) => {return abap.compare.eq(i.name, name);},
      withKeyValue: [{key: (i) => {return i.name}, value: name}],
      usesTableLine: false,
      withKeySimple: {"name": name}});
    if (abap.compare.ne(abap.builtin.sy.get().subrc, abap.IntegerFactory.get(0))) {
      const unique174 = await (new abap.Classes['CX_FTD_PARAMETER_NOT_FOUND']()).constructor_();
      unique174.EXTRA_CX = {"INTERNAL_FILENAME": "cl_function_test_environment.clas.locals_imp.abap","INTERNAL_LINE": 19};
      throw unique174;
    }
    result.set(ls_row.get().value);
    return result;
  }
  async if_ftd_input_arguments$get_table_parameter(INPUT) {
    let result = new abap.types.DataReference(new abap.types.Character(4));
    let name = INPUT?.name;
    if (name?.getQualifiedName === undefined || name.getQualifiedName() !== "ABAP_PARMNAME") { name = undefined; }
    if (name === undefined) { name = new abap.types.Character(30, {"qualifiedName":"abap_parmname"}).set(INPUT.name); }
    let ls_row = new abap.types.Structure({"name": new abap.types.Character(30, {"qualifiedName":"abap_parmname"}), "value": new abap.types.DataReference(new abap.types.Character(4))}, "lcl_input_arguments=>ty_name_value", undefined, {}, {});
    abap.statements.readTable(this.mt_tables,{into: ls_row,
      withKey: (i) => {return abap.compare.eq(i.name, name);},
      withKeyValue: [{key: (i) => {return i.name}, value: name}],
      usesTableLine: false,
      withKeySimple: {"name": name}});
    if (abap.compare.ne(abap.builtin.sy.get().subrc, abap.IntegerFactory.get(0))) {
      const unique175 = await (new abap.Classes['CX_FTD_PARAMETER_NOT_FOUND']()).constructor_();
      unique175.EXTRA_CX = {"INTERNAL_FILENAME": "cl_function_test_environment.clas.locals_imp.abap","INTERNAL_LINE": 28};
      throw unique175;
    }
    result.set(ls_row.get().value);
    return result;
  }
}
abap.Classes['CLAS-CL_FUNCTION_TEST_ENVIRONMENT-LCL_INPUT_ARGUMENTS'] = lcl_input_arguments;
lcl_input_arguments.ty_name_value = new abap.types.Structure({"name": new abap.types.Character(30, {"qualifiedName":"abap_parmname"}), "value": new abap.types.DataReference(new abap.types.Character(4))}, "lcl_input_arguments=>ty_name_value", undefined, {}, {});
class lcl_invocation_result {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CLAS-CL_FUNCTION_TEST_ENVIRONMENT-LCL_INVOCATION_RESULT';
  static IMPLEMENTED_INTERFACES = ["IF_FTD_INVOCATION_RESULT","IF_FTD_OUTPUT_CONFIGURATION"];
  static ATTRIBUTES = {"MT_EXPORTING": {"type": () => {return abap.types.TableFactory.construct(new abap.types.Structure({"name": new abap.types.Character(30, {"qualifiedName":"abap_parmname"}), "value": new abap.types.DataReference(new abap.types.Character(4))}, "lcl_invocation_result=>ty_name_value", undefined, {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "");}, "visibility": "U", "is_constant": " ", "is_class": " "},
  "MT_TABLES": {"type": () => {return abap.types.TableFactory.construct(new abap.types.Structure({"name": new abap.types.Character(30, {"qualifiedName":"abap_parmname"}), "value": new abap.types.DataReference(new abap.types.Character(4))}, "lcl_invocation_result=>ty_name_value", undefined, {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "");}, "visibility": "U", "is_constant": " ", "is_class": " "}};
  static METHODS = {};
  constructor() {
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
    this.mt_exporting = abap.types.TableFactory.construct(new abap.types.Structure({"name": new abap.types.Character(30, {"qualifiedName":"abap_parmname"}), "value": new abap.types.DataReference(new abap.types.Character(4))}, "lcl_invocation_result=>ty_name_value", undefined, {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "");
    this.mt_tables = abap.types.TableFactory.construct(new abap.types.Structure({"name": new abap.types.Character(30, {"qualifiedName":"abap_parmname"}), "value": new abap.types.DataReference(new abap.types.Character(4))}, "lcl_invocation_result=>ty_name_value", undefined, {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "");
  }
  async constructor_(INPUT) {
    if (super.constructor_) { await super.constructor_(INPUT); }
    return this;
  }
  async if_ftd_invocation_result$get_output_configuration() {
    let result = new abap.types.ABAPObject({qualifiedName: "IF_FTD_OUTPUT_CONFIGURATION", RTTIName: "\\INTERFACE=IF_FTD_OUTPUT_CONFIGURATION"});
    result.set(this.me);
    return result;
  }
  async if_ftd_output_configuration$set_exporting_parameter(INPUT) {
    let self = new abap.types.ABAPObject({qualifiedName: "IF_FTD_OUTPUT_CONFIGURATION", RTTIName: "\\INTERFACE=IF_FTD_OUTPUT_CONFIGURATION"});
    let name = INPUT?.name;
    if (name?.getQualifiedName === undefined || name.getQualifiedName() !== "ABAP_PARMNAME") { name = undefined; }
    if (name === undefined) { name = new abap.types.Character(30, {"qualifiedName":"abap_parmname"}).set(INPUT.name); }
    let value = INPUT?.value;
    let ls_row = new abap.types.Structure({"name": new abap.types.Character(30, {"qualifiedName":"abap_parmname"}), "value": new abap.types.DataReference(new abap.types.Character(4))}, "lcl_invocation_result=>ty_name_value", undefined, {}, {});
    ls_row.get().name.set(name);
    ls_row.get().value.assign(value);
    abap.statements.insertInternal({data: ls_row, table: this.mt_exporting});
    self.set(this.me);
    return self;
  }
  async if_ftd_output_configuration$set_table_parameter(INPUT) {
    let self = new abap.types.ABAPObject({qualifiedName: "IF_FTD_OUTPUT_CONFIGURATION", RTTIName: "\\INTERFACE=IF_FTD_OUTPUT_CONFIGURATION"});
    let name = INPUT?.name;
    if (name?.getQualifiedName === undefined || name.getQualifiedName() !== "ABAP_PARMNAME") { name = undefined; }
    if (name === undefined) { name = new abap.types.Character(30, {"qualifiedName":"abap_parmname"}).set(INPUT.name); }
    let value = INPUT?.value;
    let ls_row = new abap.types.Structure({"name": new abap.types.Character(30, {"qualifiedName":"abap_parmname"}), "value": new abap.types.DataReference(new abap.types.Character(4))}, "lcl_invocation_result=>ty_name_value", undefined, {}, {});
    ls_row.get().name.set(name);
    ls_row.get().value.assign(value);
    abap.statements.insertInternal({data: ls_row, table: this.mt_tables});
    self.set(this.me);
    return self;
  }
}
abap.Classes['CLAS-CL_FUNCTION_TEST_ENVIRONMENT-LCL_INVOCATION_RESULT'] = lcl_invocation_result;
lcl_invocation_result.ty_name_value = new abap.types.Structure({"name": new abap.types.Character(30, {"qualifiedName":"abap_parmname"}), "value": new abap.types.DataReference(new abap.types.Character(4))}, "lcl_invocation_result=>ty_name_value", undefined, {}, {});
class lcl_invoker {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CLAS-CL_FUNCTION_TEST_ENVIRONMENT-LCL_INVOKER';
  static IMPLEMENTED_INTERFACES = [];
  static ATTRIBUTES = {};
  static METHODS = {"INVOKE": {"visibility": "U", "parameters": {"FMINPUT": {"type": () => {return new abap.types.Character(4);}, "is_optional": " "}, "ANSWER": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_FTD_INVOCATION_ANSWER", RTTIName: "\\INTERFACE=IF_FTD_INVOCATION_ANSWER"});}, "is_optional": " "}}}};
  constructor() {
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
  }
  async constructor_(INPUT) {
    if (super.constructor_) { await super.constructor_(INPUT); }
    return this;
  }
  async invoke(INPUT) {
    return lcl_invoker.invoke(INPUT);
  }
  static async invoke(INPUT) {
    let fminput = INPUT?.fminput;
    let answer = INPUT?.answer;
    if (answer?.getQualifiedName === undefined || answer.getQualifiedName() !== "IF_FTD_INVOCATION_ANSWER") { answer = undefined; }
    if (answer === undefined) { answer = new abap.types.ABAPObject({qualifiedName: "IF_FTD_INVOCATION_ANSWER", RTTIName: "\\INTERFACE=IF_FTD_INVOCATION_ANSWER"}).set(INPUT.answer); }
    let lo_result = new abap.types.ABAPObject({qualifiedName: "LCL_INVOCATION_RESULT", RTTIName: "\\CLASS-POOL=CL_FUNCTION_TEST_ENVIRONMENT\\CLASS=LCL_INVOCATION_RESULT"});
    let li_result = new abap.types.ABAPObject({qualifiedName: "IF_FTD_INVOCATION_RESULT", RTTIName: "\\INTERFACE=IF_FTD_INVOCATION_RESULT"});
    let lo_arguments = new abap.types.ABAPObject({qualifiedName: "LCL_INPUT_ARGUMENTS", RTTIName: "\\CLASS-POOL=CL_FUNCTION_TEST_ENVIRONMENT\\CLASS=LCL_INPUT_ARGUMENTS"});
    let li_arguments = new abap.types.ABAPObject({qualifiedName: "IF_FTD_INPUT_ARGUMENTS", RTTIName: "\\INTERFACE=IF_FTD_INPUT_ARGUMENTS"});
    let ls_exporting = new abap.types.Structure({"name": new abap.types.Character(30, {"qualifiedName":"abap_parmname"}), "value": new abap.types.DataReference(new abap.types.Character(4))}, "lcl_invocation_result=>ty_name_value", undefined, {}, {});
    let ls_importing = new abap.types.Structure({"name": new abap.types.Character(30, {"qualifiedName":"abap_parmname"}), "value": new abap.types.DataReference(new abap.types.Character(4))}, "lcl_input_arguments=>ty_name_value", undefined, {}, {});
    let ls_table = new abap.types.Structure({"name": new abap.types.Character(30, {"qualifiedName":"abap_parmname"}), "value": new abap.types.DataReference(new abap.types.Character(4))}, "lcl_input_arguments=>ty_name_value", undefined, {}, {});
    lo_result.set(await (new abap.Classes['CLAS-CL_FUNCTION_TEST_ENVIRONMENT-LCL_INVOCATION_RESULT']()).constructor_());
    li_result.set(lo_result);
    lo_arguments.set(await (new abap.Classes['CLAS-CL_FUNCTION_TEST_ENVIRONMENT-LCL_INPUT_ARGUMENTS']()).constructor_());
    li_arguments.set(lo_arguments);
    for (const importing in fminput?.exporting || []) {
        ls_importing.get().name.set(importing.toUpperCase());
        ls_importing.get().value.pointer = fminput.exporting[importing];
      abap.statements.insertInternal({data: ls_importing, table: lo_arguments.get().mt_importing});
    }
    for (const table in fminput?.tables || []) {
        ls_table.get().name.set(table.toUpperCase());
        ls_table.get().value.pointer = fminput.tables[table];
      abap.statements.insertInternal({data: ls_table, table: lo_arguments.get().mt_tables});
    }
    await answer.get().if_ftd_invocation_answer$answer({arguments: li_arguments, result: li_result});
    for await (const unique176 of abap.statements.loop(lo_result.get().mt_exporting)) {
      ls_exporting.set(unique176);
      fminput.importing[ls_exporting.get().name.get().toLowerCase().trimEnd()].set(ls_exporting.get().value.dereference());
    }
    for await (const unique177 of abap.statements.loop(lo_result.get().mt_tables)) {
      ls_table.set(unique177);
      fminput.tables[ls_table.get().name.get().toLowerCase().trimEnd()].set(ls_table.get().value.dereference());
    }
  }
}
abap.Classes['CLAS-CL_FUNCTION_TEST_ENVIRONMENT-LCL_INVOKER'] = lcl_invoker;
class lcl_double {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CLAS-CL_FUNCTION_TEST_ENVIRONMENT-LCL_DOUBLE';
  static IMPLEMENTED_INTERFACES = ["IF_FUNCTION_TESTDOUBLE","IF_FTD_INPUT_CONFIG_SETTER","IF_FTD_OUTPUT_CONFIG_SETTER"];
  static ATTRIBUTES = {"MV_NAME": {"type": () => {return new abap.types.Character(30, {"qualifiedName":"SXCO_FM_NAME","ddicName":"SXCO_FM_NAME","description":"Function module name"});}, "visibility": "I", "is_constant": " ", "is_class": " "}};
  static METHODS = {"CONSTRUCTOR": {"visibility": "U", "parameters": {"IV_NAME": {"type": () => {return new abap.types.Character(30, {"qualifiedName":"SXCO_FM_NAME","ddicName":"SXCO_FM_NAME","description":"Function module name"});}, "is_optional": " "}}}};
  constructor() {
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
    this.mv_name = new abap.types.Character(30, {"qualifiedName":"SXCO_FM_NAME","ddicName":"SXCO_FM_NAME","description":"Function module name"});
  }
  async constructor_(INPUT) {
    let iv_name = INPUT?.iv_name;
    if (iv_name?.getQualifiedName === undefined || iv_name.getQualifiedName() !== "SXCO_FM_NAME") { iv_name = undefined; }
    if (iv_name === undefined) { iv_name = new abap.types.Character(30, {"qualifiedName":"SXCO_FM_NAME","ddicName":"SXCO_FM_NAME","description":"Function module name"}).set(INPUT.iv_name); }
    abap.statements.assert(abap.compare.initial(iv_name) === false);
    this.mv_name.set(iv_name);
    return this;
  }
  async if_function_testdouble$configure_call() {
    let input_configuration_setter = new abap.types.ABAPObject({qualifiedName: "IF_FTD_INPUT_CONFIG_SETTER", RTTIName: "\\INTERFACE=IF_FTD_INPUT_CONFIG_SETTER"});
    input_configuration_setter.set(this.me);
    return input_configuration_setter;
  }
  async if_ftd_input_config_setter$ignore_all_parameters() {
    let output_configuration_setter = new abap.types.ABAPObject({qualifiedName: "IF_FTD_OUTPUT_CONFIG_SETTER", RTTIName: "\\INTERFACE=IF_FTD_OUTPUT_CONFIG_SETTER"});
    output_configuration_setter.set(this.me);
    return output_configuration_setter;
  }
  async if_ftd_output_config_setter$then_answer(INPUT) {
    let self = new abap.types.ABAPObject({qualifiedName: "IF_FTD_OUTPUT_CONFIG_SETTER", RTTIName: "\\INTERFACE=IF_FTD_OUTPUT_CONFIG_SETTER"});
    let answer = INPUT?.answer;
    if (answer?.getQualifiedName === undefined || answer.getQualifiedName() !== "IF_FTD_INVOCATION_ANSWER") { answer = undefined; }
    if (answer === undefined) { answer = new abap.types.ABAPObject({qualifiedName: "IF_FTD_INVOCATION_ANSWER", RTTIName: "\\INTERFACE=IF_FTD_INVOCATION_ANSWER"}).set(INPUT.answer); }
    abap.FunctionModules[this.mv_name.get().trimEnd()] = (INPUT) => lcl_invoker.invoke({fminput: INPUT, answer});
    return self;
  }
}
abap.Classes['CLAS-CL_FUNCTION_TEST_ENVIRONMENT-LCL_DOUBLE'] = lcl_double;
export {lcl_input_arguments, lcl_invocation_result, lcl_invoker, lcl_double};
//# sourceMappingURL=cl_function_test_environment.clas.locals.mjs.map