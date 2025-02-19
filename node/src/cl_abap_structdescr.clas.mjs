const {cl_abap_complexdescr} = await import("./cl_abap_complexdescr.clas.mjs");
const {cx_root} = await import("./cx_root.clas.mjs");
// cl_abap_structdescr.clas.abap
class cl_abap_structdescr extends cl_abap_complexdescr {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CL_ABAP_STRUCTDESCR';
  static IMPLEMENTED_INTERFACES = [];
  static ATTRIBUTES = {"HAS_INCLUDE": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});}, "visibility": "U", "is_constant": " ", "is_class": " "},
  "COMPONENTS": {"type": () => {return abap.types.TableFactory.construct(new abap.types.Structure({"length": new abap.types.Integer({qualifiedName: "LENGTH"}), "decimals": new abap.types.Integer({qualifiedName: "DECIMALS"}), "type_kind": new abap.types.Character(1, {"qualifiedName":"abap_typekind"}), "name": new abap.types.Character(30, {"qualifiedName":"abap_compname"})}, "abap_compdescr", undefined, {}, {}), {"withHeader":false,"keyType":"USER","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":["NAME"]},"secondary":[]}, "abap_compdescr_tab");}, "visibility": "U", "is_constant": " ", "is_class": " "},
  "STRUCT_KIND": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"abap_structkind"});}, "visibility": "U", "is_constant": " ", "is_class": " "},
  "MT_REFS": {"type": () => {return abap.types.TableFactory.construct(new abap.types.Structure({"name": new abap.types.String({qualifiedName: "NAME"}), "type": new abap.types.ABAPObject({qualifiedName: "CL_ABAP_DATADESCR", RTTIName: "\\CLASS=CL_ABAP_DATADESCR"}), "as_include": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "suffix": new abap.types.String({qualifiedName: "SUFFIX"})}, "abap_componentdescr", undefined, {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "abap_component_tab");}, "visibility": "I", "is_constant": " ", "is_class": " "}};
  static METHODS = {"UPDATE_COMPONENTS": {"visibility": "I", "parameters": {}},
  "CONSTRUCT_FROM_DATA": {"visibility": "U", "parameters": {"DESCR": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "CL_ABAP_STRUCTDESCR", RTTIName: "\\CLASS=CL_ABAP_STRUCTDESCR"});}, "is_optional": " "}, "DATA": {"type": () => {return new abap.types.Character(4);}, "is_optional": " "}}},
  "GET_COMPONENTS": {"visibility": "U", "parameters": {"RT_COMPONENTS": {"type": () => {return abap.types.TableFactory.construct(new abap.types.Structure({"name": new abap.types.String({qualifiedName: "NAME"}), "type": new abap.types.ABAPObject({qualifiedName: "CL_ABAP_DATADESCR", RTTIName: "\\CLASS=CL_ABAP_DATADESCR"}), "as_include": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "suffix": new abap.types.String({qualifiedName: "SUFFIX"})}, "abap_componentdescr", undefined, {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "abap_component_tab");}, "is_optional": " "}}},
  "GET_DDIC_FIELD_LIST": {"visibility": "U", "parameters": {"RT_COMPONENTS": {"type": () => {return abap.types.TableFactory.construct(new abap.types.Structure({"tabname": new abap.types.Character(30, {}), "fieldname": new abap.types.Character(30, {}), "langu": new abap.types.Character(1, {}), "position": new abap.types.Numc({length: 4}), "offset": new abap.types.Numc({length: 6}), "domname": new abap.types.Character(30, {}), "rollname": new abap.types.Character(30, {}), "checktable": new abap.types.Character(1, {}), "leng": new abap.types.Numc({length: 6}), "intlen": new abap.types.Numc({length: 6}), "outputlen": new abap.types.Numc({length: 6}), "decimals": new abap.types.Numc({length: 6}), "datatype": new abap.types.Character(1, {}), "inttype": new abap.types.Character(1, {}), "reftable": new abap.types.Character(1, {}), "reffield": new abap.types.Character(1, {}), "precfield": new abap.types.Character(1, {}), "authorid": new abap.types.Character(1, {}), "memoryid": new abap.types.Character(1, {}), "logflag": new abap.types.Character(1, {}), "mask": new abap.types.Character(20, {}), "masklen": new abap.types.Character(1, {}), "convexit": new abap.types.Character(1, {}), "headlen": new abap.types.Character(1, {}), "scrlen1": new abap.types.Character(1, {}), "scrlen2": new abap.types.Character(1, {}), "scrlen3": new abap.types.Character(1, {}), "fieldtext": new abap.types.Character(1, {}), "reptext": new abap.types.Character(1, {}), "scrtext_s": new abap.types.Character(1, {}), "scrtext_m": new abap.types.Character(1, {}), "scrtext_l": new abap.types.Character(1, {}), "keyflag": new abap.types.Character(1, {}), "lowercase": new abap.types.Character(1, {}), "mac": new abap.types.Character(1, {}), "genkey": new abap.types.Character(1, {}), "noforkey": new abap.types.Character(1, {}), "valexi": new abap.types.Character(1, {}), "noauthch": new abap.types.Character(1, {}), "sign": new abap.types.Character(1, {}), "dynpfld": new abap.types.Character(1, {}), "f4availabl": new abap.types.Character(1, {}), "comptype": new abap.types.Character(1, {}), "outputstyle": new abap.types.Character(1, {}), "lfieldname": new abap.types.Character(132, {})}, "DFIES", "DFIES", {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"isUnique":false,"type":"STANDARD","keyFields":[],"name":"primary_key"},"secondary":[]}, "DDFIELDS");}, "is_optional": " "}, "P_LANGU": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"sy-langu","conversionExit":"ISOLA"});}, "is_optional": " "}, "P_INCLUDING_SUBSTRUCTRES": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});}, "is_optional": " "}}},
  "GET_COMPONENT_TYPE": {"visibility": "U", "parameters": {"P_DESCR_REF": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "CL_ABAP_DATADESCR", RTTIName: "\\CLASS=CL_ABAP_DATADESCR"});}, "is_optional": " "}, "P_NAME": {"type": () => {return new abap.types.Character(4);}, "is_optional": " "}}},
  "GET_INCLUDED_VIEW": {"visibility": "U", "parameters": {"P_RESULT": {"type": () => {return abap.types.TableFactory.construct(new abap.types.Structure({"name": new abap.types.String({qualifiedName: "NAME"}), "type": new abap.types.ABAPObject({qualifiedName: "CL_ABAP_DATADESCR", RTTIName: "\\CLASS=CL_ABAP_DATADESCR"})}, "abap_simple_componentdescr", undefined, {}, {}), {"withHeader":false,"keyType":"USER","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":["NAME"]},"secondary":[]}, "abap_component_view_tab");}, "is_optional": " "}, "P_LEVEL": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}}},
  "GET": {"visibility": "U", "parameters": {"P_RESULT": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "CL_ABAP_STRUCTDESCR", RTTIName: "\\CLASS=CL_ABAP_STRUCTDESCR"});}, "is_optional": " "}, "P_COMPONENTS": {"type": () => {return abap.types.TableFactory.construct(new abap.types.Structure({"name": new abap.types.String({qualifiedName: "NAME"}), "type": new abap.types.ABAPObject({qualifiedName: "CL_ABAP_DATADESCR", RTTIName: "\\CLASS=CL_ABAP_DATADESCR"}), "as_include": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "suffix": new abap.types.String({qualifiedName: "SUFFIX"})}, "abap_componentdescr", undefined, {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "abap_component_tab");}, "is_optional": " "}}},
  "CREATE": {"visibility": "U", "parameters": {"REF": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "CL_ABAP_STRUCTDESCR", RTTIName: "\\CLASS=CL_ABAP_STRUCTDESCR"});}, "is_optional": " "}, "P_COMPONENTS": {"type": () => {return abap.types.TableFactory.construct(new abap.types.Structure({"name": new abap.types.String({qualifiedName: "NAME"}), "type": new abap.types.ABAPObject({qualifiedName: "CL_ABAP_DATADESCR", RTTIName: "\\CLASS=CL_ABAP_DATADESCR"}), "as_include": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "suffix": new abap.types.String({qualifiedName: "SUFFIX"})}, "abap_componentdescr", undefined, {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "abap_component_tab");}, "is_optional": " "}, "P_STRICT": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});}, "is_optional": " "}}},
  "GET_SYMBOLS": {"visibility": "U", "parameters": {"P_RESULT": {"type": () => {return abap.types.TableFactory.construct(new abap.types.Structure({"name": new abap.types.String({qualifiedName: "NAME"}), "type": new abap.types.ABAPObject({qualifiedName: "CL_ABAP_DATADESCR", RTTIName: "\\CLASS=CL_ABAP_DATADESCR"})}, "abap_simple_componentdescr", undefined, {}, {}), {"withHeader":false,"keyType":"USER","primaryKey":{"name":"primary_key","type":"HASHED","isUnique":true,"keyFields":["NAME"]},"secondary":[]}, "abap_component_symbol_tab");}, "is_optional": " "}}}};
  constructor() {
    super();
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
    this.has_include = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    this.components = abap.types.TableFactory.construct(new abap.types.Structure({"length": new abap.types.Integer({qualifiedName: "LENGTH"}), "decimals": new abap.types.Integer({qualifiedName: "DECIMALS"}), "type_kind": new abap.types.Character(1, {"qualifiedName":"abap_typekind"}), "name": new abap.types.Character(30, {"qualifiedName":"abap_compname"})}, "abap_compdescr", undefined, {}, {}), {"withHeader":false,"keyType":"USER","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":["NAME"]},"secondary":[]}, "abap_compdescr_tab");
    this.struct_kind = new abap.types.Character(1, {"qualifiedName":"abap_structkind"});
    this.mt_refs = abap.types.TableFactory.construct(new abap.types.Structure({"name": new abap.types.String({qualifiedName: "NAME"}), "type": new abap.types.ABAPObject({qualifiedName: "CL_ABAP_DATADESCR", RTTIName: "\\CLASS=CL_ABAP_DATADESCR"}), "as_include": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "suffix": new abap.types.String({qualifiedName: "SUFFIX"})}, "abap_componentdescr", undefined, {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "abap_component_tab");
  }
  async constructor_(INPUT) {
    if (super.constructor_) { await super.constructor_(INPUT); }
    return this;
  }
  async get_symbols() {
    let p_result = abap.types.TableFactory.construct(new abap.types.Structure({"name": new abap.types.String({qualifiedName: "NAME"}), "type": new abap.types.ABAPObject({qualifiedName: "CL_ABAP_DATADESCR", RTTIName: "\\CLASS=CL_ABAP_DATADESCR"})}, "abap_simple_componentdescr", undefined, {}, {}), {"withHeader":false,"keyType":"USER","primaryKey":{"name":"primary_key","type":"HASHED","isUnique":true,"keyFields":["NAME"]},"secondary":[]}, "abap_component_symbol_tab");
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return p_result;
  }
  async get(INPUT) {
    return cl_abap_structdescr.get(INPUT);
  }
  static async get(INPUT) {
    let p_result = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_STRUCTDESCR", RTTIName: "\\CLASS=CL_ABAP_STRUCTDESCR"});
    let p_components = INPUT?.p_components;
    if (p_components?.getQualifiedName === undefined || p_components.getQualifiedName() !== "ABAP_COMPONENT_TAB") { p_components = undefined; }
    if (p_components === undefined) { p_components = abap.types.TableFactory.construct(new abap.types.Structure({"name": new abap.types.String({qualifiedName: "NAME"}), "type": new abap.types.ABAPObject({qualifiedName: "CL_ABAP_DATADESCR", RTTIName: "\\CLASS=CL_ABAP_DATADESCR"}), "as_include": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "suffix": new abap.types.String({qualifiedName: "SUFFIX"})}, "abap_componentdescr", undefined, {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "abap_component_tab").set(INPUT.p_components); }
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return p_result;
  }
  async create(INPUT) {
    return cl_abap_structdescr.create(INPUT);
  }
  static async create(INPUT) {
    let ref = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_STRUCTDESCR", RTTIName: "\\CLASS=CL_ABAP_STRUCTDESCR"});
    let p_components = INPUT?.p_components;
    if (p_components?.getQualifiedName === undefined || p_components.getQualifiedName() !== "ABAP_COMPONENT_TAB") { p_components = undefined; }
    if (p_components === undefined) { p_components = abap.types.TableFactory.construct(new abap.types.Structure({"name": new abap.types.String({qualifiedName: "NAME"}), "type": new abap.types.ABAPObject({qualifiedName: "CL_ABAP_DATADESCR", RTTIName: "\\CLASS=CL_ABAP_DATADESCR"}), "as_include": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "suffix": new abap.types.String({qualifiedName: "SUFFIX"})}, "abap_componentdescr", undefined, {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "abap_component_tab").set(INPUT.p_components); }
    let p_strict = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    if (INPUT && INPUT.p_strict) {p_strict.set(INPUT.p_strict);}
    let ls_component = new abap.types.Structure({"name": new abap.types.String({qualifiedName: "NAME"}), "type": new abap.types.ABAPObject({qualifiedName: "CL_ABAP_DATADESCR", RTTIName: "\\CLASS=CL_ABAP_DATADESCR"}), "as_include": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "suffix": new abap.types.String({qualifiedName: "SUFFIX"})}, "abap_componentdescr", undefined, {}, {});
    let ls_ref = new abap.types.Structure({"name": new abap.types.String({qualifiedName: "NAME"}), "type": new abap.types.ABAPObject({qualifiedName: "CL_ABAP_DATADESCR", RTTIName: "\\CLASS=CL_ABAP_DATADESCR"}), "as_include": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "suffix": new abap.types.String({qualifiedName: "SUFFIX"})}, "abap_componentdescr", undefined, {}, {});
    if (abap.compare.eq(abap.builtin.lines({val: p_components}), abap.IntegerFactory.get(0))) {
      const unique120 = await (new abap.Classes['CX_SY_STRUCT_ATTRIBUTES']()).constructor_();
      unique120.EXTRA_CX = {"INTERNAL_FILENAME": "cl_abap_structdescr.clas.abap","INTERNAL_LINE": 89};
      throw unique120;
    }
    for await (const unique121 of abap.statements.loop(p_components)) {
      ls_component.set(unique121);
      if (abap.compare.initial(ls_component.get().name)) {
        const unique122 = await (new abap.Classes['CX_SY_STRUCT_COMP_NAME']()).constructor_();
        unique122.EXTRA_CX = {"INTERNAL_FILENAME": "cl_abap_structdescr.clas.abap","INTERNAL_LINE": 94};
        throw unique122;
      } else if (abap.compare.initial(ls_component.get().type)) {
        const unique123 = await (new abap.Classes['CX_SY_STRUCT_COMP_TYPE']()).constructor_();
        unique123.EXTRA_CX = {"INTERNAL_FILENAME": "cl_abap_structdescr.clas.abap","INTERNAL_LINE": 96};
        throw unique123;
      } else if (abap.compare.gt(abap.builtin.strlen({val: ls_component.get().name}), abap.IntegerFactory.get(30))) {
        const unique124 = await (new abap.Classes['CX_SY_STRUCT_COMP_NAME']()).constructor_();
        unique124.EXTRA_CX = {"INTERNAL_FILENAME": "cl_abap_structdescr.clas.abap","INTERNAL_LINE": 98};
        throw unique124;
      }
    }
    ref.set(await (new abap.Classes['CL_ABAP_STRUCTDESCR']()).constructor_());
    for await (const unique125 of abap.statements.loop(p_components)) {
      ls_component.set(unique125);
      abap.statements.clear(ls_ref);
      ls_ref.get().name.set(ls_component.get().name);
      ls_ref.get().type.set(ls_component.get().type);
      abap.statements.append({source: ls_ref, target: ref.get().mt_refs});
    }
    await ref.get().update_components();
    ref.get().type_kind.set(cl_abap_structdescr.typekind_struct2);
    ref.get().kind.set(cl_abap_structdescr.kind_struct);
    return ref;
  }
  async get_included_view(INPUT) {
    let p_result = abap.types.TableFactory.construct(new abap.types.Structure({"name": new abap.types.String({qualifiedName: "NAME"}), "type": new abap.types.ABAPObject({qualifiedName: "CL_ABAP_DATADESCR", RTTIName: "\\CLASS=CL_ABAP_DATADESCR"})}, "abap_simple_componentdescr", undefined, {}, {}), {"withHeader":false,"keyType":"USER","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":["NAME"]},"secondary":[]}, "abap_component_view_tab");
    let p_level = new abap.types.Integer({qualifiedName: "I"});
    if (INPUT && INPUT.p_level) {p_level.set(INPUT.p_level);}
    let ls_component = new abap.types.Structure({"length": new abap.types.Integer({qualifiedName: "LENGTH"}), "decimals": new abap.types.Integer({qualifiedName: "DECIMALS"}), "type_kind": new abap.types.Character(1, {"qualifiedName":"abap_typekind"}), "name": new abap.types.Character(30, {"qualifiedName":"abap_compname"})}, "abap_compdescr", undefined, {}, {});
    let ls_view = new abap.types.Structure({"name": new abap.types.String({qualifiedName: "NAME"}), "type": new abap.types.ABAPObject({qualifiedName: "CL_ABAP_DATADESCR", RTTIName: "\\CLASS=CL_ABAP_DATADESCR"})}, "abap_simple_componentdescr", undefined, {}, {});
    let ls_ref = new abap.types.Structure({"name": new abap.types.String({qualifiedName: "NAME"}), "type": new abap.types.ABAPObject({qualifiedName: "CL_ABAP_DATADESCR", RTTIName: "\\CLASS=CL_ABAP_DATADESCR"}), "as_include": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "suffix": new abap.types.String({qualifiedName: "SUFFIX"})}, "abap_componentdescr", undefined, {}, {});
    for await (const unique126 of abap.statements.loop(this.components)) {
      ls_component.set(unique126);
      abap.statements.clear(ls_view);
      ls_view.get().name.set(ls_component.get().name);
      abap.statements.readTable(this.mt_refs,{into: ls_ref,
        withKey: (i) => {return abap.compare.eq(i.name, ls_component.get().name);},
        withKeyValue: [{key: (i) => {return i.name}, value: ls_component.get().name}],
        usesTableLine: false,
        withKeySimple: {"name": ls_component.get().name}});
      if (abap.compare.eq(abap.builtin.sy.get().subrc, abap.IntegerFactory.get(0))) {
        ls_view.get().type.set(ls_ref.get().type);
      }
      if (abap.compare.eq(ls_ref.get().as_include, abap.builtin.abap_true)) {
        continue;
      }
      abap.statements.insertInternal({data: ls_view, table: p_result});
    }
    return p_result;
  }
  async get_ddic_field_list(INPUT) {
    let rt_components = abap.types.TableFactory.construct(new abap.types.Structure({"tabname": new abap.types.Character(30, {}), "fieldname": new abap.types.Character(30, {}), "langu": new abap.types.Character(1, {}), "position": new abap.types.Numc({length: 4}), "offset": new abap.types.Numc({length: 6}), "domname": new abap.types.Character(30, {}), "rollname": new abap.types.Character(30, {}), "checktable": new abap.types.Character(1, {}), "leng": new abap.types.Numc({length: 6}), "intlen": new abap.types.Numc({length: 6}), "outputlen": new abap.types.Numc({length: 6}), "decimals": new abap.types.Numc({length: 6}), "datatype": new abap.types.Character(1, {}), "inttype": new abap.types.Character(1, {}), "reftable": new abap.types.Character(1, {}), "reffield": new abap.types.Character(1, {}), "precfield": new abap.types.Character(1, {}), "authorid": new abap.types.Character(1, {}), "memoryid": new abap.types.Character(1, {}), "logflag": new abap.types.Character(1, {}), "mask": new abap.types.Character(20, {}), "masklen": new abap.types.Character(1, {}), "convexit": new abap.types.Character(1, {}), "headlen": new abap.types.Character(1, {}), "scrlen1": new abap.types.Character(1, {}), "scrlen2": new abap.types.Character(1, {}), "scrlen3": new abap.types.Character(1, {}), "fieldtext": new abap.types.Character(1, {}), "reptext": new abap.types.Character(1, {}), "scrtext_s": new abap.types.Character(1, {}), "scrtext_m": new abap.types.Character(1, {}), "scrtext_l": new abap.types.Character(1, {}), "keyflag": new abap.types.Character(1, {}), "lowercase": new abap.types.Character(1, {}), "mac": new abap.types.Character(1, {}), "genkey": new abap.types.Character(1, {}), "noforkey": new abap.types.Character(1, {}), "valexi": new abap.types.Character(1, {}), "noauthch": new abap.types.Character(1, {}), "sign": new abap.types.Character(1, {}), "dynpfld": new abap.types.Character(1, {}), "f4availabl": new abap.types.Character(1, {}), "comptype": new abap.types.Character(1, {}), "outputstyle": new abap.types.Character(1, {}), "lfieldname": new abap.types.Character(132, {})}, "DFIES", "DFIES", {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"isUnique":false,"type":"STANDARD","keyFields":[],"name":"primary_key"},"secondary":[]}, "DDFIELDS");
    let p_langu = new abap.types.Character(1, {"qualifiedName":"sy-langu","conversionExit":"ISOLA"});
    if (INPUT && INPUT.p_langu) {p_langu.set(INPUT.p_langu);}
    if (INPUT === undefined || INPUT.p_langu === undefined) {p_langu = abap.builtin.sy.get().langu;}
    let p_including_substructres = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    if (INPUT && INPUT.p_including_substructres) {p_including_substructres.set(INPUT.p_including_substructres);}
    if (INPUT === undefined || INPUT.p_including_substructres === undefined) {p_including_substructres = abap.builtin.abap_false;}
    let lt_components = abap.types.TableFactory.construct(new abap.types.Structure({"name": new abap.types.String({qualifiedName: "NAME"}), "type": new abap.types.ABAPObject({qualifiedName: "CL_ABAP_DATADESCR", RTTIName: "\\CLASS=CL_ABAP_DATADESCR"}), "as_include": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "suffix": new abap.types.String({qualifiedName: "SUFFIX"})}, "abap_componentdescr", undefined, {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "abap_component_tab");
    let ls_component = new abap.types.Structure({"name": new abap.types.String({qualifiedName: "NAME"}), "type": new abap.types.ABAPObject({qualifiedName: "CL_ABAP_DATADESCR", RTTIName: "\\CLASS=CL_ABAP_DATADESCR"}), "as_include": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "suffix": new abap.types.String({qualifiedName: "SUFFIX"})}, "abap_componentdescr", undefined, {}, {});
    let ls_return = new abap.types.Structure({"tabname": new abap.types.Character(30, {}), "fieldname": new abap.types.Character(30, {}), "langu": new abap.types.Character(1, {}), "position": new abap.types.Numc({length: 4}), "offset": new abap.types.Numc({length: 6}), "domname": new abap.types.Character(30, {}), "rollname": new abap.types.Character(30, {}), "checktable": new abap.types.Character(1, {}), "leng": new abap.types.Numc({length: 6}), "intlen": new abap.types.Numc({length: 6}), "outputlen": new abap.types.Numc({length: 6}), "decimals": new abap.types.Numc({length: 6}), "datatype": new abap.types.Character(1, {}), "inttype": new abap.types.Character(1, {}), "reftable": new abap.types.Character(1, {}), "reffield": new abap.types.Character(1, {}), "precfield": new abap.types.Character(1, {}), "authorid": new abap.types.Character(1, {}), "memoryid": new abap.types.Character(1, {}), "logflag": new abap.types.Character(1, {}), "mask": new abap.types.Character(20, {}), "masklen": new abap.types.Character(1, {}), "convexit": new abap.types.Character(1, {}), "headlen": new abap.types.Character(1, {}), "scrlen1": new abap.types.Character(1, {}), "scrlen2": new abap.types.Character(1, {}), "scrlen3": new abap.types.Character(1, {}), "fieldtext": new abap.types.Character(1, {}), "reptext": new abap.types.Character(1, {}), "scrtext_s": new abap.types.Character(1, {}), "scrtext_m": new abap.types.Character(1, {}), "scrtext_l": new abap.types.Character(1, {}), "keyflag": new abap.types.Character(1, {}), "lowercase": new abap.types.Character(1, {}), "mac": new abap.types.Character(1, {}), "genkey": new abap.types.Character(1, {}), "noforkey": new abap.types.Character(1, {}), "valexi": new abap.types.Character(1, {}), "noauthch": new abap.types.Character(1, {}), "sign": new abap.types.Character(1, {}), "dynpfld": new abap.types.Character(1, {}), "f4availabl": new abap.types.Character(1, {}), "comptype": new abap.types.Character(1, {}), "outputstyle": new abap.types.Character(1, {}), "lfieldname": new abap.types.Character(132, {})}, "DFIES", "DFIES", {}, {});
    let lv_name = new abap.types.String({qualifiedName: "STRING"});
    let lv_keyfield = new abap.types.String({qualifiedName: "STRING"});
    let lo_elemdescr = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_ELEMDESCR", RTTIName: "\\CLASS=CL_ABAP_ELEMDESCR"});
    let fs_component_ = new abap.types.FieldSymbol(new abap.types.Structure({"tabname": new abap.types.Character(30, {}), "fieldname": new abap.types.Character(30, {}), "langu": new abap.types.Character(1, {}), "position": new abap.types.Numc({length: 4}), "offset": new abap.types.Numc({length: 6}), "domname": new abap.types.Character(30, {}), "rollname": new abap.types.Character(30, {}), "checktable": new abap.types.Character(1, {}), "leng": new abap.types.Numc({length: 6}), "intlen": new abap.types.Numc({length: 6}), "outputlen": new abap.types.Numc({length: 6}), "decimals": new abap.types.Numc({length: 6}), "datatype": new abap.types.Character(1, {}), "inttype": new abap.types.Character(1, {}), "reftable": new abap.types.Character(1, {}), "reffield": new abap.types.Character(1, {}), "precfield": new abap.types.Character(1, {}), "authorid": new abap.types.Character(1, {}), "memoryid": new abap.types.Character(1, {}), "logflag": new abap.types.Character(1, {}), "mask": new abap.types.Character(20, {}), "masklen": new abap.types.Character(1, {}), "convexit": new abap.types.Character(1, {}), "headlen": new abap.types.Character(1, {}), "scrlen1": new abap.types.Character(1, {}), "scrlen2": new abap.types.Character(1, {}), "scrlen3": new abap.types.Character(1, {}), "fieldtext": new abap.types.Character(1, {}), "reptext": new abap.types.Character(1, {}), "scrtext_s": new abap.types.Character(1, {}), "scrtext_m": new abap.types.Character(1, {}), "scrtext_l": new abap.types.Character(1, {}), "keyflag": new abap.types.Character(1, {}), "lowercase": new abap.types.Character(1, {}), "mac": new abap.types.Character(1, {}), "genkey": new abap.types.Character(1, {}), "noforkey": new abap.types.Character(1, {}), "valexi": new abap.types.Character(1, {}), "noauthch": new abap.types.Character(1, {}), "sign": new abap.types.Character(1, {}), "dynpfld": new abap.types.Character(1, {}), "f4availabl": new abap.types.Character(1, {}), "comptype": new abap.types.Character(1, {}), "outputstyle": new abap.types.Character(1, {}), "lfieldname": new abap.types.Character(132, {})}, "DFIES", "DFIES", {}, {}));
    lt_components.set((await this.get_components()));
    abap.statements.assert(abap.compare.cp(this.absolute_name, new abap.types.Character(7).set('+TYPE=*')));
    lv_name.set(this.absolute_name.getOffset({offset: 6}));
    for await (const unique127 of abap.statements.loop(lt_components)) {
      ls_component.set(unique127);
      abap.statements.clear(ls_return);
      ls_return.get().tabname.set(lv_name);
      ls_return.get().fieldname.set(ls_component.get().name);
      if (abap.compare.eq(ls_component.get().type.get().kind, abap.Classes['CL_ABAP_TYPEDESCR'].kind_elem)) {
        await abap.statements.cast(lo_elemdescr, ls_component.get().type);
        ls_return.get().leng.set(lo_elemdescr.get().output_length);
      }
      abap.statements.append({source: ls_return, target: rt_components});
    }
    for (const keyfield of abap.DDIC[lv_name.get()]?.keyFields || [] ) {
      lv_keyfield.set(keyfield);
      abap.statements.readTable(rt_components,{assigning: fs_component_,
        withKey: (i) => {return abap.compare.eq(i.fieldname, lv_keyfield);},
        withKeyValue: [{key: (i) => {return i.fieldname}, value: lv_keyfield}],
        usesTableLine: false,
        withKeySimple: {"fieldname": lv_keyfield}});
      abap.statements.assert(abap.compare.eq(abap.builtin.sy.get().subrc, abap.IntegerFactory.get(0)));
      fs_component_.get().keyflag.set(abap.builtin.abap_true);
    }
    return rt_components;
  }
  async construct_from_data(INPUT) {
    return cl_abap_structdescr.construct_from_data(INPUT);
  }
  static async construct_from_data(INPUT) {
    let descr = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_STRUCTDESCR", RTTIName: "\\CLASS=CL_ABAP_STRUCTDESCR"});
    let data = INPUT?.data;
    let lv_name = new abap.types.String({qualifiedName: "STRING"});
    let ls_ref = new abap.types.Structure({"name": new abap.types.String({qualifiedName: "NAME"}), "type": new abap.types.ABAPObject({qualifiedName: "CL_ABAP_DATADESCR", RTTIName: "\\CLASS=CL_ABAP_DATADESCR"}), "as_include": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "suffix": new abap.types.String({qualifiedName: "SUFFIX"})}, "abap_componentdescr", undefined, {}, {});
    let lv_suffix = new abap.types.String({qualifiedName: "STRING"});
    let lv_as_include = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    let lo_datadescr = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_DATADESCR", RTTIName: "\\CLASS=CL_ABAP_DATADESCR"});
    let fs_fs_ = new abap.types.FieldSymbol(new abap.types.Character(4));
    descr.set(await (new abap.Classes['CL_ABAP_STRUCTDESCR']()).constructor_());
    for (const name of Object.keys(INPUT.data.value)) {
        lv_name.set(name.toUpperCase());
      abap.statements.assign({component: lv_name, target: fs_fs_, source: data});
      await abap.statements.cast(lo_datadescr, (await abap.Classes['CL_ABAP_TYPEDESCR'].describe_by_data({p_data: fs_fs_})));
      ls_ref.get().name.set(lv_name);
      ls_ref.get().type.set(lo_datadescr);
      if (INPUT.data?.getAsInclude) {
          lv_as_include.set(INPUT.data?.getAsInclude()?.[name.toLowerCase()] ? "X" : " ");
      }
      ls_ref.get().as_include.set(lv_as_include);
      if (INPUT.data?.getSuffix) {
          lv_as_include.set(INPUT.data?.getSuffix()?.[name.toLowerCase()] || "");
      }
      ls_ref.get().suffix.set(lv_suffix);
      abap.statements.append({source: ls_ref, target: descr.get().mt_refs});
    }
    await descr.get().update_components();
    return descr;
  }
  async update_components() {
    let ls_component = new abap.types.Structure({"length": new abap.types.Integer({qualifiedName: "LENGTH"}), "decimals": new abap.types.Integer({qualifiedName: "DECIMALS"}), "type_kind": new abap.types.Character(1, {"qualifiedName":"abap_typekind"}), "name": new abap.types.Character(30, {"qualifiedName":"abap_compname"})}, "abap_compdescr", undefined, {}, {});
    let fs_ls_ref_ = new abap.types.FieldSymbol(new abap.types.Structure({"name": new abap.types.String({qualifiedName: "NAME"}), "type": new abap.types.ABAPObject({qualifiedName: "CL_ABAP_DATADESCR", RTTIName: "\\CLASS=CL_ABAP_DATADESCR"}), "as_include": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "suffix": new abap.types.String({qualifiedName: "SUFFIX"})}, "abap_componentdescr", undefined, {}, {}));
    abap.statements.clear(this.components);
    for await (const unique128 of abap.statements.loop(this.mt_refs)) {
      fs_ls_ref_.assign(unique128);
      ls_component.get().name.set(fs_ls_ref_.get().name);
      ls_component.get().type_kind.set(fs_ls_ref_.get().type.get().type_kind);
      ls_component.get().length.set(fs_ls_ref_.get().type.get().length);
      ls_component.get().decimals.set(fs_ls_ref_.get().type.get().decimals);
      abap.statements.append({source: ls_component, target: this.components});
    }
  }
  async get_components() {
    let rt_components = abap.types.TableFactory.construct(new abap.types.Structure({"name": new abap.types.String({qualifiedName: "NAME"}), "type": new abap.types.ABAPObject({qualifiedName: "CL_ABAP_DATADESCR", RTTIName: "\\CLASS=CL_ABAP_DATADESCR"}), "as_include": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "suffix": new abap.types.String({qualifiedName: "SUFFIX"})}, "abap_componentdescr", undefined, {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "abap_component_tab");
    rt_components.set(this.mt_refs);
    return rt_components;
  }
  async get_component_type(INPUT) {
    let p_descr_ref = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_DATADESCR", RTTIName: "\\CLASS=CL_ABAP_DATADESCR"});
    let p_name = INPUT?.p_name;
    let fs_line_ = new abap.types.FieldSymbol(new abap.types.Structure({"name": new abap.types.String({qualifiedName: "NAME"}), "type": new abap.types.ABAPObject({qualifiedName: "CL_ABAP_DATADESCR", RTTIName: "\\CLASS=CL_ABAP_DATADESCR"}), "as_include": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "suffix": new abap.types.String({qualifiedName: "SUFFIX"})}, "abap_componentdescr", undefined, {}, {}));
    abap.statements.readTable(this.mt_refs,{assigning: fs_line_,
      withKey: (i) => {return abap.compare.eq(i.name, p_name);},
      withKeyValue: [{key: (i) => {return i.name}, value: p_name}],
      usesTableLine: false,
      withKeySimple: {"name": p_name}});
    if (abap.compare.ne(abap.builtin.sy.get().subrc, abap.IntegerFactory.get(0))) {
      throw new abap.ClassicError({classic: "component_not_found"});
    } else {
      p_descr_ref.set(fs_line_.get().type);
    }
    return p_descr_ref;
  }
}
abap.Classes['CL_ABAP_STRUCTDESCR'] = cl_abap_structdescr;
cl_abap_structdescr.component = new abap.types.Structure({"name": new abap.types.String({qualifiedName: "NAME"}), "type": new abap.types.ABAPObject({qualifiedName: "CL_ABAP_DATADESCR", RTTIName: "\\CLASS=CL_ABAP_DATADESCR"}), "as_include": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "suffix": new abap.types.String({qualifiedName: "SUFFIX"})}, "abap_componentdescr", undefined, {}, {});
cl_abap_structdescr.component_table = abap.types.TableFactory.construct(new abap.types.Structure({"name": new abap.types.String({qualifiedName: "NAME"}), "type": new abap.types.ABAPObject({qualifiedName: "CL_ABAP_DATADESCR", RTTIName: "\\CLASS=CL_ABAP_DATADESCR"}), "as_include": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "suffix": new abap.types.String({qualifiedName: "SUFFIX"})}, "abap_componentdescr", undefined, {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "abap_component_tab");
cl_abap_structdescr.included_view = abap.types.TableFactory.construct(new abap.types.Structure({"name": new abap.types.String({qualifiedName: "NAME"}), "type": new abap.types.ABAPObject({qualifiedName: "CL_ABAP_DATADESCR", RTTIName: "\\CLASS=CL_ABAP_DATADESCR"})}, "abap_simple_componentdescr", undefined, {}, {}), {"withHeader":false,"keyType":"USER","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":["NAME"]},"secondary":[]}, "abap_component_view_tab");
cl_abap_structdescr.symbol_table = abap.types.TableFactory.construct(new abap.types.Structure({"name": new abap.types.String({qualifiedName: "NAME"}), "type": new abap.types.ABAPObject({qualifiedName: "CL_ABAP_DATADESCR", RTTIName: "\\CLASS=CL_ABAP_DATADESCR"})}, "abap_simple_componentdescr", undefined, {}, {}), {"withHeader":false,"keyType":"USER","primaryKey":{"name":"primary_key","type":"HASHED","isUnique":true,"keyFields":["NAME"]},"secondary":[]}, "abap_component_symbol_tab");
export {cl_abap_structdescr};
//# sourceMappingURL=cl_abap_structdescr.clas.mjs.map