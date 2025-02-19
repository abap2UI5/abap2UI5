// if_ixml_stream_factory.intf.abap
class if_ixml_stream_factory {
  static INTERNAL_TYPE = 'INTF';
  static ATTRIBUTES = {};
  static METHODS = {"CREATE_OSTREAM_CSTRING": {"visibility": "U", "parameters": {"STREAM": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_IXML_OSTREAM", RTTIName: "\\INTERFACE=IF_IXML_OSTREAM"});}, "is_optional": " "}, "STRING": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}},
  "CREATE_OSTREAM_XSTRING": {"visibility": "U", "parameters": {"STREAM": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_IXML_OSTREAM", RTTIName: "\\INTERFACE=IF_IXML_OSTREAM"});}, "is_optional": " "}, "STRING": {"type": () => {return new abap.types.XString({qualifiedName: "XSTRING"});}, "is_optional": " "}}},
  "CREATE_ISTREAM_STRING": {"visibility": "U", "parameters": {"STREAM": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_IXML_ISTREAM", RTTIName: "\\INTERFACE=IF_IXML_ISTREAM"});}, "is_optional": " "}, "STRING": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}},
  "CREATE_ISTREAM_XSTRING": {"visibility": "U", "parameters": {"STREAM": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_IXML_ISTREAM", RTTIName: "\\INTERFACE=IF_IXML_ISTREAM"});}, "is_optional": " "}, "STRING": {"type": () => {return new abap.types.XString({qualifiedName: "XSTRING"});}, "is_optional": " "}}},
  "CREATE_OSTREAM_ITABLE": {"visibility": "U", "parameters": {"RVAL": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_IXML_OSTREAM", RTTIName: "\\INTERFACE=IF_IXML_OSTREAM"});}, "is_optional": " "}, "TABLE": {"type": () => {return abap.types.TableFactory.construct(new abap.types.Character(4), {"withHeader":false,"keyType":"DEFAULT"});}, "is_optional": " "}}},
  "CREATE_ISTREAM_CSTRING": {"visibility": "U", "parameters": {"RVAL": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_IXML_ISTREAM", RTTIName: "\\INTERFACE=IF_IXML_ISTREAM"});}, "is_optional": " "}, "STRING": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}}};
}
abap.Classes['IF_IXML_STREAM_FACTORY'] = if_ixml_stream_factory;
export {if_ixml_stream_factory};
//# sourceMappingURL=if_ixml_stream_factory.intf.mjs.map