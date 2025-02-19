await import("./%23ui2%23cl_json.clas.locals.mjs");
const {cx_root} = await import("./cx_root.clas.mjs");
// #ui2#cl_json.clas.abap
class $ui2$cl_json {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = '/UI2/CL_JSON';
  static IMPLEMENTED_INTERFACES = [];
  static ATTRIBUTES = {"MO_PARSED": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "LCL_PARSER", RTTIName: "\\CLASS-POOL=/UI2/CL_JSON\\CLASS=LCL_PARSER"});}, "visibility": "I", "is_constant": " ", "is_class": "X"},
  "MV_COMPRESS": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});}, "visibility": "O", "is_constant": " ", "is_class": " "},
  "MV_PRETTY_NAME": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "visibility": "O", "is_constant": " ", "is_class": " "},
  "MV_ASSOC_ARRAYS": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});}, "visibility": "O", "is_constant": " ", "is_class": " "},
  "MV_TS_AS_ISO8601": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});}, "visibility": "O", "is_constant": " ", "is_class": " "},
  "MV_EXTENDED": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});}, "visibility": "O", "is_constant": " ", "is_class": " "},
  "PRETTY_MODE": {"type": () => {return new abap.types.Structure({"none": new abap.types.String({qualifiedName: "STRING"}), "low_case": new abap.types.String({qualifiedName: "STRING"}), "camel_case": new abap.types.String({qualifiedName: "STRING"})}, undefined, undefined, {}, {});}, "visibility": "U", "is_constant": "X", "is_class": "X"}};
  static METHODS = {"_DESERIALIZE": {"visibility": "I", "parameters": {"PREFIX": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "PRETTY_NAME": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "IO_TYPE": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "CL_ABAP_TYPEDESCR", RTTIName: "\\CLASS=CL_ABAP_TYPEDESCR"});}, "is_optional": " "}, "DATA": {"type": () => {return new abap.types.Character(4);}, "is_optional": " "}}},
  "IS_COMPRESSABLE": {"visibility": "O", "parameters": {"RV_COMPRESS": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});}, "is_optional": " "}, "TYPE_DESCR": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "CL_ABAP_TYPEDESCR", RTTIName: "\\CLASS=CL_ABAP_TYPEDESCR"});}, "is_optional": " "}, "NAME": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}},
  "RAW_TO_STRING": {"visibility": "U", "parameters": {"RV_STRING": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "IV_XSTRING": {"type": () => {return new abap.types.XString({qualifiedName: "XSTRING"});}, "is_optional": " "}}},
  "STRING_TO_RAW": {"visibility": "U", "parameters": {"RV_XSTRING": {"type": () => {return new abap.types.XString({qualifiedName: "XSTRING"});}, "is_optional": " "}, "IV_STRING": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}},
  "DESERIALIZE": {"visibility": "U", "parameters": {"JSON": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "JSONX": {"type": () => {return new abap.types.XString({qualifiedName: "XSTRING"});}, "is_optional": " "}, "PRETTY_NAME": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "ASSOC_ARRAYS": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});}, "is_optional": " "}, "ASSOC_ARRAYS_OPT": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});}, "is_optional": " "}, "DATA": {"type": () => {return new abap.types.Character(4);}, "is_optional": " "}}},
  "SERIALIZE": {"visibility": "U", "parameters": {"R_JSON": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "DATA": {"type": () => {return new abap.types.Character(4);}, "is_optional": " "}, "COMPRESS": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});}, "is_optional": " "}, "PRETTY_NAME": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "ASSOC_ARRAYS": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});}, "is_optional": " "}, "ASSOC_ARRAYS_OPT": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});}, "is_optional": " "}, "TS_AS_ISO8601": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});}, "is_optional": " "}, "TYPE_DESCR": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "CL_ABAP_TYPEDESCR", RTTIName: "\\CLASS=CL_ABAP_TYPEDESCR"});}, "is_optional": " "}, "FORMAT_OUTPUT": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});}, "is_optional": " "}}},
  "GENERATE": {"visibility": "U", "parameters": {"RR_DATA": {"type": () => {return new abap.types.DataReference(new abap.types.Character(4));}, "is_optional": " "}, "JSON": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "PRETTY_NAME": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}},
  "SERIALIZE_INT": {"visibility": "U", "parameters": {"R_JSON": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "DATA": {"type": () => {return new abap.types.Character(4);}, "is_optional": " "}, "TYPE_DESCR": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "CL_ABAP_TYPEDESCR", RTTIName: "\\CLASS=CL_ABAP_TYPEDESCR"});}, "is_optional": " "}}},
  "CONSTRUCTOR": {"visibility": "U", "parameters": {"COMPRESS": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});}, "is_optional": " "}, "PRETTY_NAME": {"type": () => {return new abap.types.String({qualifiedName: "/UI2/CL_JSON=>PRETTY_NAME_MODE"});}, "is_optional": " "}, "ASSOC_ARRAYS": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});}, "is_optional": " "}, "TS_AS_ISO8601": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});}, "is_optional": " "}}}};
  constructor() {
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
    this.mo_parsed = $ui2$cl_json.mo_parsed;
    this.mv_compress = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    this.mv_pretty_name = new abap.types.String({qualifiedName: "STRING"});
    this.mv_assoc_arrays = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    this.mv_ts_as_iso8601 = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    this.mv_extended = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    this.pretty_mode = $ui2$cl_json.pretty_mode;
  }
  async raw_to_string(INPUT) {
    return $ui2$cl_json.raw_to_string(INPUT);
  }
  static async raw_to_string(INPUT) {
    let rv_string = new abap.types.String({qualifiedName: "STRING"});
    let iv_xstring = INPUT?.iv_xstring;
    if (iv_xstring?.getQualifiedName === undefined || iv_xstring.getQualifiedName() !== "XSTRING") { iv_xstring = undefined; }
    if (iv_xstring === undefined) { iv_xstring = new abap.types.XString({qualifiedName: "XSTRING"}).set(INPUT.iv_xstring); }
    rv_string.set((await abap.Classes['CL_ABAP_CODEPAGE'].convert_from({source: iv_xstring})));
    return rv_string;
  }
  async string_to_raw(INPUT) {
    return $ui2$cl_json.string_to_raw(INPUT);
  }
  static async string_to_raw(INPUT) {
    let rv_xstring = new abap.types.XString({qualifiedName: "XSTRING"});
    let iv_string = INPUT?.iv_string;
    if (iv_string?.getQualifiedName === undefined || iv_string.getQualifiedName() !== "STRING") { iv_string = undefined; }
    if (iv_string === undefined) { iv_string = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.iv_string); }
    rv_xstring.set((await abap.Classes['CL_ABAP_CODEPAGE'].convert_to({source: iv_string})));
    return rv_xstring;
  }
  async serialize_int(INPUT) {
    let r_json = new abap.types.String({qualifiedName: "STRING"});
    let data = INPUT?.data;
    let type_descr = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_TYPEDESCR", RTTIName: "\\CLASS=CL_ABAP_TYPEDESCR"});
    if (INPUT && INPUT.type_descr) {type_descr.set(INPUT.type_descr);}
    let lo_type = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_TYPEDESCR", RTTIName: "\\CLASS=CL_ABAP_TYPEDESCR"});
    let lo_struct = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_STRUCTDESCR", RTTIName: "\\CLASS=CL_ABAP_STRUCTDESCR"});
    let lo_table = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_TABLEDESCR", RTTIName: "\\CLASS=CL_ABAP_TABLEDESCR"});
    let lt_components = abap.types.TableFactory.construct(new abap.types.Structure({"name": new abap.types.String({qualifiedName: "NAME"}), "type": new abap.types.ABAPObject({qualifiedName: "CL_ABAP_DATADESCR", RTTIName: "\\CLASS=CL_ABAP_DATADESCR"}), "as_include": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "suffix": new abap.types.String({qualifiedName: "SUFFIX"})}, "abap_componentdescr", undefined, {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "abap_component_tab");
    let ref = new abap.types.DataReference(new abap.types.Character(4));
    let lv_index = new abap.types.Integer({qualifiedName: "I"});
    let fs_ls_component_ = new abap.types.FieldSymbol(new abap.types.Structure({"name": new abap.types.String({qualifiedName: "NAME"}), "type": new abap.types.ABAPObject({qualifiedName: "CL_ABAP_DATADESCR", RTTIName: "\\CLASS=CL_ABAP_DATADESCR"}), "as_include": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "suffix": new abap.types.String({qualifiedName: "SUFFIX"})}, "abap_componentdescr", undefined, {}, {}));
    let fs_any_ = new abap.types.FieldSymbol(new abap.types.Character(4));
    let fs_tab_ = new abap.types.FieldSymbol(abap.types.TableFactory.construct(new abap.types.Character(4), {"withHeader":false,"keyType":"DEFAULT"}));
    if (abap.compare.initial(type_descr)) {
      lo_type.set((await abap.Classes['CL_ABAP_TYPEDESCR'].describe_by_data({p_data: data})));
    } else {
      lo_type.set(type_descr);
    }
    let unique61 = lo_type.get().kind;
    if (abap.compare.eq(unique61, abap.Classes['CL_ABAP_TYPEDESCR'].kind_elem)) {
      let unique62 = lo_type.get().type_kind;
      if (abap.compare.eq(unique62, abap.Classes['CL_ABAP_TYPEDESCR'].typekind_char)) {
        if (abap.compare.eq(lo_type.get().absolute_name, new abap.types.String().set(`\\TYPE-POOL=ABAP\\TYPE=ABAP_BOOL`))) {
          if (abap.compare.eq(data, abap.builtin.abap_true)) {
            r_json.set(new abap.types.Character(4).set('true'));
          } else {
            r_json.set(new abap.types.Character(5).set('false'));
          }
        } else if (abap.compare.initial(data)) {
          r_json.set(new abap.types.Character(2).set('""'));
        } else {
          r_json.set(abap.operators.concat(new abap.types.Character(1).set('"'),abap.operators.concat(abap.builtin.escape({val: new abap.types.String().set(`${abap.templateFormatting(data)}`), format: abap.Classes['CL_ABAP_FORMAT'].e_json_string}),new abap.types.Character(1).set('"'))));
        }
      } else if (abap.compare.eq(unique62, abap.Classes['CL_ABAP_TYPEDESCR'].typekind_xstring)) {
        r_json.set(abap.operators.concat(new abap.types.Character(1).set('"'),abap.operators.concat((await abap.Classes['CL_HTTP_UTILITY'].encode_x_base64({unencoded: data})),new abap.types.Character(1).set('"'))));
      } else if (abap.compare.eq(unique62, abap.Classes['CL_ABAP_TYPEDESCR'].typekind_string)) {
        r_json.set(abap.operators.concat(new abap.types.Character(1).set('"'),abap.operators.concat(abap.builtin.escape({val: data, format: abap.Classes['CL_ABAP_FORMAT'].e_json_string}),new abap.types.Character(1).set('"'))));
      } else if (abap.compare.eq(unique62, abap.Classes['CL_ABAP_TYPEDESCR'].typekind_int)) {
        r_json.set(new abap.types.String().set(`${abap.templateFormatting(data)}`));
      } else if (abap.compare.eq(unique62, abap.Classes['CL_ABAP_TYPEDESCR'].typekind_num)) {
        if (abap.compare.eq(data, abap.IntegerFactory.get(0))) {
          r_json.set(new abap.types.String().set(`0`));
        } else {
          r_json.set(new abap.types.String().set(`${abap.templateFormatting(data)}`));
          abap.statements.shift(r_json, {direction: 'LEFT',deletingLeading: new abap.types.Character(1).set('0')});
        }
      } else if (abap.compare.eq(unique62, abap.Classes['CL_ABAP_TYPEDESCR'].typekind_packed)) {
        if (abap.compare.eq(this.mv_ts_as_iso8601, abap.builtin.abap_true) && (abap.compare.eq(lo_type.get().absolute_name, new abap.types.String().set(`\\TYPE=TIMESTAMP`)) || abap.compare.eq(lo_type.get().absolute_name, new abap.types.String().set(`\\TYPE=TIMESTAMPL`)))) {
          if (abap.compare.initial(data)) {
            r_json.set(new abap.types.String().set(`""`));
          } else if (abap.compare.eq(lo_type.get().absolute_name, new abap.types.String().set(`\\TYPE=TIMESTAMP`))) {
            r_json.set(new abap.types.String().set(`"${abap.templateFormatting(data,{"timestamp":"iso"})}.0000000Z"`));
          } else {
            r_json.set(new abap.types.String().set(`"${abap.templateFormatting(data,{"timestamp":"iso"})}Z"`));
            abap.statements.replace({target: r_json, all: false, with: new abap.types.Character(1).set('.'), of: new abap.types.Character(1).set(',')});
          }
        } else {
          r_json.set(new abap.types.String().set(`${abap.templateFormatting(data)}`));
        }
      } else if (abap.compare.eq(unique62, abap.Classes['CL_ABAP_TYPEDESCR'].typekind_date)) {
        r_json.set(new abap.types.String().set(`"${abap.templateFormatting(data,{"date":"iso"})}"`));
      } else if (abap.compare.eq(unique62, abap.Classes['CL_ABAP_TYPEDESCR'].typekind_time)) {
        r_json.set(new abap.types.String().set(`"${abap.templateFormatting(data,{"time":"iso"})}"`));
      } else {
        r_json.set(data);
      }
    } else if (abap.compare.eq(unique61, abap.Classes['CL_ABAP_TYPEDESCR'].kind_table)) {
      r_json.set(new abap.types.Character(1).set('['));
      abap.statements.assign({target: fs_tab_, source: data});
      await abap.statements.cast(lo_table, lo_type);
      for await (const unique63 of abap.statements.loop(fs_tab_)) {
        fs_any_.assign(unique63);
        lv_index.set(abap.builtin.sy.get().tabix);
        r_json.set(abap.operators.concat(r_json,(await this.serialize_int({data: fs_any_, type_descr: (await lo_table.get().get_table_line_type())}))));
        if (abap.compare.ne(abap.builtin.lines({val: fs_tab_}), lv_index)) {
          r_json.set(abap.operators.concat(r_json,new abap.types.Character(1).set(',')));
        }
      }
      r_json.set(abap.operators.concat(r_json,new abap.types.Character(1).set(']')));
    } else if (abap.compare.eq(unique61, abap.Classes['CL_ABAP_TYPEDESCR'].kind_struct)) {
      await abap.statements.cast(lo_struct, lo_type);
      lt_components.set((await lo_struct.get().get_components()));
      r_json.set(new abap.types.Character(1).set('{'));
      for await (const unique64 of abap.statements.loop(lt_components)) {
        fs_ls_component_.assign(unique64);
        abap.statements.assign({component: fs_ls_component_.get().name, target: fs_any_, source: data});
        abap.statements.assert(abap.compare.eq(abap.builtin.sy.get().subrc, abap.IntegerFactory.get(0)));
        if (abap.compare.eq(this.mv_compress, abap.builtin.abap_true) && abap.compare.initial(fs_any_)) {
          continue;
        }
        if (abap.compare.eq(this.mv_pretty_name, $ui2$cl_json.pretty_mode.get().camel_case)) {
          r_json.set(abap.operators.concat(r_json,new abap.types.String().set(`"${abap.templateFormatting(abap.builtin.to_mixed({val: abap.builtin.to_lower({val: fs_ls_component_.get().name})}))}":`)));
        } else if (abap.compare.eq(this.mv_pretty_name, $ui2$cl_json.pretty_mode.get().low_case)) {
          r_json.set(abap.operators.concat(r_json,new abap.types.String().set(`"${abap.templateFormatting(abap.builtin.to_lower({val: fs_ls_component_.get().name}))}":`)));
        } else {
          r_json.set(abap.operators.concat(r_json,new abap.types.String().set(`"${abap.templateFormatting(fs_ls_component_.get().name)}":`)));
        }
        r_json.set(abap.operators.concat(r_json,(await this.serialize_int({data: fs_any_, type_descr: fs_ls_component_.get().type}))));
        r_json.set(abap.operators.concat(r_json,new abap.types.Character(1).set(',')));
      }
      if (abap.compare.cp(r_json, new abap.types.Character(2).set('*,'))) {
        r_json.set(abap.builtin.substring({val: r_json, off: abap.IntegerFactory.get(0), len: abap.operators.minus(abap.builtin.strlen({val: r_json}),abap.IntegerFactory.get(1))}));
      }
      r_json.set(abap.operators.concat(r_json,new abap.types.Character(1).set('}')));
    } else if (abap.compare.eq(unique61, abap.Classes['CL_ABAP_TYPEDESCR'].kind_ref)) {
      if (abap.compare.initial(data)) {
        r_json.set(new abap.types.Character(4).set('null'));
        return r_json;
      }
      abap.statements.assign({target: fs_any_, source: data.dereference()});
      r_json.set((await this.serialize_int({data: fs_any_})));
    } else {
      abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(21).set('cl_json, unknown kind')));
    }
    return r_json;
  }
  async deserialize(INPUT) {
    return $ui2$cl_json.deserialize(INPUT);
  }
  static async deserialize(INPUT) {
    let json = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.json) {json.set(INPUT.json);}
    let jsonx = new abap.types.XString({qualifiedName: "XSTRING"});
    if (INPUT && INPUT.jsonx) {jsonx.set(INPUT.jsonx);}
    let pretty_name = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.pretty_name) {pretty_name.set(INPUT.pretty_name);}
    let assoc_arrays = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    if (INPUT && INPUT.assoc_arrays) {assoc_arrays.set(INPUT.assoc_arrays);}
    let assoc_arrays_opt = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    if (INPUT && INPUT.assoc_arrays_opt) {assoc_arrays_opt.set(INPUT.assoc_arrays_opt);}
    let data = new abap.types.Character(4);
    if (INPUT && INPUT.data) {data = INPUT.data;}
    let lo_type = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_TYPEDESCR", RTTIName: "\\CLASS=CL_ABAP_TYPEDESCR"});
    $ui2$cl_json.mo_parsed.set(await (new abap.Classes['CLAS-/UI2/CL_JSON-LCL_PARSER']()).constructor_());
    if (abap.compare.initial(jsonx) === false) {
      await $ui2$cl_json.mo_parsed.get().parse({iv_json: (await abap.Classes['CL_ABAP_CODEPAGE'].convert_from({source: jsonx}))});
    } else if (abap.compare.initial(json)) {
      return;
    } else {
      await $ui2$cl_json.mo_parsed.get().parse({iv_json: json});
    }
    await $ui2$cl_json.mo_parsed.get().adjust_names();
    lo_type.set((await abap.Classes['CL_ABAP_TYPEDESCR'].describe_by_data({p_data: data})));
    await this._deserialize({prefix: new abap.types.Character(1).set(''), pretty_name: pretty_name, io_type: lo_type, data: data});
  }
  async constructor_(INPUT) {
    let compress = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    if (INPUT && INPUT.compress) {compress.set(INPUT.compress);}
    if (INPUT === undefined || INPUT.compress === undefined) {compress = abap.builtin.abap_false;}
    let pretty_name = new abap.types.String({qualifiedName: "/UI2/CL_JSON=>PRETTY_NAME_MODE"});
    if (INPUT && INPUT.pretty_name) {pretty_name.set(INPUT.pretty_name);}
    if (INPUT === undefined || INPUT.pretty_name === undefined) {pretty_name = this.pretty_mode.get().none;}
    let assoc_arrays = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    if (INPUT && INPUT.assoc_arrays) {assoc_arrays.set(INPUT.assoc_arrays);}
    if (INPUT === undefined || INPUT.assoc_arrays === undefined) {assoc_arrays = abap.builtin.abap_false;}
    let ts_as_iso8601 = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    if (INPUT && INPUT.ts_as_iso8601) {ts_as_iso8601.set(INPUT.ts_as_iso8601);}
    if (INPUT === undefined || INPUT.ts_as_iso8601 === undefined) {ts_as_iso8601 = abap.builtin.abap_false;}
    let rtti = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_CLASSDESCR", RTTIName: "\\CLASS=CL_ABAP_CLASSDESCR"});
    this.mv_compress.set(compress);
    this.mv_pretty_name.set(pretty_name);
    this.mv_assoc_arrays.set(assoc_arrays);
    this.mv_ts_as_iso8601.set(ts_as_iso8601);
    return this;
  }
  async is_compressable(INPUT) {
    let rv_compress = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    let type_descr = INPUT?.type_descr;
    if (type_descr?.getQualifiedName === undefined || type_descr.getQualifiedName() !== "CL_ABAP_TYPEDESCR") { type_descr = undefined; }
    if (type_descr === undefined) { type_descr = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_TYPEDESCR", RTTIName: "\\CLASS=CL_ABAP_TYPEDESCR"}).set(INPUT.type_descr); }
    let name = INPUT?.name;
    if (name?.getQualifiedName === undefined || name.getQualifiedName() !== "STRING") { name = undefined; }
    if (name === undefined) { name = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.name); }
    rv_compress.set(abap.builtin.abap_true);
    return rv_compress;
  }
  async generate(INPUT) {
    return $ui2$cl_json.generate(INPUT);
  }
  static async generate(INPUT) {
    let rr_data = new abap.types.DataReference(new abap.types.Character(4));
    let json = INPUT?.json;
    if (json?.getQualifiedName === undefined || json.getQualifiedName() !== "STRING") { json = undefined; }
    if (json === undefined) { json = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.json); }
    let pretty_name = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.pretty_name) {pretty_name.set(INPUT.pretty_name);}
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return rr_data;
  }
  async serialize(INPUT) {
    return $ui2$cl_json.serialize(INPUT);
  }
  static async serialize(INPUT) {
    let r_json = new abap.types.String({qualifiedName: "STRING"});
    let data = INPUT?.data;
    let compress = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    if (INPUT && INPUT.compress) {compress.set(INPUT.compress);}
    let pretty_name = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.pretty_name) {pretty_name.set(INPUT.pretty_name);}
    let assoc_arrays = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    if (INPUT && INPUT.assoc_arrays) {assoc_arrays.set(INPUT.assoc_arrays);}
    let assoc_arrays_opt = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    if (INPUT && INPUT.assoc_arrays_opt) {assoc_arrays_opt.set(INPUT.assoc_arrays_opt);}
    let ts_as_iso8601 = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    if (INPUT && INPUT.ts_as_iso8601) {ts_as_iso8601.set(INPUT.ts_as_iso8601);}
    let type_descr = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_TYPEDESCR", RTTIName: "\\CLASS=CL_ABAP_TYPEDESCR"});
    if (INPUT && INPUT.type_descr) {type_descr.set(INPUT.type_descr);}
    let format_output = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    if (INPUT && INPUT.format_output) {format_output.set(INPUT.format_output);}
    let lo_json = new abap.types.ABAPObject({qualifiedName: "/UI2/CL_JSON", RTTIName: "\\CLASS=/UI2/CL_JSON"});
    abap.statements.assert(abap.compare.initial(format_output));
    lo_json.set(await (new abap.Classes['/UI2/CL_JSON']()).constructor_({compress: compress, pretty_name: pretty_name, assoc_arrays: assoc_arrays, ts_as_iso8601: ts_as_iso8601}));
    r_json.set((await lo_json.get().serialize_int({data: data, type_descr: type_descr})));
    return r_json;
  }
  async _deserialize(INPUT) {
    return $ui2$cl_json._deserialize(INPUT);
  }
  static async _deserialize(INPUT) {
    let prefix = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.prefix) {prefix.set(INPUT.prefix);}
    let pretty_name = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.pretty_name) {pretty_name.set(INPUT.pretty_name);}
    let io_type = INPUT?.io_type;
    if (io_type?.getQualifiedName === undefined || io_type.getQualifiedName() !== "CL_ABAP_TYPEDESCR") { io_type = undefined; }
    if (io_type === undefined) { io_type = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_TYPEDESCR", RTTIName: "\\CLASS=CL_ABAP_TYPEDESCR"}).set(INPUT.io_type); }
    let data = new abap.types.Character(4);
    if (INPUT && INPUT.data) {data = INPUT.data;}
    let lo_struct = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_STRUCTDESCR", RTTIName: "\\CLASS=CL_ABAP_STRUCTDESCR"});
    let lo_table = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_TABLEDESCR", RTTIName: "\\CLASS=CL_ABAP_TABLEDESCR"});
    let lo_refdescr = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_REFDESCR", RTTIName: "\\CLASS=CL_ABAP_REFDESCR"});
    let lt_components = abap.types.TableFactory.construct(new abap.types.Structure({"name": new abap.types.String({qualifiedName: "NAME"}), "type": new abap.types.ABAPObject({qualifiedName: "CL_ABAP_DATADESCR", RTTIName: "\\CLASS=CL_ABAP_DATADESCR"}), "as_include": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "suffix": new abap.types.String({qualifiedName: "SUFFIX"})}, "abap_componentdescr", undefined, {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "abap_component_tab");
    let ls_component = new abap.types.Structure({"name": new abap.types.String({qualifiedName: "NAME"}), "type": new abap.types.ABAPObject({qualifiedName: "CL_ABAP_DATADESCR", RTTIName: "\\CLASS=CL_ABAP_DATADESCR"}), "as_include": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "suffix": new abap.types.String({qualifiedName: "SUFFIX"})}, "abap_componentdescr", undefined, {}, {});
    let lt_members = abap.types.TableFactory.construct(new abap.types.String({qualifiedName: "STRING"}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"isUnique":false,"type":"STANDARD","keyFields":[],"name":"primary_key"},"secondary":[]}, "STRING_TABLE");
    let ref = new abap.types.DataReference(new abap.types.Character(4));
    let lv_name = new abap.types.String({qualifiedName: "STRING"});
    let lv_type = new abap.types.String({qualifiedName: "STRING"});
    let lv_value = new abap.types.String({qualifiedName: "STRING"});
    let lv_member = new abap.types.String({qualifiedName: "STRING"});
    let fs_any_ = new abap.types.FieldSymbol(new abap.types.Character(4));
    let fs_at_ = new abap.types.FieldSymbol(abap.types.TableFactory.construct(new abap.types.Character(4), {"withHeader":false,"keyType":"DEFAULT"}));
    let fs_ls_component_ = new abap.types.FieldSymbol(new abap.types.Structure({"name": new abap.types.String({qualifiedName: "NAME"}), "type": new abap.types.ABAPObject({qualifiedName: "CL_ABAP_DATADESCR", RTTIName: "\\CLASS=CL_ABAP_DATADESCR"}), "as_include": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "suffix": new abap.types.String({qualifiedName: "SUFFIX"})}, "abap_componentdescr", undefined, {}, {}));
    prefix.set((await $ui2$cl_json.mo_parsed.get().find_ignore_case({iv_path: prefix})));
    let unique65 = io_type.get().kind;
    if (abap.compare.eq(unique65, abap.Classes['CL_ABAP_TYPEDESCR'].kind_elem)) {
      if (abap.compare.eq(io_type.get().absolute_name, new abap.types.Character(30).set('\\TYPE-POOL=ABAP\\TYPE=ABAP_BOOL')) || abap.compare.eq(io_type.get().absolute_name, new abap.types.Character(18).set('\\TYPE=ABAP_BOOLEAN')) || abap.compare.eq(io_type.get().absolute_name, new abap.types.Character(10).set('\\TYPE=FLAG'))) {
        data.set(abap.builtin.boolc(abap.compare.eq((await $ui2$cl_json.mo_parsed.get().value_string({iv_path: prefix})), new abap.types.Character(4).set('true'))));
      } else if (abap.compare.eq(io_type.get().absolute_name, new abap.types.String().set(`\\TYPE=TIMESTAMP`)) || abap.compare.eq(io_type.get().absolute_name, new abap.types.String().set(`\\TYPE=TIMESTAMPL`))) {
        lv_value.set((await $ui2$cl_json.mo_parsed.get().value_string({iv_path: prefix})));
        abap.statements.replace({target: lv_value, all: true, with: new abap.types.Character(1).set(''), of: new abap.types.Character(1).set('-')});
        abap.statements.replace({target: lv_value, all: true, with: new abap.types.Character(1).set(''), of: new abap.types.Character(1).set('T')});
        abap.statements.replace({target: lv_value, all: true, with: new abap.types.Character(1).set(''), of: new abap.types.Character(1).set(':')});
        abap.statements.replace({target: lv_value, all: true, with: new abap.types.Character(1).set(''), of: new abap.types.Character(1).set('Z')});
        data.set(lv_value);
      } else if (abap.compare.eq(io_type.get().type_kind, abap.Classes['CL_ABAP_TYPEDESCR'].typekind_date)) {
        lv_value.set((await $ui2$cl_json.mo_parsed.get().value_string({iv_path: prefix})));
        abap.statements.replace({target: lv_value, all: true, with: new abap.types.Character(1).set(''), of: new abap.types.Character(1).set('-')});
        if (abap.compare.co(lv_value, abap.builtin.space)) {
          abap.statements.clear(data);
        } else {
          data.set(lv_value);
        }
      } else if (abap.compare.eq(io_type.get().type_kind, abap.Classes['CL_ABAP_TYPEDESCR'].typekind_time)) {
        lv_value.set((await $ui2$cl_json.mo_parsed.get().value_string({iv_path: prefix})));
        abap.statements.replace({target: lv_value, all: true, with: new abap.types.Character(1).set(''), of: new abap.types.Character(1).set(':')});
        if (abap.compare.co(lv_value, abap.builtin.space)) {
          abap.statements.clear(data);
        } else {
          data.set(lv_value);
        }
      } else {
        data.set((await $ui2$cl_json.mo_parsed.get().value_string({iv_path: prefix})));
      }
    } else if (abap.compare.eq(unique65, abap.Classes['CL_ABAP_TYPEDESCR'].kind_table)) {
      await abap.statements.cast(lo_table, io_type);
      lt_members.set((await $ui2$cl_json.mo_parsed.get().members({iv_path: abap.operators.concat(prefix,new abap.types.Character(1).set('/'))})));
      abap.statements.assign({target: fs_at_, source: data});
      for await (const unique66 of abap.statements.loop(lt_members)) {
        lv_member.set(unique66);
        abap.statements.createData(ref,{"likeLineOf": data});
        abap.statements.assign({target: fs_any_, source: ref.dereference()});
        await this._deserialize({prefix: abap.operators.concat(prefix,abap.operators.concat(new abap.types.Character(1).set('/'),lv_member)), pretty_name: pretty_name, io_type: (await lo_table.get().get_table_line_type()), data: fs_any_});
        abap.statements.insertInternal({data: fs_any_, table: fs_at_});
      }
    } else if (abap.compare.eq(unique65, abap.Classes['CL_ABAP_TYPEDESCR'].kind_struct)) {
      await abap.statements.cast(lo_struct, io_type);
      lt_components.set((await lo_struct.get().get_components()));
      for await (const unique67 of abap.statements.loop(lt_components)) {
        fs_ls_component_.assign(unique67);
        abap.statements.assign({component: fs_ls_component_.get().name, target: fs_any_, source: data});
        abap.statements.assert(abap.compare.eq(abap.builtin.sy.get().subrc, abap.IntegerFactory.get(0)));
        let unique68 = pretty_name;
        if (abap.compare.eq(unique68, $ui2$cl_json.pretty_mode.get().camel_case)) {
          lv_name.set(abap.builtin.to_mixed({val: abap.builtin.to_lower({val: fs_ls_component_.get().name})}));
        } else {
          lv_name.set(abap.builtin.to_lower({val: fs_ls_component_.get().name}));
        }
        await this._deserialize({prefix: abap.operators.concat(prefix,abap.operators.concat(new abap.types.Character(1).set('/'),lv_name)), pretty_name: pretty_name, io_type: fs_ls_component_.get().type, data: fs_any_});
      }
    } else if (abap.compare.eq(unique65, abap.Classes['CL_ABAP_TYPEDESCR'].kind_ref)) {
      await abap.statements.cast(lo_refdescr, io_type);
      if (abap.compare.initial(data)) {
        lt_members.set((await $ui2$cl_json.mo_parsed.get().members({iv_path: abap.operators.concat(prefix,new abap.types.Character(1).set('/'))})));
        if (abap.compare.eq(abap.builtin.lines({val: lt_members}), abap.IntegerFactory.get(0)) && abap.compare.eq(prefix, new abap.types.Character(1).set(''))) {
          return;
        }
        lv_type.set((await $ui2$cl_json.mo_parsed.get().get_type({iv_path: abap.operators.concat(prefix,new abap.types.Character(1).set('/'))})));
        if (abap.compare.initial(lv_type)) {
          lv_type.set((await $ui2$cl_json.mo_parsed.get().get_type({iv_path: prefix})));
        }
        if (abap.compare.gt(abap.builtin.lines({val: lt_members}), abap.IntegerFactory.get(0)) && abap.compare.eq(lv_type, new abap.types.Character(6).set('object'))) {
          abap.statements.clear(lt_components);
          for await (const unique69 of abap.statements.loop(lt_members)) {
            lv_member.set(unique69);
            abap.statements.clear(ls_component);
            ls_component.get().name.set(abap.builtin.to_upper({val: lv_member}));
            abap.statements.translate(ls_component.get().name, '-_');
            ls_component.get().type.set((await abap.Classes['CL_ABAP_REFDESCR'].get_ref_to_data()));
            abap.statements.assert(abap.compare.initial(ls_component.get().name) === false);
            abap.statements.append({source: ls_component, target: lt_components});
          }
          lo_struct.set((await abap.Classes['CL_ABAP_STRUCTDESCR'].create({p_components: lt_components})));
          if (abap.Classes['KERNEL_CREATE_DATA_HANDLE'] === undefined) throw new Error("CreateData, kernel class missing");
          await abap.Classes['KERNEL_CREATE_DATA_HANDLE'].call({handle: lo_struct, dref: data});
        } else if (abap.compare.eq(lv_type, new abap.types.Character(5).set('array'))) {
          lo_table.set((await abap.Classes['CL_ABAP_TABLEDESCR'].create({p_line_type: (await abap.Classes['CL_ABAP_REFDESCR'].get_ref_to_data())})));
          if (abap.Classes['KERNEL_CREATE_DATA_HANDLE'] === undefined) throw new Error("CreateData, kernel class missing");
          await abap.Classes['KERNEL_CREATE_DATA_HANDLE'].call({handle: lo_table, dref: data});
        } else {
          let unique70 = lv_type;
          if (abap.compare.eq(unique70, new abap.types.Character(3).set('num'))) {
            lv_value.set((await $ui2$cl_json.mo_parsed.get().value_string({iv_path: prefix})));
            if (abap.compare.co(lv_value, new abap.types.Character(11).set('-0123456789'))) {
              abap.statements.createData(data,{"typeName": "I"});
            } else if (abap.compare.co(lv_value, new abap.types.Character(12).set('-0123456789.'))) {
              abap.statements.createData(data,{"typeName": "F"});
            } else {
              abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
            }
          } else if (abap.compare.eq(unique70, new abap.types.Character(4).set('bool'))) {
            if (abap.Classes['KERNEL_CREATE_DATA_HANDLE'] === undefined) throw new Error("CreateData, kernel class missing");
            await abap.Classes['KERNEL_CREATE_DATA_HANDLE'].call({handle: (await abap.Classes['CL_ABAP_TYPEDESCR'].describe_by_name({p_name: new abap.types.Character(9).set('ABAP_BOOL')})), dref: data});
          } else if (abap.compare.eq(unique70, new abap.types.Character(3).set('str'))) {
            if (abap.Classes['KERNEL_CREATE_DATA_HANDLE'] === undefined) throw new Error("CreateData, kernel class missing");
            await abap.Classes['KERNEL_CREATE_DATA_HANDLE'].call({handle: (await abap.Classes['CL_ABAP_ELEMDESCR'].get_string()), dref: data});
          }
        }
      }
      abap.statements.assign({target: fs_any_, source: data.dereference()});
      await this._deserialize({prefix: prefix, pretty_name: pretty_name, io_type: (await abap.Classes['CL_ABAP_TYPEDESCR'].describe_by_data({p_data: fs_any_})), data: fs_any_});
    } else {
      abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(21).set('cl_json, unknown kind')));
    }
  }
}
abap.Classes['/UI2/CL_JSON'] = $ui2$cl_json;
$ui2$cl_json.mo_parsed = new abap.types.ABAPObject({qualifiedName: "LCL_PARSER", RTTIName: "\\CLASS-POOL=/UI2/CL_JSON\\CLASS=LCL_PARSER"});
$ui2$cl_json.pretty_mode = new abap.types.Structure({"none": new abap.types.String({qualifiedName: "STRING"}), "low_case": new abap.types.String({qualifiedName: "STRING"}), "camel_case": new abap.types.String({qualifiedName: "STRING"})}, undefined, undefined, {}, {});
$ui2$cl_json.pretty_mode.get().none.set('');
$ui2$cl_json.pretty_mode.get().low_case.set('low_case');
$ui2$cl_json.pretty_mode.get().camel_case.set('camel_case');
$ui2$cl_json.pretty_name_mode = new abap.types.String({qualifiedName: "/UI2/CL_JSON=>PRETTY_NAME_MODE"});
$ui2$cl_json.tribool = new abap.types.Character(1, {"qualifiedName":"/ui2/cl_json=>tribool"});
export {$ui2$cl_json};
//# sourceMappingURL=%23ui2%23cl_json.clas.mjs.map