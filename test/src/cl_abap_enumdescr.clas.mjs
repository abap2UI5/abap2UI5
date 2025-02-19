const {cl_abap_elemdescr} = await import("./cl_abap_elemdescr.clas.mjs");
const {cx_root} = await import("./cx_root.clas.mjs");
// cl_abap_enumdescr.clas.abap
class cl_abap_enumdescr extends cl_abap_elemdescr {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CL_ABAP_ENUMDESCR';
  static IMPLEMENTED_INTERFACES = [];
  static ATTRIBUTES = {"MEMBERS": {"type": () => {return abap.types.TableFactory.construct(new abap.types.Structure({"name": new abap.types.Character(30, {"qualifiedName":"cl_abap_enumdescr=>member-name"}), "value": new abap.types.String({qualifiedName: "CL_ABAP_ENUMDESCR=>MEMBER-VALUE"})}, "cl_abap_enumdescr=>member", undefined, {}, {}), {"withHeader":false,"keyType":"USER","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":["NAME"]},"secondary":[]}, "cl_abap_enumdescr=>member_table");}, "visibility": "U", "is_constant": " ", "is_class": " "}};
  static METHODS = {};
  constructor() {
    super();
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
    this.members = abap.types.TableFactory.construct(new abap.types.Structure({"name": new abap.types.Character(30, {"qualifiedName":"cl_abap_enumdescr=>member-name"}), "value": new abap.types.String({qualifiedName: "CL_ABAP_ENUMDESCR=>MEMBER-VALUE"})}, "cl_abap_enumdescr=>member", undefined, {}, {}), {"withHeader":false,"keyType":"USER","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":["NAME"]},"secondary":[]}, "cl_abap_enumdescr=>member_table");
  }
  async constructor_(INPUT) {
    if (super.constructor_) { await super.constructor_(INPUT); }
    return this;
  }
}
abap.Classes['CL_ABAP_ENUMDESCR'] = cl_abap_enumdescr;
cl_abap_enumdescr.member = new abap.types.Structure({"name": new abap.types.Character(30, {"qualifiedName":"cl_abap_enumdescr=>member-name"}), "value": new abap.types.String({qualifiedName: "CL_ABAP_ENUMDESCR=>MEMBER-VALUE"})}, "cl_abap_enumdescr=>member", undefined, {}, {});
cl_abap_enumdescr.member_table = abap.types.TableFactory.construct(new abap.types.Structure({"name": new abap.types.Character(30, {"qualifiedName":"cl_abap_enumdescr=>member-name"}), "value": new abap.types.String({qualifiedName: "CL_ABAP_ENUMDESCR=>MEMBER-VALUE"})}, "cl_abap_enumdescr=>member", undefined, {}, {}), {"withHeader":false,"keyType":"USER","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":["NAME"]},"secondary":[]}, "cl_abap_enumdescr=>member_table");
export {cl_abap_enumdescr};
//# sourceMappingURL=cl_abap_enumdescr.clas.mjs.map