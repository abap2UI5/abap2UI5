// if_abap_conv_out.intf.abap
class if_abap_conv_out {
  static INTERNAL_TYPE = 'INTF';
  static ATTRIBUTES = {};
  static METHODS = {"CONVERT": {"visibility": "U", "parameters": {"RESULT": {"type": () => {return new abap.types.XString({qualifiedName: "XSTRING"});}, "is_optional": " "}, "SOURCE": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}}};
}
abap.Classes['IF_ABAP_CONV_OUT'] = if_abap_conv_out;
export {if_abap_conv_out};
//# sourceMappingURL=if_abap_conv_out.intf.mjs.map