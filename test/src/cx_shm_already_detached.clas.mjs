const {cx_shm_general_error} = await import("./cx_shm_general_error.clas.mjs");
const {cx_root} = await import("./cx_root.clas.mjs");
// cx_shm_already_detached.clas.abap
class cx_shm_already_detached extends cx_shm_general_error {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CX_SHM_ALREADY_DETACHED';
  static IMPLEMENTED_INTERFACES = ["IF_MESSAGE","IF_MESSAGE","IF_MESSAGE","IF_MESSAGE"];
  static ATTRIBUTES = {};
  static METHODS = {"CONSTRUCTOR": {"visibility": "U", "parameters": {"TEXTID": {"type": () => {return new abap.types.Character(32, {});}, "is_optional": " "}, "PREVIOUS": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "CX_ROOT", RTTIName: "\\CLASS=CX_ROOT"});}, "is_optional": " "}, "AREA_NAME": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "INST_NAME": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "CLIENT": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}}};
  constructor() {
    super();
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
  }
  async constructor_(INPUT) {
    let textid = new abap.types.Character(32, {});
    if (INPUT && INPUT.textid) {textid.set(INPUT.textid);}
    let previous = new abap.types.ABAPObject({qualifiedName: "CX_ROOT", RTTIName: "\\CLASS=CX_ROOT"});
    if (INPUT && INPUT.previous) {previous.set(INPUT.previous);}
    let area_name = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.area_name) {area_name.set(INPUT.area_name);}
    let inst_name = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.inst_name) {inst_name.set(INPUT.inst_name);}
    let client = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.client) {client.set(INPUT.client);}
    return this;
    return this;
  }
}
abap.Classes['CX_SHM_ALREADY_DETACHED'] = cx_shm_already_detached;
export {cx_shm_already_detached};
//# sourceMappingURL=cx_shm_already_detached.clas.mjs.map