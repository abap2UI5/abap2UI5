// if_ixml_parser.intf.abap
class if_ixml_parser {
  static INTERNAL_TYPE = 'INTF';
  static ATTRIBUTES = {"CO_NO_VALIDATION": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "CO_VALIDATE_IF_DTD": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": "X", "is_class": "X"}};
  static METHODS = {"PARSE": {"visibility": "U", "parameters": {"SUBRC": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}}},
  "SET_NORMALIZING": {"visibility": "U", "parameters": {"NORMAL": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});}, "is_optional": " "}}},
  "NUM_ERRORS": {"visibility": "U", "parameters": {"ERRORS": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}}},
  "ADD_STRIP_SPACE_ELEMENT": {"visibility": "U", "parameters": {}},
  "GET_ERROR": {"visibility": "U", "parameters": {"ERROR": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_IXML_PARSE_ERROR", RTTIName: "\\INTERFACE=IF_IXML_PARSE_ERROR"});}, "is_optional": " "}, "INDEX": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}}},
  "SET_VALIDATING": {"visibility": "U", "parameters": {"RVAL": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});}, "is_optional": " "}, "MODE": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}}}};
}
abap.Classes['IF_IXML_PARSER'] = if_ixml_parser;
if_ixml_parser.if_ixml_parser$co_no_validation = new abap.types.Integer({qualifiedName: "I"});
if_ixml_parser.if_ixml_parser$co_no_validation.set(0);
if_ixml_parser.if_ixml_parser$co_validate_if_dtd = new abap.types.Integer({qualifiedName: "I"});
if_ixml_parser.if_ixml_parser$co_validate_if_dtd.set(2);
export {if_ixml_parser};
//# sourceMappingURL=if_ixml_parser.intf.mjs.map