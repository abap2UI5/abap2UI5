const {cx_root} = await import("./cx_root.clas.mjs");
// cl_http_utility.clas.abap
class cl_http_utility {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CL_HTTP_UTILITY';
  static IMPLEMENTED_INTERFACES = ["IF_HTTP_UTILITY"];
  static ATTRIBUTES = {};
  static METHODS = {"DECODE_X_BASE64": {"visibility": "U", "parameters": {"DECODED": {"type": () => {return new abap.types.XString({qualifiedName: "XSTRING"});}, "is_optional": " "}, "ENCODED": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}},
  "ENCODE_X_BASE64": {"visibility": "U", "parameters": {"ENCODED": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "UNENCODED": {"type": () => {return new abap.types.XString({qualifiedName: "XSTRING"});}, "is_optional": " "}}},
  "SET_QUERY": {"visibility": "U", "parameters": {"REQUEST": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_HTTP_REQUEST", RTTIName: "\\INTERFACE=IF_HTTP_REQUEST"});}, "is_optional": " "}, "QUERY": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}},
  "SET_REQUEST_URI": {"visibility": "U", "parameters": {"REQUEST": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_HTTP_REQUEST", RTTIName: "\\INTERFACE=IF_HTTP_REQUEST"});}, "is_optional": " "}, "URI": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}},
  "ESCAPE_XML_ATTR_VALUE": {"visibility": "U", "parameters": {"ESCAPED": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "UNESCAPED": {"type": () => {return new abap.types.Character();}, "is_optional": " "}}},
  "ESCAPE_HTML": {"visibility": "U", "parameters": {"ESCAPED": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "UNESCAPED": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "KEEP_NUM_CHAR_REF": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});}, "is_optional": " "}}},
  "ESCAPE_JAVASCRIPT": {"visibility": "U", "parameters": {"ESCAPED": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "UNESCAPED": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "INSIDE_HTML": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});}, "is_optional": " "}}}};
  constructor() {
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
    this.decode_base64 = this.if_http_utility$decode_base64;
    this.encode_base64 = this.if_http_utility$encode_base64;
    this.escape_url = this.if_http_utility$escape_url;
    this.fields_to_string = this.if_http_utility$fields_to_string;
    this.get_last_error = this.if_http_utility$get_last_error;
    this.string_to_fields = this.if_http_utility$string_to_fields;
    this.unescape_url = this.if_http_utility$unescape_url;
    this.normalize_url = this.if_http_utility$normalize_url;
  }
  async constructor_(INPUT) {
    if (super.constructor_) { await super.constructor_(INPUT); }
    return this;
  }
  async set_request_uri(INPUT) {
    return cl_http_utility.set_request_uri(INPUT);
  }
  static async set_request_uri(INPUT) {
    let request = INPUT?.request;
    if (request?.getQualifiedName === undefined || request.getQualifiedName() !== "IF_HTTP_REQUEST") { request = undefined; }
    if (request === undefined) { request = new abap.types.ABAPObject({qualifiedName: "IF_HTTP_REQUEST", RTTIName: "\\INTERFACE=IF_HTTP_REQUEST"}).set(INPUT.request); }
    let uri = INPUT?.uri;
    if (uri?.getQualifiedName === undefined || uri.getQualifiedName() !== "STRING") { uri = undefined; }
    if (uri === undefined) { uri = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.uri); }
    await request.get().if_http_entity$set_header_field({name: new abap.types.Character(12).set('~request_uri'), value: uri});
  }
  async escape_html(INPUT) {
    return cl_http_utility.escape_html(INPUT);
  }
  static async escape_html(INPUT) {
    let escaped = new abap.types.String({qualifiedName: "STRING"});
    let unescaped = INPUT?.unescaped;
    if (unescaped?.getQualifiedName === undefined || unescaped.getQualifiedName() !== "STRING") { unescaped = undefined; }
    if (unescaped === undefined) { unescaped = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.unescaped); }
    let keep_num_char_ref = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    if (INPUT && INPUT.keep_num_char_ref) {keep_num_char_ref.set(INPUT.keep_num_char_ref);}
    if (INPUT === undefined || INPUT.keep_num_char_ref === undefined) {keep_num_char_ref = abap.builtin.abap_undefined;}
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return escaped;
  }
  async escape_javascript(INPUT) {
    return cl_http_utility.escape_javascript(INPUT);
  }
  static async escape_javascript(INPUT) {
    let escaped = new abap.types.String({qualifiedName: "STRING"});
    let unescaped = INPUT?.unescaped;
    if (unescaped?.getQualifiedName === undefined || unescaped.getQualifiedName() !== "STRING") { unescaped = undefined; }
    if (unescaped === undefined) { unescaped = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.unescaped); }
    let inside_html = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    if (INPUT && INPUT.inside_html) {inside_html.set(INPUT.inside_html);}
    if (INPUT === undefined || INPUT.inside_html === undefined) {inside_html = abap.builtin.abap_false;}
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return escaped;
  }
  async escape_xml_attr_value(INPUT) {
    return cl_http_utility.escape_xml_attr_value(INPUT);
  }
  static async escape_xml_attr_value(INPUT) {
    let escaped = new abap.types.String({qualifiedName: "STRING"});
    let unescaped = INPUT?.unescaped;
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return escaped;
  }
  async if_http_utility$get_last_error() {
    return cl_http_utility.if_http_utility$get_last_error();
  }
  static async if_http_utility$get_last_error() {
    let rc = new abap.types.Integer({qualifiedName: "I"});
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return rc;
  }
  async if_http_utility$string_to_fields(INPUT) {
    return cl_http_utility.if_http_utility$string_to_fields(INPUT);
  }
  static async if_http_utility$string_to_fields(INPUT) {
    let fields = abap.types.TableFactory.construct(new abap.types.Structure({"name": new abap.types.String({qualifiedName: "STRING"}), "value": new abap.types.String({qualifiedName: "STRING"})}, "IHTTPNVP", "IHTTPNVP", {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"isUnique":false,"type":"STANDARD","keyFields":[],"name":"primary_key"},"secondary":[]}, "TIHTTPNVP");
    let string = INPUT?.string;
    if (string?.getQualifiedName === undefined || string.getQualifiedName() !== "STRING") { string = undefined; }
    if (string === undefined) { string = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.string); }
    let ignore_parenthesis = new abap.types.Integer({qualifiedName: "I"});
    if (INPUT && INPUT.ignore_parenthesis) {ignore_parenthesis.set(INPUT.ignore_parenthesis);}
    if (INPUT === undefined || INPUT.ignore_parenthesis === undefined) {ignore_parenthesis = abap.IntegerFactory.get(0);}
    let tab = abap.types.TableFactory.construct(new abap.types.String({qualifiedName: "STRING"}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "");
    let str = new abap.types.String({qualifiedName: "STRING"});
    let ls_field = new abap.types.Structure({"name": new abap.types.String({qualifiedName: "STRING"}), "value": new abap.types.String({qualifiedName: "STRING"})}, "IHTTPNVP", "IHTTPNVP", {}, {});
    abap.statements.assert(abap.compare.eq(ignore_parenthesis, abap.IntegerFactory.get(0)));
    abap.statements.split({source: string, at: new abap.types.Character(1).set('&'), table: tab});
    for await (const unique42 of abap.statements.loop(tab)) {
      str.set(unique42);
      abap.statements.split({source: str, at: new abap.types.Character(1).set('='), targets: [ls_field.get().name,ls_field.get().value]});
      abap.statements.append({source: ls_field, target: fields});
    }
    return fields;
  }
  async set_query(INPUT) {
    return cl_http_utility.set_query(INPUT);
  }
  static async set_query(INPUT) {
    let request = INPUT?.request;
    if (request?.getQualifiedName === undefined || request.getQualifiedName() !== "IF_HTTP_REQUEST") { request = undefined; }
    if (request === undefined) { request = new abap.types.ABAPObject({qualifiedName: "IF_HTTP_REQUEST", RTTIName: "\\INTERFACE=IF_HTTP_REQUEST"}).set(INPUT.request); }
    let query = INPUT?.query;
    if (query?.getQualifiedName === undefined || query.getQualifiedName() !== "STRING") { query = undefined; }
    if (query === undefined) { query = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.query); }
    await request.get().if_http_entity$set_form_fields({fields: (await this.if_http_utility$string_to_fields({string: query}))});
  }
  async if_http_utility$normalize_url(INPUT) {
    return cl_http_utility.if_http_utility$normalize_url(INPUT);
  }
  static async if_http_utility$normalize_url(INPUT) {
    let normalized = new abap.types.String({qualifiedName: "STRING"});
    let unnormalized = INPUT?.unnormalized;
    if (unnormalized?.getQualifiedName === undefined || unnormalized.getQualifiedName() !== "STRING") { unnormalized = undefined; }
    if (unnormalized === undefined) { unnormalized = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.unnormalized); }
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return normalized;
  }
  async if_http_utility$fields_to_string(INPUT) {
    return cl_http_utility.if_http_utility$fields_to_string(INPUT);
  }
  static async if_http_utility$fields_to_string(INPUT) {
    let string = new abap.types.String({qualifiedName: "STRING"});
    let fields = INPUT?.fields;
    if (fields?.getQualifiedName === undefined || fields.getQualifiedName() !== "TIHTTPNVP") { fields = undefined; }
    if (fields === undefined) { fields = abap.types.TableFactory.construct(new abap.types.Structure({"name": new abap.types.String({qualifiedName: "STRING"}), "value": new abap.types.String({qualifiedName: "STRING"})}, "IHTTPNVP", "IHTTPNVP", {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"isUnique":false,"type":"STANDARD","keyFields":[],"name":"primary_key"},"secondary":[]}, "TIHTTPNVP").set(INPUT.fields); }
    let tab = abap.types.TableFactory.construct(new abap.types.String({qualifiedName: "STRING"}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "");
    let str = new abap.types.String({qualifiedName: "STRING"});
    let ls_field = new abap.types.Structure({"name": new abap.types.String({qualifiedName: "STRING"}), "value": new abap.types.String({qualifiedName: "STRING"})}, "IHTTPNVP", "IHTTPNVP", {}, {});
    for await (const unique43 of abap.statements.loop(fields)) {
      ls_field.set(unique43);
      ls_field.get().value.set((await this.if_http_utility$escape_url({unescaped: ls_field.get().value})));
      str.set(abap.operators.concat(ls_field.get().name,abap.operators.concat(new abap.types.Character(1).set('='),ls_field.get().value)));
      abap.statements.append({source: str, target: tab});
    }
    string.set(abap.builtin.concat_lines_of({table: tab, sep: new abap.types.Character(1).set('&')}));
    return string;
  }
  async encode_x_base64(INPUT) {
    return cl_http_utility.encode_x_base64(INPUT);
  }
  static async encode_x_base64(INPUT) {
    let encoded = new abap.types.String({qualifiedName: "STRING"});
    let unencoded = INPUT?.unencoded;
    if (unencoded?.getQualifiedName === undefined || unencoded.getQualifiedName() !== "XSTRING") { unencoded = undefined; }
    if (unencoded === undefined) { unencoded = new abap.types.XString({qualifiedName: "XSTRING"}).set(INPUT.unencoded); }
    let buffer = Buffer.from(unencoded.get(), "hex");
    encoded.set(buffer.toString("base64"));
    return encoded;
  }
  async decode_x_base64(INPUT) {
    return cl_http_utility.decode_x_base64(INPUT);
  }
  static async decode_x_base64(INPUT) {
    let decoded = new abap.types.XString({qualifiedName: "XSTRING"});
    let encoded = INPUT?.encoded;
    if (encoded?.getQualifiedName === undefined || encoded.getQualifiedName() !== "STRING") { encoded = undefined; }
    if (encoded === undefined) { encoded = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.encoded); }
    let buffer = Buffer.from(encoded.get(), "base64");
    decoded.set(buffer.toString("hex").toUpperCase());
    return decoded;
  }
  async if_http_utility$unescape_url(INPUT) {
    return cl_http_utility.if_http_utility$unescape_url(INPUT);
  }
  static async if_http_utility$unescape_url(INPUT) {
    let unescaped = new abap.types.String({qualifiedName: "STRING"});
    let escaped = INPUT?.escaped;
    if (escaped?.getQualifiedName === undefined || escaped.getQualifiedName() !== "STRING") { escaped = undefined; }
    if (escaped === undefined) { escaped = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.escaped); }
    let options = new abap.types.Integer({qualifiedName: "I"});
    if (INPUT && INPUT.options) {options.set(INPUT.options);}
    let foo = escaped.get();
    unescaped.set(decodeURIComponent(foo));
    return unescaped;
  }
  async if_http_utility$escape_url(INPUT) {
    return cl_http_utility.if_http_utility$escape_url(INPUT);
  }
  static async if_http_utility$escape_url(INPUT) {
    let escaped = new abap.types.String({qualifiedName: "STRING"});
    let unescaped = INPUT?.unescaped;
    if (unescaped?.getQualifiedName === undefined || unescaped.getQualifiedName() !== "STRING") { unescaped = undefined; }
    if (unescaped === undefined) { unescaped = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.unescaped); }
    let lv_index = new abap.types.Integer({qualifiedName: "I"});
    let lv_char = new abap.types.String({qualifiedName: "STRING"});
    const indexBackup1 = abap.builtin.sy.get().index.get();
    const unique44 = abap.builtin.strlen({val: unescaped}).get();
    for (let unique45 = 0; unique45 < unique44; unique45++) {
      abap.builtin.sy.get().index.set(unique45 + 1);
      lv_index.set(abap.operators.minus(abap.builtin.sy.get().index,abap.IntegerFactory.get(1)));
      lv_char.set(unescaped.getOffset({offset: lv_index, length: 1}));
      if (abap.compare.ca(abap.builtin.to_upper({val: lv_char}), abap.builtin.sy.get().abcde) || abap.compare.ca(lv_char, new abap.types.Character(14).set('0123456789.-()'))) {
        escaped.set(abap.operators.concat(escaped,lv_char));
      } else {
        escaped.set(abap.operators.concat(escaped,abap.operators.concat(new abap.types.Character(1).set('%'),(abap.builtin.to_lower({val: (await abap.Classes['CL_ABAP_CODEPAGE'].convert_to({source: lv_char}))})))));
      }
    }
    abap.builtin.sy.get().index.set(indexBackup1);
    return escaped;
  }
  async if_http_utility$encode_base64(INPUT) {
    return cl_http_utility.if_http_utility$encode_base64(INPUT);
  }
  static async if_http_utility$encode_base64(INPUT) {
    let encoded = new abap.types.String({qualifiedName: "STRING"});
    let unencoded = INPUT?.unencoded;
    if (unencoded?.getQualifiedName === undefined || unencoded.getQualifiedName() !== "STRING") { unencoded = undefined; }
    if (unencoded === undefined) { unencoded = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.unencoded); }
    let buffer = Buffer.from(unencoded.get());
    encoded.set(buffer.toString("base64"));
    return encoded;
  }
  async if_http_utility$decode_base64(INPUT) {
    return cl_http_utility.if_http_utility$decode_base64(INPUT);
  }
  static async if_http_utility$decode_base64(INPUT) {
    let decoded = new abap.types.String({qualifiedName: "STRING"});
    let encoded = INPUT?.encoded;
    if (encoded?.getQualifiedName === undefined || encoded.getQualifiedName() !== "STRING") { encoded = undefined; }
    if (encoded === undefined) { encoded = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.encoded); }
    let buffer = Buffer.from(encoded.get(), "base64");
    decoded.set(buffer.toString());
    return decoded;
  }
}
abap.Classes['CL_HTTP_UTILITY'] = cl_http_utility;
export {cl_http_utility};
//# sourceMappingURL=cl_http_utility.clas.mjs.map