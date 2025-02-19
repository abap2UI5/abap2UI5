const {cx_root} = await import("./cx_root.clas.mjs");
// kernel_create_data_handle.clas.abap
class kernel_create_data_handle {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'KERNEL_CREATE_DATA_HANDLE';
  static IMPLEMENTED_INTERFACES = [];
  static ATTRIBUTES = {};
  static METHODS = {"ELEM": {"visibility": "I", "parameters": {"HANDLE": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "CL_ABAP_DATADESCR", RTTIName: "\\CLASS=CL_ABAP_DATADESCR"});}, "is_optional": " "}, "DREF": {"type": () => {return new abap.types.DataReference(new abap.types.Character(4));}, "is_optional": " "}}},
  "STRUCT": {"visibility": "I", "parameters": {"HANDLE": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "CL_ABAP_DATADESCR", RTTIName: "\\CLASS=CL_ABAP_DATADESCR"});}, "is_optional": " "}, "DREF": {"type": () => {return new abap.types.DataReference(new abap.types.Character(4));}, "is_optional": " "}}},
  "TABLE": {"visibility": "I", "parameters": {"HANDLE": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "CL_ABAP_DATADESCR", RTTIName: "\\CLASS=CL_ABAP_DATADESCR"});}, "is_optional": " "}, "DREF": {"type": () => {return new abap.types.DataReference(new abap.types.Character(4));}, "is_optional": " "}}},
  "REF": {"visibility": "I", "parameters": {"HANDLE": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "CL_ABAP_DATADESCR", RTTIName: "\\CLASS=CL_ABAP_DATADESCR"});}, "is_optional": " "}, "DREF": {"type": () => {return new abap.types.DataReference(new abap.types.Character(4));}, "is_optional": " "}}},
  "CALL": {"visibility": "U", "parameters": {"HANDLE": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "CL_ABAP_DATADESCR", RTTIName: "\\CLASS=CL_ABAP_DATADESCR"});}, "is_optional": " "}, "DREF": {"type": () => {return new abap.types.DataReference(new abap.types.Character(4));}, "is_optional": " "}}}};
  constructor() {
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
  }
  async constructor_(INPUT) {
    if (super.constructor_) { await super.constructor_(INPUT); }
    return this;
  }
  async call(INPUT) {
    return kernel_create_data_handle.call(INPUT);
  }
  static async call(INPUT) {
    let handle = INPUT?.handle;
    if (handle?.getQualifiedName === undefined || handle.getQualifiedName() !== "CL_ABAP_DATADESCR") { handle = undefined; }
    if (handle === undefined) { handle = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_DATADESCR", RTTIName: "\\CLASS=CL_ABAP_DATADESCR"}).set(INPUT.handle); }
    let dref = new abap.types.DataReference(new abap.types.Character(4));
    if (INPUT && INPUT.dref) {dref = INPUT.dref;}
    abap.statements.assert(abap.compare.initial(handle) === false);
    if (dref.constructor.name === "FieldSymbol") {
        dref = dref.getPointer();
    }
    let unique101 = handle.get().kind;
    if (abap.compare.eq(unique101, abap.Classes['CL_ABAP_TYPEDESCR'].kind_elem)) {
      await this.elem({handle: handle, dref: dref});
    } else if (abap.compare.eq(unique101, abap.Classes['CL_ABAP_TYPEDESCR'].kind_struct)) {
      await this.struct({handle: handle, dref: dref});
    } else if (abap.compare.eq(unique101, abap.Classes['CL_ABAP_TYPEDESCR'].kind_table)) {
      await this.table({handle: handle, dref: dref});
    } else if (abap.compare.eq(unique101, abap.Classes['CL_ABAP_TYPEDESCR'].kind_ref)) {
      await this.ref({handle: handle, dref: dref});
    } else {
      console.dir(handle);
      abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    }
  }
  async ref(INPUT) {
    return kernel_create_data_handle.ref(INPUT);
  }
  static async ref(INPUT) {
    let handle = INPUT?.handle;
    if (handle?.getQualifiedName === undefined || handle.getQualifiedName() !== "CL_ABAP_DATADESCR") { handle = undefined; }
    if (handle === undefined) { handle = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_DATADESCR", RTTIName: "\\CLASS=CL_ABAP_DATADESCR"}).set(INPUT.handle); }
    let dref = new abap.types.DataReference(new abap.types.Character(4));
    if (INPUT && INPUT.dref) {dref = INPUT.dref;}
    let lo_ref = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_REFDESCR", RTTIName: "\\CLASS=CL_ABAP_REFDESCR"});
    let lo_data = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_DATADESCR", RTTIName: "\\CLASS=CL_ABAP_DATADESCR"});
    let field = new abap.types.DataReference(new abap.types.Character(4));
    await abap.statements.cast(lo_ref, handle);
    await abap.statements.cast(lo_data, (await lo_ref.get().get_referenced_type()));
    await this.call({handle: lo_data, dref: field});
    dref.assign(new abap.types.DataReference(field.getPointer()));
  }
  async struct(INPUT) {
    return kernel_create_data_handle.struct(INPUT);
  }
  static async struct(INPUT) {
    let handle = INPUT?.handle;
    if (handle?.getQualifiedName === undefined || handle.getQualifiedName() !== "CL_ABAP_DATADESCR") { handle = undefined; }
    if (handle === undefined) { handle = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_DATADESCR", RTTIName: "\\CLASS=CL_ABAP_DATADESCR"}).set(INPUT.handle); }
    let dref = new abap.types.DataReference(new abap.types.Character(4));
    if (INPUT && INPUT.dref) {dref = INPUT.dref;}
    let lo_struct = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_STRUCTDESCR", RTTIName: "\\CLASS=CL_ABAP_STRUCTDESCR"});
    let lt_components = abap.types.TableFactory.construct(new abap.types.Structure({"name": new abap.types.String({qualifiedName: "NAME"}), "type": new abap.types.ABAPObject({qualifiedName: "CL_ABAP_DATADESCR", RTTIName: "\\CLASS=CL_ABAP_DATADESCR"}), "as_include": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "suffix": new abap.types.String({qualifiedName: "SUFFIX"})}, "abap_componentdescr", undefined, {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "abap_component_tab");
    let field = new abap.types.DataReference(new abap.types.Character(4));
    let lv_name = new abap.types.String({qualifiedName: "STRING"});
    let fs_ls_component_ = new abap.types.FieldSymbol(new abap.types.Structure({"name": new abap.types.String({qualifiedName: "NAME"}), "type": new abap.types.ABAPObject({qualifiedName: "CL_ABAP_DATADESCR", RTTIName: "\\CLASS=CL_ABAP_DATADESCR"}), "as_include": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "suffix": new abap.types.String({qualifiedName: "SUFFIX"})}, "abap_componentdescr", undefined, {}, {}));
    await abap.statements.cast(lo_struct, handle);
    lt_components.set((await lo_struct.get().get_components()));
    let obj = {};
    for await (const unique102 of abap.statements.loop(lt_components)) {
      fs_ls_component_.assign(unique102);
      await this.call({handle: (await lo_struct.get().get_component_type({p_name: fs_ls_component_.get().name})), dref: field});
      lv_name.set(abap.builtin.to_lower({val: fs_ls_component_.get().name}));
      obj[lv_name.get()] = field.getPointer();
    }
    dref.assign(new abap.types.Structure(obj));
  }
  async table(INPUT) {
    return kernel_create_data_handle.table(INPUT);
  }
  static async table(INPUT) {
    let handle = INPUT?.handle;
    if (handle?.getQualifiedName === undefined || handle.getQualifiedName() !== "CL_ABAP_DATADESCR") { handle = undefined; }
    if (handle === undefined) { handle = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_DATADESCR", RTTIName: "\\CLASS=CL_ABAP_DATADESCR"}).set(INPUT.handle); }
    let dref = new abap.types.DataReference(new abap.types.Character(4));
    if (INPUT && INPUT.dref) {dref = INPUT.dref;}
    let lo_table = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_TABLEDESCR", RTTIName: "\\CLASS=CL_ABAP_TABLEDESCR"});
    let lt_keys = abap.types.TableFactory.construct(new abap.types.Structure({"components": abap.types.TableFactory.construct(new abap.types.Structure({"name": new abap.types.String({qualifiedName: "NAME"})}, "abap_table_keycompdescr", undefined, {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "abap_table_keydescr-components"), "name": new abap.types.String({qualifiedName: "NAME"}), "is_primary": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "access_kind": new abap.types.String({qualifiedName: "ACCESS_KIND"}), "is_unique": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "key_kind": new abap.types.String({qualifiedName: "KEY_KIND"})}, "abap_table_keydescr", undefined, {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "abap_table_keydescr_tab");
    let lv_component = new abap.types.String({qualifiedName: "STRING"});
    let field = new abap.types.DataReference(new abap.types.Character(4));
    let fs_ls_key_ = new abap.types.FieldSymbol(new abap.types.Structure({"components": abap.types.TableFactory.construct(new abap.types.Structure({"name": new abap.types.String({qualifiedName: "NAME"})}, "abap_table_keycompdescr", undefined, {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "abap_table_keydescr-components"), "name": new abap.types.String({qualifiedName: "NAME"}), "is_primary": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "access_kind": new abap.types.String({qualifiedName: "ACCESS_KIND"}), "is_unique": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "key_kind": new abap.types.String({qualifiedName: "KEY_KIND"})}, "abap_table_keydescr", undefined, {}, {}));
    await abap.statements.cast(lo_table, handle);
    await this.call({handle: (await lo_table.get().get_table_line_type()), dref: field});
    let options = {primaryKey: undefined, keyType: "DEFAULT", withHeader: false};
    options.primaryKey = {name: "primary_key", type: "STANDARD", keyFields: [], isUnique: false};
    lt_keys.set((await lo_table.get().get_keys()));
    for await (const unique103 of abap.statements.loop(lt_keys,{where: async (I) => {return abap.compare.eq(I.is_primary, abap.builtin.abap_true);},topEquals: {"is_primary": abap.builtin.abap_true}})) {
      fs_ls_key_.assign(unique103);
      if (abap.compare.eq(fs_ls_key_.get().access_kind, abap.Classes['CL_ABAP_TABLEDESCR'].tablekind_sorted)) {
        options.primaryKey.type = "SORTED";
      } else if (abap.compare.eq(fs_ls_key_.get().access_kind, abap.Classes['CL_ABAP_TABLEDESCR'].tablekind_hashed)) {
        options.primaryKey.type = "HASHED";
      }
      if (abap.compare.eq(fs_ls_key_.get().is_unique, abap.builtin.abap_true)) {
        options.primaryKey.isUnique = true;
      }
      for await (const unique104 of abap.statements.loop(fs_ls_key_.get().components)) {
        lv_component.set(unique104);
        options.primaryKey.keyFields.push(lv_component.get().toLowerCase());
      }
    }
    dref.assign(abap.types.TableFactory.construct(field.getPointer(), options));
  }
  async elem(INPUT) {
    return kernel_create_data_handle.elem(INPUT);
  }
  static async elem(INPUT) {
    let handle = INPUT?.handle;
    if (handle?.getQualifiedName === undefined || handle.getQualifiedName() !== "CL_ABAP_DATADESCR") { handle = undefined; }
    if (handle === undefined) { handle = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_DATADESCR", RTTIName: "\\CLASS=CL_ABAP_DATADESCR"}).set(INPUT.handle); }
    let dref = new abap.types.DataReference(new abap.types.Character(4));
    if (INPUT && INPUT.dref) {dref = INPUT.dref;}
    let lv_half = new abap.types.Integer({qualifiedName: "I"});
    let unique105 = handle.get().type_kind;
    if (abap.compare.eq(unique105, abap.Classes['CL_ABAP_TYPEDESCR'].typekind_float)) {
      abap.statements.createData(dref,{"typeName": "F"});
    } else if (abap.compare.eq(unique105, abap.Classes['CL_ABAP_TYPEDESCR'].typekind_string)) {
      abap.statements.createData(dref,{"typeName": "STRING"});
    } else if (abap.compare.eq(unique105, abap.Classes['CL_ABAP_TYPEDESCR'].typekind_xstring)) {
      abap.statements.createData(dref,{"typeName": "XSTRING"});
    } else if (abap.compare.eq(unique105, abap.Classes['CL_ABAP_TYPEDESCR'].typekind_int)) {
      abap.statements.createData(dref,{"typeName": "I"});
    } else if (abap.compare.eq(unique105, abap.Classes['CL_ABAP_TYPEDESCR'].typekind_utclong)) {
      abap.statements.createData(dref,{"typeName": "UTCLONG"});
    } else if (abap.compare.eq(unique105, abap.Classes['CL_ABAP_TYPEDESCR'].typekind_date)) {
      abap.statements.createData(dref,{"typeName": "D"});
    } else if (abap.compare.eq(unique105, abap.Classes['CL_ABAP_TYPEDESCR'].typekind_hex)) {
      abap.statements.createData(dref,{"typeName": "X","length": handle.get().length});
    } else if (abap.compare.eq(unique105, abap.Classes['CL_ABAP_TYPEDESCR'].typekind_packed)) {
      abap.statements.createData(dref,{"typeName": "P","length": handle.get().length,"decimals": handle.get().decimals});
    } else if (abap.compare.eq(unique105, abap.Classes['CL_ABAP_TYPEDESCR'].typekind_char)) {
      lv_half.set(abap.operators.divide(handle.get().length,abap.IntegerFactory.get(2)));
      abap.statements.createData(dref,{"typeName": "C","length": lv_half});
      dref.getPointer().extra = {"qualifiedName": handle.get().relative_name};
    } else if (abap.compare.eq(unique105, abap.Classes['CL_ABAP_TYPEDESCR'].typekind_num)) {
      lv_half.set(abap.operators.divide(handle.get().length,abap.IntegerFactory.get(2)));
      abap.statements.createData(dref,{"typeName": "N","length": lv_half});
    } else if (abap.compare.eq(unique105, abap.Classes['CL_ABAP_TYPEDESCR'].typekind_time)) {
      abap.statements.createData(dref,{"typeName": "T"});
    } else if (abap.compare.eq(unique105, abap.Classes['CL_ABAP_TYPEDESCR'].typekind_int8)) {
      abap.statements.createData(dref,{"typeName": "INT8"});
    } else {
      console.dir(handle);
      abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    }
  }
}
abap.Classes['KERNEL_CREATE_DATA_HANDLE'] = kernel_create_data_handle;
export {kernel_create_data_handle};
//# sourceMappingURL=kernel_create_data_handle.clas.mjs.map