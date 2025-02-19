// if_sxml_named.intf.abap
class if_sxml_named {
  static INTERNAL_TYPE = 'INTF';
  static ATTRIBUTES = {"CO_USE_DEFAULT_XMLNS": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "visibility": "U", "is_constant": "X", "is_class": "X"}};
  static METHODS = {};
}
abap.Classes['IF_SXML_NAMED'] = if_sxml_named;
if_sxml_named.if_sxml_named$co_use_default_xmlns = new abap.types.String({qualifiedName: "STRING"});
if_sxml_named.if_sxml_named$co_use_default_xmlns.set(':');
if_sxml_named.pathnode = new abap.types.Structure({"qname": new abap.types.Structure({"name": new abap.types.String({qualifiedName: "IF_SXML_NAMED=>PATHNODE-QNAME-NAME"}), "namespace": new abap.types.String({qualifiedName: "IF_SXML_NAMED=>PATHNODE-QNAME-NAMESPACE"})}, "if_sxml_named=>pathnode-qname", undefined, {}, {}), "prefix": new abap.types.String({qualifiedName: "IF_SXML_NAMED=>PATHNODE-PREFIX"}), "child_position": new abap.types.Integer({qualifiedName: "IF_SXML_NAMED=>PATHNODE-CHILD_POSITION"})}, "if_sxml_named=>pathnode", undefined, {}, {});
if_sxml_named.path = abap.types.TableFactory.construct(new abap.types.Structure({"qname": new abap.types.Structure({"name": new abap.types.String({qualifiedName: "IF_SXML_NAMED=>PATHNODE-QNAME-NAME"}), "namespace": new abap.types.String({qualifiedName: "IF_SXML_NAMED=>PATHNODE-QNAME-NAMESPACE"})}, "if_sxml_named=>pathnode-qname", undefined, {}, {}), "prefix": new abap.types.String({qualifiedName: "IF_SXML_NAMED=>PATHNODE-PREFIX"}), "child_position": new abap.types.Integer({qualifiedName: "IF_SXML_NAMED=>PATHNODE-CHILD_POSITION"})}, "if_sxml_named=>pathnode", undefined, {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "if_sxml_named=>path");
if_sxml_named.nsbinding = new abap.types.Structure({"prefix": new abap.types.String({qualifiedName: "IF_SXML_NAMED=>NSBINDING-PREFIX"}), "nsuri": new abap.types.String({qualifiedName: "IF_SXML_NAMED=>NSBINDING-NSURI"})}, "if_sxml_named=>nsbinding", undefined, {}, {});
if_sxml_named.nsbindings = abap.types.TableFactory.construct(new abap.types.Structure({"prefix": new abap.types.String({qualifiedName: "IF_SXML_NAMED=>NSBINDING-PREFIX"}), "nsuri": new abap.types.String({qualifiedName: "IF_SXML_NAMED=>NSBINDING-NSURI"})}, "if_sxml_named=>nsbinding", undefined, {}, {}), {"withHeader":false,"keyType":"USER","primaryKey":{"name":"primary_key","type":"HASHED","isUnique":true,"keyFields":["PREFIX"]},"secondary":[]}, "if_sxml_named=>nsbindings");
export {if_sxml_named};
//# sourceMappingURL=if_sxml_named.intf.mjs.map