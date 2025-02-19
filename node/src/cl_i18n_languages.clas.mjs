const {cx_root} = await import("./cx_root.clas.mjs");
// cl_i18n_languages.clas.abap
class cl_i18n_languages {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CL_I18N_LANGUAGES';
  static IMPLEMENTED_INTERFACES = [];
  static ATTRIBUTES = {};
  static METHODS = {"SAP1_TO_SAP2": {"visibility": "U", "parameters": {"RE_LANG_SAP2": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "IM_LANG_SAP1": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"sy-langu","conversionExit":"ISOLA"});}, "is_optional": " "}}},
  "SAP2_TO_SAP1": {"visibility": "U", "parameters": {"RE_LANG_SAP1": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"sy-langu","conversionExit":"ISOLA"});}, "is_optional": " "}, "IM_LANG_SAP2": {"type": () => {return new abap.types.Character(2, {"qualifiedName":"LAISO","ddicName":"LAISO","description":"LAISO"});}, "is_optional": " "}}},
  "SAP2_TO_ISO639_1": {"visibility": "U", "parameters": {"IM_LANG_SAP2": {"type": () => {return new abap.types.Character(2, {"qualifiedName":"LAISO","ddicName":"LAISO","description":"LAISO"});}, "is_optional": " "}, "EX_LANG_ISO639": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "EX_COUNTRY": {"type": () => {return new abap.types.Character(3, {"qualifiedName":"LAND1","ddicName":"LAND1","description":"LAND1"});}, "is_optional": " "}}}};
  constructor() {
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
  }
  async constructor_(INPUT) {
    if (super.constructor_) { await super.constructor_(INPUT); }
    return this;
  }
  async sap2_to_sap1(INPUT) {
    return cl_i18n_languages.sap2_to_sap1(INPUT);
  }
  static async sap2_to_sap1(INPUT) {
    let re_lang_sap1 = new abap.types.Character(1, {"qualifiedName":"sy-langu","conversionExit":"ISOLA"});
    let im_lang_sap2 = INPUT?.im_lang_sap2;
    if (im_lang_sap2?.getQualifiedName === undefined || im_lang_sap2.getQualifiedName() !== "LAISO") { im_lang_sap2 = undefined; }
    if (im_lang_sap2 === undefined) { im_lang_sap2 = new abap.types.Character(2, {"qualifiedName":"LAISO","ddicName":"LAISO","description":"LAISO"}).set(INPUT.im_lang_sap2); }
    let unique18 = abap.builtin.to_upper({val: im_lang_sap2});
    if (abap.compare.eq(unique18, new abap.types.Character(2).set('SR'))) {
      re_lang_sap1.set(new abap.types.Character(1).set('0'));
    } else if (abap.compare.eq(unique18, new abap.types.Character(2).set('ZH'))) {
      re_lang_sap1.set(new abap.types.Character(1).set('1'));
    } else if (abap.compare.eq(unique18, new abap.types.Character(2).set('TH'))) {
      re_lang_sap1.set(new abap.types.Character(1).set('2'));
    } else if (abap.compare.eq(unique18, new abap.types.Character(2).set('KO'))) {
      re_lang_sap1.set(new abap.types.Character(1).set('3'));
    } else if (abap.compare.eq(unique18, new abap.types.Character(2).set('RO'))) {
      re_lang_sap1.set(new abap.types.Character(1).set('4'));
    } else if (abap.compare.eq(unique18, new abap.types.Character(2).set('SL'))) {
      re_lang_sap1.set(new abap.types.Character(1).set('5'));
    } else if (abap.compare.eq(unique18, new abap.types.Character(2).set('HR'))) {
      re_lang_sap1.set(new abap.types.Character(1).set('6'));
    } else if (abap.compare.eq(unique18, new abap.types.Character(2).set('MS'))) {
      re_lang_sap1.set(new abap.types.Character(1).set('7'));
    } else if (abap.compare.eq(unique18, new abap.types.Character(2).set('UK'))) {
      re_lang_sap1.set(new abap.types.Character(1).set('8'));
    } else if (abap.compare.eq(unique18, new abap.types.Character(2).set('ET'))) {
      re_lang_sap1.set(new abap.types.Character(1).set('9'));
    } else if (abap.compare.eq(unique18, new abap.types.Character(2).set('AR'))) {
      re_lang_sap1.set(new abap.types.Character(1).set('A'));
    } else if (abap.compare.eq(unique18, new abap.types.Character(2).set('HE'))) {
      re_lang_sap1.set(new abap.types.Character(1).set('B'));
    } else if (abap.compare.eq(unique18, new abap.types.Character(2).set('CS'))) {
      re_lang_sap1.set(new abap.types.Character(1).set('C'));
    } else if (abap.compare.eq(unique18, new abap.types.Character(2).set('DE'))) {
      re_lang_sap1.set(new abap.types.Character(1).set('D'));
    } else if (abap.compare.eq(unique18, new abap.types.Character(2).set('EN'))) {
      re_lang_sap1.set(new abap.types.Character(1).set('E'));
    } else if (abap.compare.eq(unique18, new abap.types.Character(2).set('FR'))) {
      re_lang_sap1.set(new abap.types.Character(1).set('F'));
    } else if (abap.compare.eq(unique18, new abap.types.Character(2).set('EL'))) {
      re_lang_sap1.set(new abap.types.Character(1).set('G'));
    } else if (abap.compare.eq(unique18, new abap.types.Character(2).set('HU'))) {
      re_lang_sap1.set(new abap.types.Character(1).set('H'));
    } else if (abap.compare.eq(unique18, new abap.types.Character(2).set('IT'))) {
      re_lang_sap1.set(new abap.types.Character(1).set('I'));
    } else if (abap.compare.eq(unique18, new abap.types.Character(2).set('JA'))) {
      re_lang_sap1.set(new abap.types.Character(1).set('J'));
    } else if (abap.compare.eq(unique18, new abap.types.Character(2).set('DA'))) {
      re_lang_sap1.set(new abap.types.Character(1).set('K'));
    } else if (abap.compare.eq(unique18, new abap.types.Character(2).set('PL'))) {
      re_lang_sap1.set(new abap.types.Character(1).set('L'));
    } else if (abap.compare.eq(unique18, new abap.types.Character(2).set('ZF'))) {
      re_lang_sap1.set(new abap.types.Character(1).set('M'));
    } else if (abap.compare.eq(unique18, new abap.types.Character(2).set('NL'))) {
      re_lang_sap1.set(new abap.types.Character(1).set('N'));
    } else if (abap.compare.eq(unique18, new abap.types.Character(2).set('NO'))) {
      re_lang_sap1.set(new abap.types.Character(1).set('O'));
    } else if (abap.compare.eq(unique18, new abap.types.Character(2).set('PT'))) {
      re_lang_sap1.set(new abap.types.Character(1).set('P'));
    } else if (abap.compare.eq(unique18, new abap.types.Character(2).set('SK'))) {
      re_lang_sap1.set(new abap.types.Character(1).set('Q'));
    } else if (abap.compare.eq(unique18, new abap.types.Character(2).set('RU'))) {
      re_lang_sap1.set(new abap.types.Character(1).set('R'));
    } else if (abap.compare.eq(unique18, new abap.types.Character(2).set('ES'))) {
      re_lang_sap1.set(new abap.types.Character(1).set('S'));
    } else if (abap.compare.eq(unique18, new abap.types.Character(2).set('TR'))) {
      re_lang_sap1.set(new abap.types.Character(1).set('T'));
    } else if (abap.compare.eq(unique18, new abap.types.Character(2).set('FI'))) {
      re_lang_sap1.set(new abap.types.Character(1).set('U'));
    } else if (abap.compare.eq(unique18, new abap.types.Character(2).set('SV'))) {
      re_lang_sap1.set(new abap.types.Character(1).set('V'));
    } else if (abap.compare.eq(unique18, new abap.types.Character(2).set('BG'))) {
      re_lang_sap1.set(new abap.types.Character(1).set('W'));
    } else if (abap.compare.eq(unique18, new abap.types.Character(2).set('LT'))) {
      re_lang_sap1.set(new abap.types.Character(1).set('X'));
    } else if (abap.compare.eq(unique18, new abap.types.Character(2).set('LV'))) {
      re_lang_sap1.set(new abap.types.Character(1).set('Y'));
    } else if (abap.compare.eq(unique18, new abap.types.Character(2).set('Z1'))) {
      re_lang_sap1.set(new abap.types.Character(1).set('Z'));
    } else if (abap.compare.eq(unique18, new abap.types.Character(2).set('AF'))) {
      re_lang_sap1.set(new abap.types.Character(1).set('a'));
    } else if (abap.compare.eq(unique18, new abap.types.Character(2).set('IS'))) {
      re_lang_sap1.set(new abap.types.Character(1).set('b'));
    } else if (abap.compare.eq(unique18, new abap.types.Character(2).set('CA'))) {
      re_lang_sap1.set(new abap.types.Character(1).set('c'));
    } else if (abap.compare.eq(unique18, new abap.types.Character(2).set('SH'))) {
      re_lang_sap1.set(new abap.types.Character(1).set('d'));
    } else if (abap.compare.eq(unique18, new abap.types.Character(2).set('ID'))) {
      re_lang_sap1.set(new abap.types.Character(1).set('i'));
    } else if (abap.compare.eq(unique18, new abap.types.Character(2).set('1Q'))) {
      re_lang_sap1.set(new abap.types.Character(1).set(''));
    } else {
      throw new abap.ClassicError({classic: "no_assignment"});
    }
    abap.builtin.sy.get().subrc.set(0);
    return re_lang_sap1;
  }
  async sap1_to_sap2(INPUT) {
    return cl_i18n_languages.sap1_to_sap2(INPUT);
  }
  static async sap1_to_sap2(INPUT) {
    let re_lang_sap2 = new abap.types.String({qualifiedName: "STRING"});
    let im_lang_sap1 = INPUT?.im_lang_sap1;
    if (im_lang_sap1?.getQualifiedName === undefined || im_lang_sap1.getQualifiedName() !== "SY-LANGU") { im_lang_sap1 = undefined; }
    if (im_lang_sap1 === undefined) { im_lang_sap1 = new abap.types.Character(1, {"qualifiedName":"sy-langu","conversionExit":"ISOLA"}).set(INPUT.im_lang_sap1); }
    let unique19 = im_lang_sap1;
    if (abap.compare.eq(unique19, new abap.types.Character(1).set('0'))) {
      re_lang_sap2.set(new abap.types.Character(2).set('SR'));
    } else if (abap.compare.eq(unique19, new abap.types.Character(1).set('1'))) {
      re_lang_sap2.set(new abap.types.Character(2).set('ZH'));
    } else if (abap.compare.eq(unique19, new abap.types.Character(1).set('2'))) {
      re_lang_sap2.set(new abap.types.Character(2).set('TH'));
    } else if (abap.compare.eq(unique19, new abap.types.Character(1).set('3'))) {
      re_lang_sap2.set(new abap.types.Character(2).set('KO'));
    } else if (abap.compare.eq(unique19, new abap.types.Character(1).set('4'))) {
      re_lang_sap2.set(new abap.types.Character(2).set('RO'));
    } else if (abap.compare.eq(unique19, new abap.types.Character(1).set('5'))) {
      re_lang_sap2.set(new abap.types.Character(2).set('SL'));
    } else if (abap.compare.eq(unique19, new abap.types.Character(1).set('6'))) {
      re_lang_sap2.set(new abap.types.Character(2).set('HR'));
    } else if (abap.compare.eq(unique19, new abap.types.Character(1).set('7'))) {
      re_lang_sap2.set(new abap.types.Character(2).set('MS'));
    } else if (abap.compare.eq(unique19, new abap.types.Character(1).set('8'))) {
      re_lang_sap2.set(new abap.types.Character(2).set('UK'));
    } else if (abap.compare.eq(unique19, new abap.types.Character(1).set('9'))) {
      re_lang_sap2.set(new abap.types.Character(2).set('ET'));
    } else if (abap.compare.eq(unique19, new abap.types.Character(1).set('A'))) {
      re_lang_sap2.set(new abap.types.Character(2).set('AR'));
    } else if (abap.compare.eq(unique19, new abap.types.Character(1).set('B'))) {
      re_lang_sap2.set(new abap.types.Character(2).set('HE'));
    } else if (abap.compare.eq(unique19, new abap.types.Character(1).set('C'))) {
      re_lang_sap2.set(new abap.types.Character(2).set('CS'));
    } else if (abap.compare.eq(unique19, new abap.types.Character(1).set('D'))) {
      re_lang_sap2.set(new abap.types.Character(2).set('DE'));
    } else if (abap.compare.eq(unique19, new abap.types.Character(1).set('E'))) {
      re_lang_sap2.set(new abap.types.Character(2).set('EN'));
    } else if (abap.compare.eq(unique19, new abap.types.Character(1).set('F'))) {
      re_lang_sap2.set(new abap.types.Character(2).set('FR'));
    } else if (abap.compare.eq(unique19, new abap.types.Character(1).set('G'))) {
      re_lang_sap2.set(new abap.types.Character(2).set('EL'));
    } else if (abap.compare.eq(unique19, new abap.types.Character(1).set('H'))) {
      re_lang_sap2.set(new abap.types.Character(2).set('HU'));
    } else if (abap.compare.eq(unique19, new abap.types.Character(1).set('I'))) {
      re_lang_sap2.set(new abap.types.Character(2).set('IT'));
    } else if (abap.compare.eq(unique19, new abap.types.Character(1).set('J'))) {
      re_lang_sap2.set(new abap.types.Character(2).set('JA'));
    } else if (abap.compare.eq(unique19, new abap.types.Character(1).set('K'))) {
      re_lang_sap2.set(new abap.types.Character(2).set('DA'));
    } else if (abap.compare.eq(unique19, new abap.types.Character(1).set('L'))) {
      re_lang_sap2.set(new abap.types.Character(2).set('PL'));
    } else if (abap.compare.eq(unique19, new abap.types.Character(1).set('M'))) {
      re_lang_sap2.set(new abap.types.Character(2).set('ZF'));
    } else if (abap.compare.eq(unique19, new abap.types.Character(1).set('N'))) {
      re_lang_sap2.set(new abap.types.Character(2).set('NL'));
    } else if (abap.compare.eq(unique19, new abap.types.Character(1).set('O'))) {
      re_lang_sap2.set(new abap.types.Character(2).set('NO'));
    } else if (abap.compare.eq(unique19, new abap.types.Character(1).set('P'))) {
      re_lang_sap2.set(new abap.types.Character(2).set('PT'));
    } else if (abap.compare.eq(unique19, new abap.types.Character(1).set('Q'))) {
      re_lang_sap2.set(new abap.types.Character(2).set('SK'));
    } else if (abap.compare.eq(unique19, new abap.types.Character(1).set('R'))) {
      re_lang_sap2.set(new abap.types.Character(2).set('RU'));
    } else if (abap.compare.eq(unique19, new abap.types.Character(1).set('S'))) {
      re_lang_sap2.set(new abap.types.Character(2).set('ES'));
    } else if (abap.compare.eq(unique19, new abap.types.Character(1).set('T'))) {
      re_lang_sap2.set(new abap.types.Character(2).set('TR'));
    } else if (abap.compare.eq(unique19, new abap.types.Character(1).set('U'))) {
      re_lang_sap2.set(new abap.types.Character(2).set('FI'));
    } else if (abap.compare.eq(unique19, new abap.types.Character(1).set('V'))) {
      re_lang_sap2.set(new abap.types.Character(2).set('SV'));
    } else if (abap.compare.eq(unique19, new abap.types.Character(1).set('W'))) {
      re_lang_sap2.set(new abap.types.Character(2).set('BG'));
    } else if (abap.compare.eq(unique19, new abap.types.Character(1).set('X'))) {
      re_lang_sap2.set(new abap.types.Character(2).set('LT'));
    } else if (abap.compare.eq(unique19, new abap.types.Character(1).set('Y'))) {
      re_lang_sap2.set(new abap.types.Character(2).set('LV'));
    } else if (abap.compare.eq(unique19, new abap.types.Character(1).set('Z'))) {
      re_lang_sap2.set(new abap.types.Character(2).set('Z1'));
    } else if (abap.compare.eq(unique19, new abap.types.Character(1).set('a'))) {
      re_lang_sap2.set(new abap.types.Character(2).set('AF'));
    } else if (abap.compare.eq(unique19, new abap.types.Character(1).set('b'))) {
      re_lang_sap2.set(new abap.types.Character(2).set('IS'));
    } else if (abap.compare.eq(unique19, new abap.types.Character(1).set('c'))) {
      re_lang_sap2.set(new abap.types.Character(2).set('CA'));
    } else if (abap.compare.eq(unique19, new abap.types.Character(1).set('d'))) {
      re_lang_sap2.set(new abap.types.Character(2).set('SH'));
    } else if (abap.compare.eq(unique19, new abap.types.Character(1).set('i'))) {
      re_lang_sap2.set(new abap.types.Character(2).set('ID'));
    } else {
      throw new abap.ClassicError({classic: "no_assignment"});
    }
    abap.builtin.sy.get().subrc.set(0);
    return re_lang_sap2;
  }
  async sap2_to_iso639_1(INPUT) {
    return cl_i18n_languages.sap2_to_iso639_1(INPUT);
  }
  static async sap2_to_iso639_1(INPUT) {
    let im_lang_sap2 = INPUT?.im_lang_sap2;
    if (im_lang_sap2?.getQualifiedName === undefined || im_lang_sap2.getQualifiedName() !== "LAISO") { im_lang_sap2 = undefined; }
    if (im_lang_sap2 === undefined) { im_lang_sap2 = new abap.types.Character(2, {"qualifiedName":"LAISO","ddicName":"LAISO","description":"LAISO"}).set(INPUT.im_lang_sap2); }
    let ex_lang_iso639 = INPUT?.ex_lang_iso639 || new abap.types.String({qualifiedName: "STRING"});
    let ex_country = INPUT?.ex_country || new abap.types.Character(3, {"qualifiedName":"LAND1","ddicName":"LAND1","description":"LAND1"});
    let unique20 = im_lang_sap2;
    if (abap.compare.eq(unique20, new abap.types.Character(2).set('SR'))) {
      ex_lang_iso639.set(new abap.types.Character(2).set('sr'));
    } else if (abap.compare.eq(unique20, new abap.types.Character(2).set('ZH'))) {
      ex_lang_iso639.set(new abap.types.Character(2).set('zh'));
      ex_country.set(new abap.types.Character(2).set('CN'));
    } else if (abap.compare.eq(unique20, new abap.types.Character(2).set('TH'))) {
      ex_lang_iso639.set(new abap.types.Character(2).set('th'));
    } else if (abap.compare.eq(unique20, new abap.types.Character(2).set('KO'))) {
      ex_lang_iso639.set(new abap.types.Character(2).set('ko'));
      ex_country.set(new abap.types.Character(2).set('KR'));
    } else if (abap.compare.eq(unique20, new abap.types.Character(2).set('RO'))) {
      ex_lang_iso639.set(new abap.types.Character(2).set('ro'));
      ex_country.set(new abap.types.Character(2).set('RO'));
    } else if (abap.compare.eq(unique20, new abap.types.Character(2).set('SL'))) {
      ex_lang_iso639.set(new abap.types.Character(2).set('sl'));
    } else if (abap.compare.eq(unique20, new abap.types.Character(2).set('HR'))) {
      ex_lang_iso639.set(new abap.types.Character(2).set('hr'));
    } else if (abap.compare.eq(unique20, new abap.types.Character(2).set('MS'))) {
      ex_lang_iso639.set(new abap.types.Character(2).set('ms'));
      ex_country.set(new abap.types.Character(2).set('MY'));
    } else if (abap.compare.eq(unique20, new abap.types.Character(2).set('UK'))) {
      ex_lang_iso639.set(new abap.types.Character(2).set('uk'));
    } else if (abap.compare.eq(unique20, new abap.types.Character(2).set('ET'))) {
      ex_lang_iso639.set(new abap.types.Character(2).set('et'));
    } else if (abap.compare.eq(unique20, new abap.types.Character(2).set('AR'))) {
      ex_lang_iso639.set(new abap.types.Character(2).set('ar'));
      ex_country.set(new abap.types.Character(2).set('SA'));
    } else if (abap.compare.eq(unique20, new abap.types.Character(2).set('HE'))) {
      ex_lang_iso639.set(new abap.types.Character(2).set('he'));
    } else if (abap.compare.eq(unique20, new abap.types.Character(2).set('CS'))) {
      ex_lang_iso639.set(new abap.types.Character(2).set('cs'));
    } else if (abap.compare.eq(unique20, new abap.types.Character(2).set('DE'))) {
      ex_lang_iso639.set(new abap.types.Character(2).set('de'));
      ex_country.set(new abap.types.Character(2).set('DE'));
    } else if (abap.compare.eq(unique20, new abap.types.Character(2).set('EN'))) {
      ex_lang_iso639.set(new abap.types.Character(2).set('en'));
      ex_country.set(new abap.types.Character(2).set('US'));
    } else if (abap.compare.eq(unique20, new abap.types.Character(2).set('FR'))) {
      ex_lang_iso639.set(new abap.types.Character(2).set('fr'));
      ex_country.set(new abap.types.Character(2).set('FR'));
    } else if (abap.compare.eq(unique20, new abap.types.Character(2).set('EL'))) {
      ex_lang_iso639.set(new abap.types.Character(2).set('el'));
    } else if (abap.compare.eq(unique20, new abap.types.Character(2).set('HU'))) {
      ex_lang_iso639.set(new abap.types.Character(2).set('hu'));
    } else if (abap.compare.eq(unique20, new abap.types.Character(2).set('IT'))) {
      ex_lang_iso639.set(new abap.types.Character(2).set('it'));
      ex_country.set(new abap.types.Character(2).set('IT'));
    } else if (abap.compare.eq(unique20, new abap.types.Character(2).set('JA'))) {
      ex_lang_iso639.set(new abap.types.Character(2).set('ja'));
    } else if (abap.compare.eq(unique20, new abap.types.Character(2).set('DA'))) {
      ex_lang_iso639.set(new abap.types.Character(2).set('da'));
    } else if (abap.compare.eq(unique20, new abap.types.Character(2).set('PL'))) {
      ex_lang_iso639.set(new abap.types.Character(2).set('pl'));
    } else if (abap.compare.eq(unique20, new abap.types.Character(2).set('ZF'))) {
      ex_lang_iso639.set(new abap.types.Character(2).set('zh'));
      ex_country.set(new abap.types.Character(2).set('TW'));
    } else if (abap.compare.eq(unique20, new abap.types.Character(2).set('NL'))) {
      ex_lang_iso639.set(new abap.types.Character(2).set('nl'));
      ex_country.set(new abap.types.Character(2).set('NL'));
    } else if (abap.compare.eq(unique20, new abap.types.Character(2).set('NO'))) {
      ex_lang_iso639.set(new abap.types.Character(2).set('no'));
    } else if (abap.compare.eq(unique20, new abap.types.Character(2).set('PT'))) {
      ex_lang_iso639.set(new abap.types.Character(2).set('pt'));
      ex_country.set(new abap.types.Character(2).set('BR'));
    } else if (abap.compare.eq(unique20, new abap.types.Character(2).set('SK'))) {
      ex_lang_iso639.set(new abap.types.Character(2).set('sk'));
    } else if (abap.compare.eq(unique20, new abap.types.Character(2).set('RU'))) {
      ex_lang_iso639.set(new abap.types.Character(2).set('ru'));
      ex_country.set(new abap.types.Character(2).set('RU'));
    } else if (abap.compare.eq(unique20, new abap.types.Character(2).set('ES'))) {
      ex_lang_iso639.set(new abap.types.Character(2).set('es'));
      ex_country.set(new abap.types.Character(2).set('ES'));
    } else if (abap.compare.eq(unique20, new abap.types.Character(2).set('TR'))) {
      ex_lang_iso639.set(new abap.types.Character(2).set('tr'));
    } else if (abap.compare.eq(unique20, new abap.types.Character(2).set('FI'))) {
      ex_lang_iso639.set(new abap.types.Character(2).set('fi'));
    } else if (abap.compare.eq(unique20, new abap.types.Character(2).set('SV'))) {
      ex_lang_iso639.set(new abap.types.Character(2).set('sv'));
    } else if (abap.compare.eq(unique20, new abap.types.Character(2).set('BG'))) {
      ex_lang_iso639.set(new abap.types.Character(2).set('bg'));
    } else if (abap.compare.eq(unique20, new abap.types.Character(2).set('LT'))) {
      ex_lang_iso639.set(new abap.types.Character(2).set('lt'));
    } else if (abap.compare.eq(unique20, new abap.types.Character(2).set('LV'))) {
      ex_lang_iso639.set(new abap.types.Character(2).set('lv'));
    } else if (abap.compare.eq(unique20, new abap.types.Character(2).set('AF'))) {
      ex_lang_iso639.set(new abap.types.Character(2).set('af'));
    } else if (abap.compare.eq(unique20, new abap.types.Character(2).set('IS'))) {
      ex_lang_iso639.set(new abap.types.Character(2).set('is'));
    } else if (abap.compare.eq(unique20, new abap.types.Character(2).set('CA'))) {
      ex_lang_iso639.set(new abap.types.Character(2).set('ca'));
    } else if (abap.compare.eq(unique20, new abap.types.Character(2).set('SH'))) {
      ex_lang_iso639.set(new abap.types.Character(2).set('sr'));
    } else if (abap.compare.eq(unique20, new abap.types.Character(2).set('ID'))) {
      ex_lang_iso639.set(new abap.types.Character(2).set('id'));
    } else {
      throw new abap.ClassicError({classic: "no_assignment"});
    }
    abap.builtin.sy.get().subrc.set(0);
  }
}
abap.Classes['CL_I18N_LANGUAGES'] = cl_i18n_languages;
export {cl_i18n_languages};
//# sourceMappingURL=cl_i18n_languages.clas.mjs.map