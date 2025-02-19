// if_ixml_parse_error.intf.abap
class if_ixml_parse_error {
  static INTERNAL_TYPE = 'INTF';
  static ATTRIBUTES = {};
  static METHODS = {"GET_REASON": {"visibility": "U", "parameters": {"REASON": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}},
  "GET_LINE": {"visibility": "U", "parameters": {"LINE": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}}},
  "GET_COLUMN": {"visibility": "U", "parameters": {"COLUMN": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}}}};
}
abap.Classes['IF_IXML_PARSE_ERROR'] = if_ixml_parse_error;
export {if_ixml_parse_error};
//# sourceMappingURL=if_ixml_parse_error.intf.mjs.map