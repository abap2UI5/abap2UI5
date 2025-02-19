const {cx_root} = await import("./cx_root.clas.mjs");
// cl_oo_factory.clas.abap
class cl_oo_factory {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CL_OO_FACTORY';
  static IMPLEMENTED_INTERFACES = ["IF_OO_CLIF_SOURCE"];
  static ATTRIBUTES = {"MV_NAME": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "visibility": "I", "is_constant": " ", "is_class": " "}};
  static METHODS = {"CREATE_INSTANCE": {"visibility": "U", "parameters": {"RESULT": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "CL_OO_FACTORY", RTTIName: "\\CLASS=CL_OO_FACTORY"});}, "is_optional": " "}}},
  "CREATE_CLIF_SOURCE": {"visibility": "U", "parameters": {"RESULT": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_OO_CLIF_SOURCE", RTTIName: "\\INTERFACE=IF_OO_CLIF_SOURCE"});}, "is_optional": " "}, "CLIF_NAME": {"type": () => {return new abap.types.Character();}, "is_optional": " "}}}};
  constructor() {
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
    this.mv_name = new abap.types.String({qualifiedName: "STRING"});
  }
  async constructor_(INPUT) {
    if (super.constructor_) { await super.constructor_(INPUT); }
    return this;
  }
  async create_instance() {
    return cl_oo_factory.create_instance();
  }
  static async create_instance() {
    let result = new abap.types.ABAPObject({qualifiedName: "CL_OO_FACTORY", RTTIName: "\\CLASS=CL_OO_FACTORY"});
    result.set(await (new abap.Classes['CL_OO_FACTORY']()).constructor_());
    return result;
  }
  async create_clif_source(INPUT) {
    let result = new abap.types.ABAPObject({qualifiedName: "IF_OO_CLIF_SOURCE", RTTIName: "\\INTERFACE=IF_OO_CLIF_SOURCE"});
    let clif_name = INPUT?.clif_name;
    result.set(this.me);
    this.mv_name.set(abap.builtin.to_upper({val: clif_name}));
    return result;
  }
  async if_oo_clif_source$get_source(INPUT) {
    let source = INPUT?.source || abap.types.TableFactory.construct(new abap.types.String({qualifiedName: "STRING"}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"isUnique":false,"type":"STANDARD","keyFields":[],"name":"primary_key"},"secondary":[]}, "STRING_TABLE");
    let ls_data = new abap.types.Structure({"progname": new abap.types.Character(40, {}), "data": new abap.types.String({qualifiedName: "STRING"}), "unam": new abap.types.Character(12, {}), "udat": new abap.types.Date(), "utime": new abap.types.Time()}, "REPOSRC", "REPOSRC", {}, {});
    await abap.statements.select(ls_data, {select: "SELECT * FROM " + abap.buildDbTableName("reposrc") + " WHERE \"progname\" = '" + this.mv_name.get() + "' UP TO 1 ROWS", primaryKey: ["progname"]});
    abap.statements.split({source: ls_data.get().data, at: new abap.types.String().set(`\n`), table: source});
  }
}
abap.Classes['CL_OO_FACTORY'] = cl_oo_factory;
export {cl_oo_factory};
//# sourceMappingURL=cl_oo_factory.clas.mjs.map