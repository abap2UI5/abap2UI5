const {cx_root} = await import("./cx_root.clas.mjs");
// cl_abap_regex.clas.abap
class cl_abap_regex {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CL_ABAP_REGEX';
  static IMPLEMENTED_INTERFACES = [];
  static ATTRIBUTES = {"MV_PATTERN": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "visibility": "I", "is_constant": " ", "is_class": " "},
  "MV_IGNORE_CASE": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});}, "visibility": "I", "is_constant": " ", "is_class": " "}};
  static METHODS = {"CONSTRUCTOR": {"visibility": "U", "parameters": {"PATTERN": {"type": () => {return new abap.types.Character();}, "is_optional": " "}, "IGNORE_CASE": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});}, "is_optional": " "}}},
  "CREATE_MATCHER": {"visibility": "U", "parameters": {"RO_MATCHER": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "CL_ABAP_MATCHER", RTTIName: "\\CLASS=CL_ABAP_MATCHER"});}, "is_optional": " "}, "TEXT": {"type": () => {return new abap.types.Character();}, "is_optional": " "}}},
  "CREATE_PCRE": {"visibility": "U", "parameters": {"REGEX": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "CL_ABAP_REGEX", RTTIName: "\\CLASS=CL_ABAP_REGEX"});}, "is_optional": " "}, "PATTERN": {"type": () => {return new abap.types.Character();}, "is_optional": " "}, "IGNORE_CASE": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});}, "is_optional": " "}}}};
  constructor() {
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
    this.mv_pattern = new abap.types.String({qualifiedName: "STRING"});
    this.mv_ignore_case = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
  }
  async constructor_(INPUT) {
    let pattern = INPUT?.pattern;
    let ignore_case = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    if (INPUT && INPUT.ignore_case) {ignore_case.set(INPUT.ignore_case);}
    if (INPUT === undefined || INPUT.ignore_case === undefined) {ignore_case = abap.builtin.abap_false;}
    this.mv_pattern.set(pattern);
    this.mv_ignore_case.set(ignore_case);
    return this;
  }
  async create_pcre(INPUT) {
    return cl_abap_regex.create_pcre(INPUT);
  }
  static async create_pcre(INPUT) {
    let regex = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_REGEX", RTTIName: "\\CLASS=CL_ABAP_REGEX"});
    let pattern = INPUT?.pattern;
    let ignore_case = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    if (INPUT && INPUT.ignore_case) {ignore_case.set(INPUT.ignore_case);}
    if (INPUT === undefined || INPUT.ignore_case === undefined) {ignore_case = abap.builtin.abap_false;}
    regex.set(await (new abap.Classes['CL_ABAP_REGEX']()).constructor_({pattern: pattern, ignore_case: ignore_case}));
    return regex;
  }
  async create_matcher(INPUT) {
    let ro_matcher = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_MATCHER", RTTIName: "\\CLASS=CL_ABAP_MATCHER"});
    let text = INPUT?.text;
    ro_matcher.set(await (new abap.Classes['CL_ABAP_MATCHER']()).constructor_({pattern: this.mv_pattern, ignore_case: this.mv_ignore_case, text: text}));
    return ro_matcher;
  }
}
abap.Classes['CL_ABAP_REGEX'] = cl_abap_regex;
export {cl_abap_regex};
//# sourceMappingURL=cl_abap_regex.clas.mjs.map