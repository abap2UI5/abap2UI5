// if_t100_message.intf.abap
class if_t100_message {
  static INTERNAL_TYPE = 'INTF';
  static ATTRIBUTES = {"T100KEY": {"type": () => {return new abap.types.Structure({"msgid": new abap.types.Character(20, {}), "msgno": new abap.types.Numc({length: 3}), "attr1": new abap.types.Character(255, {}), "attr2": new abap.types.Character(255, {}), "attr3": new abap.types.Character(255, {}), "attr4": new abap.types.Character(255, {})}, "SCX_T100KEY", "SCX_T100KEY", {}, {});}, "visibility": "U", "is_constant": " ", "is_class": " "},
  "DEFAULT_TEXTID": {"type": () => {return new abap.types.Structure({"msgid": new abap.types.Character(20, {"qualifiedName":"SYMSGID","ddicName":"SYMSGID","description":"SYMSGID"}), "msgno": new abap.types.Numc({length: 3, qualifiedName: "SYMSGNO"}), "attr1": new abap.types.String({qualifiedName: "SCX_ATTRNAME"}), "attr2": new abap.types.String({qualifiedName: "SCX_ATTRNAME"}), "attr3": new abap.types.String({qualifiedName: "SCX_ATTRNAME"}), "attr4": new abap.types.String({qualifiedName: "SCX_ATTRNAME"})}, undefined, undefined, {}, {});}, "visibility": "U", "is_constant": "X", "is_class": "X"}};
  static METHODS = {};
}
abap.Classes['IF_T100_MESSAGE'] = if_t100_message;
if_t100_message.if_t100_message$default_textid = new abap.types.Structure({"msgid": new abap.types.Character(20, {"qualifiedName":"SYMSGID","ddicName":"SYMSGID","description":"SYMSGID"}), "msgno": new abap.types.Numc({length: 3, qualifiedName: "SYMSGNO"}), "attr1": new abap.types.String({qualifiedName: "SCX_ATTRNAME"}), "attr2": new abap.types.String({qualifiedName: "SCX_ATTRNAME"}), "attr3": new abap.types.String({qualifiedName: "SCX_ATTRNAME"}), "attr4": new abap.types.String({qualifiedName: "SCX_ATTRNAME"})}, undefined, undefined, {}, {});
if_t100_message.if_t100_message$default_textid.get().msgid.set('AB');
if_t100_message.if_t100_message$default_textid.get().msgno.set('123');
if_t100_message.if_t100_message$default_textid.get().attr1.set('');
if_t100_message.if_t100_message$default_textid.get().attr2.set('');
if_t100_message.if_t100_message$default_textid.get().attr3.set('');
if_t100_message.if_t100_message$default_textid.get().attr4.set('');
export {if_t100_message};
//# sourceMappingURL=if_t100_message.intf.mjs.map