// if_http_client.intf.abap
class if_http_client {
  static INTERNAL_TYPE = 'INTF';
  static ATTRIBUTES = {"REQUEST": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_HTTP_REQUEST", RTTIName: "\\INTERFACE=IF_HTTP_REQUEST"});}, "visibility": "U", "is_constant": " ", "is_class": " "},
  "RESPONSE": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_HTTP_RESPONSE", RTTIName: "\\INTERFACE=IF_HTTP_RESPONSE"});}, "visibility": "U", "is_constant": " ", "is_class": " "},
  "PROPERTYTYPE_LOGON_POPUP": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": " ", "is_class": " "},
  "PROPERTYTYPE_ACCEPT_COOKIE": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": " ", "is_class": " "},
  "PROPERTYTYPE_REDIRECT": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": " ", "is_class": " "},
  "CO_DISABLED": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "CO_ENABLED": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "CO_TIMEOUT_DEFAULT": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": "X", "is_class": "X"}};
  static METHODS = {"AUTHENTICATE": {"visibility": "U", "parameters": {"PROXY_AUTHENTICATION": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});}, "is_optional": " "}, "USERNAME": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "PASSWORD": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}},
  "CLOSE": {"visibility": "U", "parameters": {}},
  "SEND": {"visibility": "U", "parameters": {"TIMEOUT": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}}},
  "RECEIVE": {"visibility": "U", "parameters": {}},
  "SEND_SAP_LOGON_TICKET": {"visibility": "U", "parameters": {}},
  "GET_LAST_ERROR": {"visibility": "U", "parameters": {"CODE": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}, "MESSAGE": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}},
  "REFRESH_REQUEST": {"visibility": "U", "parameters": {}},
  "CREATE_ABS_URL": {"visibility": "U", "parameters": {"URL": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "PATH": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}},
  "ESCAPE_URL": {"visibility": "U", "parameters": {"ESCAPED": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "UNESCAPED": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}}};
}
abap.Classes['IF_HTTP_CLIENT'] = if_http_client;
if_http_client.if_http_client$co_disabled = new abap.types.Integer({qualifiedName: "I"});
if_http_client.if_http_client$co_disabled.set(0);
if_http_client.if_http_client$co_enabled = new abap.types.Integer({qualifiedName: "I"});
if_http_client.if_http_client$co_enabled.set(1);
if_http_client.if_http_client$co_timeout_default = new abap.types.Integer({qualifiedName: "I"});
if_http_client.if_http_client$co_timeout_default.set(60);
export {if_http_client};
//# sourceMappingURL=if_http_client.intf.mjs.map