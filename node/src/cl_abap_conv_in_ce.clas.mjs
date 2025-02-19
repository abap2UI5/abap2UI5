const {cx_root} = await import("./cx_root.clas.mjs");
// cl_abap_conv_in_ce.clas.abap
class cl_abap_conv_in_ce {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CL_ABAP_CONV_IN_CE';
  static IMPLEMENTED_INTERFACES = [];
  static ATTRIBUTES = {"MV_INPUT": {"type": () => {return new abap.types.XString({qualifiedName: "XSTRING"});}, "visibility": "I", "is_constant": " ", "is_class": " "},
  "MV_JS_ENCODING": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "visibility": "I", "is_constant": " ", "is_class": " "},
  "MV_IGNORE_CERR": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});}, "visibility": "I", "is_constant": " ", "is_class": " "}};
  static METHODS = {"CREATE": {"visibility": "U", "parameters": {"RET": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "CL_ABAP_CONV_IN_CE", RTTIName: "\\CLASS=CL_ABAP_CONV_IN_CE"});}, "is_optional": " "}, "ENCODING": {"type": () => {return new abap.types.Character(20, {"qualifiedName":"abap_encoding"});}, "is_optional": " "}, "INPUT": {"type": () => {return new abap.types.XString({qualifiedName: "XSTRING"});}, "is_optional": " "}, "REPLACEMENT": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"CHAR1","ddicName":"CHAR1","description":"CHAR1"});}, "is_optional": " "}, "IGNORE_CERR": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});}, "is_optional": " "}, "ENDIAN": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"CHAR1","ddicName":"CHAR1","description":"CHAR1"});}, "is_optional": " "}}},
  "UCCPI": {"visibility": "U", "parameters": {"RET": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "VALUE": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}}},
  "UCCP": {"visibility": "U", "parameters": {"CHAR": {"type": () => {return new abap.types.Character(2, {"qualifiedName":"cl_abap_conv_in_ce=>ty_char2"});}, "is_optional": " "}, "UCCP": {"type": () => {return new abap.types.Character();}, "is_optional": " "}}},
  "CONVERT": {"visibility": "U", "parameters": {"INPUT": {"type": () => {return new abap.types.Hex();}, "is_optional": " "}, "N": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}, "DATA": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}},
  "READ": {"visibility": "U", "parameters": {"N": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}, "DATA": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}}};
  constructor() {
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
    this.mv_input = new abap.types.XString({qualifiedName: "XSTRING"});
    this.mv_js_encoding = new abap.types.String({qualifiedName: "STRING"});
    this.mv_ignore_cerr = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
  }
  async constructor_(INPUT) {
    if (super.constructor_) { await super.constructor_(INPUT); }
    return this;
  }
  async create(INPUT) {
    return cl_abap_conv_in_ce.create(INPUT);
  }
  static async create(INPUT) {
    let ret = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_CONV_IN_CE", RTTIName: "\\CLASS=CL_ABAP_CONV_IN_CE"});
    let encoding = new abap.types.Character(20, {"qualifiedName":"abap_encoding"});
    if (INPUT && INPUT.encoding) {encoding.set(INPUT.encoding);}
    if (INPUT === undefined || INPUT.encoding === undefined) {encoding = new abap.types.Character(5).set('UTF-8');}
    let input = new abap.types.XString({qualifiedName: "XSTRING"});
    if (INPUT && INPUT.input) {input.set(INPUT.input);}
    let replacement = new abap.types.Character(1, {"qualifiedName":"CHAR1","ddicName":"CHAR1","description":"CHAR1"});
    if (INPUT && INPUT.replacement) {replacement.set(INPUT.replacement);}
    if (INPUT === undefined || INPUT.replacement === undefined) {replacement = new abap.types.Character(1).set('#');}
    let ignore_cerr = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    if (INPUT && INPUT.ignore_cerr) {ignore_cerr.set(INPUT.ignore_cerr);}
    if (INPUT === undefined || INPUT.ignore_cerr === undefined) {ignore_cerr = abap.builtin.abap_false;}
    let endian = new abap.types.Character(1, {"qualifiedName":"CHAR1","ddicName":"CHAR1","description":"CHAR1"});
    if (INPUT && INPUT.endian) {endian.set(INPUT.endian);}
    abap.statements.assert(abap.compare.eq(replacement, new abap.types.Character(1).set('#')));
    abap.statements.assert(abap.compare.initial(endian));
    ret.set(await (new abap.Classes['CL_ABAP_CONV_IN_CE']()).constructor_());
    let unique22 = encoding;
    if (abap.compare.eq(unique22, new abap.types.Character(6).set('UTF-16'))) {
      ret.get().mv_js_encoding.set(new abap.types.Character(8).set('utf-16le'));
    } else if (abap.compare.eq(unique22, new abap.types.Character(5).set('UTF-8'))) {
      ret.get().mv_js_encoding.set(new abap.types.Character(4).set('utf8'));
    } else if (abap.compare.eq(unique22, new abap.types.Character(4).set('4103'))) {
      ret.get().mv_js_encoding.set(new abap.types.Character(8).set('utf-16le'));
    } else {
      abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(13).set('not supported')));
    }
    ret.get().mv_input.set(input);
    ret.get().mv_ignore_cerr.set(ignore_cerr);
    return ret;
  }
  async uccp(INPUT) {
    return cl_abap_conv_in_ce.uccp(INPUT);
  }
  static async uccp(INPUT) {
    let char = new abap.types.Character(2, {"qualifiedName":"cl_abap_conv_in_ce=>ty_char2"});
    let uccp = INPUT?.uccp;
    let int = new abap.types.Integer({qualifiedName: "I"});
    let hex = new abap.types.Hex({length: 2});
    hex.set(uccp);
    int.set(hex);
    try {
      char.set((await this.uccpi({value: int})));
    } catch (e) {
      if ((abap.Classes['CX_SY_CONVERSION_CODEPAGE'] && e instanceof abap.Classes['CX_SY_CONVERSION_CODEPAGE'])) {
      } else {
        throw e;
      }
    }
    return char;
  }
  async uccpi(INPUT) {
    return cl_abap_conv_in_ce.uccpi(INPUT);
  }
  static async uccpi(INPUT) {
    let ret = new abap.types.String({qualifiedName: "STRING"});
    let value = INPUT?.value;
    if (value?.getQualifiedName === undefined || value.getQualifiedName() !== "I") { value = undefined; }
    if (value === undefined) { value = new abap.types.Integer({qualifiedName: "I"}).set(INPUT.value); }
    let lv_hex = new abap.types.Hex({length: 2});
    let lo_in = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_CONV_IN_CE", RTTIName: "\\CLASS=CL_ABAP_CONV_IN_CE"});
    lv_hex.set(value);
    abap.statements.concatenate({source: [lv_hex.getOffset({offset: 1, length: 1}), lv_hex.getOffset({length: 1})], target: lv_hex});
    lo_in.set((await this.create({encoding: new abap.types.Character(4).set('4103')})));
    await lo_in.get().convert({input: lv_hex, data: ret});
    return ret;
  }
  async convert(INPUT) {
    let input = INPUT?.input;
    let n = new abap.types.Integer({qualifiedName: "I"});
    if (INPUT && INPUT.n) {n.set(INPUT.n);}
    let data = INPUT?.data || new abap.types.String({qualifiedName: "STRING"});
    let lv_error = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    abap.statements.assert(abap.compare.initial(this.mv_js_encoding) === false);
    let buf = Buffer.from(input.get(), "hex");
    const decoder = TextDecoder || await import("util").TextDecoder;
    const td = new decoder(this.mv_js_encoding.get(), {fatal: this.mv_ignore_cerr.get() !== "X", ignoreBOM: true});
    try {
        data.set(td.decode(buf));
    } catch (e) {
      lv_error.set(abap.builtin.abap_true);
    }
    if (abap.compare.eq(lv_error, abap.builtin.abap_true)) {
      const unique23 = await (new abap.Classes['CX_SY_CONVERSION_CODEPAGE']()).constructor_();
      unique23.EXTRA_CX = {"INTERNAL_FILENAME": "cl_abap_conv_in_ce.clas.abap","INTERNAL_LINE": 118};
      throw unique23;
    }
  }
  async read(INPUT) {
    let n = new abap.types.Integer({qualifiedName: "I"});
    if (INPUT && INPUT.n) {n.set(INPUT.n);}
    let data = INPUT?.data || new abap.types.String({qualifiedName: "STRING"});
    await this.convert({input: this.mv_input, n: n, data: data});
  }
}
abap.Classes['CL_ABAP_CONV_IN_CE'] = cl_abap_conv_in_ce;
cl_abap_conv_in_ce.ty_char2 = new abap.types.Character(2, {"qualifiedName":"cl_abap_conv_in_ce=>ty_char2"});
export {cl_abap_conv_in_ce};
//# sourceMappingURL=cl_abap_conv_in_ce.clas.mjs.map