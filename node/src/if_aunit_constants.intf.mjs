// if_aunit_constants.intf.abap
class if_aunit_constants {
  static INTERNAL_TYPE = 'INTF';
  static ATTRIBUTES = {"NO": {"type": () => {return new abap.types.Integer({qualifiedName: "INT1"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "CRITICAL": {"type": () => {return new abap.types.Integer({qualifiedName: "INT1"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "FATAL": {"type": () => {return new abap.types.Integer({qualifiedName: "INT1"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "TOLERABLE": {"type": () => {return new abap.types.Integer({qualifiedName: "INT1"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "METHOD": {"type": () => {return new abap.types.Integer({qualifiedName: "INT1"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "CLASS": {"type": () => {return new abap.types.Integer({qualifiedName: "INT1"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "SEVERITY": {"type": () => {return new abap.types.Structure({"low": new abap.types.Integer({qualifiedName: "INT1"}), "medium": new abap.types.Integer({qualifiedName: "INT1"}), "high": new abap.types.Integer({qualifiedName: "INT1"})}, undefined, undefined, {}, {});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "QUIT": {"type": () => {return new abap.types.Structure({"no": new abap.types.Integer({qualifiedName: "INT1"}), "test": new abap.types.Integer({qualifiedName: "INT1"})}, undefined, undefined, {}, {});}, "visibility": "U", "is_constant": "X", "is_class": "X"}};
  static METHODS = {};
}
abap.Classes['IF_AUNIT_CONSTANTS'] = if_aunit_constants;
if_aunit_constants.if_aunit_constants$no = new abap.types.Integer({qualifiedName: "INT1"});
if_aunit_constants.if_aunit_constants$no.set(0);
if_aunit_constants.if_aunit_constants$critical = new abap.types.Integer({qualifiedName: "INT1"});
if_aunit_constants.if_aunit_constants$critical.set(1);
if_aunit_constants.if_aunit_constants$fatal = new abap.types.Integer({qualifiedName: "INT1"});
if_aunit_constants.if_aunit_constants$fatal.set(1);
if_aunit_constants.if_aunit_constants$tolerable = new abap.types.Integer({qualifiedName: "INT1"});
if_aunit_constants.if_aunit_constants$tolerable.set(1);
if_aunit_constants.if_aunit_constants$method = new abap.types.Integer({qualifiedName: "INT1"});
if_aunit_constants.if_aunit_constants$method.set(1);
if_aunit_constants.if_aunit_constants$class = new abap.types.Integer({qualifiedName: "INT1"});
if_aunit_constants.if_aunit_constants$class.set(2);
if_aunit_constants.if_aunit_constants$severity = new abap.types.Structure({"low": new abap.types.Integer({qualifiedName: "INT1"}), "medium": new abap.types.Integer({qualifiedName: "INT1"}), "high": new abap.types.Integer({qualifiedName: "INT1"})}, undefined, undefined, {}, {});
if_aunit_constants.if_aunit_constants$severity.get().low.set(0);
if_aunit_constants.if_aunit_constants$severity.get().medium.set(1);
if_aunit_constants.if_aunit_constants$severity.get().high.set(2);
if_aunit_constants.if_aunit_constants$quit = new abap.types.Structure({"no": new abap.types.Integer({qualifiedName: "INT1"}), "test": new abap.types.Integer({qualifiedName: "INT1"})}, undefined, undefined, {}, {});
if_aunit_constants.if_aunit_constants$quit.get().no.set(0);
if_aunit_constants.if_aunit_constants$quit.get().test.set(1);
export {if_aunit_constants};
//# sourceMappingURL=if_aunit_constants.intf.mjs.map