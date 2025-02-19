const {cx_root} = await import("./cx_root.clas.mjs");
// cl_abap_datfm.clas.abap
class cl_abap_datfm {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CL_ABAP_DATFM';
  static IMPLEMENTED_INTERFACES = [];
  static ATTRIBUTES = {"DDMMYYYY_DOT_SEPERATED": {"type": () => {return new abap.types.Character(1, {});}, "visibility": "I", "is_constant": "X", "is_class": "X"},
  "YYYYMMDD_DOT_SEPERATED": {"type": () => {return new abap.types.Character(1, {});}, "visibility": "I", "is_constant": "X", "is_class": "X"}};
  static METHODS = {"CONV_DATE_EXT_TO_INT": {"visibility": "U", "parameters": {"IM_DATEXT": {"type": () => {return new abap.types.Character();}, "is_optional": " "}, "IM_DATFMDES": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"CHAR1","ddicName":"CHAR1","description":"CHAR1"});}, "is_optional": " "}, "EX_DATINT": {"type": () => {return new abap.types.Date({qualifiedName: "D"});}, "is_optional": " "}, "EX_DATFMUSED": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"CHAR1","ddicName":"CHAR1","description":"CHAR1"});}, "is_optional": " "}}},
  "GET_DATE_FORMAT_DES": {"visibility": "U", "parameters": {"IM_DATFM": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"CHAR1","ddicName":"CHAR1","description":"CHAR1"});}, "is_optional": " "}, "IM_LANGU": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"SPRAS","ddicName":"SPRAS","description":"SPRAS"});}, "is_optional": " "}, "IM_PLAIN": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});}, "is_optional": " "}, "IM_LONG": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});}, "is_optional": " "}, "EX_DATEFORMAT": {"type": () => {return new abap.types.Character();}, "is_optional": " "}}},
  "CONV_PERIOD_EXT_TO_INT": {"visibility": "U", "parameters": {"IM_PERIODEXT": {"type": () => {return new abap.types.Character();}, "is_optional": " "}, "EX_PERIODINT": {"type": () => {return new abap.types.Character();}, "is_optional": " "}}}};
  constructor() {
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
    this.ddmmyyyy_dot_seperated = cl_abap_datfm.ddmmyyyy_dot_seperated;
    this.yyyymmdd_dot_seperated = cl_abap_datfm.yyyymmdd_dot_seperated;
  }
  async constructor_(INPUT) {
    if (super.constructor_) { await super.constructor_(INPUT); }
    return this;
  }
  async conv_period_ext_to_int(INPUT) {
    return cl_abap_datfm.conv_period_ext_to_int(INPUT);
  }
  static async conv_period_ext_to_int(INPUT) {
    let im_periodext = INPUT?.im_periodext;
    let ex_periodint = INPUT?.ex_periodint || new abap.types.Character();
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
  }
  async conv_date_ext_to_int(INPUT) {
    return cl_abap_datfm.conv_date_ext_to_int(INPUT);
  }
  static async conv_date_ext_to_int(INPUT) {
    let im_datext = INPUT?.im_datext;
    let im_datfmdes = new abap.types.Character(1, {"qualifiedName":"CHAR1","ddicName":"CHAR1","description":"CHAR1"});
    if (INPUT && INPUT.im_datfmdes) {im_datfmdes.set(INPUT.im_datfmdes);}
    let ex_datint = INPUT?.ex_datint || new abap.types.Date({qualifiedName: "D"});
    let ex_datfmused = INPUT?.ex_datfmused || new abap.types.Character(1, {"qualifiedName":"CHAR1","ddicName":"CHAR1","description":"CHAR1"});
    let regex_ddmmyyyy_dot_seperated = new abap.types.String({qualifiedName: "STRING"});
    regex_ddmmyyyy_dot_seperated.set('^(0[0-9]|[12][0-9]|3[01])[- \\..](0[0-9]|1[012])[- \\..]\\d\\d\\d\\d$');
    let regex_yyyymmdd_dot_seperated = new abap.types.String({qualifiedName: "STRING"});
    regex_yyyymmdd_dot_seperated.set('^\\d\\d\\d\\d[- \\..](0[0-9]|1[012])[- \\..](0[0-9]|[12][0-9]|3[01])$');
    let regex_yyyymmdd_no_dot = new abap.types.String({qualifiedName: "STRING"});
    regex_yyyymmdd_no_dot.set('^(\\d{4})(0[0-9]|1[012])(0[0-9]|[12][0-9]|3[01])$');
    if (abap.compare.ne(im_datfmdes, cl_abap_datfm.ddmmyyyy_dot_seperated) && abap.compare.ne(im_datfmdes, cl_abap_datfm.yyyymmdd_dot_seperated)) {
      const unique30 = await (new abap.Classes['CX_ABAP_DATFM']()).constructor_();
      unique30.EXTRA_CX = {"INTERNAL_FILENAME": "cl_abap_datfm.clas.abap","INTERNAL_LINE": 50};
      throw unique30;
    }
    abap.statements.find(im_datext, {regex: regex_ddmmyyyy_dot_seperated, first: false});
    if (abap.compare.eq(abap.builtin.sy.get().subrc, abap.IntegerFactory.get(0))) {
      ex_datint.set(abap.operators.concat(im_datext.getOffset({offset: 6, length: 4}),abap.operators.concat(im_datext.getOffset({offset: 3, length: 2}),im_datext.getOffset({length: 2}))));
      ex_datfmused.set(cl_abap_datfm.ddmmyyyy_dot_seperated);
      return;
    }
    abap.statements.find(im_datext, {regex: regex_yyyymmdd_dot_seperated, first: false});
    if (abap.compare.eq(abap.builtin.sy.get().subrc, abap.IntegerFactory.get(0))) {
      ex_datint.set(abap.operators.concat(im_datext.getOffset({length: 4}),abap.operators.concat(im_datext.getOffset({offset: 5, length: 2}),im_datext.getOffset({offset: 8, length: 2}))));
      ex_datfmused.set(cl_abap_datfm.yyyymmdd_dot_seperated);
      return;
    }
    abap.statements.find(im_datext, {regex: regex_yyyymmdd_no_dot, first: false});
    if (abap.compare.eq(abap.builtin.sy.get().subrc, abap.IntegerFactory.get(0))) {
      ex_datint.set(im_datext);
      ex_datfmused.set(cl_abap_datfm.yyyymmdd_dot_seperated);
      return;
    }
    const unique31 = await (new abap.Classes['CX_ABAP_DATFM']()).constructor_();
    unique31.EXTRA_CX = {"INTERNAL_FILENAME": "cl_abap_datfm.clas.abap","INTERNAL_LINE": 74};
    throw unique31;
  }
  async get_date_format_des(INPUT) {
    return cl_abap_datfm.get_date_format_des(INPUT);
  }
  static async get_date_format_des(INPUT) {
    let im_datfm = new abap.types.Character(1, {"qualifiedName":"CHAR1","ddicName":"CHAR1","description":"CHAR1"});
    if (INPUT && INPUT.im_datfm) {im_datfm.set(INPUT.im_datfm);}
    let im_langu = new abap.types.Character(1, {"qualifiedName":"SPRAS","ddicName":"SPRAS","description":"SPRAS"});
    if (INPUT && INPUT.im_langu) {im_langu.set(INPUT.im_langu);}
    if (INPUT === undefined || INPUT.im_langu === undefined) {im_langu = abap.builtin.sy.get().langu;}
    let im_plain = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    if (INPUT && INPUT.im_plain) {im_plain.set(INPUT.im_plain);}
    if (INPUT === undefined || INPUT.im_plain === undefined) {im_plain = abap.builtin.abap_false;}
    let im_long = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    if (INPUT && INPUT.im_long) {im_long.set(INPUT.im_long);}
    if (INPUT === undefined || INPUT.im_long === undefined) {im_long = abap.builtin.abap_false;}
    let ex_dateformat = INPUT?.ex_dateformat || new abap.types.Character();
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
  }
}
abap.Classes['CL_ABAP_DATFM'] = cl_abap_datfm;
cl_abap_datfm.ddmmyyyy_dot_seperated = new abap.types.Character(1, {});
cl_abap_datfm.ddmmyyyy_dot_seperated.set('1');
cl_abap_datfm.yyyymmdd_dot_seperated = new abap.types.Character(1, {});
cl_abap_datfm.yyyymmdd_dot_seperated.set('4');
export {cl_abap_datfm};
//# sourceMappingURL=cl_abap_datfm.clas.mjs.map