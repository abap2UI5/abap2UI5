const {cx_root} = await import("./cx_root.clas.mjs");
// cl_abap_matcher.clas.abap
class cl_abap_matcher {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CL_ABAP_MATCHER';
  static IMPLEMENTED_INTERFACES = [];
  static ATTRIBUTES = {"MT_MATCHES": {"type": () => {return abap.types.TableFactory.construct(new abap.types.Structure({"line": new abap.types.Integer({qualifiedName: "I"}), "offset": new abap.types.Integer({qualifiedName: "I"}), "length": new abap.types.Integer({qualifiedName: "I"}), "submatches": abap.types.TableFactory.construct(new abap.types.Structure({"offset": new abap.types.Integer({qualifiedName: "I"}), "length": new abap.types.Integer({qualifiedName: "I"})}, "SUBMATCH_RESULT", "SUBMATCH_RESULT", {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"isUnique":false,"type":"STANDARD","keyFields":[],"name":"primary_key"},"secondary":[]}, "SUBMATCH_RESULT_TAB")}, "MATCH_RESULT", "MATCH_RESULT", {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"isUnique":false,"type":"STANDARD","keyFields":[],"name":"primary_key"},"secondary":[]}, "MATCH_RESULT_TAB");}, "visibility": "I", "is_constant": " ", "is_class": " "},
  "MV_INDEX": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "I", "is_constant": " ", "is_class": " "},
  "MV_TEXT": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "visibility": "I", "is_constant": " ", "is_class": " "},
  "MV_PATTERN": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "visibility": "I", "is_constant": " ", "is_class": " "}};
  static METHODS = {"CONSTRUCTOR": {"visibility": "U", "parameters": {"PATTERN": {"type": () => {return new abap.types.Character();}, "is_optional": " "}, "IGNORE_CASE": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});}, "is_optional": " "}, "TEXT": {"type": () => {return new abap.types.Character();}, "is_optional": " "}}},
  "FIND_ALL": {"visibility": "U", "parameters": {"RT_MATCHES": {"type": () => {return abap.types.TableFactory.construct(new abap.types.Structure({"line": new abap.types.Integer({qualifiedName: "I"}), "offset": new abap.types.Integer({qualifiedName: "I"}), "length": new abap.types.Integer({qualifiedName: "I"}), "submatches": abap.types.TableFactory.construct(new abap.types.Structure({"offset": new abap.types.Integer({qualifiedName: "I"}), "length": new abap.types.Integer({qualifiedName: "I"})}, "SUBMATCH_RESULT", "SUBMATCH_RESULT", {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"isUnique":false,"type":"STANDARD","keyFields":[],"name":"primary_key"},"secondary":[]}, "SUBMATCH_RESULT_TAB")}, "MATCH_RESULT", "MATCH_RESULT", {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"isUnique":false,"type":"STANDARD","keyFields":[],"name":"primary_key"},"secondary":[]}, "MATCH_RESULT_TAB");}, "is_optional": " "}}},
  "FIND_NEXT": {"visibility": "U", "parameters": {"FOUND": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});}, "is_optional": " "}}},
  "GET_SUBMATCH": {"visibility": "U", "parameters": {"MATCH": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "INDEX": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}}},
  "GET_OFFSET": {"visibility": "U", "parameters": {"OFFSET": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}}},
  "MATCH": {"visibility": "U", "parameters": {"SUCCESS": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});}, "is_optional": " "}}},
  "GET_LENGTH": {"visibility": "U", "parameters": {"LENGTH": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}}}};
  constructor() {
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
    this.mt_matches = abap.types.TableFactory.construct(new abap.types.Structure({"line": new abap.types.Integer({qualifiedName: "I"}), "offset": new abap.types.Integer({qualifiedName: "I"}), "length": new abap.types.Integer({qualifiedName: "I"}), "submatches": abap.types.TableFactory.construct(new abap.types.Structure({"offset": new abap.types.Integer({qualifiedName: "I"}), "length": new abap.types.Integer({qualifiedName: "I"})}, "SUBMATCH_RESULT", "SUBMATCH_RESULT", {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"isUnique":false,"type":"STANDARD","keyFields":[],"name":"primary_key"},"secondary":[]}, "SUBMATCH_RESULT_TAB")}, "MATCH_RESULT", "MATCH_RESULT", {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"isUnique":false,"type":"STANDARD","keyFields":[],"name":"primary_key"},"secondary":[]}, "MATCH_RESULT_TAB");
    this.mv_index = new abap.types.Integer({qualifiedName: "I"});
    this.mv_text = new abap.types.String({qualifiedName: "STRING"});
    this.mv_pattern = new abap.types.String({qualifiedName: "STRING"});
  }
  async constructor_(INPUT) {
    let pattern = INPUT?.pattern;
    let ignore_case = INPUT?.ignore_case;
    if (ignore_case?.getQualifiedName === undefined || ignore_case.getQualifiedName() !== "ABAP_BOOL") { ignore_case = undefined; }
    if (ignore_case === undefined) { ignore_case = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}).set(INPUT.ignore_case); }
    let text = INPUT?.text;
    if (abap.compare.eq(ignore_case, abap.builtin.abap_true)) {
      abap.statements.find(text, {regex: pattern, first: false, ignoringCase: true, results: this.mt_matches});
    } else {
      abap.statements.find(text, {regex: pattern, first: false, results: this.mt_matches});
    }
    this.mv_pattern.set(pattern);
    this.mv_text.set(text);
    return this;
  }
  async match() {
    let success = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    abap.statements.find(this.mv_text, {regex: new abap.types.String().set(`^${abap.templateFormatting(this.mv_pattern)}$`), first: false});
    success.set(abap.builtin.boolc(abap.compare.eq(abap.builtin.sy.get().subrc, abap.IntegerFactory.get(0))));
    return success;
  }
  async find_all() {
    let rt_matches = abap.types.TableFactory.construct(new abap.types.Structure({"line": new abap.types.Integer({qualifiedName: "I"}), "offset": new abap.types.Integer({qualifiedName: "I"}), "length": new abap.types.Integer({qualifiedName: "I"}), "submatches": abap.types.TableFactory.construct(new abap.types.Structure({"offset": new abap.types.Integer({qualifiedName: "I"}), "length": new abap.types.Integer({qualifiedName: "I"})}, "SUBMATCH_RESULT", "SUBMATCH_RESULT", {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"isUnique":false,"type":"STANDARD","keyFields":[],"name":"primary_key"},"secondary":[]}, "SUBMATCH_RESULT_TAB")}, "MATCH_RESULT", "MATCH_RESULT", {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"isUnique":false,"type":"STANDARD","keyFields":[],"name":"primary_key"},"secondary":[]}, "MATCH_RESULT_TAB");
    rt_matches.set(this.mt_matches);
    return rt_matches;
  }
  async find_next() {
    let found = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    this.mv_index.set(abap.operators.add(this.mv_index,abap.IntegerFactory.get(1)));
    abap.statements.readTable(this.mt_matches,{index: this.mv_index});
    found.set(abap.builtin.boolc(abap.compare.eq(abap.builtin.sy.get().subrc, abap.IntegerFactory.get(0))));
    return found;
  }
  async get_submatch(INPUT) {
    let match = new abap.types.String({qualifiedName: "STRING"});
    let index = INPUT?.index;
    if (index?.getQualifiedName === undefined || index.getQualifiedName() !== "I") { index = undefined; }
    if (index === undefined) { index = new abap.types.Integer({qualifiedName: "I"}).set(INPUT.index); }
    let ls_match = new abap.types.Structure({"line": new abap.types.Integer({qualifiedName: "I"}), "offset": new abap.types.Integer({qualifiedName: "I"}), "length": new abap.types.Integer({qualifiedName: "I"}), "submatches": abap.types.TableFactory.construct(new abap.types.Structure({"offset": new abap.types.Integer({qualifiedName: "I"}), "length": new abap.types.Integer({qualifiedName: "I"})}, "SUBMATCH_RESULT", "SUBMATCH_RESULT", {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"isUnique":false,"type":"STANDARD","keyFields":[],"name":"primary_key"},"secondary":[]}, "SUBMATCH_RESULT_TAB")}, "MATCH_RESULT", "MATCH_RESULT", {}, {});
    let ls_submatch = new abap.types.Structure({"offset": new abap.types.Integer({qualifiedName: "I"}), "length": new abap.types.Integer({qualifiedName: "I"})}, "SUBMATCH_RESULT", "SUBMATCH_RESULT", {}, {});
    abap.statements.readTable(this.mt_matches,{index: this.mv_index,
      into: ls_match});
    abap.statements.readTable(ls_match.get().submatches,{index: index,
      into: ls_submatch});
    if (abap.compare.eq(abap.builtin.sy.get().subrc, abap.IntegerFactory.get(0))) {
      match.set(this.mv_text.getOffset({offset: ls_submatch.get().offset, length: ls_submatch.get().length}));
    }
    return match;
  }
  async get_offset() {
    let offset = new abap.types.Integer({qualifiedName: "I"});
    let ls_match = new abap.types.Structure({"line": new abap.types.Integer({qualifiedName: "I"}), "offset": new abap.types.Integer({qualifiedName: "I"}), "length": new abap.types.Integer({qualifiedName: "I"}), "submatches": abap.types.TableFactory.construct(new abap.types.Structure({"offset": new abap.types.Integer({qualifiedName: "I"}), "length": new abap.types.Integer({qualifiedName: "I"})}, "SUBMATCH_RESULT", "SUBMATCH_RESULT", {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"isUnique":false,"type":"STANDARD","keyFields":[],"name":"primary_key"},"secondary":[]}, "SUBMATCH_RESULT_TAB")}, "MATCH_RESULT", "MATCH_RESULT", {}, {});
    abap.statements.readTable(this.mt_matches,{index: this.mv_index,
      into: ls_match});
    offset.set(ls_match.get().offset);
    return offset;
  }
  async get_length() {
    let length = new abap.types.Integer({qualifiedName: "I"});
    let ls_match = new abap.types.Structure({"line": new abap.types.Integer({qualifiedName: "I"}), "offset": new abap.types.Integer({qualifiedName: "I"}), "length": new abap.types.Integer({qualifiedName: "I"}), "submatches": abap.types.TableFactory.construct(new abap.types.Structure({"offset": new abap.types.Integer({qualifiedName: "I"}), "length": new abap.types.Integer({qualifiedName: "I"})}, "SUBMATCH_RESULT", "SUBMATCH_RESULT", {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"isUnique":false,"type":"STANDARD","keyFields":[],"name":"primary_key"},"secondary":[]}, "SUBMATCH_RESULT_TAB")}, "MATCH_RESULT", "MATCH_RESULT", {}, {});
    abap.statements.readTable(this.mt_matches,{index: this.mv_index,
      into: ls_match});
    length.set(ls_match.get().length);
    return length;
  }
}
abap.Classes['CL_ABAP_MATCHER'] = cl_abap_matcher;
export {cl_abap_matcher};
//# sourceMappingURL=cl_abap_matcher.clas.mjs.map