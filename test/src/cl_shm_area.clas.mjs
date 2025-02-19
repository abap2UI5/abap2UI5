const {cx_shm_general_error} = await import("./cx_shm_general_error.clas.mjs");
const {cx_root} = await import("./cx_root.clas.mjs");
// cl_shm_area.clas.abap
class cl_shm_area extends cx_shm_general_error {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CL_SHM_AREA';
  static IMPLEMENTED_INTERFACES = ["IF_MESSAGE","IF_MESSAGE","IF_MESSAGE","IF_MESSAGE"];
  static ATTRIBUTES = {"MO_ROOT": {"type": () => {return new abap.types.ABAPObject({qualifiedName: undefined, RTTIName: undefined});}, "visibility": "I", "is_constant": " ", "is_class": "X"},
  "PROPERTIES": {"type": () => {return new abap.types.Structure({"auto_build": new abap.types.Character(1, {}), "has_versions": new abap.types.Character(1, {})}, "SHM_PROPERTIES", "SHM_PROPERTIES", {}, {});}, "visibility": "U", "is_constant": " ", "is_class": " "},
  "INST_NAME": {"type": () => {return new abap.types.Character(80, {"qualifiedName":"SHM_INST_NAME","ddicName":"SHM_INST_NAME","description":"SHM_INST_NAME"});}, "visibility": "U", "is_constant": " ", "is_class": " "},
  "CLIENT": {"type": () => {return new abap.types.Character(3, {"qualifiedName":"MANDT","ddicName":"MANDT","description":"MANDT"});}, "visibility": "U", "is_constant": " ", "is_class": " "},
  "INST_TRACE_ACTIVE": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});}, "visibility": "O", "is_constant": " ", "is_class": " "},
  "INST_TRACE_SERVICE": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_SHM_TRACE", RTTIName: "\\INTERFACE=IF_SHM_TRACE"});}, "visibility": "O", "is_constant": " ", "is_class": " "},
  "_LOCK": {"type": () => {return new abap.types.Hex({length: 8});}, "visibility": "O", "is_constant": " ", "is_class": " "},
  "DEFAULT_INSTANCE": {"type": () => {return new abap.types.Character(80, {"qualifiedName":"SHM_INST_NAME","ddicName":"SHM_INST_NAME","description":"SHM_INST_NAME"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "INVOCATION_MODE_EXPLICIT": {"type": () => {return new abap.types.Integer({qualifiedName: "SHM_CONSTR_INVOCATION_MODE"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "LIFE_CONTEXT_APPSERVER": {"type": () => {return new abap.types.Integer({qualifiedName: "SHM_LIFE_CONTEXT"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "ATTACH_MODE_DEFAULT": {"type": () => {return new abap.types.Integer({qualifiedName: "SHM_ATTACH_MODE"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "ATTACH_MODE_WAIT": {"type": () => {return new abap.types.Integer({qualifiedName: "SHM_ATTACH_MODE"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "AFFECT_LOCAL_SERVER": {"type": () => {return new abap.types.Integer({qualifiedName: "SHM_AFFECT_SERVER"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "ATTACH_MODE_WAIT_2ND_TRY": {"type": () => {return new abap.types.Integer({qualifiedName: "SHM_ATTACH_MODE"});}, "visibility": "O", "is_constant": "X", "is_class": "X"}};
  static METHODS = {"_ATTACH_READ71": {"visibility": "O", "parameters": {"SNEAK_MODE": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});}, "is_optional": " "}, "AREA_NAME": {"type": () => {return new abap.types.Character(30, {"qualifiedName":"SHM_AREA_NAME","ddicName":"SHM_AREA_NAME","description":"SHM_AREA_NAME"});}, "is_optional": " "}, "LIFE_CONTEXT": {"type": () => {return new abap.types.Integer({qualifiedName: "SHM_LIFE_CONTEXT"});}, "is_optional": " "}, "ROOT": {"type": () => {return new abap.types.ABAPObject({qualifiedName: undefined, RTTIName: undefined});}, "is_optional": " "}}},
  "_ATTACH_UPDATE70": {"visibility": "O", "parameters": {"AREA_NAME": {"type": () => {return new abap.types.Character(30, {"qualifiedName":"SHM_AREA_NAME","ddicName":"SHM_AREA_NAME","description":"SHM_AREA_NAME"});}, "is_optional": " "}, "MODE": {"type": () => {return new abap.types.Integer({qualifiedName: "SHM_ATTACH_MODE"});}, "is_optional": " "}, "ROOT": {"type": () => {return new abap.types.ABAPObject({qualifiedName: undefined, RTTIName: undefined});}, "is_optional": " "}, "WAIT_TIME": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}}},
  "_ATTACH_WRITE70": {"visibility": "O", "parameters": {"AREA_NAME": {"type": () => {return new abap.types.Character(30, {"qualifiedName":"SHM_AREA_NAME","ddicName":"SHM_AREA_NAME","description":"SHM_AREA_NAME"});}, "is_optional": " "}, "MODE": {"type": () => {return new abap.types.Integer({qualifiedName: "SHM_ATTACH_MODE"});}, "is_optional": " "}, "ROOT": {"type": () => {return new abap.types.ABAPObject({qualifiedName: undefined, RTTIName: undefined});}, "is_optional": " "}, "WAIT_TIME": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "is_optional": " "}}},
  "_INVALIDATE_AREA71": {"visibility": "O", "parameters": {"RC": {"type": () => {return new abap.types.Integer({qualifiedName: "SHM_RC"});}, "is_optional": " "}, "AREA_NAME": {"type": () => {return new abap.types.Character(30, {"qualifiedName":"SHM_AREA_NAME","ddicName":"SHM_AREA_NAME","description":"SHM_AREA_NAME"});}, "is_optional": " "}, "CLIENT": {"type": () => {return new abap.types.Character(3, {"qualifiedName":"SHM_CLIENT","ddicName":"SHM_CLIENT","description":"SHMA_CLIENT"});}, "is_optional": " "}, "CLIENT_SUPPLIED": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});}, "is_optional": " "}, "TRANSACTIONAL": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});}, "is_optional": " "}, "CLIENT_DEPENDENT": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});}, "is_optional": " "}, "TERMINATE_CHANGER": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});}, "is_optional": " "}, "AFFECT_SERVER": {"type": () => {return new abap.types.Integer({qualifiedName: "SHM_AFFECT_SERVER"});}, "is_optional": " "}, "LIFE_CONTEXT": {"type": () => {return new abap.types.Integer({qualifiedName: "SHM_LIFE_CONTEXT"});}, "is_optional": " "}}},
  "_INVALIDATE_INSTANCE71": {"visibility": "O", "parameters": {"RC": {"type": () => {return new abap.types.Integer({qualifiedName: "SHM_RC"});}, "is_optional": " "}, "AREA_NAME": {"type": () => {return new abap.types.Character(30, {"qualifiedName":"SHM_AREA_NAME","ddicName":"SHM_AREA_NAME","description":"SHM_AREA_NAME"});}, "is_optional": " "}, "INST_NAME": {"type": () => {return new abap.types.Character(80, {"qualifiedName":"SHM_INST_NAME","ddicName":"SHM_INST_NAME","description":"SHM_INST_NAME"});}, "is_optional": " "}, "CLIENT": {"type": () => {return new abap.types.Character(3, {"qualifiedName":"SHM_CLIENT","ddicName":"SHM_CLIENT","description":"SHMA_CLIENT"});}, "is_optional": " "}, "CLIENT_SUPPLIED": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});}, "is_optional": " "}, "TRANSACTIONAL": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});}, "is_optional": " "}, "CLIENT_DEPENDENT": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});}, "is_optional": " "}, "TERMINATE_CHANGER": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});}, "is_optional": " "}, "AFFECT_SERVER": {"type": () => {return new abap.types.Integer({qualifiedName: "SHM_AFFECT_SERVER"});}, "is_optional": " "}, "LIFE_CONTEXT": {"type": () => {return new abap.types.Integer({qualifiedName: "SHM_LIFE_CONTEXT"});}, "is_optional": " "}}},
  "_SET_ROOT": {"visibility": "O", "parameters": {"ROOT": {"type": () => {return new abap.types.ABAPObject({qualifiedName: undefined, RTTIName: undefined});}, "is_optional": " "}}},
  "_DETACH_AREA71": {"visibility": "O", "parameters": {"RC": {"type": () => {return new abap.types.Integer({qualifiedName: "SHM_RC"});}, "is_optional": " "}, "AREA_NAME": {"type": () => {return new abap.types.Character(30, {"qualifiedName":"SHM_AREA_NAME","ddicName":"SHM_AREA_NAME","description":"SHM_AREA_NAME"});}, "is_optional": " "}, "CLIENT": {"type": () => {return new abap.types.Character(3, {"qualifiedName":"SHM_CLIENT","ddicName":"SHM_CLIENT","description":"SHMA_CLIENT"});}, "is_optional": " "}, "CLIENT_SUPPLIED": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});}, "is_optional": " "}, "CLIENT_DEPENDENT": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});}, "is_optional": " "}, "LIFE_CONTEXT": {"type": () => {return new abap.types.Integer({qualifiedName: "SHM_LIFE_CONTEXT"});}, "is_optional": " "}}},
  "_FREE_AREA71": {"visibility": "O", "parameters": {"RC": {"type": () => {return new abap.types.Integer({qualifiedName: "SHM_RC"});}, "is_optional": " "}, "AREA_NAME": {"type": () => {return new abap.types.Character(30, {"qualifiedName":"SHM_AREA_NAME","ddicName":"SHM_AREA_NAME","description":"SHM_AREA_NAME"});}, "is_optional": " "}, "CLIENT": {"type": () => {return new abap.types.Character(3, {"qualifiedName":"SHM_CLIENT","ddicName":"SHM_CLIENT","description":"SHMA_CLIENT"});}, "is_optional": " "}, "CLIENT_SUPPLIED": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});}, "is_optional": " "}, "TRANSACTIONAL": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});}, "is_optional": " "}, "CLIENT_DEPENDENT": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});}, "is_optional": " "}, "TERMINATE_CHANGER": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});}, "is_optional": " "}, "AFFECT_SERVER": {"type": () => {return new abap.types.Integer({qualifiedName: "SHM_AFFECT_SERVER"});}, "is_optional": " "}, "LIFE_CONTEXT": {"type": () => {return new abap.types.Integer({qualifiedName: "SHM_LIFE_CONTEXT"});}, "is_optional": " "}}},
  "_GET_INSTANCE_INFOS71": {"visibility": "O", "parameters": {"INFOS": {"type": () => {return abap.types.TableFactory.construct(new abap.types.Structure({"client": new abap.types.Character(3, {"qualifiedName":"MANDT","ddicName":"MANDT","description":"MANDT"}), "name": new abap.types.Character(80, {"qualifiedName":"SHM_INST_NAME","ddicName":"SHM_INST_NAME","description":"SHM_INST_NAME"})}, "SHM_INST_INFO", "SHM_INST_INFO", {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"isUnique":false,"type":"STANDARD","keyFields":[],"name":"primary_key"},"secondary":[]}, "SHM_INST_INFOS");}, "is_optional": " "}, "AREA_NAME": {"type": () => {return new abap.types.Character(30, {"qualifiedName":"SHM_AREA_NAME","ddicName":"SHM_AREA_NAME","description":"SHM_AREA_NAME"});}, "is_optional": " "}, "CLIENT": {"type": () => {return new abap.types.Character(3, {"qualifiedName":"SHM_CLIENT","ddicName":"SHM_CLIENT","description":"SHMA_CLIENT"});}, "is_optional": " "}, "CLIENT_SUPPLIED": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});}, "is_optional": " "}, "CLIENT_DEPENDENT": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});}, "is_optional": " "}, "LIFE_CONTEXT": {"type": () => {return new abap.types.Integer({qualifiedName: "SHM_LIFE_CONTEXT"});}, "is_optional": " "}}},
  "_FREE_INSTANCE71": {"visibility": "O", "parameters": {"RC": {"type": () => {return new abap.types.Integer({qualifiedName: "SHM_RC"});}, "is_optional": " "}, "AREA_NAME": {"type": () => {return new abap.types.Character(30, {"qualifiedName":"SHM_AREA_NAME","ddicName":"SHM_AREA_NAME","description":"SHM_AREA_NAME"});}, "is_optional": " "}, "INST_NAME": {"type": () => {return new abap.types.Character(80, {"qualifiedName":"SHM_INST_NAME","ddicName":"SHM_INST_NAME","description":"SHM_INST_NAME"});}, "is_optional": " "}, "CLIENT": {"type": () => {return new abap.types.Character(3, {"qualifiedName":"SHM_CLIENT","ddicName":"SHM_CLIENT","description":"SHMA_CLIENT"});}, "is_optional": " "}, "CLIENT_SUPPLIED": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});}, "is_optional": " "}, "TRANSACTIONAL": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});}, "is_optional": " "}, "CLIENT_DEPENDENT": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});}, "is_optional": " "}, "TERMINATE_CHANGER": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});}, "is_optional": " "}, "AFFECT_SERVER": {"type": () => {return new abap.types.Integer({qualifiedName: "SHM_AFFECT_SERVER"});}, "is_optional": " "}, "LIFE_CONTEXT": {"type": () => {return new abap.types.Integer({qualifiedName: "SHM_LIFE_CONTEXT"});}, "is_optional": " "}}},
  "DETACH_COMMIT": {"visibility": "U", "parameters": {}},
  "DETACH": {"visibility": "U", "parameters": {}},
  "GET_ROOT": {"visibility": "U", "parameters": {"ROOT": {"type": () => {return new abap.types.ABAPObject({qualifiedName: undefined, RTTIName: undefined});}, "is_optional": " "}}},
  "IS_VALID": {"visibility": "U", "parameters": {"VALID": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});}, "is_optional": " "}}}};
  constructor() {
    super();
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
    this.mo_root = cl_shm_area.mo_root;
    this.properties = new abap.types.Structure({"auto_build": new abap.types.Character(1, {}), "has_versions": new abap.types.Character(1, {})}, "SHM_PROPERTIES", "SHM_PROPERTIES", {}, {});
    this.inst_name = new abap.types.Character(80, {"qualifiedName":"SHM_INST_NAME","ddicName":"SHM_INST_NAME","description":"SHM_INST_NAME"});
    this.client = new abap.types.Character(3, {"qualifiedName":"MANDT","ddicName":"MANDT","description":"MANDT"});
    this.inst_trace_active = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    this.inst_trace_active.set(' ');
    this.inst_trace_service = new abap.types.ABAPObject({qualifiedName: "IF_SHM_TRACE", RTTIName: "\\INTERFACE=IF_SHM_TRACE"});
    this._lock = new abap.types.Hex({length: 8});
    this.default_instance = cl_shm_area.default_instance;
    this.invocation_mode_explicit = cl_shm_area.invocation_mode_explicit;
    this.life_context_appserver = cl_shm_area.life_context_appserver;
    this.attach_mode_default = cl_shm_area.attach_mode_default;
    this.attach_mode_wait = cl_shm_area.attach_mode_wait;
    this.affect_local_server = cl_shm_area.affect_local_server;
    this.attach_mode_wait_2nd_try = cl_shm_area.attach_mode_wait_2nd_try;
  }
  async constructor_(INPUT) {
    if (super.constructor_) { await super.constructor_(INPUT); }
    return this;
  }
  async is_valid() {
    let valid = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    valid.set(abap.builtin.abap_true);
    return valid;
  }
  async _free_instance71(INPUT) {
    return cl_shm_area._free_instance71(INPUT);
  }
  static async _free_instance71(INPUT) {
    let rc = new abap.types.Integer({qualifiedName: "SHM_RC"});
    let area_name = INPUT?.area_name;
    if (area_name?.getQualifiedName === undefined || area_name.getQualifiedName() !== "SHM_AREA_NAME") { area_name = undefined; }
    if (area_name === undefined) { area_name = new abap.types.Character(30, {"qualifiedName":"SHM_AREA_NAME","ddicName":"SHM_AREA_NAME","description":"SHM_AREA_NAME"}).set(INPUT.area_name); }
    let inst_name = INPUT?.inst_name;
    if (inst_name?.getQualifiedName === undefined || inst_name.getQualifiedName() !== "SHM_INST_NAME") { inst_name = undefined; }
    if (inst_name === undefined) { inst_name = new abap.types.Character(80, {"qualifiedName":"SHM_INST_NAME","ddicName":"SHM_INST_NAME","description":"SHM_INST_NAME"}).set(INPUT.inst_name); }
    let client = INPUT?.client;
    if (client?.getQualifiedName === undefined || client.getQualifiedName() !== "SHM_CLIENT") { client = undefined; }
    if (client === undefined) { client = new abap.types.Character(3, {"qualifiedName":"SHM_CLIENT","ddicName":"SHM_CLIENT","description":"SHMA_CLIENT"}).set(INPUT.client); }
    let client_supplied = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    if (INPUT && INPUT.client_supplied) {client_supplied.set(INPUT.client_supplied);}
    if (INPUT === undefined || INPUT.client_supplied === undefined) {client_supplied = abap.builtin.abap_false;}
    let transactional = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    if (INPUT && INPUT.transactional) {transactional.set(INPUT.transactional);}
    if (INPUT === undefined || INPUT.transactional === undefined) {transactional = abap.builtin.abap_false;}
    let client_dependent = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    if (INPUT && INPUT.client_dependent) {client_dependent.set(INPUT.client_dependent);}
    if (INPUT === undefined || INPUT.client_dependent === undefined) {client_dependent = abap.builtin.abap_false;}
    let terminate_changer = INPUT?.terminate_changer;
    if (terminate_changer?.getQualifiedName === undefined || terminate_changer.getQualifiedName() !== "ABAP_BOOL") { terminate_changer = undefined; }
    if (terminate_changer === undefined) { terminate_changer = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}).set(INPUT.terminate_changer); }
    let affect_server = INPUT?.affect_server;
    if (affect_server?.getQualifiedName === undefined || affect_server.getQualifiedName() !== "SHM_AFFECT_SERVER") { affect_server = undefined; }
    if (affect_server === undefined) { affect_server = new abap.types.Integer({qualifiedName: "SHM_AFFECT_SERVER"}).set(INPUT.affect_server); }
    let life_context = new abap.types.Integer({qualifiedName: "SHM_LIFE_CONTEXT"});
    if (INPUT && INPUT.life_context) {life_context.set(INPUT.life_context);}
    if (INPUT === undefined || INPUT.life_context === undefined) {life_context = this.life_context_appserver;}
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return rc;
  }
  async detach_commit() {
    return;
  }
  async detach() {
    return;
  }
  async _attach_read71(INPUT) {
    let sneak_mode = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    if (INPUT && INPUT.sneak_mode) {sneak_mode.set(INPUT.sneak_mode);}
    if (INPUT === undefined || INPUT.sneak_mode === undefined) {sneak_mode = abap.builtin.abap_false;}
    let area_name = INPUT?.area_name;
    if (area_name?.getQualifiedName === undefined || area_name.getQualifiedName() !== "SHM_AREA_NAME") { area_name = undefined; }
    if (area_name === undefined) { area_name = new abap.types.Character(30, {"qualifiedName":"SHM_AREA_NAME","ddicName":"SHM_AREA_NAME","description":"SHM_AREA_NAME"}).set(INPUT.area_name); }
    let life_context = INPUT?.life_context;
    if (life_context?.getQualifiedName === undefined || life_context.getQualifiedName() !== "SHM_LIFE_CONTEXT") { life_context = undefined; }
    if (life_context === undefined) { life_context = new abap.types.Integer({qualifiedName: "SHM_LIFE_CONTEXT"}).set(INPUT.life_context); }
    let root = INPUT?.root || new abap.types.ABAPObject({qualifiedName: undefined, RTTIName: undefined});
    let created = new abap.types.ABAPObject({qualifiedName: undefined, RTTIName: undefined});
    let lv_name = new abap.types.String({qualifiedName: "STRING"});
    if (abap.compare.eq(sneak_mode, abap.builtin.abap_false) && abap.compare.initial(cl_shm_area.mo_root)) {
      lv_name.set(area_name);
      abap.statements.replace({target: lv_name, all: false, with: new abap.types.Character(5).set('_ROOT'), of: new abap.types.Character(5).set('_AREA')});
      let unique135 = abap.Classes["CLAS-CL_SHM_AREA-"+lv_name.get().trimEnd()];
      if (unique135 === undefined) { unique135 = abap.Classes[lv_name.get().trimEnd()]; }
      if (unique135 === undefined) { throw new abap.Classes['CX_SY_CREATE_OBJECT_ERROR']; }
      created.set(await (new unique135()).constructor_());
      await this._set_root({root: created});
    }
    root.set(cl_shm_area.mo_root);
  }
  async _get_instance_infos71(INPUT) {
    return cl_shm_area._get_instance_infos71(INPUT);
  }
  static async _get_instance_infos71(INPUT) {
    let infos = abap.types.TableFactory.construct(new abap.types.Structure({"client": new abap.types.Character(3, {"qualifiedName":"MANDT","ddicName":"MANDT","description":"MANDT"}), "name": new abap.types.Character(80, {"qualifiedName":"SHM_INST_NAME","ddicName":"SHM_INST_NAME","description":"SHM_INST_NAME"})}, "SHM_INST_INFO", "SHM_INST_INFO", {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"isUnique":false,"type":"STANDARD","keyFields":[],"name":"primary_key"},"secondary":[]}, "SHM_INST_INFOS");
    let area_name = INPUT?.area_name;
    if (area_name?.getQualifiedName === undefined || area_name.getQualifiedName() !== "SHM_AREA_NAME") { area_name = undefined; }
    if (area_name === undefined) { area_name = new abap.types.Character(30, {"qualifiedName":"SHM_AREA_NAME","ddicName":"SHM_AREA_NAME","description":"SHM_AREA_NAME"}).set(INPUT.area_name); }
    let client = INPUT?.client;
    if (client?.getQualifiedName === undefined || client.getQualifiedName() !== "SHM_CLIENT") { client = undefined; }
    if (client === undefined) { client = new abap.types.Character(3, {"qualifiedName":"SHM_CLIENT","ddicName":"SHM_CLIENT","description":"SHMA_CLIENT"}).set(INPUT.client); }
    let client_supplied = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    if (INPUT && INPUT.client_supplied) {client_supplied.set(INPUT.client_supplied);}
    if (INPUT === undefined || INPUT.client_supplied === undefined) {client_supplied = abap.builtin.abap_false;}
    let client_dependent = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    if (INPUT && INPUT.client_dependent) {client_dependent.set(INPUT.client_dependent);}
    if (INPUT === undefined || INPUT.client_dependent === undefined) {client_dependent = abap.builtin.abap_false;}
    let life_context = INPUT?.life_context;
    if (life_context?.getQualifiedName === undefined || life_context.getQualifiedName() !== "SHM_LIFE_CONTEXT") { life_context = undefined; }
    if (life_context === undefined) { life_context = new abap.types.Integer({qualifiedName: "SHM_LIFE_CONTEXT"}).set(INPUT.life_context); }
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return infos;
  }
  async _detach_area71(INPUT) {
    return cl_shm_area._detach_area71(INPUT);
  }
  static async _detach_area71(INPUT) {
    let rc = new abap.types.Integer({qualifiedName: "SHM_RC"});
    let area_name = INPUT?.area_name;
    if (area_name?.getQualifiedName === undefined || area_name.getQualifiedName() !== "SHM_AREA_NAME") { area_name = undefined; }
    if (area_name === undefined) { area_name = new abap.types.Character(30, {"qualifiedName":"SHM_AREA_NAME","ddicName":"SHM_AREA_NAME","description":"SHM_AREA_NAME"}).set(INPUT.area_name); }
    let client = INPUT?.client;
    if (client?.getQualifiedName === undefined || client.getQualifiedName() !== "SHM_CLIENT") { client = undefined; }
    if (client === undefined) { client = new abap.types.Character(3, {"qualifiedName":"SHM_CLIENT","ddicName":"SHM_CLIENT","description":"SHMA_CLIENT"}).set(INPUT.client); }
    let client_supplied = INPUT?.client_supplied;
    if (client_supplied?.getQualifiedName === undefined || client_supplied.getQualifiedName() !== "ABAP_BOOL") { client_supplied = undefined; }
    if (client_supplied === undefined) { client_supplied = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}).set(INPUT.client_supplied); }
    let client_dependent = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    if (INPUT && INPUT.client_dependent) {client_dependent.set(INPUT.client_dependent);}
    if (INPUT === undefined || INPUT.client_dependent === undefined) {client_dependent = abap.builtin.abap_false;}
    let life_context = INPUT?.life_context;
    if (life_context?.getQualifiedName === undefined || life_context.getQualifiedName() !== "SHM_LIFE_CONTEXT") { life_context = undefined; }
    if (life_context === undefined) { life_context = new abap.types.Integer({qualifiedName: "SHM_LIFE_CONTEXT"}).set(INPUT.life_context); }
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return rc;
  }
  async _free_area71(INPUT) {
    return cl_shm_area._free_area71(INPUT);
  }
  static async _free_area71(INPUT) {
    let rc = new abap.types.Integer({qualifiedName: "SHM_RC"});
    let area_name = INPUT?.area_name;
    if (area_name?.getQualifiedName === undefined || area_name.getQualifiedName() !== "SHM_AREA_NAME") { area_name = undefined; }
    if (area_name === undefined) { area_name = new abap.types.Character(30, {"qualifiedName":"SHM_AREA_NAME","ddicName":"SHM_AREA_NAME","description":"SHM_AREA_NAME"}).set(INPUT.area_name); }
    let client = INPUT?.client;
    if (client?.getQualifiedName === undefined || client.getQualifiedName() !== "SHM_CLIENT") { client = undefined; }
    if (client === undefined) { client = new abap.types.Character(3, {"qualifiedName":"SHM_CLIENT","ddicName":"SHM_CLIENT","description":"SHMA_CLIENT"}).set(INPUT.client); }
    let client_supplied = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    if (INPUT && INPUT.client_supplied) {client_supplied.set(INPUT.client_supplied);}
    if (INPUT === undefined || INPUT.client_supplied === undefined) {client_supplied = abap.builtin.abap_false;}
    let transactional = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    if (INPUT && INPUT.transactional) {transactional.set(INPUT.transactional);}
    if (INPUT === undefined || INPUT.transactional === undefined) {transactional = abap.builtin.abap_false;}
    let client_dependent = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    if (INPUT && INPUT.client_dependent) {client_dependent.set(INPUT.client_dependent);}
    if (INPUT === undefined || INPUT.client_dependent === undefined) {client_dependent = abap.builtin.abap_false;}
    let terminate_changer = INPUT?.terminate_changer;
    if (terminate_changer?.getQualifiedName === undefined || terminate_changer.getQualifiedName() !== "ABAP_BOOL") { terminate_changer = undefined; }
    if (terminate_changer === undefined) { terminate_changer = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}).set(INPUT.terminate_changer); }
    let affect_server = INPUT?.affect_server;
    if (affect_server?.getQualifiedName === undefined || affect_server.getQualifiedName() !== "SHM_AFFECT_SERVER") { affect_server = undefined; }
    if (affect_server === undefined) { affect_server = new abap.types.Integer({qualifiedName: "SHM_AFFECT_SERVER"}).set(INPUT.affect_server); }
    let life_context = new abap.types.Integer({qualifiedName: "SHM_LIFE_CONTEXT"});
    if (INPUT && INPUT.life_context) {life_context.set(INPUT.life_context);}
    if (INPUT === undefined || INPUT.life_context === undefined) {life_context = this.life_context_appserver;}
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return rc;
  }
  async _set_root(INPUT) {
    let root = INPUT?.root;
    if (root === undefined) { root = new abap.types.ABAPObject({qualifiedName: undefined, RTTIName: undefined}).set(INPUT.root); }
    cl_shm_area.mo_root.set(root);
  }
  async _invalidate_instance71(INPUT) {
    return cl_shm_area._invalidate_instance71(INPUT);
  }
  static async _invalidate_instance71(INPUT) {
    let rc = new abap.types.Integer({qualifiedName: "SHM_RC"});
    let area_name = INPUT?.area_name;
    if (area_name?.getQualifiedName === undefined || area_name.getQualifiedName() !== "SHM_AREA_NAME") { area_name = undefined; }
    if (area_name === undefined) { area_name = new abap.types.Character(30, {"qualifiedName":"SHM_AREA_NAME","ddicName":"SHM_AREA_NAME","description":"SHM_AREA_NAME"}).set(INPUT.area_name); }
    let inst_name = INPUT?.inst_name;
    if (inst_name?.getQualifiedName === undefined || inst_name.getQualifiedName() !== "SHM_INST_NAME") { inst_name = undefined; }
    if (inst_name === undefined) { inst_name = new abap.types.Character(80, {"qualifiedName":"SHM_INST_NAME","ddicName":"SHM_INST_NAME","description":"SHM_INST_NAME"}).set(INPUT.inst_name); }
    let client = INPUT?.client;
    if (client?.getQualifiedName === undefined || client.getQualifiedName() !== "SHM_CLIENT") { client = undefined; }
    if (client === undefined) { client = new abap.types.Character(3, {"qualifiedName":"SHM_CLIENT","ddicName":"SHM_CLIENT","description":"SHMA_CLIENT"}).set(INPUT.client); }
    let client_supplied = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    if (INPUT && INPUT.client_supplied) {client_supplied.set(INPUT.client_supplied);}
    if (INPUT === undefined || INPUT.client_supplied === undefined) {client_supplied = abap.builtin.abap_false;}
    let transactional = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    if (INPUT && INPUT.transactional) {transactional.set(INPUT.transactional);}
    if (INPUT === undefined || INPUT.transactional === undefined) {transactional = abap.builtin.abap_false;}
    let client_dependent = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    if (INPUT && INPUT.client_dependent) {client_dependent.set(INPUT.client_dependent);}
    if (INPUT === undefined || INPUT.client_dependent === undefined) {client_dependent = abap.builtin.abap_false;}
    let terminate_changer = INPUT?.terminate_changer;
    if (terminate_changer?.getQualifiedName === undefined || terminate_changer.getQualifiedName() !== "ABAP_BOOL") { terminate_changer = undefined; }
    if (terminate_changer === undefined) { terminate_changer = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}).set(INPUT.terminate_changer); }
    let affect_server = INPUT?.affect_server;
    if (affect_server?.getQualifiedName === undefined || affect_server.getQualifiedName() !== "SHM_AFFECT_SERVER") { affect_server = undefined; }
    if (affect_server === undefined) { affect_server = new abap.types.Integer({qualifiedName: "SHM_AFFECT_SERVER"}).set(INPUT.affect_server); }
    let life_context = new abap.types.Integer({qualifiedName: "SHM_LIFE_CONTEXT"});
    if (INPUT && INPUT.life_context) {life_context.set(INPUT.life_context);}
    if (INPUT === undefined || INPUT.life_context === undefined) {life_context = this.life_context_appserver;}
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return rc;
  }
  async _invalidate_area71(INPUT) {
    return cl_shm_area._invalidate_area71(INPUT);
  }
  static async _invalidate_area71(INPUT) {
    let rc = new abap.types.Integer({qualifiedName: "SHM_RC"});
    let area_name = INPUT?.area_name;
    if (area_name?.getQualifiedName === undefined || area_name.getQualifiedName() !== "SHM_AREA_NAME") { area_name = undefined; }
    if (area_name === undefined) { area_name = new abap.types.Character(30, {"qualifiedName":"SHM_AREA_NAME","ddicName":"SHM_AREA_NAME","description":"SHM_AREA_NAME"}).set(INPUT.area_name); }
    let client = INPUT?.client;
    if (client?.getQualifiedName === undefined || client.getQualifiedName() !== "SHM_CLIENT") { client = undefined; }
    if (client === undefined) { client = new abap.types.Character(3, {"qualifiedName":"SHM_CLIENT","ddicName":"SHM_CLIENT","description":"SHMA_CLIENT"}).set(INPUT.client); }
    let client_supplied = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    if (INPUT && INPUT.client_supplied) {client_supplied.set(INPUT.client_supplied);}
    if (INPUT === undefined || INPUT.client_supplied === undefined) {client_supplied = abap.builtin.abap_false;}
    let transactional = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    if (INPUT && INPUT.transactional) {transactional.set(INPUT.transactional);}
    if (INPUT === undefined || INPUT.transactional === undefined) {transactional = abap.builtin.abap_false;}
    let client_dependent = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    if (INPUT && INPUT.client_dependent) {client_dependent.set(INPUT.client_dependent);}
    if (INPUT === undefined || INPUT.client_dependent === undefined) {client_dependent = abap.builtin.abap_false;}
    let terminate_changer = INPUT?.terminate_changer;
    if (terminate_changer?.getQualifiedName === undefined || terminate_changer.getQualifiedName() !== "ABAP_BOOL") { terminate_changer = undefined; }
    if (terminate_changer === undefined) { terminate_changer = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}).set(INPUT.terminate_changer); }
    let affect_server = INPUT?.affect_server;
    if (affect_server?.getQualifiedName === undefined || affect_server.getQualifiedName() !== "SHM_AFFECT_SERVER") { affect_server = undefined; }
    if (affect_server === undefined) { affect_server = new abap.types.Integer({qualifiedName: "SHM_AFFECT_SERVER"}).set(INPUT.affect_server); }
    let life_context = new abap.types.Integer({qualifiedName: "SHM_LIFE_CONTEXT"});
    if (INPUT && INPUT.life_context) {life_context.set(INPUT.life_context);}
    if (INPUT === undefined || INPUT.life_context === undefined) {life_context = this.life_context_appserver;}
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return rc;
  }
  async _attach_update70(INPUT) {
    let area_name = INPUT?.area_name;
    if (area_name?.getQualifiedName === undefined || area_name.getQualifiedName() !== "SHM_AREA_NAME") { area_name = undefined; }
    if (area_name === undefined) { area_name = new abap.types.Character(30, {"qualifiedName":"SHM_AREA_NAME","ddicName":"SHM_AREA_NAME","description":"SHM_AREA_NAME"}).set(INPUT.area_name); }
    let mode = INPUT?.mode;
    if (mode?.getQualifiedName === undefined || mode.getQualifiedName() !== "SHM_ATTACH_MODE") { mode = undefined; }
    if (mode === undefined) { mode = new abap.types.Integer({qualifiedName: "SHM_ATTACH_MODE"}).set(INPUT.mode); }
    let root = INPUT?.root || new abap.types.ABAPObject({qualifiedName: undefined, RTTIName: undefined});
    let wait_time = new abap.types.Integer({qualifiedName: "I"});
    if (INPUT && INPUT.wait_time) {wait_time = INPUT.wait_time;}
    let created = new abap.types.ABAPObject({qualifiedName: undefined, RTTIName: undefined});
    let lv_name = new abap.types.String({qualifiedName: "STRING"});
    if (abap.compare.initial(cl_shm_area.mo_root)) {
      abap.statements.replace({target: lv_name, all: false, with: new abap.types.Character(5).set('_ROOT'), of: new abap.types.Character(5).set('_AREA')});
      let unique136 = abap.Classes["CLAS-CL_SHM_AREA-"+lv_name.get().trimEnd()];
      if (unique136 === undefined) { unique136 = abap.Classes[lv_name.get().trimEnd()]; }
      if (unique136 === undefined) { throw new abap.Classes['CX_SY_CREATE_OBJECT_ERROR']; }
      created.set(await (new unique136()).constructor_());
      await this._set_root({root: created});
    }
    root.set(cl_shm_area.mo_root);
  }
  async _attach_write70(INPUT) {
    let area_name = INPUT?.area_name;
    if (area_name?.getQualifiedName === undefined || area_name.getQualifiedName() !== "SHM_AREA_NAME") { area_name = undefined; }
    if (area_name === undefined) { area_name = new abap.types.Character(30, {"qualifiedName":"SHM_AREA_NAME","ddicName":"SHM_AREA_NAME","description":"SHM_AREA_NAME"}).set(INPUT.area_name); }
    let mode = INPUT?.mode;
    if (mode?.getQualifiedName === undefined || mode.getQualifiedName() !== "SHM_ATTACH_MODE") { mode = undefined; }
    if (mode === undefined) { mode = new abap.types.Integer({qualifiedName: "SHM_ATTACH_MODE"}).set(INPUT.mode); }
    let root = INPUT?.root || new abap.types.ABAPObject({qualifiedName: undefined, RTTIName: undefined});
    let wait_time = new abap.types.Integer({qualifiedName: "I"});
    if (INPUT && INPUT.wait_time) {wait_time = INPUT.wait_time;}
    return;
  }
}
abap.Classes['CL_SHM_AREA'] = cl_shm_area;
cl_shm_area.mo_root = new abap.types.ABAPObject({qualifiedName: undefined, RTTIName: undefined});
cl_shm_area.default_instance = new abap.types.Character(80, {"qualifiedName":"SHM_INST_NAME","ddicName":"SHM_INST_NAME","description":"SHM_INST_NAME"});
cl_shm_area.default_instance.set('$DEFAULT_INSTANCE$');
cl_shm_area.invocation_mode_explicit = new abap.types.Integer({qualifiedName: "SHM_CONSTR_INVOCATION_MODE"});
cl_shm_area.invocation_mode_explicit.set(319200300);
cl_shm_area.life_context_appserver = new abap.types.Integer({qualifiedName: "SHM_LIFE_CONTEXT"});
cl_shm_area.life_context_appserver.set(109200001);
cl_shm_area.attach_mode_default = new abap.types.Integer({qualifiedName: "SHM_ATTACH_MODE"});
cl_shm_area.attach_mode_default.set(1302197000);
cl_shm_area.attach_mode_wait = new abap.types.Integer({qualifiedName: "SHM_ATTACH_MODE"});
cl_shm_area.attach_mode_wait.set(1302197002);
cl_shm_area.affect_local_server = new abap.types.Integer({qualifiedName: "SHM_AFFECT_SERVER"});
cl_shm_area.affect_local_server.set(281119720);
cl_shm_area.attach_mode_wait_2nd_try = new abap.types.Integer({qualifiedName: "SHM_ATTACH_MODE"});
cl_shm_area.attach_mode_wait_2nd_try.set(1302197003);
export {cl_shm_area};
//# sourceMappingURL=cl_shm_area.clas.mjs.map