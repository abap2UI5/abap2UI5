const {cx_root} = await import("./cx_root.clas.mjs");
// kernel_numberrange.clas.abap
class kernel_numberrange {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'KERNEL_NUMBERRANGE';
  static IMPLEMENTED_INTERFACES = [];
  static ATTRIBUTES = {"STATUS": {"type": () => {return abap.types.TableFactory.construct(new abap.types.Structure({"nr_range_nr": new abap.types.Character(2, {"qualifiedName":"cl_numberrange_runtime=>nr_interval"}), "object": new abap.types.Character(10, {"qualifiedName":"cl_numberrange_runtime=>nr_object"}), "number": new abap.types.Numc({length: 20, qualifiedName: "cl_numberrange_runtime=>nr_number"})}, "kernel_numberrange=>ty_status", undefined, {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "");}, "visibility": "I", "is_constant": " ", "is_class": "X"}};
  static METHODS = {"NUMBER_GET": {"visibility": "U", "parameters": {"NR_RANGE_NR": {"type": () => {return new abap.types.Character(2, {"qualifiedName":"cl_numberrange_runtime=>nr_interval"});}, "is_optional": " "}, "OBJECT": {"type": () => {return new abap.types.Character(10, {"qualifiedName":"cl_numberrange_runtime=>nr_object"});}, "is_optional": " "}, "NUMBER": {"type": () => {return new abap.types.Numc({length: 20, qualifiedName: "cl_numberrange_runtime=>nr_number"});}, "is_optional": " "}}}};
  constructor() {
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
    this.status = kernel_numberrange.status;
  }
  async constructor_(INPUT) {
    if (super.constructor_) { await super.constructor_(INPUT); }
    return this;
  }
  async number_get(INPUT) {
    return kernel_numberrange.number_get(INPUT);
  }
  static async number_get(INPUT) {
    let nr_range_nr = INPUT?.nr_range_nr;
    if (nr_range_nr?.getQualifiedName === undefined || nr_range_nr.getQualifiedName() !== "CL_NUMBERRANGE_RUNTIME=>NR_INTERVAL") { nr_range_nr = undefined; }
    if (nr_range_nr === undefined) { nr_range_nr = new abap.types.Character(2, {"qualifiedName":"cl_numberrange_runtime=>nr_interval"}).set(INPUT.nr_range_nr); }
    let object = INPUT?.object;
    if (object?.getQualifiedName === undefined || object.getQualifiedName() !== "CL_NUMBERRANGE_RUNTIME=>NR_OBJECT") { object = undefined; }
    if (object === undefined) { object = new abap.types.Character(10, {"qualifiedName":"cl_numberrange_runtime=>nr_object"}).set(INPUT.object); }
    let number = INPUT?.number || new abap.types.Numc({length: 20, qualifiedName: "cl_numberrange_runtime=>nr_number"});
    let fs_row_ = new abap.types.FieldSymbol(new abap.types.Structure({"nr_range_nr": new abap.types.Character(2, {"qualifiedName":"cl_numberrange_runtime=>nr_interval"}), "object": new abap.types.Character(10, {"qualifiedName":"cl_numberrange_runtime=>nr_object"}), "number": new abap.types.Numc({length: 20, qualifiedName: "cl_numberrange_runtime=>nr_number"})}, "kernel_numberrange=>ty_status", undefined, {}, {}));
    abap.statements.readTable(kernel_numberrange.status,{assigning: fs_row_,
      withKey: (i) => {return abap.compare.eq(i.nr_range_nr, nr_range_nr) && abap.compare.eq(i.object, object);},
      withKeyValue: [{key: (i) => {return i.nr_range_nr}, value: nr_range_nr},{key: (i) => {return i.object}, value: object}],
      usesTableLine: false,
      withKeySimple: {"nr_range_nr": nr_range_nr,"object": object}});
    if (abap.compare.eq(abap.builtin.sy.get().subrc, abap.IntegerFactory.get(0))) {
      fs_row_.get().number.set(abap.operators.add(fs_row_.get().number,abap.IntegerFactory.get(1)));
    } else {
      fs_row_.assign(kernel_numberrange.status.appendInitial());
      fs_row_.get().nr_range_nr.set(nr_range_nr);
      fs_row_.get().object.set(object);
      fs_row_.get().number.set(abap.IntegerFactory.get(1));
    }
    number.set(fs_row_.get().number);
  }
}
abap.Classes['KERNEL_NUMBERRANGE'] = kernel_numberrange;
kernel_numberrange.status = abap.types.TableFactory.construct(new abap.types.Structure({"nr_range_nr": new abap.types.Character(2, {"qualifiedName":"cl_numberrange_runtime=>nr_interval"}), "object": new abap.types.Character(10, {"qualifiedName":"cl_numberrange_runtime=>nr_object"}), "number": new abap.types.Numc({length: 20, qualifiedName: "cl_numberrange_runtime=>nr_number"})}, "kernel_numberrange=>ty_status", undefined, {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "");
kernel_numberrange.ty_status = new abap.types.Structure({"nr_range_nr": new abap.types.Character(2, {"qualifiedName":"cl_numberrange_runtime=>nr_interval"}), "object": new abap.types.Character(10, {"qualifiedName":"cl_numberrange_runtime=>nr_object"}), "number": new abap.types.Numc({length: 20, qualifiedName: "cl_numberrange_runtime=>nr_number"})}, "kernel_numberrange=>ty_status", undefined, {}, {});
export {kernel_numberrange};
//# sourceMappingURL=kernel_numberrange.clas.mjs.map