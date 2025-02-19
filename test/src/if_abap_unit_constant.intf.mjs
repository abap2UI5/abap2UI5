// if_abap_unit_constant.intf.abap
class if_abap_unit_constant {
  static INTERNAL_TYPE = 'INTF';
  static ATTRIBUTES = {"SEVERITY": {"type": () => {return new abap.types.Structure({"low": new abap.types.Integer({qualifiedName: "INT1"}), "medium": new abap.types.Integer({qualifiedName: "INT1"}), "high": new abap.types.Integer({qualifiedName: "INT1"})}, undefined, undefined, {}, {});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "QUIT": {"type": () => {return new abap.types.Structure({"test": new abap.types.Integer({qualifiedName: "INT1"}), "no": new abap.types.Integer({qualifiedName: "INT1"})}, undefined, undefined, {}, {});}, "visibility": "U", "is_constant": "X", "is_class": "X"}};
  static METHODS = {};
}
abap.Classes['IF_ABAP_UNIT_CONSTANT'] = if_abap_unit_constant;
if_abap_unit_constant.if_abap_unit_constant$severity = new abap.types.Structure({"low": new abap.types.Integer({qualifiedName: "INT1"}), "medium": new abap.types.Integer({qualifiedName: "INT1"}), "high": new abap.types.Integer({qualifiedName: "INT1"})}, undefined, undefined, {}, {});
if_abap_unit_constant.if_abap_unit_constant$severity.get().low.set(0);
if_abap_unit_constant.if_abap_unit_constant$severity.get().medium.set(1);
if_abap_unit_constant.if_abap_unit_constant$severity.get().high.set(2);
if_abap_unit_constant.if_abap_unit_constant$quit = new abap.types.Structure({"test": new abap.types.Integer({qualifiedName: "INT1"}), "no": new abap.types.Integer({qualifiedName: "INT1"})}, undefined, undefined, {}, {});
if_abap_unit_constant.if_abap_unit_constant$quit.get().test.set(1);
if_abap_unit_constant.if_abap_unit_constant$quit.get().no.set(5);
export {if_abap_unit_constant};
//# sourceMappingURL=if_abap_unit_constant.intf.mjs.map