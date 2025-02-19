await import("./cl_ixml.clas.locals.mjs");
const {cx_root} = await import("./cx_root.clas.mjs");
// cl_ixml.clas.abap
class cl_ixml {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CL_IXML';
  static IMPLEMENTED_INTERFACES = ["IF_IXML"];
  static ATTRIBUTES = {};
  static METHODS = {"CREATE": {"visibility": "U", "parameters": {"XML": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_IXML", RTTIName: "\\INTERFACE=IF_IXML"});}, "is_optional": " "}}}};
  constructor() {
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
  }
  async constructor_(INPUT) {
    if (super.constructor_) { await super.constructor_(INPUT); }
    return this;
  }
  async create() {
    return cl_ixml.create();
  }
  static async create() {
    let xml = new abap.types.ABAPObject({qualifiedName: "IF_IXML", RTTIName: "\\INTERFACE=IF_IXML"});
    xml.set(await (new abap.Classes['CL_IXML']()).constructor_());
    return xml;
  }
  async if_ixml$create_encoding(INPUT) {
    let rval = new abap.types.ABAPObject({qualifiedName: "IF_IXML_ENCODING", RTTIName: "\\INTERFACE=IF_IXML_ENCODING"});
    let byte_order = INPUT?.byte_order;
    if (byte_order?.getQualifiedName === undefined || byte_order.getQualifiedName() !== "I") { byte_order = undefined; }
    if (byte_order === undefined) { byte_order = new abap.types.Integer({qualifiedName: "I"}).set(INPUT.byte_order); }
    let character_set = INPUT?.character_set;
    if (character_set?.getQualifiedName === undefined || character_set.getQualifiedName() !== "STRING") { character_set = undefined; }
    if (character_set === undefined) { character_set = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.character_set); }
    rval.set(await (new abap.Classes['CLAS-CL_IXML-LCL_ENCODING']()).constructor_());
    return rval;
  }
  async if_ixml$create_document() {
    let doc = new abap.types.ABAPObject({qualifiedName: "IF_IXML_DOCUMENT", RTTIName: "\\INTERFACE=IF_IXML_DOCUMENT"});
    doc.set(await (new abap.Classes['CLAS-CL_IXML-LCL_DOCUMENT']()).constructor_());
    return doc;
  }
  async if_ixml$create_stream_factory() {
    let stream = new abap.types.ABAPObject({qualifiedName: "IF_IXML_STREAM_FACTORY", RTTIName: "\\INTERFACE=IF_IXML_STREAM_FACTORY"});
    stream.set(await (new abap.Classes['CLAS-CL_IXML-LCL_STREAM_FACTORY']()).constructor_());
    return stream;
  }
  async if_ixml$create_renderer(INPUT) {
    let renderer = new abap.types.ABAPObject({qualifiedName: "IF_IXML_RENDERER", RTTIName: "\\INTERFACE=IF_IXML_RENDERER"});
    let ostream = INPUT?.ostream;
    if (ostream?.getQualifiedName === undefined || ostream.getQualifiedName() !== "IF_IXML_OSTREAM") { ostream = undefined; }
    if (ostream === undefined) { ostream = new abap.types.ABAPObject({qualifiedName: "IF_IXML_OSTREAM", RTTIName: "\\INTERFACE=IF_IXML_OSTREAM"}).set(INPUT.ostream); }
    let document = INPUT?.document;
    if (document?.getQualifiedName === undefined || document.getQualifiedName() !== "IF_IXML_DOCUMENT") { document = undefined; }
    if (document === undefined) { document = new abap.types.ABAPObject({qualifiedName: "IF_IXML_DOCUMENT", RTTIName: "\\INTERFACE=IF_IXML_DOCUMENT"}).set(INPUT.document); }
    renderer.set(await (new abap.Classes['CLAS-CL_IXML-LCL_RENDERER']()).constructor_({ostream: ostream, document: document}));
    return renderer;
  }
  async if_ixml$create_parser(INPUT) {
    let parser = new abap.types.ABAPObject({qualifiedName: "IF_IXML_PARSER", RTTIName: "\\INTERFACE=IF_IXML_PARSER"});
    let stream_factory = INPUT?.stream_factory;
    if (stream_factory?.getQualifiedName === undefined || stream_factory.getQualifiedName() !== "IF_IXML_STREAM_FACTORY") { stream_factory = undefined; }
    if (stream_factory === undefined) { stream_factory = new abap.types.ABAPObject({qualifiedName: "IF_IXML_STREAM_FACTORY", RTTIName: "\\INTERFACE=IF_IXML_STREAM_FACTORY"}).set(INPUT.stream_factory); }
    let istream = INPUT?.istream;
    if (istream?.getQualifiedName === undefined || istream.getQualifiedName() !== "IF_IXML_ISTREAM") { istream = undefined; }
    if (istream === undefined) { istream = new abap.types.ABAPObject({qualifiedName: "IF_IXML_ISTREAM", RTTIName: "\\INTERFACE=IF_IXML_ISTREAM"}).set(INPUT.istream); }
    let document = INPUT?.document;
    if (document?.getQualifiedName === undefined || document.getQualifiedName() !== "IF_IXML_DOCUMENT") { document = undefined; }
    if (document === undefined) { document = new abap.types.ABAPObject({qualifiedName: "IF_IXML_DOCUMENT", RTTIName: "\\INTERFACE=IF_IXML_DOCUMENT"}).set(INPUT.document); }
    parser.set(await (new abap.Classes['CLAS-CL_IXML-LCL_PARSER']()).constructor_({istream: istream, document: document}));
    return parser;
  }
}
abap.Classes['CL_IXML'] = cl_ixml;
export {cl_ixml};
//# sourceMappingURL=cl_ixml.clas.mjs.map