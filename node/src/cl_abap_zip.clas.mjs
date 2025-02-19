await import("./cl_abap_zip.clas.locals.mjs");
const {cx_root} = await import("./cx_root.clas.mjs");
// cl_abap_zip.clas.abap
class cl_abap_zip {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CL_ABAP_ZIP';
  static IMPLEMENTED_INTERFACES = [];
  static ATTRIBUTES = {"FILES": {"type": () => {return abap.types.TableFactory.construct(new abap.types.Structure({"name": new abap.types.String({qualifiedName: "CL_ABAP_ZIP=>T_FILE-NAME"}), "size": new abap.types.Integer({qualifiedName: "CL_ABAP_ZIP=>T_FILE-SIZE"})}, "cl_abap_zip=>t_file", undefined, {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "cl_abap_zip=>t_files");}, "visibility": "U", "is_constant": " ", "is_class": " "},
  "MT_CONTENTS": {"type": () => {return abap.types.TableFactory.construct(new abap.types.Structure({"name": new abap.types.String({qualifiedName: "CL_ABAP_ZIP=>TY_CONTENTS-NAME"}), "content": new abap.types.XString({qualifiedName: "CL_ABAP_ZIP=>TY_CONTENTS-CONTENT"}), "compressed": new abap.types.XString({qualifiedName: "CL_ABAP_ZIP=>TY_CONTENTS-COMPRESSED"})}, "cl_abap_zip=>ty_contents", undefined, {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "");}, "visibility": "I", "is_constant": " ", "is_class": " "}};
  static METHODS = {"ADD": {"visibility": "U", "parameters": {"NAME": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "CONTENT": {"type": () => {return new abap.types.XString({qualifiedName: "XSTRING"});}, "is_optional": " "}}},
  "SAVE": {"visibility": "U", "parameters": {"VAL": {"type": () => {return new abap.types.XString({qualifiedName: "XSTRING"});}, "is_optional": " "}}},
  "LOAD": {"visibility": "U", "parameters": {"ZIP": {"type": () => {return new abap.types.XString({qualifiedName: "XSTRING"});}, "is_optional": " "}}},
  "GET": {"visibility": "U", "parameters": {"NAME": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "INDEX": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}, "CONTENT": {"type": () => {return new abap.types.XString({qualifiedName: "XSTRING"});}, "is_optional": " "}}},
  "DELETE": {"visibility": "U", "parameters": {"NAME": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "INDEX": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}}},
  "CRC32": {"visibility": "U", "parameters": {"CRC": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}, "CONTENT": {"type": () => {return new abap.types.XString({qualifiedName: "XSTRING"});}, "is_optional": " "}}}};
  constructor() {
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
    this.files = abap.types.TableFactory.construct(new abap.types.Structure({"name": new abap.types.String({qualifiedName: "CL_ABAP_ZIP=>T_FILE-NAME"}), "size": new abap.types.Integer({qualifiedName: "CL_ABAP_ZIP=>T_FILE-SIZE"})}, "cl_abap_zip=>t_file", undefined, {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "cl_abap_zip=>t_files");
    this.mt_contents = abap.types.TableFactory.construct(new abap.types.Structure({"name": new abap.types.String({qualifiedName: "CL_ABAP_ZIP=>TY_CONTENTS-NAME"}), "content": new abap.types.XString({qualifiedName: "CL_ABAP_ZIP=>TY_CONTENTS-CONTENT"}), "compressed": new abap.types.XString({qualifiedName: "CL_ABAP_ZIP=>TY_CONTENTS-COMPRESSED"})}, "cl_abap_zip=>ty_contents", undefined, {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "");
  }
  async constructor_(INPUT) {
    if (super.constructor_) { await super.constructor_(INPUT); }
    return this;
  }
  async crc32(INPUT) {
    return cl_abap_zip.crc32(INPUT);
  }
  static async crc32(INPUT) {
    let crc = new abap.types.Integer({qualifiedName: "I"});
    let content = INPUT?.content;
    if (content?.getQualifiedName === undefined || content.getQualifiedName() !== "XSTRING") { content = undefined; }
    if (content === undefined) { content = new abap.types.XString({qualifiedName: "XSTRING"}).set(INPUT.content); }
    let lo_stream = new abap.types.ABAPObject({qualifiedName: "LCL_STREAM", RTTIName: "\\CLASS-POOL=CL_ABAP_ZIP\\CLASS=LCL_STREAM"});
    lo_stream.set(await (new abap.Classes['CLAS-CL_ABAP_ZIP-LCL_STREAM']()).constructor_());
    crc.set((await lo_stream.get().append_crc({iv_little_endian: abap.builtin.abap_false, iv_xstring: content})));
    return crc;
  }
  async delete(INPUT) {
    let name = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.name) {name.set(INPUT.name);}
    let index = new abap.types.Integer({qualifiedName: "I"});
    if (INPUT && INPUT.index) {index.set(INPUT.index);}
    if (INPUT === undefined || INPUT.index === undefined) {index = abap.IntegerFactory.get(0);}
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
  }
  async get(INPUT) {
    let name = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.name) {name.set(INPUT.name);}
    let index = new abap.types.Integer({qualifiedName: "I"});
    if (INPUT && INPUT.index) {index.set(INPUT.index);}
    let content = INPUT?.content || new abap.types.XString({qualifiedName: "XSTRING"});
    let ls_length = new abap.types.Integer({qualifiedName: "I"});
    let ls_contents = new abap.types.Structure({"name": new abap.types.String({qualifiedName: "CL_ABAP_ZIP=>TY_CONTENTS-NAME"}), "content": new abap.types.XString({qualifiedName: "CL_ABAP_ZIP=>TY_CONTENTS-CONTENT"}), "compressed": new abap.types.XString({qualifiedName: "CL_ABAP_ZIP=>TY_CONTENTS-COMPRESSED"})}, "cl_abap_zip=>ty_contents", undefined, {}, {});
    abap.statements.assert(abap.compare.initial(name) === false);
    abap.statements.assert(abap.compare.initial(index));
    abap.statements.readTable(this.mt_contents,{into: ls_contents,
      withKey: (i) => {return abap.compare.eq(i.name, name);},
      withKeyValue: [{key: (i) => {return i.name}, value: name}],
      usesTableLine: false,
      withKeySimple: {"name": name}});
    await abap.Classes['CL_ABAP_GZIP'].decompress_binary({gzip_in: ls_contents.get().compressed, raw_out: content, raw_out_len: ls_length});
  }
  async add(INPUT) {
    let name = INPUT?.name;
    if (name?.getQualifiedName === undefined || name.getQualifiedName() !== "STRING") { name = undefined; }
    if (name === undefined) { name = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.name); }
    let content = INPUT?.content;
    if (content?.getQualifiedName === undefined || content.getQualifiedName() !== "XSTRING") { content = undefined; }
    if (content === undefined) { content = new abap.types.XString({qualifiedName: "XSTRING"}).set(INPUT.content); }
    let ls_contents = new abap.types.Structure({"name": new abap.types.String({qualifiedName: "CL_ABAP_ZIP=>TY_CONTENTS-NAME"}), "content": new abap.types.XString({qualifiedName: "CL_ABAP_ZIP=>TY_CONTENTS-CONTENT"}), "compressed": new abap.types.XString({qualifiedName: "CL_ABAP_ZIP=>TY_CONTENTS-COMPRESSED"})}, "cl_abap_zip=>ty_contents", undefined, {}, {});
    ls_contents.get().name.set(name);
    ls_contents.get().content.set(content);
    await abap.Classes['CL_ABAP_GZIP'].compress_binary({raw_in: content, gzip_out: ls_contents.get().compressed});
    abap.statements.insertInternal({data: ls_contents, table: this.mt_contents});
  }
  async load(INPUT) {
    let zip = INPUT?.zip;
    if (zip?.getQualifiedName === undefined || zip.getQualifiedName() !== "XSTRING") { zip = undefined; }
    if (zip === undefined) { zip = new abap.types.XString({qualifiedName: "XSTRING"}).set(INPUT.zip); }
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
  }
  async save() {
    let val = new abap.types.XString({qualifiedName: "XSTRING"});
    let lo_total = new abap.types.ABAPObject({qualifiedName: "LCL_STREAM", RTTIName: "\\CLASS-POOL=CL_ABAP_ZIP\\CLASS=LCL_STREAM"});
    let lo_file = new abap.types.ABAPObject({qualifiedName: "LCL_STREAM", RTTIName: "\\CLASS-POOL=CL_ABAP_ZIP\\CLASS=LCL_STREAM"});
    let lo_central = new abap.types.ABAPObject({qualifiedName: "LCL_STREAM", RTTIName: "\\CLASS-POOL=CL_ABAP_ZIP\\CLASS=LCL_STREAM"});
    let ls_contents = new abap.types.Structure({"name": new abap.types.String({qualifiedName: "CL_ABAP_ZIP=>TY_CONTENTS-NAME"}), "content": new abap.types.XString({qualifiedName: "CL_ABAP_ZIP=>TY_CONTENTS-CONTENT"}), "compressed": new abap.types.XString({qualifiedName: "CL_ABAP_ZIP=>TY_CONTENTS-COMPRESSED"})}, "cl_abap_zip=>ty_contents", undefined, {}, {});
    let lv_buffer = new abap.types.XString({qualifiedName: "XSTRING"});
    let lv_tmp = new abap.types.XString({qualifiedName: "XSTRING"});
    let lv_start = new abap.types.Integer({qualifiedName: "I"});
    let lo_conv = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_CONV_OUT_CE", RTTIName: "\\CLASS=CL_ABAP_CONV_OUT_CE"});
    lo_central.set(await (new abap.Classes['CLAS-CL_ABAP_ZIP-LCL_STREAM']()).constructor_());
    lo_total.set(await (new abap.Classes['CLAS-CL_ABAP_ZIP-LCL_STREAM']()).constructor_());
    lo_conv.set((await abap.Classes['CL_ABAP_CONV_OUT_CE'].create()));
    for await (const unique13 of abap.statements.loop(this.mt_contents)) {
      ls_contents.set(unique13);
      await lo_conv.get().convert({data: ls_contents.get().name, buffer: lv_buffer});
      lo_file.set(await (new abap.Classes['CLAS-CL_ABAP_ZIP-LCL_STREAM']()).constructor_());
      await lo_file.get().append({iv_xstr: new abap.types.Character(8).set('504B0304')});
      await lo_file.get().append({iv_xstr: new abap.types.Character(4).set('1400')});
      await lo_file.get().append({iv_xstr: new abap.types.Character(4).set('0000')});
      await lo_file.get().append({iv_xstr: new abap.types.Character(4).set('0800')});
      await lo_file.get().append({iv_xstr: new abap.types.Character(4).set('0699')});
      await lo_file.get().append({iv_xstr: new abap.types.Character(4).set('F856')});
      await lo_file.get().append_crc({iv_little_endian: abap.builtin.abap_true, iv_xstring: ls_contents.get().content});
      await lo_file.get().append_int4({iv_int: abap.builtin.xstrlen({val: ls_contents.get().compressed})});
      await lo_file.get().append_int4({iv_int: abap.builtin.xstrlen({val: ls_contents.get().content})});
      await lo_file.get().append_int2({iv_int: abap.builtin.xstrlen({val: lv_buffer})});
      await lo_file.get().append({iv_xstr: new abap.types.Character(4).set('0000')});
      await lo_file.get().append({iv_xstr: lv_buffer});
      await lo_file.get().append({iv_xstr: ls_contents.get().compressed});
      await lo_central.get().append({iv_xstr: new abap.types.Character(8).set('504B0102')});
      await lo_central.get().append({iv_xstr: new abap.types.Character(4).set('1400')});
      lv_tmp.set((await lo_file.get().get()));
      await lo_central.get().append({iv_xstr: lv_tmp.getOffset({offset: 4, length: 26})});
      await lo_central.get().append_int2({iv_int: abap.IntegerFactory.get(0)});
      await lo_central.get().append_int2({iv_int: abap.IntegerFactory.get(0)});
      await lo_central.get().append_int2({iv_int: abap.IntegerFactory.get(0)});
      await lo_central.get().append_int4({iv_int: abap.IntegerFactory.get(0)});
      await lo_central.get().append_int4({iv_int: (abap.builtin.xstrlen({val: (await lo_total.get().get())}))});
      await lo_central.get().append({iv_xstr: lv_buffer});
      await lo_total.get().append({iv_xstr: (await lo_file.get().get())});
    }
    lv_start.set((abap.builtin.xstrlen({val: (await lo_total.get().get())})));
    await lo_total.get().append({iv_xstr: (await lo_central.get().get())});
    await lo_total.get().append({iv_xstr: new abap.types.Character(8).set('504B0506')});
    await lo_total.get().append_int2({iv_int: abap.IntegerFactory.get(0)});
    await lo_total.get().append_int2({iv_int: abap.IntegerFactory.get(0)});
    await lo_total.get().append_int2({iv_int: abap.builtin.lines({val: this.mt_contents})});
    await lo_total.get().append_int2({iv_int: abap.builtin.lines({val: this.mt_contents})});
    await lo_total.get().append_int4({iv_int: (abap.builtin.xstrlen({val: (await lo_central.get().get())}))});
    await lo_total.get().append_int4({iv_int: lv_start});
    await lo_total.get().append_int2({iv_int: abap.IntegerFactory.get(0)});
    val.set((await lo_total.get().get()));
    return val;
  }
}
abap.Classes['CL_ABAP_ZIP'] = cl_abap_zip;
cl_abap_zip.t_file = new abap.types.Structure({"name": new abap.types.String({qualifiedName: "CL_ABAP_ZIP=>T_FILE-NAME"}), "size": new abap.types.Integer({qualifiedName: "CL_ABAP_ZIP=>T_FILE-SIZE"})}, "cl_abap_zip=>t_file", undefined, {}, {});
cl_abap_zip.t_files = abap.types.TableFactory.construct(new abap.types.Structure({"name": new abap.types.String({qualifiedName: "CL_ABAP_ZIP=>T_FILE-NAME"}), "size": new abap.types.Integer({qualifiedName: "CL_ABAP_ZIP=>T_FILE-SIZE"})}, "cl_abap_zip=>t_file", undefined, {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "cl_abap_zip=>t_files");
cl_abap_zip.ty_contents = new abap.types.Structure({"name": new abap.types.String({qualifiedName: "CL_ABAP_ZIP=>TY_CONTENTS-NAME"}), "content": new abap.types.XString({qualifiedName: "CL_ABAP_ZIP=>TY_CONTENTS-CONTENT"}), "compressed": new abap.types.XString({qualifiedName: "CL_ABAP_ZIP=>TY_CONTENTS-COMPRESSED"})}, "cl_abap_zip=>ty_contents", undefined, {}, {});
export {cl_abap_zip};
//# sourceMappingURL=cl_abap_zip.clas.mjs.map