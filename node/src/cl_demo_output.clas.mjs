const {cx_root} = await import("./cx_root.clas.mjs");
// cl_demo_output.clas.abap
class cl_demo_output {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CL_DEMO_OUTPUT';
  static IMPLEMENTED_INTERFACES = ["IF_DEMO_OUTPUT"];
  static ATTRIBUTES = {};
  static METHODS = {"WRITE": {"visibility": "U", "parameters": {"DATA": {"type": () => {return new abap.types.Character(4);}, "is_optional": " "}, "NAME": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}},
  "CLEAR": {"visibility": "U", "parameters": {}},
  "NEW": {"visibility": "U", "parameters": {"OUTPUT": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_DEMO_OUTPUT", RTTIName: "\\INTERFACE=IF_DEMO_OUTPUT"});}, "is_optional": " "}}},
  "DISPLAY": {"visibility": "U", "parameters": {"DATA": {"type": () => {return new abap.types.Character(4);}, "is_optional": " "}, "NAME": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}}};
  constructor() {
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
  }
  async constructor_(INPUT) {
    if (super.constructor_) { await super.constructor_(INPUT); }
    return this;
  }
  async write(INPUT) {
    return cl_demo_output.write(INPUT);
  }
  static async write(INPUT) {
    let data = INPUT?.data;
    let name = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.name) {name.set(INPUT.name);}
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(13).set('not supported')));
  }
  async if_demo_output$write(INPUT) {
    let data = INPUT?.data;
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(13).set('not supported')));
  }
  async new() {
    return cl_demo_output.new();
  }
  static async new() {
    let output = new abap.types.ABAPObject({qualifiedName: "IF_DEMO_OUTPUT", RTTIName: "\\INTERFACE=IF_DEMO_OUTPUT"});
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(13).set('not supported')));
    return output;
  }
  async clear() {
    return cl_demo_output.clear();
  }
  static async clear() {
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(13).set('not supported')));
  }
  async display(INPUT) {
    return cl_demo_output.display(INPUT);
  }
  static async display(INPUT) {
    let data = INPUT?.data || new abap.types.Character(4);
    let name = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.name) {name.set(INPUT.name);}
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(13).set('not supported')));
  }
  async if_demo_output$display() {
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(13).set('not supported')));
  }
}
abap.Classes['CL_DEMO_OUTPUT'] = cl_demo_output;
export {cl_demo_output};
//# sourceMappingURL=cl_demo_output.clas.mjs.map