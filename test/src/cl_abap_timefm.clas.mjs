const {cx_root} = await import("./cx_root.clas.mjs");
// cl_abap_timefm.clas.abap
class cl_abap_timefm {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CL_ABAP_TIMEFM';
  static IMPLEMENTED_INTERFACES = [];
  static ATTRIBUTES = {};
  static METHODS = {"CONV_TIME_EXT_TO_INT": {"visibility": "U", "parameters": {"TIME_EXT": {"type": () => {return new abap.types.Character();}, "is_optional": " "}, "IS_24_ALLOWED": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});}, "is_optional": " "}, "TIME_INT": {"type": () => {return new abap.types.Time({qualifiedName: "T"});}, "is_optional": " "}}},
  "CONV_TIME_INT_TO_EXT": {"visibility": "U", "parameters": {"TIME_INT": {"type": () => {return new abap.types.Time({qualifiedName: "T"});}, "is_optional": " "}, "TIME_EXT": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}},
  "GET_ENVIRONMENT_TIMEFM": {"visibility": "U", "parameters": {"TIMEFM": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"cl_abap_timefm=>ty_timefm"});}, "is_optional": " "}}}};
  constructor() {
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
  }
  async constructor_(INPUT) {
    if (super.constructor_) { await super.constructor_(INPUT); }
    return this;
  }
  async conv_time_ext_to_int(INPUT) {
    return cl_abap_timefm.conv_time_ext_to_int(INPUT);
  }
  static async conv_time_ext_to_int(INPUT) {
    let time_ext = INPUT?.time_ext;
    let is_24_allowed = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    if (INPUT && INPUT.is_24_allowed) {is_24_allowed.set(INPUT.is_24_allowed);}
    if (INPUT === undefined || INPUT.is_24_allowed === undefined) {is_24_allowed = abap.builtin.abap_false;}
    let time_int = INPUT?.time_int || new abap.types.Time({qualifiedName: "T"});
    let lv_text = new abap.types.String({qualifiedName: "STRING"});
    abap.statements.assert(abap.compare.eq(is_24_allowed, abap.builtin.abap_true));
    abap.statements.find(time_ext, {regex: new abap.types.Character(44).set('^([0-1]?[0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]$')});
    if (abap.compare.ne(abap.builtin.sy.get().subrc, abap.IntegerFactory.get(0))) {
      const unique32 = await (new abap.Classes['CX_ABAP_TIMEFM_INVALID']()).constructor_();
      unique32.EXTRA_CX = {"INTERNAL_FILENAME": "cl_abap_timefm.clas.abap","INTERNAL_LINE": 38};
      throw unique32;
    }
    lv_text.set(time_ext);
    abap.statements.replace({target: lv_text, all: true, with: new abap.types.Character(1).set(''), of: new abap.types.Character(1).set(':')});
    time_int.set(lv_text);
  }
  async conv_time_int_to_ext(INPUT) {
    return cl_abap_timefm.conv_time_int_to_ext(INPUT);
  }
  static async conv_time_int_to_ext(INPUT) {
    let time_int = INPUT?.time_int;
    if (time_int?.getQualifiedName === undefined || time_int.getQualifiedName() !== "T") { time_int = undefined; }
    if (time_int === undefined) { time_int = new abap.types.Time({qualifiedName: "T"}).set(INPUT.time_int); }
    let time_ext = INPUT?.time_ext || new abap.types.String({qualifiedName: "STRING"});
    time_ext.set(new abap.types.String().set(`${abap.templateFormatting(time_int,{"time":"iso"})}`));
  }
  async get_environment_timefm() {
    return cl_abap_timefm.get_environment_timefm();
  }
  static async get_environment_timefm() {
    let timefm = new abap.types.Character(1, {"qualifiedName":"cl_abap_timefm=>ty_timefm"});
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return timefm;
  }
}
abap.Classes['CL_ABAP_TIMEFM'] = cl_abap_timefm;
cl_abap_timefm.ty_format = new abap.types.Integer({qualifiedName: "CL_ABAP_TIMEFM=>TY_FORMAT"});
cl_abap_timefm.ty_timefm = new abap.types.Character(1, {"qualifiedName":"cl_abap_timefm=>ty_timefm"});
export {cl_abap_timefm};
//# sourceMappingURL=cl_abap_timefm.clas.mjs.map