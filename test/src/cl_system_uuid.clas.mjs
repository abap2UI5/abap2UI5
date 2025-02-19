const {cx_root} = await import("./cx_root.clas.mjs");
// cl_system_uuid.clas.abap
class cl_system_uuid {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CL_SYSTEM_UUID';
  static IMPLEMENTED_INTERFACES = ["IF_SYSTEM_UUID_RFC4122_STATIC","IF_SYSTEM_UUID_STATIC"];
  static ATTRIBUTES = {};
  static METHODS = {"RANDOM": {"visibility": "I", "parameters": {"RV_STR": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}}};
  constructor() {
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
    this.create_uuid_c32_static = this.if_system_uuid_static$create_uuid_c32;
    this.create_uuid_x16_static = this.if_system_uuid_static$create_uuid_x16;
  }
  async constructor_(INPUT) {
    if (super.constructor_) { await super.constructor_(INPUT); }
    return this;
  }
  async random() {
    return cl_system_uuid.random();
  }
  static async random() {
    let rv_str = new abap.types.String({qualifiedName: "STRING"});
    if (cl_system_uuid.CRYPTO === undefined) cl_system_uuid.CRYPTO = await import("crypto");
    if (cl_system_uuid.CRYPTO.randomUUID) {
        rv_str.set(cl_system_uuid.CRYPTO.randomUUID());
    } else {
        rv_str = window.crypto.randomUUID();
    }
    return rv_str;
  }
  async if_system_uuid_static$create_uuid_x16() {
    return cl_system_uuid.if_system_uuid_static$create_uuid_x16();
  }
  static async if_system_uuid_static$create_uuid_x16() {
    let uuid = new abap.types.Hex({length: 16});
    let lv_str = new abap.types.String({qualifiedName: "STRING"});
    lv_str.set((await this.random()));
    abap.statements.replace({target: lv_str, all: true, with: new abap.types.Character(1).set(''), of: new abap.types.Character(1).set('-')});
    abap.statements.translate(lv_str, "UPPER");
    uuid.set(lv_str.getOffset({length: 32}));
    return uuid;
  }
  async if_system_uuid_static$create_uuid_c32() {
    return cl_system_uuid.if_system_uuid_static$create_uuid_c32();
  }
  static async if_system_uuid_static$create_uuid_c32() {
    let uuid = new abap.types.Character(32, {"qualifiedName":"SYSUUID_C32","ddicName":"SYSUUID_C32","description":"UUID"});
    let lv_str = new abap.types.String({qualifiedName: "STRING"});
    lv_str.set((await this.random()));
    abap.statements.replace({target: lv_str, all: true, with: new abap.types.Character(1).set(''), of: new abap.types.Character(1).set('-')});
    uuid.set(lv_str.getOffset({length: 32}));
    abap.statements.translate(uuid, "UPPER");
    return uuid;
  }
  async if_system_uuid_rfc4122_static$create_uuid_c36_by_version(INPUT) {
    return cl_system_uuid.if_system_uuid_rfc4122_static$create_uuid_c36_by_version(INPUT);
  }
  static async if_system_uuid_rfc4122_static$create_uuid_c36_by_version(INPUT) {
    let uuid = new abap.types.Character(36, {"qualifiedName":"SYSUUID_C36","ddicName":"SYSUUID_C36","description":"SYSUUID_C36"});
    let version = INPUT?.version;
    if (version?.getQualifiedName === undefined || version.getQualifiedName() !== "I") { version = undefined; }
    if (version === undefined) { version = new abap.types.Integer({qualifiedName: "I"}).set(INPUT.version); }
    abap.statements.assert(abap.compare.eq(version, abap.IntegerFactory.get(4)));
    uuid.set((await this.random()));
    return uuid;
  }
  async if_system_uuid_static$create_uuid_c22() {
    return cl_system_uuid.if_system_uuid_static$create_uuid_c22();
  }
  static async if_system_uuid_static$create_uuid_c22() {
    let uuid = new abap.types.Character(22, {"qualifiedName":"SYSUUID_C22","ddicName":"SYSUUID_C22","description":"UUID"});
    let lv_str = new abap.types.String({qualifiedName: "STRING"});
    lv_str.set((await this.random()));
    abap.statements.replace({target: lv_str, all: true, with: new abap.types.Character(1).set(''), of: new abap.types.Character(1).set('-')});
    uuid.set(lv_str.getOffset({length: 22}));
    return uuid;
  }
}
abap.Classes['CL_SYSTEM_UUID'] = cl_system_uuid;
export {cl_system_uuid};
//# sourceMappingURL=cl_system_uuid.clas.mjs.map