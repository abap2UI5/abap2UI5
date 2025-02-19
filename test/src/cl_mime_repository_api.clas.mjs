const {cx_root} = await import("./cx_root.clas.mjs");
// cl_mime_repository_api.clas.abap
class cl_mime_repository_api {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CL_MIME_REPOSITORY_API';
  static IMPLEMENTED_INTERFACES = ["IF_MR_API"];
  static ATTRIBUTES = {};
  static METHODS = {};
  constructor() {
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
    this.get_api = this.if_mr_api$get_api;
  }
  async constructor_(INPUT) {
    if (super.constructor_) { await super.constructor_(INPUT); }
    return this;
  }
  async if_mr_api$get_by_io(INPUT) {
    let i_loio = INPUT?.i_loio;
    let i_check_authority = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    if (INPUT && INPUT.i_check_authority) {i_check_authority.set(INPUT.i_check_authority);}
    if (INPUT === undefined || INPUT.i_check_authority === undefined) {i_check_authority = abap.builtin.abap_true;}
    let e_is_folder = INPUT?.e_is_folder || new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    let e_content = INPUT?.e_content || new abap.types.XString({qualifiedName: "XSTRING"});
    let e_content_last_changed = INPUT?.e_content_last_changed || new abap.types.Character(4);
    let e_mime_type = INPUT?.e_mime_type || new abap.types.Character();
    let e_phio_id = INPUT?.e_phio_id || new abap.types.Character(4);
    let c_language = new abap.types.Character(1, {"qualifiedName":"SPRAS","ddicName":"SPRAS","description":"SPRAS"});
    if (INPUT && INPUT.c_language) {c_language = INPUT.c_language;}
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
  }
  async if_mr_api$get_url_for_io(INPUT) {
    let i_loio = INPUT?.i_loio;
    let e_url = INPUT?.e_url || new abap.types.String({qualifiedName: "STRING"});
    let e_is_folder = INPUT?.e_is_folder || new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
  }
  async if_mr_api$get_api(INPUT) {
    return cl_mime_repository_api.if_mr_api$get_api(INPUT);
  }
  static async if_mr_api$get_api(INPUT) {
    let r_mr_api = new abap.types.ABAPObject({qualifiedName: "IF_MR_API", RTTIName: "\\INTERFACE=IF_MR_API"});
    let i_prefix = INPUT?.i_prefix || new abap.types.Character();
    if (INPUT === undefined || INPUT.i_prefix === undefined) {i_prefix = abap.builtin.space;}
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return r_mr_api;
  }
  async if_mr_api$get(INPUT) {
    let i_url = INPUT?.i_url;
    let i_check_authority = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    if (INPUT && INPUT.i_check_authority) {i_check_authority.set(INPUT.i_check_authority);}
    if (INPUT === undefined || INPUT.i_check_authority === undefined) {i_check_authority = abap.builtin.abap_true;}
    let e_is_folder = INPUT?.e_is_folder || new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    let e_content = INPUT?.e_content || new abap.types.XString({qualifiedName: "XSTRING"});
    let e_mime_type = INPUT?.e_mime_type || new abap.types.Character();
    let e_loio = INPUT?.e_loio || new abap.types.Structure({"objtype": new abap.types.Character(1, {"qualifiedName":"SKWF_IOTY","ddicName":"SKWF_IOTY","description":"SKWF_IOTY"}), "object": new abap.types.Structure({"class": new abap.types.Character(10, {"qualifiedName":"SDOK_CLASS","ddicName":"SDOK_CLASS","description":"SDOK_CLASS"}), "objid": new abap.types.Character(32, {"qualifiedName":"SDOK_DOCID","ddicName":"SDOK_DOCID","description":"SDOK_DOCID"})}, "SDOKOBJECT", "SDOKOBJECT", {}, {}), "class": new abap.types.Character(10, {"qualifiedName":"SDOK_CLASS","ddicName":"SDOK_CLASS","description":"SDOK_CLASS"}), "objid": new abap.types.Character(32, {"qualifiedName":"SDOK_DOCID","ddicName":"SDOK_DOCID","description":"SDOK_DOCID"})}, "SKWF_IO", "SKWF_IO", {}, {});
    let e_content_last_changed = INPUT?.e_content_last_changed || new abap.types.Character(4);
    let c_language = new abap.types.Character(1, {"qualifiedName":"LANGU","ddicName":"LANGU","description":"LANGU"});
    if (INPUT && INPUT.c_language) {c_language = INPUT.c_language;}
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
  }
  async if_mr_api$create_folder(INPUT) {
    let i_url = INPUT?.i_url;
    let i_language = new abap.types.Character(1, {"qualifiedName":"LANGU","ddicName":"LANGU","description":"LANGU"});
    if (INPUT && INPUT.i_language) {i_language.set(INPUT.i_language);}
    if (INPUT === undefined || INPUT.i_language === undefined) {i_language = abap.builtin.sy.get().langu;}
    let i_description = INPUT?.i_description || new abap.types.Character();
    let i_check_authority = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    if (INPUT && INPUT.i_check_authority) {i_check_authority.set(INPUT.i_check_authority);}
    if (INPUT === undefined || INPUT.i_check_authority === undefined) {i_check_authority = abap.builtin.abap_true;}
    let i_suppress_package_dialog = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    if (INPUT && INPUT.i_suppress_package_dialog) {i_suppress_package_dialog.set(INPUT.i_suppress_package_dialog);}
    if (INPUT === undefined || INPUT.i_suppress_package_dialog === undefined) {i_suppress_package_dialog = abap.builtin.space;}
    let i_dev_package = new abap.types.Character(30, {"qualifiedName":"DEVCLASS","ddicName":"DEVCLASS","description":"DEVCLASS"});
    if (INPUT && INPUT.i_dev_package) {i_dev_package.set(INPUT.i_dev_package);}
    let i_genflag = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    if (INPUT && INPUT.i_genflag) {i_genflag.set(INPUT.i_genflag);}
    if (INPUT === undefined || INPUT.i_genflag === undefined) {i_genflag = abap.builtin.abap_false;}
    let i_corr_number = new abap.types.Character(20, {"qualifiedName":"TRKORR","ddicName":"TRKORR","description":"TRKORR"});
    if (INPUT && INPUT.i_corr_number) {i_corr_number.set(INPUT.i_corr_number);}
    let i_folder_loio = INPUT?.i_folder_loio || new abap.types.Character(4);
    let i_suppress_dialogs = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    if (INPUT && INPUT.i_suppress_dialogs) {i_suppress_dialogs.set(INPUT.i_suppress_dialogs);}
    let i_folder_role = INPUT?.i_folder_role || new abap.types.Character(4);
    let i_new_folder_role_description = INPUT?.i_new_folder_role_description || new abap.types.Character(4);
    let e_folder_io = INPUT?.e_folder_io || new abap.types.Structure({"objtype": new abap.types.Character(1, {"qualifiedName":"SKWF_IOTY","ddicName":"SKWF_IOTY","description":"SKWF_IOTY"}), "object": new abap.types.Structure({"class": new abap.types.Character(10, {"qualifiedName":"SDOK_CLASS","ddicName":"SDOK_CLASS","description":"SDOK_CLASS"}), "objid": new abap.types.Character(32, {"qualifiedName":"SDOK_DOCID","ddicName":"SDOK_DOCID","description":"SDOK_DOCID"})}, "SDOKOBJECT", "SDOKOBJECT", {}, {}), "class": new abap.types.Character(10, {"qualifiedName":"SDOK_CLASS","ddicName":"SDOK_CLASS","description":"SDOK_CLASS"}), "objid": new abap.types.Character(32, {"qualifiedName":"SDOK_DOCID","ddicName":"SDOK_DOCID","description":"SDOK_DOCID"})}, "SKWF_IO", "SKWF_IO", {}, {});
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
  }
  async if_mr_api$put(INPUT) {
    let i_url = INPUT?.i_url;
    let i_content = INPUT?.i_content;
    if (i_content?.getQualifiedName === undefined || i_content.getQualifiedName() !== "XSTRING") { i_content = undefined; }
    if (i_content === undefined) { i_content = new abap.types.XString({qualifiedName: "XSTRING"}).set(INPUT.i_content); }
    let i_language = new abap.types.Character(1, {"qualifiedName":"LANGU","ddicName":"LANGU","description":"LANGU"});
    if (INPUT && INPUT.i_language) {i_language.set(INPUT.i_language);}
    if (INPUT === undefined || INPUT.i_language === undefined) {i_language = abap.builtin.sy.get().langu;}
    let i_description = INPUT?.i_description || new abap.types.Character();
    let i_check_authority = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    if (INPUT && INPUT.i_check_authority) {i_check_authority.set(INPUT.i_check_authority);}
    if (INPUT === undefined || INPUT.i_check_authority === undefined) {i_check_authority = abap.builtin.abap_true;}
    let i_suppress_package_dialog = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    if (INPUT && INPUT.i_suppress_package_dialog) {i_suppress_package_dialog.set(INPUT.i_suppress_package_dialog);}
    if (INPUT === undefined || INPUT.i_suppress_package_dialog === undefined) {i_suppress_package_dialog = abap.builtin.space;}
    let i_dev_package = new abap.types.Character(30, {"qualifiedName":"DEVCLASS","ddicName":"DEVCLASS","description":"DEVCLASS"});
    if (INPUT && INPUT.i_dev_package) {i_dev_package.set(INPUT.i_dev_package);}
    let i_genflag = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    if (INPUT && INPUT.i_genflag) {i_genflag.set(INPUT.i_genflag);}
    if (INPUT === undefined || INPUT.i_genflag === undefined) {i_genflag = abap.builtin.abap_false;}
    let i_corr_number = new abap.types.Character(20, {"qualifiedName":"TRKORR","ddicName":"TRKORR","description":"TRKORR"});
    if (INPUT && INPUT.i_corr_number) {i_corr_number.set(INPUT.i_corr_number);}
    let i_new_loio = INPUT?.i_new_loio || new abap.types.Character(4);
    let i_virus_profile = INPUT?.i_virus_profile || new abap.types.Character(4);
    let i_suppress_dialogs = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    if (INPUT && INPUT.i_suppress_dialogs) {i_suppress_dialogs.set(INPUT.i_suppress_dialogs);}
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
  }
  async if_mr_api$delete(INPUT) {
    let i_url = INPUT?.i_url;
    let i_delete_children = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    if (INPUT && INPUT.i_delete_children) {i_delete_children.set(INPUT.i_delete_children);}
    if (INPUT === undefined || INPUT.i_delete_children === undefined) {i_delete_children = abap.builtin.abap_false;}
    let i_check_authority = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    if (INPUT && INPUT.i_check_authority) {i_check_authority.set(INPUT.i_check_authority);}
    if (INPUT === undefined || INPUT.i_check_authority === undefined) {i_check_authority = abap.builtin.abap_true;}
    let i_corr_number = new abap.types.Character(20, {"qualifiedName":"TRKORR","ddicName":"TRKORR","description":"TRKORR"});
    if (INPUT && INPUT.i_corr_number) {i_corr_number.set(INPUT.i_corr_number);}
    let i_suppress_dialogs = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    if (INPUT && INPUT.i_suppress_dialogs) {i_suppress_dialogs.set(INPUT.i_suppress_dialogs);}
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
  }
  async if_mr_api$file_list(INPUT) {
    let i_url = INPUT?.i_url;
    let i_recursive_call = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    if (INPUT && INPUT.i_recursive_call) {i_recursive_call.set(INPUT.i_recursive_call);}
    if (INPUT === undefined || INPUT.i_recursive_call === undefined) {i_recursive_call = abap.builtin.abap_false;}
    let i_check_authority = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    if (INPUT && INPUT.i_check_authority) {i_check_authority.set(INPUT.i_check_authority);}
    if (INPUT === undefined || INPUT.i_check_authority === undefined) {i_check_authority = abap.builtin.abap_true;}
    let e_files = INPUT?.e_files || abap.types.TableFactory.construct(new abap.types.String({qualifiedName: "STRING"}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"isUnique":false,"type":"STANDARD","keyFields":[],"name":"primary_key"},"secondary":[]}, "STRING_TABLE");
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
  }
  async if_mr_api$properties(INPUT) {
    let i_url = INPUT?.i_url;
    let i_check_authority = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    if (INPUT && INPUT.i_check_authority) {i_check_authority.set(INPUT.i_check_authority);}
    if (INPUT === undefined || INPUT.i_check_authority === undefined) {i_check_authority = abap.builtin.abap_true;}
    let e_is_folder = INPUT?.e_is_folder || new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    let e_mime_type = INPUT?.e_mime_type || new abap.types.Character();
    let e_name = INPUT?.e_name || new abap.types.String({qualifiedName: "STRING"});
    let e_size = INPUT?.e_size || new abap.types.Integer({qualifiedName: "I"});
    let e_bin_data = INPUT?.e_bin_data || new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    let e_loio = INPUT?.e_loio || new abap.types.Structure({"objtype": new abap.types.Character(1, {"qualifiedName":"SKWF_IOTY","ddicName":"SKWF_IOTY","description":"SKWF_IOTY"}), "object": new abap.types.Structure({"class": new abap.types.Character(10, {"qualifiedName":"SDOK_CLASS","ddicName":"SDOK_CLASS","description":"SDOK_CLASS"}), "objid": new abap.types.Character(32, {"qualifiedName":"SDOK_DOCID","ddicName":"SDOK_DOCID","description":"SDOK_DOCID"})}, "SDOKOBJECT", "SDOKOBJECT", {}, {}), "class": new abap.types.Character(10, {"qualifiedName":"SDOK_CLASS","ddicName":"SDOK_CLASS","description":"SDOK_CLASS"}), "objid": new abap.types.Character(32, {"qualifiedName":"SDOK_DOCID","ddicName":"SDOK_DOCID","description":"SDOK_DOCID"})}, "SKWF_IO", "SKWF_IO", {}, {});
    let e_phio = INPUT?.e_phio || new abap.types.Structure({"objtype": new abap.types.Character(1, {"qualifiedName":"SKWF_IOTY","ddicName":"SKWF_IOTY","description":"SKWF_IOTY"}), "object": new abap.types.Structure({"class": new abap.types.Character(10, {"qualifiedName":"SDOK_CLASS","ddicName":"SDOK_CLASS","description":"SDOK_CLASS"}), "objid": new abap.types.Character(32, {"qualifiedName":"SDOK_DOCID","ddicName":"SDOK_DOCID","description":"SDOK_DOCID"})}, "SDOKOBJECT", "SDOKOBJECT", {}, {}), "class": new abap.types.Character(10, {"qualifiedName":"SDOK_CLASS","ddicName":"SDOK_CLASS","description":"SDOK_CLASS"}), "objid": new abap.types.Character(32, {"qualifiedName":"SDOK_DOCID","ddicName":"SDOK_DOCID","description":"SDOK_DOCID"})}, "SKWF_IO", "SKWF_IO", {}, {});
    let e_language = INPUT?.e_language || new abap.types.Character(1, {"qualifiedName":"LANGU","ddicName":"LANGU","description":"LANGU"});
    let e_phio_last_changed = INPUT?.e_phio_last_changed || new abap.types.String({qualifiedName: "STRING"});
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
  }
  async if_mr_api$get_io_for_url(INPUT) {
    let i_url = INPUT?.i_url;
    let e_is_folder = INPUT?.e_is_folder || new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    let e_loio = INPUT?.e_loio || new abap.types.Structure({"objtype": new abap.types.Character(1, {"qualifiedName":"SKWF_IOTY","ddicName":"SKWF_IOTY","description":"SKWF_IOTY"}), "object": new abap.types.Structure({"class": new abap.types.Character(10, {"qualifiedName":"SDOK_CLASS","ddicName":"SDOK_CLASS","description":"SDOK_CLASS"}), "objid": new abap.types.Character(32, {"qualifiedName":"SDOK_DOCID","ddicName":"SDOK_DOCID","description":"SDOK_DOCID"})}, "SDOKOBJECT", "SDOKOBJECT", {}, {}), "class": new abap.types.Character(10, {"qualifiedName":"SDOK_CLASS","ddicName":"SDOK_CLASS","description":"SDOK_CLASS"}), "objid": new abap.types.Character(32, {"qualifiedName":"SDOK_DOCID","ddicName":"SDOK_DOCID","description":"SDOK_DOCID"})}, "SKWF_IO", "SKWF_IO", {}, {});
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
  }
}
abap.Classes['CL_MIME_REPOSITORY_API'] = cl_mime_repository_api;
export {cl_mime_repository_api};
//# sourceMappingURL=cl_mime_repository_api.clas.mjs.map