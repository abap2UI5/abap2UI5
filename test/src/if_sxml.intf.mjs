// if_sxml.intf.abap
class if_sxml {
  static INTERNAL_TYPE = 'INTF';
  static ATTRIBUTES = {"CO_XT_XML10": {"type": () => {return new abap.types.Integer({qualifiedName: "IF_SXML=>XML_STREAM_TYPE"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "CO_XT_BINARY": {"type": () => {return new abap.types.Integer({qualifiedName: "IF_SXML=>XML_STREAM_TYPE"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "CO_XT_XOP": {"type": () => {return new abap.types.Integer({qualifiedName: "IF_SXML=>XML_STREAM_TYPE"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "CO_XT_JSON": {"type": () => {return new abap.types.Integer({qualifiedName: "IF_SXML=>XML_STREAM_TYPE"});}, "visibility": "U", "is_constant": "X", "is_class": "X"}};
  static METHODS = {};
}
abap.Classes['IF_SXML'] = if_sxml;
if_sxml.if_sxml$co_xt_xml10 = new abap.types.Integer({qualifiedName: "IF_SXML=>XML_STREAM_TYPE"});
if_sxml.if_sxml$co_xt_xml10.set(1);
if_sxml.if_sxml$co_xt_binary = new abap.types.Integer({qualifiedName: "IF_SXML=>XML_STREAM_TYPE"});
if_sxml.if_sxml$co_xt_binary.set(2);
if_sxml.if_sxml$co_xt_xop = new abap.types.Integer({qualifiedName: "IF_SXML=>XML_STREAM_TYPE"});
if_sxml.if_sxml$co_xt_xop.set(3);
if_sxml.if_sxml$co_xt_json = new abap.types.Integer({qualifiedName: "IF_SXML=>XML_STREAM_TYPE"});
if_sxml.if_sxml$co_xt_json.set(4);
if_sxml.xml_stream_type = new abap.types.Integer({qualifiedName: "IF_SXML=>XML_STREAM_TYPE"});
export {if_sxml};
//# sourceMappingURL=if_sxml.intf.mjs.map