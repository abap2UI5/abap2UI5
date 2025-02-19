const {cx_root} = await import("./cx_root.clas.mjs");
// cl_abap_zip.clas.locals_imp.abap
class lcl_stream {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CLAS-CL_ABAP_ZIP-LCL_STREAM';
  static IMPLEMENTED_INTERFACES = [];
  static ATTRIBUTES = {"CRC32_MAP": {"type": () => {return new abap.types.XString({qualifiedName: "XSTRING"});}, "visibility": "I", "is_constant": " ", "is_class": "X"},
  "MV_XSTR": {"type": () => {return new abap.types.XString({qualifiedName: "XSTRING"});}, "visibility": "I", "is_constant": " ", "is_class": " "}};
  static METHODS = {"APPEND": {"visibility": "U", "parameters": {"IV_XSTR": {"type": () => {return new abap.types.Hex();}, "is_optional": " "}}},
  "GET": {"visibility": "U", "parameters": {"RV_XSTR": {"type": () => {return new abap.types.XString({qualifiedName: "XSTRING"});}, "is_optional": " "}}},
  "APPEND_DATE": {"visibility": "U", "parameters": {"IV_DATE": {"type": () => {return new abap.types.Date({qualifiedName: "D"});}, "is_optional": " "}}},
  "APPEND_TIME": {"visibility": "U", "parameters": {"IV_TIME": {"type": () => {return new abap.types.Time({qualifiedName: "T"});}, "is_optional": " "}}},
  "APPEND_INT4": {"visibility": "U", "parameters": {"IV_INT": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}}},
  "APPEND_INT2": {"visibility": "U", "parameters": {"IV_INT": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}}},
  "APPEND_CRC": {"visibility": "U", "parameters": {"RV_CRC": {"type": () => {return new abap.types.XString({qualifiedName: "XSTRING"});}, "is_optional": " "}, "IV_LITTLE_ENDIAN": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});}, "is_optional": " "}, "IV_XSTRING": {"type": () => {return new abap.types.XString({qualifiedName: "XSTRING"});}, "is_optional": " "}}}};
  constructor() {
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
    this.crc32_map = lcl_stream.crc32_map;
    this.mv_xstr = new abap.types.XString({qualifiedName: "XSTRING"});
  }
  async constructor_(INPUT) {
    if (super.constructor_) { await super.constructor_(INPUT); }
    return this;
  }
  async append(INPUT) {
    let iv_xstr = INPUT?.iv_xstr;
    abap.statements.concatenate({source: [this.mv_xstr, iv_xstr], target: this.mv_xstr});
  }
  async get() {
    let rv_xstr = new abap.types.XString({qualifiedName: "XSTRING"});
    rv_xstr.set(this.mv_xstr);
    return rv_xstr;
  }
  async append_date(INPUT) {
    let iv_date = INPUT?.iv_date;
    if (iv_date?.getQualifiedName === undefined || iv_date.getQualifiedName() !== "D") { iv_date = undefined; }
    if (iv_date === undefined) { iv_date = new abap.types.Date({qualifiedName: "D"}).set(INPUT.iv_date); }
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
  }
  async append_time(INPUT) {
    let iv_time = INPUT?.iv_time;
    if (iv_time?.getQualifiedName === undefined || iv_time.getQualifiedName() !== "T") { iv_time = undefined; }
    if (iv_time === undefined) { iv_time = new abap.types.Time({qualifiedName: "T"}).set(INPUT.iv_time); }
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
  }
  async append_int2(INPUT) {
    let iv_int = INPUT?.iv_int;
    if (iv_int?.getQualifiedName === undefined || iv_int.getQualifiedName() !== "I") { iv_int = undefined; }
    if (iv_int === undefined) { iv_int = new abap.types.Integer({qualifiedName: "I"}).set(INPUT.iv_int); }
    let lv_hex = new abap.types.Hex({length: 2});
    lv_hex.set(iv_int);
    abap.statements.shift(lv_hex, {direction: 'LEFT',circular: true,mode: 'BYTE'});
    await this.append({iv_xstr: lv_hex});
  }
  async append_int4(INPUT) {
    let iv_int = INPUT?.iv_int;
    if (iv_int?.getQualifiedName === undefined || iv_int.getQualifiedName() !== "I") { iv_int = undefined; }
    if (iv_int === undefined) { iv_int = new abap.types.Integer({qualifiedName: "I"}).set(INPUT.iv_int); }
    let lv_hex = new abap.types.Hex({length: 4});
    lv_hex.set(iv_int);
    abap.statements.concatenate({source: [lv_hex.getOffset({offset: 3, length: 1}), lv_hex.getOffset({offset: 2, length: 1}), lv_hex.getOffset({offset: 1, length: 1}), lv_hex.getOffset({length: 1})], target: lv_hex});
    await this.append({iv_xstr: lv_hex});
  }
  async append_crc(INPUT) {
    let rv_crc = new abap.types.XString({qualifiedName: "XSTRING"});
    let iv_little_endian = INPUT?.iv_little_endian;
    if (iv_little_endian?.getQualifiedName === undefined || iv_little_endian.getQualifiedName() !== "ABAP_BOOL") { iv_little_endian = undefined; }
    if (iv_little_endian === undefined) { iv_little_endian = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}).set(INPUT.iv_little_endian); }
    let iv_xstring = INPUT?.iv_xstring;
    if (iv_xstring?.getQualifiedName === undefined || iv_xstring.getQualifiedName() !== "XSTRING") { iv_xstring = undefined; }
    if (iv_xstring === undefined) { iv_xstring = new abap.types.XString({qualifiedName: "XSTRING"}).set(INPUT.iv_xstring); }
    let magic_nr = new abap.types.Hex({length: 4});
    magic_nr.set('EDB88320');
    let mffffffff = new abap.types.Hex({length: 4});
    mffffffff.set('FFFFFFFF');
    let m7fffffff = new abap.types.Hex({length: 4});
    m7fffffff.set('7FFFFFFF');
    let m00ffffff = new abap.types.Hex({length: 4});
    m00ffffff.set('00FFFFFF');
    let m000000ff = new abap.types.Hex({length: 4});
    m000000ff.set('000000FF');
    let m000000 = new abap.types.Hex({length: 3});
    m000000.set('000000');
    let cindex = new abap.types.Hex({length: 4});
    let low_bit = new abap.types.Hex({length: 4});
    let len = new abap.types.Integer({qualifiedName: "I"});
    let nindex = new abap.types.Integer({qualifiedName: "I"});
    let crc = new abap.types.Hex({length: 4});
    crc.set(mffffffff);
    let x4 = new abap.types.Hex({length: 4});
    let idx = new abap.types.Hex({length: 4});
    if (abap.compare.eq(abap.builtin.xstrlen({val: lcl_stream.crc32_map}), abap.IntegerFactory.get(0))) {
      const indexBackup1 = abap.builtin.sy.get().index.get();
      const unique7 = new abap.types.Integer().set(256).get();
      for (let unique8 = 0; unique8 < unique7; unique8++) {
        abap.builtin.sy.get().index.set(unique8 + 1);
        cindex.set(abap.operators.minus(abap.builtin.sy.get().index,abap.IntegerFactory.get(1)));
        const indexBackup2 = abap.builtin.sy.get().index.get();
        const unique9 = abap.IntegerFactory.get(8).get();
        for (let unique10 = 0; unique10 < unique9; unique10++) {
          abap.builtin.sy.get().index.set(unique10 + 1);
          low_bit.set(new abap.types.Character(8).set('00000001'));
          low_bit.set(abap.operators.bitand(cindex,low_bit));
          cindex.set(abap.operators.div(cindex,abap.IntegerFactory.get(2)));
          cindex.set(abap.operators.bitand(cindex,m7fffffff));
          if (abap.compare.initial(low_bit) === false) {
            cindex.set(abap.operators.bitxor(cindex,magic_nr));
          }
        }
        abap.builtin.sy.get().index.set(indexBackup2);
        abap.statements.concatenate({source: [lcl_stream.crc32_map, cindex], target: lcl_stream.crc32_map});
      }
      abap.builtin.sy.get().index.set(indexBackup1);
    }
    len.set(abap.builtin.xstrlen({val: iv_xstring}));
    const indexBackup3 = abap.builtin.sy.get().index.get();
    const unique11 = len.get();
    for (let unique12 = 0; unique12 < unique11; unique12++) {
      abap.builtin.sy.get().index.set(unique12 + 1);
      nindex.set(abap.operators.minus(abap.builtin.sy.get().index,abap.IntegerFactory.get(1)));
      abap.statements.concatenate({source: [m000000, iv_xstring.getOffset({offset: nindex, length: 1})], target: idx});
      idx.set(abap.operators.bitand(abap.operators.bitxor(crc,idx),m000000ff));
      idx.set(abap.operators.multiply(idx,abap.IntegerFactory.get(4)));
      x4.set(lcl_stream.crc32_map.getOffset({offset: idx, length: 4}));
      crc.set(abap.operators.div(crc,new abap.types.Integer().set(256)));
      crc.set(abap.operators.bitand(crc,m00ffffff));
      crc.set(abap.operators.bitxor(x4,crc));
    }
    abap.builtin.sy.get().index.set(indexBackup3);
    crc.set(abap.operators.bitxor(crc,mffffffff));
    if (abap.compare.eq(iv_little_endian, abap.builtin.abap_true)) {
      abap.statements.concatenate({source: [crc.getOffset({offset: 3, length: 1}), crc.getOffset({offset: 2, length: 1}), crc.getOffset({offset: 1, length: 1}), crc.getOffset({length: 1})], target: crc});
    }
    rv_crc.set(crc);
    await this.append({iv_xstr: rv_crc});
    return rv_crc;
  }
}
abap.Classes['CLAS-CL_ABAP_ZIP-LCL_STREAM'] = lcl_stream;
lcl_stream.crc32_map = new abap.types.XString({qualifiedName: "XSTRING"});
export {lcl_stream};
//# sourceMappingURL=cl_abap_zip.clas.locals.mjs.map