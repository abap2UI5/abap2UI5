// if_ixml_renderer.intf.abap
class if_ixml_renderer {
  static INTERNAL_TYPE = 'INTF';
  static ATTRIBUTES = {};
  static METHODS = {"RENDER": {"visibility": "U", "parameters": {"RVAL": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}}},
  "SET_NORMALIZING": {"visibility": "U", "parameters": {"NORMAL": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});}, "is_optional": " "}}}};
}
abap.Classes['IF_IXML_RENDERER'] = if_ixml_renderer;
export {if_ixml_renderer};
//# sourceMappingURL=if_ixml_renderer.intf.mjs.map