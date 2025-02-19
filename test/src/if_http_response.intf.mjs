// if_http_response.intf.abap
class if_http_response {
  static INTERNAL_TYPE = 'INTF';
  static ATTRIBUTES = {"IF_HTTP_ENTITY~CO_REQUEST_METHOD_GET": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "IF_HTTP_ENTITY~CO_REQUEST_METHOD_POST": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "IF_HTTP_ENTITY~CO_BODY_BEFORE_QUERY_STRING": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "IF_HTTP_ENTITY~CO_PROTOCOL_VERSION_1_0": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "IF_HTTP_ENTITY~CO_PROTOCOL_VERSION_1_1": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "IF_HTTP_ENTITY~CO_COMPRESS_BASED_ON_MIME_TYPE": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": "X", "is_class": "X"}};
  static METHODS = {"GET_STATUS": {"visibility": "U", "parameters": {"CODE": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}, "REASON": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}},
  "SET_STATUS": {"visibility": "U", "parameters": {"CODE": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}, "REASON": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}},
  "DELETE_COOKIE_AT_CLIENT": {"visibility": "U", "parameters": {"NAME": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "PATH": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "DOMAIN": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}},
  "REDIRECT": {"visibility": "U", "parameters": {"URL": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "PERMANENTLY": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}, "EXPLANATION": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "PROTOCOL_DEPENDENT": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}}},
  "COPY": {"visibility": "U", "parameters": {"RESPONSE": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_HTTP_RESPONSE", RTTIName: "\\INTERFACE=IF_HTTP_RESPONSE"});}, "is_optional": " "}}},
  "GET_RAW_MESSAGE": {"visibility": "U", "parameters": {"DATA": {"type": () => {return new abap.types.XString({qualifiedName: "XSTRING"});}, "is_optional": " "}}},
  "SERVER_CACHE_BROWSER_DEPENDENT": {"visibility": "U", "parameters": {"DEPENDENT": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"BOOLEAN","ddicName":"BOOLEAN","description":""});}, "is_optional": " "}}},
  "SERVER_CACHE_EXPIRE_ABS": {"visibility": "U", "parameters": {"EXPIRES_ABS_DATE": {"type": () => {return new abap.types.Date({qualifiedName: "D"});}, "is_optional": " "}, "EXPIRES_ABS_TIME": {"type": () => {return new abap.types.Time({qualifiedName: "T"});}, "is_optional": " "}, "ETAG": {"type": () => {return new abap.types.Character(32, {"qualifiedName":"CHAR32","ddicName":"CHAR32","description":""});}, "is_optional": " "}, "BROWSER_DEPENDENT": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"BOOLEAN","ddicName":"BOOLEAN","description":""});}, "is_optional": " "}, "NO_UFO_CACHE": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"BOOLEAN","ddicName":"BOOLEAN","description":""});}, "is_optional": " "}}},
  "SERVER_CACHE_EXPIRE_DEFAULT": {"visibility": "U", "parameters": {"ETAG": {"type": () => {return new abap.types.Character(32, {"qualifiedName":"CHAR32","ddicName":"CHAR32","description":""});}, "is_optional": " "}, "BROWSER_DEPENDENT": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"BOOLEAN","ddicName":"BOOLEAN","description":""});}, "is_optional": " "}, "NO_UFO_CACHE": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"BOOLEAN","ddicName":"BOOLEAN","description":""});}, "is_optional": " "}}},
  "SERVER_CACHE_EXPIRE_REL": {"visibility": "U", "parameters": {"EXPIRES_REL": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}, "ETAG": {"type": () => {return new abap.types.Character(32, {"qualifiedName":"CHAR32","ddicName":"CHAR32","description":""});}, "is_optional": " "}, "BROWSER_DEPENDENT": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"BOOLEAN","ddicName":"BOOLEAN","description":""});}, "is_optional": " "}, "NO_UFO_CACHE": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"BOOLEAN","ddicName":"BOOLEAN","description":""});}, "is_optional": " "}}}};
}
abap.Classes['IF_HTTP_RESPONSE'] = if_http_response;
if_http_response.if_http_response$co_compress_based_on_mime_type = new abap.types.Integer({qualifiedName: "I"});
if_http_response.if_http_entity$co_compress_based_on_mime_type = if_http_response.if_http_response$co_compress_based_on_mime_type;
if_http_response.if_http_response$co_compress_based_on_mime_type.set(2);
if_http_response.if_http_response$co_protocol_version_1_0 = new abap.types.Integer({qualifiedName: "I"});
if_http_response.if_http_entity$co_protocol_version_1_0 = if_http_response.if_http_response$co_protocol_version_1_0;
if_http_response.if_http_response$co_protocol_version_1_0.set(1000);
if_http_response.if_http_response$co_protocol_version_1_1 = new abap.types.Integer({qualifiedName: "I"});
if_http_response.if_http_entity$co_protocol_version_1_1 = if_http_response.if_http_response$co_protocol_version_1_1;
if_http_response.if_http_response$co_protocol_version_1_1.set(1001);
if_http_response.if_http_response$co_request_method_get = new abap.types.String({qualifiedName: "STRING"});
if_http_response.if_http_entity$co_request_method_get = if_http_response.if_http_response$co_request_method_get;
if_http_response.if_http_response$co_request_method_get.set('GET');
if_http_response.if_http_response$co_request_method_post = new abap.types.String({qualifiedName: "STRING"});
if_http_response.if_http_entity$co_request_method_post = if_http_response.if_http_response$co_request_method_post;
if_http_response.if_http_response$co_request_method_post.set('POST');
export {if_http_response};
//# sourceMappingURL=if_http_response.intf.mjs.map