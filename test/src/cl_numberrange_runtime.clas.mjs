const {cx_root} = await import("./cx_root.clas.mjs");
// cl_numberrange_runtime.clas.abap
class cl_numberrange_runtime {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CL_NUMBERRANGE_RUNTIME';
  static IMPLEMENTED_INTERFACES = [];
  static ATTRIBUTES = {};
  static METHODS = {"NUMBER_GET": {"visibility": "U", "parameters": {"NR_RANGE_NR": {"type": () => {return new abap.types.Character(2, {"qualifiedName":"cl_numberrange_runtime=>nr_interval"});}, "is_optional": " "}, "OBJECT": {"type": () => {return new abap.types.Character(10, {"qualifiedName":"cl_numberrange_runtime=>nr_object"});}, "is_optional": " "}, "NUMBER": {"type": () => {return new abap.types.Numc({length: 20, qualifiedName: "cl_numberrange_runtime=>nr_number"});}, "is_optional": " "}}}};
  constructor() {
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
  }
  async constructor_(INPUT) {
    if (super.constructor_) { await super.constructor_(INPUT); }
    return this;
  }
  async number_get(INPUT) {
    return cl_numberrange_runtime.number_get(INPUT);
  }
  static async number_get(INPUT) {
    let nr_range_nr = INPUT?.nr_range_nr;
    if (nr_range_nr?.getQualifiedName === undefined || nr_range_nr.getQualifiedName() !== "CL_NUMBERRANGE_RUNTIME=>NR_INTERVAL") { nr_range_nr = undefined; }
    if (nr_range_nr === undefined) { nr_range_nr = new abap.types.Character(2, {"qualifiedName":"cl_numberrange_runtime=>nr_interval"}).set(INPUT.nr_range_nr); }
    let object = INPUT?.object;
    if (object?.getQualifiedName === undefined || object.getQualifiedName() !== "CL_NUMBERRANGE_RUNTIME=>NR_OBJECT") { object = undefined; }
    if (object === undefined) { object = new abap.types.Character(10, {"qualifiedName":"cl_numberrange_runtime=>nr_object"}).set(INPUT.object); }
    let number = INPUT?.number || new abap.types.Numc({length: 20, qualifiedName: "cl_numberrange_runtime=>nr_number"});
    try {
      if (abap.FunctionModules['NUMBER_GET_NEXT'] === undefined && abap.Classes['CX_SY_DYN_CALL_ILLEGAL_FUNC'.trimEnd()] === undefined) { throw "CX_SY_DYN_CALL_ILLEGAL_FUNC not found"; }
      if (abap.FunctionModules['NUMBER_GET_NEXT'] === undefined) { throw new abap.Classes['CX_SY_DYN_CALL_ILLEGAL_FUNC'.trimEnd()](); }
      await abap.FunctionModules['NUMBER_GET_NEXT']({exporting: {nr_range_nr: nr_range_nr, object: object}, importing: {number: number}});
      abap.builtin.sy.get().subrc.set(0);
    } catch (e) {
      if (e.classic) {
          switch (e.classic.toUpperCase()) {
          case "INTERVAL_NOT_FOUND": abap.builtin.sy.get().subrc.set(1); break;
          case "NUMBER_RANGE_NOT_INTERN": abap.builtin.sy.get().subrc.set(2); break;
          case "OBJECT_NOT_FOUND": abap.builtin.sy.get().subrc.set(3); break;
          case "QUANTITY_IS_0": abap.builtin.sy.get().subrc.set(4); break;
          case "QUANTITY_IS_NOT_1": abap.builtin.sy.get().subrc.set(5); break;
          case "INTERVAL_OVERFLOW": abap.builtin.sy.get().subrc.set(6); break;
          case "BUFFER_OVERFLOW": abap.builtin.sy.get().subrc.set(7); break;
          default: abap.builtin.sy.get().subrc.set(8); break;
            }
        } else {
            throw e;
        }
      }
      if (abap.compare.ne(abap.builtin.sy.get().subrc, abap.IntegerFactory.get(0))) {
        return;
      }
    }
  }
  abap.Classes['CL_NUMBERRANGE_RUNTIME'] = cl_numberrange_runtime;
  cl_numberrange_runtime.nr_interval = new abap.types.Character(2, {"qualifiedName":"cl_numberrange_runtime=>nr_interval"});
  cl_numberrange_runtime.nr_object = new abap.types.Character(10, {"qualifiedName":"cl_numberrange_runtime=>nr_object"});
  cl_numberrange_runtime.nr_number = new abap.types.Numc({length: 20, qualifiedName: "cl_numberrange_runtime=>nr_number"});
export {cl_numberrange_runtime};
//# sourceMappingURL=cl_numberrange_runtime.clas.mjs.map