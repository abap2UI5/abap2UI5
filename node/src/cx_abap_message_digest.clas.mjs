const {cx_static_check} = await import("./cx_static_check.clas.mjs");
const {cx_root} = await import("./cx_root.clas.mjs");
// cx_abap_message_digest.clas.abap
class cx_abap_message_digest extends cx_static_check {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CX_ABAP_MESSAGE_DIGEST';
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
abap.Classes['CX_ABAP_MESSAGE_DIGEST'] = cx_abap_message_digest;
export {cx_abap_message_digest};
//# sourceMappingURL=cx_abap_message_digest.clas.mjs.map