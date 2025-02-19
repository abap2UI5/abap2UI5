// if_http_request.intf.abap
class if_http_request {
  static INTERNAL_TYPE = 'INTF';
  static ATTRIBUTES = {"IF_HTTP_ENTITY~CO_REQUEST_METHOD_GET": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "IF_HTTP_ENTITY~CO_REQUEST_METHOD_POST": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "IF_HTTP_ENTITY~CO_BODY_BEFORE_QUERY_STRING": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "IF_HTTP_ENTITY~CO_PROTOCOL_VERSION_1_0": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "IF_HTTP_ENTITY~CO_PROTOCOL_VERSION_1_1": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "IF_HTTP_ENTITY~CO_COMPRESS_BASED_ON_MIME_TYPE": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": "X", "is_class": "X"}};
  static METHODS = {"SET_METHOD": {"visibility": "U", "parameters": {"METHOD": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}},
  "GET_METHOD": {"visibility": "U", "parameters": {"METH": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}},
  "SET_VERSION": {"visibility": "U", "parameters": {"VERSION": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}}},
  "SET_AUTHORIZATION": {"visibility": "U", "parameters": {"AUTH_TYPE": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}, "USERNAME": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "PASSWORD": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}},
  "COPY": {"visibility": "U", "parameters": {"REQUEST": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_HTTP_REQUEST", RTTIName: "\\INTERFACE=IF_HTTP_REQUEST"});}, "is_optional": " "}}},
  "GET_AUTHORIZATION": {"visibility": "U", "parameters": {"AUTH_TYPE": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}, "USERNAME": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "PASSWORD": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}},
  "GET_FORM_DATA": {"visibility": "U", "parameters": {"NAME": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "DATA": {"type": () => {return new abap.types.Character(4);}, "is_optional": " "}}},
  "GET_RAW_MESSAGE": {"visibility": "U", "parameters": {"DATA": {"type": () => {return new abap.types.XString({qualifiedName: "XSTRING"});}, "is_optional": " "}}},
  "GET_URI_PARAMETER": {"visibility": "U", "parameters": {"VALUE": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "NAME": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}},
  "GET_USER_AGENT": {"visibility": "U", "parameters": {"USER_AGENT_TYPE": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}, "USER_AGENT_VERSION": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}}}};
}
abap.Classes['IF_HTTP_REQUEST'] = if_http_request;
if_http_request.if_http_request$co_compress_based_on_mime_type = new abap.types.Integer({qualifiedName: "I"});
if_http_request.if_http_entity$co_compress_based_on_mime_type = if_http_request.if_http_request$co_compress_based_on_mime_type;
if_http_request.if_http_request$co_compress_based_on_mime_type.set(2);
if_http_request.if_http_request$co_protocol_version_1_0 = new abap.types.Integer({qualifiedName: "I"});
if_http_request.if_http_entity$co_protocol_version_1_0 = if_http_request.if_http_request$co_protocol_version_1_0;
if_http_request.if_http_request$co_protocol_version_1_0.set(1000);
if_http_request.if_http_request$co_protocol_version_1_1 = new abap.types.Integer({qualifiedName: "I"});
if_http_request.if_http_entity$co_protocol_version_1_1 = if_http_request.if_http_request$co_protocol_version_1_1;
if_http_request.if_http_request$co_protocol_version_1_1.set(1001);
if_http_request.if_http_request$co_request_method_get = new abap.types.String({qualifiedName: "STRING"});
if_http_request.if_http_entity$co_request_method_get = if_http_request.if_http_request$co_request_method_get;
if_http_request.if_http_request$co_request_method_get.set('GET');
if_http_request.if_http_request$co_request_method_post = new abap.types.String({qualifiedName: "STRING"});
if_http_request.if_http_entity$co_request_method_post = if_http_request.if_http_request$co_request_method_post;
if_http_request.if_http_request$co_request_method_post.set('POST');
export {if_http_request};
//# sourceMappingURL=if_http_request.intf.mjs.map