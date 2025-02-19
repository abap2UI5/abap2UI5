const {cx_root} = await import("./cx_root.clas.mjs");
// cl_http_server.clas.abap
class cl_http_server {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CL_HTTP_SERVER';
  static IMPLEMENTED_INTERFACES = ["IF_HTTP_SERVER"];
  static ATTRIBUTES = {"C_COMPRESSION_SUPPORTED": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": " ", "is_class": "X"},
  "M_PROTOCOL_VERSION": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "visibility": "U", "is_constant": " ", "is_class": " "},
  "IF_HTTP_SERVER~SESSION_ID": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "visibility": "U", "is_constant": " ", "is_class": "X"},
  "IF_HTTP_SERVER~AUTHENTICATION_METHOD": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": " ", "is_class": "X"},
  "IF_HTTP_SERVER~AUTHENTICATED": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": " ", "is_class": "X"},
  "IF_HTTP_SERVER~RESPONSE": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_HTTP_RESPONSE", RTTIName: "\\INTERFACE=IF_HTTP_RESPONSE"});}, "visibility": "U", "is_constant": " ", "is_class": " "},
  "IF_HTTP_SERVER~REQUEST": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_HTTP_REQUEST", RTTIName: "\\INTERFACE=IF_HTTP_REQUEST"});}, "visibility": "U", "is_constant": " ", "is_class": " "},
  "IF_HTTP_SERVER~AUTHMETHOD_SERVICE": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "IF_HTTP_SERVER~CO_COMPRESS_BASED_ON_MIME_TYPE": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "IF_HTTP_SERVER~CO_DISABLED": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "IF_HTTP_SERVER~CO_ENABLED": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "IF_HTTP_SERVER~CO_PAGE_ERROR_TYPE": {"type": () => {return new abap.types.Character(1, {});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "IF_HTTP_SERVER~CO_RESPONSE_PAGE_OPTION": {"type": () => {return new abap.types.Character(1, {});}, "visibility": "U", "is_constant": "X", "is_class": "X"}};
  static METHODS = {"GET_LOCATION": {"visibility": "U", "parameters": {"APPLICATION": {"type": () => {return new abap.types.Character();}, "is_optional": " "}, "PORT": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "OUT_PROTOCOL": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "HOST": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}}};
  constructor() {
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
    this.c_compression_supported = cl_http_server.c_compression_supported;
    this.m_protocol_version = new abap.types.String({qualifiedName: "STRING"});
    this.if_http_server$authmethod_service = abap.Classes['IF_HTTP_SERVER'].if_http_server$authmethod_service;
    this.if_http_server$co_compress_based_on_mime_type = abap.Classes['IF_HTTP_SERVER'].if_http_server$co_compress_based_on_mime_type;
    this.if_http_server$co_disabled = abap.Classes['IF_HTTP_SERVER'].if_http_server$co_disabled;
    this.if_http_server$co_enabled = abap.Classes['IF_HTTP_SERVER'].if_http_server$co_enabled;
    this.if_http_server$co_page_error_type = abap.Classes['IF_HTTP_SERVER'].if_http_server$co_page_error_type;
    this.if_http_server$co_response_page_option = abap.Classes['IF_HTTP_SERVER'].if_http_server$co_response_page_option;
    if (this.if_http_server$session_id === undefined) this.if_http_server$session_id = cl_http_server.if_http_server$session_id;
    if (this.if_http_server$authentication_method === undefined) this.if_http_server$authentication_method = cl_http_server.if_http_server$authentication_method;
    if (this.if_http_server$authenticated === undefined) this.if_http_server$authenticated = cl_http_server.if_http_server$authenticated;
    if (this.if_http_server$response === undefined) this.if_http_server$response = new abap.types.ABAPObject({qualifiedName: "IF_HTTP_RESPONSE", RTTIName: "\\INTERFACE=IF_HTTP_RESPONSE"});
    if (this.if_http_server$request === undefined) this.if_http_server$request = new abap.types.ABAPObject({qualifiedName: "IF_HTTP_REQUEST", RTTIName: "\\INTERFACE=IF_HTTP_REQUEST"});
    this.co_enabled = this.if_http_server$co_enabled;
    this.append_field_url = this.if_http_server$append_field_url;
  }
  async constructor_(INPUT) {
    if (super.constructor_) { await super.constructor_(INPUT); }
    return this;
  }
  async if_http_server$logoff(INPUT) {
    let delete_mysapsso2_cookie = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    if (INPUT && INPUT.delete_mysapsso2_cookie) {delete_mysapsso2_cookie.set(INPUT.delete_mysapsso2_cookie);}
    let propagate_logoff = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    if (INPUT && INPUT.propagate_logoff) {propagate_logoff.set(INPUT.propagate_logoff);}
    let redirect_url = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.redirect_url) {redirect_url.set(INPUT.redirect_url);}
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
  }
  async if_http_server$set_session_stateful(INPUT) {
    let stateful = new abap.types.Integer({qualifiedName: "I"});
    if (INPUT && INPUT.stateful) {stateful.set(INPUT.stateful);}
    if (INPUT === undefined || INPUT.stateful === undefined) {stateful = abap.Classes['IF_HTTP_SERVER'].if_http_server$co_enabled;}
    let path = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.path) {path.set(INPUT.path);}
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
  }
  async if_http_server$append_field_url(INPUT) {
    return cl_http_server.if_http_server$append_field_url(INPUT);
  }
  static async if_http_server$append_field_url(INPUT) {
    let name = INPUT?.name;
    if (name?.getQualifiedName === undefined || name.getQualifiedName() !== "STRING") { name = undefined; }
    if (name === undefined) { name = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.name); }
    let value = INPUT?.value;
    if (value?.getQualifiedName === undefined || value.getQualifiedName() !== "STRING") { value = undefined; }
    if (value === undefined) { value = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.value); }
    let url = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.url) {url = INPUT.url;}
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
  }
  async if_http_server$create_abs_url(INPUT) {
    let url = new abap.types.String({qualifiedName: "STRING"});
    let protocol = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.protocol) {protocol.set(INPUT.protocol);}
    let post = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.post) {post.set(INPUT.post);}
    let port = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.port) {port.set(INPUT.port);}
    let path = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.path) {path.set(INPUT.path);}
    let querystring = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.querystring) {querystring.set(INPUT.querystring);}
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return url;
  }
  async if_http_server$create_rel_url(INPUT) {
    let url = new abap.types.String({qualifiedName: "STRING"});
    let path = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.path) {path.set(INPUT.path);}
    let querystring = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.querystring) {querystring.set(INPUT.querystring);}
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return url;
  }
  async if_http_server$decode_base64(INPUT) {
    return cl_http_server.if_http_server$decode_base64(INPUT);
  }
  static async if_http_server$decode_base64(INPUT) {
    let decoded = new abap.types.String({qualifiedName: "STRING"});
    let encoded = INPUT?.encoded;
    if (encoded?.getQualifiedName === undefined || encoded.getQualifiedName() !== "STRING") { encoded = undefined; }
    if (encoded === undefined) { encoded = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.encoded); }
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return decoded;
  }
  async if_http_server$enable_foreign_session_access(INPUT) {
    let url_path = INPUT?.url_path;
    if (url_path?.getQualifiedName === undefined || url_path.getQualifiedName() !== "STRING") { url_path = undefined; }
    if (url_path === undefined) { url_path = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.url_path); }
    let user_id = new abap.types.Character(12, {"qualifiedName":"SYUNAME","ddicName":"SYUNAME","description":"SYUNAME"});
    if (INPUT && INPUT.user_id) {user_id.set(INPUT.user_id);}
    let one_time_access_token = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    if (INPUT && INPUT.one_time_access_token) {one_time_access_token.set(INPUT.one_time_access_token);}
    if (INPUT === undefined || INPUT.one_time_access_token === undefined) {one_time_access_token = abap.builtin.abap_true;}
    let session_access_token = INPUT?.session_access_token || new abap.types.String({qualifiedName: "STRING"});
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
  }
  async if_http_server$encode_base64(INPUT) {
    return cl_http_server.if_http_server$encode_base64(INPUT);
  }
  static async if_http_server$encode_base64(INPUT) {
    let encoded = new abap.types.String({qualifiedName: "STRING"});
    let unencoded = INPUT?.unencoded;
    if (unencoded?.getQualifiedName === undefined || unencoded.getQualifiedName() !== "STRING") { unencoded = undefined; }
    if (unencoded === undefined) { unencoded = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.unencoded); }
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return encoded;
  }
  async if_http_server$escape_html(INPUT) {
    return cl_http_server.if_http_server$escape_html(INPUT);
  }
  static async if_http_server$escape_html(INPUT) {
    let escaped = new abap.types.String({qualifiedName: "STRING"});
    let unescaped = INPUT?.unescaped;
    if (unescaped?.getQualifiedName === undefined || unescaped.getQualifiedName() !== "STRING") { unescaped = undefined; }
    if (unescaped === undefined) { unescaped = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.unescaped); }
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return escaped;
  }
  async if_http_server$escape_url(INPUT) {
    return cl_http_server.if_http_server$escape_url(INPUT);
  }
  static async if_http_server$escape_url(INPUT) {
    let escaped = new abap.types.String({qualifiedName: "STRING"});
    let unescaped = INPUT?.unescaped;
    if (unescaped?.getQualifiedName === undefined || unescaped.getQualifiedName() !== "STRING") { unescaped = undefined; }
    if (unescaped === undefined) { unescaped = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.unescaped); }
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return escaped;
  }
  async if_http_server$get_extension_info(INPUT) {
    return cl_http_server.if_http_server$get_extension_info(INPUT);
  }
  static async if_http_server$get_extension_info(INPUT) {
    let extension_class = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.extension_class) {extension_class.set(INPUT.extension_class);}
    let urls = INPUT?.urls || abap.types.TableFactory.construct(new abap.types.String({qualifiedName: "STRING"}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"isUnique":false,"type":"STANDARD","keyFields":[],"name":"primary_key"},"secondary":[]}, "STRING_TABLE");
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
  }
  async if_http_server$get_extension_url(INPUT) {
    return cl_http_server.if_http_server$get_extension_url(INPUT);
  }
  static async if_http_server$get_extension_url(INPUT) {
    let extension_class = INPUT?.extension_class;
    if (extension_class?.getQualifiedName === undefined || extension_class.getQualifiedName() !== "STRING") { extension_class = undefined; }
    if (extension_class === undefined) { extension_class = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.extension_class); }
    let urls = INPUT?.urls || abap.types.TableFactory.construct(new abap.types.String({qualifiedName: "STRING"}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"isUnique":false,"type":"STANDARD","keyFields":[],"name":"primary_key"},"secondary":[]}, "STRING_TABLE");
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
  }
  async if_http_server$get_last_error() {
    let rc = new abap.types.Integer({qualifiedName: "I"});
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return rc;
  }
  async if_http_server$get_location(INPUT) {
    return cl_http_server.if_http_server$get_location(INPUT);
  }
  static async if_http_server$get_location(INPUT) {
    let url_part = new abap.types.String({qualifiedName: "STRING"});
    let protocol = INPUT?.protocol || new abap.types.Character();
    let application = INPUT?.application || new abap.types.Character();
    let for_domain = INPUT?.for_domain || new abap.types.Character();
    let server = new abap.types.ABAPObject({qualifiedName: "IF_HTTP_SERVER", RTTIName: "\\INTERFACE=IF_HTTP_SERVER"});
    if (INPUT && INPUT.server) {server.set(INPUT.server);}
    let use_ticket_protocol = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    if (INPUT && INPUT.use_ticket_protocol) {use_ticket_protocol.set(INPUT.use_ticket_protocol);}
    if (INPUT === undefined || INPUT.use_ticket_protocol === undefined) {use_ticket_protocol = abap.builtin.abap_true;}
    let host = INPUT?.host || new abap.types.String({qualifiedName: "STRING"});
    let port = INPUT?.port || new abap.types.String({qualifiedName: "STRING"});
    let out_protocol = INPUT?.out_protocol || new abap.types.String({qualifiedName: "STRING"});
    let vh_switch = INPUT?.vh_switch || new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return url_part;
  }
  async if_http_server$get_location_exception(INPUT) {
    return cl_http_server.if_http_server$get_location_exception(INPUT);
  }
  static async if_http_server$get_location_exception(INPUT) {
    let url_part = new abap.types.String({qualifiedName: "STRING"});
    let protocol = INPUT?.protocol || new abap.types.Character();
    let application = INPUT?.application || new abap.types.Character();
    let for_domain = INPUT?.for_domain || new abap.types.Character();
    let server = new abap.types.ABAPObject({qualifiedName: "IF_HTTP_SERVER", RTTIName: "\\INTERFACE=IF_HTTP_SERVER"});
    if (INPUT && INPUT.server) {server.set(INPUT.server);}
    let use_ticket_protocol = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    if (INPUT && INPUT.use_ticket_protocol) {use_ticket_protocol.set(INPUT.use_ticket_protocol);}
    if (INPUT === undefined || INPUT.use_ticket_protocol === undefined) {use_ticket_protocol = abap.builtin.abap_true;}
    let host = INPUT?.host || new abap.types.String({qualifiedName: "STRING"});
    let port = INPUT?.port || new abap.types.String({qualifiedName: "STRING"});
    let out_protocol = INPUT?.out_protocol || new abap.types.String({qualifiedName: "STRING"});
    let vh_switch = INPUT?.vh_switch || new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return url_part;
  }
  async if_http_server$get_xsrf_token(INPUT) {
    let token = INPUT?.token || new abap.types.String({qualifiedName: "STRING"});
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
  }
  async if_http_server$send_page() {
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
  }
  async if_http_server$set_compression(INPUT) {
    let options = new abap.types.Integer({qualifiedName: "I"});
    if (INPUT && INPUT.options) {options.set(INPUT.options);}
    if (INPUT === undefined || INPUT.options === undefined) {options = abap.Classes['IF_HTTP_SERVER'].if_http_server$co_compress_based_on_mime_type;}
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
  }
  async if_http_server$set_page(INPUT) {
    let response_page_type = new abap.types.Character(1, {"qualifiedName":"CHAR1","ddicName":"CHAR1","description":"CHAR1"});
    if (INPUT && INPUT.response_page_type) {response_page_type.set(INPUT.response_page_type);}
    if (INPUT === undefined || INPUT.response_page_type === undefined) {response_page_type = abap.Classes['IF_HTTP_SERVER'].if_http_server$co_page_error_type;}
    let response_option = new abap.types.Character(1, {"qualifiedName":"CHAR1","ddicName":"CHAR1","description":"CHAR1"});
    if (INPUT && INPUT.response_option) {response_option.set(INPUT.response_option);}
    if (INPUT === undefined || INPUT.response_option === undefined) {response_option = abap.Classes['IF_HTTP_SERVER'].if_http_server$co_response_page_option;}
    let response_option_page = INPUT?.response_option_page || new abap.types.Character(4);
    let response_option_redirect_url = INPUT?.response_option_redirect_url || new abap.types.Character(4);
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
  }
  async if_http_server$set_session_stateful_via_url(INPUT) {
    let stateful = new abap.types.Integer({qualifiedName: "I"});
    if (INPUT && INPUT.stateful) {stateful.set(INPUT.stateful);}
    if (INPUT === undefined || INPUT.stateful === undefined) {stateful = abap.Classes['IF_HTTP_SERVER'].if_http_server$co_enabled;}
    let rewrite_url = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.rewrite_url) {rewrite_url = INPUT.rewrite_url;}
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
  }
  async if_http_server$unescape_url(INPUT) {
    return cl_http_server.if_http_server$unescape_url(INPUT);
  }
  static async if_http_server$unescape_url(INPUT) {
    let unescaped = new abap.types.String({qualifiedName: "STRING"});
    let escaped = INPUT?.escaped;
    if (escaped?.getQualifiedName === undefined || escaped.getQualifiedName() !== "STRING") { escaped = undefined; }
    if (escaped === undefined) { escaped = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.escaped); }
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return unescaped;
  }
  async if_http_server$validate_xsrf_token(INPUT) {
    let token = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.token) {token.set(INPUT.token);}
    let successful = INPUT?.successful || new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
  }
  async get_location(INPUT) {
    return cl_http_server.get_location(INPUT);
  }
  static async get_location(INPUT) {
    let application = INPUT?.application || new abap.types.Character();
    let port = INPUT?.port || new abap.types.String({qualifiedName: "STRING"});
    let out_protocol = INPUT?.out_protocol || new abap.types.String({qualifiedName: "STRING"});
    let host = INPUT?.host || new abap.types.String({qualifiedName: "STRING"});
    host.set(new abap.types.Character(13).set('open-abap.org'));
  }
}
abap.Classes['CL_HTTP_SERVER'] = cl_http_server;
cl_http_server.c_compression_supported = new abap.types.Integer({qualifiedName: "I"});
cl_http_server.if_http_server$session_id = new abap.types.String({qualifiedName: "STRING"});
cl_http_server.if_http_server$authentication_method = new abap.types.Integer({qualifiedName: "I"});
cl_http_server.if_http_server$authenticated = new abap.types.Integer({qualifiedName: "I"});
cl_http_server.if_http_server$authmethod_service = new abap.types.Integer({qualifiedName: "I"});
cl_http_server.if_http_server$authmethod_service.set(4);
cl_http_server.if_http_server$co_compress_based_on_mime_type = new abap.types.Integer({qualifiedName: "I"});
cl_http_server.if_http_server$co_compress_based_on_mime_type.set(2);
cl_http_server.if_http_server$co_disabled = new abap.types.Integer({qualifiedName: "I"});
cl_http_server.if_http_server$co_disabled.set(0);
cl_http_server.if_http_server$co_enabled = new abap.types.Integer({qualifiedName: "I"});
cl_http_server.if_http_server$co_enabled.set(1);
cl_http_server.if_http_server$co_page_error_type = new abap.types.Character(1, {});
cl_http_server.if_http_server$co_page_error_type.set('1');
cl_http_server.if_http_server$co_response_page_option = new abap.types.Character(1, {});
cl_http_server.if_http_server$co_response_page_option.set(' ');
cl_http_server.co_enabled = cl_http_server.if_http_server$co_enabled;
export {cl_http_server};
//# sourceMappingURL=cl_http_server.clas.mjs.map