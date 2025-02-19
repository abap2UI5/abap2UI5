// if_sxml_writer.intf.abap
class if_sxml_writer {
  static INTERNAL_TYPE = 'INTF';
  static ATTRIBUTES = {"CO_OPT_NORMALIZING": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "CO_OPT_NO_EMPTY": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "CO_OPT_IGNORE_CONV_ERRROS": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "CO_OPT_LINEBREAKS": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "CO_OPT_INDENT": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "CO_OPT_ILLEGAL_CHAR_REJECT": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "CO_OPT_ILLEGAL_CHAR_REPLACE": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "CO_OPT_ILLEGAL_CHAR_REPLACE_BY": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "CO_OPT_BASE64_NO_LF": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": "X", "is_class": "X"}};
  static METHODS = {"OPEN_ELEMENT": {"visibility": "U", "parameters": {"NAME": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "NSURI": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "PREFIX": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}},
  "CLOSE_ELEMENT": {"visibility": "U", "parameters": {}},
  "NEW_CLOSE_ELEMENT": {"visibility": "U", "parameters": {"ELEMENT": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_SXML_CLOSE_ELEMENT", RTTIName: "\\INTERFACE=IF_SXML_CLOSE_ELEMENT"});}, "is_optional": " "}}},
  "WRITE_ATTRIBUTE": {"visibility": "U", "parameters": {"NAME": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "NSURI": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "PREFIX": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "VALUE": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}},
  "WRITE_ATTRIBUTE_RAW": {"visibility": "U", "parameters": {"NAME": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "NSURI": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "PREFIX": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "VALUE": {"type": () => {return new abap.types.XString({qualifiedName: "XSTRING"});}, "is_optional": " "}}},
  "WRITE_VALUE": {"visibility": "U", "parameters": {"VALUE": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}},
  "SET_OPTION": {"visibility": "U", "parameters": {"OPTION": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}, "VALUE": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});}, "is_optional": " "}}},
  "NEW_OPEN_ELEMENT": {"visibility": "U", "parameters": {"ELEMENT": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_SXML_OPEN_ELEMENT", RTTIName: "\\INTERFACE=IF_SXML_OPEN_ELEMENT"});}, "is_optional": " "}, "NAME": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "NSURI": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "PREFIX": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}},
  "NEW_VALUE": {"visibility": "U", "parameters": {"VALUE": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_SXML_VALUE_NODE", RTTIName: "\\INTERFACE=IF_SXML_VALUE_NODE"});}, "is_optional": " "}}},
  "WRITE_NAMESPACE_DECLARATION": {"visibility": "U", "parameters": {"NSURI": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "PREFIX": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}},
  "WRITE_NODE": {"visibility": "U", "parameters": {"NODE": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_SXML_NODE", RTTIName: "\\INTERFACE=IF_SXML_NODE"});}, "is_optional": " "}}},
  "WRITE_VALUE_RAW": {"visibility": "U", "parameters": {"VALUE": {"type": () => {return new abap.types.XString({qualifiedName: "XSTRING"});}, "is_optional": " "}}}};
}
abap.Classes['IF_SXML_WRITER'] = if_sxml_writer;
if_sxml_writer.if_sxml_writer$co_opt_normalizing = new abap.types.Integer({qualifiedName: "I"});
if_sxml_writer.if_sxml_writer$co_opt_normalizing.set(1);
if_sxml_writer.if_sxml_writer$co_opt_no_empty = new abap.types.Integer({qualifiedName: "I"});
if_sxml_writer.if_sxml_writer$co_opt_no_empty.set(2);
if_sxml_writer.if_sxml_writer$co_opt_ignore_conv_errros = new abap.types.Integer({qualifiedName: "I"});
if_sxml_writer.if_sxml_writer$co_opt_ignore_conv_errros.set(3);
if_sxml_writer.if_sxml_writer$co_opt_linebreaks = new abap.types.Integer({qualifiedName: "I"});
if_sxml_writer.if_sxml_writer$co_opt_linebreaks.set(4);
if_sxml_writer.if_sxml_writer$co_opt_indent = new abap.types.Integer({qualifiedName: "I"});
if_sxml_writer.if_sxml_writer$co_opt_indent.set(5);
if_sxml_writer.if_sxml_writer$co_opt_illegal_char_reject = new abap.types.Integer({qualifiedName: "I"});
if_sxml_writer.if_sxml_writer$co_opt_illegal_char_reject.set(6);
if_sxml_writer.if_sxml_writer$co_opt_illegal_char_replace = new abap.types.Integer({qualifiedName: "I"});
if_sxml_writer.if_sxml_writer$co_opt_illegal_char_replace.set(7);
if_sxml_writer.if_sxml_writer$co_opt_illegal_char_replace_by = new abap.types.Integer({qualifiedName: "I"});
if_sxml_writer.if_sxml_writer$co_opt_illegal_char_replace_by.set(8);
if_sxml_writer.if_sxml_writer$co_opt_base64_no_lf = new abap.types.Integer({qualifiedName: "I"});
if_sxml_writer.if_sxml_writer$co_opt_base64_no_lf.set(9);
export {if_sxml_writer};
//# sourceMappingURL=if_sxml_writer.intf.mjs.map