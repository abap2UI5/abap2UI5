const {cx_root} = await import("./cx_root.clas.mjs");
// kernel_ixml_xml_to_data.clas.abap
class kernel_ixml_xml_to_data {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'KERNEL_IXML_XML_TO_DATA';
  static IMPLEMENTED_INTERFACES = [];
  static ATTRIBUTES = {"MI_HEAP": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_IXML_ELEMENT", RTTIName: "\\INTERFACE=IF_IXML_ELEMENT"});}, "visibility": "I", "is_constant": " ", "is_class": "X"}};
  static METHODS = {"TRAVERSE": {"visibility": "I", "parameters": {"II_NODE": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE", RTTIName: "\\INTERFACE=IF_IXML_NODE"});}, "is_optional": " "}, "IV_REF": {"type": () => {return new abap.types.DataReference(new abap.types.Character(4));}, "is_optional": " "}}},
  "FIND_HREF_IN_HEAP": {"visibility": "I", "parameters": {"RI_NODE": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE", RTTIName: "\\INTERFACE=IF_IXML_NODE"});}, "is_optional": " "}, "IV_HREF": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}},
  "BUILD": {"visibility": "U", "parameters": {"IV_NAME": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "IV_REF": {"type": () => {return new abap.types.DataReference(new abap.types.Character(4));}, "is_optional": " "}, "II_DOC": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_IXML_DOCUMENT", RTTIName: "\\INTERFACE=IF_IXML_DOCUMENT"});}, "is_optional": " "}}}};
  constructor() {
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
    this.mi_heap = kernel_ixml_xml_to_data.mi_heap;
  }
  async constructor_(INPUT) {
    if (super.constructor_) { await super.constructor_(INPUT); }
    return this;
  }
  async build(INPUT) {
    return kernel_ixml_xml_to_data.build(INPUT);
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
    let li_first = new abap.types.ABAPObject({qualifiedName: "IF_IXML_ELEMENT", RTTIName: "\\INTERFACE=IF_IXML_ELEMENT"});
    let li_node = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE", RTTIName: "\\INTERFACE=IF_IXML_NODE"});
    let lv_name = new abap.types.String({qualifiedName: "STRING"});
    let li_iterator = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE_ITERATOR", RTTIName: "\\INTERFACE=IF_IXML_NODE_ITERATOR"});
    kernel_ixml_xml_to_data.mi_heap.set((await ii_doc.get().if_ixml_document$find_from_name_ns({name: new abap.types.Character(4).set('heap')})));
    await abap.statements.cast(li_first, (await (await ii_doc.get().if_ixml_document$get_root()).get().if_ixml_node$get_first_child()));
    li_node.set((await li_first.get().if_ixml_element$find_from_name_ns({name: iv_name, depth: abap.IntegerFactory.get(0), namespace: new abap.types.Character(1).set('')})));
    if (abap.compare.initial(li_node) === false) {
      await this.traverse({ii_node: li_node, iv_ref: iv_ref});
    }
  }
  async find_href_in_heap(INPUT) {
    return kernel_ixml_xml_to_data.find_href_in_heap(INPUT);
  }
  static async find_href_in_heap(INPUT) {
    let ri_node = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE", RTTIName: "\\INTERFACE=IF_IXML_NODE"});
    let iv_href = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.iv_href) {iv_href.set(INPUT.iv_href);}
    let li_iterator = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE_ITERATOR", RTTIName: "\\INTERFACE=IF_IXML_NODE_ITERATOR"});
    let li_child = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE", RTTIName: "\\INTERFACE=IF_IXML_NODE"});
    let lv_id = new abap.types.String({qualifiedName: "STRING"});
    abap.statements.replace({target: iv_href, all: false, with: new abap.types.Character(1).set(''), of: new abap.types.Character(1).set('#')});
    abap.statements.assert(abap.compare.initial(kernel_ixml_xml_to_data.mi_heap) === false);
    abap.statements.assert(abap.compare.initial(iv_href) === false);
    li_iterator.set((await (await kernel_ixml_xml_to_data.mi_heap.get().if_ixml_element$get_children()).get().if_ixml_node_list$create_iterator()));
    const indexBackup1 = abap.builtin.sy.get().index.get();
    let unique93 = 1;
    while (true) {
      abap.builtin.sy.get().index.set(unique93++);
      li_child.set((await li_iterator.get().if_ixml_node_iterator$get_next()));
      if (abap.compare.initial(li_child)) {
        break;
      }
      lv_id.set((await (await (await li_child.get().if_ixml_node$get_attributes()).get().if_ixml_named_node_map$get_named_item_ns({name: new abap.types.Character(2).set('id')})).get().if_ixml_node$get_value()));
      if (abap.compare.eq(lv_id, iv_href)) {
        ri_node.set(li_child);
        abap.builtin.sy.get().index.set(indexBackup1);
        return ri_node;
      }
    }
    abap.builtin.sy.get().index.set(indexBackup1);
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(17).set('not found in heap')));
    return ri_node;
  }
  async traverse(INPUT) {
    return kernel_ixml_xml_to_data.traverse(INPUT);
  }
  static async traverse(INPUT) {
    let ii_node = INPUT?.ii_node;
    if (ii_node?.getQualifiedName === undefined || ii_node.getQualifiedName() !== "IF_IXML_NODE") { ii_node = undefined; }
    if (ii_node === undefined) { ii_node = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE", RTTIName: "\\INTERFACE=IF_IXML_NODE"}).set(INPUT.ii_node); }
    let iv_ref = INPUT?.iv_ref;
    if (iv_ref === undefined) { iv_ref = new abap.types.DataReference(new abap.types.Character(4)).set(INPUT.iv_ref); }
    let lo_type = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_TYPEDESCR", RTTIName: "\\CLASS=CL_ABAP_TYPEDESCR"});
    let li_child = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE", RTTIName: "\\INTERFACE=IF_IXML_NODE"});
    let li_heap = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE", RTTIName: "\\INTERFACE=IF_IXML_NODE"});
    let li_iname = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE", RTTIName: "\\INTERFACE=IF_IXML_NODE"});
    let lv_name = new abap.types.String({qualifiedName: "STRING"});
    let li_iterator = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE_ITERATOR", RTTIName: "\\INTERFACE=IF_IXML_NODE_ITERATOR"});
    let lv_ref = new abap.types.DataReference(new abap.types.Character(4));
    let lv_value = new abap.types.String({qualifiedName: "STRING"});
    let li_href = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE", RTTIName: "\\INTERFACE=IF_IXML_NODE"});
    let fs_any_ = new abap.types.FieldSymbol(new abap.types.Character(4));
    let fs_field_ = new abap.types.FieldSymbol(new abap.types.Character(4));
    let fs_tab_ = new abap.types.FieldSymbol(abap.types.TableFactory.construct(new abap.types.Character(4), {"withHeader":false,"keyType":"DEFAULT"}));
    lo_type.set((await abap.Classes['CL_ABAP_TYPEDESCR'].describe_by_data({p_data: iv_ref.dereference()})));
    let unique94 = lo_type.get().kind;
    if (abap.compare.eq(unique94, abap.Classes['CL_ABAP_TYPEDESCR'].kind_struct)) {
      abap.statements.assign({target: fs_any_, source: iv_ref.dereference()});
      li_iterator.set((await (await ii_node.get().if_ixml_node$get_children()).get().if_ixml_node_list$create_iterator()));
      const indexBackup1 = abap.builtin.sy.get().index.get();
      let unique95 = 1;
      while (true) {
        abap.builtin.sy.get().index.set(unique95++);
        li_child.set((await li_iterator.get().if_ixml_node_iterator$get_next()));
        if (abap.compare.initial(li_child)) {
          break;
        }
        lv_name.set((await li_child.get().if_ixml_node$get_name()));
        abap.statements.assign({component: lv_name, target: fs_field_, source: fs_any_});
        if (abap.compare.eq(abap.builtin.sy.get().subrc, abap.IntegerFactory.get(0))) {
          lv_ref.assign(fs_field_.getPointer());
          await this.traverse({ii_node: li_child, iv_ref: lv_ref});
        }
      }
      abap.builtin.sy.get().index.set(indexBackup1);
    } else if (abap.compare.eq(unique94, abap.Classes['CL_ABAP_TYPEDESCR'].kind_elem)) {
      li_child.set((await ii_node.get().if_ixml_node$get_first_child()));
      if (abap.compare.initial(li_child) === false) {
        abap.statements.assign({target: fs_any_, source: iv_ref.dereference()});
        fs_any_.set((await li_child.get().if_ixml_node$get_value()));
      }
    } else if (abap.compare.eq(unique94, abap.Classes['CL_ABAP_TYPEDESCR'].kind_table)) {
      abap.statements.assign({target: fs_tab_, source: iv_ref.dereference()});
      li_iterator.set((await (await ii_node.get().if_ixml_node$get_children()).get().if_ixml_node_list$create_iterator()));
      const indexBackup2 = abap.builtin.sy.get().index.get();
      let unique96 = 1;
      while (true) {
        abap.builtin.sy.get().index.set(unique96++);
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
    } else if (abap.compare.eq(unique94, abap.Classes['CL_ABAP_TYPEDESCR'].kind_ref)) {
      abap.statements.assign({target: fs_any_, source: iv_ref.dereference()});
      if (abap.compare.initial(fs_any_)) {
        li_href.set((await (await ii_node.get().if_ixml_node$get_attributes()).get().if_ixml_named_node_map$get_named_item_ns({name: new abap.types.Character(4).set('href')})));
        if (abap.compare.initial(li_href)) {
          return;
        }
        lv_value.set((await li_href.get().if_ixml_node$get_value()));
        abap.statements.assert(abap.compare.initial(lv_value) === false);
        li_heap.set((await this.find_href_in_heap({iv_href: lv_value})));
        li_iname.set((await (await li_heap.get().if_ixml_node$get_attributes()).get().if_ixml_named_node_map$get_named_item_ns({name: new abap.types.Character(12).set('internalName')})));
        if (abap.compare.initial(li_iname) && abap.compare.eq(lv_value.getOffset({length: 2}), new abap.types.Character(2).set('#o'))) {
          return;
        }
        if (abap.compare.eq(lv_value.getOffset({length: 2}), new abap.types.Character(2).set('#o'))) {
          lv_value.set((await li_iname.get().if_ixml_node$get_value()));
          abap.statements.assert(abap.compare.initial(lv_value) === false);
          fs_any_.pointer.value = new abap.Classes[lv_value.get()]();
          li_iterator.set((await (await (await li_heap.get().if_ixml_node$get_first_child()).get().if_ixml_node$get_children()).get().if_ixml_node_list$create_iterator()));
          const indexBackup3 = abap.builtin.sy.get().index.get();
          let unique97 = 1;
          while (true) {
            abap.builtin.sy.get().index.set(unique97++);
            li_child.set((await li_iterator.get().if_ixml_node_iterator$get_next()));
            if (abap.compare.initial(li_child)) {
              break;
            }
            lv_name.set((await li_child.get().if_ixml_node$get_name()));
            abap.statements.replace({target: lv_name, all: false, with: new abap.types.Character(1).set('~'), of: new abap.types.Character(1).set('.')});
            abap.statements.assign({target: fs_field_, dynamicName: '<any>' + '->' + lv_name.get(), dynamicSource: (() => {
                        try { return fs_any_; } catch {}
                        try { return this.fs_any_; } catch {}
                      })()});
              if (abap.compare.eq(abap.builtin.sy.get().subrc, abap.IntegerFactory.get(0))) {
                lv_ref.assign(fs_field_.getPointer());
                await this.traverse({ii_node: li_child, iv_ref: lv_ref});
              }
            }
            abap.builtin.sy.get().index.set(indexBackup3);
          } else {
            abap.statements.createData(fs_any_);
            li_child.set((await li_heap.get().if_ixml_node$get_first_child()));
            lv_ref.assign(fs_any_.getPointer());
            await this.traverse({ii_node: li_child, iv_ref: lv_ref.dereference()});
          }
        } else {
          abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(9).set('todo_ref2')));
        }
      } else {
        console.dir(lo_type.get().kind.get());
        abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
      }
    }
  }
  abap.Classes['KERNEL_IXML_XML_TO_DATA'] = kernel_ixml_xml_to_data;
  kernel_ixml_xml_to_data.mi_heap = new abap.types.ABAPObject({qualifiedName: "IF_IXML_ELEMENT", RTTIName: "\\INTERFACE=IF_IXML_ELEMENT"});
export {kernel_ixml_xml_to_data};
//# sourceMappingURL=kernel_ixml_xml_to_data.clas.mjs.map