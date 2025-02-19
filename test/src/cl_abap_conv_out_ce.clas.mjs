const {cx_root} = await import("./cx_root.clas.mjs");
// cl_abap_conv_out_ce.clas.abap
class cl_abap_conv_out_ce {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CL_ABAP_CONV_OUT_CE';
  static IMPLEMENTED_INTERFACES = [];
  static ATTRIBUTES = {"MV_JS_ENCODING": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "visibility": "I", "is_constant": " ", "is_class": " "},
  "MV_BUFFER": {"type": () => {return new abap.types.XString({qualifiedName: "XSTRING"});}, "visibility": "I", "is_constant": " ", "is_class": " "}};
  static METHODS = {"CREATE": {"visibility": "U", "parameters": {"RET": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "CL_ABAP_CONV_OUT_CE", RTTIName: "\\CLASS=CL_ABAP_CONV_OUT_CE"});}, "is_optional": " "}, "ENCODING": {"type": () => {return new abap.types.Character(20, {"qualifiedName":"abap_encoding"});}, "is_optional": " "}, "IGNORE_CERR": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});}, "is_optional": " "}, "ENDIAN": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "REPLACEMENT": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}},
  "UCCPI": {"visibility": "U", "parameters": {"RET": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}, "CHAR": {"type": () => {return new abap.types.Character();}, "is_optional": " "}}},
  "UCCP": {"visibility": "U", "parameters": {"UCCP": {"type": () => {return new abap.types.Hex({length: 2});}, "is_optional": " "}, "CHAR": {"type": () => {return new abap.types.Character();}, "is_optional": " "}}},
  "CONVERT": {"visibility": "U", "parameters": {"DATA": {"type": () => {return new abap.types.Character();}, "is_optional": " "}, "N": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}, "BUFFER": {"type": () => {return new abap.types.XString({qualifiedName: "XSTRING"});}, "is_optional": " "}}},
  "WRITE": {"visibility": "U", "parameters": {"DATA": {"type": () => {return new abap.types.Character(4);}, "is_optional": " "}}},
  "GET_BUFFER": {"visibility": "U", "parameters": {"BUFFER": {"type": () => {return new abap.types.XString({qualifiedName: "XSTRING"});}, "is_optional": " "}}},
  "RESET": {"visibility": "U", "parameters": {}}};
  constructor() {
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
    this.mv_js_encoding = new abap.types.String({qualifiedName: "STRING"});
    this.mv_buffer = new abap.types.XString({qualifiedName: "XSTRING"});
  }
  async constructor_(INPUT) {
    if (super.constructor_) { await super.constructor_(INPUT); }
    return this;
  }
  async create(INPUT) {
    return cl_abap_conv_out_ce.create(INPUT);
  }
  static async create(INPUT) {
    let ret = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_CONV_OUT_CE", RTTIName: "\\CLASS=CL_ABAP_CONV_OUT_CE"});
    let encoding = new abap.types.Character(20, {"qualifiedName":"abap_encoding"});
    if (INPUT && INPUT.encoding) {encoding.set(INPUT.encoding);}
    let ignore_cerr = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    if (INPUT && INPUT.ignore_cerr) {ignore_cerr.set(INPUT.ignore_cerr);}
    if (INPUT === undefined || INPUT.ignore_cerr === undefined) {ignore_cerr = abap.builtin.abap_false;}
    let endian = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.endian) {endian.set(INPUT.endian);}
    let replacement = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.replacement) {replacement.set(INPUT.replacement);}
    ret.set(await (new abap.Classes['CL_ABAP_CONV_OUT_CE']()).constructor_());
    let unique24 = encoding;
    if (abap.compare.eq(unique24, new abap.types.Character(5).set('UTF-8')) || abap.compare.eq(unique24, new abap.types.Character(1).set(''))) {
      ret.get().mv_js_encoding.set(new abap.types.Character(4).set('utf8'));
    } else if (abap.compare.eq(unique24, new abap.types.Character(4).set('4103'))) {
      ret.get().mv_js_encoding.set(new abap.types.Character(7).set('utf16le'));
    } else {
      abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(13).set('not supported')));
    }
    return ret;
  }
  async uccpi(INPUT) {
    return cl_abap_conv_out_ce.uccpi(INPUT);
  }
  static async uccpi(INPUT) {
    let ret = new abap.types.Integer({qualifiedName: "I"});
    let char = INPUT?.char;
    let lo_out = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_CONV_OUT_CE", RTTIName: "\\CLASS=CL_ABAP_CONV_OUT_CE"});
    let lv_hex = new abap.types.XString({qualifiedName: "XSTRING"});
    lo_out.set((await this.create({encoding: new abap.types.Character(4).set('4103')})));
    await lo_out.get().convert({data: char, buffer: lv_hex});
    abap.statements.assert(abap.compare.eq(abap.builtin.xstrlen({val: lv_hex}), abap.IntegerFactory.get(2)));
    ret.set(lv_hex.getOffset({length: 1}));
    ret.set(abap.operators.add(ret,abap.operators.multiply(lv_hex.getOffset({offset: 1, length: 1}),new abap.types.Integer().set(255))));
    return ret;
  }
  async write(INPUT) {
    let data = INPUT?.data;
    let res = new abap.types.XString({qualifiedName: "XSTRING"});
    await this.convert({data: data, buffer: res});
    abap.statements.concatenate({source: [this.mv_buffer, res], target: this.mv_buffer});
  }
  async get_buffer() {
    let buffer = new abap.types.XString({qualifiedName: "XSTRING"});
    buffer.set(this.mv_buffer);
    return buffer;
  }
  async uccp(INPUT) {
    return cl_abap_conv_out_ce.uccp(INPUT);
  }
  static async uccp(INPUT) {
    let uccp = new abap.types.Hex({length: 2});
    let char = INPUT?.char;
    let lv_char = new abap.types.Character(1, {});
    let lo_obj = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_CONV_OUT_CE", RTTIName: "\\CLASS=CL_ABAP_CONV_OUT_CE"});
    lv_char.set(char.getOffset({length: 1}));
    lo_obj.set((await this.create({encoding: new abap.types.Character(4).set('4103')})));
    await lo_obj.get().convert({data: lv_char, buffer: uccp});
    abap.statements.shift(uccp, {direction: 'LEFT',circular: true,mode: 'BYTE'});
    return uccp;
  }
  async reset() {
    abap.statements.clear(this.mv_buffer);
  }
  async convert(INPUT) {
    let data = INPUT?.data;
    let n = new abap.types.Integer({qualifiedName: "I"});
    if (INPUT && INPUT.n) {n.set(INPUT.n);}
    let buffer = INPUT?.buffer || new abap.types.XString({qualifiedName: "XSTRING"});
    let lv_str = new abap.types.String({qualifiedName: "STRING"});
    let result = "";
    if (INPUT && INPUT.n) {
      lv_str.set(data);
      lv_str.set(lv_str.getOffset({length: n}));
      result = Buffer.from(lv_str.get(), this.mv_js_encoding.get()).toString("hex");
    } else {
      result = Buffer.from(data.get(), this.mv_js_encoding.get()).toString("hex");
    }
    buffer.set(result.toUpperCase());
  }
}
abap.Classes['CL_ABAP_CONV_OUT_CE'] = cl_abap_conv_out_ce;
cl_abap_conv_out_ce.hex02 = new abap.types.Hex({length: 2});
export {cl_abap_conv_out_ce};
//# sourceMappingURL=cl_abap_conv_out_ce.clas.mjs.map