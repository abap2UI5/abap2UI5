// if_ixml_ostream.intf.abap
class if_ixml_ostream {
  static INTERNAL_TYPE = 'INTF';
  static ATTRIBUTES = {};
  static METHODS = {"WRITE_STRING": {"visibility": "U", "parameters": {"RVAL": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}, "STRING": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}},
  "GET_NUM_WRITTEN_RAW": {"visibility": "U", "parameters": {"RVAL": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}}},
  "SET_ENCODING": {"visibility": "U", "parameters": {"RVAL": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"BOOLEAN","ddicName":"BOOLEAN","description":""});}, "is_optional": " "}, "ENCODING": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_IXML_ENCODING", RTTIName: "\\INTERFACE=IF_IXML_ENCODING"});}, "is_optional": " "}}},
  "SET_PRETTY_PRINT": {"visibility": "U", "parameters": {"PRETTY_PRINT": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});}, "is_optional": " "}}},
  "GET_PRETTY_PRINT": {"visibility": "U", "parameters": {"RVAL": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"BOOLEAN","ddicName":"BOOLEAN","description":""});}, "is_optional": " "}}},
  "GET_INDENT": {"visibility": "U", "parameters": {"RVAL": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}}},
  "SET_INDENT": {"visibility": "U", "parameters": {"INDENT": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}}}};
}
abap.Classes['IF_IXML_OSTREAM'] = if_ixml_ostream;
export {if_ixml_ostream};
//# sourceMappingURL=if_ixml_ostream.intf.mjs.map