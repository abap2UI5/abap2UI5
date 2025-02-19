const {cx_root} = await import("./cx_root.clas.mjs");
// kernel_unit_runner.clas.abap
class kernel_unit_runner {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'KERNEL_UNIT_RUNNER';
  static IMPLEMENTED_INTERFACES = [];
  static ATTRIBUTES = {"MV_CONSOLE": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "visibility": "U", "is_constant": " ", "is_class": "X"},
  "GC_STATUS": {"type": () => {return new abap.types.Structure({"success": new abap.types.String({qualifiedName: "KERNEL_UNIT_RUNNER=>TY_STATUS"}), "failed": new abap.types.String({qualifiedName: "KERNEL_UNIT_RUNNER=>TY_STATUS"}), "skipped": new abap.types.String({qualifiedName: "KERNEL_UNIT_RUNNER=>TY_STATUS"})}, undefined, undefined, {}, {});}, "visibility": "U", "is_constant": "X", "is_class": "X"}};
  static METHODS = {"UNIQUE_CLASSES": {"visibility": "I", "parameters": {"RT_CLASSES": {"type": () => {return abap.types.TableFactory.construct(new abap.types.Structure({"class_name": new abap.types.Character(30, {"qualifiedName":"kernel_unit_runner=>ty_class_item-class_name"}), "testclass_name": new abap.types.Character(30, {"qualifiedName":"kernel_unit_runner=>ty_class_item-testclass_name"})}, "kernel_unit_runner=>ty_class_item", undefined, {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "kernel_unit_runner=>ty_classes");}, "is_optional": " "}, "IT_INPUT": {"type": () => {return abap.types.TableFactory.construct(new abap.types.Structure({"class_name": new abap.types.Character(30, {"qualifiedName":"kernel_unit_runner=>ty_input_item-class_name"}), "testclass_name": new abap.types.Character(30, {"qualifiedName":"kernel_unit_runner=>ty_input_item-testclass_name"}), "method_name": new abap.types.Character(30, {"qualifiedName":"kernel_unit_runner=>ty_input_item-method_name"})}, "kernel_unit_runner=>ty_input_item", undefined, {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "kernel_unit_runner=>ty_input");}, "is_optional": " "}}},
  "TO_JSON": {"visibility": "I", "parameters": {"RV_JSON": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "IT_LIST": {"type": () => {return abap.types.TableFactory.construct(new abap.types.Structure({"class_name": new abap.types.Character(30, {"qualifiedName":"kernel_unit_runner=>ty_input_item-class_name"}), "testclass_name": new abap.types.Character(30, {"qualifiedName":"kernel_unit_runner=>ty_input_item-testclass_name"}), "method_name": new abap.types.Character(30, {"qualifiedName":"kernel_unit_runner=>ty_input_item-method_name"}), "expected": new abap.types.String({qualifiedName: "KERNEL_UNIT_RUNNER=>TY_RESULT_ITEM-EXPECTED"}), "actual": new abap.types.String({qualifiedName: "KERNEL_UNIT_RUNNER=>TY_RESULT_ITEM-ACTUAL"}), "status": new abap.types.String({qualifiedName: "KERNEL_UNIT_RUNNER=>TY_STATUS"}), "runtime": new abap.types.Integer({qualifiedName: "KERNEL_UNIT_RUNNER=>TY_RESULT_ITEM-RUNTIME"}), "message": new abap.types.String({qualifiedName: "KERNEL_UNIT_RUNNER=>TY_RESULT_ITEM-MESSAGE"}), "js_location": new abap.types.String({qualifiedName: "KERNEL_UNIT_RUNNER=>TY_RESULT_ITEM-JS_LOCATION"}), "console": new abap.types.String({qualifiedName: "KERNEL_UNIT_RUNNER=>TY_RESULT_ITEM-CONSOLE"})}, "kernel_unit_runner=>ty_result_item", undefined, {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "kernel_unit_runner=>ty_result-list");}, "is_optional": " "}}},
  "GET_LOCATION": {"visibility": "I", "parameters": {"RV_LOCATION": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "IX_ERROR": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "CX_ROOT", RTTIName: "\\CLASS=CX_ROOT"});}, "is_optional": " "}}},
  "RUN": {"visibility": "U", "parameters": {"RS_RESULT": {"type": () => {return new abap.types.Structure({"list": abap.types.TableFactory.construct(new abap.types.Structure({"class_name": new abap.types.Character(30, {"qualifiedName":"kernel_unit_runner=>ty_input_item-class_name"}), "testclass_name": new abap.types.Character(30, {"qualifiedName":"kernel_unit_runner=>ty_input_item-testclass_name"}), "method_name": new abap.types.Character(30, {"qualifiedName":"kernel_unit_runner=>ty_input_item-method_name"}), "expected": new abap.types.String({qualifiedName: "KERNEL_UNIT_RUNNER=>TY_RESULT_ITEM-EXPECTED"}), "actual": new abap.types.String({qualifiedName: "KERNEL_UNIT_RUNNER=>TY_RESULT_ITEM-ACTUAL"}), "status": new abap.types.String({qualifiedName: "KERNEL_UNIT_RUNNER=>TY_STATUS"}), "runtime": new abap.types.Integer({qualifiedName: "KERNEL_UNIT_RUNNER=>TY_RESULT_ITEM-RUNTIME"}), "message": new abap.types.String({qualifiedName: "KERNEL_UNIT_RUNNER=>TY_RESULT_ITEM-MESSAGE"}), "js_location": new abap.types.String({qualifiedName: "KERNEL_UNIT_RUNNER=>TY_RESULT_ITEM-JS_LOCATION"}), "console": new abap.types.String({qualifiedName: "KERNEL_UNIT_RUNNER=>TY_RESULT_ITEM-CONSOLE"})}, "kernel_unit_runner=>ty_result_item", undefined, {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "kernel_unit_runner=>ty_result-list"), "json": new abap.types.String({qualifiedName: "KERNEL_UNIT_RUNNER=>TY_RESULT-JSON"})}, "kernel_unit_runner=>ty_result", undefined, {}, {});}, "is_optional": " "}, "IT_INPUT": {"type": () => {return abap.types.TableFactory.construct(new abap.types.Structure({"class_name": new abap.types.Character(30, {"qualifiedName":"kernel_unit_runner=>ty_input_item-class_name"}), "testclass_name": new abap.types.Character(30, {"qualifiedName":"kernel_unit_runner=>ty_input_item-testclass_name"}), "method_name": new abap.types.Character(30, {"qualifiedName":"kernel_unit_runner=>ty_input_item-method_name"})}, "kernel_unit_runner=>ty_input_item", undefined, {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "kernel_unit_runner=>ty_input");}, "is_optional": " "}}}};
  constructor() {
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
    this.mv_console = kernel_unit_runner.mv_console;
    this.gc_status = kernel_unit_runner.gc_status;
  }
  async constructor_(INPUT) {
    if (super.constructor_) { await super.constructor_(INPUT); }
    return this;
  }
  async get_location(INPUT) {
    return kernel_unit_runner.get_location(INPUT);
  }
  static async get_location(INPUT) {
    let rv_location = new abap.types.String({qualifiedName: "STRING"});
    let ix_error = INPUT?.ix_error;
    if (ix_error?.getQualifiedName === undefined || ix_error.getQualifiedName() !== "CX_ROOT") { ix_error = undefined; }
    if (ix_error === undefined) { ix_error = new abap.types.ABAPObject({qualifiedName: "CX_ROOT", RTTIName: "\\CLASS=CX_ROOT"}).set(INPUT.ix_error); }
    let lv_stack = new abap.types.String({qualifiedName: "STRING"});
    let lt_lines = abap.types.TableFactory.construct(new abap.types.String({qualifiedName: "STRING"}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "");
    let lv_found = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    lv_stack.set(INPUT.ix_error.get().stack);
    abap.statements.split({source: lv_stack, at: new abap.types.String().set(`\n`), table: lt_lines});
    for await (const unique180 of abap.statements.loop(lt_lines)) {
      lv_stack.set(unique180);
      if (abap.compare.cp(lv_stack, new abap.types.Character(21).set('*cl_abap_unit_assert*'))) {
        lv_found.set(abap.builtin.abap_true);
        continue;
      } else if (abap.compare.eq(lv_found, abap.builtin.abap_true)) {
        abap.statements.replace({target: lv_stack, all: false, with: new abap.types.Character(1).set(''), of: new abap.types.String().set(`at `)});
        rv_location.set(abap.builtin.condense({val: lv_stack}));
        break;
      }
    }
    return rv_location;
  }
  async to_json(INPUT) {
    return kernel_unit_runner.to_json(INPUT);
  }
  static async to_json(INPUT) {
    let rv_json = new abap.types.String({qualifiedName: "STRING"});
    let it_list = INPUT?.it_list;
    if (it_list?.getQualifiedName === undefined || it_list.getQualifiedName() !== "KERNEL_UNIT_RUNNER=>TY_RESULT-LIST") { it_list = undefined; }
    if (it_list === undefined) { it_list = abap.types.TableFactory.construct(new abap.types.Structure({"class_name": new abap.types.Character(30, {"qualifiedName":"kernel_unit_runner=>ty_input_item-class_name"}), "testclass_name": new abap.types.Character(30, {"qualifiedName":"kernel_unit_runner=>ty_input_item-testclass_name"}), "method_name": new abap.types.Character(30, {"qualifiedName":"kernel_unit_runner=>ty_input_item-method_name"}), "expected": new abap.types.String({qualifiedName: "KERNEL_UNIT_RUNNER=>TY_RESULT_ITEM-EXPECTED"}), "actual": new abap.types.String({qualifiedName: "KERNEL_UNIT_RUNNER=>TY_RESULT_ITEM-ACTUAL"}), "status": new abap.types.String({qualifiedName: "KERNEL_UNIT_RUNNER=>TY_STATUS"}), "runtime": new abap.types.Integer({qualifiedName: "KERNEL_UNIT_RUNNER=>TY_RESULT_ITEM-RUNTIME"}), "message": new abap.types.String({qualifiedName: "KERNEL_UNIT_RUNNER=>TY_RESULT_ITEM-MESSAGE"}), "js_location": new abap.types.String({qualifiedName: "KERNEL_UNIT_RUNNER=>TY_RESULT_ITEM-JS_LOCATION"}), "console": new abap.types.String({qualifiedName: "KERNEL_UNIT_RUNNER=>TY_RESULT_ITEM-CONSOLE"})}, "kernel_unit_runner=>ty_result_item", undefined, {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "kernel_unit_runner=>ty_result-list").set(INPUT.it_list); }
    let ls_list = new abap.types.Structure({"class_name": new abap.types.Character(30, {"qualifiedName":"kernel_unit_runner=>ty_input_item-class_name"}), "testclass_name": new abap.types.Character(30, {"qualifiedName":"kernel_unit_runner=>ty_input_item-testclass_name"}), "method_name": new abap.types.Character(30, {"qualifiedName":"kernel_unit_runner=>ty_input_item-method_name"}), "expected": new abap.types.String({qualifiedName: "KERNEL_UNIT_RUNNER=>TY_RESULT_ITEM-EXPECTED"}), "actual": new abap.types.String({qualifiedName: "KERNEL_UNIT_RUNNER=>TY_RESULT_ITEM-ACTUAL"}), "status": new abap.types.String({qualifiedName: "KERNEL_UNIT_RUNNER=>TY_STATUS"}), "runtime": new abap.types.Integer({qualifiedName: "KERNEL_UNIT_RUNNER=>TY_RESULT_ITEM-RUNTIME"}), "message": new abap.types.String({qualifiedName: "KERNEL_UNIT_RUNNER=>TY_RESULT_ITEM-MESSAGE"}), "js_location": new abap.types.String({qualifiedName: "KERNEL_UNIT_RUNNER=>TY_RESULT_ITEM-JS_LOCATION"}), "console": new abap.types.String({qualifiedName: "KERNEL_UNIT_RUNNER=>TY_RESULT_ITEM-CONSOLE"})}, "kernel_unit_runner=>ty_result_item", undefined, {}, {});
    let lt_strings = abap.types.TableFactory.construct(new abap.types.String({qualifiedName: "STRING"}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "");
    let lv_string = new abap.types.String({qualifiedName: "STRING"});
    let lv_message = new abap.types.String({qualifiedName: "STRING"});
    for await (const unique181 of abap.statements.loop(it_list)) {
      ls_list.set(unique181);
      lv_message.set(ls_list.get().message);
      abap.statements.replace({target: lv_message, all: true, with: new abap.types.String().set(`\"`), of: new abap.types.String().set(`"`)});
      abap.statements.replace({target: lv_message, all: true, with: new abap.types.String().set(`\\n`), of: new abap.types.String().set(`\n`)});
      abap.statements.replace({target: ls_list.get().expected, all: true, with: new abap.types.String().set(`\"`), of: new abap.types.String().set(`"`)});
      abap.statements.replace({target: ls_list.get().expected, all: true, with: new abap.types.String().set(`\\n`), of: new abap.types.String().set(`\n`)});
      abap.statements.replace({target: ls_list.get().actual, all: true, with: new abap.types.String().set(`\"`), of: new abap.types.String().set(`"`)});
      abap.statements.replace({target: ls_list.get().actual, all: true, with: new abap.types.String().set(`\\n`), of: new abap.types.String().set(`\n`)});
      abap.statements.replace({target: ls_list.get().console, all: true, with: new abap.types.String().set(`\"`), of: new abap.types.String().set(`"`)});
      abap.statements.replace({target: ls_list.get().console, all: true, with: new abap.types.String().set(`\\n`), of: new abap.types.String().set(`\n`)});
      lv_string.set(new abap.types.String().set(`\{"class_name": "${abap.templateFormatting(ls_list.get().class_name)}","testclass_name": "${abap.templateFormatting(ls_list.get().testclass_name)}","method_name": "${abap.templateFormatting(ls_list.get().method_name)}","expected": "${abap.templateFormatting(ls_list.get().expected)}","actual": "${abap.templateFormatting(ls_list.get().actual)}","status": "${abap.templateFormatting(ls_list.get().status)}","runtime": ${abap.templateFormatting(ls_list.get().runtime)},"console": "${abap.templateFormatting(ls_list.get().console)}","message": "${abap.templateFormatting(lv_message)}","js_location": "${abap.templateFormatting(ls_list.get().js_location)}"\}`));
      abap.statements.append({source: lv_string, target: lt_strings});
    }
    abap.statements.concatenate({source: [lt_strings], target: rv_json, separatedBy: new abap.types.Character(1).set(','), lines: true});
    rv_json.set(abap.operators.concat(new abap.types.Character(1).set('['),abap.operators.concat(rv_json,new abap.types.Character(1).set(']'))));
    return rv_json;
  }
  async unique_classes(INPUT) {
    return kernel_unit_runner.unique_classes(INPUT);
  }
  static async unique_classes(INPUT) {
    let rt_classes = abap.types.TableFactory.construct(new abap.types.Structure({"class_name": new abap.types.Character(30, {"qualifiedName":"kernel_unit_runner=>ty_class_item-class_name"}), "testclass_name": new abap.types.Character(30, {"qualifiedName":"kernel_unit_runner=>ty_class_item-testclass_name"})}, "kernel_unit_runner=>ty_class_item", undefined, {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "kernel_unit_runner=>ty_classes");
    let it_input = INPUT?.it_input;
    if (it_input?.getQualifiedName === undefined || it_input.getQualifiedName() !== "KERNEL_UNIT_RUNNER=>TY_INPUT") { it_input = undefined; }
    if (it_input === undefined) { it_input = abap.types.TableFactory.construct(new abap.types.Structure({"class_name": new abap.types.Character(30, {"qualifiedName":"kernel_unit_runner=>ty_input_item-class_name"}), "testclass_name": new abap.types.Character(30, {"qualifiedName":"kernel_unit_runner=>ty_input_item-testclass_name"}), "method_name": new abap.types.Character(30, {"qualifiedName":"kernel_unit_runner=>ty_input_item-method_name"})}, "kernel_unit_runner=>ty_input_item", undefined, {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "kernel_unit_runner=>ty_input").set(INPUT.it_input); }
    let ls_input = new abap.types.Structure({"class_name": new abap.types.Character(30, {"qualifiedName":"kernel_unit_runner=>ty_input_item-class_name"}), "testclass_name": new abap.types.Character(30, {"qualifiedName":"kernel_unit_runner=>ty_input_item-testclass_name"}), "method_name": new abap.types.Character(30, {"qualifiedName":"kernel_unit_runner=>ty_input_item-method_name"})}, "kernel_unit_runner=>ty_input_item", undefined, {}, {});
    let ls_class = new abap.types.Structure({"class_name": new abap.types.Character(30, {"qualifiedName":"kernel_unit_runner=>ty_class_item-class_name"}), "testclass_name": new abap.types.Character(30, {"qualifiedName":"kernel_unit_runner=>ty_class_item-testclass_name"})}, "kernel_unit_runner=>ty_class_item", undefined, {}, {});
    for await (const unique182 of abap.statements.loop(it_input)) {
      ls_input.set(unique182);
      abap.statements.moveCorresponding(ls_input, ls_class);
      abap.statements.insertInternal({data: ls_class, table: rt_classes});
    }
    abap.statements.sort(rt_classes,{});
    await abap.statements.deleteInternal(rt_classes,{adjacent: true});
    return rt_classes;
  }
  async run(INPUT) {
    return kernel_unit_runner.run(INPUT);
  }
  static async run(INPUT) {
    let rs_result = new abap.types.Structure({"list": abap.types.TableFactory.construct(new abap.types.Structure({"class_name": new abap.types.Character(30, {"qualifiedName":"kernel_unit_runner=>ty_input_item-class_name"}), "testclass_name": new abap.types.Character(30, {"qualifiedName":"kernel_unit_runner=>ty_input_item-testclass_name"}), "method_name": new abap.types.Character(30, {"qualifiedName":"kernel_unit_runner=>ty_input_item-method_name"}), "expected": new abap.types.String({qualifiedName: "KERNEL_UNIT_RUNNER=>TY_RESULT_ITEM-EXPECTED"}), "actual": new abap.types.String({qualifiedName: "KERNEL_UNIT_RUNNER=>TY_RESULT_ITEM-ACTUAL"}), "status": new abap.types.String({qualifiedName: "KERNEL_UNIT_RUNNER=>TY_STATUS"}), "runtime": new abap.types.Integer({qualifiedName: "KERNEL_UNIT_RUNNER=>TY_RESULT_ITEM-RUNTIME"}), "message": new abap.types.String({qualifiedName: "KERNEL_UNIT_RUNNER=>TY_RESULT_ITEM-MESSAGE"}), "js_location": new abap.types.String({qualifiedName: "KERNEL_UNIT_RUNNER=>TY_RESULT_ITEM-JS_LOCATION"}), "console": new abap.types.String({qualifiedName: "KERNEL_UNIT_RUNNER=>TY_RESULT_ITEM-CONSOLE"})}, "kernel_unit_runner=>ty_result_item", undefined, {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "kernel_unit_runner=>ty_result-list"), "json": new abap.types.String({qualifiedName: "KERNEL_UNIT_RUNNER=>TY_RESULT-JSON"})}, "kernel_unit_runner=>ty_result", undefined, {}, {});
    let it_input = INPUT?.it_input;
    if (it_input?.getQualifiedName === undefined || it_input.getQualifiedName() !== "KERNEL_UNIT_RUNNER=>TY_INPUT") { it_input = undefined; }
    if (it_input === undefined) { it_input = abap.types.TableFactory.construct(new abap.types.Structure({"class_name": new abap.types.Character(30, {"qualifiedName":"kernel_unit_runner=>ty_input_item-class_name"}), "testclass_name": new abap.types.Character(30, {"qualifiedName":"kernel_unit_runner=>ty_input_item-testclass_name"}), "method_name": new abap.types.Character(30, {"qualifiedName":"kernel_unit_runner=>ty_input_item-method_name"})}, "kernel_unit_runner=>ty_input_item", undefined, {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "kernel_unit_runner=>ty_input").set(INPUT.it_input); }
    let ls_input = new abap.types.Structure({"class_name": new abap.types.Character(30, {"qualifiedName":"kernel_unit_runner=>ty_input_item-class_name"}), "testclass_name": new abap.types.Character(30, {"qualifiedName":"kernel_unit_runner=>ty_input_item-testclass_name"}), "method_name": new abap.types.Character(30, {"qualifiedName":"kernel_unit_runner=>ty_input_item-method_name"})}, "kernel_unit_runner=>ty_input_item", undefined, {}, {});
    let lv_time = new abap.types.Integer({qualifiedName: "I"});
    let lo_obj = new abap.types.ABAPObject({qualifiedName: undefined, RTTIName: undefined});
    let lv_name = new abap.types.String({qualifiedName: "STRING"});
    let lt_classes = abap.types.TableFactory.construct(new abap.types.Structure({"class_name": new abap.types.Character(30, {"qualifiedName":"kernel_unit_runner=>ty_class_item-class_name"}), "testclass_name": new abap.types.Character(30, {"qualifiedName":"kernel_unit_runner=>ty_class_item-testclass_name"})}, "kernel_unit_runner=>ty_class_item", undefined, {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "kernel_unit_runner=>ty_classes");
    let ls_class = new abap.types.Structure({"class_name": new abap.types.Character(30, {"qualifiedName":"kernel_unit_runner=>ty_class_item-class_name"}), "testclass_name": new abap.types.Character(30, {"qualifiedName":"kernel_unit_runner=>ty_class_item-testclass_name"})}, "kernel_unit_runner=>ty_class_item", undefined, {}, {});
    let lx_root = new abap.types.ABAPObject({qualifiedName: "CX_ROOT", RTTIName: "\\CLASS=CX_ROOT"});
    let lx_assert = new abap.types.ABAPObject({qualifiedName: "KERNEL_CX_ASSERT", RTTIName: "\\CLASS=KERNEL_CX_ASSERT"});
    let fs_ls_result_ = new abap.types.FieldSymbol(new abap.types.Structure({"class_name": new abap.types.Character(30, {"qualifiedName":"kernel_unit_runner=>ty_input_item-class_name"}), "testclass_name": new abap.types.Character(30, {"qualifiedName":"kernel_unit_runner=>ty_input_item-testclass_name"}), "method_name": new abap.types.Character(30, {"qualifiedName":"kernel_unit_runner=>ty_input_item-method_name"}), "expected": new abap.types.String({qualifiedName: "KERNEL_UNIT_RUNNER=>TY_RESULT_ITEM-EXPECTED"}), "actual": new abap.types.String({qualifiedName: "KERNEL_UNIT_RUNNER=>TY_RESULT_ITEM-ACTUAL"}), "status": new abap.types.String({qualifiedName: "KERNEL_UNIT_RUNNER=>TY_STATUS"}), "runtime": new abap.types.Integer({qualifiedName: "KERNEL_UNIT_RUNNER=>TY_RESULT_ITEM-RUNTIME"}), "message": new abap.types.String({qualifiedName: "KERNEL_UNIT_RUNNER=>TY_RESULT_ITEM-MESSAGE"}), "js_location": new abap.types.String({qualifiedName: "KERNEL_UNIT_RUNNER=>TY_RESULT_ITEM-JS_LOCATION"}), "console": new abap.types.String({qualifiedName: "KERNEL_UNIT_RUNNER=>TY_RESULT_ITEM-CONSOLE"})}, "kernel_unit_runner=>ty_result_item", undefined, {}, {}));
    lt_classes.set((await this.unique_classes({it_input: it_input})));
    for await (const unique183 of abap.statements.loop(lt_classes)) {
      ls_class.set(unique183);
      lv_name.set(new abap.types.String().set(`CLAS-${abap.templateFormatting(ls_class.get().class_name)}-${abap.templateFormatting(ls_class.get().testclass_name)}`));
      let unique184 = abap.Classes["CLAS-KERNEL_UNIT_RUNNER-"+lv_name.get().trimEnd()];
      if (unique184 === undefined) { unique184 = abap.Classes[lv_name.get().trimEnd()]; }
      if (unique184 === undefined) { throw new abap.Classes['CX_SY_CREATE_OBJECT_ERROR']; }
      lo_obj.set(await (new unique184()).constructor_());
      try {
        if (lo_obj.get().class_setup === undefined && abap.Classes['CX_SY_DYN_CALL_ILLEGAL_METHOD'.trimEnd()] === undefined) { throw "CX_SY_DYN_CALL_ILLEGAL_METHOD not found"; }
        if (lo_obj.get().class_setup === undefined) { throw new abap.Classes['CX_SY_DYN_CALL_ILLEGAL_METHOD'.trimEnd()](); }
        await lo_obj.get().class_setup();
      } catch (e) {
        if ((abap.Classes['CX_SY_DYN_CALL_ILLEGAL_METHOD'] && e instanceof abap.Classes['CX_SY_DYN_CALL_ILLEGAL_METHOD'])) {
        } else {
          throw e;
        }
      }
      for await (const unique185 of abap.statements.loop(it_input,{where: async (I) => {return abap.compare.eq(I.class_name, ls_class.get().class_name) && abap.compare.eq(I.testclass_name, ls_class.get().testclass_name);},topEquals: {"class_name": ls_class.get().class_name,"testclass_name": ls_class.get().testclass_name}})) {
        ls_input.set(unique185);
        fs_ls_result_.assign(rs_result.get().list.appendInitial());
        abap.statements.moveCorresponding(ls_input, fs_ls_result_);
        try {
          if (lo_obj.get().setup === undefined && abap.Classes['CX_SY_DYN_CALL_ILLEGAL_METHOD'.trimEnd()] === undefined) { throw "CX_SY_DYN_CALL_ILLEGAL_METHOD not found"; }
          if (lo_obj.get().setup === undefined) { throw new abap.Classes['CX_SY_DYN_CALL_ILLEGAL_METHOD'.trimEnd()](); }
          await lo_obj.get().setup();
        } catch (e) {
          if ((abap.Classes['CX_SY_DYN_CALL_ILLEGAL_METHOD'] && e instanceof abap.Classes['CX_SY_DYN_CALL_ILLEGAL_METHOD'])) {
          } else {
            throw e;
          }
        }
        abap.statements.getRunTime(lv_time);
        abap.statements.clear(kernel_unit_runner.mv_console);
        try {
          if (lo_obj.get()[ls_input.get().method_name.get().toLowerCase().trimEnd()] === undefined && abap.Classes['CX_SY_DYN_CALL_ILLEGAL_METHOD'.trimEnd()] === undefined) { throw "CX_SY_DYN_CALL_ILLEGAL_METHOD not found"; }
          if (lo_obj.get()[ls_input.get().method_name.get().toLowerCase().trimEnd()] === undefined) { throw new abap.Classes['CX_SY_DYN_CALL_ILLEGAL_METHOD'.trimEnd()](); }
          await lo_obj.get()[ls_input.get().method_name.get().toLowerCase().trimEnd()]();
          fs_ls_result_.get().status.set(kernel_unit_runner.gc_status.get().success);
          fs_ls_result_.get().console.set(kernel_unit_runner.mv_console);
        } catch (e) {
          if ((abap.Classes['KERNEL_CX_ASSERT'] && e instanceof abap.Classes['KERNEL_CX_ASSERT'])) {
            lx_assert.set(e);
            fs_ls_result_.get().status.set(kernel_unit_runner.gc_status.get().failed);
            fs_ls_result_.get().actual.set(lx_assert.get().actual);
            fs_ls_result_.get().expected.set(lx_assert.get().expected);
            fs_ls_result_.get().message.set(lx_assert.get().msg);
            fs_ls_result_.get().js_location.set((await this.get_location({ix_error: lx_assert})));
            fs_ls_result_.get().console.set(kernel_unit_runner.mv_console);
          } else if ((abap.Classes['CX_ROOT'] && e instanceof abap.Classes['CX_ROOT'])) {
            lx_root.set(e);
            fs_ls_result_.get().status.set(kernel_unit_runner.gc_status.get().failed);
            fs_ls_result_.get().message.set(new abap.types.String().set(`Some exception raised`));
            fs_ls_result_.get().js_location.set((await this.get_location({ix_error: lx_root})));
            fs_ls_result_.get().console.set(kernel_unit_runner.mv_console);
          } else {
            throw e;
          }
        }
        abap.statements.getRunTime(lv_time);
        fs_ls_result_.get().runtime.set(lv_time);
        try {
          if (lo_obj.get().teardown === undefined && abap.Classes['CX_SY_DYN_CALL_ILLEGAL_METHOD'.trimEnd()] === undefined) { throw "CX_SY_DYN_CALL_ILLEGAL_METHOD not found"; }
          if (lo_obj.get().teardown === undefined) { throw new abap.Classes['CX_SY_DYN_CALL_ILLEGAL_METHOD'.trimEnd()](); }
          await lo_obj.get().teardown();
        } catch (e) {
          if ((abap.Classes['CX_SY_DYN_CALL_ILLEGAL_METHOD'] && e instanceof abap.Classes['CX_SY_DYN_CALL_ILLEGAL_METHOD'])) {
          } else {
            throw e;
          }
        }
      }
      try {
        if (lo_obj.get().class_teardown === undefined && abap.Classes['CX_SY_DYN_CALL_ILLEGAL_METHOD'.trimEnd()] === undefined) { throw "CX_SY_DYN_CALL_ILLEGAL_METHOD not found"; }
        if (lo_obj.get().class_teardown === undefined) { throw new abap.Classes['CX_SY_DYN_CALL_ILLEGAL_METHOD'.trimEnd()](); }
        await lo_obj.get().class_teardown();
      } catch (e) {
        if ((abap.Classes['CX_SY_DYN_CALL_ILLEGAL_METHOD'] && e instanceof abap.Classes['CX_SY_DYN_CALL_ILLEGAL_METHOD'])) {
        } else {
          throw e;
        }
      }
    }
    rs_result.get().json.set((await this.to_json({it_list: rs_result.get().list})));
    return rs_result;
  }
}
abap.Classes['KERNEL_UNIT_RUNNER'] = kernel_unit_runner;
kernel_unit_runner.mv_console = new abap.types.String({qualifiedName: "STRING"});
kernel_unit_runner.gc_status = new abap.types.Structure({"success": new abap.types.String({qualifiedName: "KERNEL_UNIT_RUNNER=>TY_STATUS"}), "failed": new abap.types.String({qualifiedName: "KERNEL_UNIT_RUNNER=>TY_STATUS"}), "skipped": new abap.types.String({qualifiedName: "KERNEL_UNIT_RUNNER=>TY_STATUS"})}, undefined, undefined, {}, {});
kernel_unit_runner.gc_status.get().success.set('SUCCESS');
kernel_unit_runner.gc_status.get().failed.set('FAILED');
kernel_unit_runner.gc_status.get().skipped.set('SKIPPED');
kernel_unit_runner.ty_input_item = new abap.types.Structure({"class_name": new abap.types.Character(30, {"qualifiedName":"kernel_unit_runner=>ty_input_item-class_name"}), "testclass_name": new abap.types.Character(30, {"qualifiedName":"kernel_unit_runner=>ty_input_item-testclass_name"}), "method_name": new abap.types.Character(30, {"qualifiedName":"kernel_unit_runner=>ty_input_item-method_name"})}, "kernel_unit_runner=>ty_input_item", undefined, {}, {});
kernel_unit_runner.ty_input = abap.types.TableFactory.construct(new abap.types.Structure({"class_name": new abap.types.Character(30, {"qualifiedName":"kernel_unit_runner=>ty_input_item-class_name"}), "testclass_name": new abap.types.Character(30, {"qualifiedName":"kernel_unit_runner=>ty_input_item-testclass_name"}), "method_name": new abap.types.Character(30, {"qualifiedName":"kernel_unit_runner=>ty_input_item-method_name"})}, "kernel_unit_runner=>ty_input_item", undefined, {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "kernel_unit_runner=>ty_input");
kernel_unit_runner.ty_status = new abap.types.String({qualifiedName: "KERNEL_UNIT_RUNNER=>TY_STATUS"});
kernel_unit_runner.ty_result_item = new abap.types.Structure({"class_name": new abap.types.Character(30, {"qualifiedName":"kernel_unit_runner=>ty_input_item-class_name"}), "testclass_name": new abap.types.Character(30, {"qualifiedName":"kernel_unit_runner=>ty_input_item-testclass_name"}), "method_name": new abap.types.Character(30, {"qualifiedName":"kernel_unit_runner=>ty_input_item-method_name"}), "expected": new abap.types.String({qualifiedName: "KERNEL_UNIT_RUNNER=>TY_RESULT_ITEM-EXPECTED"}), "actual": new abap.types.String({qualifiedName: "KERNEL_UNIT_RUNNER=>TY_RESULT_ITEM-ACTUAL"}), "status": new abap.types.String({qualifiedName: "KERNEL_UNIT_RUNNER=>TY_STATUS"}), "runtime": new abap.types.Integer({qualifiedName: "KERNEL_UNIT_RUNNER=>TY_RESULT_ITEM-RUNTIME"}), "message": new abap.types.String({qualifiedName: "KERNEL_UNIT_RUNNER=>TY_RESULT_ITEM-MESSAGE"}), "js_location": new abap.types.String({qualifiedName: "KERNEL_UNIT_RUNNER=>TY_RESULT_ITEM-JS_LOCATION"}), "console": new abap.types.String({qualifiedName: "KERNEL_UNIT_RUNNER=>TY_RESULT_ITEM-CONSOLE"})}, "kernel_unit_runner=>ty_result_item", undefined, {}, {});
kernel_unit_runner.ty_result = new abap.types.Structure({"list": abap.types.TableFactory.construct(new abap.types.Structure({"class_name": new abap.types.Character(30, {"qualifiedName":"kernel_unit_runner=>ty_input_item-class_name"}), "testclass_name": new abap.types.Character(30, {"qualifiedName":"kernel_unit_runner=>ty_input_item-testclass_name"}), "method_name": new abap.types.Character(30, {"qualifiedName":"kernel_unit_runner=>ty_input_item-method_name"}), "expected": new abap.types.String({qualifiedName: "KERNEL_UNIT_RUNNER=>TY_RESULT_ITEM-EXPECTED"}), "actual": new abap.types.String({qualifiedName: "KERNEL_UNIT_RUNNER=>TY_RESULT_ITEM-ACTUAL"}), "status": new abap.types.String({qualifiedName: "KERNEL_UNIT_RUNNER=>TY_STATUS"}), "runtime": new abap.types.Integer({qualifiedName: "KERNEL_UNIT_RUNNER=>TY_RESULT_ITEM-RUNTIME"}), "message": new abap.types.String({qualifiedName: "KERNEL_UNIT_RUNNER=>TY_RESULT_ITEM-MESSAGE"}), "js_location": new abap.types.String({qualifiedName: "KERNEL_UNIT_RUNNER=>TY_RESULT_ITEM-JS_LOCATION"}), "console": new abap.types.String({qualifiedName: "KERNEL_UNIT_RUNNER=>TY_RESULT_ITEM-CONSOLE"})}, "kernel_unit_runner=>ty_result_item", undefined, {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "kernel_unit_runner=>ty_result-list"), "json": new abap.types.String({qualifiedName: "KERNEL_UNIT_RUNNER=>TY_RESULT-JSON"})}, "kernel_unit_runner=>ty_result", undefined, {}, {});
kernel_unit_runner.ty_class_item = new abap.types.Structure({"class_name": new abap.types.Character(30, {"qualifiedName":"kernel_unit_runner=>ty_class_item-class_name"}), "testclass_name": new abap.types.Character(30, {"qualifiedName":"kernel_unit_runner=>ty_class_item-testclass_name"})}, "kernel_unit_runner=>ty_class_item", undefined, {}, {});
kernel_unit_runner.ty_classes = abap.types.TableFactory.construct(new abap.types.Structure({"class_name": new abap.types.Character(30, {"qualifiedName":"kernel_unit_runner=>ty_class_item-class_name"}), "testclass_name": new abap.types.Character(30, {"qualifiedName":"kernel_unit_runner=>ty_class_item-testclass_name"})}, "kernel_unit_runner=>ty_class_item", undefined, {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "kernel_unit_runner=>ty_classes");
export {kernel_unit_runner};
//# sourceMappingURL=kernel_unit_runner.clas.mjs.map