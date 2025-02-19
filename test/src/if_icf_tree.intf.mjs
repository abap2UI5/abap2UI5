// if_icf_tree.intf.abap
class if_icf_tree {
  static INTERNAL_TYPE = 'INTF';
  static ATTRIBUTES = {};
  static METHODS = {"SERVICE_FROM_URL": {"visibility": "U", "parameters": {"URL": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "HOSTNUMBER": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}, "AUTHORITY_CHECK": {"type": () => {return new abap.types.Character();}, "is_optional": " "}, "URLSUFFIX": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "ICFNODGUID": {"type": () => {return new abap.types.Character(25, {"qualifiedName":"CHAR25","ddicName":"CHAR25","description":"CHAR25"});}, "is_optional": " "}, "ICF_NAME": {"type": () => {return new abap.types.Character(15, {"qualifiedName":"CHAR15","ddicName":"CHAR15","description":"CHAR15"});}, "is_optional": " "}, "ICFACTIVE": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});}, "is_optional": " "}, "ICFALTNME": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}}};
}
abap.Classes['IF_ICF_TREE'] = if_icf_tree;
export {if_icf_tree};
//# sourceMappingURL=if_icf_tree.intf.mjs.map