const {cx_root} = await import("./cx_root.clas.mjs");
// cl_abap_tstmp.clas.abap
class cl_abap_tstmp {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CL_ABAP_TSTMP';
  static IMPLEMENTED_INTERFACES = [];
  static ATTRIBUTES = {};
  static METHODS = {"SUBTRACT": {"visibility": "U", "parameters": {"R_SECS": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}, "TSTMP1": {"type": () => {return new abap.types.Packed({length: 1, decimals: 0});}, "is_optional": " "}, "TSTMP2": {"type": () => {return new abap.types.Packed({length: 1, decimals: 0});}, "is_optional": " "}}},
  "ADD": {"visibility": "U", "parameters": {"TIME": {"type": () => {return new abap.types.Packed({length: 15, decimals: 0, qualifiedName: "TIMESTAMP"});}, "is_optional": " "}, "TSTMP": {"type": () => {return new abap.types.Packed({length: 1, decimals: 0});}, "is_optional": " "}, "SECS": {"type": () => {return new abap.types.Packed({length: 8, decimals: 2});}, "is_optional": " "}}},
  "SUBTRACTSECS": {"visibility": "U", "parameters": {"TIME": {"type": () => {return new abap.types.Packed({length: 15, decimals: 0, qualifiedName: "TIMESTAMP"});}, "is_optional": " "}, "TSTMP": {"type": () => {return new abap.types.Packed({length: 1, decimals: 0});}, "is_optional": " "}, "SECS": {"type": () => {return new abap.types.Packed({length: 8, decimals: 2});}, "is_optional": " "}}},
  "TD_ADD": {"visibility": "U", "parameters": {"DATE": {"type": () => {return new abap.types.Date({qualifiedName: "D"});}, "is_optional": " "}, "TIME": {"type": () => {return new abap.types.Time({qualifiedName: "T"});}, "is_optional": " "}, "SECS": {"type": () => {return new abap.types.Packed({length: 8, decimals: 2});}, "is_optional": " "}, "RES_DATE": {"type": () => {return new abap.types.Date({qualifiedName: "D"});}, "is_optional": " "}, "RES_TIME": {"type": () => {return new abap.types.Time({qualifiedName: "T"});}, "is_optional": " "}}},
  "MOVE": {"visibility": "U", "parameters": {"TSTMP_SRC": {"type": () => {return new abap.types.Packed({length: 1, decimals: 0});}, "is_optional": " "}, "TSTMP_TGT": {"type": () => {return new abap.types.Packed({length: 1, decimals: 0});}, "is_optional": " "}}},
  "SYSTEMTSTMP_SYST2UTC": {"visibility": "U", "parameters": {"SYST_DATE": {"type": () => {return new abap.types.Date({qualifiedName: "D"});}, "is_optional": " "}, "SYST_TIME": {"type": () => {return new abap.types.Time({qualifiedName: "T"});}, "is_optional": " "}, "UTC_TSTMP": {"type": () => {return new abap.types.Packed({length: 1, decimals: 0});}, "is_optional": " "}}},
  "MOVE_TO_SHORT": {"visibility": "U", "parameters": {"TSTMP_OUT": {"type": () => {return new abap.types.Packed({length: 15, decimals: 0, qualifiedName: "TZNTSTMPS"});}, "is_optional": " "}, "TSTMP_SRC": {"type": () => {return new abap.types.Packed({length: 21, decimals: 7, qualifiedName: "TZNTSTMPL"});}, "is_optional": " "}}},
  "TD_SUBTRACT": {"visibility": "U", "parameters": {"DATE1": {"type": () => {return new abap.types.Date({qualifiedName: "D"});}, "is_optional": " "}, "TIME1": {"type": () => {return new abap.types.Time({qualifiedName: "T"});}, "is_optional": " "}, "DATE2": {"type": () => {return new abap.types.Date({qualifiedName: "D"});}, "is_optional": " "}, "TIME2": {"type": () => {return new abap.types.Time({qualifiedName: "T"});}, "is_optional": " "}, "RES_SECS": {"type": () => {return new abap.types.Packed({length: 8, decimals: 2});}, "is_optional": " "}}},
  "SYSTEMTSTMP_UTC2SYST": {"visibility": "U", "parameters": {"UTC_TSTMP": {"type": () => {return new abap.types.Packed({length: 15, decimals: 0, qualifiedName: "TIMESTAMP"});}, "is_optional": " "}, "SYST_DATE": {"type": () => {return new abap.types.Date({qualifiedName: "D"});}, "is_optional": " "}, "SYST_TIME": {"type": () => {return new abap.types.Time({qualifiedName: "T"});}, "is_optional": " "}}}};
  constructor() {
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
  }
  async constructor_(INPUT) {
    if (super.constructor_) { await super.constructor_(INPUT); }
    return this;
  }
  async td_add(INPUT) {
    return cl_abap_tstmp.td_add(INPUT);
  }
  static async td_add(INPUT) {
    let date = INPUT?.date;
    if (date?.getQualifiedName === undefined || date.getQualifiedName() !== "D") { date = undefined; }
    if (date === undefined) { date = new abap.types.Date({qualifiedName: "D"}).set(INPUT.date); }
    let time = INPUT?.time;
    if (time?.getQualifiedName === undefined || time.getQualifiedName() !== "T") { time = undefined; }
    if (time === undefined) { time = new abap.types.Time({qualifiedName: "T"}).set(INPUT.time); }
    let secs = INPUT?.secs;
    if (secs.constructor.name === "Character") {
        secs = new abap.types.Packed({length: 8, decimals: 2});
        secs.set(INPUT?.secs);
    }
    let res_date = INPUT?.res_date || new abap.types.Date({qualifiedName: "D"});
    let res_time = INPUT?.res_time || new abap.types.Time({qualifiedName: "T"});
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
  }
  async systemtstmp_utc2syst(INPUT) {
    return cl_abap_tstmp.systemtstmp_utc2syst(INPUT);
  }
  static async systemtstmp_utc2syst(INPUT) {
    let utc_tstmp = INPUT?.utc_tstmp;
    if (utc_tstmp?.getQualifiedName === undefined || utc_tstmp.getQualifiedName() !== "TIMESTAMP") { utc_tstmp = undefined; }
    if (utc_tstmp === undefined) { utc_tstmp = new abap.types.Packed({length: 15, decimals: 0, qualifiedName: "TIMESTAMP"}).set(INPUT.utc_tstmp); }
    let syst_date = INPUT?.syst_date || new abap.types.Date({qualifiedName: "D"});
    let syst_time = INPUT?.syst_time || new abap.types.Time({qualifiedName: "T"});
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
  }
  async move(INPUT) {
    return cl_abap_tstmp.move(INPUT);
  }
  static async move(INPUT) {
    let tstmp_src = INPUT?.tstmp_src;
    if (tstmp_src === undefined) { tstmp_src = new abap.types.Packed({length: 1, decimals: 0}).set(INPUT.tstmp_src); }
    let tstmp_tgt = INPUT?.tstmp_tgt || new abap.types.Packed({length: 1, decimals: 0});
    tstmp_tgt.set(tstmp_src);
  }
  async systemtstmp_syst2utc(INPUT) {
    return cl_abap_tstmp.systemtstmp_syst2utc(INPUT);
  }
  static async systemtstmp_syst2utc(INPUT) {
    let syst_date = INPUT?.syst_date;
    if (syst_date?.getQualifiedName === undefined || syst_date.getQualifiedName() !== "D") { syst_date = undefined; }
    if (syst_date === undefined) { syst_date = new abap.types.Date({qualifiedName: "D"}).set(INPUT.syst_date); }
    let syst_time = INPUT?.syst_time;
    if (syst_time?.getQualifiedName === undefined || syst_time.getQualifiedName() !== "T") { syst_time = undefined; }
    if (syst_time === undefined) { syst_time = new abap.types.Time({qualifiedName: "T"}).set(INPUT.syst_time); }
    let utc_tstmp = INPUT?.utc_tstmp || new abap.types.Packed({length: 1, decimals: 0});
    if (abap.compare.initial(syst_date)) {
      const unique33 = await (new abap.Classes['CX_PARAMETER_INVALID_RANGE']()).constructor_();
      unique33.EXTRA_CX = {"INTERNAL_FILENAME": "cl_abap_tstmp.clas.abap","INTERNAL_LINE": 98};
      throw unique33;
    }
    utc_tstmp.set(new abap.types.String().set(`${abap.templateFormatting(syst_date)}${abap.templateFormatting(syst_time)}`));
  }
  async subtract(INPUT) {
    return cl_abap_tstmp.subtract(INPUT);
  }
  static async subtract(INPUT) {
    let r_secs = new abap.types.Integer({qualifiedName: "I"});
    let tstmp1 = INPUT?.tstmp1;
    if (tstmp1 === undefined) { tstmp1 = new abap.types.Packed({length: 1, decimals: 0}).set(INPUT.tstmp1); }
    let tstmp2 = INPUT?.tstmp2;
    if (tstmp2 === undefined) { tstmp2 = new abap.types.Packed({length: 1, decimals: 0}).set(INPUT.tstmp2); }
    let str = new abap.types.String({qualifiedName: "STRING"});
    let lv_dummy = new abap.types.String({qualifiedName: "STRING"});
    str.set(new abap.types.String().set(`${abap.templateFormatting(tstmp1,{"timestamp":"iso"})}`));
    if (abap.compare.ca(str, new abap.types.Character(1).set(','))) {
      abap.statements.split({source: str, at: new abap.types.Character(1).set(','), targets: [str,lv_dummy]});
    }
    let t1 = Date.parse(str.get());
    str.set(new abap.types.String().set(`${abap.templateFormatting(tstmp2,{"timestamp":"iso"})}`));
    if (abap.compare.ca(str, new abap.types.Character(1).set(','))) {
      abap.statements.split({source: str, at: new abap.types.Character(1).set(','), targets: [str,lv_dummy]});
    }
    let t2 = Date.parse(str.get());
    r_secs.set((t1 - t2)/1000);
    return r_secs;
  }
  async add(INPUT) {
    return cl_abap_tstmp.add(INPUT);
  }
  static async add(INPUT) {
    let time = new abap.types.Packed({length: 15, decimals: 0, qualifiedName: "TIMESTAMP"});
    let tstmp = INPUT?.tstmp;
    if (tstmp === undefined) { tstmp = new abap.types.Packed({length: 1, decimals: 0}).set(INPUT.tstmp); }
    let secs = INPUT?.secs;
    if (secs.constructor.name === "Character") {
        secs = new abap.types.Packed({length: 8, decimals: 2});
        secs.set(INPUT?.secs);
    }
    let str = new abap.types.String({qualifiedName: "STRING"});
    let lv_dummy = new abap.types.String({qualifiedName: "STRING"});
    str.set(new abap.types.String().set(`${abap.templateFormatting(tstmp,{"timestamp":"iso"})}`));
    if (abap.compare.ca(str, new abap.types.Character(1).set(','))) {
      abap.statements.split({source: str, at: new abap.types.Character(1).set(','), targets: [str,lv_dummy]});
    }
    let t1 = new Date(Date.parse(str.get() + "Z"));
    t1.setSeconds( t1.getSeconds() + secs.get() );
    time.set(t1.toISOString().slice(0, 19).replace(/-/g, "").replace(/:/g, "").replace("T", ""));
    return time;
  }
  async subtractsecs(INPUT) {
    return cl_abap_tstmp.subtractsecs(INPUT);
  }
  static async subtractsecs(INPUT) {
    let time = new abap.types.Packed({length: 15, decimals: 0, qualifiedName: "TIMESTAMP"});
    let tstmp = INPUT?.tstmp;
    if (tstmp === undefined) { tstmp = new abap.types.Packed({length: 1, decimals: 0}).set(INPUT.tstmp); }
    let secs = INPUT?.secs;
    if (secs.constructor.name === "Character") {
        secs = new abap.types.Packed({length: 8, decimals: 2});
        secs.set(INPUT?.secs);
    }
    let lv_secs = new abap.types.Integer({qualifiedName: "I"});
    lv_secs.set(abap.operators.multiply(secs,abap.IntegerFactory.get(-1)));
    time.set((await this.add({tstmp: tstmp, secs: lv_secs})));
    return time;
  }
  async move_to_short(INPUT) {
    return cl_abap_tstmp.move_to_short(INPUT);
  }
  static async move_to_short(INPUT) {
    let tstmp_out = new abap.types.Packed({length: 15, decimals: 0, qualifiedName: "TZNTSTMPS"});
    let tstmp_src = INPUT?.tstmp_src;
    if (tstmp_src?.getQualifiedName === undefined || tstmp_src.getQualifiedName() !== "TZNTSTMPL") { tstmp_src = undefined; }
    if (tstmp_src === undefined) { tstmp_src = new abap.types.Packed({length: 21, decimals: 7, qualifiedName: "TZNTSTMPL"}).set(INPUT.tstmp_src); }
    await this.move({tstmp_src: tstmp_src, tstmp_tgt: tstmp_out});
    return tstmp_out;
  }
  async td_subtract(INPUT) {
    return cl_abap_tstmp.td_subtract(INPUT);
  }
  static async td_subtract(INPUT) {
    let date1 = INPUT?.date1;
    if (date1?.getQualifiedName === undefined || date1.getQualifiedName() !== "D") { date1 = undefined; }
    if (date1 === undefined) { date1 = new abap.types.Date({qualifiedName: "D"}).set(INPUT.date1); }
    let time1 = INPUT?.time1;
    if (time1?.getQualifiedName === undefined || time1.getQualifiedName() !== "T") { time1 = undefined; }
    if (time1 === undefined) { time1 = new abap.types.Time({qualifiedName: "T"}).set(INPUT.time1); }
    let date2 = INPUT?.date2;
    if (date2?.getQualifiedName === undefined || date2.getQualifiedName() !== "D") { date2 = undefined; }
    if (date2 === undefined) { date2 = new abap.types.Date({qualifiedName: "D"}).set(INPUT.date2); }
    let time2 = INPUT?.time2;
    if (time2?.getQualifiedName === undefined || time2.getQualifiedName() !== "T") { time2 = undefined; }
    if (time2 === undefined) { time2 = new abap.types.Time({qualifiedName: "T"}).set(INPUT.time2); }
    let res_secs = INPUT?.res_secs || new abap.types.Packed({length: 8, decimals: 2});
    let lv_stamp1 = new abap.types.Packed({length: 15, decimals: 0, qualifiedName: "TIMESTAMP"});
    let lv_stamp2 = new abap.types.Packed({length: 15, decimals: 0, qualifiedName: "TIMESTAMP"});
    abap.statements.convert({date: date1,time: time1}, {stamp: lv_stamp1});
    abap.statements.convert({date: date2,time: time2}, {stamp: lv_stamp2});
    res_secs.set((await this.subtract({tstmp1: lv_stamp1, tstmp2: lv_stamp2})));
  }
}
abap.Classes['CL_ABAP_TSTMP'] = cl_abap_tstmp;
export {cl_abap_tstmp};
//# sourceMappingURL=cl_abap_tstmp.clas.mjs.map