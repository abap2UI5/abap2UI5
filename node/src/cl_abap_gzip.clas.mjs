const {cx_root} = await import("./cx_root.clas.mjs");
// cl_abap_gzip.clas.abap
class cl_abap_gzip {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CL_ABAP_GZIP';
  static IMPLEMENTED_INTERFACES = [];
  static ATTRIBUTES = {};
  static METHODS = {"DECOMPRESS_BINARY": {"visibility": "U", "parameters": {"GZIP_IN": {"type": () => {return new abap.types.XString({qualifiedName: "XSTRING"});}, "is_optional": " "}, "RAW_OUT": {"type": () => {return new abap.types.XString({qualifiedName: "XSTRING"});}, "is_optional": " "}, "RAW_OUT_LEN": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}}},
  "COMPRESS_BINARY": {"visibility": "U", "parameters": {"COMPRESS_LEVEL": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}, "RAW_IN": {"type": () => {return new abap.types.XString({qualifiedName: "XSTRING"});}, "is_optional": " "}, "GZIP_OUT": {"type": () => {return new abap.types.XString({qualifiedName: "XSTRING"});}, "is_optional": " "}, "GZIP_OUT_LEN": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}}},
  "DECOMPRESS_TEXT": {"visibility": "U", "parameters": {"GZIP_IN": {"type": () => {return new abap.types.Hex();}, "is_optional": " "}, "GZIP_IN_LEN": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}, "CONVERSION": {"type": () => {return new abap.types.Character(20, {"qualifiedName":"ABAP_ENCOD","ddicName":"ABAP_ENCOD","description":"ABAP_ENCOD"});}, "is_optional": " "}, "TEXT_OUT": {"type": () => {return new abap.types.Character();}, "is_optional": " "}, "TEXT_OUT_LEN": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}}},
  "COMPRESS_TEXT": {"visibility": "U", "parameters": {"TEXT_IN": {"type": () => {return new abap.types.Character();}, "is_optional": " "}, "TEXT_IN_LEN": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}, "COMPRESS_LEVEL": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}, "CONVERSION": {"type": () => {return new abap.types.Character(20, {"qualifiedName":"ABAP_ENCOD","ddicName":"ABAP_ENCOD","description":"ABAP_ENCOD"});}, "is_optional": " "}, "GZIP_OUT": {"type": () => {return new abap.types.Hex();}, "is_optional": " "}, "GZIP_OUT_LEN": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}}},
  "DECOMPRESS_BINARY_WITH_HEADER": {"visibility": "U", "parameters": {"GZIP_IN": {"type": () => {return new abap.types.XString({qualifiedName: "XSTRING"});}, "is_optional": " "}, "RAW_OUT": {"type": () => {return new abap.types.XString({qualifiedName: "XSTRING"});}, "is_optional": " "}}}};
  constructor() {
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
  }
  async constructor_(INPUT) {
    if (super.constructor_) { await super.constructor_(INPUT); }
    return this;
  }
  async decompress_binary_with_header(INPUT) {
    return cl_abap_gzip.decompress_binary_with_header(INPUT);
  }
  static async decompress_binary_with_header(INPUT) {
    let gzip_in = INPUT?.gzip_in;
    if (gzip_in?.getQualifiedName === undefined || gzip_in.getQualifiedName() !== "XSTRING") { gzip_in = undefined; }
    if (gzip_in === undefined) { gzip_in = new abap.types.XString({qualifiedName: "XSTRING"}).set(INPUT.gzip_in); }
    let raw_out = INPUT?.raw_out || new abap.types.XString({qualifiedName: "XSTRING"});
    const zlib = await import("zlib");
    const buf = Buffer.from(gzip_in.get(), "hex");
    const decompress = zlib.gunzipSync(buf).toString("hex").toUpperCase();
    raw_out.set(decompress);
  }
  async decompress_text(INPUT) {
    return cl_abap_gzip.decompress_text(INPUT);
  }
  static async decompress_text(INPUT) {
    let gzip_in = INPUT?.gzip_in;
    let gzip_in_len = new abap.types.Integer({qualifiedName: "I"});
    if (INPUT && INPUT.gzip_in_len) {gzip_in_len.set(INPUT.gzip_in_len);}
    if (INPUT === undefined || INPUT.gzip_in_len === undefined) {gzip_in_len = abap.IntegerFactory.get(-1);}
    let conversion = new abap.types.Character(20, {"qualifiedName":"ABAP_ENCOD","ddicName":"ABAP_ENCOD","description":"ABAP_ENCOD"});
    if (INPUT && INPUT.conversion) {conversion.set(INPUT.conversion);}
    if (INPUT === undefined || INPUT.conversion === undefined) {conversion = new abap.types.Character(7).set('DEFAULT');}
    let text_out = INPUT?.text_out || new abap.types.Character();
    let text_out_len = INPUT?.text_out_len || new abap.types.Integer({qualifiedName: "I"});
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
  }
  async compress_text(INPUT) {
    return cl_abap_gzip.compress_text(INPUT);
  }
  static async compress_text(INPUT) {
    let text_in = INPUT?.text_in;
    let text_in_len = new abap.types.Integer({qualifiedName: "I"});
    if (INPUT && INPUT.text_in_len) {text_in_len.set(INPUT.text_in_len);}
    if (INPUT === undefined || INPUT.text_in_len === undefined) {text_in_len = abap.IntegerFactory.get(-1);}
    let compress_level = new abap.types.Integer({qualifiedName: "I"});
    if (INPUT && INPUT.compress_level) {compress_level.set(INPUT.compress_level);}
    if (INPUT === undefined || INPUT.compress_level === undefined) {compress_level = abap.IntegerFactory.get(6);}
    let conversion = new abap.types.Character(20, {"qualifiedName":"ABAP_ENCOD","ddicName":"ABAP_ENCOD","description":"ABAP_ENCOD"});
    if (INPUT && INPUT.conversion) {conversion.set(INPUT.conversion);}
    if (INPUT === undefined || INPUT.conversion === undefined) {conversion = new abap.types.Character(7).set('DEFAULT');}
    let gzip_out = INPUT?.gzip_out || new abap.types.Hex();
    let gzip_out_len = INPUT?.gzip_out_len || new abap.types.Integer({qualifiedName: "I"});
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
  }
  async decompress_binary(INPUT) {
    return cl_abap_gzip.decompress_binary(INPUT);
  }
  static async decompress_binary(INPUT) {
    let gzip_in = INPUT?.gzip_in;
    if (gzip_in?.getQualifiedName === undefined || gzip_in.getQualifiedName() !== "XSTRING") { gzip_in = undefined; }
    if (gzip_in === undefined) { gzip_in = new abap.types.XString({qualifiedName: "XSTRING"}).set(INPUT.gzip_in); }
    let raw_out = INPUT?.raw_out || new abap.types.XString({qualifiedName: "XSTRING"});
    let raw_out_len = INPUT?.raw_out_len || new abap.types.Integer({qualifiedName: "I"});
    const zlib = await import("zlib");
    const buf = Buffer.from(gzip_in.get(), "hex");
    const decompress = zlib.inflateRawSync(buf, {finishFlush: zlib.constants.Z_SYNC_FLUSH}).toString("hex").toUpperCase();
    raw_out.set(decompress);
    raw_out_len.set(abap.builtin.xstrlen({val: raw_out}));
  }
  async compress_binary(INPUT) {
    return cl_abap_gzip.compress_binary(INPUT);
  }
  static async compress_binary(INPUT) {
    let compress_level = new abap.types.Integer({qualifiedName: "I"});
    if (INPUT && INPUT.compress_level) {compress_level.set(INPUT.compress_level);}
    let raw_in = INPUT?.raw_in;
    if (raw_in?.getQualifiedName === undefined || raw_in.getQualifiedName() !== "XSTRING") { raw_in = undefined; }
    if (raw_in === undefined) { raw_in = new abap.types.XString({qualifiedName: "XSTRING"}).set(INPUT.raw_in); }
    let gzip_out = INPUT?.gzip_out || new abap.types.XString({qualifiedName: "XSTRING"});
    let gzip_out_len = INPUT?.gzip_out_len || new abap.types.Integer({qualifiedName: "I"});
    const zlib = await import("zlib");
    const buf = Buffer.from(raw_in.get(), "hex");
    const gzi = zlib.deflateRawSync(buf).toString("hex").toUpperCase();
    gzip_out.set(gzi);
    gzip_out_len.set(abap.builtin.xstrlen({val: gzip_out}));
  }
}
abap.Classes['CL_ABAP_GZIP'] = cl_abap_gzip;
export {cl_abap_gzip};
//# sourceMappingURL=cl_abap_gzip.clas.mjs.map