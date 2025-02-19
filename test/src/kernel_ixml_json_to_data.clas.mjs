const {cx_root} = await import("./cx_root.clas.mjs");
// kernel_ixml_json_to_data.clas.abap
class kernel_ixml_json_to_data {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'KERNEL_IXML_JSON_TO_DATA';
  static IMPLEMENTED_INTERFACES = [];
  static ATTRIBUTES = {};
  static METHODS = {"GET_FIELD_NAME": {"visibility": "I", "parameters": {"RV_NAME": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "II_NODE": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE", RTTIName: "\\INTERFACE=IF_IXML_NODE"});}, "is_optional": " "}}},
  "TRAVERSE": {"visibility": "I", "parameters": {"II_NODE": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE", RTTIName: "\\INTERFACE=IF_IXML_NODE"});}, "is_optional": " "}, "IV_REF": {"type": () => {return new abap.types.DataReference(new abap.types.Character(4));}, "is_optional": " "}}},
  "BUILD": {"visibility": "U", "parameters": {"IV_NAME": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "IV_REF": {"type": () => {return new abap.types.DataReference(new abap.types.Character(4));}, "is_optional": " "}, "II_DOC": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_IXML_DOCUMENT", RTTIName: "\\INTERFACE=IF_IXML_DOCUMENT"});}, "is_optional": " "}}}};
  constructor() {
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
  }
  async constructor_(INPUT) {
    if (super.constructor_) { await super.constructor_(INPUT); }
    return this;
  }
  async get_field_name(INPUT) {
    return kernel_ixml_json_to_data.get_field_name(INPUT);
  }
  static async get_field_name(INPUT) {
    let rv_name = new abap.types.String({qualifiedName: "STRING"});
    let ii_node = INPUT?.ii_node;
    if (ii_node?.getQualifiedName === undefined || ii_node.getQualifiedName() !== "IF_IXML_NODE") { ii_node = undefined; }
    if (ii_node === undefined) { ii_node = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE", RTTIName: "\\INTERFACE=IF_IXML_NODE"}).set(INPUT.ii_node); }
    let li_aiterator = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE_ITERATOR", RTTIName: "\\INTERFACE=IF_IXML_NODE_ITERATOR"});
    let li_anode = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE", RTTIName: "\\INTERFACE=IF_IXML_NODE"});
    let attr = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NAMED_NODE_MAP", RTTIName: "\\INTERFACE=IF_IXML_NAMED_NODE_MAP"});
    attr.set((await ii_node.get().if_ixml_node$get_attributes()));
    if (abap.compare.initial(attr) === false) {
      li_aiterator.set((await attr.get().if_ixml_named_node_map$create_iterator()));
      const indexBackup1 = abap.builtin.sy.get().index.get();
      let unique88 = 1;
      while (true) {
        abap.builtin.sy.get().index.set(unique88++);
        li_anode.set((await li_aiterator.get().if_ixml_node_iterator$get_next()));
        if (abap.compare.initial(li_anode)) {
          break;
        }
        rv_name.set((await li_anode.get().if_ixml_node$get_value()));
        abap.builtin.sy.get().index.set(indexBackup1);
        return rv_name;
      }
      abap.builtin.sy.get().index.set(indexBackup1);
    }
    return rv_name;
  }
  async build(INPUT) {
    return kernel_ixml_json_to_data.build(INPUT);
  }
  static async build(INPUT) {
    let iv_name = INPUT?.iv_name;
    if (iv_name?.getQualifiedName === undefined || iv_name.getQualifiedName() !== "STRING") { iv_name = undefined; }
    if (iv_name === undefined) { iv_name = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.iv_name); }
    let iv_ref = INPUT?.iv_ref;
    if (iv_ref === undefined) { iv_ref = new abap.types.DataReference(new abap.types.Character(4)).set(INPUT.iv_ref); }
    let ii_doc = INPUT?.ii_doc;
    if (ii_doc?.getQualifiedName === undefined || ii_doc.getQualifiedName() !== "IF_IXML_DOCUMENT") { ii_doc = undefined; }
    if (ii_doc === undefined) { ii_doc = new abap.types.ABAPObject({qualifiedName: "IF_IXML_DOCUMENT", RTTIName: "\\INTERFACE=IF_IXML_DOCUMENT"}).set(INPUT.ii_doc); }
    let li_first = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE", RTTIName: "\\INTERFACE=IF_IXML_NODE"});
    let li_node = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE", RTTIName: "\\INTERFACE=IF_IXML_NODE"});
    let lv_name = new abap.types.String({qualifiedName: "STRING"});
    let li_iterator = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE_ITERATOR", RTTIName: "\\INTERFACE=IF_IXML_NODE_ITERATOR"});
    li_first.set((await (await ii_doc.get().if_ixml_document$get_root()).get().if_ixml_node$get_first_child()));
    abap.statements.assert(abap.compare.eq((await li_first.get().if_ixml_node$get_name()), new abap.types.Character(6).set('object')));
    li_iterator.set((await (await li_first.get().if_ixml_node$get_children()).get().if_ixml_node_list$create_iterator()));
    const indexBackup1 = abap.builtin.sy.get().index.get();
    let unique89 = 1;
    while (true) {
      abap.builtin.sy.get().index.set(unique89++);
      li_node.set((await li_iterator.get().if_ixml_node_iterator$get_next()));
      if (abap.compare.initial(li_node)) {
        break;
      }
      lv_name.set((await this.get_field_name({ii_node: li_node})));
      if (abap.compare.eq(lv_name, iv_name)) {
        await this.traverse({iv_ref: iv_ref, ii_node: li_node});
        abap.builtin.sy.get().index.set(indexBackup1);
        return;
      }
    }
    abap.builtin.sy.get().index.set(indexBackup1);
  }
  async traverse(INPUT) {
    return kernel_ixml_json_to_data.traverse(INPUT);
  }
  static async traverse(INPUT) {
    let ii_node = INPUT?.ii_node;
    if (ii_node?.getQualifiedName === undefined || ii_node.getQualifiedName() !== "IF_IXML_NODE") { ii_node = undefined; }
    if (ii_node === undefined) { ii_node = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE", RTTIName: "\\INTERFACE=IF_IXML_NODE"}).set(INPUT.ii_node); }
    let iv_ref = INPUT?.iv_ref;
    if (iv_ref === undefined) { iv_ref = new abap.types.DataReference(new abap.types.Character(4)).set(INPUT.iv_ref); }
    let lo_type = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_TYPEDESCR", RTTIName: "\\CLASS=CL_ABAP_TYPEDESCR"});
    let li_child = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE", RTTIName: "\\INTERFACE=IF_IXML_NODE"});
    let lv_name = new abap.types.String({qualifiedName: "STRING"});
    let li_iterator = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE_ITERATOR", RTTIName: "\\INTERFACE=IF_IXML_NODE_ITERATOR"});
    let lv_ref = new abap.types.DataReference(new abap.types.Character(4));
    let fs_any_ = new abap.types.FieldSymbol(new abap.types.Character(4));
    let fs_field_ = new abap.types.FieldSymbol(new abap.types.Character(4));
    let fs_tab_ = new abap.types.FieldSymbol(abap.types.TableFactory.construct(new abap.types.Character(4), {"withHeader":false,"keyType":"DEFAULT"}));
    lo_type.set((await abap.Classes['CL_ABAP_TYPEDESCR'].describe_by_data({p_data: iv_ref.dereference()})));
    let unique90 = lo_type.get().kind;
    if (abap.compare.eq(unique90, abap.Classes['CL_ABAP_TYPEDESCR'].kind_struct)) {
      abap.statements.assert(abap.compare.eq((await ii_node.get().if_ixml_node$get_name()), new abap.types.Character(6).set('object')));
      abap.statements.assign({target: fs_any_, source: iv_ref.dereference()});
      li_iterator.set((await (await ii_node.get().if_ixml_node$get_children()).get().if_ixml_node_list$create_iterator()));
      const indexBackup1 = abap.builtin.sy.get().index.get();
      let unique91 = 1;
      while (true) {
        abap.builtin.sy.get().index.set(unique91++);
        li_child.set((await li_iterator.get().if_ixml_node_iterator$get_next()));
        if (abap.compare.initial(li_child)) {
          break;
        }
        lv_name.set((await this.get_field_name({ii_node: li_child})));
        abap.statements.assign({component: lv_name, target: fs_field_, source: fs_any_});
        if (abap.compare.eq(abap.builtin.sy.get().subrc, abap.IntegerFactory.get(0))) {
          lv_ref.assign(fs_field_.getPointer());
          await this.traverse({ii_node: li_child, iv_ref: lv_ref});
        }
      }
      abap.builtin.sy.get().index.set(indexBackup1);
    } else if (abap.compare.eq(unique90, abap.Classes['CL_ABAP_TYPEDESCR'].kind_elem)) {
      li_child.set((await ii_node.get().if_ixml_node$get_first_child()));
      abap.statements.assert(abap.compare.eq((await li_child.get().if_ixml_node$get_name()), new abap.types.Character(5).set('#text')));
      abap.statements.assign({target: fs_any_, source: iv_ref.dereference()});
      fs_any_.set((await li_child.get().if_ixml_node$get_value()));
      if (abap.compare.eq(lo_type.get().type_kind, abap.Classes['CL_ABAP_TYPEDESCR'].typekind_char) || abap.compare.eq(lo_type.get().type_kind, abap.Classes['CL_ABAP_TYPEDESCR'].typekind_clike) || abap.compare.eq(lo_type.get().type_kind, abap.Classes['CL_ABAP_TYPEDESCR'].typekind_string)) {
        abap.statements.replace({target: fs_any_, all: true, with: new abap.types.Character(1).set('"'), of: new abap.types.Character(2).set('\\"')});
      }
    } else if (abap.compare.eq(unique90, abap.Classes['CL_ABAP_TYPEDESCR'].kind_table)) {
      abap.statements.assert(abap.compare.eq((await ii_node.get().if_ixml_node$get_name()), new abap.types.Character(5).set('array')));
      abap.statements.assign({target: fs_tab_, source: iv_ref.dereference()});
      li_iterator.set((await (await ii_node.get().if_ixml_node$get_children()).get().if_ixml_node_list$create_iterator()));
      const indexBackup2 = abap.builtin.sy.get().index.get();
      let unique92 = 1;
      while (true) {
        abap.builtin.sy.get().index.set(unique92++);
        li_child.set((await li_iterator.get().if_ixml_node_iterator$get_next()));
        if (abap.compare.initial(li_child)) {
          break;
        }
        abap.statements.createData(lv_ref,{"likeLineOf": fs_tab_});
        abap.statements.assign({target: fs_any_, source: lv_ref.dereference()});
        await this.traverse({ii_node: li_child, iv_ref: lv_ref});
        abap.statements.insertInternal({data: fs_any_, table: fs_tab_});
      }
      abap.builtin.sy.get().index.set(indexBackup2);
    } else {
      console.dir(lo_type.get().kind.get());
      abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    }
  }
}
abap.Classes['KERNEL_IXML_JSON_TO_DATA'] = kernel_ixml_json_to_data;
export {kernel_ixml_json_to_data};
//# sourceMappingURL=kernel_ixml_json_to_data.clas.mjs.map