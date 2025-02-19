const {cx_root} = await import("./cx_root.clas.mjs");
// cl_web_http_utility.clas.abap
class cl_web_http_utility {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CL_WEB_HTTP_UTILITY';
  static IMPLEMENTED_INTERFACES = [];
  static ATTRIBUTES = {};
  static METHODS = {"UNESCAPE_URL": {"visibility": "U", "parameters": {"UNESCAPED": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "ESCAPED": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "OPTIONS": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}}},
  "DECODE_X_BASE64": {"visibility": "U", "parameters": {"DECODED": {"type": () => {return new abap.types.XString({qualifiedName: "XSTRING"});}, "is_optional": " "}, "ENCODED": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}},
  "ENCODE_X_BASE64": {"visibility": "U", "parameters": {"ENCODED": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "UNENCODED": {"type": () => {return new abap.types.XString({qualifiedName: "XSTRING"});}, "is_optional": " "}}},
  "DECODE_BASE64": {"visibility": "U", "parameters": {"DECODED": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "ENCODED": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}},
  "ENCODE_BASE64": {"visibility": "U", "parameters": {"ENCODED": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "UNENCODED": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}}};
  constructor() {
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
  }
  async constructor_(INPUT) {
    if (super.constructor_) { await super.constructor_(INPUT); }
    return this;
  }
  async decode_base64(INPUT) {
    return cl_web_http_utility.decode_base64(INPUT);
  }
  static async decode_base64(INPUT) {
    let decoded = new abap.types.String({qualifiedName: "STRING"});
    let encoded = INPUT?.encoded;
    if (encoded?.getQualifiedName === undefined || encoded.getQualifiedName() !== "STRING") { encoded = undefined; }
    if (encoded === undefined) { encoded = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.encoded); }
    decoded.set((await abap.Classes['CL_ABAP_CODEPAGE'].convert_from({source: (await abap.Classes['CL_HTTP_UTILITY'].decode_x_base64({encoded: encoded}))})));
    return decoded;
  }
  async encode_base64(INPUT) {
    return cl_web_http_utility.encode_base64(INPUT);
  }
  static async encode_base64(INPUT) {
    let encoded = new abap.types.String({qualifiedName: "STRING"});
    let unencoded = INPUT?.unencoded;
    if (unencoded?.getQualifiedName === undefined || unencoded.getQualifiedName() !== "STRING") { unencoded = undefined; }
    if (unencoded === undefined) { unencoded = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.unencoded); }
    encoded.set((await abap.Classes['CL_HTTP_UTILITY'].encode_x_base64({unencoded: (await abap.Classes['CL_ABAP_CODEPAGE'].convert_to({source: unencoded}))})));
    return encoded;
  }
  async unescape_url(INPUT) {
    return cl_web_http_utility.unescape_url(INPUT);
  }
  static async unescape_url(INPUT) {
    let unescaped = new abap.types.String({qualifiedName: "STRING"});
    let escaped = INPUT?.escaped;
    if (escaped?.getQualifiedName === undefined || escaped.getQualifiedName() !== "STRING") { escaped = undefined; }
    if (escaped === undefined) { escaped = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.escaped); }
    let options = new abap.types.Integer({qualifiedName: "I"});
    if (INPUT && INPUT.options) {options.set(INPUT.options);}
    unescaped.set((await abap.Classes['CL_HTTP_UTILITY'].if_http_utility$unescape_url({escaped: escaped, options: options})));
    return unescaped;
  }
  async decode_x_base64(INPUT) {
    return cl_web_http_utility.decode_x_base64(INPUT);
  }
  static async decode_x_base64(INPUT) {
    let decoded = new abap.types.XString({qualifiedName: "XSTRING"});
    let encoded = INPUT?.encoded;
    if (encoded?.getQualifiedName === undefined || encoded.getQualifiedName() !== "STRING") { encoded = undefined; }
    if (encoded === undefined) { encoded = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.encoded); }
    decoded.set((await abap.Classes['CL_HTTP_UTILITY'].decode_x_base64({encoded: encoded})));
    return decoded;
  }
  async encode_x_base64(INPUT) {
    return cl_web_http_utility.encode_x_base64(INPUT);
  }
  static async encode_x_base64(INPUT) {
    let encoded = new abap.types.String({qualifiedName: "STRING"});
    let unencoded = INPUT?.unencoded;
    if (unencoded?.getQualifiedName === undefined || unencoded.getQualifiedName() !== "XSTRING") { unencoded = undefined; }
    if (unencoded === undefined) { unencoded = new abap.types.XString({qualifiedName: "XSTRING"}).set(INPUT.unencoded); }
    encoded.set((await abap.Classes['CL_HTTP_UTILITY'].encode_x_base64({unencoded: unencoded})));
    return encoded;
  }
}
abap.Classes['CL_WEB_HTTP_UTILITY'] = cl_web_http_utility;
export {cl_web_http_utility};
//# sourceMappingURL=cl_web_http_utility.clas.mjs.map