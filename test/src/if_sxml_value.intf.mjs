// if_sxml_value.intf.abap
class if_sxml_value {
  static INTERNAL_TYPE = 'INTF';
  static ATTRIBUTES = {"TYPE": {"type": () => {return new abap.types.Integer({qualifiedName: "IF_SXML_VALUE=>VALUE_TYPE"});}, "visibility": "U", "is_constant": " ", "is_class": " "},
  "CO_VT_TEXT": {"type": () => {return new abap.types.Integer({qualifiedName: "IF_SXML_VALUE=>VALUE_TYPE"});}, "visibility": "U", "is_constant": "X", "is_class": "X"}};
  static METHODS = {"GET_VALUE": {"visibility": "U", "parameters": {"VALUE": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}},
  "GET_VALUE_RAW": {"visibility": "U", "parameters": {"VALUE": {"type": () => {return new abap.types.XString({qualifiedName: "XSTRING"});}, "is_optional": " "}}},
  "SET_VALUE": {"visibility": "U", "parameters": {"VALUE": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}},
  "SET_VALUE_RAW": {"visibility": "U", "parameters": {"VALUE": {"type": () => {return new abap.types.XString({qualifiedName: "XSTRING"});}, "is_optional": " "}}}};
}
abap.Classes['IF_SXML_VALUE'] = if_sxml_value;
if_sxml_value.if_sxml_value$co_vt_text = new abap.types.Integer({qualifiedName: "IF_SXML_VALUE=>VALUE_TYPE"});
if_sxml_value.if_sxml_value$co_vt_text.set(2);
if_sxml_value.value_type = new abap.types.Integer({qualifiedName: "IF_SXML_VALUE=>VALUE_TYPE"});
export {if_sxml_value};
//# sourceMappingURL=if_sxml_value.intf.mjs.map