const {cx_root} = await import("./cx_root.clas.mjs");
// kernel_lock.clas.abap
class kernel_lock {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'KERNEL_LOCK';
  static IMPLEMENTED_INTERFACES = [];
  static ATTRIBUTES = {};
  static METHODS = {"ENQUEUE": {"visibility": "U", "parameters": {"INPUT": {"type": () => {return new abap.types.Character(4);}, "is_optional": " "}}},
  "DEQUEUE": {"visibility": "U", "parameters": {"INPUT": {"type": () => {return new abap.types.Character(4);}, "is_optional": " "}}}};
  constructor() {
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
  }
  async constructor_(INPUT) {
    if (super.constructor_) { await super.constructor_(INPUT); }
    return this;
  }
  async enqueue(INPUT) {
    return kernel_lock.enqueue(INPUT);
  }
  static async enqueue(INPUT) {
    let input = INPUT?.input;
    abap.builtin.sy.get().subrc.set(abap.IntegerFactory.get(0));
    abap.builtin.sy.get().subrc.set(0);
  }
  async dequeue(INPUT) {
    return kernel_lock.dequeue(INPUT);
  }
  static async dequeue(INPUT) {
    let input = INPUT?.input;
    abap.builtin.sy.get().subrc.set(abap.IntegerFactory.get(0));
  }
}
abap.Classes['KERNEL_LOCK'] = kernel_lock;
export {kernel_lock};
//# sourceMappingURL=kernel_lock.clas.mjs.map