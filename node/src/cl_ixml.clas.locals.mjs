const {cx_root} = await import("./cx_root.clas.mjs");
// cl_ixml.clas.locals_imp.abap
class lcl_escape {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CLAS-CL_IXML-LCL_ESCAPE';
  static IMPLEMENTED_INTERFACES = [];
  static ATTRIBUTES = {};
  static METHODS = {"UNESCAPE_VALUE": {"visibility": "U", "parameters": {"RV_VALUE": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "IV_VALUE": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}},
  "ESCAPE_VALUE": {"visibility": "U", "parameters": {"RV_VALUE": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "IV_VALUE": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}}};
  constructor() {
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
  }
  async constructor_(INPUT) {
    if (super.constructor_) { await super.constructor_(INPUT); }
    return this;
  }
  async unescape_value(INPUT) {
    return lcl_escape.unescape_value(INPUT);
  }
  static async unescape_value(INPUT) {
    let rv_value = new abap.types.String({qualifiedName: "STRING"});
    let iv_value = INPUT?.iv_value;
    if (iv_value?.getQualifiedName === undefined || iv_value.getQualifiedName() !== "STRING") { iv_value = undefined; }
    if (iv_value === undefined) { iv_value = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.iv_value); }
    rv_value.set(iv_value);
    abap.statements.replace({target: rv_value, all: true, with: new abap.types.Character(1).set('&'), of: new abap.types.Character(5).set('&amp;')});
    abap.statements.replace({target: rv_value, all: true, with: new abap.types.Character(1).set('<'), of: new abap.types.Character(4).set('&lt;')});
    abap.statements.replace({target: rv_value, all: true, with: new abap.types.Character(1).set('>'), of: new abap.types.Character(4).set('&gt;')});
    abap.statements.replace({target: rv_value, all: true, with: new abap.types.Character(1).set('"'), of: new abap.types.Character(6).set('&quot;')});
    abap.statements.replace({target: rv_value, all: true, with: new abap.types.String().set(`'`), of: new abap.types.Character(6).set('&apos;')});
    return rv_value;
  }
  async escape_value(INPUT) {
    return lcl_escape.escape_value(INPUT);
  }
  static async escape_value(INPUT) {
    let rv_value = new abap.types.String({qualifiedName: "STRING"});
    let iv_value = INPUT?.iv_value;
    if (iv_value?.getQualifiedName === undefined || iv_value.getQualifiedName() !== "STRING") { iv_value = undefined; }
    if (iv_value === undefined) { iv_value = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.iv_value); }
    rv_value.set(iv_value);
    abap.statements.replace({target: rv_value, all: true, with: new abap.types.Character(5).set('&amp;'), of: new abap.types.Character(1).set('&')});
    abap.statements.replace({target: rv_value, all: true, with: new abap.types.Character(4).set('&lt;'), of: new abap.types.Character(1).set('<')});
    abap.statements.replace({target: rv_value, all: true, with: new abap.types.Character(4).set('&gt;'), of: new abap.types.Character(1).set('>')});
    abap.statements.replace({target: rv_value, all: true, with: new abap.types.Character(6).set('&quot;'), of: new abap.types.Character(1).set('"')});
    abap.statements.replace({target: rv_value, all: true, with: new abap.types.Character(6).set('&apos;'), of: new abap.types.String().set(`'`)});
    return rv_value;
  }
}
abap.Classes['CLAS-CL_IXML-LCL_ESCAPE'] = lcl_escape;
class lcl_node_iterator {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CLAS-CL_IXML-LCL_NODE_ITERATOR';
  static IMPLEMENTED_INTERFACES = ["IF_IXML_NODE_ITERATOR"];
  static ATTRIBUTES = {"MV_POINTER": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "I", "is_constant": " ", "is_class": " "},
  "MT_LIST": {"type": () => {return abap.types.TableFactory.construct(new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE", RTTIName: "\\INTERFACE=IF_IXML_NODE"}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "lcl_node_iterator=>ty_list");}, "visibility": "I", "is_constant": " ", "is_class": " "}};
  static METHODS = {"CONSTRUCTOR": {"visibility": "U", "parameters": {"IT_LIST": {"type": () => {return abap.types.TableFactory.construct(new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE", RTTIName: "\\INTERFACE=IF_IXML_NODE"}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "lcl_node_iterator=>ty_list");}, "is_optional": " "}}}};
  constructor() {
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
    this.mv_pointer = new abap.types.Integer({qualifiedName: "I"});
    this.mt_list = abap.types.TableFactory.construct(new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE", RTTIName: "\\INTERFACE=IF_IXML_NODE"}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "lcl_node_iterator=>ty_list");
  }
  async constructor_(INPUT) {
    let it_list = INPUT?.it_list;
    if (it_list?.getQualifiedName === undefined || it_list.getQualifiedName() !== "LCL_NODE_ITERATOR=>TY_LIST") { it_list = undefined; }
    if (it_list === undefined) { it_list = abap.types.TableFactory.construct(new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE", RTTIName: "\\INTERFACE=IF_IXML_NODE"}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "lcl_node_iterator=>ty_list").set(INPUT.it_list); }
    this.mt_list.set(it_list);
    this.mv_pointer.set(abap.IntegerFactory.get(1));
    return this;
  }
  async if_ixml_node_iterator$reset() {
    this.mv_pointer.set(abap.IntegerFactory.get(1));
  }
  async if_ixml_node_iterator$get_next() {
    let rval = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE", RTTIName: "\\INTERFACE=IF_IXML_NODE"});
    abap.statements.readTable(this.mt_list,{index: this.mv_pointer,
      into: rval});
    this.mv_pointer.set(abap.operators.add(this.mv_pointer,abap.IntegerFactory.get(1)));
    return rval;
  }
}
abap.Classes['CLAS-CL_IXML-LCL_NODE_ITERATOR'] = lcl_node_iterator;
lcl_node_iterator.ty_list = abap.types.TableFactory.construct(new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE", RTTIName: "\\INTERFACE=IF_IXML_NODE"}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "lcl_node_iterator=>ty_list");
class lcl_encoding {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CLAS-CL_IXML-LCL_ENCODING';
  static IMPLEMENTED_INTERFACES = ["IF_IXML_ENCODING"];
  static ATTRIBUTES = {"IF_IXML_ENCODING~CO_NONE": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "IF_IXML_ENCODING~CO_BIG_ENDIAN": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "IF_IXML_ENCODING~CO_PLATFORM_ENDIAN": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": "X", "is_class": "X"}};
  static METHODS = {};
  constructor() {
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
    this.if_ixml_encoding$co_none = abap.Classes['IF_IXML_ENCODING'].if_ixml_encoding$co_none;
    this.if_ixml_encoding$co_big_endian = abap.Classes['IF_IXML_ENCODING'].if_ixml_encoding$co_big_endian;
    this.if_ixml_encoding$co_platform_endian = abap.Classes['IF_IXML_ENCODING'].if_ixml_encoding$co_platform_endian;
  }
  async constructor_(INPUT) {
    if (super.constructor_) { await super.constructor_(INPUT); }
    return this;
  }
  async if_ixml_encoding$get_byte_order() {
    let rval = new abap.types.Integer({qualifiedName: "I"});
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return rval;
  }
  async if_ixml_encoding$get_character_set() {
    let rval = new abap.types.String({qualifiedName: "STRING"});
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return rval;
  }
}
abap.Classes['CLAS-CL_IXML-LCL_ENCODING'] = lcl_encoding;
lcl_encoding.if_ixml_encoding$co_none = new abap.types.Integer({qualifiedName: "I"});
lcl_encoding.if_ixml_encoding$co_none.set(0);
lcl_encoding.if_ixml_encoding$co_big_endian = new abap.types.Integer({qualifiedName: "I"});
lcl_encoding.if_ixml_encoding$co_big_endian.set(1);
lcl_encoding.if_ixml_encoding$co_platform_endian = new abap.types.Integer({qualifiedName: "I"});
lcl_encoding.if_ixml_encoding$co_platform_endian.set(4);
class lcl_named_node_map {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CLAS-CL_IXML-LCL_NAMED_NODE_MAP';
  static IMPLEMENTED_INTERFACES = ["IF_IXML_NAMED_NODE_MAP"];
  static ATTRIBUTES = {"MT_LIST": {"type": () => {return abap.types.TableFactory.construct(new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE", RTTIName: "\\INTERFACE=IF_IXML_NODE"}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "");}, "visibility": "I", "is_constant": " ", "is_class": " "}};
  static METHODS = {};
  constructor() {
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
    this.mt_list = abap.types.TableFactory.construct(new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE", RTTIName: "\\INTERFACE=IF_IXML_NODE"}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "");
  }
  async constructor_(INPUT) {
    if (super.constructor_) { await super.constructor_(INPUT); }
    return this;
  }
  async if_ixml_named_node_map$create_iterator() {
    let iterator = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE_ITERATOR", RTTIName: "\\INTERFACE=IF_IXML_NODE_ITERATOR"});
    iterator.set(await (new abap.Classes['CLAS-CL_IXML-LCL_NODE_ITERATOR']()).constructor_({it_list: this.mt_list}));
    return iterator;
  }
  async if_ixml_named_node_map$get_length() {
    let val = new abap.types.Integer({qualifiedName: "I"});
    val.set(abap.builtin.lines({val: this.mt_list}));
    return val;
  }
  async if_ixml_named_node_map$get_named_item_ns(INPUT) {
    let val = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE", RTTIName: "\\INTERFACE=IF_IXML_NODE"});
    let name = INPUT?.name;
    if (name?.getQualifiedName === undefined || name.getQualifiedName() !== "STRING") { name = undefined; }
    if (name === undefined) { name = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.name); }
    let li_node = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE", RTTIName: "\\INTERFACE=IF_IXML_NODE"});
    for await (const unique46 of abap.statements.loop(this.mt_list)) {
      li_node.set(unique46);
      if (abap.compare.eq((await li_node.get().if_ixml_node$get_name()), name)) {
        val.set(li_node);
        return val;
      }
    }
    return val;
  }
  async if_ixml_named_node_map$get_named_item(INPUT) {
    let val = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE", RTTIName: "\\INTERFACE=IF_IXML_NODE"});
    let name = INPUT?.name;
    if (name?.getQualifiedName === undefined || name.getQualifiedName() !== "STRING") { name = undefined; }
    if (name === undefined) { name = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.name); }
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return val;
  }
  async if_ixml_named_node_map$remove_named_item(INPUT) {
    let name = INPUT?.name;
    if (name?.getQualifiedName === undefined || name.getQualifiedName() !== "STRING") { name = undefined; }
    if (name === undefined) { name = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.name); }
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
  }
  async if_ixml_named_node_map$set_named_item_ns(INPUT) {
    let node = INPUT?.node;
    if (node?.getQualifiedName === undefined || node.getQualifiedName() !== "IF_IXML_NODE") { node = undefined; }
    if (node === undefined) { node = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE", RTTIName: "\\INTERFACE=IF_IXML_NODE"}).set(INPUT.node); }
    abap.statements.append({source: node, target: this.mt_list});
  }
}
abap.Classes['CLAS-CL_IXML-LCL_NAMED_NODE_MAP'] = lcl_named_node_map;
class lcl_node_list {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CLAS-CL_IXML-LCL_NODE_LIST';
  static IMPLEMENTED_INTERFACES = ["IF_IXML_NODE_LIST"];
  static ATTRIBUTES = {"MT_LIST": {"type": () => {return abap.types.TableFactory.construct(new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE", RTTIName: "\\INTERFACE=IF_IXML_NODE"}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "");}, "visibility": "I", "is_constant": " ", "is_class": " "}};
  static METHODS = {"APPEND": {"visibility": "U", "parameters": {"II_NODE": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE", RTTIName: "\\INTERFACE=IF_IXML_NODE"});}, "is_optional": " "}}},
  "REMOVE": {"visibility": "U", "parameters": {"II_NODE": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE", RTTIName: "\\INTERFACE=IF_IXML_NODE"});}, "is_optional": " "}}}};
  constructor() {
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
    this.mt_list = abap.types.TableFactory.construct(new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE", RTTIName: "\\INTERFACE=IF_IXML_NODE"}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "");
  }
  async constructor_(INPUT) {
    if (super.constructor_) { await super.constructor_(INPUT); }
    return this;
  }
  async append(INPUT) {
    let ii_node = INPUT?.ii_node;
    if (ii_node?.getQualifiedName === undefined || ii_node.getQualifiedName() !== "IF_IXML_NODE") { ii_node = undefined; }
    if (ii_node === undefined) { ii_node = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE", RTTIName: "\\INTERFACE=IF_IXML_NODE"}).set(INPUT.ii_node); }
    abap.statements.assert(abap.compare.initial(ii_node) === false);
    abap.statements.append({source: ii_node, target: this.mt_list});
  }
  async remove(INPUT) {
    let ii_node = INPUT?.ii_node;
    if (ii_node?.getQualifiedName === undefined || ii_node.getQualifiedName() !== "IF_IXML_NODE") { ii_node = undefined; }
    if (ii_node === undefined) { ii_node = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE", RTTIName: "\\INTERFACE=IF_IXML_NODE"}).set(INPUT.ii_node); }
    abap.statements.readTable(this.mt_list,{withKey: (i) => {return abap.compare.eq(i.table_line, ii_node);},
      withKeyValue: [{key: (i) => {return i.table_line}, value: ii_node}],
      usesTableLine: true,
      withKeySimple: {"table_line": ii_node}});
    if (abap.compare.eq(abap.builtin.sy.get().subrc, abap.IntegerFactory.get(0))) {
      await abap.statements.deleteInternal(this.mt_list,{index: abap.builtin.sy.get().tabix});
    }
  }
  async if_ixml_node_list$get_length() {
    let length = new abap.types.Integer({qualifiedName: "I"});
    length.set(abap.builtin.lines({val: this.mt_list}));
    return length;
  }
  async if_ixml_node_list$create_iterator() {
    let rval = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE_ITERATOR", RTTIName: "\\INTERFACE=IF_IXML_NODE_ITERATOR"});
    rval.set(await (new abap.Classes['CLAS-CL_IXML-LCL_NODE_ITERATOR']()).constructor_({it_list: this.mt_list}));
    return rval;
  }
  async if_ixml_node_list$get_item(INPUT) {
    let val = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE", RTTIName: "\\INTERFACE=IF_IXML_NODE"});
    let index = INPUT?.index;
    if (index?.getQualifiedName === undefined || index.getQualifiedName() !== "I") { index = undefined; }
    if (index === undefined) { index = new abap.types.Integer({qualifiedName: "I"}).set(INPUT.index); }
    abap.statements.readTable(this.mt_list,{index: index,
      into: val});
    return val;
  }
  async if_ixml_node_list$create_rev_iterator_filtered(INPUT) {
    let val = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE_ITERATOR", RTTIName: "\\INTERFACE=IF_IXML_NODE_ITERATOR"});
    let filter = INPUT?.filter;
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return val;
  }
}
abap.Classes['CLAS-CL_IXML-LCL_NODE_LIST'] = lcl_node_list;
class lcl_node {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CLAS-CL_IXML-LCL_NODE';
  static IMPLEMENTED_INTERFACES = ["IF_IXML_ELEMENT","IF_IXML_NODE"];
  static ATTRIBUTES = {"MV_NAME": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "visibility": "I", "is_constant": " ", "is_class": " "},
  "MV_NAMESPACE": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "visibility": "I", "is_constant": " ", "is_class": " "},
  "MV_VALUE": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "visibility": "I", "is_constant": " ", "is_class": " "},
  "MO_CHILDREN": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "LCL_NODE_LIST", RTTIName: "\\CLASS-POOL=CL_IXML\\CLASS=LCL_NODE_LIST"});}, "visibility": "I", "is_constant": " ", "is_class": " "},
  "MI_PARENT": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE", RTTIName: "\\INTERFACE=IF_IXML_NODE"});}, "visibility": "I", "is_constant": " ", "is_class": " "},
  "MI_ATTRIBUTES": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_IXML_NAMED_NODE_MAP", RTTIName: "\\INTERFACE=IF_IXML_NAMED_NODE_MAP"});}, "visibility": "I", "is_constant": " ", "is_class": " "},
  "IF_IXML_NODE~CO_NODE_DOCUMENT": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "IF_IXML_NODE~CO_NODE_ELEMENT": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "IF_IXML_NODE~CO_NODE_TEXT": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "IF_IXML_NODE~CO_NODE_CDATA_SECTION": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": "X", "is_class": "X"}};
  static METHODS = {"HAS_DIRECT_TEXT": {"visibility": "I", "parameters": {"RV_HAS": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});}, "is_optional": " "}}},
  "CONSTRUCTOR": {"visibility": "U", "parameters": {"II_PARENT": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE", RTTIName: "\\INTERFACE=IF_IXML_NODE"});}, "is_optional": " "}}}};
  constructor() {
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
    this.mv_name = new abap.types.String({qualifiedName: "STRING"});
    this.mv_namespace = new abap.types.String({qualifiedName: "STRING"});
    this.mv_value = new abap.types.String({qualifiedName: "STRING"});
    this.mo_children = new abap.types.ABAPObject({qualifiedName: "LCL_NODE_LIST", RTTIName: "\\CLASS-POOL=CL_IXML\\CLASS=LCL_NODE_LIST"});
    this.mi_parent = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE", RTTIName: "\\INTERFACE=IF_IXML_NODE"});
    this.mi_attributes = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NAMED_NODE_MAP", RTTIName: "\\INTERFACE=IF_IXML_NAMED_NODE_MAP"});
    this.if_ixml_node$co_node_document = abap.Classes['IF_IXML_NODE'].if_ixml_node$co_node_document;
    this.if_ixml_node$co_node_element = abap.Classes['IF_IXML_NODE'].if_ixml_node$co_node_element;
    this.if_ixml_node$co_node_text = abap.Classes['IF_IXML_NODE'].if_ixml_node$co_node_text;
    this.if_ixml_node$co_node_cdata_section = abap.Classes['IF_IXML_NODE'].if_ixml_node$co_node_cdata_section;
  }
  async constructor_(INPUT) {
    let ii_parent = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE", RTTIName: "\\INTERFACE=IF_IXML_NODE"});
    if (INPUT && INPUT.ii_parent) {ii_parent.set(INPUT.ii_parent);}
    this.mo_children.set(await (new abap.Classes['CLAS-CL_IXML-LCL_NODE_LIST']()).constructor_());
    this.mi_attributes.set(await (new abap.Classes['CLAS-CL_IXML-LCL_NAMED_NODE_MAP']()).constructor_());
    this.mi_parent.set(ii_parent);
    if (abap.compare.initial(this.mi_parent) === false) {
      await ii_parent.get().if_ixml_node$append_child({new_child: this.me});
    }
    return this;
  }
  async if_ixml_node$get_height() {
    let rval = new abap.types.Integer({qualifiedName: "I"});
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return rval;
  }
  async if_ixml_node$get_gid() {
    let rval = new abap.types.Integer({qualifiedName: "I"});
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return rval;
  }
  async if_ixml_node$insert_child(INPUT) {
    let rval = new abap.types.Integer({qualifiedName: "I"});
    let new_child = INPUT?.new_child;
    if (new_child?.getQualifiedName === undefined || new_child.getQualifiedName() !== "IF_IXML_NODE") { new_child = undefined; }
    if (new_child === undefined) { new_child = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE", RTTIName: "\\INTERFACE=IF_IXML_NODE"}).set(INPUT.new_child); }
    let ref_child = INPUT?.ref_child;
    if (ref_child?.getQualifiedName === undefined || ref_child.getQualifiedName() !== "IF_IXML_NODE") { ref_child = undefined; }
    if (ref_child === undefined) { ref_child = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE", RTTIName: "\\INTERFACE=IF_IXML_NODE"}).set(INPUT.ref_child); }
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return rval;
  }
  async if_ixml_node$clone() {
    let rval = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE", RTTIName: "\\INTERFACE=IF_IXML_NODE"});
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return rval;
  }
  async if_ixml_node$create_iterator_filtered(INPUT) {
    let rval = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE_ITERATOR", RTTIName: "\\INTERFACE=IF_IXML_NODE_ITERATOR"});
    let filter = INPUT?.filter;
    if (filter?.getQualifiedName === undefined || filter.getQualifiedName() !== "IF_IXML_NODE_FILTER") { filter = undefined; }
    if (filter === undefined) { filter = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE_FILTER", RTTIName: "\\INTERFACE=IF_IXML_NODE_FILTER"}).set(INPUT.filter); }
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return rval;
  }
  async if_ixml_node$get_column() {
    let rval = new abap.types.Integer({qualifiedName: "I"});
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return rval;
  }
  async if_ixml_node$create_filter_name_ns(INPUT) {
    let rval = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE_FILTER", RTTIName: "\\INTERFACE=IF_IXML_NODE_FILTER"});
    let name = INPUT?.name;
    if (name?.getQualifiedName === undefined || name.getQualifiedName() !== "STRING") { name = undefined; }
    if (name === undefined) { name = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.name); }
    let namespace = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.namespace) {namespace.set(INPUT.namespace);}
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return rval;
  }
  async if_ixml_element$get_attribute_node_ns(INPUT) {
    let val = new abap.types.ABAPObject({qualifiedName: "IF_IXML_ATTRIBUTE", RTTIName: "\\INTERFACE=IF_IXML_ATTRIBUTE"});
    let name = INPUT?.name;
    if (name?.getQualifiedName === undefined || name.getQualifiedName() !== "STRING") { name = undefined; }
    if (name === undefined) { name = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.name); }
    let uri = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.uri) {uri.set(INPUT.uri);}
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return val;
  }
  async if_ixml_node$get_next() {
    let rval = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE", RTTIName: "\\INTERFACE=IF_IXML_NODE"});
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return rval;
  }
  async if_ixml_node$get_namespace_prefix() {
    let rv_prefix = new abap.types.String({qualifiedName: "STRING"});
    rv_prefix.set(this.mv_namespace);
    return rv_prefix;
  }
  async if_ixml_node$get_namespace_uri() {
    let rval = new abap.types.String({qualifiedName: "STRING"});
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return rval;
  }
  async if_ixml_element$get_attributes() {
    let attr = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NAMED_NODE_MAP", RTTIName: "\\INTERFACE=IF_IXML_NAMED_NODE_MAP"});
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return attr;
  }
  async if_ixml_element$get_next() {
    let next = new abap.types.ABAPObject({qualifiedName: "IF_IXML_ELEMENT", RTTIName: "\\INTERFACE=IF_IXML_ELEMENT"});
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return next;
  }
  async if_ixml_element$get_name() {
    let name = new abap.types.String({qualifiedName: "STRING"});
    name.set(this.mv_name);
    return name;
  }
  async if_ixml_element$append_child(INPUT) {
    let rc = new abap.types.Integer({qualifiedName: "I"});
    let new_child = INPUT?.new_child;
    if (new_child?.getQualifiedName === undefined || new_child.getQualifiedName() !== "IF_IXML_NODE") { new_child = undefined; }
    if (new_child === undefined) { new_child = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE", RTTIName: "\\INTERFACE=IF_IXML_NODE"}).set(INPUT.new_child); }
    let lo_node = new abap.types.ABAPObject({qualifiedName: "LCL_NODE", RTTIName: "\\CLASS-POOL=CL_IXML\\CLASS=LCL_NODE"});
    await abap.statements.cast(lo_node, new_child);
    if (abap.compare.initial(lo_node.get().mi_parent) === false) {
      await lo_node.get().mi_parent.get().if_ixml_node$remove_child({child: lo_node});
    }
    lo_node.get().mi_parent.set(this.me);
    await this.mo_children.get().append({ii_node: new_child});
    return rc;
  }
  async if_ixml_element$clone() {
    let val = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE", RTTIName: "\\INTERFACE=IF_IXML_NODE"});
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return val;
  }
  async if_ixml_element$create_filter_node_type(INPUT) {
    let val = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE_FILTER", RTTIName: "\\INTERFACE=IF_IXML_NODE_FILTER"});
    let node_types = INPUT?.node_types;
    if (node_types?.getQualifiedName === undefined || node_types.getQualifiedName() !== "I") { node_types = undefined; }
    if (node_types === undefined) { node_types = new abap.types.Integer({qualifiedName: "I"}).set(INPUT.node_types); }
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return val;
  }
  async if_ixml_element$remove_attribute_ns(INPUT) {
    let foo = INPUT?.foo;
    if (foo?.getQualifiedName === undefined || foo.getQualifiedName() !== "STRING") { foo = undefined; }
    if (foo === undefined) { foo = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.foo); }
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
  }
  async if_ixml_element$create_iterator() {
    let val = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE_ITERATOR", RTTIName: "\\INTERFACE=IF_IXML_NODE_ITERATOR"});
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return val;
  }
  async if_ixml_element$find_from_name_ns(INPUT) {
    let val = new abap.types.ABAPObject({qualifiedName: "IF_IXML_ELEMENT", RTTIName: "\\INTERFACE=IF_IXML_ELEMENT"});
    let name = INPUT?.name;
    if (name?.getQualifiedName === undefined || name.getQualifiedName() !== "STRING") { name = undefined; }
    if (name === undefined) { name = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.name); }
    let namespace = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.namespace) {namespace.set(INPUT.namespace);}
    let uri = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.uri) {uri.set(INPUT.uri);}
    let depth = new abap.types.Integer({qualifiedName: "I"});
    if (INPUT && INPUT.depth) {depth.set(INPUT.depth);}
    let li_iterator = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE_ITERATOR", RTTIName: "\\INTERFACE=IF_IXML_NODE_ITERATOR"});
    let li_node = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE", RTTIName: "\\INTERFACE=IF_IXML_NODE"});
    let li_children = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE_LIST", RTTIName: "\\INTERFACE=IF_IXML_NODE_LIST"});
    let lt_nodes = abap.types.TableFactory.construct(new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE", RTTIName: "\\INTERFACE=IF_IXML_NODE"}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "");
    let li_top = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE", RTTIName: "\\INTERFACE=IF_IXML_NODE"});
    abap.statements.append({source: this.me, target: lt_nodes});
    for await (const unique47 of abap.statements.loop(lt_nodes)) {
      li_top.set(unique47);
      li_children.set((await li_top.get().if_ixml_node$get_children()));
      li_iterator.set((await li_children.get().if_ixml_node_list$create_iterator()));
      const indexBackup1 = abap.builtin.sy.get().index.get();
      let unique48 = 1;
      while (true) {
        abap.builtin.sy.get().index.set(unique48++);
        li_node.set((await li_iterator.get().if_ixml_node_iterator$get_next()));
        if (abap.compare.initial(li_node)) {
          break;
        }
        if (abap.compare.eq((await li_node.get().if_ixml_node$get_name()), name)) {
          await abap.statements.cast(val, li_node);
          abap.builtin.sy.get().index.set(indexBackup1);
          return val;
        }
        abap.statements.append({source: li_node, target: lt_nodes});
      }
      abap.builtin.sy.get().index.set(indexBackup1);
    }
    return val;
  }
  async if_ixml_element$find_from_name(INPUT) {
    let val = new abap.types.ABAPObject({qualifiedName: "IF_IXML_ELEMENT", RTTIName: "\\INTERFACE=IF_IXML_ELEMENT"});
    let name = INPUT?.name;
    if (name?.getQualifiedName === undefined || name.getQualifiedName() !== "STRING") { name = undefined; }
    if (name === undefined) { name = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.name); }
    let namespace = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.namespace) {namespace.set(INPUT.namespace);}
    let depth = new abap.types.Integer({qualifiedName: "I"});
    if (INPUT && INPUT.depth) {depth.set(INPUT.depth);}
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return val;
  }
  async if_ixml_element$get_attribute_node(INPUT) {
    let val = new abap.types.ABAPObject({qualifiedName: "IF_IXML_ATTRIBUTE", RTTIName: "\\INTERFACE=IF_IXML_ATTRIBUTE"});
    let name = INPUT?.name;
    if (name?.getQualifiedName === undefined || name.getQualifiedName() !== "STRING") { name = undefined; }
    if (name === undefined) { name = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.name); }
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return val;
  }
  async if_ixml_element$get_attribute_ns(INPUT) {
    let val = new abap.types.String({qualifiedName: "STRING"});
    let name = INPUT?.name;
    if (name?.getQualifiedName === undefined || name.getQualifiedName() !== "STRING") { name = undefined; }
    if (name === undefined) { name = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.name); }
    let uri = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.uri) {uri.set(INPUT.uri);}
    let li_node = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE", RTTIName: "\\INTERFACE=IF_IXML_NODE"});
    li_node.set((await (await this.if_ixml_node$get_attributes()).get().if_ixml_named_node_map$get_named_item_ns({name: name})));
    if (abap.compare.initial(li_node) === false) {
      val.set((await li_node.get().if_ixml_node$get_value()));
    }
    return val;
  }
  async if_ixml_element$get_attribute(INPUT) {
    let val = new abap.types.String({qualifiedName: "STRING"});
    let name = INPUT?.name;
    if (name?.getQualifiedName === undefined || name.getQualifiedName() !== "STRING") { name = undefined; }
    if (name === undefined) { name = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.name); }
    let namespace = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.namespace) {namespace.set(INPUT.namespace);}
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return val;
  }
  async if_ixml_element$get_children() {
    let val = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE_LIST", RTTIName: "\\INTERFACE=IF_IXML_NODE_LIST"});
    val.set((await this.if_ixml_node$get_children()));
    return val;
  }
  async if_ixml_element$get_elements_by_tag_name(INPUT) {
    let val = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE_COLLECTION", RTTIName: "\\INTERFACE=IF_IXML_NODE_COLLECTION"});
    let name = INPUT?.name;
    if (name?.getQualifiedName === undefined || name.getQualifiedName() !== "STRING") { name = undefined; }
    if (name === undefined) { name = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.name); }
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return val;
  }
  async if_ixml_element$get_elements_by_tag_name_ns(INPUT) {
    let val = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE_COLLECTION", RTTIName: "\\INTERFACE=IF_IXML_NODE_COLLECTION"});
    let name = INPUT?.name;
    if (name?.getQualifiedName === undefined || name.getQualifiedName() !== "STRING") { name = undefined; }
    if (name === undefined) { name = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.name); }
    let uri = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.uri) {uri.set(INPUT.uri);}
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return val;
  }
  async if_ixml_element$get_first_child() {
    let val = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE", RTTIName: "\\INTERFACE=IF_IXML_NODE"});
    val.set((await this.if_ixml_node$get_first_child()));
    return val;
  }
  async if_ixml_element$get_value() {
    let val = new abap.types.String({qualifiedName: "STRING"});
    val.set((await this.if_ixml_node$get_value()));
    return val;
  }
  async if_ixml_element$remove_attribute(INPUT) {
    let name = INPUT?.name;
    if (name?.getQualifiedName === undefined || name.getQualifiedName() !== "STRING") { name = undefined; }
    if (name === undefined) { name = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.name); }
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
  }
  async if_ixml_element$remove_node() {
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
  }
  async has_direct_text() {
    let rv_has = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    let li_children = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE_LIST", RTTIName: "\\INTERFACE=IF_IXML_NODE_LIST"});
    let li_child = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE", RTTIName: "\\INTERFACE=IF_IXML_NODE"});
    li_children.set((await this.if_ixml_node$get_children()));
    rv_has.set(abap.builtin.abap_false);
    if (abap.compare.ne((await li_children.get().if_ixml_node_list$get_length()), abap.IntegerFactory.get(1))) {
      return rv_has;
    }
    li_child.set((await li_children.get().if_ixml_node_list$get_item({index: abap.IntegerFactory.get(1)})));
    if (abap.compare.eq((await li_child.get().if_ixml_node$get_name()), new abap.types.Character(5).set('#text'))) {
      rv_has.set(abap.builtin.abap_true);
    }
    return rv_has;
  }
  async if_ixml_element$render(INPUT) {
    let ostream = INPUT?.ostream;
    if (ostream?.getQualifiedName === undefined || ostream.getQualifiedName() !== "IF_IXML_OSTREAM") { ostream = undefined; }
    if (ostream === undefined) { ostream = new abap.types.ABAPObject({qualifiedName: "IF_IXML_OSTREAM", RTTIName: "\\INTERFACE=IF_IXML_OSTREAM"}).set(INPUT.ostream); }
    let li_iterator = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE_ITERATOR", RTTIName: "\\INTERFACE=IF_IXML_NODE_ITERATOR"});
    let li_node = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE", RTTIName: "\\INTERFACE=IF_IXML_NODE"});
    let li_element = new abap.types.ABAPObject({qualifiedName: "IF_IXML_ELEMENT", RTTIName: "\\INTERFACE=IF_IXML_ELEMENT"});
    let li_children = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE_LIST", RTTIName: "\\INTERFACE=IF_IXML_NODE_LIST"});
    let lv_attributes = new abap.types.String({qualifiedName: "STRING"});
    let lv_ns = new abap.types.String({qualifiedName: "STRING"});
    li_iterator.set((await this.mi_attributes.get().if_ixml_named_node_map$create_iterator()));
    const indexBackup1 = abap.builtin.sy.get().index.get();
    let unique49 = 1;
    while (true) {
      abap.builtin.sy.get().index.set(unique49++);
      li_node.set((await li_iterator.get().if_ixml_node_iterator$get_next()));
      if (abap.compare.initial(li_node)) {
        break;
      }
      lv_ns.set((await li_node.get().if_ixml_node$get_namespace_prefix()));
      if (abap.compare.initial(lv_ns) === false) {
        lv_ns.set(abap.operators.concat(lv_ns,new abap.types.Character(1).set(':')));
      }
      lv_attributes.set(abap.operators.concat(lv_attributes,abap.operators.concat(new abap.types.String().set(` `),abap.operators.concat(lv_ns,abap.operators.concat((await li_node.get().if_ixml_node$get_name()),abap.operators.concat(new abap.types.Character(2).set('="'),abap.operators.concat((await li_node.get().if_ixml_node$get_value()),new abap.types.Character(1).set('"'))))))));
    }
    abap.builtin.sy.get().index.set(indexBackup1);
    abap.statements.clear(lv_ns);
    if (abap.compare.initial(this.mv_namespace) === false) {
      lv_ns.set(abap.operators.concat(this.mv_namespace,new abap.types.Character(1).set(':')));
    }
    li_children.set((await this.if_ixml_node$get_children()));
    if (abap.compare.ne(this.mv_name, new abap.types.Character(5).set('#text')) && abap.compare.eq((await ostream.get().if_ixml_ostream$get_pretty_print()), abap.builtin.abap_true)) {
      await ostream.get().if_ixml_ostream$write_string({string: (abap.builtin.repeat({val: new abap.types.String().set(` `), occ: (await ostream.get().if_ixml_ostream$get_indent())}))});
    }
    if (abap.compare.ne(this.mv_name, new abap.types.Character(5).set('#text'))) {
      await ostream.get().if_ixml_ostream$write_string({string: abap.operators.concat(new abap.types.Character(1).set('<'),abap.operators.concat(lv_ns,abap.operators.concat(this.mv_name,lv_attributes)))});
      if (abap.compare.gt((await li_children.get().if_ixml_node_list$get_length()), abap.IntegerFactory.get(0)) || abap.compare.initial(this.mv_value) === false) {
        await ostream.get().if_ixml_ostream$write_string({string: new abap.types.Character(1).set('>')});
      }
    }
    if (abap.compare.eq((await ostream.get().if_ixml_ostream$get_pretty_print()), abap.builtin.abap_true) && abap.compare.eq((await this.if_ixml_node$is_leaf()), abap.builtin.abap_false) && abap.compare.eq((await this.has_direct_text()), abap.builtin.abap_false)) {
      await ostream.get().if_ixml_ostream$write_string({string: new abap.types.String().set(`\n`)});
    }
    await ostream.get().if_ixml_ostream$set_indent({indent: abap.operators.add((await ostream.get().if_ixml_ostream$get_indent()),abap.IntegerFactory.get(1))});
    li_iterator.set((await li_children.get().if_ixml_node_list$create_iterator()));
    const indexBackup2 = abap.builtin.sy.get().index.get();
    let unique50 = 1;
    while (true) {
      abap.builtin.sy.get().index.set(unique50++);
      await abap.statements.cast(li_element, (await li_iterator.get().if_ixml_node_iterator$get_next()));
      if (abap.compare.initial(li_element)) {
        break;
      }
      await li_element.get().if_ixml_element$render({ostream: ostream});
    }
    abap.builtin.sy.get().index.set(indexBackup2);
    await ostream.get().if_ixml_ostream$set_indent({indent: abap.operators.minus((await ostream.get().if_ixml_ostream$get_indent()),abap.IntegerFactory.get(1))});
    if (abap.compare.gt((await li_children.get().if_ixml_node_list$get_length()), abap.IntegerFactory.get(0)) || abap.compare.initial(this.mv_value) === false) {
      await ostream.get().if_ixml_ostream$write_string({string: (await abap.Classes['CLAS-CL_IXML-LCL_ESCAPE'].escape_value({iv_value: this.mv_value}))});
      if (abap.compare.ne(this.mv_name, new abap.types.Character(5).set('#text'))) {
        if (abap.compare.eq((await ostream.get().if_ixml_ostream$get_pretty_print()), abap.builtin.abap_true) && abap.compare.eq((await this.has_direct_text()), abap.builtin.abap_false)) {
          await ostream.get().if_ixml_ostream$write_string({string: (abap.builtin.repeat({val: new abap.types.String().set(` `), occ: (await ostream.get().if_ixml_ostream$get_indent())}))});
        }
        await ostream.get().if_ixml_ostream$write_string({string: abap.operators.concat(new abap.types.Character(2).set('</'),abap.operators.concat(lv_ns,abap.operators.concat(this.mv_name,new abap.types.Character(1).set('>'))))});
      }
    } else {
      await ostream.get().if_ixml_ostream$write_string({string: new abap.types.Character(2).set('/>')});
    }
    if (abap.compare.eq((await ostream.get().if_ixml_ostream$get_pretty_print()), abap.builtin.abap_true) && abap.compare.ne(this.mv_name, new abap.types.Character(5).set('#text'))) {
      await ostream.get().if_ixml_ostream$write_string({string: new abap.types.String().set(`\n`)});
    }
  }
  async if_ixml_element$set_attribute_node_ns(INPUT) {
    let attr = INPUT?.attr;
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
  }
  async if_ixml_element$set_attribute(INPUT) {
    let rval = new abap.types.Integer({qualifiedName: "I"});
    let name = INPUT?.name;
    if (name?.getQualifiedName === undefined || name.getQualifiedName() !== "STRING") { name = undefined; }
    if (name === undefined) { name = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.name); }
    let namespace = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.namespace) {namespace.set(INPUT.namespace);}
    let value = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.value) {value.set(INPUT.value);}
    await this.if_ixml_element$set_attribute_ns({name: name, value: value});
    return rval;
  }
  async if_ixml_element$set_attribute_ns(INPUT) {
    let name = INPUT?.name;
    if (name?.getQualifiedName === undefined || name.getQualifiedName() !== "STRING") { name = undefined; }
    if (name === undefined) { name = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.name); }
    let prefix = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.prefix) {prefix.set(INPUT.prefix);}
    let value = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.value) {value.set(INPUT.value);}
    let lo_node = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE", RTTIName: "\\INTERFACE=IF_IXML_NODE"});
    lo_node.set(await (new abap.Classes['CLAS-CL_IXML-LCL_NODE']()).constructor_());
    await lo_node.get().if_ixml_node$set_name({name: name});
    await lo_node.get().if_ixml_node$set_value({value: value});
    await lo_node.get().if_ixml_node$set_namespace_prefix({val: prefix});
    await this.mi_attributes.get().if_ixml_named_node_map$set_named_item_ns({node: lo_node});
  }
  async if_ixml_element$set_value(INPUT) {
    let rc = new abap.types.Integer({qualifiedName: "I"});
    let value = INPUT?.value;
    if (value?.getQualifiedName === undefined || value.getQualifiedName() !== "STRING") { value = undefined; }
    if (value === undefined) { value = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.value); }
    await this.if_ixml_node$set_value({value: value});
    return rc;
  }
  async if_ixml_node$set_namespace_prefix(INPUT) {
    let val = INPUT?.val;
    if (val?.getQualifiedName === undefined || val.getQualifiedName() !== "STRING") { val = undefined; }
    if (val === undefined) { val = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.val); }
    this.mv_namespace.set(val);
  }
  async if_ixml_node$append_child(INPUT) {
    let new_child = INPUT?.new_child;
    if (new_child?.getQualifiedName === undefined || new_child.getQualifiedName() !== "IF_IXML_NODE") { new_child = undefined; }
    if (new_child === undefined) { new_child = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE", RTTIName: "\\INTERFACE=IF_IXML_NODE"}).set(INPUT.new_child); }
    let lo_node = new abap.types.ABAPObject({qualifiedName: "LCL_NODE", RTTIName: "\\CLASS-POOL=CL_IXML\\CLASS=LCL_NODE"});
    await abap.statements.cast(lo_node, new_child);
    lo_node.get().mi_parent.set(this.me);
    await this.mo_children.get().append({ii_node: new_child});
  }
  async if_ixml_node$get_attributes() {
    let map = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NAMED_NODE_MAP", RTTIName: "\\INTERFACE=IF_IXML_NAMED_NODE_MAP"});
    map.set(this.mi_attributes);
    return map;
  }
  async if_ixml_node$get_first_child() {
    let node = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE", RTTIName: "\\INTERFACE=IF_IXML_NODE"});
    node.set((await this.mo_children.get().if_ixml_node_list$get_item({index: abap.IntegerFactory.get(1)})));
    return node;
  }
  async if_ixml_node$get_children() {
    let val = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE_LIST", RTTIName: "\\INTERFACE=IF_IXML_NODE_LIST"});
    val.set(this.mo_children);
    return val;
  }
  async if_ixml_node$query_interface(INPUT) {
    let rval = new abap.types.ABAPObject({qualifiedName: "IF_IXML_UNKNOWN", RTTIName: "\\INTERFACE=IF_IXML_UNKNOWN"});
    let iid = INPUT?.iid;
    if (iid?.getQualifiedName === undefined || iid.getQualifiedName() !== "I") { iid = undefined; }
    if (iid === undefined) { iid = new abap.types.Integer({qualifiedName: "I"}).set(INPUT.iid); }
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return rval;
  }
  async if_ixml_node$remove_node() {
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
  }
  async if_ixml_node$get_parent() {
    let val = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE", RTTIName: "\\INTERFACE=IF_IXML_NODE"});
    val.set(this.mi_parent);
    return val;
  }
  async if_ixml_node$replace_child(INPUT) {
    let new_child = INPUT?.new_child;
    if (new_child?.getQualifiedName === undefined || new_child.getQualifiedName() !== "STRING") { new_child = undefined; }
    if (new_child === undefined) { new_child = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.new_child); }
    let old_child = INPUT?.old_child;
    if (old_child?.getQualifiedName === undefined || old_child.getQualifiedName() !== "STRING") { old_child = undefined; }
    if (old_child === undefined) { old_child = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.old_child); }
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
  }
  async if_ixml_node$get_name() {
    let val = new abap.types.String({qualifiedName: "STRING"});
    val.set(this.mv_name);
    return val;
  }
  async if_ixml_node$get_depth() {
    let val = new abap.types.Integer({qualifiedName: "I"});
    let li_iterator = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE_ITERATOR", RTTIName: "\\INTERFACE=IF_IXML_NODE_ITERATOR"});
    let li_node = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE", RTTIName: "\\INTERFACE=IF_IXML_NODE"});
    let lv_max = new abap.types.Integer({qualifiedName: "I"});
    if (abap.compare.eq((await this.mo_children.get().if_ixml_node_list$get_length()), abap.IntegerFactory.get(0))) {
      val.set(abap.IntegerFactory.get(0));
    } else {
      li_iterator.set((await this.mo_children.get().if_ixml_node_list$create_iterator()));
      const indexBackup1 = abap.builtin.sy.get().index.get();
      let unique51 = 1;
      while (true) {
        abap.builtin.sy.get().index.set(unique51++);
        li_node.set((await li_iterator.get().if_ixml_node_iterator$get_next()));
        if (abap.compare.initial(li_node)) {
          break;
        }
        if (abap.compare.gt((await li_node.get().if_ixml_node$get_depth()), lv_max)) {
          lv_max.set((await li_node.get().if_ixml_node$get_depth()));
        }
      }
      abap.builtin.sy.get().index.set(indexBackup1);
      val.set(abap.operators.add(lv_max,abap.IntegerFactory.get(1)));
    }
    return val;
  }
  async if_ixml_node$is_leaf() {
    let val = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    val.set(abap.builtin.boolc(abap.compare.eq((await this.mo_children.get().if_ixml_node_list$get_length()), abap.IntegerFactory.get(0))));
    return val;
  }
  async if_ixml_node$get_namespace() {
    let val = new abap.types.String({qualifiedName: "STRING"});
    val.set(this.mv_namespace);
    return val;
  }
  async if_ixml_node$get_value() {
    let val = new abap.types.String({qualifiedName: "STRING"});
    let li_iterator = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE_ITERATOR", RTTIName: "\\INTERFACE=IF_IXML_NODE_ITERATOR"});
    let li_node = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE", RTTIName: "\\INTERFACE=IF_IXML_NODE"});
    let lv_max = new abap.types.Integer({qualifiedName: "I"});
    if (abap.compare.eq((await this.mo_children.get().if_ixml_node_list$get_length()), abap.IntegerFactory.get(0))) {
      val.set(this.mv_value);
    } else {
      li_iterator.set((await this.mo_children.get().if_ixml_node_list$create_iterator()));
      const indexBackup1 = abap.builtin.sy.get().index.get();
      let unique52 = 1;
      while (true) {
        abap.builtin.sy.get().index.set(unique52++);
        li_node.set((await li_iterator.get().if_ixml_node_iterator$get_next()));
        if (abap.compare.initial(li_node)) {
          break;
        }
        val.set(abap.operators.concat(val,(await li_node.get().if_ixml_node$get_value())));
      }
      abap.builtin.sy.get().index.set(indexBackup1);
    }
    return val;
  }
  async if_ixml_node$get_type() {
    let val = new abap.types.String({qualifiedName: "STRING"});
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return val;
  }
  async if_ixml_node$set_name(INPUT) {
    let name = INPUT?.name;
    if (name?.getQualifiedName === undefined || name.getQualifiedName() !== "STRING") { name = undefined; }
    if (name === undefined) { name = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.name); }
    this.mv_name.set(name);
  }
  async if_ixml_node$remove_child(INPUT) {
    let child = INPUT?.child;
    if (child?.getQualifiedName === undefined || child.getQualifiedName() !== "IF_IXML_NODE") { child = undefined; }
    if (child === undefined) { child = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE", RTTIName: "\\INTERFACE=IF_IXML_NODE"}).set(INPUT.child); }
    await this.mo_children.get().remove({ii_node: child});
  }
  async if_ixml_node$set_value(INPUT) {
    let value = INPUT?.value;
    if (value?.getQualifiedName === undefined || value.getQualifiedName() !== "STRING") { value = undefined; }
    if (value === undefined) { value = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.value); }
    this.mv_value.set(value);
  }
}
abap.Classes['CLAS-CL_IXML-LCL_NODE'] = lcl_node;
lcl_node.if_ixml_node$co_node_document = new abap.types.Integer({qualifiedName: "I"});
lcl_node.if_ixml_node$co_node_document.set(1);
lcl_node.if_ixml_node$co_node_element = new abap.types.Integer({qualifiedName: "I"});
lcl_node.if_ixml_node$co_node_element.set(4);
lcl_node.if_ixml_node$co_node_text = new abap.types.Integer({qualifiedName: "I"});
lcl_node.if_ixml_node$co_node_text.set(16);
lcl_node.if_ixml_node$co_node_cdata_section = new abap.types.Integer({qualifiedName: "I"});
lcl_node.if_ixml_node$co_node_cdata_section.set(32);
class lcl_document {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CLAS-CL_IXML-LCL_DOCUMENT';
  static IMPLEMENTED_INTERFACES = ["IF_IXML_DOCUMENT","IF_IXML_NODE"];
  static ATTRIBUTES = {"MI_NODE": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "LCL_NODE", RTTIName: "\\CLASS-POOL=CL_IXML\\CLASS=LCL_NODE"});}, "visibility": "I", "is_constant": " ", "is_class": " "},
  "MV_STANDALONE": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});}, "visibility": "I", "is_constant": " ", "is_class": " "},
  "IF_IXML_NODE~CO_NODE_DOCUMENT": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "IF_IXML_NODE~CO_NODE_ELEMENT": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "IF_IXML_NODE~CO_NODE_TEXT": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "IF_IXML_NODE~CO_NODE_CDATA_SECTION": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": "X", "is_class": "X"}};
  static METHODS = {"CONSTRUCTOR": {"visibility": "U", "parameters": {}}};
  constructor() {
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
    this.mi_node = new abap.types.ABAPObject({qualifiedName: "LCL_NODE", RTTIName: "\\CLASS-POOL=CL_IXML\\CLASS=LCL_NODE"});
    this.mv_standalone = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    this.if_ixml_node$co_node_document = abap.Classes['IF_IXML_NODE'].if_ixml_node$co_node_document;
    this.if_ixml_node$co_node_element = abap.Classes['IF_IXML_NODE'].if_ixml_node$co_node_element;
    this.if_ixml_node$co_node_text = abap.Classes['IF_IXML_NODE'].if_ixml_node$co_node_text;
    this.if_ixml_node$co_node_cdata_section = abap.Classes['IF_IXML_NODE'].if_ixml_node$co_node_cdata_section;
    this.if_ixml_document$create_filter_name_ns = this.if_ixml_node$create_filter_name_ns;
  }
  async constructor_(INPUT) {
    this.mi_node.set(await (new abap.Classes['CLAS-CL_IXML-LCL_NODE']()).constructor_());
    await this.mi_node.get().if_ixml_node$set_name({name: new abap.types.Character(9).set('#document')});
    return this;
  }
  async if_ixml_node$get_height() {
    let rval = new abap.types.Integer({qualifiedName: "I"});
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return rval;
  }
  async if_ixml_node$get_gid() {
    let rval = new abap.types.Integer({qualifiedName: "I"});
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return rval;
  }
  async if_ixml_node$insert_child(INPUT) {
    let rval = new abap.types.Integer({qualifiedName: "I"});
    let new_child = INPUT?.new_child;
    if (new_child?.getQualifiedName === undefined || new_child.getQualifiedName() !== "IF_IXML_NODE") { new_child = undefined; }
    if (new_child === undefined) { new_child = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE", RTTIName: "\\INTERFACE=IF_IXML_NODE"}).set(INPUT.new_child); }
    let ref_child = INPUT?.ref_child;
    if (ref_child?.getQualifiedName === undefined || ref_child.getQualifiedName() !== "IF_IXML_NODE") { ref_child = undefined; }
    if (ref_child === undefined) { ref_child = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE", RTTIName: "\\INTERFACE=IF_IXML_NODE"}).set(INPUT.ref_child); }
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return rval;
  }
  async if_ixml_node$clone() {
    let rval = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE", RTTIName: "\\INTERFACE=IF_IXML_NODE"});
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return rval;
  }
  async if_ixml_node$create_iterator_filtered(INPUT) {
    let rval = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE_ITERATOR", RTTIName: "\\INTERFACE=IF_IXML_NODE_ITERATOR"});
    let filter = INPUT?.filter;
    if (filter?.getQualifiedName === undefined || filter.getQualifiedName() !== "IF_IXML_NODE_FILTER") { filter = undefined; }
    if (filter === undefined) { filter = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE_FILTER", RTTIName: "\\INTERFACE=IF_IXML_NODE_FILTER"}).set(INPUT.filter); }
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return rval;
  }
  async if_ixml_node$get_column() {
    let rval = new abap.types.Integer({qualifiedName: "I"});
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return rval;
  }
  async if_ixml_node$create_filter_name_ns(INPUT) {
    let rval = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE_FILTER", RTTIName: "\\INTERFACE=IF_IXML_NODE_FILTER"});
    let name = INPUT?.name;
    if (name?.getQualifiedName === undefined || name.getQualifiedName() !== "STRING") { name = undefined; }
    if (name === undefined) { name = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.name); }
    let namespace = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.namespace) {namespace.set(INPUT.namespace);}
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return rval;
  }
  async if_ixml_node$get_namespace_prefix() {
    let rv_prefix = new abap.types.String({qualifiedName: "STRING"});
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return rv_prefix;
  }
  async if_ixml_node$get_next() {
    let rval = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE", RTTIName: "\\INTERFACE=IF_IXML_NODE"});
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return rval;
  }
  async if_ixml_node$get_namespace_uri() {
    let rval = new abap.types.String({qualifiedName: "STRING"});
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return rval;
  }
  async if_ixml_node$append_child(INPUT) {
    let new_child = INPUT?.new_child;
    if (new_child?.getQualifiedName === undefined || new_child.getQualifiedName() !== "IF_IXML_NODE") { new_child = undefined; }
    if (new_child === undefined) { new_child = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE", RTTIName: "\\INTERFACE=IF_IXML_NODE"}).set(INPUT.new_child); }
    let lo_node = new abap.types.ABAPObject({qualifiedName: "LCL_NODE", RTTIName: "\\CLASS-POOL=CL_IXML\\CLASS=LCL_NODE"});
    await abap.statements.cast(lo_node, new_child);
    lo_node.get().mi_parent.set(this.me);
    await this.mi_node.get().if_ixml_node$append_child({new_child: new_child});
  }
  async if_ixml_node$set_namespace_prefix(INPUT) {
    let val = INPUT?.val;
    if (val?.getQualifiedName === undefined || val.getQualifiedName() !== "STRING") { val = undefined; }
    if (val === undefined) { val = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.val); }
    await this.mi_node.get().if_ixml_node$set_namespace_prefix({val: val});
  }
  async if_ixml_node$get_attributes() {
    let map = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NAMED_NODE_MAP", RTTIName: "\\INTERFACE=IF_IXML_NAMED_NODE_MAP"});
    map.set((await this.mi_node.get().if_ixml_node$get_attributes()));
    return map;
  }
  async if_ixml_node$get_first_child() {
    let node = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE", RTTIName: "\\INTERFACE=IF_IXML_NODE"});
    node.set((await this.mi_node.get().if_ixml_node$get_first_child()));
    return node;
  }
  async if_ixml_node$get_children() {
    let val = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE_LIST", RTTIName: "\\INTERFACE=IF_IXML_NODE_LIST"});
    val.set((await this.mi_node.get().if_ixml_node$get_children()));
    return val;
  }
  async if_ixml_node$query_interface(INPUT) {
    let rval = new abap.types.ABAPObject({qualifiedName: "IF_IXML_UNKNOWN", RTTIName: "\\INTERFACE=IF_IXML_UNKNOWN"});
    let iid = INPUT?.iid;
    if (iid?.getQualifiedName === undefined || iid.getQualifiedName() !== "I") { iid = undefined; }
    if (iid === undefined) { iid = new abap.types.Integer({qualifiedName: "I"}).set(INPUT.iid); }
    await this.mi_node.get().if_ixml_node$query_interface({iid: iid});
    return rval;
  }
  async if_ixml_node$remove_node() {
    await this.mi_node.get().if_ixml_node$remove_node();
  }
  async if_ixml_node$get_parent() {
    let val = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE", RTTIName: "\\INTERFACE=IF_IXML_NODE"});
    val.set((await this.mi_node.get().if_ixml_node$get_parent()));
    return val;
  }
  async if_ixml_node$replace_child(INPUT) {
    let new_child = INPUT?.new_child;
    if (new_child?.getQualifiedName === undefined || new_child.getQualifiedName() !== "STRING") { new_child = undefined; }
    if (new_child === undefined) { new_child = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.new_child); }
    let old_child = INPUT?.old_child;
    if (old_child?.getQualifiedName === undefined || old_child.getQualifiedName() !== "STRING") { old_child = undefined; }
    if (old_child === undefined) { old_child = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.old_child); }
    await this.mi_node.get().if_ixml_node$replace_child({new_child: new_child, old_child: old_child});
  }
  async if_ixml_node$get_name() {
    let val = new abap.types.String({qualifiedName: "STRING"});
    val.set((await this.mi_node.get().if_ixml_node$get_name()));
    return val;
  }
  async if_ixml_node$get_depth() {
    let val = new abap.types.Integer({qualifiedName: "I"});
    val.set((await this.mi_node.get().if_ixml_node$get_depth()));
    return val;
  }
  async if_ixml_node$is_leaf() {
    let val = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    val.set((await this.mi_node.get().if_ixml_node$is_leaf()));
    return val;
  }
  async if_ixml_node$get_namespace() {
    let val = new abap.types.String({qualifiedName: "STRING"});
    val.set((await this.mi_node.get().if_ixml_node$get_namespace()));
    return val;
  }
  async if_ixml_node$get_value() {
    let val = new abap.types.String({qualifiedName: "STRING"});
    val.set((await this.mi_node.get().if_ixml_node$get_value()));
    return val;
  }
  async if_ixml_node$get_type() {
    let val = new abap.types.String({qualifiedName: "STRING"});
    val.set((await this.mi_node.get().if_ixml_node$get_type()));
    return val;
  }
  async if_ixml_node$set_name(INPUT) {
    let name = INPUT?.name;
    if (name?.getQualifiedName === undefined || name.getQualifiedName() !== "STRING") { name = undefined; }
    if (name === undefined) { name = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.name); }
    await this.mi_node.get().if_ixml_node$set_name({name: name});
  }
  async if_ixml_node$remove_child(INPUT) {
    let child = INPUT?.child;
    if (child?.getQualifiedName === undefined || child.getQualifiedName() !== "IF_IXML_NODE") { child = undefined; }
    if (child === undefined) { child = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE", RTTIName: "\\INTERFACE=IF_IXML_NODE"}).set(INPUT.child); }
    await this.mi_node.get().if_ixml_node$remove_child({child: child});
  }
  async if_ixml_node$set_value(INPUT) {
    let value = INPUT?.value;
    if (value?.getQualifiedName === undefined || value.getQualifiedName() !== "STRING") { value = undefined; }
    if (value === undefined) { value = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.value); }
    await this.mi_node.get().if_ixml_node$set_value({value: value});
  }
  async if_ixml_document$set_encoding(INPUT) {
    let encoding = INPUT?.encoding;
    if (encoding === undefined) { encoding = new abap.types.ABAPObject({qualifiedName: undefined, RTTIName: undefined}).set(INPUT.encoding); }
    return;
  }
  async if_ixml_document$set_standalone(INPUT) {
    let standalone = INPUT?.standalone;
    if (standalone?.getQualifiedName === undefined || standalone.getQualifiedName() !== "ABAP_BOOL") { standalone = undefined; }
    if (standalone === undefined) { standalone = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}).set(INPUT.standalone); }
    this.mv_standalone.set(standalone);
  }
  async if_ixml_document$get_standalone() {
    let rval = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    rval.set(this.mv_standalone);
    return rval;
  }
  async if_ixml_document$set_namespace_prefix(INPUT) {
    let prefix = INPUT?.prefix;
    if (prefix?.getQualifiedName === undefined || prefix.getQualifiedName() !== "STRING") { prefix = undefined; }
    if (prefix === undefined) { prefix = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.prefix); }
    return;
  }
  async if_ixml_document$append_child(INPUT) {
    let new_child = INPUT?.new_child;
    if (new_child?.getQualifiedName === undefined || new_child.getQualifiedName() !== "IF_IXML_NODE") { new_child = undefined; }
    if (new_child === undefined) { new_child = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE", RTTIName: "\\INTERFACE=IF_IXML_NODE"}).set(INPUT.new_child); }
    await this.if_ixml_node$append_child({new_child: new_child});
  }
  async if_ixml_document$get_first_child() {
    let child = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE", RTTIName: "\\INTERFACE=IF_IXML_NODE"});
    child.set((await this.mi_node.get().if_ixml_node$get_first_child()));
    return child;
  }
  async if_ixml_document$create_attribute_ns(INPUT) {
    let element = new abap.types.ABAPObject({qualifiedName: "IF_IXML_ATTRIBUTE", RTTIName: "\\INTERFACE=IF_IXML_ATTRIBUTE"});
    let name = INPUT?.name;
    if (name?.getQualifiedName === undefined || name.getQualifiedName() !== "STRING") { name = undefined; }
    if (name === undefined) { name = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.name); }
    let prefix = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.prefix) {prefix.set(INPUT.prefix);}
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return element;
  }
  async if_ixml_document$create_element_ns(INPUT) {
    let element = new abap.types.ABAPObject({qualifiedName: "IF_IXML_ELEMENT", RTTIName: "\\INTERFACE=IF_IXML_ELEMENT"});
    let name = INPUT?.name;
    if (name?.getQualifiedName === undefined || name.getQualifiedName() !== "STRING") { name = undefined; }
    if (name === undefined) { name = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.name); }
    let prefix = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.prefix) {prefix.set(INPUT.prefix);}
    let uri = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.uri) {uri.set(INPUT.uri);}
    element.set(await (new abap.Classes['CLAS-CL_IXML-LCL_NODE']()).constructor_());
    await element.get().if_ixml_node$set_name({name: name});
    await element.get().if_ixml_node$set_namespace_prefix({val: prefix});
    return element;
  }
  async if_ixml_document$create_element(INPUT) {
    let element = new abap.types.ABAPObject({qualifiedName: "IF_IXML_ELEMENT", RTTIName: "\\INTERFACE=IF_IXML_ELEMENT"});
    let name = INPUT?.name;
    if (name?.getQualifiedName === undefined || name.getQualifiedName() !== "STRING") { name = undefined; }
    if (name === undefined) { name = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.name); }
    element.set(await (new abap.Classes['CLAS-CL_IXML-LCL_NODE']()).constructor_());
    await element.get().if_ixml_node$set_name({name: name});
    return element;
  }
  async if_ixml_document$create_iterator_filtered(INPUT) {
    let val = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE_ITERATOR", RTTIName: "\\INTERFACE=IF_IXML_NODE_ITERATOR"});
    let filter = INPUT?.filter;
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return val;
  }
  async if_ixml_document$set_declaration(INPUT) {
    let declaration = INPUT?.declaration;
    if (declaration?.getQualifiedName === undefined || declaration.getQualifiedName() !== "ABAP_BOOL") { declaration = undefined; }
    if (declaration === undefined) { declaration = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}).set(INPUT.declaration); }
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
  }
  async if_ixml_document$create_filter_and(INPUT) {
    let val = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE_FILTER", RTTIName: "\\INTERFACE=IF_IXML_NODE_FILTER"});
    let filter1 = INPUT?.filter1;
    let filter2 = INPUT?.filter2;
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return val;
  }
  async if_ixml_document$create_iterator() {
    let rval = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE_ITERATOR", RTTIName: "\\INTERFACE=IF_IXML_NODE_ITERATOR"});
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return rval;
  }
  async if_ixml_document$create_filter_node_type(INPUT) {
    let val = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE_FILTER", RTTIName: "\\INTERFACE=IF_IXML_NODE_FILTER"});
    let node_types = INPUT?.node_types;
    if (node_types?.getQualifiedName === undefined || node_types.getQualifiedName() !== "I") { node_types = undefined; }
    if (node_types === undefined) { node_types = new abap.types.Integer({qualifiedName: "I"}).set(INPUT.node_types); }
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return val;
  }
  async if_ixml_document$create_simple_element_ns(INPUT) {
    let val = new abap.types.ABAPObject({qualifiedName: "IF_IXML_ELEMENT", RTTIName: "\\INTERFACE=IF_IXML_ELEMENT"});
    let name = INPUT?.name;
    if (name?.getQualifiedName === undefined || name.getQualifiedName() !== "STRING") { name = undefined; }
    if (name === undefined) { name = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.name); }
    let parent = INPUT?.parent;
    if (parent?.getQualifiedName === undefined || parent.getQualifiedName() !== "IF_IXML_NODE") { parent = undefined; }
    if (parent === undefined) { parent = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE", RTTIName: "\\INTERFACE=IF_IXML_NODE"}).set(INPUT.parent); }
    let prefix = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.prefix) {prefix.set(INPUT.prefix);}
    let li_node = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE", RTTIName: "\\INTERFACE=IF_IXML_NODE"});
    val.set((await this.if_ixml_document$create_simple_element({name: name, parent: parent})));
    await abap.statements.cast(li_node, val);
    await li_node.get().if_ixml_node$set_namespace_prefix({val: prefix});
    return val;
  }
  async if_ixml_document$create_filter_attribute(INPUT) {
    let val = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE_FILTER", RTTIName: "\\INTERFACE=IF_IXML_NODE_FILTER"});
    let name = INPUT?.name;
    if (name?.getQualifiedName === undefined || name.getQualifiedName() !== "STRING") { name = undefined; }
    if (name === undefined) { name = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.name); }
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return val;
  }
  async if_ixml_document$create_simple_element(INPUT) {
    let val = new abap.types.ABAPObject({qualifiedName: "IF_IXML_ELEMENT", RTTIName: "\\INTERFACE=IF_IXML_ELEMENT"});
    let name = INPUT?.name;
    if (name?.getQualifiedName === undefined || name.getQualifiedName() !== "STRING") { name = undefined; }
    if (name === undefined) { name = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.name); }
    let parent = INPUT?.parent;
    if (parent?.getQualifiedName === undefined || parent.getQualifiedName() !== "IF_IXML_NODE") { parent = undefined; }
    if (parent === undefined) { parent = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE", RTTIName: "\\INTERFACE=IF_IXML_NODE"}).set(INPUT.parent); }
    let value = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.value) {value.set(INPUT.value);}
    val.set(await (new abap.Classes['CLAS-CL_IXML-LCL_NODE']()).constructor_({ii_parent: parent}));
    await val.get().if_ixml_node$set_name({name: name});
    await val.get().if_ixml_node$set_value({value: value});
    return val;
  }
  async if_ixml_document$find_from_name(INPUT) {
    let element = new abap.types.ABAPObject({qualifiedName: "IF_IXML_ELEMENT", RTTIName: "\\INTERFACE=IF_IXML_ELEMENT"});
    let name = INPUT?.name;
    if (name?.getQualifiedName === undefined || name.getQualifiedName() !== "STRING") { name = undefined; }
    if (name === undefined) { name = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.name); }
    let depth = new abap.types.Integer({qualifiedName: "I"});
    if (INPUT && INPUT.depth) {depth.set(INPUT.depth);}
    let namespace = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.namespace) {namespace.set(INPUT.namespace);}
    element.set((await this.mi_node.get().if_ixml_element$find_from_name_ns({name: name, depth: depth, namespace: namespace})));
    return element;
  }
  async if_ixml_document$find_from_name_ns(INPUT) {
    let element = new abap.types.ABAPObject({qualifiedName: "IF_IXML_ELEMENT", RTTIName: "\\INTERFACE=IF_IXML_ELEMENT"});
    let depth = new abap.types.Integer({qualifiedName: "I"});
    if (INPUT && INPUT.depth) {depth.set(INPUT.depth);}
    let uri = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.uri) {uri.set(INPUT.uri);}
    let name = INPUT?.name;
    if (name?.getQualifiedName === undefined || name.getQualifiedName() !== "STRING") { name = undefined; }
    if (name === undefined) { name = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.name); }
    element.set((await this.mi_node.get().if_ixml_element$find_from_name_ns({name: name, depth: depth, namespace: new abap.types.Character(1).set('')})));
    return element;
  }
  async if_ixml_document$find_from_path(INPUT) {
    let val = new abap.types.ABAPObject({qualifiedName: "IF_IXML_ELEMENT", RTTIName: "\\INTERFACE=IF_IXML_ELEMENT"});
    let path = INPUT?.path;
    if (path?.getQualifiedName === undefined || path.getQualifiedName() !== "STRING") { path = undefined; }
    if (path === undefined) { path = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.path); }
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return val;
  }
  async if_ixml_document$get_elements_by_tag_name_ns(INPUT) {
    let val = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE_COLLECTION", RTTIName: "\\INTERFACE=IF_IXML_NODE_COLLECTION"});
    let name = INPUT?.name;
    if (name?.getQualifiedName === undefined || name.getQualifiedName() !== "STRING") { name = undefined; }
    if (name === undefined) { name = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.name); }
    let namespace = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.namespace) {namespace.set(INPUT.namespace);}
    let uri = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.uri) {uri.set(INPUT.uri);}
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return val;
  }
  async if_ixml_document$get_elements_by_tag_name(INPUT) {
    let val = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE_COLLECTION", RTTIName: "\\INTERFACE=IF_IXML_NODE_COLLECTION"});
    let depth = new abap.types.Integer({qualifiedName: "I"});
    if (INPUT && INPUT.depth) {depth.set(INPUT.depth);}
    let name = INPUT?.name;
    if (name?.getQualifiedName === undefined || name.getQualifiedName() !== "STRING") { name = undefined; }
    if (name === undefined) { name = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.name); }
    let namespace = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.namespace) {namespace.set(INPUT.namespace);}
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return val;
  }
  async if_ixml_document$get_root() {
    let node = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE", RTTIName: "\\INTERFACE=IF_IXML_NODE"});
    node.set(this.mi_node);
    return node;
  }
  async if_ixml_document$get_root_element() {
    let root = new abap.types.ABAPObject({qualifiedName: "IF_IXML_ELEMENT", RTTIName: "\\INTERFACE=IF_IXML_ELEMENT"});
    await abap.statements.cast(root, (await this.mi_node.get().if_ixml_element$get_first_child()));
    return root;
  }
}
abap.Classes['CLAS-CL_IXML-LCL_DOCUMENT'] = lcl_document;
lcl_document.if_ixml_node$co_node_document = new abap.types.Integer({qualifiedName: "I"});
lcl_document.if_ixml_node$co_node_document.set(1);
lcl_document.if_ixml_node$co_node_element = new abap.types.Integer({qualifiedName: "I"});
lcl_document.if_ixml_node$co_node_element.set(4);
lcl_document.if_ixml_node$co_node_text = new abap.types.Integer({qualifiedName: "I"});
lcl_document.if_ixml_node$co_node_text.set(16);
lcl_document.if_ixml_node$co_node_cdata_section = new abap.types.Integer({qualifiedName: "I"});
lcl_document.if_ixml_node$co_node_cdata_section.set(32);
class lcl_renderer {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CLAS-CL_IXML-LCL_RENDERER';
  static IMPLEMENTED_INTERFACES = ["IF_IXML_RENDERER"];
  static ATTRIBUTES = {"MI_OSTREAM": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_IXML_OSTREAM", RTTIName: "\\INTERFACE=IF_IXML_OSTREAM"});}, "visibility": "I", "is_constant": " ", "is_class": " "},
  "MI_DOCUMENT": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_IXML_DOCUMENT", RTTIName: "\\INTERFACE=IF_IXML_DOCUMENT"});}, "visibility": "I", "is_constant": " ", "is_class": " "}};
  static METHODS = {"CONSTRUCTOR": {"visibility": "U", "parameters": {"OSTREAM": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_IXML_OSTREAM", RTTIName: "\\INTERFACE=IF_IXML_OSTREAM"});}, "is_optional": " "}, "DOCUMENT": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_IXML_DOCUMENT", RTTIName: "\\INTERFACE=IF_IXML_DOCUMENT"});}, "is_optional": " "}}}};
  constructor() {
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
    this.mi_ostream = new abap.types.ABAPObject({qualifiedName: "IF_IXML_OSTREAM", RTTIName: "\\INTERFACE=IF_IXML_OSTREAM"});
    this.mi_document = new abap.types.ABAPObject({qualifiedName: "IF_IXML_DOCUMENT", RTTIName: "\\INTERFACE=IF_IXML_DOCUMENT"});
  }
  async constructor_(INPUT) {
    let ostream = INPUT?.ostream;
    if (ostream?.getQualifiedName === undefined || ostream.getQualifiedName() !== "IF_IXML_OSTREAM") { ostream = undefined; }
    if (ostream === undefined) { ostream = new abap.types.ABAPObject({qualifiedName: "IF_IXML_OSTREAM", RTTIName: "\\INTERFACE=IF_IXML_OSTREAM"}).set(INPUT.ostream); }
    let document = INPUT?.document;
    if (document?.getQualifiedName === undefined || document.getQualifiedName() !== "IF_IXML_DOCUMENT") { document = undefined; }
    if (document === undefined) { document = new abap.types.ABAPObject({qualifiedName: "IF_IXML_DOCUMENT", RTTIName: "\\INTERFACE=IF_IXML_DOCUMENT"}).set(INPUT.document); }
    this.mi_ostream.set(ostream);
    this.mi_document.set(document);
    return this;
  }
  async if_ixml_renderer$render() {
    let rval = new abap.types.Integer({qualifiedName: "I"});
    let li_root = new abap.types.ABAPObject({qualifiedName: "IF_IXML_ELEMENT", RTTIName: "\\INTERFACE=IF_IXML_ELEMENT"});
    let lv_standalone = new abap.types.String({qualifiedName: "STRING"});
    let lo_stream = new abap.types.ABAPObject({qualifiedName: "LCL_OSTREAM", RTTIName: "\\CLASS-POOL=CL_IXML\\CLASS=LCL_OSTREAM"});
    if (abap.compare.eq((await this.mi_document.get().if_ixml_document$get_standalone()), abap.builtin.abap_true)) {
      lv_standalone.set(new abap.types.String().set(` standalone="yes"`));
    }
    await abap.statements.cast(lo_stream, this.mi_ostream);
    if (abap.compare.eq(lo_stream.get().mv_hex, abap.builtin.abap_true)) {
      await this.mi_ostream.get().if_ixml_ostream$write_string({string: new abap.types.String().set(`<?xml version="1.0" encoding="utf-8"${abap.templateFormatting(lv_standalone)}?>`)});
    } else {
      await this.mi_ostream.get().if_ixml_ostream$write_string({string: new abap.types.String().set(`<?xml version="1.0" encoding="utf-16"${abap.templateFormatting(lv_standalone)}?>`)});
    }
    if (abap.compare.eq(lo_stream.get().mv_pretty_print, abap.builtin.abap_true)) {
      await this.mi_ostream.get().if_ixml_ostream$write_string({string: new abap.types.String().set(`\n`)});
    }
    li_root.set((await this.mi_document.get().if_ixml_document$get_root_element()));
    if (abap.compare.initial(li_root)) {
      return rval;
    }
    await li_root.get().if_ixml_element$render({ostream: this.mi_ostream});
    return rval;
  }
  async if_ixml_renderer$set_normalizing(INPUT) {
    let normal = INPUT?.normal;
    if (normal?.getQualifiedName === undefined || normal.getQualifiedName() !== "ABAP_BOOL") { normal = undefined; }
    if (normal === undefined) { normal = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}).set(INPUT.normal); }
    await this.mi_ostream.get().if_ixml_ostream$set_pretty_print({pretty_print: normal});
  }
}
abap.Classes['CLAS-CL_IXML-LCL_RENDERER'] = lcl_renderer;
class lcl_ostream {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CLAS-CL_IXML-LCL_OSTREAM';
  static IMPLEMENTED_INTERFACES = ["IF_IXML_OSTREAM"];
  static ATTRIBUTES = {"MV_STRING": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "visibility": "U", "is_constant": " ", "is_class": " "},
  "MV_HEX": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});}, "visibility": "U", "is_constant": " ", "is_class": " "},
  "MV_PRETTY_PRINT": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});}, "visibility": "U", "is_constant": " ", "is_class": " "},
  "MV_INDENT": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": " ", "is_class": " "}};
  static METHODS = {};
  constructor() {
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
    this.mv_string = new abap.types.String({qualifiedName: "STRING"});
    this.mv_hex = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    this.mv_pretty_print = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    this.mv_indent = new abap.types.Integer({qualifiedName: "I"});
  }
  async constructor_(INPUT) {
    if (super.constructor_) { await super.constructor_(INPUT); }
    return this;
  }
  async if_ixml_ostream$write_string(INPUT) {
    let rval = new abap.types.Integer({qualifiedName: "I"});
    let string = INPUT?.string;
    if (string?.getQualifiedName === undefined || string.getQualifiedName() !== "STRING") { string = undefined; }
    if (string === undefined) { string = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.string); }
    let lo_obj = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_CONV_OUT_CE", RTTIName: "\\CLASS=CL_ABAP_CONV_OUT_CE"});
    let lv_xstr = new abap.types.XString({qualifiedName: "XSTRING"});
    if (abap.compare.eq(this.mv_hex, abap.builtin.abap_true)) {
      await (await abap.Classes['CL_ABAP_CONV_OUT_CE'].create()).get().convert({data: string, n: abap.builtin.strlen({val: string}), buffer: lv_xstr});
      this.mv_string.set(abap.operators.concat(this.mv_string,lv_xstr));
    } else {
      this.mv_string.set(abap.operators.concat(this.mv_string,string));
    }
    return rval;
  }
  async if_ixml_ostream$set_pretty_print(INPUT) {
    let pretty_print = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    if (INPUT && INPUT.pretty_print) {pretty_print.set(INPUT.pretty_print);}
    if (INPUT === undefined || INPUT.pretty_print === undefined) {pretty_print = abap.builtin.abap_true;}
    this.mv_pretty_print.set(pretty_print);
  }
  async if_ixml_ostream$get_pretty_print() {
    let rval = new abap.types.Character(1, {"qualifiedName":"BOOLEAN","ddicName":"BOOLEAN","description":""});
    rval.set(this.mv_pretty_print);
    return rval;
  }
  async if_ixml_ostream$set_indent(INPUT) {
    let indent = INPUT?.indent;
    if (indent?.getQualifiedName === undefined || indent.getQualifiedName() !== "I") { indent = undefined; }
    if (indent === undefined) { indent = new abap.types.Integer({qualifiedName: "I"}).set(INPUT.indent); }
    this.mv_indent.set(indent);
  }
  async if_ixml_ostream$get_indent() {
    let rval = new abap.types.Integer({qualifiedName: "I"});
    rval.set(this.mv_indent);
    return rval;
  }
  async if_ixml_ostream$set_encoding(INPUT) {
    let rval = new abap.types.Character(1, {"qualifiedName":"BOOLEAN","ddicName":"BOOLEAN","description":""});
    let encoding = INPUT?.encoding;
    if (encoding?.getQualifiedName === undefined || encoding.getQualifiedName() !== "IF_IXML_ENCODING") { encoding = undefined; }
    if (encoding === undefined) { encoding = new abap.types.ABAPObject({qualifiedName: "IF_IXML_ENCODING", RTTIName: "\\INTERFACE=IF_IXML_ENCODING"}).set(INPUT.encoding); }
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return rval;
  }
  async if_ixml_ostream$get_num_written_raw() {
    let rval = new abap.types.Integer({qualifiedName: "I"});
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return rval;
  }
}
abap.Classes['CLAS-CL_IXML-LCL_OSTREAM'] = lcl_ostream;
class lcl_istream {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CLAS-CL_IXML-LCL_ISTREAM';
  static IMPLEMENTED_INTERFACES = ["IF_IXML_ISTREAM"];
  static ATTRIBUTES = {"MV_XML": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "visibility": "I", "is_constant": " ", "is_class": " "},
  "IF_IXML_ISTREAM~DTD_ALLOWED": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "IF_IXML_ISTREAM~DTD_RESTRICTED": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "IF_IXML_ISTREAM~DTD_PROHIBITED": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": "X", "is_class": "X"}};
  static METHODS = {"CONSTRUCTOR": {"visibility": "U", "parameters": {"IV_XML": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}}};
  constructor() {
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
    this.mv_xml = new abap.types.String({qualifiedName: "STRING"});
    this.if_ixml_istream$dtd_allowed = abap.Classes['IF_IXML_ISTREAM'].if_ixml_istream$dtd_allowed;
    this.if_ixml_istream$dtd_restricted = abap.Classes['IF_IXML_ISTREAM'].if_ixml_istream$dtd_restricted;
    this.if_ixml_istream$dtd_prohibited = abap.Classes['IF_IXML_ISTREAM'].if_ixml_istream$dtd_prohibited;
  }
  async constructor_(INPUT) {
    let iv_xml = INPUT?.iv_xml;
    if (iv_xml?.getQualifiedName === undefined || iv_xml.getQualifiedName() !== "STRING") { iv_xml = undefined; }
    if (iv_xml === undefined) { iv_xml = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.iv_xml); }
    this.mv_xml.set(iv_xml);
    return this;
  }
  async if_ixml_istream$close() {
    return;
  }
  async if_ixml_istream$set_dtd_restriction(INPUT) {
    let level = new abap.types.Integer({qualifiedName: "I"});
    if (INPUT && INPUT.level) {level.set(INPUT.level);}
    if (INPUT === undefined || INPUT.level === undefined) {level = abap.Classes['IF_IXML_ISTREAM'].if_ixml_istream$dtd_restricted;}
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
  }
  async if_ixml_istream$get_dtd_restriction() {
    let rval = new abap.types.Integer({qualifiedName: "I"});
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return rval;
  }
}
abap.Classes['CLAS-CL_IXML-LCL_ISTREAM'] = lcl_istream;
lcl_istream.if_ixml_istream$dtd_allowed = new abap.types.Integer({qualifiedName: "I"});
lcl_istream.if_ixml_istream$dtd_allowed.set(0);
lcl_istream.if_ixml_istream$dtd_restricted = new abap.types.Integer({qualifiedName: "I"});
lcl_istream.if_ixml_istream$dtd_restricted.set(1);
lcl_istream.if_ixml_istream$dtd_prohibited = new abap.types.Integer({qualifiedName: "I"});
lcl_istream.if_ixml_istream$dtd_prohibited.set(2);
class lcl_stream_factory {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CLAS-CL_IXML-LCL_STREAM_FACTORY';
  static IMPLEMENTED_INTERFACES = ["IF_IXML_STREAM_FACTORY"];
  static ATTRIBUTES = {};
  static METHODS = {};
  constructor() {
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
  }
  async constructor_(INPUT) {
    if (super.constructor_) { await super.constructor_(INPUT); }
    return this;
  }
  async if_ixml_stream_factory$create_ostream_itable(INPUT) {
    let rval = new abap.types.ABAPObject({qualifiedName: "IF_IXML_OSTREAM", RTTIName: "\\INTERFACE=IF_IXML_OSTREAM"});
    let table = INPUT?.table;
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return rval;
  }
  async if_ixml_stream_factory$create_istream_cstring(INPUT) {
    let rval = new abap.types.ABAPObject({qualifiedName: "IF_IXML_ISTREAM", RTTIName: "\\INTERFACE=IF_IXML_ISTREAM"});
    let string = INPUT?.string;
    if (string?.getQualifiedName === undefined || string.getQualifiedName() !== "STRING") { string = undefined; }
    if (string === undefined) { string = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.string); }
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return rval;
  }
  async if_ixml_stream_factory$create_ostream_cstring(INPUT) {
    let stream = new abap.types.ABAPObject({qualifiedName: "IF_IXML_OSTREAM", RTTIName: "\\INTERFACE=IF_IXML_OSTREAM"});
    let string = INPUT?.string;
    if (string?.getQualifiedName === undefined || string.getQualifiedName() !== "STRING") { string = undefined; }
    if (string === undefined) { string = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.string); }
    stream.set(await (new abap.Classes['CLAS-CL_IXML-LCL_OSTREAM']()).constructor_());
    stream.get().mv_string = INPUT.string;
    return stream;
  }
  async if_ixml_stream_factory$create_ostream_xstring(INPUT) {
    let stream = new abap.types.ABAPObject({qualifiedName: "IF_IXML_OSTREAM", RTTIName: "\\INTERFACE=IF_IXML_OSTREAM"});
    let string = INPUT?.string;
    if (string?.getQualifiedName === undefined || string.getQualifiedName() !== "XSTRING") { string = undefined; }
    if (string === undefined) { string = new abap.types.XString({qualifiedName: "XSTRING"}).set(INPUT.string); }
    let lo_stream = new abap.types.ABAPObject({qualifiedName: "LCL_OSTREAM", RTTIName: "\\CLASS-POOL=CL_IXML\\CLASS=LCL_OSTREAM"});
    lo_stream.set(await (new abap.Classes['CLAS-CL_IXML-LCL_OSTREAM']()).constructor_());
    stream.set(lo_stream);
    lo_stream.get().mv_hex.set(abap.builtin.abap_true);
    stream.get().mv_string = INPUT.string;
    return stream;
  }
  async if_ixml_stream_factory$create_istream_xstring(INPUT) {
    let stream = new abap.types.ABAPObject({qualifiedName: "IF_IXML_ISTREAM", RTTIName: "\\INTERFACE=IF_IXML_ISTREAM"});
    let string = INPUT?.string;
    if (string?.getQualifiedName === undefined || string.getQualifiedName() !== "XSTRING") { string = undefined; }
    if (string === undefined) { string = new abap.types.XString({qualifiedName: "XSTRING"}).set(INPUT.string); }
    stream.set(await (new abap.Classes['CLAS-CL_IXML-LCL_ISTREAM']()).constructor_({iv_xml: (await abap.Classes['CL_ABAP_CODEPAGE'].convert_from({source: string}))}));
    return stream;
  }
  async if_ixml_stream_factory$create_istream_string(INPUT) {
    let stream = new abap.types.ABAPObject({qualifiedName: "IF_IXML_ISTREAM", RTTIName: "\\INTERFACE=IF_IXML_ISTREAM"});
    let string = INPUT?.string;
    if (string?.getQualifiedName === undefined || string.getQualifiedName() !== "STRING") { string = undefined; }
    if (string === undefined) { string = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.string); }
    stream.set(await (new abap.Classes['CLAS-CL_IXML-LCL_ISTREAM']()).constructor_({iv_xml: string}));
    return stream;
  }
}
abap.Classes['CLAS-CL_IXML-LCL_STREAM_FACTORY'] = lcl_stream_factory;
class lcl_parser {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CLAS-CL_IXML-LCL_PARSER';
  static IMPLEMENTED_INTERFACES = ["IF_IXML_PARSER"];
  static ATTRIBUTES = {"MI_ISTREAM": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_IXML_ISTREAM", RTTIName: "\\INTERFACE=IF_IXML_ISTREAM"});}, "visibility": "I", "is_constant": " ", "is_class": " "},
  "MI_DOCUMENT": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_IXML_DOCUMENT", RTTIName: "\\INTERFACE=IF_IXML_DOCUMENT"});}, "visibility": "I", "is_constant": " ", "is_class": " "},
  "LC_REGEX_TAG": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "visibility": "I", "is_constant": "X", "is_class": "X"},
  "LC_REGEX_ATTR": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "visibility": "I", "is_constant": "X", "is_class": "X"},
  "IF_IXML_PARSER~CO_NO_VALIDATION": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "IF_IXML_PARSER~CO_VALIDATE_IF_DTD": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": "X", "is_class": "X"}};
  static METHODS = {"PARSE_ATTRIBUTES": {"visibility": "I", "parameters": {"II_NODE": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE", RTTIName: "\\INTERFACE=IF_IXML_NODE"});}, "is_optional": " "}, "IV_XML": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "IS_MATCH": {"type": () => {return new abap.types.Structure({"line": new abap.types.Integer({qualifiedName: "I"}), "offset": new abap.types.Integer({qualifiedName: "I"}), "length": new abap.types.Integer({qualifiedName: "I"}), "submatches": abap.types.TableFactory.construct(new abap.types.Structure({"offset": new abap.types.Integer({qualifiedName: "I"}), "length": new abap.types.Integer({qualifiedName: "I"})}, "SUBMATCH_RESULT", "SUBMATCH_RESULT", {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"isUnique":false,"type":"STANDARD","keyFields":[],"name":"primary_key"},"secondary":[]}, "SUBMATCH_RESULT_TAB")}, "MATCH_RESULT", "MATCH_RESULT", {}, {});}, "is_optional": " "}}},
  "CONSTRUCTOR": {"visibility": "U", "parameters": {"ISTREAM": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_IXML_ISTREAM", RTTIName: "\\INTERFACE=IF_IXML_ISTREAM"});}, "is_optional": " "}, "DOCUMENT": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_IXML_DOCUMENT", RTTIName: "\\INTERFACE=IF_IXML_DOCUMENT"});}, "is_optional": " "}}}};
  constructor() {
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
    this.mi_istream = new abap.types.ABAPObject({qualifiedName: "IF_IXML_ISTREAM", RTTIName: "\\INTERFACE=IF_IXML_ISTREAM"});
    this.mi_document = new abap.types.ABAPObject({qualifiedName: "IF_IXML_DOCUMENT", RTTIName: "\\INTERFACE=IF_IXML_DOCUMENT"});
    this.if_ixml_parser$co_no_validation = abap.Classes['IF_IXML_PARSER'].if_ixml_parser$co_no_validation;
    this.if_ixml_parser$co_validate_if_dtd = abap.Classes['IF_IXML_PARSER'].if_ixml_parser$co_validate_if_dtd;
    this.lc_regex_tag = lcl_parser.lc_regex_tag;
    this.lc_regex_attr = lcl_parser.lc_regex_attr;
  }
  async constructor_(INPUT) {
    let istream = INPUT?.istream;
    if (istream?.getQualifiedName === undefined || istream.getQualifiedName() !== "IF_IXML_ISTREAM") { istream = undefined; }
    if (istream === undefined) { istream = new abap.types.ABAPObject({qualifiedName: "IF_IXML_ISTREAM", RTTIName: "\\INTERFACE=IF_IXML_ISTREAM"}).set(INPUT.istream); }
    let document = INPUT?.document;
    if (document?.getQualifiedName === undefined || document.getQualifiedName() !== "IF_IXML_DOCUMENT") { document = undefined; }
    if (document === undefined) { document = new abap.types.ABAPObject({qualifiedName: "IF_IXML_DOCUMENT", RTTIName: "\\INTERFACE=IF_IXML_DOCUMENT"}).set(INPUT.document); }
    this.mi_istream.set(istream);
    this.mi_document.set(document);
    return this;
  }
  async if_ixml_parser$set_validating(INPUT) {
    let rval = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    let mode = new abap.types.Integer({qualifiedName: "I"});
    if (INPUT && INPUT.mode) {mode.set(INPUT.mode);}
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return rval;
  }
  async if_ixml_parser$parse() {
    let subrc = new abap.types.Integer({qualifiedName: "I"});
    let lv_xml = new abap.types.String({qualifiedName: "STRING"});
    let lv_offset = new abap.types.Integer({qualifiedName: "I"});
    let lv_value = new abap.types.String({qualifiedName: "STRING"});
    let lv_name = new abap.types.String({qualifiedName: "STRING"});
    let lv_namespace = new abap.types.String({qualifiedName: "STRING"});
    let lv_tag = new abap.types.String({qualifiedName: "STRING"});
    let ls_match = new abap.types.Structure({"line": new abap.types.Integer({qualifiedName: "I"}), "offset": new abap.types.Integer({qualifiedName: "I"}), "length": new abap.types.Integer({qualifiedName: "I"}), "submatches": abap.types.TableFactory.construct(new abap.types.Structure({"offset": new abap.types.Integer({qualifiedName: "I"}), "length": new abap.types.Integer({qualifiedName: "I"})}, "SUBMATCH_RESULT", "SUBMATCH_RESULT", {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"isUnique":false,"type":"STANDARD","keyFields":[],"name":"primary_key"},"secondary":[]}, "SUBMATCH_RESULT_TAB")}, "MATCH_RESULT", "MATCH_RESULT", {}, {});
    let ls_submatch = new abap.types.Structure({"offset": new abap.types.Integer({qualifiedName: "I"}), "length": new abap.types.Integer({qualifiedName: "I"})}, "SUBMATCH_RESULT", "SUBMATCH_RESULT", {}, {});
    let lo_parent = new abap.types.ABAPObject({qualifiedName: "LCL_NODE", RTTIName: "\\CLASS-POOL=CL_IXML\\CLASS=LCL_NODE"});
    let lo_node = new abap.types.ABAPObject({qualifiedName: "LCL_NODE", RTTIName: "\\CLASS-POOL=CL_IXML\\CLASS=LCL_NODE"});
    await abap.statements.cast(lo_parent, (await this.mi_document.get().if_ixml_document$get_root()));
    lv_xml.set(this.mi_istream.get().mv_xml);
    abap.statements.replace({target: lv_xml, all: true, with: new abap.types.String().set(``), of: new abap.types.String().set(`\n`)});
    const indexBackup1 = abap.builtin.sy.get().index.get();
    let unique53 = 1;
    while (abap.compare.initial(lv_xml) === false) {
      abap.builtin.sy.get().index.set(unique53++);
      abap.statements.clear(lo_node);
      if (abap.compare.cp(lv_xml, new abap.types.Character(7).set('<?xml *'))) {
        abap.statements.find(lv_xml, {find: new abap.types.Character(2).set('?>'), first: true, offset: lv_offset});
        abap.statements.assert(abap.compare.gt(lv_offset, abap.IntegerFactory.get(0)));
        lv_offset.set(abap.operators.add(lv_offset,abap.IntegerFactory.get(2)));
      } else if (abap.compare.cp(lv_xml, new abap.types.Character(2).set('<*'))) {
        abap.statements.find(lv_xml, {regex: lcl_parser.lc_regex_tag, first: true, results: ls_match});
        abap.statements.assert(abap.compare.eq(ls_match.get().offset, abap.IntegerFactory.get(0)));
        lv_tag.set(lv_xml.getOffset({length: ls_match.get().length}));
        abap.statements.readTable(ls_match.get().submatches,{index: abap.IntegerFactory.get(1),
          into: ls_submatch});
        abap.statements.assert(abap.compare.eq(abap.builtin.sy.get().subrc, abap.IntegerFactory.get(0)));
        lv_name.set(lv_xml.getOffset({offset: ls_submatch.get().offset, length: ls_submatch.get().length}));
        if (abap.compare.cp(lv_xml, new abap.types.Character(3).set('</*'))) {
          await abap.statements.cast(lo_parent, (await lo_parent.get().if_ixml_node$get_parent()));
        } else {
          lo_node.set(await (new abap.Classes['CLAS-CL_IXML-LCL_NODE']()).constructor_({ii_parent: lo_parent}));
          if (abap.compare.ca(lv_name, new abap.types.Character(1).set(':'))) {
            abap.statements.split({source: lv_name, at: new abap.types.Character(1).set(':'), targets: [lv_namespace,lv_name]});
            await lo_node.get().if_ixml_node$set_namespace_prefix({val: lv_namespace});
          }
          await lo_node.get().if_ixml_node$set_name({name: lv_name});
          if (abap.compare.np(lv_tag, new abap.types.Character(3).set('*/>'))) {
            lo_parent.set(lo_node);
          }
        }
        await this.parse_attributes({ii_node: lo_node, iv_xml: lv_xml, is_match: ls_match});
        lv_offset.set(ls_match.get().length);
      } else {
        abap.statements.find(lv_xml, {find: new abap.types.Character(1).set('<'), first: true, offset: lv_offset});
        lv_value.set(lv_xml.getOffset({length: lv_offset}));
        lo_node.set(await (new abap.Classes['CLAS-CL_IXML-LCL_NODE']()).constructor_({ii_parent: lo_parent}));
        await lo_node.get().if_ixml_node$set_name({name: new abap.types.Character(5).set('#text')});
        await lo_node.get().if_ixml_node$set_value({value: (await abap.Classes['CLAS-CL_IXML-LCL_ESCAPE'].unescape_value({iv_value: lv_value}))});
      }
      lv_xml.set(lv_xml.getOffset({offset: lv_offset}));
      abap.statements.condense(lv_xml, {nogaps: false});
    }
    abap.builtin.sy.get().index.set(indexBackup1);
    return subrc;
  }
  async parse_attributes(INPUT) {
    let ii_node = INPUT?.ii_node;
    if (ii_node?.getQualifiedName === undefined || ii_node.getQualifiedName() !== "IF_IXML_NODE") { ii_node = undefined; }
    if (ii_node === undefined) { ii_node = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE", RTTIName: "\\INTERFACE=IF_IXML_NODE"}).set(INPUT.ii_node); }
    let iv_xml = INPUT?.iv_xml;
    if (iv_xml?.getQualifiedName === undefined || iv_xml.getQualifiedName() !== "STRING") { iv_xml = undefined; }
    if (iv_xml === undefined) { iv_xml = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.iv_xml); }
    let is_match = INPUT?.is_match;
    if (is_match?.getQualifiedName === undefined || is_match.getQualifiedName() !== "MATCH_RESULT") { is_match = undefined; }
    if (is_match === undefined) { is_match = new abap.types.Structure({"line": new abap.types.Integer({qualifiedName: "I"}), "offset": new abap.types.Integer({qualifiedName: "I"}), "length": new abap.types.Integer({qualifiedName: "I"}), "submatches": abap.types.TableFactory.construct(new abap.types.Structure({"offset": new abap.types.Integer({qualifiedName: "I"}), "length": new abap.types.Integer({qualifiedName: "I"})}, "SUBMATCH_RESULT", "SUBMATCH_RESULT", {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"isUnique":false,"type":"STANDARD","keyFields":[],"name":"primary_key"},"secondary":[]}, "SUBMATCH_RESULT_TAB")}, "MATCH_RESULT", "MATCH_RESULT", {}, {}).set(INPUT.is_match); }
    let ls_submatch = new abap.types.Structure({"offset": new abap.types.Integer({qualifiedName: "I"}), "length": new abap.types.Integer({qualifiedName: "I"})}, "SUBMATCH_RESULT", "SUBMATCH_RESULT", {}, {});
    let lv_name = new abap.types.String({qualifiedName: "STRING"});
    let lv_value = new abap.types.String({qualifiedName: "STRING"});
    let lv_xml = new abap.types.String({qualifiedName: "STRING"});
    let li_node = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE", RTTIName: "\\INTERFACE=IF_IXML_NODE"});
    let lv_offset = new abap.types.Integer({qualifiedName: "I"});
    let lv_length = new abap.types.Integer({qualifiedName: "I"});
    if (abap.compare.eq(abap.builtin.lines({val: is_match.get().submatches}), abap.IntegerFactory.get(1))) {
      return;
    }
    lv_xml.set(iv_xml.getOffset({length: is_match.get().length}));
    const indexBackup1 = abap.builtin.sy.get().index.get();
    let unique54 = 1;
    while (true) {
      abap.builtin.sy.get().index.set(unique54++);
      abap.statements.find(lv_xml, {regex: lcl_parser.lc_regex_attr, first: true, offset: lv_offset, length: lv_length, submatches: [lv_name,lv_value]});
      if (abap.compare.ne(abap.builtin.sy.get().subrc, abap.IntegerFactory.get(0))) {
        abap.builtin.sy.get().index.set(indexBackup1);
        return;
      }
      li_node.set(await (new abap.Classes['CLAS-CL_IXML-LCL_NODE']()).constructor_());
      await li_node.get().if_ixml_node$set_name({name: lv_name});
      await li_node.get().if_ixml_node$set_value({value: lv_value});
      await (await ii_node.get().if_ixml_node$get_attributes()).get().if_ixml_named_node_map$set_named_item_ns({node: li_node});
      lv_offset.set(abap.operators.add(lv_offset,lv_length));
      lv_xml.set(lv_xml.getOffset({offset: lv_offset}));
    }
    abap.builtin.sy.get().index.set(indexBackup1);
  }
  async if_ixml_parser$set_normalizing(INPUT) {
    let normal = INPUT?.normal;
    if (normal?.getQualifiedName === undefined || normal.getQualifiedName() !== "ABAP_BOOL") { normal = undefined; }
    if (normal === undefined) { normal = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}).set(INPUT.normal); }
    return;
  }
  async if_ixml_parser$num_errors() {
    let errors = new abap.types.Integer({qualifiedName: "I"});
    return errors;
    return errors;
  }
  async if_ixml_parser$add_strip_space_element() {
    return;
  }
  async if_ixml_parser$get_error(INPUT) {
    let error = new abap.types.ABAPObject({qualifiedName: "IF_IXML_PARSE_ERROR", RTTIName: "\\INTERFACE=IF_IXML_PARSE_ERROR"});
    let index = INPUT?.index;
    if (index?.getQualifiedName === undefined || index.getQualifiedName() !== "I") { index = undefined; }
    if (index === undefined) { index = new abap.types.Integer({qualifiedName: "I"}).set(INPUT.index); }
    return error;
    return error;
  }
}
abap.Classes['CLAS-CL_IXML-LCL_PARSER'] = lcl_parser;
lcl_parser.lc_regex_tag = new abap.types.String({qualifiedName: "STRING"});
lcl_parser.lc_regex_tag.set('<\\/?([\\w:\\.]+)( [\\w:]+="[\\w\\.,:\\-\\/#; %\\(\\){}&]+")* */?>');
lcl_parser.lc_regex_attr = new abap.types.String({qualifiedName: "STRING"});
lcl_parser.lc_regex_attr.set('([\\w:]+)="([\\w\\.,:\\-\\/#; %\\(\\){}&]+)"');
lcl_parser.if_ixml_parser$co_no_validation = new abap.types.Integer({qualifiedName: "I"});
lcl_parser.if_ixml_parser$co_no_validation.set(0);
lcl_parser.if_ixml_parser$co_validate_if_dtd = new abap.types.Integer({qualifiedName: "I"});
lcl_parser.if_ixml_parser$co_validate_if_dtd.set(2);
export {lcl_escape, lcl_node_iterator, lcl_encoding, lcl_named_node_map, lcl_node_list, lcl_node, lcl_document, lcl_ostream, lcl_renderer, lcl_istream, lcl_stream_factory, lcl_parser};
//# sourceMappingURL=cl_ixml.clas.locals.mjs.map