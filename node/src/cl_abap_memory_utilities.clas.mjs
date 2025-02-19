const {cx_root} = await import("./cx_root.clas.mjs");
// cl_abap_memory_utilities.clas.abap
class cl_abap_memory_utilities {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CL_ABAP_MEMORY_UTILITIES';
  static IMPLEMENTED_INTERFACES = [];
  static ATTRIBUTES = {};
  static METHODS = {"GET_MEMORY_SIZE_OF_OBJECT": {"visibility": "U", "parameters": {"OBJECT": {"type": () => {return new abap.types.Character(4);}, "is_optional": " "}, "BOUND_SIZE_ALLOC": {"type": () => {return new abap.types.Packed({length: 20, decimals: 0, qualifiedName: "ABAP_MSIZE"});}, "is_optional": " "}, "BOUND_SIZE_USED": {"type": () => {return new abap.types.Packed({length: 20, decimals: 0, qualifiedName: "ABAP_MSIZE"});}, "is_optional": " "}, "REFERENCED_SIZE_ALLOC": {"type": () => {return new abap.types.Packed({length: 20, decimals: 0, qualifiedName: "ABAP_MSIZE"});}, "is_optional": " "}, "REFERENCED_SIZE_USED": {"type": () => {return new abap.types.Packed({length: 20, decimals: 0, qualifiedName: "ABAP_MSIZE"});}, "is_optional": " "}, "IS_PART_OF_NON_TRIVIAL_SZK": {"type": () => {return new abap.types.Character();}, "is_optional": " "}, "SZK_SIZE_ALLOC": {"type": () => {return new abap.types.Packed({length: 20, decimals: 0, qualifiedName: "ABAP_MSIZE"});}, "is_optional": " "}, "SZK_SIZE_USED": {"type": () => {return new abap.types.Packed({length: 20, decimals: 0, qualifiedName: "ABAP_MSIZE"});}, "is_optional": " "}, "LOW_MEM": {"type": () => {return new abap.types.Character();}, "is_optional": " "}, "IS_IN_SHARED_MEMORY": {"type": () => {return new abap.types.Character();}, "is_optional": " "}, "SIZEOF_ALLOC": {"type": () => {return new abap.types.Packed({length: 20, decimals: 0, qualifiedName: "ABAP_MSIZE"});}, "is_optional": " "}, "SIZEOF_USED": {"type": () => {return new abap.types.Packed({length: 20, decimals: 0, qualifiedName: "ABAP_MSIZE"});}, "is_optional": " "}}},
  "GET_PEAK_USED_SIZE": {"visibility": "U", "parameters": {"SIZE": {"type": () => {return new abap.types.Packed({length: 20, decimals: 0, qualifiedName: "ABAP_MSIZE"});}, "is_optional": " "}}},
  "GET_TOTAL_USED_SIZE": {"visibility": "U", "parameters": {"SIZE": {"type": () => {return new abap.types.Packed({length: 20, decimals: 0, qualifiedName: "ABAP_MSIZE"});}, "is_optional": " "}}},
  "DO_GARBAGE_COLLECTION": {"visibility": "U", "parameters": {}}};
  constructor() {
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
  }
  async constructor_(INPUT) {
    if (super.constructor_) { await super.constructor_(INPUT); }
    return this;
  }
  async get_total_used_size(INPUT) {
    return cl_abap_memory_utilities.get_total_used_size(INPUT);
  }
  static async get_total_used_size(INPUT) {
    let size = INPUT?.size || new abap.types.Packed({length: 20, decimals: 0, qualifiedName: "ABAP_MSIZE"});
    return;
  }
  async do_garbage_collection() {
    return cl_abap_memory_utilities.do_garbage_collection();
  }
  static async do_garbage_collection() {
    return;
  }
  async get_peak_used_size(INPUT) {
    return cl_abap_memory_utilities.get_peak_used_size(INPUT);
  }
  static async get_peak_used_size(INPUT) {
    let size = INPUT?.size || new abap.types.Packed({length: 20, decimals: 0, qualifiedName: "ABAP_MSIZE"});
    return;
  }
  async get_memory_size_of_object(INPUT) {
    return cl_abap_memory_utilities.get_memory_size_of_object(INPUT);
  }
  static async get_memory_size_of_object(INPUT) {
    let object = INPUT?.object;
    let bound_size_alloc = INPUT?.bound_size_alloc || new abap.types.Packed({length: 20, decimals: 0, qualifiedName: "ABAP_MSIZE"});
    let bound_size_used = INPUT?.bound_size_used || new abap.types.Packed({length: 20, decimals: 0, qualifiedName: "ABAP_MSIZE"});
    let referenced_size_alloc = INPUT?.referenced_size_alloc || new abap.types.Packed({length: 20, decimals: 0, qualifiedName: "ABAP_MSIZE"});
    let referenced_size_used = INPUT?.referenced_size_used || new abap.types.Packed({length: 20, decimals: 0, qualifiedName: "ABAP_MSIZE"});
    let is_part_of_non_trivial_szk = INPUT?.is_part_of_non_trivial_szk || new abap.types.Character();
    let szk_size_alloc = INPUT?.szk_size_alloc || new abap.types.Packed({length: 20, decimals: 0, qualifiedName: "ABAP_MSIZE"});
    let szk_size_used = INPUT?.szk_size_used || new abap.types.Packed({length: 20, decimals: 0, qualifiedName: "ABAP_MSIZE"});
    let low_mem = INPUT?.low_mem || new abap.types.Character();
    let is_in_shared_memory = INPUT?.is_in_shared_memory || new abap.types.Character();
    let sizeof_alloc = INPUT?.sizeof_alloc || new abap.types.Packed({length: 20, decimals: 0, qualifiedName: "ABAP_MSIZE"});
    let sizeof_used = INPUT?.sizeof_used || new abap.types.Packed({length: 20, decimals: 0, qualifiedName: "ABAP_MSIZE"});
    return;
  }
}
abap.Classes['CL_ABAP_MEMORY_UTILITIES'] = cl_abap_memory_utilities;
export {cl_abap_memory_utilities};
//# sourceMappingURL=cl_abap_memory_utilities.clas.mjs.map