// if_oo_adt_classrun.intf.abap
class if_oo_adt_classrun {
  static INTERNAL_TYPE = 'INTF';
  static ATTRIBUTES = {};
  static METHODS = {"MAIN": {"visibility": "U", "parameters": {"OUT": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_OO_ADT_CLASSRUN_OUT", RTTIName: "\\INTERFACE=IF_OO_ADT_CLASSRUN_OUT"});}, "is_optional": " "}}}};
}
abap.Classes['IF_OO_ADT_CLASSRUN'] = if_oo_adt_classrun;
export {if_oo_adt_classrun};
//# sourceMappingURL=if_oo_adt_classrun.intf.mjs.map