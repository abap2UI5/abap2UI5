const {cx_root} = await import("./cx_root.clas.mjs");
// #ui2#cl_json.clas.locals_imp.abap
class lcl_stack {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CLAS-/UI2/CL_JSON-LCL_STACK';
  static IMPLEMENTED_INTERFACES = [];
  static ATTRIBUTES = {"MT_STACK": {"type": () => {return abap.types.TableFactory.construct(new abap.types.Structure({"name": new abap.types.String({qualifiedName: "LCL_STACK=>TY_DATA-NAME"}), "is_array": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "array_index": new abap.types.Integer({qualifiedName: "LCL_STACK=>TY_DATA-ARRAY_INDEX"})}, "lcl_stack=>ty_data", undefined, {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "");}, "visibility": "I", "is_constant": " ", "is_class": " "}};
  static METHODS = {"PUSH": {"visibility": "U", "parameters": {"IV_NAME": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "IV_TYPE": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}},
  "POP": {"visibility": "U", "parameters": {"RV_NAME": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}},
  "IS_ARRAY": {"visibility": "U", "parameters": {"RV_ARRAY": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});}, "is_optional": " "}}},
  "GET_AND_INCREASE_INDEX": {"visibility": "U", "parameters": {"RV_INDEX": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}},
  "GET_FULL_NAME": {"visibility": "U", "parameters": {"RV_PATH": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}}};
  constructor() {
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
    this.mt_stack = abap.types.TableFactory.construct(new abap.types.Structure({"name": new abap.types.String({qualifiedName: "LCL_STACK=>TY_DATA-NAME"}), "is_array": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "array_index": new abap.types.Integer({qualifiedName: "LCL_STACK=>TY_DATA-ARRAY_INDEX"})}, "lcl_stack=>ty_data", undefined, {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "");
  }
  async constructor_(INPUT) {
    if (super.constructor_) { await super.constructor_(INPUT); }
    return this;
  }
  async push(INPUT) {
    let iv_name = INPUT?.iv_name;
    if (iv_name?.getQualifiedName === undefined || iv_name.getQualifiedName() !== "STRING") { iv_name = undefined; }
    if (iv_name === undefined) { iv_name = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.iv_name); }
    let iv_type = INPUT?.iv_type;
    if (iv_type?.getQualifiedName === undefined || iv_type.getQualifiedName() !== "STRING") { iv_type = undefined; }
    if (iv_type === undefined) { iv_type = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.iv_type); }
    let ls_data = new abap.types.Structure({"name": new abap.types.String({qualifiedName: "LCL_STACK=>TY_DATA-NAME"}), "is_array": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "array_index": new abap.types.Integer({qualifiedName: "LCL_STACK=>TY_DATA-ARRAY_INDEX"})}, "lcl_stack=>ty_data", undefined, {}, {});
    ls_data.get().name.set(iv_name);
    ls_data.get().is_array.set(abap.builtin.boolc(abap.compare.eq(iv_type, new abap.types.Character(5).set('array'))));
    abap.statements.append({source: ls_data, target: this.mt_stack});
  }
  async is_array() {
    let rv_array = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    let lv_index = new abap.types.Integer({qualifiedName: "I"});
    let fs_ls_data_ = new abap.types.FieldSymbol(new abap.types.Structure({"name": new abap.types.String({qualifiedName: "LCL_STACK=>TY_DATA-NAME"}), "is_array": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "array_index": new abap.types.Integer({qualifiedName: "LCL_STACK=>TY_DATA-ARRAY_INDEX"})}, "lcl_stack=>ty_data", undefined, {}, {}));
    lv_index.set(abap.builtin.lines({val: this.mt_stack}));
    abap.statements.readTable(this.mt_stack,{index: lv_index,
      assigning: fs_ls_data_});
    if (abap.compare.eq(abap.builtin.sy.get().subrc, abap.IntegerFactory.get(0))) {
      rv_array.set(fs_ls_data_.get().is_array);
    }
    return rv_array;
  }
  async get_and_increase_index() {
    let rv_index = new abap.types.String({qualifiedName: "STRING"});
    let lv_index = new abap.types.Integer({qualifiedName: "I"});
    let fs_ls_data_ = new abap.types.FieldSymbol(new abap.types.Structure({"name": new abap.types.String({qualifiedName: "LCL_STACK=>TY_DATA-NAME"}), "is_array": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "array_index": new abap.types.Integer({qualifiedName: "LCL_STACK=>TY_DATA-ARRAY_INDEX"})}, "lcl_stack=>ty_data", undefined, {}, {}));
    lv_index.set(abap.builtin.lines({val: this.mt_stack}));
    abap.statements.readTable(this.mt_stack,{index: lv_index,
      assigning: fs_ls_data_});
    if (abap.compare.eq(abap.builtin.sy.get().subrc, abap.IntegerFactory.get(0))) {
      fs_ls_data_.get().array_index.set(abap.operators.add(fs_ls_data_.get().array_index,abap.IntegerFactory.get(1)));
      rv_index.set(fs_ls_data_.get().array_index);
      rv_index.set(abap.builtin.condense({val: rv_index}));
    }
    return rv_index;
  }
  async pop() {
    let rv_name = new abap.types.String({qualifiedName: "STRING"});
    let lv_index = new abap.types.Integer({qualifiedName: "I"});
    let fs_ls_data_ = new abap.types.FieldSymbol(new abap.types.Structure({"name": new abap.types.String({qualifiedName: "LCL_STACK=>TY_DATA-NAME"}), "is_array": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "array_index": new abap.types.Integer({qualifiedName: "LCL_STACK=>TY_DATA-ARRAY_INDEX"})}, "lcl_stack=>ty_data", undefined, {}, {}));
    lv_index.set(abap.builtin.lines({val: this.mt_stack}));
    if (abap.compare.gt(lv_index, abap.IntegerFactory.get(0))) {
      abap.statements.readTable(this.mt_stack,{index: lv_index,
        assigning: fs_ls_data_});
      rv_name.set(fs_ls_data_.get().name);
      await abap.statements.deleteInternal(this.mt_stack,{index: lv_index});
    }
    return rv_name;
  }
  async get_full_name() {
    let rv_path = new abap.types.String({qualifiedName: "STRING"});
    let fs_ls_data_ = new abap.types.FieldSymbol(new abap.types.Structure({"name": new abap.types.String({qualifiedName: "LCL_STACK=>TY_DATA-NAME"}), "is_array": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "array_index": new abap.types.Integer({qualifiedName: "LCL_STACK=>TY_DATA-ARRAY_INDEX"})}, "lcl_stack=>ty_data", undefined, {}, {}));
    for await (const unique55 of abap.statements.loop(this.mt_stack)) {
      fs_ls_data_.assign(unique55);
      rv_path.set(abap.operators.concat(rv_path,fs_ls_data_.get().name));
    }
    return rv_path;
  }
}
abap.Classes['CLAS-/UI2/CL_JSON-LCL_STACK'] = lcl_stack;
lcl_stack.ty_data = new abap.types.Structure({"name": new abap.types.String({qualifiedName: "LCL_STACK=>TY_DATA-NAME"}), "is_array": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "array_index": new abap.types.Integer({qualifiedName: "LCL_STACK=>TY_DATA-ARRAY_INDEX"})}, "lcl_stack=>ty_data", undefined, {}, {});
class lcl_parser {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CLAS-/UI2/CL_JSON-LCL_PARSER';
  static IMPLEMENTED_INTERFACES = [];
  static ATTRIBUTES = {"MT_DATA": {"type": () => {return abap.types.TableFactory.construct(new abap.types.Structure({"parent": new abap.types.String({qualifiedName: "LCL_PARSER=>TY_DATA-PARENT"}), "name": new abap.types.String({qualifiedName: "LCL_PARSER=>TY_DATA-NAME"}), "full_name": new abap.types.String({qualifiedName: "LCL_PARSER=>TY_DATA-FULL_NAME"}), "full_name_upper": new abap.types.String({qualifiedName: "LCL_PARSER=>TY_DATA-FULL_NAME_UPPER"}), "value": new abap.types.String({qualifiedName: "LCL_PARSER=>TY_DATA-VALUE"}), "type": new abap.types.String({qualifiedName: "LCL_PARSER=>TY_DATA-TYPE"})}, "lcl_parser=>ty_data", undefined, {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[{"name":"key_full_name","type":"SORTED","isUnique":true,"keyFields":["FULL_NAME"]},{"name":"key_full_name_upper","type":"SORTED","isUnique":true,"keyFields":["FULL_NAME_UPPER"]},{"name":"key_parent","type":"SORTED","isUnique":false,"keyFields":["PARENT"]}]}, "lcl_parser=>ty_data_tt");}, "visibility": "I", "is_constant": " ", "is_class": " "}};
  static METHODS = {"PARSE": {"visibility": "U", "parameters": {"IV_JSON": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}},
  "ADJUST_NAMES": {"visibility": "U", "parameters": {}},
  "VALUE_BOOLEAN": {"visibility": "U", "parameters": {"RV_VALUE": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});}, "is_optional": " "}, "IV_PATH": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}},
  "VALUE_INTEGER": {"visibility": "U", "parameters": {"RV_VALUE": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}, "IV_PATH": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}},
  "VALUE_NUMBER": {"visibility": "U", "parameters": {"RV_VALUE": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}, "IV_PATH": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}},
  "VALUE_STRING": {"visibility": "U", "parameters": {"RV_VALUE": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "IV_PATH": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}},
  "GET_TYPE": {"visibility": "U", "parameters": {"RV_TYPE": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "IV_PATH": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}},
  "MEMBERS": {"visibility": "U", "parameters": {"RT_MEMBERS": {"type": () => {return abap.types.TableFactory.construct(new abap.types.String({qualifiedName: "STRING"}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"isUnique":false,"type":"STANDARD","keyFields":[],"name":"primary_key"},"secondary":[]}, "STRING_TABLE");}, "is_optional": " "}, "IV_PATH": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}},
  "FIND_IGNORE_CASE": {"visibility": "U", "parameters": {"RV_PATH": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "IV_PATH": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}}};
  constructor() {
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
    this.mt_data = abap.types.TableFactory.construct(new abap.types.Structure({"parent": new abap.types.String({qualifiedName: "LCL_PARSER=>TY_DATA-PARENT"}), "name": new abap.types.String({qualifiedName: "LCL_PARSER=>TY_DATA-NAME"}), "full_name": new abap.types.String({qualifiedName: "LCL_PARSER=>TY_DATA-FULL_NAME"}), "full_name_upper": new abap.types.String({qualifiedName: "LCL_PARSER=>TY_DATA-FULL_NAME_UPPER"}), "value": new abap.types.String({qualifiedName: "LCL_PARSER=>TY_DATA-VALUE"}), "type": new abap.types.String({qualifiedName: "LCL_PARSER=>TY_DATA-TYPE"})}, "lcl_parser=>ty_data", undefined, {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[{"name":"key_full_name","type":"SORTED","isUnique":true,"keyFields":["FULL_NAME"]},{"name":"key_full_name_upper","type":"SORTED","isUnique":true,"keyFields":["FULL_NAME_UPPER"]},{"name":"key_parent","type":"SORTED","isUnique":false,"keyFields":["PARENT"]}]}, "lcl_parser=>ty_data_tt");
  }
  async constructor_(INPUT) {
    if (super.constructor_) { await super.constructor_(INPUT); }
    return this;
  }
  async adjust_names() {
    let fs_ls_data_ = new abap.types.FieldSymbol(new abap.types.Structure({"parent": new abap.types.String({qualifiedName: "LCL_PARSER=>TY_DATA-PARENT"}), "name": new abap.types.String({qualifiedName: "LCL_PARSER=>TY_DATA-NAME"}), "full_name": new abap.types.String({qualifiedName: "LCL_PARSER=>TY_DATA-FULL_NAME"}), "full_name_upper": new abap.types.String({qualifiedName: "LCL_PARSER=>TY_DATA-FULL_NAME_UPPER"}), "value": new abap.types.String({qualifiedName: "LCL_PARSER=>TY_DATA-VALUE"}), "type": new abap.types.String({qualifiedName: "LCL_PARSER=>TY_DATA-TYPE"})}, "lcl_parser=>ty_data", undefined, {}, {}));
    for await (const unique56 of abap.statements.loop(this.mt_data)) {
      fs_ls_data_.assign(unique56);
      abap.statements.replace({target: fs_ls_data_.get().parent, all: true, with: new abap.types.Character(1).set('_'), of: new abap.types.Character(1).set('-')});
      abap.statements.replace({target: fs_ls_data_.get().name, all: true, with: new abap.types.Character(1).set('_'), of: new abap.types.Character(1).set('-')});
      abap.statements.replace({target: fs_ls_data_.get().full_name, all: true, with: new abap.types.Character(1).set('_'), of: new abap.types.Character(1).set('-')});
      abap.statements.replace({target: fs_ls_data_.get().full_name_upper, all: true, with: new abap.types.Character(1).set('_'), of: new abap.types.Character(1).set('-')});
    }
  }
  async find_ignore_case(INPUT) {
    let rv_path = new abap.types.String({qualifiedName: "STRING"});
    let iv_path = INPUT?.iv_path;
    if (iv_path?.getQualifiedName === undefined || iv_path.getQualifiedName() !== "STRING") { iv_path = undefined; }
    if (iv_path === undefined) { iv_path = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.iv_path); }
    let ls_data = new abap.types.Structure({"parent": new abap.types.String({qualifiedName: "LCL_PARSER=>TY_DATA-PARENT"}), "name": new abap.types.String({qualifiedName: "LCL_PARSER=>TY_DATA-NAME"}), "full_name": new abap.types.String({qualifiedName: "LCL_PARSER=>TY_DATA-FULL_NAME"}), "full_name_upper": new abap.types.String({qualifiedName: "LCL_PARSER=>TY_DATA-FULL_NAME_UPPER"}), "value": new abap.types.String({qualifiedName: "LCL_PARSER=>TY_DATA-VALUE"}), "type": new abap.types.String({qualifiedName: "LCL_PARSER=>TY_DATA-TYPE"})}, "lcl_parser=>ty_data", undefined, {}, {});
    abap.statements.readTable(this.mt_data,{keyName: "key_full_name_upper",
      into: ls_data,
      withKey: (i) => {return abap.compare.eq(i.full_name_upper, abap.builtin.to_upper({val: iv_path}));},
      withKeyValue: [{key: (i) => {return i.full_name_upper}, value: abap.builtin.to_upper({val: iv_path})}],
      usesTableLine: false,
      withKeySimple: {"full_name_upper": abap.builtin.to_upper({val: iv_path})}});
    if (abap.compare.eq(abap.builtin.sy.get().subrc, abap.IntegerFactory.get(0))) {
      rv_path.set(ls_data.get().full_name);
      return rv_path;
    }
    rv_path.set(iv_path);
    return rv_path;
  }
  async get_type(INPUT) {
    let rv_type = new abap.types.String({qualifiedName: "STRING"});
    let iv_path = INPUT?.iv_path;
    if (iv_path?.getQualifiedName === undefined || iv_path.getQualifiedName() !== "STRING") { iv_path = undefined; }
    if (iv_path === undefined) { iv_path = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.iv_path); }
    let ls_data = new abap.types.Structure({"parent": new abap.types.String({qualifiedName: "LCL_PARSER=>TY_DATA-PARENT"}), "name": new abap.types.String({qualifiedName: "LCL_PARSER=>TY_DATA-NAME"}), "full_name": new abap.types.String({qualifiedName: "LCL_PARSER=>TY_DATA-FULL_NAME"}), "full_name_upper": new abap.types.String({qualifiedName: "LCL_PARSER=>TY_DATA-FULL_NAME_UPPER"}), "value": new abap.types.String({qualifiedName: "LCL_PARSER=>TY_DATA-VALUE"}), "type": new abap.types.String({qualifiedName: "LCL_PARSER=>TY_DATA-TYPE"})}, "lcl_parser=>ty_data", undefined, {}, {});
    abap.statements.readTable(this.mt_data,{keyName: "key_full_name",
      into: ls_data,
      withKey: (i) => {return abap.compare.eq(i.full_name, iv_path);},
      withKeyValue: [{key: (i) => {return i.full_name}, value: iv_path}],
      usesTableLine: false,
      withKeySimple: {"full_name": iv_path}});
    rv_type.set(ls_data.get().type);
    return rv_type;
  }
  async members(INPUT) {
    let rt_members = abap.types.TableFactory.construct(new abap.types.String({qualifiedName: "STRING"}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"isUnique":false,"type":"STANDARD","keyFields":[],"name":"primary_key"},"secondary":[]}, "STRING_TABLE");
    let iv_path = INPUT?.iv_path;
    if (iv_path?.getQualifiedName === undefined || iv_path.getQualifiedName() !== "STRING") { iv_path = undefined; }
    if (iv_path === undefined) { iv_path = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.iv_path); }
    let ls_data = new abap.types.Structure({"parent": new abap.types.String({qualifiedName: "LCL_PARSER=>TY_DATA-PARENT"}), "name": new abap.types.String({qualifiedName: "LCL_PARSER=>TY_DATA-NAME"}), "full_name": new abap.types.String({qualifiedName: "LCL_PARSER=>TY_DATA-FULL_NAME"}), "full_name_upper": new abap.types.String({qualifiedName: "LCL_PARSER=>TY_DATA-FULL_NAME_UPPER"}), "value": new abap.types.String({qualifiedName: "LCL_PARSER=>TY_DATA-VALUE"}), "type": new abap.types.String({qualifiedName: "LCL_PARSER=>TY_DATA-TYPE"})}, "lcl_parser=>ty_data", undefined, {}, {});
    for await (const unique57 of abap.statements.loop(this.mt_data,{usingKey: "key_parent",where: async (I) => {return abap.compare.eq(I.parent, iv_path);},topEquals: {"parent": iv_path}})) {
      ls_data.set(unique57);
      abap.statements.append({source: ls_data.get().name, target: rt_members});
    }
    return rt_members;
  }
  async value_boolean(INPUT) {
    let rv_value = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    let iv_path = INPUT?.iv_path;
    if (iv_path?.getQualifiedName === undefined || iv_path.getQualifiedName() !== "STRING") { iv_path = undefined; }
    if (iv_path === undefined) { iv_path = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.iv_path); }
    rv_value.set(abap.builtin.boolc(abap.compare.eq((await this.value_string({iv_path: iv_path})), new abap.types.Character(4).set('true'))));
    return rv_value;
  }
  async value_integer(INPUT) {
    let rv_value = new abap.types.Integer({qualifiedName: "I"});
    let iv_path = INPUT?.iv_path;
    if (iv_path?.getQualifiedName === undefined || iv_path.getQualifiedName() !== "STRING") { iv_path = undefined; }
    if (iv_path === undefined) { iv_path = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.iv_path); }
    rv_value.set((await this.value_string({iv_path: iv_path})));
    return rv_value;
  }
  async value_number(INPUT) {
    let rv_value = new abap.types.Integer({qualifiedName: "I"});
    let iv_path = INPUT?.iv_path;
    if (iv_path?.getQualifiedName === undefined || iv_path.getQualifiedName() !== "STRING") { iv_path = undefined; }
    if (iv_path === undefined) { iv_path = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.iv_path); }
    rv_value.set((await this.value_string({iv_path: iv_path})));
    return rv_value;
  }
  async value_string(INPUT) {
    let rv_value = new abap.types.String({qualifiedName: "STRING"});
    let iv_path = INPUT?.iv_path;
    if (iv_path?.getQualifiedName === undefined || iv_path.getQualifiedName() !== "STRING") { iv_path = undefined; }
    if (iv_path === undefined) { iv_path = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.iv_path); }
    let ls_data = new abap.types.Structure({"parent": new abap.types.String({qualifiedName: "LCL_PARSER=>TY_DATA-PARENT"}), "name": new abap.types.String({qualifiedName: "LCL_PARSER=>TY_DATA-NAME"}), "full_name": new abap.types.String({qualifiedName: "LCL_PARSER=>TY_DATA-FULL_NAME"}), "full_name_upper": new abap.types.String({qualifiedName: "LCL_PARSER=>TY_DATA-FULL_NAME_UPPER"}), "value": new abap.types.String({qualifiedName: "LCL_PARSER=>TY_DATA-VALUE"}), "type": new abap.types.String({qualifiedName: "LCL_PARSER=>TY_DATA-TYPE"})}, "lcl_parser=>ty_data", undefined, {}, {});
    abap.statements.readTable(this.mt_data,{keyName: "key_full_name",
      into: ls_data,
      withKey: (i) => {return abap.compare.eq(i.full_name, iv_path);},
      withKeyValue: [{key: (i) => {return i.full_name}, value: iv_path}],
      usesTableLine: false,
      withKeySimple: {"full_name": iv_path}});
    if (abap.compare.eq(abap.builtin.sy.get().subrc, abap.IntegerFactory.get(0))) {
      rv_value.set(ls_data.get().value);
    }
    return rv_value;
  }
  async parse(INPUT) {
    let iv_json = INPUT?.iv_json;
    if (iv_json?.getQualifiedName === undefined || iv_json.getQualifiedName() !== "STRING") { iv_json = undefined; }
    if (iv_json === undefined) { iv_json = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.iv_json); }
    let li_node = new abap.types.ABAPObject({qualifiedName: "IF_SXML_NODE", RTTIName: "\\INTERFACE=IF_SXML_NODE"});
    let li_next = new abap.types.ABAPObject({qualifiedName: "IF_SXML_NODE", RTTIName: "\\INTERFACE=IF_SXML_NODE"});
    let li_reader = new abap.types.ABAPObject({qualifiedName: "IF_SXML_READER", RTTIName: "\\INTERFACE=IF_SXML_READER"});
    let li_close = new abap.types.ABAPObject({qualifiedName: "IF_SXML_CLOSE_ELEMENT", RTTIName: "\\INTERFACE=IF_SXML_CLOSE_ELEMENT"});
    let li_open = new abap.types.ABAPObject({qualifiedName: "IF_SXML_OPEN_ELEMENT", RTTIName: "\\INTERFACE=IF_SXML_OPEN_ELEMENT"});
    let lt_attributes = abap.types.TableFactory.construct(new abap.types.ABAPObject({qualifiedName: "IF_SXML_ATTRIBUTE", RTTIName: "\\INTERFACE=IF_SXML_ATTRIBUTE"}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "if_sxml_attribute=>attributes");
    let li_attribute = new abap.types.ABAPObject({qualifiedName: "IF_SXML_ATTRIBUTE", RTTIName: "\\INTERFACE=IF_SXML_ATTRIBUTE"});
    let li_value = new abap.types.ABAPObject({qualifiedName: "IF_SXML_VALUE_NODE", RTTIName: "\\INTERFACE=IF_SXML_VALUE_NODE"});
    let lv_push = new abap.types.String({qualifiedName: "STRING"});
    let lv_name = new abap.types.String({qualifiedName: "STRING"});
    let lo_stack = new abap.types.ABAPObject({qualifiedName: "LCL_STACK", RTTIName: "\\CLASS-POOL=/UI2/CL_JSON\\CLASS=LCL_STACK"});
    let ls_data = new abap.types.Structure({"parent": new abap.types.String({qualifiedName: "LCL_PARSER=>TY_DATA-PARENT"}), "name": new abap.types.String({qualifiedName: "LCL_PARSER=>TY_DATA-NAME"}), "full_name": new abap.types.String({qualifiedName: "LCL_PARSER=>TY_DATA-FULL_NAME"}), "full_name_upper": new abap.types.String({qualifiedName: "LCL_PARSER=>TY_DATA-FULL_NAME_UPPER"}), "value": new abap.types.String({qualifiedName: "LCL_PARSER=>TY_DATA-VALUE"}), "type": new abap.types.String({qualifiedName: "LCL_PARSER=>TY_DATA-TYPE"})}, "lcl_parser=>ty_data", undefined, {}, {});
    let lv_index = new abap.types.Integer({qualifiedName: "I"});
    let lt_nodes = abap.types.TableFactory.construct(new abap.types.ABAPObject({qualifiedName: "IF_SXML_NODE", RTTIName: "\\INTERFACE=IF_SXML_NODE"}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "");
    lo_stack.set(await (new abap.Classes['CLAS-/UI2/CL_JSON-LCL_STACK']()).constructor_());
    li_reader.set((await abap.Classes['CL_SXML_STRING_READER'].create({input: (await abap.Classes['CL_ABAP_CODEPAGE'].convert_to({source: iv_json}))})));
    const indexBackup1 = abap.builtin.sy.get().index.get();
    let unique58 = 1;
    while (true) {
      abap.builtin.sy.get().index.set(unique58++);
      li_node.set((await li_reader.get().if_sxml_reader$read_next_node()));
      if (abap.compare.initial(li_node)) {
        break;
      }
      abap.statements.append({source: li_node, target: lt_nodes});
    }
    abap.builtin.sy.get().index.set(indexBackup1);
    for await (const unique59 of abap.statements.loop(lt_nodes)) {
      li_node.set(unique59);
      lv_index.set(abap.builtin.sy.get().tabix);
      let unique60 = li_node.get().if_sxml_node$type;
      if (abap.compare.eq(unique60, abap.Classes['IF_SXML_NODE'].if_sxml_node$co_nt_element_open)) {
        await abap.statements.cast(li_open, li_node);
        lt_attributes.set((await li_open.get().if_sxml_open_element$get_attributes()));
        abap.statements.readTable(lt_attributes,{index: abap.IntegerFactory.get(1),
          into: li_attribute});
        if (abap.compare.eq(abap.builtin.sy.get().subrc, abap.IntegerFactory.get(0))) {
          lv_push.set((await li_attribute.get().if_sxml_attribute$get_value()));
        } else if (abap.compare.eq((await lo_stack.get().is_array()), abap.builtin.abap_true)) {
          lv_push.set((await lo_stack.get().get_and_increase_index()));
        }
        if (abap.compare.initial(lv_push) === false) {
          abap.statements.clear(ls_data);
          ls_data.get().parent.set((await lo_stack.get().get_full_name()));
          ls_data.get().name.set(lv_push);
          ls_data.get().full_name.set(abap.operators.concat(ls_data.get().parent,ls_data.get().name));
          ls_data.get().full_name_upper.set(abap.builtin.to_upper({val: ls_data.get().full_name}));
          ls_data.get().type.set(li_open.get().if_sxml_open_element$qname.get().name);
          lv_index.set(abap.operators.add(lv_index,abap.IntegerFactory.get(1)));
          abap.statements.readTable(lt_nodes,{index: lv_index,
            into: li_next});
          if (abap.compare.eq(abap.builtin.sy.get().subrc, abap.IntegerFactory.get(0)) && abap.compare.eq(li_next.get().if_sxml_node$type, abap.Classes['IF_SXML_NODE'].if_sxml_node$co_nt_value)) {
            await abap.statements.cast(li_value, li_next);
            ls_data.get().value.set((await li_value.get().if_sxml_value_node$get_value()));
          }
          abap.statements.append({source: ls_data, target: this.mt_data});
          await lo_stack.get().push({iv_name: lv_push, iv_type: li_open.get().if_sxml_open_element$qname.get().name});
        }
        if (abap.compare.eq(li_open.get().if_sxml_open_element$qname.get().name, new abap.types.Character(6).set('object')) || abap.compare.eq(li_open.get().if_sxml_open_element$qname.get().name, new abap.types.Character(5).set('array'))) {
          abap.statements.clear(ls_data);
          ls_data.get().parent.set((await lo_stack.get().get_full_name()));
          ls_data.get().name.set(new abap.types.Character(1).set('/'));
          ls_data.get().full_name.set(abap.operators.concat(ls_data.get().parent,ls_data.get().name));
          ls_data.get().full_name_upper.set(abap.builtin.to_upper({val: ls_data.get().full_name}));
          ls_data.get().type.set(li_open.get().if_sxml_open_element$qname.get().name);
          abap.statements.append({source: ls_data, target: this.mt_data});
          await lo_stack.get().push({iv_name: new abap.types.Character(1).set('/'), iv_type: li_open.get().if_sxml_open_element$qname.get().name});
        }
      } else if (abap.compare.eq(unique60, abap.Classes['IF_SXML_NODE'].if_sxml_node$co_nt_element_close)) {
        await abap.statements.cast(li_close, li_node);
        lv_name.set((await lo_stack.get().pop()));
        if (abap.compare.eq(lv_name, new abap.types.Character(1).set('/'))) {
          await lo_stack.get().pop();
        }
      }
    }
  }
}
abap.Classes['CLAS-/UI2/CL_JSON-LCL_PARSER'] = lcl_parser;
lcl_parser.ty_data = new abap.types.Structure({"parent": new abap.types.String({qualifiedName: "LCL_PARSER=>TY_DATA-PARENT"}), "name": new abap.types.String({qualifiedName: "LCL_PARSER=>TY_DATA-NAME"}), "full_name": new abap.types.String({qualifiedName: "LCL_PARSER=>TY_DATA-FULL_NAME"}), "full_name_upper": new abap.types.String({qualifiedName: "LCL_PARSER=>TY_DATA-FULL_NAME_UPPER"}), "value": new abap.types.String({qualifiedName: "LCL_PARSER=>TY_DATA-VALUE"}), "type": new abap.types.String({qualifiedName: "LCL_PARSER=>TY_DATA-TYPE"})}, "lcl_parser=>ty_data", undefined, {}, {});
lcl_parser.ty_data_tt = abap.types.TableFactory.construct(new abap.types.Structure({"parent": new abap.types.String({qualifiedName: "LCL_PARSER=>TY_DATA-PARENT"}), "name": new abap.types.String({qualifiedName: "LCL_PARSER=>TY_DATA-NAME"}), "full_name": new abap.types.String({qualifiedName: "LCL_PARSER=>TY_DATA-FULL_NAME"}), "full_name_upper": new abap.types.String({qualifiedName: "LCL_PARSER=>TY_DATA-FULL_NAME_UPPER"}), "value": new abap.types.String({qualifiedName: "LCL_PARSER=>TY_DATA-VALUE"}), "type": new abap.types.String({qualifiedName: "LCL_PARSER=>TY_DATA-TYPE"})}, "lcl_parser=>ty_data", undefined, {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[{"name":"key_full_name","type":"SORTED","isUnique":true,"keyFields":["FULL_NAME"]},{"name":"key_full_name_upper","type":"SORTED","isUnique":true,"keyFields":["FULL_NAME_UPPER"]},{"name":"key_parent","type":"SORTED","isUnique":false,"keyFields":["PARENT"]}]}, "lcl_parser=>ty_data_tt");
export {lcl_stack, lcl_parser};
//# sourceMappingURL=%23ui2%23cl_json.clas.locals.mjs.map