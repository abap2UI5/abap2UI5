const {cx_root} = await import("./cx_root.clas.mjs");
// cl_sxml_string_writer.clas.abap
class cl_sxml_string_writer {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CL_SXML_STRING_WRITER';
  static IMPLEMENTED_INTERFACES = ["IF_SXML_WRITER"];
  static ATTRIBUTES = {"MV_OUTPUT": {"type": () => {return new abap.types.XString({qualifiedName: "XSTRING"});}, "visibility": "I", "is_constant": " ", "is_class": " "},
  "MV_TYPE": {"type": () => {return new abap.types.Integer({qualifiedName: "IF_SXML=>XML_STREAM_TYPE"});}, "visibility": "I", "is_constant": " ", "is_class": " "},
  "MT_STACK": {"type": () => {return abap.types.TableFactory.construct(new abap.types.String({qualifiedName: "STRING"}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "");}, "visibility": "I", "is_constant": " ", "is_class": " "},
  "IF_SXML_WRITER~CO_OPT_NORMALIZING": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "IF_SXML_WRITER~CO_OPT_NO_EMPTY": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "IF_SXML_WRITER~CO_OPT_IGNORE_CONV_ERRROS": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "IF_SXML_WRITER~CO_OPT_LINEBREAKS": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "IF_SXML_WRITER~CO_OPT_INDENT": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "IF_SXML_WRITER~CO_OPT_ILLEGAL_CHAR_REJECT": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "IF_SXML_WRITER~CO_OPT_ILLEGAL_CHAR_REPLACE": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "IF_SXML_WRITER~CO_OPT_ILLEGAL_CHAR_REPLACE_BY": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "IF_SXML_WRITER~CO_OPT_BASE64_NO_LF": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": "X", "is_class": "X"}};
  static METHODS = {"APPEND_TEXT": {"visibility": "I", "parameters": {"TEXT": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}},
  "GET_TEXT": {"visibility": "I", "parameters": {"TEXT": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}},
  "PEEK": {"visibility": "I", "parameters": {"RV_NAME": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}},
  "REMOVE": {"visibility": "I", "parameters": {"RV_NAME": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}},
  "CONSTRUCTOR": {"visibility": "U", "parameters": {"TYPE": {"type": () => {return new abap.types.Integer({qualifiedName: "IF_SXML=>XML_STREAM_TYPE"});}, "is_optional": " "}}},
  "GET_OUTPUT": {"visibility": "U", "parameters": {"OUTPUT": {"type": () => {return new abap.types.XString({qualifiedName: "XSTRING"});}, "is_optional": " "}}},
  "CREATE": {"visibility": "U", "parameters": {"WRITER": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "CL_SXML_STRING_WRITER", RTTIName: "\\CLASS=CL_SXML_STRING_WRITER"});}, "is_optional": " "}, "TYPE": {"type": () => {return new abap.types.Integer({qualifiedName: "IF_SXML=>XML_STREAM_TYPE"});}, "is_optional": " "}, "IGNORE_CONVERSION_ERRORS": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});}, "is_optional": " "}, "NORMALIZING": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});}, "is_optional": " "}, "NO_EMPTY_ELEMENTS": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});}, "is_optional": " "}, "ENCODING": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}}};
  constructor() {
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
    this.mv_output = new abap.types.XString({qualifiedName: "XSTRING"});
    this.mv_type = new abap.types.Integer({qualifiedName: "IF_SXML=>XML_STREAM_TYPE"});
    this.mt_stack = abap.types.TableFactory.construct(new abap.types.String({qualifiedName: "STRING"}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "");
    this.if_sxml_writer$co_opt_normalizing = abap.Classes['IF_SXML_WRITER'].if_sxml_writer$co_opt_normalizing;
    this.if_sxml_writer$co_opt_no_empty = abap.Classes['IF_SXML_WRITER'].if_sxml_writer$co_opt_no_empty;
    this.if_sxml_writer$co_opt_ignore_conv_errros = abap.Classes['IF_SXML_WRITER'].if_sxml_writer$co_opt_ignore_conv_errros;
    this.if_sxml_writer$co_opt_linebreaks = abap.Classes['IF_SXML_WRITER'].if_sxml_writer$co_opt_linebreaks;
    this.if_sxml_writer$co_opt_indent = abap.Classes['IF_SXML_WRITER'].if_sxml_writer$co_opt_indent;
    this.if_sxml_writer$co_opt_illegal_char_reject = abap.Classes['IF_SXML_WRITER'].if_sxml_writer$co_opt_illegal_char_reject;
    this.if_sxml_writer$co_opt_illegal_char_replace = abap.Classes['IF_SXML_WRITER'].if_sxml_writer$co_opt_illegal_char_replace;
    this.if_sxml_writer$co_opt_illegal_char_replace_by = abap.Classes['IF_SXML_WRITER'].if_sxml_writer$co_opt_illegal_char_replace_by;
    this.if_sxml_writer$co_opt_base64_no_lf = abap.Classes['IF_SXML_WRITER'].if_sxml_writer$co_opt_base64_no_lf;
  }
  async constructor_(INPUT) {
    let type = INPUT?.type;
    if (type?.getQualifiedName === undefined || type.getQualifiedName() !== "IF_SXML=>XML_STREAM_TYPE") { type = undefined; }
    if (type === undefined) { type = new abap.types.Integer({qualifiedName: "IF_SXML=>XML_STREAM_TYPE"}).set(INPUT.type); }
    this.mv_type.set(type);
    return this;
  }
  async if_sxml_writer$new_close_element() {
    return cl_sxml_string_writer.if_sxml_writer$new_close_element();
  }
  static async if_sxml_writer$new_close_element() {
    let element = new abap.types.ABAPObject({qualifiedName: "IF_SXML_CLOSE_ELEMENT", RTTIName: "\\INTERFACE=IF_SXML_CLOSE_ELEMENT"});
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return element;
  }
  async if_sxml_writer$write_attribute_raw(INPUT) {
    let name = INPUT?.name;
    if (name?.getQualifiedName === undefined || name.getQualifiedName() !== "STRING") { name = undefined; }
    if (name === undefined) { name = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.name); }
    let nsuri = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.nsuri) {nsuri.set(INPUT.nsuri);}
    let prefix = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.prefix) {prefix.set(INPUT.prefix);}
    let value = new abap.types.XString({qualifiedName: "XSTRING"});
    if (INPUT && INPUT.value) {value.set(INPUT.value);}
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
  }
  async if_sxml_writer$new_value() {
    return cl_sxml_string_writer.if_sxml_writer$new_value();
  }
  static async if_sxml_writer$new_value() {
    let value = new abap.types.ABAPObject({qualifiedName: "IF_SXML_VALUE_NODE", RTTIName: "\\INTERFACE=IF_SXML_VALUE_NODE"});
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return value;
  }
  async if_sxml_writer$new_open_element(INPUT) {
    return cl_sxml_string_writer.if_sxml_writer$new_open_element(INPUT);
  }
  static async if_sxml_writer$new_open_element(INPUT) {
    let element = new abap.types.ABAPObject({qualifiedName: "IF_SXML_OPEN_ELEMENT", RTTIName: "\\INTERFACE=IF_SXML_OPEN_ELEMENT"});
    let name = INPUT?.name;
    if (name?.getQualifiedName === undefined || name.getQualifiedName() !== "STRING") { name = undefined; }
    if (name === undefined) { name = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.name); }
    let nsuri = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.nsuri) {nsuri.set(INPUT.nsuri);}
    let prefix = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.prefix) {prefix.set(INPUT.prefix);}
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return element;
  }
  async if_sxml_writer$write_value_raw(INPUT) {
    let value = INPUT?.value;
    if (value?.getQualifiedName === undefined || value.getQualifiedName() !== "XSTRING") { value = undefined; }
    if (value === undefined) { value = new abap.types.XString({qualifiedName: "XSTRING"}).set(INPUT.value); }
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
  }
  async if_sxml_writer$write_namespace_declaration(INPUT) {
    let nsuri = INPUT?.nsuri;
    if (nsuri?.getQualifiedName === undefined || nsuri.getQualifiedName() !== "STRING") { nsuri = undefined; }
    if (nsuri === undefined) { nsuri = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.nsuri); }
    let prefix = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.prefix) {prefix.set(INPUT.prefix);}
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
  }
  async if_sxml_writer$write_node(INPUT) {
    let node = INPUT?.node;
    if (node?.getQualifiedName === undefined || node.getQualifiedName() !== "IF_SXML_NODE") { node = undefined; }
    if (node === undefined) { node = new abap.types.ABAPObject({qualifiedName: "IF_SXML_NODE", RTTIName: "\\INTERFACE=IF_SXML_NODE"}).set(INPUT.node); }
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
  }
  async create(INPUT) {
    return cl_sxml_string_writer.create(INPUT);
  }
  static async create(INPUT) {
    let writer = new abap.types.ABAPObject({qualifiedName: "CL_SXML_STRING_WRITER", RTTIName: "\\CLASS=CL_SXML_STRING_WRITER"});
    let type = new abap.types.Integer({qualifiedName: "IF_SXML=>XML_STREAM_TYPE"});
    if (INPUT && INPUT.type) {type.set(INPUT.type);}
    if (INPUT === undefined || INPUT.type === undefined) {type = abap.Classes['IF_SXML'].if_sxml$co_xt_xml10;}
    let ignore_conversion_errors = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    if (INPUT && INPUT.ignore_conversion_errors) {ignore_conversion_errors.set(INPUT.ignore_conversion_errors);}
    if (INPUT === undefined || INPUT.ignore_conversion_errors === undefined) {ignore_conversion_errors = abap.builtin.abap_false;}
    let normalizing = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    if (INPUT && INPUT.normalizing) {normalizing.set(INPUT.normalizing);}
    if (INPUT === undefined || INPUT.normalizing === undefined) {normalizing = abap.builtin.abap_false;}
    let no_empty_elements = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    if (INPUT && INPUT.no_empty_elements) {no_empty_elements.set(INPUT.no_empty_elements);}
    if (INPUT === undefined || INPUT.no_empty_elements === undefined) {no_empty_elements = abap.builtin.abap_false;}
    let encoding = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.encoding) {encoding.set(INPUT.encoding);}
    if (INPUT === undefined || INPUT.encoding === undefined) {encoding = new abap.types.Character(5).set('UTF-8');}
    writer.set(await (new abap.Classes['CL_SXML_STRING_WRITER']()).constructor_({type: type}));
    return writer;
  }
  async if_sxml_writer$set_option(INPUT) {
    let option = INPUT?.option;
    if (option?.getQualifiedName === undefined || option.getQualifiedName() !== "I") { option = undefined; }
    if (option === undefined) { option = new abap.types.Integer({qualifiedName: "I"}).set(INPUT.option); }
    let value = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    if (INPUT && INPUT.value) {value.set(INPUT.value);}
    if (INPUT === undefined || INPUT.value === undefined) {value = abap.builtin.abap_true;}
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
  }
  async get_output() {
    let output = new abap.types.XString({qualifiedName: "XSTRING"});
    output.set(this.mv_output);
    return output;
  }
  async append_text(INPUT) {
    let text = INPUT?.text;
    if (text?.getQualifiedName === undefined || text.getQualifiedName() !== "STRING") { text = undefined; }
    if (text === undefined) { text = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.text); }
    let append = new abap.types.XString({qualifiedName: "XSTRING"});
    append.set((await (await abap.Classes['CL_ABAP_CONV_CODEPAGE'].create_out()).get().if_abap_conv_out$convert({source: text})));
    abap.statements.concatenate({source: [this.mv_output, append], target: this.mv_output});
  }
  async get_text() {
    let text = new abap.types.String({qualifiedName: "STRING"});
    text.set((await (await abap.Classes['CL_ABAP_CONV_CODEPAGE'].create_in()).get().if_abap_conv_in$convert({source: this.mv_output})));
    return text;
  }
  async if_sxml_writer$open_element(INPUT) {
    let name = INPUT?.name;
    if (name?.getQualifiedName === undefined || name.getQualifiedName() !== "STRING") { name = undefined; }
    if (name === undefined) { name = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.name); }
    let nsuri = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.nsuri) {nsuri.set(INPUT.nsuri);}
    let prefix = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.prefix) {prefix.set(INPUT.prefix);}
    let parent = new abap.types.String({qualifiedName: "STRING"});
    parent.set((await this.peek()));
    if (abap.compare.eq(parent, new abap.types.Character(5).set('array')) && abap.compare.np((await this.get_text()), new abap.types.Character(2).set('*['))) {
      await this.append_text({text: new abap.types.Character(1).set(',')});
    }
    if (abap.compare.eq(parent, new abap.types.Character(6).set('object')) && abap.compare.np((await this.get_text()), new abap.types.Character(2).set('*{'))) {
      await this.append_text({text: new abap.types.Character(1).set(',')});
    }
    abap.statements.append({source: name, target: this.mt_stack});
    let unique146 = name;
    if (abap.compare.eq(unique146, new abap.types.Character(6).set('object'))) {
      await this.append_text({text: new abap.types.Character(1).set('{')});
    } else if (abap.compare.eq(unique146, new abap.types.Character(5).set('array'))) {
      await this.append_text({text: new abap.types.Character(1).set('[')});
    }
  }
  async remove() {
    let rv_name = new abap.types.String({qualifiedName: "STRING"});
    let index = new abap.types.Integer({qualifiedName: "I"});
    index.set(abap.builtin.lines({val: this.mt_stack}));
    abap.statements.readTable(this.mt_stack,{index: index,
      into: rv_name});
    await abap.statements.deleteInternal(this.mt_stack,{index: index});
    return rv_name;
  }
  async if_sxml_writer$close_element() {
    let name = new abap.types.String({qualifiedName: "STRING"});
    name.set((await this.remove()));
    let unique147 = name;
    if (abap.compare.eq(unique147, new abap.types.Character(6).set('object'))) {
      await this.append_text({text: new abap.types.Character(1).set('}')});
    } else if (abap.compare.eq(unique147, new abap.types.Character(5).set('array'))) {
      await this.append_text({text: new abap.types.Character(1).set(']')});
    }
  }
  async if_sxml_writer$write_attribute(INPUT) {
    let name = INPUT?.name;
    if (name?.getQualifiedName === undefined || name.getQualifiedName() !== "STRING") { name = undefined; }
    if (name === undefined) { name = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.name); }
    let nsuri = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.nsuri) {nsuri.set(INPUT.nsuri);}
    let prefix = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.prefix) {prefix.set(INPUT.prefix);}
    let value = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.value) {value.set(INPUT.value);}
    await this.append_text({text: new abap.types.Character(1).set('"')});
    await this.append_text({text: value});
    await this.append_text({text: new abap.types.Character(2).set('":')});
  }
  async peek() {
    let rv_name = new abap.types.String({qualifiedName: "STRING"});
    let index = new abap.types.Integer({qualifiedName: "I"});
    index.set(abap.builtin.lines({val: this.mt_stack}));
    abap.statements.readTable(this.mt_stack,{index: index,
      into: rv_name});
    return rv_name;
  }
  async if_sxml_writer$write_value(INPUT) {
    let value = INPUT?.value;
    if (value?.getQualifiedName === undefined || value.getQualifiedName() !== "STRING") { value = undefined; }
    if (value === undefined) { value = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.value); }
    let name = new abap.types.String({qualifiedName: "STRING"});
    name.set((await this.peek()));
    let unique148 = name;
    if (abap.compare.eq(unique148, new abap.types.Character(3).set('str'))) {
      await this.append_text({text: new abap.types.Character(1).set('"')});
      await this.append_text({text: abap.builtin.condense({val: value})});
      await this.append_text({text: new abap.types.Character(1).set('"')});
    } else if (abap.compare.eq(unique148, new abap.types.Character(3).set('num'))) {
      await this.append_text({text: abap.builtin.condense({val: value})});
    } else {
      console.dir(name);
      abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(31).set('todo_if_sxml_writer_write_value')));
    }
  }
}
abap.Classes['CL_SXML_STRING_WRITER'] = cl_sxml_string_writer;
cl_sxml_string_writer.if_sxml_writer$co_opt_normalizing = new abap.types.Integer({qualifiedName: "I"});
cl_sxml_string_writer.if_sxml_writer$co_opt_normalizing.set(1);
cl_sxml_string_writer.if_sxml_writer$co_opt_no_empty = new abap.types.Integer({qualifiedName: "I"});
cl_sxml_string_writer.if_sxml_writer$co_opt_no_empty.set(2);
cl_sxml_string_writer.if_sxml_writer$co_opt_ignore_conv_errros = new abap.types.Integer({qualifiedName: "I"});
cl_sxml_string_writer.if_sxml_writer$co_opt_ignore_conv_errros.set(3);
cl_sxml_string_writer.if_sxml_writer$co_opt_linebreaks = new abap.types.Integer({qualifiedName: "I"});
cl_sxml_string_writer.if_sxml_writer$co_opt_linebreaks.set(4);
cl_sxml_string_writer.if_sxml_writer$co_opt_indent = new abap.types.Integer({qualifiedName: "I"});
cl_sxml_string_writer.if_sxml_writer$co_opt_indent.set(5);
cl_sxml_string_writer.if_sxml_writer$co_opt_illegal_char_reject = new abap.types.Integer({qualifiedName: "I"});
cl_sxml_string_writer.if_sxml_writer$co_opt_illegal_char_reject.set(6);
cl_sxml_string_writer.if_sxml_writer$co_opt_illegal_char_replace = new abap.types.Integer({qualifiedName: "I"});
cl_sxml_string_writer.if_sxml_writer$co_opt_illegal_char_replace.set(7);
cl_sxml_string_writer.if_sxml_writer$co_opt_illegal_char_replace_by = new abap.types.Integer({qualifiedName: "I"});
cl_sxml_string_writer.if_sxml_writer$co_opt_illegal_char_replace_by.set(8);
cl_sxml_string_writer.if_sxml_writer$co_opt_base64_no_lf = new abap.types.Integer({qualifiedName: "I"});
cl_sxml_string_writer.if_sxml_writer$co_opt_base64_no_lf.set(9);
export {cl_sxml_string_writer};
//# sourceMappingURL=cl_sxml_string_writer.clas.mjs.map