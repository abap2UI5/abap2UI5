// if_ixml_encoding.intf.abap
class if_ixml_encoding {
  static INTERNAL_TYPE = 'INTF';
  static ATTRIBUTES = {"CO_NONE": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "CO_BIG_ENDIAN": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "CO_PLATFORM_ENDIAN": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": "X", "is_class": "X"}};
  static METHODS = {"GET_BYTE_ORDER": {"visibility": "U", "parameters": {"RVAL": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}}},
  "GET_CHARACTER_SET": {"visibility": "U", "parameters": {"RVAL": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}}};
}
abap.Classes['IF_IXML_ENCODING'] = if_ixml_encoding;
if_ixml_encoding.if_ixml_encoding$co_none = new abap.types.Integer({qualifiedName: "I"});
if_ixml_encoding.if_ixml_encoding$co_none.set(0);
if_ixml_encoding.if_ixml_encoding$co_big_endian = new abap.types.Integer({qualifiedName: "I"});
if_ixml_encoding.if_ixml_encoding$co_big_endian.set(1);
if_ixml_encoding.if_ixml_encoding$co_platform_endian = new abap.types.Integer({qualifiedName: "I"});
if_ixml_encoding.if_ixml_encoding$co_platform_endian.set(4);
export {if_ixml_encoding};
//# sourceMappingURL=if_ixml_encoding.intf.mjs.map