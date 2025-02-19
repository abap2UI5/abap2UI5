const {cl_abap_datadescr} = await import("./cl_abap_datadescr.clas.mjs");
const {cx_root} = await import("./cx_root.clas.mjs");
// cl_abap_tabledescr.clas.abap
class cl_abap_tabledescr extends cl_abap_datadescr {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CL_ABAP_TABLEDESCR';
  static IMPLEMENTED_INTERFACES = [];
  static ATTRIBUTES = {"HAS_UNIQUE_KEY": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});}, "visibility": "U", "is_constant": " ", "is_class": " "},
  "KEY": {"type": () => {return abap.types.TableFactory.construct(new abap.types.Structure({"name": new abap.types.Character(255, {"qualifiedName":"abap_keyname"})}, "abap_keydescr", undefined, {}, {}), {"withHeader":false,"keyType":"USER","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":["NAME"]},"secondary":[]}, "abap_keydescr_tab");}, "visibility": "U", "is_constant": " ", "is_class": " "},
  "KEY_DEFKIND": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"abap_keydefkind"});}, "visibility": "U", "is_constant": " ", "is_class": " "},
  "TABLE_KIND": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"abap_tablekind"});}, "visibility": "U", "is_constant": " ", "is_class": " "},
  "INITIAL_SIZE": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": " ", "is_class": " "},
  "MO_LINE_TYPE": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "CL_ABAP_TYPEDESCR", RTTIName: "\\CLASS=CL_ABAP_TYPEDESCR"});}, "visibility": "I", "is_constant": " ", "is_class": " "},
  "MT_KEYS": {"type": () => {return abap.types.TableFactory.construct(new abap.types.Structure({"components": abap.types.TableFactory.construct(new abap.types.Structure({"name": new abap.types.String({qualifiedName: "NAME"})}, "abap_table_keycompdescr", undefined, {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "abap_table_keydescr-components"), "name": new abap.types.String({qualifiedName: "NAME"}), "is_primary": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "access_kind": new abap.types.String({qualifiedName: "ACCESS_KIND"}), "is_unique": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "key_kind": new abap.types.String({qualifiedName: "KEY_KIND"})}, "abap_table_keydescr", undefined, {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "abap_table_keydescr_tab");}, "visibility": "I", "is_constant": " ", "is_class": " "},
  "TABLEKIND_ANY": {"type": () => {return new abap.types.Character(1, {});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "TABLEKIND_STD": {"type": () => {return new abap.types.Character(1, {});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "TABLEKIND_INDEX": {"type": () => {return new abap.types.Character(1, {});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "TABLEKIND_HASHED": {"type": () => {return new abap.types.Character(1, {});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "TABLEKIND_SORTED": {"type": () => {return new abap.types.Character(1, {});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "KEYDEFKIND_DEFAULT": {"type": () => {return new abap.types.Character(1, {});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "KEYDEFKIND_TABLELINE": {"type": () => {return new abap.types.Character(1, {});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "KEYDEFKIND_USER": {"type": () => {return new abap.types.Character(1, {});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "KEYDEFKIND_EMPTY": {"type": () => {return new abap.types.Character(1, {});}, "visibility": "U", "is_constant": "X", "is_class": "X"}};
  static METHODS = {"CONSTRUCT_FROM_DATA": {"visibility": "U", "parameters": {"DESCR": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "CL_ABAP_TABLEDESCR", RTTIName: "\\CLASS=CL_ABAP_TABLEDESCR"});}, "is_optional": " "}, "DATA": {"type": () => {return new abap.types.Character(4);}, "is_optional": " "}}},
  "GET_TABLE_LINE_TYPE": {"visibility": "U", "parameters": {"TYPE": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "CL_ABAP_DATADESCR", RTTIName: "\\CLASS=CL_ABAP_DATADESCR"});}, "is_optional": " "}}},
  "GET": {"visibility": "U", "parameters": {"VAL": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "CL_ABAP_TABLEDESCR", RTTIName: "\\CLASS=CL_ABAP_TABLEDESCR"});}, "is_optional": " "}, "TYPE": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "CL_ABAP_DATADESCR", RTTIName: "\\CLASS=CL_ABAP_DATADESCR"});}, "is_optional": " "}}},
  "GET_WITH_KEYS": {"visibility": "U", "parameters": {"P_RESULT": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "CL_ABAP_TABLEDESCR", RTTIName: "\\CLASS=CL_ABAP_TABLEDESCR"});}, "is_optional": " "}, "P_LINE_TYPE": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "CL_ABAP_DATADESCR", RTTIName: "\\CLASS=CL_ABAP_DATADESCR"});}, "is_optional": " "}, "P_KEYS": {"type": () => {return abap.types.TableFactory.construct(new abap.types.Structure({"components": abap.types.TableFactory.construct(new abap.types.Structure({"name": new abap.types.String({qualifiedName: "NAME"})}, "abap_table_keycompdescr", undefined, {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "abap_table_keydescr-components"), "name": new abap.types.String({qualifiedName: "NAME"}), "is_primary": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "access_kind": new abap.types.String({qualifiedName: "ACCESS_KIND"}), "is_unique": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "key_kind": new abap.types.String({qualifiedName: "KEY_KIND"})}, "abap_table_keydescr", undefined, {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "abap_table_keydescr_tab");}, "is_optional": " "}}},
  "CREATE": {"visibility": "U", "parameters": {"REF": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "CL_ABAP_TABLEDESCR", RTTIName: "\\CLASS=CL_ABAP_TABLEDESCR"});}, "is_optional": " "}, "P_LINE_TYPE": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "CL_ABAP_TYPEDESCR", RTTIName: "\\CLASS=CL_ABAP_TYPEDESCR"});}, "is_optional": " "}, "P_TABLE_KIND": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"abap_tablekind"});}, "is_optional": " "}, "P_UNIQUE": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});}, "is_optional": " "}, "P_KEY": {"type": () => {return abap.types.TableFactory.construct(new abap.types.Structure({"name": new abap.types.Character(255, {"qualifiedName":"abap_keyname"})}, "abap_keydescr", undefined, {}, {}), {"withHeader":false,"keyType":"USER","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":["NAME"]},"secondary":[]}, "abap_keydescr_tab");}, "is_optional": " "}, "P_KEY_KIND": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"abap_keydefkind"});}, "is_optional": " "}}},
  "GET_KEYS": {"visibility": "U", "parameters": {"P_KEYS": {"type": () => {return abap.types.TableFactory.construct(new abap.types.Structure({"components": abap.types.TableFactory.construct(new abap.types.Structure({"name": new abap.types.String({qualifiedName: "NAME"})}, "abap_table_keycompdescr", undefined, {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "abap_table_keydescr-components"), "name": new abap.types.String({qualifiedName: "NAME"}), "is_primary": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "access_kind": new abap.types.String({qualifiedName: "ACCESS_KIND"}), "is_unique": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "key_kind": new abap.types.String({qualifiedName: "KEY_KIND"})}, "abap_table_keydescr", undefined, {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "abap_table_keydescr_tab");}, "is_optional": " "}}}};
  constructor() {
    super();
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
    this.has_unique_key = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    this.key = abap.types.TableFactory.construct(new abap.types.Structure({"name": new abap.types.Character(255, {"qualifiedName":"abap_keyname"})}, "abap_keydescr", undefined, {}, {}), {"withHeader":false,"keyType":"USER","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":["NAME"]},"secondary":[]}, "abap_keydescr_tab");
    this.key_defkind = new abap.types.Character(1, {"qualifiedName":"abap_keydefkind"});
    this.table_kind = new abap.types.Character(1, {"qualifiedName":"abap_tablekind"});
    this.initial_size = new abap.types.Integer({qualifiedName: "I"});
    this.mo_line_type = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_TYPEDESCR", RTTIName: "\\CLASS=CL_ABAP_TYPEDESCR"});
    this.mt_keys = abap.types.TableFactory.construct(new abap.types.Structure({"components": abap.types.TableFactory.construct(new abap.types.Structure({"name": new abap.types.String({qualifiedName: "NAME"})}, "abap_table_keycompdescr", undefined, {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "abap_table_keydescr-components"), "name": new abap.types.String({qualifiedName: "NAME"}), "is_primary": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "access_kind": new abap.types.String({qualifiedName: "ACCESS_KIND"}), "is_unique": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "key_kind": new abap.types.String({qualifiedName: "KEY_KIND"})}, "abap_table_keydescr", undefined, {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "abap_table_keydescr_tab");
    this.tablekind_any = cl_abap_tabledescr.tablekind_any;
    this.tablekind_std = cl_abap_tabledescr.tablekind_std;
    this.tablekind_index = cl_abap_tabledescr.tablekind_index;
    this.tablekind_hashed = cl_abap_tabledescr.tablekind_hashed;
    this.tablekind_sorted = cl_abap_tabledescr.tablekind_sorted;
    this.keydefkind_default = cl_abap_tabledescr.keydefkind_default;
    this.keydefkind_tableline = cl_abap_tabledescr.keydefkind_tableline;
    this.keydefkind_user = cl_abap_tabledescr.keydefkind_user;
    this.keydefkind_empty = cl_abap_tabledescr.keydefkind_empty;
  }
  async constructor_(INPUT) {
    if (super.constructor_) { await super.constructor_(INPUT); }
    return this;
  }
  async create(INPUT) {
    return cl_abap_tabledescr.create(INPUT);
  }
  static async create(INPUT) {
    let ref = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_TABLEDESCR", RTTIName: "\\CLASS=CL_ABAP_TABLEDESCR"});
    let p_line_type = INPUT?.p_line_type;
    if (p_line_type?.getQualifiedName === undefined || p_line_type.getQualifiedName() !== "CL_ABAP_TYPEDESCR") { p_line_type = undefined; }
    if (p_line_type === undefined) { p_line_type = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_TYPEDESCR", RTTIName: "\\CLASS=CL_ABAP_TYPEDESCR"}).set(INPUT.p_line_type); }
    let p_table_kind = new abap.types.Character(1, {"qualifiedName":"abap_tablekind"});
    if (INPUT && INPUT.p_table_kind) {p_table_kind.set(INPUT.p_table_kind);}
    if (INPUT === undefined || INPUT.p_table_kind === undefined) {p_table_kind = this.tablekind_std;}
    let p_unique = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    if (INPUT && INPUT.p_unique) {p_unique.set(INPUT.p_unique);}
    if (INPUT === undefined || INPUT.p_unique === undefined) {p_unique = abap.builtin.abap_false;}
    let p_key = abap.types.TableFactory.construct(new abap.types.Structure({"name": new abap.types.Character(255, {"qualifiedName":"abap_keyname"})}, "abap_keydescr", undefined, {}, {}), {"withHeader":false,"keyType":"USER","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":["NAME"]},"secondary":[]}, "abap_keydescr_tab");
    if (INPUT && INPUT.p_key) {p_key.set(INPUT.p_key);}
    let p_key_kind = new abap.types.Character(1, {"qualifiedName":"abap_keydefkind"});
    if (INPUT && INPUT.p_key_kind) {p_key_kind.set(INPUT.p_key_kind);}
    if (INPUT === undefined || INPUT.p_key_kind === undefined) {p_key_kind = this.keydefkind_default;}
    ref.set(await (new abap.Classes['CL_ABAP_TABLEDESCR']()).constructor_());
    ref.get().has_unique_key.set(p_unique);
    ref.get().mo_line_type.set(p_line_type);
    ref.get().key.set(p_key);
    ref.get().key_defkind.set(p_key_kind);
    ref.get().table_kind.set(p_table_kind);
    ref.get().type_kind.set(cl_abap_tabledescr.typekind_table);
    ref.get().kind.set(cl_abap_tabledescr.kind_table);
    return ref;
  }
  async get_keys() {
    let p_keys = abap.types.TableFactory.construct(new abap.types.Structure({"components": abap.types.TableFactory.construct(new abap.types.Structure({"name": new abap.types.String({qualifiedName: "NAME"})}, "abap_table_keycompdescr", undefined, {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "abap_table_keydescr-components"), "name": new abap.types.String({qualifiedName: "NAME"}), "is_primary": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "access_kind": new abap.types.String({qualifiedName: "ACCESS_KIND"}), "is_unique": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "key_kind": new abap.types.String({qualifiedName: "KEY_KIND"})}, "abap_table_keydescr", undefined, {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "abap_table_keydescr_tab");
    p_keys.set(this.mt_keys);
    return p_keys;
  }
  async get_with_keys(INPUT) {
    return cl_abap_tabledescr.get_with_keys(INPUT);
  }
  static async get_with_keys(INPUT) {
    let p_result = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_TABLEDESCR", RTTIName: "\\CLASS=CL_ABAP_TABLEDESCR"});
    let p_line_type = INPUT?.p_line_type;
    if (p_line_type?.getQualifiedName === undefined || p_line_type.getQualifiedName() !== "CL_ABAP_DATADESCR") { p_line_type = undefined; }
    if (p_line_type === undefined) { p_line_type = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_DATADESCR", RTTIName: "\\CLASS=CL_ABAP_DATADESCR"}).set(INPUT.p_line_type); }
    let p_keys = INPUT?.p_keys;
    if (p_keys?.getQualifiedName === undefined || p_keys.getQualifiedName() !== "ABAP_TABLE_KEYDESCR_TAB") { p_keys = undefined; }
    if (p_keys === undefined) { p_keys = abap.types.TableFactory.construct(new abap.types.Structure({"components": abap.types.TableFactory.construct(new abap.types.Structure({"name": new abap.types.String({qualifiedName: "NAME"})}, "abap_table_keycompdescr", undefined, {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "abap_table_keydescr-components"), "name": new abap.types.String({qualifiedName: "NAME"}), "is_primary": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "access_kind": new abap.types.String({qualifiedName: "ACCESS_KIND"}), "is_unique": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "key_kind": new abap.types.String({qualifiedName: "KEY_KIND"})}, "abap_table_keydescr", undefined, {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "abap_table_keydescr_tab").set(INPUT.p_keys); }
    let ls_key = new abap.types.Structure({"components": abap.types.TableFactory.construct(new abap.types.Structure({"name": new abap.types.String({qualifiedName: "NAME"})}, "abap_table_keycompdescr", undefined, {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "abap_table_keydescr-components"), "name": new abap.types.String({qualifiedName: "NAME"}), "is_primary": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "access_kind": new abap.types.String({qualifiedName: "ACCESS_KIND"}), "is_unique": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "key_kind": new abap.types.String({qualifiedName: "KEY_KIND"})}, "abap_table_keydescr", undefined, {}, {});
    if (abap.compare.ne(abap.builtin.lines({val: p_keys}), abap.IntegerFactory.get(1))) {
      abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    }
    abap.statements.readTable(p_keys,{index: abap.IntegerFactory.get(1),
      into: ls_key});
    abap.statements.assert(abap.compare.eq(abap.builtin.sy.get().subrc, abap.IntegerFactory.get(0)));
    p_result.set(await (new abap.Classes['CL_ABAP_TABLEDESCR']()).constructor_());
    p_result.get().has_unique_key.set(ls_key.get().is_unique);
    p_result.get().mo_line_type.set(p_line_type);
    p_result.get().key_defkind.set(ls_key.get().key_kind);
    p_result.get().table_kind.set(ls_key.get().access_kind);
    p_result.get().mt_keys.set(p_keys);
    p_result.get().type_kind.set(cl_abap_tabledescr.typekind_table);
    p_result.get().kind.set(cl_abap_tabledescr.kind_table);
    return p_result;
  }
  async get(INPUT) {
    return cl_abap_tabledescr.get(INPUT);
  }
  static async get(INPUT) {
    let val = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_TABLEDESCR", RTTIName: "\\CLASS=CL_ABAP_TABLEDESCR"});
    let type = INPUT?.type;
    if (type?.getQualifiedName === undefined || type.getQualifiedName() !== "CL_ABAP_DATADESCR") { type = undefined; }
    if (type === undefined) { type = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_DATADESCR", RTTIName: "\\CLASS=CL_ABAP_DATADESCR"}).set(INPUT.type); }
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return val;
  }
  async construct_from_data(INPUT) {
    return cl_abap_tabledescr.construct_from_data(INPUT);
  }
  static async construct_from_data(INPUT) {
    let descr = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_TABLEDESCR", RTTIName: "\\CLASS=CL_ABAP_TABLEDESCR"});
    let data = INPUT?.data;
    let lv_dummy = new abap.types.Integer({qualifiedName: "I"});
    let lv_flag = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    let lv_str = new abap.types.String({qualifiedName: "STRING"});
    let lv_type = new abap.types.String({qualifiedName: "STRING"});
    let lo_struct = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_STRUCTDESCR", RTTIName: "\\CLASS=CL_ABAP_STRUCTDESCR"});
    let lt_components = abap.types.TableFactory.construct(new abap.types.Structure({"name": new abap.types.String({qualifiedName: "NAME"}), "type": new abap.types.ABAPObject({qualifiedName: "CL_ABAP_DATADESCR", RTTIName: "\\CLASS=CL_ABAP_DATADESCR"}), "as_include": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "suffix": new abap.types.String({qualifiedName: "SUFFIX"})}, "abap_componentdescr", undefined, {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "abap_component_tab");
    let ls_component = new abap.types.Structure({"name": new abap.types.String({qualifiedName: "NAME"}), "type": new abap.types.ABAPObject({qualifiedName: "CL_ABAP_DATADESCR", RTTIName: "\\CLASS=CL_ABAP_DATADESCR"}), "as_include": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "suffix": new abap.types.String({qualifiedName: "SUFFIX"})}, "abap_componentdescr", undefined, {}, {});
    let ls_key = new abap.types.Structure({"name": new abap.types.Character(255, {"qualifiedName":"abap_keyname"})}, "abap_keydescr", undefined, {}, {});
    descr.set(await (new abap.Classes['CL_ABAP_TABLEDESCR']()).constructor_());
    lv_flag.set(data.getOptions()?.primaryKey?.isUnique === true ? "X" : "");
    descr.get().has_unique_key.set(lv_flag);
    lv_type.set(data.getOptions()?.primaryKey?.type || "");
    let unique129 = lv_type;
    if (abap.compare.eq(unique129, new abap.types.Character(8).set('STANDARD'))) {
      descr.get().table_kind.set(cl_abap_tabledescr.tablekind_std);
    } else if (abap.compare.eq(unique129, new abap.types.Character(6).set('SORTED'))) {
      descr.get().table_kind.set(cl_abap_tabledescr.tablekind_sorted);
    } else if (abap.compare.eq(unique129, new abap.types.Character(6).set('HASHED'))) {
      descr.get().table_kind.set(cl_abap_tabledescr.tablekind_hashed);
    } else {
      descr.get().table_kind.set(cl_abap_tabledescr.tablekind_std);
    }
    lv_dummy = data.getRowType();
    descr.get().mo_line_type.set((await abap.Classes['CL_ABAP_TYPEDESCR'].describe_by_data({p_data: lv_dummy})));
    lv_flag.set(data.getOptions()?.primaryKey?.keyFields.length > 0 ? "X" : "");
    if (abap.compare.eq(lv_flag, abap.builtin.abap_true)) {
      descr.get().key_defkind.set(cl_abap_tabledescr.keydefkind_user);
      for (const k of data.getOptions()?.primaryKey?.keyFields) {
        lv_str.set(k);
        ls_key.get().name.set(lv_str);
        abap.statements.append({source: ls_key, target: descr.get().key});
      }
      if (abap.compare.eq(abap.builtin.lines({val: descr.get().key}), abap.IntegerFactory.get(1)) && abap.compare.eq(ls_key.get().name, new abap.types.Character(10).set('TABLE_LINE'))) {
        descr.get().key_defkind.set(cl_abap_tabledescr.keydefkind_tableline);
      }
    } else {
      descr.get().key_defkind.set(cl_abap_tabledescr.keydefkind_default);
      if (abap.compare.eq(descr.get().mo_line_type.get().kind, cl_abap_tabledescr.kind_struct)) {
        await abap.statements.cast(lo_struct, descr.get().mo_line_type);
        lt_components.set((await lo_struct.get().get_components()));
        for await (const unique130 of abap.statements.loop(lt_components)) {
          ls_component.set(unique130);
          ls_key.get().name.set(ls_component.get().name);
          abap.statements.append({source: ls_key, target: descr.get().key});
        }
      }
    }
    return descr;
  }
  async get_table_line_type() {
    let type = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_DATADESCR", RTTIName: "\\CLASS=CL_ABAP_DATADESCR"});
    await abap.statements.cast(type, this.mo_line_type);
    return type;
  }
}
abap.Classes['CL_ABAP_TABLEDESCR'] = cl_abap_tabledescr;
cl_abap_tabledescr.tablekind_any = new abap.types.Character(1, {});
cl_abap_tabledescr.tablekind_any.set('A');
cl_abap_tabledescr.tablekind_std = new abap.types.Character(1, {});
cl_abap_tabledescr.tablekind_std.set('S');
cl_abap_tabledescr.tablekind_index = new abap.types.Character(1, {});
cl_abap_tabledescr.tablekind_index.set('I');
cl_abap_tabledescr.tablekind_hashed = new abap.types.Character(1, {});
cl_abap_tabledescr.tablekind_hashed.set('H');
cl_abap_tabledescr.tablekind_sorted = new abap.types.Character(1, {});
cl_abap_tabledescr.tablekind_sorted.set('O');
cl_abap_tabledescr.keydefkind_default = new abap.types.Character(1, {});
cl_abap_tabledescr.keydefkind_default.set('D');
cl_abap_tabledescr.keydefkind_tableline = new abap.types.Character(1, {});
cl_abap_tabledescr.keydefkind_tableline.set('L');
cl_abap_tabledescr.keydefkind_user = new abap.types.Character(1, {});
cl_abap_tabledescr.keydefkind_user.set('U');
cl_abap_tabledescr.keydefkind_empty = new abap.types.Character(1, {});
cl_abap_tabledescr.keydefkind_empty.set('E');
export {cl_abap_tabledescr};
//# sourceMappingURL=cl_abap_tabledescr.clas.mjs.map