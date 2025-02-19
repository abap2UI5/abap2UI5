const {cx_dynamic_check} = await import("./cx_dynamic_check.clas.mjs");
const {cx_root} = await import("./cx_root.clas.mjs");
// cx_sy_move_cast_error.clas.abap
class cx_sy_move_cast_error extends cx_dynamic_check {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CX_SY_MOVE_CAST_ERROR';
  static IMPLEMENTED_INTERFACES = ["IF_MESSAGE","IF_MESSAGE"];
  static ATTRIBUTES = {};
  static METHODS = {"IF_MESSAGE~GET_TEXT": {"visibility": "U", "parameters": {}}};
  constructor() {
    super();
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
  }
  async constructor_(INPUT) {
    if (super.constructor_) { await super.constructor_(INPUT); }
    return this;
  }
  async if_message$get_text() {
    let result = new abap.types.String({qualifiedName: "STRING"});
    result.set(new abap.types.Character(36).set('Casting failed, types not compatible'));
    return result;
  }
}
abap.Classes['CX_SY_MOVE_CAST_ERROR'] = cx_sy_move_cast_error;
export {cx_sy_move_cast_error};
//# sourceMappingURL=cx_sy_move_cast_error.clas.mjs.map