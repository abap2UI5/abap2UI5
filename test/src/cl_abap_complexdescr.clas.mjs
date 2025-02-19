const {cl_abap_datadescr} = await import("./cl_abap_datadescr.clas.mjs");
const {cx_root} = await import("./cx_root.clas.mjs");
// cl_abap_complexdescr.clas.abap
class cl_abap_complexdescr extends cl_abap_datadescr {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CL_ABAP_COMPLEXDESCR';
  static IMPLEMENTED_INTERFACES = [];
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
abap.Classes['CL_ABAP_COMPLEXDESCR'] = cl_abap_complexdescr;
export {cl_abap_complexdescr};
//# sourceMappingURL=cl_abap_complexdescr.clas.mjs.map