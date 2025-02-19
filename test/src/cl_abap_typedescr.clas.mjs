const {cx_root} = await import("./cx_root.clas.mjs");
// cl_abap_typedescr.clas.abap
class cl_abap_typedescr {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CL_ABAP_TYPEDESCR';
  static IMPLEMENTED_INTERFACES = [];
  static ATTRIBUTES = {"GV_COUNTER": {"type": () => {return new abap.types.Numc({length: 10});}, "visibility": "I", "is_constant": " ", "is_class": "X"},
  "TYPE_KIND": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"abap_typekind"});}, "visibility": "U", "is_constant": " ", "is_class": " "},
  "KIND": {"type": () => {return new abap.types.Character(1, {});}, "visibility": "U", "is_constant": " ", "is_class": " "},
  "DDIC": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});}, "visibility": "U", "is_constant": " ", "is_class": " "},
  "LENGTH": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": " ", "is_class": " "},
  "DECIMALS": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": " ", "is_class": " "},
  "ABSOLUTE_NAME": {"type": () => {return new abap.types.Character(200, {"qualifiedName":"abap_abstypename"});}, "visibility": "U", "is_constant": " ", "is_class": " "},
  "RELATIVE_NAME": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "visibility": "U", "is_constant": " ", "is_class": " "},
  "TYPEKIND_ANY": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"abap_typekind"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "TYPEKIND_CHAR": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"abap_typekind"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "TYPEKIND_CLASS": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"abap_typekind"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "TYPEKIND_CLIKE": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"abap_typekind"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "TYPEKIND_CSEQUENCE": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"abap_typekind"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "TYPEKIND_DATA": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"abap_typekind"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "TYPEKIND_DATE": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"abap_typekind"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "TYPEKIND_DECFLOAT": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"abap_typekind"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "TYPEKIND_DECFLOAT16": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"abap_typekind"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "TYPEKIND_DECFLOAT34": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"abap_typekind"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "TYPEKIND_DREF": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"abap_typekind"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "TYPEKIND_ENUM": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"abap_typekind"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "TYPEKIND_FLOAT": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"abap_typekind"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "TYPEKIND_HEX": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"abap_typekind"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "TYPEKIND_INT": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"abap_typekind"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "TYPEKIND_INT1": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"abap_typekind"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "TYPEKIND_INT2": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"abap_typekind"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "TYPEKIND_INT8": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"abap_typekind"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "TYPEKIND_INTF": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"abap_typekind"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "TYPEKIND_IREF": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"abap_typekind"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "TYPEKIND_NUM": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"abap_typekind"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "TYPEKIND_NUMERIC": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"abap_typekind"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "TYPEKIND_OREF": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"abap_typekind"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "TYPEKIND_PACKED": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"abap_typekind"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "TYPEKIND_SIMPLE": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"abap_typekind"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "TYPEKIND_STRING": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"abap_typekind"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "TYPEKIND_STRUCT1": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"abap_typekind"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "TYPEKIND_STRUCT2": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"abap_typekind"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "TYPEKIND_TABLE": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"abap_typekind"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "TYPEKIND_TIME": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"abap_typekind"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "TYPEKIND_UTCLONG": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"abap_typekind"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "TYPEKIND_W": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"abap_typekind"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "TYPEKIND_XSTRING": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"abap_typekind"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "KIND_ELEM": {"type": () => {return new abap.types.Character(1, {});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "KIND_STRUCT": {"type": () => {return new abap.types.Character(1, {});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "KIND_TABLE": {"type": () => {return new abap.types.Character(1, {});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "KIND_REF": {"type": () => {return new abap.types.Character(1, {});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "KIND_CLASS": {"type": () => {return new abap.types.Character(1, {});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "KIND_INTF": {"type": () => {return new abap.types.Character(1, {});}, "visibility": "U", "is_constant": "X", "is_class": "X"}};
  static METHODS = {"DESCRIBE_BY_DASHES": {"visibility": "I", "parameters": {"TYPE": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "CL_ABAP_TYPEDESCR", RTTIName: "\\CLASS=CL_ABAP_TYPEDESCR"});}, "is_optional": " "}, "P_NAME": {"type": () => {return new abap.types.Character();}, "is_optional": " "}}},
  "IS_DEEP": {"visibility": "I", "parameters": {"RV_DEEP": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});}, "is_optional": " "}, "IO_STRUCT": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "CL_ABAP_STRUCTDESCR", RTTIName: "\\CLASS=CL_ABAP_STRUCTDESCR"});}, "is_optional": " "}}},
  "DESCRIBE_BY_DATA": {"visibility": "U", "parameters": {"TYPE": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "CL_ABAP_TYPEDESCR", RTTIName: "\\CLASS=CL_ABAP_TYPEDESCR"});}, "is_optional": " "}, "P_DATA": {"type": () => {return new abap.types.Character(4);}, "is_optional": " "}}},
  "DESCRIBE_BY_NAME": {"visibility": "U", "parameters": {"TYPE": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "CL_ABAP_TYPEDESCR", RTTIName: "\\CLASS=CL_ABAP_TYPEDESCR"});}, "is_optional": " "}, "P_NAME": {"type": () => {return new abap.types.Character();}, "is_optional": " "}}},
  "DESCRIBE_BY_DATA_REF": {"visibility": "U", "parameters": {"TYPE": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "CL_ABAP_TYPEDESCR", RTTIName: "\\CLASS=CL_ABAP_TYPEDESCR"});}, "is_optional": " "}, "P_DATA_REF": {"type": () => {return new abap.types.DataReference(new abap.types.Character(4));}, "is_optional": " "}}},
  "DESCRIBE_BY_OBJECT_REF": {"visibility": "U", "parameters": {"P_DESCR_REF": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "CL_ABAP_TYPEDESCR", RTTIName: "\\CLASS=CL_ABAP_TYPEDESCR"});}, "is_optional": " "}, "P_OBJECT_REF": {"type": () => {return new abap.types.ABAPObject({qualifiedName: undefined, RTTIName: undefined});}, "is_optional": " "}}},
  "GET_DDIC_HEADER": {"visibility": "U", "parameters": {"P_HEADER": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});}, "is_optional": " "}}},
  "GET_RELATIVE_NAME": {"visibility": "U", "parameters": {"NAME": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}},
  "IS_DDIC_TYPE": {"visibility": "U", "parameters": {"P_ABAP_BOOL": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});}, "is_optional": " "}}},
  "IS_INSTANTIATABLE": {"visibility": "U", "parameters": {"P_RESULT": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});}, "is_optional": " "}}},
  "GET_DDIC_OBJECT": {"visibility": "U", "parameters": {"P_OBJECT": {"type": () => {return abap.types.TableFactory.construct(new abap.types.String({qualifiedName: "STRING"}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"isUnique":false,"type":"STANDARD","keyFields":[],"name":"primary_key"},"secondary":[]}, "STRING_TABLE");}, "is_optional": " "}}}};
  constructor() {
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
    this.gv_counter = cl_abap_typedescr.gv_counter;
    this.type_kind = new abap.types.Character(1, {"qualifiedName":"abap_typekind"});
    this.kind = new abap.types.Character(1, {});
    this.ddic = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    this.length = new abap.types.Integer({qualifiedName: "I"});
    this.decimals = new abap.types.Integer({qualifiedName: "I"});
    this.absolute_name = new abap.types.Character(200, {"qualifiedName":"abap_abstypename"});
    this.relative_name = new abap.types.String({qualifiedName: "STRING"});
    this.typekind_any = cl_abap_typedescr.typekind_any;
    this.typekind_char = cl_abap_typedescr.typekind_char;
    this.typekind_class = cl_abap_typedescr.typekind_class;
    this.typekind_clike = cl_abap_typedescr.typekind_clike;
    this.typekind_csequence = cl_abap_typedescr.typekind_csequence;
    this.typekind_data = cl_abap_typedescr.typekind_data;
    this.typekind_date = cl_abap_typedescr.typekind_date;
    this.typekind_decfloat = cl_abap_typedescr.typekind_decfloat;
    this.typekind_decfloat16 = cl_abap_typedescr.typekind_decfloat16;
    this.typekind_decfloat34 = cl_abap_typedescr.typekind_decfloat34;
    this.typekind_dref = cl_abap_typedescr.typekind_dref;
    this.typekind_enum = cl_abap_typedescr.typekind_enum;
    this.typekind_float = cl_abap_typedescr.typekind_float;
    this.typekind_hex = cl_abap_typedescr.typekind_hex;
    this.typekind_int = cl_abap_typedescr.typekind_int;
    this.typekind_int1 = cl_abap_typedescr.typekind_int1;
    this.typekind_int2 = cl_abap_typedescr.typekind_int2;
    this.typekind_int8 = cl_abap_typedescr.typekind_int8;
    this.typekind_intf = cl_abap_typedescr.typekind_intf;
    this.typekind_iref = cl_abap_typedescr.typekind_iref;
    this.typekind_num = cl_abap_typedescr.typekind_num;
    this.typekind_numeric = cl_abap_typedescr.typekind_numeric;
    this.typekind_oref = cl_abap_typedescr.typekind_oref;
    this.typekind_packed = cl_abap_typedescr.typekind_packed;
    this.typekind_simple = cl_abap_typedescr.typekind_simple;
    this.typekind_string = cl_abap_typedescr.typekind_string;
    this.typekind_struct1 = cl_abap_typedescr.typekind_struct1;
    this.typekind_struct2 = cl_abap_typedescr.typekind_struct2;
    this.typekind_table = cl_abap_typedescr.typekind_table;
    this.typekind_time = cl_abap_typedescr.typekind_time;
    this.typekind_utclong = cl_abap_typedescr.typekind_utclong;
    this.typekind_w = cl_abap_typedescr.typekind_w;
    this.typekind_xstring = cl_abap_typedescr.typekind_xstring;
    this.kind_elem = cl_abap_typedescr.kind_elem;
    this.kind_struct = cl_abap_typedescr.kind_struct;
    this.kind_table = cl_abap_typedescr.kind_table;
    this.kind_ref = cl_abap_typedescr.kind_ref;
    this.kind_class = cl_abap_typedescr.kind_class;
    this.kind_intf = cl_abap_typedescr.kind_intf;
  }
  async constructor_(INPUT) {
    if (super.constructor_) { await super.constructor_(INPUT); }
    return this;
  }
  async get_ddic_object() {
    let p_object = abap.types.TableFactory.construct(new abap.types.String({qualifiedName: "STRING"}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"isUnique":false,"type":"STANDARD","keyFields":[],"name":"primary_key"},"secondary":[]}, "STRING_TABLE");
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return p_object;
  }
  async is_instantiatable() {
    let p_result = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return p_result;
  }
  async describe_by_dashes(INPUT) {
    return cl_abap_typedescr.describe_by_dashes(INPUT);
  }
  static async describe_by_dashes(INPUT) {
    let type = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_TYPEDESCR", RTTIName: "\\CLASS=CL_ABAP_TYPEDESCR"});
    let p_name = INPUT?.p_name;
    let lt_parts = abap.types.TableFactory.construct(new abap.types.String({qualifiedName: "STRING"}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "");
    let lv_part = new abap.types.String({qualifiedName: "STRING"});
    let lo_current = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_TYPEDESCR", RTTIName: "\\CLASS=CL_ABAP_TYPEDESCR"});
    let lo_struct = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_STRUCTDESCR", RTTIName: "\\CLASS=CL_ABAP_STRUCTDESCR"});
    abap.statements.split({source: p_name, at: new abap.types.Character(1).set('-'), table: lt_parts});
    for await (const unique131 of abap.statements.loop(lt_parts)) {
      lv_part.set(unique131);
      if (abap.compare.initial(lo_current)) {
        lo_current.set((await this.describe_by_name({p_name: lv_part})));
      } else if (abap.compare.eq(lo_current.get().kind, cl_abap_typedescr.kind_struct)) {
        await abap.statements.cast(lo_struct, lo_current);
        lo_current.set((await lo_struct.get().get_component_type({p_name: lv_part})));
      }
    }
    type.set(lo_current);
    return type;
  }
  async describe_by_name(INPUT) {
    return cl_abap_typedescr.describe_by_name(INPUT);
  }
  static async describe_by_name(INPUT) {
    let type = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_TYPEDESCR", RTTIName: "\\CLASS=CL_ABAP_TYPEDESCR"});
    let p_name = INPUT?.p_name;
    let ref = new abap.types.DataReference(new abap.types.Character(4));
    let objectdescr = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_OBJECTDESCR", RTTIName: "\\CLASS=CL_ABAP_OBJECTDESCR"});
    let oo_type = new abap.types.String({qualifiedName: "STRING"});
    let lv_any = new abap.types.String({qualifiedName: "STRING"});
    if (abap.compare.ca(p_name, new abap.types.Character(1).set('-')) && abap.compare.np(p_name, new abap.types.Character(6).set('CLAS-*')) && abap.compare.np(p_name, new abap.types.Character(6).set('PROG-*'))) {
      type.set((await this.describe_by_dashes({p_name: p_name})));
      return type;
    }
    oo_type.set(abap.Classes[p_name.get().toUpperCase().trimEnd()]?.INTERNAL_TYPE || "");
    lv_any = abap.Classes[p_name.get().toUpperCase().trimEnd()];
    let unique132 = oo_type;
    if (abap.compare.eq(unique132, new abap.types.Character(4).set('INTF'))) {
      type.set(await (new abap.Classes['CL_ABAP_INTFDESCR']()).constructor_({p_object: lv_any}));
      type.get().type_kind.set(cl_abap_typedescr.typekind_intf);
      type.get().kind.set(cl_abap_typedescr.kind_intf);
      type.get().relative_name.set(abap.builtin.to_upper({val: p_name}));
      type.get().absolute_name.set(abap.operators.concat(new abap.types.Character(7).set('\\CLASS='),abap.builtin.to_upper({val: p_name})));
      await abap.statements.cast(objectdescr, type);
      objectdescr.get().mv_object_name.set(abap.builtin.to_upper({val: p_name}));
      objectdescr.get().mv_object_type.set(oo_type);
    } else if (abap.compare.eq(unique132, new abap.types.Character(4).set('CLAS'))) {
      type.set(await (new abap.Classes['CL_ABAP_CLASSDESCR']()).constructor_());
      type.get().type_kind.set(cl_abap_typedescr.typekind_class);
      type.get().kind.set(cl_abap_typedescr.kind_class);
      type.get().relative_name.set(abap.builtin.to_upper({val: p_name}));
      if (abap.compare.cp(p_name, new abap.types.Character(6).set('CLAS-*'))) {
        type.get().absolute_name.set((await abap.Classes['KERNEL_INTERNAL_NAME'].internal_to_rtti({iv_internal: p_name})));
      } else {
        type.get().absolute_name.set(abap.operators.concat(new abap.types.Character(7).set('\\CLASS='),abap.builtin.to_upper({val: p_name})));
      }
      await abap.statements.cast(objectdescr, type);
      objectdescr.get().mv_object_name.set(abap.builtin.to_upper({val: p_name}));
      objectdescr.get().mv_object_type.set(oo_type);
    } else {
      try {
        abap.statements.createData(ref,{"name": p_name.get()});
      } catch (e) {
        if ((abap.Classes['CX_SY_CREATE_DATA_ERROR'] && e instanceof abap.Classes['CX_SY_CREATE_DATA_ERROR'])) {
          throw new abap.ClassicError({classic: "type_not_found"});
        } else {
          throw e;
        }
      }
      type.set((await this.describe_by_data_ref({p_data_ref: ref})));
    }
    abap.builtin.sy.get().subrc.set(0);
    return type;
  }
  async get_relative_name() {
    let name = new abap.types.String({qualifiedName: "STRING"});
    name.set(this.relative_name);
    return name;
  }
  async get_ddic_header() {
    let p_header = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), abap.IntegerFactory.get(2)));
    return p_header;
  }
  async is_ddic_type() {
    let p_abap_bool = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    p_abap_bool.set(this.ddic);
    return p_abap_bool;
  }
  async describe_by_data_ref(INPUT) {
    return cl_abap_typedescr.describe_by_data_ref(INPUT);
  }
  static async describe_by_data_ref(INPUT) {
    let type = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_TYPEDESCR", RTTIName: "\\CLASS=CL_ABAP_TYPEDESCR"});
    let p_data_ref = INPUT?.p_data_ref;
    if (p_data_ref === undefined) { p_data_ref = new abap.types.DataReference(new abap.types.Character(4)).set(INPUT.p_data_ref); }
    let fs_ref_ = new abap.types.FieldSymbol(new abap.types.Character(4));
    abap.statements.assign({target: fs_ref_, source: p_data_ref.dereference()});
    type.set((await this.describe_by_data({p_data: fs_ref_})));
    return type;
  }
  async describe_by_object_ref(INPUT) {
    return cl_abap_typedescr.describe_by_object_ref(INPUT);
  }
  static async describe_by_object_ref(INPUT) {
    let p_descr_ref = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_TYPEDESCR", RTTIName: "\\CLASS=CL_ABAP_TYPEDESCR"});
    let p_object_ref = INPUT?.p_object_ref;
    if (p_object_ref === undefined) { p_object_ref = new abap.types.ABAPObject({qualifiedName: undefined, RTTIName: undefined}).set(INPUT.p_object_ref); }
    let lv_name = new abap.types.String({qualifiedName: "STRING"});
    let lo_cdescr = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_CLASSDESCR", RTTIName: "\\CLASS=CL_ABAP_CLASSDESCR"});
    let lv_any = new abap.types.String({qualifiedName: "STRING"});
    if (abap.compare.initial(p_object_ref)) {
      throw new abap.ClassicError({classic: "reference_is_initial"});
    }
    lv_any = p_object_ref.get().constructor;
    lo_cdescr.set(await (new abap.Classes['CL_ABAP_CLASSDESCR']()).constructor_({p_object: lv_any}));
    lo_cdescr.get().type_kind.set(cl_abap_typedescr.typekind_class);
    lo_cdescr.get().kind.set(cl_abap_typedescr.kind_class);
    lv_name.set(p_object_ref.get().constructor.name.toUpperCase());
    lo_cdescr.get().relative_name.set(lv_name);
    lo_cdescr.get().absolute_name.set(abap.operators.concat(new abap.types.Character(7).set('\\CLASS='),lv_name));
    p_descr_ref.set(lo_cdescr);
    abap.builtin.sy.get().subrc.set(0);
    return p_descr_ref;
  }
  async is_deep(INPUT) {
    return cl_abap_typedescr.is_deep(INPUT);
  }
  static async is_deep(INPUT) {
    let rv_deep = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    let io_struct = INPUT?.io_struct;
    if (io_struct?.getQualifiedName === undefined || io_struct.getQualifiedName() !== "CL_ABAP_STRUCTDESCR") { io_struct = undefined; }
    if (io_struct === undefined) { io_struct = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_STRUCTDESCR", RTTIName: "\\CLASS=CL_ABAP_STRUCTDESCR"}).set(INPUT.io_struct); }
    let lt_components = abap.types.TableFactory.construct(new abap.types.Structure({"name": new abap.types.String({qualifiedName: "NAME"}), "type": new abap.types.ABAPObject({qualifiedName: "CL_ABAP_DATADESCR", RTTIName: "\\CLASS=CL_ABAP_DATADESCR"}), "as_include": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "suffix": new abap.types.String({qualifiedName: "SUFFIX"})}, "abap_componentdescr", undefined, {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "abap_component_tab");
    let fs_ls_component_ = new abap.types.FieldSymbol(new abap.types.Structure({"name": new abap.types.String({qualifiedName: "NAME"}), "type": new abap.types.ABAPObject({qualifiedName: "CL_ABAP_DATADESCR", RTTIName: "\\CLASS=CL_ABAP_DATADESCR"}), "as_include": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "suffix": new abap.types.String({qualifiedName: "SUFFIX"})}, "abap_componentdescr", undefined, {}, {}));
    lt_components.set((await io_struct.get().get_components()));
    rv_deep.set(abap.builtin.abap_false);
    for await (const unique133 of abap.statements.loop(lt_components)) {
      fs_ls_component_.assign(unique133);
      if (abap.compare.eq(fs_ls_component_.get().type.get().kind, cl_abap_typedescr.kind_struct) || abap.compare.eq(fs_ls_component_.get().type.get().type_kind, cl_abap_typedescr.typekind_string) || abap.compare.eq(fs_ls_component_.get().type.get().type_kind, cl_abap_typedescr.typekind_xstring) || abap.compare.eq(fs_ls_component_.get().type.get().kind, cl_abap_typedescr.kind_table)) {
        rv_deep.set(abap.builtin.abap_true);
        return rv_deep;
      }
    }
    return rv_deep;
  }
  async describe_by_data(INPUT) {
    return cl_abap_typedescr.describe_by_data(INPUT);
  }
  static async describe_by_data(INPUT) {
    let type = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_TYPEDESCR", RTTIName: "\\CLASS=CL_ABAP_TYPEDESCR"});
    let p_data = INPUT?.p_data;
    let lo_elem = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_ELEMDESCR", RTTIName: "\\CLASS=CL_ABAP_ELEMDESCR"});
    let lo_ref = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_REFDESCR", RTTIName: "\\CLASS=CL_ABAP_REFDESCR"});
    let lo_struct = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_STRUCTDESCR", RTTIName: "\\CLASS=CL_ABAP_STRUCTDESCR"});
    let lv_any = new abap.types.String({qualifiedName: "STRING"});
    let lv_convexit = new abap.types.String({qualifiedName: "STRING"});
    let lv_ddicname = new abap.types.String({qualifiedName: "STRING"});
    let lv_decimals = new abap.types.Integer({qualifiedName: "I"});
    let lv_length = new abap.types.Integer({qualifiedName: "I"});
    let lv_name = new abap.types.String({qualifiedName: "STRING"});
    let lv_prefix = new abap.types.String({qualifiedName: "STRING"});
    let lv_qualified = new abap.types.String({qualifiedName: "STRING"});
    let lv_rtti_name = new abap.types.String({qualifiedName: "STRING"});
    lv_name.set(p_data.constructor.name);
    lv_length.set(p_data.getLength ? p_data.getLength() : 0);
    lv_decimals.set(p_data.getDecimals ? p_data.getDecimals() : 0);
    let unique134 = lv_name;
    if (abap.compare.eq(unique134, new abap.types.Character(7).set('Integer'))) {
      type.set(await (new abap.Classes['CL_ABAP_ELEMDESCR']()).constructor_());
      type.get().type_kind.set(cl_abap_typedescr.typekind_int);
      type.get().kind.set(cl_abap_typedescr.kind_elem);
      type.get().length.set(abap.IntegerFactory.get(4));
      await abap.statements.cast(lo_elem, type);
      lo_elem.get().output_length.set(abap.IntegerFactory.get(11));
      type.get().absolute_name.set(new abap.types.Character(1).set('I'));
    } else if (abap.compare.eq(unique134, new abap.types.Character(8).set('Integer8'))) {
      type.set(await (new abap.Classes['CL_ABAP_ELEMDESCR']()).constructor_());
      type.get().type_kind.set(cl_abap_typedescr.typekind_int8);
      type.get().kind.set(cl_abap_typedescr.kind_elem);
      type.get().length.set(abap.IntegerFactory.get(8));
      await abap.statements.cast(lo_elem, type);
      lo_elem.get().output_length.set(abap.IntegerFactory.get(20));
      type.get().absolute_name.set(new abap.types.Character(4).set('INT8'));
    } else if (abap.compare.eq(unique134, new abap.types.Character(4).set('Numc'))) {
      type.set(await (new abap.Classes['CL_ABAP_ELEMDESCR']()).constructor_());
      type.get().type_kind.set(cl_abap_typedescr.typekind_num);
      type.get().kind.set(cl_abap_typedescr.kind_elem);
      type.get().length.set(abap.operators.multiply(lv_length,abap.IntegerFactory.get(2)));
      await abap.statements.cast(lo_elem, type);
      lo_elem.get().output_length.set(lv_length);
    } else if (abap.compare.eq(unique134, new abap.types.Character(3).set('Hex')) || abap.compare.eq(unique134, new abap.types.Character(8).set('HexUInt8'))) {
      type.set(await (new abap.Classes['CL_ABAP_ELEMDESCR']()).constructor_());
      type.get().type_kind.set(cl_abap_typedescr.typekind_hex);
      type.get().kind.set(cl_abap_typedescr.kind_elem);
      type.get().length.set(lv_length);
      await abap.statements.cast(lo_elem, type);
      lo_elem.get().output_length.set(abap.operators.multiply(lv_length,abap.IntegerFactory.get(2)));
    } else if (abap.compare.eq(unique134, new abap.types.Character(4).set('Date'))) {
      type.set(await (new abap.Classes['CL_ABAP_ELEMDESCR']()).constructor_());
      type.get().type_kind.set(cl_abap_typedescr.typekind_date);
      type.get().kind.set(cl_abap_typedescr.kind_elem);
      type.get().length.set(abap.IntegerFactory.get(16));
      await abap.statements.cast(lo_elem, type);
      lo_elem.get().output_length.set(abap.IntegerFactory.get(8));
      type.get().absolute_name.set(new abap.types.Character(1).set('D'));
    } else if (abap.compare.eq(unique134, new abap.types.Character(6).set('Packed'))) {
      type.set(await (new abap.Classes['CL_ABAP_ELEMDESCR']()).constructor_());
      type.get().type_kind.set(cl_abap_typedescr.typekind_packed);
      type.get().kind.set(cl_abap_typedescr.kind_elem);
      type.get().length.set(lv_length);
      type.get().decimals.set(lv_decimals);
    } else if (abap.compare.eq(unique134, new abap.types.Character(4).set('Time'))) {
      type.set(await (new abap.Classes['CL_ABAP_ELEMDESCR']()).constructor_());
      type.get().type_kind.set(cl_abap_typedescr.typekind_time);
      type.get().kind.set(cl_abap_typedescr.kind_elem);
      type.get().length.set(abap.IntegerFactory.get(12));
      await abap.statements.cast(lo_elem, type);
      lo_elem.get().output_length.set(abap.IntegerFactory.get(6));
      type.get().absolute_name.set(new abap.types.Character(1).set('T'));
    } else if (abap.compare.eq(unique134, new abap.types.Character(5).set('Float'))) {
      type.set(await (new abap.Classes['CL_ABAP_ELEMDESCR']()).constructor_());
      type.get().type_kind.set(cl_abap_typedescr.typekind_float);
      type.get().kind.set(cl_abap_typedescr.kind_elem);
      type.get().absolute_name.set(new abap.types.Character(1).set('F'));
    } else if (abap.compare.eq(unique134, new abap.types.Character(10).set('DecFloat34'))) {
      type.set(await (new abap.Classes['CL_ABAP_ELEMDESCR']()).constructor_());
      type.get().type_kind.set(cl_abap_typedescr.typekind_decfloat34);
      type.get().kind.set(cl_abap_typedescr.kind_elem);
    } else if (abap.compare.eq(unique134, new abap.types.Character(9).set('Structure'))) {
      lo_struct.set((await abap.Classes['CL_ABAP_STRUCTDESCR'].construct_from_data({data: p_data})));
      await abap.statements.cast(type, lo_struct);
      if (abap.compare.eq((await this.is_deep({io_struct: lo_struct})), abap.builtin.abap_true)) {
        type.get().type_kind.set(cl_abap_typedescr.typekind_struct2);
      } else {
        type.get().type_kind.set(cl_abap_typedescr.typekind_struct1);
      }
      type.get().kind.set(cl_abap_typedescr.kind_struct);
    } else if (abap.compare.eq(unique134, new abap.types.Character(5).set('Table')) || abap.compare.eq(unique134, new abap.types.Character(11).set('HashedTable'))) {
      await abap.statements.cast(type, (await abap.Classes['CL_ABAP_TABLEDESCR'].construct_from_data({data: p_data})));
      type.get().type_kind.set(cl_abap_typedescr.typekind_table);
      type.get().kind.set(cl_abap_typedescr.kind_table);
      type.get().length.set(abap.IntegerFactory.get(8));
    } else if (abap.compare.eq(unique134, new abap.types.Character(7).set('XString'))) {
      type.set(await (new abap.Classes['CL_ABAP_ELEMDESCR']()).constructor_());
      type.get().type_kind.set(cl_abap_typedescr.typekind_xstring);
      type.get().kind.set(cl_abap_typedescr.kind_elem);
      type.get().length.set(abap.IntegerFactory.get(8));
      type.get().absolute_name.set(new abap.types.Character(7).set('XSTRING'));
    } else if (abap.compare.eq(unique134, new abap.types.Character(6).set('String'))) {
      type.set(await (new abap.Classes['CL_ABAP_ELEMDESCR']()).constructor_());
      type.get().type_kind.set(cl_abap_typedescr.typekind_string);
      type.get().kind.set(cl_abap_typedescr.kind_elem);
      type.get().length.set(abap.IntegerFactory.get(8));
      type.get().absolute_name.set(new abap.types.Character(6).set('STRING'));
    } else if (abap.compare.eq(unique134, new abap.types.Character(9).set('Character'))) {
      type.set(await (new abap.Classes['CL_ABAP_ELEMDESCR']()).constructor_());
      type.get().type_kind.set(cl_abap_typedescr.typekind_char);
      type.get().kind.set(cl_abap_typedescr.kind_elem);
      type.get().length.set(abap.operators.multiply(lv_length,abap.IntegerFactory.get(2)));
      await abap.statements.cast(lo_elem, type);
      lo_elem.get().output_length.set(lv_length);
    } else if (abap.compare.eq(unique134, new abap.types.Character(11).set('FieldSymbol'))) {
      lv_name = p_data.getPointer();
      type.set((await this.describe_by_data({p_data: lv_name})));
      return type;
    } else if (abap.compare.eq(unique134, new abap.types.Character(10).set('ABAPObject'))) {
      type.set(await (new abap.Classes['CL_ABAP_REFDESCR']()).constructor_());
      type.get().type_kind.set(cl_abap_typedescr.typekind_oref);
      type.get().kind.set(cl_abap_typedescr.kind_ref);
      await abap.statements.cast(lo_ref, type);
      if (abap.compare.initial(p_data)) {
        lv_rtti_name.set(p_data.RTTIName || "");
        if (abap.compare.cp(lv_rtti_name, new abap.types.Character(13).set('\\CLASS-POOL=*'))) {
          lv_rtti_name.set((await abap.Classes['KERNEL_INTERNAL_NAME'].rtti_to_internal({iv_rtti: lv_rtti_name})));
          lo_ref.get().referenced.set((await this.describe_by_name({p_name: lv_rtti_name})));
        } else {
          lv_name.set(p_data.qualifiedName || "");
          lo_ref.get().referenced.set((await this.describe_by_name({p_name: lv_name})));
        }
      } else {
        lo_ref.get().referenced.set((await this.describe_by_object_ref({p_object_ref: p_data})));
      }
    } else if (abap.compare.eq(unique134, new abap.types.Character(7).set('UTCLong'))) {
      type.set(await (new abap.Classes['CL_ABAP_ELEMDESCR']()).constructor_());
      type.get().type_kind.set(cl_abap_typedescr.typekind_utclong);
      type.get().kind.set(cl_abap_typedescr.kind_elem);
    } else if (abap.compare.eq(unique134, new abap.types.Character(13).set('DataReference'))) {
      type.set(await (new abap.Classes['CL_ABAP_REFDESCR']()).constructor_());
      type.get().type_kind.set(cl_abap_typedescr.typekind_dref);
      type.get().kind.set(cl_abap_typedescr.kind_ref);
      await abap.statements.cast(lo_ref, type);
      lv_any = p_data.type;
      lo_ref.get().referenced.set((await this.describe_by_data({p_data: lv_any})));
    } else {
      abap.statements.write(lv_name,{newLine: true});
      abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(22).set('todo_cl_abap_typedescr')));
    }
    lv_ddicname.set(p_data.getDDICName ? p_data.getDDICName() || "" : "");
    lv_convexit.set(p_data.getConversionExit ? p_data.getConversionExit() || "" : "");
    lv_qualified.set(p_data.getQualifiedName ? p_data.getQualifiedName() || "" : "");
    if (abap.compare.na(lv_qualified, new abap.types.Character(1).set('-'))) {
      type.get().absolute_name.set(lv_qualified);
    } else if (abap.compare.ne(lv_ddicname, new abap.types.Character(1).set(''))) {
      type.get().absolute_name.set(lv_ddicname);
    }
    if(abap.DDIC[type.get().absolute_name.get().toUpperCase().trimEnd()]) { type.get().ddic.set("X"); }
    abap.statements.translate(type.get().absolute_name, "UPPER");
    abap.statements.translate(type.get().relative_name, "UPPER");
    if (abap.compare.eq(type.get().absolute_name, new abap.types.Character(9).set('ABAP_BOOL'))) {
      type.get().relative_name.set(new abap.types.Character(9).set('ABAP_BOOL'));
      type.get().absolute_name.set(new abap.types.Character(30).set('\\TYPE-POOL=ABAP\\TYPE=ABAP_BOOL'));
    } else if (abap.compare.initial(type.get().absolute_name)) {
      cl_abap_typedescr.gv_counter.set(abap.operators.add(cl_abap_typedescr.gv_counter,abap.IntegerFactory.get(1)));
      type.get().absolute_name.set(abap.operators.concat(new abap.types.Character(24).set('\\TYPE=%_T000000000000000'),cl_abap_typedescr.gv_counter));
    } else if (abap.compare.cs(type.get().absolute_name, new abap.types.Character(2).set('=>'))) {
      abap.statements.split({source: type.get().absolute_name, at: new abap.types.Character(2).set('=>'), targets: [lv_prefix,type.get().absolute_name]});
      type.get().relative_name.set(type.get().absolute_name);
      type.get().absolute_name.set(abap.operators.concat(new abap.types.Character(7).set('\\CLASS='),abap.operators.concat(lv_prefix,abap.operators.concat(new abap.types.Character(6).set('\\TYPE='),type.get().absolute_name))));
    } else if (abap.compare.eq(type.get().type_kind, cl_abap_typedescr.typekind_oref)) {
      type.get().relative_name.set(type.get().absolute_name);
      type.get().absolute_name.set(abap.operators.concat(new abap.types.Character(7).set('\\CLASS='),type.get().absolute_name));
    } else {
      type.get().relative_name.set(type.get().absolute_name);
      type.get().absolute_name.set(abap.operators.concat(new abap.types.Character(6).set('\\TYPE='),type.get().absolute_name));
    }
    if (abap.compare.ne(lv_convexit, new abap.types.Character(1).set(''))) {
      lo_elem.get().edit_mask.set(abap.operators.concat(new abap.types.Character(2).set('=='),lv_convexit));
    }
    return type;
  }
}
abap.Classes['CL_ABAP_TYPEDESCR'] = cl_abap_typedescr;
cl_abap_typedescr.gv_counter = new abap.types.Numc({length: 10});
cl_abap_typedescr.typekind_any = new abap.types.Character(1, {"qualifiedName":"abap_typekind"});
cl_abap_typedescr.typekind_any.set('~');
cl_abap_typedescr.typekind_char = new abap.types.Character(1, {"qualifiedName":"abap_typekind"});
cl_abap_typedescr.typekind_char.set('C');
cl_abap_typedescr.typekind_class = new abap.types.Character(1, {"qualifiedName":"abap_typekind"});
cl_abap_typedescr.typekind_class.set('*');
cl_abap_typedescr.typekind_clike = new abap.types.Character(1, {"qualifiedName":"abap_typekind"});
cl_abap_typedescr.typekind_clike.set('&');
cl_abap_typedescr.typekind_csequence = new abap.types.Character(1, {"qualifiedName":"abap_typekind"});
cl_abap_typedescr.typekind_csequence.set('?');
cl_abap_typedescr.typekind_data = new abap.types.Character(1, {"qualifiedName":"abap_typekind"});
cl_abap_typedescr.typekind_data.set('#');
cl_abap_typedescr.typekind_date = new abap.types.Character(1, {"qualifiedName":"abap_typekind"});
cl_abap_typedescr.typekind_date.set('D');
cl_abap_typedescr.typekind_decfloat = new abap.types.Character(1, {"qualifiedName":"abap_typekind"});
cl_abap_typedescr.typekind_decfloat.set('/');
cl_abap_typedescr.typekind_decfloat16 = new abap.types.Character(1, {"qualifiedName":"abap_typekind"});
cl_abap_typedescr.typekind_decfloat16.set('a');
cl_abap_typedescr.typekind_decfloat34 = new abap.types.Character(1, {"qualifiedName":"abap_typekind"});
cl_abap_typedescr.typekind_decfloat34.set('e');
cl_abap_typedescr.typekind_dref = new abap.types.Character(1, {"qualifiedName":"abap_typekind"});
cl_abap_typedescr.typekind_dref.set('l');
cl_abap_typedescr.typekind_enum = new abap.types.Character(1, {"qualifiedName":"abap_typekind"});
cl_abap_typedescr.typekind_enum.set('k');
cl_abap_typedescr.typekind_float = new abap.types.Character(1, {"qualifiedName":"abap_typekind"});
cl_abap_typedescr.typekind_float.set('F');
cl_abap_typedescr.typekind_hex = new abap.types.Character(1, {"qualifiedName":"abap_typekind"});
cl_abap_typedescr.typekind_hex.set('X');
cl_abap_typedescr.typekind_int = new abap.types.Character(1, {"qualifiedName":"abap_typekind"});
cl_abap_typedescr.typekind_int.set('I');
cl_abap_typedescr.typekind_int1 = new abap.types.Character(1, {"qualifiedName":"abap_typekind"});
cl_abap_typedescr.typekind_int1.set('b');
cl_abap_typedescr.typekind_int2 = new abap.types.Character(1, {"qualifiedName":"abap_typekind"});
cl_abap_typedescr.typekind_int2.set('s');
cl_abap_typedescr.typekind_int8 = new abap.types.Character(1, {"qualifiedName":"abap_typekind"});
cl_abap_typedescr.typekind_int8.set('8');
cl_abap_typedescr.typekind_intf = new abap.types.Character(1, {"qualifiedName":"abap_typekind"});
cl_abap_typedescr.typekind_intf.set('+');
cl_abap_typedescr.typekind_iref = new abap.types.Character(1, {"qualifiedName":"abap_typekind"});
cl_abap_typedescr.typekind_iref.set('m');
cl_abap_typedescr.typekind_num = new abap.types.Character(1, {"qualifiedName":"abap_typekind"});
cl_abap_typedescr.typekind_num.set('N');
cl_abap_typedescr.typekind_numeric = new abap.types.Character(1, {"qualifiedName":"abap_typekind"});
cl_abap_typedescr.typekind_numeric.set('%');
cl_abap_typedescr.typekind_oref = new abap.types.Character(1, {"qualifiedName":"abap_typekind"});
cl_abap_typedescr.typekind_oref.set('r');
cl_abap_typedescr.typekind_packed = new abap.types.Character(1, {"qualifiedName":"abap_typekind"});
cl_abap_typedescr.typekind_packed.set('P');
cl_abap_typedescr.typekind_simple = new abap.types.Character(1, {"qualifiedName":"abap_typekind"});
cl_abap_typedescr.typekind_simple.set('$');
cl_abap_typedescr.typekind_string = new abap.types.Character(1, {"qualifiedName":"abap_typekind"});
cl_abap_typedescr.typekind_string.set('g');
cl_abap_typedescr.typekind_struct1 = new abap.types.Character(1, {"qualifiedName":"abap_typekind"});
cl_abap_typedescr.typekind_struct1.set('u');
cl_abap_typedescr.typekind_struct2 = new abap.types.Character(1, {"qualifiedName":"abap_typekind"});
cl_abap_typedescr.typekind_struct2.set('v');
cl_abap_typedescr.typekind_table = new abap.types.Character(1, {"qualifiedName":"abap_typekind"});
cl_abap_typedescr.typekind_table.set('h');
cl_abap_typedescr.typekind_time = new abap.types.Character(1, {"qualifiedName":"abap_typekind"});
cl_abap_typedescr.typekind_time.set('T');
cl_abap_typedescr.typekind_utclong = new abap.types.Character(1, {"qualifiedName":"abap_typekind"});
cl_abap_typedescr.typekind_utclong.set('p');
cl_abap_typedescr.typekind_w = new abap.types.Character(1, {"qualifiedName":"abap_typekind"});
cl_abap_typedescr.typekind_w.set('w');
cl_abap_typedescr.typekind_xstring = new abap.types.Character(1, {"qualifiedName":"abap_typekind"});
cl_abap_typedescr.typekind_xstring.set('y');
cl_abap_typedescr.kind_elem = new abap.types.Character(1, {});
cl_abap_typedescr.kind_elem.set('E');
cl_abap_typedescr.kind_struct = new abap.types.Character(1, {});
cl_abap_typedescr.kind_struct.set('S');
cl_abap_typedescr.kind_table = new abap.types.Character(1, {});
cl_abap_typedescr.kind_table.set('T');
cl_abap_typedescr.kind_ref = new abap.types.Character(1, {});
cl_abap_typedescr.kind_ref.set('R');
cl_abap_typedescr.kind_class = new abap.types.Character(1, {});
cl_abap_typedescr.kind_class.set('C');
cl_abap_typedescr.kind_intf = new abap.types.Character(1, {});
cl_abap_typedescr.kind_intf.set('I');
export {cl_abap_typedescr};
//# sourceMappingURL=cl_abap_typedescr.clas.mjs.map