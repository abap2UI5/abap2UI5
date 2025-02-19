// if_ixml.intf.abap
class if_ixml {
  static INTERNAL_TYPE = 'INTF';
  static ATTRIBUTES = {};
  static METHODS = {"CREATE_DOCUMENT": {"visibility": "U", "parameters": {"DOC": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_IXML_DOCUMENT", RTTIName: "\\INTERFACE=IF_IXML_DOCUMENT"});}, "is_optional": " "}}},
  "CREATE_STREAM_FACTORY": {"visibility": "U", "parameters": {"STREAM": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_IXML_STREAM_FACTORY", RTTIName: "\\INTERFACE=IF_IXML_STREAM_FACTORY"});}, "is_optional": " "}}},
  "CREATE_RENDERER": {"visibility": "U", "parameters": {"RENDERER": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_IXML_RENDERER", RTTIName: "\\INTERFACE=IF_IXML_RENDERER"});}, "is_optional": " "}, "OSTREAM": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_IXML_OSTREAM", RTTIName: "\\INTERFACE=IF_IXML_OSTREAM"});}, "is_optional": " "}, "DOCUMENT": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_IXML_DOCUMENT", RTTIName: "\\INTERFACE=IF_IXML_DOCUMENT"});}, "is_optional": " "}}},
  "CREATE_PARSER": {"visibility": "U", "parameters": {"PARSER": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_IXML_PARSER", RTTIName: "\\INTERFACE=IF_IXML_PARSER"});}, "is_optional": " "}, "STREAM_FACTORY": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_IXML_STREAM_FACTORY", RTTIName: "\\INTERFACE=IF_IXML_STREAM_FACTORY"});}, "is_optional": " "}, "ISTREAM": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_IXML_ISTREAM", RTTIName: "\\INTERFACE=IF_IXML_ISTREAM"});}, "is_optional": " "}, "DOCUMENT": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_IXML_DOCUMENT", RTTIName: "\\INTERFACE=IF_IXML_DOCUMENT"});}, "is_optional": " "}}},
  "CREATE_ENCODING": {"visibility": "U", "parameters": {"RVAL": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_IXML_ENCODING", RTTIName: "\\INTERFACE=IF_IXML_ENCODING"});}, "is_optional": " "}, "BYTE_ORDER": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}, "CHARACTER_SET": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}}};
}
abap.Classes['IF_IXML'] = if_ixml;
export {if_ixml};
//# sourceMappingURL=if_ixml.intf.mjs.map