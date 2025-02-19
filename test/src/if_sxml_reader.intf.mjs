// if_sxml_reader.intf.abap
class if_sxml_reader {
  static INTERNAL_TYPE = 'INTF';
  static ATTRIBUTES = {"NODE_TYPE": {"type": () => {return new abap.types.Integer({qualifiedName: "IF_SXML_NODE=>NODE_TYPE"});}, "visibility": "U", "is_constant": " ", "is_class": " "},
  "NAME": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "visibility": "U", "is_constant": " ", "is_class": " "},
  "VALUE_TYPE": {"type": () => {return new abap.types.Integer({qualifiedName: "IF_SXML_VALUE=>VALUE_TYPE"});}, "visibility": "U", "is_constant": " ", "is_class": " "},
  "VALUE": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "visibility": "U", "is_constant": " ", "is_class": " "},
  "VALUE_RAW": {"type": () => {return new abap.types.XString({qualifiedName: "XSTRING"});}, "visibility": "U", "is_constant": " ", "is_class": " "},
  "CO_OPT_NORMALIZING": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "CO_OPT_KEEP_WHITESPACE": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "CO_OPT_ASXML": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "CO_OPT_SEP_MEMBER": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": "X", "is_class": "X"}};
  static METHODS = {"READ_NEXT_NODE": {"visibility": "U", "parameters": {"NODE": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_SXML_NODE", RTTIName: "\\INTERFACE=IF_SXML_NODE"});}, "is_optional": " "}}},
  "NEXT_NODE": {"visibility": "U", "parameters": {"VALUE_TYPE": {"type": () => {return new abap.types.Integer({qualifiedName: "IF_SXML_VALUE=>VALUE_TYPE"});}, "is_optional": " "}}},
  "NEXT_ATTRIBUTE": {"visibility": "U", "parameters": {"VALUE_TYPE": {"type": () => {return new abap.types.Integer({qualifiedName: "IF_SXML_VALUE=>VALUE_TYPE"});}, "is_optional": " "}}},
  "SKIP_NODE": {"visibility": "U", "parameters": {"WRITER": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_SXML_WRITER", RTTIName: "\\INTERFACE=IF_SXML_WRITER"});}, "is_optional": " "}}},
  "SET_OPTION": {"visibility": "U", "parameters": {"OPTION": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}, "VALUE": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});}, "is_optional": " "}}},
  "GET_NSURI_BY_PREFIX": {"visibility": "U", "parameters": {"NSURI": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "PREFIX": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}},
  "GET_PREFIX_BY_NSURI": {"visibility": "U", "parameters": {"PREFIX": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "NSURI": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}},
  "GET_NSBINDINGS": {"visibility": "U", "parameters": {"NSBINDINGS": {"type": () => {return abap.types.TableFactory.construct(new abap.types.Structure({"prefix": new abap.types.String({qualifiedName: "IF_SXML_NAMED=>NSBINDING-PREFIX"}), "nsuri": new abap.types.String({qualifiedName: "IF_SXML_NAMED=>NSBINDING-NSURI"})}, "if_sxml_named=>nsbinding", undefined, {}, {}), {"withHeader":false,"keyType":"USER","primaryKey":{"name":"primary_key","type":"HASHED","isUnique":true,"keyFields":["PREFIX"]},"secondary":[]}, "if_sxml_named=>nsbindings");}, "is_optional": " "}}},
  "GET_PATH": {"visibility": "U", "parameters": {"PATH": {"type": () => {return abap.types.TableFactory.construct(new abap.types.Structure({"qname": new abap.types.Structure({"name": new abap.types.String({qualifiedName: "IF_SXML_NAMED=>PATHNODE-QNAME-NAME"}), "namespace": new abap.types.String({qualifiedName: "IF_SXML_NAMED=>PATHNODE-QNAME-NAMESPACE"})}, "if_sxml_named=>pathnode-qname", undefined, {}, {}), "prefix": new abap.types.String({qualifiedName: "IF_SXML_NAMED=>PATHNODE-PREFIX"}), "child_position": new abap.types.Integer({qualifiedName: "IF_SXML_NAMED=>PATHNODE-CHILD_POSITION"})}, "if_sxml_named=>pathnode", undefined, {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "if_sxml_named=>path");}, "is_optional": " "}}},
  "CURRENT_NODE": {"visibility": "U", "parameters": {}},
  "READ_CURRENT_NODE": {"visibility": "U", "parameters": {"NODE": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_SXML_NODE", RTTIName: "\\INTERFACE=IF_SXML_NODE"});}, "is_optional": " "}}}};
}
abap.Classes['IF_SXML_READER'] = if_sxml_reader;
if_sxml_reader.if_sxml_reader$co_opt_normalizing = new abap.types.Integer({qualifiedName: "I"});
if_sxml_reader.if_sxml_reader$co_opt_normalizing.set(1);
if_sxml_reader.if_sxml_reader$co_opt_keep_whitespace = new abap.types.Integer({qualifiedName: "I"});
if_sxml_reader.if_sxml_reader$co_opt_keep_whitespace.set(2);
if_sxml_reader.if_sxml_reader$co_opt_asxml = new abap.types.Integer({qualifiedName: "I"});
if_sxml_reader.if_sxml_reader$co_opt_asxml.set(3);
if_sxml_reader.if_sxml_reader$co_opt_sep_member = new abap.types.Integer({qualifiedName: "I"});
if_sxml_reader.if_sxml_reader$co_opt_sep_member.set(4);
export {if_sxml_reader};
//# sourceMappingURL=if_sxml_reader.intf.mjs.map