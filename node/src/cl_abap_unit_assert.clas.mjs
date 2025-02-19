await import("./cl_abap_unit_assert.clas.locals.mjs");
const {cx_root} = await import("./cx_root.clas.mjs");
// cl_abap_unit_assert.clas.abap
class cl_abap_unit_assert {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CL_ABAP_UNIT_ASSERT';
  static IMPLEMENTED_INTERFACES = [];
  static ATTRIBUTES = {};
  static METHODS = {"COMPARE_TABLES": {"visibility": "I", "parameters": {"ACT": {"type": () => {return new abap.types.Character(4);}, "is_optional": " "}, "EXP": {"type": () => {return new abap.types.Character(4);}, "is_optional": " "}}},
  "ASSERT_EQUALS": {"visibility": "U", "parameters": {"ACT": {"type": () => {return new abap.types.Character(4);}, "is_optional": " "}, "EXP": {"type": () => {return new abap.types.Character(4);}, "is_optional": " "}, "MSG": {"type": () => {return new abap.types.Character();}, "is_optional": " "}, "TOL": {"type": () => {return new abap.types.Float({qualifiedName: "F"});}, "is_optional": " "}, "QUIT": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}, "LEVEL": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}}},
  "ABORT": {"visibility": "U", "parameters": {"MSG": {"type": () => {return new abap.types.Character();}, "is_optional": " "}, "DETAIL": {"type": () => {return new abap.types.Character();}, "is_optional": " "}, "QUIT": {"type": () => {return new abap.types.Integer({qualifiedName: "INT1"});}, "is_optional": " "}}},
  "ASSERT_DIFFERS": {"visibility": "U", "parameters": {"ACT": {"type": () => {return new abap.types.Character();}, "is_optional": " "}, "EXP": {"type": () => {return new abap.types.Character();}, "is_optional": " "}, "MSG": {"type": () => {return new abap.types.Character();}, "is_optional": " "}, "QUIT": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}, "LEVEL": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}}},
  "ASSERT_NUMBER_BETWEEN": {"visibility": "U", "parameters": {"LOWER": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}, "UPPER": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}, "NUMBER": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}, "MSG": {"type": () => {return new abap.types.Character();}, "is_optional": " "}, "QUIT": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}, "LEVEL": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}}},
  "ASSERT_NOT_INITIAL": {"visibility": "U", "parameters": {"ACT": {"type": () => {return new abap.types.Character(4);}, "is_optional": " "}, "MSG": {"type": () => {return new abap.types.Character();}, "is_optional": " "}, "QUIT": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}, "LEVEL": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}}},
  "ASSERT_INITIAL": {"visibility": "U", "parameters": {"ACT": {"type": () => {return new abap.types.Character(4);}, "is_optional": " "}, "MSG": {"type": () => {return new abap.types.Character();}, "is_optional": " "}, "QUIT": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}, "LEVEL": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}}},
  "SKIP": {"visibility": "U", "parameters": {"MSG": {"type": () => {return new abap.types.Character();}, "is_optional": " "}, "DETAIL": {"type": () => {return new abap.types.Character();}, "is_optional": " "}}},
  "FAIL": {"visibility": "U", "parameters": {"MSG": {"type": () => {return new abap.types.Character();}, "is_optional": " "}, "QUIT": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}, "LEVEL": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}, "DETAIL": {"type": () => {return new abap.types.Character();}, "is_optional": " "}}},
  "ASSERT_SUBRC": {"visibility": "U", "parameters": {"EXP": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}, "ACT": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}, "MSG": {"type": () => {return new abap.types.Character();}, "is_optional": " "}, "QUIT": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}, "LEVEL": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}}},
  "ASSERT_TRUE": {"visibility": "U", "parameters": {"ACT": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});}, "is_optional": " "}, "MSG": {"type": () => {return new abap.types.Character();}, "is_optional": " "}, "QUIT": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}, "LEVEL": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}}},
  "ASSERT_FALSE": {"visibility": "U", "parameters": {"ACT": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});}, "is_optional": " "}, "MSG": {"type": () => {return new abap.types.Character();}, "is_optional": " "}, "QUIT": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}, "LEVEL": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}}},
  "ASSERT_CHAR_CP": {"visibility": "U", "parameters": {"ACT": {"type": () => {return new abap.types.Character();}, "is_optional": " "}, "EXP": {"type": () => {return new abap.types.Character();}, "is_optional": " "}, "MSG": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "QUIT": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}, "LEVEL": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}}},
  "ASSERT_CHAR_NP": {"visibility": "U", "parameters": {"ACT": {"type": () => {return new abap.types.Character();}, "is_optional": " "}, "EXP": {"type": () => {return new abap.types.Character();}, "is_optional": " "}, "MSG": {"type": () => {return new abap.types.Character();}, "is_optional": " "}, "QUIT": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}, "LEVEL": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}}},
  "ASSERT_BOUND": {"visibility": "U", "parameters": {"ACT": {"type": () => {return new abap.types.Character(4);}, "is_optional": " "}, "MSG": {"type": () => {return new abap.types.Character();}, "is_optional": " "}, "QUIT": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}, "LEVEL": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}}},
  "ASSERT_NOT_BOUND": {"visibility": "U", "parameters": {"ACT": {"type": () => {return new abap.types.Character(4);}, "is_optional": " "}, "MSG": {"type": () => {return new abap.types.Character();}, "is_optional": " "}, "QUIT": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}, "LEVEL": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}}},
  "ASSERT_TEXT_MATCHES": {"visibility": "U", "parameters": {"PATTERN": {"type": () => {return new abap.types.Character();}, "is_optional": " "}, "TEXT": {"type": () => {return new abap.types.Character();}, "is_optional": " "}, "MSG": {"type": () => {return new abap.types.Character();}, "is_optional": " "}, "QUIT": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}, "LEVEL": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}}}};
  constructor() {
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
  }
  async constructor_(INPUT) {
    if (super.constructor_) { await super.constructor_(INPUT); }
    return this;
  }
  async compare_tables(INPUT) {
    return cl_abap_unit_assert.compare_tables(INPUT);
  }
  static async compare_tables(INPUT) {
    let act = INPUT?.act;
    let exp = INPUT?.exp;
    let index = new abap.types.Integer({qualifiedName: "I"});
    let type1 = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_TABLEDESCR", RTTIName: "\\CLASS=CL_ABAP_TABLEDESCR"});
    let type2 = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_TABLEDESCR", RTTIName: "\\CLASS=CL_ABAP_TABLEDESCR"});
    let lv_match = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    let fs_tab1_ = new abap.types.FieldSymbol(abap.types.TableFactory.construct(new abap.types.Character(4), {"withHeader":false,"keyType":"DEFAULT"}));
    let fs_row1_ = new abap.types.FieldSymbol(new abap.types.Character(4));
    let fs_tab2_ = new abap.types.FieldSymbol(abap.types.TableFactory.construct(new abap.types.Character(4), {"withHeader":false,"keyType":"DEFAULT"}));
    let fs_row2_ = new abap.types.FieldSymbol(new abap.types.Character(4));
    if (abap.compare.ne(abap.builtin.lines({val: act}), abap.builtin.lines({val: exp}))) {
      const unique151 = await (new abap.Classes['KERNEL_CX_ASSERT']()).constructor_({msg: new abap.types.String().set(`Expected table to contain ${abap.templateFormatting(abap.builtin.lines({val: exp}))} rows, got ${abap.templateFormatting(abap.builtin.lines({val: act}))}`)});
      unique151.EXTRA_CX = {"INTERNAL_FILENAME": "cl_abap_unit_assert.clas.abap","INTERNAL_LINE": 162};
      throw unique151;
    }
    abap.statements.assign({target: fs_tab1_, source: act});
    abap.statements.assign({target: fs_tab2_, source: exp});
    await abap.statements.cast(type1, (await abap.Classes['CL_ABAP_TYPEDESCR'].describe_by_data({p_data: act})));
    await abap.statements.cast(type2, (await abap.Classes['CL_ABAP_TYPEDESCR'].describe_by_data({p_data: exp})));
    if (abap.compare.eq(type1.get().table_kind, abap.Classes['CL_ABAP_TABLEDESCR'].tablekind_hashed) || abap.compare.eq(type2.get().table_kind, abap.Classes['CL_ABAP_TABLEDESCR'].tablekind_hashed)) {
      for await (const unique152 of abap.statements.loop(fs_tab1_)) {
        fs_row1_.assign(unique152);
        lv_match.set(abap.builtin.abap_false);
        for await (const unique153 of abap.statements.loop(fs_tab2_)) {
          fs_row2_.assign(unique153);
          try {
            await this.assert_equals({act: fs_row1_, exp: fs_row2_});
            lv_match.set(abap.builtin.abap_true);
            break;
          } catch (e) {
            if ((abap.Classes['KERNEL_CX_ASSERT'] && e instanceof abap.Classes['KERNEL_CX_ASSERT'])) {
            } else {
              throw e;
            }
          }
        }
        if (abap.compare.eq(lv_match, abap.builtin.abap_false)) {
          const unique154 = await (new abap.Classes['KERNEL_CX_ASSERT']()).constructor_({msg: new abap.types.String().set(`Hashed table contents differs`)});
          unique154.EXTRA_CX = {"INTERNAL_FILENAME": "cl_abap_unit_assert.clas.abap","INTERNAL_LINE": 188};
          throw unique154;
        }
      }
    } else {
      const indexBackup1 = abap.builtin.sy.get().index.get();
      const unique155 = abap.builtin.lines({val: act}).get();
      for (let unique156 = 0; unique156 < unique155; unique156++) {
        abap.builtin.sy.get().index.set(unique156 + 1);
        index.set(abap.builtin.sy.get().index);
        abap.statements.readTable(fs_tab1_,{index: index,
          assigning: fs_row1_});
        await this.assert_subrc();
        abap.statements.readTable(fs_tab2_,{index: index,
          assigning: fs_row2_});
        await this.assert_subrc();
        await this.assert_equals({act: fs_row1_, exp: fs_row2_});
      }
      abap.builtin.sy.get().index.set(indexBackup1);
    }
  }
  async assert_text_matches(INPUT) {
    return cl_abap_unit_assert.assert_text_matches(INPUT);
  }
  static async assert_text_matches(INPUT) {
    let pattern = INPUT?.pattern;
    let text = INPUT?.text;
    let msg = INPUT?.msg || new abap.types.Character();
    let quit = new abap.types.Integer({qualifiedName: "I"});
    if (INPUT && INPUT.quit) {quit.set(INPUT.quit);}
    let level = new abap.types.Integer({qualifiedName: "I"});
    if (INPUT && INPUT.level) {level.set(INPUT.level);}
    let lv_match = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    lv_match.set(abap.builtin.boolc({val: abap.builtin.contains({val: text, regex: pattern})}));
    if (abap.compare.eq(lv_match, abap.builtin.abap_false)) {
      const unique157 = await (new abap.Classes['KERNEL_CX_ASSERT']()).constructor_({expected: pattern, actual: text, msg: msg});
      unique157.EXTRA_CX = {"INTERNAL_FILENAME": "cl_abap_unit_assert.clas.abap","INTERNAL_LINE": 214};
      throw unique157;
    }
  }
  async abort(INPUT) {
    return cl_abap_unit_assert.abort(INPUT);
  }
  static async abort(INPUT) {
    let msg = INPUT?.msg || new abap.types.Character();
    let detail = INPUT?.detail || new abap.types.Character();
    let quit = new abap.types.Integer({qualifiedName: "INT1"});
    if (INPUT && INPUT.quit) {quit.set(INPUT.quit);}
    if (INPUT === undefined || INPUT.quit === undefined) {quit = abap.IntegerFactory.get(2);}
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
  }
  async assert_bound(INPUT) {
    return cl_abap_unit_assert.assert_bound(INPUT);
  }
  static async assert_bound(INPUT) {
    let act = INPUT?.act;
    let msg = INPUT?.msg || new abap.types.Character();
    let quit = new abap.types.Integer({qualifiedName: "I"});
    if (INPUT && INPUT.quit) {quit.set(INPUT.quit);}
    let level = new abap.types.Integer({qualifiedName: "I"});
    if (INPUT && INPUT.level) {level.set(INPUT.level);}
    if (abap.compare.initial(act)) {
      const unique158 = await (new abap.Classes['KERNEL_CX_ASSERT']()).constructor_({msg: new abap.types.String().set(`Expected value to be bound`)});
      unique158.EXTRA_CX = {"INTERNAL_FILENAME": "cl_abap_unit_assert.clas.abap","INTERNAL_LINE": 228};
      throw unique158;
    }
  }
  async assert_not_bound(INPUT) {
    return cl_abap_unit_assert.assert_not_bound(INPUT);
  }
  static async assert_not_bound(INPUT) {
    let act = INPUT?.act;
    let msg = INPUT?.msg || new abap.types.Character();
    let quit = new abap.types.Integer({qualifiedName: "I"});
    if (INPUT && INPUT.quit) {quit.set(INPUT.quit);}
    let level = new abap.types.Integer({qualifiedName: "I"});
    if (INPUT && INPUT.level) {level.set(INPUT.level);}
    if (abap.compare.initial(act) === false) {
      const unique159 = await (new abap.Classes['KERNEL_CX_ASSERT']()).constructor_({msg: new abap.types.String().set(`Expected value to not be bound`)});
      unique159.EXTRA_CX = {"INTERNAL_FILENAME": "cl_abap_unit_assert.clas.abap","INTERNAL_LINE": 236};
      throw unique159;
    }
  }
  async assert_char_cp(INPUT) {
    return cl_abap_unit_assert.assert_char_cp(INPUT);
  }
  static async assert_char_cp(INPUT) {
    let act = INPUT?.act;
    let exp = INPUT?.exp;
    let msg = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.msg) {msg.set(INPUT.msg);}
    let quit = new abap.types.Integer({qualifiedName: "I"});
    if (INPUT && INPUT.quit) {quit.set(INPUT.quit);}
    let level = new abap.types.Integer({qualifiedName: "I"});
    if (INPUT && INPUT.level) {level.set(INPUT.level);}
    if (abap.compare.np(act, exp)) {
      const unique160 = await (new abap.Classes['KERNEL_CX_ASSERT']()).constructor_({expected: exp, actual: act, msg: msg});
      unique160.EXTRA_CX = {"INTERNAL_FILENAME": "cl_abap_unit_assert.clas.abap","INTERNAL_LINE": 244};
      throw unique160;
    }
  }
  async assert_char_np(INPUT) {
    return cl_abap_unit_assert.assert_char_np(INPUT);
  }
  static async assert_char_np(INPUT) {
    let act = INPUT?.act;
    let exp = INPUT?.exp;
    let msg = INPUT?.msg || new abap.types.Character();
    let quit = new abap.types.Integer({qualifiedName: "I"});
    if (INPUT && INPUT.quit) {quit.set(INPUT.quit);}
    let level = new abap.types.Integer({qualifiedName: "I"});
    if (INPUT && INPUT.level) {level.set(INPUT.level);}
    if (abap.compare.cp(act, exp)) {
      const unique161 = await (new abap.Classes['KERNEL_CX_ASSERT']()).constructor_({msg: new abap.types.String().set(`Actual: ${abap.templateFormatting(act)}`)});
      unique161.EXTRA_CX = {"INTERNAL_FILENAME": "cl_abap_unit_assert.clas.abap","INTERNAL_LINE": 254};
      throw unique161;
    }
  }
  async fail(INPUT) {
    return cl_abap_unit_assert.fail(INPUT);
  }
  static async fail(INPUT) {
    let msg = INPUT?.msg || new abap.types.Character();
    let quit = new abap.types.Integer({qualifiedName: "I"});
    if (INPUT && INPUT.quit) {quit.set(INPUT.quit);}
    let level = new abap.types.Integer({qualifiedName: "I"});
    if (INPUT && INPUT.level) {level.set(INPUT.level);}
    let detail = INPUT?.detail || new abap.types.Character();
    const unique162 = await (new abap.Classes['KERNEL_CX_ASSERT']()).constructor_({msg: msg});
    unique162.EXTRA_CX = {"INTERNAL_FILENAME": "cl_abap_unit_assert.clas.abap","INTERNAL_LINE": 261};
    throw unique162;
  }
  async skip(INPUT) {
    return cl_abap_unit_assert.skip(INPUT);
  }
  static async skip(INPUT) {
    let msg = INPUT?.msg;
    let detail = INPUT?.detail || new abap.types.Character();
    return;
  }
  async assert_differs(INPUT) {
    return cl_abap_unit_assert.assert_differs(INPUT);
  }
  static async assert_differs(INPUT) {
    let act = INPUT?.act;
    let exp = INPUT?.exp;
    let msg = INPUT?.msg || new abap.types.Character();
    let quit = new abap.types.Integer({qualifiedName: "I"});
    if (INPUT && INPUT.quit) {quit.set(INPUT.quit);}
    let level = new abap.types.Integer({qualifiedName: "I"});
    if (INPUT && INPUT.level) {level.set(INPUT.level);}
    try {
      await this.assert_equals({act: act, exp: exp});
      const unique163 = await (new abap.Classes['KERNEL_CX_ASSERT']()).constructor_({msg: new abap.types.String().set(`Expected different values`), actual: act, expected: exp});
      unique163.EXTRA_CX = {"INTERNAL_FILENAME": "cl_abap_unit_assert.clas.abap","INTERNAL_LINE": 275};
      throw unique163;
    } catch (e) {
      if ((abap.Classes['KERNEL_CX_ASSERT'] && e instanceof abap.Classes['KERNEL_CX_ASSERT'])) {
        return;
      } else {
        throw e;
      }
    }
  }
  async assert_true(INPUT) {
    return cl_abap_unit_assert.assert_true(INPUT);
  }
  static async assert_true(INPUT) {
    let act = INPUT?.act;
    if (act?.getQualifiedName === undefined || act.getQualifiedName() !== "ABAP_BOOL") { act = undefined; }
    if (act === undefined) { act = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}).set(INPUT.act); }
    let msg = INPUT?.msg || new abap.types.Character();
    let quit = new abap.types.Integer({qualifiedName: "I"});
    if (INPUT && INPUT.quit) {quit.set(INPUT.quit);}
    let level = new abap.types.Integer({qualifiedName: "I"});
    if (INPUT && INPUT.level) {level.set(INPUT.level);}
    if (abap.compare.ne(act, abap.builtin.abap_true)) {
      const unique164 = await (new abap.Classes['KERNEL_CX_ASSERT']()).constructor_({msg: new abap.types.String().set(`Expected abap_true`)});
      unique164.EXTRA_CX = {"INTERNAL_FILENAME": "cl_abap_unit_assert.clas.abap","INTERNAL_LINE": 287};
      throw unique164;
    }
  }
  async assert_false(INPUT) {
    return cl_abap_unit_assert.assert_false(INPUT);
  }
  static async assert_false(INPUT) {
    let act = INPUT?.act;
    if (act?.getQualifiedName === undefined || act.getQualifiedName() !== "ABAP_BOOL") { act = undefined; }
    if (act === undefined) { act = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}).set(INPUT.act); }
    let msg = INPUT?.msg || new abap.types.Character();
    let quit = new abap.types.Integer({qualifiedName: "I"});
    if (INPUT && INPUT.quit) {quit.set(INPUT.quit);}
    let level = new abap.types.Integer({qualifiedName: "I"});
    if (INPUT && INPUT.level) {level.set(INPUT.level);}
    if (abap.compare.ne(act, abap.builtin.abap_false)) {
      const unique165 = await (new abap.Classes['KERNEL_CX_ASSERT']()).constructor_({msg: new abap.types.String().set(`Expected abap_false`)});
      unique165.EXTRA_CX = {"INTERNAL_FILENAME": "cl_abap_unit_assert.clas.abap","INTERNAL_LINE": 295};
      throw unique165;
    }
  }
  async assert_equals(INPUT) {
    return cl_abap_unit_assert.assert_equals(INPUT);
  }
  static async assert_equals(INPUT) {
    let act = INPUT?.act;
    let exp = INPUT?.exp;
    let msg = INPUT?.msg || new abap.types.Character();
    let tol = new abap.types.Float({qualifiedName: "F"});
    if (INPUT && INPUT.tol) {tol.set(INPUT.tol);}
    let quit = new abap.types.Integer({qualifiedName: "I"});
    if (INPUT && INPUT.quit) {quit.set(INPUT.quit);}
    let level = new abap.types.Integer({qualifiedName: "I"});
    if (INPUT && INPUT.level) {level.set(INPUT.level);}
    let type1 = new abap.types.Character(1, {});
    let type2 = new abap.types.Character(1, {});
    let diff = new abap.types.Float({qualifiedName: "F"});
    let lv_exp = new abap.types.String({qualifiedName: "STRING"});
    let lv_act = new abap.types.String({qualifiedName: "STRING"});
    let lv_msg = new abap.types.String({qualifiedName: "STRING"});
    abap.statements.describe({field: act, type: type1});
    abap.statements.describe({field: exp, type: type2});
    if (abap.compare.ca(type1, new abap.types.Character(11).set('CgyIFPDTXN8'))) {
      if (abap.compare.initial(type2) === false) {
        if (abap.compare.na(type2, new abap.types.Character(11).set('CgyIFPDTXN8'))) {
          const unique166 = await (new abap.Classes['KERNEL_CX_ASSERT']()).constructor_({msg: new abap.types.String().set(`Unexpected types`)});
          unique166.EXTRA_CX = {"INTERNAL_FILENAME": "cl_abap_unit_assert.clas.abap","INTERNAL_LINE": 316};
          throw unique166;
        }
      }
    } else if (abap.compare.initial(type1) === false && abap.compare.initial(type2) === false) {
      if (abap.compare.ne(type1, type2)) {
        const unique167 = await (new abap.Classes['KERNEL_CX_ASSERT']()).constructor_({msg: new abap.types.String().set(`Unexpected types`)});
        unique167.EXTRA_CX = {"INTERNAL_FILENAME": "cl_abap_unit_assert.clas.abap","INTERNAL_LINE": 324};
        throw unique167;
      }
    }
    if (abap.compare.eq(type1, new abap.types.Character(1).set('h'))) {
      await this.compare_tables({act: act, exp: exp});
    } else if (INPUT && INPUT.tol) {
      diff.set(abap.operators.minus(exp,act));
      if (abap.compare.ge(diff, tol)) {
        const unique168 = await (new abap.Classes['KERNEL_CX_ASSERT']()).constructor_();
        unique168.EXTRA_CX = {"INTERNAL_FILENAME": "cl_abap_unit_assert.clas.abap","INTERNAL_LINE": 339};
        throw unique168;
      }
    } else if (abap.compare.eq(type1, new abap.types.Character(1).set('l'))) {
      await this.assert_equals({act: act.dereference(), exp: exp.dereference()});
    } else if (abap.compare.ne(act, exp)) {
      lv_act.set((await abap.Classes['CLAS-CL_ABAP_UNIT_ASSERT-LCL_DUMP'].to_string({iv_val: act})));
      lv_exp.set((await abap.Classes['CLAS-CL_ABAP_UNIT_ASSERT-LCL_DUMP'].to_string({iv_val: exp})));
      if (abap.compare.ne(msg, new abap.types.Character(1).set(''))) {
        lv_msg.set(msg);
      } else {
        lv_msg.set(new abap.types.String().set(`Expected '${abap.templateFormatting(lv_exp)}', got '${abap.templateFormatting(lv_act)}'`));
      }
      const unique169 = await (new abap.Classes['KERNEL_CX_ASSERT']()).constructor_({msg: lv_msg, actual: lv_act, expected: lv_exp});
      unique169.EXTRA_CX = {"INTERNAL_FILENAME": "cl_abap_unit_assert.clas.abap","INTERNAL_LINE": 353};
      throw unique169;
    }
  }
  async assert_not_initial(INPUT) {
    return cl_abap_unit_assert.assert_not_initial(INPUT);
  }
  static async assert_not_initial(INPUT) {
    let act = INPUT?.act;
    let msg = INPUT?.msg || new abap.types.Character();
    let quit = new abap.types.Integer({qualifiedName: "I"});
    if (INPUT && INPUT.quit) {quit.set(INPUT.quit);}
    let level = new abap.types.Integer({qualifiedName: "I"});
    if (INPUT && INPUT.level) {level.set(INPUT.level);}
    let lv_msg = new abap.types.String({qualifiedName: "STRING"});
    if (abap.compare.initial(act)) {
      lv_msg.set(msg);
      if (abap.compare.initial(lv_msg)) {
        lv_msg.set(new abap.types.String().set(`Expected non initial value`));
      }
      const unique170 = await (new abap.Classes['KERNEL_CX_ASSERT']()).constructor_({msg: lv_msg});
      unique170.EXTRA_CX = {"INTERNAL_FILENAME": "cl_abap_unit_assert.clas.abap","INTERNAL_LINE": 368};
      throw unique170;
    }
  }
  async assert_initial(INPUT) {
    return cl_abap_unit_assert.assert_initial(INPUT);
  }
  static async assert_initial(INPUT) {
    let act = INPUT?.act;
    let msg = INPUT?.msg || new abap.types.Character();
    let quit = new abap.types.Integer({qualifiedName: "I"});
    if (INPUT && INPUT.quit) {quit.set(INPUT.quit);}
    let level = new abap.types.Integer({qualifiedName: "I"});
    if (INPUT && INPUT.level) {level.set(INPUT.level);}
    let lv_msg = new abap.types.String({qualifiedName: "STRING"});
    if (abap.compare.initial(act) === false) {
      lv_msg.set(msg);
      if (abap.compare.initial(lv_msg)) {
        lv_msg.set(new abap.types.String().set(`Expected initial value`));
      }
      const unique171 = await (new abap.Classes['KERNEL_CX_ASSERT']()).constructor_({msg: lv_msg});
      unique171.EXTRA_CX = {"INTERNAL_FILENAME": "cl_abap_unit_assert.clas.abap","INTERNAL_LINE": 381};
      throw unique171;
    }
  }
  async assert_subrc(INPUT) {
    return cl_abap_unit_assert.assert_subrc(INPUT);
  }
  static async assert_subrc(INPUT) {
    let exp = new abap.types.Integer({qualifiedName: "I"});
    if (INPUT && INPUT.exp) {exp.set(INPUT.exp);}
    if (INPUT === undefined || INPUT.exp === undefined) {exp = abap.IntegerFactory.get(0);}
    let act = new abap.types.Integer({qualifiedName: "I"});
    if (INPUT && INPUT.act) {act.set(INPUT.act);}
    if (INPUT === undefined || INPUT.act === undefined) {act = abap.builtin.sy.get().subrc;}
    let msg = INPUT?.msg || new abap.types.Character();
    let quit = new abap.types.Integer({qualifiedName: "I"});
    if (INPUT && INPUT.quit) {quit.set(INPUT.quit);}
    let level = new abap.types.Integer({qualifiedName: "I"});
    if (INPUT && INPUT.level) {level.set(INPUT.level);}
    let lv_msg = new abap.types.String({qualifiedName: "STRING"});
    if (abap.compare.ne(act, exp)) {
      lv_msg.set(msg);
      if (abap.compare.initial(lv_msg)) {
        lv_msg.set(new abap.types.String().set(`Expected sy-subrc to equal ${abap.templateFormatting(exp)}, got ${abap.templateFormatting(act)}`));
      }
      const unique172 = await (new abap.Classes['KERNEL_CX_ASSERT']()).constructor_({msg: lv_msg});
      unique172.EXTRA_CX = {"INTERNAL_FILENAME": "cl_abap_unit_assert.clas.abap","INTERNAL_LINE": 394};
      throw unique172;
    }
  }
  async assert_number_between(INPUT) {
    return cl_abap_unit_assert.assert_number_between(INPUT);
  }
  static async assert_number_between(INPUT) {
    let lower = INPUT?.lower;
    if (lower?.getQualifiedName === undefined || lower.getQualifiedName() !== "I") { lower = undefined; }
    if (lower === undefined) { lower = new abap.types.Integer({qualifiedName: "I"}).set(INPUT.lower); }
    let upper = INPUT?.upper;
    if (upper?.getQualifiedName === undefined || upper.getQualifiedName() !== "I") { upper = undefined; }
    if (upper === undefined) { upper = new abap.types.Integer({qualifiedName: "I"}).set(INPUT.upper); }
    let number = INPUT?.number;
    if (number?.getQualifiedName === undefined || number.getQualifiedName() !== "I") { number = undefined; }
    if (number === undefined) { number = new abap.types.Integer({qualifiedName: "I"}).set(INPUT.number); }
    let msg = INPUT?.msg || new abap.types.Character();
    let quit = new abap.types.Integer({qualifiedName: "I"});
    if (INPUT && INPUT.quit) {quit.set(INPUT.quit);}
    let level = new abap.types.Integer({qualifiedName: "I"});
    if (INPUT && INPUT.level) {level.set(INPUT.level);}
    if (abap.compare.lt(number, lower) || abap.compare.gt(number, upper)) {
      const unique173 = await (new abap.Classes['KERNEL_CX_ASSERT']()).constructor_();
      unique173.EXTRA_CX = {"INTERNAL_FILENAME": "cl_abap_unit_assert.clas.abap","INTERNAL_LINE": 402};
      throw unique173;
    }
  }
}
abap.Classes['CL_ABAP_UNIT_ASSERT'] = cl_abap_unit_assert;
export {cl_abap_unit_assert};
//# sourceMappingURL=cl_abap_unit_assert.clas.mjs.map