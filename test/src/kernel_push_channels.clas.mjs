const {cx_root} = await import("./cx_root.clas.mjs");
// kernel_push_channels.clas.abap
class kernel_push_channels {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'KERNEL_PUSH_CHANNELS';
  static IMPLEMENTED_INTERFACES = [];
  static ATTRIBUTES = {};
  static METHODS = {"WAIT": {"visibility": "U", "parameters": {"SECONDS": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}, "COND": {"type": () => {return new abap.types.Character(4);}, "is_optional": " "}}}};
  constructor() {
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
  }
  async constructor_(INPUT) {
    if (super.constructor_) { await super.constructor_(INPUT); }
    return this;
  }
  async wait(INPUT) {
    return kernel_push_channels.wait(INPUT);
  }
  static async wait(INPUT) {
    let seconds = INPUT?.seconds;
    if (seconds?.getQualifiedName === undefined || seconds.getQualifiedName() !== "I") { seconds = undefined; }
    if (seconds === undefined) { seconds = new abap.types.Integer({qualifiedName: "I"}).set(INPUT.seconds); }
    let cond = INPUT?.cond;
    let lv_seconds = new abap.types.Integer({qualifiedName: "I"});
    let lv_condition = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    lv_seconds.set(abap.operators.multiply(seconds,new abap.types.Integer().set(1000)));
    abap.statements.assert(abap.compare.gt(lv_seconds, abap.IntegerFactory.get(0)));
    const indexBackup1 = abap.builtin.sy.get().index.get();
    let unique106 = 1;
    while (abap.compare.gt(lv_seconds, abap.IntegerFactory.get(0))) {
      abap.builtin.sy.get().index.set(unique106++);
      await new Promise(resolve => setTimeout(resolve, 100));
      lv_condition = cond() ? "X" : " ";
      if (abap.compare.eq(lv_condition, abap.builtin.abap_true)) {
        abap.builtin.sy.get().subrc.set(abap.IntegerFactory.get(0));
        abap.builtin.sy.get().index.set(indexBackup1);
        return;
      }
      lv_seconds.set(abap.operators.minus(lv_seconds,abap.IntegerFactory.get(100)));
    }
    abap.builtin.sy.get().index.set(indexBackup1);
    abap.builtin.sy.get().subrc.set(abap.IntegerFactory.get(4));
  }
}
abap.Classes['KERNEL_PUSH_CHANNELS'] = kernel_push_channels;
export {kernel_push_channels};
//# sourceMappingURL=kernel_push_channels.clas.mjs.map