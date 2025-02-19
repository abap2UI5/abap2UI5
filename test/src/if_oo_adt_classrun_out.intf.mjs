// if_oo_adt_classrun_out.intf.abap
class if_oo_adt_classrun_out {
  static INTERNAL_TYPE = 'INTF';
  static ATTRIBUTES = {};
  static METHODS = {"WRITE": {"visibility": "U", "parameters": {"OUTPUT": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_OO_ADT_CLASSRUN_OUT", RTTIName: "\\INTERFACE=IF_OO_ADT_CLASSRUN_OUT"});}, "is_optional": " "}, "DATA": {"type": () => {return new abap.types.Character(4);}, "is_optional": " "}, "NAME": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}},
  "GET": {"visibility": "U", "parameters": {"OUTPUT": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "DATA": {"type": () => {return new abap.types.Character(4);}, "is_optional": " "}, "NAME": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}}};
}
abap.Classes['IF_OO_ADT_CLASSRUN_OUT'] = if_oo_adt_classrun_out;
export {if_oo_adt_classrun_out};
//# sourceMappingURL=if_oo_adt_classrun_out.intf.mjs.map