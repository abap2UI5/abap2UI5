const {cx_root} = await import("./cx_root.clas.mjs");
// kernel_call_transformation.clas.locals_imp.abap
class lcl_heap {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CLAS-KERNEL_CALL_TRANSFORMATION-LCL_HEAP';
  static IMPLEMENTED_INTERFACES = [];
  static ATTRIBUTES = {"MV_COUNTER": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "I", "is_constant": " ", "is_class": " "},
  "MV_DATA": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "visibility": "I", "is_constant": " ", "is_class": " "}};
  static METHODS = {"ADD_OBJECT": {"visibility": "U", "parameters": {"RV_ID": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "IV_REF": {"type": () => {return new abap.types.Character(4);}, "is_optional": " "}}},
  "ADD_DATA": {"visibility": "U", "parameters": {"RV_ID": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "IV_REF": {"type": () => {return new abap.types.Character(4);}, "is_optional": " "}}},
  "SERIALIZE": {"visibility": "U", "parameters": {"RV_XML": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}}};
  constructor() {
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
    this.mv_counter = new abap.types.Integer({qualifiedName: "I"});
    this.mv_data = new abap.types.String({qualifiedName: "STRING"});
  }
  async constructor_(INPUT) {
    if (super.constructor_) { await super.constructor_(INPUT); }
    return this;
  }
  async serialize() {
    let rv_xml = new abap.types.String({qualifiedName: "STRING"});
    if (abap.compare.eq(this.mv_counter, abap.IntegerFactory.get(0))) {
      return rv_xml;
    }
    rv_xml.set(abap.operators.concat(rv_xml,new abap.types.String().set(`<asx:heap xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:abap="http://www.sap.com/abapxml/types/built-in" xmlns:cls="http://www.sap.com/abapxml/classes/global" xmlns:dic="http://www.sap.com/abapxml/types/dictionary">`)));
    rv_xml.set(abap.operators.concat(rv_xml,this.mv_data));
    rv_xml.set(abap.operators.concat(rv_xml,new abap.types.String().set(`</asx:heap>`)));
    return rv_xml;
  }
  async add_data(INPUT) {
    let rv_id = new abap.types.String({qualifiedName: "STRING"});
    let iv_ref = INPUT?.iv_ref;
    let lo_descr = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_DATADESCR", RTTIName: "\\CLASS=CL_ABAP_DATADESCR"});
    let lv_data = new abap.types.String({qualifiedName: "STRING"});
    let lv_name = new abap.types.String({qualifiedName: "STRING"});
    let lo_data_to_xml = new abap.types.ABAPObject({qualifiedName: "LCL_DATA_TO_XML", RTTIName: "\\CLASS-POOL=KERNEL_CALL_TRANSFORMATION\\CLASS=LCL_DATA_TO_XML"});
    let lv_counter = new abap.types.Integer({qualifiedName: "I"});
    this.mv_counter.set(abap.operators.add(this.mv_counter,abap.IntegerFactory.get(1)));
    lv_counter.set(this.mv_counter);
    await abap.statements.cast(lo_descr, (await abap.Classes['CL_ABAP_TYPEDESCR'].describe_by_data({p_data: iv_ref})));
    lv_name.set(lo_descr.get().relative_name);
    lo_data_to_xml.set(await (new abap.Classes['CLAS-KERNEL_CALL_TRANSFORMATION-LCL_DATA_TO_XML']()).constructor_({io_heap: this.me}));
    abap.statements.replace({target: lv_name, all: true, with: new abap.types.Character(1).set('.'), of: new abap.types.Character(2).set('=>')});
    lv_data.set(abap.operators.concat(lv_data,new abap.types.String().set(`<prg:${abap.templateFormatting(lv_name)} xmlns:prg="http://www.sap.com/abapxml/classes/class-pool/TODO" id="d${abap.templateFormatting(this.mv_counter)}">`)));
    lv_data.set(abap.operators.concat(lv_data,(await lo_data_to_xml.get().run({iv_name: new abap.types.Character(7).set('DATAREF'), iv_ref: iv_ref}))));
    lv_data.set(abap.operators.concat(lv_data,new abap.types.String().set(`</prg:${abap.templateFormatting(lv_name)}>`)));
    this.mv_data.set(abap.operators.concat(this.mv_data,lv_data));
    rv_id.set(new abap.types.String().set(`${abap.templateFormatting(lv_counter)}`));
    return rv_id;
  }
  async add_object(INPUT) {
    let rv_id = new abap.types.String({qualifiedName: "STRING"});
    let iv_ref = INPUT?.iv_ref;
    let lv_name = new abap.types.String({qualifiedName: "STRING"});
    let is_serializable = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    let lo_descr = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_CLASSDESCR", RTTIName: "\\CLASS=CL_ABAP_CLASSDESCR"});
    let ls_interface = new abap.types.Structure({"name": new abap.types.Character(30, {"qualifiedName":"abap_intfname"}), "is_inherited": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"})}, "abap_intfdescr", undefined, {}, {});
    let ls_attribute = new abap.types.Structure({"length": new abap.types.Integer({qualifiedName: "LENGTH"}), "decimals": new abap.types.Integer({qualifiedName: "DECIMALS"}), "name": new abap.types.Character(61, {"qualifiedName":"abap_attrname"}), "type_kind": new abap.types.Character(1, {"qualifiedName":"abap_typekind"}), "visibility": new abap.types.Character(1, {"qualifiedName":"abap_visibility"}), "is_interface": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "is_inherited": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "is_class": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "is_constant": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "is_virtual": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "is_read_only": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "alias_for": new abap.types.Character(61, {"qualifiedName":"abap_attrname"})}, "abap_attrdescr", undefined, {}, {});
    let lo_data_to_xml = new abap.types.ABAPObject({qualifiedName: "LCL_DATA_TO_XML", RTTIName: "\\CLASS-POOL=KERNEL_CALL_TRANSFORMATION\\CLASS=LCL_DATA_TO_XML"});
    let lv_ref = new abap.types.DataReference(new abap.types.Character(4));
    let lv_internal = new abap.types.String({qualifiedName: "STRING"});
    let lv_data = new abap.types.String({qualifiedName: "STRING"});
    let lv_counter = new abap.types.Integer({qualifiedName: "I"});
    let fs_any_ = new abap.types.FieldSymbol(new abap.types.DataReference(new abap.types.Character(4)));
    this.mv_counter.set(abap.operators.add(this.mv_counter,abap.IntegerFactory.get(1)));
    lv_counter.set(this.mv_counter);
    await abap.statements.cast(lo_descr, (await abap.Classes['CL_ABAP_TYPEDESCR'].describe_by_object_ref({p_object_ref: iv_ref})));
    lv_name.set(lo_descr.get().relative_name);
    for await (const unique71 of abap.statements.loop(lo_descr.get().interfaces)) {
      ls_interface.set(unique71);
      if (abap.compare.eq(ls_interface.get().name, new abap.types.Character(22).set('IF_SERIALIZABLE_OBJECT'))) {
        is_serializable.set(abap.builtin.abap_true);
      }
    }
    lv_internal.set(iv_ref.get().constructor.INTERNAL_NAME);
    if (abap.compare.eq(is_serializable, abap.builtin.abap_true)) {
      lo_data_to_xml.set(await (new abap.Classes['CLAS-KERNEL_CALL_TRANSFORMATION-LCL_DATA_TO_XML']()).constructor_({io_heap: this.me}));
      lv_data.set(abap.operators.concat(lv_data,abap.operators.concat(new abap.types.String().set(`<prg:${abap.templateFormatting(lv_name)} xmlns:prg="http://www.sap.com/abapxml/classes/class-pool/TODO" id="o${abap.templateFormatting(this.mv_counter)}" internalName="${abap.templateFormatting(lv_internal)}">`),new abap.types.String().set(`<local.${abap.templateFormatting(lv_name)}>`))));
      for await (const unique72 of abap.statements.loop(lo_descr.get().attributes,{where: async (I) => {return abap.compare.eq(I.is_class, abap.builtin.abap_false);},topEquals: {"is_class": abap.builtin.abap_false}})) {
        ls_attribute.set(unique72);
        abap.statements.assign({target: fs_any_, dynamicName: 'iv_ref' + '->' + ls_attribute.get().name.get(), dynamicSource: (() => {
                    try { return iv_ref; } catch {}
                    try { return this.iv_ref; } catch {}
                  })()});
          abap.statements.assert(abap.compare.eq(abap.builtin.sy.get().subrc, abap.IntegerFactory.get(0)));
          abap.statements.replace({target: ls_attribute.get().name, all: false, with: new abap.types.Character(1).set('.'), of: new abap.types.Character(1).set('~')});
          lv_ref.assign(fs_any_.getPointer());
          lv_data.set(abap.operators.concat(lv_data,(await lo_data_to_xml.get().run({iv_name: ls_attribute.get().name, iv_ref: lv_ref}))));
        }
        lv_data.set(abap.operators.concat(lv_data,abap.operators.concat(new abap.types.String().set(`</local.${abap.templateFormatting(lv_name)}>`),new abap.types.String().set(`</prg:${abap.templateFormatting(lv_name)}>`))));
      } else {
        lv_data.set(abap.operators.concat(lv_data,new abap.types.String().set(`<prg:${abap.templateFormatting(lv_name)} xmlns:prg="http://www.sap.com/abapxml/classes/class-pool/TODO" id="o${abap.templateFormatting(this.mv_counter)}"/>`)));
      }
      this.mv_data.set(abap.operators.concat(this.mv_data,lv_data));
      rv_id.set(new abap.types.String().set(`${abap.templateFormatting(lv_counter)}`));
      return rv_id;
    }
  }
  abap.Classes['CLAS-KERNEL_CALL_TRANSFORMATION-LCL_HEAP'] = lcl_heap;
  class lcl_data_to_xml {
    static INTERNAL_TYPE = 'CLAS';
    static INTERNAL_NAME = 'CLAS-KERNEL_CALL_TRANSFORMATION-LCL_DATA_TO_XML';
    static IMPLEMENTED_INTERFACES = [];
    static ATTRIBUTES = {"MO_HEAP": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "LCL_HEAP", RTTIName: "\\CLASS-POOL=KERNEL_CALL_TRANSFORMATION\\CLASS=LCL_HEAP"});}, "visibility": "I", "is_constant": " ", "is_class": " "},
    "MS_OPTIONS": {"type": () => {return new abap.types.Structure({"initial_components": new abap.types.String({qualifiedName: "KERNEL_CALL_TRANSFORMATION=>TY_OPTIONS-INITIAL_COMPONENTS"}), "xml_header": new abap.types.String({qualifiedName: "KERNEL_CALL_TRANSFORMATION=>TY_OPTIONS-XML_HEADER"})}, "kernel_call_transformation=>ty_options", undefined, {}, {});}, "visibility": "I", "is_constant": " ", "is_class": " "}};
    static METHODS = {"CONSTRUCTOR": {"visibility": "U", "parameters": {"IS_OPTIONS": {"type": () => {return new abap.types.Structure({"initial_components": new abap.types.String({qualifiedName: "KERNEL_CALL_TRANSFORMATION=>TY_OPTIONS-INITIAL_COMPONENTS"}), "xml_header": new abap.types.String({qualifiedName: "KERNEL_CALL_TRANSFORMATION=>TY_OPTIONS-XML_HEADER"})}, "kernel_call_transformation=>ty_options", undefined, {}, {});}, "is_optional": " "}, "IO_HEAP": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "LCL_HEAP", RTTIName: "\\CLASS-POOL=KERNEL_CALL_TRANSFORMATION\\CLASS=LCL_HEAP"});}, "is_optional": " "}}},
    "RUN": {"visibility": "U", "parameters": {"RV_XML": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "IV_NAME": {"type": () => {return new abap.types.Character();}, "is_optional": " "}, "IV_REF": {"type": () => {return new abap.types.DataReference(new abap.types.Character(4));}, "is_optional": " "}}},
    "SERIALIZE_HEAP": {"visibility": "U", "parameters": {"RV_XML": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}}};
    constructor() {
      this.me = new abap.types.ABAPObject();
      this.me.set(this);
      this.mo_heap = new abap.types.ABAPObject({qualifiedName: "LCL_HEAP", RTTIName: "\\CLASS-POOL=KERNEL_CALL_TRANSFORMATION\\CLASS=LCL_HEAP"});
      this.ms_options = new abap.types.Structure({"initial_components": new abap.types.String({qualifiedName: "KERNEL_CALL_TRANSFORMATION=>TY_OPTIONS-INITIAL_COMPONENTS"}), "xml_header": new abap.types.String({qualifiedName: "KERNEL_CALL_TRANSFORMATION=>TY_OPTIONS-XML_HEADER"})}, "kernel_call_transformation=>ty_options", undefined, {}, {});
    }
    async constructor_(INPUT) {
      let is_options = new abap.types.Structure({"initial_components": new abap.types.String({qualifiedName: "KERNEL_CALL_TRANSFORMATION=>TY_OPTIONS-INITIAL_COMPONENTS"}), "xml_header": new abap.types.String({qualifiedName: "KERNEL_CALL_TRANSFORMATION=>TY_OPTIONS-XML_HEADER"})}, "kernel_call_transformation=>ty_options", undefined, {}, {});
      if (INPUT && INPUT.is_options) {is_options.set(INPUT.is_options);}
      let io_heap = new abap.types.ABAPObject({qualifiedName: "LCL_HEAP", RTTIName: "\\CLASS-POOL=KERNEL_CALL_TRANSFORMATION\\CLASS=LCL_HEAP"});
      if (INPUT && INPUT.io_heap) {io_heap.set(INPUT.io_heap);}
      if (abap.compare.initial(io_heap)) {
        this.mo_heap.set(await (new abap.Classes['CLAS-KERNEL_CALL_TRANSFORMATION-LCL_HEAP']()).constructor_());
      } else {
        this.mo_heap.set(io_heap);
      }
      this.ms_options.set(is_options);
      return this;
    }
    async serialize_heap() {
      let rv_xml = new abap.types.String({qualifiedName: "STRING"});
      rv_xml.set((await this.mo_heap.get().serialize()));
      return rv_xml;
    }
    async run(INPUT) {
      let rv_xml = new abap.types.String({qualifiedName: "STRING"});
      let iv_name = INPUT?.iv_name;
      let iv_ref = INPUT?.iv_ref;
      if (iv_ref === undefined) { iv_ref = new abap.types.DataReference(new abap.types.Character(4)).set(INPUT.iv_ref); }
      let lo_type = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_TYPEDESCR", RTTIName: "\\CLASS=CL_ABAP_TYPEDESCR"});
      let lo_struc = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_STRUCTDESCR", RTTIName: "\\CLASS=CL_ABAP_STRUCTDESCR"});
      let lt_comps = abap.types.TableFactory.construct(new abap.types.Structure({"name": new abap.types.String({qualifiedName: "NAME"}), "type": new abap.types.ABAPObject({qualifiedName: "CL_ABAP_DATADESCR", RTTIName: "\\CLASS=CL_ABAP_DATADESCR"}), "as_include": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "suffix": new abap.types.String({qualifiedName: "SUFFIX"})}, "abap_componentdescr", undefined, {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "abap_component_tab");
      let ls_compo = new abap.types.Structure({"name": new abap.types.String({qualifiedName: "NAME"}), "type": new abap.types.ABAPObject({qualifiedName: "CL_ABAP_DATADESCR", RTTIName: "\\CLASS=CL_ABAP_DATADESCR"}), "as_include": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "suffix": new abap.types.String({qualifiedName: "SUFFIX"})}, "abap_componentdescr", undefined, {}, {});
      let lv_ref = new abap.types.DataReference(new abap.types.Character(4));
      let fs_any_ = new abap.types.FieldSymbol(new abap.types.Character(4));
      let fs_table_ = new abap.types.FieldSymbol(abap.types.TableFactory.construct(new abap.types.Character(4), {"withHeader":false,"keyType":"DEFAULT"}));
      let fs_field_ = new abap.types.FieldSymbol(new abap.types.Character(4));
      lo_type.set((await abap.Classes['CL_ABAP_TYPEDESCR'].describe_by_data({p_data: iv_ref.dereference()})));
      let unique73 = lo_type.get().kind;
      if (abap.compare.eq(unique73, abap.Classes['CL_ABAP_TYPEDESCR'].kind_struct)) {
        await abap.statements.cast(lo_struc, lo_type);
        lt_comps.set((await lo_struc.get().get_components()));
        abap.statements.assign({target: fs_any_, source: iv_ref.dereference()});
        if (abap.compare.eq(this.ms_options.get().initial_components, abap.Classes['KERNEL_CALL_TRANSFORMATION'].gc_options.get().suppress) && abap.compare.initial(fs_any_)) {
          rv_xml.set(abap.operators.concat(rv_xml,new abap.types.String().set(`<${abap.templateFormatting(iv_name)}/>`)));
          return rv_xml;
        }
        rv_xml.set(abap.operators.concat(rv_xml,new abap.types.String().set(`<${abap.templateFormatting(iv_name)}>`)));
        for await (const unique74 of abap.statements.loop(lt_comps)) {
          ls_compo.set(unique74);
          abap.statements.assign({component: ls_compo.get().name, target: fs_field_, source: fs_any_});
          lv_ref.assign(fs_field_.getPointer());
          rv_xml.set(abap.operators.concat(rv_xml,(await this.run({iv_name: abap.builtin.to_upper({val: ls_compo.get().name}), iv_ref: lv_ref}))));
        }
        rv_xml.set(abap.operators.concat(rv_xml,new abap.types.String().set(`</${abap.templateFormatting(iv_name)}>`)));
      } else if (abap.compare.eq(unique73, abap.Classes['CL_ABAP_TYPEDESCR'].kind_elem)) {
        if (abap.compare.eq(this.ms_options.get().initial_components, abap.Classes['KERNEL_CALL_TRANSFORMATION'].gc_options.get().suppress) && abap.compare.initial(iv_ref.dereference())) {
          return rv_xml;
        }
        if (abap.compare.eq(lo_type.get().type_kind, abap.Classes['CL_ABAP_TYPEDESCR'].typekind_string) && abap.compare.initial(iv_ref.dereference())) {
          rv_xml.set(abap.operators.concat(rv_xml,new abap.types.String().set(`<${abap.templateFormatting(iv_name)}/>`)));
        } else {
          rv_xml.set(abap.operators.concat(rv_xml,abap.operators.concat(new abap.types.String().set(`<${abap.templateFormatting(iv_name)}>`),abap.operators.concat(iv_ref.dereference(),new abap.types.String().set(`</${abap.templateFormatting(iv_name)}>`)))));
        }
      } else if (abap.compare.eq(unique73, abap.Classes['CL_ABAP_TYPEDESCR'].kind_table)) {
        abap.statements.assign({target: fs_table_, source: iv_ref.dereference()});
        if (abap.compare.eq(this.ms_options.get().initial_components, abap.Classes['KERNEL_CALL_TRANSFORMATION'].gc_options.get().suppress) && abap.compare.initial(fs_table_)) {
          rv_xml.set(abap.operators.concat(rv_xml,new abap.types.String().set(`<${abap.templateFormatting(iv_name)}/>`)));
          return rv_xml;
        }
        rv_xml.set(abap.operators.concat(rv_xml,new abap.types.String().set(`<${abap.templateFormatting(iv_name)}>`)));
        for await (const unique75 of abap.statements.loop(fs_table_)) {
          fs_any_.assign(unique75);
          lv_ref.assign(fs_any_.getPointer());
          rv_xml.set(abap.operators.concat(rv_xml,(await this.run({iv_name: new abap.types.String().set(`item`), iv_ref: lv_ref}))));
        }
        rv_xml.set(abap.operators.concat(rv_xml,new abap.types.String().set(`</${abap.templateFormatting(iv_name)}>`)));
      } else if (abap.compare.eq(unique73, abap.Classes['CL_ABAP_TYPEDESCR'].kind_ref)) {
        let unique76 = lo_type.get().type_kind;
        if (abap.compare.eq(unique76, abap.Classes['CL_ABAP_TYPEDESCR'].typekind_oref)) {
          if (abap.compare.initial(iv_ref.dereference())) {
            rv_xml.set(new abap.types.String().set(`<${abap.templateFormatting(iv_name)}/>`));
          } else {
            rv_xml.set(new abap.types.String().set(`<${abap.templateFormatting(iv_name)} href="#o${abap.templateFormatting((await this.mo_heap.get().add_object({iv_ref: iv_ref.dereference()})))}"/>`));
          }
        } else {
          if (abap.compare.initial(iv_ref.dereference())) {
            rv_xml.set(new abap.types.String().set(`<${abap.templateFormatting(iv_name)}/>`));
          } else {
            rv_xml.set(new abap.types.String().set(`<${abap.templateFormatting(iv_name)} href="#d${abap.templateFormatting((await this.mo_heap.get().add_data({iv_ref: iv_ref.dereference()})))}"/>`));
          }
        }
      } else {
        abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(21).set('todo,lcl_data_to_xml2')));
      }
      return rv_xml;
    }
  }
  abap.Classes['CLAS-KERNEL_CALL_TRANSFORMATION-LCL_DATA_TO_XML'] = lcl_data_to_xml;
  class lcl_object_to_sxml {
    static INTERNAL_TYPE = 'CLAS';
    static INTERNAL_NAME = 'CLAS-KERNEL_CALL_TRANSFORMATION-LCL_OBJECT_TO_SXML';
    static IMPLEMENTED_INTERFACES = [];
    static ATTRIBUTES = {"MI_WRITER": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_SXML_WRITER", RTTIName: "\\INTERFACE=IF_SXML_WRITER"});}, "visibility": "I", "is_constant": " ", "is_class": "X"}};
    static METHODS = {"TRAVERSE_WRITE": {"visibility": "I", "parameters": {"IV_REF": {"type": () => {return new abap.types.DataReference(new abap.types.Character(4));}, "is_optional": " "}}},
    "TRAVERSE_WRITE_TYPE": {"visibility": "I", "parameters": {"RV_TYPE": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "IV_REF": {"type": () => {return new abap.types.DataReference(new abap.types.Character(4));}, "is_optional": " "}}},
    "RUN": {"visibility": "U", "parameters": {"II_WRITER": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_SXML_WRITER", RTTIName: "\\INTERFACE=IF_SXML_WRITER"});}, "is_optional": " "}, "SOURCE": {"type": () => {return new abap.types.Character(4);}, "is_optional": " "}}}};
    constructor() {
      this.me = new abap.types.ABAPObject();
      this.me.set(this);
      this.mi_writer = lcl_object_to_sxml.mi_writer;
    }
    async constructor_(INPUT) {
      if (super.constructor_) { await super.constructor_(INPUT); }
      return this;
    }
    async run(INPUT) {
      return lcl_object_to_sxml.run(INPUT);
    }
    static async run(INPUT) {
      let ii_writer = INPUT?.ii_writer;
      if (ii_writer?.getQualifiedName === undefined || ii_writer.getQualifiedName() !== "IF_SXML_WRITER") { ii_writer = undefined; }
      if (ii_writer === undefined) { ii_writer = new abap.types.ABAPObject({qualifiedName: "IF_SXML_WRITER", RTTIName: "\\INTERFACE=IF_SXML_WRITER"}).set(INPUT.ii_writer); }
      let source = INPUT?.source;
      let lv_name = new abap.types.String({qualifiedName: "STRING"});
      let result = new abap.types.DataReference(new abap.types.Character(4));
      lcl_object_to_sxml.mi_writer.set(ii_writer);
      await lcl_object_to_sxml.mi_writer.get().if_sxml_writer$open_element({name: new abap.types.Character(6).set('object')});
      for (const name in INPUT.source) {
          lv_name.set(name);
          if (INPUT.source[name].constructor.name === "FieldSymbol") {
              result.assign(INPUT.source[name].getPointer());
            } else {
                result.assign(INPUT.source[name]);
              }
            await lcl_object_to_sxml.mi_writer.get().if_sxml_writer$open_element({name: new abap.types.Character(3).set('str')});
            await lcl_object_to_sxml.mi_writer.get().if_sxml_writer$write_attribute({name: new abap.types.Character(4).set('name'), value: abap.builtin.to_upper({val: lv_name})});
            await this.traverse_write({iv_ref: result});
            await lcl_object_to_sxml.mi_writer.get().if_sxml_writer$close_element();
          }
          await lcl_object_to_sxml.mi_writer.get().if_sxml_writer$close_element();
        }
        async traverse_write_type(INPUT) {
          return lcl_object_to_sxml.traverse_write_type(INPUT);
        }
        static async traverse_write_type(INPUT) {
          let rv_type = new abap.types.String({qualifiedName: "STRING"});
          let iv_ref = INPUT?.iv_ref;
          if (iv_ref === undefined) { iv_ref = new abap.types.DataReference(new abap.types.Character(4)).set(INPUT.iv_ref); }
          let lo_type = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_TYPEDESCR", RTTIName: "\\CLASS=CL_ABAP_TYPEDESCR"});
          lo_type.set((await abap.Classes['CL_ABAP_TYPEDESCR'].describe_by_data({p_data: iv_ref.dereference()})));
          let unique77 = lo_type.get().type_kind;
          if (abap.compare.eq(unique77, abap.Classes['CL_ABAP_TYPEDESCR'].typekind_int) || abap.compare.eq(unique77, abap.Classes['CL_ABAP_TYPEDESCR'].typekind_int1) || abap.compare.eq(unique77, abap.Classes['CL_ABAP_TYPEDESCR'].typekind_int2) || abap.compare.eq(unique77, abap.Classes['CL_ABAP_TYPEDESCR'].typekind_int8) || abap.compare.eq(unique77, abap.Classes['CL_ABAP_TYPEDESCR'].typekind_decfloat) || abap.compare.eq(unique77, abap.Classes['CL_ABAP_TYPEDESCR'].typekind_decfloat16) || abap.compare.eq(unique77, abap.Classes['CL_ABAP_TYPEDESCR'].typekind_decfloat34)) {
            rv_type.set(new abap.types.Character(3).set('num'));
          } else {
            rv_type.set(new abap.types.Character(3).set('str'));
          }
          return rv_type;
        }
        async traverse_write(INPUT) {
          return lcl_object_to_sxml.traverse_write(INPUT);
        }
        static async traverse_write(INPUT) {
          let iv_ref = INPUT?.iv_ref;
          if (iv_ref === undefined) { iv_ref = new abap.types.DataReference(new abap.types.Character(4)).set(INPUT.iv_ref); }
          let lo_type = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_TYPEDESCR", RTTIName: "\\CLASS=CL_ABAP_TYPEDESCR"});
          let lo_struc = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_STRUCTDESCR", RTTIName: "\\CLASS=CL_ABAP_STRUCTDESCR"});
          let lt_comps = abap.types.TableFactory.construct(new abap.types.Structure({"name": new abap.types.String({qualifiedName: "NAME"}), "type": new abap.types.ABAPObject({qualifiedName: "CL_ABAP_DATADESCR", RTTIName: "\\CLASS=CL_ABAP_DATADESCR"}), "as_include": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "suffix": new abap.types.String({qualifiedName: "SUFFIX"})}, "abap_componentdescr", undefined, {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "abap_component_tab");
          let ls_compo = new abap.types.Structure({"name": new abap.types.String({qualifiedName: "NAME"}), "type": new abap.types.ABAPObject({qualifiedName: "CL_ABAP_DATADESCR", RTTIName: "\\CLASS=CL_ABAP_DATADESCR"}), "as_include": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "suffix": new abap.types.String({qualifiedName: "SUFFIX"})}, "abap_componentdescr", undefined, {}, {});
          let lv_ref = new abap.types.DataReference(new abap.types.Character(4));
          let fs_any_ = new abap.types.FieldSymbol(new abap.types.Character(4));
          let fs_table_ = new abap.types.FieldSymbol(abap.types.TableFactory.construct(new abap.types.Character(4), {"withHeader":false,"keyType":"DEFAULT"}));
          let fs_field_ = new abap.types.FieldSymbol(new abap.types.Character(4));
          lo_type.set((await abap.Classes['CL_ABAP_TYPEDESCR'].describe_by_data({p_data: iv_ref.dereference()})));
          let unique78 = lo_type.get().kind;
          if (abap.compare.eq(unique78, abap.Classes['CL_ABAP_TYPEDESCR'].kind_struct)) {
            await lcl_object_to_sxml.mi_writer.get().if_sxml_writer$open_element({name: new abap.types.Character(6).set('object')});
            await abap.statements.cast(lo_struc, lo_type);
            lt_comps.set((await lo_struc.get().get_components()));
            abap.statements.assign({target: fs_any_, source: iv_ref.dereference()});
            for await (const unique79 of abap.statements.loop(lt_comps)) {
              ls_compo.set(unique79);
              abap.statements.assign({component: ls_compo.get().name, target: fs_field_, source: fs_any_});
              lv_ref.assign(fs_field_.getPointer());
              await lcl_object_to_sxml.mi_writer.get().if_sxml_writer$open_element({name: (await this.traverse_write_type({iv_ref: lv_ref}))});
              await lcl_object_to_sxml.mi_writer.get().if_sxml_writer$write_attribute({name: new abap.types.Character(4).set('name'), value: abap.builtin.to_upper({val: ls_compo.get().name})});
              await this.traverse_write({iv_ref: lv_ref});
              await lcl_object_to_sxml.mi_writer.get().if_sxml_writer$close_element();
            }
            await lcl_object_to_sxml.mi_writer.get().if_sxml_writer$close_element();
          } else if (abap.compare.eq(unique78, abap.Classes['CL_ABAP_TYPEDESCR'].kind_elem)) {
            await lcl_object_to_sxml.mi_writer.get().if_sxml_writer$write_value({value: iv_ref.dereference()});
          } else if (abap.compare.eq(unique78, abap.Classes['CL_ABAP_TYPEDESCR'].kind_table)) {
            await lcl_object_to_sxml.mi_writer.get().if_sxml_writer$open_element({name: new abap.types.Character(5).set('array')});
            abap.statements.assign({target: fs_table_, source: iv_ref.dereference()});
            for await (const unique80 of abap.statements.loop(fs_table_)) {
              fs_any_.assign(unique80);
              lv_ref.assign(fs_any_.getPointer());
              if (abap.compare.eq(((await abap.Classes['CL_ABAP_TYPEDESCR'].describe_by_data({p_data: lv_ref.dereference()}))).get().kind, abap.Classes['CL_ABAP_TYPEDESCR'].kind_elem)) {
                await lcl_object_to_sxml.mi_writer.get().if_sxml_writer$open_element({name: (await this.traverse_write_type({iv_ref: lv_ref}))});
              }
              await this.traverse_write({iv_ref: lv_ref});
              if (abap.compare.eq(((await abap.Classes['CL_ABAP_TYPEDESCR'].describe_by_data({p_data: lv_ref.dereference()}))).get().kind, abap.Classes['CL_ABAP_TYPEDESCR'].kind_elem)) {
                await lcl_object_to_sxml.mi_writer.get().if_sxml_writer$close_element();
              }
            }
            await lcl_object_to_sxml.mi_writer.get().if_sxml_writer$close_element();
          } else {
            abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(19).set('todo_traverse_write')));
          }
        }
      }
      abap.Classes['CLAS-KERNEL_CALL_TRANSFORMATION-LCL_OBJECT_TO_SXML'] = lcl_object_to_sxml;
      lcl_object_to_sxml.mi_writer = new abap.types.ABAPObject({qualifiedName: "IF_SXML_WRITER", RTTIName: "\\INTERFACE=IF_SXML_WRITER"});
      class lcl_object_to_string {
        static INTERNAL_TYPE = 'CLAS';
        static INTERNAL_NAME = 'CLAS-KERNEL_CALL_TRANSFORMATION-LCL_OBJECT_TO_STRING';
        static IMPLEMENTED_INTERFACES = [];
        static ATTRIBUTES = {};
        static METHODS = {"RUN": {"visibility": "U", "parameters": {"RV_RESULT": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "IS_OPTIONS": {"type": () => {return new abap.types.Structure({"initial_components": new abap.types.String({qualifiedName: "KERNEL_CALL_TRANSFORMATION=>TY_OPTIONS-INITIAL_COMPONENTS"}), "xml_header": new abap.types.String({qualifiedName: "KERNEL_CALL_TRANSFORMATION=>TY_OPTIONS-XML_HEADER"})}, "kernel_call_transformation=>ty_options", undefined, {}, {});}, "is_optional": " "}, "SOURCE": {"type": () => {return new abap.types.Character(4);}, "is_optional": " "}}}};
        constructor() {
          this.me = new abap.types.ABAPObject();
          this.me.set(this);
        }
        async constructor_(INPUT) {
          if (super.constructor_) { await super.constructor_(INPUT); }
          return this;
        }
        async run(INPUT) {
          return lcl_object_to_string.run(INPUT);
        }
        static async run(INPUT) {
          let rv_result = new abap.types.String({qualifiedName: "STRING"});
          let is_options = INPUT?.is_options;
          if (is_options?.getQualifiedName === undefined || is_options.getQualifiedName() !== "KERNEL_CALL_TRANSFORMATION=>TY_OPTIONS") { is_options = undefined; }
          if (is_options === undefined) { is_options = new abap.types.Structure({"initial_components": new abap.types.String({qualifiedName: "KERNEL_CALL_TRANSFORMATION=>TY_OPTIONS-INITIAL_COMPONENTS"}), "xml_header": new abap.types.String({qualifiedName: "KERNEL_CALL_TRANSFORMATION=>TY_OPTIONS-XML_HEADER"})}, "kernel_call_transformation=>ty_options", undefined, {}, {}).set(INPUT.is_options); }
          let source = INPUT?.source;
          let lv_name = new abap.types.String({qualifiedName: "STRING"});
          let lo_data_to_xml = new abap.types.ABAPObject({qualifiedName: "LCL_DATA_TO_XML", RTTIName: "\\CLASS-POOL=KERNEL_CALL_TRANSFORMATION\\CLASS=LCL_DATA_TO_XML"});
          let result = new abap.types.DataReference(new abap.types.Character(4));
          rv_result.set(new abap.types.Character(114).set('<?xml version="1.0" encoding="utf-16"?><asx:abap xmlns:asx="http://www.sap.com/abapxml" version="1.0"><asx:values>'));
          lo_data_to_xml.set(await (new abap.Classes['CLAS-KERNEL_CALL_TRANSFORMATION-LCL_DATA_TO_XML']()).constructor_({is_options: is_options}));
          if (INPUT.source.constructor.name === "Object") {
              for (const name in INPUT.source) {
                  lv_name.set(name);
                  if (INPUT.source[name].constructor.name === "FieldSymbol") {
                      result.assign(INPUT.source[name].getPointer());
                    } else {
                        result.assign(INPUT.source[name]);
                      }
                  rv_result.set(abap.operators.concat(rv_result,(await lo_data_to_xml.get().run({iv_name: abap.builtin.to_upper({val: lv_name}), iv_ref: result}))));
                    }
                } else if (INPUT.source.constructor.name === "Table") {
                    for (const row of INPUT.source.array()) {
                        lv_name.set(row.get().name.get());
                        result.assign(row.get().value.dereference());
                    rv_result.set(abap.operators.concat(rv_result,(await lo_data_to_xml.get().run({iv_name: abap.builtin.to_upper({val: lv_name}), iv_ref: result}))));
                      }
                  } else {
                    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(13).set('invalid input')));
                  }
                  rv_result.set(abap.operators.concat(rv_result,new abap.types.String().set(`</asx:values>${abap.templateFormatting((await lo_data_to_xml.get().serialize_heap()))}</asx:abap>`)));
                  return rv_result;
                }
              }
              abap.Classes['CLAS-KERNEL_CALL_TRANSFORMATION-LCL_OBJECT_TO_STRING'] = lcl_object_to_string;
              class lcl_object_to_ixml {
                static INTERNAL_TYPE = 'CLAS';
                static INTERNAL_NAME = 'CLAS-KERNEL_CALL_TRANSFORMATION-LCL_OBJECT_TO_IXML';
                static IMPLEMENTED_INTERFACES = [];
                static ATTRIBUTES = {};
                static METHODS = {"TRAVERSE": {"visibility": "I", "parameters": {"II_PARENT": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_IXML_ELEMENT", RTTIName: "\\INTERFACE=IF_IXML_ELEMENT"});}, "is_optional": " "}, "II_DOC": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_IXML_DOCUMENT", RTTIName: "\\INTERFACE=IF_IXML_DOCUMENT"});}, "is_optional": " "}, "IV_REF": {"type": () => {return new abap.types.DataReference(new abap.types.Character(4));}, "is_optional": " "}}},
                "RUN": {"visibility": "U", "parameters": {"II_DOC": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_IXML_DOCUMENT", RTTIName: "\\INTERFACE=IF_IXML_DOCUMENT"});}, "is_optional": " "}, "SOURCE": {"type": () => {return new abap.types.Character(4);}, "is_optional": " "}}}};
                constructor() {
                  this.me = new abap.types.ABAPObject();
                  this.me.set(this);
                }
                async constructor_(INPUT) {
                  if (super.constructor_) { await super.constructor_(INPUT); }
                  return this;
                }
                async run(INPUT) {
                  return lcl_object_to_ixml.run(INPUT);
                }
                static async run(INPUT) {
                  let ii_doc = INPUT?.ii_doc;
                  if (ii_doc?.getQualifiedName === undefined || ii_doc.getQualifiedName() !== "IF_IXML_DOCUMENT") { ii_doc = undefined; }
                  if (ii_doc === undefined) { ii_doc = new abap.types.ABAPObject({qualifiedName: "IF_IXML_DOCUMENT", RTTIName: "\\INTERFACE=IF_IXML_DOCUMENT"}).set(INPUT.ii_doc); }
                  let source = INPUT?.source;
                  let lv_name = new abap.types.String({qualifiedName: "STRING"});
                  let result = new abap.types.DataReference(new abap.types.Character(4));
                  let li_element = new abap.types.ABAPObject({qualifiedName: "IF_IXML_ELEMENT", RTTIName: "\\INTERFACE=IF_IXML_ELEMENT"});
                  let li_top = new abap.types.ABAPObject({qualifiedName: "IF_IXML_ELEMENT", RTTIName: "\\INTERFACE=IF_IXML_ELEMENT"});
                  let li_sub = new abap.types.ABAPObject({qualifiedName: "IF_IXML_ELEMENT", RTTIName: "\\INTERFACE=IF_IXML_ELEMENT"});
                  let lt_stab = abap.types.TableFactory.construct(new abap.types.Structure({"name": new abap.types.String({qualifiedName: "NAME"}), "value": new abap.types.DataReference(new abap.types.Character(4))}, "abap_trans_srcbind", undefined, {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "abap_trans_srcbind_tab");
                  let ls_stab = new abap.types.Structure({"name": new abap.types.String({qualifiedName: "NAME"}), "value": new abap.types.DataReference(new abap.types.Character(4))}, "abap_trans_srcbind", undefined, {}, {});
                  if (INPUT.source.constructor.name === "Table") {
                      lt_stab = INPUT.source;
                  }
                  abap.statements.assert(abap.compare.gt(abap.builtin.lines({val: lt_stab}), abap.IntegerFactory.get(0)));
                  li_top.set((await ii_doc.get().if_ixml_document$create_element_ns({prefix: new abap.types.Character(3).set('asx'), name: new abap.types.Character(4).set('abap')})));
                  await li_top.get().if_ixml_element$set_attribute({name: new abap.types.Character(9).set('xmlns:asx'), value: new abap.types.Character(26).set('http://www.sap.com/abapxml')});
                  await li_top.get().if_ixml_element$set_attribute({name: new abap.types.Character(7).set('version'), value: new abap.types.Character(3).set('1.0')});
                  await ii_doc.get().if_ixml_document$append_child({new_child: li_top});
                  li_sub.set((await ii_doc.get().if_ixml_document$create_element_ns({prefix: new abap.types.Character(3).set('asx'), name: new abap.types.Character(6).set('values')})));
                  await li_top.get().if_ixml_element$append_child({new_child: li_sub});
                  for await (const unique81 of abap.statements.loop(lt_stab)) {
                    ls_stab.set(unique81);
                    li_element.set((await ii_doc.get().if_ixml_document$create_element({name: ls_stab.get().name})));
                    await this.traverse({ii_parent: li_element, ii_doc: ii_doc, iv_ref: ls_stab.get().value});
                    await li_sub.get().if_ixml_element$append_child({new_child: li_element});
                  }
                }
                async traverse(INPUT) {
                  return lcl_object_to_ixml.traverse(INPUT);
                }
                static async traverse(INPUT) {
                  let ii_parent = INPUT?.ii_parent;
                  if (ii_parent?.getQualifiedName === undefined || ii_parent.getQualifiedName() !== "IF_IXML_ELEMENT") { ii_parent = undefined; }
                  if (ii_parent === undefined) { ii_parent = new abap.types.ABAPObject({qualifiedName: "IF_IXML_ELEMENT", RTTIName: "\\INTERFACE=IF_IXML_ELEMENT"}).set(INPUT.ii_parent); }
                  let ii_doc = INPUT?.ii_doc;
                  if (ii_doc?.getQualifiedName === undefined || ii_doc.getQualifiedName() !== "IF_IXML_DOCUMENT") { ii_doc = undefined; }
                  if (ii_doc === undefined) { ii_doc = new abap.types.ABAPObject({qualifiedName: "IF_IXML_DOCUMENT", RTTIName: "\\INTERFACE=IF_IXML_DOCUMENT"}).set(INPUT.ii_doc); }
                  let iv_ref = INPUT?.iv_ref;
                  if (iv_ref === undefined) { iv_ref = new abap.types.DataReference(new abap.types.Character(4)).set(INPUT.iv_ref); }
                  let lo_type = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_TYPEDESCR", RTTIName: "\\CLASS=CL_ABAP_TYPEDESCR"});
                  let lo_struc = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_STRUCTDESCR", RTTIName: "\\CLASS=CL_ABAP_STRUCTDESCR"});
                  let lt_comps = abap.types.TableFactory.construct(new abap.types.Structure({"name": new abap.types.String({qualifiedName: "NAME"}), "type": new abap.types.ABAPObject({qualifiedName: "CL_ABAP_DATADESCR", RTTIName: "\\CLASS=CL_ABAP_DATADESCR"}), "as_include": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "suffix": new abap.types.String({qualifiedName: "SUFFIX"})}, "abap_componentdescr", undefined, {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "abap_component_tab");
                  let ls_compo = new abap.types.Structure({"name": new abap.types.String({qualifiedName: "NAME"}), "type": new abap.types.ABAPObject({qualifiedName: "CL_ABAP_DATADESCR", RTTIName: "\\CLASS=CL_ABAP_DATADESCR"}), "as_include": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "suffix": new abap.types.String({qualifiedName: "SUFFIX"})}, "abap_componentdescr", undefined, {}, {});
                  let lv_ref = new abap.types.DataReference(new abap.types.Character(4));
                  let li_element = new abap.types.ABAPObject({qualifiedName: "IF_IXML_ELEMENT", RTTIName: "\\INTERFACE=IF_IXML_ELEMENT"});
                  let fs_any_ = new abap.types.FieldSymbol(new abap.types.Character(4));
                  let fs_table_ = new abap.types.FieldSymbol(abap.types.TableFactory.construct(new abap.types.Character(4), {"withHeader":false,"keyType":"DEFAULT"}));
                  let fs_field_ = new abap.types.FieldSymbol(new abap.types.Character(4));
                  lo_type.set((await abap.Classes['CL_ABAP_TYPEDESCR'].describe_by_data({p_data: iv_ref.dereference()})));
                  let unique82 = lo_type.get().kind;
                  if (abap.compare.eq(unique82, abap.Classes['CL_ABAP_TYPEDESCR'].kind_struct)) {
                    await abap.statements.cast(lo_struc, lo_type);
                    lt_comps.set((await lo_struc.get().get_components()));
                    abap.statements.assign({target: fs_any_, source: iv_ref.dereference()});
                    for await (const unique83 of abap.statements.loop(lt_comps)) {
                      ls_compo.set(unique83);
                      li_element.set((await ii_doc.get().if_ixml_document$create_element({name: ls_compo.get().name})));
                      abap.statements.assign({component: ls_compo.get().name, target: fs_field_, source: fs_any_});
                      lv_ref.assign(fs_field_.getPointer());
                      await this.traverse({ii_parent: li_element, ii_doc: ii_doc, iv_ref: lv_ref});
                      await ii_parent.get().if_ixml_element$append_child({new_child: li_element});
                    }
                  } else if (abap.compare.eq(unique82, abap.Classes['CL_ABAP_TYPEDESCR'].kind_elem)) {
                    await ii_parent.get().if_ixml_element$set_value({value: new abap.types.String().set(`${abap.templateFormatting(iv_ref.dereference())}`)});
                  } else if (abap.compare.eq(unique82, abap.Classes['CL_ABAP_TYPEDESCR'].kind_table)) {
                    abap.statements.assign({target: fs_table_, source: iv_ref.dereference()});
                    for await (const unique84 of abap.statements.loop(fs_table_)) {
                      fs_any_.assign(unique84);
                      li_element.set((await ii_doc.get().if_ixml_document$create_element({name: new abap.types.Character(4).set('item')})));
                      lv_ref.assign(fs_any_.getPointer());
                      await this.traverse({ii_parent: li_element, ii_doc: ii_doc, iv_ref: lv_ref});
                      await ii_parent.get().if_ixml_element$append_child({new_child: li_element});
                    }
                  } else {
                    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), abap.IntegerFactory.get(2)));
                  }
                }
              }
              abap.Classes['CLAS-KERNEL_CALL_TRANSFORMATION-LCL_OBJECT_TO_IXML'] = lcl_object_to_ixml;
              class lcl_string_to_string {
                static INTERNAL_TYPE = 'CLAS';
                static INTERNAL_NAME = 'CLAS-KERNEL_CALL_TRANSFORMATION-LCL_STRING_TO_STRING';
                static IMPLEMENTED_INTERFACES = [];
                static ATTRIBUTES = {};
                static METHODS = {"RUN": {"visibility": "U", "parameters": {"RESULT": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "SOURCE": {"type": () => {return new abap.types.Character(4);}, "is_optional": " "}, "OPTIONS": {"type": () => {return new abap.types.Structure({"initial_components": new abap.types.String({qualifiedName: "KERNEL_CALL_TRANSFORMATION=>TY_OPTIONS-INITIAL_COMPONENTS"}), "xml_header": new abap.types.String({qualifiedName: "KERNEL_CALL_TRANSFORMATION=>TY_OPTIONS-XML_HEADER"})}, "kernel_call_transformation=>ty_options", undefined, {}, {});}, "is_optional": " "}}}};
                constructor() {
                  this.me = new abap.types.ABAPObject();
                  this.me.set(this);
                }
                async constructor_(INPUT) {
                  if (super.constructor_) { await super.constructor_(INPUT); }
                  return this;
                }
                async run(INPUT) {
                  return lcl_string_to_string.run(INPUT);
                }
                static async run(INPUT) {
                  let result = new abap.types.String({qualifiedName: "STRING"});
                  let source = INPUT?.source;
                  let options = INPUT?.options;
                  if (options?.getQualifiedName === undefined || options.getQualifiedName() !== "KERNEL_CALL_TRANSFORMATION=>TY_OPTIONS") { options = undefined; }
                  if (options === undefined) { options = new abap.types.Structure({"initial_components": new abap.types.String({qualifiedName: "KERNEL_CALL_TRANSFORMATION=>TY_OPTIONS-INITIAL_COMPONENTS"}), "xml_header": new abap.types.String({qualifiedName: "KERNEL_CALL_TRANSFORMATION=>TY_OPTIONS-XML_HEADER"})}, "kernel_call_transformation=>ty_options", undefined, {}, {}).set(INPUT.options); }
                  let lv_str_bom = new abap.types.String({qualifiedName: "STRING"});
                  let lv_hex_bom = new abap.types.XString({qualifiedName: "XSTRING"});
                  result.set(INPUT.source.get());
                  lv_hex_bom.set(abap.Classes['CL_ABAP_CHAR_UTILITIES'].byte_order_mark_little);
                  lv_str_bom.set((await abap.Classes['CL_ABAP_CODEPAGE'].convert_from({source: lv_hex_bom, codepage: new abap.types.Character(6).set('UTF-16')})));
                  if (abap.compare.eq(options.get().xml_header, new abap.types.Character(2).set('no'))) {
                    abap.statements.replace({target: result, all: false, with: new abap.types.Character(1).set(''), regex: new abap.types.Character(8).set('<\\?.*\\?>')});
                    abap.statements.concatenate({source: [lv_str_bom, result], target: result});
                  }
                  return result;
                }
              }
              abap.Classes['CLAS-KERNEL_CALL_TRANSFORMATION-LCL_STRING_TO_STRING'] = lcl_string_to_string;
export {lcl_heap, lcl_data_to_xml, lcl_object_to_sxml, lcl_object_to_string, lcl_object_to_ixml, lcl_string_to_string};
//# sourceMappingURL=kernel_call_transformation.clas.locals.mjs.map