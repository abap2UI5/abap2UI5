const {cx_root} = await import("./cx_root.clas.mjs");
// cl_bcs_convert.clas.abap
class cl_bcs_convert {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CL_BCS_CONVERT';
  static IMPLEMENTED_INTERFACES = [];
  static ATTRIBUTES = {};
  static METHODS = {"STRING_TO_SOLI": {"visibility": "U", "parameters": {"ET_SOLI": {"type": () => {return abap.types.TableFactory.construct(new abap.types.Structure({"line": new abap.types.Character(255, {"qualifiedName":"SO_TEXT255","ddicName":"SO_TEXT255","description":"SO_TEXT255"})}, "SOLI", "SOLI", {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"isUnique":false,"type":"STANDARD","keyFields":[],"name":"primary_key"},"secondary":[]}, "SOLI_TAB");}, "is_optional": " "}, "IV_STRING": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}},
  "XSTRING_TO_SOLIX": {"visibility": "U", "parameters": {"ET_SOLIX": {"type": () => {return abap.types.TableFactory.construct(new abap.types.Structure({"line": new abap.types.Hex({length: 255})}, "SOLIX", "SOLIX", {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"isUnique":false,"type":"STANDARD","keyFields":[],"name":"primary_key"},"secondary":[]}, "SOLIX_TAB");}, "is_optional": " "}, "IV_XSTRING": {"type": () => {return new abap.types.XString({qualifiedName: "XSTRING"});}, "is_optional": " "}}},
  "RAW_TO_STRING": {"visibility": "U", "parameters": {"EV_STRING": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "IT_SOLI": {"type": () => {return abap.types.TableFactory.construct(new abap.types.Structure({"line": new abap.types.Character(255, {"qualifiedName":"SO_TEXT255","ddicName":"SO_TEXT255","description":"SO_TEXT255"})}, "SOLI", "SOLI", {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"isUnique":false,"type":"STANDARD","keyFields":[],"name":"primary_key"},"secondary":[]}, "SOLI_TAB");}, "is_optional": " "}}},
  "SOLIX_TO_XSTRING": {"visibility": "U", "parameters": {"EV_XSTRING": {"type": () => {return new abap.types.XString({qualifiedName: "XSTRING"});}, "is_optional": " "}, "IT_SOLIX": {"type": () => {return abap.types.TableFactory.construct(new abap.types.Structure({"line": new abap.types.Hex({length: 255})}, "SOLIX", "SOLIX", {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"isUnique":false,"type":"STANDARD","keyFields":[],"name":"primary_key"},"secondary":[]}, "SOLIX_TAB");}, "is_optional": " "}, "IV_SIZE": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}}}};
  constructor() {
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
  }
  async constructor_(INPUT) {
    if (super.constructor_) { await super.constructor_(INPUT); }
    return this;
  }
  async string_to_soli(INPUT) {
    return cl_bcs_convert.string_to_soli(INPUT);
  }
  static async string_to_soli(INPUT) {
    let et_soli = abap.types.TableFactory.construct(new abap.types.Structure({"line": new abap.types.Character(255, {"qualifiedName":"SO_TEXT255","ddicName":"SO_TEXT255","description":"SO_TEXT255"})}, "SOLI", "SOLI", {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"isUnique":false,"type":"STANDARD","keyFields":[],"name":"primary_key"},"secondary":[]}, "SOLI_TAB");
    let iv_string = INPUT?.iv_string;
    if (iv_string?.getQualifiedName === undefined || iv_string.getQualifiedName() !== "STRING") { iv_string = undefined; }
    if (iv_string === undefined) { iv_string = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.iv_string); }
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return et_soli;
  }
  async solix_to_xstring(INPUT) {
    return cl_bcs_convert.solix_to_xstring(INPUT);
  }
  static async solix_to_xstring(INPUT) {
    let ev_xstring = new abap.types.XString({qualifiedName: "XSTRING"});
    let it_solix = INPUT?.it_solix;
    if (it_solix?.getQualifiedName === undefined || it_solix.getQualifiedName() !== "SOLIX_TAB") { it_solix = undefined; }
    if (it_solix === undefined) { it_solix = abap.types.TableFactory.construct(new abap.types.Structure({"line": new abap.types.Hex({length: 255})}, "SOLIX", "SOLIX", {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"isUnique":false,"type":"STANDARD","keyFields":[],"name":"primary_key"},"secondary":[]}, "SOLIX_TAB").set(INPUT.it_solix); }
    let iv_size = new abap.types.Integer({qualifiedName: "I"});
    if (INPUT && INPUT.iv_size) {iv_size.set(INPUT.iv_size);}
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return ev_xstring;
  }
  async xstring_to_solix(INPUT) {
    return cl_bcs_convert.xstring_to_solix(INPUT);
  }
  static async xstring_to_solix(INPUT) {
    let et_solix = abap.types.TableFactory.construct(new abap.types.Structure({"line": new abap.types.Hex({length: 255})}, "SOLIX", "SOLIX", {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"isUnique":false,"type":"STANDARD","keyFields":[],"name":"primary_key"},"secondary":[]}, "SOLIX_TAB");
    let iv_xstring = INPUT?.iv_xstring;
    if (iv_xstring?.getQualifiedName === undefined || iv_xstring.getQualifiedName() !== "XSTRING") { iv_xstring = undefined; }
    if (iv_xstring === undefined) { iv_xstring = new abap.types.XString({qualifiedName: "XSTRING"}).set(INPUT.iv_xstring); }
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return et_solix;
  }
  async raw_to_string(INPUT) {
    return cl_bcs_convert.raw_to_string(INPUT);
  }
  static async raw_to_string(INPUT) {
    let ev_string = new abap.types.String({qualifiedName: "STRING"});
    let it_soli = INPUT?.it_soli;
    if (it_soli?.getQualifiedName === undefined || it_soli.getQualifiedName() !== "SOLI_TAB") { it_soli = undefined; }
    if (it_soli === undefined) { it_soli = abap.types.TableFactory.construct(new abap.types.Structure({"line": new abap.types.Character(255, {"qualifiedName":"SO_TEXT255","ddicName":"SO_TEXT255","description":"SO_TEXT255"})}, "SOLI", "SOLI", {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"isUnique":false,"type":"STANDARD","keyFields":[],"name":"primary_key"},"secondary":[]}, "SOLI_TAB").set(INPUT.it_soli); }
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return ev_string;
  }
}
abap.Classes['CL_BCS_CONVERT'] = cl_bcs_convert;
export {cl_bcs_convert};
//# sourceMappingURL=cl_bcs_convert.clas.mjs.map