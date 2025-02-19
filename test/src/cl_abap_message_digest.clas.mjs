const {cx_root} = await import("./cx_root.clas.mjs");
// cl_abap_message_digest.clas.abap
class cl_abap_message_digest {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CL_ABAP_MESSAGE_DIGEST';
  static IMPLEMENTED_INTERFACES = [];
  static ATTRIBUTES = {};
  static METHODS = {"CALCULATE_HASH_FOR_RAW": {"visibility": "U", "parameters": {"IF_ALGORITHM": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "IF_DATA": {"type": () => {return new abap.types.XString({qualifiedName: "XSTRING"});}, "is_optional": " "}, "EF_HASHXSTRING": {"type": () => {return new abap.types.XString({qualifiedName: "XSTRING"});}, "is_optional": " "}}},
  "CALCULATE_HASH_FOR_CHAR": {"visibility": "U", "parameters": {"IF_ALGORITHM": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "IF_DATA": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "EF_HASHXSTRING": {"type": () => {return new abap.types.XString({qualifiedName: "XSTRING"});}, "is_optional": " "}, "EF_HASHSTRING": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "EF_HASHB64STRING": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}}};
  constructor() {
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
  }
  async constructor_(INPUT) {
    if (super.constructor_) { await super.constructor_(INPUT); }
    return this;
  }
  async calculate_hash_for_raw(INPUT) {
    return cl_abap_message_digest.calculate_hash_for_raw(INPUT);
  }
  static async calculate_hash_for_raw(INPUT) {
    let if_algorithm = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.if_algorithm) {if_algorithm.set(INPUT.if_algorithm);}
    if (INPUT === undefined || INPUT.if_algorithm === undefined) {if_algorithm = new abap.types.Character(4).set('SHA1');}
    let if_data = INPUT?.if_data;
    if (if_data?.getQualifiedName === undefined || if_data.getQualifiedName() !== "XSTRING") { if_data = undefined; }
    if (if_data === undefined) { if_data = new abap.types.XString({qualifiedName: "XSTRING"}).set(INPUT.if_data); }
    let ef_hashxstring = INPUT?.ef_hashxstring || new abap.types.XString({qualifiedName: "XSTRING"});
    let lv_algorithm = new abap.types.String({qualifiedName: "STRING"});
    lv_algorithm.set(abap.builtin.to_lower({val: if_algorithm}));
    abap.statements.assert(abap.compare.eq(lv_algorithm, new abap.types.Character(4).set('sha1')) || abap.compare.eq(lv_algorithm, new abap.types.Character(3).set('md5')) || abap.compare.eq(lv_algorithm, new abap.types.Character(6).set('sha256')));
    const crypto = await import("crypto");
    var shasum = crypto.createHash(lv_algorithm.get());
    shasum.update(if_data.get(), "hex");
    ef_hashxstring.set(shasum.digest("hex").toUpperCase());
  }
  async calculate_hash_for_char(INPUT) {
    return cl_abap_message_digest.calculate_hash_for_char(INPUT);
  }
  static async calculate_hash_for_char(INPUT) {
    let if_algorithm = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.if_algorithm) {if_algorithm.set(INPUT.if_algorithm);}
    if (INPUT === undefined || INPUT.if_algorithm === undefined) {if_algorithm = new abap.types.Character(4).set('SHA1');}
    let if_data = INPUT?.if_data;
    if (if_data?.getQualifiedName === undefined || if_data.getQualifiedName() !== "STRING") { if_data = undefined; }
    if (if_data === undefined) { if_data = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.if_data); }
    let ef_hashxstring = INPUT?.ef_hashxstring || new abap.types.XString({qualifiedName: "XSTRING"});
    let ef_hashstring = INPUT?.ef_hashstring || new abap.types.String({qualifiedName: "STRING"});
    let ef_hashb64string = INPUT?.ef_hashb64string || new abap.types.String({qualifiedName: "STRING"});
    let lv_algorithm = new abap.types.String({qualifiedName: "STRING"});
    lv_algorithm.set(abap.builtin.to_lower({val: if_algorithm}));
    abap.statements.assert(abap.compare.eq(lv_algorithm, new abap.types.Character(4).set('sha1')) || abap.compare.eq(lv_algorithm, new abap.types.Character(3).set('md5')) || abap.compare.eq(lv_algorithm, new abap.types.Character(6).set('sha256')));
    const crypto = await import("crypto");
    var shasum = crypto.createHash(lv_algorithm.get());
    shasum.update(if_data.get());
    ef_hashxstring.set(shasum.digest("hex").toUpperCase());
    ef_hashb64string.set(Buffer.from(ef_hashxstring.get(), "hex").toString("base64"));
    ef_hashstring.set(ef_hashxstring);
  }
}
abap.Classes['CL_ABAP_MESSAGE_DIGEST'] = cl_abap_message_digest;
export {cl_abap_message_digest};
//# sourceMappingURL=cl_abap_message_digest.clas.mjs.map