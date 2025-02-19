const {cx_root} = await import("./cx_root.clas.mjs");
// cl_gdt_conversion.clas.abap
class cl_gdt_conversion {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CL_GDT_CONVERSION';
  static IMPLEMENTED_INTERFACES = [];
  static ATTRIBUTES = {};
  static METHODS = {"LANGUAGE_CODE_OUTBOUND": {"visibility": "U", "parameters": {"IM_VALUE": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"SPRAS","ddicName":"SPRAS","description":"SPRAS"});}, "is_optional": " "}, "EX_VALUE": {"type": () => {return new abap.types.Character(2, {"qualifiedName":"LAISO","ddicName":"LAISO","description":"LAISO"});}, "is_optional": " "}}},
  "LANGUAGE_CODE_INBOUND": {"visibility": "U", "parameters": {"IM_VALUE": {"type": () => {return new abap.types.Character();}, "is_optional": " "}, "EX_VALUE": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"SPRAS","ddicName":"SPRAS","description":"SPRAS"});}, "is_optional": " "}}},
  "AMOUNT_OUTBOUND": {"visibility": "U", "parameters": {"IM_VALUE": {"type": () => {return new abap.types.Packed({length: 1, decimals: 0});}, "is_optional": " "}, "IM_CURRENCY_CODE": {"type": () => {return new abap.types.Character();}, "is_optional": " "}, "EX_VALUE": {"type": () => {return new abap.types.Packed({length: 1, decimals: 0});}, "is_optional": " "}}},
  "COUNTRY_CODE_OUTBOUND": {"visibility": "U", "parameters": {"IM_VALUE": {"type": () => {return new abap.types.Character(3, {"qualifiedName":"LAND1","ddicName":"LAND1","description":"LAND1"});}, "is_optional": " "}, "EX_VALUE": {"type": () => {return new abap.types.Character();}, "is_optional": " "}}},
  "DATE_TIME_INBOUND": {"visibility": "U", "parameters": {"IM_VALUE": {"type": () => {return new abap.types.Character();}, "is_optional": " "}, "EX_VALUE_SHORT": {"type": () => {return new abap.types.Packed({length: 15, decimals: 0, qualifiedName: "TIMESTAMP"});}, "is_optional": " "}}},
  "UNIT_CODE_INBOUND": {"visibility": "U", "parameters": {"IM_VALUE": {"type": () => {return new abap.types.Character();}, "is_optional": " "}, "EX_VALUE": {"type": () => {return new abap.types.Character(3, {"qualifiedName":"MSEHI","ddicName":"MSEHI","description":"UOM"});}, "is_optional": " "}}},
  "UNIT_CODE_OUTBOUND": {"visibility": "U", "parameters": {"IM_VALUE": {"type": () => {return new abap.types.Character(3, {"qualifiedName":"MSEHI","ddicName":"MSEHI","description":"UOM"});}, "is_optional": " "}, "EX_VALUE": {"type": () => {return new abap.types.Character();}, "is_optional": " "}}}};
  constructor() {
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
  }
  async constructor_(INPUT) {
    if (super.constructor_) { await super.constructor_(INPUT); }
    return this;
  }
  async amount_outbound(INPUT) {
    return cl_gdt_conversion.amount_outbound(INPUT);
  }
  static async amount_outbound(INPUT) {
    let im_value = INPUT?.im_value;
    if (im_value === undefined) { im_value = new abap.types.Packed({length: 1, decimals: 0}).set(INPUT.im_value); }
    let im_currency_code = INPUT?.im_currency_code;
    let ex_value = INPUT?.ex_value || new abap.types.Packed({length: 1, decimals: 0});
    let unique25 = im_currency_code;
    if (abap.compare.eq(unique25, new abap.types.Character(3).set('DKK')) || abap.compare.eq(unique25, new abap.types.Character(3).set('EUR')) || abap.compare.eq(unique25, new abap.types.Character(3).set('USD'))) {
      ex_value.set(im_value);
    } else if (abap.compare.eq(unique25, new abap.types.Character(3).set('VND'))) {
      ex_value.set(abap.operators.multiply(im_value,abap.IntegerFactory.get(100)));
    } else {
      abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    }
  }
  async language_code_inbound(INPUT) {
    return cl_gdt_conversion.language_code_inbound(INPUT);
  }
  static async language_code_inbound(INPUT) {
    let im_value = INPUT?.im_value;
    let ex_value = INPUT?.ex_value || new abap.types.Character(1, {"qualifiedName":"SPRAS","ddicName":"SPRAS","description":"SPRAS"});
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
  }
  async unit_code_outbound(INPUT) {
    return cl_gdt_conversion.unit_code_outbound(INPUT);
  }
  static async unit_code_outbound(INPUT) {
    let im_value = INPUT?.im_value;
    if (im_value?.getQualifiedName === undefined || im_value.getQualifiedName() !== "MSEHI") { im_value = undefined; }
    if (im_value === undefined) { im_value = new abap.types.Character(3, {"qualifiedName":"MSEHI","ddicName":"MSEHI","description":"UOM"}).set(INPUT.im_value); }
    let ex_value = INPUT?.ex_value || new abap.types.Character();
    let unique26 = im_value;
    if (abap.compare.eq(unique26, new abap.types.Character(1).set(''))) {
      const unique27 = await (new abap.Classes['CX_GDT_CONVERSION']()).constructor_();
      unique27.EXTRA_CX = {"INTERNAL_FILENAME": "cl_gdt_conversion.clas.abap","INTERNAL_LINE": 81};
      throw unique27;
    } else if (abap.compare.eq(unique26, new abap.types.Character(2).set('ST'))) {
      ex_value.set(new abap.types.Character(3).set('PCE'));
    } else if (abap.compare.eq(unique26, new abap.types.Character(2).set('KG'))) {
      ex_value.set(new abap.types.Character(3).set('KGM'));
    } else if (abap.compare.eq(unique26, new abap.types.Character(3).set('CDM'))) {
      ex_value.set(new abap.types.Character(3).set('DMQ'));
    } else {
      abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    }
  }
  async country_code_outbound(INPUT) {
    return cl_gdt_conversion.country_code_outbound(INPUT);
  }
  static async country_code_outbound(INPUT) {
    let im_value = INPUT?.im_value;
    if (im_value?.getQualifiedName === undefined || im_value.getQualifiedName() !== "LAND1") { im_value = undefined; }
    if (im_value === undefined) { im_value = new abap.types.Character(3, {"qualifiedName":"LAND1","ddicName":"LAND1","description":"LAND1"}).set(INPUT.im_value); }
    let ex_value = INPUT?.ex_value || new abap.types.Character();
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
  }
  async date_time_inbound(INPUT) {
    return cl_gdt_conversion.date_time_inbound(INPUT);
  }
  static async date_time_inbound(INPUT) {
    let im_value = INPUT?.im_value;
    let ex_value_short = INPUT?.ex_value_short || new abap.types.Packed({length: 15, decimals: 0, qualifiedName: "TIMESTAMP"});
    let lv_str = new abap.types.String({qualifiedName: "STRING"});
    if (abap.compare.np(im_value, new abap.types.Character(2).set('*Z'))) {
      abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(30).set('todo, only handles UTC for now')));
    }
    lv_str.set(im_value);
    abap.statements.replace({target: lv_str, all: true, with: new abap.types.Character(1).set(''), of: new abap.types.Character(1).set('-')});
    abap.statements.replace({target: lv_str, all: true, with: new abap.types.Character(1).set(''), of: new abap.types.Character(1).set(':')});
    abap.statements.replace({target: lv_str, all: true, with: new abap.types.Character(1).set(''), of: new abap.types.Character(1).set('T')});
    abap.statements.replace({target: lv_str, all: true, with: new abap.types.Character(1).set(''), of: new abap.types.Character(1).set('Z')});
    ex_value_short.set(lv_str);
  }
  async unit_code_inbound(INPUT) {
    return cl_gdt_conversion.unit_code_inbound(INPUT);
  }
  static async unit_code_inbound(INPUT) {
    let im_value = INPUT?.im_value;
    let ex_value = INPUT?.ex_value || new abap.types.Character(3, {"qualifiedName":"MSEHI","ddicName":"MSEHI","description":"UOM"});
    let unique28 = im_value;
    if (abap.compare.eq(unique28, new abap.types.Character(3).set('MTR'))) {
      ex_value.set(new abap.types.Character(1).set('M'));
    } else if (abap.compare.eq(unique28, new abap.types.Character(3).set('PCE'))) {
      ex_value.set(new abap.types.Character(2).set('PC'));
    } else if (abap.compare.eq(unique28, new abap.types.Character(3).set('KGM'))) {
      ex_value.set(new abap.types.Character(2).set('KG'));
    } else if (abap.compare.eq(unique28, new abap.types.Character(3).set('LTR'))) {
      ex_value.set(new abap.types.Character(1).set('L'));
    } else {
      abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    }
  }
  async language_code_outbound(INPUT) {
    return cl_gdt_conversion.language_code_outbound(INPUT);
  }
  static async language_code_outbound(INPUT) {
    let im_value = INPUT?.im_value;
    if (im_value?.getQualifiedName === undefined || im_value.getQualifiedName() !== "SPRAS") { im_value = undefined; }
    if (im_value === undefined) { im_value = new abap.types.Character(1, {"qualifiedName":"SPRAS","ddicName":"SPRAS","description":"SPRAS"}).set(INPUT.im_value); }
    let ex_value = INPUT?.ex_value || new abap.types.Character(2, {"qualifiedName":"LAISO","ddicName":"LAISO","description":"LAISO"});
    try {
      ex_value.set(await abap.Classes['CL_I18N_LANGUAGES'].sap1_to_sap2({im_lang_sap1: im_value}));
      abap.builtin.sy.get().subrc.set(0);
    } catch (e) {
      if (e.classic) {
          switch (e.classic.toUpperCase()) {
          case "NO_ASSIGNMENT": abap.builtin.sy.get().subrc.set(1); break;
          default: abap.builtin.sy.get().subrc.set(2); break;
            }
        } else {
            throw e;
        }
      }
      abap.statements.translate(ex_value, "LOWER");
      if (abap.compare.ne(abap.builtin.sy.get().subrc, abap.IntegerFactory.get(0))) {
        const unique29 = await (new abap.Classes['CX_GDT_CONVERSION']()).constructor_();
        unique29.EXTRA_CX = {"INTERNAL_FILENAME": "cl_gdt_conversion.clas.abap","INTERNAL_LINE": 143};
        throw unique29;
      }
    }
  }
  abap.Classes['CL_GDT_CONVERSION'] = cl_gdt_conversion;
export {cl_gdt_conversion};
//# sourceMappingURL=cl_gdt_conversion.clas.mjs.map