// if_abap_conv_in.intf.abap
class if_abap_conv_in {
  static INTERNAL_TYPE = 'INTF';
  static ATTRIBUTES = {};
  static METHODS = {"CONVERT": {"visibility": "U", "parameters": {"RESULT": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "SOURCE": {"type": () => {return new abap.types.XString({qualifiedName: "XSTRING"});}, "is_optional": " "}}}};
}
abap.Classes['IF_ABAP_CONV_IN'] = if_abap_conv_in;
export {if_abap_conv_in};
//# sourceMappingURL=if_abap_conv_in.intf.mjs.map