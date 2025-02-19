const {cx_root} = await import("./cx_root.clas.mjs");
// cl_http_entity.clas.abap
class cl_http_entity {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CL_HTTP_ENTITY';
  static IMPLEMENTED_INTERFACES = ["IF_HTTP_RESPONSE","IF_HTTP_REQUEST","IF_HTTP_ENTITY","IF_HTTP_ENTITY"];
  static ATTRIBUTES = {"M_LAST_ERROR": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "O", "is_constant": " ", "is_class": " "},
  "MV_STATUS": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "I", "is_constant": " ", "is_class": " "},
  "MV_REASON": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "visibility": "I", "is_constant": " ", "is_class": " "},
  "MV_CONTENT_TYPE": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "visibility": "I", "is_constant": " ", "is_class": " "},
  "MV_METHOD": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "visibility": "I", "is_constant": " ", "is_class": " "},
  "MV_DATA": {"type": () => {return new abap.types.XString({qualifiedName: "XSTRING"});}, "visibility": "I", "is_constant": " ", "is_class": " "},
  "MT_HEADERS": {"type": () => {return abap.types.TableFactory.construct(new abap.types.Structure({"name": new abap.types.String({qualifiedName: "STRING"}), "value": new abap.types.String({qualifiedName: "STRING"})}, "IHTTPNVP", "IHTTPNVP", {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"isUnique":false,"type":"STANDARD","keyFields":[],"name":"primary_key"},"secondary":[]}, "TIHTTPNVP");}, "visibility": "I", "is_constant": " ", "is_class": " "},
  "MT_FORM_FIELDS": {"type": () => {return abap.types.TableFactory.construct(new abap.types.Structure({"name": new abap.types.String({qualifiedName: "STRING"}), "value": new abap.types.String({qualifiedName: "STRING"})}, "IHTTPNVP", "IHTTPNVP", {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"isUnique":false,"type":"STANDARD","keyFields":[],"name":"primary_key"},"secondary":[]}, "TIHTTPNVP");}, "visibility": "I", "is_constant": " ", "is_class": " "},
  "IF_HTTP_ENTITY~CO_REQUEST_METHOD_GET": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "IF_HTTP_ENTITY~CO_REQUEST_METHOD_POST": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "IF_HTTP_ENTITY~CO_BODY_BEFORE_QUERY_STRING": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "IF_HTTP_ENTITY~CO_PROTOCOL_VERSION_1_0": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "IF_HTTP_ENTITY~CO_PROTOCOL_VERSION_1_1": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "IF_HTTP_ENTITY~CO_COMPRESS_BASED_ON_MIME_TYPE": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "IF_HTTP_ENTITY~CO_REQUEST_METHOD_GET": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "IF_HTTP_ENTITY~CO_REQUEST_METHOD_POST": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "IF_HTTP_ENTITY~CO_BODY_BEFORE_QUERY_STRING": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "IF_HTTP_ENTITY~CO_PROTOCOL_VERSION_1_0": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "IF_HTTP_ENTITY~CO_PROTOCOL_VERSION_1_1": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "IF_HTTP_ENTITY~CO_COMPRESS_BASED_ON_MIME_TYPE": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": "X", "is_class": "X"}};
  static METHODS = {};
  constructor() {
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
    this.m_last_error = new abap.types.Integer({qualifiedName: "I"});
    this.mv_status = new abap.types.Integer({qualifiedName: "I"});
    this.mv_reason = new abap.types.String({qualifiedName: "STRING"});
    this.mv_content_type = new abap.types.String({qualifiedName: "STRING"});
    this.mv_method = new abap.types.String({qualifiedName: "STRING"});
    this.mv_data = new abap.types.XString({qualifiedName: "XSTRING"});
    this.mt_headers = abap.types.TableFactory.construct(new abap.types.Structure({"name": new abap.types.String({qualifiedName: "STRING"}), "value": new abap.types.String({qualifiedName: "STRING"})}, "IHTTPNVP", "IHTTPNVP", {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"isUnique":false,"type":"STANDARD","keyFields":[],"name":"primary_key"},"secondary":[]}, "TIHTTPNVP");
    this.mt_form_fields = abap.types.TableFactory.construct(new abap.types.Structure({"name": new abap.types.String({qualifiedName: "STRING"}), "value": new abap.types.String({qualifiedName: "STRING"})}, "IHTTPNVP", "IHTTPNVP", {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"isUnique":false,"type":"STANDARD","keyFields":[],"name":"primary_key"},"secondary":[]}, "TIHTTPNVP");
    this.if_http_entity$co_request_method_get = abap.Classes['IF_HTTP_ENTITY'].if_http_entity$co_request_method_get;
    this.if_http_entity$co_request_method_post = abap.Classes['IF_HTTP_ENTITY'].if_http_entity$co_request_method_post;
    this.if_http_entity$co_body_before_query_string = abap.Classes['IF_HTTP_ENTITY'].if_http_entity$co_body_before_query_string;
    this.if_http_entity$co_protocol_version_1_0 = abap.Classes['IF_HTTP_ENTITY'].if_http_entity$co_protocol_version_1_0;
    this.if_http_entity$co_protocol_version_1_1 = abap.Classes['IF_HTTP_ENTITY'].if_http_entity$co_protocol_version_1_1;
    this.if_http_entity$co_compress_based_on_mime_type = abap.Classes['IF_HTTP_ENTITY'].if_http_entity$co_compress_based_on_mime_type;
    this.if_http_response$add_cookie_field = this.if_http_entity$add_cookie_field;
    this.if_http_response$add_multipart = this.if_http_entity$add_multipart;
    this.if_http_response$append_cdata = this.if_http_entity$append_cdata;
    this.if_http_response$append_cdata2 = this.if_http_entity$append_cdata2;
    this.if_http_response$append_data = this.if_http_entity$append_data;
    this.if_http_response$co_compress_based_on_mime_type = this.if_http_entity$co_compress_based_on_mime_type;
    this.if_http_response$co_protocol_version_1_0 = this.if_http_entity$co_protocol_version_1_0;
    this.if_http_response$co_protocol_version_1_1 = this.if_http_entity$co_protocol_version_1_1;
    this.if_http_response$co_request_method_get = this.if_http_entity$co_request_method_get;
    this.if_http_response$co_request_method_post = this.if_http_entity$co_request_method_post;
    this.if_http_response$delete_cookie = this.if_http_entity$delete_cookie;
    this.if_http_response$delete_cookie_secure = this.if_http_entity$delete_cookie_secure;
    this.if_http_response$delete_form_field = this.if_http_entity$delete_form_field;
    this.if_http_response$delete_form_field_secure = this.if_http_entity$delete_form_field_secure;
    this.if_http_response$delete_header_field = this.if_http_entity$delete_header_field;
    this.if_http_response$delete_header_field_secure = this.if_http_entity$delete_header_field_secure;
    this.if_http_response$from_xstring = this.if_http_entity$from_xstring;
    this.if_http_response$get_cdata = this.if_http_entity$get_cdata;
    this.if_http_response$get_content_type = this.if_http_entity$get_content_type;
    this.if_http_response$get_cookie = this.if_http_entity$get_cookie;
    this.if_http_response$get_cookie_field = this.if_http_entity$get_cookie_field;
    this.if_http_response$get_cookies = this.if_http_entity$get_cookies;
    this.if_http_response$get_data = this.if_http_entity$get_data;
    this.if_http_response$get_form_field = this.if_http_entity$get_form_field;
    this.if_http_response$get_form_field_cs = this.if_http_entity$get_form_field_cs;
    this.if_http_response$get_form_fields = this.if_http_entity$get_form_fields;
    this.if_http_response$get_form_fields_cs = this.if_http_entity$get_form_fields_cs;
    this.if_http_response$get_header_field = this.if_http_entity$get_header_field;
    this.if_http_response$get_header_fields = this.if_http_entity$get_header_fields;
    this.if_http_response$get_last_error = this.if_http_entity$get_last_error;
    this.if_http_response$get_multipart = this.if_http_entity$get_multipart;
    this.if_http_response$get_serialized_message_length = this.if_http_entity$get_serialized_message_length;
    this.if_http_response$get_version = this.if_http_entity$get_version;
    this.if_http_response$num_multiparts = this.if_http_entity$num_multiparts;
    this.if_http_response$set_cdata = this.if_http_entity$set_cdata;
    this.if_http_response$set_compression = this.if_http_entity$set_compression;
    this.if_http_response$set_content_type = this.if_http_entity$set_content_type;
    this.if_http_response$set_cookie = this.if_http_entity$set_cookie;
    this.if_http_response$set_data = this.if_http_entity$set_data;
    this.if_http_response$set_formfield_encoding = this.if_http_entity$set_formfield_encoding;
    this.if_http_response$set_form_field = this.if_http_entity$set_form_field;
    this.if_http_response$set_form_fields = this.if_http_entity$set_form_fields;
    this.if_http_response$set_header_field = this.if_http_entity$set_header_field;
    this.if_http_response$set_header_fields = this.if_http_entity$set_header_fields;
    this.if_http_response$suppress_content_type = this.if_http_entity$suppress_content_type;
    this.if_http_response$to_xstring = this.if_http_entity$to_xstring;
    this.if_http_entity$co_request_method_get = abap.Classes['IF_HTTP_ENTITY'].if_http_entity$co_request_method_get;
    this.if_http_entity$co_request_method_post = abap.Classes['IF_HTTP_ENTITY'].if_http_entity$co_request_method_post;
    this.if_http_entity$co_body_before_query_string = abap.Classes['IF_HTTP_ENTITY'].if_http_entity$co_body_before_query_string;
    this.if_http_entity$co_protocol_version_1_0 = abap.Classes['IF_HTTP_ENTITY'].if_http_entity$co_protocol_version_1_0;
    this.if_http_entity$co_protocol_version_1_1 = abap.Classes['IF_HTTP_ENTITY'].if_http_entity$co_protocol_version_1_1;
    this.if_http_entity$co_compress_based_on_mime_type = abap.Classes['IF_HTTP_ENTITY'].if_http_entity$co_compress_based_on_mime_type;
    this.if_http_request$add_cookie_field = this.if_http_entity$add_cookie_field;
    this.if_http_request$add_multipart = this.if_http_entity$add_multipart;
    this.if_http_request$append_cdata = this.if_http_entity$append_cdata;
    this.if_http_request$append_cdata2 = this.if_http_entity$append_cdata2;
    this.if_http_request$append_data = this.if_http_entity$append_data;
    this.if_http_request$co_compress_based_on_mime_type = this.if_http_entity$co_compress_based_on_mime_type;
    this.if_http_request$co_protocol_version_1_0 = this.if_http_entity$co_protocol_version_1_0;
    this.if_http_request$co_protocol_version_1_1 = this.if_http_entity$co_protocol_version_1_1;
    this.if_http_request$co_request_method_get = this.if_http_entity$co_request_method_get;
    this.if_http_request$co_request_method_post = this.if_http_entity$co_request_method_post;
    this.if_http_request$delete_cookie = this.if_http_entity$delete_cookie;
    this.if_http_request$delete_cookie_secure = this.if_http_entity$delete_cookie_secure;
    this.if_http_request$delete_form_field = this.if_http_entity$delete_form_field;
    this.if_http_request$delete_form_field_secure = this.if_http_entity$delete_form_field_secure;
    this.if_http_request$delete_header_field = this.if_http_entity$delete_header_field;
    this.if_http_request$delete_header_field_secure = this.if_http_entity$delete_header_field_secure;
    this.if_http_request$from_xstring = this.if_http_entity$from_xstring;
    this.if_http_request$get_cdata = this.if_http_entity$get_cdata;
    this.if_http_request$get_content_type = this.if_http_entity$get_content_type;
    this.if_http_request$get_cookie = this.if_http_entity$get_cookie;
    this.if_http_request$get_cookie_field = this.if_http_entity$get_cookie_field;
    this.if_http_request$get_cookies = this.if_http_entity$get_cookies;
    this.if_http_request$get_data = this.if_http_entity$get_data;
    this.if_http_request$get_form_field = this.if_http_entity$get_form_field;
    this.if_http_request$get_form_field_cs = this.if_http_entity$get_form_field_cs;
    this.if_http_request$get_form_fields = this.if_http_entity$get_form_fields;
    this.if_http_request$get_form_fields_cs = this.if_http_entity$get_form_fields_cs;
    this.if_http_request$get_header_field = this.if_http_entity$get_header_field;
    this.if_http_request$get_header_fields = this.if_http_entity$get_header_fields;
    this.if_http_request$get_last_error = this.if_http_entity$get_last_error;
    this.if_http_request$get_multipart = this.if_http_entity$get_multipart;
    this.if_http_request$get_serialized_message_length = this.if_http_entity$get_serialized_message_length;
    this.if_http_request$get_version = this.if_http_entity$get_version;
    this.if_http_request$num_multiparts = this.if_http_entity$num_multiparts;
    this.if_http_request$set_cdata = this.if_http_entity$set_cdata;
    this.if_http_request$set_compression = this.if_http_entity$set_compression;
    this.if_http_request$set_content_type = this.if_http_entity$set_content_type;
    this.if_http_request$set_cookie = this.if_http_entity$set_cookie;
    this.if_http_request$set_data = this.if_http_entity$set_data;
    this.if_http_request$set_formfield_encoding = this.if_http_entity$set_formfield_encoding;
    this.if_http_request$set_form_field = this.if_http_entity$set_form_field;
    this.if_http_request$set_form_fields = this.if_http_entity$set_form_fields;
    this.if_http_request$set_header_field = this.if_http_entity$set_header_field;
    this.if_http_request$set_header_fields = this.if_http_entity$set_header_fields;
    this.if_http_request$suppress_content_type = this.if_http_entity$suppress_content_type;
    this.if_http_request$to_xstring = this.if_http_entity$to_xstring;
    this.set_header_field = this.if_http_entity$set_header_field;
    this.append_cdata = this.if_http_entity$append_cdata;
    this.get_cdata = this.if_http_entity$get_cdata;
    this.set_cdata = this.if_http_entity$set_cdata;
    this.get_header_field = this.if_http_entity$get_header_field;
    this.set_header_field = this.if_http_entity$set_header_field;
  }
  async constructor_(INPUT) {
    if (super.constructor_) { await super.constructor_(INPUT); }
    return this;
  }
  async if_http_response$server_cache_expire_rel(INPUT) {
    let expires_rel = INPUT?.expires_rel;
    if (expires_rel?.getQualifiedName === undefined || expires_rel.getQualifiedName() !== "I") { expires_rel = undefined; }
    if (expires_rel === undefined) { expires_rel = new abap.types.Integer({qualifiedName: "I"}).set(INPUT.expires_rel); }
    let etag = new abap.types.Character(32, {"qualifiedName":"CHAR32","ddicName":"CHAR32","description":""});
    if (INPUT && INPUT.etag) {etag.set(INPUT.etag);}
    let browser_dependent = new abap.types.Character(1, {"qualifiedName":"BOOLEAN","ddicName":"BOOLEAN","description":""});
    if (INPUT && INPUT.browser_dependent) {browser_dependent.set(INPUT.browser_dependent);}
    if (INPUT === undefined || INPUT.browser_dependent === undefined) {browser_dependent = abap.builtin.abap_false;}
    let no_ufo_cache = new abap.types.Character(1, {"qualifiedName":"BOOLEAN","ddicName":"BOOLEAN","description":""});
    if (INPUT && INPUT.no_ufo_cache) {no_ufo_cache.set(INPUT.no_ufo_cache);}
    if (INPUT === undefined || INPUT.no_ufo_cache === undefined) {no_ufo_cache = abap.builtin.abap_false;}
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
  }
  async if_http_response$server_cache_expire_default(INPUT) {
    let etag = new abap.types.Character(32, {"qualifiedName":"CHAR32","ddicName":"CHAR32","description":""});
    if (INPUT && INPUT.etag) {etag.set(INPUT.etag);}
    let browser_dependent = new abap.types.Character(1, {"qualifiedName":"BOOLEAN","ddicName":"BOOLEAN","description":""});
    if (INPUT && INPUT.browser_dependent) {browser_dependent.set(INPUT.browser_dependent);}
    if (INPUT === undefined || INPUT.browser_dependent === undefined) {browser_dependent = abap.builtin.abap_false;}
    let no_ufo_cache = new abap.types.Character(1, {"qualifiedName":"BOOLEAN","ddicName":"BOOLEAN","description":""});
    if (INPUT && INPUT.no_ufo_cache) {no_ufo_cache.set(INPUT.no_ufo_cache);}
    if (INPUT === undefined || INPUT.no_ufo_cache === undefined) {no_ufo_cache = abap.builtin.abap_false;}
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
  }
  async if_http_response$server_cache_expire_abs(INPUT) {
    let expires_abs_date = new abap.types.Date({qualifiedName: "D"});
    if (INPUT && INPUT.expires_abs_date) {expires_abs_date.set(INPUT.expires_abs_date);}
    let expires_abs_time = new abap.types.Time({qualifiedName: "T"});
    if (INPUT && INPUT.expires_abs_time) {expires_abs_time.set(INPUT.expires_abs_time);}
    let etag = new abap.types.Character(32, {"qualifiedName":"CHAR32","ddicName":"CHAR32","description":""});
    if (INPUT && INPUT.etag) {etag.set(INPUT.etag);}
    let browser_dependent = new abap.types.Character(1, {"qualifiedName":"BOOLEAN","ddicName":"BOOLEAN","description":""});
    if (INPUT && INPUT.browser_dependent) {browser_dependent.set(INPUT.browser_dependent);}
    if (INPUT === undefined || INPUT.browser_dependent === undefined) {browser_dependent = abap.builtin.abap_false;}
    let no_ufo_cache = new abap.types.Character(1, {"qualifiedName":"BOOLEAN","ddicName":"BOOLEAN","description":""});
    if (INPUT && INPUT.no_ufo_cache) {no_ufo_cache.set(INPUT.no_ufo_cache);}
    if (INPUT === undefined || INPUT.no_ufo_cache === undefined) {no_ufo_cache = abap.builtin.abap_false;}
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
  }
  async if_http_response$server_cache_browser_dependent(INPUT) {
    let dependent = new abap.types.Character(1, {"qualifiedName":"BOOLEAN","ddicName":"BOOLEAN","description":""});
    if (INPUT && INPUT.dependent) {dependent.set(INPUT.dependent);}
    if (INPUT === undefined || INPUT.dependent === undefined) {dependent = abap.builtin.abap_true;}
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
  }
  async if_http_response$get_raw_message() {
    let data = new abap.types.XString({qualifiedName: "XSTRING"});
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return data;
  }
  async if_http_response$copy() {
    let response = new abap.types.ABAPObject({qualifiedName: "IF_HTTP_RESPONSE", RTTIName: "\\INTERFACE=IF_HTTP_RESPONSE"});
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return response;
  }
  async if_http_request$get_user_agent(INPUT) {
    let user_agent_type = INPUT?.user_agent_type || new abap.types.Integer({qualifiedName: "I"});
    let user_agent_version = INPUT?.user_agent_version || new abap.types.Integer({qualifiedName: "I"});
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
  }
  async if_http_request$get_uri_parameter(INPUT) {
    let value = new abap.types.String({qualifiedName: "STRING"});
    let name = INPUT?.name;
    if (name?.getQualifiedName === undefined || name.getQualifiedName() !== "STRING") { name = undefined; }
    if (name === undefined) { name = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.name); }
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return value;
  }
  async if_http_request$get_raw_message() {
    let data = new abap.types.XString({qualifiedName: "XSTRING"});
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return data;
  }
  async if_http_request$get_form_data(INPUT) {
    let name = INPUT?.name;
    if (name?.getQualifiedName === undefined || name.getQualifiedName() !== "STRING") { name = undefined; }
    if (name === undefined) { name = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.name); }
    let data = new abap.types.Character(4);
    if (INPUT && INPUT.data) {data = INPUT.data;}
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
  }
  async if_http_request$get_authorization(INPUT) {
    let auth_type = INPUT?.auth_type || new abap.types.Integer({qualifiedName: "I"});
    let username = INPUT?.username || new abap.types.String({qualifiedName: "STRING"});
    let password = INPUT?.password || new abap.types.String({qualifiedName: "STRING"});
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
  }
  async if_http_request$copy() {
    let request = new abap.types.ABAPObject({qualifiedName: "IF_HTTP_REQUEST", RTTIName: "\\INTERFACE=IF_HTTP_REQUEST"});
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return request;
  }
  async if_http_request$set_authorization(INPUT) {
    let auth_type = new abap.types.Integer({qualifiedName: "I"});
    if (INPUT && INPUT.auth_type) {auth_type.set(INPUT.auth_type);}
    if (INPUT === undefined || INPUT.auth_type === undefined) {auth_type = abap.IntegerFactory.get(1);}
    let username = INPUT?.username;
    if (username?.getQualifiedName === undefined || username.getQualifiedName() !== "STRING") { username = undefined; }
    if (username === undefined) { username = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.username); }
    let password = INPUT?.password;
    if (password?.getQualifiedName === undefined || password.getQualifiedName() !== "STRING") { password = undefined; }
    if (password === undefined) { password = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.password); }
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
  }
  async if_http_entity$add_multipart(INPUT) {
    let entity = new abap.types.ABAPObject({qualifiedName: "IF_HTTP_ENTITY", RTTIName: "\\INTERFACE=IF_HTTP_ENTITY"});
    let suppress_content_length = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    if (INPUT && INPUT.suppress_content_length) {suppress_content_length.set(INPUT.suppress_content_length);}
    if (INPUT === undefined || INPUT.suppress_content_length === undefined) {suppress_content_length = abap.builtin.abap_false;}
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return entity;
  }
  async if_http_entity$get_cookie_field(INPUT) {
    let field_value = new abap.types.String({qualifiedName: "STRING"});
    let cookie_name = INPUT?.cookie_name;
    if (cookie_name?.getQualifiedName === undefined || cookie_name.getQualifiedName() !== "STRING") { cookie_name = undefined; }
    if (cookie_name === undefined) { cookie_name = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.cookie_name); }
    let cookie_path = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.cookie_path) {cookie_path.set(INPUT.cookie_path);}
    let field_name = INPUT?.field_name;
    if (field_name?.getQualifiedName === undefined || field_name.getQualifiedName() !== "STRING") { field_name = undefined; }
    if (field_name === undefined) { field_name = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.field_name); }
    let base64 = new abap.types.Integer({qualifiedName: "I"});
    if (INPUT && INPUT.base64) {base64.set(INPUT.base64);}
    if (INPUT === undefined || INPUT.base64 === undefined) {base64 = abap.IntegerFactory.get(1);}
    abap.statements.clear(field_value);
    return field_value;
  }
  async if_http_entity$set_compression(INPUT) {
    let disable_extended_checks = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    if (INPUT && INPUT.disable_extended_checks) {disable_extended_checks.set(INPUT.disable_extended_checks);}
    if (INPUT === undefined || INPUT.disable_extended_checks === undefined) {disable_extended_checks = abap.builtin.abap_false;}
    let options = new abap.types.Integer({qualifiedName: "I"});
    if (INPUT && INPUT.options) {options.set(INPUT.options);}
    if (INPUT === undefined || INPUT.options === undefined) {options = abap.Classes['IF_HTTP_ENTITY'].if_http_entity$co_compress_based_on_mime_type;}
  }
  async if_http_entity$append_cdata(INPUT) {
    let data = INPUT?.data;
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
  }
  async if_http_entity$append_cdata2(INPUT) {
    let data = INPUT?.data;
    if (data?.getQualifiedName === undefined || data.getQualifiedName() !== "STRING") { data = undefined; }
    if (data === undefined) { data = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.data); }
    let encoding = new abap.types.Integer({qualifiedName: "I"});
    if (INPUT && INPUT.encoding) {encoding.set(INPUT.encoding);}
    let offset = new abap.types.Integer({qualifiedName: "I"});
    if (INPUT && INPUT.offset) {offset.set(INPUT.offset);}
    let length = new abap.types.Integer({qualifiedName: "I"});
    if (INPUT && INPUT.length) {length.set(INPUT.length);}
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
  }
  async if_http_entity$add_cookie_field(INPUT) {
    let cookie_name = INPUT?.cookie_name;
    if (cookie_name?.getQualifiedName === undefined || cookie_name.getQualifiedName() !== "STRING") { cookie_name = undefined; }
    if (cookie_name === undefined) { cookie_name = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.cookie_name); }
    let cookie_path = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.cookie_path) {cookie_path.set(INPUT.cookie_path);}
    let field_name = INPUT?.field_name;
    if (field_name?.getQualifiedName === undefined || field_name.getQualifiedName() !== "STRING") { field_name = undefined; }
    if (field_name === undefined) { field_name = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.field_name); }
    let field_value = INPUT?.field_value;
    if (field_value?.getQualifiedName === undefined || field_value.getQualifiedName() !== "STRING") { field_value = undefined; }
    if (field_value === undefined) { field_value = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.field_value); }
    let base64 = new abap.types.Integer({qualifiedName: "I"});
    if (INPUT && INPUT.base64) {base64.set(INPUT.base64);}
    if (INPUT === undefined || INPUT.base64 === undefined) {base64 = abap.IntegerFactory.get(1);}
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
  }
  async if_http_entity$append_data(INPUT) {
    let data = INPUT?.data;
    if (data?.getQualifiedName === undefined || data.getQualifiedName() !== "XSTRING") { data = undefined; }
    if (data === undefined) { data = new abap.types.XString({qualifiedName: "XSTRING"}).set(INPUT.data); }
    let offset = new abap.types.Integer({qualifiedName: "I"});
    if (INPUT && INPUT.offset) {offset.set(INPUT.offset);}
    let length = new abap.types.Integer({qualifiedName: "I"});
    if (INPUT && INPUT.length) {length.set(INPUT.length);}
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
  }
  async if_http_entity$to_xstring() {
    let data = new abap.types.XString({qualifiedName: "XSTRING"});
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return data;
  }
  async if_http_entity$delete_cookie_secure(INPUT) {
    let name = INPUT?.name;
    if (name?.getQualifiedName === undefined || name.getQualifiedName() !== "STRING") { name = undefined; }
    if (name === undefined) { name = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.name); }
    let path = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.path) {path.set(INPUT.path);}
    if (INPUT === undefined || INPUT.path === undefined) {path = new abap.types.String().set(``);}
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
  }
  async if_http_entity$get_cookies(INPUT) {
    let cookies = new abap.types.Character(4);
    if (INPUT && INPUT.cookies) {cookies = INPUT.cookies;}
    abap.statements.clear(cookies);
  }
  async if_http_entity$delete_form_field(INPUT) {
    let name = INPUT?.name;
    if (name?.getQualifiedName === undefined || name.getQualifiedName() !== "STRING") { name = undefined; }
    if (name === undefined) { name = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.name); }
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
  }
  async if_http_entity$delete_form_field_secure(INPUT) {
    let name = INPUT?.name;
    if (name?.getQualifiedName === undefined || name.getQualifiedName() !== "STRING") { name = undefined; }
    if (name === undefined) { name = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.name); }
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
  }
  async if_http_entity$get_cookie(INPUT) {
    let name = INPUT?.name;
    if (name?.getQualifiedName === undefined || name.getQualifiedName() !== "STRING") { name = undefined; }
    if (name === undefined) { name = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.name); }
    let path = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.path) {path.set(INPUT.path);}
    if (INPUT === undefined || INPUT.path === undefined) {path = new abap.types.String().set(``);}
    let value = INPUT?.value || new abap.types.String({qualifiedName: "STRING"});
    let domain = INPUT?.domain || new abap.types.String({qualifiedName: "STRING"});
    let expires = INPUT?.expires || new abap.types.String({qualifiedName: "STRING"});
    let secure = INPUT?.secure || new abap.types.Integer({qualifiedName: "I"});
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
  }
  async if_http_entity$get_data_length(INPUT) {
    let data_length = INPUT?.data_length || new abap.types.Integer({qualifiedName: "I"});
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
  }
  async if_http_entity$from_xstring(INPUT) {
    let data = INPUT?.data;
    if (data?.getQualifiedName === undefined || data.getQualifiedName() !== "XSTRING") { data = undefined; }
    if (data === undefined) { data = new abap.types.XString({qualifiedName: "XSTRING"}).set(INPUT.data); }
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
  }
  async if_http_entity$get_form_field_cs(INPUT) {
    let value = new abap.types.String({qualifiedName: "STRING"});
    let name = INPUT?.name;
    if (name?.getQualifiedName === undefined || name.getQualifiedName() !== "STRING") { name = undefined; }
    if (name === undefined) { name = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.name); }
    let formfield_encoding = new abap.types.Integer({qualifiedName: "I"});
    if (INPUT && INPUT.formfield_encoding) {formfield_encoding.set(INPUT.formfield_encoding);}
    let search_option = new abap.types.Integer({qualifiedName: "I"});
    if (INPUT && INPUT.search_option) {search_option.set(INPUT.search_option);}
    if (INPUT === undefined || INPUT.search_option === undefined) {search_option = abap.Classes['IF_HTTP_ENTITY'].if_http_entity$co_body_before_query_string;}
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return value;
  }
  async if_http_entity$get_last_error() {
    let rc = new abap.types.Integer({qualifiedName: "I"});
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return rc;
  }
  async if_http_entity$delete_header_field(INPUT) {
    let name = INPUT?.name;
    if (name?.getQualifiedName === undefined || name.getQualifiedName() !== "STRING") { name = undefined; }
    if (name === undefined) { name = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.name); }
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
  }
  async if_http_entity$delete_header_field_secure(INPUT) {
    let name = INPUT?.name;
    if (name?.getQualifiedName === undefined || name.getQualifiedName() !== "STRING") { name = undefined; }
    if (name === undefined) { name = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.name); }
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
  }
  async if_http_entity$delete_cookie(INPUT) {
    let name = INPUT?.name;
    if (name?.getQualifiedName === undefined || name.getQualifiedName() !== "STRING") { name = undefined; }
    if (name === undefined) { name = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.name); }
    let path = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.path) {path.set(INPUT.path);}
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
  }
  async if_http_entity$set_header_fields(INPUT) {
    let fields = INPUT?.fields;
    if (fields?.getQualifiedName === undefined || fields.getQualifiedName() !== "TIHTTPNVP") { fields = undefined; }
    if (fields === undefined) { fields = abap.types.TableFactory.construct(new abap.types.Structure({"name": new abap.types.String({qualifiedName: "STRING"}), "value": new abap.types.String({qualifiedName: "STRING"})}, "IHTTPNVP", "IHTTPNVP", {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"isUnique":false,"type":"STANDARD","keyFields":[],"name":"primary_key"},"secondary":[]}, "TIHTTPNVP").set(INPUT.fields); }
    let ls_field = new abap.types.Structure({"name": new abap.types.String({qualifiedName: "STRING"}), "value": new abap.types.String({qualifiedName: "STRING"})}, "IHTTPNVP", "IHTTPNVP", {}, {});
    for await (const unique40 of abap.statements.loop(fields)) {
      ls_field.set(unique40);
      await this.if_http_entity$set_header_field({name: ls_field.get().name, value: ls_field.get().value});
    }
  }
  async if_http_entity$suppress_content_type(INPUT) {
    let suppress = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    if (INPUT && INPUT.suppress) {suppress.set(INPUT.suppress);}
    if (INPUT === undefined || INPUT.suppress === undefined) {suppress = abap.builtin.abap_true;}
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
  }
  async if_http_entity$set_formfield_encoding(INPUT) {
    let formfield_encoding = INPUT?.formfield_encoding;
    if (formfield_encoding?.getQualifiedName === undefined || formfield_encoding.getQualifiedName() !== "I") { formfield_encoding = undefined; }
    if (formfield_encoding === undefined) { formfield_encoding = new abap.types.Integer({qualifiedName: "I"}).set(INPUT.formfield_encoding); }
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
  }
  async if_http_entity$set_cookie(INPUT) {
    let name = INPUT?.name;
    if (name?.getQualifiedName === undefined || name.getQualifiedName() !== "STRING") { name = undefined; }
    if (name === undefined) { name = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.name); }
    let path = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.path) {path.set(INPUT.path);}
    let value = INPUT?.value;
    if (value?.getQualifiedName === undefined || value.getQualifiedName() !== "STRING") { value = undefined; }
    if (value === undefined) { value = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.value); }
    let domain = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.domain) {domain.set(INPUT.domain);}
    let expires = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.expires) {expires.set(INPUT.expires);}
    let secure = new abap.types.Integer({qualifiedName: "I"});
    if (INPUT && INPUT.secure) {secure.set(INPUT.secure);}
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
  }
  async if_http_entity$get_version() {
    let version = new abap.types.Integer({qualifiedName: "I"});
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return version;
  }
  async if_http_entity$get_serialized_message_length(INPUT) {
    let body_length = INPUT?.body_length || new abap.types.Integer({qualifiedName: "I"});
    let header_length = INPUT?.header_length || new abap.types.Integer({qualifiedName: "I"});
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
  }
  async if_http_entity$get_header_field(INPUT) {
    let value = new abap.types.String({qualifiedName: "STRING"});
    let name = INPUT?.name;
    if (name?.getQualifiedName === undefined || name.getQualifiedName() !== "STRING") { name = undefined; }
    if (name === undefined) { name = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.name); }
    let ls_header = new abap.types.Structure({"name": new abap.types.String({qualifiedName: "STRING"}), "value": new abap.types.String({qualifiedName: "STRING"})}, "IHTTPNVP", "IHTTPNVP", {}, {});
    abap.statements.readTable(this.mt_headers,{into: ls_header,
      withKey: (i) => {return abap.compare.eq(i.name, abap.builtin.to_lower({val: name}));},
      withKeyValue: [{key: (i) => {return i.name}, value: abap.builtin.to_lower({val: name})}],
      usesTableLine: false,
      withKeySimple: {"name": abap.builtin.to_lower({val: name})}});
    if (abap.compare.eq(abap.builtin.sy.get().subrc, abap.IntegerFactory.get(0))) {
      value.set(ls_header.get().value);
    }
    return value;
  }
  async if_http_entity$get_header_fields(INPUT) {
    let fields = abap.types.TableFactory.construct(new abap.types.Structure({"name": new abap.types.String({qualifiedName: "STRING"}), "value": new abap.types.String({qualifiedName: "STRING"})}, "IHTTPNVP", "IHTTPNVP", {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"isUnique":false,"type":"STANDARD","keyFields":[],"name":"primary_key"},"secondary":[]}, "TIHTTPNVP");
    if (INPUT && INPUT.fields) {fields = INPUT.fields;}
    fields.set(this.mt_headers);
  }
  async if_http_response$get_status(INPUT) {
    let code = INPUT?.code || new abap.types.Integer({qualifiedName: "I"});
    let reason = INPUT?.reason || new abap.types.String({qualifiedName: "STRING"});
    code.set(this.mv_status);
    reason.set(this.mv_reason);
  }
  async if_http_entity$get_cdata() {
    let data = new abap.types.String({qualifiedName: "STRING"});
    await (await abap.Classes['CL_ABAP_CONV_IN_CE'].create({encoding: new abap.types.Character(5).set('UTF-8')})).get().convert({input: this.mv_data, data: data});
    return data;
  }
  async if_http_response$set_status(INPUT) {
    let code = INPUT?.code;
    if (code?.getQualifiedName === undefined || code.getQualifiedName() !== "I") { code = undefined; }
    if (code === undefined) { code = new abap.types.Integer({qualifiedName: "I"}).set(INPUT.code); }
    let reason = INPUT?.reason;
    if (reason?.getQualifiedName === undefined || reason.getQualifiedName() !== "STRING") { reason = undefined; }
    if (reason === undefined) { reason = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.reason); }
    this.mv_status.set(code);
    this.mv_reason.set(reason);
  }
  async if_http_entity$set_cdata(INPUT) {
    let data = INPUT?.data;
    if (data?.getQualifiedName === undefined || data.getQualifiedName() !== "STRING") { data = undefined; }
    if (data === undefined) { data = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.data); }
    let offset = new abap.types.Integer({qualifiedName: "I"});
    if (INPUT && INPUT.offset) {offset.set(INPUT.offset);}
    let length = new abap.types.Integer({qualifiedName: "I"});
    if (INPUT && INPUT.length) {length.set(INPUT.length);}
    await (await abap.Classes['CL_ABAP_CONV_OUT_CE'].create({encoding: new abap.types.Character(5).set('UTF-8')})).get().convert({data: data, buffer: this.mv_data});
  }
  async if_http_entity$get_content_type() {
    let content_type = new abap.types.String({qualifiedName: "STRING"});
    content_type.set((await this.if_http_entity$get_header_field({name: new abap.types.Character(12).set('content-type')})));
    return content_type;
  }
  async if_http_entity$set_content_type(INPUT) {
    let content_type = INPUT?.content_type;
    if (content_type?.getQualifiedName === undefined || content_type.getQualifiedName() !== "STRING") { content_type = undefined; }
    if (content_type === undefined) { content_type = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.content_type); }
    await this.if_http_entity$set_header_field({name: new abap.types.Character(12).set('content-type'), value: content_type});
  }
  async if_http_entity$get_data() {
    let data = new abap.types.XString({qualifiedName: "XSTRING"});
    data.set(this.mv_data);
    return data;
  }
  async if_http_entity$set_data(INPUT) {
    let data = INPUT?.data;
    if (data?.getQualifiedName === undefined || data.getQualifiedName() !== "XSTRING") { data = undefined; }
    if (data === undefined) { data = new abap.types.XString({qualifiedName: "XSTRING"}).set(INPUT.data); }
    this.mv_data.set(data);
  }
  async if_http_response$delete_cookie_at_client(INPUT) {
    let name = INPUT?.name;
    if (name?.getQualifiedName === undefined || name.getQualifiedName() !== "STRING") { name = undefined; }
    if (name === undefined) { name = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.name); }
    let path = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.path) {path.set(INPUT.path);}
    let domain = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.domain) {domain.set(INPUT.domain);}
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(2), new abap.types.Character(4).set('todo')));
  }
  async if_http_response$redirect(INPUT) {
    let url = INPUT?.url;
    if (url?.getQualifiedName === undefined || url.getQualifiedName() !== "STRING") { url = undefined; }
    if (url === undefined) { url = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.url); }
    let permanently = new abap.types.Integer({qualifiedName: "I"});
    if (INPUT && INPUT.permanently) {permanently.set(INPUT.permanently);}
    let explanation = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.explanation) {explanation.set(INPUT.explanation);}
    let protocol_dependent = new abap.types.Integer({qualifiedName: "I"});
    if (INPUT && INPUT.protocol_dependent) {protocol_dependent.set(INPUT.protocol_dependent);}
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(2), new abap.types.Character(4).set('todo')));
  }
  async if_http_entity$num_multiparts() {
    let num = new abap.types.Integer({qualifiedName: "I"});
    num.set(abap.IntegerFactory.get(0));
    return num;
  }
  async if_http_entity$get_multipart(INPUT) {
    let entity = new abap.types.ABAPObject({qualifiedName: "IF_HTTP_ENTITY", RTTIName: "\\INTERFACE=IF_HTTP_ENTITY"});
    let index = INPUT?.index;
    if (index?.getQualifiedName === undefined || index.getQualifiedName() !== "I") { index = undefined; }
    if (index === undefined) { index = new abap.types.Integer({qualifiedName: "I"}).set(INPUT.index); }
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(2), new abap.types.Character(4).set('todo')));
    return entity;
  }
  async if_http_entity$get_form_fields_cs(INPUT) {
    let formfield_encoding = new abap.types.Integer({qualifiedName: "I"});
    if (INPUT && INPUT.formfield_encoding) {formfield_encoding.set(INPUT.formfield_encoding);}
    let search_option = new abap.types.Integer({qualifiedName: "I"});
    if (INPUT && INPUT.search_option) {search_option.set(INPUT.search_option);}
    if (INPUT === undefined || INPUT.search_option === undefined) {search_option = abap.Classes['IF_HTTP_ENTITY'].if_http_entity$co_body_before_query_string;}
    let fields = abap.types.TableFactory.construct(new abap.types.Structure({"name": new abap.types.String({qualifiedName: "STRING"}), "value": new abap.types.String({qualifiedName: "STRING"})}, "IHTTPNVP", "IHTTPNVP", {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"isUnique":false,"type":"STANDARD","keyFields":[],"name":"primary_key"},"secondary":[]}, "TIHTTPNVP");
    if (INPUT && INPUT.fields) {fields = INPUT.fields;}
    fields.set(this.mt_form_fields);
  }
  async if_http_entity$set_form_fields(INPUT) {
    let fields = INPUT?.fields;
    if (fields?.getQualifiedName === undefined || fields.getQualifiedName() !== "TIHTTPNVP") { fields = undefined; }
    if (fields === undefined) { fields = abap.types.TableFactory.construct(new abap.types.Structure({"name": new abap.types.String({qualifiedName: "STRING"}), "value": new abap.types.String({qualifiedName: "STRING"})}, "IHTTPNVP", "IHTTPNVP", {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"isUnique":false,"type":"STANDARD","keyFields":[],"name":"primary_key"},"secondary":[]}, "TIHTTPNVP").set(INPUT.fields); }
    let multivalue = new abap.types.Integer({qualifiedName: "INT4"});
    if (INPUT && INPUT.multivalue) {multivalue.set(INPUT.multivalue);}
    this.mt_form_fields.set(fields);
  }
  async if_http_entity$get_form_fields(INPUT) {
    let fields = abap.types.TableFactory.construct(new abap.types.Structure({"name": new abap.types.String({qualifiedName: "STRING"}), "value": new abap.types.String({qualifiedName: "STRING"})}, "IHTTPNVP", "IHTTPNVP", {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"isUnique":false,"type":"STANDARD","keyFields":[],"name":"primary_key"},"secondary":[]}, "TIHTTPNVP");
    if (INPUT && INPUT.fields) {fields = INPUT.fields;}
    let ls_field = new abap.types.Structure({"name": new abap.types.String({qualifiedName: "STRING"}), "value": new abap.types.String({qualifiedName: "STRING"})}, "IHTTPNVP", "IHTTPNVP", {}, {});
    for await (const unique41 of abap.statements.loop(this.mt_form_fields)) {
      ls_field.set(unique41);
      abap.statements.translate(ls_field.get().name, "LOWER");
      abap.statements.append({source: ls_field, target: fields});
    }
  }
  async if_http_entity$get_form_field(INPUT) {
    let value = new abap.types.String({qualifiedName: "STRING"});
    let name = INPUT?.name;
    if (name?.getQualifiedName === undefined || name.getQualifiedName() !== "STRING") { name = undefined; }
    if (name === undefined) { name = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.name); }
    let ls_field = new abap.types.Structure({"name": new abap.types.String({qualifiedName: "STRING"}), "value": new abap.types.String({qualifiedName: "STRING"})}, "IHTTPNVP", "IHTTPNVP", {}, {});
    abap.statements.readTable(this.mt_form_fields,{into: ls_field,
      withKey: (i) => {return abap.compare.eq(i.name, abap.builtin.to_lower({val: name}));},
      withKeyValue: [{key: (i) => {return i.name}, value: abap.builtin.to_lower({val: name})}],
      usesTableLine: false,
      withKeySimple: {"name": abap.builtin.to_lower({val: name})}});
    if (abap.compare.eq(abap.builtin.sy.get().subrc, abap.IntegerFactory.get(0))) {
      value.set(ls_field.get().value);
    }
    return value;
  }
  async if_http_entity$set_header_field(INPUT) {
    let name = INPUT?.name;
    if (name?.getQualifiedName === undefined || name.getQualifiedName() !== "STRING") { name = undefined; }
    if (name === undefined) { name = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.name); }
    let value = INPUT?.value;
    if (value?.getQualifiedName === undefined || value.getQualifiedName() !== "STRING") { value = undefined; }
    if (value === undefined) { value = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.value); }
    let ls_header = new abap.types.Structure({"name": new abap.types.String({qualifiedName: "STRING"}), "value": new abap.types.String({qualifiedName: "STRING"})}, "IHTTPNVP", "IHTTPNVP", {}, {});
    let fs_ls_header_ = new abap.types.FieldSymbol(new abap.types.Structure({"name": new abap.types.String({qualifiedName: "STRING"}), "value": new abap.types.String({qualifiedName: "STRING"})}, "IHTTPNVP", "IHTTPNVP", {}, {}));
    abap.statements.readTable(this.mt_headers,{assigning: fs_ls_header_,
      withKey: (i) => {return abap.compare.eq(i.name, abap.builtin.to_lower({val: name}));},
      withKeyValue: [{key: (i) => {return i.name}, value: abap.builtin.to_lower({val: name})}],
      usesTableLine: false,
      withKeySimple: {"name": abap.builtin.to_lower({val: name})}});
    if (abap.compare.eq(abap.builtin.sy.get().subrc, abap.IntegerFactory.get(0))) {
      fs_ls_header_.get().value.set(value);
    } else {
      ls_header.get().name.set(abap.builtin.to_lower({val: name}));
      ls_header.get().value.set(value);
      abap.statements.append({source: ls_header, target: this.mt_headers});
    }
    if (abap.compare.eq(name, new abap.types.Character(15).set('~request_method'))) {
      await this.if_http_request$set_method({method: value});
    }
  }
  async if_http_request$set_method(INPUT) {
    let method = INPUT?.method;
    if (method?.getQualifiedName === undefined || method.getQualifiedName() !== "STRING") { method = undefined; }
    if (method === undefined) { method = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.method); }
    this.mv_method.set(method);
  }
  async if_http_request$get_method() {
    let meth = new abap.types.String({qualifiedName: "STRING"});
    meth.set(this.mv_method);
    return meth;
  }
  async if_http_request$set_version(INPUT) {
    let version = INPUT?.version;
    if (version?.getQualifiedName === undefined || version.getQualifiedName() !== "I") { version = undefined; }
    if (version === undefined) { version = new abap.types.Integer({qualifiedName: "I"}).set(INPUT.version); }
    return;
  }
  async if_http_entity$set_form_field(INPUT) {
    let name = INPUT?.name;
    if (name?.getQualifiedName === undefined || name.getQualifiedName() !== "STRING") { name = undefined; }
    if (name === undefined) { name = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.name); }
    let value = INPUT?.value;
    if (value?.getQualifiedName === undefined || value.getQualifiedName() !== "STRING") { value = undefined; }
    if (value === undefined) { value = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.value); }
    let ls_field = new abap.types.Structure({"name": new abap.types.String({qualifiedName: "STRING"}), "value": new abap.types.String({qualifiedName: "STRING"})}, "IHTTPNVP", "IHTTPNVP", {}, {});
    ls_field.get().name.set(name);
    ls_field.get().value.set(value);
    abap.statements.append({source: ls_field, target: this.mt_form_fields});
  }
}
abap.Classes['CL_HTTP_ENTITY'] = cl_http_entity;
cl_http_entity.if_http_entity$co_request_method_get = new abap.types.String({qualifiedName: "STRING"});
cl_http_entity.if_http_entity$co_request_method_get.set('GET');
cl_http_entity.if_http_entity$co_request_method_post = new abap.types.String({qualifiedName: "STRING"});
cl_http_entity.if_http_entity$co_request_method_post.set('POST');
cl_http_entity.if_http_entity$co_body_before_query_string = new abap.types.Integer({qualifiedName: "I"});
cl_http_entity.if_http_entity$co_body_before_query_string.set(3);
cl_http_entity.if_http_entity$co_protocol_version_1_0 = new abap.types.Integer({qualifiedName: "I"});
cl_http_entity.if_http_entity$co_protocol_version_1_0.set(1000);
cl_http_entity.if_http_entity$co_protocol_version_1_1 = new abap.types.Integer({qualifiedName: "I"});
cl_http_entity.if_http_entity$co_protocol_version_1_1.set(1001);
cl_http_entity.if_http_entity$co_compress_based_on_mime_type = new abap.types.Integer({qualifiedName: "I"});
cl_http_entity.if_http_entity$co_compress_based_on_mime_type.set(2);
cl_http_entity.if_http_entity$co_request_method_get = new abap.types.String({qualifiedName: "STRING"});
cl_http_entity.if_http_entity$co_request_method_get.set('GET');
cl_http_entity.if_http_entity$co_request_method_post = new abap.types.String({qualifiedName: "STRING"});
cl_http_entity.if_http_entity$co_request_method_post.set('POST');
cl_http_entity.if_http_entity$co_body_before_query_string = new abap.types.Integer({qualifiedName: "I"});
cl_http_entity.if_http_entity$co_body_before_query_string.set(3);
cl_http_entity.if_http_entity$co_protocol_version_1_0 = new abap.types.Integer({qualifiedName: "I"});
cl_http_entity.if_http_entity$co_protocol_version_1_0.set(1000);
cl_http_entity.if_http_entity$co_protocol_version_1_1 = new abap.types.Integer({qualifiedName: "I"});
cl_http_entity.if_http_entity$co_protocol_version_1_1.set(1001);
cl_http_entity.if_http_entity$co_compress_based_on_mime_type = new abap.types.Integer({qualifiedName: "I"});
cl_http_entity.if_http_entity$co_compress_based_on_mime_type.set(2);
export {cl_http_entity};
//# sourceMappingURL=cl_http_entity.clas.mjs.map