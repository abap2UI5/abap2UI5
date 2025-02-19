const {cx_root} = await import("./cx_root.clas.mjs");
// cl_document_bcs.clas.abap
class cl_document_bcs {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CL_DOCUMENT_BCS';
  static IMPLEMENTED_INTERFACES = ["IF_DOCUMENT_BCS"];
  static ATTRIBUTES = {};
  static METHODS = {"CREATE_DOCUMENT": {"visibility": "U", "parameters": {"RESULT": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "CL_DOCUMENT_BCS", RTTIName: "\\CLASS=CL_DOCUMENT_BCS"});}, "is_optional": " "}, "I_TYPE": {"type": () => {return new abap.types.Character();}, "is_optional": " "}, "I_SUBJECT": {"type": () => {return new abap.types.Character();}, "is_optional": " "}, "I_TEXT": {"type": () => {return new abap.types.Character(4);}, "is_optional": " "}, "I_LENGTH": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}}},
  "ADD_ATTACHMENT": {"visibility": "U", "parameters": {"I_ATTACHMENT_TYPE": {"type": () => {return new abap.types.Character();}, "is_optional": " "}, "I_ATTACHMENT_SUBJECT": {"type": () => {return new abap.types.Character();}, "is_optional": " "}, "I_ATTACHMENT_SIZE": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}, "I_ATT_CONTENT_TEXT": {"type": () => {return new abap.types.Character(4);}, "is_optional": " "}, "I_ATT_CONTENT_HEX": {"type": () => {return new abap.types.Character(4);}, "is_optional": " "}, "I_ATTACHMENT_HEADER": {"type": () => {return abap.types.TableFactory.construct(new abap.types.Structure({"line": new abap.types.Character(255, {"qualifiedName":"SO_TEXT255","ddicName":"SO_TEXT255","description":"SO_TEXT255"})}, "SOLI", "SOLI", {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"isUnique":false,"type":"STANDARD","keyFields":[],"name":"primary_key"},"secondary":[]}, "SOLI_TAB");}, "is_optional": " "}}}};
  constructor() {
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
  }
  async constructor_(INPUT) {
    if (super.constructor_) { await super.constructor_(INPUT); }
    return this;
  }
  async create_document(INPUT) {
    return cl_document_bcs.create_document(INPUT);
  }
  static async create_document(INPUT) {
    let result = new abap.types.ABAPObject({qualifiedName: "CL_DOCUMENT_BCS", RTTIName: "\\CLASS=CL_DOCUMENT_BCS"});
    let i_type = INPUT?.i_type;
    let i_subject = INPUT?.i_subject;
    let i_text = INPUT?.i_text || new abap.types.Character(4);
    let i_length = new abap.types.Integer({qualifiedName: "I"});
    if (INPUT && INPUT.i_length) {i_length.set(INPUT.i_length);}
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return result;
  }
  async add_attachment(INPUT) {
    let i_attachment_type = INPUT?.i_attachment_type;
    let i_attachment_subject = INPUT?.i_attachment_subject;
    let i_attachment_size = new abap.types.Integer({qualifiedName: "I"});
    if (INPUT && INPUT.i_attachment_size) {i_attachment_size.set(INPUT.i_attachment_size);}
    let i_att_content_text = INPUT?.i_att_content_text || new abap.types.Character(4);
    let i_att_content_hex = INPUT?.i_att_content_hex || new abap.types.Character(4);
    let i_attachment_header = abap.types.TableFactory.construct(new abap.types.Structure({"line": new abap.types.Character(255, {"qualifiedName":"SO_TEXT255","ddicName":"SO_TEXT255","description":"SO_TEXT255"})}, "SOLI", "SOLI", {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"isUnique":false,"type":"STANDARD","keyFields":[],"name":"primary_key"},"secondary":[]}, "SOLI_TAB");
    if (INPUT && INPUT.i_attachment_header) {i_attachment_header.set(INPUT.i_attachment_header);}
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
  }
}
abap.Classes['CL_DOCUMENT_BCS'] = cl_document_bcs;
export {cl_document_bcs};
//# sourceMappingURL=cl_document_bcs.clas.mjs.map