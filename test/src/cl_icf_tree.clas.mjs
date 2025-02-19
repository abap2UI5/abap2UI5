const {cx_root} = await import("./cx_root.clas.mjs");
// cl_icf_tree.clas.abap
class cl_icf_tree {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CL_ICF_TREE';
  static IMPLEMENTED_INTERFACES = ["IF_ICF_TREE"];
  static ATTRIBUTES = {};
  static METHODS = {};
  constructor() {
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
  }
  async constructor_(INPUT) {
    if (super.constructor_) { await super.constructor_(INPUT); }
    return this;
  }
  async if_icf_tree$service_from_url(INPUT) {
    return cl_icf_tree.if_icf_tree$service_from_url(INPUT);
  }
  static async if_icf_tree$service_from_url(INPUT) {
    let url = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.url) {url.set(INPUT.url);}
    if (INPUT === undefined || INPUT.url === undefined) {url = new abap.types.Character(1).set('/');}
    let hostnumber = INPUT?.hostnumber;
    if (hostnumber?.getQualifiedName === undefined || hostnumber.getQualifiedName() !== "I") { hostnumber = undefined; }
    if (hostnumber === undefined) { hostnumber = new abap.types.Integer({qualifiedName: "I"}).set(INPUT.hostnumber); }
    let authority_check = INPUT?.authority_check || new abap.types.Character();
    if (INPUT === undefined || INPUT.authority_check === undefined) {authority_check = new abap.types.Character(1).set('X');}
    let urlsuffix = INPUT?.urlsuffix || new abap.types.String({qualifiedName: "STRING"});
    let icfnodguid = INPUT?.icfnodguid || new abap.types.Character(25, {"qualifiedName":"CHAR25","ddicName":"CHAR25","description":"CHAR25"});
    let icf_name = INPUT?.icf_name || new abap.types.Character(15, {"qualifiedName":"CHAR15","ddicName":"CHAR15","description":"CHAR15"});
    let icfactive = INPUT?.icfactive || new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    let icfaltnme = INPUT?.icfaltnme || new abap.types.String({qualifiedName: "STRING"});
    return;
    abap.builtin.sy.get().subrc.set(0);
  }
}
abap.Classes['CL_ICF_TREE'] = cl_icf_tree;
export {cl_icf_tree};
//# sourceMappingURL=cl_icf_tree.clas.mjs.map