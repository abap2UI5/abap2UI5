const {cx_root} = await import("./cx_root.clas.mjs");
// cl_abap_hmac.clas.abap
class cl_abap_hmac {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CL_ABAP_HMAC';
  static IMPLEMENTED_INTERFACES = [];
  static ATTRIBUTES = {};
  static METHODS = {"CALCULATE_HMAC_FOR_RAW": {"visibility": "U", "parameters": {"IF_ALGORITHM": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "IF_KEY": {"type": () => {return new abap.types.XString({qualifiedName: "XSTRING"});}, "is_optional": " "}, "IF_DATA": {"type": () => {return new abap.types.XString({qualifiedName: "XSTRING"});}, "is_optional": " "}, "IF_LENGTH": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}, "EF_HMACSTRING": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "EF_HMACXSTRING": {"type": () => {return new abap.types.XString({qualifiedName: "XSTRING"});}, "is_optional": " "}, "EF_HMACB64STRING": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}},
  "CALCULATE_HMAC_FOR_CHAR": {"visibility": "U", "parameters": {"IF_ALGORITHM": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "IF_KEY": {"type": () => {return new abap.types.XString({qualifiedName: "XSTRING"});}, "is_optional": " "}, "IF_DATA": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "EF_HMACSTRING": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "EF_HMACXSTRING": {"type": () => {return new abap.types.XString({qualifiedName: "XSTRING"});}, "is_optional": " "}, "EF_HMACB64STRING": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}},
  "STRING_TO_XSTRING": {"visibility": "U", "parameters": {"ER_OUTPUT": {"type": () => {return new abap.types.XString({qualifiedName: "XSTRING"});}, "is_optional": " "}, "IF_INPUT": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}}};
  constructor() {
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
  }
  async constructor_(INPUT) {
    if (super.constructor_) { await super.constructor_(INPUT); }
    return this;
  }
  async calculate_hmac_for_raw(INPUT) {
    return cl_abap_hmac.calculate_hmac_for_raw(INPUT);
  }
  static async calculate_hmac_for_raw(INPUT) {
    let if_algorithm = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.if_algorithm) {if_algorithm.set(INPUT.if_algorithm);}
    if (INPUT === undefined || INPUT.if_algorithm === undefined) {if_algorithm = new abap.types.Character(4).set('SHA1');}
    let if_key = INPUT?.if_key;
    if (if_key?.getQualifiedName === undefined || if_key.getQualifiedName() !== "XSTRING") { if_key = undefined; }
    if (if_key === undefined) { if_key = new abap.types.XString({qualifiedName: "XSTRING"}).set(INPUT.if_key); }
    let if_data = INPUT?.if_data;
    if (if_data?.getQualifiedName === undefined || if_data.getQualifiedName() !== "XSTRING") { if_data = undefined; }
    if (if_data === undefined) { if_data = new abap.types.XString({qualifiedName: "XSTRING"}).set(INPUT.if_data); }
    let if_length = new abap.types.Integer({qualifiedName: "I"});
    if (INPUT && INPUT.if_length) {if_length.set(INPUT.if_length);}
    let ef_hmacstring = INPUT?.ef_hmacstring || new abap.types.String({qualifiedName: "STRING"});
    let ef_hmacxstring = INPUT?.ef_hmacxstring || new abap.types.XString({qualifiedName: "XSTRING"});
    let ef_hmacb64string = INPUT?.ef_hmacb64string || new abap.types.String({qualifiedName: "STRING"});
    let lv_algorithm = new abap.types.String({qualifiedName: "STRING"});
    abap.statements.clear(ef_hmacstring);
    abap.statements.clear(ef_hmacxstring);
    abap.statements.assert(abap.compare.eq(if_length, abap.IntegerFactory.get(0)));
    lv_algorithm.set(abap.builtin.to_lower({val: if_algorithm}));
    abap.statements.assert(abap.compare.eq(lv_algorithm, new abap.types.Character(4).set('sha1')) || abap.compare.eq(lv_algorithm, new abap.types.Character(3).set('md5')) || abap.compare.eq(lv_algorithm, new abap.types.Character(6).set('sha256')));
    const crypto = await import("crypto");
    if (abap.compare.initial(if_key)) {
      var shasum = crypto.createHash(lv_algorithm.get());
      shasum.update(if_data.get(), "hex");
      ef_hmacstring.set(shasum.digest("hex").toUpperCase());
    } else {
      let hmac = crypto.createHmac(lv_algorithm.get(), Buffer.from(if_key.get(), "hex")).update(if_data.get(), "hex").digest("hex").toUpperCase();
      ef_hmacstring.set(hmac);
    }
    ef_hmacb64string.set(Buffer.from(ef_hmacstring.get(), "hex").toString("base64"));
    ef_hmacxstring.set(ef_hmacstring);
  }
  async calculate_hmac_for_char(INPUT) {
    return cl_abap_hmac.calculate_hmac_for_char(INPUT);
  }
  static async calculate_hmac_for_char(INPUT) {
    let if_algorithm = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.if_algorithm) {if_algorithm.set(INPUT.if_algorithm);}
    if (INPUT === undefined || INPUT.if_algorithm === undefined) {if_algorithm = new abap.types.Character(4).set('SHA1');}
    let if_key = INPUT?.if_key;
    if (if_key?.getQualifiedName === undefined || if_key.getQualifiedName() !== "XSTRING") { if_key = undefined; }
    if (if_key === undefined) { if_key = new abap.types.XString({qualifiedName: "XSTRING"}).set(INPUT.if_key); }
    let if_data = INPUT?.if_data;
    if (if_data?.getQualifiedName === undefined || if_data.getQualifiedName() !== "STRING") { if_data = undefined; }
    if (if_data === undefined) { if_data = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.if_data); }
    let ef_hmacstring = INPUT?.ef_hmacstring || new abap.types.String({qualifiedName: "STRING"});
    let ef_hmacxstring = INPUT?.ef_hmacxstring || new abap.types.XString({qualifiedName: "XSTRING"});
    let ef_hmacb64string = INPUT?.ef_hmacb64string || new abap.types.String({qualifiedName: "STRING"});
    let lv_xstr = new abap.types.XString({qualifiedName: "XSTRING"});
    lv_xstr.set((await this.string_to_xstring({if_input: if_data})));
    await this.calculate_hmac_for_raw({if_algorithm: if_algorithm, if_key: if_key, if_data: lv_xstr, ef_hmacstring: ef_hmacstring, ef_hmacxstring: ef_hmacxstring, ef_hmacb64string: ef_hmacb64string});
  }
  async string_to_xstring(INPUT) {
    return cl_abap_hmac.string_to_xstring(INPUT);
  }
  static async string_to_xstring(INPUT) {
    let er_output = new abap.types.XString({qualifiedName: "XSTRING"});
    let if_input = INPUT?.if_input;
    if (if_input?.getQualifiedName === undefined || if_input.getQualifiedName() !== "STRING") { if_input = undefined; }
    if (if_input === undefined) { if_input = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.if_input); }
    er_output.set((await abap.Classes['CL_ABAP_CODEPAGE'].convert_to({source: if_input})));
    return er_output;
  }
}
abap.Classes['CL_ABAP_HMAC'] = cl_abap_hmac;
export {cl_abap_hmac};
//# sourceMappingURL=cl_abap_hmac.clas.mjs.map