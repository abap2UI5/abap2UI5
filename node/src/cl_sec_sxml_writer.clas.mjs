const {cx_root} = await import("./cx_root.clas.mjs");
// cl_sec_sxml_writer.clas.abap
class cl_sec_sxml_writer {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CL_SEC_SXML_WRITER';
  static IMPLEMENTED_INTERFACES = [];
  static ATTRIBUTES = {"CO_AES128_ALGORITHM": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "CO_AES192_ALGORITHM": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "CO_AES256_ALGORITHM": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "visibility": "U", "is_constant": "X", "is_class": "X"}};
  static METHODS = {"CRYPT_AES_CTR": {"visibility": "U", "parameters": {"INPUT": {"type": () => {return new abap.types.XString({qualifiedName: "XSTRING"});}, "is_optional": " "}, "KEY": {"type": () => {return new abap.types.XString({qualifiedName: "XSTRING"});}, "is_optional": " "}, "IV": {"type": () => {return new abap.types.XString({qualifiedName: "XSTRING"});}, "is_optional": " "}, "ALGORITHM": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "RESULT": {"type": () => {return new abap.types.XString({qualifiedName: "XSTRING"});}, "is_optional": " "}}}};
  constructor() {
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
    this.co_aes128_algorithm = cl_sec_sxml_writer.co_aes128_algorithm;
    this.co_aes192_algorithm = cl_sec_sxml_writer.co_aes192_algorithm;
    this.co_aes256_algorithm = cl_sec_sxml_writer.co_aes256_algorithm;
  }
  async constructor_(INPUT) {
    if (super.constructor_) { await super.constructor_(INPUT); }
    return this;
  }
  async crypt_aes_ctr(INPUT) {
    return cl_sec_sxml_writer.crypt_aes_ctr(INPUT);
  }
  static async crypt_aes_ctr(INPUT) {
    let input = INPUT?.input;
    if (input?.getQualifiedName === undefined || input.getQualifiedName() !== "XSTRING") { input = undefined; }
    if (input === undefined) { input = new abap.types.XString({qualifiedName: "XSTRING"}).set(INPUT.input); }
    let key = INPUT?.key;
    if (key?.getQualifiedName === undefined || key.getQualifiedName() !== "XSTRING") { key = undefined; }
    if (key === undefined) { key = new abap.types.XString({qualifiedName: "XSTRING"}).set(INPUT.key); }
    let iv = INPUT?.iv;
    if (iv?.getQualifiedName === undefined || iv.getQualifiedName() !== "XSTRING") { iv = undefined; }
    if (iv === undefined) { iv = new abap.types.XString({qualifiedName: "XSTRING"}).set(INPUT.iv); }
    let algorithm = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.algorithm) {algorithm.set(INPUT.algorithm);}
    if (INPUT === undefined || INPUT.algorithm === undefined) {algorithm = this.co_aes128_algorithm;}
    let result = INPUT?.result || new abap.types.XString({qualifiedName: "XSTRING"});
    let lv_algo = new abap.types.String({qualifiedName: "STRING"});
    let unique137 = algorithm;
    if (abap.compare.eq(unique137, cl_sec_sxml_writer.co_aes128_algorithm)) {
      lv_algo.set(new abap.types.Character(11).set('aes-128-ctr'));
    } else if (abap.compare.eq(unique137, cl_sec_sxml_writer.co_aes256_algorithm)) {
      lv_algo.set(new abap.types.Character(11).set('aes-256-ctr'));
    } else {
      abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    }
    const crypto = await import("crypto");
    const js_key = Buffer.from(key.get(), "hex");
    const js_iv = Buffer.from(iv.get(), "hex");
    const js_input = Buffer.from(input.get(), "hex");
    const cipher = crypto.createDecipheriv(lv_algo.get(), js_key, js_iv);
    const encrypted = cipher.update(js_input);
    result.set(encrypted.toString("hex").toUpperCase());
  }
}
abap.Classes['CL_SEC_SXML_WRITER'] = cl_sec_sxml_writer;
cl_sec_sxml_writer.co_aes128_algorithm = new abap.types.String({qualifiedName: "STRING"});
cl_sec_sxml_writer.co_aes128_algorithm.set('http://www.w3.org/2001/04/xmlenc#aes128-cbc');
cl_sec_sxml_writer.co_aes192_algorithm = new abap.types.String({qualifiedName: "STRING"});
cl_sec_sxml_writer.co_aes192_algorithm.set('http://www.w3.org/2001/04/xmlenc#aes192-cbc');
cl_sec_sxml_writer.co_aes256_algorithm = new abap.types.String({qualifiedName: "STRING"});
cl_sec_sxml_writer.co_aes256_algorithm.set('http://www.w3.org/2001/04/xmlenc#aes256-cbc');
export {cl_sec_sxml_writer};
//# sourceMappingURL=cl_sec_sxml_writer.clas.mjs.map