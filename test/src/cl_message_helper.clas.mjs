const {cx_root} = await import("./cx_root.clas.mjs");
// cl_message_helper.clas.abap
class cl_message_helper {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CL_MESSAGE_HELPER';
  static IMPLEMENTED_INTERFACES = [];
  static ATTRIBUTES = {"GC_FALLBACK": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "visibility": "I", "is_constant": "X", "is_class": "X"}};
  static METHODS = {"SET_MSG_VARS_FOR_IF_MSG": {"visibility": "U", "parameters": {"TEXT": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_MESSAGE", RTTIName: "\\INTERFACE=IF_MESSAGE"});}, "is_optional": " "}, "STRING": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}},
  "SET_MSG_VARS_FOR_CLIKE": {"visibility": "U", "parameters": {"TEXT": {"type": () => {return new abap.types.Character();}, "is_optional": " "}}},
  "GET_TEXT_FOR_MESSAGE": {"visibility": "U", "parameters": {"RESULT": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "TEXT": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_MESSAGE", RTTIName: "\\INTERFACE=IF_MESSAGE"});}, "is_optional": " "}}},
  "CHECK_MSG_KIND": {"visibility": "U", "parameters": {"MSG": {"type": () => {return new abap.types.ABAPObject({qualifiedName: undefined, RTTIName: undefined});}, "is_optional": " "}, "T100KEY": {"type": () => {return new abap.types.Structure({"msgid": new abap.types.Character(20, {}), "msgno": new abap.types.Numc({length: 3}), "attr1": new abap.types.Character(255, {}), "attr2": new abap.types.Character(255, {}), "attr3": new abap.types.Character(255, {}), "attr4": new abap.types.Character(255, {})}, "SCX_T100KEY", "SCX_T100KEY", {}, {});}, "is_optional": " "}, "TEXTID": {"type": () => {return new abap.types.Character(32, {"qualifiedName":"SOTR_CONC","ddicName":"SOTR_CONC","description":"SOTR_CONC"});}, "is_optional": " "}}},
  "GET_OTR_TEXT_RAW": {"visibility": "U", "parameters": {"TEXTID": {"type": () => {return new abap.types.Character(32, {"qualifiedName":"SOTR_CONC","ddicName":"SOTR_CONC","description":"SOTR_CONC"});}, "is_optional": " "}, "RESULT": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}},
  "REPLACE_TEXT_PARAMS": {"visibility": "U", "parameters": {"OBJ": {"type": () => {return new abap.types.ABAPObject({qualifiedName: undefined, RTTIName: undefined});}, "is_optional": " "}, "RESULT": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}}};
  constructor() {
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
    this.gc_fallback = cl_message_helper.gc_fallback;
  }
  async constructor_(INPUT) {
    if (super.constructor_) { await super.constructor_(INPUT); }
    return this;
  }
  async get_otr_text_raw(INPUT) {
    return cl_message_helper.get_otr_text_raw(INPUT);
  }
  static async get_otr_text_raw(INPUT) {
    let textid = INPUT?.textid;
    if (textid?.getQualifiedName === undefined || textid.getQualifiedName() !== "SOTR_CONC") { textid = undefined; }
    if (textid === undefined) { textid = new abap.types.Character(32, {"qualifiedName":"SOTR_CONC","ddicName":"SOTR_CONC","description":"SOTR_CONC"}).set(INPUT.textid); }
    let result = INPUT?.result || new abap.types.String({qualifiedName: "STRING"});
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
  }
  async replace_text_params(INPUT) {
    return cl_message_helper.replace_text_params(INPUT);
  }
  static async replace_text_params(INPUT) {
    let obj = INPUT?.obj;
    if (obj === undefined) { obj = new abap.types.ABAPObject({qualifiedName: undefined, RTTIName: undefined}).set(INPUT.obj); }
    let result = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.result) {result = INPUT.result;}
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
  }
  async get_text_for_message(INPUT) {
    return cl_message_helper.get_text_for_message(INPUT);
  }
  static async get_text_for_message(INPUT) {
    let result = new abap.types.String({qualifiedName: "STRING"});
    let text = INPUT?.text;
    if (text?.getQualifiedName === undefined || text.getQualifiedName() !== "IF_MESSAGE") { text = undefined; }
    if (text === undefined) { text = new abap.types.ABAPObject({qualifiedName: "IF_MESSAGE", RTTIName: "\\INTERFACE=IF_MESSAGE"}).set(INPUT.text); }
    let lv_msgid = new abap.types.Character(20, {"qualifiedName":"sy-msgid"});
    let lv_msgno = new abap.types.Numc({length: 3, qualifiedName: "sy-msgno"});
    let lv_msgv1 = new abap.types.Character(50, {"qualifiedName":"sy-msgv1"});
    let lv_msgv2 = new abap.types.Character(50, {"qualifiedName":"sy-msgv2"});
    let lv_msgv3 = new abap.types.Character(50, {"qualifiedName":"sy-msgv3"});
    let lv_msgv4 = new abap.types.Character(50, {"qualifiedName":"sy-msgv4"});
    if (text.get()?.if_t100_message$t100key === undefined) { result.set(this.gc_fallback); return result; };
    lv_msgid.set(text.get().if_t100_message$t100key.get().msgid);
    lv_msgno.set(text.get().if_t100_message$t100key.get().msgno);
    lv_msgv1.set(text.get()[text.get().if_t100_message$t100key.get().attr1.get().toLowerCase().replace("~", "$").trimEnd()] ? text.get()[text.get().if_t100_message$t100key.get().attr1.get().toLowerCase().replace("~", "$").trimEnd()].get() : "");
    lv_msgv2.set(text.get()[text.get().if_t100_message$t100key.get().attr2.get().toLowerCase().replace("~", "$").trimEnd()] ? text.get()[text.get().if_t100_message$t100key.get().attr2.get().toLowerCase().replace("~", "$").trimEnd()].get() : "");
    lv_msgv3.set(text.get()[text.get().if_t100_message$t100key.get().attr3.get().toLowerCase().replace("~", "$").trimEnd()] ? text.get()[text.get().if_t100_message$t100key.get().attr3.get().toLowerCase().replace("~", "$").trimEnd()].get() : "");
    lv_msgv4.set(text.get()[text.get().if_t100_message$t100key.get().attr4.get().toLowerCase().replace("~", "$").trimEnd()] ? text.get()[text.get().if_t100_message$t100key.get().attr4.get().toLowerCase().replace("~", "$").trimEnd()].get() : "");
    await abap.statements.message({into: result, id: lv_msgid, type: new abap.types.Character(1).set('I'), number: lv_msgno, with: [lv_msgv1,lv_msgv2,lv_msgv3,lv_msgv4]});
    return result;
  }
  async set_msg_vars_for_if_msg(INPUT) {
    return cl_message_helper.set_msg_vars_for_if_msg(INPUT);
  }
  static async set_msg_vars_for_if_msg(INPUT) {
    let text = INPUT?.text;
    if (text?.getQualifiedName === undefined || text.getQualifiedName() !== "IF_MESSAGE") { text = undefined; }
    if (text === undefined) { text = new abap.types.ABAPObject({qualifiedName: "IF_MESSAGE", RTTIName: "\\INTERFACE=IF_MESSAGE"}).set(INPUT.text); }
    let string = INPUT?.string || new abap.types.String({qualifiedName: "STRING"});
    if (abap.compare.initial(text)) {
      const unique21 = await (new abap.Classes['CX_SY_MESSAGE_ILLEGAL_TEXT']()).constructor_();
      unique21.EXTRA_CX = {"INTERNAL_FILENAME": "cl_message_helper.clas.abap","INTERNAL_LINE": 76};
      throw unique21;
    }
    string.set((await this.get_text_for_message({text: text})));
    if (abap.compare.ne(string, cl_message_helper.gc_fallback)) {
      abap.statements.clear(abap.builtin.sy.get().msgty);
      return;
    }
    string.set((await text.get().if_message$get_text()));
    if (abap.compare.initial(string)) {
      abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    }
    await this.set_msg_vars_for_clike({text: string});
  }
  async set_msg_vars_for_clike(INPUT) {
    return cl_message_helper.set_msg_vars_for_clike(INPUT);
  }
  static async set_msg_vars_for_clike(INPUT) {
    let text = INPUT?.text;
    let lv_char200 = new abap.types.Character(200, {});
    lv_char200.set(text);
    abap.builtin.sy.get().msgid.set(new abap.types.Character(2).set('00'));
    abap.builtin.sy.get().msgno.set(new abap.types.Character(3).set('001'));
    abap.builtin.sy.get().msgv1.set(lv_char200);
    if (abap.compare.eq(lv_char200.getOffset({offset: 49, length: 1}), abap.builtin.space)) {
      lv_char200.set(lv_char200.getOffset({offset: 49}));
    } else {
      lv_char200.set(text.getOffset({offset: 50}));
    }
    abap.builtin.sy.get().msgv2.set(lv_char200);
    if (abap.compare.eq(lv_char200.getOffset({offset: 49, length: 1}), abap.builtin.space)) {
      lv_char200.set(lv_char200.getOffset({offset: 49}));
    } else {
      lv_char200.set(lv_char200.getOffset({offset: 50}));
    }
    abap.builtin.sy.get().msgv3.set(lv_char200);
    if (abap.compare.eq(lv_char200.getOffset({offset: 49, length: 1}), abap.builtin.space)) {
      lv_char200.set(lv_char200.getOffset({offset: 49}));
    } else {
      lv_char200.set(lv_char200.getOffset({offset: 50}));
    }
    abap.builtin.sy.get().msgv4.set(lv_char200);
  }
  async check_msg_kind(INPUT) {
    return cl_message_helper.check_msg_kind(INPUT);
  }
  static async check_msg_kind(INPUT) {
    let msg = INPUT?.msg;
    if (msg === undefined) { msg = new abap.types.ABAPObject({qualifiedName: undefined, RTTIName: undefined}).set(INPUT.msg); }
    let t100key = INPUT?.t100key || new abap.types.Structure({"msgid": new abap.types.Character(20, {}), "msgno": new abap.types.Numc({length: 3}), "attr1": new abap.types.Character(255, {}), "attr2": new abap.types.Character(255, {}), "attr3": new abap.types.Character(255, {}), "attr4": new abap.types.Character(255, {})}, "SCX_T100KEY", "SCX_T100KEY", {}, {});
    let textid = INPUT?.textid || new abap.types.Character(32, {"qualifiedName":"SOTR_CONC","ddicName":"SOTR_CONC","description":"SOTR_CONC"});
    let li_t100_message = new abap.types.ABAPObject({qualifiedName: "IF_T100_MESSAGE", RTTIName: "\\INTERFACE=IF_T100_MESSAGE"});
    try {
      await abap.statements.cast(li_t100_message, msg);
      t100key.set(li_t100_message.get().if_t100_message$t100key);
    } catch (e) {
      if ((abap.Classes['CX_SY_MOVE_CAST_ERROR'] && e instanceof abap.Classes['CX_SY_MOVE_CAST_ERROR'])) {
        abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
      } else {
        throw e;
      }
    }
  }
}
abap.Classes['CL_MESSAGE_HELPER'] = cl_message_helper;
cl_message_helper.gc_fallback = new abap.types.String({qualifiedName: "STRING"});
cl_message_helper.gc_fallback.set('An exception was raised.');
export {cl_message_helper};
//# sourceMappingURL=cl_message_helper.clas.mjs.map