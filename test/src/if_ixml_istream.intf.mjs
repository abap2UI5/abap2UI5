// if_ixml_istream.intf.abap
class if_ixml_istream {
  static INTERNAL_TYPE = 'INTF';
  static ATTRIBUTES = {"DTD_ALLOWED": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "DTD_RESTRICTED": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "DTD_PROHIBITED": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": "X", "is_class": "X"}};
  static METHODS = {"CLOSE": {"visibility": "U", "parameters": {}},
  "GET_DTD_RESTRICTION": {"visibility": "U", "parameters": {"RVAL": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}}},
  "SET_DTD_RESTRICTION": {"visibility": "U", "parameters": {"LEVEL": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}}}};
}
abap.Classes['IF_IXML_ISTREAM'] = if_ixml_istream;
if_ixml_istream.if_ixml_istream$dtd_allowed = new abap.types.Integer({qualifiedName: "I"});
if_ixml_istream.if_ixml_istream$dtd_allowed.set(0);
if_ixml_istream.if_ixml_istream$dtd_restricted = new abap.types.Integer({qualifiedName: "I"});
if_ixml_istream.if_ixml_istream$dtd_restricted.set(1);
if_ixml_istream.if_ixml_istream$dtd_prohibited = new abap.types.Integer({qualifiedName: "I"});
if_ixml_istream.if_ixml_istream$dtd_prohibited.set(2);
export {if_ixml_istream};
//# sourceMappingURL=if_ixml_istream.intf.mjs.map