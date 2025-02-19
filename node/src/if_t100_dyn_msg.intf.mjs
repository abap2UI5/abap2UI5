// if_t100_dyn_msg.intf.abap
class if_t100_dyn_msg {
  static INTERNAL_TYPE = 'INTF';
  static ATTRIBUTES = {"MSGTY": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"SYMSGTY","ddicName":"SYMSGTY","description":"SYMSGTY"});}, "visibility": "U", "is_constant": " ", "is_class": " "},
  "MSGV1": {"type": () => {return new abap.types.Character(50, {"qualifiedName":"SYMSGV","ddicName":"SYMSGV","description":"SYMSGV"});}, "visibility": "U", "is_constant": " ", "is_class": " "},
  "MSGV2": {"type": () => {return new abap.types.Character(50, {"qualifiedName":"SYMSGV","ddicName":"SYMSGV","description":"SYMSGV"});}, "visibility": "U", "is_constant": " ", "is_class": " "},
  "MSGV3": {"type": () => {return new abap.types.Character(50, {"qualifiedName":"SYMSGV","ddicName":"SYMSGV","description":"SYMSGV"});}, "visibility": "U", "is_constant": " ", "is_class": " "},
  "MSGV4": {"type": () => {return new abap.types.Character(50, {"qualifiedName":"SYMSGV","ddicName":"SYMSGV","description":"SYMSGV"});}, "visibility": "U", "is_constant": " ", "is_class": " "},
  "IF_T100_MESSAGE~T100KEY": {"type": () => {return new abap.types.Structure({"msgid": new abap.types.Character(20, {}), "msgno": new abap.types.Numc({length: 3}), "attr1": new abap.types.Character(255, {}), "attr2": new abap.types.Character(255, {}), "attr3": new abap.types.Character(255, {}), "attr4": new abap.types.Character(255, {})}, "SCX_T100KEY", "SCX_T100KEY", {}, {});}, "visibility": "U", "is_constant": " ", "is_class": " "},
  "IF_T100_MESSAGE~DEFAULT_TEXTID": {"type": () => {return new abap.types.Structure({"msgid": new abap.types.Character(20, {"qualifiedName":"SYMSGID","ddicName":"SYMSGID","description":"SYMSGID"}), "msgno": new abap.types.Numc({length: 3, qualifiedName: "SYMSGNO"}), "attr1": new abap.types.String({qualifiedName: "SCX_ATTRNAME"}), "attr2": new abap.types.String({qualifiedName: "SCX_ATTRNAME"}), "attr3": new abap.types.String({qualifiedName: "SCX_ATTRNAME"}), "attr4": new abap.types.String({qualifiedName: "SCX_ATTRNAME"})}, undefined, undefined, {}, {});}, "visibility": "U", "is_constant": "X", "is_class": "X"}};
  static METHODS = {};
}
abap.Classes['IF_T100_DYN_MSG'] = if_t100_dyn_msg;
export {if_t100_dyn_msg};
//# sourceMappingURL=if_t100_dyn_msg.intf.mjs.map