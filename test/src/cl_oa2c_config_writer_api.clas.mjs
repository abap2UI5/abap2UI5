const {cx_root} = await import("./cx_root.clas.mjs");
// cl_oa2c_config_writer_api.clas.abap
class cl_oa2c_config_writer_api {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CL_OA2C_CONFIG_WRITER_API';
  static IMPLEMENTED_INTERFACES = [];
  static ATTRIBUTES = {"MT_SAVED_CONFIGS": {"type": () => {return abap.types.TableFactory.construct(new abap.types.Structure({"configuration": new abap.types.Character(32, {"qualifiedName":"OA2C_CONFIGURATION","ddicName":"OA2C_CONFIGURATION","description":""}), "client_id": new abap.types.String({qualifiedName: "CL_OA2C_CONFIG_WRITER_API=>TY_CONFIG-CLIENT_ID"}), "client_secret": new abap.types.String({qualifiedName: "CL_OA2C_CONFIG_WRITER_API=>TY_CONFIG-CLIENT_SECRET"}), "authorization_endpoint": new abap.types.String({qualifiedName: "CL_OA2C_CONFIG_WRITER_API=>TY_CONFIG-AUTHORIZATION_ENDPOINT"}), "token_endpoint": new abap.types.String({qualifiedName: "CL_OA2C_CONFIG_WRITER_API=>TY_CONFIG-TOKEN_ENDPOINT"}), "target_path": new abap.types.String({qualifiedName: "CL_OA2C_CONFIG_WRITER_API=>TY_CONFIG-TARGET_PATH"}), "granttype": new abap.types.Integer({qualifiedName: "OA2C_GRANTTYPE"})}, "cl_oa2c_config_writer_api=>ty_config", undefined, {}, {}), {"withHeader":false,"keyType":"USER","primaryKey":{"name":"primary_key","type":"SORTED","isUnique":true,"keyFields":["CONFIGURATION"]},"secondary":[]}, "");}, "visibility": "I", "is_constant": " ", "is_class": "X"},
  "MS_CONFIG": {"type": () => {return new abap.types.Structure({"configuration": new abap.types.Character(32, {"qualifiedName":"OA2C_CONFIGURATION","ddicName":"OA2C_CONFIGURATION","description":""}), "client_id": new abap.types.String({qualifiedName: "CL_OA2C_CONFIG_WRITER_API=>TY_CONFIG-CLIENT_ID"}), "client_secret": new abap.types.String({qualifiedName: "CL_OA2C_CONFIG_WRITER_API=>TY_CONFIG-CLIENT_SECRET"}), "authorization_endpoint": new abap.types.String({qualifiedName: "CL_OA2C_CONFIG_WRITER_API=>TY_CONFIG-AUTHORIZATION_ENDPOINT"}), "token_endpoint": new abap.types.String({qualifiedName: "CL_OA2C_CONFIG_WRITER_API=>TY_CONFIG-TOKEN_ENDPOINT"}), "target_path": new abap.types.String({qualifiedName: "CL_OA2C_CONFIG_WRITER_API=>TY_CONFIG-TARGET_PATH"}), "granttype": new abap.types.Integer({qualifiedName: "OA2C_GRANTTYPE"})}, "cl_oa2c_config_writer_api=>ty_config", undefined, {}, {});}, "visibility": "I", "is_constant": " ", "is_class": " "},
  "C_GRANTTYPE_CC": {"type": () => {return new abap.types.Integer({qualifiedName: "OA2C_GRANTTYPE"});}, "visibility": "U", "is_constant": "X", "is_class": "X"}};
  static METHODS = {"CREATE": {"visibility": "U", "parameters": {"RO_CONFIG_WRITER_API": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "CL_OA2C_CONFIG_WRITER_API", RTTIName: "\\CLASS=CL_OA2C_CONFIG_WRITER_API"});}, "is_optional": " "}, "I_PROFILE": {"type": () => {return new abap.types.Character(30, {"qualifiedName":"OA2C_PROFILE","ddicName":"OA2C_PROFILE","description":""});}, "is_optional": " "}, "I_CONFIGURATION": {"type": () => {return new abap.types.Character(32, {"qualifiedName":"OA2C_CONFIGURATION","ddicName":"OA2C_CONFIGURATION","description":""});}, "is_optional": " "}, "I_CLIENT_ID": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "I_CLIENT_SECRET": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "I_AUTHORIZATION_ENDPOINT": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "I_TOKEN_ENDPOINT": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "I_TARGET_PATH": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "I_CONFIGURED_GRANTTYPE": {"type": () => {return new abap.types.Integer({qualifiedName: "OA2C_GRANTTYPE"});}, "is_optional": " "}}},
  "LOAD": {"visibility": "U", "parameters": {"RO_CONFIG_WRITER_API": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "CL_OA2C_CONFIG_WRITER_API", RTTIName: "\\CLASS=CL_OA2C_CONFIG_WRITER_API"});}, "is_optional": " "}, "I_CONFIGURATION": {"type": () => {return new abap.types.Character(32, {"qualifiedName":"OA2C_CONFIGURATION","ddicName":"OA2C_CONFIGURATION","description":""});}, "is_optional": " "}}},
  "SAVE": {"visibility": "U", "parameters": {}},
  "READ": {"visibility": "U", "parameters": {"E_CLIENT_ID": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "E_AUTHORIZATION_ENDPOINT": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "E_TOKEN_ENDPOINT": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "E_TARGET_PATH": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "E_CONFIGURED_GRANTTYPE": {"type": () => {return new abap.types.Integer({qualifiedName: "OA2C_GRANTTYPE"});}, "is_optional": " "}}}};
  constructor() {
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
    this.mt_saved_configs = cl_oa2c_config_writer_api.mt_saved_configs;
    this.ms_config = new abap.types.Structure({"configuration": new abap.types.Character(32, {"qualifiedName":"OA2C_CONFIGURATION","ddicName":"OA2C_CONFIGURATION","description":""}), "client_id": new abap.types.String({qualifiedName: "CL_OA2C_CONFIG_WRITER_API=>TY_CONFIG-CLIENT_ID"}), "client_secret": new abap.types.String({qualifiedName: "CL_OA2C_CONFIG_WRITER_API=>TY_CONFIG-CLIENT_SECRET"}), "authorization_endpoint": new abap.types.String({qualifiedName: "CL_OA2C_CONFIG_WRITER_API=>TY_CONFIG-AUTHORIZATION_ENDPOINT"}), "token_endpoint": new abap.types.String({qualifiedName: "CL_OA2C_CONFIG_WRITER_API=>TY_CONFIG-TOKEN_ENDPOINT"}), "target_path": new abap.types.String({qualifiedName: "CL_OA2C_CONFIG_WRITER_API=>TY_CONFIG-TARGET_PATH"}), "granttype": new abap.types.Integer({qualifiedName: "OA2C_GRANTTYPE"})}, "cl_oa2c_config_writer_api=>ty_config", undefined, {}, {});
    this.c_granttype_cc = cl_oa2c_config_writer_api.c_granttype_cc;
  }
  async constructor_(INPUT) {
    if (super.constructor_) { await super.constructor_(INPUT); }
    return this;
  }
  async create(INPUT) {
    return cl_oa2c_config_writer_api.create(INPUT);
  }
  static async create(INPUT) {
    let ro_config_writer_api = new abap.types.ABAPObject({qualifiedName: "CL_OA2C_CONFIG_WRITER_API", RTTIName: "\\CLASS=CL_OA2C_CONFIG_WRITER_API"});
    let i_profile = INPUT?.i_profile;
    if (i_profile?.getQualifiedName === undefined || i_profile.getQualifiedName() !== "OA2C_PROFILE") { i_profile = undefined; }
    if (i_profile === undefined) { i_profile = new abap.types.Character(30, {"qualifiedName":"OA2C_PROFILE","ddicName":"OA2C_PROFILE","description":""}).set(INPUT.i_profile); }
    let i_configuration = new abap.types.Character(32, {"qualifiedName":"OA2C_CONFIGURATION","ddicName":"OA2C_CONFIGURATION","description":""});
    if (INPUT && INPUT.i_configuration) {i_configuration.set(INPUT.i_configuration);}
    let i_client_id = INPUT?.i_client_id;
    if (i_client_id?.getQualifiedName === undefined || i_client_id.getQualifiedName() !== "STRING") { i_client_id = undefined; }
    if (i_client_id === undefined) { i_client_id = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.i_client_id); }
    let i_client_secret = INPUT?.i_client_secret;
    if (i_client_secret?.getQualifiedName === undefined || i_client_secret.getQualifiedName() !== "STRING") { i_client_secret = undefined; }
    if (i_client_secret === undefined) { i_client_secret = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.i_client_secret); }
    let i_authorization_endpoint = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.i_authorization_endpoint) {i_authorization_endpoint.set(INPUT.i_authorization_endpoint);}
    let i_token_endpoint = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.i_token_endpoint) {i_token_endpoint.set(INPUT.i_token_endpoint);}
    let i_target_path = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.i_target_path) {i_target_path.set(INPUT.i_target_path);}
    let i_configured_granttype = new abap.types.Integer({qualifiedName: "OA2C_GRANTTYPE"});
    if (INPUT && INPUT.i_configured_granttype) {i_configured_granttype.set(INPUT.i_configured_granttype);}
    if (INPUT === undefined || INPUT.i_configured_granttype === undefined) {i_configured_granttype = abap.IntegerFactory.get(0);}
    abap.statements.assert(abap.compare.eq(i_configured_granttype, cl_oa2c_config_writer_api.c_granttype_cc));
    ro_config_writer_api.set(await (new abap.Classes['CL_OA2C_CONFIG_WRITER_API']()).constructor_());
    ro_config_writer_api.get().ms_config.get().configuration.set(i_configuration);
    ro_config_writer_api.get().ms_config.get().client_id.set(i_client_id);
    ro_config_writer_api.get().ms_config.get().client_secret.set(i_client_secret);
    ro_config_writer_api.get().ms_config.get().authorization_endpoint.set(i_authorization_endpoint);
    ro_config_writer_api.get().ms_config.get().token_endpoint.set(i_token_endpoint);
    ro_config_writer_api.get().ms_config.get().target_path.set(i_target_path);
    ro_config_writer_api.get().ms_config.get().granttype.set(i_configured_granttype);
    return ro_config_writer_api;
  }
  async save() {
    abap.statements.insertInternal({data: this.ms_config, table: cl_oa2c_config_writer_api.mt_saved_configs});
    abap.statements.assert(abap.compare.eq(abap.builtin.sy.get().subrc, abap.IntegerFactory.get(0)));
  }
  async load(INPUT) {
    return cl_oa2c_config_writer_api.load(INPUT);
  }
  static async load(INPUT) {
    let ro_config_writer_api = new abap.types.ABAPObject({qualifiedName: "CL_OA2C_CONFIG_WRITER_API", RTTIName: "\\CLASS=CL_OA2C_CONFIG_WRITER_API"});
    let i_configuration = new abap.types.Character(32, {"qualifiedName":"OA2C_CONFIGURATION","ddicName":"OA2C_CONFIGURATION","description":""});
    if (INPUT && INPUT.i_configuration) {i_configuration.set(INPUT.i_configuration);}
    let ls_config = new abap.types.Structure({"configuration": new abap.types.Character(32, {"qualifiedName":"OA2C_CONFIGURATION","ddicName":"OA2C_CONFIGURATION","description":""}), "client_id": new abap.types.String({qualifiedName: "CL_OA2C_CONFIG_WRITER_API=>TY_CONFIG-CLIENT_ID"}), "client_secret": new abap.types.String({qualifiedName: "CL_OA2C_CONFIG_WRITER_API=>TY_CONFIG-CLIENT_SECRET"}), "authorization_endpoint": new abap.types.String({qualifiedName: "CL_OA2C_CONFIG_WRITER_API=>TY_CONFIG-AUTHORIZATION_ENDPOINT"}), "token_endpoint": new abap.types.String({qualifiedName: "CL_OA2C_CONFIG_WRITER_API=>TY_CONFIG-TOKEN_ENDPOINT"}), "target_path": new abap.types.String({qualifiedName: "CL_OA2C_CONFIG_WRITER_API=>TY_CONFIG-TARGET_PATH"}), "granttype": new abap.types.Integer({qualifiedName: "OA2C_GRANTTYPE"})}, "cl_oa2c_config_writer_api=>ty_config", undefined, {}, {});
    abap.statements.readTable(cl_oa2c_config_writer_api.mt_saved_configs,{into: ls_config,
      withKey: (i) => {return abap.compare.eq(i.configuration, i_configuration);},
      withKeyValue: [{key: (i) => {return i.configuration}, value: i_configuration}],
      usesTableLine: false,
      withKeySimple: {"configuration": i_configuration}});
    if (abap.compare.ne(abap.builtin.sy.get().subrc, abap.IntegerFactory.get(0))) {
      const unique114 = await (new abap.Classes['CX_OA2C_CONFIG_NOT_FOUND']()).constructor_();
      unique114.EXTRA_CX = {"INTERNAL_FILENAME": "cl_oa2c_config_writer_api.clas.abap","INTERNAL_LINE": 85};
      throw unique114;
    }
    ro_config_writer_api.set(await (new abap.Classes['CL_OA2C_CONFIG_WRITER_API']()).constructor_());
    ro_config_writer_api.get().ms_config.set(ls_config);
    return ro_config_writer_api;
  }
  async read(INPUT) {
    let e_client_id = INPUT?.e_client_id || new abap.types.String({qualifiedName: "STRING"});
    let e_authorization_endpoint = INPUT?.e_authorization_endpoint || new abap.types.String({qualifiedName: "STRING"});
    let e_token_endpoint = INPUT?.e_token_endpoint || new abap.types.String({qualifiedName: "STRING"});
    let e_target_path = INPUT?.e_target_path || new abap.types.String({qualifiedName: "STRING"});
    let e_configured_granttype = INPUT?.e_configured_granttype || new abap.types.Integer({qualifiedName: "OA2C_GRANTTYPE"});
    e_client_id.set(this.ms_config.get().client_id);
    e_authorization_endpoint.set(this.ms_config.get().authorization_endpoint);
    e_token_endpoint.set(this.ms_config.get().token_endpoint);
    e_target_path.set(this.ms_config.get().target_path);
    e_configured_granttype.set(this.ms_config.get().granttype);
  }
}
abap.Classes['CL_OA2C_CONFIG_WRITER_API'] = cl_oa2c_config_writer_api;
cl_oa2c_config_writer_api.mt_saved_configs = abap.types.TableFactory.construct(new abap.types.Structure({"configuration": new abap.types.Character(32, {"qualifiedName":"OA2C_CONFIGURATION","ddicName":"OA2C_CONFIGURATION","description":""}), "client_id": new abap.types.String({qualifiedName: "CL_OA2C_CONFIG_WRITER_API=>TY_CONFIG-CLIENT_ID"}), "client_secret": new abap.types.String({qualifiedName: "CL_OA2C_CONFIG_WRITER_API=>TY_CONFIG-CLIENT_SECRET"}), "authorization_endpoint": new abap.types.String({qualifiedName: "CL_OA2C_CONFIG_WRITER_API=>TY_CONFIG-AUTHORIZATION_ENDPOINT"}), "token_endpoint": new abap.types.String({qualifiedName: "CL_OA2C_CONFIG_WRITER_API=>TY_CONFIG-TOKEN_ENDPOINT"}), "target_path": new abap.types.String({qualifiedName: "CL_OA2C_CONFIG_WRITER_API=>TY_CONFIG-TARGET_PATH"}), "granttype": new abap.types.Integer({qualifiedName: "OA2C_GRANTTYPE"})}, "cl_oa2c_config_writer_api=>ty_config", undefined, {}, {}), {"withHeader":false,"keyType":"USER","primaryKey":{"name":"primary_key","type":"SORTED","isUnique":true,"keyFields":["CONFIGURATION"]},"secondary":[]}, "");
cl_oa2c_config_writer_api.c_granttype_cc = new abap.types.Integer({qualifiedName: "OA2C_GRANTTYPE"});
cl_oa2c_config_writer_api.c_granttype_cc.set(4);
cl_oa2c_config_writer_api.ty_config = new abap.types.Structure({"configuration": new abap.types.Character(32, {"qualifiedName":"OA2C_CONFIGURATION","ddicName":"OA2C_CONFIGURATION","description":""}), "client_id": new abap.types.String({qualifiedName: "CL_OA2C_CONFIG_WRITER_API=>TY_CONFIG-CLIENT_ID"}), "client_secret": new abap.types.String({qualifiedName: "CL_OA2C_CONFIG_WRITER_API=>TY_CONFIG-CLIENT_SECRET"}), "authorization_endpoint": new abap.types.String({qualifiedName: "CL_OA2C_CONFIG_WRITER_API=>TY_CONFIG-AUTHORIZATION_ENDPOINT"}), "token_endpoint": new abap.types.String({qualifiedName: "CL_OA2C_CONFIG_WRITER_API=>TY_CONFIG-TOKEN_ENDPOINT"}), "target_path": new abap.types.String({qualifiedName: "CL_OA2C_CONFIG_WRITER_API=>TY_CONFIG-TARGET_PATH"}), "granttype": new abap.types.Integer({qualifiedName: "OA2C_GRANTTYPE"})}, "cl_oa2c_config_writer_api=>ty_config", undefined, {}, {});
export {cl_oa2c_config_writer_api};
//# sourceMappingURL=cl_oa2c_config_writer_api.clas.mjs.map