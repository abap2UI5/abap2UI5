await import("./kernel_call_transformation.clas.locals.mjs");
const {cx_root} = await import("./cx_root.clas.mjs");
// kernel_call_transformation.clas.abap
class kernel_call_transformation {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'KERNEL_CALL_TRANSFORMATION';
  static IMPLEMENTED_INTERFACES = [];
  static ATTRIBUTES = {"MI_DOC": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_IXML_DOCUMENT", RTTIName: "\\INTERFACE=IF_IXML_DOCUMENT"});}, "visibility": "I", "is_constant": " ", "is_class": "X"},
  "MS_OPTIONS": {"type": () => {return new abap.types.Structure({"initial_components": new abap.types.String({qualifiedName: "KERNEL_CALL_TRANSFORMATION=>TY_OPTIONS-INITIAL_COMPONENTS"}), "xml_header": new abap.types.String({qualifiedName: "KERNEL_CALL_TRANSFORMATION=>TY_OPTIONS-XML_HEADER"})}, "kernel_call_transformation=>ty_options", undefined, {}, {});}, "visibility": "I", "is_constant": " ", "is_class": "X"},
  "GC_OPTIONS": {"type": () => {return new abap.types.Structure({"suppress": new abap.types.String({qualifiedName: "STRING"})}, undefined, undefined, {}, {});}, "visibility": "U", "is_constant": "X", "is_class": "X"}};
  static METHODS = {"PARSE_XML": {"visibility": "I", "parameters": {"IV_XML": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}},
  "PARSE_OPTIONS": {"visibility": "I", "parameters": {"OPTIONS": {"type": () => {return new abap.types.Character(4);}, "is_optional": " "}}},
  "CALL": {"visibility": "U", "parameters": {"NAME": {"type": () => {return new abap.types.Character(4);}, "is_optional": " "}, "OPTIONS": {"type": () => {return new abap.types.Character(4);}, "is_optional": " "}}}};
  constructor() {
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
    this.mi_doc = kernel_call_transformation.mi_doc;
    this.ms_options = kernel_call_transformation.ms_options;
    this.gc_options = kernel_call_transformation.gc_options;
  }
  async constructor_(INPUT) {
    if (super.constructor_) { await super.constructor_(INPUT); }
    return this;
  }
  async call(INPUT) {
    return kernel_call_transformation.call(INPUT);
  }
  static async call(INPUT) {
    let name = INPUT?.name;
    let options = INPUT?.options;
    let lv_name = new abap.types.String({qualifiedName: "STRING"});
    let lv_source = new abap.types.String({qualifiedName: "STRING"});
    let lv_result = new abap.types.String({qualifiedName: "STRING"});
    let result = new abap.types.DataReference(new abap.types.Character(4));
    let lt_rtab = abap.types.TableFactory.construct(new abap.types.Structure({"name": new abap.types.String({qualifiedName: "NAME"}), "value": new abap.types.DataReference(new abap.types.Character(4))}, "abap_trans_srcbind", undefined, {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "abap_trans_srcbind_tab");
    let ls_rtab = new abap.types.Structure({"name": new abap.types.String({qualifiedName: "NAME"}), "value": new abap.types.DataReference(new abap.types.Character(4))}, "abap_trans_srcbind", undefined, {}, {});
    let lv_type = new abap.types.String({qualifiedName: "STRING"});
    let lv_dummy = new abap.types.String({qualifiedName: "STRING"});
    let li_writer = new abap.types.ABAPObject({qualifiedName: "IF_SXML_WRITER", RTTIName: "\\INTERFACE=IF_SXML_WRITER"});
    let li_doc = new abap.types.ABAPObject({qualifiedName: "IF_IXML_DOCUMENT", RTTIName: "\\INTERFACE=IF_IXML_DOCUMENT"});
    abap.statements.clear(kernel_call_transformation.mi_doc);
    lv_name.set(INPUT.name.toUpperCase());
    abap.statements.assert(abap.compare.eq(lv_name, new abap.types.Character(2).set('ID')));
    await this.parse_options({options: options});
    if (INPUT.sourceXML?.constructor.name === "ABAPObject") this.mi_doc.set(INPUT.sourceXML);
    if (INPUT.sourceXML?.constructor.name === "String") lv_source.set(INPUT.sourceXML);
    if (abap.compare.initial(lv_source) === false) {
      if (abap.compare.eq(lv_source.getOffset({length: 1}), new abap.types.Character(1).set('<'))) {
        lv_type.set(new abap.types.Character(3).set('XML'));
        await this.parse_xml({iv_xml: lv_source});
      } else if (abap.compare.eq(lv_source.getOffset({length: 1}), new abap.types.Character(1).set('{')) || abap.compare.eq(lv_source.getOffset({length: 1}), new abap.types.Character(1).set('['))) {
        lv_type.set(new abap.types.Character(4).set('JSON'));
        kernel_call_transformation.mi_doc.set((await abap.Classes['KERNEL_JSON_TO_IXML'].build({iv_json: lv_source})));
      } else {
        const unique85 = await (new abap.Classes['CX_XSLT_FORMAT_ERROR']()).constructor_();
        unique85.EXTRA_CX = {"INTERNAL_FILENAME": "kernel_call_transformation.clas.abap","INTERNAL_LINE": 68};
        throw unique85;
      }
    }
    if (typeof INPUT.source === "object"
        && INPUT.resultXML?.constructor.name === "ABAPObject"
        && INPUT.resultXML?.qualifiedName === "IF_IXML_DOCUMENT") {
        li_doc.set(INPUT.resultXML);
        lv_dummy = INPUT.source;
    }
    if (abap.compare.initial(li_doc) === false) {
      await abap.Classes['CLAS-KERNEL_CALL_TRANSFORMATION-LCL_OBJECT_TO_IXML'].run({ii_doc: li_doc, source: lv_dummy});
      return;
    }
    if (typeof INPUT.source === "object"
        && INPUT.resultXML?.constructor.name === "ABAPObject") {
        li_writer.set(INPUT.resultXML);
        lv_dummy = INPUT.source;
    }
    if (abap.compare.initial(li_writer) === false) {
      await abap.Classes['CLAS-KERNEL_CALL_TRANSFORMATION-LCL_OBJECT_TO_SXML'].run({ii_writer: li_writer, source: lv_dummy});
      return;
    }
    if (INPUT.resultXML && INPUT.resultXML.constructor.name === "String") {
        if (INPUT.sourceXML && INPUT.sourceXML.constructor.name === "String") {
            lv_result.set("X");
            lv_dummy = INPUT.sourceXML;
          }
      }
      if (abap.compare.eq(lv_result, abap.builtin.abap_true)) {
        lv_result.set((await abap.Classes['CLAS-KERNEL_CALL_TRANSFORMATION-LCL_STRING_TO_STRING'].run({source: lv_dummy, options: kernel_call_transformation.ms_options})));
          INPUT.resultXML.set(lv_result);
        return;
      }
      if (INPUT.resultXML && INPUT.resultXML.constructor.name === "String") {
          lv_result.set("X");
          lv_dummy = INPUT.source;
      }
      if (abap.compare.eq(lv_result, abap.builtin.abap_true)) {
        lv_result.set((await abap.Classes['CLAS-KERNEL_CALL_TRANSFORMATION-LCL_OBJECT_TO_STRING'].run({is_options: kernel_call_transformation.ms_options, source: lv_dummy})));
          INPUT.resultXML.set(lv_result);
        return;
      }
      if (abap.compare.initial(lv_source) && abap.compare.initial(kernel_call_transformation.mi_doc)) {
        const unique86 = await (new abap.Classes['CX_XSLT_RUNTIME_ERROR']()).constructor_();
        unique86.EXTRA_CX = {"INTERNAL_FILENAME": "kernel_call_transformation.clas.abap","INTERNAL_LINE": 128};
        throw unique86;
      }
      if (INPUT.result.constructor.name === "Table") {
        lt_rtab = INPUT.result;
        for await (const unique87 of abap.statements.loop(lt_rtab)) {
          ls_rtab.set(unique87);
          await abap.Classes['KERNEL_IXML_XML_TO_DATA'].build({iv_name: ls_rtab.get().name, iv_ref: ls_rtab.get().value, ii_doc: kernel_call_transformation.mi_doc});
        }
      } else {
        for (const name in INPUT.result) {
            lv_name.set(name.toUpperCase());
            if (INPUT.result[name].constructor.name === "FieldSymbol") {
                result.assign(INPUT.result[name].getPointer());
              } else {
                  result.assign(INPUT.result[name]);
                }
              if (abap.compare.eq(lv_type, new abap.types.Character(4).set('JSON'))) {
                await abap.Classes['KERNEL_IXML_JSON_TO_DATA'].build({iv_name: lv_name, iv_ref: result, ii_doc: kernel_call_transformation.mi_doc});
              } else {
                await abap.Classes['KERNEL_IXML_XML_TO_DATA'].build({iv_name: lv_name, iv_ref: result, ii_doc: kernel_call_transformation.mi_doc});
              }
            }
          }
        }
        async parse_options(INPUT) {
          return kernel_call_transformation.parse_options(INPUT);
        }
        static async parse_options(INPUT) {
          let options = INPUT?.options;
          let lv_name = new abap.types.String({qualifiedName: "STRING"});
          let lv_value = new abap.types.String({qualifiedName: "STRING"});
          let fs_lv_field_ = new abap.types.FieldSymbol(new abap.types.String({qualifiedName: "STRING"}));
          for (const name in INPUT.options || {}) {
              lv_name.set(name);
              lv_value.set(INPUT.options[name]);
            abap.statements.assign({component: lv_name, target: fs_lv_field_, source: kernel_call_transformation.ms_options});
            if (abap.compare.eq(abap.builtin.sy.get().subrc, abap.IntegerFactory.get(0))) {
              fs_lv_field_.set(lv_value);
            }
          }
        }
        async parse_xml(INPUT) {
          return kernel_call_transformation.parse_xml(INPUT);
        }
        static async parse_xml(INPUT) {
          let iv_xml = INPUT?.iv_xml;
          if (iv_xml?.getQualifiedName === undefined || iv_xml.getQualifiedName() !== "STRING") { iv_xml = undefined; }
          if (iv_xml === undefined) { iv_xml = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.iv_xml); }
          let li_factory = new abap.types.ABAPObject({qualifiedName: "IF_IXML_STREAM_FACTORY", RTTIName: "\\INTERFACE=IF_IXML_STREAM_FACTORY"});
          let li_istream = new abap.types.ABAPObject({qualifiedName: "IF_IXML_ISTREAM", RTTIName: "\\INTERFACE=IF_IXML_ISTREAM"});
          let li_parser = new abap.types.ABAPObject({qualifiedName: "IF_IXML_PARSER", RTTIName: "\\INTERFACE=IF_IXML_PARSER"});
          let li_ixml = new abap.types.ABAPObject({qualifiedName: "IF_IXML", RTTIName: "\\INTERFACE=IF_IXML"});
          let lv_subrc = new abap.types.Integer({qualifiedName: "I"});
          li_ixml.set((await abap.Classes['CL_IXML'].create()));
          kernel_call_transformation.mi_doc.set((await li_ixml.get().if_ixml$create_document()));
          li_factory.set((await li_ixml.get().if_ixml$create_stream_factory()));
          li_istream.set((await li_factory.get().if_ixml_stream_factory$create_istream_string({string: iv_xml})));
          li_parser.set((await li_ixml.get().if_ixml$create_parser({stream_factory: li_factory, istream: li_istream, document: kernel_call_transformation.mi_doc})));
          await li_parser.get().if_ixml_parser$add_strip_space_element();
          lv_subrc.set((await li_parser.get().if_ixml_parser$parse()));
          await li_istream.get().if_ixml_istream$close();
          abap.statements.assert(abap.compare.eq(lv_subrc, abap.IntegerFactory.get(0)));
        }
      }
      abap.Classes['KERNEL_CALL_TRANSFORMATION'] = kernel_call_transformation;
      kernel_call_transformation.mi_doc = new abap.types.ABAPObject({qualifiedName: "IF_IXML_DOCUMENT", RTTIName: "\\INTERFACE=IF_IXML_DOCUMENT"});
      kernel_call_transformation.ms_options = new abap.types.Structure({"initial_components": new abap.types.String({qualifiedName: "KERNEL_CALL_TRANSFORMATION=>TY_OPTIONS-INITIAL_COMPONENTS"}), "xml_header": new abap.types.String({qualifiedName: "KERNEL_CALL_TRANSFORMATION=>TY_OPTIONS-XML_HEADER"})}, "kernel_call_transformation=>ty_options", undefined, {}, {});
      kernel_call_transformation.gc_options = new abap.types.Structure({"suppress": new abap.types.String({qualifiedName: "STRING"})}, undefined, undefined, {}, {});
      kernel_call_transformation.gc_options.get().suppress.set('suppress');
      kernel_call_transformation.ty_options = new abap.types.Structure({"initial_components": new abap.types.String({qualifiedName: "KERNEL_CALL_TRANSFORMATION=>TY_OPTIONS-INITIAL_COMPONENTS"}), "xml_header": new abap.types.String({qualifiedName: "KERNEL_CALL_TRANSFORMATION=>TY_OPTIONS-XML_HEADER"})}, "kernel_call_transformation=>ty_options", undefined, {}, {});
export {kernel_call_transformation};
//# sourceMappingURL=kernel_call_transformation.clas.mjs.map