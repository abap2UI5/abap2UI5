const {cx_root} = await import("./cx_root.clas.mjs");
// kernel_scan_abap_source.clas.abap
class kernel_scan_abap_source {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'KERNEL_SCAN_ABAP_SOURCE';
  static IMPLEMENTED_INTERFACES = [];
  static ATTRIBUTES = {"GC_TOKEN": {"type": () => {return new abap.types.Structure({"comment": new abap.types.Character(1, {}), "identifier": new abap.types.Character(1, {}), "list": new abap.types.Character(1, {}), "literal": new abap.types.Character(1, {}), "pragma": new abap.types.Character(1, {})}, undefined, undefined, {}, {});}, "visibility": "I", "is_constant": "X", "is_class": "X"},
  "GC_STATEMENT": {"type": () => {return new abap.types.Structure({"comment": new abap.types.Character(1, {}), "comment_in_stmnt": new abap.types.Character(1, {}), "compute_direct": new abap.types.Character(1, {}), "empty": new abap.types.Character(1, {}), "macro_call": new abap.types.Character(1, {}), "macro_definition": new abap.types.Character(1, {}), "method_direct": new abap.types.Character(1, {}), "native_sql": new abap.types.Character(1, {}), "pragma": new abap.types.Character(1, {}), "standard": new abap.types.Character(1, {})}, undefined, undefined, {}, {});}, "visibility": "I", "is_constant": "X", "is_class": "X"}};
  static METHODS = {"CALL_INTERNAL": {"visibility": "I", "parameters": {"SOURCE": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "ET_STOKESX": {"type": () => {return abap.types.TableFactory.construct(new abap.types.Structure({"str": new abap.types.String({qualifiedName: "STRING"}), "row": new abap.types.Integer({qualifiedName: "I"}), "off2": new abap.types.Integer({qualifiedName: "I"}), "off3": new abap.types.Integer({qualifiedName: "I"}), "col": new abap.types.Integer({qualifiedName: "I"}), "len1": new abap.types.Integer({qualifiedName: "I"}), "len2": new abap.types.Integer({qualifiedName: "I"}), "len3": new abap.types.Integer({qualifiedName: "I"}), "type": new abap.types.Character(1, {})}, "STOKESX", "STOKESX", {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "kernel_scan_abap_source=>ty_stokesx");}, "is_optional": " "}, "ET_SSTMNT": {"type": () => {return abap.types.TableFactory.construct(new abap.types.Structure({"level": new abap.types.Integer({qualifiedName: "I"}), "struc": new abap.types.Integer({qualifiedName: "I"}), "from": new abap.types.Integer({qualifiedName: "I"}), "to": new abap.types.Integer({qualifiedName: "I"}), "number": new abap.types.Integer({qualifiedName: "I"}), "colonrow": new abap.types.Integer({qualifiedName: "I"}), "trow": new abap.types.Integer({qualifiedName: "I"}), "coloncol": new abap.types.Integer({qualifiedName: "I"}), "tcol": new abap.types.Integer({qualifiedName: "I"}), "prefixlen": new abap.types.Integer({qualifiedName: "I"}), "type": new abap.types.Character(1, {}), "terminator": new abap.types.Character(1, {}), "enhmt": new abap.types.Integer({qualifiedName: "I"})}, "SSTMNT", "SSTMNT", {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "kernel_scan_abap_source=>ty_sstmnt");}, "is_optional": " "}}},
  "PASS1": {"visibility": "I", "parameters": {"SOURCE": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "ET_TOKENS": {"type": () => {return abap.types.TableFactory.construct(new abap.types.Structure({"str": new abap.types.String({qualifiedName: "STRING"}), "row": new abap.types.Integer({qualifiedName: "I"}), "off2": new abap.types.Integer({qualifiedName: "I"}), "off3": new abap.types.Integer({qualifiedName: "I"}), "col": new abap.types.Integer({qualifiedName: "I"}), "len1": new abap.types.Integer({qualifiedName: "I"}), "len2": new abap.types.Integer({qualifiedName: "I"}), "len3": new abap.types.Integer({qualifiedName: "I"}), "type": new abap.types.Character(1, {})}, "STOKESX", "STOKESX", {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "kernel_scan_abap_source=>ty_stokesx");}, "is_optional": " "}, "ET_STATEMENTS": {"type": () => {return abap.types.TableFactory.construct(new abap.types.Structure({"level": new abap.types.Integer({qualifiedName: "I"}), "struc": new abap.types.Integer({qualifiedName: "I"}), "from": new abap.types.Integer({qualifiedName: "I"}), "to": new abap.types.Integer({qualifiedName: "I"}), "number": new abap.types.Integer({qualifiedName: "I"}), "colonrow": new abap.types.Integer({qualifiedName: "I"}), "trow": new abap.types.Integer({qualifiedName: "I"}), "coloncol": new abap.types.Integer({qualifiedName: "I"}), "tcol": new abap.types.Integer({qualifiedName: "I"}), "prefixlen": new abap.types.Integer({qualifiedName: "I"}), "type": new abap.types.Character(1, {}), "terminator": new abap.types.Character(1, {}), "enhmt": new abap.types.Integer({qualifiedName: "I"})}, "SSTMNT", "SSTMNT", {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "kernel_scan_abap_source=>ty_sstmnt");}, "is_optional": " "}}},
  "PASS2": {"visibility": "I", "parameters": {"CT_TOKENS": {"type": () => {return abap.types.TableFactory.construct(new abap.types.Structure({"str": new abap.types.String({qualifiedName: "STRING"}), "row": new abap.types.Integer({qualifiedName: "I"}), "off2": new abap.types.Integer({qualifiedName: "I"}), "off3": new abap.types.Integer({qualifiedName: "I"}), "col": new abap.types.Integer({qualifiedName: "I"}), "len1": new abap.types.Integer({qualifiedName: "I"}), "len2": new abap.types.Integer({qualifiedName: "I"}), "len3": new abap.types.Integer({qualifiedName: "I"}), "type": new abap.types.Character(1, {})}, "STOKESX", "STOKESX", {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "kernel_scan_abap_source=>ty_stokesx");}, "is_optional": " "}, "CT_STATEMENTS": {"type": () => {return abap.types.TableFactory.construct(new abap.types.Structure({"level": new abap.types.Integer({qualifiedName: "I"}), "struc": new abap.types.Integer({qualifiedName: "I"}), "from": new abap.types.Integer({qualifiedName: "I"}), "to": new abap.types.Integer({qualifiedName: "I"}), "number": new abap.types.Integer({qualifiedName: "I"}), "colonrow": new abap.types.Integer({qualifiedName: "I"}), "trow": new abap.types.Integer({qualifiedName: "I"}), "coloncol": new abap.types.Integer({qualifiedName: "I"}), "tcol": new abap.types.Integer({qualifiedName: "I"}), "prefixlen": new abap.types.Integer({qualifiedName: "I"}), "type": new abap.types.Character(1, {}), "terminator": new abap.types.Character(1, {}), "enhmt": new abap.types.Integer({qualifiedName: "I"})}, "SSTMNT", "SSTMNT", {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "kernel_scan_abap_source=>ty_sstmnt");}, "is_optional": " "}}},
  "CALL": {"visibility": "U", "parameters": {"INPUT": {"type": () => {return new abap.types.Character(4);}, "is_optional": " "}}}};
  constructor() {
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
    this.gc_token = kernel_scan_abap_source.gc_token;
    this.gc_statement = kernel_scan_abap_source.gc_statement;
  }
  async constructor_(INPUT) {
    if (super.constructor_) { await super.constructor_(INPUT); }
    return this;
  }
  async call(INPUT) {
    return kernel_scan_abap_source.call(INPUT);
  }
  static async call(INPUT) {
    let input = INPUT?.input;
    let lt_sstmnt = abap.types.TableFactory.construct(new abap.types.Structure({"level": new abap.types.Integer({qualifiedName: "I"}), "struc": new abap.types.Integer({qualifiedName: "I"}), "from": new abap.types.Integer({qualifiedName: "I"}), "to": new abap.types.Integer({qualifiedName: "I"}), "number": new abap.types.Integer({qualifiedName: "I"}), "colonrow": new abap.types.Integer({qualifiedName: "I"}), "trow": new abap.types.Integer({qualifiedName: "I"}), "coloncol": new abap.types.Integer({qualifiedName: "I"}), "tcol": new abap.types.Integer({qualifiedName: "I"}), "prefixlen": new abap.types.Integer({qualifiedName: "I"}), "type": new abap.types.Character(1, {}), "terminator": new abap.types.Character(1, {}), "enhmt": new abap.types.Integer({qualifiedName: "I"})}, "SSTMNT", "SSTMNT", {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "kernel_scan_abap_source=>ty_sstmnt");
    let lt_stokes = abap.types.TableFactory.construct(new abap.types.Structure({"str": new abap.types.String({qualifiedName: "STRING"}), "row": new abap.types.Integer({qualifiedName: "I"}), "col": new abap.types.Integer({qualifiedName: "I"}), "type": new abap.types.Character(1, {})}, "STOKES", "STOKES", {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"isUnique":false,"type":"STANDARD","keyFields":[],"name":"primary_key"},"secondary":[]}, "STOKES_TAB");
    let ls_stokes = new abap.types.Structure({"str": new abap.types.String({qualifiedName: "STRING"}), "row": new abap.types.Integer({qualifiedName: "I"}), "col": new abap.types.Integer({qualifiedName: "I"}), "type": new abap.types.Character(1, {})}, "STOKES", "STOKES", {}, {});
    let lt_stokesx = abap.types.TableFactory.construct(new abap.types.Structure({"str": new abap.types.String({qualifiedName: "STRING"}), "row": new abap.types.Integer({qualifiedName: "I"}), "off2": new abap.types.Integer({qualifiedName: "I"}), "off3": new abap.types.Integer({qualifiedName: "I"}), "col": new abap.types.Integer({qualifiedName: "I"}), "len1": new abap.types.Integer({qualifiedName: "I"}), "len2": new abap.types.Integer({qualifiedName: "I"}), "len3": new abap.types.Integer({qualifiedName: "I"}), "type": new abap.types.Character(1, {})}, "STOKESX", "STOKESX", {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "kernel_scan_abap_source=>ty_stokesx");
    let ls_stokesx = new abap.types.Structure({"str": new abap.types.String({qualifiedName: "STRING"}), "row": new abap.types.Integer({qualifiedName: "I"}), "off2": new abap.types.Integer({qualifiedName: "I"}), "off3": new abap.types.Integer({qualifiedName: "I"}), "col": new abap.types.Integer({qualifiedName: "I"}), "len1": new abap.types.Integer({qualifiedName: "I"}), "len2": new abap.types.Integer({qualifiedName: "I"}), "len3": new abap.types.Integer({qualifiedName: "I"}), "type": new abap.types.Character(1, {})}, "STOKESX", "STOKESX", {}, {});
    let lv_source = new abap.types.String({qualifiedName: "STRING"});
    lv_source.set(INPUT.scan_abap_source.array ? INPUT.scan_abap_source.array().map(e => e.get()).join("\n") : INPUT.scan_abap_source.get());
    await this.call_internal({source: lv_source, et_stokesx: lt_stokesx, et_sstmnt: lt_sstmnt});
    for await (const unique107 of abap.statements.loop(lt_stokesx)) {
      ls_stokesx.set(unique107);
      abap.statements.clear(ls_stokes);
      abap.statements.moveCorresponding(ls_stokesx, ls_stokes);
      abap.statements.append({source: ls_stokes, target: lt_stokes});
    }
    const len = Object.keys(INPUT.tokens_into.getRowType().get()).length;
    INPUT.tokens_into.set(len == 4 ? lt_stokes : lt_stokesx);
    INPUT.statements_into.set(lt_sstmnt);
  }
  async call_internal(INPUT) {
    return kernel_scan_abap_source.call_internal(INPUT);
  }
  static async call_internal(INPUT) {
    let source = INPUT?.source;
    if (source?.getQualifiedName === undefined || source.getQualifiedName() !== "STRING") { source = undefined; }
    if (source === undefined) { source = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.source); }
    let et_stokesx = INPUT?.et_stokesx || abap.types.TableFactory.construct(new abap.types.Structure({"str": new abap.types.String({qualifiedName: "STRING"}), "row": new abap.types.Integer({qualifiedName: "I"}), "off2": new abap.types.Integer({qualifiedName: "I"}), "off3": new abap.types.Integer({qualifiedName: "I"}), "col": new abap.types.Integer({qualifiedName: "I"}), "len1": new abap.types.Integer({qualifiedName: "I"}), "len2": new abap.types.Integer({qualifiedName: "I"}), "len3": new abap.types.Integer({qualifiedName: "I"}), "type": new abap.types.Character(1, {})}, "STOKESX", "STOKESX", {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "kernel_scan_abap_source=>ty_stokesx");
    let et_sstmnt = INPUT?.et_sstmnt || abap.types.TableFactory.construct(new abap.types.Structure({"level": new abap.types.Integer({qualifiedName: "I"}), "struc": new abap.types.Integer({qualifiedName: "I"}), "from": new abap.types.Integer({qualifiedName: "I"}), "to": new abap.types.Integer({qualifiedName: "I"}), "number": new abap.types.Integer({qualifiedName: "I"}), "colonrow": new abap.types.Integer({qualifiedName: "I"}), "trow": new abap.types.Integer({qualifiedName: "I"}), "coloncol": new abap.types.Integer({qualifiedName: "I"}), "tcol": new abap.types.Integer({qualifiedName: "I"}), "prefixlen": new abap.types.Integer({qualifiedName: "I"}), "type": new abap.types.Character(1, {}), "terminator": new abap.types.Character(1, {}), "enhmt": new abap.types.Integer({qualifiedName: "I"})}, "SSTMNT", "SSTMNT", {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "kernel_scan_abap_source=>ty_sstmnt");
    await this.pass1({source: source, et_tokens: et_stokesx, et_statements: et_sstmnt});
    await this.pass2({ct_tokens: et_stokesx, ct_statements: et_sstmnt});
  }
  async pass1(INPUT) {
    return kernel_scan_abap_source.pass1(INPUT);
  }
  static async pass1(INPUT) {
    let source = INPUT?.source;
    if (source?.getQualifiedName === undefined || source.getQualifiedName() !== "STRING") { source = undefined; }
    if (source === undefined) { source = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.source); }
    let et_tokens = INPUT?.et_tokens || abap.types.TableFactory.construct(new abap.types.Structure({"str": new abap.types.String({qualifiedName: "STRING"}), "row": new abap.types.Integer({qualifiedName: "I"}), "off2": new abap.types.Integer({qualifiedName: "I"}), "off3": new abap.types.Integer({qualifiedName: "I"}), "col": new abap.types.Integer({qualifiedName: "I"}), "len1": new abap.types.Integer({qualifiedName: "I"}), "len2": new abap.types.Integer({qualifiedName: "I"}), "len3": new abap.types.Integer({qualifiedName: "I"}), "type": new abap.types.Character(1, {})}, "STOKESX", "STOKESX", {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "kernel_scan_abap_source=>ty_stokesx");
    let et_statements = INPUT?.et_statements || abap.types.TableFactory.construct(new abap.types.Structure({"level": new abap.types.Integer({qualifiedName: "I"}), "struc": new abap.types.Integer({qualifiedName: "I"}), "from": new abap.types.Integer({qualifiedName: "I"}), "to": new abap.types.Integer({qualifiedName: "I"}), "number": new abap.types.Integer({qualifiedName: "I"}), "colonrow": new abap.types.Integer({qualifiedName: "I"}), "trow": new abap.types.Integer({qualifiedName: "I"}), "coloncol": new abap.types.Integer({qualifiedName: "I"}), "tcol": new abap.types.Integer({qualifiedName: "I"}), "prefixlen": new abap.types.Integer({qualifiedName: "I"}), "type": new abap.types.Character(1, {}), "terminator": new abap.types.Character(1, {}), "enhmt": new abap.types.Integer({qualifiedName: "I"})}, "SSTMNT", "SSTMNT", {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "kernel_scan_abap_source=>ty_sstmnt");
    let c_mode = new abap.types.Structure({"normal": new abap.types.Integer({qualifiedName: "I"}), "comment": new abap.types.Integer({qualifiedName: "I"})}, undefined, undefined, {}, {});
    c_mode.get().normal.set(abap.IntegerFactory.get(1));
    c_mode.get().comment.set(abap.IntegerFactory.get(2));
    let character = new abap.types.Character(1, {});
    let row = new abap.types.Integer({qualifiedName: "I"});
    row.set(1);
    let column = new abap.types.Integer({qualifiedName: "I"});
    let index = new abap.types.Integer({qualifiedName: "I"});
    let sfrom = new abap.types.Integer({qualifiedName: "I"});
    sfrom.set(1);
    let mode = new abap.types.Integer({qualifiedName: "I"});
    let chain_tokens = abap.types.TableFactory.construct(new abap.types.Structure({"str": new abap.types.String({qualifiedName: "STRING"}), "row": new abap.types.Integer({qualifiedName: "I"}), "off2": new abap.types.Integer({qualifiedName: "I"}), "off3": new abap.types.Integer({qualifiedName: "I"}), "col": new abap.types.Integer({qualifiedName: "I"}), "len1": new abap.types.Integer({qualifiedName: "I"}), "len2": new abap.types.Integer({qualifiedName: "I"}), "len3": new abap.types.Integer({qualifiedName: "I"}), "type": new abap.types.Character(1, {})}, "STOKESX", "STOKESX", {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "kernel_scan_abap_source=>ty_stokesx");
    let fs_trow_ = new abap.types.FieldSymbol(new abap.types.Structure({"str": new abap.types.String({qualifiedName: "STRING"}), "row": new abap.types.Integer({qualifiedName: "I"}), "off2": new abap.types.Integer({qualifiedName: "I"}), "off3": new abap.types.Integer({qualifiedName: "I"}), "col": new abap.types.Integer({qualifiedName: "I"}), "len1": new abap.types.Integer({qualifiedName: "I"}), "len2": new abap.types.Integer({qualifiedName: "I"}), "len3": new abap.types.Integer({qualifiedName: "I"}), "type": new abap.types.Character(1, {})}, "STOKESX", "STOKESX", {}, {}));
    let fs_srow_ = new abap.types.FieldSymbol(new abap.types.Structure({"level": new abap.types.Integer({qualifiedName: "I"}), "struc": new abap.types.Integer({qualifiedName: "I"}), "from": new abap.types.Integer({qualifiedName: "I"}), "to": new abap.types.Integer({qualifiedName: "I"}), "number": new abap.types.Integer({qualifiedName: "I"}), "colonrow": new abap.types.Integer({qualifiedName: "I"}), "trow": new abap.types.Integer({qualifiedName: "I"}), "coloncol": new abap.types.Integer({qualifiedName: "I"}), "tcol": new abap.types.Integer({qualifiedName: "I"}), "prefixlen": new abap.types.Integer({qualifiedName: "I"}), "type": new abap.types.Character(1, {}), "terminator": new abap.types.Character(1, {}), "enhmt": new abap.types.Integer({qualifiedName: "I"})}, "SSTMNT", "SSTMNT", {}, {}));
    mode.set(c_mode.get().normal);
    const indexBackup1 = abap.builtin.sy.get().index.get();
    let unique108 = 1;
    while (abap.compare.initial(source) === false) {
      abap.builtin.sy.get().index.set(unique108++);
      character.set(source.getOffset({length: 1}));
      source.set(source.getOffset({offset: 1}));
      if (abap.compare.assigned(fs_trow_) === false && abap.compare.ne(character, new abap.types.Character(1).set('')) && abap.compare.ne(character, new abap.types.String().set(`\n`))) {
        fs_trow_.assign(et_tokens.appendInitial());
        fs_trow_.get().row.set(row);
        fs_trow_.get().col.set(column);
        fs_trow_.get().type.set(kernel_scan_abap_source.gc_token.get().identifier);
      } else if (abap.compare.eq(mode, c_mode.get().normal) && (abap.compare.eq(character, new abap.types.Character(1).set('')) || abap.compare.ca(character, new abap.types.String().set(`.,`)))) {
        fs_trow_.unassign();
      } else if (abap.compare.eq(mode, c_mode.get().normal) && abap.compare.eq(character, new abap.types.Character(1).set(':'))) {
        abap.statements.clear(chain_tokens);
        abap.statements.append({source: et_tokens, from: sfrom, lines: true, target: chain_tokens});
        await abap.statements.deleteInternal(chain_tokens,{where: async (I) => {return abap.compare.eq(I.type, kernel_scan_abap_source.gc_token.get().comment);}});
      }
      if ((abap.compare.eq(mode, c_mode.get().normal) && abap.compare.ca(character, new abap.types.String().set(`.,`))) || abap.compare.eq(source, new abap.types.Character(1).set(''))) {
        fs_srow_.assign(et_statements.appendInitial());
        fs_srow_.get().terminator.set(character);
        fs_srow_.get().from.set(sfrom);
        fs_srow_.get().to.set(abap.builtin.lines({val: et_tokens}));
        sfrom.set(abap.operators.add(fs_srow_.get().to,abap.IntegerFactory.get(1)));
        if (abap.compare.eq(character, new abap.types.Character(1).set(','))) {
          abap.statements.append({source: chain_tokens, lines: true, target: et_tokens});
        }
      }
      if (abap.compare.eq(character, new abap.types.String().set(`\n`))) {
        mode.set(c_mode.get().normal);
        fs_trow_.unassign();
        row.set(abap.operators.add(row,abap.IntegerFactory.get(1)));
        column.set(abap.IntegerFactory.get(0));
      } else {
        if (abap.compare.assigned(fs_trow_)) {
          if ((abap.compare.eq(character, new abap.types.Character(1).set('*')) && abap.compare.eq(column, abap.IntegerFactory.get(0))) || abap.compare.eq(character, new abap.types.Character(1).set('"'))) {
            mode.set(c_mode.get().comment);
            fs_trow_.get().type.set(kernel_scan_abap_source.gc_token.get().comment);
          }
          if (abap.compare.eq(mode, c_mode.get().comment)) {
            fs_trow_.get().type.set(kernel_scan_abap_source.gc_token.get().comment);
            abap.statements.concatenate({source: [fs_trow_.get().str, character], target: fs_trow_.get().str, respectingBlanks: true});
          } else if (abap.compare.ne(character, new abap.types.Character(1).set(':'))) {
            fs_trow_.get().str.set(abap.operators.concat(fs_trow_.get().str,abap.builtin.to_upper({val: new abap.types.String().set(`${abap.templateFormatting(character)}`)})));
          }
        }
        column.set(abap.operators.add(column,abap.IntegerFactory.get(1)));
      }
    }
    abap.builtin.sy.get().index.set(indexBackup1);
  }
  async pass2(INPUT) {
    return kernel_scan_abap_source.pass2(INPUT);
  }
  static async pass2(INPUT) {
    let ct_tokens = abap.types.TableFactory.construct(new abap.types.Structure({"str": new abap.types.String({qualifiedName: "STRING"}), "row": new abap.types.Integer({qualifiedName: "I"}), "off2": new abap.types.Integer({qualifiedName: "I"}), "off3": new abap.types.Integer({qualifiedName: "I"}), "col": new abap.types.Integer({qualifiedName: "I"}), "len1": new abap.types.Integer({qualifiedName: "I"}), "len2": new abap.types.Integer({qualifiedName: "I"}), "len3": new abap.types.Integer({qualifiedName: "I"}), "type": new abap.types.Character(1, {})}, "STOKESX", "STOKESX", {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "kernel_scan_abap_source=>ty_stokesx");
    if (INPUT && INPUT.ct_tokens) {ct_tokens = INPUT.ct_tokens;}
    let ct_statements = abap.types.TableFactory.construct(new abap.types.Structure({"level": new abap.types.Integer({qualifiedName: "I"}), "struc": new abap.types.Integer({qualifiedName: "I"}), "from": new abap.types.Integer({qualifiedName: "I"}), "to": new abap.types.Integer({qualifiedName: "I"}), "number": new abap.types.Integer({qualifiedName: "I"}), "colonrow": new abap.types.Integer({qualifiedName: "I"}), "trow": new abap.types.Integer({qualifiedName: "I"}), "coloncol": new abap.types.Integer({qualifiedName: "I"}), "tcol": new abap.types.Integer({qualifiedName: "I"}), "prefixlen": new abap.types.Integer({qualifiedName: "I"}), "type": new abap.types.Character(1, {}), "terminator": new abap.types.Character(1, {}), "enhmt": new abap.types.Integer({qualifiedName: "I"})}, "SSTMNT", "SSTMNT", {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "kernel_scan_abap_source=>ty_sstmnt");
    if (INPUT && INPUT.ct_statements) {ct_statements = INPUT.ct_statements;}
    let fs_ls_statement_ = new abap.types.FieldSymbol(new abap.types.Structure({"level": new abap.types.Integer({qualifiedName: "I"}), "struc": new abap.types.Integer({qualifiedName: "I"}), "from": new abap.types.Integer({qualifiedName: "I"}), "to": new abap.types.Integer({qualifiedName: "I"}), "number": new abap.types.Integer({qualifiedName: "I"}), "colonrow": new abap.types.Integer({qualifiedName: "I"}), "trow": new abap.types.Integer({qualifiedName: "I"}), "coloncol": new abap.types.Integer({qualifiedName: "I"}), "tcol": new abap.types.Integer({qualifiedName: "I"}), "prefixlen": new abap.types.Integer({qualifiedName: "I"}), "type": new abap.types.Character(1, {}), "terminator": new abap.types.Character(1, {}), "enhmt": new abap.types.Integer({qualifiedName: "I"})}, "SSTMNT", "SSTMNT", {}, {}));
    let ls_statement = new abap.types.Structure({"level": new abap.types.Integer({qualifiedName: "I"}), "struc": new abap.types.Integer({qualifiedName: "I"}), "from": new abap.types.Integer({qualifiedName: "I"}), "to": new abap.types.Integer({qualifiedName: "I"}), "number": new abap.types.Integer({qualifiedName: "I"}), "colonrow": new abap.types.Integer({qualifiedName: "I"}), "trow": new abap.types.Integer({qualifiedName: "I"}), "coloncol": new abap.types.Integer({qualifiedName: "I"}), "tcol": new abap.types.Integer({qualifiedName: "I"}), "prefixlen": new abap.types.Integer({qualifiedName: "I"}), "type": new abap.types.Character(1, {}), "terminator": new abap.types.Character(1, {}), "enhmt": new abap.types.Integer({qualifiedName: "I"})}, "SSTMNT", "SSTMNT", {}, {});
    let ls_token = new abap.types.Structure({"str": new abap.types.String({qualifiedName: "STRING"}), "row": new abap.types.Integer({qualifiedName: "I"}), "off2": new abap.types.Integer({qualifiedName: "I"}), "off3": new abap.types.Integer({qualifiedName: "I"}), "col": new abap.types.Integer({qualifiedName: "I"}), "len1": new abap.types.Integer({qualifiedName: "I"}), "len2": new abap.types.Integer({qualifiedName: "I"}), "len3": new abap.types.Integer({qualifiedName: "I"}), "type": new abap.types.Character(1, {})}, "STOKESX", "STOKESX", {}, {});
    let contains_comment = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    let contains_normal = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    let lv_count = new abap.types.Integer({qualifiedName: "I"});
    let lv_statement_index = new abap.types.Integer({qualifiedName: "I"});
    let lt_insert = abap.types.TableFactory.construct(new abap.types.Structure({"str": new abap.types.String({qualifiedName: "STRING"}), "row": new abap.types.Integer({qualifiedName: "I"}), "off2": new abap.types.Integer({qualifiedName: "I"}), "off3": new abap.types.Integer({qualifiedName: "I"}), "col": new abap.types.Integer({qualifiedName: "I"}), "len1": new abap.types.Integer({qualifiedName: "I"}), "len2": new abap.types.Integer({qualifiedName: "I"}), "len3": new abap.types.Integer({qualifiedName: "I"}), "type": new abap.types.Character(1, {})}, "STOKESX", "STOKESX", {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "kernel_scan_abap_source=>ty_stokesx");
    let lt_delete = abap.types.TableFactory.construct(new abap.types.Integer({qualifiedName: "I"}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "");
    let lv_index = new abap.types.Integer({qualifiedName: "I"});
    for await (const unique109 of abap.statements.loop(ct_statements)) {
      fs_ls_statement_.assign(unique109);
      lv_statement_index.set(abap.builtin.sy.get().tabix);
      contains_comment.set(abap.builtin.abap_false);
      contains_normal.set(abap.builtin.abap_false);
      for await (const unique110 of abap.statements.loop(ct_tokens,{from: fs_ls_statement_.get().from,to: fs_ls_statement_.get().to})) {
        ls_token.set(unique110);
        if (abap.compare.eq(ls_token.get().type, kernel_scan_abap_source.gc_token.get().comment)) {
          contains_comment.set(abap.builtin.abap_true);
        } else {
          contains_normal.set(abap.builtin.abap_true);
        }
      }
      if (abap.compare.eq(contains_comment, abap.builtin.abap_true) && abap.compare.eq(contains_normal, abap.builtin.abap_true)) {
        lv_count.set(abap.IntegerFactory.get(0));
        abap.statements.clear(lt_insert);
        abap.statements.clear(lt_delete);
        for await (const unique111 of abap.statements.loop(ct_tokens,{from: fs_ls_statement_.get().from,to: fs_ls_statement_.get().to})) {
          ls_token.set(unique111);
          if (abap.compare.eq(ls_token.get().type, kernel_scan_abap_source.gc_token.get().comment)) {
            abap.statements.insertInternal({data: abap.builtin.sy.get().tabix, index: abap.IntegerFactory.get(1), table: lt_delete});
            abap.statements.insertInternal({data: ls_token, index: abap.IntegerFactory.get(1), table: lt_insert});
            lv_count.set(abap.operators.add(lv_count,abap.IntegerFactory.get(1)));
          }
        }
        for await (const unique112 of abap.statements.loop(lt_delete)) {
          lv_index.set(unique112);
          await abap.statements.deleteInternal(ct_tokens,{index: lv_index});
        }
        for await (const unique113 of abap.statements.loop(lt_insert)) {
          ls_token.set(unique113);
          abap.statements.insertInternal({data: ls_token, index: fs_ls_statement_.get().from, table: ct_tokens});
        }
        abap.statements.clear(ls_statement);
        ls_statement.get().from.set(fs_ls_statement_.get().from);
        ls_statement.get().to.set(abap.operators.minus(abap.operators.add(fs_ls_statement_.get().from,lv_count),abap.IntegerFactory.get(1)));
        ls_statement.get().type.set(kernel_scan_abap_source.gc_statement.get().comment);
        fs_ls_statement_.get().from.set(abap.operators.add(fs_ls_statement_.get().from,lv_count));
        abap.statements.insertInternal({data: ls_statement, index: lv_statement_index, table: ct_statements});
      } else if (abap.compare.eq(contains_comment, abap.builtin.abap_true)) {
        fs_ls_statement_.get().type.set(kernel_scan_abap_source.gc_statement.get().comment);
      } else {
        fs_ls_statement_.get().type.set(kernel_scan_abap_source.gc_statement.get().standard);
      }
    }
  }
}
abap.Classes['KERNEL_SCAN_ABAP_SOURCE'] = kernel_scan_abap_source;
kernel_scan_abap_source.gc_token = new abap.types.Structure({"comment": new abap.types.Character(1, {}), "identifier": new abap.types.Character(1, {}), "list": new abap.types.Character(1, {}), "literal": new abap.types.Character(1, {}), "pragma": new abap.types.Character(1, {})}, undefined, undefined, {}, {});
kernel_scan_abap_source.gc_token.get().comment.set('C');
kernel_scan_abap_source.gc_token.get().identifier.set('I');
kernel_scan_abap_source.gc_token.get().list.set('L');
kernel_scan_abap_source.gc_token.get().literal.set('S');
kernel_scan_abap_source.gc_token.get().pragma.set('P');
kernel_scan_abap_source.gc_statement = new abap.types.Structure({"comment": new abap.types.Character(1, {}), "comment_in_stmnt": new abap.types.Character(1, {}), "compute_direct": new abap.types.Character(1, {}), "empty": new abap.types.Character(1, {}), "macro_call": new abap.types.Character(1, {}), "macro_definition": new abap.types.Character(1, {}), "method_direct": new abap.types.Character(1, {}), "native_sql": new abap.types.Character(1, {}), "pragma": new abap.types.Character(1, {}), "standard": new abap.types.Character(1, {})}, undefined, undefined, {}, {});
kernel_scan_abap_source.gc_statement.get().comment.set('P');
kernel_scan_abap_source.gc_statement.get().comment_in_stmnt.set('S');
kernel_scan_abap_source.gc_statement.get().compute_direct.set('C');
kernel_scan_abap_source.gc_statement.get().empty.set('N');
kernel_scan_abap_source.gc_statement.get().macro_call.set('D');
kernel_scan_abap_source.gc_statement.get().macro_definition.set('M');
kernel_scan_abap_source.gc_statement.get().method_direct.set('A');
kernel_scan_abap_source.gc_statement.get().native_sql.set('E');
kernel_scan_abap_source.gc_statement.get().pragma.set('G');
kernel_scan_abap_source.gc_statement.get().standard.set('K');
kernel_scan_abap_source.ty_stokesx = abap.types.TableFactory.construct(new abap.types.Structure({"str": new abap.types.String({qualifiedName: "STRING"}), "row": new abap.types.Integer({qualifiedName: "I"}), "off2": new abap.types.Integer({qualifiedName: "I"}), "off3": new abap.types.Integer({qualifiedName: "I"}), "col": new abap.types.Integer({qualifiedName: "I"}), "len1": new abap.types.Integer({qualifiedName: "I"}), "len2": new abap.types.Integer({qualifiedName: "I"}), "len3": new abap.types.Integer({qualifiedName: "I"}), "type": new abap.types.Character(1, {})}, "STOKESX", "STOKESX", {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "kernel_scan_abap_source=>ty_stokesx");
kernel_scan_abap_source.ty_sstmnt = abap.types.TableFactory.construct(new abap.types.Structure({"level": new abap.types.Integer({qualifiedName: "I"}), "struc": new abap.types.Integer({qualifiedName: "I"}), "from": new abap.types.Integer({qualifiedName: "I"}), "to": new abap.types.Integer({qualifiedName: "I"}), "number": new abap.types.Integer({qualifiedName: "I"}), "colonrow": new abap.types.Integer({qualifiedName: "I"}), "trow": new abap.types.Integer({qualifiedName: "I"}), "coloncol": new abap.types.Integer({qualifiedName: "I"}), "tcol": new abap.types.Integer({qualifiedName: "I"}), "prefixlen": new abap.types.Integer({qualifiedName: "I"}), "type": new abap.types.Character(1, {}), "terminator": new abap.types.Character(1, {}), "enhmt": new abap.types.Integer({qualifiedName: "I"})}, "SSTMNT", "SSTMNT", {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "kernel_scan_abap_source=>ty_sstmnt");
export {kernel_scan_abap_source};
//# sourceMappingURL=kernel_scan_abap_source.clas.mjs.map