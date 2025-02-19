const {cx_dynamic_check} = await import("./cx_dynamic_check.clas.mjs");
const {cx_root} = await import("./cx_root.clas.mjs");
// cx_sy_message_illegal_text.clas.abap
class cx_sy_message_illegal_text extends cx_dynamic_check {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CX_SY_MESSAGE_ILLEGAL_TEXT';
  static IMPLEMENTED_INTERFACES = ["IF_MESSAGE","IF_MESSAGE"];
  static ATTRIBUTES = {};
  static METHODS = {};
  constructor() {
    super();
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
  }
  async constructor_(INPUT) {
    if (super.constructor_) { await super.constructor_(INPUT); }
    return this;
  }
}
abap.Classes['CX_SY_MESSAGE_ILLEGAL_TEXT'] = cx_sy_message_illegal_text;
export {cx_sy_message_illegal_text};
//# sourceMappingURL=cx_sy_message_illegal_text.clas.mjs.map