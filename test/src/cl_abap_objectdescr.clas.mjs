const {cl_abap_typedescr} = await import("./cl_abap_typedescr.clas.mjs");
const {cx_root} = await import("./cx_root.clas.mjs");
// cl_abap_objectdescr.clas.abap
class cl_abap_objectdescr extends cl_abap_typedescr {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CL_ABAP_OBJECTDESCR';
  static IMPLEMENTED_INTERFACES = [];
  static ATTRIBUTES = {"ATTRIBUTES": {"type": () => {return abap.types.TableFactory.construct(new abap.types.Structure({"length": new abap.types.Integer({qualifiedName: "LENGTH"}), "decimals": new abap.types.Integer({qualifiedName: "DECIMALS"}), "name": new abap.types.Character(61, {"qualifiedName":"abap_attrname"}), "type_kind": new abap.types.Character(1, {"qualifiedName":"abap_typekind"}), "visibility": new abap.types.Character(1, {"qualifiedName":"abap_visibility"}), "is_interface": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "is_inherited": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "is_class": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "is_constant": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "is_virtual": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "is_read_only": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "alias_for": new abap.types.Character(61, {"qualifiedName":"abap_attrname"})}, "abap_attrdescr", undefined, {}, {}), {"withHeader":false,"keyType":"USER","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":["NAME"]},"secondary":[]}, "abap_attrdescr_tab");}, "visibility": "U", "is_constant": " ", "is_class": " "},
  "METHODS": {"type": () => {return abap.types.TableFactory.construct(new abap.types.Structure({"parameters": abap.types.TableFactory.construct(new abap.types.Structure({"length": new abap.types.Integer({qualifiedName: "LENGTH"}), "decimals": new abap.types.Integer({qualifiedName: "DECIMALS"}), "type_kind": new abap.types.Character(1, {"qualifiedName":"abap_typekind"}), "name": new abap.types.Character(30, {"qualifiedName":"abap_parmname"}), "parm_kind": new abap.types.Character(1, {"qualifiedName":"abap_parmkind"}), "by_value": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "is_optional": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"})}, "abap_parmdescr", undefined, {}, {}), {"withHeader":false,"keyType":"USER","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":["NAME"]},"secondary":[]}, "abap_parmdescr_tab"), "exceptions": abap.types.TableFactory.construct(new abap.types.Structure({"name": new abap.types.Character(30, {"qualifiedName":"abap_excpname"}), "is_resumable": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"})}, "abap_excpdescr", undefined, {}, {}), {"withHeader":false,"keyType":"USER","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":["NAME"]},"secondary":[]}, "abap_excpdescr_tab"), "name": new abap.types.Character(61, {"qualifiedName":"abap_methname"}), "for_event": new abap.types.Character(61, {"qualifiedName":"abap_evntname"}), "of_class": new abap.types.Character(30, {"qualifiedName":"abap_classname"}), "visibility": new abap.types.Character(1, {"qualifiedName":"abap_visibility"}), "is_interface": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "is_inherited": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "is_redefined": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "is_abstract": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "is_final": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "is_class": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "alias_for": new abap.types.Character(61, {"qualifiedName":"abap_methname"}), "is_raising_excps": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"})}, "abap_methdescr", undefined, {}, {}), {"withHeader":false,"keyType":"USER","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":["NAME"]},"secondary":[]}, "abap_methdescr_tab");}, "visibility": "U", "is_constant": " ", "is_class": " "},
  "INTERFACES": {"type": () => {return abap.types.TableFactory.construct(new abap.types.Structure({"name": new abap.types.Character(30, {"qualifiedName":"abap_intfname"}), "is_inherited": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"})}, "abap_intfdescr", undefined, {}, {}), {"withHeader":false,"keyType":"USER","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":["NAME"]},"secondary":[]}, "abap_intfdescr_tab");}, "visibility": "U", "is_constant": " ", "is_class": " "},
  "TYPES": {"type": () => {return abap.types.TableFactory.construct(new abap.types.Structure({"name": new abap.types.Character(61, {"qualifiedName":"abap_typename"}), "alias_for": new abap.types.Character(61, {"qualifiedName":"abap_typename"}), "visibility": new abap.types.Character(1, {"qualifiedName":"abap_visibility"}), "is_interface": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "is_inherited": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"})}, "abap_typedef", undefined, {}, {}), {"withHeader":false,"keyType":"USER","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":["NAME"]},"secondary":[]}, "abap_typedef_tab");}, "visibility": "U", "is_constant": " ", "is_class": " "},
  "EVENTS": {"type": () => {return abap.types.TableFactory.construct(new abap.types.Structure({"parameters": abap.types.TableFactory.construct(new abap.types.Structure({"length": new abap.types.Integer({qualifiedName: "LENGTH"}), "decimals": new abap.types.Integer({qualifiedName: "DECIMALS"}), "type_kind": new abap.types.Character(1, {"qualifiedName":"abap_typekind"}), "name": new abap.types.Character(30, {"qualifiedName":"abap_parmname"}), "parm_kind": new abap.types.Character(1, {"qualifiedName":"abap_parmkind"}), "by_value": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "is_optional": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"})}, "abap_parmdescr", undefined, {}, {}), {"withHeader":false,"keyType":"USER","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":["NAME"]},"secondary":[]}, "abap_parmdescr_tab"), "name": new abap.types.Character(61, {"qualifiedName":"abap_evntname"}), "visibility": new abap.types.Character(1, {"qualifiedName":"abap_visibility"}), "is_interface": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "is_inherited": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "is_class": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "alias_for": new abap.types.Character(61, {"qualifiedName":"abap_evntname"})}, "abap_evntdescr", undefined, {}, {}), {"withHeader":false,"keyType":"USER","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":["NAME"]},"secondary":[]}, "abap_evntdescr_tab");}, "visibility": "U", "is_constant": " ", "is_class": " "},
  "MV_OBJECT_NAME": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "visibility": "O", "is_constant": " ", "is_class": " "},
  "MV_OBJECT_TYPE": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "visibility": "O", "is_constant": " ", "is_class": " "},
  "MT_ATTRIBUTE_TYPES": {"type": () => {return abap.types.TableFactory.construct(new abap.types.Structure({"name": new abap.types.Character(61, {"qualifiedName":"abap_attrname"}), "type": new abap.types.ABAPObject({qualifiedName: "CL_ABAP_DATADESCR", RTTIName: "\\CLASS=CL_ABAP_DATADESCR"})}, "cl_abap_objectdescr=>ty_attribute_types", undefined, {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "");}, "visibility": "O", "is_constant": " ", "is_class": " "},
  "MT_PARAMETER_TYPES": {"type": () => {return abap.types.TableFactory.construct(new abap.types.Structure({"method": new abap.types.String({qualifiedName: "CL_ABAP_OBJECTDESCR=>TY_PARAMETER_TYPES-METHOD"}), "parameter": new abap.types.String({qualifiedName: "CL_ABAP_OBJECTDESCR=>TY_PARAMETER_TYPES-PARAMETER"}), "type": new abap.types.DataReference(new abap.types.Character(4))}, "cl_abap_objectdescr=>ty_parameter_types", undefined, {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "");}, "visibility": "O", "is_constant": " ", "is_class": " "},
  "CHANGING": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"abap_parmkind"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "EXPORTING": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"abap_parmkind"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "IMPORTING": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"abap_parmkind"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "RECEIVING": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"abap_parmkind"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "RETURNING": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"abap_parmkind"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "PRIVATE": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"abap_visibility"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "PROTECTED": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"abap_visibility"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "PUBLIC": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"abap_visibility"});}, "visibility": "U", "is_constant": "X", "is_class": "X"}};
  static METHODS = {"CONSTRUCTOR": {"visibility": "U", "parameters": {"P_OBJECT": {"type": () => {return new abap.types.Character(4);}, "is_optional": " "}}},
  "GET_ATTRIBUTE_TYPE": {"visibility": "U", "parameters": {"P_DESCR_REF": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "CL_ABAP_DATADESCR", RTTIName: "\\CLASS=CL_ABAP_DATADESCR"});}, "is_optional": " "}, "P_NAME": {"type": () => {return new abap.types.Character(4);}, "is_optional": " "}}},
  "GET_METHOD_PARAMETER_TYPE": {"visibility": "U", "parameters": {"P_DESCR_REF": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "CL_ABAP_DATADESCR", RTTIName: "\\CLASS=CL_ABAP_DATADESCR"});}, "is_optional": " "}, "P_METHOD_NAME": {"type": () => {return new abap.types.Character(4);}, "is_optional": " "}, "P_PARAMETER_NAME": {"type": () => {return new abap.types.Character(4);}, "is_optional": " "}}},
  "GET_INTERFACE_TYPE": {"visibility": "U", "parameters": {"P_DESCR_REF": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "CL_ABAP_INTFDESCR", RTTIName: "\\CLASS=CL_ABAP_INTFDESCR"});}, "is_optional": " "}, "P_NAME": {"type": () => {return new abap.types.Character(4);}, "is_optional": " "}}}};
  constructor() {
    super();
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
    this.attributes = abap.types.TableFactory.construct(new abap.types.Structure({"length": new abap.types.Integer({qualifiedName: "LENGTH"}), "decimals": new abap.types.Integer({qualifiedName: "DECIMALS"}), "name": new abap.types.Character(61, {"qualifiedName":"abap_attrname"}), "type_kind": new abap.types.Character(1, {"qualifiedName":"abap_typekind"}), "visibility": new abap.types.Character(1, {"qualifiedName":"abap_visibility"}), "is_interface": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "is_inherited": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "is_class": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "is_constant": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "is_virtual": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "is_read_only": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "alias_for": new abap.types.Character(61, {"qualifiedName":"abap_attrname"})}, "abap_attrdescr", undefined, {}, {}), {"withHeader":false,"keyType":"USER","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":["NAME"]},"secondary":[]}, "abap_attrdescr_tab");
    this.methods = abap.types.TableFactory.construct(new abap.types.Structure({"parameters": abap.types.TableFactory.construct(new abap.types.Structure({"length": new abap.types.Integer({qualifiedName: "LENGTH"}), "decimals": new abap.types.Integer({qualifiedName: "DECIMALS"}), "type_kind": new abap.types.Character(1, {"qualifiedName":"abap_typekind"}), "name": new abap.types.Character(30, {"qualifiedName":"abap_parmname"}), "parm_kind": new abap.types.Character(1, {"qualifiedName":"abap_parmkind"}), "by_value": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "is_optional": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"})}, "abap_parmdescr", undefined, {}, {}), {"withHeader":false,"keyType":"USER","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":["NAME"]},"secondary":[]}, "abap_parmdescr_tab"), "exceptions": abap.types.TableFactory.construct(new abap.types.Structure({"name": new abap.types.Character(30, {"qualifiedName":"abap_excpname"}), "is_resumable": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"})}, "abap_excpdescr", undefined, {}, {}), {"withHeader":false,"keyType":"USER","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":["NAME"]},"secondary":[]}, "abap_excpdescr_tab"), "name": new abap.types.Character(61, {"qualifiedName":"abap_methname"}), "for_event": new abap.types.Character(61, {"qualifiedName":"abap_evntname"}), "of_class": new abap.types.Character(30, {"qualifiedName":"abap_classname"}), "visibility": new abap.types.Character(1, {"qualifiedName":"abap_visibility"}), "is_interface": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "is_inherited": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "is_redefined": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "is_abstract": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "is_final": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "is_class": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "alias_for": new abap.types.Character(61, {"qualifiedName":"abap_methname"}), "is_raising_excps": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"})}, "abap_methdescr", undefined, {}, {}), {"withHeader":false,"keyType":"USER","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":["NAME"]},"secondary":[]}, "abap_methdescr_tab");
    this.interfaces = abap.types.TableFactory.construct(new abap.types.Structure({"name": new abap.types.Character(30, {"qualifiedName":"abap_intfname"}), "is_inherited": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"})}, "abap_intfdescr", undefined, {}, {}), {"withHeader":false,"keyType":"USER","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":["NAME"]},"secondary":[]}, "abap_intfdescr_tab");
    this.types = abap.types.TableFactory.construct(new abap.types.Structure({"name": new abap.types.Character(61, {"qualifiedName":"abap_typename"}), "alias_for": new abap.types.Character(61, {"qualifiedName":"abap_typename"}), "visibility": new abap.types.Character(1, {"qualifiedName":"abap_visibility"}), "is_interface": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "is_inherited": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"})}, "abap_typedef", undefined, {}, {}), {"withHeader":false,"keyType":"USER","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":["NAME"]},"secondary":[]}, "abap_typedef_tab");
    this.events = abap.types.TableFactory.construct(new abap.types.Structure({"parameters": abap.types.TableFactory.construct(new abap.types.Structure({"length": new abap.types.Integer({qualifiedName: "LENGTH"}), "decimals": new abap.types.Integer({qualifiedName: "DECIMALS"}), "type_kind": new abap.types.Character(1, {"qualifiedName":"abap_typekind"}), "name": new abap.types.Character(30, {"qualifiedName":"abap_parmname"}), "parm_kind": new abap.types.Character(1, {"qualifiedName":"abap_parmkind"}), "by_value": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "is_optional": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"})}, "abap_parmdescr", undefined, {}, {}), {"withHeader":false,"keyType":"USER","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":["NAME"]},"secondary":[]}, "abap_parmdescr_tab"), "name": new abap.types.Character(61, {"qualifiedName":"abap_evntname"}), "visibility": new abap.types.Character(1, {"qualifiedName":"abap_visibility"}), "is_interface": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "is_inherited": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "is_class": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "alias_for": new abap.types.Character(61, {"qualifiedName":"abap_evntname"})}, "abap_evntdescr", undefined, {}, {}), {"withHeader":false,"keyType":"USER","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":["NAME"]},"secondary":[]}, "abap_evntdescr_tab");
    this.mv_object_name = new abap.types.String({qualifiedName: "STRING"});
    this.mv_object_type = new abap.types.String({qualifiedName: "STRING"});
    this.mt_attribute_types = abap.types.TableFactory.construct(new abap.types.Structure({"name": new abap.types.Character(61, {"qualifiedName":"abap_attrname"}), "type": new abap.types.ABAPObject({qualifiedName: "CL_ABAP_DATADESCR", RTTIName: "\\CLASS=CL_ABAP_DATADESCR"})}, "cl_abap_objectdescr=>ty_attribute_types", undefined, {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "");
    this.mt_parameter_types = abap.types.TableFactory.construct(new abap.types.Structure({"method": new abap.types.String({qualifiedName: "CL_ABAP_OBJECTDESCR=>TY_PARAMETER_TYPES-METHOD"}), "parameter": new abap.types.String({qualifiedName: "CL_ABAP_OBJECTDESCR=>TY_PARAMETER_TYPES-PARAMETER"}), "type": new abap.types.DataReference(new abap.types.Character(4))}, "cl_abap_objectdescr=>ty_parameter_types", undefined, {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":[]},"secondary":[]}, "");
    this.changing = cl_abap_objectdescr.changing;
    this.exporting = cl_abap_objectdescr.exporting;
    this.importing = cl_abap_objectdescr.importing;
    this.receiving = cl_abap_objectdescr.receiving;
    this.returning = cl_abap_objectdescr.returning;
    this.private = cl_abap_objectdescr.private;
    this.protected = cl_abap_objectdescr.protected;
    this.public = cl_abap_objectdescr.public;
  }
  async constructor_(INPUT) {
    let p_object = INPUT?.p_object || new abap.types.Character(4);
    let lv_name = new abap.types.Character(61, {"qualifiedName":"abap_attrname"});
    let lv_char1 = new abap.types.Character(1, {});
    let lv_any = new abap.types.String({qualifiedName: "STRING"});
    let fs_attr_ = new abap.types.FieldSymbol(new abap.types.Structure({"length": new abap.types.Integer({qualifiedName: "LENGTH"}), "decimals": new abap.types.Integer({qualifiedName: "DECIMALS"}), "name": new abap.types.Character(61, {"qualifiedName":"abap_attrname"}), "type_kind": new abap.types.Character(1, {"qualifiedName":"abap_typekind"}), "visibility": new abap.types.Character(1, {"qualifiedName":"abap_visibility"}), "is_interface": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "is_inherited": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "is_class": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "is_constant": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "is_virtual": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "is_read_only": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "alias_for": new abap.types.Character(61, {"qualifiedName":"abap_attrname"})}, "abap_attrdescr", undefined, {}, {}));
    let fs_intf_ = new abap.types.FieldSymbol(new abap.types.Structure({"name": new abap.types.Character(30, {"qualifiedName":"abap_intfname"}), "is_inherited": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"})}, "abap_intfdescr", undefined, {}, {}));
    let fs_method_ = new abap.types.FieldSymbol(new abap.types.Structure({"parameters": abap.types.TableFactory.construct(new abap.types.Structure({"length": new abap.types.Integer({qualifiedName: "LENGTH"}), "decimals": new abap.types.Integer({qualifiedName: "DECIMALS"}), "type_kind": new abap.types.Character(1, {"qualifiedName":"abap_typekind"}), "name": new abap.types.Character(30, {"qualifiedName":"abap_parmname"}), "parm_kind": new abap.types.Character(1, {"qualifiedName":"abap_parmkind"}), "by_value": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "is_optional": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"})}, "abap_parmdescr", undefined, {}, {}), {"withHeader":false,"keyType":"USER","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":["NAME"]},"secondary":[]}, "abap_parmdescr_tab"), "exceptions": abap.types.TableFactory.construct(new abap.types.Structure({"name": new abap.types.Character(30, {"qualifiedName":"abap_excpname"}), "is_resumable": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"})}, "abap_excpdescr", undefined, {}, {}), {"withHeader":false,"keyType":"USER","primaryKey":{"name":"primary_key","type":"STANDARD","isUnique":false,"keyFields":["NAME"]},"secondary":[]}, "abap_excpdescr_tab"), "name": new abap.types.Character(61, {"qualifiedName":"abap_methname"}), "for_event": new abap.types.Character(61, {"qualifiedName":"abap_evntname"}), "of_class": new abap.types.Character(30, {"qualifiedName":"abap_classname"}), "visibility": new abap.types.Character(1, {"qualifiedName":"abap_visibility"}), "is_interface": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "is_inherited": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "is_redefined": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "is_abstract": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "is_final": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "is_class": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "alias_for": new abap.types.Character(61, {"qualifiedName":"abap_methname"}), "is_raising_excps": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"})}, "abap_methdescr", undefined, {}, {}));
    let fs_parameter_ = new abap.types.FieldSymbol(new abap.types.Structure({"length": new abap.types.Integer({qualifiedName: "LENGTH"}), "decimals": new abap.types.Integer({qualifiedName: "DECIMALS"}), "type_kind": new abap.types.Character(1, {"qualifiedName":"abap_typekind"}), "name": new abap.types.Character(30, {"qualifiedName":"abap_parmname"}), "parm_kind": new abap.types.Character(1, {"qualifiedName":"abap_parmkind"}), "by_value": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}), "is_optional": new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"})}, "abap_parmdescr", undefined, {}, {}));
    let fs_atype_ = new abap.types.FieldSymbol(new abap.types.Structure({"name": new abap.types.Character(61, {"qualifiedName":"abap_attrname"}), "type": new abap.types.ABAPObject({qualifiedName: "CL_ABAP_DATADESCR", RTTIName: "\\CLASS=CL_ABAP_DATADESCR"})}, "cl_abap_objectdescr=>ty_attribute_types", undefined, {}, {}));
    let fs_ptype_ = new abap.types.FieldSymbol(new abap.types.Structure({"method": new abap.types.String({qualifiedName: "CL_ABAP_OBJECTDESCR=>TY_PARAMETER_TYPES-METHOD"}), "parameter": new abap.types.String({qualifiedName: "CL_ABAP_OBJECTDESCR=>TY_PARAMETER_TYPES-PARAMETER"}), "type": new abap.types.DataReference(new abap.types.Character(4))}, "cl_abap_objectdescr=>ty_parameter_types", undefined, {}, {}));
    for (const a in p_object?.ATTRIBUTES || []) {
        lv_name.set(a);
      fs_attr_.assign(this.attributes.appendInitial());
      fs_atype_.assign(this.mt_attribute_types.appendInitial());
      fs_attr_.get().name.set(lv_name);
      fs_atype_.get().name.set(lv_name);
      fs_attr_.get().is_interface.set(abap.builtin.boolc(abap.compare.ca(lv_name, new abap.types.Character(1).set('~'))));
        lv_char1.set(p_object.ATTRIBUTES[a].is_constant);
      fs_attr_.get().is_constant.set(lv_char1);
        lv_char1.set(p_object.ATTRIBUTES[a].is_class || "");
      fs_attr_.get().is_class.set(lv_char1);
        lv_char1.set(p_object.ATTRIBUTES[a].visibility);
      fs_attr_.get().visibility.set(lv_char1);
        lv_any = p_object.ATTRIBUTES[a].type();
      await abap.statements.cast(fs_atype_.get().type, (await this.describe_by_data({p_data: lv_any})));
      fs_attr_.get().type_kind.set(fs_atype_.get().type.get().type_kind);
      fs_attr_.get().length.set(fs_atype_.get().type.get().length);
      fs_attr_.get().decimals.set(fs_atype_.get().type.get().decimals);
    }
    abap.statements.sort(this.attributes,{by: [{component: "is_interface", descending: true},{component: "name"}]});
    for (const a of p_object?.IMPLEMENTED_INTERFACES || []) {
        lv_name.set(a);
      fs_intf_.assign(this.interfaces.appendInitial());
      fs_intf_.get().name.set(lv_name);
    }
    abap.statements.sort(this.interfaces,{by: [{component: "name"}]});
    for (const a in p_object?.METHODS || []) {
        lv_name.set(a);
      fs_method_.assign(this.methods.appendInitial());
      fs_method_.get().name.set(lv_name);
        lv_char1.set(p_object.METHODS[a].visibility);
      fs_method_.get().visibility.set(lv_char1);
      for (const p in p_object.METHODS[a].parameters || []) {
        fs_ptype_.assign(this.mt_parameter_types.appendInitial());
        fs_parameter_.assign(fs_method_.get().parameters.appendInitial());
        fs_ptype_.get().method.set(fs_method_.get().name);
          lv_name.set(p);
        fs_parameter_.get().name.set(lv_name);
        fs_ptype_.get().parameter.set(lv_name);
          lv_any = p_object.METHODS[a].parameters[p].type();
        fs_ptype_.get().type.assign(lv_any);
      }
    }
    abap.statements.sort(this.methods,{by: [{component: "name"}]});
    await super.constructor_();
    return this;
  }
  async get_method_parameter_type(INPUT) {
    let p_descr_ref = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_DATADESCR", RTTIName: "\\CLASS=CL_ABAP_DATADESCR"});
    let p_method_name = INPUT?.p_method_name;
    let p_parameter_name = INPUT?.p_parameter_name;
    let ls_row = new abap.types.Structure({"method": new abap.types.String({qualifiedName: "CL_ABAP_OBJECTDESCR=>TY_PARAMETER_TYPES-METHOD"}), "parameter": new abap.types.String({qualifiedName: "CL_ABAP_OBJECTDESCR=>TY_PARAMETER_TYPES-PARAMETER"}), "type": new abap.types.DataReference(new abap.types.Character(4))}, "cl_abap_objectdescr=>ty_parameter_types", undefined, {}, {});
    abap.statements.readTable(this.mt_parameter_types,{into: ls_row,
      withKey: (i) => {return abap.compare.eq(i.method, p_method_name) && abap.compare.eq(i.parameter, p_parameter_name);},
      withKeyValue: [{key: (i) => {return i.method}, value: p_method_name},{key: (i) => {return i.parameter}, value: p_parameter_name}],
      usesTableLine: false,
      withKeySimple: {"method": p_method_name,"parameter": p_parameter_name}});
    if (abap.compare.eq(abap.builtin.sy.get().subrc, abap.IntegerFactory.get(0))) {
      await abap.statements.cast(p_descr_ref, (await this.describe_by_data({p_data: ls_row.get().type.dereference()})));
    } else {
      throw new abap.ClassicError({classic: "parameter_not_found"});
    }
    return p_descr_ref;
  }
  async get_interface_type(INPUT) {
    let p_descr_ref = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_INTFDESCR", RTTIName: "\\CLASS=CL_ABAP_INTFDESCR"});
    let p_name = INPUT?.p_name;
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return p_descr_ref;
  }
  async get_attribute_type(INPUT) {
    let p_descr_ref = new abap.types.ABAPObject({qualifiedName: "CL_ABAP_DATADESCR", RTTIName: "\\CLASS=CL_ABAP_DATADESCR"});
    let p_name = INPUT?.p_name;
    let lv_name = new abap.types.Character(61, {"qualifiedName":"abap_attrname"});
    let ls_type = new abap.types.Structure({"name": new abap.types.Character(61, {"qualifiedName":"abap_attrname"}), "type": new abap.types.ABAPObject({qualifiedName: "CL_ABAP_DATADESCR", RTTIName: "\\CLASS=CL_ABAP_DATADESCR"})}, "cl_abap_objectdescr=>ty_attribute_types", undefined, {}, {});
    lv_name.set(abap.builtin.to_upper({val: p_name}));
    abap.statements.readTable(this.mt_attribute_types,{into: ls_type,
      withKey: (i) => {return abap.compare.eq(i.name, lv_name);},
      withKeyValue: [{key: (i) => {return i.name}, value: lv_name}],
      usesTableLine: false,
      withKeySimple: {"name": lv_name}});
    if (abap.compare.ne(abap.builtin.sy.get().subrc, abap.IntegerFactory.get(0))) {
      throw new abap.ClassicError({classic: "attribute_not_found"});
    }
    p_descr_ref.set(ls_type.get().type);
    return p_descr_ref;
  }
}
abap.Classes['CL_ABAP_OBJECTDESCR'] = cl_abap_objectdescr;
cl_abap_objectdescr.changing = new abap.types.Character(1, {"qualifiedName":"abap_parmkind"});
cl_abap_objectdescr.changing.set('C');
cl_abap_objectdescr.exporting = new abap.types.Character(1, {"qualifiedName":"abap_parmkind"});
cl_abap_objectdescr.exporting.set('E');
cl_abap_objectdescr.importing = new abap.types.Character(1, {"qualifiedName":"abap_parmkind"});
cl_abap_objectdescr.importing.set('I');
cl_abap_objectdescr.receiving = new abap.types.Character(1, {"qualifiedName":"abap_parmkind"});
cl_abap_objectdescr.receiving.set('R');
cl_abap_objectdescr.returning = new abap.types.Character(1, {"qualifiedName":"abap_parmkind"});
cl_abap_objectdescr.returning.set('R');
cl_abap_objectdescr.private = new abap.types.Character(1, {"qualifiedName":"abap_visibility"});
cl_abap_objectdescr.private.set('I');
cl_abap_objectdescr.protected = new abap.types.Character(1, {"qualifiedName":"abap_visibility"});
cl_abap_objectdescr.protected.set('O');
cl_abap_objectdescr.public = new abap.types.Character(1, {"qualifiedName":"abap_visibility"});
cl_abap_objectdescr.public.set('U');
cl_abap_objectdescr.ty_attribute_types = new abap.types.Structure({"name": new abap.types.Character(61, {"qualifiedName":"abap_attrname"}), "type": new abap.types.ABAPObject({qualifiedName: "CL_ABAP_DATADESCR", RTTIName: "\\CLASS=CL_ABAP_DATADESCR"})}, "cl_abap_objectdescr=>ty_attribute_types", undefined, {}, {});
cl_abap_objectdescr.ty_parameter_types = new abap.types.Structure({"method": new abap.types.String({qualifiedName: "CL_ABAP_OBJECTDESCR=>TY_PARAMETER_TYPES-METHOD"}), "parameter": new abap.types.String({qualifiedName: "CL_ABAP_OBJECTDESCR=>TY_PARAMETER_TYPES-PARAMETER"}), "type": new abap.types.DataReference(new abap.types.Character(4))}, "cl_abap_objectdescr=>ty_parameter_types", undefined, {}, {});
export {cl_abap_objectdescr};
//# sourceMappingURL=cl_abap_objectdescr.clas.mjs.map