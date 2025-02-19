const {cx_root} = await import("./cx_root.clas.mjs");
// kernel_json_to_ixml.clas.abap
class kernel_json_to_ixml {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'KERNEL_JSON_TO_IXML';
  static IMPLEMENTED_INTERFACES = [];
  static ATTRIBUTES = {};
  static METHODS = {"BUILD": {"visibility": "U", "parameters": {"RI_DOC": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_IXML_DOCUMENT", RTTIName: "\\INTERFACE=IF_IXML_DOCUMENT"});}, "is_optional": " "}, "IV_JSON": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}}};
  constructor() {
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
  }
  async constructor_(INPUT) {
    if (super.constructor_) { await super.constructor_(INPUT); }
    return this;
  }
  async build(INPUT) {
    return kernel_json_to_ixml.build(INPUT);
  }
  static async build(INPUT) {
    let ri_doc = new abap.types.ABAPObject({qualifiedName: "IF_IXML_DOCUMENT", RTTIName: "\\INTERFACE=IF_IXML_DOCUMENT"});
    let iv_json = INPUT?.iv_json;
    if (iv_json?.getQualifiedName === undefined || iv_json.getQualifiedName() !== "STRING") { iv_json = undefined; }
    if (iv_json === undefined) { iv_json = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.iv_json); }
    let li_reader = new abap.types.ABAPObject({qualifiedName: "IF_SXML_READER", RTTIName: "\\INTERFACE=IF_SXML_READER"});
    let li_node = new abap.types.ABAPObject({qualifiedName: "IF_SXML_NODE", RTTIName: "\\INTERFACE=IF_SXML_NODE"});
    let li_close = new abap.types.ABAPObject({qualifiedName: "IF_SXML_CLOSE_ELEMENT", RTTIName: "\\INTERFACE=IF_SXML_CLOSE_ELEMENT"});
    let li_open = new abap.types.ABAPObject({qualifiedName: "IF_SXML_OPEN_ELEMENT", RTTIName: "\\INTERFACE=IF_SXML_OPEN_ELEMENT"});
    let li_value = new abap.types.ABAPObject({qualifiedName: "IF_SXML_VALUE_NODE", RTTIName: "\\INTERFACE=IF_SXML_VALUE_NODE"});
    let lt_attributes = abap.types.TableFactory.construct(new abap.types.ABAPObject({qualifiedName: "IF_SXML_ATTRIBUTE", RTTIName: "\\INTERFACE=IF_SXML_ATTRIBUTE"}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "if_sxml_attribute=>attributes");
    let li_attribute = new abap.types.ABAPObject({qualifiedName: "IF_SXML_ATTRIBUTE", RTTIName: "\\INTERFACE=IF_SXML_ATTRIBUTE"});
    let li_current = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE", RTTIName: "\\INTERFACE=IF_IXML_NODE"});
    let lv_name = new abap.types.String({qualifiedName: "STRING"});
    let li_map = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NAMED_NODE_MAP", RTTIName: "\\INTERFACE=IF_IXML_NAMED_NODE_MAP"});
    let li_new = new abap.types.ABAPObject({qualifiedName: "IF_IXML_NODE", RTTIName: "\\INTERFACE=IF_IXML_NODE"});
    let li_element = new abap.types.ABAPObject({qualifiedName: "IF_IXML_ELEMENT", RTTIName: "\\INTERFACE=IF_IXML_ELEMENT"});
    li_reader.set((await abap.Classes['CL_SXML_STRING_READER'].create({input: (await abap.Classes['CL_ABAP_CODEPAGE'].convert_to({source: iv_json}))})));
    ri_doc.set((await (await abap.Classes['CL_IXML'].create()).get().if_ixml$create_document()));
    li_current.set((await ri_doc.get().if_ixml_document$get_root()));
    const indexBackup1 = abap.builtin.sy.get().index.get();
    let unique98 = 1;
    while (true) {
      abap.builtin.sy.get().index.set(unique98++);
      li_node.set((await li_reader.get().if_sxml_reader$read_next_node()));
      if (abap.compare.initial(li_node)) {
        break;
      }
      let unique99 = li_node.get().if_sxml_node$type;
      if (abap.compare.eq(unique99, abap.Classes['IF_SXML_NODE'].if_sxml_node$co_nt_element_open)) {
        await abap.statements.cast(li_open, li_node);
        abap.statements.clear(lv_name);
        lt_attributes.set((await li_open.get().if_sxml_open_element$get_attributes()));
        for await (const unique100 of abap.statements.loop(lt_attributes)) {
          li_attribute.set(unique100);
          lv_name.set((await li_attribute.get().if_sxml_attribute$get_value()));
        }
        li_element.set((await ri_doc.get().if_ixml_document$create_element_ns({name: li_open.get().if_sxml_open_element$qname.get().name})));
        await abap.statements.cast(li_new, li_element);
        await li_current.get().if_ixml_node$append_child({new_child: li_new});
        li_current.set(li_new);
        if (abap.compare.initial(lv_name) === false) {
          li_element.set((await ri_doc.get().if_ixml_document$create_element_ns({name: new abap.types.Character(4).set('name')})));
          await abap.statements.cast(li_new, li_element);
          await li_new.get().if_ixml_node$set_value({value: lv_name});
          li_map.set((await li_current.get().if_ixml_node$get_attributes()));
          await li_map.get().if_ixml_named_node_map$set_named_item_ns({node: li_new});
        }
      } else if (abap.compare.eq(unique99, abap.Classes['IF_SXML_NODE'].if_sxml_node$co_nt_element_close)) {
        await abap.statements.cast(li_close, li_node);
        li_current.set((await li_current.get().if_ixml_node$get_parent()));
      } else if (abap.compare.eq(unique99, abap.Classes['IF_SXML_NODE'].if_sxml_node$co_nt_value)) {
        await abap.statements.cast(li_value, li_node);
        li_element.set((await ri_doc.get().if_ixml_document$create_element_ns({name: new abap.types.Character(5).set('#text')})));
        await li_element.get().if_ixml_element$set_value({value: (await li_value.get().if_sxml_value_node$get_value())});
        await abap.statements.cast(li_new, li_element);
        await li_current.get().if_ixml_node$append_child({new_child: li_new});
      }
    }
    abap.builtin.sy.get().index.set(indexBackup1);
    return ri_doc;
  }
}
abap.Classes['KERNEL_JSON_TO_IXML'] = kernel_json_to_ixml;
export {kernel_json_to_ixml};
//# sourceMappingURL=kernel_json_to_ixml.clas.mjs.map